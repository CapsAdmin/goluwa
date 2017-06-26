local shaders = {
	unlitgeneric = function()
		SHADER_PARAM( ALBEDO, SHADER_PARAM_TYPE_TEXTURE, "shadertest/BaseTexture", "albedo (Base texture with no baked lighting)" )
		SHADER_PARAM( DETAIL, SHADER_PARAM_TYPE_TEXTURE, "shadertest/detail", "detail texture" )
		SHADER_PARAM( DETAILFRAME, SHADER_PARAM_TYPE_INTEGER, "0", "frame number for $detail" )
		SHADER_PARAM( DETAILSCALE, SHADER_PARAM_TYPE_FLOAT, "4", "scale of the detail texture" )
		SHADER_PARAM( ENVMAP, SHADER_PARAM_TYPE_TEXTURE, "shadertest/shadertest_env", "envmap" )
		SHADER_PARAM( ENVMAPFRAME, SHADER_PARAM_TYPE_INTEGER, "", "envmap frame number" )
		SHADER_PARAM( ENVMAPMASK, SHADER_PARAM_TYPE_TEXTURE, "shadertest/shadertest_envmask", "envmap mask" )
		SHADER_PARAM( ENVMAPMASKFRAME, SHADER_PARAM_TYPE_INTEGER, "0", "" )
		SHADER_PARAM( ENVMAPMASKTRANSFORM, SHADER_PARAM_TYPE_MATRIX, "center .5 .5 scale 1 1 rotate 0 translate 0 0", "$envmapmask texcoord transform" )
		SHADER_PARAM( ENVMAPTINT, SHADER_PARAM_TYPE_COLOR, "[1 1 1]", "envmap tint" )
		SHADER_PARAM( ENVMAPCONTRAST, SHADER_PARAM_TYPE_FLOAT, "0.0", "contrast 0 == normal 1 == color*color" )
		SHADER_PARAM( ENVMAPSATURATION, SHADER_PARAM_TYPE_FLOAT, "1.0", "saturation 0 == greyscale 1 == normal" )
		SHADER_PARAM( ALPHATESTREFERENCE, SHADER_PARAM_TYPE_FLOAT, "0.7", "" )
		SHADER_PARAM( VERTEXALPHATEST, SHADER_PARAM_TYPE_INTEGER, "0", "" )
		SHADER_PARAM( HDRCOLORSCALE, SHADER_PARAM_TYPE_FLOAT, "1.0", "hdr color scale" )
		SHADER_PARAM( PHONGEXPONENT, SHADER_PARAM_TYPE_FLOAT, "5.0", "Phong exponent for local specular lights" )
		SHADER_PARAM( PHONGTINT, SHADER_PARAM_TYPE_VEC3, "5.0", "Phong tint for local specular lights" )
		SHADER_PARAM( PHONGALBEDOTINT, SHADER_PARAM_TYPE_BOOL, "1.0", "Apply tint by albedo (controlled by spec exponent texture" )
		SHADER_PARAM( LIGHTWARPTEXTURE, SHADER_PARAM_TYPE_TEXTURE, "shadertest/BaseTexture", "1D ramp texture for tinting scalar diffuse term" )
		SHADER_PARAM( PHONGWARPTEXTURE, SHADER_PARAM_TYPE_TEXTURE, "shadertest/BaseTexture", "2D map for warping specular" )
		SHADER_PARAM( PHONGFRESNELRANGES, SHADER_PARAM_TYPE_VEC3, "[0  0.5  1]", "Parameters for remapping fresnel output" )
		SHADER_PARAM( PHONGBOOST, SHADER_PARAM_TYPE_FLOAT, "1.0", "Phong overbrightening factor (specular mask channel should be authored to account for this)" )
		SHADER_PARAM( PHONGEXPONENTTEXTURE, SHADER_PARAM_TYPE_TEXTURE, "shadertest/BaseTexture", "Phong Exponent map" )
		SHADER_PARAM( PHONG, SHADER_PARAM_TYPE_BOOL, "0", "enables phong lighting" )
		SHADER_PARAM( DETAILBLENDMODE, SHADER_PARAM_TYPE_INTEGER, "0", "mode for combining detail texture with base. 0=normal, 1= additive, 2=alpha blend detail over base, 3=crossfade" )
		SHADER_PARAM( DETAILBLENDFACTOR, SHADER_PARAM_TYPE_FLOAT, "1", "blend amount for detail texture." )
		SHADER_PARAM( DETAILTEXTURETRANSFORM, SHADER_PARAM_TYPE_MATRIX, "center .5 .5 scale 1 1 rotate 0 translate 0 0", "$detail texcoord transform" )

		SHADER_PARAM( SELFILLUMMASK, SHADER_PARAM_TYPE_TEXTURE, "shadertest/BaseTexture", "If we bind a texture here, it overrides base alpha (if any) for self illum" )

		SHADER_PARAM( DISTANCEALPHA, SHADER_PARAM_TYPE_BOOL, "0", "Use distance-coded alpha generated from hi-res texture by vtex.")
		SHADER_PARAM( DISTANCEALPHAFROMDETAIL, SHADER_PARAM_TYPE_BOOL, "0", "Take the distance-coded alpha mask from the detail texture.")

		SHADER_PARAM( SOFTEDGES, SHADER_PARAM_TYPE_BOOL, "0", "Enable soft edges to distance coded textures.")
		SHADER_PARAM( SCALEEDGESOFTNESSBASEDONSCREENRES, SHADER_PARAM_TYPE_BOOL, "0", "Scale the size of the soft edges based upon resolution. 1024x768 = nominal.")
		SHADER_PARAM( EDGESOFTNESSSTART, SHADER_PARAM_TYPE_FLOAT, "0.6", "Start value for soft edges for distancealpha.");
		SHADER_PARAM( EDGESOFTNESSEND, SHADER_PARAM_TYPE_FLOAT, "0.5", "End value for soft edges for distancealpha.");

		SHADER_PARAM( GLOW, SHADER_PARAM_TYPE_BOOL, "0", "Enable glow/shadow for distance coded textures.")
		SHADER_PARAM( GLOWCOLOR, SHADER_PARAM_TYPE_COLOR, "[1 1 1]", "color of outter glow for distance coded line art." )
		SHADER_PARAM( GLOWALPHA, SHADER_PARAM_TYPE_FLOAT, "1", "Base glow alpha amount for glows/shadows with distance alpha." )
		SHADER_PARAM( GLOWSTART, SHADER_PARAM_TYPE_FLOAT, "0.7", "start value for glow/shadow")
		SHADER_PARAM( GLOWEND, SHADER_PARAM_TYPE_FLOAT, "0.5", "end value for glow/shadow")
		SHADER_PARAM( GLOWX, SHADER_PARAM_TYPE_FLOAT, "0", "texture offset x for glow mask.")
		SHADER_PARAM( GLOWY, SHADER_PARAM_TYPE_FLOAT, "0", "texture offset y for glow mask.")

		SHADER_PARAM( OUTLINE, SHADER_PARAM_TYPE_BOOL, "0", "Enable outline for distance coded textures.")
		SHADER_PARAM( OUTLINECOLOR, SHADER_PARAM_TYPE_COLOR, "[1 1 1]", "color of outline for distance coded images." )
		SHADER_PARAM( OUTLINEALPHA, SHADER_PARAM_TYPE_FLOAT, "0.0", "alpha value for outline")
		SHADER_PARAM( OUTLINESTART0, SHADER_PARAM_TYPE_FLOAT, "0.0", "outer start value for outline")
		SHADER_PARAM( OUTLINESTART1, SHADER_PARAM_TYPE_FLOAT, "0.0", "inner start value for outline")
		SHADER_PARAM( OUTLINEEND0, SHADER_PARAM_TYPE_FLOAT, "0.0", "inner end value for outline")
		SHADER_PARAM( OUTLINEEND1, SHADER_PARAM_TYPE_FLOAT, "0.0", "outer end value for outline")
		SHADER_PARAM( SCALEOUTLINESOFTNESSBASEDONSCREENRES, SHADER_PARAM_TYPE_BOOL, "0", "Scale the size of the soft part of the outline based upon resolution. 1024x768 = nominal.")

		SHADER_PARAM( SEPARATEDETAILUVS, SHADER_PARAM_TYPE_BOOL, "0", "Use texcoord1 for detail texture" )

		SHADER_PARAM( GAMMACOLORREAD, SHADER_PARAM_TYPE_INTEGER, "0", "Disables SRGB conversion of color texture read." )
		SHADER_PARAM( LINEARWRITE, SHADER_PARAM_TYPE_INTEGER, "0", "Disables SRGB conversion of shader results." )

		SHADER_PARAM( DEPTHBLEND, SHADER_PARAM_TYPE_INTEGER, "0", "fade at intersection boundaries" )
		SHADER_PARAM( DEPTHBLENDSCALE, SHADER_PARAM_TYPE_FLOAT, "50.0", "Amplify or reduce DEPTHBLEND fading. Lower values make harder edges." )
		SHADER_PARAM( RECEIVEFLASHLIGHT, SHADER_PARAM_TYPE_INTEGER, "0", "Forces this material to receive flashlights." )
	end,

	vertexlitgeneric = function()
		SHADER_PARAM( ALBEDO, SHADER_PARAM_TYPE_TEXTURE, "shadertest/BaseTexture", "albedo (Base texture with no baked lighting)" )
		SHADER_PARAM( COMPRESS, SHADER_PARAM_TYPE_TEXTURE, "shadertest/BaseTexture", "compression wrinklemap" )
		SHADER_PARAM( STRETCH, SHADER_PARAM_TYPE_TEXTURE, "shadertest/BaseTexture", "expansion wrinklemap" )
		SHADER_PARAM( SELFILLUMTINT, SHADER_PARAM_TYPE_COLOR, "[1 1 1]", "Self-illumination tint" )
		SHADER_PARAM( DETAIL, SHADER_PARAM_TYPE_TEXTURE, "shadertest/detail", "detail texture" )
		SHADER_PARAM( DETAILFRAME, SHADER_PARAM_TYPE_INTEGER, "0", "frame number for $detail" )
		SHADER_PARAM( DETAILSCALE, SHADER_PARAM_TYPE_FLOAT, "4", "scale of the detail texture" )
		SHADER_PARAM( ENVMAP, SHADER_PARAM_TYPE_TEXTURE, "shadertest/shadertest_env", "envmap" )
		SHADER_PARAM( ENVMAPFRAME, SHADER_PARAM_TYPE_INTEGER, "0", "envmap frame number" )
		SHADER_PARAM( ENVMAPMASK, SHADER_PARAM_TYPE_TEXTURE, "shadertest/shadertest_envmask", "envmap mask" )
		SHADER_PARAM( ENVMAPMASKFRAME, SHADER_PARAM_TYPE_INTEGER, "0", "" )
		SHADER_PARAM( ENVMAPMASKTRANSFORM, SHADER_PARAM_TYPE_MATRIX, "center .5 .5 scale 1 1 rotate 0 translate 0 0", "$envmapmask texcoord transform" )
		SHADER_PARAM( ENVMAPTINT, SHADER_PARAM_TYPE_COLOR, "[1 1 1]", "envmap tint" )
		SHADER_PARAM( BUMPMAP, SHADER_PARAM_TYPE_TEXTURE, "models/shadertest/shader1_normal", "bump map" )
		SHADER_PARAM( BUMPCOMPRESS, SHADER_PARAM_TYPE_TEXTURE, "models/shadertest/shader3_normal", "compression bump map" )
		SHADER_PARAM( BUMPSTRETCH, SHADER_PARAM_TYPE_TEXTURE, "models/shadertest/shader1_normal", "expansion bump map" )
		SHADER_PARAM( BUMPFRAME, SHADER_PARAM_TYPE_INTEGER, "0", "frame number for $bumpmap" )
		SHADER_PARAM( BUMPTRANSFORM, SHADER_PARAM_TYPE_MATRIX, "center .5 .5 scale 1 1 rotate 0 translate 0 0", "$bumpmap texcoord transform" )
		SHADER_PARAM( ENVMAPCONTRAST, SHADER_PARAM_TYPE_FLOAT, "0.0", "contrast 0 == normal 1 == color*color" )
		SHADER_PARAM( ENVMAPSATURATION, SHADER_PARAM_TYPE_FLOAT, "1.0", "saturation 0 == greyscale 1 == normal" )
		SHADER_PARAM( SELFILLUM_ENVMAPMASK_ALPHA, SHADER_PARAM_TYPE_FLOAT,"0.0","defines that self illum value comes from env map mask alpha" )
		SHADER_PARAM( SELFILLUMFRESNEL, SHADER_PARAM_TYPE_BOOL, "0", "Self illum fresnel" )
		SHADER_PARAM( SELFILLUMFRESNELMINMAXEXP, SHADER_PARAM_TYPE_VEC4, "0", "Self illum fresnel min, max, exp" )
		SHADER_PARAM( ALPHATESTREFERENCE, SHADER_PARAM_TYPE_FLOAT, "0.0", "" )
		SHADER_PARAM( FLASHLIGHTNOLAMBERT, SHADER_PARAM_TYPE_BOOL, "0", "Flashlight pass sets N.L=1.0" )

		-- Debugging term for visualizing ambient data on its own
		SHADER_PARAM( AMBIENTONLY, SHADER_PARAM_TYPE_INTEGER, "0", "Control drawing of non-ambient light ()" )

		SHADER_PARAM( PHONGEXPONENT, SHADER_PARAM_TYPE_FLOAT, "5.0", "Phong exponent for local specular lights" )
		SHADER_PARAM( PHONGTINT, SHADER_PARAM_TYPE_VEC3, "5.0", "Phong tint for local specular lights" )
		SHADER_PARAM( PHONGALBEDOTINT, SHADER_PARAM_TYPE_BOOL, "1.0", "Apply tint by albedo (controlled by spec exponent texture" )
		SHADER_PARAM( LIGHTWARPTEXTURE, SHADER_PARAM_TYPE_TEXTURE, "shadertest/BaseTexture", "1D ramp texture for tinting scalar diffuse term" )
		SHADER_PARAM( PHONGWARPTEXTURE, SHADER_PARAM_TYPE_TEXTURE, "shadertest/BaseTexture", "warp the specular term" )
		SHADER_PARAM( PHONGFRESNELRANGES, SHADER_PARAM_TYPE_VEC3, "[0  0.5  1]", "Parameters for remapping fresnel output" )
		SHADER_PARAM( PHONGBOOST, SHADER_PARAM_TYPE_FLOAT, "1.0", "Phong overbrightening factor (specular mask channel should be authored to account for this)" )
		SHADER_PARAM( PHONGEXPONENTTEXTURE, SHADER_PARAM_TYPE_TEXTURE, "shadertest/BaseTexture", "Phong Exponent map" )
		SHADER_PARAM( PHONG, SHADER_PARAM_TYPE_BOOL, "0", "enables phong lighting" )
		SHADER_PARAM( BASEMAPALPHAPHONGMASK, SHADER_PARAM_TYPE_INTEGER, "0", "indicates that there is no normal map and that the phong mask is in base alpha" )
		SHADER_PARAM( INVERTPHONGMASK, SHADER_PARAM_TYPE_INTEGER, "0", "invert the phong mask (0=full phong, 1=no phong)" )
		SHADER_PARAM( ENVMAPFRESNEL, SHADER_PARAM_TYPE_FLOAT, "0", "Degree to which Fresnel should be applied to env map" )
		SHADER_PARAM( SELFILLUMMASK, SHADER_PARAM_TYPE_TEXTURE, "shadertest/BaseTexture", "If we bind a texture here, it overrides base alpha (if any) for self illum" )

		-- detail (multi-) texturing
		SHADER_PARAM( DETAILBLENDMODE, SHADER_PARAM_TYPE_INTEGER, "0", "mode for combining detail texture with base. 0=normal, 1= additive, 2=alpha blend detail over base, 3=crossfade" )
		SHADER_PARAM( DETAILBLENDFACTOR, SHADER_PARAM_TYPE_FLOAT, "1", "blend amount for detail texture." )
		SHADER_PARAM( DETAILTINT, SHADER_PARAM_TYPE_COLOR, "[1 1 1]", "detail texture tint" )
		SHADER_PARAM( DETAILTEXTURETRANSFORM, SHADER_PARAM_TYPE_MATRIX, "center .5 .5 scale 1 1 rotate 0 translate 0 0", "$detail texcoord transform" )

		-- Rim lighting terms
		SHADER_PARAM( RIMLIGHT, SHADER_PARAM_TYPE_BOOL, "0", "enables rim lighting" )
		SHADER_PARAM( RIMLIGHTEXPONENT, SHADER_PARAM_TYPE_FLOAT, "4.0", "Exponent for rim lights" )
		SHADER_PARAM( RIMLIGHTBOOST, SHADER_PARAM_TYPE_FLOAT, "1.0", "Boost for rim lights" )
		SHADER_PARAM( RIMMASK, SHADER_PARAM_TYPE_BOOL, "0", "Indicates whether or not to use alpha channel of exponent texture to mask the rim term" )

		-- Seamless mapping scale
		SHADER_PARAM( SEAMLESS_BASE, SHADER_PARAM_TYPE_BOOL, "0", "whether to apply seamless mapping to the base texture. requires a smooth model." )
		SHADER_PARAM( SEAMLESS_DETAIL, SHADER_PARAM_TYPE_BOOL, "0", "where to apply seamless mapping to the detail texture." )
		SHADER_PARAM( SEAMLESS_SCALE, SHADER_PARAM_TYPE_FLOAT, "1.0", "the scale for the seamless mapping. # of repetions of texture per inch." )

		-- Emissive Scroll Pass
		SHADER_PARAM( EMISSIVEBLENDENABLED, SHADER_PARAM_TYPE_BOOL, "0", "Enable emissive blend pass" )
		SHADER_PARAM( EMISSIVEBLENDBASETEXTURE, SHADER_PARAM_TYPE_TEXTURE, "", "self-illumination map" )
		SHADER_PARAM( EMISSIVEBLENDSCROLLVECTOR, SHADER_PARAM_TYPE_VEC2, "[0.11 0.124]", "Emissive scroll vec" )
		SHADER_PARAM( EMISSIVEBLENDSTRENGTH, SHADER_PARAM_TYPE_FLOAT, "1.0", "Emissive blend strength" )
		SHADER_PARAM( EMISSIVEBLENDTEXTURE, SHADER_PARAM_TYPE_TEXTURE, "", "self-illumination map" )
		SHADER_PARAM( EMISSIVEBLENDTINT, SHADER_PARAM_TYPE_COLOR, "[1 1 1]", "Self-illumination tint" )
		SHADER_PARAM( EMISSIVEBLENDFLOWTEXTURE, SHADER_PARAM_TYPE_TEXTURE, "", "flow map" )
		SHADER_PARAM( TIME, SHADER_PARAM_TYPE_FLOAT, "0.0", "Needs CurrentTime Proxy" )

		-- Cloak Pass
		SHADER_PARAM( CLOAKPASSENABLED, SHADER_PARAM_TYPE_BOOL, "0", "Enables cloak render in a second pass" )
		SHADER_PARAM( CLOAKFACTOR, SHADER_PARAM_TYPE_FLOAT, "0.0", "" )
		SHADER_PARAM( CLOAKCOLORTINT, SHADER_PARAM_TYPE_COLOR, "[1 1 1]", "Cloak color tint" )
		SHADER_PARAM( REFRACTAMOUNT, SHADER_PARAM_TYPE_FLOAT, "2", "" )

		-- Weapon Sheen Pass
		SHADER_PARAM( SHEENPASSENABLED, SHADER_PARAM_TYPE_BOOL, "0", "Enables weapon sheen render in a second pass" )
		SHADER_PARAM( SHEENMAP, SHADER_PARAM_TYPE_TEXTURE, "shadertest/shadertest_env", "sheenmap" )
		SHADER_PARAM( SHEENMAPMASK, SHADER_PARAM_TYPE_TEXTURE, "shadertest/shadertest_envmask", "sheenmap mask" )
		SHADER_PARAM( SHEENMAPMASKFRAME, SHADER_PARAM_TYPE_INTEGER, "0", "" )
		SHADER_PARAM( SHEENMAPTINT, SHADER_PARAM_TYPE_COLOR, "[1 1 1]", "sheenmap tint" )
		SHADER_PARAM( SHEENMAPMASKSCALEX, SHADER_PARAM_TYPE_FLOAT, "1", "X Scale the size of the map mask to the size of the target" )
		SHADER_PARAM( SHEENMAPMASKSCALEY, SHADER_PARAM_TYPE_FLOAT, "1", "Y Scale the size of the map mask to the size of the target" )
		SHADER_PARAM( SHEENMAPMASKOFFSETX, SHADER_PARAM_TYPE_FLOAT, "0", "X Offset of the mask relative to model space coords of target" )
		SHADER_PARAM( SHEENMAPMASKOFFSETY, SHADER_PARAM_TYPE_FLOAT, "0", "Y Offset of the mask relative to model space coords of target" )
		SHADER_PARAM( SHEENMAPMASKDIRECTION, SHADER_PARAM_TYPE_INTEGER, "0", "The direction the sheen should move (length direction of weapon) XYZ, 0,1,2" )
		SHADER_PARAM( SHEENINDEX, SHADER_PARAM_TYPE_INTEGER, "0", "Index of the Effect Type (Color Additive, Override etc...)" )

		-- Flesh Interior Pass
		SHADER_PARAM( FLESHINTERIORENABLED, SHADER_PARAM_TYPE_BOOL, "0", "Enable Flesh interior blend pass" )
		SHADER_PARAM( FLESHINTERIORTEXTURE, SHADER_PARAM_TYPE_TEXTURE, "", "Flesh color texture" )
		SHADER_PARAM( FLESHINTERIORNOISETEXTURE, SHADER_PARAM_TYPE_TEXTURE, "", "Flesh noise texture" )
		SHADER_PARAM( FLESHBORDERTEXTURE1D, SHADER_PARAM_TYPE_TEXTURE, "", "Flesh border 1D texture" )
		SHADER_PARAM( FLESHNORMALTEXTURE, SHADER_PARAM_TYPE_TEXTURE, "", "Flesh normal texture" )
		SHADER_PARAM( FLESHSUBSURFACETEXTURE, SHADER_PARAM_TYPE_TEXTURE, "", "Flesh subsurface texture" )
		SHADER_PARAM( FLESHCUBETEXTURE, SHADER_PARAM_TYPE_TEXTURE, "", "Flesh cubemap texture" )
		SHADER_PARAM( FLESHBORDERNOISESCALE, SHADER_PARAM_TYPE_FLOAT, "1.5", "Flesh Noise UV scalar for border" )
		SHADER_PARAM( FLESHDEBUGFORCEFLESHON, SHADER_PARAM_TYPE_BOOL, "0", "Flesh Debug full flesh" )
		SHADER_PARAM( FLESHEFFECTCENTERRADIUS1, SHADER_PARAM_TYPE_VEC4, "[0 0 0 0.001]", "Flesh effect center and radius" )
		SHADER_PARAM( FLESHEFFECTCENTERRADIUS2, SHADER_PARAM_TYPE_VEC4, "[0 0 0 0.001]", "Flesh effect center and radius" )
		SHADER_PARAM( FLESHEFFECTCENTERRADIUS3, SHADER_PARAM_TYPE_VEC4, "[0 0 0 0.001]", "Flesh effect center and radius" )
		SHADER_PARAM( FLESHEFFECTCENTERRADIUS4, SHADER_PARAM_TYPE_VEC4, "[0 0 0 0.001]", "Flesh effect center and radius" )
		SHADER_PARAM( FLESHSUBSURFACETINT, SHADER_PARAM_TYPE_COLOR, "[1 1 1]", "Subsurface Color" )
		SHADER_PARAM( FLESHBORDERWIDTH, SHADER_PARAM_TYPE_FLOAT, "0.3", "Flesh border" )
		SHADER_PARAM( FLESHBORDERSOFTNESS, SHADER_PARAM_TYPE_FLOAT, "0.42", "Flesh border softness (> 0.0 && <= 0.5)" )
		SHADER_PARAM( FLESHBORDERTINT, SHADER_PARAM_TYPE_COLOR, "[1 1 1]", "Flesh border Color" )
		SHADER_PARAM( FLESHGLOBALOPACITY, SHADER_PARAM_TYPE_FLOAT, "1.0", "Flesh global opacity" )
		SHADER_PARAM( FLESHGLOSSBRIGHTNESS, SHADER_PARAM_TYPE_FLOAT, "0.66", "Flesh gloss brightness" )
		SHADER_PARAM( FLESHSCROLLSPEED, SHADER_PARAM_TYPE_FLOAT, "1.0", "Flesh scroll speed" )

		SHADER_PARAM( SEPARATEDETAILUVS, SHADER_PARAM_TYPE_BOOL, "0", "Use texcoord1 for detail texture" )
		SHADER_PARAM( LINEARWRITE, SHADER_PARAM_TYPE_INTEGER, "0", "Disables SRGB conversion of shader results." )
		SHADER_PARAM( DEPTHBLEND, SHADER_PARAM_TYPE_INTEGER, "0", "fade at intersection boundaries. Only supported without bumpmaps" )
		SHADER_PARAM( DEPTHBLENDSCALE, SHADER_PARAM_TYPE_FLOAT, "50.0", "Amplify or reduce DEPTHBLEND fading. Lower values make harder edges." )

		SHADER_PARAM( BLENDTINTBYBASEALPHA, SHADER_PARAM_TYPE_BOOL, "0", "Use the base alpha to blend in the $color modulation")
		SHADER_PARAM( BLENDTINTCOLOROVERBASE, SHADER_PARAM_TYPE_FLOAT, "0", "blend between tint acting as a multiplication versus a replace" )
	end,
}

