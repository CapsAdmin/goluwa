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

local function syntax_process(str)
	reader.string_init(str)
	local ls = lex_setup(reader.string, str)

	local last_pos = 1
	local out = {}
		
	for i = 1, 10000 do
		local ok, msg = pcall(ls.next, ls)
		
		if not ok then
			local tbl = msg:explode("\n")
			table.insert(out, str:sub(-ls.p))
			break
		end
			
		if #ls.token == 1 then
			table.insert(out, colors.operator)
		else
			table.insert(out, translate[ls.token] or colors.keyword)
		end
		table.insert(out, str:sub(last_pos-1, ls.p-2))
		
		last_pos = ls.p 
				
		if ls.token == "TK_eof" then break end
	end
	
	out[#out] = out[#out] .. str:sub(last_pos-1, last_pos)
	
	--table.print(syntax.)
	
	return out
end  
  
local str = vfs.Read("lua/goluwa/libraries/markup.lua"):sub(0, 1000)
  
if markup_frame and markup_frame:IsValid()
 then markup_frame:Remove() end 
  
local frame = aahh.Create("frame")
local panel = frame:CreatePanel("panel")
panel:Dock("fill")

frame:SetSize(500, 500)
 
local markup = Markup()
markup.chunk_fix = true
markup:SetTable(syntax_process(str))

markup.OnTextChanged = function(self, str)
	if not markup.chunk_fix then
		self:SetTable(syntax_process(str))
	end
end

markup.OnInvalidate = function()
	--markup:SetTable()
end

function panel:OnDraw(size)
	surface.Color(0.1, 0.1, 0.1, 1)
	surface.DrawRect(0,0, size:Unpack())
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

panel:MakeActivePanel()
frame:RequestLayout(true) 

M = markup
markup_frame = frame