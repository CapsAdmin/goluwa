printf("mmyy: No platform name set! mmmy will use a while loop to update instead.")

addons.AutorunAll()

function main()
	hook.Call("Initialize")
		
	while true do
		hook.Call("OnUpdate")
		timer.Update()
	end
	
	hook.Call("ShutDown")
end

hook.Add("Initialized", "main", main)