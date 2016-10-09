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
				--if gmod.print_keys then llog("key reverse: ", key, " >> ", translate_key_rev[key]) end
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
	for k,v in pairs(translate_mouse) do
		translate_mouse_rev[v] = k
	end

	function gmod.GetMouseCode(button, rev)
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
				llog("mouse button %q could not be translated!\n", button)
				return translate_mouse.button_5
			end
		end
	end
end

do
	gmod.bindings = gmod.bindings or {}

	function gmod.SetupKeyBind(key, cmd, on_press, on_release)
		input.Unbind(key)

		local p = cmd:match("^(%p)")
		if p then
			key = p .. key
		end
		gmod.bindings[key] = {cmd = cmd, p = p, on_press = on_press, on_release = on_release or p and on_press}
	end

	event.AddListener("KeyInput", "gmod", function(key, press)
		if not gmod.init then return end

		local info = gmod.bindings[key] or (press and gmod.bindings["+" .. key] or gmod.bindings["-" .. key])
		if info then
			if gmod.env.gamemode.Call("PlayerBindPress", gmod.env.LocalPlayer(), info.cmd, press) ~= true then
				if press then
					if info.on_press and (not info.p or info.p == "+") then
						info.on_press()
					end
				else
					if info.on_release and (not info.p or info.p == "-") then
						info.on_release()
					end
				end
				gmod.env.RunConsoleCommand(info.cmd)
			end

			return false
		end
	end)

	gmod.SetupKeyBind("q", "+menu")
	gmod.SetupKeyBind("q", "-menu")

	gmod.SetupKeyBind("c", "+menu_context")
	gmod.SetupKeyBind("c", "-menu_context")

	gmod.SetupKeyBind("x", "+voicerecord", function()
		gmod.env.gamemode.Call("PlayerStartVoice", gmod.env.LocalPlayer())
	end)

	gmod.SetupKeyBind("x", "-voicerecord", function()
		gmod.env.gamemode.Call("PlayerEndVoice", gmod.env.LocalPlayer())
	end)

	gmod.SetupKeyBind("t", "messagemode")
	gmod.SetupKeyBind("u", "messagemode2")

	gmod.SetupKeyBind("tab", "+score", function()
		gmod.env.gamemode.Call("ScoreboardShow")
	end)

	gmod.SetupKeyBind("tab", "-score", function()
		gmod.env.gamemode.Call("ScoreboardHide")
	end)
end

local input = gmod.env.input
local lib = _G.input

function input.SetCursorPos(x, y)
	window.SetMousePosition(Vec2(x, y))
end

function input.GetCursorPos()
	return window.GetMousePosition():Unpack()
end

function input.IsShiftDown()
	return lib.IsKeyDown("left_shift") or lib.IsKeyDown("right_shift")
end

function input.IsMouseDown(code)
	return lib.IsMouseDown(gmod.GetMouseCode(code, true))
end

function input.IsKeyDown(code)
	return lib.IsKeyDown(gmod.GetKeyCode(code, true))
end

function input.GetKeyName(code)
	return gmod.GetKeyCode(code, true)
end


local b
function input.StartKeyTrapping()
	b = true
end

function input.IsKeyTrapping()
	return b
end

function input.CheckKeyTrapping()

end

function input.StopKeyTrapping()
	b = false
end