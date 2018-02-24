local ITexture = gmod.FindMetaTable("ITexture")
local IMaterial = gmod.FindMetaTable("IMaterial")

local ITexture_GetColor = ITexture.GetColor
local ITexture_GetMappingWidth = ITexture.GetMappingWidth
local ITexture_GetMappingHeight = ITexture.GetMappingHeight
local IMaterial_GetInt = IMaterial.GetInt
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

function META:GetPixelColor(x,y)
	local c = ITexture_GetColor(self.tex, x,y)
	return Color(c.r/255, c.g/255, c.b/255, c.a/255)
end

function META:GetSize()
	if self:IsLoading() then
		return Vec2(16, 16)
	end

	return Vec2(self.width, self.height)
end

function META:SetMinFilter() end
function META:SetMagFilter() end

function META:SetPath(path, gmod_path)
	if gmod_path then
		self.mat = Material(path, default_flags)

		self.tex = IMaterial_GetTexture(self.mat, "$basetexture")

		self.width = IMaterial_GetInt(self.mat, "$realwidth") or ITexture_GetMappingWidth(self.tex)
		self.height = IMaterial_GetInt(self.mat, "$realheight") or ITexture_GetMappingHeight(self.tex)
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

			if path:endswith(".vtf") then
				self.mat = CreateMaterial("goluwa_" .. path, "UnlitGeneric", {
					["$basetexture"] = path:sub(0, -5),
					["$translucent"] = 1,
					["$vertexcolor"] = 1,
					["$vertexalpha"] = 1,
				})
			else
				self.mat = Material(path, default_flags)
			end

			self.tex = IMaterial_GetTexture(self.mat, "$basetexture")

			self.width = IMaterial_GetInt(self.mat, "$realwidth") or ITexture_GetMappingWidth(self.tex)
			self.height = IMaterial_GetInt(self.mat, "$realheight") or ITexture_GetMappingHeight(self.tex)
			self.Size = Vec2(self.width, self.height)

			self.loading = false
		end)
	end
end

local loading_material = Material("gui/progress_cog.png", default_flags)

function render._CreateTexture(self, type)
	self.mat = loading_material
	self.loading = true

	return self
end