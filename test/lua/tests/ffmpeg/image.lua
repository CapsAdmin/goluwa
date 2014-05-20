local ffmpeg = require("lj-ffmpeg")

local path = R"textures/aahh/pac.png"
local decoder = assert(ffmpeg.Open(path, {video_only = true}))
local texture = Texture(decoder:GetConfig().width, decoder:GetConfig().height, decoder:Read())

function goluwa.decoder_test.OnDraw2D()
	surface.Color(1,1,1,1)
	
	surface.SetTexture(texture)
	surface.DrawRect(0,0, texture.w,texture.h)
end