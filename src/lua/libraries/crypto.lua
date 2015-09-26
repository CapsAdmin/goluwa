local crypto = _G.crypto or {}

do
	local ffi = require "ffi"
	local bit = require "bit"
	local band = bit.band
	local bxor = bit.bxor
	local bnot = bit.bnot

	local rshift = bit.rshift

	-- Karl Malbrain's compact CRC-32.
	-- See "A compact CCITT crc16 and crc32 C implementation that balances processor cache usage against speed":
	-- http://www.geocities.ws/malbrain/

	--
	local s_crc32 = ffi.new("const uint32_t[16]", {
		0x00000000, 0x1db71064, 0x3b6e20c8, 0x26d930ac,
		0x76dc4190, 0x6b6b51f4, 0x4db26158, 0x5005713c,
		0xedb88320, 0xf00f9344, 0xd6d6a3e8, 0xcb61b38c,
		0x9b64c2b0, 0x86d3d2d4, 0xa00ae278, 0xbdbdf21c
	});

	function mz_crc32(buff, buf_len)

	end

	function crypto.CRC32(src, len)

		if not len then
			if type(src) == "string" then
				len = #src
			elseif type(src) == "cdata" then
				len = ffi.sizeof(src)
			end
		end

		if not len then return nil end

		local crcu32 = 0ULL
		local ptr = ffi.cast("const uint8_t *", src)

		if ptr == nil then
			return 0
		end

		crcu32 = bnot(crcu32);

		while len > 0 do
			local b = ptr[0];

			crcu32 = bxor(rshift(crcu32, 4), s_crc32[bxor(band(crcu32, 0xF), band(b, 0xF))])
			crcu32 = bxor(rshift(crcu32, 4), s_crc32[bxor(band(crcu32, 0xF), rshift(b, 4))])

			ptr = ptr + 1
			len = len - 1
		end

		crcu32 = bnot(crcu32)

		return tostring(crcu32):sub(0, -4) -- asdf
	end
end

-- Lua 5.1+ base64 v3.0 (c) 2009 by Alex Kloss <alexthkloss@web.de>
-- licensed under the terms of the LGPL2

-- character table string
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- encoding
function crypto.Base64Encode(data)
	return ((data:gsub('.', function(x)
		local r,b='',x:byte()
		for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
		return r;
	end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then return '' end
		local c=0
		for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
		return b:sub(c+1,c+1)
	end)..({ '', '==', '=' })[#data%3+1])
end

-- decoding
function crypto.Base64Decode(data)
	data = string.gsub(data, '[^'..b..'=]', '')
	return (data:gsub('.', function(x)
		if (x == '=') then return '' end
		local r,f='',(b:find(x)-1)
		for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
		return r;
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if (#x ~= 8) then return '' end
		local c=0
		for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
		return string.char(c)
	end))
end

return crypto