local love = ... or _G.love
local ENV = love._line_env
love.mouse = love.mouse or {}

function love.mouse.setPosition(x, y) --window.SetMousePosition(Vec2(x, y))
end

function love.mouse.getPosition()
	return window.GetMousePosition():Unpack()
end

function love.mouse.getX()
	return window.GetMousePosition().x
end

function love.mouse.getY()
	return window.GetMousePosition().y
end

function love.mouse.setRelativeMode(b) end

love.mouse.setGrabbed = love.mouse.setRelativeMode
local Cursor = line.TypeTemplate("Cursor")
line.RegisterType(Cursor)

function love.mouse.newCursor()
	local obj = line.CreateObject("Cursor")
	return obj
end

function love.mouse.getCursor()
	local obj = line.CreateObject("Cursor")
	obj.getType = function()
		return window.GetCursor()
	end
	return obj
end

function love.mouse.setCursor() --window.GetCursor()
end

function love.mouse.getSystemCursor()
	local obj = line.CreateObject("Cursor")
	obj.getType = function()
		return window.GetCursor()
	end
	return obj
end

do
	ENV.mouse_visible = false

	function love.mouse.setVisible(bool)
		ENV.mouse_visible = bool
	end

	function love.mouse.getVisible(bool)
		return ENV.mouse_visible
	end
end

local mouse_keymap = {
	button_1 = "l",
	button_2 = "r",
	button_3 = "m",
	button_4 = "x1",
	button_5 = "x2",
	mwheel_up = "wu",
	mwheel_down = "wd",
}
local mouse_keymap_10 = {
	button_1 = 1,
	button_2 = 2,
	button_3 = 3,
	button_4 = 4,
	button_5 = 5,
}
local mouse_keymap_reverse = {}

for k, v in pairs(mouse_keymap) do
	mouse_keymap_reverse[v] = k
end

local mouse_keymap_10_reverse = {}

for k, v in pairs(mouse_keymap_10) do
	mouse_keymap_10_reverse[v] = k
end

function love.mouse.isDown(key)
	return input.IsMouseDown(mouse_keymap_10_reverse[key]) or
		input.IsMouseDown(mouse_keymap_reverse[key])
end

event.AddListener("LoveNewIndex", "line_mouse", function(love, key, val)
	if key == "mousepressed" or key == "mousereleased" then
		if val then
			event.AddListener("MouseInput", "line", function(key, press)
				local x, y = window.GetMousePosition():Unpack()

				if key == "mwheel_up" or key == "mwheel_down" then
					line.CallEvent("wheelmoved", 0, key == "mwheel_up" and 1 or -1)
				end

				if press then
					if mouse_keymap[key] then
						line.CallEvent("mousepressed", x, y, mouse_keymap[key])
					end

					if mouse_keymap_10[key] then
						line.CallEvent("mousepressed", x, y, mouse_keymap_10[key])
					end
				else
					if mouse_keymap[key] then
						line.CallEvent("mousereleased", x, y, mouse_keymap[key])
					end

					if mouse_keymap_10[key] then
						line.CallEvent("mousereleased", x, y, mouse_keymap_10[key])
					end
				end
			end)
		else
			event.RemoveListener("MouseInput", "line")
		end
	end
end)