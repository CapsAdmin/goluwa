local syntax_process

do
	local lex_setup = require("langtoolkit.lexer")
	local reader = require("langtoolkit.reader")
	 
	local colors = {
		default = Color(255, 255, 255),
		keyword = Color(127, 159, 191),
		identifier = Color(223, 223, 223),
		string = Color(191, 127, 127),
		number = Color(127, 191, 127),
		operator = Color(191, 191, 159),
		ccomment = Color(159, 159, 159),
		cmulticomment = Color(159, 159, 159),
		comment = Color(159, 159, 159),
		multicomment = Color(159, 159, 159),
	}

	local translate = {
		TK_ge = colors.operator, 
		TK_le = colors.operator, 
		TK_concat = colors.operator, 
		TK_eq = colors.operator,
		TK_label = colors.operator,
		
		TK_dots = colors.operator,
		TK_number = colors.number,
		TK_string = colors.string,
		TK_name = colors.default,
		
		--TK_local = colors.comment,
		
		-- rest is keyword ??
	}

	function syntax_process(str, markup)
		reader.string_init(str)
		local ls = lex_setup(reader.string, str)

		local last_pos = 1
			
		for i = 1, 10000 do
			local ok, msg = pcall(ls.next, ls)
			
			if not ok then
				local tbl = msg:explode("\n")
				markup:AddString(str:sub(-ls.p))
				break
			end
				
			if #ls.token == 1 then
				markup:AddColor(colors.operator)
			else
				markup:AddColor(translate[ls.token] or colors.keyword)
			end
			markup:AddString(str:sub(last_pos-1, ls.p-2))
			
			last_pos = ls.p 
					
			if ls.token == "TK_eof" then break end
		end
		
		markup:AddString(str:sub(last_pos-1, last_pos))
		
		--table.print(syntax.)
		
		return out
	end  
end

local markup = Markup()

