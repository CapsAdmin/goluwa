vfs.Mount(steam.GetGamePath("GarrysMod") .. "sourceengine/hl2_sound_vo_english_dir.vpk")
local snd = Sound("sound/vo/breencast/br_overwatch08.wav")
snd:Play() 
table.print(snd.decode_info)