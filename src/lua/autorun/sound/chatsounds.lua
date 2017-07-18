local init = false

event.AddListener("ClientChat", "chatsounds", function(client, txt, seed)
	if not init then
		chatsounds.Initialize()
		chatsounds.BuildFromGithub("https://api.github.com/repos/Metastruct/garrysmod-chatsounds/git/trees/master?recursive=1")
		for k,v in ipairs(steam.GetMountedSourceGames()) do
			chatsounds.LoadListFromAppID(v.filesystem.steamappid)
		end
		init = true
	end

	if not txt:find("^%p") then
		chatsounds.Say(txt, seed)
	end
end)