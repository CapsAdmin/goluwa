local gmod = ... or gmod
local vgui = gmod.env.vgui

gmod.gui_world = gmod.gui_world or NULL

local translate_mouse = {
	button_1 = gmod.env.MOUSE_LEFT,
	button_2 = gmod.env.MOUSE_RIGHT,
	button_3 = gmod.env.MOUSE_MIDDLE,
	button_4 = gmod.env.MOUSE_4,
	button_5 = gmod.env.MOUSE_5,
	mwheel_up = gmod.env.MOUSE_WHEEL_UP,
	mwheel_down = gmod.env.MOUSE_WHEEL_DOWN,
}

local translate_key = {}
for k,v in pairs(gmod.env) do
	if k:startswith("KEY_") then
		translate_key[k:match("KEY_(.+)"):lower()] = v
	end
end

local function vgui_Create(class, parent, name)

	if not gmod.gui_world:IsValid() then
		gmod.gui_world = gui.CreatePanel("base")
		gmod.gui_world:SetColor(Color(0,0,0,0))
		gmod.gui_world.__class = "CGModBase"
		function gmod.gui_world:OnUpdate()
			local size = window.GetSize()
			self.Size.x = size.x
			self.Size.y = size.y
		end
	end

	class = class:lower()

	local obj

	if class == "textentry" then
		obj = gui.CreatePanel("text_edit")
	else
		obj = gui.CreatePanel("base")
	end

	local self = gmod.WrapObject(obj, "Panel")

	obj.gmod_pnl = self
	self.__class = class

	obj.fg_color = Color(1,1,1,1)
	obj.bg_color = Color(1,1,1,1)
	obj.text_inset = Vec2()
	obj.text_offset = Vec2()
	obj.vgui_type = class
	--self:SetPaintBackgroundEnabled(true)
	obj:SetSize(Vec2(64, 24))
	obj:SetPadding(Rect())
	obj:SetMargin(Rect())

	self:MouseCapture(false)

	self:SetParent(parent)

	obj.OnChildAdd = function(_, child)
		if obj.gmod_prepared then
			child = gmod.WrapObject(child, "Panel")
			if child.__obj.gmod_prepared then
				self:OnChildAdded(child)
			end
		end
	end

	obj.OnChildRemove = function(_, child)
		if obj.gmod_prepared then
			child = gmod.WrapObject(child, "Panel")
			if child.__obj.gmod_prepared then
				self:OnChildRemoved(child)
			end
		end
	end

	obj.OnDraw = function()
		if self.gmod_layout then
			self:InvalidateLayout(true)
			self.gmod_layout = nil
		end

		local paint_bg = self:Paint(obj:GetWidth(), obj:GetHeight())

		if not obj.draw_manual then
			if obj.paint_bg and paint_bg ~= nil then
				surface.SetWhiteTexture()
				surface.SetColor(obj.bg_color:Unpack())
				surface.DrawRect(0,0,obj.Size.x,obj.Size.y)
			end

			if class == "label" then
				if obj.text_internal and obj.text_internal ~= "" then
					surface.SetColor(obj.fg_color:Unpack())
					surface.SetTextPosition(obj.text_offset.x, obj.text_offset.y)
					surface.SetFont(gmod.surface_fonts[obj.font_internal])
					surface.DrawText(obj.text_internal)
				end
			end
		end

		self:PaintOver(obj:GetWidth(), obj:GetHeight())
	end
	obj:CallOnRemove(function() self:OnDeletion() end)
	obj.OnUpdate = function() self:Think() self:AnimationThink() end
	obj.OnMouseMove = function(_, x, y) self:OnCursorMoved(x, y) end
	obj.OnMouseEnter = function() self:OnCursorEntered() end
	obj.OnMouseExit = function() self:OnCursorExited() end

	-- OnChildAdd and such doesn't seem to be called in Init

	obj.OnPostLayout = function()
		local panel = obj

		if panel.vgui_type == "label" then
			local w, h = gmod.surface_fonts[panel.font_internal]:GetTextSize(panel.text_internal)
			local m = panel:GetMargin()

			if panel.content_alignment == 5 then
				panel.text_offset = (panel:GetSize() / 2) - (Vec2(w, h) / 2)
			elseif panel.content_alignment == 4 then
				panel.text_offset.x = m:GetLeft()
				panel.text_offset.y = (panel:GetHeight() / 2) - (h / 2)
			elseif panel.content_alignment == 6 then
				panel.text_offset.x = panel:GetWidth() - w - m:GetRight()
				panel.text_offset.y = (panel:GetHeight() / 2) - (h / 2)
			elseif panel.content_alignment == 2 then
				panel.text_offset.x = (panel:GetWidth() / 2) - (w / 2)
				panel.text_offset.y = panel:GetHeight() - h - m:GetBottom()
			elseif panel.content_alignment == 8 then
				panel.text_offset.x = (panel:GetWidth() / 2) - (w / 2)
				panel.text_offset.y = m:GetTop()
			elseif panel.content_alignment == 7 then
				panel.text_offset.x = m:GetLeft()
				panel.text_offset.y = m:GetTop()
			elseif panel.content_alignment == 9 then
				panel.text_offset.x = panel:GetWidth() - w - m:GetRight()
				panel.text_offset.y = m:GetTop()
			elseif panel.content_alignment == 1 then
				panel.text_offset.x = m:GetLeft()
				panel.text_offset.y = panel:GetHeight() - h - m:GetBottom()
			elseif panel.content_alignment == 3 then
				panel.text_offset.x = panel:GetWidth() - w - m:GetRight()
				panel.text_offset.y = panel:GetHeight() - h - m:GetBottom()
			end

			panel.text_offset = panel.text_offset + panel.text_inset
		end

		self:InvalidateLayout(true)
	end

	obj.OnMouseInput = function(_, button, press)
		if translate_mouse[button] then
			if press then
				if self.OnMousePressed then
					self:OnMousePressed(translate_mouse[button])
				end
			else
				if self.OnMouseReleased then
					self:OnMouseReleased(translate_mouse[button])
				end
			end
		else
			logf("mouse button %q could not be translated!\n", button)
		end
	end

	obj.OnKeyInput = function(_, key, press)
		if press and self.OnKeyCodePressed then
			if translate_key[key] then
				self:OnKeyCodePressed(translate_key[key])
			else
				logf("key %q could not be translated!\n", key)
			end
		end
	end

	function obj:IsInsideParent()
		if
			self.Position.x < self.Parent.Size.x and
			self.Position.y < self.Parent.Size.y and
			self.Position.x + self.Size.x > 0 and
			self.Position.y + self.Size.y > 0
		then
			return true
		end

		return false
	end

	return self
end

if vgui.CreateX then
	vgui.CreateX = vgui_Create
else
	vgui.Create = vgui_Create
end

function vgui.GetHoveredPanel()
	local pnl = gui.GetHoveringPanel()
	if pnl:IsValid() then
		return gmod.WrapObject(gui.GetHoveringPanel(), "Panel")
	end
end

function vgui.FocusedHasParent(parent)
	if gui.focus_panel:IsValid() and parent then
		return parent.__obj:HasChild(gui.focus_panel)
	end
end

function vgui.GetKeyboardFocus()
	return true
end