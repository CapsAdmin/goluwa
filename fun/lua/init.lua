runfile("lua/libraries/filesystem/files/*", vfs)

runfile("lua/libraries/steam/server_query.lua", steam)
--runfile("lua/libraries/steam/steamworks.lua", steam)
runfile("lua/libraries/steam/web_api.lua", steam)

runfile("lua/libraries/utilities/find_color.lua", utilities)
runfile("lua/libraries/utilities/quickbms.lua", utilities)
runfile("lua/libraries/utilities/vmd_parser.lua", utilities)

if SERVER or CLIENT then
	chat = runfile("lua/libraries/network/chat.lua")
	runfile("lua/libraries/network/chat_above_head.lua")
end

if GRAPHICS then
	gui = runfile("lua/libraries/graphics/gui/gui.lua")

	runfile("lua/libraries/graphics/fonts/fonts/*", fonts)

	runfile("lua/libraries/graphics/gfx/particles.lua", gfx)
	runfile("lua/libraries/graphics/gfx/video.lua", gfx)
end

if SOUND then
	runfile("lua/libraries/audio/midi.lua", audio)
	chatsounds = runfile("lua/libraries/audio/chatsounds/chatsounds.lua")
end

line = runfile("lua/libraries/love/line.lua") -- a löve wrapper that lets you run löve games
gine = runfile("lua/libraries/gmod/gine.lua") -- a gmod wrapper that lets you run gmod scripts

if not CLI then
	resource.AddProvider("https://github.com/CapsAdmin/goluwa-assets/raw/master/base/", true)
	resource.AddProvider("https://github.com/CapsAdmin/goluwa-assets/raw/master/extras/", true)
end

if WINDOW then
	gui.Initialize()
	love = line.CreateLoveEnv() -- https://www.love2d.org/wiki/love
end