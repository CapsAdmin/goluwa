
--[[local mode = VideoMode()
mode.width = 800
mode.height = 600
mode.bitsPerPixel = 32]]

-- Create the main window
local window = RenderWindow(VideoMode(800, 600, 32), "SFML window", bit.bor(sfml.libraries.window.sfResize, sfml.libraries.window.sfClose), ContextSettings())

-- Load a sprite to display
local rect = Rect(0, 0, 100, 100)

local texture = Texture("file", "../textures/cute_image.jpg", rect)
local sprite = Sprite()
sprite:SetTexture(texture, 1)

-- Create a graphical text to display
local font = Font("file", "../fonts/arial.ttf")
local text = Text()
text:SetString("Hello SFML")
text:SetFont(font)
text:SetCharacterSize(50)

-- Load a music to play
local music = Music("file", "../sound/nice_music.ogg")

-- Play the music
--music:Play()

local event = ffi.new("sfEvent")

-- Start the game loop
hook.Add("OnUpdate", "test", function()

	if window:IsOpen() then
	-- Process events
		if window:PollEvent(event) then
			-- Close window : exit
			if event.type == sfml.libraries.window.sfEvtClosed then
				window:Close()
			end
 		end

		-- Clear the screen
		window:Clear(sfml.libraries.graphics.sfBlack)

		-- Draw the sprite
		window:DrawSprite(sprite, nil)

		-- Draw the text
		window:DrawText(text, nil)

		-- Update the window
		window:Display()
	end
end)