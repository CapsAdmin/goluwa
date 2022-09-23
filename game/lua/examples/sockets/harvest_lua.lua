local function fetch_repos(page_num)
	page_num = page_num or 1

	http.GET(
		"https://github.com/search?l=Lua&o=desc&p=" .. page_num .. "&q=extension%3Alua&s=forks&type=Repositories"
	):Then(function(content)
		for url in content:gmatch("Repository&quot;,&quot;url&quot;:&quot;(.-)&quot;") do
			serializer.StoreInFile("luadata", "lua_harvest", url, true)
		end
	end)
end

--fetch_repos(2)
local git = system.GetCLICommand("git")
fs.CreateDirectory("harvest_lua")
fs.PushWorkingDirectory("harvest_lua")

for url in pairs(serializer.GetKeyValuesInFile("luadata", "lua_harvest")) do
	local name = url:match(".+/(.+)")

	if fs.get_type(name) ~= "directory" then git.clone(url, "--depth 1", "&") end
end

fs.PopWorkingDirectory()
fs.CreateDirectory("harvest_lua/flat")

for path in io.popen("locate .lua"):lines() do
	if path:ends_with(".lua") then
		local f, err = io.open(path)

		if f then
			local content = f:read("*all")
			f:close()

			if content and loadstring(content) then
				vfs.Write(
					"os:" .. e.ROOT_FOLDER .. "harvest_lua/flat/" .. crypto.CRC32(content) .. ".lua",
					content
				)
			end
		end
	end
end

for _, path in ipairs(fs.get_files_recursive("harvest_lua")) do
	if path:ends_with(".lua") then
		local f = assert(io.open(path))
		local content = f:read("*all")
		f:close()

		if content then
			vfs.CopyFile(
				"os:" .. e.ROOT_FOLDER .. path,
				"os:" .. e.ROOT_FOLDER .. "harvest_lua/flat/" .. crypto.CRC32(content) .. ".lua"
			)
		end
	end
end