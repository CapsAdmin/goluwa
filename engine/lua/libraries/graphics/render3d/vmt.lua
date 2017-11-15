local META = ... or prototype.GetRegistered("material", "model")

local function unpack_numbers(str)
	str = str:gsub("%s+", " ")
	local t = str:split(" ")
	for k,v in ipairs(t) do t[k] = tonumber(v) end
	return unpack(t)
end

local get_srgb = function(path) return render.CreateTextureFromPath("[srgb]" .. path) end
local get_non_srgb = function(path) return render.CreateTextureFromPath("[~srgb]" .. path) end

local property_translate = {
	basetexture = {"AlbedoTexture", get_srgb},
	basetexture2 = {"Albedo2Texture", get_srgb},
	texture2 = {"Albedo2Texture", get_srgb},

	bumpmap = {"NormalTexture", get_non_srgb},
	bumpmap2 = {"Normal2Texture", get_non_srgb},
	envmapmask = {"MetallicTexture", get_non_srgb},
	phongexponenttexture = {"RoughnessTexture", get_non_srgb},
	blendmodulatetexture = {"BlendTexture", get_non_srgb},

	selfillummask = {"SelfIlluminationTexture", get_non_srgb},

	selfillum = {"SelfIllumination", function(num) return num end},
	selfillumtint = {"IlluminationColor", function(v)
		if type(v) == "string" then
			local r,g,b = unpack_numbers(v)
			return Color(r,g,b,1)
		elseif typex(v) == "vec3" then
			return Color(v.x, v.y, v.z, 1)
		end
		return v
	end},

	alphatest = {"AlphaTest", function(num) return num == 1 end},
	ssbump = {"SSBump", function(num) return num == 1 end},
	nocull = {"NoCull"},
	translucent = {"Translucent", function(num) return num == 1 end},

	normalmapalphaenvmapmask = {"NormalAlphaMetallic", function(num) return num == 1 end},
	basealphaenvmapmask = {"AlbedoAlphaMetallic", function(num) return num == 1 end},

	basemapluminancephongmask = {"AlbedoLuminancePhongMask", function(num) return num == 1 end},
	basemapalphaphongmask = {"AlbedoPhongMask", function(num) return num == 1 end},
	blendtintbybasealpha = {"BlendTintByBaseAlpha", function(num) return num == 1 end},

	phongexponent = {"RoughnessMultiplier", function(num) return 1/(-num+1)^3 end},
	envmaptint = {"MetallicMultiplier", function(num)
		if type(num) == "string" then
			return Vec3(unpack_numbers(num)):GetLength()
		elseif type(num) == "number" then
			return num
		elseif typex(num) == "vec3" then
			return num:GetLength()
		elseif typex(num) == "color" then
			return Vec3(num.r, num.g, num.b):GetLength()
		end
	end},
}

local special_textures = {
	_rt_fullframefb = "error",
	[1] = "error", -- huh
}

steam.unused_vmt_properties = steam.unused_vmt_properties or {}

function META:LoadVMT(path)
	self:SetName(path)
	self.vmt = {}

	steam.LoadVMT(
		path,
		function(key, val, full_path)
			self.vmt.fullpath = full_path
			self.vmt[key] = val

			if property_translate[key] then
				local func_name, convert = unpack(property_translate[key])
				if convert then
					val = convert(val)
				end
				self["Set" .. func_name](self, val)
			else
				steam.unused_vmt_properties[full_path] = steam.unused_vmt_properties[full_path] or {}
				steam.unused_vmt_properties[full_path][key] = val
			end
		end,
		function(err)
			self:SetError(err)
		end
	)
end

if RELOAD then
	for _,v in pairs(prototype.GetCreated()) do
		if v.Type == "material" and v.ClassName == "model" and v.vmt then
			--v:SetMetallicMultiplier(v:GetMetallicMultiplier()/3)
		end
	end
end

commands.Add("dump_unused_vmt_properties", function()
	for k, v in pairs(steam.unused_vmt_properties) do
		local properties = {}
		for k,v in pairs(v) do
			if
				k ~= "shader" and
				k ~= "fullpath" and
				k ~= "envmap" and
				k ~= "%keywords" and
				k ~= "surfaceprop"
			then
				properties[k] = v
			end
		end
		if next(properties) then
			logf("%s %s:\n", v.shader, k)

			for k,v in pairs(properties) do
				logf("\t%s = %s\n", k, v)
			end
		end
	end
end)