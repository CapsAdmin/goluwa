local utility = _G.utility or ...

function utility.ParseVMD(file)
	local iconv = require("iconv")
	local out = {}

	out.version = file:ReadString(30, true)

	if out.version == "Vocaloid Motion Data 0002" then
		out.model_name = assert(assert(iconv:new("UTF-8", "SHIFT_JIS")):convert(file:ReadString(20, true)))
	else
		out.model_name = assert(assert(iconv:new("UTF-8", "SHIFT_JIS")):convert(file:ReadString(10, true)))
	end

	out.bone_count = file:ReadUnsignedLong()
	out.frames = {}

	for i = 1, out.bone_count do
		local name = assert(assert(iconv:new("UTF-8", "SHIFT_JIS")):convert(file:ReadString(15, true)))
		local frame = file:ReadUnsignedLong()
		local pos = file:ReadVec3()
		local rot = file:ReadQuat()
		local params = file:ReadBytes(64)

		local temp = {}
		for i = 1, #params do
			temp[i-1] = params:sub(i, i):byte()
		end
		params = temp

		out.frames[frame] = out.frames[frame] or {}
		out.frames[frame][name] = out.frames[frame][name] or {
			pos = pos,
			rot = rot,
			params = params
		}

		break
	end

	out.keyframe_count = 0 or file:ReadUnsignedLong()
	out.keyframes = {}

	for i = 1, out.keyframe_count do
		local name = assert(assert(iconv:new("UTF-8", "SHIFT_JIS")):convert(file:ReadString(15, true)))
		local index = file:ReadUnsignedLong()
		local weight = file:ReadFloat()
		out.keyframes[index] = {name = name, weight = weight}
	end

	return out
end

if RELOAD then
	table.print(utility.ParseVMD(vfs.Open("E:/SteamLibrary/steamapps/common/GarrysMod/garrysmod/data/body_vmd.dat")))
end