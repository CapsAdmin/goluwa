local graphics = graphics or {}

graphics.debug = false

local disable_flags

function graphics.Set2DFlags(...)
	if disable_flags then return end

end

function graphics.DisableFlags(b)
	disable_flags = b
end

function graphics.GetScreenRect()
	return Rect(0,0,render.GetScreenSize())
end

function graphics.SetRect(rect)	
	if rect then
		
		--surface.SetTranslation(0,0)
		
		--render.SetViewport(draw_rect.x, draw_rect.y, draw_rect.w, draw_rect.h)
		local x,y,w,h = rect:Unpack()
		surface.StartClip(x,y,w,h)
	else
		surface.EndClip()
	end
end

local white

local corner

function graphics.GetFont(name)
	return fonts[name] or fonts.default
end

function graphics.GetTextSize(font, text)	
	font = font or "default"
	text = text or "W"
	
	text = tostring(text)

	local fnt = fonts[font]

	if not fnt then
		return Vec2(1,1)
	end

	fnt.scale = nil
	
	if not fnt.scale or not fnt.scale[text] then
		fnt.scale = fnt.scale or {}
		surface.SetFont(fnt)
		fnt.scale[text] = Vec2(surface.GetTextSize(text))
	end

	return fonts[font].scale[text] 
end

e.TEXT_ALIGN_CENTER = Vec2(0.5,0.5)

local function DrawText(text, pos, font, size, color, align_normal)
	fonts = fonts or create()

	font = font or "default"
	size = size or Vec2() + 12
	color = color or Color(1,1,1,1)
	align_normal = align_normal or Vec2(0,0)
	
	if color.a == 0 then return end
	
	surface.SetFont(fonts[font])
	surface.Color(color:Unpack())

	if type(size) == "number" then
		size = Vec2() + size
	end
	
	if align_normal ~= Vec2(0, 0) then
		local scale = graphics.GetTextSize(text, font)
	
		pos = pos + (align_normal * scale)
	end
	
	surface.DrawText(text)
		
	if graphics.debug then
		graphics.DrawRect(Rect(pos.x, pos.y, graphics.GetTextSize(font, text) * size), Color(0, 0, 1, 0.25))
	end
	
	return pos
end

function graphics.DrawText(text, pos, font, scale, color, align_normal, shadow_dir, shadow_color, shadow_size, shadow_blur)
	graphics.Set2DFlags()

	if shadow_dir then
		shadow_color = shadow_color or Color(0,0,0, color.a)
		shadow_size = shadow_size or scale
		if shadow_blur and shadow_blur > 0 then
			
			for i = 1, shadow_blur do
				 
				local alpha_0_1 = (i/shadow_blur)
				local alpha_1_0 = -(i/shadow_blur)+1
				
				local col = shadow_color:Copy()
				col.a = math.clamp(col.a * alpha_1_0 ^ 2.5, 0.004, 1) -- when the alpha is below 0.004 the text becomes white. fix this!
						
				local scale = ((Vec2() + scale) * shadow_size) / graphics.GetTextSize(font, text).h * (alpha_0_1 + 1) ^ 2
						
				DrawText(
					text, 
					pos, 
					font, 
					scale,
					col, 
					align_normal + ((shadow_dir / scale) * alpha_0_1)
				)
			end
		else
			DrawText(text, shadow_dir + pos, font, shadow_size, shadow_color, align_normal)
		end
	end
	return DrawText(text, pos, font, scale, color, align_normal)
end

function graphics.DrawFilledRect(rect, color, ...)
	color = color or Color(1,1,1,1)
	if color.a == 0 then return end

	graphics.Set2DFlags()
	
	surface.Color(color:Unpack())
	surface.SetWhiteTexture()
	surface.DrawRect(rect.x, rect.y, rect.w, rect.h, ...)
end

