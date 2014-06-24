
-- 88.90.232.18

-- TODO: Margin area for line numbers, or other gui elements.
-- TODO: Scrollbar, View area
-- TODO: Selection, Copy

local PANEL = {}

PANEL.ClassName = "line_viewer"
PANEL.Base = "panel"

-- If true, text will not extend past the rightmost edge. Instead it will be cut and the end
--  piece will be moved to the next line.
gui.GetSet(PANEL, "Wrap", true)

-- If true,  it will wrap by word (spaces define breaking points)
-- If false, it will wrap by letter
gui.GetSet(PANEL, "ByWord", true) -- "true" for word-warpping, "false" for letter-wrapping

-- Colors for interchanging lines
gui.GetSet(PANEL, "ColorA", Color(0.1, 0.1, 0.1, 1))
gui.GetSet(PANEL, "ColorB", Color(0.15, 0.15, 0.15, 1))

-- Minimum and Maximum line heights
gui.GetSet(PANEL, "MinLineHeight", 10)
gui.GetSet(PANEL, "MaxLineHeight", 60)

-- Enable / Disable scroll bars
gui.GetSet(PANEL, "XScroll", false)
gui.GetSet(PANEL, "YScroll", true)

-- Maximum number of elements
gui.GetSet(PANEL, "MaxElements", 10000)

-- The margin the lines are forced to follow
gui.GetSet(PANEL, "LineMargin")

-- If true, the view will keep up with the last line unless the view is moved upwards
gui.GetSet(PANEL, "StayOnBottom", true)

-- If true, scrolling space will exist underneath the last line.
gui.GetSet(PANEL, "SpaceBeneath", false)

function PANEL:Initialize()
	
	self.removals = {}
	self.elements = {}
	self.lines = {}
	self.viewx = 0
	self.viewy = 0
	
	self.process = 0 	  -- Element index being processed
	self.maxchunk = 100   -- Maximum number of elements processed per layout
	
	self.startline = 1    -- Which line it will start rendering at
	self.startelement = 1 -- Which element it will start rendering at
	
	self.fullwidth = 0
	self.fullheight = 0
	
	self:SetMargin(Rect(2, 2, 12, 4))
	
	self.layoutfinished = false
	
end

function PANEL:SetXScroll(bool)
	self.XScroll = bool
	if bool == true then
		self.Margin.w = 12
	else
		self.Margin.w = 2
	end
end

function PANEL:SetYScroll(bool)
	self.YScroll = bool
	if bool == true then
		self.Margin.h = 12
	else
		self.Margin.h = 2
	end
end

function PANEL:GetElements()
	return self.elements
end

function PANEL:RemoveElement(pnl)
	for k,v in ipairs(self.elements)do
		if v == pnl then
			table.remove(self.elements, k)
			return true
		end
	end
	return false
end

