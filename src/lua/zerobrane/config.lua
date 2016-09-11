local G = ...

local default_project_dir = "../../"
local default_file = "/src/lua/examples/hello_world.lua"
local default_interpreter = "goluwa"

editor.usetabs = true
editor.tabwidth = 4
editor.usewrap = false
editor.fontsize = 9
editor.fontname = "Oxygen Mono"
editor.menuicon = true
bordersize = 4

--staticanalyzer.infervalue = true
--filetree.mousemove = false

excludelist = {
	"capsadmin/",
	"data/",
	"goluwa_ffmpeg/",
	"private/",
	"megahal/",
	"love_games/",
	"TinyC/",
	"vlc/",
	"wiki/",
	"vlc/",
	"shell32/",
	"chromium/",
	"src/languages/",
	"src/lua/modules/",
}

binarylist = {
	"*.md",
	"AUTHORS",
	"COPYING",
}


do
	local math = G.math

	local function h2d(n) return 0+('0x'..n) end
	local function H(c, mult) c = c:gsub('#','')
		mult = mult or 1
		-- since alpha is not implemented, convert RGBA to RGB
		-- assuming 0 is transparent and 255 is opaque
		-- based on http://stackoverflow.com/a/2645218/1442917
		local a = #c > 6 and h2d(c:sub(7,8))/255 or 1
		local r, g, b = h2d(c:sub(1,2)), h2d(c:sub(3,4)), h2d(c:sub(5,6))
		r = r * mult
		g = g * mult
		b = b * mult
		return {
			math.min(255, math.floor((1-a)+a*r)),
			math.min(255, math.floor((1-a)+a*g)),
			math.min(255, math.floor((1-a)+a*b))
		}
	end

	local C = {
		Background	= H'232629',
		CurrentLine = H('3daee9', 0.25),
		Selection   = H('3daee9', 0.5),
		Foreground	= H'eaebec',
		Comment     = H'8e908c',
		Red         = H'da4453',
		Orange      = H'f5871f',
		Yellow      = H'fdbc4b',
		Green       = H'27ae60',
		Aqua        = H'3daee9',
		Blue        = H'2980b9',
		Purple      = H'f67400',
	}

	local function lerp(m, a, b)
		return (b - a) * m + a
	end

	--[[for k,v in G.pairs(C) do
		if k ~= "Background" then
			for i = 1, 3 do
				v[i] = math.floor(lerp(0.025, v[i], C.Background[i]))
			end
		end
	end]]

	-- add more of the specified color (keeping all in 0-255 range)
	local mixer = function(c, n, more)
		if not c or #c == 0 then return c end
		local c = {c[1], c[2], c[3]} -- create a copy, so it can be modified
		c[n] = c[n] + more
		local excess = c[n] - 255
		if excess > 0 then
			for clr = 1, 3 do
				c[clr] = n == clr and 255 or c[clr] > excess and c[clr] - excess or 0
			end
		end
		return c
	end

	-- wxstc.wxSTC_LUA_DEFAULT
	styles.lexerdef = {fg = C.Foreground}
	-- wxstc.wxSTC_LUA_COMMENT, wxstc.wxSTC_LUA_COMMENTLINE, wxstc.wxSTC_LUA_COMMENTDOC
	styles.comment = {fg = C.Comment, fill = true}
	-- wxstc.wxSTC_LUA_STRING, wxstc.wxSTC_LUA_CHARACTER, wxstc.wxSTC_LUA_LITERALSTRING
	styles.stringtxt = {fg = C.Green}
	-- wxstc.wxSTC_LUA_STRINGEOL
	styles.stringeol = {fg = C.Green, fill = true}
	-- wxstc.wxSTC_LUA_PREPROCESSOR
	styles.preprocessor = {fg = C.Orange}
	-- wxstc.wxSTC_LUA_OPERATOR
	styles.operator = {fg = C.Red}
	-- wxstc.wxSTC_LUA_NUMBER
	styles.number = {fg = C.Red}

	-- wxstc.wxSTC_LUA_WORD, wxstc.wxSTC_LUA_WORD2-8
	styles.keywords0 = {fg = C.Blue, b = true}
	styles.keywords1 = {fg = C.Aqua, b = false}
	styles.keywords2 = {fg = C.Aqua, b = true}
	styles.keywords3 = {fg = C.Purple, b = false}
	styles.keywords4 = {fg = C.Purple, b = false}
	styles.keywords5 = {fg = C.Purple, b = false}
	styles.keywords6 = {fg = C.Purple, b = false}
	styles.keywords7 = {fg = C.Purple, b = false}

	-- common (inherit fg/bg from text)
	-- wxstc.wxSTC_LUA_IDENTIFIER
	styles.text = {fg = C.Foreground, bg = C.Background}
	styles.linenumber = {fg = C.Comment}
	styles.bracematch = {fg = C.Orange, b = true}
	styles.bracemiss = {fg = C.Red, b = true}
	styles.ctrlchar = {fg = C.Yellow}
	styles.indent = {fg = C.Comment}
	styles.calltip = nil

	-- common special (need custom fg & bg)
	styles.sel = {bg = C.Selection}
	styles.caret = {fg = C.Foreground}
	styles.caretlinebg = {bg = C.CurrentLine}
	styles.fold = {fg = C.Comment, bg = C.Background, sel = mixer(C.Comment, 1, 96)}
	styles.whitespace = {fg = C.Comment, bg = C.Background}
	styles.edge = {}

	styles.indicator = {
		fncall = {fg = C.Purple, st = wxstc.wxSTC_INDIC_HIDDEN},
		--[[ other possible values are:
			wxSTC_INDIC_PLAIN	 Single-line underline
			wxSTC_INDIC_SQUIGGLE Squiggly underline
			wxSTC_INDIC_TT	 Line of small T-shapes
			wxSTC_INDIC_DIAGONAL Diagonal hatching
			wxSTC_INDIC_STRIKE	 Strike-out
			wxSTC_INDIC_BOX			Box
			wxSTC_INDIC_ROUNDBOX Rounded Box
		--]]
		-- these indicators have all different default styles
		varlocal = {fg = C.Foreground},
		varglobal = {fg = C.Foreground},
		varmasked = {fg = C.Foreground},
		varmasking = {fg = C.Foreground},
	}

	-- markup
	styles['['] = {hs = mixer(C.Comment, 3, 64)}
	styles['|'] = {fg = mixer(mixer(C.Comment, 1, 64), 3, 64)}

	-- markers
	styles.marker = {
		message = {bg = C.Selection},
		output = {bg = C.CurrentLine},
		prompt = {fg = C.Foreground, bg = C.Background},
		error = {bg = mixer(C.Background, 1, 32)},
	}

	stylesoutshell = styles -- apply the same scheme to Output/Console windows
	styles.auxwindow = styles.text -- apply text colors to auxiliary windows
	styles.calltip = styles.text -- apply text colors to tooltips

	styles.indicator.varglobal = nil
	styles.indicator.varlocal = nil
	styles.indicator = nil
end

package.path = package.path .. ";../../src/lua/modules/?.lua"
package.path = package.path .. ";../../src/lua/modules/?/init.lua"
package.path = package.path .. ";../../src/lua/modules/?/?.lua"

package("packages/") -- relative to config.lua

local temp
temp = ide:AddTimer(wx.wxGetApp(), function()
	temp:Stop()
	
	do -- set default project directory
		local obj = wx.wxFileName(default_project_dir)
		obj:Normalize()
		
		ProjectUpdateProjectDir(obj:GetFullPath())
	end
			
	do -- open default file
		if #ide:GetDocuments() == 0 then
			LoadFile(ide.config.path.projectdir .. default_file)
		end
	end
	
	do -- set default interpreter
		ProjectSetInterpreter(default_interpreter)
	end
end)    
temp:Start(0.1,false)  
