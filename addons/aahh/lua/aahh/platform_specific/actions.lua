function aahh.GetMousePosition()

	-- grr int
	local pos = mouse.GetPosition(ffi.cast("struct sfWindow *", asdfml.GetWindow()))
	
	return Vec2(pos.x, pos.y)
end


function aahh.SetCursor()

end

event.AddListener("OnDraw", "aahh", function(delta)
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
		aahh.Draw(delta)
	event.Call("PostDrawMenu")
end, logn)

event.AddListener("OnKeyPressed", "aahh", function(params)
	aahh.KeyInput(params.key.code, true)
end)
event.AddListener("OnKeyReleased", "aahh", function(params)
	aahh.KeyInput(params.key.code, false)
end)

event.AddListener("OnTextEvent", "aahh", function(params)
	aahh.CharInput(params.text.unicode, true)
end)

event.AddListener("OnMouseButtonPressed", "aahh", function(params)
	aahh.MouseInput(params.mouseButton.button, true, Vec2(params.mouseButton.x, params.mouseButton.y))
end)

event.AddListener("OnMouseButtonReleased", "aahh", function(params)
	aahh.MouseInput(params.mouseButton.button, false, Vec2(params.mouseButton.x, params.mouseButton.y))
end)