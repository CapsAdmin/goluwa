local KEY_FIRST = gmod.KEY_FIRST
local KEY_LAST = gmod.KEY_LAST
local MOUSE_FIRST = gmod.MOUSE_FIRST
local MOUSE_LAST = gmod.MOUSE_LAST
local input_IsKeyDown = gmod.input.IsKeyDown
local input_GetKeyName = gmod.input.GetKeyName
local input_IsMouseDown = gmod.input.IsMouseDown
local gui_MousePos = gmod.gui.MousePos
local input_IsShiftDown = gmod.input.IsShiftDown
local system_GetCountry = gmod.system.GetCountry
local ScrW = gmod.ScrW
local ScrH = gmod.ScrH
local gui_MousePos = gmod.gui.MousePos
local gui_SetMousePos = gmod.gui.SetMousePos
local gui_EnableScreenClicker = gmod.gui.EnableScreenClicker
local system_HasFocus = gmod.system.HasFocus
local SetClipboardText = gmod.SetClipboardText

local META = ... or prototype.GetRegistered("window")


function META:Initialize()
	local self = META:CreateObject()

	local event_name_translate = {}

	local function call(self, name, ...)
		if not event_name_translate[name] then
			event_name_translate[name] = name:gsub("^On", "Window")
		end

		local b

		if self[name] then
			if self[name](self, ...) ~= false then
				b = event.Call(event_name_translate[name], self, ...)
			end
		end

		return b
	end


	if not gmod.TEST_GOLUWA_GUI then return self end

	local translate = {
		mouse1 = "button_1",
		mouse2 = "button_2",
		mouse3 = "button_3",
		mouse4 = "button_4",

		leftarrow = "left",
		rightarrow = "right",
		uparrow = "up",
		downarrow = "down",

		[gmod.KEY_LCONTROL] = "left_control",
		[gmod.KEY_RCONTROL] = "right_control",
		[gmod.KEY_LALT] = "left_alt",
		[gmod.KEY_RALT] = "right_alt",
	}

	local keys = {}

	local function key_input(i, press)
		local key = input_GetKeyName(i)

		if key then
			key = key:lower()
		else
			key = i
		end

		key = translate[key] or translate[i] or key

		if not key or type(key) == "number" then
			print("[goluwa] unhandled key event:", i, key, input_GetKeyName(i), press)
			return
		end

		call(self, "OnKeyInput", key, press)
	end

	local function char_input(i)
		local key = input_GetKeyName(i)

		if key then
			key = key:lower()
		else
			key = i
		end

		key = translate[key] or key

		if not key or type(key) == "number" then
			print("[goluwa] unhandled char event:", i, key, input_GetKeyName(i))
			return
		end

		local char = key

		-- etc
		if system_GetCountry() == "NO" then
			if key == "`" then
				char = "|"
			elseif key == "semicolon" then
				char = "ø"
			elseif key == "'" then
				char = "æ"
			elseif key == "[" then
				char = "å"
			end
		end

		if char then
			if input_IsShiftDown() then
				char = utf8.upper(char)
			end

			if utf8.length(char) == 1 then
				if input.debug then print("char:", char) end
				call(self, "OnCharInput", char)
			end
		end
	end

	local buttons = {}

	local function mouse_input(btn, press)
		btn = translate[btn] or btn

		call(self, "OnMouseInput", btn, press, gui_MousePos())
	end

	local char_input_timer = math.huge
	local next_char_input = 0

	local function check_keys()
		for i = KEY_FIRST + 1, KEY_LAST do
			if input_IsKeyDown(i) then
				if not keys[i] then
					key_input(i, true)
					--char_input(i)
					--char_input_timer = system.GetElapsedTime() + 0.5
				end
				keys[i] = true
--[[
				if system.GetElapsedTime() > char_input_timer then
					if next_char_input < system.GetElapsedTime() then
						char_input(i)
						next_char_input = system.GetElapsedTime() + 0.05
					end
				end
]]
			else
				if keys[i] then
					key_input(i, false)
				end
				keys[i] = false
			end
		end

		for i = MOUSE_FIRST, MOUSE_LAST do
			if input_IsMouseDown(i) then
				if not buttons[i] then
					mouse_input(input_GetKeyName(i):lower(), true)
				end
				buttons[i] = true
			else
				if buttons[i] then
					mouse_input(input_GetKeyName(i):lower(), false)
				end
				buttons[i] = false
			end
		end
	end

	gmod.hook.Add("Think", "goluwa_keys", check_keys)
	gmod.hook.Add("KeyPress", "goluwa_keys", check_keys) -- resposnive

	local gmod_text_entry = NULL

	event.AddListener("TextInputFocus", "gmod_text_input", function(pnl)
		if not gmod_text_entry:IsValid() then
			local pnl = gmod.vgui.Create("EditablePanel")
			gmod_text_entry = pnl

			local text_entry = pnl:Add("TextEntry")

			pnl:MakePopup()
			text_entry:RequestFocus()
			text_entry:SetSize(0,0)
			text_entry.Paint = function() end
			text_entry.OnTextChanged = function()
				call(self, "OnCharInput", text_entry:GetText())
				text_entry:SetText("")
			end

			pnl.text_entry = text_entry
		end
	end)

	event.AddListener("TextInputUnfocus", "gmod_text_input", function(pnl)
		if gmod_text_entry:IsValid() then
			gmod_text_entry:Remove()
		end
	end)

	return self
end

function META:OnRemove()
	event.RemoveListener("TextInputFocus", "gmod_text_input")
	event.RemoveListener("TextInputUnfocus", "gmod_text_input")

	gmod.hook.Remove("Think", "goluwa_keys")
	gmod.hook.Remove("KeyPress", "goluwa_keys")
end


function META:Maximize() end
function META:Minimize() end
function META:Restore() end

function META:SetCursor(mode)
	self.Cursor = mode

	if mode == "trapped" or mode == "hidden" then
		gui.EnableScreenClicker(false)
	else
		gui.EnableScreenClicker(true)
	end
end


function META:GetMousePosition()
	return Vec2(gui_MousePos())
end

function META:SetMousePosition(pos)
	gui_SetMousePos(pos.x, pos.y)
end

function META:IsFocused()
	return system.HasFocus()
end

function META:SetClipboard(str)
	SetClipboardText(tostring(str))
end

function META:GetClipboard()
	return ""
end

do
	local battery_level
	local last_check_battery_level = 0

	function system.GetBatteryLevel()
		if last_check_battery_level < system.GetElapsedTime() then
			battery_level = system.BatteryPower() / 100
		end

		return battery_level
	end
end

function system.IsUsingBattery()
	return system.GetBatteryLevel() ~= 1
end