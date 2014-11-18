local gui2 = ... or _G.gui2
local S = gui2.skin.scale

do -- base property
	local PANEL = {}
	
	PANEL.Base = "text_button"
	PANEL.ClassName = "base_property"
	
	prototype.GetSet(PANEL, "DefaultValue")
	
	PANEL.special = NULL
		
	function PANEL:Initialize()
		prototype.GetRegistered(self.Type, "text_button").Initialize(self)
		 
		self:SetActiveStyle("property")
		self:SetInactiveStyle("property")
		self:SetHighlightOnMouseEnter(false)
		self:SetClicksToActivate(2)
		self:SetMargin(Rect())
		self:SetConcatenateTextToSize(true)
	end
	
	function PANEL:SetSpecialCallback(callback)
		prototype.SafeRemove(self.special)
		local special = self:CreatePanel("text_button", "special")
		special:SetText("...")		
		special:SetMode("toggle")
		special.OnStateChanged = function(_, b) callback(b) end
	end
	
	function PANEL:OnLayout()
		if self.special:IsValid() then
			self.special:SetX(self:GetWidth() - self.special:GetWidth())
			self.special:SetSize(Vec2()+self:GetHeight())
			self.special:CenterText()
		end
	end
		
	function PANEL:OnMouseInput(button, press)
		prototype.GetRegistered(self.Type, "button").OnMouseInput(self, button, press)
		
		if press then
			if button == "button_1" then
				self:OnClick()
			elseif button == "button_2" then
				gui2.CreateMenu({
					{"copy", function() system.SetClipboard(self:GetEncodedValue()) end, gui2.skin.icons.copy},
					{"paste", function() self:SetEncodedValue(system.GetClipboard()) end, gui2.skin.icons.paste},
					{},
					{"reset", function() self:SetValue(self:GetDefaultValue()) end, gui2.skin.icons.clear},
				}, self)
			end
		end
	end
	
	function PANEL:OnPress()	
		self:StartEditing()
	end
	
	function PANEL:StartEditing()
		if self.edit then return end
		
		local edit = self:CreatePanel("text_edit", "edit")
		edit:SetText(self:GetEncodedValue())
		edit:SizeToText()
		edit:SetupLayoutChain("fill_x", "fill_y")
		edit:SelectAll()
		edit.OnEnter = function() 
			self:StopEditing()
		end
		
		edit:RequestFocus()
	end
	
	function PANEL:StopEditing()	
		local edit = self.edit
		if edit then
			local str = edit:GetText()
			local val = self:Decode(str)
			
			str = self:Encode(val)
			
			self:SetText(str)
			edit:Remove()
			self:OnValueChanged(val)
			self:OnValueChangedInternal(val)
			
			self.edit = nil
		end
	end
	
	function PANEL:SetValue(val, skip_internal)
		self:SetText(self:Encode(val))
		self.label:SetPosition(Vec2(S*2, S))
		self:OnValueChanged(val)
		if not skip_internal then
			self:OnValueChangedInternal(val)
		end
		--self:SizeToText()
		self:Layout()
	end
	
	function PANEL:GetValue()
		return self:Decode(self:GetText())
	end
	
	function PANEL:GetEncodedValue()
		return self:Encode(self:GetValue() or self:GetDefaultValue())
	end
	
	function PANEL:SetEncodedValue(str)
		self:SetValue(self:Decode(str))
	end
	
	function PANEL:Encode(var)
		return tostring(var)
	end
	
	function PANEL:Decode(str)
		return str
	end 
	
	function PANEL:OnValueChanged(val)
	
	end
	
	function PANEL:OnValueChangedInternal(val)
	
	end
	
	function PANEL:OnClick()
	
	end
	
	gui2.RegisterPanel(PANEL)
end

do -- string
	local PANEL = {}
	
	PANEL.Base = "base_property"
	PANEL.ClassName = "string_property"
		
	function PANEL:Initialize()
		prototype.GetRegistered(self.Type, "base_property").Initialize(self)
		
		self:SetClicksToActivate(1)
	end
	
	gui2.RegisterPanel(PANEL)
end

