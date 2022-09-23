local crypto = _G.crypto or {}

do
	-- https://github.com/lancelijade/qqwry.lua/blob/master/crc32.lua#L133
	local CRC32 = {
		0x00000000,
		0x77073096,
		0xee0e612c,
		0x990951ba,
		0x076dc419,
		0x706af48f,
		0xe963a535,
		0x9e6495a3,
		0x0edb8832,
		0x79dcb8a4,
		0xe0d5e91e,
		0x97d2d988,
		0x09b64c2b,
		0x7eb17cbd,
		0xe7b82d07,
		0x90bf1d91,
		0x1db71064,
		0x6ab020f2,
		0xf3b97148,
		0x84be41de,
		0x1adad47d,
		0x6ddde4eb,
		0xf4d4b551,
		0x83d385c7,
		0x136c9856,
		0x646ba8c0,
		0xfd62f97a,
		0x8a65c9ec,
		0x14015c4f,
		0x63066cd9,
		0xfa0f3d63,
		0x8d080df5,
		0x3b6e20c8,
		0x4c69105e,
		0xd56041e4,
		0xa2677172,
		0x3c03e4d1,
		0x4b04d447,
		0xd20d85fd,
		0xa50ab56b,
		0x35b5a8fa,
		0x42b2986c,
		0xdbbbc9d6,
		0xacbcf940,
		0x32d86ce3,
		0x45df5c75,
		0xdcd60dcf,
		0xabd13d59,
		0x26d930ac,
		0x51de003a,
		0xc8d75180,
		0xbfd06116,
		0x21b4f4b5,
		0x56b3c423,
		0xcfba9599,
		0xb8bda50f,
		0x2802b89e,
		0x5f058808,
		0xc60cd9b2,
		0xb10be924,
		0x2f6f7c87,
		0x58684c11,
		0xc1611dab,
		0xb6662d3d,
		0x76dc4190,
		0x01db7106,
		0x98d220bc,
		0xefd5102a,
		0x71b18589,
		0x06b6b51f,
		0x9fbfe4a5,
		0xe8b8d433,
		0x7807c9a2,
		0x0f00f934,
		0x9609a88e,
		0xe10e9818,
		0x7f6a0dbb,
		0x086d3d2d,
		0x91646c97,
		0xe6635c01,
		0x6b6b51f4,
		0x1c6c6162,
		0x856530d8,
		0xf262004e,
		0x6c0695ed,
		0x1b01a57b,
		0x8208f4c1,
		0xf50fc457,
		0x65b0d9c6,
		0x12b7e950,
		0x8bbeb8ea,
		0xfcb9887c,
		0x62dd1ddf,
		0x15da2d49,
		0x8cd37cf3,
		0xfbd44c65,
		0x4db26158,
		0x3ab551ce,
		0xa3bc0074,
		0xd4bb30e2,
		0x4adfa541,
		0x3dd895d7,
		0xa4d1c46d,
		0xd3d6f4fb,
		0x4369e96a,
		0x346ed9fc,
		0xad678846,
		0xda60b8d0,
		0x44042d73,
		0x33031de5,
		0xaa0a4c5f,
		0xdd0d7cc9,
		0x5005713c,
		0x270241aa,
		0xbe0b1010,
		0xc90c2086,
		0x5768b525,
		0x206f85b3,
		0xb966d409,
		0xce61e49f,
		0x5edef90e,
		0x29d9c998,
		0xb0d09822,
		0xc7d7a8b4,
		0x59b33d17,
		0x2eb40d81,
		0xb7bd5c3b,
		0xc0ba6cad,
		0xedb88320,
		0x9abfb3b6,
		0x03b6e20c,
		0x74b1d29a,
		0xead54739,
		0x9dd277af,
		0x04db2615,
		0x73dc1683,
		0xe3630b12,
		0x94643b84,
		0x0d6d6a3e,
		0x7a6a5aa8,
		0xe40ecf0b,
		0x9309ff9d,
		0x0a00ae27,
		0x7d079eb1,
		0xf00f9344,
		0x8708a3d2,
		0x1e01f268,
		0x6906c2fe,
		0xf762575d,
		0x806567cb,
		0x196c3671,
		0x6e6b06e7,
		0xfed41b76,
		0x89d32be0,
		0x10da7a5a,
		0x67dd4acc,
		0xf9b9df6f,
		0x8ebeeff9,
		0x17b7be43,
		0x60b08ed5,
		0xd6d6a3e8,
		0xa1d1937e,
		0x38d8c2c4,
		0x4fdff252,
		0xd1bb67f1,
		0xa6bc5767,
		0x3fb506dd,
		0x48b2364b,
		0xd80d2bda,
		0xaf0a1b4c,
		0x36034af6,
		0x41047a60,
		0xdf60efc3,
		0xa867df55,
		0x316e8eef,
		0x4669be79,
		0xcb61b38c,
		0xbc66831a,
		0x256fd2a0,
		0x5268e236,
		0xcc0c7795,
		0xbb0b4703,
		0x220216b9,
		0x5505262f,
		0xc5ba3bbe,
		0xb2bd0b28,
		0x2bb45a92,
		0x5cb36a04,
		0xc2d7ffa7,
		0xb5d0cf31,
		0x2cd99e8b,
		0x5bdeae1d,
		0x9b64c2b0,
		0xec63f226,
		0x756aa39c,
		0x026d930a,
		0x9c0906a9,
		0xeb0e363f,
		0x72076785,
		0x05005713,
		0x95bf4a82,
		0xe2b87a14,
		0x7bb12bae,
		0x0cb61b38,
		0x92d28e9b,
		0xe5d5be0d,
		0x7cdcefb7,
		0x0bdbdf21,
		0x86d3d2d4,
		0xf1d4e242,
		0x68ddb3f8,
		0x1fda836e,
		0x81be16cd,
		0xf6b9265b,
		0x6fb077e1,
		0x18b74777,
		0x88085ae6,
		0xff0f6a70,
		0x66063bca,
		0x11010b5c,
		0x8f659eff,
		0xf862ae69,
		0x616bffd3,
		0x166ccf45,
		0xa00ae278,
		0xd70dd2ee,
		0x4e048354,
		0x3903b3c2,
		0xa7672661,
		0xd06016f7,
		0x4969474d,
		0x3e6e77db,
		0xaed16a4a,
		0xd9d65adc,
		0x40df0b66,
		0x37d83bf0,
		0xa9bcae53,
		0xdebb9ec5,
		0x47b2cf7f,
		0x30b5ffe9,
		0xbdbdf21c,
		0xcabac28a,
		0x53b39330,
		0x24b4a3a6,
		0xbad03605,
		0xcdd70693,
		0x54de5729,
		0x23d967bf,
		0xb3667a2e,
		0xc4614ab8,
		0x5d681b02,
		0x2a6f2b94,
		0xb40bbe37,
		0xc30c8ea1,
		0x5a05df1b,
		0x2d02ef8d,
	}
	local xor = bit.bxor
	local lshift = bit.lshift
	local rshift = bit.rshift
	local band = bit.band
	local cache = table.weak()

	function crypto.CRC32(val)
		if cache[val] then return cache[val] end

		local str = tostring(val)
		local count = string.len(str)
		local crc = 2 ^ 32 - 1
		local i = 1

		while count > 0 do
			local byte = string.byte(str, i)
			crc = xor(rshift(crc, 8), CRC32[xor(band(crc, 0xFF), byte) + 1])
			i = i + 1
			count = count - 1
		end

		crc = xor(crc, 0xFFFFFFFF)

		-- dirty hack for bitop return number < 0
		if crc < 0 then crc = crc + 2 ^ 32 end

		cache[val] = tostring(crc)
		return cache[val]
	end
