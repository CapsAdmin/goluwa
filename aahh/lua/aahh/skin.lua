aahh.Skins = {}

aahh.ActiveSkin = NULL

function aahh.SkinCall(pnl, func_name, skin, ...)
	skin = skin or aahh.ActiveSkin
	
	local func = skin[func_name]

	if func then
		return func(skin, pnl, ...)
	end
end

function aahh.SkinDrawHook(pnl, func_name, skin, ...)
	skin = skin or aahh.ActiveSkin

	local func = skin[func_name]

	if func then
		return func(skin, pnl, pnl.Colors, ...)
	else
		return skin:DefaultDraw(pnl, pnl.Colors, ...)
	end
end

function aahh.SkinLayoutHook(pnl, func_name, skin, ...)
	skin = skin or aahh.ActiveSkin

	local func = skin[func_name]

	if func then
		return func(skin, pnl, ...)
	else
		return skin:DefaultLayout(pnl, ...)
	end
end

function aahh.GetSkinVar(key, skin)
	skin = skin or aahh.ActiveSkin

	return skin[key]
end

function aahh.GetSkinColor(key, skin, def)
	skin = skin or aahh.ActiveSkin

	return skin.Colors[key] or def or skin.Colors.medium
end

do -- skins
	function aahh.UseSkin(name)
		local skin = class.Create("skin", name)
		
		skin.IsValid = function() return true end
		skin.OnThink = skin.OnThink or function(delta) end
		skin.DefaultDraw = skin.DrawDefault or function(panel) end
		skin.DefaultLayout = skin.LayoutDefault or function(panel) end

		aahh.ActiveSkin = skin

		if skin.Initialize then
			skin:Initialize()
		end
		
		for k,v in pairs(aahh.active_panels) do
			if v.Skin and v.Skin.ClassName == name then
				v.Skin = skin
			end
		end
		
		if aahh.World:IsValid() then
			aahh.World:RequestLayout()
		end
	end

	function aahh.RegisterSkin(META, name)
		local _, name = class.Register(META, "skin", name)
		aahh.UseSkin(name)
	end

	function aahh.GetSkin(name)
		return class.Get("skin", name)
	end
end

include("aahh/skins/*")