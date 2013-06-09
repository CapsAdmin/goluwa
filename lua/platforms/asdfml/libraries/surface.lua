local surface = _G.surface or {}

local window
local view  

local matrix = RectangleShape():GetTransform() -- what's default?
local state = RenderStates(e.BLEND_ALPHA, matrix)
state.transform = matrix

do -- render state
	function surface.SetShader(shader)
		state.shader =  shader
	end
	
	function surface.SetBlendMode(mode)
		state.blendMode = mode
	end
	
	function surface.SetShaderTexture(tex)
		state.texture = tex
	end
	
	function surface.SetTransform(transform)
		state.transform = transform
		matrix = transform
	end
end

do -- transform	
	function surface.Rotate(a, cx, cy)
		if cx and cy then
			matrix:RotateWithCenter(a, cx, cy)
		else
			matrix:Rotate(a)
		end
	end
	
	function surface.Translate(x, y)
		matrix:Translate(x, y)
	end
	
	function surface.Scale(w, h, cx, cy)
		if cx and cy then
			matrix:ScaleWithCenter(w, h, cx, cy)
		else
			matrix:Scale(w, h)
		end
	end
end

function surface.SetWindow(wnd)
	window = wnd
	view = window:GetView()
end

function surface.GetWindowSize()
	if window then
		local size = window:GetSize()
		return size.x, size.y
	end
end

function surface.GetMousePos()
	local position = mouse.GetPosition(ffi.cast("sfWindow *", window))

	return position.x, position.y;
end;

do -- view
	local temp_rect = FloatRect()
	local temp_vec2 = Vector2f()
	
	function surface.SetViewport(x, y, w, h)
		temp_rect.left = x
		temp_rect.top = y
		temp_rect.width = w
		temp_rect.height = h
		
		if view then
			view:SetViewport(temp_rect)
			window:SetView(view)
		end
	end
	
	function surface.SetViewCenter(x, y)
		temp_vec2.x = x
		temp_vec2.y = y
	
		if view then
			view:SetCenter(temp_vec2)
			window:SetView(view)
		end
	end
	
	function surface.SetViewSize(x, y)
		temp_vec2.x = x
		temp_vec2.y = y
	
		if view then
			view:SetSize(temp_vec2)
			window:SetView(view)
		end
	end
	
	function surface.SetViewRotation(ang)
		if view then
			view:SetRotation(ang)
			window:SetView(view)
		end
	end
	
	function surface.ZoomView(factor)
		if view then
			view:Zoom(factor)
			window:SetView(view)
		end
	end
	
	
end
 
do
	local temp_vec2 = Vector2f()
	local temp_color = sfml.Color()

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
		
		text:SetColor(temp_color)
	end
	
	function surface.SetTextSize(s)
		text:SetCharacterSize(s)
	end
	
	function surface.SetFont(font)
		text:SetFont(font)
	end
	
	function surface.SetTextAngle(ang)
		text:SetRotation(ang)
	end
	
	function surface.SetTextStyle(...)
		text:SetStyle(bit.bor(...))
	end

	function surface.DrawText(str, x, y)
		if str then
			surface.SetText( tostring(str) )
		end
		
		if x and y then
			surface.SetTextPosition(x, y)
		end	
		
		if window then
			window:DrawText(text, state)
		end
	end
end

do
	local temp_vec2 = Vector2f()
	local temp_color = sfml.Color()
	
	local rect_shape = RectangleShape()

	function surface.SetColor(r,g,b,a)
		temp_color.r = r
		temp_color.g = g
		temp_color.b = b
		temp_color.a = a
		rect_shape:SetFillColor(temp_color)
	end
	
	function surface.SetTexture(tex)
		rect_shape:SetTexture(tex, false)
	end
 
 	function surface.SetOrigin(x, y)
		temp_vec2.x = x
		temp_vec2.y = y
		rect_shape:SetOrigin(temp_vec2)
	end
 
	function surface.SetAngle(angle)
		rect_shape:SetRotation(angle)
	end

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
			window:DrawRectangleShape(rect_shape, state)
		end
	end

	function surface.SetOutlineThickness(amount)
		rect_shape:SetOutlineThickness(amount);
	end;

	function surface.SetOutlineColor(r, g, b, a)
		temp_color.r = r;
		temp_color.g = g;
		temp_color.b = b;
		temp_color.a = a;

		rect_shape:SetOutlineColor(temp_color);
	end;
end  

return surface