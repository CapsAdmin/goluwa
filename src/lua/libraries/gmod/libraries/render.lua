local lib = render
local render = gmod.env.render

function render.GetBloomTex0() return _G.render.GetErrorTexture() end
function render.GetBloomTex1() return _G.render.GetErrorTexture() end
function render.GetScreenEffectTexture() return _G.render.GetErrorTexture() end

function render.PushFilterMin() end
function render.PushFilterMag() end
function render.PopFilterMin() end
function render.PopFilterMag() end

function render.MaxTextureWidth() return 4096 end
function render.MaxTextureHeight() return 4096 end


function render.SuppressEngineLighting(b)

end

function render.SetLightingOrigin()

end

function render.ResetModelLighting()

end

function render.SetColorModulation(r,g,b)

end

function render.SetBlend(a)
	surface.SetAlphaMultiplier(a)
end

function render.SetModelLighting()

end

function render.SetScissorRect(x,y,w,h, b)

end

function render.UpdateScreenEffectTexture()

end

function gmod.env.ScrW() return lib.GetWidth() end
function gmod.env.ScrH() return lib.GetHeight() end

function gmod.env.DisableClipping(b)

end

function render.SupportsPixelShaders_1_4() return true end
function render.SupportsVertexShaders_2_0() return true end
function render.SupportsPixelShaders_2_0() return true end
function render.SupportsHDR() return true end

function render.GetMoBlurTex0()
	return gmod.WrapObject(_G.render.GetErrorTexture(), "ITexture")
end