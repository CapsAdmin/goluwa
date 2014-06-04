function aahh.Create(name, parent, pos)
	if name ~= "base" and (not parent or not parent:IsValid()) then
		parent = aahh.GetWorld()
	end
	
	local pnl = class.Create("panel", name, "base")
	
	if not pnl then return NULL end
		
	if pnl.__Initialize then
		pnl:__Initialize()
	end
	
	table.insert(aahh.active_panels, 1, pnl)
	pnl.aahh_id = #aahh.active_panels
	
	if pnl.Initialize then
		pnl:Initialize()
	end
	
	pnl:RequestLayout()
	
	return pnl, pnl:SetParent(parent, pos)
end

function aahh.RegisterPanel(META, name)
	META.TypeBase = "base"
	local _, name = class.Register(META, "panel", name)
	
	-- update entity functions only
	-- updating variables might mess things up
	for key, pnl in pairs(aahh.active_panels) do
		if pnl.ClassName == name then
			for k, v in pairs(META) do
				if type(v) == "function" then
					pnl[k] = v
				end
			end
		end
	end	
	
	aahh["Create" .. ("_" .. name):gsub("_(.)", string.upper)] = function(...)
		return aahh.Create(name, ...)
	end
end

function aahh.GetRegisteredPanels()
	return class.GetAll("panel")
end

function aahh.GetPanel(name)
	return class.Get("panel", name)
end

function aahh.GetPanels()
	for key, pnl in pairs(aahh.active_panels) do
		if not pnl:IsValid() then
			aahh.active_panels[key] = nil
		end
	end
	return aahh.active_panels
end

function aahh.RemoveAllPanels()
	for key, pnl in pairs(aahh.GetPanels()) do
		if pnl:IsValid() then
			pnl:Remove()
		end
	end
	aahh.active_panels = {}
end

function aahh.CallPanelHook(name, ...)
	for key, pnl in pairs(aahh.GetPanels()) do
		if pnl[name] then
			pnl[name](pnl, ...)
		end
	end
end

include("base_panel.lua")

include("panels/*")
