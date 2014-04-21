chatsounds.Initialize()

local seed = 0

event.AddListener("OnPlayerChat", "chatsounds", function(ply, txt)
	chatsounds.Say(ply, txt, seed)
	
	seed = seed + 1
end)