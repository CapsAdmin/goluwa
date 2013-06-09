local PANEL = {}

PANEL.ClassName = "textinput2"
	
aahh.GetSet(PANEL, "Text", "")
aahh.GetSet(PANEL, "CaretPos", Vec2(1,1))
aahh.GetSet(PANEL, "Wrap", true)
aahh.GetSet(PANEL, "TextSize", 8)
aahh.GetSet(PANEL, "MultiLine", true)
aahh.GetSet(PANEL, "Font", "consola.ttf")

aahh.GetSet(PANEL, "ChokeTime", 0.5)

PANEL.lines = {}
PANEL.Choke = 0

function PANEL:Initialize()
	self:SetSkinColor("light", "dark")
end

function PANEL:Clear()
	self.Text = ""
	self.lines = {}
	self.CaretPos = Vec2()
end

function PANEL:OnRequestLayout()
	if self.Wrap then self:LayoutText(self:GetWidth())  end
end

function PANEL:OnKeyInput(key, press)
		
	if key == "space" then return end
	
	if self.suppress_key then
		self.suppress_key = false
		return
	end
	
	if press then
		self.Key = key
		self:HandleKey(key)
		self:DoChoke()
	else
		self.Key = nil
	end		
end

function PANEL:OnMouseInput(button, press)
	self:MakeActivePanel()

	if button == "mouse1" then
		self.CaretPos = select(3,self:GetCharFromPixelPos(self:GetMousePosition())) or self.CaretPos
	end
end

function PANEL:OnCharInput(char, press)

	if self.suppress_char then
		self.suppress_char = false
		return
	end
	
	self.Char = char
	self:HandleChar(char)
end

function PANEL:OnThink()
	if self.Key and not self:IsChoked() and INTERVAL(0.02) then
		self:HandleKey(self.Key)
	end

	if self.Text ~= self.last_text then
		self:OnTextChanged(self.Text, self.last_text)		
		self.last_text = self.Text
	end
end

function PANEL:SuppressNextChar()
	self.suppress_char = true
end

function PANEL:SuppressNextKey()
	self.suppress_key = true
end
		
function PANEL:DoChoke(time)
	self.Choke = os.clock() + (time or self.ChokeTime)
end

function PANEL:IsChoked()
	return self.Choke > os.clock()
end
 
function PANEL:InsertChar(char)
	local subpos = self:GetSubPosFromPos(self.CaretPos)
	
	if #self.Text == 0 then
		self.Text = self.Text .. char
	elseif subpos == #self.Text then
		self.Text = self.Text .. char
	else
		self.Text = self.Text:sub(1, subpos) .. char .. self.Text:sub(subpos+1)
	end
			
	self:HandleKey("right")
	
	self:LayoutText()
end

function PANEL:SetText(str)			
	self.Text = str
	
	if self.Wrap then self:LayoutText(self:GetWidth()) end
end
	