do -- number
	local PANEL = {}
	
	PANEL.Base = "base_property"
	PANEL.ClassName = "number_property"
	
	prototype.GetSet(PANEL, "Minimum")
	prototype.GetSet(PANEL, "Maximum")
	prototype.GetSet(PANEL, "Sensitivity", 1)
	
	PANEL.slider = NULL
	
	function PANEL:Initialize()
		prototype.GetRegistered(self.Type, "base_property").Initialize(self)
		
		self:SetCursor("sizens")
	end
	
	function PANEL:Decode(str)
		return tonumber(str)
	end
	
	function PANEL:Encode(num)
		return tostring(num)
	end
	
	function PANEL:OnClick()
		self:SetAlwaysCalcMouse(true)
		
		self.drag_number = true
		self.base_value = nil
		self.drag_y_pos = nil
		self.real_base_value = nil
	end
	
	function PANEL:OnPostDraw()
		if self.Minimum and self.Maximum then
			surface.SetWhiteTexture()
			surface.SetColor(0.5,0.75,1,0.5)
			surface.DrawRect(0, 0, self:GetWidth() * math.normalize(self:GetValue(), self.Minimum, self.Maximum), self:GetHeight())
		elseif self.drag_number then
			surface.SetWhiteTexture()
			
			local frac = math.abs((self.real_base_value - self:GetValue())) / 100
			surface.SetColor(1,0.5,0.5,frac)
			
			surface.DrawRect(0, 0, self:GetWidth(), self:GetHeight())
		end
	end
		
	function PANEL:OnUpdate()
		if not self.drag_number then return end
				
		if input.IsKeyDown("left_shift") then
			self:SetValue(self.real_base_value)
			self.base_value = nil
			self.drag_y_pos = nil
		end
		
		if input.IsMouseDown("button_1") then			
			local pos = self:GetMousePosition()
			
			self.base_value = self.base_value or self:GetValue()
			self.real_base_value = self.real_base_value or self.base_value
			
			if not self.base_value then return end
			
			self.drag_y_pos = self.drag_y_pos or pos.y
		
			local sens = self.Sensitivity
			
			if input.IsKeyDown("left_alt") then
				sens = sens / 10
			end
			
			do
				for i, parent in ipairs(self:GetParentList()) do
					if parent.ClassName == "properties" then
						local ppos = self:LocalToWorld(pos)
						if ppos.y > render.GetHeight() then
							local mpos = window.GetMousePosition()
							mpos.y = 4
							window.SetMousePosition(mpos)
							
							self.base_value = nil
							self.drag_y_pos = nil
							return
						elseif ppos.y < 0 then
							local mpos = window.GetMousePosition()
							mpos.y = render.GetHeight()-4
							window.SetMousePosition(mpos)
							
							self.base_value = nil
							self.drag_y_pos = nil
							return
						end
					end
				end

				--if wpos.y > render.GetHeight()
			end
				
			local delta = ((self.drag_y_pos - pos.y) / 10) * sens
			local value = self.base_value + delta
			
			if input.IsKeyDown("left_control") then
				value = math.round(value)
			else
				value = math.round(value, 3)
			end
			
			if self.Minimum then
				value = math.max(value, self.Minimum)
			end
			
			if self.Maximum then
				value = math.min(value, self.Maximum)
			end

			self:SetValue(value)
		else
			self.drag_number = false 
			self:SetAlwaysCalcMouse(false)
		end
	end
	
	gui2.RegisterPanel(PANEL)
end

do -- boolean
	local PANEL = {}
	
	PANEL.Base = "base_property"
	PANEL.ClassName = "boolean_property"
	
	function PANEL:Initialize()
		prototype.GetRegistered(self.Type, "base_property").Initialize(self)

		local panel = self:CreatePanel("button", "panel")
		panel:SetMode("toggle")
		panel:SetActiveStyle("check")
		panel:SetInactiveStyle("uncheck")
		panel.OnStateChanged = function(_, b) self:SetValue(b, true) end
	end
	
	function PANEL:OnLayout()
		prototype.GetRegistered(self.Type, PANEL.Base).OnLayout(self)
		
		self.label:SetX(self.panel:GetWidth() + S)
	end
	
	function PANEL:OnValueChangedInternal(val)
		self.panel:SetState(val)
	end
	
	local str2bool = {
		["true"] = true,
		["false"] = false,
		["1"] = true,
		["0"] = false,
		["yes"] = true,
		["no"] = false,
	}
		
	function PANEL:Decode(str)
		return str2bool[str:lower()]
	end
	
	function PANEL:Encode(b)
		return b and "true" or "false"
	end
	
	gui2.RegisterPanel(PANEL)
end

do -- color
	local PANEL = {}
	
	PANEL.Base = "base_property"
	PANEL.ClassName = "color_property"
	
	function PANEL:Initialize()
		prototype.GetRegistered(self.Type, "base_property").Initialize(self)

		local panel = self:CreatePanel("button", "panel")
		panel:SetStyle("none")
		panel:SetActiveStyle("none")
		panel:SetInactiveStyle("none")
		panel:SetHighlightOnMouseEnter(false)
		panel.OnPress = function()
			local frame = gui2.CreatePanel("frame")
			frame:SetSize(Vec2(300, 300))
			frame:Center()
			frame:SetTitle("color picker")
			
			local picker = frame:CreatePanel("color_picker")
			picker:SetupLayoutChain("fill_x", "fill_y")
			picker.OnColorChanged = function(_, color) self:SetValue(color) end
			
			panel:CallOnRemove(function() gui2.RemovePanel(frame) end)
		end
	end
	
	function PANEL:OnLayout()
		prototype.GetRegistered(self.Type, PANEL.Base).OnLayout(self)
		
		self.panel:SetPosition(Vec2(1,1))
		self.panel:SetSize(Vec2(self:GetHeight(), self:GetHeight())-2)
		self.label:SetX(self.panel:GetWidth() + S)
	end
	
	function PANEL:OnValueChangedInternal(val)
		self.panel:SetColor(val)
	end
	
	function PANEL:Decode(str)
		return ColorBytes(str:match("(%d+)%s-(%d+)%s-(%d+)"))
	end
	
	function PANEL:Encode(color)
		local r,g,b = (color*255):Round():Unpack()
		return ("%d %d %d"):format(r,g,b)
	end
	
	gui2.RegisterPanel(PANEL)
