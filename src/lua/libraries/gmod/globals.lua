local gmod = ... or gmod
local globals = gmod.env

local function make_is(name)
	if name:sub(1,1) == name:sub(1,1):upper() then
		globals["is" .. name:lower()] = function(var)
			return typex(var) == name
		end
	else
		globals["is" .. name:lower()] = function(var)
			return type(var) == name
		end
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
make_is("Panel")

function globals.type(obj)
	local t = type(obj)

	if t == "table" then
		local meta = getmetatable(obj)
		if meta and meta.MetaName then
			return meta.MetaName
		end
	end

	return t
end

do
	local tr = {
		Angle = gmod.env.TYPE_ANGLE, --  	11
		boolean = gmod.env.TYPE_BOOL, --  	1
		Color = gmod.env.TYPE_COLOR, --  	255
		ConVar = gmod.env.TYPE_CONVAR, --  	27
		CTakeDamageInfo = gmod.env.TYPE_DAMAGEINFO, --  	15
		DynamicLight = gmod.env.TYPE_DLIGHT, --  	32
		CEffectData = gmod.env.TYPE_EFFECTDATA, --  	16
		Entity = gmod.env.TYPE_ENTITY, --  	9
		File = gmod.env.TYPE_FILE, --  	34
		["function"] = gmod.env.TYPE_FUNCTION, --  	6
		IMesh = gmod.env.TYPE_IMESH, --  	28
		lightuserdata = gmod.env.TYPE_LIGHTUSERDATA, --  	2
		CLuaLocomotion = gmod.env.TYPE_LOCOMOTION, --  	35
		IMaterial = gmod.env.TYPE_MATERIAL, --  	21
		VMatrix = gmod.env.TYPE_MATRIX, --  	29
		CMoveData = gmod.env.TYPE_MOVEDATA, --  	17
		CNavArea = gmod.env.TYPE_NAVAREA, --  	37
		CNavLadder = gmod.env.TYPE_NAVLADDER, --  	39
		["nil"] = gmod.env.TYPE_NIL, --  	0
		number = gmod.env.TYPE_NUMBER, --  	3
		Panel = gmod.env.TYPE_PANEL, --  	22
		CLuaParticle = gmod.env.TYPE_PARTICLE, --  	23
		CLuaEmitter = gmod.env.TYPE_PARTICLEEMITTER, --  	24
		CNewParticleEffect = gmod.env.TYPE_PARTICLESYSTEM, --  	40
		PathFollower = gmod.env.TYPE_PATH, --  	36
		PhysObj = gmod.env.TYPE_PHYSOBJ, --  	12
		pixelvis_handle_t = gmod.env.TYPE_PIXELVISHANDLE, --  	31
		CRecipientFilter = gmod.env.TYPE_RECIPIENTFILTER, --  	18
		IRestore = gmod.env.TYPE_RESTORE, --  	14
		ISave = gmod.env.TYPE_SAVE, --  	13
		Vehicle = gmod.env.TYPE_SCRIPTEDVEHICLE, --  	20
		CSoundPatch = gmod.env.TYPE_SOUND, --  	30
		IGModAudioChannel = gmod.env.TYPE_SOUNDHANDLE, --  	38
		string = gmod.env.TYPE_STRING, --  	4
		table = gmod.env.TYPE_TABLE, --  	5
		ITexture = gmod.env.TYPE_TEXTURE, --  	25
		thread = gmod.env.TYPE_THREAD, --  	8
		CUserCmd = gmod.env.TYPE_USERCMD, --  	19
		userdata = gmod.env.TYPE_USERDATA, --  	7
		bf_read = gmod.env.TYPE_USERMSG, --  	26
		Vector = gmod.env.TYPE_VECTOR, --  	10
		IVideoWriter = gmod.env.TYPE_VIDEO, --  	33
	}
	function globals.TypeID(val)
		return tr[gmod.env.type(val)] or gmod.env.TYPE_INVALID
	end
end

function globals.istable(obj)
	return globals.type(obj) == "table"
end

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

function globals.HSVToColor(h,s,v)
	return globals.Color(ColorHSV(h*360,s,v):Unpack())
end

function globals.ColorToHSV(r,g,b)
	if type(r) == "table" then
		local t = r
		r = t.r
		g = t.g
		b = t.b
	end
	return ColorBytes(r,g,b):GetHSV()
end

function globals.GetHostName()
	return "TODO: hostname"
end

function globals.AddCSLuaFile()

end

function globals.AddConsoleCommand(name)
	commands.Add(name, function(line, ...)
		gmod.env.concommand.Run(NULL, name, {...}, line)
	end)
end

