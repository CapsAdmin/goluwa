
# Fonts

Supports loading fonts from various websites. It also has an effect api to create outlines, blur, shadows, etc for each glyph.

![ScreenShot](https://raw.githubusercontent.com/CapsAdmin/goluwa-assets/master/extras/screenshots/fonts.png)

```lua
local font = fonts.CreateFont({
	path = "helvetica",
	size = 100,
	padding = 50,
	shadow = {
		order = 1,
		dir = 30,
		dir_passes = 40,
		dir_falloff = 3,
		color = Color(0,0,0,1),
	},
})
 ```
 
```lua
local font = fonts.CreateFont({
	path = "barrio",
	size = 40,
	padding = 50,
	spacing = 10,
	fx = {
		{
			type = "shadow",
			dir = Vec2(0,0),
			color = Color(1,0.75,1,1),
			blur_radius = 0.1,
			blur_passes = 10,
			alpha_pow = 3,
			dir_passes = 40,
			dir_falloff = 3,
		},
		{
			type = "shadow",
			dir = Vec2(0,0),
			color = Color(0.75,0.75,1,1),
			blur_radius = 0.1,
			blur_passes = 10,
			alpha_pow = 3,
			dir_passes = 40,
			dir_falloff = 3,
		},
		{
			type = "shadow",
			dir = Vec2(0,0),
			color = Color(0.75,1,1,1),
			blur_radius = 0.1,
			blur_passes = 10,
			alpha_pow = 3,
			dir_passes = 40,
			dir_falloff = 3,
		},
	},
})
 ```
 
 
 
 
