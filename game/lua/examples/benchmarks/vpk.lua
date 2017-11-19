local dir = steam.GetGamePath("GarrysMod") .. "/sourceengine/hl2_misc_dir.vpk/"
local bytes = 0
S""
for _, path in ipairs(vfs.Search(dir)) do
	if vfs.IsFile(path) then
		local str, err = vfs.Read(path)
		if not str then
			print(err)
		else
			bytes = bytes + #str
		end
	end
end
S""
print(utility.FormatFileSize(bytes))
