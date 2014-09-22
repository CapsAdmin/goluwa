gui = {}

gui.active_panels = gui.active_panels or {}
gui.ActivePanel = NULL
gui.HoveringPanel = NULL
gui.World = NULL

function gui.Initialize()
	gui.UseSkin("default")
	
	gui.World = gui.GetWorld()
	
	gui.initialized = true
	
	event.AddListener("WindowFramebufferResized", "aahh_world", function(window, w,h)
		gui.World:RequestLayout()
	end)
	
	gui.World:RequestLayout()
end
 
function gui.GetWorld()
	if not gui.World:IsValid() then
		local WORLD = gui.Create("base")
		WORLD:SetMargin(Rect()+5)
		
		function WORLD:GetSize()
			self.Size = gui.GetScreenSize()
			return self.Size
		end
		
		function WORLD:GetPos()
			self.Pos = Vec2(0, 0)
			return self.Pos
		end
		
		function WORLD:OnRequestLayout()
			event.Call("WorldPanelLayout")
		end
		
		WORLD:SetCursor("arrow")
		
		gui.World = WORLD
	end
	
	return gui.World
end

 
gui.IsSet = prototype.IsSet

function gui.GetSet(PANEL, name, var, ...) 
	prototype.GetSet(PANEL, name, var, ...)
	if name:find("Color") then
		PANEL["Set" .. name] = function(self, color) 
			self[name] = self:HandleColor(color) or var
		end 
	end
end

function gui.Panic()
	for key, pnl in pairs(gui.active_panels) do
		pnl:Remove()
	end

	gui.active_panels = {}
end

gui.LayoutRequests = {}

include("panels.lua")
include("input.lua")
include("drawing.lua")
include("skin.lua")
include("util.lua")

event.AddListener("RenderContextInitialized", "gui", function()
	gui.Initialize()

	event.Call("AahhInitialized")
end)