local flags = {
	"debug",
	"no_debug_override",
	"no_draw",
	"use_in_fillrate_mode",
	"vertexcolor",
	"vertexalpha",
	"selfillum",
	"additive",
	"alphatest",
	"multipass",
	"znearer",
	"model",
	"flat",
	"nocull",
	"nofog",
	"ignorez",
	"decal",
	"envmapsphere",
	"noalphamod",
	"envmapcameraspace",
	"basealphaenvmapmask",
	"translucent",
	"normalmapalphaenvmapmask",
	"needs_software_skinning",
	"opaquetexture",
	"envmapmode",
	"suppress_decals",
	"halflambert",
	"wireframe",
	"allowalphatocoverage",
	"ignore_alpha_modulation",

	-- extra
	"nolod",
}

local other = {
	basetexture = {type = "texture", default = nil, description = "base texture"},
	texture = {type = "texture", default = nil, description = "base texture"},
	basetexture2 = {type = "texture", default = nil, description = "base texture"},
	texture2 = {type = "texture", default = nil, description = "base texture"},
}

for name, func in pairs(shaders) do
	local tbl = {}
	setfenv(func, setmetatable({SHADER_PARAM = function(key, type, default, description) tbl[key] = {type = type:sub(19), default = default, description = description} end}, {__index = function(_, key) return key:lower() end}))
	func()
	shaders[name] = tbl
