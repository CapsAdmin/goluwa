local gui = ... or _G.gui
local expand_memory = {}

do -- base property
	local META = prototype.CreateTemplate("base_property")
	META.Base = "text_button"
	META:GetSet("DefaultValue")

	function META:Initialize()
		self.special = NULL
		prototype.GetRegistered(self.Type, META.Base).Initialize(self)
		self:SetActiveStyle("property")
		self:SetInactiveStyle("property")
		self:SetHighlightOnMouseEnter(false)
		self:SetClicksToActivate(2)
		self:SetMouseHoverTimeTrigger(0.25)
	end

	function META:SetSpecialCallback(callback)
		prototype.SafeRemove(self.special)
		local special = self:CreatePanel("text_button", "special")
		special:SetText("...")
		special:SizeToText()
		special:SetupLayout("center_right")
		special:SetMode("toggle")
		special.OnStateChanged = function(_, b)
			callback(b)
		end
	end

	function META:OnLayout(S)
		self.label:SetPadding(Rect() + S)
	end

	function META:OnUpdate()
		if self.edit then return end

		local val = self:GetValue()

		if val ~= self.last_value then
			self:SetText(self:Encode(val))
			self.last_value = val
		end
	end

	function META:OnMouseInput(button, press)
		prototype.GetRegistered(self.Type, "button").OnMouseInput(self, button, press)

		if press then
			if button == "button_1" then
				self:OnClick()
			elseif button == "button_2" then
				local option

				if PROPERTY_LINK_INFO then
					option = {
						L("link to property"),
						function()
							local info = PROPERTY_LINK_INFO
							prototype.AddPropertyLink(
								info.obj,
								self.obj,
								info.info.var_name,
								self.info.var_name,
								info.info.field,
								self.info.field
							)
							PROPERTY_LINK_INFO = nil
						end,
						"textures/silkicons/link.png",
					}
				else
					option = {
						L("link"),
						function()
							PROPERTY_LINK_INFO = {obj = self.obj, info = self.info}
						end,
						"textures/silkicons/link_add.png",
					}
				end

				gui.CreateMenu(
					{
						{
							L("copy"),
							function()
								window.SetClipboard(self:GetEncodedValue())
							end,
							self:GetSkin().icons.copy,
						},
						{
							L("paste"),
							function()
								self:SetEncodedValue(window.GetClipboard())
							end,
							self:GetSkin().icons.paste,
						},
						{},
						option,
						{
							L("remove links"),
							function()
								prototype.RemovePropertyLinks(self.obj)
							end,
							"textures/silkicons/link_break.png",
						},
						{},
						{
							L("reset"),
							function()
								self:SetValue(self:GetDefaultValue())
							end,
							self:GetSkin().icons.clear,
						},
					},
					self
				)
			end
		end
	end

	function META:OnPress()
		self:StartEditing()
	end

	function META:StartEditing()
		if self.edit then return end

		local edit = self:CreatePanel("text_edit", "edit")
		edit:SetText(self:GetEncodedValue())
		edit:SetSize(self:GetSize())
		edit.OnLayout = function(self, S)
			self.label:SetPadding(Rect() + S)
		end
		edit.OnEnter = function()
			self:StopEditing()
		end
		local old = edit.OnKeyInput
		edit.OnKeyInput = function(_, key, press)
			if key == "escape" then self:CancelEditing() end

			return old(_, key, press)
		end
		edit:RequestFocus()
		edit:SelectAll()
	end

	function META:StopEditing()
		local edit = self.edit

		if edit then
			local str = edit:GetText()
			local val = self:Decode(str)
			str = self:Encode(val)
			self:SetText(str)
			edit:Remove()
			self:SetValue(val)
			self.edit = nil
		end
	end

	function META:CancelEditing()
		local edit = self.edit

		if edit then
			edit:Remove()
			self.edit = nil
		end
	end

	function META:SetValue(val, skip_internal)
		self:SetText(self:Encode(val))
		self:OnValueChanged(val)

		if not skip_internal then self:OnValueChangedInternal(val) end

		--self:SizeToText()
		self.label:SetupLayout("center_left")
		self:Layout()
		self.tooltip_text = self:GetEncodedValue()
	end

	function META:GetValue()
		local val = self:Decode(self:GetText())

		if val == nil then return self:GetDefaultValue() end

		return val
	end

	function META:GetEncodedValue()
		return self:Encode(self:GetValue() or self:GetDefaultValue())
	end

	function META:SetEncodedValue(str)
		self:SetValue(self:Decode(str))
	end

	function META:Encode(var)
		return tostring(var)
	end

	function META:Decode(str)
		return str
	end

	function META:OnValueChanged(val) end

	function META:OnValueChangedInternal(val) end

	function META:OnClick() end

	gui.RegisterPanel(META)
