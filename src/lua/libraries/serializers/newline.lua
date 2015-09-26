local serializer = ...
local newline = {}

function newline.Encode(tbl)
	local str = {}

	for i, v in ipairs(tbl) do
		table.insert(str, tostring(v))
	end

	return table.concat(str)
end

function newline.Decode(str)
	local out = {}

	str = str:gsub("\r\n", "\n") .. "\n"

	for v in str:gmatch("(.-)\n") do
		table.insert(out, fromstring(v))
	end

	return out
end

serializer.AddLibrary("newline", function(...) return newline.Encode(...) end, function(...) return newline.Decode(...) end, newline)
