--chatsounds.Initialize()

do return end

event.AddListener("ClientChat", "chatsounds", function(client, txt, seed)
	if not txt:find("^%p") then
		chatsounds.Initialize()

		chatsounds.Say(client, txt, seed)
	end
end)