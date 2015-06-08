local gmod = ... or gmod
local gui = gmod.env.gui

function gui.MousePos()
	return window.GetMousePosition():Unpack()
end

function gui.MouseX()
	return window.GetMousePosition().x
end

function gui.MouseY()
	return window.GetMousePosition().y
end

function gui.ScreenToVector(x, y)
	return gmod.env.Vector(math3d.ScreenToWorldDirection(Vec2(x, y)):Unpack())
end