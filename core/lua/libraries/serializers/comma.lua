local serializer = ...
local comma = {}

function comma.Encode(tbl)
	local str = {}

	for i, v in ipairs(tbl) do
		if type(v) ~= "string" then
			list.insert(str, serializer.GetLibrary("luadata").Encode(v))
		else
			list.insert(str, v)
		end
	end

	return list.concat(str, ",")
end

function comma.Decode(str)
	local out = {}

	for i, v in ipairs(str:split(",")) do
		out[i] = from_string(v:trim())
	end

	return out
end

serializer.AddLibrary(
	"comma",
	function(simple, ...)
		return comma.Encode(...)
	end,
	function(simple, ...)
		return comma.Decode(...)
	end,
	comma
)