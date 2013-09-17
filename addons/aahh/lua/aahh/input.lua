
do -- events
	function aahh.GetMousePosition()
		return input.GetMousePos()
	end

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
end

function aahh.CallEvent(pnl, name, ...)
	pnl = pnl or aahh.World
	
	return pnl:CallEvent(name, ...)
end

function aahh.MouseInput(key, press, pos)
	local tbl = {}
	
	for _, pnl in pairs(aahh.GetPanels()) do
		if not pnl.IgnoreMouse and pnl:IsWorldPosInside(pos) and pnl:IsVisible() then
			
			if pnl.AlwaysReceiveMouse then
				pnl:OnMouseInput(key, press, pos - pnl:GetWorldPos())
			end
			
			table.insert(tbl, pnl)
		end
	end

	for _, pnl in pairs(tbl) do
		if pnl:IsInFront() then
			return pnl:OnMouseInput(key, press, pos - pnl:GetWorldPos())
		end
	end
	
	for _, pnl in pairs(tbl) do	
		if press then pnl:BringToFront() end
		return pnl:OnMouseInput(key, press, pos - pnl:GetWorldPos())
	end
end

function aahh.KeyInput(key, press)
	return aahh.CallEvent(aahh.World, "KeyInput", key, press)
end

function aahh.CharInput(key, press)
	return aahh.CallEvent(aahh.World, "CharInput", key, press)
end
 