function graphics.DrawRoundedOutlinedRect(rect, size, color, tl, tr, bl, br)
	corner = corner or Image("textures/gui/corner.png")
	
	if color.a == 0 then return end

	tl = tl == nil and true or tl
	tr = tr == nil and true or tr
	bl = bl == nil and true or bl
	br = br == nil and true or br

	graphics.DrawFilledRect(Rect(rect.x + size, rect.y, rect.w - size * 2, size), color)
	graphics.DrawFilledRect(Rect(rect.x + size, rect.y + rect.h, rect.w - size * 2, -size), color)

	graphics.DrawFilledRect(Rect(rect.x, rect.y + size, size, rect.h - size * 2), color)
	graphics.DrawFilledRect(Rect(rect.x + rect.w, rect.y + size, -size, rect.h - size * 2), color)

	rect = rect:Copy():Shrink(size * 0.5)

	surface.SetColor(color)
	surface.SetTexture(tl and corner or white)

	surface.DrawRect(
		rect.x - size * 0.5,
		rect.y - size * 0.5,

		size,
		size
	)

	surface.SetTexture(tr and corner or white)
	surface.DrawRect(
		rect.x + rect.w + size * 0.5,
		rect.y + rect.h + size * 0.5,

		-size,
		-size
	)

	surface.SetTexture(bl and corner or white)
	surface.DrawRect(
		rect.x + rect.w + size * 0.5,
		rect.y - size * 0.5,

		-size,
		size
	)

	surface.SetTexture(br and corner or white)
	surface.DrawRect(
		rect.x - size * 0.5,
		rect.y + rect.h + size * 0.5,

		size,
		-size
	)
end

function graphics.DrawOutlinedRect(rect, size, color)
	if color.a == 0 then return end

	graphics.DrawFilledRect(Rect(rect.x, rect.y, rect.w, size), color)
	graphics.DrawFilledRect(Rect(rect.x, rect.y + rect.h, rect.w, -size), color)

	graphics.DrawFilledRect(Rect(rect.x, rect.y + size, size, rect.h - size * 2), color)
	graphics.DrawFilledRect(Rect(rect.x + rect.w, rect.y + size, -size, rect.h - size * 2), color)
end

function graphics.DrawRoundedRect(rect, size, color, tl, tr, bl, br)
	if color.a == 0 then return end
	graphics.DrawFilledRect(rect:Copy():Shrink(size), color)
	graphics.DrawRoundedOutlinedRect(rect, size, color, tl, tr, bl, br)
end

function graphics.DrawRect(rect, color, roundness, border_size, border_color, shadow_distance, shadow_color, tl, tr, bl, br)	
	color = color or Color(1,1,1,1)
	roundness = roundness or 0
	border_size = border_size or 0
	border_color = border_color or Color(1,1,1,1)
	shadow_distance = shadow_distance or Vec2(0, 0)
	shadow_color = shadow_color or Color(0,0,0,0.2)

	if roundness > 0 then
		if shadow_distance ~= Vec2(0,0) then
			graphics.DrawRoundedRect(rect + Rect(shadow_distance, Vec2()), roundness, shadow_color, tl, tr, bl, br)
		end
		if border_size > 0 then
			graphics.DrawRoundedRect(rect, roundness, border_color, tl, tr, bl, br)
			graphics.DrawRoundedRect(rect:Shrink(border_size), roundness, color, tl, tr, bl, br)
		else
			graphics.DrawRoundedRect(rect, roundness, color, tl, tr, bl, br)
		end
	else
		if shadow_distance ~= Vec2(0,0) then
			graphics.DrawFilledRect(rect + Rect(shadow_distance, Vec2()), shadow_color)
		end
		if border_size > 0 then
			graphics.DrawOutlinedRect(rect, border_size, border_color)
			graphics.DrawFilledRect(rect:Shrink(border_size), color)
		else
			graphics.DrawFilledRect(rect, color)
		end
	end
end

function graphics.CreateTexture(path, rect)
	local tex = Image("textures/"..path)

	tex.uv = {(rect or Rect(0,0,1,1)):GetUV8(Vec2(tex:GetSize()))}

	return tex
end

function graphics.DrawTexture(tex, rect, color, uv, nofilter)
	graphics.Set2DFlags()

	if type(tex) ~= "number" then
		uv = tex.uv
		tex = tex:GetId()
	end

	if not uv then
		uv = {Rect(0,0,1,1):GetUV8(Vec2(1,1))}
	end
	
	surface.SetColor(color or Color(1,1,1,1))
	surface.SetTexture(tex)
	
	surface.DrawRect(
		rect.x,
		rect.y,
		rect.w,
		rect.h
	)
end

function graphics.DrawLine(a,b, color)
	surface.SetColor(color or Color(1,1,1,1))	
	surface.DrawLine(a.x, a.y, b.x, b.y)
end

function graphics.GetScreenSize()
	return Vec2(render.GetScreenSize())
end

return graphics