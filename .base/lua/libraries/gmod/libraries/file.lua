local gmod = ... or _G.gmod

local file = gmod.env.file

function file.Write(name, str)
	vfs.Write(name, str)
end

function file.Find(path)
	return vfs.Find(path)
end

function file.Read(path)
	return vfs.Read(path)
end