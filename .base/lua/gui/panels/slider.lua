local PANEL = {}

PANEL.ClassName = "slider"

gui.GetSet(PANEL, "DragPos", Vec2())
gui.GetSet(PANEL, "LockX", false)
gui.GetSet(PANEL, "LockY", false)


function PANEL:Initialize()
	self.DragPos = Vec2()
	
	local drag = gui.Create("draggable", self)
	
	drag:SetTrapInsideParent(true)
	drag:SetObeyMargin(false)
	drag:SetResizingAllowed(false)
		
	drag.CalcBounds = function(s)		
		if self.LockX then
			drag:SetWidth(self:GetWidth() - 2)
		end
				
		self:SetDragPos((drag:GetPos() / (self:GetSize() - drag:GetSize())))
		self:OnDrag(self.DragPos)
	end 
	
	drag.OnDraw = function(s)
		gui.Draw("rect", 
			Rect(Vec2(0,0), Vec2(0, 0) + s:GetHeight()),
			self:GetSkinColor("light2"),
			s:GetHeight() / 2
		)
	end
	
	self.drag = drag
end

function PANEL:OnDraw(size)
	gui.Draw("rect", Rect(0,0,size), self:GetSkinColor("dark"), self:GetHeight() / 2)
end

function PANEL:OnRequestLayout()
	self.drag:CalcBounds()
	self.drag:SetSize(Vec2() + self:GetHeight() - 4)
end

function PANEL:SetDragPos(pos)
	if input.IsKeyDown("lctrl") then
		pos = pos:Round(1)
	end

	self.DragPos = pos
	
	self.drag:SetPos(pos * (self:GetSize() - self.drag:GetSize()))
	
	if self.LockX then
		self.drag:CenterX()
	end
	
	if self.LockY then
		self.drag:CenterY()
	end
end

function PANEL:OnMouseInput(button, press, pos, ...)
	if button == "mwheel_up" then
		pos = self.drag:GetPos()
		pos.y = pos.y - 1
		self:SetDragPos(pos / (self:GetSize() - self.drag:GetSize()))
		self:OnDrag(self.DragPos)
	elseif button == "mwheel_down" then
		pos = self.drag:GetPos()
		pos.y = pos.y + 1
		self:SetDragPos(pos / (self:GetSize() - self.drag:GetSize()))
		self:OnDrag(self.DragPos)
	else	
		if press then
			self:SetDragPos(pos / (self:GetSize() - self.drag:GetSize()))
			self.drag:OnMouseInput(button, press, self.drag:GetSize()/2, ...)
			self:OnDrag(self.DragPos)
		end
	end
end

function PANEL:OnDrag(pos)

end

gui.RegisterPanel(PANEL)

do -- label slider
	local PANEL = {}
	
	PANEL.ClassName = "labeled_slider"
	
	gui.GetSet(PANEL, "Min", 0)
	gui.GetSet(PANEL, "Max", 100)
	gui.GetSet(PANEL, "Rounding", 0)
	gui.GetSet(PANEL, "Value", 0)
	
	function PANEL:Initialize()
		local lbl = gui.Create("label", self)
		lbl:SetText("nothing")
		self.left_label = lbl
		
		local sld = gui.Create("slider", self)
		sld:SetLockY(true)
		sld.OnDrag = function(_, pos)
			local val = pos.x
			
			val = math.round(math.lerp(val, self.Min, self.Max), self.Rounding)

			self.Value = val
			
			self:OnValueChanged(val)
			self.right_label:SetText(val)
			self:OnRequestLayout()
		end
		self.slider = sld
		
		local lbl = gui.Create("label", self)
		self.right_label = lbl
	end
	
	function PANEL:SetValue(num)
		self.Value = num
		
		self.slider:SetDragPos(Vec2(num / self.Max, 0))
	end
	
	function PANEL:SetText(str)
		self.left_label:SetText(str)
	end
	
	function PANEL:OnRequestLayout(parent, size)
		local pad = self.NoPadding and 0 or self:GetSkinVar("Padding", 1)

		self.left_label:SetPos(Vec2(0, 0))
		self.left_label:SizeToText()
		
		self.right_label:SizeToText()
		
		self.slider:SetPos(Vec2(self.left_label:GetWidth() + pad, 0))
		self.slider:SetSize(self:GetSize() - Vec2(30 + self.left_label:GetWidth() + pad, 0))
		
		self.right_label:SetPos(Vec2(self.slider:GetPos().x + self.slider:GetWidth() + pad, 0))
		
		self.slider:CenterY()
		self.left_label:CenterY()
		self.right_label:CenterY()
	end
	
	function PANEL:OnValueChanged(val)
	
	end
	
	gui.RegisterPanel(PANEL)
end