end

for _, key in ipairs(flags) do
	for name, shader in pairs(shaders) do
		shader[key] = {type = "int", default = "0", description = ""}
	end
end

for key, info in pairs(other) do
	for name, shader in pairs(shaders) do
		shader[key] = shader[key] or table.copy(info)
	end
end

local function add_new_defaults(shader, defaults)
	for k,v in pairs(defaults) do
		if shaders[shader][k] then
			shaders[shader][k].default2 = v
		end
	end
end

add_new_defaults("unlitgeneric", {
	-- lua_run_cl local mat = CreateMaterial("wow", "UnlitGeneric", {}) for k,v in pairs(mat:GetKeyValues()) do print(k:sub(2) .. " = \"" .. mat:GetString(k) .. "\",") end
	glowstart = "0.000000",
	outlinestart0 = "0.000000",
	vertexalphatest = "0",
	envmapsaturation = "1.000000",
	frame = "0",
	envmapmasktransform = "[ 1.000 0.000 0.000 0.000 0.000 1.000 0.000 0.000 0.000 0.000 1.000 0.000 0.000 0.000 0.000 1.000 ]",
	color2 = "[ 1.000000 1.000000 1.000000 ]",
	phongalbedotint = "0",
	phongboost = "0.000000",
	phongfresnelranges = "[ 0.000000 0.000000 0.000000 ]",
	outlineend0 = "0.000000",
	flashlighttextureframe = "0",
	depthblendscale = "50.000000",
	flags = "0",
	envmapmaskframe = "0",
	flags2 = "262144",
	depthblend = "0",
	separatedetailuvs = "0",
	basetexturetransform = "[ 1.000 0.000 0.000 0.000 0.000 1.000 0.000 0.000 0.000 0.000 1.000 0.000 0.000 0.000 0.000 1.000 ]",
	alphatestreference = "0.000000",
	linearwrite = "0",
	detailblendfactor = "1.000000",
	scaleedgesoftnessbasedonscreenres = "0",
	scaleoutlinesoftnessbasedonscreenres = "0",
	outlineend1 = "0.000000",
	outlinestart1 = "0.000000",
	alpha = "1.000000",
	outlinealpha = "1.000000",
	glowend = "0.000000",
	outlinecolor = "[ 1.000000 1.000000 1.000000 ]",
	softedges = "0",
	glowy = "0.000000",
	envmapcontrast = "0.000000",
	envmapframe = "0",
	glowx = "0.000000",
	flags_defined = "0",
	glowalpha = "1.000000",
	color = "[ 1.000000 1.000000 1.000000 ]",
	detailframe = "0",
	glow = "0",
	detailscale = "4.000000",
	flashlighttexture = "effects/flashlight_border",
	edgesoftnessend = "0.500000",
	envmaptint = "[ 1.000000 1.000000 1.000000 ]",
	phong = "0",
	gammacolorread = "0",
	outline = "0",
	detailtexturetransform = "[ 1.000 0.000 0.000 0.000 0.000 1.000 0.000 0.000 0.000 0.000 1.000 0.000 0.000 0.000 0.000 1.000 ]",
	distancealphafromdetail = "0",
	distancealpha = "0",
	receiveflashlight = "0",
	edgesoftnessstart = "0.500000",
	srgbtint = "[ 1.000000 1.000000 1.000000 ]",
	glowcolor = "[ 1.000000 1.000000 1.000000 ]",
	hdrcolorscale = "1.000000",
	phongexponent = "0.000000",
	detailblendmode = "0",
	phongtint = "[ 0.000000 0.000000 0.000000 ]",
	flags_defined2 = "0",
})

