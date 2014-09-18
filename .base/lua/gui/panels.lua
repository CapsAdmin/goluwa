function gui.Create(name, parent, pos)
	if name ~= "base" and (not parent or not parent:IsValid()) then
		parent = gui.GetWorld()
	end
	
	local pnl = metatable.CreateClass("panel", name, "base")
	
	if not pnl then return NULL end
		
	if pnl.__Initialize then
		pnl:__Initialize()
	end
	
	table.insert(gui.active_panels, 1, pnl)
	pnl.aahh_id = #gui.active_panels
	
	if pnl.Initialize then
		pnl:Initialize()
	end
	
	pnl:RequestLayout()
	
	return pnl, pnl:SetParent(parent, pos)
end

function gui.RegisterPanel(META, name)
	META.TypeBase = "base"
	local _, name = metatable.RegisterClass(META, "panel", name)
	
	-- update entity functions only
	-- updating variables might mess things up
	for key, pnl in pairs(gui.active_panels) do
		if pnl.ClassName == name then
			for k, v in pairs(META) do
				if type(v) == "function" then
					pnl[k] = v
				end
			end
		end
	end	
	
	gui["Create" .. ("_" .. name):gsub("_(.)", string.upper)] = function(...)
		return gui.Create(name, ...)
	end
end

function gui.GetRegisteredPanels()
	return metatable.GetRegisteredClasses("panel")
end

function gui.GetPanel(name)
	return metatable.GetRegisteredClass("panel", name)
end

function gui.GetPanels()
	for key, pnl in pairs(gui.active_panels) do
		if not pnl:IsValid() then
			gui.active_panels[key] = nil
		end
	end
	return gui.active_panels
end

function gui.RemoveAllPanels()
	for key, pnl in pairs(gui.GetPanels()) do
		if pnl:IsValid() then
			pnl:Remove()
		end
	end
	gui.active_panels = {}
end

function gui.CallPanelHook(name, ...)
	for key, pnl in pairs(gui.GetPanels()) do
		if pnl[name] then
			pnl[name](pnl, ...)
		end
	end
end

include("base_panel.lua")

include("panels/*")
