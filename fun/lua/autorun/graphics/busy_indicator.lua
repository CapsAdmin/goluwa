event.AddListener("TasksBusy", "busy_indicator", function(b)
	if b then
		gui.world:SetCursor("wait")
	else
		gui.world:SetCursor()
	end
end)