local gmod = ... or _G.gmod

gmod.hud_element_list = {
	"CHudAmmo",
	"CHudBattery",
	"CHudChat",
	"CHudCrosshair",
	"CHudDamageIndicator",
	"CHudDeathNotice",
	"CHudGeiger",
	"CHudGMod",
	"CHudHealth",
	"CHudHintDisplay",
	"CHudMenu",
	"CHudMessage",
	"CHudPoisonDamageIndicator",
	"CHudSecondaryAmmo",
	"CHudSquadStatus",
	"CHudTrain",
	"CHudWeapon",
	"CHudWeaponSelection",
	"Hiding",
	"CHudZoom",
	"Only",
	"NetGraph",
	"CTargetID",
	"CHudHistoryResource",
	"CHudSuitPower",
	"CHudCloseCaption",
	"CHudLocator",
	"CHudFlashlight",
	"CAchievementNotificationPanel",
	"CHudAnimationInfo",
	"CHUDAutoAim",
	"CHudBonusProgress",
	"CHudCapturePanel",
	"CHudCommentary",
	"CHudControlPointIcons",
	"CHudCredits",
	"CHudVehicle",
	"CHudVguiScreenCursor",
	"CHudVoiceSelfStatus",
	"CHudVoiceStatus",
	"CHudVote",
	"CMapOverview",
	"CPDumpPanel",
	"CReplayReminderPanel",
	"CTeamPlayHud",
	"CHudFilmDemo",
	"CHudGameMessage",
	"CHudHDRDemo",
	"CHudHintKeyDisplay",
	"CHudPosture",
	"CHUDQuickInfo",
}

local env = {}
env._R = {}
env._G = env

gmod.env = env

local data = include("lua/libraries/gmod/"..(CLIENT and "cl_" or SERVER and "sv_").."exported.lua")

do -- copy standard libraries
	local function add_lib_copy(name)
		local lib = {}

		for k,v in pairs(_G[name]) do lib[k] = v end

		env[name] = lib
	end

	add_lib_copy("string")
	add_lib_copy("math")
	add_lib_copy("table")
	add_lib_copy("coroutine")
	add_lib_copy("debug")
	add_lib_copy("bit")
	add_lib_copy("io")
	add_lib_copy("os")
	add_lib_copy("jit")

	env.table.insert = function(t,...) table.insert(t,...) return #t end
	env.debug.getregistry = function() return env._R end

	for k in pairs(_OLD_G) do
		env[k] = _G[k]
	end
end

do -- enums
	for enum_name, value in pairs(data.enums) do
		env[enum_name] = env[enum_name] or value
	end
end

-- global functions
for func_name in pairs(data.functions.globals) do
	env[func_name] = env[func_name] or function(...) logf(("gmod NYI: %s(%s)\n"):format(func_name, table.concat(tostring_args(...), ","))) end
end

data.functions.globals = nil

-- metatables
for meta_name, functions in pairs(data.meta) do
	functions.__tostring = nil
	functions.__newindex = nil

	if not env._R[meta_name] then
		local META = {}
		META.MetaName = meta_name
		META.__index = META

		if functions.IsValid then
			function META:IsValid()
				if self.__removed then return false end
				return self.__obj and self.__obj:IsValid()
			end
		end

		if functions.Remove then
			function META:Remove()
				self.__removed = true
				event.Delay(0,function() prototype.SafeRemove(self.__obj) end)
			end
		end

		env._R[meta_name] = META
	end

	for func_name in pairs(functions) do
		env._R[meta_name][func_name] = env._R[meta_name][func_name] or function(...) logf("gmod NYI: %s:%s(%s)\n", meta_name, func_name, table.concat(tostring_args(...), ",")) end
	end

	gmod.objects[meta_name] = gmod.objects[meta_name] or {}
end

-- libraries
for lib_name, functions in pairs(data.functions) do
	env[lib_name] = env[lib_name] or {}

	for func_name in pairs(functions) do
		env[lib_name][func_name] = env[lib_name][func_name] or function(...) logf(("gmod NYI: %s.%s(%s)\n"):format(lib_name, func_name, table.concat(tostring_args(...), ","))) end
	end
end

if gmod.debug then
	for _, meta in pairs(env._R) do
		setmetatable(meta, {__newindex = function(s, k, v)
			if not k:startswith("__") then
				warning("adding meta function that doesn't exist in glua: %s", 2, k)
			end
			rawset(s,k,v)
		end})
	end

	setmetatable(env, {__newindex = function(s, k, v)
		warning("adding function that doesn't exist in glua: %s", 2, k)
		rawset(s,k,v)
	end})
end

function gmod.GetMetaTable(name)
	return gmod.env._R[name]
end

include("lua/libraries/gmod/libraries/*", gmod)

if gmod.debug then
	setmetatable(env)

	for _, meta in pairs(env._R) do
		setmetatable(meta)
	end
end

setmetatable(env, {__index = _G})

do
	local translate_key = {}

	for k,v in pairs(gmod.env) do
		if k:startswith("KEY_") then
			translate_key[k:match("KEY_(.+)"):lower()] = v
		end
	end

	local translate_key_rev = {}
	for k,v in pairs(translate_key) do
		translate_key_rev[v] = k
	end

	function gmod.GetKeyCode(key, rev)
		if rev then
			if translate_key_rev[key] then
				if gmod.print_keys then llog("key reverse: ", key, " >> ", translate_key_rev[key]) end
				return translate_key_rev[key]
			else
				logf("key %q could not be translated!\n", key)
				return translate_key_rev.KEY_P -- dunno
			end
		else
			if translate_key[key] then
				if gmod.print_keys then llog("key: ", key, " >> ", translate_key[key]) end
				return translate_key[key]
			else
				logf("key %q could not be translated!\n", key)
				return translate_key.p -- dunno
			end
		end
	end

	local translate_mouse = {
		button_1 = gmod.env.MOUSE_LEFT,
		button_2 = gmod.env.MOUSE_RIGHT,
		button_3 = gmod.env.MOUSE_MIDDLE,
		button_4 = gmod.env.MOUSE_4,
		button_5 = gmod.env.MOUSE_5,
		mwheel_up = gmod.env.MOUSE_WHEEL_UP,
		mwheel_down = gmod.env.MOUSE_WHEEL_DOWN,
	}

	local translate_mouse_rev = {}
	for k,v in pairs(translate_key) do
		translate_mouse_rev[v] = k
	end

	function gmod.GetMouseCode(button, rev)
		if rev then
			if translate_mouse_rev[button] then
				return translate_mouse_rev[button]
			else
				llog("mouse button %q could not be translated!\n", button)
				return translate_mouse.MOUSE_5
			end
		else
			if translate_mouse[button] then
				return translate_mouse[button]
			else
				llog("mouse button %q could not be translated!\n", button)
				return translate_mouse.button_5
			end
		end
	end
end