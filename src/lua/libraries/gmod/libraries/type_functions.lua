local function make_is(name)
	if name:sub(1,1) == name:sub(1,1):upper() then
		gine.env["is" .. name:lower()] = function(var)
			return name and type(var) == "table" and var.MetaName == name
		end
	else
		gine.env["is" .. name:lower()] = function(var)
			return type(var) == name
		end
	end
end

make_is("string")
make_is("number")
make_is("table")
make_is("bool")
make_is("Entity")
make_is("Angle")
make_is("Vector")
make_is("function")
make_is("Panel")
make_is("Matrix")

gine.env.IsEntity = gine.env.isentity

function gine.env.type(obj)
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
		Angle = gine.env.TYPE_ANGLE, --  	11
		boolean = gine.env.TYPE_BOOL, --  	1
		Color = gine.env.TYPE_COLOR, --  	255
		ConVar = gine.env.TYPE_CONVAR, --  	27
		CTakeDamageInfo = gine.env.TYPE_DAMAGEINFO, --  	15
		DynamicLight = gine.env.TYPE_DLIGHT, --  	32
		CEffectData = gine.env.TYPE_EFFECTDATA, --  	16
		Entity = gine.env.TYPE_ENTITY, --  	9
		Player = gine.env.TYPE_ENTITY, --  	9
		File = gine.env.TYPE_FILE, --  	34
		["function"] = gine.env.TYPE_FUNCTION, --  	6
		IMesh = gine.env.TYPE_IMESH, --  	28
		lightuserdata = gine.env.TYPE_LIGHTUSERDATA, --  	2
		CLuaLocomotion = gine.env.TYPE_LOCOMOTION, --  	35
		IMaterial = gine.env.TYPE_MATERIAL, --  	21
		VMatrix = gine.env.TYPE_MATRIX, --  	29
		CMoveData = gine.env.TYPE_MOVEDATA, --  	17
		CNavArea = gine.env.TYPE_NAVAREA, --  	37
		CNavLadder = gine.env.TYPE_NAVLADDER, --  	39
		["nil"] = gine.env.TYPE_NIL, --  	0
		number = gine.env.TYPE_NUMBER, --  	3
		Panel = gine.env.TYPE_PANEL, --  	22
		CLuaParticle = gine.env.TYPE_PARTICLE, --  	23
		CLuaEmitter = gine.env.TYPE_PARTICLEEMITTER, --  	24
		CNewParticleEffect = gine.env.TYPE_PARTICLESYSTEM, --  	40
		PathFollower = gine.env.TYPE_PATH, --  	36
		PhysObj = gine.env.TYPE_PHYSOBJ, --  	12
		pixelvis_handle_t = gine.env.TYPE_PIXELVISHANDLE, --  	31
		CRecipientFilter = gine.env.TYPE_RECIPIENTFILTER, --  	18
		IRestore = gine.env.TYPE_RESTORE, --  	14
		ISave = gine.env.TYPE_SAVE, --  	13
		Vehicle = gine.env.TYPE_SCRIPTEDVEHICLE, --  	20
		CSoundPatch = gine.env.TYPE_SOUND, --  	30
		IGModAudioChannel = gine.env.TYPE_SOUNDHANDLE, --  	38
		string = gine.env.TYPE_STRING, --  	4
		table = gine.env.TYPE_TABLE, --  	5
		ITexture = gine.env.TYPE_TEXTURE, --  	25
		thread = gine.env.TYPE_THREAD, --  	8
		CUserCmd = gine.env.TYPE_USERCMD, --  	19
		userdata = gine.env.TYPE_USERDATA, --  	7
		bf_read = gine.env.TYPE_USERMSG, --  	26
		Vector = gine.env.TYPE_VECTOR, --  	10
		IVideoWriter = gine.env.TYPE_VIDEO, --  	33
	}
	function gine.env.TypeID(val)
		return tr[gine.env.type(val)] or gine.env.TYPE_INVALID
	end
end

function gine.env.istable(obj)
	return gine.env.type(obj) == "table"
end

function gine.env.FindMetaTable(name)
	return gine.GetMetaTable(name)
end
