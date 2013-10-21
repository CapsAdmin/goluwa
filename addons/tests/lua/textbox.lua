--[[
快速
这正确地排除了两个部分资本化的话，但仍有中的标点符号，像这样：

string.gsub（“（快速）的棕色狐狸跳”，“％A％U+％”，打印）

（快速）
此外，还有另外一个问题，除了捕获的两侧的非字母。看看这个：

string.gsub（“（快速）的棕色狐狸跳”，“％A％U+％”，打印）

（快速）
资本正确的开始和结束的字符串的话都没有检测到。

解决办法：边疆模式：％F

string.gsub（“（快速）的棕色狐狸跳”，“％F[％]％U +％F [％]”，打印）

本
]]

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
				table.insert(lines, str:usub(last_pos+1, space_pos))
				last_pos = space_pos
			else
				table.insert(lines, str:usub(last_pos+1, pos))
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
		table.insert(lines, str:usub(last_pos+1, pos))
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
class.GetSet(PANEL, "Font", "default") 

function PANEL:SetText(str)
	self.click_pos = self.click_pos or Vec2()
	self.Text = str
	self:InvalidateText()
end

function PANEL:OnRequestLayout()
	self:InvalidateText()
end
 
function PANEL:InvalidateText()	
	
	surface.SetFont(self.Font)
	
	-- lol
	self.Text = self.Text:gsub("\r", "\n")
	
	local lines = self.Text:explode("\n")
	local markup = {w = 0, h = 0, data = {}}	
	local height = 0
		
	local temp = {}
	
	for pos, line in pairs(lines) do
		for _, str in pairs(split_text(line, self.Wrap and self:GetSize().w)) do
			local w, h = surface.GetTextSize(str)
			
			table.insert(temp, {str = str, pos = pos, w = w, h = h, x = 0, y = 0})
			
			if self.FixedHeight and h > height then 
				height = h  + self.LineSpacing
			end
		end		
	end
	
	local y = 0

	for i, data in pairs(temp) do	 
		data.y = y
		
		if self.FixedHeight then
			y = y + height
			data.h = height
		else
			y = y + data.h + 5
		end
		
		markup.h = markup.h + data.h
		
		table.insert(markup.data, data)
	end
	
	self.markup = markup
	self.lines = lines
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
	
	if not self.markup then return end
	
	self.selected_line = self.markup.data[pos.y] or self.markup.data[#self.markup.data]
	surface.SetFont(self.Font)
	check_char_table_cache(self.selected_line)
	self.selected_char = self.selected_line.tbl[pos.x] or self.selected_line.tbl[#self.selected_line.tbl]
	
	-- incase the pos is beyond the text
	if self.CaretPos.x > 1 then
		self.CaretPos.x = self.selected_char.pos
	end
	
	if self.CaretPos.y < 1 then
		self.selected_line = self.markup.data[1]
	end

	self.CaretPos.y = self.selected_line.pos
	
	self.CaretPos.x = math.max(self.CaretPos.x, 0)
end

function PANEL:SetCaretPosInPixels(pos)
	if not self.markup then return end

	for i, data in pairs(self.markup.data) do						
		if self.click_pos.y > data.y then
			self.selected_line = data
		end
	end
	
	if self.selected_line then				
		self.CaretPos.y = self.selected_line.pos
		
		surface.SetFont(self.Font)
		check_char_table_cache(self.selected_line)
						
		for pos, char in pairs(self.selected_line.tbl) do
			if char.x-char.w*0.5 < self.click_pos.x then
				self.selected_char = char
			end
		end
		
		if not self.selected_char then
			self.selected_char = self.selected_line.tbl[#self.selected_line.tbl]
		end
		
		if self.selected_char then
			if self.click_pos.x < self.selected_line.tbl[1].w then
				self.CaretPos.x = 0
			else
				self.CaretPos.x = self.selected_char.pos
			end
		end
	end
end 

function PANEL:GetSubPosFromPos(pos)
	local length = 0
	
	for i, data in pairs(self.markup.data) do					
		if i == pos.y then
			return length + data.str:usub(1, pos.x):ulength()
		else
			length = length + data.str:ulength() + 1
		end
	end
	
	return length
end

function PANEL:InsertChar(char)
	local sub_pos = self:GetSubPosFromPos(self.CaretPos)
		
	if #self.Text == 0 then
		self.Text = self.Text .. char
	elseif sub_pos == #self.Text then
		self.Text = self.Text .. char
	else
		self.Text = self.Text:usub(1, sub_pos) .. char .. self.Text:usub(sub_pos + 1)
	end
		
	self:InvalidateText()
end
 
function PANEL:OnCharInput(char)
	self:InsertChar(char)
	self:OnKeyInput("right", true, true)
end


function PANEL:OnKeyInput(key, press, skip_mods)
	if press then	
		local prev_line = self.markup.data[self.selected_line.pos-1]
		local next_line = self.markup.data[self.selected_line.pos+1]
		local line = self.selected_line.str
		local sub_pos = self:GetSubPosFromPos(self.CaretPos)
		local ctrl_down =  not skip_mods and input.IsKeyDown("left_control") or input.IsKeyDown("right_control") 
		
		self.real_x = self.real_x or 0
	
		if key == "tab" then
			if input.IsKeyDown("left_shift") then
				if self.Text:usub(sub_pos, sub_pos) == "\t" then
					self:OnKeyInput("backspace", true)
				else
					-- wip
					--print(self.Text:usub(sub_pos - #line, self.CaretPos.x):find("$\t-"))
				
				end
			else
				self:OnCharInput("\t")
			end
		end
		
		if key == "enter" then
			local space = line:match("^(%s+)") or ""
			
			self:InsertChar("\n" .. space)
			self.CaretPos.x = #space
			self.real_x = #space
			self.CaretPos.y = self.CaretPos.y + 1
		end
			
		if key == "v" and ctrl_down then
			local str = system.GetClipboard()
			
			if #str > 0 then			
				self:InsertChar(str)
				self.CaretPos.x = self.CaretPos.x + str:ulength()
				self.CaretPos.y = self.CaretPos.y + str:count("\n")
				self.real_x = self.CaretPos.x
			end
		end
		
		if key == "backspace" then
			if sub_pos == 0 then return end
						
			if ctrl_down then
				local x = (select(2, self.Text:usub(sub_pos - #line, self.CaretPos.x):find(".*%f[_%a].-[%a]")) or 1) - 1
				self.Text = self.Text:usub(1, x) .. self.Text:usub(sub_pos + 1)
				
				self.CaretPos.x = x - 1
				self.real_x = self.CaretPos.x 
			else
				self.Text = self.Text:usub(1, sub_pos - 1) .. self.Text:usub(sub_pos + 1)
			end
						
			if self.CaretPos.x == 0 then
				self.CaretPos.x = prev_line.str:ulength()+1
				self.real_x = prev_line.str:ulength()+1
				self.CaretPos.y = self.CaretPos.y - 1
			end
			
			self.CaretPos.x = self.CaretPos.x - 1
			self.real_x = self.CaretPos.x
			
			self:InvalidateText()
		elseif key == "delete" then
			
			if ctrl_down then
				local pos = (select(2, self.Text:find("[%a_].-[%a]", sub_pos + 1)) or self.Text:ulength() + 1) - 1
				self.Text = self.Text:usub(1, sub_pos) .. self.Text:usub(pos + 1)
			else
				self.Text = self.Text:usub(1, sub_pos) .. self.Text:usub(sub_pos + 2)
			end
			
			self:InvalidateText()
		end
		
		if key == "right" then	
			if ctrl_down then
				local x = (select(1, line:find("%f[_%a].-", self.CaretPos.x + 2)) or #line+1) - 1
				
				if x == self.CaretPos.x then
					x = math.huge -- go to the next line
				end
				
				self.CaretPos.x = x
			else
				self.CaretPos.x = self.CaretPos.x + 1
			end
			
			self.real_x = self.CaretPos.x
			
		elseif key == "left" then
			if ctrl_down then
				local x = (select(2, line:usub(1, self.CaretPos.x):find(".*%f[_%a].-[%a]")) or -1) - 1

				self.CaretPos.x = x
			else
				self.CaretPos.x = self.CaretPos.x - 1
			end
			
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
			local pos = (select(2, line:find("%s+(.)")) or 1) - 1
			
			if self.CaretPos.x == pos then
				pos = 0
			end
			
			self.CaretPos.x = pos
			self.real_x = self.CaretPos.x
		elseif key == "end" then
			-- this should be #line if you compare to 
			-- scintillia but in a way it makes sense to have it like this
			self.CaretPos.x = math.huge 
			self.real_x = self.CaretPos.x
		end
		 
		local x = self.CaretPos.x
		
		self:SetCaretPos(self.CaretPos)
		
		-- if we're at the end of the line, got to the next
		if x ~= self.CaretPos.x then
			if key == "right" then
				self.CaretPos.x = 0
				self.CaretPos.y = self.CaretPos.y + 1
				self:SetCaretPos(self.CaretPos)
			elseif key == "left" then
				self.CaretPos.x = math.huge
				self.CaretPos.y = self.CaretPos.y - 1
				self:SetCaretPos(self.CaretPos)
			end
		end
	end
end

function PANEL:OnDraw(size)
	surface.Color(0.1, 0.1, 0.1, 1)
	surface.SetWhiteTexture()
	surface.DrawRect(0, 0, size.w, size.h)
	
	surface.SetFont(self.Font)

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

				surface.SetFont(self.Font)
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

	if self.first_line_selected then
		surface.SetWhiteTexture()
		surface.Color(1, 1, 1, 0.25)
		surface.DrawRect(self.first_line_selected.x, self.first_line_selected.y, self.first_line_selected.w, self.first_line_selected.h)
	end
	
	if self.last_line_selected then
		surface.SetFont(self.Font)
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


surface.CreateFont("lol", {
	path = "fonts/unifont.ttf",
	size = 13,
	smoothness = 0,
})

local frame = utilities.RemoveOldObject(aahh.Create("frame"), "lol")
frame:SetSize(Vec2()+1000)
frame:Center()
frame:SetTitle("hmmm")
local edit = aahh.Create("text_edit", frame)
edit:SetFont("lol")
edit:SetText(STR)
edit:Dock("fill")
edit:SetWrap(true)
edit:MakeActivePanel()
