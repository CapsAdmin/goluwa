surface.CreateFont("lol", {
	path = "fonts/unifont.ttf",
	size = 14,
})

surface.SetFont("lol")

local function split_text(str, max_width)	
	local lines = {}
	
	if not max_width or max_width == 0 then
		lines[1] = str
		return lines
	end
 
	local last_pos = 0
	local line_width = 0
	local found = false
	
	local space_pos
		
	for pos, char in pairs(str:utotable()) do		
		local w, h = surface.GetTextSize(char)

		if char:find("%s") then
			space_pos = pos
		end

		if line_width + w >= max_width then
			
			if space_pos then
				table.insert(lines, str:sub(last_pos+1, space_pos))
				last_pos = space_pos
			else
				table.insert(lines, str:sub(last_pos+1, pos))
				last_pos = pos
			end		
			
			line_width = 0
			found = true
			space_pos = nil
		else
			line_width = line_width + w
		end
	end
	
	if found then
		table.insert(lines, str:sub(last_pos+1, pos))
	else
		table.insert(lines, str)
	end
	 
	return lines
end

-- this function makes a table of characters for the line with some other info
-- but we only call this when we need it for performance reasons

local function check_char_table_cache(line)
	if not line.tbl then 
		local tbl = {}
		local x = 0
		
		for pos, char in pairs(line.str:utotable()) do
			local w, h = surface.GetTextSize(char)
			x = x + w
			tbl[pos] = {char = char, pos = pos, x = x, w = w, h = h}
		end
		
		if #tbl == 0 then
			tbl[1] = {char = line, pos = 1, x = 0, w = 0, h = 0}
		end
		
		line.tbl = tbl
	end
end

local PANEL = {}

PANEL.ClassName = "text_edit"

class.GetSet(PANEL, "Text", "")
class.GetSet(PANEL, "Wrap", false)
class.GetSet(PANEL, "FixedHeight", true)
class.GetSet(PANEL, "LineSpacing", 3) 
class.GetSet(PANEL, "CaretPos", Vec2()) 

function PANEL:SetText(str)
	self.Text = str
	self:InvalidateText()
end

function PANEL:InvalidateText()	
	local lines = self.Text:explode("\n")
	local markup = {w = 0, h = 0, data = {}}	
	local height = 0
		
	local temp = {}
	
	for i, line in pairs(lines) do
		for _, str in pairs(split_text(line, self.Wrap and self:GetSize().w)) do
			local w, h = surface.GetTextSize(str)
			
			table.insert(temp, {str = str, w = w, h = h, x = 0, y = 0})
			
			if self.FixedHeight and h > height then 
				height = h 
			end
		end		
	end
	
	local y = 0

	for i, data in pairs(temp) do	 
		data.y = y
		data.i = i
		
		if self.FixedHeight then
			y = y + height + self.LineSpacing
			data.h = height + self.LineSpacing
		else
			y = y + data.h + 5
		end
		
		markup.h = markup.h + data.h
		
		table.insert(markup.data, data)
	end
	
	self.markup = markup
end

local selected_pos

local caret_pos = Vec2(0, 0)
local current_mouse_pos = Vec2(0, 0)
		
local selected_line 
local selected_char
local last_selected_line

function PANEL:OnMouseInput(button, press, pos)
	if button == "button_1" then
		if press then
			self.click_pos = self:GetMousePos()
		else
			last_selected_line = nil
		end

		self.is_mouse_down = press
		
		if press then
			self:SetCaretPosInPixels(pos)
		end
	end
end