end

local PANEL = {}

PANEL.ClassName = "properties"

PANEL.added_properties = {}

function PANEL:Initialize()
	self:SetStack(true)
	self:SetStackRight(false) 
	self:SetSizeStackToWidth(true)  
	--self:SetStyle("property")
	self:SetColor(gui2.skin.property_background)
	self:SetMargin(Rect())
	
	self:AddEvent("PanelMouseInput")
	
	local divider = self:CreatePanel("divider", "divider")
	divider:SetMargin(Rect())
	divider:SetHideDivider(true)
	divider:SetupLayoutChain("fill_x", "fill_y")
	
	local left = self.divider:SetLeft(gui2.CreatePanel("base"))
	left:SetStack(true)
	left:SetPadding(Rect(0,0,0,-1))
	left:SetStackRight(false)
	left:SetSizeStackToWidth(true)
	--left:SetupLayoutChain("fill_x", "fill_y")
	left:SetNoDraw(true)  
	self.left = left
	
	local right = self.divider:SetRight(gui2.CreatePanel("base"))
	right:SetStack(true)
	right:SetPadding(Rect(0,0,0,-1))
	right:SetStackRight(false)
	right:SetSizeStackToWidth(true)
	--right:SetupLayoutChain("fill_x", "fill_y")
	right:SetNoDraw(true)
	right:SetMargin(Rect())
	self.right = right
end

function PANEL:AddGroup(name)
	local left = self.left:CreatePanel("base")
	left:SetNoDraw(true)
	left.group = true
	--left:SetStyle("property")
	
	local exp = left:CreatePanel("button")
	exp:SetMargin(Rect()+S)
	exp:SetStyle("-")
	exp:SetStyleTranslation("button_active", "+")
	exp:SetStyleTranslation("button_inactive", "-")
	exp:SetPosition(Vec2(S*2, S*2+S))
	exp:SetMode("toggle")
	exp.OnStateChanged = function(_, b)
		local found = false
		for i, panel in ipairs(self.left:GetChildren()) do
			if found then
				if panel.group then break end
				
				self.right:GetChildren()[i]:SetVisible(not b)
				self.right:GetChildren()[i]:SetStackable(not b)
				panel:SetStackable(not b)
				panel:SetVisible(not b)

				self:Layout()
			end
		
			if panel == left then
				found = true
			end
		end
		
		found = false
		
		for i, panel in ipairs(self.left:GetChildren()) do	
			if found then
			
				if panel.expand and not b then
					panel.expand:OnStateChanged(panel.expand:GetState())
				end
				
			end
			
			if panel == left then
				found = true
			end
		end
	end
	
	local label = left:CreatePanel("text")
	label:SetText(name)
	label:SetPosition(Vec2(S*4 + exp:GetWidth(), S*2))
	left:SetHeight(S*10)	
	
	local right = self.right:CreatePanel("base")
	right:SetHeight(S*10)
	right:SetNoDraw(true)
end

