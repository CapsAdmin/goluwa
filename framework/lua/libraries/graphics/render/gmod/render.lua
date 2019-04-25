local ScrW = gmod.ScrW
local ScrH = gmod.ScrH

local render = ... or {}

runfile("texture.lua", render)
runfile("vertex_buffer.lua", render)
runfile("index_buffer.lua", render)
runfile("framebuffer.lua", render)

function render._Initialize(wnd)

end

do
	local translate_mode = {
		zero = gmod.BLEND_ZERO,
		one = gmod.BLEND_ONE,
		dst_color = gmod.BLEND_DST_COLOR,
		one_minus_dst_color = gmod.BLEND_ONE_MINUS_DST_COLOR,
		src_alpha = gmod.BLEND_SRC_ALPHA,
		one_minus_src_alpha = gmod.BLEND_ONE_MINUS_SRC_ALPHA,
		dst_alpha = gmod.BLEND_DST_ALPHA,
		one_minus_dst_alpha = gmod.BLEND_ONE_MINUS_DST_ALPHA,
		src_alpha_saturate = gmod.BLEND_SRC_ALPHA_SATURATE,
		src_color = gmod.BLEND_SRC_COLOR,
		one_minus_src_color = gmod.BLEND_ONE_MINUS_SRC_COLOR,
	}

	local translate_func = {
		add = gmod.BLENDFUNC_ADD,
		subtract = gmod.BLENDFUNC_SUBTRACT,
		reverse_subtract = gmod.BLENDFUNC_REVERSE_SUBTRACT,
	}

	local render_OverrideBlend = gmod.render.OverrideBlend

	function render.SetBlendMode(src_color, dst_color, func_color, src_alpha, dst_alpha, func_alpha)
		if not render_OverrideBlend then return end

		if not src_color then
			render_OverrideBlend(false)
			return
		end

		render_OverrideBlend(
			true,
			translate_mode[src_color],
			translate_mode[dst_color],
			translate_func[func_color],

			translate_mode[src_alpha],
			translate_mode[dst_alpha],
			translate_func[func_alpha]
		)
	end
end

function render.SetColorMask(r,g,b,a)
	render.color_mask_r = r == 1
	render.color_mask_g = g == 1
	render.color_mask_b = b == 1
	render.color_mask_a = a == 1
end

do
	local render_SetStencilEnable = gmod.render.SetStencilEnable
	local enabled = false

	function render.SetStencil(b)
		render_SetStencilEnable(b)
		enabled = true
	end

	function render.GetStencil()
		return enabled
	end
end

do
	local translate = {
		never = gmod.STENCILCOMPARISONFUNCTION_NEVER, -- Never passes.
		less = gmod.STENCILCOMPARISONFUNCTION_LESS, -- Passes where the reference value is less than the stencil value.
		equal = gmod.STENCILCOMPARISONFUNCTION_EQUAL, -- Passes where the reference value is equal to the stencil value.
		lessequal = gmod.STENCILCOMPARISONFUNCTION_LESSEQUAL, -- Passes where the reference value is less than or equal to the stencil value.
		greter = gmod.STENCILCOMPARISONFUNCTION_GREATER, -- Passes where the reference value is greater than the stencil value.
		notequal = gmod.STENCILCOMPARISONFUNCTION_NOTEQUAL, -- Passes where the reference value is not equal to the stencil value.
		greaterequal = gmod.STENCILCOMPARISONFUNCTION_GREATEREQUAL, -- Passes where the reference value is greater than or equal to the stencil value.
		always = gmod.STENCILCOMPARISONFUNCTION_ALWAYS, -- Always passes.
	}

	local render_SetStencilCompareFunction = gmod.render.SetStencilCompareFunction
	local render_SetStencilReferenceValue = gmod.render.SetStencilReferenceValue

	function render.StencilFunction(mode, ref)
		render_SetStencilCompareFunction(translate[mode])
		render_SetStencilReferenceValue(ref)
	end
end

do
	local translate = {
		keep = gmod.STENCILOPERATION_KEEP, -- Preserves the existing stencil buffer value.
		zero = gmod.STENCILOPERATION_ZERO, -- Sets the value in the stencil buffer to 0.
		replace = gmod.STENCILOPERATION_REPLACE, -- Sets the value in the stencil buffer to the reference value, set using render.SetStencilReferenceValue.
		incrsat = gmod.STENCILOPERATION_INCRSAT, -- Increments the value in the stencil buffer by 1, clamping the result.
		decrsat = gmod.STENCILOPERATION_DECRSAT, -- Decrements the value in the stencil buffer by 1, clamping the result.
		invert = gmod.STENCILOPERATION_INVERT, -- Inverts the value in the stencil buffer.
		incr = gmod.STENCILOPERATION_INCR, -- Increments the value in the stencil buffer by 1, wrapping around on overflow.
		decr = gmod.STENCILOPERATION_DECR, -- Decrements the value in the stencil buffer by 1, wrapping around on overflow.
	}

	translate.increase = translate.incr
	translate.increment = translate.incr
	translate.increase_wrap = translate.incr -- missing
	translate.incrementwrap = translate.incr -- missing
	translate.incrsat = translate.incr
	translate.decrease = translate.decr
	translate.decrement = translate.decr
	translate.decrease_wrap = translate.decr -- missing
	translate.decrementwrap = translate.decr -- missing
	translate.decrsat = translate.decr

	local render_SetStencilFailOperation = gmod.render.SetStencilFailOperation
	local render_SetStencilZFailOperation = gmod.render.SetStencilZFailOperation
	local render_SetStencilPassOperation = gmod.render.SetStencilPassOperation

	function render.StencilOperation(stencil_fail, stencil_pass_depth_fail, depth_pass)
		render_SetStencilFailOperation(translate[stencil_fail])
		render_SetStencilPassOperation(translate[depth_pass])
		render_SetStencilZFailOperation(translate[stencil_pass_depth_fail])
	end
end

do
	local render_SetStencilWriteMask = gmod.render_SetStencilWriteMask

	function render.StencilMask(n)
		render_SetStencilWriteMask(n)
		render_SetStencilTestMask(n)
	end
end

do
	local render_SetViewPort = gmod.render.SetViewPort

	function render._SetViewport(x,y,w,h)
		render_SetViewPort(x,y,w,h)
	end
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
	return Vec2(ScrW(), ScrH())
end