function PANEL:SetCaretPos(pos)
	self.CaretPos = pos
	
	if not self.markup or not self.click_pos then return end
	
	self.selected_line = self.markup.data[pos.y] or self.markup.data[#self.data.markup]
	check_char_table_cache(self.selected_line)
	self.selected_char = self.selected_line.tbl[pos.x] or self.selected_line.tbl[#self.selected_line.tbl]
	
	-- incase the pos is beyond the text
	if self.CaretPos.x > 1 then
		self.CaretPos.x = self.selected_char.pos
	end
	self.CaretPos.y = self.selected_line.i
	
	self.CaretPos.x = math.max(self.CaretPos.x, 0)
end

function PANEL:SetCaretPosInPixels(pos)
	if not self.markup or not self.click_pos then return end

	for i, data in pairs(self.markup.data) do						
		if self.click_pos.y > data.y then
			self.selected_line = data
		end
	end
	
	if self.selected_line then				
		self.CaretPos.y = self.selected_line.i
		
		check_char_table_cache(self.selected_line)
						
		for pos, char in pairs(self.selected_line.tbl) do
			if char.x < self.click_pos.x then
				self.selected_char = self.selected_line.tbl[pos+1] 
			end
		end
		
		if not self.selected_char then
			self.selected_char = self.selected_line.tbl[#self.selected_line.tbl]
		end
		
		if self.selected_char then
			self.CaretPos.x = self.selected_char.pos
		end
	end
end

function PANEL:OnKeyInput(key, press)
	if press then
		if key == "right" then
			self.CaretPos.x = self.CaretPos.x + 1
			self.real_x = self.CaretPos.x
		elseif key == "left" then
			self.CaretPos.x = self.CaretPos.x - 1
			self.real_x = self.CaretPos.x
		end
		
		if key == "up" then
			self.CaretPos.y = self.CaretPos.y - 1
			self.CaretPos.x = self.real_x
		elseif key == "down" then
			self.CaretPos.y = self.CaretPos.y + 1
			self.CaretPos.x = self.real_x
		end
		
		if key == "home" then
			self.CaretPos.x = 0
			self.real_x = self.CaretPos.x
		elseif key == "end" then
			self.CaretPos.x = math.huge
			self.real_x = self.CaretPos.x
		end
		
		local x = self.CaretPos.x
		
		self:SetCaretPos(self.CaretPos)
		
		-- if we're at the end of the line, got to the next
		if x ~= self.CaretPos.x and key == "right" then
			self.CaretPos.x = 0
			self.CaretPos.y = self.CaretPos.y + 1
			self:SetCaretPos(self.CaretPos)
		end
	end
end

function PANEL:OnDraw(size)
	surface.Color(0.1, 0.1, 0.1, 1)
	surface.SetWhiteTexture()
	surface.DrawRect(0, 0, size.w, size.h)

	if not self.markup or not self.click_pos then return end
	
	self.first_line_selected = nil
	self.last_line_selected = nil
	
	local select_start = self.click_pos
	local select_end = self:GetMousePos()
		
	for i, data in pairs(self.markup.data) do
		
		if self.is_mouse_down then 
			-- skip the last line and first line if we're selecting multiple lines
			if 
				(select_start.y < data.y + data.h and select_end.y > data.y + data.h) or
				(select_start.y > data.y + data.h and select_end.y < data.y + data.h)
			then

				local w = 0
				local x = 0
				local first_char

				check_char_table_cache(data)			
				
				if not self.first_line_selected then
					local x = 0
					local w = 0
					
					for pos, char in pairs(data.tbl) do
						if select_start.x > char.x - char.w*0.5 then
							x = char.x
						end
						
						if select_start.x < char.x then
							w = w + char.w
						end
					end
					
					self.first_line_selected = {str = data.str, x = x, y = data.y, w = w, h = data.h}
				else
				
					self.last_line_selected = self.markup.data[i+1]
					
					surface.SetWhiteTexture()
					surface.Color(1, 1, 1, 0.25)
					surface.DrawRect(data.x, data.y, data.w, data.h)					
				end
			end
		end
		
		if data.y < size.y then		
			-- draw the text
			surface.Color(1, 1, 1, 1)
			surface.SetTextPos(data.x, data.y)
			surface.DrawText(data.str)	 
		end
	end
	
	if self.first_line_selected and self.last_line_selected then
		if self.first_line_selected.y > self.last_line_selected.y then
		
			local temp = self.last_line_selected
			self.last_line_selected = self.first_line_selected
			self.first_line_selected = temp
		end
	end
	
	if self.first_line_selected then
		surface.SetWhiteTexture()
		surface.Color(1, 1, 1, 0.25)
		surface.DrawRect(self.first_line_selected.x, self.first_line_selected.y, self.first_line_selected.w, self.first_line_selected.h)
	end
	
	if self.last_line_selected then
		check_char_table_cache(self.last_line_selected)			
 	
		local x = 0
		local w = 0
		
		for pos, char in pairs(self.last_line_selected.tbl) do
			if select_end.x > char.x - char.w*0.5 then
				w = w + char.w
			end
		end
	
		surface.SetWhiteTexture()
		surface.Color(1, 1, 1, 0.25)
		surface.DrawRect(x, self.last_line_selected.y, w, self.last_line_selected.h)
		
		surface.SetWhiteTexture()
		surface.Color(1, 1, 1, 0.125)
		surface.DrawRect(w, self.last_line_selected.y, size.w - w, self.last_line_selected.h)
		
	elseif self.selected_line then
		surface.SetWhiteTexture()
		surface.Color(1, 1, 1, 0.125)
		surface.DrawRect(self.selected_line.x, self.selected_line.y, size.w, self.selected_line.h)
			
		if self.selected_char then
			local x = self.selected_char.x - 2
			
			surface.SetWhiteTexture()
			surface.Color(1, 1, 1, (math.sin(os.clock()*16)+1)^4)
			
			if self.CaretPos.x == 0 then
				x = 0
			end
			
			surface.DrawRect(x, self.selected_line.y, 1, self.selected_line.h) 
		end
	end
end

aahh.RegisterPanel(PANEL)

STR = STR or ""

for i = 1, math.random(20, 50) do
	local line = ""
	for i = 1, math.random(30, 100) do
		line = line .. string.char(math.random(34, 120))
	end
	STR = STR .. line .. "\n"
end 

STR = vfs.Read("lua/textbox.lua")

window.Open(1000, 1000)  

local frame = utilities.RemoveOldObject(aahh.Create("frame"), "lol")
frame:SetSize(Vec2()+500)
frame:Center()
frame:SetTitle("hmmm")
local edit = aahh.Create("text_edit", frame)
edit:SetText(STR)
edit:Dock("fill")
edit:MakeActivePanel()
