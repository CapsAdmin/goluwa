do
	local translate_key = {}

	local function find_enums(name)
		for k,v in pairs(gine.env) do
			if k:startswith(name .. "_") then
				translate_key[k:match(name .. "_(.+)"):lower()] = v
			end
		end
	end

	find_enums("KEY")
	find_enums("MOUSE")
	find_enums("BUTTON")
	find_enums("JOYSTICK")

	translate_key.left = gine.env.KEY_LEFT
	translate_key.right = gine.env.KEY_RIGHT

	translate_key.left_shift = gine.env.KEY_LSHIFT
	translate_key.lshift = nil
	translate_key.right_shift = gine.env.KEY_RSHIFT
	translate_key.rshift = nil

	translate_key.lcontrol = nil
	translate_key.left_control = gine.env.KEY_LCONTROL
	translate_key.right_control = gine.env.KEY_RCONTROL
	translate_key.rcontrol = nil

	translate_key.left_alt = gine.env.KEY_LALT
	translate_key.lalt = nil
	translate_key.right_alt = gine.env.KEY_RALT
	translate_key.ralt = nil

	local translate_key_rev = {}
	for k,v in pairs(translate_key) do
		translate_key_rev[v] = k
	end

	gine.translate_key = translate_key
	gine.translate_key_rev = translate_key_rev

	function gine.GetKeyCode(key, rev)
		if rev then
			if translate_key_rev[key] then
				--if gine.print_keys then llog("key reverse: ", key, " >> ", translate_key_rev[key]) end
				return translate_key_rev[key]
			else
				--logf("key %q could not be translated!\n", key)
				return translate_key_rev.KEY_P -- dunno
			end
		else
			if translate_key[key] then
				if gine.print_keys then llog("key: ", key, " >> ", translate_key[key]) end
				return translate_key[key]
			else
				--logf("key %q could not be translated!\n", key)
				return translate_key.p -- dunno
			end
		end
	end

	local translate_mouse = {
		button_1 = gine.env.MOUSE_LEFT,
		button_2 = gine.env.MOUSE_RIGHT,
		button_3 = gine.env.MOUSE_MIDDLE,
		button_4 = gine.env.MOUSE_4,
		button_5 = gine.env.MOUSE_5,
		mwheel_up = gine.env.MOUSE_WHEEL_UP,
		mwheel_down = gine.env.MOUSE_WHEEL_DOWN,
	}

	local translate_mouse_rev = {}
	for k,v in pairs(translate_mouse) do
		translate_mouse_rev[v] = k
	end

	function gine.GetMouseCode(button, rev)
		if rev then
			if translate_mouse_rev[button] then
				return translate_mouse_rev[button]
			else
				--llog("mouse button %q could not be translated!\n", button)
				return translate_mouse.MOUSE_5
			end
		else
			if translate_mouse[button] then
				return translate_mouse[button]
			else
				--llog("mouse button %q could not be translated!\n", button)
				return translate_mouse.button_5
			end
		end
	end
end

do
	gine.bindings = gine.bindings or {}

	function gine.SetupKeyBind(key, cmd, on_press, on_release)
		input.Unbind(key)

		local p = cmd:match("^(%p)")
		if p then
			key = p .. key
		end
		gine.bindings[key] = {cmd = cmd, p = p, on_press = on_press, on_release = on_release or p and on_press}
	end

	gine.AddEvent("KeyInput", function(key, press)
		if input.DisableFocus then return end

		local ply = gine.env.LocalPlayer()

		if press then
			gine.env.gamemode.Call("KeyPress", ply, gine.GetKeyCode(key))
		else
			gine.env.gamemode.Call("KeyRelease", ply, gine.GetKeyCode(key))
		end

		local info = gine.bindings[key] or (press and gine.bindings["+" .. key] or gine.bindings["-" .. key])

		if info then
			if gine.env.gamemode.Call("PlayerBindPress", ply, info.cmd, press) ~= true then
				if press then
					if info.on_press and (not info.p or info.p == "+") then
						info.on_press()
					end
				else
					if info.on_release and (not info.p or info.p == "-") then
						info.on_release()
					end
				end
				gine.env.RunConsoleCommand(info.cmd)
			end

			return false
		end
	end)

	gine.SetupKeyBind("q", "+menu")
	gine.SetupKeyBind("q", "-menu")

	gine.SetupKeyBind("c", "+menu_context")
	gine.SetupKeyBind("c", "-menu_context")

	gine.SetupKeyBind("x", "+voicerecord", function()
		gine.env.gamemode.Call("PlayerStartVoice", gine.env.LocalPlayer())
	end)

	gine.SetupKeyBind("x", "-voicerecord", function()
		gine.env.gamemode.Call("PlayerEndVoice", gine.env.LocalPlayer())
	end)

	gine.SetupKeyBind("t", "messagemode")
	gine.SetupKeyBind("u", "messagemode2")

	gine.SetupKeyBind("tab", "+score", function()
		gine.env.gamemode.Call("ScoreboardShow")
	end)

	gine.SetupKeyBind("tab", "-score", function()
		gine.env.gamemode.Call("ScoreboardHide")
	end)
end

local input = gine.env.input
local lib = _G.input

function input.LookupBinding(cmd)
	for k,v in pairs(gine.bindings) do
		if v.cmd == cmd then
			return k
		end
	end
end

function input.SetCursorPos(x, y)
	window.SetMousePosition(Vec2(x, y))
end

function input.GetCursorPos()
	return window.GetMousePosition():Unpack()
end

function input.IsShiftDown()
	return lib.IsKeyDown("left_shift") or lib.IsKeyDown("right_shift")
end

function input.IsControlDown()
	return lib.IsKeyDown("left_control") or lib.IsKeyDown("right_control")
end

function input.IsMouseDown(code)
	return lib.IsMouseDown(gine.GetMouseCode(code, true))
end

function input.IsKeyDown(code)
	return lib.IsKeyDown(gine.GetKeyCode(code, true))
end

function input.GetKeyName(code)
	return gine.GetKeyCode(code, true)
end

do
	local last_key
	local b = false

	function input.StartKeyTrapping()
		b = true
		last_key = nil

		event.AddListener("KeyInput", "gine_keytrap", function(key, press) last_key = gine.GetKeyCode(key) end)
		event.AddListener("MouseInput", "gine_keytrap", function(key, press) last_key = gine.GetMouseCode(key) end)
	end

	function input.IsKeyTrapping()
		return b
	end

	function input.CheckKeyTrapping()
		return last_key
	end

	function input.StopKeyTrapping()
		b = false

		event.RemoveListener("KeyInput", "gine_keytrap")
		event.RemoveListener("MouseInput", "gine_keytrap")
	end
end