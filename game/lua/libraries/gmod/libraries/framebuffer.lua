if SERVER then return end

local lib = _G.render
local render = gine.env.render

gine.render_targets = gine.render_targets or {}

function gine.env.GetRenderTarget(name, w, h, additive)
	return gine.env.GetRenderTargetEx(name, w, h)
end

local size_mode_tr = gine.GetReverseEnums("RT_SIZE_(.+)")
local depth_mode_tr = gine.GetReverseEnums("MATERIAL_RT_DEPTH_(.+)")
local image_format_tr = gine.GetReverseEnums("IMAGE_FORMAT_(.+)")

local texture_flags_tbl = gine.GetEnums("TEXTUREFLAGS_(.+)")
local rt_flags_tbl = gine.GetEnums("CREATERENDERTARGETFLAGS_(.+)")

function gine.env.GetRenderTargetEx(name, w, h, size_mode, depth_mode, texture_flags, rt_flags, image_format)
	if gine.render_targets[name] then
		return gine.render_targets[name]
	end

	local size = Vec2(w, h)
	size_mode = size_mode_tr[size_mode or gine.env.RT_SIZE_DEFAULT]
	depth_mode = depth_mode_tr[depth_mode or gine.env.MATERIAL_RT_DEPTH_NONE]
	image_format = image_format_tr[size_mode or gine.env.IMAGE_FORMAT_DEFAULT]

	texture_flags = utility.FlagsToTable(texture_flags or 0, texture_flags_tbl)
	rt_flags = utility.FlagsToTable(rt_flags or 0, rt_flags_tbl)

	local texture_flags_str = {}
	for k,v in pairs(texture_flags) do if v then table.insert(texture_flags_str, k) end end
	texture_flags_str = "[" .. table.concat(texture_flags_str, ", ") .. "]"

	local rt_flags_str = {}
	for k,v in pairs(rt_flags) do if v then table.insert(rt_flags_str, k) end end
	rt_flags_str = "[" .. table.concat(rt_flags_str, ", ") .. "]"

	--[[llog("GetRenderTarget(Ex):")
	table.print({
		name = name,
		size = size,
		size_mode = size_mode,
		depth_mode = depth_mode,
		texture_flags = texture_flags_str,
		rt_flags = rt_flags_str,
		image_format = image_format,
	})]]

	local fb = lib.CreateFrameBuffer(size)

	fb:SetTexture("depth_stencil", {internal_format = "depth_stencil", size = size})
	fb:GetTexture().fb = fb

	gine.render_targets[name] = gine.WrapObject(fb:GetTexture(), "ITexture")

	return gine.render_targets[name]
end

local current_fb

function render.SetRenderTarget(tex)
	if tex.__obj.fb then
		tex.__obj.fb:Bind()
		current_fb = tex
	end
end

function render.GetRenderTarget()
	return current_fb or gine.WrapObject(_G.render.GetErrorTexture(), "ITexture")
end

function render.CopyRenderTargetToTexture(tex)

end

function render.PushRenderTarget(rt, x,y,w,h)
	lib.PushFrameBuffer(rt.__obj.fb)

	x = x or 0
	y = y or 0
	w = w or rt.__obj.fb:GetSize().x
	h = h or rt.__obj.fb:GetSize().y

	lib.PushViewport(x,y,w,h)
end

function render.PopRenderTarget()
	lib.PopViewport()

	lib.PopFrameBuffer()
end
