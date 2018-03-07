local ITexture = gmod.FindMetaTable("ITexture")
local IMaterial = gmod.FindMetaTable("IMaterial")

local ITexture_GetColor = ITexture.GetColor
local ITexture_GetMappingWidth = ITexture.GetMappingWidth
local ITexture_GetMappingHeight = ITexture.GetMappingHeight
local IMaterial_GetInt = IMaterial.GetInt
local IMaterial_SetTexture = IMaterial.SetTexture
local IMaterial_GetTexture = IMaterial.GetTexture

local Material = gmod.Material
local CreateMaterial = gmod.CreateMaterial
local CreateMaterial = gmod.CreateMaterial

local default_flags = "unlitgeneric mips noclamp smooth"

local render = ... or _G.render
local META = prototype.GetRegistered("texture")

function META:IsValid()
	return true
end

function META:IsLoading()
	return self.loading
end

function META:_GetRawPixelColor(x,y)
	local c = ITexture_GetColor(self.tex, x-1,y-1)

	return c.r, c.g, c.b, c.a
end

function META:GetSize()
	if self:IsLoading() then
		return Vec2(16, 16)
	end

	return Vec2(self.width or self.Size.x, self.height or self.Size.y)
end

function META:GetMipSize()
	return Vec3(0,0,0)
end

function META:_Download()

end

function META:SetMinFilter() end
function META:SetMagFilter() end

function META:SetITexture(tex)
	self.tex = tex

	self.width = tex:Width()
	self.height = tex:Height()

	self.Size = Vec2(self.width, self.height)
end

function META:SetPath(path, gmod_path)
	self.loading = true

	if gmod_path then
		local mat = Material(path, default_flags)

		self.tex = IMaterial_GetTexture(mat, "$basetexture")

		self.width = IMaterial_GetInt(mat, "$realwidth") or ITexture_GetMappingWidth(self.tex)
		self.height = IMaterial_GetInt(mat, "$realheight") or ITexture_GetMappingHeight(self.tex)
		self.Size = Vec2(self.width, self.height)

		self.loading = false
	else
		resource.Download(path, function(path)
			local path, where = GoluwaToGmodPath(path)

			if where == "DATA" then
				path = "../data/" .. path
			elseif path:StartWith("materials/") then
				path = path:sub(#"materials/" + 1)
			end

			local mat

			if path:endswith(".vtf") then
				mat = CreateMaterial("goluwa_" .. path, "UnlitGeneric", {
					["$basetexture"] = path:sub(0, -5),
				})
			else
				mat = Material(path, default_flags)
			end


			self.tex = IMaterial_GetTexture(mat, "$basetexture")

			self.width = IMaterial_GetInt(mat, "$realwidth") or ITexture_GetMappingWidth(self.tex)
			self.height = IMaterial_GetInt(mat, "$realheight") or ITexture_GetMappingHeight(self.tex)

			self.Size = Vec2(self.width, self.height)

			self.loading = false
		end)
	end
end

function META:Clear()
	local old = gmod.render.GetRenderTarget()
	gmod.render.SetRenderTarget(self.tex)
	gmod.render.Clear(0,0,0,0)
	gmod.render.SetRenderTarget(old)
end

function render._CreateTexture(self, type)
	self.tex =
		render.loading_texture and
		render.loading_texture.tex or
		IMaterial_GetTexture(Material("gui/progress_cog.png", default_flags), "$basetexture")

	return self
end