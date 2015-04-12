local gmod = ... or gmod
local gui = gmod.env.gui

function gui.MousePos()
	return surface.GetMousePosition()
end

function gui.ScreenToVector(x, y)
	return gmod.env.Vector(math3d.ScreenToWorldDirection(Vec2(x, y)):Unpack())
end