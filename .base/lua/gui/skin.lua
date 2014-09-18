gui.Skins = {}

gui.ActiveSkin = NULL

function gui.SkinCall(pnl, func_name, skin, ...)
	skin = skin or gui.ActiveSkin
	
	local func = skin[func_name]

	if func then
		return func(skin, pnl, ...)
	end
end

function gui.SkinDrawHook(pnl, func_name, skin, ...)
	skin = skin or gui.ActiveSkin

	local func = skin[func_name]

	if func then
		return func(skin, pnl, pnl.Colors, ...)
	else
		return skin:DefaultDraw(pnl, pnl.Colors, ...)
	end
end

function gui.SkinLayoutHook(pnl, func_name, skin, ...)
	skin = skin or gui.ActiveSkin

	local func = skin[func_name]

	if func then
		return func(skin, pnl, ...)
	else
		return skin:DefaultLayout(pnl, ...)
	end
end

function gui.GetSkinVar(key, skin)
	skin = skin or gui.ActiveSkin

	return skin[key]
end

function gui.GetSkinColor(key, skin, def)
	skin = skin or gui.ActiveSkin

	return skin.Colors[key] or def or skin.Colors.medium
end

do -- skins
	function gui.UseSkin(name)
		local skin = metatable.CreateDerivedObject("skin", name)
		
		skin.IsValid = function() return true end
		skin.OnThink = skin.OnThink or function(delta) end
		skin.DefaultDraw = skin.DrawDefault or function(panel) end
		skin.DefaultLayout = skin.LayoutDefault or function(panel) end

		gui.ActiveSkin = skin

		if skin.Initialize then
			skin:Initialize()
		end
		
		for k,v in pairs(gui.active_panels) do
			if v.current_skin and v.current_skin.ClassName == name then
				v.current_skin = skin
			end
		end
		
		if gui.World:IsValid() then
			gui.World:RequestLayout()
		end
	end

	function gui.RegisterSkin(META, name)
		local _, name = metatable.Register(META, "skin", name)
		gui.UseSkin(name)
	end

	function gui.GetSkin(name)
		return metatable.GetRegistered("skin", name)
	end
end

include("skins/*")