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

function vgui.Create(class, parent, name)
	local obj = gui.CreatePanel("base")
	if parent then obj:SetParent(parent.__obj) end
	
	local self = gmod.WrapObject(obj, "Panel")
	
	obj.fg_color = Color(1,1,1,1)
	obj.bg_color = Color(0,0,0,1)
	self:SetPaintBackgroundEnabled(true)
	
	obj.OnDraw = function() 
		if obj.Paint then 
			self:Paint(obj:GetWidth(), obj:GetHeight()) 
		end 
		
		if not obj.draw_manual then
			if obj.paint_bg then
				surface.SetColor(obj.bg_color:Unpack())
				surface.DrawRect(0,0,obj.Size.w,obj.Size.h)
			end
			
			if obj.text_internal and obj.text_internal ~= "" then
				surface.SetColor(obj.fg_color:Unpack())
				surface.SetTextPosition(0,0)
				surface.SetFont(obj.font_internal)
				surface.DrawText(obj.text_internal)
			end
		end
		
		if obj.PaintOver then 
			self:PaintOver(obj:GetWidth(), obj:GetHeight()) 
		end 
	end
	obj.OnUpdate = function() if self.Think then self:Think() end end
	obj.OnMouseMove = function(_, x, y) if self.OnCursorMoved then self:OnCursorMoved(x, y) end end
	obj.OnMouseEnter = function() if self.OnMouseEnter then self:OnMouseEnter() end end
	obj.OnCursorExited = function() if self.OnCursorExited then self:OnCursorExited() end end	
	obj.OnChildAdd = function(_, child) if self.OnChildAdded then self:OnChildAdded(child) end end	
	obj.OnLayout = function() if self.PerformLayout then self:PerformLayout(obj:GetWidth(), obj:GetHeight()) end end	
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
		end
	end
	
	return self
end

function vgui.GetHoveredPanel()
	return gmod.WrapObject(gui.GetHoveringPanel(), "Panel")
end

function vgui.GetHoveredPanel()
	return gmod.WrapObject(gui.world, "Panel")
end