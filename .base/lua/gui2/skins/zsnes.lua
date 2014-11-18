local gui2 = ... or _G.gui2

local scale = 2
local ninepatch_size = 32
local ninepatch_corner_size = 4
local ninepatch_pixel_border = scale

local S = scale

local text_size = 5*S 

local font = surface.CreateFont("default_gui_zsnes", {path = "fonts/unifont.ttf", size = 10, filtering = "nearest"})

surface.CreateFont("zsnes_gui_font", {
	path = "fonts/zfont.txt",
	fallback = "default_gui_zsnes",
	shadow = 1,
	size = 5*S,
	scale = S,
	filtering = "nearest",
}) 

local texture = Texture("textures/gui/skins/zsnes.png", {min_filter = "nearest", mag_filter = "nearest"})

local skin = {}

local function add(name, u,v, w,h, corner_size, color)
	skin[name] = {
		texture = texture, 
		texture_rect = Rect(u, v, w, h),
		corner_size = corner_size, 
		color = color,
		ninepatch = true,
	}
end

local function add_simple(name, u,v, w,h, color, no_size)
	skin[name] = {
		texture = texture, 
		texture_rect = Rect(u, v, w, h),
		color = color,
	}
	if not no_size then
		skin[name].size = Vec2(w, h)
	end
end

add("button_inactive", 480,0, 31,31, 4)
add("button_active", 480,96, 31,31, 4) 

add_simple("close_inactive", 32,452, 9,7) 
add_simple("close_active", 96,452, 9,7) 

add_simple("minimize_inactive", 132,452, 9,7) 
add_simple("minimize_active", 196,452, 9,7) 

add_simple("maximize_inactive", 225,484, 9,7) 
add_simple("maximize_active", 290,484, 9,7) 

add_simple("maximize2_inactive", 225,452, 9,7) 
add_simple("maximize2_active", 290,452, 9,7) 

add_simple("up_inactive", 464,224, 15,15) 
add_simple("up_active", 480,224, 15,15) 

add_simple("down_inactive", 464,256, 15,15) 
add_simple("down_active", 480,256, 15,15) 

add_simple("left_inactive", 464,208, 15,15) 
add_simple("left_active", 480,208, 15,15) 

add_simple("right_inactive", 464,240, 15,15) 
add_simple("right_active", 480,240, 15,15) 

add_simple("menu_right_arrow", 472,116, 4,7) 
add_simple("list_up_arrow", 385,114, 5,3) 
add_simple("list_down_arrow", 385,122, 5,3) 

add_simple("check", 449,34, 7,7)
add_simple("uncheck", 465,34, 7,7)
 
add_simple("+", 451,99, 5,5) 
add_simple("-", 467,99, 5,5)

add("scroll_vertical_track", 384,208, 15,127, 4) 
add("scroll_vertical_handle_inactive", 400,208, 15,127, 4) 
add("scroll_vertical_handle_active", 432,208, 15,127, 4)

add("scroll_horizontal_track", 384,128, 127,15, 4) 
add("scroll_horizontal_handle_inactive", 384,144, 127,15, 4) 
add("scroll_horizontal_handle_active", 384,176, 127,15, 4) 

add("button_rounded_active", 480,64, 31,31, 4) 
add("button_rounded_inactive", 480,64, 31,31, 4) 

add("tab_active", 1,384, 61,24, 8) 
add("tab_inactive", 128,384, 61,24, 16) 
add("tab_frame", 1,256+4, 127-2,127-4, 16)

add("menu_select", 130,258, 123,27, 16)
add("frame", 480,32, 31,31, 16)
add("frame2", 320,384+19, 63,63-19, 20)
add("frame_bar", 320,384, 63,19, 19/2)
add("property", 256,256, 63,127, 4)

add_simple("gradient", 0,128, 127,21, nil, true)
add("gradient1", 480,96, 31,31, 16)
add("gradient2", 480,96, 31,31, 16)
add("gradient3", 480,96, 31,31, 16)
add("text_edit", 0,172, 127,21, 16)

skin.tab_active_text_color = Color(0.25,0.25,0.25)
skin.tab_inactive_text_color = Color(0.5,0.5,0.5)

local buffer, length = texture:Download()

skin.text_color = texture:GetPixelColor(187, 504, buffer)
skin.text_color.a = 1
skin.text_color_inactive = skin.text_color * 0.80
skin.text_edit_color = texture:GetPixelColor(110, 497, buffer)
skin.text_edit_color.a = 1
skin.property_background = texture:GetPixelColor(28, 500, buffer)


skin.default_font = "zsnes_gui_font"
skin.scale = scale
skin.pixel_scale = S

skin.background = Color(0.5, 0.5, 0.5)

skin.icons = include("gui2/icons.lua")

return skin