local render_SetViewPort = gmod.render.SetViewPort

local ScrW = gmod.ScrW
local ScrH = gmod.ScrH

local render = ... or {}

runfile("texture.lua", render)
runfile("vertex_buffer.lua", render)
runfile("index_buffer.lua", render)
runfile("framebuffer.lua", render)

function render._Initialize(wnd)

end

function render.SetBlendMode(src_color, dst_color, func_color, src_alpha, dst_alpha, func_alpha)

end

function render.SetStencil() end
function render.GetStencil() end
function render.StencilFunction() end
function render.StencilOperation() end
function render.StencilMask() end

function render._SetViewport(x,y,w,h)
	render_SetViewPort(x,y,w,h)
end

do
	local window = NULL

	function render._SetWindow(wnd)
		window = wnd
	end

	function render._GetWindow()
		return window
	end
end


function render.IsExtensionSupported()
	return false
end


function render.GetWidth()
	return ScrW()
end

function render.GetHeight()
	return ScrH()
end

function render.GetScreenSize()
	return env.Vec2(ScrW(), ScrH())
end

