-- delay so we don't time out while initializing all the other stuff
event.Delay(0.25, function()
	if CAPS or MORTEN then
		console.RunString("connect 192.168.0.18")
		--console.RunString("connect 192.168.0.10")
	else
		console.RunString("connect 109.199.217.23")
	end
end)
