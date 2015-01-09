-- .\n[?].-\n
-- 79 x 29 display
--░ ▒ ▓ ⛝▩▦▧⛝

local shades = "░▒▓"
local shades = "▁▂▃▄▅▆▇█" 
local shades = "@8:."
local shades = "﻿＠８：．"
local shades = ",. "
local shades = "█▓▒░"
local shades = "▓▒░"


shades = utf8.totable(shades)

table.print(shades)

local w, h = 43, 43/2

w = math.ceil(w)
h = math.ceil(h)

event.AddListener("PostDrawScene", "fetch_pixels", function()

	local size = render.GetScreenSize()
	
	local values = {}
	
	local ratio = render.GetHeight( ) / render.GetWidth()
	
	for y = h, 0, -1 do	
		y = render.GetHeight() * (y / h)
				
		for x = 0, w do
			x = render.GetWidth() * (x / w)
			
			local h,s,v = ColorToHSV(Color(render.ReadPixels(x, y, 1, 1)))
			
			table.insert(values, v)
		end
	end
		
	local darkest = math.huge
	local brightest = 0
	
	for i, value in ipairs(values) do
		if value < darkest then
			darkest = value
		end
		
		if value > brightest then
			brightest = value
		end
	end
		
	local output = {".\n"}
	local asdf = -1
	
	for i, value in ipairs(values) do
		value = (value - darkest) / (brightest - darkest)
		value = value ^ 0.5
	
		if asdf == w then
			table.insert(output, "\n")
			asdf = 0
		else
			asdf = asdf + 1
		end
				
		local val = math.ceil(value * #shades)
		table.insert(output, shades[val] or shades[1])
	end

---	steam.SendChatMessage("76561198057705455", table.concat(output))
	system.SetClipboard(table.concat(output))

	return e.EVENT_DESTROY
end)
