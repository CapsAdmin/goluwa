GARRYSMOD = "..\\..\\orangebox\\garrysmod\\"
GARRYSMODX = "..\\orangebox\\garrysmod\\" -- grabbin puke
SRCDS = "..\\..\\orangebox\\"

gserv = dofile("libraries/gserv")
console = dofile("libraries/console")

console.AddCommand("start", function()
	gserv.StartServer(1)
end)

console.AddCommand("stop", function()
	gserv.StopServer(1)
end)

console.AddCommand("reload", function()
	gserv.ReloadFastDL()
	logn("FastDL reloaded")
end)

console.AddCommand("update", function()
	gserv.UpdateServer()
end)

console.AddCommand("update_repositories", function()
	gserv.UpdateRepositories()
end)

function main()
	event.Call("Initialize")

	--gserv.UpdateRepositories()
	gserv.CompressThings()
	gserv.InjectFastDLSomething()
	--gserv.ReloadFastDL()
	gserv.StartServer(1)
	--gserv.UpdateGame()
	
	while true do
		luasocket.Update()
		event.Call("OnUpdate")
	end
	
	event.Call("ShutDown")
end

event.AddListener("Initialized", "main", main)