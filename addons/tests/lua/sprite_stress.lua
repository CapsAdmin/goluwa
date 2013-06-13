 
local WIDTH = 1920
local HEIGHT = 1080
local NUM_SPRITES = 40000
local MAX_SCALE = 2

local window = glw.OpenWindow(WIDTH, HEIGHT)

local sprites = {}

-- Load a sprite to display
local texture = Texture("file", R"textures/blowfish.png",  IntRect(0, 0, 100, 100))
texture:SetSmooth(true)

-- set up the random variables for each sprite
for i = 1, NUM_SPRITES do	
	local x = math.random(0, WIDTH)
	local y = math.random(0, HEIGHT)
	
	local sprite = Sprite()
	sprite:SetTexture(texture, 1)
	
	local sprite = {sprite = sprite}
	
	sprite.rotSpeed = math.random(-200, 200)
	sprite.scaleSpeed = math.random(-2*MAX_SCALE, 2*MAX_SCALE)
	sprite.speed = math.random(50, 500)
	sprite.dirX = -1 + (2 * math.random())
	sprite.dirY = -1 + (2 * math.random())
	
	sprite.x = x
	sprite.y = y
	sprite.r = 1
	sprite.scale = 1
	sprite.w = texture:GetSize().x / 2
	sprite.h = texture:GetSize().y / 2
	
	sprites[i] = sprite
end

local tvec2 = Vector2f()
local tonumber=tonumber
local logn=logn
local math=math
local deg=math.deg
local rad=math.rad
local window=window
event.AddListener("OnDraw", "test", function(dt)
    for i, val in ipairs(sprites) do
        -- update the rotation
        val.r = rad(deg(val.r) + val.rotSpeed * dt)
        
        -- update the scale
        local scaleAmount = val.scaleSpeed * dt
		
        if val.scale + scaleAmount <= -MAX_SCALE or val.scale + scaleAmount >= MAX_SCALE then
            scaleAmount = -scaleAmount
            val.scaleSpeed = -val.scaleSpeed
        end
		
        val.scale = val.scale + scaleAmount
        
        -- update the x movement
        local moveAmountX = val.dirX * val.speed * dt
        local newLocX = val.x + moveAmountX
		
        if newLocX < 0 or newLocX > WIDTH then
            moveAmountX = -moveAmountX
            newLocX = val.x + moveAmountX
            val.dirX = -val.dirX
        end
        val.x = newLocX
        
        -- update the y movement
        local moveAmountY = val.dirY * val.speed * dt
        local newLocY = val.y + moveAmountY
		
        if newLocY < 0 or newLocY > HEIGHT then
            moveAmountY = -moveAmountY
            newLocY = val.y + moveAmountY
            val.dirY = -val.dirY
        end
        val.y = newLocY
        
        -- update the sprite in the sprite batch
		tvec2.x = 1+val.scale
		tvec2.y = 1+val.scale
		val.sprite:SetScale(tvec2)
		
		tvec2.x = val.x
		tvec2.y = val.y
		val.sprite:SetPosition(tvec2)		
		
		window:DrawSprite(val.sprite, nil)
    end
end)