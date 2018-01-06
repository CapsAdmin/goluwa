local init = false

event.AddListener("ClientChat", "chatsounds", function(client, txt, seed)
	if not init then
		chatsounds.Initialize()
		chatsounds.BuildFromGithub("PAC3-Server/chatsounds")
		for k,v in ipairs(steam.GetMountedSourceGames()) do
			chatsounds.LoadListFromAppID(v.filesystem.steamappid)
		end
		init = true
	end

	if not txt:find("^%p") then
		chatsounds.Say(txt, seed)
	end
end)