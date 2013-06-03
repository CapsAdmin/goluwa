dofile("header_parse/sfml")
--dofile("header_parse/glew")
gl = dofile("libraries/opengl")

addons.AutorunAll()

function main()
	event.Call("Initialize")
		
	while true do
		event.Call("OnUpdate")
		timer.Update()
	end
	
	event.Call("ShutDown")
end

event.AddListener("Initialized", "main", main)