end

do -- string
	local META = prototype.CreateTemplate("string_property")
	META.Base = "base_property"

	function META:Initialize()
		prototype.GetRegistered(self.Type, META.Base).Initialize(self)
		self:SetClicksToActivate(1)
	end

	function META:OnSystemFileDrop(path)
		self:SetValue(path)
	end

	gui.RegisterPanel(META)
end

do -- choice
	local META = prototype.CreateTemplate("choice_property")
	META.Base = "base_property"

	function META:Initialize()
		prototype.GetRegistered(self.Type, META.Base).Initialize(self)
		self:SetClicksToActivate(2)
		local icon = self:CreatePanel("base")
		icon:SetIgnoreMouse(true)
		icon:SetStyle("list_down_arrow")
		icon:SetupLayout("left", "right", "center_y_simple")
	end

	function META:OnClick()
		local menu = gui.CreateMenu(self.choices)
		menu:SetPosition(self:GetWorldPosition() + Vec2(0, self:GetHeight()))
	end

	function META:SetChoices(tbl)
		local menu_options = {}

		if type(tbl[1]) == "string" then
			for _, v in ipairs(tbl) do
				list.insert(menu_options, {
					v,
					function()
						self:SetValue(v)
					end,
				})
			end
		elseif not list.is_list(tbl) then
			for k, v in pairs(tbl) do
				list.insert(
					menu_options,
					{
						v.friendly or
						k,
						function()
							self:SetValue(k)
						end,
						v.icon_path,
					}
				)
			end

			list.sort(menu_options, function(a, b)
				return a[1] < b[1]
			end)
		end

		self.choices = menu_options
	end

	gui.RegisterPanel(META)
end

