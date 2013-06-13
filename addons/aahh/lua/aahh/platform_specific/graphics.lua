-- pretty much everything here has a default variable and resources are created if neeeded
local window = glw.GetWindow()

graphics = graphics or {}

function graphics.SetTranslation(vec)
	surface.SetTranslation(vec.x, vec.y)
end

function graphics.GetScreenSize()
	local size = glw.GetWindow():GetSize()
	return Vec2(size.x, size.y)
end

function graphics.GetScreenRect()
	return Rect(0,0, graphics.GetScreenSize())
end

function graphics.GetScreenScale()
	return Vec2(1,1)
end

do -- text

	function graphics.GetFont(name)
		
	end

	function graphics.GetTextSize(font, text)
		return Vec2(1,1)
	end

	function graphics.DrawText(text, pos, font, scale, color, align_normal, shadow_dir, shadow_color, shadow_size, shadow_blur)
		
	end
	
end

do -- rectanlge

	local shape = RectangleShape() 

	function graphics.DrawFilledRect(rect, color, ...)	
		color = color or Color(1,1,1,1)
		if color.a == 0 then return end
		
		shape:SetPosition(translation + rect:GetPos())
		shape:SetSize(rect:GetSize())
		
		shape:SetFillColor(Color(color.r * 255, color.g * 255, color.b * 255, color.a * 255))
		window:DrawRectangleShape(shape, nil)
	end

	function graphics.DrawRoundedOutlinedRect(rect, size, color, tl, tr, bl, br)
		corner = corner or Texture(Path("textures/gui/corner.dds")):GetId()
		
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

		draw_textured_rect(
			rect.x - size * 0.5,
			rect.y - size * 0.5,

			size,
			size
		)

		surface.SetTexture(tr and corner or white)
		draw_textured_rect(
			rect.x + rect.w + size * 0.5,
			rect.y + rect.h + size * 0.5,

			-size,
			-size
		)

		surface.SetTexture(bl and corner or white)
		draw_textured_rect(
			rect.x + rect.w + size * 0.5,
			rect.y - size * 0.5,

			-size,
			size
		)

		surface.SetTexture(br and corner or white)
		draw_textured_rect(
			rect.x - size * 0.5,
			rect.y + rect.h + size * 0.5,

			size,
			-size
		)
	end

	function graphics.DrawOutlinedRect(rect, size, color)

	end

	function graphics.DrawRoundedRect(rect, size, color, tl, tr, bl, br)
		
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

end

local def = Texture("file", R"textures/aahh/error.png", Rect(0,0,100,100))

function graphics.CreateTexture(path, rect)
	return def--Texture("file", R(path), rect or Rect(0,0,100,100))
end

function graphics.DrawTexture(tex, rect, color, uv, nofilter)

end

function graphics.DrawLine(a,b, color)
end