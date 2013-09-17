function aahh.Create(name, parent, pos)
	if name ~= "base" and (not parent or not parent:IsValid()) then
		parent = aahh.GetWorld()
	end
	
	local pnl = class.Create("panel", name, "base")
	
	if not pnl then return end
	
	for key, val in pairs(pnl) do
		if hasindex(val) and val.Copy then
			pnl[key] = val:Copy()
		end
	end
	
	if pnl.__Initialize then
		pnl:__Initialize()
	end
	
	table.insert(aahh.ActivePanels, 1, pnl)
	pnl.aahh_id = #aahh.ActivePanels
	
	if pnl.Initialize then
		pnl:Initialize()
	end
	
	pnl:RequestLayout()
	
	return pnl, pnl:SetParent(parent, pos)
end

function aahh.RegisterPanel(META, name)
	META.TypeBase = "base"
	class.Register(META, "panel", name)
end

function aahh.GetRegisteredPanels()
	return class.GetAll("panel")
end

function aahh.GetPanel(name)
	return class.Get("panel", name)
end

function aahh.GetPanels()
	for key, pnl in pairs(aahh.ActivePanels) do
		if not pnl:IsValid() then
			aahh.ActivePanels[key] = nil
		end
	end
	return aahh.ActivePanels
end

function aahh.RemoveAllPanels()
	for key, pnl in pairs(aahh.GetPanels()) do
		if pnl:IsValid() then
			pnl:Remove()
		end
	end
	aahh.ActivePanels = {}
end

function aahh.CallPanelHook(name, ...)
	for key, pnl in pairs(aahh.GetPanels()) do
		if pnl[name] then
			pnl[name](pnl, ...)
		end
	end
end

include("base_panel.lua")

include("aahh/panels/*")
