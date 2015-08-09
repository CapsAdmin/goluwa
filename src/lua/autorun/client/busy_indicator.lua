event.CreateTimer("busy_indicator", 1, 0, function()
	if threads.IsBusy() then
		gui.world:SetCursor("wait")
	else
		gui.world:SetCursor()
	end
end)