do -- utilities

	function PANEL:GetCharFromPixelPos(pos)	
		local y = math.ceil(pos.y / (self.TextSize * 1.5))
		local line = self.lines[y]
		
		if not line then return end

		local x = 0
		local i = 0
		
		for char in line:gmatch("(.)") do
			
			local siz = graphics.GetTextSize(self.Font, char) * self.TextSize
			local rect = Rect(x, y * (self.TextSize * 1.5) - (self.TextSize * 1.5), siz)
			
			if rect:IsPosInside(pos) then
				return char, rect, Vec2(i, y)
			end
			
			x = x + siz.w
			i = i + 1
		end
	end

	function PANEL:GetCharFromPos(pos)
		local line = self.lines[pos.y]
		
		if not line then return end 
		
		local char = line:sub(pos.x, pos.x)
		
		local x = graphics.GetTextSize(self.Font, line:sub(0, pos.x)).w * self.TextSize
		local y = pos.y * (self.TextSize * 1.5) - (self.TextSize * 1.5)
		
		local siz = graphics.GetTextSize(self.Font, char) * self.TextSize
		local rect = Rect(x, y, siz)
		
		return char, rect, pos
	end	

	function PANEL:GetSubPosFromPos(pos)
		local num = 0
		
		for key, line in pairs(self.lines) do					
			if key == pos.y then
				return num + #line:sub(0, pos.x)
			else
				num = num + #line
			end
		end
		
		return num
	end

	function PANEL:GetPosFromSubPos(num)
		return Vec2(#self.Text:sub(0, num):match(".+\n(.+)"), self.Text:count("\n"))
	end

end

function PANEL:LayoutText(max_width)
	max_width = max_width or self:GetWidth()
	local caret_pos = self:GetSubPosFromPos(self.CaretPos)
	
	self.lines = {}
	
	local current_width = 0
	local line = ""
	
	for str in self.Text:gmatch("(.)") do
		
		-- subtract the width of the character on max_width so it doesn't go outside the panel
		local w = graphics.GetTextSize(self.Font, str).w * self.TextSize
		local max_width = max_width - w
		
		if current_width > max_width or str == "\n" or i == #self.Text then	
			table.insert(self.lines, line)

			current_width = w
			line = str
		else				
			current_width = current_width + w
			line = line .. str
		end
				
	end
	
	if #self.lines == 0 then
		table.insert(self.lines, self.Text)
	end
end

function PANEL:HandleKey(key)	
	if key == "v" and input.IsKeyDown("lctrl") then
		local str = clipboard.GetText()
		if #str > 0 then
			if not self.MultiLine then	 	
				str = str:gsub("\n", "")
			end
		
			self:InsertChar(str)
			self:SetCaretPos(self:GetCaretPos() + Vec2(#str, 0))
			self:SuppressNextChar()
			
			self:LayoutText()
		end
		return
	end


	local line = self.lines[self.CaretPos.y] 
	
	if key == "up" then
		self.CaretPos = self.CaretPos +  Vec2(0, -1)
	elseif key == "down" then
		self.CaretPos = self.CaretPos + Vec2(0, 1)
	elseif key == "left" then
		local pos = self.CaretPos + Vec2(-1, 0)

		-- this should snap before the next %p
		if input.IsKeyDown("lctrl") then
			pos.x = (select(2, line:sub(1, self.CaretPos.x):find(".*[%s%p].-[%P%S]")) or 1) - 1
		end
		
		self.CaretPos = pos			
	elseif key == "right" then
		local pos = self.CaretPos + Vec2(1, 0)
		
		-- this should snap before the next %p
		if input.IsKeyDown("lctrl") then
			pos.x = (select(2, line:find("[%s%p].-[%P%S]", self.CaretPos.x + 1)) or 1) - 1
			if pos.x < self.CaretPos.x then
				pos.x = #line
			end
		end
		
		self.CaretPos = pos
	elseif key == "end" then
		self.CaretPos.x = #line
	elseif key == "home" then
		self.CaretPos.x = 0
	end
	self:LayoutText()
	
	
	local subpos = self:GetSubPosFromPos(self.CaretPos)
					
	if key == "delete" then
		if input.IsKeyDown("lctrl") then
			local pos = (select(2, self.Text:find("[%s%p].-[^%p%s]", subpos+1)) or #self.Text+1) - 1
			self.Text = self.Text:sub(1, subpos) .. self.Text:sub(pos+1)
		else
			self.Text = self.Text:sub(1, subpos) .. self.Text:sub(subpos+2)
		end
		
		self:LayoutText()
	elseif key == "backspace" then
		if subpos == 0 then return end
		
		if input.IsKeyDown("lctrl") then
			local pos = (select(2, self.Text:sub(1, subpos):find(".*[%s%p].-[^%p%s]")) or 1) - 1
			self.Text = self.Text:sub(1, pos) .. self.Text:sub(subpos+1)
			self.CaretPos.x = pos - 1
		else
			self.Text = self.Text:sub(1, subpos-1) .. self.Text:sub(subpos+1)
			self:HandleKey("left")
		end
		
		if self.CaretPos.x < 0 then
			self.CaretPos.x = self.lines[self.CaretPos.y - 1] and #self.lines[self.CaretPos.y - 1] or 0
			self.CaretPos.y = self.CaretPos.y - 1
		end
		
		self:LayoutText()
		
	elseif key == "space" then
		self:InsertChar(" ")
	elseif key == "tab" then
		self:InsertChar("\t")
	elseif key == "pgdn" then
		self:InsertChar("\n")
	elseif key == "enter" or key == "np_enter" then
		if self.MultiLine then
			self:InsertChar("\n")
		else
			self:OnEnter(self.Text)
		end
	else
		self:OnUnhandledKey(key)
	end
end

function PANEL:HandleChar(char)
	local byte = char:byte()

	if byte > 32 then
		self:InsertChar(char)
	elseif byte == 32 then
		self:HandleKey("space")
	else
		self:OnUnhandledChar(char)
	end
end

function PANEL:OnEnter(str) end
function PANEL:OnUnhandledKey(key) end
function PANEL:OnTextChanged() end
function PANEL:OnUnhandledChar(char) end

function PANEL:OnDraw(size)	
	graphics.DrawRect(Rect(0, 0, self:GetWide(), self:GetTall()), self:GetSkinColor("dark"), 0, 1, self:GetSkinColor("medium"))

	if not self.lines then return end

	local h = 0
	
	for key, line in pairs(self.lines) do
		local line_height = self.TextSize * 1.5
	
		key = key - 1 -- start from 0 instead of 1 to avoid offset issues
		h = (key + 2) * line_height
		graphics.DrawText(line, Vec2(0, key * line_height), self.Font, self.TextSize, self:GetSkinColor("light2"))
	
		if h > size.h then break end
	end
	
	
	local char, rect, pos = self:GetCharFromPos(self.CaretPos)
			
	-- caret
	if rect and --[[self:IsActivePanel() and]] T%0.5 > 0.25 then
		rect.w = 2
		graphics.DrawRect(rect, self:GetSkinColor("light2"))
	end		
	
	if false and char then
		graphics.DrawRect(rect, Color(1,0,0,0.25))
		graphics.DrawText(char .. " " .. tostring(pos), rect:GetPos(), "tahoma",  20, Color(0,0,0,1))
	end

end

aahh.RegisterPanel(PANEL)

if CAPSADMIN and false then
	timer.Simple(0.1, function()
		local frame = utilities.RemoveOldObject(aahh.Create("frame"), "uh")
		frame:SetPos(Vec2(50, 550))
		frame:SetSize(Vec2(0, 0) + 400)
		 
		local pnl = frame:CreatePanel("textinput2")
		
		local function escape(s)
			return string.gsub(s, "([^A-Za-z0-9_])", function(c)
				return string.format("%%%02x", string.byte(c))
			end)
		end

		local function geturl(str, to, from)
			from = from or "en"
			assert(str)
			assert(to)
			return ("http://translate.google.com/translate_a/t?client=t&text=%s&sl=%s&tl=%s&ie=UTF-8&oe=UTF-8"):format(escape(str), from, to)
		end

		local function translate(str, from, to, callback)
			luasocket.Query(geturl(str, to, from), function(data)
				data = data.content
				local res = data:match("%[%[%[\"(.-)\"")
				print(res)
				callback(res)
			end)
		end
		
		luasocket.Query("http://loripsum.net/api/plaintext", function(data)
			--print(data.content)
			pnl:SetText("WWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWWW\n" .. data.content)
			do return end
			translate(data.content, "it", "ja", function(str)
				pnl:SetText(str)
			end)
		end)
		 
		pnl:Dock("fill")
	end)
end