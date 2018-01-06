if not GRAPHICS then return end

local render = ... or _G.render

local vl = system.GetFFIBuildLibrary("VTFLib")

if not vl then return end

vl.Initialize()

render.AddTextureDecoder("vtflib", function(data, path_hint)
	return vl.LoadImage(data, path_hint)
end)