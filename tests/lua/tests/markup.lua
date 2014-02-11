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
	
	TK_number = colors.number,
	TK_string = colors.string,
	TK_name = colors.default,
	
	--TK_local = colors.comment,
	
	-- rest is keyword ??
}

local function syntax_process(str)

	reader.string_init(str)
	local ls = lex_setup(reader.string, str)

	local last_pos = 1
	local out = {}
	
	for i = 1, 10000 do
		local ok, msg = pcall(ls.next, ls)
		 
		if not ok then
			local tbl = msg:explode("\n")
			print(tbl[#tbl])
			table.insert(out, str:sub(-ls.p))
			break
		end
		
		table.insert(out, translate[ls.token] or colors.keyword)
		table.insert(out, str:sub(last_pos-1, ls.p-2))
		
		last_pos = ls.p
		
		if ls.token == "TK_eof" then break end
	end

	table.insert(out, str:sub(last_pos-1, last_pos))
	
	--table.print(syntax.)
	
	return out
end 

local str = vfs.Read("lua/goluwa/libraries/markup.lua"):sub(0, 505)
 
local m = Markup()
m:SetEditMode(true)
     
m:SetTable(syntax_process(str))

m.OnTextChanged = function(self, str)
	self:SetTable(syntax_process(str))
end

M = m

event.AddListener("OnDraw2D", "markup", function()
	
	if input.IsMouseDown("button_2") then
		local x = window.GetMousePos().x
		
		m:SetMaxWidth(x) 
		
		surface.Color(1,1,1,1)
		surface.DrawLine(x, 0, x, 1000)
	end

	m:Draw()
end)     

event.AddListener("OnMouseInput", "markup", function(button, press)
	m:OnMouseInput(button, press, window.GetMousePos():Unpack())
end)

event.AddListener("OnKeyInput", "markup", function(key, press)
	m:OnKeyInput(key, press)
end)

event.AddListener("OnChar", "markup", function(char)
	m:OnCharInput(char)
end)