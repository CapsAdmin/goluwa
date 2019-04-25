local render = ... or _G.render

local ffi = require("ffi")
local sdl = require("SDL2")

function render.PreWindowSetup(flags)
	table.insert(flags, "vulkan")
end

function render.PostWindowSetup()

end

function render.CreateVulkanSurface(wnd, instance)
	local surface = sdl.CreateVulkanSurface(wnd.wnd_ptr, instance)

	if surface == nil then
		return nil, ffi.string(sdl.GetError())
	end

	return surface
end

function render.GetRequiredInstanceExtensions(wnd, extra)
	return sdl.GetRequiredInstanceExtensions(wnd.wnd_ptr, extra)
end