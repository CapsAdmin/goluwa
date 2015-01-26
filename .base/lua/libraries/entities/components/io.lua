do
	wire = wire or {}
	wire.current_wires = wire.current_wires or {}
	
	event.AddListener("Draw2D", "draw_wires", function()
		rope = rope or Texture("materials/cable/cable.vtf")
		surface.SetColor(1,1,1,1)
		surface.SetTexture(rope)
			
		if wire.connection_point then
			local a_pos = wire.connection_point:GetWorldPosition() + wire.connection_point:GetSize() / 2
			local b_pos = Vec2(surface.GetMousePosition())
			
			surface.DrawLine(a_pos.x, a_pos.y, b_pos.x, b_pos.y, 2, true)
			
			if input.IsMouseDown("button_2") then
				wire.connection_point = nil
			end
		end
	
		for a, b in pairs(wire.current_wires) do
			if not a:IsValid() then wire.current_wires[a] = nil goto continue end
			if not b:IsValid() then wire.current_wires[a] = nil goto continue end
			
			local a_pos = a:GetWorldPosition() + a:GetSize() / 2
			local b_pos = b:GetWorldPosition() + b:GetSize() / 2
			
			surface.DrawLine(a_pos.x, a_pos.y, b_pos.x, b_pos.y, 2, true)
			
			::continue::
		end
	end)
end

do
	local COMPONENT = {}

	COMPONENT.Name = "io"
	COMPONENT.Events = {"Update"}

	function COMPONENT:OnAdd(ent)
		self.input_connections = {}
		self.output_connections = {}
	
		do
			self.input_values = {}
			
			if type(self.Inputs) == "number" then
				local tbl = {}	
				for i = 1, self.Inputs do tbl[i] = {default = 0} end
				self.Inputs = tbl
			end
					
			if self.Inputs then
				for i, v in ipairs(self.Inputs) do
					self.input_values[i] = v.default
				end
			end
		end
		
		do
			self.output_values = {}
			
			if type(self.Outputs) == "number" then
				local tbl = {}	
				for i = 1, self.Outputs do tbl[i] = {default = 0} end
				self.Outputs = tbl
			end
					
			if self.Outputs then
				for i, v in ipairs(self.Outputs) do
					self.output_values[i] = v.default
				end
			end
		end
	
		if gui then
			local panel = gui.CreatePanel("logic_gate")
			if panel:IsValid() then
				panel:SetGate(self)
				self.panel = panel
			end
		end
		
		if ent:HasParent() and ent.GetIO and ent:GetIO() then
			self.panel:SetParent(ent:GetIO().panel)
		end
	end

	function COMPONENT:OnRemove(ent)
		gui.RemovePanel(self.panel)
	end
	
	function COMPONENT:ComputeInputs() end
	
	function COMPONENT:OnUpdate()
		for i, v in pairs(self.input_connections) do
			self:SetInput(i, v.output:GetOutput(v.output_i))
		end
		
		self:ComputeInputs(self.input_values, self.output_values)
	end
	
	function COMPONENT:SetOutput(i, val)
		self.output_values[i] = val
	end
	
	function COMPONENT:GetOutput(i)
		return self.output_values[i or 1]
	end
	
	
	function COMPONENT:SetInput(i, val)
		self.input_values[i] = val
	end
	
	function COMPONENT:GetInput(i)
		return self.input_values[i or 1]
	end
	

	function COMPONENT.Connect(output, input, input_i, output_i)
		if input.GetIO then input = input:GetIO() end
				
		input_i = input_i or 1
		output_i = output_i or 1
		
		input.input_connections[input_i] = {
			output = output, 
			output_i = output_i,
		}
		
		wire.current_wires[input.panel.inputs[input_i]] = output.panel.outputs[output_i]
	end
	
	function COMPONENT:Disconnect(i)
		i = i or 1
		if self.input_connections[i] then
			self:SetInput(i, self.Inputs[i].default)
			self.input_connections[i] = nil
			return true
		end
	end
	
	function COMPONENT:OnSerialize()
		local out = {}
		
		for i,v in pairs(self.input_connections) do
			out[i] = {
				output = v.output:GetGUID(), 
				output_i = v.output_i,
			}
		end
		
		return out
	end
	
	function COMPONENT:OnDeserialize(tbl)
		for i,v in pairs(tbl) do
			self:WaitForGUID(v.output, function(output)
				output:Connect(self, i, v.output_i)
			end)
		end
	end
	
	function COMPONENT:GetIO()
		return self
	end

	prototype.RegisterComponent(COMPONENT)
end

local function ADD_GATE(name, inputs, outputs, callback, callback2)
	local COMPONENT = {}

	COMPONENT.Name = "gate_" .. name
	COMPONENT.Base = "io"
	
	if callback2 then
		callback2(COMPONENT)
	end

	COMPONENT.Inputs = inputs

	COMPONENT.Outputs = outputs

	COMPONENT.ComputeInputs = callback
	
	prototype.RegisterComponent(COMPONENT)
	prototype.SetupComponents(COMPONENT.Name, {COMPONENT.Name}, "textures/silkicons/plugin_disabled.png", name)
end

do
	ADD_GATE(
		"constant", 
		nil, 1, 
		function(self, i, o) 
			o[1] = self.Value 
		end, 
		function(COMPONENT) 
			prototype.StartStorable(COMPONENT)
				prototype.GetSet("Value", 0)
			prototype.EndStorable()
		end
	)

	ADD_GATE(
		"timer", 
		2, 1, 
		function(self, i, o)
			if i[1] > 0 then
				if not self.start or i[2] > 0 then
					self.start = system.GetElapsedTime()
				end
				o[1] = system.GetElapsedTime() - self.start
			end
		end
	)
	
	local function ADD_2IN1OUT(name, func)
		ADD_GATE(name, 2, 1, function(self, i, o) o[1] = func(i[1], i[2]) end)
	end

	local function ADD_1IN1OUT(name, func)
		ADD_GATE(name, 1, 1, function(self, i, o) o[1] = func(i[1]) end)
	end

	ADD_2IN1OUT("add", function(a, b) return a + b end)
	ADD_2IN1OUT("subtract", function(a, b) return a - b end)
	ADD_2IN1OUT("multiply", function(a, b) return a * b end)
	ADD_2IN1OUT("divide", function(a, b) return a / b end)
	ADD_2IN1OUT("modulus", function(a, b) return a % b end)
	ADD_2IN1OUT("pow", function(a, b) return a ^ b end)
	ADD_2IN1OUT("atan2", math.atan2)
	ADD_2IN1OUT("equal", function(a, b) return a == b and 1 or 0 end)
	ADD_2IN1OUT("not_equal", function(a, b) return a ~= b and 1 or 0 end)
	ADD_2IN1OUT("above", function(a, b) return a > b and 1 or 0 end)
	ADD_2IN1OUT("above_or_equal", function(a, b) return a >= b and 1 or 0 end)
	ADD_2IN1OUT("below", function(a, b) return a < b and 1 or 0 end)
	ADD_2IN1OUT("below_or_equal", function(a, b) return a <= b and 1 or 0 end)
	ADD_2IN1OUT("or", function(a, b) return (a > 0 or b > 0) and 1 or 0 end)

	ADD_1IN1OUT("sin", math.sin)
	ADD_1IN1OUT("cos", math.cos)
	ADD_1IN1OUT("rad", math.cos)
	ADD_1IN1OUT("deg", math.cos)
end