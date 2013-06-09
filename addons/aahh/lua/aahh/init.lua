include("platform_specific/graphics.lua")

aahh = {}

aahh.ActivePanels = aahh.ActivePanels or {}
aahh.ActivePanel = NULL
aahh.HoveringPanel = NULL
aahh.World = NULL
aahh.Stats = 
{
	layout_count = 0
}

function aahh.StartDraw(pnl)
	if not pnl:IsValid() then return end
		
	graphics.SetTranslation(pnl:GetWorldPos())
end

function aahh.EndDraw(pnl)	
	graphics.SetTranslation(Vec2())
end

function aahh.Draw(delta)
	if aahh.ActiveSkin then
		aahh.ActiveSkin.FT = delta
		aahh.ActiveSkin:Think(delta)
	end
	if aahh.World:IsValid() then
		aahh.World:Draw()
	end
	
	if aahh.HoveringPanel:IsValid() then
		aahh.SetCursor(aahh.HoveringPanel:GetCursor())
	else
		aahh.SetCursor(1)
	end
end

function aahh.Initialize()
	aahh.UseSkin("default")
	
	local WORLD = aahh.Create("base")
		WORLD:SetMargin(Rect()+5)
		
		function WORLD:GetSize()
			self.Size = graphics.GetScreenSize()
			return self.Size
		end
		
		function WORLD:GetPos()
			self.Pos = Vec2(0, 0)
			return self.Pos
		end
		
		WORLD:SetCursor(1)
		
	aahh.World = WORLD
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
	for key, pnl in pairs(aahh.ActivePanels) do
		pnl:Remove()
	end

	aahh.ActivePanels = {}
end

aahh.LayoutRequests = {}

include("panels.lua")
include("input.lua")
include("platform_specific/actions.lua")
include("skin.lua")
include("util.lua")

aahh.Initialize()

event.Call("AahhInitialized")

include("unit_test.lua")