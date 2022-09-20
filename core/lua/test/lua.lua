for _, path in ipairs(vfs.GetFilesRecursive("lua/", {".lua"})) do
	local ok, err = loadfile(R(path))

	if not ok then test.fail("loadstring " .. path, err) end
end