end

do
	-- Lua 5.1+ base64 v3.0 (c) 2009 by Alex Kloss <alexthkloss@web.de>
	-- licensed under the terms of the LGPL2
	-- character table string
	local b = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"

	-- encoding
	function crypto.Base64Encode(data)
		return (
				(
					data:gsub(".", function(x)
						local r, b = "", x:byte()

						for i = 8, 1, -1 do
							r = r .. (b % 2 ^ i - b % 2 ^ (i - 1) > 0 and "1" or "0")
						end

						return r
					end) .. "0000"
				):gsub("%d%d%d?%d?%d?%d?", function(x)
					if (#x < 6) then return "" end

					local c = 0

					for i = 1, 6 do
						c = c + (x:sub(i, i) == "1" and 2 ^ (6 - i) or 0)
					end

					return b:sub(c + 1, c + 1)
				end) .. (
					{"", "==", "="}
				)[#data % 3 + 1]
			)
	end

	-- decoding
	function crypto.Base64Decode(data)
		data = string.gsub(data, "[^" .. b .. "=]", "")
		return (
			data:gsub(".", function(x)
				if (x == "=") then return "" end

				local r, f = "", (b:find(x) - 1)

				for i = 6, 1, -1 do
					r = r .. (f % 2 ^ i - f % 2 ^ (i - 1) > 0 and "1" or "0")
				end

				return r
			end):gsub("%d%d%d?%d?%d?%d?%d?%d?", function(x)
				if (#x ~= 8) then return "" end

				local c = 0

				for i = 1, 8 do
					c = c + (x:sub(i, i) == "1" and 2 ^ (8 - i) or 0)
				end

				return string.char(c)
			end)
		)
	end
end

do
	local read_n_bytes = function(str, pos, n)
		pos = pos or 1
		return pos + n, string.byte(str, pos, pos + n - 1)
	end
	local write_int32 = function(v)
		return string.char(
			bit.band(bit.rshift(v, 24), 0xFF),
			bit.band(bit.rshift(v, 16), 0xFF),
			bit.band(bit.rshift(v, 8), 0xFF),
			bit.band(v, 0xFF)
		)
	end
	local read_int32 = function(str, pos)
		local new_pos, a, b, c, d = read_n_bytes(str, pos, 4)
		return new_pos, bit.lshift(a, 24) + bit.lshift(b, 16) + bit.lshift(c, 8) + d
	end

	function crypto.SHA1(msg)
		local h0 = 0x67452301
		local h1 = 0xEFCDAB89
		local h2 = 0x98BADCFE
		local h3 = 0x10325476
		local h4 = 0xC3D2E1F0
		local bits = #msg * 8
		-- append b10000000
		msg = msg .. string.char(0x80)
		-- 64 bit length will be appended
		local bytes = #msg + 8
		-- 512 bit append stuff
		local fill_bytes = 64 - (bytes % 64)

		if fill_bytes ~= 64 then msg = msg .. string.rep(string.char(0), fill_bytes) end

		-- append 64 big endian length
		local high = math.floor(bits / 2 ^ 32)
		local low = bits - high * 2 ^ 32
		msg = msg .. write_int32(high) .. write_int32(low)
		assert(#msg % 64 == 0, #msg % 64)

		for j = 1, #msg, 64 do
			local chunk = msg:sub(j, j + 63)
			assert(#chunk == 64, #chunk)
			local words = {}
			local next = 1
			local word

			repeat
				next, word = read_int32(chunk, next)
				list.insert(words, word)			
			until next > 64

			assert(#words == 16)

			for i = 17, 80 do
				words[i] = bit.bxor(words[i - 3], words[i - 8], words[i - 14], words[i - 16])
				words[i] = bit.rol(words[i], 1)
			end

			local a = h0
			local b = h1
			local c = h2
			local d = h3
			local e = h4

			for i = 1, 80 do
				local k, f

				if i > 0 and i < 21 then
					f = bit.bor(bit.band(b, c), bit.band(bit.bnot(b), d))
					k = 0x5A827999
				elseif i > 20 and i < 41 then
					f = bit.bxor(b, c, d)
					k = 0x6ED9EBA1
				elseif i > 40 and i < 61 then
					f = bit.bor(bit.band(b, c), bit.band(b, d), bit.band(c, d))
					k = 0x8F1BBCDC
				elseif i > 60 and i < 81 then
					f = bit.bxor(b, c, d)
					k = 0xCA62C1D6
				end

				local temp = bit.rol(a, 5) + f + e + k + words[i]
				e = d
				d = c
				c = bit.rol(b, 30)
				b = a
				a = temp
			end

			h0 = h0 + a
			h1 = h1 + b
			h2 = h2 + c
			h3 = h3 + d
			h4 = h4 + e
		end

		-- necessary on sizeof(int) == 32 machines
		h0 = bit.band(h0, 0xffffffff)
		h1 = bit.band(h1, 0xffffffff)
		h2 = bit.band(h2, 0xffffffff)
		h3 = bit.band(h3, 0xffffffff)
		h4 = bit.band(h4, 0xffffffff)
		return write_int32(h0) .. write_int32(h1) .. write_int32(h2) .. write_int32(h3) .. write_int32(h4)
	end
end

return crypto