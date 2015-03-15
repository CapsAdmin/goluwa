local gmod = ... or gmod
local render = gmod.env.render

function render.GetBloomTex0() return _G.render.GetErrorTexture() end
function render.GetBloomTex1() return _G.render.GetErrorTexture() end
function render.GetScreenEffectTexture() return _G.render.GetErrorTexture() end

