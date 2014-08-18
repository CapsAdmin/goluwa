
do -- events
	function gui.GetMousePos()
		return window.GetMousePos()
	end
	
	function gui.IsMouseDown(button)
		return input.IsMouseDown(button)
	end

	event.AddListener("KeyInputRepeat", "gui", function(key, press)
		gui.KeyInput(key, press)
	end, {on_error = system.OnError})
	
	event.AddListener("CharInput", "gui", function(char)
		gui.CharInput(char, true)
	end, {on_error = system.OnError})

	event.AddListener("MouseInput", "gui", function(key, press)
		gui.MouseInput(key, press, gui.GetMousePos())
	end, {on_error = system.OnError})
end

function gui.CallEvent(pnl, name, ...)
	pnl = pnl or gui.World
	
	if pnl:IsValid() then
		return pnl:CallEvent(name, ...)
	end
end

function gui.MouseInput(key, press, pos)
	local tbl = {}
	
	for _, pnl in pairs(gui.GetPanels()) do
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

function gui.KeyInput(key, press)
	return gui.CallEvent(gui.World, "KeyInput", key, press)
end

function gui.CharInput(key, press)
	return gui.CallEvent(gui.World, "CharInput", key, press)
end
 