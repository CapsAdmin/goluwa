local serializer = ...
local gz = require("deflatelua")
serializer.AddLibrary("gunzip", nil, function(str)
	local out = {}
	local i = 1

	gz.gunzip({input = str, output = function(byte)
		out[i] = string.char(byte)
		i = i + 1
	end, disable_crc = true})

	return table.concat(out)
end, gz)