function PANEL:MarkForRemoval(pnl)
	self.removals[#self.removals+1] = pnl
end

function PANEL:SetMaxChunk(maxchunk)
	self.maxchunk = maxchunk
end

function PANEL:GetMaxChunk()
	return self.maxchunk
end

function PANEL:TextToWords(struct)
	
	local words = {}
	
	local text = struct.text
	local font = struct.font
	local fontsize = struct.fontsize
	local length = string.len(text)
	
	local space
	local word
	
	for i=1, string.len(text) do
		
		length = string.len(text)
		
		space = nil
		word = nil
		
		local ss,se = string.find(text, "[ ]+")
		local ws,we = string.find(text, "[^ ]+")
		
		--print(ss)
		--print(se)
		--print(ws)
		--print(we)
		
		if ss == nil and ws == nil then break end
		
		if ss then
			if #words == 0 and ss == 1 then
				space = {}
				space.isspace = true
				space.text = string.rep(" ", se-ss)
				space.width = self:GetTextSize(font, fontsize, space.text).w
			elseif se == length then
				space = {}
				space.isspace = true
				space.text = string.rep(" ", se-ss+1)
				space.width = self:GetTextSize(font, fontsize, space.text).w
			elseif se > ss then
				space = {}
				space.isspace = true
				space.text = string.rep(" ", se-ss+1 - 1)
				space.width = self:GetTextSize(font, fontsize, space.text).w
			end
		end
		
		if ws then
			local wtext = string.sub(text, ws, we)
			word = {}
			word.text = wtext
			word.width = self:GetTextSize(font, fontsize, wtext).w
		end
		
		local first
		local second
		
		--print("Space: ".. ( space and string.len(space.text) or "nil"))
		--print("Word: "..( word and word.text or "nil"))
		
		if word and space == nil then
			first = word
		end
		if space and word == nil then
			first = space
		end
		if space and word then
			if ws < ss then
				first = word
				second = space
			else
				first = space
				second = word
			end
		end
		
		text = string.sub(text, math.max(we or 0, se or 0)+1)
		
		--print(text)
		
		if first then
			words[#words+1] = first
		end
		
		if second then
			words[#words+1] = second
		end
		
		--print("----------")
		
	end
	
	--table.print(words)
	
	return words
	
end


---------------------------------------------------------------------------------------------------------
-- Additions ---- Additions ---- Additions ---- Additions ---- Additions ---- Additions ---- Additions --
---------------------------------------------------------------------------------------------------------

function PANEL:AddElement(element, name)
	
	if type(element) ~= "table" then return end
	
	if #self.elements == self.MaxElements then
		table.remove(self.elements, 1)
	end
	
	element.name = name or "Unhandled"
	element.rect = Rect()
	
	self.elements[#self.elements+1] = element
	
	if self.layoutfinished then
		self:OrganizeElements(#self.elements, #self.elements)
	end
end

function PANEL:AddPanel(panel)
	panel:SetParent(self)
	panel:SetTrapInsideParent(false)
	panel:SetObeyMargin(false)
	panel:SetVisible(false)
	
	self:AddElement(panel, "Panel")
end

function PANEL:AddText(text, fgcolor, bgcolor, font, fontsize)
	
	if not text then return end
	fgcolor = fgcolor or Color(1, 1, 1, 1)
	font = font or "tahoma.ttf"
	fontsize = fontsize or 10
	
	local struct = {
		["text"] = text,
		["fgcolor"] = fgcolor,
		["bgcolor"] = bgcolor,
		["font"] = font,
		["fontsize"] = fontsize,
		["spacewidth"] = self:GetTextSize(font, fontsize, " ").w,
		["height"] = self:GetTextSize(font, fontsize, "WTIKgjqp").h
	}
	
	if self.Wrap then
		if self.ByWord then
			struct.words = self:TextToWords(struct)
			self:AddElement(struct, "Words")
		else
			self:AddElement(struct, "TextWrap")
		end
	else
		self:AddElement(struct, "Text")
	end
	
end

function PANEL:AddCodedText(text)
	-- TODO
end

function PANEL:AddNewLine()
	self:AddElement({"\n"}, "String")
end

function PANEL:AddImage(path) end -- TODO
function PANEL:AddLink(link) end -- TODO

------------------------------------------------------------------------------------------------
-- Text Codes ---- Text Codes ---- Text Codes ---- Text Codes ---- Text Codes ---- Text Codes --
------------------------------------------------------------------------------------------------

local codes = {}

--[[

|--------------------------------------------------------------------------------------------------------------------------
| Codes 			| Name / Description 				| Final Arguments
|--------------------------------------------------------------------------------------------------------------------------
|#932# 				| Color of text.	 				| 9/9 red | 3/9 green | 2/9 blue |
|#932187#			| Color of text and background 		| 9/9 red | 3/9 green | 2/9 blue | 1/9 red | 8/9 green | 7/9 blue |
|#f12# = 			| Font size 						| 12 |
|#fn(tahoma.ttf) = 	| Font 								| tahoma.ttf |
|--------------------------------------------------------------------------------------------------------------------------
]]

codes["#%i"] = function() end

----------------------------------------------------------------------------------------------------
-- Text Functions ---- Text Functions ---- Text Functions ---- Text Functions ---- Text Functions --
----------------------------------------------------------------------------------------------------

function PANEL:GetTextSize(font, fontsize, text)
	return gui.GetTextSize(font, text) * Vec2(1, 1)
end


function PANEL:TextWidth(struct, from, to)
	local text = string.sub(struct.text, from or 1, to)
	return self:GetTextSize(struct.font, struct.fontsize, text).w
end

----------------------------------------------------------------------------------------
-- Helper Functions ---- Helper Functions ---- Helper Functions ---- Helper Functions --
----------------------------------------------------------------------------------------

function PANEL:NewLine()
	
	self.x = self.Margin.x
	
	if (#self.lines <= 0 and #self.newlines <= 0) or not self.line then
		self.y = self.Margin.y
	else
		self:AddToY(self.line.rect.h)
	end
	
	local line = {}
	
	if self.LineMargin then
		line.rect = Rect(self.LineMargin:GetPos(), self.Size-self.LineMargin:GetSize())
	else
		line.rect = Rect(0, self.y, self.Size.w, self.MinLineHeight)
	end
	line.children = {}
	line.color = ((#self.lines+#self.newlines)%2 == 0) and self.ColorA or self.ColorB
	
	self.line = line
	
	self.newlines[#self.newlines + 1] = self.line
end

function PANEL:AddToX(x)
	self.x = self.x + x
	if self.x > self.fullwidth then
		self.fullwidth = self.x
	end
end

function PANEL:AddToY(y)
	self.y = self.y + y
end

function PANEL:CalculateFullHeight()
	self.fullheight = 0
	
	for _,line in ipairs(self.lines)do
		self.fullheight = self.fullheight + line.rect.h
	end
end
--------------------------------------------------------------------------------------------------------------
-- Adjust Functions ---- Adjust Functions ---- Adjust Functions ---- Adjust Functions ---- Adjust Functions --
--------------------------------------------------------------------------------------------------------------

function PANEL:AdjustLineHeight(height)
	local lineheight = self.line.rect.h
	self.line.rect.h = math.max(lineheight, height)
	if lineheight > self.MaxLineHeight then self.line.rect.h = self.MaxLineHeight end
end

function PANEL:AdjustTextHeight(label, height)
	label.rect.h = height
	
	local textw = label.textr.w
	local texth = label.textr.h
	
	label.textr.x = label.rect.x + label.rect.w/2 - textw/2
	label.textr.y = label.rect.y + label.rect.h/2 - texth/2 - texth*label.struct.fontsize*0.015
end

function PANEL:AdjustPanelHeight(pnl, height)
	pnl:SetHeight(height)
end

----------------------------------------------------------------------------------------------------
-- Line Functions ---- Line Functions ---- Line Functions ---- Line Functions ---- Line Functions --
----------------------------------------------------------------------------------------------------

function PANEL:AddElementToLine(element)
	self.line.children[#self.line.children+1] = element
	
	element.visible = self:ElementIsVisible(element)
	
	self.visuals = self.visuals+1
end

function PANEL:AddTextToLine(struct, text, width, height)
	
	local font = struct.font
	local fontsize = struct.fontsize
	
	if not width or not height then
		local size = self:GetTextSize(font, fontsize, text)
		width = size.w
		height = size.h
	end
	
	local label = {}
	label.name = "Text"
	label.text = text
	label.rect = Rect(self.x, self.y, width, height+4)
	label.textr = Rect(self.x, self.y, width, height)
	label.struct = struct
	
	self:AdjustLineHeight(height+4)
	self:AddElementToLine(label)
	
	self:AddToX(width)
end

function PANEL:AddPanelToLine(pnl)
	
	pnl:SetPos(Vec2(self.x, self.y))
	
	self:AdjustLineHeight(pnl:GetHeight())
	self:AddElementToLine(pnl)
	
	self:AddToX(pnl:GetWidth())
end

------------------------------------------------------------------------------------------
-- Processes ---- Processes ---- Processes ---- Processes ---- Processes ---- Processes --
------------------------------------------------------------------------------------------

function PANEL:ProcessText(struct)
	local width = self:GetTextSize(struct.font, struct.fontsize, struct.text).w
	local height = struct.height
	
	self:AddTextToLine(struct, sturct.text, width, height)
end

function PANEL:ProcessTextWrap(struct)
	local width = self:GetTextSize(struct.font, struct.fontsize, struct.text).w
	local width2 = self:GetTextSize(struct.font, struct.fontsize, string.sub(struct.text, 1, 16)).w
	local height = struct.height
	
	if self.x + width <= self.areawidth or width2 >= self.areawidth then
		-- Text is short enough to fit on one line or collosal and just spam at that point
		self:AddTextToLine(struct, struct.text, nil, height)
	else
		-- Text is too long, break it down
		local textlength = string.len(struct.text)
		local i = 3
		for a=i, textlength do
			i = a
			if self.x + self:TextWidth(struct, 1, i) > self.areawidth then break end
			if i > textlength then break end
		end
		
		local oldtext = struct.text
		
		struct.text = string.sub(oldtext, 1, i-1)
		self:AddTextToLine(struct, struct.text, nil, height)
		
		struct.text = string.sub(oldtext, i)
		
		self:NewLine()
		self:ProcessText(struct)
		
		struct.text = oldtext
	end
end

function PANEL:ProcessWords(struct, i)
	
	i = i or 1
	
	if i>#struct.words then return end
	
	local words = struct.words
	local word = words[i]
	local text = word.text
	local width = word.width
	local height = struct.height
	
	if width > self.areawidth and string.len(text) <= 16 then
		for a=i, #words do
			i = a
			text = text.." "..words[a].text
			width = width + (words[a].isspace and 0 or struct.spacewidth) + words[a].width
		end
		self:AddTextToLine(struct, text, width, height)
		return
	end
	if width > self.areawidth then
		self:AddTextToLine(struct, word.text, width, height)
		self:NewLine()
		self:ProcessWords(struct, i+1)
		return
	end
	if self.x + width > self.areawidth then
		self:NewLine()
		self:ProcessWords(struct, i)
		return
	end
	
	for a=i+1, #words do
		i = a
		word = words[i]
		
		if not word then break end
		if self.x + width + (word.isspace and 0 or struct.spacewidth) + word.width > self.areawidth then break end
		
		width = width + (word.isspace and 0 or struct.spacewidth) + word.width
		text = text.." "..word.text
	end
	
	self:AddTextToLine(struct, text, width, height)
	
	if i+1 <= #words then
		self:NewLine()
		self:ProcessWords(struct, i)
	end
	
end

-- Processes a string code, new lines, tabs, etc..
function PANEL:ProcessString(element)
	local str = element[1]
	if str == "\n" then self:NewLine() end
end

-- Processes any panel
function PANEL:ProcessPanel(pnl)
	
	if pnl:GetWidth() > self.areawidth then -- Either panel is giant or lineviewer is tiny
		self:MarkForRemoval(pnl)
		return
	end
	
	if self.x + pnl:GetWidth() > self.areawidth then
		self:NewLine()
		self:AddPanelToLine(pnl)
	else
		self:AddPanelToLine(pnl)
	end

end

-- Base function for processing elements
--   Organizes and calls the correct processes for the element type.
function PANEL:ProcessElement(element)
	
	if self.x >= self.areawidth then self:NewLine() end
	
	local name = element.name
	if self["Process"..name] then
		self["Process"..name](self, element)
	end
end

--------------------------------------------------------------------------------------------------------
-- Layouts ---- Layouts ---- Layouts ---- Layouts ---- Layouts ---- Layouts ---- Layouts ---- Layouts --
--------------------------------------------------------------------------------------------------------

-- Organizes all the elements, reprocessing text and lines.
function PANEL:OrganizeElements(from, to, noupdate)
	
	if self.areawidth < 100 then return end
	
	if not noupdate then self.newlines = {} end
	
	if to > from then
		for i=from, to do
			self:ProcessElement(self.elements[i])
		end
	else
		self:ProcessElement(self.elements[from])
	end
	
	for k,v in ipairs(self.removals)do
		self:RemoveElement(v)
	end
	
	if noupdate then return end
	
	if #self.lines > 0 then
		local line = self.lines[#self.lines]
		for _,element in ipairs(line.children)do
			if self["Adjust"..element.name.."Height"] then
				self["Adjust"..element.name.."Height"](self, element, line.rect.h)
			end
		end
	end
	
	for _,line in ipairs(self.newlines)do
		for _,element in ipairs(line.children)do
			if self["Adjust"..element.name.."Height"] then
				self["Adjust"..element.name.."Height"](self, element, line.rect.h)
			end
		end
		line.visible = self:LineIsVisible(line)
		self.lines[#self.lines+1] = line
	end
	
	self.newlines = nil
	
	self:CalculateFullHeight()
	self:CalculateScrollbars()
	
	if self.StayOnBottom and self.onbottom then
		self:SetViewY(self:PercentToViewY(1))
	end
	
end

function PANEL:FinalizeLayout()
	self.process = 0
	self.nextlayout = nil
	self.layoutfinished = true
	
	self.lines = {}
	
	for _,line in ipairs(self.newlines)do
		for _,element in ipairs(line.children)do
			if self["Adjust"..element.name.."Height"] then
				self["Adjust"..element.name.."Height"](self, element, line.rect.h)
			end
		end
		line.visible = self:LineIsVisible(line)
		self.lines[#self.lines+1] = line
	end
	
	self.newlines = nil
	
	local onbottom = self.onbottom
	
	self:CalculateFullHeight()
	self:CalculateScrollbars()
	
	if self.StayOnBottom and onbottom then
		self:SetViewY(self:PercentToViewY(1))
	end
end

function PANEL:InitializeLayout()
	
	self.visuals = 0
	self.process = 1
	self.layoutfinished = false
	
	self.x = self.Margin.x
	self.y = self.Margin.y
	--self.lines = {}
	self.newlines = {}
	self.line = nil
	self.areawidth = self.Size.w - self.Margin:GetXW()
	self.areaheight = self.Size.h - self.Margin:GetYH()
	
	self:NewLine()
	
end

function PANEL:OnThink()
	if self.nextlayout and os.clock() >= self.nextlayout then
		self:DoLayout()
		return
	end
	if not self.nextupdate then self.nextupdate = os.clock() + 6 end
	if self.layoutfinished and os.clock() > self.nextupdate then
		self:DoLayout()
		self.nextupdate = os.clock() + 6
		return
	end
end

function PANEL:DoLayout()
	
	if #self.elements <= self.maxchunk then
		self:InitializeLayout()
		self:OrganizeElements(1, #self.elements, true)
		self:FinalizeLayout()
	elseif self.process == 0 then
		self:InitializeLayout()
		self:OrganizeElements(self.process, self.maxchunk, true)
		self.nextlayout = os.clock() + 0.25
	else
		self.process = self.process+self.maxchunk
		local to = self.process+self.maxchunk-1
		local final = false
		if to >= #self.elements then
			to = #self.elements
			final = true
		end
		self:OrganizeElements(self.process, to, true)
		if final then
			self:FinalizeLayout()
		else
			self.nextlayout = os.clock() + 0.25
		end
	end
	
end

function PANEL:OnRequestLayout()
	
	if self.LastSize and self:GetSize() == self.LastSize then return end
	self.LastSize = self:GetSize()
	
	self:DoLayout()
	
end

----------------------------------------------------------------------------------------------------
-- View ---- View ---- View ---- View ---- View ---- View ---- View ---- View ---- View ---- View --
----------------------------------------------------------------------------------------------------

function PANEL:GetViewMaxX()
	return self.fullwidth
end

function PANEL:GetViewMaxY()
	if self.SpaceBeneath then
		return self.fullheight
	else
		return self.fullheight - self.Size.h
	end
end

function PANEL:SetViewX(x)
	x = math.clamp(x, 0, self:GetViewMaxX())
	if x == self.viewx then return end
	self.viewx = x
	self:CalculateVisibleElements()
	self:CalculateScrollbars()
end

function PANEL:SetViewY(y)
	y = math.clamp(y, 0, self:GetViewMaxY())
	if y == self:GetViewMaxY() then self.onbottom = true else self.onbottom = false end
	if y == self.viewy then return end
	self.viewy = y
	self:CalculateVisibleElements()
	self:CalculateScrollbars()
end

function PANEL:SetViewPos(vec)
	if vec.x == self.viewx and vec.y == self.viewy then return end
	self.viewx = vec.x
	self.viewy = vec.y
	self:CalculateVisibleElements()
	self:CalculateScrollbars()
end

function PANEL:PercentToViewY(percent)
	return self:GetViewMaxY()*percent
end

function PANEL:ViewYToPercent()
	return self.viewy/(self:GetViewMaxY()+1)
end

function PANEL:YBarHeight()
	return math.max((self.Size.h / self.fullheight)*self.Size.h, 40)
end

function PANEL:YBarAreaHeight(height)
	return self.Size.h - (height or self:YBarHeight())
end

function PANEL:CalculateScrollbars()
	if self.XScroll and self.fullwidth > self.Size.w then
		self.xbar = {}
	else
		self.xbar = nil
	end
	
	if self.YScroll and self.fullheight > self.Size.h then
		self.ybar = Rect()
		self.ybar.x = self.Size.w - 10
		self.ybar.w = 10
		
		local height = self:YBarHeight()
		local areah = self:YBarAreaHeight(height)
		
		self.ybar.y = areah*self:ViewYToPercent()
		self.ybar.h = height
	else
		self.ybar = nil
	end
end

function PANEL:RectInView(rect)
	if rect.x > self.viewx + self.areawidth then return false end
	if rect.y > self.viewy + self.areaheight then return false end
	if rect.x + rect.w < self.viewx then return false end
	if rect.y + rect.h < self.viewy then return false end
	
	return true
end

function PANEL:TextIsVisible(text)
	return self:RectInView(text.rect)
end

function PANEL:PanelIsVisible(pnl)
	return self:RectInView(pnl:GetRect())
end

function PANEL:ElementIsVisible(element)
	if self[element.name.."IsVisible"] then
		return self[element.name.."IsVisible"](self, element)
	end
	return true
end

function PANEL:LineIsVisible(line)
	return self:RectInView(line.rect)
end

function PANEL:CalculateVisibleElements()
	
	for _,line in ipairs(self.lines)do
		local visible = self:LineIsVisible(line)
		line.visible = visible
		if line.visible then
			for _,element in ipairs(line.children)do
				local visible = self:ElementIsVisible(element)
				element.visible = visible
			end
		end
	end
end

------------------------------------------------------------------------------------------------------
-- Mouse Input ---- Mouse Input ---- Mouse Input ---- Mouse Input ---- Mouse Input ---- Mouse Input --
------------------------------------------------------------------------------------------------------


function PANEL:VecInRect(vec, rect)
	
	if 
		vec.x > rect.x and
		vec.y > rect.y and
		vec.x < rect.x + rect.w and
		vec.y < rect.y + rect.h then
		return true
	end
	
	return false
end

function PANEL:YBarMoveTo(y)
	local height = self:YBarHeight()
	local areah = self:YBarAreaHeight()
	
	y = y-height/2
	
	local percent = math.clamp(y/areah, 0, 1)
	
	self:SetViewY(self:PercentToViewY(percent))
	
end

function PANEL:YBarDrag(y)
	self:YBarMoveTo(y - self.ybaroffset + self:YBarHeight()/2)
end

function PANEL:YBarBeginDrag(y)
	self.ybaroffset = y - self.ybar.y
end

function PANEL:YBarEndDrag()
	self.ybaroffset = nil
end

function PANEL:OnMouseMove(pos, inpnl)
	if self.ybar and self.ybaroffset then
		if input.IsKeyDown("mouse1") then
			self:YBarDrag(pos.y)
		else
			self:YBarEndDrag()
		end
	end
	
	if not inpnl then return end
	
	if self.ybar then
		if self:VecInRect(pos, self.ybar) then
			self.ybarhighlight = true
		else
			self.ybarhighlight = false
		end
	end
end

function PANEL:OnMouseInput(button, press, pos)
	
	if button == "mouse1" then
		if self.ybar and pos.x > self.ybar.x then
			if self:VecInRect(pos, self.ybar) then
				if press then
					self:YBarBeginDrag(pos.y)
				end
			else
				self:YBarMoveTo(pos.y)
			end
		end
		
		if not press and self.ybaroffset then
			self:YBarEndDrag(pos.y)
		end
	end
	
	if button == "mwheel_down" then
		self:SetViewY(self.viewy + 18)
	end
	
	if button == "mwheel_up" then
		self:SetViewY(self.viewy - 18)
	end
end

--------------------------------------------------------------------------------------------------------
-- Drawing ---- Drawing ---- Drawing ---- Drawing ---- Drawing ---- Drawing ---- Drawing ---- Drawing --
--------------------------------------------------------------------------------------------------------

function PANEL:OnDraw()
	
	if self:GetDrawBackground() then
		gui.Draw("rect", Rect(0, 0, self:GetWidth(), self:GetHeight()), Color(0.1, 0.1, 0.1, 1))
	end
	
	local linedrew = false
	local elemdrew = false
	
	for _,line in ipairs(self.lines)do
		if not line.visible and linedrew then break end
		if line.visible then
			linedrew = true
			if self.DrawBackground then
				self:DrawLine(line)
			end
			for _,e in ipairs(line.children)do
				if not e.visible and elemdrew then break end
				elemdrew = true
				if e.visible then
					if self["Draw"..e.name] then
						self["Draw"..e.name](self, e)
					end
				end
			end
		end
	end
	
	if self.xbar then self:DrawXScrollbar() end
	if self.ybar then self:DrawYScrollbar() end
	
end

function PANEL:DrawXScrollbar()
	
end

function PANEL:DrawYScrollbar()
	gui.Draw("rect", self.ybar, Color(1, 1, 1, 0.35 + (self.ybarhighlight and 0.2 or 0)))
end

function PANEL:DrawLine(line)
	if line.visible and self:GetDrawBackground() then --and #line.children > 0 then
		gui.Draw("rect", line.rect-Rect(self.viewx, self.viewy, 0, 0), line.color)
	end
end

local testfont = surface.CreateFont("um", {path = R("fonts/tahoma.ttf")})

function PANEL:DrawText(element)
	
	if element.struct.bgcolor then
		gui.Draw("rect", element.rect-Rect(self.viewx, self.viewy, 0, 0), element.struct.bgcolor)
	end
	
	--local center = element.rect:GetPos() + element.rect:GetSize()/2
	--gui.DrawText(element.text, center, "default", 12, Color(1, 1, 1, 1))
	
	--do return end
	
	if element.struct.fgcolor then
		
		local font = element.struct.font
		font = testfont
		local fontsize = element.struct.fontsize
		local color = element.struct.fgcolor
		
		surface.SetFont(font)
		surface.SetColor(color:Unpack())
		
		local rect = element.rect
		local textr = element.textr
		
		surface.SetTextPos(textr.x-self.viewx, textr.y-self.viewy)
		surface.DrawText(element.text)
	end
end

function PANEL:DrawPanel(pnl)
	
	pnl:SetVisible(true)
	local oldpos = pnl:GetPos()
	pnl:SetPos(pnl:GetPos()-Vec2(self.viewx, self.viewy))
	pnl:OnDraw()
	pnl:SetPos(oldpos)
	pnl:SetVisible(false)
	
end

gui.RegisterPanel(PANEL)

