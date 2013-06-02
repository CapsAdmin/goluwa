-- Create the main window
local window = RenderWindow(VideoMode(800, 600, 32), "SFML window", bit.bor(e.RESIZE, e.CLOSE), ContextSettings())

-- Load a sprite to display
local texture = Texture("file", e.BASE_FOLDER .. "textures/cute_image.jpg",  Rect(0, 0, 100, 100))
local sprite = Sprite()
sprite:SetTexture(texture, 1)

-- Create a graphical text to display
local text = Text()
text:SetString("Hello SFML")
text:SetFont(Font("file", e.BASE_FOLDER .. "fonts/arial.ttf"))
text:SetCharacterSize(50)

-- Load a music to play
local music = Music("file", e.BASE_FOLDER .. "sound/nice_music.ogg")

-- Play the music
music:Play()

local params = Event()

-- Start the game loop
event.AddListener("OnUpdate", "test", function()
	if window:IsOpen() then
		-- Process events
		if window:PollEvent(params) then
			-- Close window : exit
			if params.type == e.EVT_CLOSED then
				window:Close()
			end
 		end

		-- Clear the screen
		window:Clear(e.BLACK)

		-- Draw the sprite
		window:DrawSprite(sprite, nil)

		-- Draw the text
		window:DrawText(text, nil)

		-- Update the window
		window:Display()
	end
end)