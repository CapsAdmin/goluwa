local gmod = ... or gmod
local vgui = gmod.env.vgui

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

function vgui.CreateX(class, parent, name)
	
	class = class:lower()
		
	logn("vgui create ", class)
		
	local obj = class == "textentry" and gui.CreatePanel("text_edit") or gui.CreatePanel("base")
	if parent then obj:SetParent(parent.__obj) end
		
	local self = gmod.WrapObject(obj, "Panel")
	
	obj.fg_color = Color(1,1,1,1)
	obj.bg_color = Color(1,1,1,1)
	obj.text_offset = Vec2()
	obj.vgui_type = class
	self:SetPaintBackgroundEnabled(true)
	obj:SetSize(Vec2(250, 250))
	
	obj.OnDraw = function()
		local paint_rest = true
		
		if self.Paint then 
			paint_rest = not self:Paint(obj:GetWidth(), obj:GetHeight()) 
		end 
		
		if paint_rest and not obj.draw_manual and class == "label" then
			if obj.paint_bg then
				surface.SetColor(obj.bg_color:Unpack())
				surface.DrawRect(0,0,obj.Size.w,obj.Size.h)
			end
						
			if obj.text_internal and obj.text_internal ~= "" then
				surface.SetColor(obj.fg_color:Unpack())
				surface.SetTextPosition(obj.text_offset.x, obj.text_offset.y)
				surface.SetFont(obj.font_internal)
				surface.DrawText(obj.text_internal)
			end
		end
		
		if self.PaintOver then 
			self:PaintOver(obj:GetWidth(), obj:GetHeight()) 
		end 
	end
	obj:CallOnRemove(function() if self.OnDeletion then self:OnDeletion() end end)
	obj.OnUpdate = function() if self.Think then self:Think() end if self.AnimationThink then self:AnimationThink() end end
	obj.OnMouseMove = function(_, x, y) if self.OnCursorMoved then self:OnCursorMoved(x, y) end end
	obj.OnMouseEnter = function() if self.OnMouseEnter then self:OnMouseEnter() end end
	obj.OnCursorExited = function() if self.OnCursorExited then self:OnCursorExited() end end	
	obj.OnChildAdd = function(_, child) if self.OnChildAdded then self:OnChildAdded(gmod.WrapObject(child, "Panel")) end end	
	obj.OnChildRemove = function(_, child) if self.OnChildRemoved then self:OnChildRemoved(gmod.WrapObject(child, "Panel")) end end	
	obj.OnLayout = function() 
		local panel = obj
	
		if panel.vgui_type == "label" then
			local w, h = surface.GetFont(panel.font_internal):GetTextSize(panel.text_internal)
			
			local m = panel:GetMargin()
		
			if panel.content_alignment == 5 then
				panel.text_offset = (panel:GetSize() / 2) - (Vec2(w, h) / 2)
			elseif panel.content_alignment == 4 then
				panel.text_offset.x = m.left
				panel.text_offset.y = (panel:GetHeight() / 2) + (h / 2)
			elseif panel.content_alignment == 6 then
				panel.text_offset.x = panel:GetWidth() - w - m.right
				panel.text_offset.y = (panel:GetHeight() / 2) + (h / 2)
			elseif panel.content_alignment == 2 then
				panel.text_offset.x = (panel:GetWidth() / 2) + (w / 2)
				panel.text_offset.y = panel:GetHeight() - h - m.bottom
			elseif panel.content_alignment == 8 then
				panel.text_offset.x = (panel:GetWidth() / 2) + (w / 2)
				panel.text_offset.y = m.top
			elseif panel.content_alignment == 7 then
				panel.text_offset.x = m.left
				panel.text_offset.y = m.top
			elseif panel.content_alignment == 9 then
				panel.text_offset.x = panel:GetWidth() - w - m.right
				panel.text_offset.y = m.top
			elseif panel.content_alignment == 1 then
				panel.text_offset.x = m.left
				panel.text_offset.y = panel:GetHeight() - h - m.bottom
			elseif panel.content_alignment == 3 then
				panel.text_offset.x = panel:GetWidth() - w - m.right
				panel.text_offset.y = panel:GetHeight() - h - m.bottom
			end
		end
	
		if self.ApplySchemeSettings then 
			self:ApplySchemeSettings()
		end
	
		if self.PerformLayout then 
			self:PerformLayout(obj:GetWidth(), obj:GetHeight()) 
		end
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
	
	return self
end

if not vgui.Create then
	vgui.Create = vgui.CreateX
	vgui.CreateX = nil
end

function vgui.GetHoveredPanel()
	return gmod.WrapObject(gui.GetHoveringPanel(), "Panel")
end

function vgui.GetHoveredPanel()
	return gmod.WrapObject(gui.world, "Panel")
end

function vgui.FocusedHasParent(parent)
	if gui.focus_panel:IsValid() then
		return parent:HasChild(gui.focus_panel)
	end
end

function vgui.GetKeyboardFocus()
	return true
end