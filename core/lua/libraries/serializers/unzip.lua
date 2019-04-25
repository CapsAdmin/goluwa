local ffi = require("ffi")

local serializer = ...

local deflate

do
	local BTYPE_NO_COMPRESSION = 0
	local BTYPE_FIXED_HUFFMAN = 1
	local BTYPE_DYNAMIC_HUFFMAN = 2

	local tdecode_len_base
	do
		local t = {[257]=3}
		local skip = 1
		for i=258,285,4 do
			for j=i,i+3 do t[j] = t[j-1] + skip end
			if i ~= 258 then skip = skip * 2 end
		end
		t[285] = 258
		tdecode_len_base = t
	end

	local tdecode_len_nextrabits
	do
		local t = {}
		for i=257,285 do
			local j = math.max(i - 261, 0)
			t[i] = bit.rshift(j, 2)
		end
		t[285] = 0
		tdecode_len_nextrabits = t
	end

	local tdecode_dist_base
	do
		local t = {[0]=1}
		local skip = 1
		for i=1,29,2 do
			for j=i,i+1 do t[j] = t[j-1] + skip end
			if i ~= 1 then skip = skip * 2 end
		end
		tdecode_dist_base = t
	end

	local tdecode_dist_nextrabits
	do
		local t = {}
		for i=0,29 do
			local j = math.max(i - 2, 0)
			t[i] = bit.rshift(j, 1)
		end
		tdecode_dist_nextrabits = t
	end

	local function sort_huffman(a,b)
		return a.nbits == b.nbits and a.val < b.val or a.nbits < b.nbits
	end

	local function gen_huffman_table(init)
		local t = {}
		for i=1, #init-2, 2 do
			local firstval, nbits, nextval = init[i], init[i+1], init[i+2]
			for val = firstval, nextval-1 do
				table.insert(t, {val = val, nbits = nbits})
			end
		end
		table.sort(t, sort_huffman)
		return t
	end

	local huffman_dist_table = gen_huffman_table({0,5, 32,nil})
	local huffman_list_table = gen_huffman_table({0,8, 144,9, 256,7, 280,8, 288,nil})
	local codelen_vals = {16, 17, 18, 0, 8, 7, 9, 6, 10, 5, 11, 4, 12, 3, 13, 2, 14, 1, 15}

	local function read_bit_stream(look, bs)
		local code = 1 -- leading 1 marker
		for _ = 1, 16 do
			code = code * 2 + bs:ReadBits(1)
			local val = look[code]
			if val then
				return val
			end
		end
	end

	local function HuffmanTable(t)
		local look = {}

		-- assign codes
		local code = 1	-- leading 1 marker
		local nbits = 0

		for _,s in ipairs(t) do
			if s.nbits ~= nbits then
				code = code * 2^(s.nbits - nbits)
				nbits = s.nbits
			end

			look[code] = s.val

			code = code + 1
		end

		return look
	end

	local function decode(bs, ncodes, codelentable)
		local init = {}
		local nbits
		local val = 0
		local i2 = 1

		for _ = 1, 256 do
			if val >= ncodes then break end
			local codelen = read_bit_stream(codelentable, bs)
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
			end

			for _ = 1, nrepeat do
				if nbits ~= 0 then
					init[i2] = {nbits = nbits, val = val}
					i2 = i2 + 1
				end
				val = val + 1
			end

			if val >= ncodes then break end
		end

		table.sort(init, sort_huffman)

		return HuffmanTable(init)
	end

	local function output(outstate, byte)
		local window_pos = outstate.window_pos
		outstate.string_buffer[outstate.byte_pos] = byte
		outstate.byte_pos = outstate.byte_pos + 1
		outstate.window[window_pos] = byte
		outstate.window_pos = window_pos % 32768 + 1	-- 32K
	end

	function deflate(bs, string_buffer)
		bs:RestartReadBits()

		local outstate = {}
		outstate.byte_pos = 0
		outstate.string_buffer = string_buffer
		outstate.window = {}
		outstate.window_pos = 1

		for _ = 1, math.huge do
			local bfinal = bs:ReadBits(1)
			local btype = bs:ReadBits(2)

			if btype == BTYPE_NO_COMPRESSION then
				bs:ReadBits(bs:BitsLeftInByte())
				local len = bs:ReadBits(16)
				local nlen_ = bs:ReadBits(16)

				for _ = 1, len do
					output(outstate, bs:ReadBits(8))
				end
			elseif btype == BTYPE_FIXED_HUFFMAN or btype == BTYPE_DYNAMIC_HUFFMAN then
				local littable
				local disttable
				if btype == BTYPE_DYNAMIC_HUFFMAN then
					local hlit = bs:ReadBits(5)	-- # of literal/length codes - 257
					local hdist = bs:ReadBits(5) -- # of distance codes - 1
					local hclen = bs:ReadBits(4) -- # of code length codes - 4


					local codelen_init = {}
					local i2 = 1
					for i = 1, hclen + 4 do
						local nbits = bs:ReadBits(3)
						if nbits ~= 0 then
							local val = codelen_vals[i]
							codelen_init[i2] = {val = val, nbits = nbits}
							i2 = i2 + 1
						end
					end
					table.sort(codelen_init, sort_huffman)

					local codelentable = HuffmanTable(codelen_init)
					littable = decode(bs, hlit + 257, codelentable)
					disttable = decode(bs, hdist + 1, codelentable)
				else
					littable = HuffmanTable(huffman_list_table)
					disttable = HuffmanTable(huffman_dist_table)
				end

				for _ = 1, math.huge do
					local val = read_bit_stream(littable, bs)
					if val < 256 then -- literal
						output(outstate, val)
					elseif val == 256 then -- end of block
						break
					else
						local extrabits = bs:ReadBits(tdecode_len_nextrabits[val])
						local dist_val = read_bit_stream(disttable, bs)
						local dist_extrabits = bs:ReadBits(tdecode_dist_nextrabits[dist_val])
						local dist = tdecode_dist_base[dist_val] + dist_extrabits

						for _ = 1, tdecode_len_base[val] + extrabits do
							local pos = (outstate.window_pos - 1 - dist) % 32768 + 1	-- 32K
							output(outstate, outstate.window[pos])
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

local zip = {}

function zip.Decode(str)
	local name = os.tmpname()
	vfs.Write(name, str)
	local zip = file.Open(name)

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
					if false then
						zip:Advance(data.compressed_size)
					else
						local out = ffi.new("uint8_t[?]", data.uncompressed_size)
						local t = system.GetTime()
						deflate(zip, out)
						data.deflate_time = system.GetTime() - t
						data.file_content = ffi.string(out, data.uncompressed_size)
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

	for _, data in ipairs(archive.files) do
		if data.file_content then
			if crypto.CRC32(data.file_content) ~= tostring(data.crc) then
				table.print(data)
				error("crc ("..crypto.CRC32(data.file_content)..") does not match "..data.crc.."!")
			end
		end
	end

	return archive
end

serializer.AddLibrary(
	"luaunzip",
	nil,
	function(simple, ...) return zip.Decode(...) end,
	zip
)