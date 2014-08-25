--[[
All surface.fonts must implement:
number :GetHeight()
w, h:GetTextSize(text)
x, y :DrawString(str, x, y)
.options (a ref to the options table)

surface.AddFontLoader{.AttemptLoad(<binaryData>, options, callback(suc, errmsg/metatable))}
]]

include("../packed_rectangle.lua")

local surface = (...) or _G.surface

surface.debug = true

surface.fonts = surface.fonts or {}
surface.font_loaders = surface.font_loaders or {}
surface.font_dpi = 72

local initted = false
local queue = {}

function surface.InitializeFonts()
	surface.CreateFont("default", {path = "fonts/unifont.ttf"})
	
	initted = true
	
	for k,v in pairs(queue) do
		surface.CreateFont(unpack(v))
	end
end

function surface.CreateFont(name, options, callback)
	
	if not initted then
		table.insert(queue, {name, options, callback})
		surface.fonts[name] = "loading"
		return
	end
	
	options = options or {}
	options.path = options.path or name
	options.size = options.size or 14
			
	surface.fonts[name] = "loading"
	
	for _, font_loader in pairs(surface.font_loaders) do		
		local ok, res = pcall(font_loader.LoadFont, name, options, function(...)
			event.Call("FontChanged", name, options)
			if callback then
				callback(...)
			end
		end)
		if ok then
			surface.fonts[name] = res
			return
		end
		if surface.debug then
			logf("%s failed to load font %s: %s\n", font_loader.Name, name, res)
		end
	end
	
	surface.fonts[name] = "default"
end

function surface.RegisterFontLoader(tbl)		
	surface.font_loaders[tbl.Name] = metatable.CreateTemplate("surface_font_" .. tbl.Name, tbl)
end

local font = "default"

function surface.SetFont(name)
	if not surface.fonts[name] then 
		return 
	end
	font = name
end

local X, Y = 0, 0

function surface.DrawText(str, x, y)
	
	local ux,uy,uw,uh,usx,usy = surface.GetRectUV()
	local old_tex = surface.GetTexture()
	local r,g,b,a = surface.GetColor()

	do
		x = x or X
		y = y or Y
		
		local font = surface.fonts[font]
		
		if not font then return end
		
		if font == "loading" or font.state ~= 'loaded' then
			surface.SetColor(0.8, 0.8, 0.8, 1)
			surface.SetWhiteTexture()
			surface.DrawRect(x, y, 32, 32)
			local deg = 360 / 8
			for i = 0, 7 do
				local n=0
				if math.floor(os.clock()*5)%18>=9 then
					n = ((math.floor(os.clock()*5) % 9) - i)
				else
					n = 1-(((math.floor(os.clock()*5)+9) % 9) - i)
				end
				surface.SetColor(n, n, n, 1)
				local ang = math.rad(deg * i)
				local X, Y = math.sin(ang), math.cos(ang)
				surface.DrawLine(X*2+16, Y*2+16, X*16 + 16, Y*16 + 16, 2)
			end
			return
		end
		
		X, Y = font:DrawString(str, x, y)
	end
	
	surface.SetRectUV(ux,uy,uw,uh,usx,usy)
	surface.SetTexture(old_tex)
	surface.SetColor(r,g,b,a)
end

function surface.SetTextPos(x, y)
	X = x or X
	Y = y or Y
end

function surface.GetTextSize(str)
	local font = surface.fonts[font]
	
	if not font then return 0, 0 end
	
	if font == "loading" or font.state ~= 'loaded' then
		return 32, 32
	end
	
	return font:GetTextSize(str)
end

function surface.SetTextScale() 

end

include("font_loaders/*", surface)

if RELOAD then
	surface.InitializeFonts()
end