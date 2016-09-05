local circle = render.CreateTextureFromPath( "textures/ball.png" )
local luwa = render.CreateTextureFromPath( "textures/goluwa.png" )

local x, y = 0, 0
local dirX, dirY = 100, 100

local W, H = luwa:GetSize().x - 10, luwa:GetSize().y - 10
event.AddListener( "PreDrawGUI", "goluwa", function()

	x = x + dirX * system.GetFrameTime()
	y = y + dirY * system.GetFrameTime()
	if x + W / 2 >= render.GetWidth() or x <= W / 2 then
		dirX = -dirX
		W = W / 2
	end
	if y + H / 2 >= render.GetHeight()  or y <= H / 2 then
		dirY = -dirY
		H = H / 2
	end
	W = W + ((luwa:GetSize().x-10)/W) * system.GetFrameTime() * 300
	H = H + ((luwa:GetSize().y-10)/H) * system.GetFrameTime() * 300


	x = math.clamp( x, W / 2, render.GetWidth() - W / 2 )
	y = math.clamp( y, H / 2, render.GetHeight() - H / 2 )


	surface.SetTexture( luwa )
	surface.SetColor(1,1,1,1)
	surface.DrawRect( x - W / 2, y - H/2, W, H )
	surface.SetTexture( circle )
	local X, Y = math.sin( math.rad( system.GetElapsedTime() * 500) ) * (W/2-10) - (W/5/2),
		math.cos( math.rad( system.GetElapsedTime() * 500 ) ) * (H/2-10) - (H/5/2)
	surface.DrawRect( x + X, y + Y, W/5, H/5 )
end, {priority=-math.huge})