add_new_defaults("vertexlitgeneric", {
	-- lua_run_cl local mat = CreateMaterial("wow2", "VertexLitGeneric", {}) for k,v in pairs(mat:GetKeyValues()) do print(k:sub(2) .. " = \"" .. mat:GetString(k) .. "\",") end
	flesheffectcenterradius1 = "[ 0.000000 0.000000 0.000000 0.000000 ]",
	envmapsaturation = "1.000000",
	rimlight = "0",
	envmapmasktransform = "[ 1.000 0.000 0.000 0.000 0.000 1.000 0.000 0.000 0.000 0.000 1.000 0.000 0.000 0.000 0.000 1.000 ]",
	phongalbedotint = "0",
	flashlighttextureframe = "0",
	fleshborderwidth = "0.000000",
	flags = "0",
	envmapmaskframe = "0",
	flags2 = "262146",
	basetexturetransform = "[ 1.000 0.000 0.000 0.000 0.000 1.000 0.000 0.000 0.000 0.000 1.000 0.000 0.000 0.000 0.000 1.000 ]",
	alphatestreference = "0.000000",
	bumptransform = "[ 1.000 0.000 0.000 0.000 0.000 1.000 0.000 0.000 0.000 0.000 1.000 0.000 0.000 0.000 0.000 1.000 ]",
	flesheffectcenterradius2 = "[ 0.000000 0.000000 0.000000 0.000000 ]",
	fleshinteriorenabled = "0",
	bumpframe = "0",
	flesheffectcenterradius3 = "[ 0.000000 0.000000 0.000000 0.000000 ]",
	color = "[ 1.000000 1.000000 1.000000 ]",
	detailscale = "4.000000",
	phongtint = "[ 0.000000 0.000000 0.000000 ]",
	srgbtint = "[ 1.000000 1.000000 1.000000 ]",
	selfillumtint = "[ 1.000000 1.000000 1.000000 ]",
	cloakpassenabled = "0",
	fleshdebugforcefleshon = "0",
	fleshglossbrightness = "0.000000",
	detailtint = "[ 1.000000 1.000000 1.000000 ]",
	phongexponent = "0.000000",
	flashlightnolambert = "0",
	seamless_detail = "0",
	selfillum_envmapmask_alpha = "0.000000",
	basemapalphaphongmask = "0",
	frame = "0",
	seamless_base = "0",
	color2 = "[ 1.000000 1.000000 1.000000 ]",
	phongboost = "0.000000",
	fleshscrollspeed = "0.000000",
	emissiveblendenabled = "0",
	ambientonly = "0",
	blendtintcoloroverbase = "0.000000",
	blendtintbybasealpha = "0",
	detailblendmode = "0",
	detailblendfactor = "1.000000",
	depthblend = "0",
	envmapfresnel = "0.000000",
	linearwrite = "0",
	alpha = "1.000000",
	separatedetailuvs = "0",
	selfillumfresnel = "0",
	rimmask = "0",
	emissiveblendscrollvector = "[ 0.000000 0.000000 ]",
	fleshbordertint = "[ 1.000000 1.000000 1.000000 ]",
	envmapcontrast = "0.000000",
	rimlightexponent = "0.000000",
	fleshbordersoftness = "0.000000",
	flags_defined = "0",
	fleshsubsurfacetint = "[ 1.000000 1.000000 1.000000 ]",
	flesheffectcenterradius4 = "[ 0.000000 0.000000 0.000000 0.000000 ]",
	flags_defined2 = "0",
	time = "0.000000",
	detailframe = "0",
	rimlightboost = "0.000000",
	refractamount = "0.000000",
	envmaptint = "[ 1.000000 1.000000 1.000000 ]",
	phong = "0",
	selfillumfresnelminmaxexp = "[ 0.000000 0.000000 0.000000 0.000000 ]",
	envmapframe = "0",
	detailtexturetransform = "[ 1.000 0.000 0.000 0.000 0.000 1.000 0.000 0.000 0.000 0.000 1.000 0.000 0.000 0.000 0.000 1.000 ]",
	invertphongmask = "0",
	phongfresnelranges = "[ 0.000000 0.000000 0.000000 ]",
	seamless_scale = "0.000000",
	flashlighttexture = "effects/flashlight_border",
	cloakcolortint = "[ 1.000000 1.000000 1.000000 ]",
	fleshbordernoisescale = "0.000000",
	cloakfactor = "0.000000",
	depthblendscale = "50.000000",
	fleshglobalopacity = "0.000000",
	emissiveblendstrength = "0.000000",
	emissiveblendtint = "[ 1.000000 1.000000 1.000000 ]",
})

