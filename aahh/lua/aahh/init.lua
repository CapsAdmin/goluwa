aahh = {}

aahh.active_panels = aahh.active_panels or {}
aahh.ActivePanel = NULL
aahh.HoveringPanel = NULL
aahh.World = NULL

function aahh.Initialize()
	aahh.UseSkin("default")
	
	aahh.World = aahh.GetWorld()
	
	aahh.initialized = true
	
	event.AddListener("WindowFramebufferResized", "aahh_world", function(window, w,h)
		aahh.World:RequestLayout()
	end)
	
	aahh.World:RequestLayout()
end
 
function aahh.GetWorld()
	if not aahh.World:IsValid() then
		local WORLD = aahh.Create("base")
		WORLD:SetMargin(Rect()+5)
		
		function WORLD:GetSize()
			self.Size = aahh.GetScreenSize()
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
		
		aahh.World = WORLD
	end
	
	return aahh.World
end

 
aahh.IsSet = class.IsSet

function aahh.GetSet(PANEL, name, var, ...) 
	class.GetSet(PANEL, name, var, ...)
	if name:find("Color") then
		PANEL["Set" .. name] = function(self, color) 
			self[name] = self:HandleColor(color) or var
		end 
	end
end

function aahh.Panic()
	for key, pnl in pairs(aahh.active_panels) do
		pnl:Remove()
	end

	aahh.active_panels = {}
end

aahh.LayoutRequests = {}

include("panels.lua")
include("input.lua")
include("drawing.lua")
include("skin.lua")
include("util.lua")

event.AddListener("RenderContextInitialized", "aahh", function()
	aahh.Initialize()

	event.Call("AahhInitialized")
end)