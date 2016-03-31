local lib = _G.surface

local gmod = ... or gmod
local surface = gmod.env.surface

function surface.GetTextureID(path)
	if vfs.IsFile("materials/" .. path) then
		return render.CreateTextureFromPath("materials/" .. path)
	end

	return render.CreateTextureFromPath("materials/" .. path .. ".vtf")
end

function surface.SetDrawColor(r,g,b,a)
	if type(r) == "table" then
		r,g,b,a = r.r, r.g, r.b, r.a
	end
	a = a or 255
	lib.SetColor(r/255,g/255,b/255,a/255)
end

function surface.SetAlphaMultiplier(a)
	lib.SetAlphaMultiplier(a)
end

local txt_r, txt_g, txt_b, txt_a = 0,0,0,0

function surface.SetTextColor(r,g,b,a)
	if type(r) == "table" then
		r,g,b,a = r.r, r.g, r.b, r.a
	end
	txt_r = r/255
	txt_g = g/255
	txt_b = b/255
	txt_a = (a or 0) / 255
end

function surface.SetMaterial(mat)
	lib.SetTexture(mat.__obj.AlbedoTexture)
end

function surface.SetTexture(tex)
	lib.SetTexture(tex)
end

function surface.DrawTexturedRectRotated(x,y,w,h,r)
	lib.DrawRect(x,y,w,h,math.rad(r))
end

function surface.DrawTexturedRect(x,y,w,h)
	lib.DrawRect(x,y,w,h)
end

function surface.DrawRect(x,y,w,h)
	local old = lib.bound_texture
	lib.SetWhiteTexture()
	lib.DrawRect(x,y,w,h)
	lib.bound_texture = old
end

surface.DrawOutlinedRect = surface.DrawRect

function surface.DrawTexturedRectUV(x,y,w,h, u1,v1, u2,v2)
	lib.SetRectUV(u1,v1, u2-u1,v2-v1)
	lib.DrawRect(x,y,w,h)
	lib.SetRectUV()
end

function surface.SetTextPos(x, y)
	lib.SetTextPosition(x, y)
end

function surface.CreateFont(name, tbl)
	logn("gmod create font: ", tbl.font)
	local tbl = table.copy(tbl)
	tbl.path = tbl.font

	if tbl.path:lower() == "roboto bk" then
		tbl.path = "resource/fonts/Roboto-Black.ttf"
	elseif tbl.path:lower() == "helvetica" then
		tbl.path = "resource/fonts/coolvetica.ttf"
	elseif tbl.path:lower() == "tahoma" then
		tbl.path = "fonts/tahoma.ttf"
	end

	if tbl.size then tbl.size = math.ceil(tbl.size * 0.75) end

	logf("surface.CreateFont(%q, %q)\n", name, tbl.path)

	lib.CreateFont(name, tbl)
end

function surface.SetFont(name)
	lib.SetFont(name)
end

function surface.GetTextSize(str)
	str = gmod.translation2[str] or str
	return lib.GetTextSize(str)
end

function surface.DrawText(str)
	str = gmod.translation2[str] or str
	local r,g,b,a = lib.SetColor(txt_r, txt_g, txt_b, txt_a)
	lib.DrawText(str)
	lib.SetColor(r,g,b,a)
end

function surface.PlaySound(path)
	audio.CreateSource("sound/" .. path):Play()
end