local warned = {}

local function get_info(self, key)
	if self.invalid_shader then
		warned[self.shader] = warned[self.shader] or {}
		if not warned[self.shader][key] then
			llog("%s: tried to lookup %s in invalid shader %s", self.name, key, self.shader)
			warned[self.shader][key] = true
		end
		return
	end

	local info = self.params[key]

	if not info then
		warned[self.shader] = warned[self.shader] or {}
		if not warned[self.shader][key] then
			llog("%s: parameter %s not found in shader %s", self.name, key, self.shader)
			warned[self.shader][key] = true
		end
	end

	return info
end

local META = {}
META.__index = META

function META:Set(key, val)
	self.vars[key] = val
end

function META:Get(key)
	return self.vars[key]
end

function META:SetNumber(key, val)
	local info = get_info(self, key)
	if not info then return end

	if info.type == "texture" then
		val = render.GetErrorTexture()
	elseif info.type == "vec2" then
		val = Vec2(val, val)
	elseif info.type == "vec3" then
		val = Vec3(val, val, val)
	elseif info.type == "vec4" or info.type == "color" then
		val = Color(val, val, val, val)
	elseif info.type == "matrix" then
		val = Matrix44()
	end

	self:Set(key, val)
end

function META:GetNumber(key)
	local info = get_info(self, key)
	if not info then return end

	local val = self.vars[key]

	local num

	if not val then return num end

	if info.type == "texture" then
		num = nil
	elseif info.type == "vec2" then
		num = val.x
	elseif info.type == "vec3" then
		num = val.x
	elseif info.type == "vec4" or info.type == "color" then
		num = val.r
	elseif info.type == "matrix" then
		num = val:GetI(0)
	end

	return num
