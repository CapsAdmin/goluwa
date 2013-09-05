local surface = _G.surface or {}

do -- orientation
	
	function surface.Translate(x, y)
		gl.Translatef(x, y, 0)
	end
	
	function surface.Rotate(a)
		gl.Rotatef(a, 1, 0, 0)
	end
	
	function surface.Scale(w, h)
		gl.Scalef(w, h, 0)
	end
	
end

do	
	local font

	function surface.SetFont(fnt)
		font = fnt
	end
	
	function surface.DrawText(str)
		if not font then return end
		font:Render(str)
	end
	
end 

return surface