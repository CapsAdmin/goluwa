local syntax_process

do
	local lex_setup = require("lang.lexer")
	local reader = require("lang.reader")
	local colors = {
		default = ColorBytes(255, 255, 255),
		keyword = ColorBytes(127, 159, 191),
		identifier = ColorBytes(223, 223, 223),
		string = ColorBytes(191, 127, 127),
		number = ColorBytes(127, 191, 127),
		operator = ColorBytes(191, 191, 159),
		ccomment = ColorBytes(159, 159, 159),
		cmulticomment = ColorBytes(159, 159, 159),
		comment = ColorBytes(159, 159, 159),
		multicomment = ColorBytes(159, 159, 159),
	}
	local translate = {
		TK_ge = colors.operator,
		TK_le = colors.operator,
		TK_concat = colors.operator,
		TK_eq = colors.operator,
		TK_label = colors.operator,
		["#"] = colors.operator,
		["]"] = colors.operator,
		[">"] = colors.operator,
		["/"] = colors.operator,
		["{"] = colors.operator,
		["}"] = colors.operator,
		[":"] = colors.operator,
		["*"] = colors.operator,
		["["] = colors.operator,
		["("] = colors.operator,
		[")"] = colors.operator,
		["+"] = colors.operator,
		[","] = colors.operator,
		["="] = colors.operator,
		["."] = colors.operator,
		["<"] = colors.operator,
		["-"] = colors.operator,
		[""] = colors.operator,
		TK_dots = colors.operator,
		TK_else = colors.keyword,
		TK_goto = colors.keyword,
		TK_if = colors.keyword,
		TK_nil = colors.keyword,
		TK_end = colors.keyword,
		TK_or = colors.keyword,
		TK_return = colors.keyword,
		TK_true = colors.keyword,
		TK_elseif = colors.keyword,
		TK_function = colors.keyword,
		TK_while = colors.keyword,
		TK_and = colors.keyword,
		TK_then = colors.keyword,
		TK_in = colors.keyword,
		TK_for = colors.keyword,
		TK_do = colors.keyword,
		TK_for = colors.keyword,
		TK_false = colors.keyword,
		TK_break = colors.keyword,
		TK_not = colors.keyword,
		TK_local = colors.keyword,
		TK_ne = colors.keyword,
		["/37"] = colors.keyword,
		TK_number = colors.number,
		TK_string = colors.string,
		TK_name = colors.default,
	}

	function syntax_process(str, markup)
		markup:AddString(str)

		do
			return
		end

		local ls = lex_setup(reader.string(str), str)
		local last_pos = 1
		local last_color

		for _ = 1, 1000000 do
			if not pcall(ls.next, ls) then
				markup:AddString(str)
				return
			end

			if #ls.token == 1 then
				local color = colors.operator

				if color ~= last_color then
					markup:AddColor(color)
					last_color = color
				end
			else
				local color = translate[ls.token] or colors.comment

				if color ~= last_color then
					markup:AddColor(color)
					last_color = color
				end
			end

			if not ls.p then break end

			markup:AddString(str:sub(last_pos - 1, ls.p - 2))
			last_pos = ls.p

			if ls.token == "TK_eof" then break end
		end

		markup:AddString(str:sub(last_pos - 1, last_pos - 2))
	end
end

local panel = gui.CreatePanel("frame", nil, "lol")
panel:SetSize(Vec2() + 300)
--panel:CenterSimple()
--panel:SetResizable(true)
local scroll = gui.CreatePanel("scroll", panel)
scroll:SetXScrollBar(true)
scroll:SetYScrollBar(true)
scroll:SetupLayout("fill")
--scroll:SetPadding(Rect()+4)
local lol = gui.CreatePanel("text_edit")
--lol:SetWidth(300)
--lol:SetObeyPanelWidth(true)
--lol:SetTextWrap(true)
lol:SetMultiline(true)
syntax_process(vfs.Read("lua/libraries/graphics/gfx/markup.lua"), lol.label.markup)
scroll:SetPanel(lol)