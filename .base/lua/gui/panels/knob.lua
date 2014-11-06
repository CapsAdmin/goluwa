local PANEL = {}

PANEL.ClassName = "knob"

gui.GetSet(PANEL, "Value", 0)
gui.GetSet(PANEL, "DefaultValue", 0)
 
function PANEL:OnDraw(size)

	if self.drag_pos and gui.IsMouseDown("button_1") then
		local delta = (self.drag_pos - gui.GetMousePosition()) / 100
		
		if input.IsKeyDown("lshift") then
			delta = delta / 5
		end
		
		delta = self.drag_value + delta
		self:SetValue(delta.y)
	else
		self.drag_pos = nil
	end
 
	gui.Draw("rect", Rect(0, 0, size), self:GetSkinColor("dark"), self:GetHeight()/2, 1, self:GetSkinColor("border"))
	
	local pos = self:GetSize() / 2
	
	local limit = 0.125
	local val = math.clamp(self.Value, limit, 2 - limit) - (limit/2)
	gui.Draw("line", pos, pos + Vec2(math.sin(val * math.pi * -2), math.cos(val * math.pi * -2)) * self:GetHeight() / 2.5, self:GetSkinColor("light"))
end

function PANEL:SetValue(num)	
	num = math.clamp(num, 0, 1)

	self.Value = num
		
	self:OnValueChanged(self.Value)
end

function PANEL:OnValueChanged(num) end

function PANEL:OnMouseInput(button, press, pos, ...)
	if button == "mwheel_up" then
		self:SetValue(self.Value + 0.05)
	elseif button == "mwheel_down" then
		self:SetValue(self.Value - 0.05)
	else	
		if press then
			if input.IsKeyDown("lctrl") then
				self:SetValue(self.DefaultValue)
			else
				self.drag_pos = gui.GetMousePosition()
				self.drag_value = self.Value
			end
		end
	end
end

gui.RegisterPanel(PANEL)


do -- label knob
	local PANEL = {}
	
	PANEL.ClassName = "labeled_knob"
	
	gui.GetSet(PANEL, "Min", 0)
	gui.GetSet(PANEL, "Max", 100)
	gui.GetSet(PANEL, "Rounding", 0)
	gui.GetSet(PANEL, "Value", 0)
	
	function PANEL:Initialize()
		local lbl = gui.Create("label", self)
		lbl:SetText("nothing")
		self.left_label = lbl
		
		local knb = gui.Create("knob", self)
		knb.OnValueChanged = function(_, val)
			
			val = math.round(math.lerp(val, self.Min, self.Max), self.Rounding)

			self.Value = val
			
			self:OnValueChanged(val)
			--self.right_label:SetText(val)
			self:OnRequestLayout()
		end
		self.knob = knb
		
		local lbl = gui.Create("label", self)
		self.right_label = lbl
		
		ummm = self
	end
	
	function PANEL:SetValue(num)
		self.Value = num
		
		self.knob:SetValue(num / self.Max)
	end
	
	function PANEL:SetText(str)
		self.left_label:SetText(str)
	end
	
	function PANEL:OnRequestLayout(parent, size)
		local pad = self.NoPadding and 0 or self:GetSkinVar("Padding", 1)

		self.knob:SetPosition(Vec2(0, 0))
		self.knob:SetSize(Vec2() + self:GetHeight())
				
		self.left_label:SetPosition(Vec2(self.knob:GetPosition().x + self.knob:GetWidth() + pad, 0))
		self.left_label:SizeToText()

		self.knob:CenterY()
		self.left_label:CenterY()
	end
	
	function PANEL:OnValueChanged(val)
	
	end
	
	gui.RegisterPanel(PANEL)
end


if false and CAPSADMIN then
	
	
	event.Delay(0.1, function()
		
		local frame = utility.RemoveOldObject(gui.Create("frame"), "asdf")
		frame:SetSize(Vec2() + 500)
		
		local grid = gui.Create("grid", frame)
		grid:Dock("fill")
		
		local chk = gui.Create("checkbox", grid)
		chk:SetSize(Vec2()+10)
		
		for i=1, 20 do
			local pnl = gui.Create("panel")
			pnl:SetSize(Vec2(20, 30) * 2)
			
				local txt = gui.Create("label", pnl)
				txt:Dock("bottom")
				
				local knb = gui.Create("knob", pnl)
				knb:SetSize(Vec2() + 20 * 2)
				knb.OnValueChanged = function(_, val) txt:SetText(math.round(val * 127)) end
				
				knb:SetValue(i/20)
				knb:Dock("top")
				
			pnl:SetParent(grid)
		end
		
	end)  
end 

