local gui2 = ... or _G.gui2

local scale = 2
local ninepatch_size = 32
local ninepatch_corner_size = 4
local ninepatch_pixel_border = scale
local bg = ColorBytes(64, 44, 128, 200) 

local S = scale

local text_size = 8*S 

surface.CreateFont("snow_font", {
	path = "fonts/zfont.txt", 
	size = text_size,
	shadow = S,
	shadow_color = Color(0,0,0,0.5),
}) 

surface.CreateFont("snow_font_green", {
	path = "fonts/zfont.txt", 
	size = text_size,
	shadow = S,
	shadow_color = Color(0,1,0,0.4),
}) 

surface.CreateFont("snow_font_noshadow", {
	path = "fonts/zfont.txt", 
	size = text_size,
})

local skin = {
	button_inactive = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		y = -y + ninepatch_size
		
		if x >= ninepatch_size-ninepatch_pixel_border or y >= ninepatch_size-ninepatch_pixel_border then
			return 72, 68, 64, 255
		elseif x <= ninepatch_pixel_border or y <= ninepatch_pixel_border then
			return 104, 100, 96, 255
		end
		
		return 88, 92, 88, 255
	end),

	button_active = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		y = -y + ninepatch_size
		
		if x >= ninepatch_size-ninepatch_pixel_border or y >= ninepatch_size-ninepatch_pixel_border then
			return 104, 100, 96, 255
		end
		
		return 72, 68, 64, 255
	end),

	button_rounded_active = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y)
		y = -y + ninepatch_size
		
		if 
			(x >= ninepatch_size-ninepatch_pixel_border and y >= ninepatch_size-ninepatch_pixel_border) or 
			(x <= ninepatch_pixel_border and y <= ninepatch_pixel_border) or
			(x >= ninepatch_size-ninepatch_pixel_border and y <= ninepatch_pixel_border) or
			(x <= ninepatch_pixel_border and y >= ninepatch_size-ninepatch_pixel_border)
		then 					
			return 0,0,0,0 
		end
		
		if x >= ninepatch_size-ninepatch_pixel_border or y >= ninepatch_size-ninepatch_pixel_border then
			return 192, 144, 144, 255
		elseif x <= ninepatch_pixel_border or y <= ninepatch_pixel_border then
			return 160, 120, 120, 255
		end
		
		return 176, 132, 128, 255
	end),
	
	button_rounded_inactive = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y)
		y = -y + ninepatch_size
		
		if 
			(x >= ninepatch_size-ninepatch_pixel_border and y >= ninepatch_size-ninepatch_pixel_border) or 
			(x <= ninepatch_pixel_border and y <= ninepatch_pixel_border) or
			(x >= ninepatch_size-ninepatch_pixel_border and y <= ninepatch_pixel_border) or
			(x <= ninepatch_pixel_border and y >= ninepatch_size-ninepatch_pixel_border)
		then 					
			return 0,0,0,0 
		end
		
		if x >= ninepatch_size-ninepatch_pixel_border or y >= ninepatch_size-ninepatch_pixel_border then
			return 160, 120, 120, 255
		elseif x <= ninepatch_pixel_border or y <= ninepatch_pixel_border then
			return 192, 144, 144, 255
		end
		
		return 176, 132, 128, 255
	end),
	
	tab_active = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		y = -y + ninepatch_size
		
		if 
			(x <= ninepatch_pixel_border and y <= ninepatch_pixel_border) or
			(x >= ninepatch_size-ninepatch_pixel_border and y <= ninepatch_pixel_border)
		then 					
			return 0,0,0,0 
		end
		
		if x >= ninepatch_size-ninepatch_pixel_border then
			return 184, 48, 48, 255
		elseif x <= ninepatch_pixel_border or y <= ninepatch_pixel_border then
			return 184, 48, 48, 255
		end
		
		return 168, 32, 32, 255
	end),
	
	tab_inactive = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		y = -y + ninepatch_size
		
		if 
			(x <= ninepatch_pixel_border and y <= ninepatch_pixel_border) or
			(x >= ninepatch_size-ninepatch_pixel_border and y <= ninepatch_pixel_border)
		then 					
			return 0,0,0,0 
		end
		
		if x >= ninepatch_size-ninepatch_pixel_border then
			return 136, 0, 0, 255
		elseif x >= ninepatch_size-ninepatch_pixel_border or y >= ninepatch_size-ninepatch_pixel_border or y <= ninepatch_pixel_border then
			return 168, 32, 32, 255
		end
		
		return 152, 16, 16, 255
	end),

	menu_select = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		y = -y + ninepatch_size
		
		if x >= ninepatch_size-ninepatch_pixel_border or y >= ninepatch_size-ninepatch_pixel_border or x <= ninepatch_pixel_border or y <= ninepatch_pixel_border then
			return 80, 0, 136, 255
		end
		
		return 80, 0, 160, 255
	end),
	
	checkbox = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		y = -y + ninepatch_size
		
		local frac = (x+y)/(ninepatch_size*2)
		
		local b = math.lerp(frac, 224, 144)
		local gr = math.lerp(frac, 192, 160)
		
		return b, gr, gr, 255
	end),
	
	gradient = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		local v = (math.sin(y / ninepatch_size * math.pi)^0.8 * 255) / 2.25 + 130
		return v, v, v, 255
	end),

	gradient2 = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		local v = (math.sin(x / ninepatch_size * math.pi) * 255) / 5 + 180
		v = -v + 255
		return v, v, v, 255
	end),
	
	gradient3 = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		local v = (math.sin(y / ninepatch_size * math.pi) * 255) / 5 + 180
		v = -v + 255
		return v, v, v, 255
	end),
	
	frame = Texture(ninepatch_size, ninepatch_size, nil, {min_filter = "nearest", mag_filter = "nearest"}):Fill(function(x, y) 
		y = -y + ninepatch_size
		
		if x >= ninepatch_size-ninepatch_pixel_border or y >= ninepatch_size-ninepatch_pixel_border then
			return 152, 16, 16, 255
		elseif x <= ninepatch_pixel_border or y <= ninepatch_pixel_border then
			return 184, 48, 48, 255
		end

		return 168, 32, 32, 255
	end),
}

local temp = {}

for k,v in pairs(skin) do
	temp[k] = {v, ninepatch_size, ninepatch_corner_size}
end

temp.scale = scale
temp.background = bg

gui2.SetSkin(temp)