end

function META:SetString(key, val)
	local info = get_info(self, key)
	if not info then return end

	if info.type == "float" or info.type == "int" or info.type == "integer" or info.type == "bool" then
		val = tonumber(val)
	elseif info.type == "texture" then
		if val == "" or val == "error" then
			val = render.GetErrorTexture()
		else
			if key == "basetexture" or key == "basetexture2" or key == "texture" or key == "texture2" then
				val = render.CreateTextureFromPath("[srgb]" .. val)
			else
				val = render.CreateTextureFromPath("[~srgb]" .. val)
			end
		end
	elseif info.type == "vec2" then
		val = val:gsub("%s+", " "):trim()
		local x, y
		if val:startswith("[") then
			x, y = unpack(val:sub(2, -2):split(" "))
			x = tonumber(x) or 0
			y = tonumber(y) or 0
		else
			val = tonumber(val)
			x, y = val, val
		end
		val = Vec2(x,y)
	elseif info.type == "vec3" then
		val = val:gsub("%s+", " "):trim()
		local x, y, z
		if val:startswith("[") then
			x, y, z = unpack(val:sub(2, -2):split(" "))
			x = tonumber(x) or 0
			y = tonumber(y) or 0
			z = tonumber(z) or 0
		else
			val = tonumber(val)
			x, y, z = val, val, val
		end
		val = Vec3(x,y,z)
	elseif info.type == "vec4" or info.type == "color" then
		val = val:gsub("%s+", " "):trim()
		local x, y, z, w
		if val:startswith("[") then
			x, y, z, w = unpack(val:sub(2, -2):split(" "))
			x = tonumber(x) or 0
			y = tonumber(y) or 0
			z = tonumber(z) or 0
			w = tonumber(w) or 0
		else
			val = tonumber(val)
			x, y, z, w = val, val, val, val
		end

		val = Color(x,y,z,w)
	elseif info.type == "matrix" then
		val = val:gsub("%s+", " "):trim()

		local mat = Matrix44()

		if val:startswith("[") then
			local args = val:sub(2, -2):split(" ")
			for i = 1, 16 do
				mat:SetI(i-1, tonumber(args[i]) or 0)
			end
		else
			local center_x, center_y = val:match("center ([%p%d]+) ([%p%d]+)")
			center_x = tonumber(center_x)
			center_y = tonumber(center_y)

			local scale_x, scale_y = val:match("scale ([%p%d]+) ([%p%d]+)")
			scale_x = tonumber(scale_x)
			scale_y = tonumber(scale_y)

			local rotate = val:match("rotate ([%p%d]+)")
			rotate = tonumber(rotate)

			local translate_x, translate_y = val:match("translate ([%p%d]+) ([%p%d]+)")
			translate_x = tonumber(translate_x)
			translate_y = tonumber(translate_y)

			mat:Translate(center_x, center_y, 0)
			mat:Rotate(math.rad(rotate), 0, 1, 0)
			mat:Translate(center_x, center_y, 0)

			mat:Scale(scale_x, scale_y, 1)
			mat:Translate(translate_x, translate_y, 1)
		end

		val = mat
	else
		print(info.type)
	end

	self:Set(key, val)
