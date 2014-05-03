chatsounds.Initialize()

event.AddListener("OnPlayerChat", "chatsounds", function(ply, txt, seed)
	if not txt:find(".-%p") then
		chatsounds.Say(ply, txt, seed)
	end
end)