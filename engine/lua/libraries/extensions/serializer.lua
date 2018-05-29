-- automatically handle extensions like .json, .msgpack, etc in in vfs.Write/Read

event.AddListener("VFSPreWrite", "serializer", function(path, data)
	local ext = vfs.GetExtensionFromPath(path)
	if serializer.GetLibrary(ext) then
		return serializer.Encode(ext, data)
	end
end)

event.AddListener("VFSPostRead", "serializer", function(path, data)
	local ext = vfs.GetExtensionFromPath(path)
	if serializer.GetLibrary(ext) then
		return serializer.Decode(ext, data)
	end
end)