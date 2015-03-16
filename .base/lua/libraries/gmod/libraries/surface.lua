local lib = _G.surface

local gmod = ... or gmod
local surface = gmod.env.surface

function surface.GetTextureID(path)
	if vfs.IsFile("materials/" .. path) then
		return Texture("materials/" .. path)
	end
	
	return Texture("materials/" .. path .. ".vtf")
end

function surface.SetDrawColor(r,g,b,a)
	if type(r) == "table" then
		r,g,b,a = r.r, r.g, r.b, r.a
	end
	a = a or 255
	lib.SetColor(r/255,g/255,b/255,a/255)
end

function surface.SetTextColor(r,g,b,a)
	if type(r) == "table" then
		r,g,b,a = r.r, r.g, r.b, r.a
	end
	a = a or 255
	lib.SetColor(r/255,g/255,b/255,a/255)
end

function surface.SetMaterial(mat)
	lib.SetTexture(mat.DiffuseTexture)
end

function surface.DrawTexturedRectRotated(x,y,w,h,r)
	lib.DrawRect(x,y,w,h,math.rad(r))
end

function surface.DrawTexturedRect(x,y,w,h)
	lib.DrawRect(x,y,w,h)
end

function surface.DrawRect(x,y,w,h)
	surface.SetWhiteTexture()
	lib.DrawRect(x,y,w,h)
end

function surface.DrawTexturedRectUV(x,y,w,h, u1,v1, u2,v2)
	lib.SetRectUV2(u1,v1, u2,v2)
	lib.DrawRect(x,y,w,h)
	lib.SetRectUV()
end

function surface.SetTextPos(x, y)
	lib.SetTextPosition(x, y)
end

function surface.CreateFont(name, tbl)
	logn("gmod create font: ", tbl.font)
	do return end
	local tbl = table.copy(tbl)
	tbl.path = tbl.font
	lib.CreateFont(name, tbl)
end

function surface.SetFont(name) 
	name = "default"
	lib.SetFont(name) 
end

function surface.GetTextSize(str)
	return lib.GetTextSize(str) 
end

function surface.DrawText(str)
	lib.DrawText(str)
end

function surface.PlaySound(path)
	audio.CreateSource("sound/" .. path):Play()
end