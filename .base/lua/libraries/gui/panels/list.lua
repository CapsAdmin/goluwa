local gui = ... or _G.gui

local PANEL = {}

PANEL.ClassName = "list"

function PANEL:Initialize()		
	self.columns = {}
	self.last_div = NULL
	self.list = NULL

	local top = self:CreatePanel("base", "top")
	--top:SetLayoutParentOnLayout(true)
	top:SetMargin(Rect())
	--top:SetClipping(true)
	top:SetNoDraw(true)
				
	local list = self:CreatePanel("base", "list")
	self:SetStyle("property")
	--list:SetClipping(true)
	 list:SetNoDraw(true)
	--list:SetCachedRendering(true)
	
	local scroll = self:CreatePanel("scroll", "scroll")
	scroll:SetYScrollBar(true)
	scroll:SetPanel(list)
		
	self:SetupSorted("")
end

function PANEL:OnStyleChanged(skin)
	self.list:SetColor(skin.font_edit_background)
	
	for i, column in ipairs(self.columns) do
		column.div:SetColor(skin.font_edit_background)
	end
	
	for _, entry in ipairs(self.entries) do
		for i, label in ipairs(entry.labels) do
			label:SetTextColor(skin.text_color)
		end
	end
end

function PANEL:OnLayout(S)
	self.top:SetWidth(self:GetWidth())
	self.top:SetHeight(S*10)
	self.scroll:SetPosition(Vec2(0, S*10))
	self.scroll:SetWidth(self:GetWidth())
	self.scroll:SetHeight(self:GetHeight() - S*10)
	
	local y = 0
	for _, entry in ipairs(self.entries) do
		entry:SetPosition(Vec2(0, y))
		entry:SetHeight(S*8)
		entry:SetWidth(self:GetWidth())
		y = y + entry:GetHeight()		
		
		local x = 0
		for i, label in ipairs(entry.labels) do
			local w = self.columns[i].div.left:GetWidth()
			label:SetWidth(w)
			label:SetX(x+S)
			label:SetHeight(entry:GetHeight())
			
			w = w + self.columns[i].div:GetDividerWidth()
			
			if self.columns[i].div.left then
				x = x + w
			end
		end
	end
	
	self.list:SetHeight(y)
	self.list:SetWidth(self:GetWidth())
	
	--self:SizeColumnsToFit()
	
	for i, column in ipairs(self.columns) do
		column:SetMargin(Rect()+2*S)
		column:SetHeight(S*10)
		column.div:SetWidth(self:GetWidth())
	end

	if #self.columns > 0 then
		self.columns[#self.columns].div:SetDividerPosition(self:GetWidth())
	end
end

function PANEL:SizeColumnsToFit()
	for i, column in ipairs(self.columns) do			
		column.div:SetDividerPosition(column:GetTextSize().w + column.icon:GetWidth() * 2)
	end
end

function PANEL:SetupSorted(...)
	self.list:RemoveChildren()
	self.top:RemoveChildren()
	
	self.last_div = NULL
	
	self.columns = {}
	self.entries = {}
	
	for i = 1, select("#", ...) do
		local v = select(i, ...)
		local name, func
		
		if type(v) == "table" then
			 name, func = next(v)
		elseif type(v) == "string" then
			name = v
			func = table.sort
		end
					
		local column = gui.CreatePanel("text_button", self)
		column:SetText(name)
		column:SizeToText()
		column.label:SetupLayout("left", "top", "center_y_simple") 
		
		local icon = column:CreatePanel("base", "icon")
		icon:SetStyle("list_down_arrow")
		icon:SetupLayout("left", "right", "top", "center_y_simple")
		icon:SetIgnoreMouse(true)
					
		local div = self.top:CreatePanel("divider")
		--div:SetupLayout("fill")
		div:SetHideDivider(true)
		div:SetHeight(column:GetHeight())
		div:SetLeft(column)
		div.OnDividerPositionChanged = function() self:Layout() end
		column.div = div
		
		self.columns[i] = column
		
		column.OnRelease = function()			
			if column.sorted then
				icon:SetStyle("list_down_arrow")
				table.sort(self.entries, function(a, b)
					return a.labels[i].text < b.labels[i].text
				end)
			else
				icon:SetStyle("list_up_arrow")
				table.sort(self.entries, function(a, b)
					return a.labels[i].text > b.labels[i].text
				end)
			end
			
			self:Layout()
			
			column.sorted = not column.sorted
		end
		
		if self.last_div:IsValid() then 
			self.last_div:SetRight(div)
		end
		self.last_div = div
	end
	
	self:Layout()
end

function PANEL:ClearList()
	self.list:RemoveChildren()
end

function PANEL:AddEntry(...)						
	local entry = self.list:CreatePanel("button") 
	
	entry.OnSelect = function() end
	entry.labels = {}
				
	for i = 1, #self.columns do
		local text = select(i, ...) or "nil"
		
		local label = entry:CreatePanel("text_button")
		label:SetTextWrap(false)
		label.label:SetLightMode(true)
		label.label.markup:SetSuperLightMode(true)
		label:SetTextColor(self:GetSkin().text_list_color)		
		label:SetText(self.columns[i].converter and self.columns[i].converter(text) or text)
		label:SizeToText()
		label.text = text
--		label:SetFixedSize(true)
		label:SetWidth(20)
		--label:SetClipping(true) 
		label:SetNoDraw(true)
		label:SetIgnoreMouse(true)
		label:SetConcatenateTextToSize(true)
				
		entry.labels[i] = label
	end

	local last_child = self.list:GetChildren()[#self.list:GetChildren()]
	
	entry:SetMode("toggle")
	entry:SetActiveStyle("menu_select")
	entry:SetInactiveStyle("nodraw")

	entry.SetIcon = function(_, path)
		local label = entry.labels[1]
		
		table.remove(label:GetChildren())
		local icon = label:CreatePanel("base")
		table.insert(label:GetChildren(), label.label)
		
		local image = Texture(path or "textures/silkicons/folder.png") 
		icon:SetTexture(image)
		icon:SetSize(image:GetSize())

		icon:SetupLayout("left", "center_y_simple")
		label.label:SetupLayout("left", "center_y_simple")
	end
	
	entry.OnStateChanged = function(_, b)
		if b then
			entry:OnSelect()
		end
		self:OnEntrySelect(entry, b)
	end
	
	entry.i = #self.entries + 1
	
	table.insert(self.entries, entry)
	
	return entry
end

function PANEL:OnEntrySelect(entry, select)
 
end

function PANEL:SetupConverters(...)
	for i = 1, #self.columns do
		self.columns[i].converter = select(i, ...)
	end
end

gui.RegisterPanel(PANEL)

if RELOAD then
	local frame = gui.CreatePanel("frame", nil, "test")
	frame:SetSize(Vec2()+500)
	local list = frame:CreatePanel("list")
	list:SetupLayout("fill")
	list:SetupSorted("name", "modified", "type", "size")
	list:SetupConverters(nil, function(num) return os.date("%c", num) end, nil, utility.FormatFileSize)
	for i, name in ipairs(vfs.Find("lua/")) do
		local file = vfs.Open("lua/" .. name)
		local type = "folder"
		local size = 0
		local last_modified = 0
		
		if file then 
			type = name:match(".+%.(.+)")
			size = file:GetSize()
			last_modified = file:GetLastModified()
		end
		local entry = list:AddEntry(name, last_modified, type, size)
		entry:SetIcon("textures/silkicons/"..(type == "folder" and "folder" or "script")..".png")
		if file then
			file:Close()
		end
	end
end