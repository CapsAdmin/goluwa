
local sfw = sfml.window
local sfg = sfml.graphics
local sfs = sfml.system
local sfw = sfml.window
local sfa = sfml.audio

local mode = ffi.new("sfVideoMode")
mode.width = 800
mode.height = 600
mode.bitsPerPixel = 32

-- Create the main window
local window = sfg.sfRenderWindow_create(mode, "SFML window", bit.bor(sfw.sfResize, sfw.sfClose), nil)

-- Load a sprite to display
local rect = ffi.new("sfIntRect", 0, 0, 100, 100)

local texture = sfg.sfTexture_createFromFile("../textures/cute_image.jpg", rect)
local sprite = sfg.sfSprite_create()
sfg.sfSprite_setTexture(sprite, texture, 1)

-- Create a graphical text to display
local font = sfg.sfFont_createFromFile("../fonts/arial.ttf")
local text = sfg.sfText_create()
sfg.sfText_setString(text, "Hello SFML")
sfg.sfText_setFont(text, font)
sfg.sfText_setCharacterSize(text, 50)

-- Load a music to play
local music = sfa.sfMusic_createFromFile("../sound/nice_music.ogg")

-- Play the music
sfa.sfMusic_play(music)

local event = ffi.new("sfEvent")

-- Start the game loop
hook.Add("OnUpdate", "test", function()
	if sfg.sfRenderWindow_isOpen(window) then
	-- Process events
		if sfg.sfRenderWindow_pollEvent(window, event) then
			-- Close window : exit
			if event.type == sfw.sfEvtClosed then
				sfg.sfRenderWindow_close(window)
			end
 		end

		-- Clear the screen
		sfg.sfRenderWindow_clear(window, sfg.sfBlack)

		-- Draw the sprite
		sfg.sfRenderWindow_drawSprite(window, sprite, nil)

		-- Draw the text
		sfg.sfRenderWindow_drawText(window, text, nil)

		-- Update the window
		sfg.sfRenderWindow_display(window)
	end
end)