local love = ... or _G.love
local ENV = love._line_env
love.window = love.window or {}

function love.window.setTitle(title)
	window.SetTitle(title)
end

function love.window.setCaption(title)
	window.SetTitle(title)
end

function love.window.getWidth()
	return window.GetSize().x
end

function love.window.getHeight()
	return window.GetSize().y
end

function love.window.getDimensions()
	return window.GetSize():Unpack()
end

function love.window.isCreated()
	return true
end

function love.window.getPixelScale()
	return 2
end

function love.window.setFullscreen() end

function love.window.setMode(x, y, flags)
	window.SetSize(Vec2(x, y))
end

function love.window.getMode()
	local w, h = window.GetSize():Unpack()
	return w,
	h,
	{
		fullscreen = false,
		vsync = false,
		fsaa = false,
		resizable = true,
		borderless = true,
		centered = false,
		display = 0,
		minwidth = 800,
		maxwidth = 600,
		highdpi = false,
		srgb = SRGB,
		refreshrate = 60,
		x = window.GetPosition().x,
		y = window.GetPosition().y,
	}
end

function love.window.getDesktopDimensions()
	return window.GetSize():Unpack()
end

function love.window.setIcon() end

function love.window.getIcon() end

function love.window.getFullscreenModes()
	return {
		{width = 720, height = 480},
		{width = 800, height = 480},
		{width = 800, height = 600},
		{width = 852, height = 480},
		{width = 1024, height = 768},
		{width = 1152, height = 768},
		{width = 1152, height = 864},
		{width = 1280, height = 720},
		{width = 1280, height = 768},
		{width = 1280, height = 800},
		{width = 1280, height = 854},
		{width = 1280, height = 960},
		{width = 1280, height = 1024},
		{width = 1365, height = 768},
		{width = 1366, height = 768},
		{width = 1400, height = 1050},
		{width = 1440, height = 900},
		{width = 1440, height = 960},
		{width = 1600, height = 900},
		{width = 1600, height = 1200},
		{width = 1680, height = 1050},
		{width = 1920, height = 1080},
		{width = 1920, height = 1200},
		{width = 2048, height = 1536},
		{width = 2560, height = 1600},
		{width = 2560, height = 2048},
	}
end