do -- number
	local META = prototype.CreateTemplate("number_property")
	META.Base = "base_property"
	META:GetSet("Minimum")
	META:GetSet("Maximum")
	META:GetSet("Sensitivity", 1)
	META.slider = NULL

	function META:Initialize()
		prototype.GetRegistered(self.Type, META.Base).Initialize(self)
		self:SetCursor("sizens")
	end

	function META:Decode(str)
		return tonumber(str)
	end

	function META:Encode(num)
		return tostring(num)
	end

	function META:OnClick()
		self:SetAlwaysCalcMouse(true)
		self.drag_number = true
		self.base_value = nil
		self.drag_y_pos = nil
		self.real_base_value = nil --self:GetDefaultValue()
	end

	function META:OnPostDraw()
		if self.Minimum and self.Maximum then
			render2d.SetTexture()
			render2d.SetColor(0.5, 0.75, 1, 0.5)
			render2d.DrawRect(
				0,
				0,
				self:GetWidth() * math.normalize(self:GetValue(), self.Minimum, self.Maximum),
				self:GetHeight()
			)
		elseif self.drag_number and self.real_base_value then
			render2d.SetTexture()
			local frac = math.abs((self.real_base_value - self:GetValue())) / 100
			render2d.SetColor(1, 0.5, 0.5, frac)
			render2d.DrawRect(0, 0, self:GetWidth(), self:GetHeight())
		end
	end

	function META:OnUpdate()
		prototype.GetRegistered(self.Type, META.Base).OnUpdate(self)

		if not self.drag_number then return end

		if input.IsKeyDown("left_shift") and self.real_base_value then
			self:SetValue(self.real_base_value)
			self.base_value = nil
			self.drag_y_pos = nil
		end

		if input.IsMouseDown("button_1") then
			local pos = window.GetMousePosition()
			self.base_value = self.base_value or self:GetValue()
			self.real_base_value = self.real_base_value or self.base_value

			if not self.base_value then return end

			self.drag_y_pos = self.drag_y_pos or pos.y
			local sens = self.Sensitivity

			if input.IsKeyDown("left_alt") then sens = sens / 10 end

			do
				for i, parent in ipairs(self:GetParentList()) do
					if parent.ClassName == "properties" then
						if pos.y > render.GetHeight() - 4 then
							local mpos = window.GetMousePosition()
							mpos.y = 8
							window.SetMousePosition(mpos)
							self.base_value = nil
							self.drag_y_pos = nil
							return
						elseif pos.y < 4 then
							local mpos = window.GetMousePosition()
							mpos.y = render.GetHeight() - 8
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

			if self.Minimum then value = math.max(value, self.Minimum) end

			if self.Maximum then value = math.min(value, self.Maximum) end

			self:SetValue(value)
		else
			self.drag_number = false
			self:SetAlwaysCalcMouse(false)
		end
	end

	gui.RegisterPanel(META)
end

do -- boolean
	local META = prototype.CreateTemplate("boolean_property")
	META.Base = "base_property"

	function META:Initialize()
		local panel = self:CreatePanel("button", "panel")
		panel:SetMode("toggle")
		panel:SetActiveStyle("check")
		panel:SetInactiveStyle("uncheck")
		panel:SetupLayout("center_left")
		panel.OnStateChanged = function(_, b)
			self:SetValue(b, true)
		end
		prototype.GetRegistered(self.Type, META.Base).Initialize(self)
	end

	function META:OnValueChangedInternal(val)
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

	function META:Decode(str)
		return str2bool[str:lower()] or false
	end

	function META:Encode(b)
		return b and "true" or "false"
	end

	function META:OnLayout(S)
		prototype.GetRegistered(self.Type, META.Base).OnLayout(self, S)
		self.panel:SetPadding(Rect() + S)
	end

	gui.RegisterPanel(META)
end

do -- color
	local META = prototype.CreateTemplate("color_property")
	META.Base = "base_property"

	function META:Initialize()
		local panel = self:CreatePanel("button", "panel")
		panel:SetStyle("none")
		panel:SetActiveStyle("none")
		panel:SetInactiveStyle("none")
		panel:SetHighlightOnMouseEnter(false)
		panel:SetupLayout("center_left")
		panel.OnPress = function()
			local frame = gui.CreatePanel("frame")
			frame:SetSize(Vec2(300, 300))
			frame:SetTitle("color picker")
			local picker = frame:CreatePanel("color_picker")
			picker:SetupLayout("fill")
			picker.OnColorChanged = function(_, color)
				self:SetValue(color)
			end
			picker:SetColor(self:GetValue())

			panel:CallOnRemove(function()
				gui.RemovePanel(frame)
			end)

			frame:CenterSimple()
		end
		prototype.GetRegistered(self.Type, "base_property").Initialize(self)
	end

	function META:OnValueChangedInternal(val)
		self.panel:SetColor(val)
	end

	function META:Decode(str)
		return ColorBytes(str:match("(%d+)%s-(%d+)%s-(%d+)"))
	end

	function META:Encode(color)
		local r, g, b = (color * 255):Round():Unpack()
		return ("%d %d %d"):format(r, g, b)
	end

	function META:OnLayout(S)
		prototype.GetRegistered(self.Type, META.Base).OnLayout(self, S)
		self.panel:SetLayoutSize(Vec2(S * 8, S * 8) - S * 2)
		self.panel:SetPadding(Rect() + S * 2)
	end

	gui.RegisterPanel(META)
