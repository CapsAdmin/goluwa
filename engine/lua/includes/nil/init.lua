printf("mmyy: No platform name set! mmmy will use a while loop to update instead.")

addons.AutorunAll()

function main()
	events.Call("Initialize")
		
	while true do
		events.Call("OnUpdate")
		timer.Update()
	end
	
	events.Call("ShutDown")
end

events.AddListener("Initialized", "main", main)