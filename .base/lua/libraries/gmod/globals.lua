local env, gmod = ...

local function make_is(name) 
	env["is" .. name:lower()] = function(var) 
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

env.Vector = Vec3
env.Angle = Ang3

function env.AddCSLuaFile()

end

function env.FindMetaTable(name) 
	return env._R[name] 
end

function env.Material(path)
	local mat = render.CreateMaterial("model")
	steam.LoadMaterial("materials/" .. path, mat)
	return mat
end

function env.LoadPresets()
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

function env.SavePresets()

end

env.include = _G.include

function env.module(name, _ENV)
	logn("gmod: module(",name,")")

	local tbl = {}
	
	if _ENV == package.seeall then
		_ENV = env
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
	env[name] = tbl
	
	setfenv(2, tbl)	
end

function env.require(name, ...)
	logn("gmod: require(",name,")")
	
	local func, err, path = require.load(name, gmod.dir, true) 
				
	if type(func) == "function" then
		if debug.getinfo(func).what ~= "C" then
			setfenv(func, env)
		end
		
		return require.require_function(name, func, path, name) 
	end

	if pcall(require, name) then
		return require(name)
	end

	if env[name] then return env[name] end

	if not func and err then print(name, err) end

	return func
end