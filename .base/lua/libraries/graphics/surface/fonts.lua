--[[
All surface.fonts must implement:
number :GetHeight()
number :GetWidth(text)
x, y :DrawString(str, x, y)
.options (a ref to the options table)

surface.AddFontLoader{.AttemptLoad(<binaryData>, options, callback(suc, errmsg/metatable))}
]]

local surface = (...) or _G.surface

surface.fonts = surface.fonts or {}
surface.font_dpi = 72

local loaders = {}
function surface.AddFontLoader(loader)
	table.insert(loaders, loader)
end

local initted = false
local queue = {}

function surface.CreateFont(name, options, callback)
	
	if not initted then
		table.insert(queue, {name, options, callback})
		surface.fonts[name] = "loading"
		return
	end
	
	options = options or {}
	options.path = options.path or name
	options.size = options.size or 14
	
	callback = callback or function() end
		
	surface.fonts[name] = "loading"
	
	for k,v in pairs(loaders) do		
		local ok, meta, err = pcall(v.AttemptLoad, name, options, callback)
		if ok then
			surface.fonts[name] = meta
			print(name, meta, err, ok)
			return
		end
		print(meta, err, options.path)
	end
	
	surface.fonts[name] = "default"
end

local font = "default"

function surface.SetFont(name)
	if not surface.fonts[name] then return end
	font = name
end

local X, Y = 0, 0

function surface.DrawText(str, x, y)
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
function surface.SetTextScale() end


function surface.InitializeFonts()
	surface.fonts["default"] = surface.CreateFont("default", {path = "fonts/unifont.ttf"})
	
	initted = true
	
	for k,v in pairs(queue) do
		surface.CreateFont(unpack(v))
	end
end

include("angelfont.lua", surface)
include("freetype.lua", surface)

if RELOAD then
	surface.InitializeFonts()
end