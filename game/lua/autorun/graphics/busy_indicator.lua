event.AddListener("TasksBusy", "busy_indicator", function(b)
	if not gui.world or not gui.world:IsValid() then return end

	if b then
		gui.world:SetCursor("wait")
	else
		gui.world:SetCursor()
	end
end)