local addons = steam.GetGamePath("GarrysMod") .. "garrysmod/addons/"

for path in vfs.Iterate(addons, nil, true) do 
	if vfs.IsDir(path) then 
		vfs.Mount(path)  
	end 
end

if not CAPS then
	vfs.Mount(steam.GetGamePath("left 4 dead") .. "/left4dead/")
	vfs.Mount(steam.GetGamePath("left 4 dead 2") .. "/left4dead2/") 

	vfs.Mount(steam.GetGamePath("Half-Life 2") .. "/ep2/ep2_pak_dir.vpk")
	vfs.Mount(steam.GetGamePath("Half-Life 2") .. "/episodic/ep1_pak_dir.vpk")
	vfs.Mount(steam.GetGamePath("Team Fortress 2") .. "tf/tf2_sound_vo_english_dir.vpk")
	vfs.Mount(steam.GetGamePath("Counter-Strike Source") .. "/cstrike/cstrike_pak_dir.vpk")  
end

vfs.Mount(steam.GetGamePath("GarrysMod") .. "sourceengine/hl2_sound_vo_english_dir.vpk") 
vfs.Mount(steam.GetGamePath("GarrysMod") .. "sourceengine/hl2_sound_misc_dir.vpk")     

local function clean_sentence(sentence)

	sentence = sentence:lower()
	sentence = sentence:gsub("_", " ")
	sentence = sentence:gsub("%p", "")
	sentence = sentence:gsub("%s+", " ")
	
	return sentence
end
 
local found = {}
	
local function callback()
	vfs.Search("sound/", {"wav", "ogg"}, function(path) 
		local sentence
		
		if path:find("%.wav") then
			local ok, data = pcall(vfs.Read, path, "b")
			sentence = data:match("PLAINTEXT%s{%s(.-)%s}%s")
		end
		
		if not sentence or sentence == "" then
			sentence = path:match(".+/(.+)%.")
		end
 		
		sentence = clean_sentence(sentence)
		
		if sentence == "" then
			sentence = path:match(".+/(.+)%.")
			sentence = clean_sentence(sentence)
		end		
		
		table.insert(found, path .. "=" .. sentence)
		
		coroutine.yield()
	end)
end
	   
local co = coroutine.create(function() return xpcall(callback, goluwa.OnError) end)

event.AddListener("OnUpdate", "lol", function()
	local ok, err = coroutine.resume(co)
	
	if wait(1) then
		print(#found .. " sentences found")
	end
	
	if wait(10) or not ok then
		print("saving..")
		vfs.Write("chatsounds_data", table.concat(found, "\n"))
	end
	
	if not ok and err then error(err) end
end) 