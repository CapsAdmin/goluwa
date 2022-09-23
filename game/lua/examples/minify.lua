local lua = vfs.Read("lua/init.lua")
lua = lua:replace(
	"vfs.InitAddons()",
	[[
	vfs.InitAddons();
	(function() ]] .. vfs.Read(e.ROOT_FOLDER .. "/framework/lua/init.lua") .. [[ end)();
	(function() ]] .. vfs.Read(e.ROOT_FOLDER .. "/engine/lua/init.lua") .. [[ end)();
	(function() ]] .. vfs.Read(e.ROOT_FOLDER .. "/game/lua/init.lua") .. [[ end)();
]]
)

local function check(s, path)
	local ok, err = loadstring(s)

	if not ok then print(path .. ":" .. err) end

	return s
end

check(lua, "start")

local function preprocess(lua, path, parent_path)
	assert(loadstring(lua))
	return lua:gsub("%srunfile(%b())", function(args)
		local original = args
		args = args:sub(2, -2):split(",")
		local path = list.remove(args, 1)

		if not path:starts_with("\"") then return end

		path = path:sub(2, -2)

		if path:starts_with("!") then path = path:sub(2) end

		if path:find("shader_cvar") then
			path = path:gsub("\"%.%.shader_cvar:Get%(%)%.%.\"", "flat")
		end

		path = path:replace([["..(CLIENT and "cl_" or SERVER and "sv_").."]], "cl_")

		if path == "lua/includes/init.lua" then return end

		if path == "lua/includes/init_menu.lua" then return end

		if path == "lua/derma/init.lua" then return end

		if path:find("cl_index") then return end

		if path:find("sv_index") then return end

		if path:find("/gamemode/") then return end

		if path:ends_with("*") then
			local s = ""

			for _, path in ipairs(vfs.Find(path:sub(0, -2), true)) do
				if path:ends_with(".lua") then
					if not vfs.IsFile(path) and vfs.IsFile(parent_path:match("(.+/)") .. path) then
						path = parent_path:match("(.+/)") .. path
					end

					--print("including ", path)
					s = s .. check(
							"\n (function(...)\n " .. preprocess(assert(vfs.Read(path)), path, path or parent_path) .. "\n end)(" .. list.concat(args, ",") .. ");\n",
							path
						)
				end
			end

			return s
		end

		if not vfs.IsFile(path) and vfs.IsFile(parent_path:match("(.+/)") .. path) then
			path = parent_path:match("(.+/)") .. path
		end

		print("including ", path)
		return check(
			"\n (function(...) " .. preprocess(assert(vfs.Read(path)), path, path or parent_path) .. " end)(" .. list.concat(args, ",") .. ");\n",
			path
		)
	end)
end

lua = preprocess(lua, "lua/init.lua")
--lua = vfs.Read("/home/caps/goluwa/core/lua/libraries/prototype/prototype.lua")
--lua = preprocess(lua, "lua/libraries/prototype/prototype.lua")
check(lua, "lua/init.lua")
local modules = {}

lua:gsub("require(%b())", function(s)
	modules[s:sub(3, -3)] = true
end)

lua:gsub("desire(%b())", function(s)
	modules[s:sub(3, -3)] = true
end)

local s = ""

for v in pairs(modules) do
	local m = vfs.Read("lua/modules/" .. v .. ".lua") or vfs.Read(e.BIN_FOLDER .. v .. ".lua")

	if m then
		s = s .. "package.preload." .. v .. " = function(...) " .. m .. " end "
	else
		print(v)
	end
end

lua = s .. "\n" .. lua
check(lua, "eof")
vfs.Write(e.BIN_FOLDER .. "main.lua", lua) --os.execute("./luajit main.lua")