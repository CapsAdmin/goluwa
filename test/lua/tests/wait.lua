local time = 0

event.AddListener("Update", 1, function(dt)
	time = time + dt
	
	if wait(1) then
		print(time)
	end
end)