function globals.RunConsoleCommand(...)
	local str = table.concat({...}, " ")
	if str:find("utime") then return end -- sigh
	logn("gmod cmd: ", str)
	commands.RunCommand(...)
end

function globals.RealTime() return system.GetElapsedTime() end
function globals.FrameNumber() return tonumber(system.GetFrameNumber()) end
function globals.FrameTime() return system.GetFrameTime() end
function globals.VGUIFrameTime() return system.GetElapsedTime() end
function globals.CurTime() return system.GetElapsedTime() end --system.GetServerTime()
function globals.SysTime() return system.GetTime() end --system.GetServerTime()

function globals.EyeVector()
	return gmod.env.Vector(render.camera_3d:GetAngles():GetForward():Unpack())
end

function globals.EyePos()
	return gmod.env.Vector(render.camera_3d:GetPosition():Unpack())
end

function globals.EyeAngles()
	return gmod.env.Angle(render.camera_3d:GetAngles():Unpack())
end

function globals.FindMetaTable(name)
	return globals._R[name]
end

function globals.Material(path)
	local mat = render.CreateMaterial("model")
	mat.gmod_name = path

	if path:lower():endswith(".png") then
		if vfs.IsFile(path) then
			mat:SetAlbedoTexture(render.CreateTextureFromPath(path))
		else
			mat:SetAlbedoTexture(render.CreateTextureFromPath("materials/" .. path))
		end
	elseif vfs.IsFile("materials/" .. path) then
		steam.LoadMaterial("materials/" .. path, mat)
	elseif vfs.IsFile("materials/" .. path .. ".vmt") then
		steam.LoadMaterial("materials/" .. path .. ".vmt", mat)
	elseif vfs.IsFile("materials/" .. path .. ".png") then
		steam.LoadMaterial("materials/" .. path .. ".png", mat)
	end

	return gmod.WrapObject(mat, "IMaterial")
end

function globals.LoadPresets()
	local out = {}

	for folder_name in vfs.Iterate("settings/presets/") do
		if vfs.IsDirectory("settings/presets/"..folder_name) then
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

function globals.PrecacheParticleSystem() end

function globals.CreateSound(ent, path, filter)
	local self = audio.CreateSource("sound/" .. path)

	return gmod.WrapObject(self, "CSoundPatch")
end

function globals.Msg(...) log(...) end
function globals.MsgC(...) log(...) end
function globals.MsgN(...) logn(...) end

globals.include = function(path)
	local ok, err = include({
		path,
		"lua/" .. path,
		path:lower(),
		"lua/" .. path:lower()
	})
	if not ok then
		logn(err, path)
	end
end

function globals.module(name, _ENV)
	--logn("gmod: module(",name,")")

	local tbl = package.loaded[name] or globals[name] or {}

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
	--logn("gmod: require(",name,")")

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

function globals.ParticleEmitter()
	return gmod.WrapObject(ParticleEmitter(), "CLuaEmitter")
end

function globals.CreateMaterial()
	return gmod.WrapObject(render.CreateMaterial("model"), "IMaterial")
end

function globals.HTTP(tbl)
	if tbl.parameters then
		warning("NYI parameters")
		table.print(tbl.parameters)
	end

	if tbl.headers then
		warning("NYI headers")
		table.print(tbl.headers)
	end

	if tbl.body then
		warning("NYI body")
		print(tbl.headers)
	end

	if tbl.type then
		warning("NYI type")
		print(tbl.type)
	end

	sockets.Request({
		url = tbl.url,
		callback = tbl.success,
		on_fail = tbl.failed,
		method = tbl.method:upper(),
	})
end

function globals.CompileString(code, identifier, handle_error)
	if handle_error == nil then handle_error = true end
	local func, err = loadstring(code)
	if func then
		setfenv(func, gmod.env)
		return func
	end
	if handle_error then
		error(err, 2)
	end
	return err
end

function globals.CompileFile(name)
	return globals.CompileString(vfs.Read("lua/" .. name), "@lua/" .. name)
end

function globals.DeriveGamemode(name)
	local old_gm = gmod.env.GM
	gmod.env.GM = {FolderName = name}

	if SERVER then
		if vfs.IsFile("gamemodes/"..name.."/gamemode/init.lua") then
			include("gamemodes/"..name.."/gamemode/init.lua")
		end
	end

	if CLIENT then
		if vfs.IsFile("gamemodes/"..name.."/gamemode/cl_init.lua") then
			include("gamemodes/"..name.."/gamemode/cl_init.lua")
		end
	end

	gmod.env.table.Inherit(old_gm, gmod.env.GM)
	gmod.env.GM = old_gm
end

function globals.SetClipboardText(str)
	window.SetClipboard(str)
end