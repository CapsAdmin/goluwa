local util = gine.env.util

function util.KeyValuesToTable(str)
	local tbl, ok = utility.VDFToTable(str, true)
	if not tbl then
		llog(ok)
		return {}
	end
	local key, val = next(tbl)
	print(str, key, val, "?!?!")
	return val
end

function util.CRC(str)
	return crypto.CRC32(tostring(str))
end

function util.RelativePathToFull(path)
	if path == "." then path = "" end
	return R(path) or ""
end

function util.JSONToTable(str)
	local ok, res = pcall(serializer.Decode, "json", str)
	if ok then return res end
	wlog(res)
end

function util.TableToJSON(tbl)
	return serializer.Encode("json", tbl)
end

function util.SteamIDTo64(str)
	return steam.SteamIDToCommunityID(str)
end

function util.IsValidModel(path)
	return vfs.IsFile(path)
end

function util.IsValidRagdoll(ent)
	return false
end

function util.PointContents()
	return 0
end

function util.GetPixelVisibleHandle()
	return {}
end

function gine.env.LocalToWorld()
	return gine.env.Vector(), gine.env.Angle()
end

function gine.env.WorldToLocal()
	return gine.env.Vector(), gine.env.Angle()
end

function util.GetSunInfo()
	return {
		direction = gine.env.Vector(0,0,1),
		obstruction = 0,
	}
end

function util.GetPixelVisibleHandle()
	return {}
end

function util.PixelVisible(pos, radius, handle)
	return 1
end