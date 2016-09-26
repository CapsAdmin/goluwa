--chatsounds.Initialize()

event.AddListener("ClientChat", "chatsounds", function(client, txt, seed)
	if txt == "wow" then chatsounds.Initialize() end
	if not txt:find("^%p") then
		chatsounds.Say(txt, seed)
	end
end)