local init = false

event.AddListener("ClientChat", "chatsounds", function(client, txt, seed)
	if not init then
		chatsounds.Initialize()
		init = true
	end

	if not txt:find("^%p") then chatsounds.Say(txt, seed) end
end)