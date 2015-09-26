local gui = ... or _G.gui

local gate_size = 64
local connection_size = 8
local connection_padding = 2

local PANEL = {}

PANEL.ClassName = "logic_gate"

function PANEL:Initialize()
	self:SetStyle("frame")
	self:SetDraggable(true)
	self:SetSize(Vec2()+gate_size)
	self:SetMouseHoverTimeTrigger(0.1)

	self.inputs = {}
	self.outputs = {}
end

function PANEL:OnMouseHoverTrigger(entered, x, y)
	if entered then
		local tooltip = gui.CreatePanel("text_button")
		tooltip:SetPosition(Vec2(surface.GetMousePosition()))
		tooltip:SetMargin(Rect()+4)
		self.tooltip = tooltip
	else
		gui.RemovePanel(self.tooltip)
		self.tooltip = nil
	end
end

function PANEL:OnUpdate()
	local tooltip = self.tooltip
	if self.tooltip then
		local gate = self.gate

		if not gate then self:Remove() return end -- huh

		local text = gate.Name .. "\n"

		if gate.Inputs then
			text = text .. "inputs:\n"
			for i, v in ipairs(gate.Inputs) do
				text = text .. "\t" .. i .. " = " .. tostring(gate:GetInput(i)) .. "\n"
			end
		end

		if gate.Outputs then
			text = text .. "outputs:\n"
			for i, v in ipairs(gate.Outputs) do
				text = text .. "\t" .. i .. " = " .. tostring(gate:GetOutput(i)) .. "\n"
			end
		end

		text = text:sub(0, -2)

		tooltip:SetText(text)
		tooltip:SizeToText()
		tooltip:Layout(true)
	end
end

function PANEL:OnGlobalMouseInput(button, press)
	local point = self:GetParent().connection_point
	if point then
		local panel = gui.GetHoveringPanel()
		if panel.info and panel.obj then
			self.gate:ConnectToObject(panel.obj, panel.info.var_name, point.i, panel.info.field)
			self:GetParent().connection_point = nil
		end
	end
end

function PANEL:AddInput(i, info)
	local btn = self:CreatePanel("button")
	btn:SetSize(Vec2()+connection_size)

	btn.input = true
	btn.gate = self.gate
	btn.i = i

	btn.OnPress = function()
		local wire = self:GetParent()

		if btn.gate:Disconnect(i) then
			wire.connection_point = wire.current_wires[btn]
			wire.current_wires[btn] = nil
		else
			if wire.connection_point then
				local input = wire.connection_point
				local output = btn

				wire.connection_point = nil

				input.gate:Connect(output.gate, output.i, input.i)
			else
				wire.connection_point = btn
			end
		end
	end

	self.inputs[i] = btn
end

function PANEL:AddOutput(i, info)
	local btn = self:CreatePanel("button")
	btn:SetSize(Vec2()+connection_size)

	btn.output = true
	btn.gate = self.gate
	btn.i = i

	btn.OnPress = function()
		local wire = self:GetParent()

		if wire.connection_point then
			local input = btn
			local output = wire.connection_point

			wire.connection_point = nil

			input.gate:Connect(output.gate, output.i, input.i)
		else
			wire.connection_point = btn
		end
	end

	self.outputs[i] = btn
end

local connection_height = connection_size + connection_padding

function PANEL:OnLayout()
	do
		local count = #self.inputs
		if #self.outputs > count then
			count = #self.outputs
		end
		self:SetHeight(count * connection_height + connection_height)
		self:SetWidth(self:GetHeight())
	end

	local offset = (#self.inputs * connection_height) / 2
	offset = offset - self:GetHeight() / 2

	for i,v in ipairs(self.inputs) do
		i = i - 1
		v:SetY((i * connection_height) - offset)
	end

	local offset = (#self.outputs * connection_height) / 2
	offset = offset - self:GetHeight() / 2

	for i,v in ipairs(self.outputs) do
		i = i - 1
		v:SetY((i * connection_height) - offset)
		v:SetX(self:GetWidth() - v:GetWidth(), (i*10))
	end
end

function PANEL:SetGate(gate)
	if gate.GetIO then gate = gate:GetIO() end

	self.gate = gate
	gate.panel = self

	if gate.Inputs then
		for i,info in ipairs(gate.Inputs) do
			self:AddInput(i, info)
		end
	end

	if gate.Outputs then
		for i,info in ipairs(gate.Outputs) do
			self:AddOutput(i, info)
		end
	end
end

gui.RegisterPanel(PANEL)