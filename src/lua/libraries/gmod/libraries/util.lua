local util = gine.env.util

function util.KeyValuesToTable(str)
	local tbl, ok = utility.VDFToTable(str, true)
	if not tbl then
		llog(ok)
		return {}
	end
	local key, val = next(tbl)
	return val
end

function util.CRC(str)
	return crypto.CRC32(tostring(str))
end

function util.RelativePathToFull(path)
	return R(path)
end

function util.JSONToTable(str)
	return serializer.Decode("json", str)
end

function util.TableToJSON(tbl)
	return serializer.Encode("json", tbl)
end

function util.SteamIDTo64(str)
	return steam.SteamIDToCommunityID(str)
end
