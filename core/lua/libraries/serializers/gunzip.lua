local serializer = ...
serializer.AddLibrary("gunzip", nil, function(gz, str)
	local out = {}
	local i = 1

	gz.gunzip({input = str, output = function(byte)
		out[i] = string.char(byte)
		i = i + 1
	end, disable_crc = true})

	return table.concat(out)
end, desire("deflatelua"))