end

function META:GetString(key)
	local info = get_info(self, key)
	if not info then return end

	local val = self.vars[key]

	local str

	if not val then return str end

	if info.type == "float" or info.type == "int" or info.type == "integer" or info.type == "bool" then
		str = tostring(val)
	elseif info.type == "texture" then
		str = val:GetPath()
	elseif info.type == "vec2" then
		str = ("[%f %f]"):format(val:Unpack())
	elseif info.type == "vec3" then
		str = ("[%f %f %f]"):format(val:Unpack())
	elseif info.type == "vec4" or info.type == "color" then
		str = ("[%f %f %f %f]"):format(val:Unpack())
	elseif info.type == "matrix" then
		str = ("[" .. ("%f "):rep(16) .. "]"):format(val:Unpack())
	end

	return str
end

function META:SetShader(name)
	self.shader = name
	self.params = shaders[name]

	if self.params then
		for k,v in pairs(self.params) do
			if v.default2 then
				self:SetString(k, v.default2)
			end
		end
	else
		llog("tried to create unknown shader %s", name)
		self.invalid_shader = true
	end
end

function gine.CreateMaterial(shader, name)
	local self = setmetatable({}, META)
	self.vars = {}
	self.name = name or "no name"

	if shader then
		self:SetShader(shader)
	end

	return self
