
do -- events
	function aahh.GetMousePos()
		return window.GetMousePos()
	end

	event.AddListener("OnKeyInput", "aahh", function(key, press)
		aahh.KeyInput(key, press)
	end, logn)
	
	event.AddListener("OnChar", "aahh", function(char)
		aahh.CharInput(char, true)
	end, logn)

	event.AddListener("OnMouseInput", "aahh", function(key, press)
		aahh.MouseInput(key, press, aahh.GetMousePos())
	end, logn)
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
 