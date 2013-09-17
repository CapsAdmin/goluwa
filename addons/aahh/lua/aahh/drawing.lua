do
	function aahh.GetScreenSize()
		return Vec2(render.w, render.h)
	end

	function aahh.GetTextSize()
		return Vec2(1, 1)
	end	
		
	function aahh.SetCursor()

	end

	function aahh.Draw(type, ...)
		--print(type, ...)
	end

	function aahh.StartDraw(pnl)
		if not pnl:IsValid() then return end
		surface.PushMatrix(pnl:GetWorldPos():Unpack())
	end

	function aahh.EndDraw(pnl)	
		surface.PopMatrix()
	end
end

function aahh.Update(delta)
	for key, pnl in pairs(aahh.GetPanels()) do
		if pnl.remove_me then
			utilities.MakeNULL(pnl)
		end
	end

	if aahh.ActivePanel:IsValid() then
		input.DisableFocus = true
	else
		input.DisableFocus = false
	end
	
	event.Call("DrawHUD")
	
	event.Call("PreDrawMenu")
		if aahh.ActiveSkin:IsValid() then
			aahh.ActiveSkin.FT = delta
			aahh.ActiveSkin:Think(delta)
		end
		
		if aahh.World:IsValid() then
			aahh.World:Draw()
		end
		
		if aahh.HoveringPanel:IsValid() then
			aahh.SetCursor(aahh.HoveringPanel:GetCursor())
		else
			aahh.SetCursor(1)
		end
	event.Call("PostDrawMenu")
end

event.AddListener("OnDraw", "aahh", function(delta)
	aahh.Update(delta)
end, logn)