end

do -- texture
	local META = prototype.CreateTemplate("texture_property")
	META.Base = "base_property"

	function META:Initialize()
		local panel = self:CreatePanel("button", "panel")
		panel:SetStyle("none")
		panel:SetActiveStyle("none")
		panel:SetInactiveStyle("none")
		panel:SetHighlightOnMouseEnter(false)
		panel:SetupLayout("center_left")
		panel.OnPress = function()
			local frame = gui.CreatePanel("frame")
			frame:SetSize(Vec2(300, 300))
			frame:SetTitle("texture")
			local image = frame:CreatePanel("base")
			image:SetTexture(self:GetValue())
			image:SetupLayout("fill")

			panel:CallOnRemove(function()
				gui.RemovePanel(frame)
			end)

			frame:CenterSimple()
		end
		prototype.GetRegistered(self.Type, "base_property").Initialize(self)
	end

	function META:OnSystemFileDrop(path)
		self:SetValue(render.CreateTextureFromPath(path))
	end

	function META:OnValueChangedInternal(val)
		self.panel:SetTexture(val)
	end

	function META:Decode(str)
		return render.CreateTextureFromPath(str)
	end

	function META:Encode(tex)
		return tex:GetPath()
	end

	function META:OnLayout(S)
		prototype.GetRegistered(self.Type, META.Base).OnLayout(self, S)
		self.panel:SetLayoutSize(Vec2(S * 8, S * 8) - S * 2)
		self.panel:SetPadding(Rect() + S)
	end

	gui.RegisterPanel(META)
end

local META = prototype.CreateTemplate("properties")

function META:Initialize()
	self.added_properties = {}
	self:SetStack(true)
	self:SetStackRight(false)
	self:SetSizeStackToWidth(true)
	self:SetStyle("frame")
	self:AddEvent("PanelMouseInput")
	local divider = self:CreatePanel("divider", "divider")
	divider:SetHideDivider(true)
	divider:SetupLayout("fill")
	local left = self.divider:SetLeft(gui.CreatePanel("base"))
	left:SetStack(true)
	left:SetStackRight(false)
	left:SetSizeStackToWidth(true)
	--left:SetupLayout("fill")
	left:SetNoDraw(true)
	self.left = left
	local right = self.divider:SetRight(gui.CreatePanel("base"))
	right:SetStack(true)
	right:SetStackRight(false)
	right:SetSizeStackToWidth(true)
	--right:SetupLayout("fill")
	right:SetNoDraw(true)
	self.right = right
end

function META:AddGroup(name)
	local left = self.left:CreatePanel("base")
	left:SetNoDraw(true)
	left.is_group = true
	--left:SetStyle("property")
	local exp = left:CreatePanel("button", "expand")
	exp:SetState(true)
	exp:SetMode("toggle")
	exp:SetStyleTranslation("button_active", "-")
	exp:SetStyleTranslation("button_inactive", "+")
	exp:SetupLayout("center_left")
	exp.state_key = name
	exp.OnStateChanged = function(_, b)
		for i, panel in ipairs(self.left:GetChildren()) do
			if panel.group == left then
				self.right:GetChildren()[i]:SetVisible(b)
				self.right:GetChildren()[i]:SetStackable(b)
				panel:SetStackable(b)
				panel:SetVisible(b)
				self:Layout()
			end
		end

		if b then
			for i, panel in ipairs(self.left:GetChildren()) do
				if panel.group == left and panel.expand then
					local b = panel.expand:GetState()
					panel.expand:SetState(b)
					panel.expand:OnStateChanged(b)
				end
			end
		end

		expand_memory[exp.state_key] = b
	end
	local label = left:CreatePanel("text", "label")
	label:SetText(name)
	label:SetupLayout("center_left")
	local right = self.right:CreatePanel("base")
	right.is_group = true
	right:SetNoDraw(true)
	self.current_group = left
