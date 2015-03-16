local gmod = ... or gmod
local globals = gmod.env

local function make_is(name) 
	globals["is" .. name:lower()] = function(var) 
		return type(var) == name
	end
end

make_is("nil")
make_is("string")
make_is("number")
make_is("table")
make_is("bool")
make_is("Entity")
make_is("Angle")
make_is("Vector")
make_is("Color")
make_is("function")

do
	local nw_globals = {}

	local function ADD(name)
		globals["SetGlobal" .. name] = function(key, val) nw_globals[key] = val end
		globals["GetGlobal" .. name] = function(key) return nw_globals[key] end
	end
	
	ADD("String")
	ADD("Int")
	ADD("Float")
	ADD("Vector")
	ADD("Angles")
	ADD("Entity")
	ADD("Bool")
end

function globals.GetHostName()
	return "TODO: hostname"
end

function globals.AddCSLuaFile()

end

function globals.AddConsoleCommand(name)
	console.AddCommand(name, function(line, ...)
		gmod.env.concommand.Run(NULL, name, {...}, line)
	end)
end

function globals.RealTime()
	return system.GetElapsedTime()
end
function globals.FrameTime()
	return system.GetFrameTime()
end

function globals.FindMetaTable(name) 
	return globals._R[name] 
end

function globals.Material(path)
	local mat = render.CreateMaterial("model")
	steam.LoadMaterial("materials/" .. path, mat)
	return mat
end

function globals.LoadPresets()
	local out = {}
	
	for folder_name in vfs.Iterate("settings/presets/") do
		if vfs.IsFolder("settings/presets/"..folder_name) then
			out[folder_name] = {}
			for file_name in vfs.Iterate("settings/presets/"..folder_name.."/") do
				table.insert(out[folder_name], steam.VDFToTable(vfs.Read("settings/presets/"..folder_name.."/" .. file_name)))
			end
		end
	end
	
	return out
end

function globals.SavePresets()

end

function globals.Msg(...) log(...) end
function globals.MsgC(...) log(...) end
function globals.MsgN(...) logn(...) end

globals.include = _G.include

function globals.module(name, _ENV)
	logn("gmod: module(",name,")")

	local tbl = {}
	
	if _ENV == package.seeall then
		_ENV = globals
		setmetatable(tbl, {__index = _ENV})
	elseif _ENV then
		print(_ENV, "!?!??!?!")
	end
	
	if not tbl._NAME then
		tbl._NAME = name
		tbl._M = tbl
		tbl._PACKAGE = name:gsub("[^.]*$", "")
	end
	
	package.loaded[name] = tbl
	globals[name] = tbl
	
	setfenv(2, tbl)	
end

function globals.require(name, ...)
	logn("gmod: require(",name,")")
	
	local func, err, path = require.load(name, gmod.dir, true) 
				
	if type(func) == "function" then
		if debug.getinfo(func).what ~= "C" then
			setfenv(func, globals)
		end
		
		return require.require_function(name, func, path, name) 
	end

	if pcall(require, name) then
		return require(name)
	end

	if globals[name] then return globals[name] end

	if not func and err then print(name, err) end

	return func
end