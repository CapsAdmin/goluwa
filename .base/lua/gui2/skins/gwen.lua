local gui2 = ... or _G.gui2

local scale = 2
local ninepatch_size = 32
local ninepatch_corner_size = 4
local ninepatch_pixel_border = scale
local bg = ColorBytes(64, 44, 128, 200) 

local S = scale

local text_size = 5*S 

surface.CreateFont("snow_font", {
	path = "Roboto",
	fallback = "default",
	size = S*5.5,
}) 

surface.CreateFont("snow_font_noshadow", {
	path = "Roboto", 
	size = S*5.5,
})

local sub_skin = select(2, ...)

if type(sub_skin) ~= "string" then 
	sub_skin = "dark" 
end

local texture = Texture("textures/gui/skins/"..sub_skin..".png")

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

local function add_simple(name, u,v, w,h, color)
	skin[name] = {
		texture = texture, 
		texture_rect = Rect(u, v, w, h),
		size = Vec2(w, h),
		color = color,
	}
end

add("button_inactive", 480,0, 31,31, 4)
add("button_active", 480,96, 31,31, 4) 

add_simple("close_inactive", 32,452, 29,16) 
add_simple("close_active", 96,452, 29,16) 

add_simple("minimize_inactive", 132,452, 29,16) 
add_simple("minimize_active", 196,452, 29,16) 

add_simple("maximize_inactive", 225,484, 29,16) 
add_simple("maximize_active", 290,484, 29,16) 

add_simple("maximize2_inactive", 225,452, 29,16) 
add_simple("maximize2_active", 290,452, 29,16) 

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

add_simple("check", 448,32, 15,15) 
add_simple("uncheck", 464,32, 15,15)
 
add_simple("+", 451,99, 9,9) 
add_simple("-", 467,99, 9,9)

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
add("frame_bar", 320,384, 63,19, 11)
add("property", 256,256, 63,127, 4)

add("gradient", 480,96, 31,31, 16)
add("gradient1", 480,96, 31,31, 16)
add("gradient2", 480,96, 31,31, 16)
add("gradient3", 480,96, 31,31, 16)
add("text_edit", 0,150, 127,21, 16)

skin.tab_active_text_color = Color(0.25,0.25,0.25)
skin.tab_inactive_text_color = Color(0.5,0.5,0.5)

local buffer, length = texture:Download()

skin.text_color = texture:GetPixelColor(187, 504, buffer)
skin.text_color.a = 1
skin.text_color_inactive = skin.text_color * 0.80
skin.text_edit_color = texture:GetPixelColor(110, 497, buffer)
skin.text_edit_color.a = 1
skin.property_background = texture:GetPixelColor(28, 500, buffer)


skin.default_font = "snow_font"
skin.scale = scale

skin.background = Color(0.5, 0.5, 0.5)

skin.icons = {
	copy = "textures/silkicons/page_white_text.png",
	uniqueid = "textures/silkicons/vcard.png",
	paste = "textures/silkicons/paste_plain.png",
	clone = "textures/silkicons/page_copy.png",
	new = "textures/silkicons/add.png",
	autoload = "textures/silkicons/transmit_go.png",
	url = "textures/silkicons/server_go.png",
	outfit = "textures/silkicons/group.png",
	clear = "textures/silkicons/cross.png",
	language = "textures/silkicons/user_comment.png",
	font = "textures/silkicons/text_smallcaps.png",
	load = "textures/silkicons/folder.png",
	save = "textures/silkicons/disk.png",
	exit = "textures/silkicons/cancel.png",
	wear = "textures/silkicons/transmit.png",
	help = "textures/silkicons/information.png",
	edit = "textures/silkicons/table_edit.png",
	revert = "textures/silkicons/table_delete.png",
	about = "textures/silkicons/star.png",
	appearance = "textures/silkicons/paintcan.png",
	orientation = "textures/silkicons/shape_handles.png",

	text = "textures/silkicons/text_align_center.png",
	bone = "widgets/bone_small.png",
	clip = "textures/silkicons/cut.png",
	light = "textures/silkicons/lightbulb.png",
	sprite = "textures/silkicons/layers.png",
	bone = "textures/silkicons/connect.png",
	effect = "textures/silkicons/wand.png",
	model = "textures/silkicons/shape_square.png",
	animation = "textures/silkicons/eye.png",
	holdtype = "textures/silkicons/user_edit.png",
	entity = "textures/silkicons/brick.png",
	group = "textures/silkicons/world.png",
	trail = "textures/silkicons/arrow_undo.png",
	event = "textures/silkicons/clock.png",
	sunbeams = "textures/silkicons/weather_sun.png",
	jiggle = "textures/silkicons/chart_line.png",
	sound = "textures/silkicons/sound.png",
	command = "textures/silkicons/application_xp_terminal.png",
	material = "textures/silkicons/paintcan.png",
	proxy = "textures/silkicons/calculator.png",
	particles = "textures/silkicons/water.png",
	woohoo = "textures/silkicons/webcam_delete.png",
	halo = "textures/silkicons/shading.png",
	poseparameter = "textures/silkicons/disconnect.png",
	fog = "textures/silkicons/weather_clouds.png",
	physics = "textures/silkicons/shape_handles.png",
	beam = "textures/silkicons/vector.png",
	projectile = "textures/silkicons/bomb.png",
	shake = "textures/silkicons/transmit.png",
	ogg = "textures/silkicons/music.png",
	webaudio = "textures/silkicons/sound_add.png",
	script = "textures/silkicons/page_white_gear.png",
	info = "textures/silkicons/help.png",
	bodygroup = "textures/silkicons/user.png",
	camera = "textures/silkicons/camera.png",
	custom_animation = "textures/silkicons/film.png",
}

gui2.SetSkin(skin, select(2, ...) ~= nil)