end

function META:AddProperty(name, set_value, get_value, default, extra_info, obj)
	set_value = set_value or print
	get_value = get_value or function()
		return default
	end
	extra_info = extra_info or {}

	if default == nil then default = get_value() end

	local fields = extra_info.fields

	if not fields and has_index(default) then
		fields = fields or default.Args

		if fields then
			if type(fields[1]) == "table" then
				local temp = {}

				for i, v in ipairs(fields) do
					temp[i] = v[1]
				end

				fields = temp
			end
		end
	end

	local t = typex(default)
	local property
	self.left_offset = 8
	local left = self.left:CreatePanel("button")
	left:SetStyle("property")
	left.left_offset = self.left_offset
	left:SetInactiveStyle("property")
	left.MouseInput = function(_, ...)
		property:MouseInput(...)
	end
	left.group = self.current_group
	local exp

	if fields then
		exp = left:CreatePanel("button", "expand")
		exp:SetState(false)
		exp:SetMode("toggle")
		exp:SetStyleTranslation("button_active", "-")
		exp:SetStyleTranslation("button_inactive", "+")
		exp:SetupLayout("center_left")
		exp.state_key = name
	end

	local label = left:CreatePanel("text", "label")
	label:SetText(name)
	label.label_offset = extra_info.__label_offset
	label:SetIgnoreMouse(true)
	label:SetupLayout("center_left")
	local right = self.right:CreatePanel("base")
	right:SetWidth(500)

	if t == "string" then
		if extra_info.table or extra_info.list then t = "choice" end
	end

	if prototype.GetRegistered("panel", t .. "_property") then
		local panel = right:CreatePanel(t .. "_property", "property")
		panel:SetValue(default)
		panel:SetDefaultValue(extra_info.default or default)
		panel.GetValue = get_value
		panel.OnValueChanged = function(_, val)
			set_value(val)
			local new = get_value()

			if new ~= val then panel:SetValue(new) end
		end
		panel:SetupLayout("fill")
		panel.left = left
		property = panel

		if t == "choice" then
			panel:SetChoices(extra_info.table or extra_info.list)
		end

		if t == "number" then
			if extra_info.editor_min then panel:SetMinimum(extra_info.editor_min) end

			if extra_info.editor_max then panel:SetMaximum(extra_info.editor_max) end

			if extra_info.editor_sens then
				panel:SetSensitivity(extra_info.editor_sens)
			end
		end

		list.insert(self.added_properties, panel)
	else
		local panel = right:CreatePanel("base_property", "property")

		function panel:Decode(str)
			local val = serializer.Decode("luadata", str)[1]

			if typex(val) ~= t then val = default end

			return val
		end

		function panel:Encode(val)
			return serializer.Encode("luadata", val)
		end

		panel:SetValue(default)
		panel:SetDefaultValue(extra_info.default or default)
		panel.GetValue = get_value
		panel.OnValueChanged = function(_, val)
			set_value(val)
		end
		panel:SetupLayout("fill")
		panel.left = left
		property = panel
		list.insert(self.added_properties, panel)
	end

	if fields then
		local panels = {}
		exp.OnStateChanged = function(_, b)
			for i, panel in ipairs(panels) do
				panel.right:SetVisible(b)
				panel.right:SetStackable(b)
				panel.left:SetStackable(b)
				panel.left:SetVisible(b)
			end

			self:Layout()
			expand_memory[exp.state_key] = b
		end

		for i, key in ipairs(fields) do
			local extra_info = table.merge(
				{
					__label_offset = self.left_offset + (label.label_offset or self.left_offset),
					field = key,
				},
				extra_info
			)
			extra_info.default = extra_info.default[key]
			extra_info.fields = nil
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
				extra_info,
				obj
			)
			left:SetStackable(false)
			right:SetStackable(false)
			left:SetVisible(false)
			right:SetVisible(false)
			list.insert(panels, {left = left, right = right})
		end
	end

	property.obj = obj
	property.info = extra_info
	self.first_time = true
	self:Layout()
	return left, right
