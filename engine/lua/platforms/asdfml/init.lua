require("header_parse.lua")

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