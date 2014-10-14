window.SetSize(Vec2(1680, 1050))

local parent = gui2.CreatePanel("base")
parent:SetPosition(Vec2(400,140))
parent:SetSize(Vec2(300,300))
local c = HSVToColor(0, 0, 0.25)
parent:SetColor(c)
parent.original_color = c
parent:SetSnapWhileDragging(true)
parent:SetDraggable(true)
parent:SetResizable(true)

for i = 1, 5 do
	local panel = gui2.CreatePanel("base", parent)
	panel:SetPosition(Vec2(50,50))
	panel:SetColor(HSVToColor(math.random(), 1, 1))
	panel.original_color = panel:GetColor()
	panel:SetSize(Vec2(50,50))
	panel:SetSnapWhileDragging(true)
end

local frame = gui2.CreatePanel("base")
frame:SetSize(Vec2(200,200))
frame:SetPosition(Vec2(57,50))
frame:SetDraggable(true)
frame:SetResizable(true)

local c = Color(1,1,1,1) * 0.25
frame:SetColor(c)
frame.original_color = c

frame:SetClipping(true)
frame:SetScrollable(true)
--frame:SetCachedRendering(true)
--frame.OnMouseExit = function() end
--frame.OnMouseEnter = function() end

local lol = {}

for x = 1, 5 do
for y = 1, 5 do
	math.randomseed(x*y)

	local pnl = gui2.CreatePanel("base", frame)

	local c = HSVToColor(math.sin(x+y), 0.65, 1)
	pnl:SetColor(c)
	pnl.original_color = c

	pnl.rand = math.random() > 0.5 and math.randomf(20, 100) or -math.randomf(20, 100)

	pnl:SetPosition(Vec2(x * math.random(30, 80), y * math.random(30, 80)))
	pnl:SetSize(Vec2(80,80) * math.randomf(0.25, 2))
	--pnl:SetAngle(math.random(360))
	pnl:SetCursor("icon")
	pnl:SetTexture(Texture("textures/aahh/gear.png"))
	pnl.OnMouseMove = function(self) self:MarkDirty() end
	pnl.lol = true

	--pnl.OnMouseInput = pnl.RequestFocus

	table.insert(lol, pnl)
end
end

event.AddListener("Update", "lol", function()
	for i, v in ipairs(lol) do
		v:SetAngle(os.clock()*v.rand)
	end
end)

function frame:OnMouseMove(x, y)
	self:MarkDirty()
end

for x = 1, 4 do
for y = 1, 4 do
	math.randomseed(x*y)

	local pnl = gui2.CreatePanel("base")

	local c = HSVToColor(math.sin(x+y), 0.65, 1)
	pnl:SetColor(c)

	pnl:SetPosition(Vec2(-5, 260) + Vec2(x, y) * 55)
	pnl:SetSize(Vec2(50, 50))
	--pnl:SetTexture(Texture("textures/aahh/button.png"))

	if math.random() > 0.5 then
		if math.random() > 0.5 then
			if math.random() > 0.5 then
				pnl.OnClick = function(self)
					self:Animate("Color", {Color(0,0,0,0), "from", Color(1,1,0,1), "from"}, 0.5)
				end
			else
				pnl.OnClick = function(self)
					self:Animate("Color", {Color(1,0,0,1), Color(0,1,0,1),  Color(0,0,1,1), "from"}, 2)
				end
			end
		else
			pnl.OnClick = function(self)
				local duration = 0.2

				self:Animate("DrawSizeOffset", {Vec2(10, 10), function() return input.IsMouseDown("button_1") end, Vec2(0, 0)}, duration, "-")
				self:Animate("DrawPositionOffset", {Vec2(10, 10) * 0.5, function() return input.IsMouseDown("button_1") end, Vec2(0, 0)}, duration, "+")

				--self:Animate("DrawPositionOffset", Vec2(150, 150), 0.5, function(self) self:SetSize(Vec2(50,50)) end)
			end
		end
	else
		if math.random() > 0.5 then
			pnl.OnClick = function(self)
				local duration = 0.6
				self:Animate("Color", {Color(0,0,0,0), "from"}, duration)
				self:Animate("DrawAngleOffset", math.random() > 0.5 and 360 or -360, duration)
			end
		else
			if math.random() > 0.5 then
				pnl.OnClick = function(self)
					local pow = 1
					local duration = 0.5

					self:Animate("DrawSizeOffset", {Vec2(1, -self.Size.h*2), function() return input.IsMouseDown("button_1") end, "from"}, duration, "+", pow)
					self:Animate("DrawPositionOffset", {Vec2(0, self.Size.h), function() return input.IsMouseDown("button_1") end, "from"}, duration, "+", pow)
					self:Animate("Color", {Color(0,0,0,0), function() return input.IsMouseDown("button_1") end, "from"}, duration, "", pow)
				end
			else
				pnl.OnClick = function(self)
					self:Animate("DrawAngleOffset", {math.randomf(-360, 360), "from"}, math.random())
				end
			end
		end
	end
end
end