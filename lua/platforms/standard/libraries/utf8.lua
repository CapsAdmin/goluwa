local utf8 = {}

local math_floor = math.floor

-- a lot of this was taken from 
-- http://cakesaddons.googlecode.com/svn/trunk/glib/lua/glib/unicode/utf8.lua

function utf8.byte(char, offset)
	if char == "" then return -1 end
	offset = offset or 1
	
	local byte = char:byte(offset)
	local length = 1
	if byte >= 128 then
		if byte >= 240 then
			-- 4 byte sequence
			length = 4
			if #char < 4 then return -1, length end
			byte = (byte % 8) * 262144
			byte = byte + (char:byte(offset + 1) % 64) * 4096
			byte = byte + (char:byte(offset + 2) % 64) * 64
			byte = byte + (char:byte(offset + 3) % 64)
		elseif byte >= 224 then
			-- 3 byte sequence
			length = 3
			if #char < 3 then return -1, length end
			byte = (byte % 16) * 4096
			byte = byte + (char:byte(offset + 1) % 64) * 64
			byte = byte + (char:byte(offset + 2) % 64)
		elseif byte >= 192 then
			-- 2 byte sequence
			length = 2
			if #char < 2 then return -1, length end
			byte = (byte % 32) * 64
			byte = byte + (char:byte(offset + 1) % 64)
		else
			-- invalid sequence
			byte = -1
		end
	end
	return byte, length
end

function utf8.char(byte)
	local utf8 = ""
	
	if byte <= 127 then
		utf8 = string.char(byte)
	elseif byte < 2048 then
		utf8 = ("%c%c"):format(
			192 + math_floor(byte / 64), 
			128 + (byte % 64)
		)
	elseif byte < 65536 then
		utf8 = ("%c%c%c"):format(
			224 + math_floor(byte / 4096),   
			128 + (math_floor(byte / 64) % 64),   
			128 + (byte % 64)
		)
	elseif byte < 2097152 then
		utf8 = ("%c%c%c%c"):format(
			240 + math_floor(byte / 262144), 
			128 + (math_floor(byte / 4096) % 64), 
			128 + (math_floor(byte / 64) % 64), 
			128 + (byte % 64)
		)
	end
	
	return utf8
end

function utf8.length(str)
	local _, length = str:gsub("[^\128-\191]", "")
	return length
end

function utf8.totable(str)
	local tbl = {}
	
	for uchar in str:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
		tbl[#tbl + 1] = uchar
	end
	
	return tbl
end

return utf8