local render = ... or _G.render

do
	local X,Y,W,H = 0,0,1,1

	function render.SetViewport(x, y, w, h)
		if X ~= x or Y ~= y or W ~= w or H ~= h then
			render._SetViewport(x,y,w,h)

			render2d.camera.Viewport.x = x
			render2d.camera.Viewport.y = y
			render2d.camera.Viewport.w = w
			render2d.camera.Viewport.h = h
			render2d.camera:Rebuild()

			X,Y,W,H = x,y,w,h
		end
	end

	function render.GetViewport()
		return X,Y,W,H
	end

	utility.MakePushPopFunction(render, "Viewport")
end

do
	local enabled = false

	function render.SetDepth(b)
		enabled = b
		render._SetDepth(b)
	end

	function render.GetDepth()
		return enabled
	end

	utility.MakePushPopFunction(render, "Depth")
end

do
	local X, Y, W, H = 0, 0, 0, 0

	function render.SetScissor(x,y,w,h)
		if not x then
			render._SetScissor()
		else
			local _, _, sw, sh = render.GetViewport()

			x = x
			y = y or 0
			w = w or sw
			h = h or sh

			if X ~= x or Y ~= y or W ~= w or H ~= h then
				render._SetScissor(x,y,w,h, sw,sh)
			end

			X = x
			Y = y
			W = w
			H = h
		end
	end

	function render.GetScissor()
		return X,Y,W,H
	end

	utility.MakePushPopFunction(render, "Scissor")
end

do
	local cull_
	local force_

	function render.SetCullMode(mode)
		cull_ = mode
		render._SetCullMode(force_ or mode)
	end

	function render.GetCullMode()
		return cull_
	end

	function render.SetForcedCullMode(mode)
		force_ = mode
		render._SetCullMode(mode)
	end

	utility.MakePushPopFunction(render, "CullMode")
end

do
	local presets = {
		none = {
			src_color = "one",
			dst_color = "zero",
			func_color = "add",
			src_alpha = "one",
			dst_alpha = "zero",
			func_alpha = "add",
		},
		alpha = {
			src_color = "src_alpha",
			dst_color = "one_minus_src_alpha",
			func_color = "add",
			src_alpha = "one",
			dst_alpha = "one_minus_src_alpha",
			func_alpha = "add",
		},
		multiplicative = {
			src_color = "dst_color",
			dst_color = "zero",
			func_color = "add",
			src_alpha = "dst_color",
			dst_alpha = "zero",
			func_alpha = "add",
		},
		premultiplied = {
			src_color = "one",
			dst_color = "one_src_minus_alpha",
			func_color = "add",
			src_alpha = "one",
			dst_alpha = "one_src_minus_alpha",
			func_alpha = "add",
		},
		additive = {
			src_color = "src_alpha",
			dst_color = "one",
			func_color = "add",
			src_alpha = "src_alpha",
			dst_alpha = "one",
			func_alpha = "add",
		},
	}

	local current

	function render.SetPresetBlendMode(name)
		local preset = presets[name] or presets.none

		render.SetBlendMode(
			preset.src_color,
			preset.dst_color,
			preset.func_color,

			preset.src_alpha,
			preset.dst_alpha,
			preset.func_alpha
		)

		current = name
	end

	function render.GetPresetBlendMode()
		return current
	end

	utility.MakePushPopFunction(render, "PresetBlendMode")

	do
		local A,B,C,D,E,F

		function render.SetBlendMode(src_color, dst_color, func_color, src_alpha, dst_alpha, func_alpha)
			if not dst_color then
				return render.SetPresetBlendMode(src_color)
			end

			src_color = src_color or "src_alpha"
			dst_color = dst_color or "one_minus_src_alpha"
			func_color = func_color or "add"

			src_alpha = src_alpha or src_color
			dst_alpha = dst_alpha or dst_color
			func_alpha = func_alpha or func_color

			render._SetBlendMode(src_color, dst_color, func_color, src_alpha, dst_alpha, func_alpha)

			A, B, C, D, E, F = src_color, dst_color, func_color, src_alpha, dst_alpha, func_alpha
		end

		function render.GetBlendMode()
			return A, B, C, D, E, F
		end

		utility.MakePushPopFunction(render, "BlendMode")
	end
end

function render.TextureBarrier()

end
