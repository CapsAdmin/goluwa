users = dofile("libraries/users")
system = dofile("libraries/system")
console = dofile("libraries/console")

function main()
	event.Call("Initialize")
	
	dofile("open_states.lua")
		
	while true do				
		luasocket.Update()
		timer.Update()
		
		event.Call("OnUpdate")
	end
		
	event.Call("ShutDown")
end


event.AddListener("Initialized", "main", main)

utilities.MonitorFileInclude()