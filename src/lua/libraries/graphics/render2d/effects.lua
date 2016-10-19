local render2d = ... or _G.render2d

function render2d.EnableEffects(b)
	if b then
		local fb = render.CreateFrameBuffer()
		fb:SetTexture(1, render.CreateBlankTexture(render.GetScreenSize()))
		fb:SetTexture("depth_stencil", {internal_format = "depth_stencil", size = render.GetScreenSize()})
		fb:CheckCompletness()

		render2d.framebuffer = fb
	elseif render2d.framebuffer then
		render2d.framebuffer = nil
	end
end

render2d.effects = {}

function render2d.AddEffect(name, pos, ...)
	render2d.RemoveEffect(name)

	table.insert(render2d.effects, {name = name, pos = pos, args = {...}})

	table.sort(render2d.effects, function(a, b)
		return a.pos > b.pos
	end)
end

function render2d.RemoveEffect(name)
	for i, info in ipairs(render2d.effects) do
		if info.name == name then
			table.remove(render2d.effects, i)
		end
	end

	table.sort(render2d.effects, function(a, b)
		return a.pos > b.pos
	end)
end

function render2d.Start()
	if render2d.framebuffer then
		render2d.framebuffer:Begin()
	end
end

function render2d.End()
	if render2d.framebuffer then
		for _, info in ipairs(render2d.effects) do
			render2d.framebuffer:GetTexture():Shade(unpack(info.args))
		end

		render2d.framebuffer:End()

		render2d.framebuffer:Blit(render.GetScreenFrameBuffer())
	end
end