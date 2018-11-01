S""
for _, path in ipairs(vfs.Find("data/archive/", true)) do
	serializer.ReadFile("msgpack", path)
end
S""