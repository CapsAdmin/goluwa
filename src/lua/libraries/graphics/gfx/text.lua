local gfx = (...) or _G.gfx

function gfx.GetDefaultFont()
	return fonts.default_font
end

function gfx.SetFont(font)
	fonts.current_font = font or gfx.GetDefaultFont()
end

function gfx.GetFont()
	return fonts.current_font or gfx.GetDefaultFont()
end

local X, Y = 0, 0

function gfx.DrawText(str, x, y, w)
	local ux,uy,uw,uh,usx,usy = surface.GetRectUV()
	local old_tex = surface.GetTexture()
	local r,g,b,a = surface.GetColor()

	x = x or X
	y = y or Y

	local font = gfx.GetFont()

	if not font then
		surface.SetTexture(render.GetErrorTexture())
		surface.DrawRect(x,y,32,32)
	elseif not font:IsReady() then
		surface.SetTexture(render.GetLoadingTexture())
		surface.DrawRect(x,y,32,32)
	else
		font:DrawString(str, x, y, w)
	end

	surface.SetRectUV(ux,uy,uw,uh,usx,usy)
	surface.SetTexture(old_tex)
	surface.SetColor(r,g,b,a)
end

function gfx.SetTextPosition(x, y)
	X = x or X
	Y = y or Y
end

function gfx.GetTextPosition()
	return X, Y
end

do
	local cache = utility.CreateWeakTable()

	function gfx.GetTextSize(str)
		str = str or "|"

		local font = gfx.GetFont()

		if not font then
			return 0,0
		end

		if not font:IsReady() then
			return font.Size, font.Size
		end

		if cache[font] and cache[font][str] then
			return cache[font][str][1], cache[font][str][2]
		end

		local x, y = font:GetTextSize(str)

		cache[font] = cache[font] or utility.CreateWeakTable()
		cache[font][str] = cache[font][str] or utility.CreateWeakTable()
		cache[font][str][1] = x
		cache[font][str][2] = y

		return x, y
	end

	function gfx.InvalidateFontSizeCache(font)
		if font then
			cache[font] = nil
		else
			cache = {}
		end
	end
end

function gfx.WrapString(str, max_width)
	if not max_width or max_width == 0 then
		return str:split("")
	end

	local lines = {}
	local i = 1

	local last_pos = 0
	local line_width = 0
	local found = false

	local space_pos

	for pos, char in pairs(str:utotable()) do
		local w = gfx.GetTextSize(char)

		if char:find("%s") then
			space_pos = pos
		end

		if line_width >= max_width then

			if space_pos then
				lines[i] = str:usub(last_pos+1, space_pos)
				last_pos = space_pos
			else
				lines[i] = str:usub(last_pos+1, pos)
				last_pos = pos
			end

			i = i + 1

			line_width = 0
			found = true
			space_pos = nil
		end

		line_width = line_width + w
	end

	if found then
		lines[i] = str:usub(last_pos+1, pos)
	else
		lines[i] = str
	end

	return lines
end
