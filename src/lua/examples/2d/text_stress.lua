local font = fonts.CreateFont({size = 2})

local size = 256
local str = table.new(size, size)

local function regen()
	for i = 1, size ^ 2 do
		str[i] = i%size == 0 and "\n" or string.char(math.random(32,126))
	end
end

event.AddListener("PreDrawGUI", "lol", function()
	regen()

	gfx.SetFont(font)
	gfx.SetTextPosition(0,0)
	render2d.SetColor(1,1,1,1)
	gfx.DrawText(table.concat(str))
end)