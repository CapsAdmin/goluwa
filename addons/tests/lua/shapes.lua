surface = {}

local window

function surface.SetWindow(wnd)
	window = wnd
end

do
	local temp_vec2 = Vec2()
	local temp_color = Color()

	local text = Text()

	function surface.SetText(str)
		text:SetString(str)
	end

	function surface.SetTextPosition(x, y)
		temp_vec2.x = x
		temp_vec2.y = y
		text:SetPosition(temp_vec2)
	end

	function surface.SetTextScale(w, h)
		temp_vec2.x = w
		temp_vec2.y = h
		text:SetScale(temp_vec2)
	end
	
	function surface.SetTextColor(r,g,b,a)
		temp_color.r = r
		temp_color.g = g
		temp_color.b = b
		temp_color.a = a
		
		text:SetColor()
	end
	
	function surface.SetTextSize(s)
		text:SetCharacterSize(s)
	end
	
	function surface.SetFont(font)
		text:SetFont(font)
	end
	
	function surface.SetTextAngle(ang)
		text:Rotate(ang)
	end
	
	function surface.SetTextStyle(...)
		text:SetStyle(bit.bor(...))
	end

	function surface.DrawText(str, x, y)
		if str then
			surface.SetText(str)
		end
		
		if x and y then
			surface.SetTextPosition(x, y)
		end	
		
		if window then
			window:DrawText(text, nil)
		end
	end
end

do
	local temp_vec2 = Vec2()
	local temp_color = Color()
	
	local rect_shape = RectangleShape()

	function surface.SetTexture(tex)
		rect_shape:SetTexture(tex, false)
	end

	function surface.SetColor(r,g,b,a)
		temp_color.r = r
		temp_color.g = g
		temp_color.b = b
		temp_color.a = a
		rect_shape:SetFillColor(temp_color)
	end

	function surface.Rotate(angles)
		rect_shape:Rotate(angles);
	end;

	function surface.SetPosition(x, y)
		temp_vec2.x = x
		temp_vec2.y = y
		rect_shape:SetPosition(temp_vec2)
	end

	function surface.SetSize(w,h)
		temp_vec2.x = w
		temp_vec2.y = h
		rect_shape:SetSize(temp_vec2)
	end

	function surface.DrawRect(x, y, w, h)
		if x and y then
			surface.SetPosition(x, y)
		end
		
		if w and h then
			surface.SetSize(w, h)
		end
		
		if window then
			window:DrawRectangleShape(rect_shape, nil)
		end
	end

end

local window = glw.OpenWindow()
print(window)
local test = Texture("file", R"textures/cute_image.jpg",  Rect(0, 0, 100, 100))

event.AddListener("OnDraw", "surface", function()
	surface.SetWindow(window)
 
	surface.SetTexture(test)
	surface.SetColor(20, 255, 0, 255) 
	surface.DrawRect(10, 10, 60, 50) 
	surface.Rotate(30);
end)
