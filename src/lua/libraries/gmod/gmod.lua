--[[
	right now:
		the focus is 2d and vgui/derma
		i don't care too much about performance
		get things working first



]]

local gmod = _G.gmod or {}

function gmod.PreprocessLua(code, debug)
	local in_string
	local in_comment

	local multiline_open = false
	local in_multiline

	local chars = ("   " .. code .. "   "):totable()

	for i = 1, #chars do

		if chars[i] == "\\" then
			chars[i] = "\\" .. chars[i + 1]
			chars[i + 1] = ""
		end

		if debug then
			log(in_string and "S" or in_comment and "C" or in_multiline and "M" or chars[i] == "\n" and "\n" or chars[i])
		end

		if not in_string and not in_comment and not in_multiline then
			if (chars[i] == "/" and chars[i + 1] == "/") or (chars[i] == "-" and chars[i + 1] == "-") then
				chars[i] = "-"
				chars[i + 1] = "-"
				in_comment = "line"
			elseif chars[i] == "/" and chars[i + 1] == "*" then
				chars[i] = ""
				chars[i + 1] = "--[=======["
				in_comment = "c_multiline"
			end
		end

		if not in_string and not in_comment and not in_multiline then
			if chars[i] == "'" or chars[i] == '"' then
				in_string = chars[i]
			end
		elseif in_string then
			-- \\\"
			-- \\"
			-- TODO: my head hurts
			--if chars[i - 1] ~= "\\" or chars[i - 2] == "\\" or chars[i - 3] ~= "\\" then
				if (chars[i] == "'" or chars[i] == '"') and chars[i] == in_string then
					in_string = nil
				end
			--end
		end

		if in_comment then
			if in_comment == "line" and not in_multiline then
				if chars[i] == "\n" then
					in_comment = nil
				end
			elseif in_comment == "c_multiline" then
				if chars[i] == "*" and chars[i + 1] == "/" then
					in_comment = nil
					chars[i] = ""
					chars[i + 1] = "]=======]"
				end
			end
		end

		if in_multiline then
			if multiline_open then
				if chars[i] == "=" then
					in_multiline = in_multiline + 1
				elseif chars[i] == "[" then
					multiline_open = false
				end
			elseif chars[i] == "]" then
				local ok = true
				for offset = 1, in_multiline do
					if chars[i + offset] ~= "=" then
						ok = false
					end
				end
				if ok and (in_multiline ~= 0 or chars[i + 1] == "]") then
					in_multiline = nil
					in_comment = nil
				end
			end
		end

		if not in_string and not in_comment and not in_multiline or in_comment == "line" then
			if chars[i] == "[" and (chars[i + 1] == "=" or chars[i + 1] == "[") then
				multiline_open = true
				in_multiline = 0
				if in_comment == "line" and chars[i - 1] == "-" and chars[i - 2] == "-" then
					in_comment = nil

					-- ---[[ comment comment
					if chars[i - 3] == "-" then
						multiline_open = false
						in_multiline = nil
					end
				end
			end
		end

		if not in_string and not in_comment and not in_multiline then
			if chars[i] == "!" and chars[i + 1] == "=" then
				chars[i] = ""
				chars[i + 1] = " ~= "
			elseif chars[i] == "&" and chars[i + 1] == "&" then
				chars[i] = ""
				chars[i + 1] = " and "
			elseif chars[i] == "|" and chars[i + 1] == "|" then
				chars[i] = ""
				chars[i + 1] = " or "
			elseif chars[i] == "!" then
				chars[i] = " not "
			end
		end
	end

	local code = table.concat(chars):sub(4, -4)

	if code:wholeword("continue") and not loadstring(code) then
		local lex_setup = require("lang.lexer")
		local reader = require("lang.reader")

		local ls = lex_setup(reader.string(code), code)

		local stack = {}

		repeat
			ls:next()
			table.insert(stack, table.copy(ls))
		until ls.token == "TK_eof"

		for i, ls in ipairs(stack) do
			if ls.token == "TK_name" and ls.tokenval == "continue" then
				local start

				for i = i, 1, -1 do
					local v = stack[i]

					if v.token == "TK_do" then
						start = v
						start.stack_pos = i
						break
					end
				end

				if not start then
					error("unable to find start of loop")
				end


				local stop

				local balance = 0
				local return_token

				for i = start.stack_pos, #stack do
					local v = stack[i]

					if v.token == "TK_do" or v.token == "TK_if" or v.token == "TK_function" then
						balance = balance + 1
					elseif v.token == "TK_end" then
						balance = balance - 1
					end

					if stack[i].token == "TK_return" or stack[i].token == "TK_break" then
						return_token = stack[i]
					end

					if balance == 0 then
						stop = v
						break
					end
				end

				if not stop then
					error("unable to find stop of loop")
				end

				local lines = code:split("\n")

				lines[ls.linenumber] = lines[ls.linenumber]:gsub("continue", "goto CONTINUE")

				if return_token and not return_token.fixed then
					lines[return_token.linenumber] = " do ".. lines[return_token.linenumber] .. " end "
					return_token.fixed = true
				end

				if stop and not stop.fixed then
					lines[stop.linenumber] = " ::CONTINUE:: ".. lines[stop.linenumber]
					stop.fixed = true
				end
				code = table.concat(lines, "\n")

			end
		end
	end

	code = code:gsub("DEFINE_BASECLASS", "local BaseClass = baseclass.Get")

	return code
end

function gmod.SetFunctionEnvironment(func)
	if not gmod.env then
		gmod.Initialize()
	end
	setfenv(func, gmod.env)
end

gmod.objects = gmod.objects or {}
gmod.surface_fonts = gmod.surface_fonts or {}

function gmod.WrapObject(obj, meta)
	gmod.objects[meta] = gmod.objects[meta] or {}

	if not gmod.objects[meta][obj] then
		local tbl = table.copy(gmod.env.FindMetaTable(meta))

		tbl.Type = meta

		local __index_func
		local __index_tbl

		if type(tbl.__index) == "function" then
			__index_func = tbl.__index
		else
			__index_tbl = tbl.__index
		end

		function tbl:__index(key)
			if key == "__obj" then
				return obj
			end

			if __index_func then
				return __index_func(self, key)
			elseif __index_tbl then
				return __index_tbl[key]
			end
		end

		tbl.__gc = nil

		gmod.objects[meta][obj] = setmetatable({}, tbl)

		obj:CallOnRemove(function()
			if gmod.objects[meta] and gmod.objects[meta][obj] then
				local obj = gmod.objects[meta][obj]
				event.Delay(function() prototype.MakeNULL(obj) end)
				gmod.objects[meta][obj] = nil
			end
		end)
	end

	return gmod.objects[meta][obj]
end

event.AddListener("PreLoadString", "gmod_preprocess", function(code, path)
	if path:lower():find("steamapps/common/garrysmod/garrysmod/", nil, true) or path:find("%.gma") then
		if not code:find("DEFINE_BASECLASS", nil, true) and loadstring(code) then return code end

		local ok, msg = pcall(gmod.PreprocessLua, code)

		if not ok then
			logn(msg)
			return
		end

		code = msg

		if not loadstring(code) then vfs.Write("gmod_preprocess_error.lua", code) end

		return code
	end
end)

event.AddListener("PostLoadString", "gmod_function_env", function(func, path)
	if path:lower():find("steamapps/common/garrysmod/garrysmod/", nil, true) or path:find("%.gma") then
		gmod.SetFunctionEnvironment(func)
	end
end)


do
	local easy = {
		["roboto bk"] = "resource/fonts/Roboto-Black.ttf",
		["roboto"] = "resource/fonts/Roboto-Regular.ttf",
		["helvetica"] = "resource/fonts/coolvetica.ttf",
		["times new roman"] = "resource/fonts/coolvetica.ttf",
		["courier new"] = "resource/fonts/coolvetica.ttf",
		["courier"] = "resource/fonts/coolvetica.ttf",
		["arial"] = "resource/fonts/coolvetica.ttf",
		["arial black"] = "resource/fonts/coolvetica.ttf",
		["verdana"] = "resource/fonts/coolvetica.ttf",
		["trebuchet ms"] = "resource/fonts/coolvetica.ttf",
	}

	function gmod.TranslateFontName(name)
		if not name then
			return easy.helvetica
		end
		local name = name:lower()

		if easy[name] then
			return easy[name]
		end

		if vfs.IsFile("resource/" .. name .. ".ttf") then
			return "resource/" .. name .. ".ttf"
		end

		if vfs.IsFile("resource/fonts/" .. name .. ".ttf") then
			return "resource/fonts/" .. name .. ".ttf"
		end

		return easy.helvetica
	end
end

function gmod.LoadFonts()
	local screen_res = window.GetSize()

	local fonts = {}
	--table.merge(fonts, steam.VDFToTable(vfs.Read("resource/SourceScheme.res"), true).scheme.fonts)
	--table.merge(fonts, steam.VDFToTable(vfs.Read("resource/ChatScheme.res"), true).scheme.fonts)
	table.merge(fonts, steam.VDFToTable(vfs.Read("resource/ClientScheme.res"), true).scheme.fonts)

	for font_name, sub_fonts in pairs(fonts) do
		local candidates = {}

		for i, info in pairs(sub_fonts) do
			if info.yres then
				local x,y = unpack(info.yres:split(" "))
				table.insert(candidates, {info = info, dist = Vec2(tonumber(x), tonumber(y)):Distance(screen_res)})
			end
		end

		table.sort(candidates, function(a, b) return a.dist < b.dist end)
		local info = (candidates[1] and candidates[1].info) or select(2, next(sub_fonts))

		if info then
			if type(info.tall) == "table" then
				info.tall = info.tall[1]-- what
			end

			gmod.surface_fonts[font_name:lower()] = surface.CreateFont({
				path = gmod.TranslateFontName(info.name),
				size = info.tall and math.ceil(info.tall) or 11,
			})
		end
	end
end

local function load_entities(base_folder, global, register, create_table)
	for file_name in vfs.Iterate(base_folder.."/") do
		--logn("gmod: registering ",base_folder," ", file_name)
		if file_name:endswith(".lua") then
			gmod.env[global] = create_table()
			include(base_folder.."/" .. file_name)
			register(gmod.env[global], file_name:match("(.+)%."))
		else
			if SERVER then
				if vfs.IsFile(base_folder.."/" .. file_name .. "/init.lua") then
					gmod.env[global] = create_table()
					gmod.env[global].Folder = base_folder:sub(5) .. "/" .. file_name -- weapons/gmod_tool/stools/
					include(base_folder.."/" .. file_name .. "/init.lua")
					register(gmod.env[global], file_name)
				end
			end

			if CLIENT then
				if vfs.IsFile(base_folder.."/" .. file_name .. "/cl_init.lua") then
					gmod.env[global] = create_table()
					gmod.env[global].Folder = base_folder:sub(5) .. "/" .. file_name
					include(base_folder.."/" .. file_name .. "/cl_init.lua")
					register(gmod.env[global], file_name)
				end
			end
		end
	end
	gmod.env[global] = nil
end

function gmod.LoadGamemode(name)
	local info = steam.VDFToTable(vfs.Read("gamemodes/" .. name .. "/" .. name .. ".txt"))
	local name2, info = next(info)

	if info.base == "" then info.base = nil end

	if info.base then
		gmod.LoadGamemode(info.base)
	end

	if SERVER then
		if vfs.IsFile("gamemodes/"..name.."/gamemode/init.lua") then
			gmod.env.GM = {FolderName = name}
			include("gamemodes/"..name.."/gamemode/init.lua")
			gmod.env.gamemode.Register(gmod.env.GM, name, info.base)
			gmod.gamemodes[name] = gmod.env.GM
			gmod.env.GM = nil
		end
	end

	if CLIENT then
		if vfs.IsFile("gamemodes/"..name.."/gamemode/cl_init.lua") then
			gmod.env.GM = {FolderName = name}
			include("gamemodes/"..name.."/gamemode/cl_init.lua")
			gmod.env.gamemode.Register(gmod.env.GM, name, info.base)
			gmod.gamemodes[name] = gmod.env.GM
			gmod.env.GM = nil
		end
	end

	gmod.current_gamemode = gmod.gamemodes.sandbox
	gmod.env.GAMEMODE = gmod.current_gamemode
end

function gmod.Initialize()
	if not gmod.init then
		render.InitializeGBuffer()

		--steam.MountSourceGame("hl2")
		--steam.MountSourceGame("css")
		--steam.MountSourceGame("tf2")
		steam.MountSourceGame("gmod")

		gmod.gamemodes = {}
		gmod.translation = {}
		gmod.translation2 = {}

		pvars.Setup("sv_allowcslua", 1)

		-- figure out the base gmod folder
		gmod.dir = R("garrysmod_dir.vpk"):match("(.+/)")

		-- setup engine functions
		include("lua/libraries/gmod/environment.lua", gmod)

		vfs.AddModuleDirectory(R(gmod.dir.."/lua/includes/modules/"))

		-- include and init files in the right order

		include("lua/includes/init.lua") --
		include("lua/derma/init.lua") -- the gui
		gmod.env.require("notification") -- this is included by engine at this point

		gmod.LoadGamemode("base")
		gmod.LoadGamemode(CAPS and "sandbox_modded" or "sandbox")

		-- autorun lua files
		include(gmod.dir .. "/lua/autorun/*")
		if CLIENT then include(gmod.dir .. "/lua/autorun/client/*") end
		if SERVER then include(gmod.dir .. "/lua/autorun/server/*") end

		for dir in vfs.Iterate("addons/") do
			local dir = gmod.dir .. "addons/" ..  dir
			vfs.AddModuleDirectory(R(dir.."/lua/includes/modules/"))
		end


		--include("lua/postprocess/*")
		include("lua/vgui/*")
		--include("lua/matproxy/*")
		include("lua/skins/*")

		gmod.env.DCollapsibleCategory.LoadCookies = nil -- DUCT TAPE FIX

		for name in pairs(gmod.gamemodes) do
			vfs.Mount(gmod.dir .. "/gamemodes/"..name.."/entities/", "lua/")
		end

		load_entities("lua/entities", "ENT", gmod.env.scripted_ents.Register, function() return {} end)
		load_entities("lua/weapons", "SWEP", gmod.env.weapons.Register, function() return {Primary = {}, Secondary = {}} end)
		load_entities("lua/effects", "EFFECT", gmod.env.effects.Register, function() return {} end)

		do
			for path in vfs.Iterate("resource/localization/en/", true) do
				for _, line in ipairs(vfs.Read(path):split("\n")) do
					local key, val = line:match("(.-)=(.+)")
					if key and val then
						gmod.translation[key] = val:trim()
						gmod.translation2["#" .. key] = gmod.translation[key]
					end
				end
			end
		end

		gmod.LoadFonts()

		gmod.init = true
	end
end

function gmod.AddEvent(what, callback)
	event.AddListener(what, "gmod", function(...) if gmod.env then return callback(...) end end)
end

function gmod.Run()
	input.Bind("q", "+menu")
	input.Bind("q", "-menu")

	input.Bind("c", "+menu_context")
	input.Bind("c", "-menu_context")

	input.Bind("x", "+voicerecord", function()
		gmod.env.gamemode.Call("PlayerStartVoice", gmod.env.LocalPlayer())
	end)
	input.Bind("x", "-voicerecord", function()
		gmod.env.gamemode.Call("PlayerEndVoice", gmod.env.LocalPlayer())
	end)

	input.Bind("t", "messagemode")
	input.Bind("u", "messagemode2")

	input.Bind("tab", "+score", function()
		gmod.env.gamemode.Call("ScoreboardShow")
	end)

	input.Bind("tab", "-score", function()
		gmod.env.gamemode.Call("ScoreboardHide")
	end)

	for dir in vfs.Iterate("addons/", nil, true) do
		local dir = gmod.dir .. "addons/" ..  dir
		include(dir .. "/lua/includes/extensions/*")
	end

	for dir in vfs.Iterate("addons/", nil, true) do
		local dir = gmod.dir .. "addons/" ..  dir
		include(dir .. "/lua/autorun/*")
		if CLIENT then include(dir .. "/lua/autorun/client/*") end
		if SERVER then include(dir .. "/lua/autorun/server/*") end
	end

	gmod.env.gamemode.Call("CreateTeams")
	gmod.env.gamemode.Call("PreGamemodeLoaded")
	gmod.env.gamemode.Call("OnGamemodeLoaded")
	gmod.env.gamemode.Call("PostGamemodeLoaded")

	gmod.env.gamemode.Call("Initialize")
	gmod.env.gamemode.Call("InitPostEntity")
end

include("events.lua", gmod)

commands.Add("ginit", function()
	gmod.Initialize()
	gmod.Run()
end)

commands.Add("glua", function(line)
	if not gmod.env then
		gmod.Initialize()
	end
	local func = assert(loadstring(line))
	setfenv(func, gmod.env)
	print(func())
end)

return gmod