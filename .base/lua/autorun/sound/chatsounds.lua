--chatsounds.Initialize()

event.AddListener("ClientChat", "chatsounds", function(client, txt, seed)
	if not txt:find("^%p") then
		chatsounds.Say(client, txt, seed)
	end
end)