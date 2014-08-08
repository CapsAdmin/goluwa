do
	function gui.GetScreenSize()
		return Vec2(surface.GetScreenSize())
	end

	function gui.GetTextSize(font, str)
		surface.SetFont(font)		
		return Vec2(surface.GetTextSize(str))
	end	
		
	function gui.SetCursor(id)
		system.SetCursor(id)
	end
	
	local shapes = {
		rect = function(rect, color, roundness, border_size, border_color, shadow_distance, shadow_color, tl, tr, bl, br)    
			color = color or Color(1,1,1,1)

			surface.SetWhiteTexture()
			
			if shadow_distance then
				shadow_color = shadow_color or Color(0,0,0,0.5)
				surface.SetColor(shadow_color:Unpack())
				surface.DrawRect(rect.x + shadow_distance.x, rect.y + shadow_distance.y, rect.w, rect.h)
			end
			
			if border_size and border_size > 0 then
				border_color = border_color or Color(1,1,1,1)

				surface.SetColor(border_color:Unpack())
				surface.DrawRect(rect:Unpack())
			
				rect:Shrink(border_size)
			end			
			
			surface.SetColor(color:Unpack())
			surface.DrawRect(rect:Unpack())
		end,
		
		text = function(text, pos, font, color, align_normal, shadow_dir, shadow_color, shadow_size, shadow_blur)			
			surface.SetFont(font)
			
			local x, y = pos:Unpack()
			
			if align_normal then
				local w, h = surface.GetTextSize(text)
				
				x = x + (w * align_normal.x)
				y = y + (h * align_normal.y)

				surface.SetTextPos(x, y)
			end
			
			surface.SetColor(color:Unpack())
			surface.DrawText(text)
			
			if gui.debug then			
				surface.SetColor(1,0,0,0.25)
				surface.SetWhiteTexture()
				local w, h = surface.GetTextSize(text)
				surface.DrawRect(x, y, w, h)
			end
		end,
		
		texture = function(tex, rect, color, uv, nofilter)
			color = color or Color(1,1,1,1)

			surface.SetTexture(tex)
			surface.SetColor(color:Unpack())
			surface.DrawRect(rect:Unpack())
		end,
		
		line = function(a, b, color)
			surface.SetColor(color:Unpack())
			surface.DrawLine(a.x, a.y, b.x, b.y)
		end,
	}

	function gui.Draw(type, ...)
		if shapes[type] then
			shapes[type](...)
		else
			--errorf("unknown shape %s", 2, type)
		end
	end

	function gui.StartDraw(pnl, clip)		
		local x, y = pnl:GetPos():Unpack()
						
		surface.PushMatrix(x, y)
				
		if gui.debug then
			if pnl.ClassName == "text_button" then 
				surface.SetColor(1,1,0,1)
			else
				surface.SetColor(1,0,0,1)
			end
			surface.DrawRect(0,0,3,3)
		end
	end

	function gui.EndDraw(pnl, clip)	
		surface.PopMatrix()
	end
	
	-- i'm not sure what i'm doing here..
	
	function gui.StartClip(pnl)		
		if gui.noclip then return end
		if pnl:HasParent() then	
			local offset = pnl.Parent:GetOffset()
			local siz = pnl.Parent:GetSize()
			local pos = pnl.Parent:GetWorldPos()
			
			if not offset:IsZero() then
				pos = pos - offset
				siz = siz + offset
			end
			
			local w, h = siz:Unpack()
			local x, y = pos:Unpack()
			
			surface.StartClipping(x, y, w, h)
		end
	end
	
	function gui.EndClip()
		if gui.noclip then return end
		surface.EndClipping()
	end
end

gui.remove_these = gui.remove_these or {}

function gui.Update(delta)
	for key, pnl in pairs(gui.remove_these) do
		pnl:Remove(true)
		gui.remove_these[key] = nil
	end

	if gui.ActivePanel:IsValid() then
		input.DisableFocus = true
	else
		input.DisableFocus = false
	end
	
	event.Call("DrawHUD", delta)
	
	event.Call("PreDrawMenu", delta)
		if gui.ActiveSkin:IsValid() then
			gui.ActiveSkin.FT = delta
			gui.ActiveSkin:Think(delta)
		end
		
		if gui.World:IsValid() then
			gui.World:Draw()
		end
		
		gui.EndClip()
		
		if gui.HoveringPanel:IsValid() then
			gui.SetCursor(gui.HoveringPanel:GetCursor())
		else
			gui.SetCursor("arrow")
		end
	event.Call("PostDrawMenu", delta)
end

event.AddListener("Draw2D", "gui", gui.Update)