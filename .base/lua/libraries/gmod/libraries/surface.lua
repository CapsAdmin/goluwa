local lib = _G.surface

local gmod = ... or gmod
local surface = gmod.env.surface

function surface.GetTextureID(path)
	return Texture("materials/" .. path .. ".vtf")
end

function surface.SetDrawColor(r,g,b,a)
	a = a or 255
	lib.SetColor(r/255,g/255,b/255,a/255)
end

function surface.SetTextColor(r,g,b,a)
	a = a or 255
	lib.SetColor(r/255,g/255,b/255,a/255)
end

function surface.SetMaterial(mat)
	lib.SetTexture(mat.DiffuseTexture)
end

function surface.DrawTexturedRectRotated(x,y,w,h,r)
	lib.DrawRect(x,y,w,h,math.rad(r))
end

function surface.SetTextPos(x, y)
	lib.SetTextPosition(x, y)
end

function surface.CreateFont(name, tbl)
	local tbl = table.copy(tbl)
	tbl.path = tbl.font
	lib.CreateFont(name, tbl)
end

function surface.SetFont(name) 
	lib.SetFont(name) 
end

function surface.GetTextSize(str)
	return lib.GetTextSize(str) 
end

function surface.DrawText(str)
	lib.DrawText(str)
end