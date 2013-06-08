-- pretty much everything here has a default variable and resources are created if neeeded

graphics = graphics or {}

function graphics.SetTranslation(x,y)

end

function graphics.Set2DFlags(...)

end

function graphics.DisableFlags(b)
	
end

function graphics.GetScreenRect()
	return Rect()
end

function graphics.GetScreenSize()
	return Vec2(500, 500)
end

function graphics.GetScreenScale()
	return Vec2(1,1)
end

-- clipping
function graphics.SetRect(rect)	

end

function graphics.GetFont(name)
	
end

function graphics.GetTextSize(font, text)
	return Vec2(1,1)
end

function graphics.DrawText(text, pos, font, scale, color, align_normal, shadow_dir, shadow_color, shadow_size, shadow_blur)

end

function graphics.DrawFilledRect(rect, color, ...)

end

function graphics.DrawRoundedOutlinedRect(rect, size, color, tl, tr, bl, br)

end

function graphics.DrawOutlinedRect(rect, size, color)

end

function graphics.DrawRoundedRect(rect, size, color, tl, tr, bl, br)

end

function graphics.DrawRect(rect, color, roundness, border_size, border_color, shadow_distance, shadow_color, tl, tr, bl, br)
	
end

local def = Texture("file", R"textures/aahh/error.png", rect or Rect(0,0,100,100))

function graphics.CreateTexture(path, rect)
	return def--Texture("file", R(path), rect or Rect(0,0,100,100))
end

function graphics.DrawTexture(tex, rect, color, uv, nofilter)

end

function graphics.DrawLine(a,b, color)
end