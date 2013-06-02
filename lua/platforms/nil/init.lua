printf("Platform is nil! mmmy will use a while loop to update instead.")

addons.AutorunAll()

function main()
	event.Call("Initialize")
		
	while true do
		event.Call("OnUpdate")
	end
	
	event.Call("ShutDown")
end

event.AddListener("Initialized", "main", main)