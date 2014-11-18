local gui2 = ... or _G.gui2
local S = gui2.skin.scale

local PANEL = {}

PANEL.ClassName = "list"

PANEL.columns = {}
PANEL.last_div = NULL
PANEL.list = NULL

function PANEL:Initialize()	
	self:SetNoDraw(true)
	
	local top = self:CreatePanel("base", "top")
	top:SetLayoutParentOnLayout(true)
	top:SetMargin(Rect())
	top:SetClipping(true)
	top:SetNoDraw(true)
				
	local list = self:CreatePanel("base", "list")
	list:SetColor(gui2.skin.font_edit_background)
	--list:SetCachedRendering(true)
	list:SetClipping(true)
	list:SetNoDraw(true)
	
	local scroll = self:CreatePanel("scroll", "scroll")
	scroll:SetXScrollBar(false)
	scroll:SetPanel(list)
	
	self:SetupSorted("")
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
		y = y + entry:GetHeight() - S		
		
		local x = 0
		for i, label in ipairs(entry.labels) do
			local w = self.columns[i].div.left:GetWidth()
			label:SetWidth(w)
			label:SetX(x+S)
			label:SetHeight(entry:GetHeight())
			label:CenterTextY()
			
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
		column:CenterTextY()
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
					
		local column = gui2.CreatePanel("text_button")
		column:SetText(name)
		column:SetClipping(true)
		column.label:SetupLayoutChain("left")
		column:SizeToText()
				
		local icon = column:CreatePanel("base", "icon")
		icon:SetStyle("list_down_arrow")
		icon:SetupLayoutChain("right")
		icon:SetIgnoreMouse(true)
					
		local div = self.top:CreatePanel("divider")
		div:SetColor(gui2.skin.font_edit_background)
		--div:SetupLayoutChain("fill_x", "fill_y")
		div:SetHideDivider(true)
		div:SetLeft(column)
		div:SetLayoutParentOnLayout(true)
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

function PANEL:AddEntry(...)						
	local entry = self.list:CreatePanel("button") 
	
	entry.labels = {}
				
	for i = 1, #self.columns do
		local text = tostring(select(i, ...) or "nil")
		
		local label = entry:CreatePanel("text_button")
		label:SetParseTags(true)
		label:SetTextColor(gui2.skin.text_color)
		label:SetTextWrap(false)
		label:SetText(text)
		label:SizeToText()
		label.text = text
		label:SetClipping(true)
		label:SetNoDraw(true)
		label:SetIgnoreMouse(true)
		label:SetConcatenateTextToSize(true)
		
		entry.labels[i] = label
	end

	local last_child = self.list:GetChildren()[#self.list:GetChildren()]
	
	entry:SetPosition(Vec2(0, last_child:GetY() + last_child:GetHeight() - 2*S))
	entry:SetHeight(entry.labels[1]:GetHeight() + 2*S)
	entry:SetStyle("button_active")
	entry:SetNoDraw(true)

	entry.OnPress = function()
		for k, other_entry in ipairs(self.entries) do
			if other_entry ~= entry then
				other_entry:SetNoDraw(true)
			else
				entry:SetNoDraw(false)
				entry:SetStyle("button_active")
			end
		end
	end
	
	entry.i = #self.entries + 1
	
	table.insert(self.entries, entry)
	
	return entry
end

gui2.RegisterPanel(PANEL)