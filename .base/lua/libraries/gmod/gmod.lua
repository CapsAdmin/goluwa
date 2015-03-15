local gmod = _G.gmod or {}

function gmod.PreprocessLua(code)
	local code, data = utility.StripLuaCommentsAndStrings(code)
	
	code = code:gsub("&&", " and ")
	code = code:gsub("||", " or ")
	code = code:gsub("!=", " ~= ")
	code = code:gsub("!", "not ")
	code = code:gsub("/%*", "--[[")
	code = code:gsub("%*/", "]]")
	code = code:gsub("//", "--")
	code = code:gsub("DEFINE_BASECLASS", "local BaseClass = baseclass.Get")
	
	code = utility.RestoreLuaCommentsAndStrings(code, data)
	
	if code:find("continue", nil, true) then
		local lex_setup = require("luajit-lang-toolkit.lexer")
		local reader = require("luajit-lang-toolkit.reader")
		
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
				
				local stop
				
				local balance = 0
				local found_start
				local return_line
				
				for i = start.stack_pos, #stack do
					local v = stack[i]
					
					if v.token == "TK_do" or v.token == "TK_then" or v.token == "TK_function" then
						balance = balance + 1
						found_start = true
					elseif v.token == "TK_end" then
						balance = balance - 1
					end
					
					if stack[i - 1].token == "TK_return" then
						return_line = stack[i - 1].linenumber
					end
					
					if found_start and balance == 0 then
						stop = v
						break
					end
				end
				
				local lines = code:explode("\n")
				
				if return_line then
					lines[return_line] = " do ".. lines[return_line] .. " end "
				end
				
				if not lines[stop.linenumber]:find("CONTINUE") then
					lines[stop.linenumber] = " ::CONTINUE:: ".. lines[stop.linenumber]
				end
				
				code = table.concat(lines, "\n")
			end
		end
	end
	
	local code, data = utility.StripLuaCommentsAndStrings(code)
	
	code = code:gsub("continue", " goto CONTINUE ")
	
	code = utility.RestoreLuaCommentsAndStrings(code, data)
	
	local ok, err = loadstring(code)
	if not ok then print(err) vfs.Write("gmod_preprocess_error.lua", code) end
		
	return code
end

function gmod.SetFunctionEnvironment(func)
	setfenv(func, gmod.env)
end

function gmod.Initialize()
	if not gmod.init then
		include("libraries/gmod/environment.lua", gmod)
		
		steam.MountSourceGame("gmod")
		
		gmod.dir = R("garrysmod_dir.vpk"):match("(.+/)")
		
		vfs.AddModuleDirectory(R"lua/includes/modules/")

		event.AddListener("PreLoadString", "gmod_preprocess", function(code, path)
			if not path:startswith(gmod.dir) then return end
				
			return gmod.PreprocessLua(code)
		end)

		event.AddListener("PostLoadString", "gmod_function_env", function(func, path)
			if not path:startswith(gmod.dir) then return end
			
			gmod.SetFunctionEnvironment(func)
		end)

		include("includes/init.lua")
		include("derma/init.lua")
		
	end
	
	gmod.gamemodes =  {}
	
	gmod.env.GM = {}
	include("gamemodes/base/gamemode/init.lua")
	gmod.gamemodes.base = gmod.env.GM
	gmod.env.GM = nil
	
	gmod.env.GM = {}
	include("gamemodes/sandbox/gamemode/init.lua")
	gmod.gamemodes.sandbox = gmod.env.GM
	gmod.env.GM = nil
	
	for k,v in pairs(gmod.gamemodes.base) do
		gmod.gamemodes.sandbox[k] = gmod.gamemodes.sandbox[k] or v
	end
	
	for file_name in vfs.Iterate("lua/entities/") do
		logn("gmod: registering entity ", file_name)
		if file_name:endswith(".lua") then
			gmod.env.ENT = {}
			include("lua/entities/" .. file_name)
			local name = file_name:match("(.+)%.")
			gmod.env.scripted_ents.Register(gmod.env.ENT, name)
		else
			gmod.env.ENT = {}
			include("lua/entities/" .. file_name .. "/init.lua")
			include("lua/entities/" .. file_name .. "/cl_init.lua")
			gmod.env.scripted_ents.Register(gmod.env.ENT, file_name)
		end
	end
	
	gmod.init = true
end

gmod.Initialize()
_G.gmod = gmod