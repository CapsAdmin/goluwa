local gmod = _G.gmod or {}

include("environment.lua", gmod)

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
end

gmod.Initialize()
_G.gmod = gmod