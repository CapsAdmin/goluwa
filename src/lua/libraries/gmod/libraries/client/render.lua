local lib = render
local render = gine.env.render

local function get_error_texture()
	return gine.WrapObject(_G.render.GetErrorTexture(), "ITexture")
end

render.GetBloomTex0 = get_error_texture
render.GetBloomTex1 = get_error_texture
render.GetScreenEffectTexture = get_error_texture
render.GetMoBlurTex0 = get_error_texture
render.GetMoBlurTex1 = get_error_texture
render.GetSuperFPTex = get_error_texture
render.GetMorphTex0 = get_error_texture

function render.PushFilterMin() end
function render.PushFilterMag() end
function render.PopFilterMin() end
function render.PopFilterMag() end

function render.MaxTextureWidth() return 4096 end
function render.MaxTextureHeight() return 4096 end


function render.DrawScreenQuad()
	render.DrawScreenQuadEx()
end

function render.DrawScreenQuadEx(x,y,w,h)
	x = x or 0
	y = y or 0
	w = w or gine.env.ScrW()
	h = h or gine.env.ScrH()
	render2d.DrawRect(x,y,w,h)
end

function render.RedownloadAllLightmaps(b) end

function render.SuppressEngineLighting(b)

end

function render.SetLightingOrigin()

end

function render.ResetModelLighting()

end

function render.SetColorModulation(r,g,b)

end

function render.SetBlend(a)
	--render2d.SetAlphaMultiplier(a)
end

function render.SetModelLighting()

end

function render.SetScissorRect(x,y,w,h, b)

end

function render.UpdateScreenEffectTexture()

end

function render.SetViewPort(x,y,w,h)
	lib.SetViewport(x,y,w,h)
end

function gine.env.ScrW() return lib.GetWidth() end
function gine.env.ScrH() return lib.GetHeight() end

gine.env.surface.ScreenWidth = gine.env.ScrW
gine.env.surface.ScreenHeight = gine.env.ScrH

function gine.env.DisableClipping(b)

end

function render.SupportsPixelShaders_1_4() return true end
function render.SupportsVertexShaders_2_0() return true end
function render.SupportsPixelShaders_2_0() return true end
function render.SupportsHDR() return true end

do
	function render.SetStencilWriteMask(val)
		--lib.StencilMask(val)
	end

	do
		local translate = {}

		for k,v in pairs(gine.env) do
			if type(k) == "string" and k:startswith("STENCILCOMPARISONFUNCTION_") then
				translate[v] = k:match("STENCILCOMPARISONFUNCTION_(.+)"):lower()
			end
		end

		local default = translate[gine.env.STENCILCOMPARISONFUNCTION_NEVER]

		local REF = 0
		local MASK = 0
		local FUNC = default

		function render.SetStencilCompareFunction(func)
			FUNC = translate[func] or default

			lib.StencilFunction(FUNC, REF, 0xFF)
		end

		function render.SetStencilReferenceValue(val)
			REF = val
			lib.StencilFunction(FUNC, REF, 0xFF)
		end

		function render.SetStencilTestMask(val)
			TEST_MASK = val
			lib.StencilFunction(FUNC, REF, 0xFF)
		end
	end

	do
		local translate = {}

		for k,v in pairs(gine.env) do
			if type(k) == "string" and k:startswith("STENCILOPERATION_") then
				translate[v] = k:match("STENCILOPERATION_(.+)"):lower()
			end
		end

		local default = translate[gine.env.STENCILOPERATION_KEEP]

		local STENCIL_PASS = default
		local STENCIL_FAIL = default
		local DEPTH_FAIL = default

		function render.SetStencilPassOperation(func)
			STENCIL_PASS = translate[func] or default
			lib.StencilOperation(STENCIL_FAIL, DEPTH_FAIL, STENCIL_PASS)
		end
		function render.SetStencilFailOperation(func)
			STENCIL_FAIL = translate[func] or default
			lib.StencilOperation(STENCIL_FAIL, DEPTH_FAIL, STENCIL_PASS)
		end
		function render.SetStencilZFailOperation(func)
			DEPTH_FAIL = translate[func] or default
			lib.StencilOperation(STENCIL_FAIL, DEPTH_FAIL, STENCIL_PASS)
		end
	end

	function render.SetStencilEnable(b)
		lib.SetStencil(b)
	end

	function render.ClearStencil()
		lib.GetFrameBuffer():ClearStencil(0)
	end
end

function render.OverrideDepthEnable()

end

function render.Clear(r, g, b, a, depth, stencil)
	r = r / 255
	g = g / 255
	b = b / 255
	b = a / 255

	if depth then
		depth = 0
	end

	if stencil then
		stencil = 0
	end

	lib.GetFrameBuffer():ClearAll(r, g, b, a, depth, stencil)
end

function render.OverrideAlphaWriteEnable(enable, should_write)
	if enable then
		if should_write then
			lib.SetColorMask(1,1,1,1)
		else
			lib.SetColorMask(1,1,1,0)
		end
	else
		lib.SetColorMask(1,1,1,1)
	end
end

function render.PushFlashlightMode() end
function render.PopFlashlightMode() end