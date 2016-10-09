local function make_is(name)
	if name:sub(1,1) == name:sub(1,1):upper() then
		gmod.env["is" .. name:lower()] = function(var)
			return typex(var) == name
		end
	else
		gmod.env["is" .. name:lower()] = function(var)
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

function gmod.env.type(obj)
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
	function gmod.env.TypeID(val)
		return tr[gmod.env.type(val)] or gmod.env.TYPE_INVALID
	end
end

function gmod.env.istable(obj)
	return gmod.env.type(obj) == "table"
end

function gmod.env.FindMetaTable(name)
	return gmod.GetMetaTable(name)
end