do
	package.preload["mime.core"] = function()
		return {b64 = crypto.Base64Encode}
	end
	runfile("lua/libraries/sockets/irc.lua", sockets)
	runfile("lua/libraries/sockets/webhooks.lua", sockets)
	_G.intermsg = runfile("lua/libraries/sockets/intermsg.lua")
end

runfile("lua/decoders/files/*", vfs)
runfile("lua/libraries/steam/server_query.lua", steam)
--runfile("lua/libraries/steam/steamworks.lua", steam)
runfile("lua/libraries/steam/web_api.lua", steam)
runfile("lua/libraries/utilities/find_color.lua", utilities)
runfile("lua/libraries/utilities/quickbms.lua", utilities)
runfile("lua/libraries/utilities/vmd_parser.lua", utilities)
runfile("lua/libraries/utilities/line.lua", utilities)

if SERVER or CLIENT then
	chat = runfile("lua/libraries/network/chat.lua")
	runfile("lua/libraries/network/chat_above_head.lua")
end

if GRAPHICS then
	runfile("lua/gui_panels/*", gui)
	runfile("lua/decoders/fonts/*", fonts)
end

if SOUND then
	runfile("lua/decoders/sound/*", audio)
	runfile("lua/libraries/audio/midi.lua", audio)
	chatsounds = runfile("lua/libraries/audio/chatsounds/chatsounds.lua")
end

line = runfile("lua/libraries/love/line.lua") -- a löve wrapper that lets you run löve games
gine = runfile("lua/libraries/gmod/gine.lua") -- a gmod wrapper that lets you run gmod scripts
if not CLI then
	resource.AddProvider("https://gitlab.com/CapsAdmin/goluwa-assets/raw/master/extras/", true)
end

if GRAPHICS then menu = runfile("lua/libraries/graphics/menu.lua") end

goluwa = event.CreateRealm("goluwa")

if WINDOW then
	event.AddListener("WindowOpened", function()
		love = line.CreateLoveEnv() -- https://www.love2d.org/wiki/love
	--menu.Open()
	end)
end