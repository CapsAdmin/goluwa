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
		if v ~= "" then
			table.insert(out, fromstring(v))
		end
	end

	return out
end

serializer.AddLibrary(
	"newline",
	function(simple, ...) return newline.Encode(...) end,
	function(simple, ...) return newline.Decode(...) end,
	newline
)
