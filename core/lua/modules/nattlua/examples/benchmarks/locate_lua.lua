local nl = require("nattlua")
local files = {}

for full_path in io.popen("locate .lua"):read("*all"):gmatch("(.-)\n") do
	if
		full_path:sub(-4) == ".lua" and
		not full_path:find("GarrysMod")
		and
		not full_path:find("pac3")
		and
		not full_path:find("notagain")
		and
		not full_path:find("gmod")
		and
		not full_path:find("gm%-")
	then
		table.insert(files, full_path)
	end
end

for _, full_path in ipairs(files) do
	local func, err = nl.loadfile(full_path)

	if not func then print(err) end
end