function PANEL:AddProperty(name, set_value, get_value, default, extra_info)
	set_value = set_value or print
	get_value = get_value or function() return default end
	extra_info = extra_info or {}
	
	if default == nil then
		default = get_value()
	end
	
	local fields = extra_info.fields
	
	if not fields and hasindex(default) then
		fields = fields or default.Args
		if type(fields[1]) == "table" then
			local temp = {}
			for i,v in ipairs(fields) do
				temp[i] = v[2] or v[1]
			end
			fields = temp
		end
	end
	
	local t = typex(default)
		
	local left_offset = S*8
	
	local left = self.left:CreatePanel("button")
	left:SetStyle("property")
	left:SetDrawPositionOffset(Vec2(left_offset, 0))
	left:SetHeight(S*8-1)	
	left:SetInactiveStyle("property")
	left:SetMode("toggle")
	left.OnStateChanged = function(_, b) left:SetState(b) for i,v in ipairs(self.added_properties) do if v.left ~= left then v.left:SetState(false) end end end
	
	local label = left:CreatePanel("text")
	label:SetText(name)
	label:SetPosition(Vec2(extra_info.__label_offset or S*2, S))
	label:SetIgnoreMouse(true)

	local right = self.right:CreatePanel("base") 
	right:SetMargin(Rect())
	right:SetHeight(left:GetHeight())
	
	local property
	
	if prototype.GetRegistered("panel2", t .. "_property") then
		local panel = right:CreatePanel(t .. "_property")
					
		panel:SetValue(default)
		panel:SetDefaultValue(default)
		panel.GetValue = get_value
		panel.OnValueChanged = function(_, val) set_value(val) end
		panel:SetupLayoutChain("fill_x", "fill_y")
		panel.left = left
		property = panel
		
		if t == "number" then
			if extra_info.editor_min then
				panel:SetMinimum(extra_info.editor_min)
			end
			
			if extra_info.editor_max then
				panel:SetMaximum(extra_info.editor_max)
			end
			
			if extra_info.editor_sens then
				panel:SetMaximum(extra_info.max)
			end
		end
				
		right:SetWidth(panel.label:GetWidth())
				
		table.insert(self.added_properties, panel)
	else
		local panel = right:CreatePanel("base_property")
				
		function panel:Decode(str)
			local val = serializer.Decode("luadata", str)[1]
			
			if typex(val) ~= t then
				val = default
			end
			
			return val
		end
		
		function panel:Encode(val)
			return serializer.Encode("luadata", val)
		end
				
		panel:SetValue(default)
		panel:SetDefaultValue(default)
		panel.GetValue = get_value
		panel.OnValueChanged = function(_, val) set_value(val) end
		panel:SetupLayoutChain("fill_x", "fill_y")
		panel.left = left
		property = panel
		
		right:SetWidth(panel.label:GetWidth())
		
		table.insert(self.added_properties, panel)
	end
	
	if fields then
		local exp = left:CreatePanel("button", "expand")
		exp:SetMargin(Rect()+S)
		exp:SetStyleTranslation("button_active", "+")
		exp:SetStyleTranslation("button_inactive", "-")
		exp:SetState(true)
		exp:SetPosition(Vec2(S*2, S*2-1))
		exp:SetMode("toggle")
		label:SetX(S*4 + exp:GetWidth())
		
		local panels = {}
		
		exp.OnStateChanged = function(_, b)
			for i, panel in ipairs(panels) do
				panel.right:SetVisible(not b)
				panel.right:SetStackable(not b)
				
				panel.left:SetStackable(not b)
				panel.left:SetVisible(not b)
					
			end
			self:Layout()
		end
		
		for i, key in ipairs(fields) do
			local left, right = self:AddProperty(
				key, 
				function(val_)
					local val = property:GetValue()
					val[key] = val_
					property:SetValue(val)
				end, 
				function()
					return property:GetValue()[key]
				end,
				default[key],
				{
					__label_offset = label:GetX(),
				}
			)
			
			left:SetStackable(false)
			right:SetStackable(false)
			
			left:SetVisible(false)
			right:SetVisible(false)
			
			table.insert(panels, {left = left, right = right})
		end			
	end	
	
	self.left_max_width = math.max((self.left_max_width or 0), label:GetWidth() + label:GetX()*2)
	self.right_max_width = math.max((self.right_max_width or 0), right:GetWidth()+ label:GetX()+S*2)
			
	self.divider:SetDividerPosition(self.left_max_width + left_offset)	
	
	self:Layout()
	
	return left, right
end

function PANEL:OnLayout()	
	if not self.left_max_width then return end
	
	local h = self.left:GetSizeOfChildren().h
	self.divider:SetSize(Vec2(self.left_max_width + self.right_max_width, h))
	self:SetWidth(self.left_max_width + self.right_max_width)
	self:SetHeight(h)
end

function PANEL:OnPanelMouseInput(panel, button, press)
	if press and button == "button_1" and panel.ClassName:find("_property") then
		for i, right in ipairs(self.added_properties) do
			if panel ~= right then
				right:StopEditing()
			end
		end
	end
end

function PANEL:AddPropertiesFromObject(obj)	
	for _, info in ipairs(prototype.GetStorableVariables(obj)) do		
		local get = obj[info.get_name]
		local set = obj[info.set_name]
		local def = get(obj)
		
		local nice_name
		
		if info.var_name:upper() == info.var_name then
			nice_name = info.var_name:lower()
		else
			nice_name = info.var_name:gsub("%u", " %1"):lower():sub(2)
		end		
				
		self:AddProperty(
			nice_name, 
			function(val)
				if obj:IsValid() then				
					set(obj, val)
				end
			end, 
			function() 
				if obj:IsValid() then 
					return get(obj)
				end
			end, 
			def,
			info
		)
	end
end

gui2.RegisterPanel(PANEL)