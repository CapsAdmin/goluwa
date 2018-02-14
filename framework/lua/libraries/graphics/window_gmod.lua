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

local window = ... or _G.window

local META = prototype.CreateTemplate("render_window")

function META:OnRemove()

end

function META:GetPosition()
	return Vec2(0, 0)
end

function META:SetPosition(pos)

end

function META:GetSize()
	return Vec2(ScrW(), ScrH())
end

function META:SetSize(size)

end

function META:Maximize()
end

function META:Minimize()
end

function META:Restore()
end

function META:SetTitle(title)
end

function META:GetMousePosition()
	return Vec2(gui_MousePos())
end

function META:SetMousePosition(pos)
	gui_SetMousePos(pos.x, pos.y)
end

function META:HasFocus()
	return system.HasFocus()
end

function META:ShowCursor(b)
	--gui.EnableScreenClicker(b)
	self.cursor_visible = b
end

function META:IsCursorVisible()
	return self.cursor_visible
end

function META:SetMouseTrapped(b)
	self.mouse_trapped = b

	gui_EnableScreenClicker(not b)
end

function META:GetMouseTrapped()
	return self.mouse_trapped
end

function META:GetMouseDelta()
	return Vec2()
end

function META:UpdateMouseDelta()

end

function META:OnUpdate(delta)

end

function META:OnFocus(focused)

end

function META:OnShow()

end

function META:OnClose()

end

function META:OnCursorPosition(x, y)

end

function META:OnFileDrop(paths)

end

function META:OnCharInput(str)

end

function META:OnKeyInput(key, press)

end

function META:OnKeyInputRepeat(key, press)

end

function META:OnMouseInput(key, press)

end

function META:OnMouseScroll(x, y)

end

function META:OnCursorEnter()

end

function META:OnRefresh()

end

function META:OnMove(x, y)

end

function META:OnIconify()

end

function META:OnResize(width, height)

end

function META:OnTextEditing(str)

end

function META:IsFocused()
	return system_HasFocus()
end

function META:SetClipboard(str)
	SetClipboardText(tostring(str))
end

function META:GetClipboard()
	return ""
end

function META:GetBatteryLevel()
	if (self.last_check_battery_level or 0) < system.GetElapsedTime() then
		self.battery_level = system.BatteryPower() / 100
	end

	return self.battery_level
end

do
	function META:IsUsingBattery()
		return self:GetBatteryLevel() ~= 255
	end
end

do
	local current

	function META:SetCursor(id)
		id = id or "arrow"

		current = id
	end

	function META:GetCursor()
		return current
	end

end

META:Register()

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

function window.CreateWindow(width, height, title, flags)
	local self = META:CreateObject()

	do return self end
	-- don't need this for now

	local keys = {}

	local function key_input(key, press)
		call(self, "OnKeyInput", key, press)

		if press then
			local char = key

			-- etc
			if system_GetCountry() == "NO" then
				if key == "`" then
					char = "|"
				elseif key == "SEMICOLON" then
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
					call(self, "OnCharInput", char)
				end
			end
		end
	end

	local buttons = {}

	local translate = {
		MOUSE1 = "button_1",
		MOUSE2 = "button_2",
		MOUSE3 = "button_3",
		MOUSE4 = "button_4",
	}

	local function mouse_input(btn, press)
		btn = translate[btn] or btn

		call(self, "OnMouseInput", btn, press, gui_MousePos())
	end

	gmod.hook.Add("Think", "goluwa_keys", function()
		for i = KEY_FIRST, KEY_LAST do
			if input_IsKeyDown(i) then
				if not keys[i] then
					key_input(input_GetKeyName(i), true)
				end
				keys[i] = true
			else
				if keys[i] then
					key_input(input_GetKeyName(i), false)
				end
				keys[i] = false
			end
		end

		for i = MOUSE_FIRST, MOUSE_LAST do
			if input_IsMouseDown(i) then
				if not buttons[i] then
					mouse_input(input_GetKeyName(i), true)
				end
				buttons[i] = true
			else
				if buttons[i] then
					mouse_input(input_GetKeyName(i), false)
				end
				buttons[i] = false
			end
		end
	end)

	return self
end