do	  
	markup:AddString("Hello markup test!\n\n有一些中國\nそして、いくつかの日本の\nكيف حول بعض عربية")

	markup:AddString[[
	
	
markup todo:
	caret real_x should prioritise pixel width
	y axis caret movement when the text is being wrapped
	divide this up in cells (new object?)
	proper tag stack
	the ability to edit (remove and copy) custom tags that have a size (like textures)
	]]
	
	local small_font = surface.CreateFont("small", {size = 8, read_speed = 100})

	markup:AddFont(small_font)
	markup:AddString("\nhere's some text in chinese:\n我寫了這個在谷歌翻譯，所以我可以測試我的標記語言使用Unicode正確。它似乎做工精細！\n")
	markup:AddString("some normal string again\n")
	markup:AddString("and another one\n")

	markup:AddFont("default")
	markup:AddString("back to normal!\n\n") 

	do	
		local icons = vfs.Find("textures/silkicons/.")
		local tags = ""
		for i = 1, 32 do
			local path = table.random(icons)
			tags = tags .. ("<texture=textures/silkicons/%s,2>%s"):format(path, i%16 == 0 and "\n" or "")
		end
		
		markup:AddString(tags, true) 
		markup:AddString("\n\n")
	end	

	syntax_process(
[[if CLIENT then
	if window and #window.GetSize() > 5 then 
		timer.Delay(0, function()
			include("tests/markup.lua")
		end)
	end
end
]], markup)
	
	local big_font = surface.CreateFont("big", {path = "fonts/arial.ttf", size = 30, read_speed = 100})
	 
	markup:AddFont(big_font)
	markup:AddColor(Color(0,255,0,255))
	markup:AddString("This font is huge and green for some reason!\n")
	markup:AddColor(Color(255, 255, 255, 255))
	markup:AddFont("default")  
	
	local big_font = surface.CreateFont("big2", {path = "fonts/verdana.ttf", size = 20, read_speed = 100})
	 
	markup:AddFont(big_font)
	markup:AddColor(Color(255,0,255,255))
	markup:AddString("This one is slightly smaller bug with a different font\n")
	markup:AddColor(Color(255, 255, 255, 255))
	markup:AddFont("default")  
	
	--markup:AddString("rotated grin<rotate=90>:D</rotate> \n", true)	
	--markup:AddString("that's <wrong>WRONG</wrong>\n", true)
	markup:AddString("Hey look it's gordon freeman!\n")
	markup:AddString("did you forget your <mark>eggs</mark>?\n", true)
	markup:AddString("no but that's <wrong>wierd</wrong>\n", true)
	markup:AddString("what's so <rotate=-3>wierd</rotate> about that?\n", true)
	markup:AddString("<hsv=[t()+input.rand/10],[(t()+input.rand)/100]>", true)
	markup:AddString("<rotate=1>i'm not sure it seems to be</rotate><rotate=-1>some kind of</rotate><physics=0,0>interference</physics>\n", true)
	markup:AddString("<scale=[((t()/10)%5^5)+1],1>you don't say</scale>\n", true)
	
	markup:AddString("smileys?")
	markup:AddString("\n")
	markup:AddString("<rotate=90>:D</rotate>", true)
	markup:AddString("<rotate=90>:)</rotate>", true)
	markup:AddString("<rotate=90>:(</rotate>", true)
	markup:AddString("<rotate=90>:P</rotate>", true)
	markup:AddString("<rotate=90>:O</rotate>", true)
	markup:AddString("<rotate=90>:]</rotate>", true)
	markup:AddString("<rotate=90></rotate>", true)-- FIX ME
	markup:AddString("\n")
	markup:AddString("maybe..\n\n")
	
	local big_font = surface.CreateFont("big3", {path = "fonts/looney.ttf", size = 50, read_speed = 100})
	markup:AddFont(big_font)
	local str = "That's all folks!"

	-- THERE IS NO LOGIC TO THIS 
	-- FIX MATRIXEZ!!!!!!!!!!
	-- START NONSENSE
	local i = 0
	for char in str:gmatch("(.)") do
		local frac = (i / #str)*math.pi 
		if i >= 1 then 
			frac = frac + 0.3
		end
		local ang = frac * 5.3 - 20
		local x = frac - ang*40 - 800
		local y = frac - ang
		markup:AddString(("<matrixez=%s,%s,1,1,%s>%s</matrixez>"):format(x, y, ang, char), true)
		i = i + 1
	end
	-- END OF NONSENSE
		
	markup:AddFont("default")
	markup:AddString("\n")
	markup:AddString([[
© 2012, Author
Self publishing
(Possibly email address or contact data)]])
end

markup:Invalidate()

if markup_frame and markup_frame:IsValid() then 
	markup_frame:Remove() 
end 
  
markup.chunk_fix = true
M = markup

local frame = aahh.Create("frame")
local panel = frame:CreatePanel("panel")

panel:Dock("fill")
frame:SetSize(1000, 1000)
panel:MakeActivePanel()
frame:RequestLayout(true) 

markup_frame = frame

function panel:OnDraw(size)
	local w,h = size:Unpack()
	
	surface.Color(0.1, 0.1, 0.1, 1)
	surface.DrawRect(0,0, w, h)
	
	surface.Color(1, 1, 1, 0.1)
	surface.DrawRect(0,0, markup.width or w, markup.height or h)
	
	-- this is needed for proper mouse coordinates
	local x, y = self:GetWorldPos():Unpack()
	markup:Draw(x, y, size:Unpack())
end

function panel:OnRequestLayout()
	markup:SetMaxWidth(self:GetWidth()) 
end

function panel:OnMouseInput(button, press)
	markup:OnMouseInput(button, press, window.GetMousePos():Unpack())
end

function panel:OnKeyInput(key, press)
	
	if key == "left_shift" or key == "right_shift" then  markup:SetShiftDown(press) end
	if key == "left_control" or key == "right_control" then  markup:SetControlDown(press) end
	
	if press then
		markup:OnKeyInput(key)
		
		if markup.ControlDown and key == "z" then
			include("tests/markup.lua")
		end
	end
end

function panel:OnCharInput(char)
	markup:OnCharInput(char)
end