end

do
	gine.created_materials = utility.CreateWeakTable()

	function gine.env.CreateMaterial(name, shader, tbl)
		shader = shader:lower()

		if gine.created_materials[name] then
			return gine.created_materials[name]
		end

		local mat = gine.CreateMaterial(shader)
		mat.name = name

		for k,v in pairs(tbl) do
			mat:Set(k:lower():sub(2), v)
		end

		local self = gine.WrapObject(mat, "IMaterial")

		gine.created_materials[name] = self

		return self
	end

	function gine.env.Material(path)
		if gine.created_materials[path:lower()] then
			return gine.created_materials[path:lower()]
		end

		local mat = gine.CreateMaterial()
		mat.name = path

		local self = gine.WrapObject(mat, "IMaterial")

		if path:lower():endswith(".png") then
			if not vfs.IsFile(path) then
				path = "materials/" .. path
			end
			mat:SetShader("unlitgeneric")
			self:SetString("$basetexture", path)
		else
			local vmt_path

			if vfs.IsFile("materials/" .. path .. ".vmt") then
				vmt_path = "materials/" .. path .. ".vmt"
			elseif vfs.IsFile("materials/" .. path) then
				vmt_path = "materials/" .. path
			end

			steam.LoadVMT(vmt_path, function(key, val)
				self:SetString("$" .. key, tostring(val))
			end, nil, function(name) mat:SetShader(name:lower()) end)
		end

		gine.created_materials[path:lower()] = self

		return self
	end

	local META = gine.GetMetaTable("IMaterial")

	function META:GetColor(x,y)
		local r,g,b,a = self:GetTexture("$basetexture").__obj:GetPixelColor(x, y):Unpack()
		return gine.env.Color(r*255, g*255, b*255, a*255)
	end

	function META:GetName()
		return self.__obj.name
	end

	function META:GetShader()
		return self.__obj.shader
	end

	function META:Width()
		return self:GetTexture("$basetexture").__obj:GetSize().x
	end

	function META:Height()
		return self:GetTexture("$basetexture").__obj:GetSize().y
	end

	function META:GetKeyValues()
		return table.copy(self.vars)
	end

	function META:Recompute()

	end

	function META:SetString(key, val)
		key = key:lower():sub(2)
		self.__obj:SetString(key, val)
	end

	function META:GetString(key)
		key = key:lower():sub(2)
		return self.__obj:GetString(key)
	end

	function META:SetFloat(key, val)
		key = key:lower():sub(2)
		self.__obj:SetNumber(key, val)
	end

	function META:GetFloat(key)
		key = key:lower():sub(2)
		return self.__obj:GetNumber(key)
	end

	function META:SetInt(key, val)
		key = key:lower():sub(2)
		self.__obj:SetNumber(key, math.round(val))
	end

	function META:GetInt(key)
		key = key:lower():sub(2)
		return math.round(self.__obj:GetNumber(key))
	end

	function META:SetTexture(key, val)
		key = key:lower():sub(2)
		self.__obj:Set(key, val.__obj)
	end

	function META:GetTexture(key)
		key = key:lower():sub(2)
		local val = self.__obj:Get(key)
		if typex(val) == "texture" then
			return gine.WrapObject(val, "ITexture")
		end
	end

	function META:SetVector(key, val)
		key = key:lower():sub(2)
		self.__obj:Set(key, Vec3(val.x, val.y, val.z))
	end

	function META:GetVector(key)
		key = key:lower():sub(2)
		return gine.env.Vector(self.__obj:Get(key:sub(2)):Unpack())
	end

	function META:IsError()
		return false
	end
end

do
	local surface = gine.env.surface

	function surface.GetTextureID(path)
		if vfs.IsFile("materials/" .. path) then
			if vfs.IsFile("materials/" .. path .. ".vtf") then
				return render.CreateTextureFromPath("materials/" .. path)
			else
				wlog("texture not found %s", path)
			end
		end

		return render.CreateTextureFromPath("materials/" .. path .. ".vtf")
	end

	function surface.SetMaterial(mat)
		render2d.SetTexture(mat:GetTexture("$basetexture").__obj)
	end

	function surface.SetTexture(tex)
		if tex == 0 then tex = render.GetWhiteTexture() end
		render2d.SetTexture(tex)
	end
end

do
	local META = gine.GetMetaTable("ITexture")

	function META:Width()
		return self.__obj.Size.x
	end

	function META:Height()
		return self.__obj.Size.y
	end

	function META:GetColor(x, y)
		local r,g,b,a = self.__obj:GetPixelColor(x, y):Unpack()
		return gine.env.Color(r*255, g*255, b*255, a*255)
	end

	function META:GetName()
		return self.__obj:GetPath()
	end

	function META:IsError()
		return false
	end
end

function gine.env.render.SetMaterial(mat)
	render2d.SetTexture(mat:GetTexture("$basetexture").__obj)
	--render.SetMaterial(mat.__obj)
end