end

function META:OnLayout(S)
	self:SetMargin(Rect() + S * 2) -- TODO
	self.left_max_width = self.left_max_width or 0
	self.right_max_width = self.right_max_width or 0

	for i, left in ipairs(self.left:GetChildren()) do
		if left.is_group then left:SetHeight(S * 10) else left:SetHeight(S * 8) end

		if left.left_offset then
			left:SetDrawPositionOffset(Vec2(left.left_offset * S, 0))
		end

		if left.expand then left.expand:SetPadding(Rect() + S * 2) end

		left.label:SetPadding(Rect(S * 2, S * 2, left.label.label_offset or S * 2, S * 2))

		if self.first_time then
			left:Layout(true)
			self.left_max_width = math.max(
				self.left_max_width,
				left.label:GetWidth() + left.label:GetX() + (
						self.left_offset * S
					) + left.label:GetPadding():GetRight()
			)
		end
	end

	for i, right in ipairs(self.right:GetChildren()) do
		if right.is_group then
			right:SetHeight(S * 10)
		else
			right:SetHeight(S * 8)
			local w = right.property.label:GetWidth() + S * 5

			if self.first_time then
				self.right_max_width = math.max(self.right_max_width, w)
			end

			if self:HasParent() and self.Parent:GetWidth() < self.left_max_width + w then
				right.property:SetTooltip(right.property.tooltip_text)
			else
				right.property:SetTooltip("")
			end
		end
	end

	if self.first_time then
		self.divider:SetDividerPosition(self.left_max_width)
	end

	local h = self.left:GetSizeOfChildren().y + self.Margin:GetBottom() + S * 2 -- TODO
	self.divider:SetSize(Vec2(self.left_max_width + self.right_max_width, h))
	self:SetWidth(self.left_max_width + self.right_max_width)
	self:SetHeight(h)
	self.first_time = false
end

function META:OnPanelMouseInput(panel, button, press)
	if press and button == "button_1" and panel.ClassName:find("_property") then
		for i, right in ipairs(self.added_properties) do
			if panel ~= right then right:CancelEditing() end
		end
	end
end

function META:AddPropertiesFromObject(obj)
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
			L(nice_name),
			function(val)
				if obj:IsValid() then
					if event.Call("GUIObjectPropertyChanged", obj, val, info) ~= false then
						set(obj, val)
					end
				end
			end,
			function()
				if obj:IsValid() then return get(obj) end

				return def
			end,
			def,
			info,
			obj
		)
	end

	-- expand non groups first
	for k, v in pairs(self.left:GetChildren()) do
		if v.expand and not v.is_group then
			if expand_memory[v.expand.state_key] ~= nil then
				local b = expand_memory[v.expand.state_key]
				v.expand:SetState(b)
				v.expand:OnStateChanged(b)
			else
				local b = v.expand:GetState()
				v.expand:SetState(b)
				v.expand:OnStateChanged(b)
			end
		end
	end

	for k, v in pairs(self.left:GetChildren()) do
		if v.expand and v.is_group then
			if expand_memory[v.expand.state_key] ~= nil then
				local b = expand_memory[v.expand.state_key]
				v.expand:SetState(b)
				v.expand:OnStateChanged(b)
			else
				local b = v.expand:GetState()
				v.expand:SetState(b)
				v.expand:OnStateChanged(b)
			end
		end
	end
end

gui.RegisterPanel(META)