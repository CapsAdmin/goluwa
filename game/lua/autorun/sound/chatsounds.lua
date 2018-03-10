local init = false

event.AddListener("ClientChat", "chatsounds", function(client, txt, seed)
	if not init then
		chatsounds.Initialize()
		chatsounds.BuildFromGithub("PAC3-Server/chatsounds-valve-games")
		chatsounds.BuildFromGithub("PAC3-Server/chatsounds")
		chatsounds.BuildFromGithub("Metastruct/garrysmod-chatsounds", "sound/chatsounds/autoadd")
		init = true
	end

	if not txt:find("^%p") then
		chatsounds.Say(txt, seed)
	end
end)