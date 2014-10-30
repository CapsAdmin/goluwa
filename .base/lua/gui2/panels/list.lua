local gui2 = ... or _G.gui2
local S = gui2.skin.scale

local PANEL = {}

PANEL.ClassName = "list"

PANEL.columns = {}
PANEL.last_div = NULL
PANEL.list = NULL

function PANEL:Initialize()	
	self:SetNoDraw(true)
	
	local top = gui2.CreatePanel("base", self)
	top:SetLayoutParentOnLayout(true)
	top:SetMargin(Rect())
	top:SetClipping(true)
	top:SetNoDraw(true)
	self.top = top
				
	local list = gui2.CreatePanel("base", self)
	list:SetColor(Color(0,0,0,1))
	--list:SetCachedRendering(true)
	list:SetClipping(true)
	self.list = list
	
	local scroll = gui2.CreatePanel("scroll", self)
	scroll:SetXScrollBar(false)
	scroll:SetPanel(list)
	self.scroll = scroll
	
	self:SetupSorted("")
end

function PANEL:OnLayout()
	self.top:SetWidth(self:GetWidth())
	self.top:SetHeight(20)
	self.scroll:SetPosition(Vec2(0, 20))
	self.scroll:SetWidth(self:GetWidth())
	self.scroll:SetHeight(self:GetHeight() - 20)
	local y = 0
	for _, entry in ipairs(self.entries) do
		entry:SetPosition(Vec2(0, y))
		entry:SetWidth(self:GetWidth())
		y = y + entry:GetHeight() - S
		
		
		local x = 0
		for i, label in ipairs(entry.labels) do
			local w = self.columns[i].div.left:GetWidth()
			label:SetWidth(w)
			label:SetX(x)
			label:SetHeight(entry:GetHeight())
			label:CenterTextY()
			
			w = w + self.columns[i].div:GetDividerWidth()
			
			if self.columns[i].div.left then
				x = x + w
			end
		end
	end
	
	self.list:SetHeight(y)
	
	self:SizeColumnsToFit()

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
		column:SetMargin(Rect()+2*S)
		column:SetText(name)
		column:SetClipping(true)
		column:SizeToText()
		
		local icon = gui2.CreatePanel("text", column)
		icon:SetText("▼")
		icon:Dock("right")
		column.icon = icon
					
		local div = gui2.CreatePanel("divider", self.top)
		div:SetColor(Color(0,0,0,1))
		div:Dock("fill")
		div:SetLeft(column)
		div:SetLayoutParentOnLayout(true)
		column.div = div
		
		self.columns[i] = column
		
		column.OnPress = function()
			
			if column.sorted then
				icon:SetText("▼")
				table.sort(self.entries, function(a, b)
					return a.labels[i].text < b.labels[i].text
				end)
			else
				icon:SetText("▲")
				table.sort(self.entries, function(a, b)
					return a.labels[i].text > b.labels[i].text
				end)
			end
			
			self:Layout()
			
			column.sorted = not column.sorted
		end
		
		column.OnLayout = function()
			column:SetSize(Vec2(column:GetWidth(), 20))
			column:CenterTextY()
		end
		
		if self.last_div:IsValid() then 
			self.last_div:SetRight(div)
		end
		self.last_div = div
	end
end

function PANEL:AddEntry(...)						
	local entry = gui2.CreatePanel("button", self.list) 
	
	entry.labels = {}
				
	for i = 1, select("#", ...) do
		local text = tostring(select(i, ...) or "nil")
		
		local label = gui2.CreatePanel("text_button", entry)
		label:SetFont("snow_font_green")
		label:SetTextColor(Color(0,1,0))
		label:SetTextWrap(false)
		label:SetText(text)
		label:SizeToText()
		label.text = text
		label:SetClipping(true)
		label:SetNoDraw(true)
		label:SetIgnoreMouse(true)
		
		entry.labels[i] = label
	end

	local last_child = self.list:GetChildren()[#self.list:GetChildren()]
	
	entry:SetPosition(Vec2(0, last_child:GetPosition().y + last_child:GetHeight() - 2*S))
	entry:SetNoDraw(true)
	entry:SetStyleTranslation("button_active", "menu_select")
	entry:SetStyleTranslation("button_inactive", "menu_select")
	entry:SetStyle("menu_select")
	entry:SetHeight(entry.labels[1]:GetHeight() + 2*S)

	entry.OnPress = function()
		for k, other_entry in ipairs(self.entries) do
			if other_entry ~= entry then
				other_entry:SetNoDraw(true)
			else
				entry:SetStyle("menu_select")
				entry:SetNoDraw(false)
			end
		end
	end
	
	entry.i = #self.entries + 1
	
	table.insert(self.entries, entry)
end

gui2.RegisterPanel(PANEL)