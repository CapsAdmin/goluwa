local serializer = ...

local simple = {}

function simple.Encode(tbl)
	local str = {}

	for k, v in pairs(tbl) do
		table.insert(str, tostring(k))
		table.insert(str, "=")
		table.insert(str, tostring(v))
		table.insert(str, "\n")
	end

	return table.concat(str)
end

function simple.Decode(str)
	local out = {}

	for k, v in str:gmatch("(.-)=(.-)\n") do
		out[fromstring(k)] = fromstring(v)
	end

	return out
end

serializer.AddLibrary("simple", function(...) return simple.Encode(...) end, function(...) return simple.Decode(...) end, simple)
