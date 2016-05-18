--profiler.StartInstrumental()
profiler.StartTimer()
local dir = "/home/caps/.steam/steam/steamapps/common/GarrysMod/sourceengine/hl2_misc_dir.vpk/"
local bytes = 0
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
print(bytes)
profiler.StopTimer()
--profiler.StopInstrumental()