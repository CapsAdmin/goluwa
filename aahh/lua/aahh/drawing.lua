do
	function aahh.GetScreenSize()
		return Vec2(surface.GetScreenSize())
	end

	function aahh.GetTextSize(font, str)
		surface.SetFont(font)		
		return Vec2(surface.GetTextSize(str))
	end	
		
	function aahh.SetCursor(id)
		system.SetCursor(id)
	end
	
	local shapes = {
		rect = function(rect, color, roundness, border_size, border_color, shadow_distance, shadow_color, tl, tr, bl, br)    
			color = color or Color(1,1,1,1)

			surface.SetWhiteTexture()
			
			if shadow_distance then
				shadow_color = shadow_color or Color(0,0,0,0.5)
				surface.Color(shadow_color:Unpack())
				surface.DrawRect(rect.x + shadow_distance.x, rect.y + shadow_distance.y, rect.w, rect.h)
			end
			
			if border_size and border_size > 0 then
				border_color = border_color or Color(1,1,1,1)

				surface.Color(border_color:Unpack())
				surface.DrawRect(rect:Unpack())
			
				rect:Shrink(border_size)
			end			
			
			surface.Color(color:Unpack())
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
			
			surface.Color(color:Unpack())
			surface.DrawText(text)
			
			if aahh.debug then			
				surface.Color(1,0,0,0.25)
				surface.SetWhiteTexture()
				local w, h = surface.GetTextSize(text)
				surface.DrawRect(x, y, w, h)
			end
		end,
		
		texture = function(tex, rect, color, uv, nofilter)
			color = color or Color(1,1,1,1)

			surface.SetTexture(tex)
			surface.Color(color:Unpack())
			surface.DrawRect(rect:Unpack())
		end,
		
		line = function(a, b, color)
			surface.Color(color:Unpack())
			surface.DrawLine(a.x, a.y, b.x, b.y)
		end,
	}

	function aahh.Draw(type, ...)
		if shapes[type] then
			shapes[type](...)
		else
			--errorf("unknown shape %s", 2, type)
		end
	end

	function aahh.StartDraw(pnl, clip)
		if pnl.NoMatrix then return end
		
		local x, y = pnl:GetPos():Unpack()
						
		surface.PushMatrix(x, y)
				
		if aahh.debug then
			if pnl.ClassName == "textbutton" then 
				surface.Color(1,1,0,1)
			else
				surface.Color(1,0,0,1)
			end
			surface.DrawRect(0,0,3,3)
		end
	end

	function aahh.EndDraw(pnl, clip)	
		if pnl.NoMatrix then return end
		surface.PopMatrix()
	end
	
	-- i'm not sure what i'm doing here..
	
	function aahh.StartClip(pnl)		
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
	
	function aahh.EndClip()

		surface.EndClipping()
	end
end

aahh.remove_these = aahh.remove_these or {}

function aahh.Update(delta)
	for key, pnl in pairs(aahh.remove_these) do
		pnl:Remove(true)
		aahh.remove_these[key] = nil
	end

	if aahh.ActivePanel:IsValid() then
		input.DisableFocus = true
	else
		input.DisableFocus = false
	end
	
	event.Call("DrawHUD", delta)
	
	event.Call("PreDrawMenu", delta)
		if aahh.ActiveSkin:IsValid() then
			aahh.ActiveSkin.FT = delta
			aahh.ActiveSkin:Think(delta)
		end
		
		if aahh.World:IsValid() then
			aahh.World:Draw()
		end
		
		aahh.EndClip()
		
		if aahh.HoveringPanel:IsValid() then
			aahh.SetCursor(aahh.HoveringPanel:GetCursor())
		else
			aahh.SetCursor(e.IDC_ARROW)
		end
	event.Call("PostDrawMenu", delta)
end

event.AddListener("OnDraw2D", "aahh", aahh.Update, logn)