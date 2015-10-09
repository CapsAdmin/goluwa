event.Timer("busy_indicator", 1, 0, function()
	if tasks.IsBusy() then
		gui.world:SetCursor("wait")
	else
		gui.world:SetCursor()
	end
end)