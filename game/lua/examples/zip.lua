local ffi = require("ffi") -- not needed

local inflate

do
	local function sort(a,b)
		return a.nbits == b.nbits and a.val < b.val or a.nbits < b.nbits
	end

	local function msb(bits, nbits)
		local res = 0
		for i=1,nbits do
			res = bit.lshift(res, 1) + bit.band(bits, 1)
			bits = bit.rshift(bits, 1)
		end
		return res
	end

	local function read_bit_stream(self, bs)
		local minbits = self.minbits
		local code = 1 -- leading 1 marker
		local nbits = 0
		while 1 do
			if nbits == 0 then	-- small optimization (optional)
				code = (2^minbits + msb(bs:ReadBits(minbits), minbits))
				nbits = nbits + minbits
			else
				local b = bs:ReadBits(1)
				nbits = nbits + 1
				code = code * 2 + b	 -- MSB first
			end
			local val = self.look[code]
			if val then
				return val
			end
		end
	end

	local function HuffmanTable(init, is_full)
		local t = {}
		if is_full then
			for val,nbits in pairs(init) do
				if nbits ~= 0 then
					t[#t+1] = {val=val, nbits=nbits}
					--debug('*',val,nbits)
				end
			end
		else
			for i=1,#init-2,2 do
				local firstval, nbits, nextval = init[i], init[i+1], init[i+2]
				--debug(val, nextval, nbits)
				if nbits ~= 0 then
					for val=firstval,nextval-1 do
						t[#t+1] = {val=val, nbits=nbits}
					end
				end
			end
		end
		table.sort(t, sort)

		-- assign codes
		local code = 1	-- leading 1 marker
		local nbits = 0
		for _,s in ipairs(t) do
			if s.nbits ~= nbits then
				code = code * 2^(s.nbits - nbits)
				nbits = s.nbits
			end
			s.code = code
			code = code + 1
		end

		local minbits = math.huge
		local look = {}
		for _,s in ipairs(t) do
			minbits = math.min(minbits, s.nbits)
			look[s.code] = s.val
		end

		t.minbits = minbits
		t.look = look
		t.ReadBitStream = read_bit_stream

		return t
	end

	local function decode(bs, ncodes, codelentable)
		local init = {}
		local nbits
		local val = 0
		while val < ncodes do
			local codelen = codelentable:ReadBitStream(bs)
			--FIX:check nil?
			local nrepeat
			if codelen <= 15 then
				nrepeat = 1
				nbits = codelen
				--debug('w', nbits)
			elseif codelen == 16 then
				nrepeat = 3 + bs:ReadBits(2)
				-- nbits unchanged
			elseif codelen == 17 then
				nrepeat = 3 + bs:ReadBits(3)
				nbits = 0
			elseif codelen == 18 then
				nrepeat = 11 + bs:ReadBits(7)
				nbits = 0
			else
				error 'ASSERT'
			end
			for i=1,nrepeat do
				init[val] = nbits
				val = val + 1
			end
		end
		return HuffmanTable(init, true)
	end

	local BTYPE_NO_COMPRESSION = 0
	local BTYPE_FIXED_HUFFMAN = 1
	local BTYPE_DYNAMIC_HUFFMAN = 2
	local BTYPE_RESERVED_ = 3

	local tdecode_len_base
	local tdecode_len_nextrabits
	local tdecode_dist_base
	local tdecode_dist_nextrabits

	local function output(outstate, byte)
		local window_pos = outstate.window_pos
		outstate.outbs(byte)
		outstate.window[window_pos] = byte
		outstate.window_pos = window_pos % 32768 + 1	-- 32K
	end

	function inflate(bs, on_read_byte)
		bs:RestartReadBits()

		local outstate = {}
		outstate.outbs = on_read_byte
		outstate.window = {}
		outstate.window_pos = 1

		for i = 1, math.huge do
			local bfinal = bs:ReadBits(1)
			local btype = bs:ReadBits(2)

			if btype == BTYPE_NO_COMPRESSION then
				bs:ReadBits(bs:BitsLeftInByte())
				local len = bs:ReadBits(16)
				local nlen_ = bs:ReadBits(16)

				for i = 1, len do
					output(outstate, bs:ReadBits(8))
				end
			elseif btype == BTYPE_FIXED_HUFFMAN or btype == BTYPE_DYNAMIC_HUFFMAN then
				local littable, disttable
				if btype == BTYPE_DYNAMIC_HUFFMAN then
					local hlit = bs:ReadBits(5)	-- # of literal/length codes - 257
					local hdist = bs:ReadBits(5) -- # of distance codes - 1
					local hclen = bs:ReadBits(4) -- # of code length codes - 4

					local ncodelen_codes = hclen + 4
					local codelen_init = {}
					local codelen_vals = {16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15}
					for i = 1, ncodelen_codes do
						local nbits = bs:ReadBits(3)
						local val = codelen_vals[i]
						codelen_init[val] = nbits
					end

					local nlit_codes = hlit + 257
					local ndist_codes = hdist + 1

					local codelentable = HuffmanTable(codelen_init, true)
					littable = decode(bs, nlit_codes, codelentable)
					disttable = decode(bs, ndist_codes, codelentable)
				else
					littable = HuffmanTable {0,8, 144,9, 256,7, 280,8, 288,nil}
					disttable = HuffmanTable {0,5, 32,nil}
				end

				for i = 1, math.huge do
					local val = littable:ReadBitStream(bs)
					--debug(val, val < 256 and string.char(val))
					if val < 256 then -- literal
						output(outstate, val)
					elseif val == 256 then -- end of block
						break
					else
						if not tdecode_len_base then
							local t = {[257]=3}
							local skip = 1
							for i=258,285,4 do
								for j=i,i+3 do t[j] = t[j-1] + skip end
								if i ~= 258 then skip = skip * 2 end
							end
							t[285] = 258
							tdecode_len_base = t
							--for i=257,285 do debug('T1',i,t[i]) end
						end
						if not tdecode_len_nextrabits then
							local t = {}
							for i=257,285 do
								local j = math.max(i - 261, 0)
								t[i] = bit.rshift(j, 2)
							end
							t[285] = 0
							tdecode_len_nextrabits = t
							--for i=257,285 do debug('T2',i,t[i]) end
						end
						local len_base = tdecode_len_base[val]
						local nextrabits = tdecode_len_nextrabits[val]
						local extrabits = bs:ReadBits(nextrabits)
						local len = len_base + extrabits

						if not tdecode_dist_base then
							local t = {[0]=1}
							local skip = 1
							for i=1,29,2 do
								for j=i,i+1 do t[j] = t[j-1] + skip end
								if i ~= 1 then skip = skip * 2 end
							end
							tdecode_dist_base = t
							--for i=0,29 do debug('T3',i,t[i]) end
						end
						if not tdecode_dist_nextrabits then
							local t = {}
							for i=0,29 do
								local j = math.max(i - 2, 0)
								t[i] = bit.rshift(j, 1)
							end
							tdecode_dist_nextrabits = t
							--for i=0,29 do debug('T4',i,t[i]) end
						end
						local dist_val = disttable:ReadBitStream(bs)
						local dist_base = tdecode_dist_base[dist_val]
						local dist_nextrabits = tdecode_dist_nextrabits[dist_val]
						local dist_extrabits = bs:ReadBits(dist_nextrabits)
						local dist = dist_base + dist_extrabits

						--debug('BACK', len, dist)
						for i=1,len do
							local pos = (outstate.window_pos - 1 - dist) % 32768 + 1	-- 32K
							output(outstate, assert(outstate.window[pos], 'invalid distance'))
						end
					end
				end
			else
				error("unrecognized compression type")
			end

			if bfinal ~= 0 then
				break
			end
		end
	end

end

local zip = vfs.Open("/home/caps/Downloads/goluwa-master-49d7bf9ea891a216eeb82821058a85b5b5673858.zip")

local archive = {files = {}, files2 = {}}

while true do
	local sig = zip:ReadString(4)

	if sig == "\x50\x4b\x03\x04" then -- local file headers

		local data = zip:ReadStructure([[
			uint16_t version;
			uint16_t flags;
			uint16_t compression;
			uint16_t modtime;
			uint16_t moddate;
			uint32_t crc;
			uint32_t compressed_size;
			uint32_t uncompressed_size;
			uint16_t filename_length;
			uint16_t extra_field_length;
		]])

		data.file_name = zip:ReadString(data.filename_length)
		data.extra_field_data = zip:ReadString(data.extra_field_length)

		if data.uncompressed_size == 0 then
			data.directory = true
		else
			if data.compressed_size == data.uncompressed_size then
				data.file_content = zip:ReadBytes(data.compressed_size)
			else
				local out = ffi.new("char[?]", data.uncompressed_size)
				local i = 0
				inflate(zip, function(byte)
					out[i] = byte
					i = i + 1
				end)
				data.file_content = ffi.string(out, data.uncompressed_size)

				print(data.file_name, utility.FormatFileSize(#data.file_content))

				if crypto.CRC32(data.file_content) ~= tostring(data.crc) then
					table.print(data)
					error("crc ("..crypto.CRC32(data.file_content)..") does not match "..data.crc.."!")
				end
			end
		end

		table.insert(archive.files, data)
	else
		do break end -- not needed
		if sig == "\x50\x4b\x01\x02" then -- central directory (not needed)
			local data = zip:ReadStructure([[
				uint16_t version;
				uint16_t version_needed;
				uint16_t flags;
				uint16_t compression;
				uint16_t modtime;
				uint16_t moddate;
				uint32_t crc;
				uint32_t compressed_size;
				uint32_t uncompressed_size;
				uint16_t filename_length;
				uint16_t extra_field_length;
				uint16_t file_comment_length;
				uint16_t disk_start;
				uint16_t internal_attribute;
				uint32_t external_attribute;
				uint32_t offset_of_local_header;
			]])

			data.file_name = zip:ReadString(data.filename_length)
			data.extra_field_data = zip:ReadString(data.extra_field_length)
			data.file_comment = zip:ReadString(data.file_comment_length)

			table.insert(archive.files2, data)
		elseif sig == "\x50\x4b\x05\x06" then -- end of central directory (not needed)
			local data = zip:ReadStructure([[
				uint16_t version;
				uint16_t disk_number;
				uint16_t disk_wcd;
				uint16_t disk_entries;
				uint16_t total_entries;
				uint32_t central_directory_size;
				uint32_t offset_of_cd_wrt_starting_disk;
				uint16_t comment_length;
			]])

			data.comment = zip:ReadBytes(data.comment_length)
			archive.central_directory = data

			assert(zip:GetSize() == zip:GetPosition(), "unexpected end of zip archive")
		end
	end
end

--table.print(archive)
