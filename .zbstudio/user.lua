(...).setfenv(1, ...)

local print = DisplayOutputLn
local root = "C:/goluwa/"

do -- apply a dark style
	ide.styles = loadfile('cfg/tomorrow.lua')('TomorrowNightEighties')
	ide.stylesoutshell = ide.styles -- apply the same scheme to Output/Console windows
	ide.styles.auxwindow = ide.styles.text -- apply text colors to auxiliary windows
	ide.styles.calltip = ide.styles.text -- apply text colors to tooltips
end

do -- config
	local config = ide.config
	
	config.editor.usetabs = true
	config.editor.tabwidth = 4
	--config.path.wdir = root .. [[.base\bin\windows\x86\]]
	--config.path.gslshell = root .. [[.base\bin\windows\x86\luajit.exe]]
end

function get_text()
	local editor = GetEditor()
	local pos = editor:GetCurrentPosition()
	-- don't do auto-complete in comments or strings.
	-- the current position and the previous one have default style (0),
	-- so we need to check two positions back.
	local style = pos >= 2 and bit.band(editor:GetStyleAt(pos-2),31) or 0
	if editor.spec.iscomment[style] or editor.spec.isstring[style] then return end

	-- retrieve the current line and get a string to the current cursor position in the line
	local line = editor:GetCurrentLine()
	local linetx = editor:GetLine(line)
	local linestart = editor:PositionFromLine(line)
	local localpos = pos-linestart

	local lt = linetx:sub(1,localpos)
	lt = lt:gsub("%s*(["..editor.spec.sep.."])%s*", "%1")
	-- strip closed brace scopes
	lt = lt:gsub("%b()","")
	lt = lt:gsub("%b{}","")
	lt = lt:gsub("%b[]",".0")
	-- match from starting brace
	lt = lt:match("[^%[%(%{%s,]*$")

	return lt
end

local bin = ".base/bin/" .. jit.os:lower() ..	"_" .. "x86" .. "/"

local sockets = require("socket")

local port = 16273
local socket = sockets.tcp()
socket:settimeout(0)
local connected = false
local ready = false

local lua = ""..
"ZEROBRANE_LINEINPUT=sockets.CreateServer([[tcp]],[[localhost]],"..port..")"..
"ZEROBRANE_LINEINPUT.OnClientConnected=function(s,client)return\32true\32end;"..
"ZEROBRANE_LINEINPUT.OnReceive=function(s,str)console.RunString(str)end;"..
"zb=function(s)ZEROBRANE_LINEINPUT:Broadcast(s)print(s)end;"..
"ZEROBRANE_LINEINPUT.debug=true"

local PLUGIN = {
	name = "Goluwa",
	description = "",
	author = "CapsAdmin",
	version = 0.1,
}

function PLUGIN:onLineInput(str)
	socket:send(str)
end

function PLUGIN:onEditorCharAdded(editor, event)
	local char = string.char(event:GetKey())
	
end

function PLUGIN:onIdle()
	if ready then 	
		if not connected and socket:connect("localhost", port) then
			connected = true
		end
	end
	
	if not connected then return end
	
	local res = socket:receive("*a")
	if res then print(res) end
end

ide.packages["goluwa"] = setmetatable(PLUGIN, ide.proto.Plugin)

local INTERPRETER = {
	name = "Goluwa",
	description = "A game framework written in luajit",
	hasdebugger = true,
	api = {"baselib"},
	unhideanywindow = true,
}

function INTERPRETER:frun(wfile, run_debug)

	local file_path = wfile:GetFullPath()
	local temp_file 
	
	-- if running on Windows and can't open the file, this may mean that
	-- the file path includes unicode characters that need special handling
	local fh = io.open(file_path, "r")
	if fh then fh:close() end
	if ide.osname == 'Windows' and pcall(require, "winapi") and wfile:FileExists() and not fh then
		winapi.set_encoding(winapi.CP_UTF8)
		file_path = winapi.short_path(file_path)
	end

	file_path = file_path:gsub("\\", "/")
		
	if run_debug then
		DebuggerAttachDefault({startwith = file_path, allowediting = true})

		local temp = wx.wxFileName()
		temp:AssignTempFileName(".")
		temp_file = temp:GetFullPath()
		local f = io.open(temp_file, "w")
		if not f then
			DisplayOutput("Can't open temporary file '"..temp_file.."' for writing\n")
			return
		end
		f:write(run_debug)
		f:close()
	end
	
	-- modify CPATH to work with other Lua versions
	local _, cpath = wx.wxGetEnv("LUA_CPATH")
	
	if cpath then
		wx.wxSetEnv("LUA_CPATH", cpath:gsub("/clibs/", "/clibs51/"))
	end
	
	
	--callback = function(...) CONSOLE_OUT(...) end
	local fmt = "%q -e \"io.stdout:setvbuf('no')SERVER=true;DISABLE_CURSES=true;ARGS={'include[[%s]]%s'};dofile'%s'\""
	local pid = ide:ExecuteCommand(
		fmt:format(root .. bin .. "luajit", file_path, lua, root .. ".base/lua/init.lua"),
		root .. bin,
		function(s) CONSOLE_OUT(s) end,
		function() if run_debug then wx.wxRemoveFile(temp_file) end connected = false ready = false end
	)
	--callback = nil

	if cpath then
		wx.wxSetEnv("LUA_CPATH", cpath)
	end
	
	ready = true

	return pid
end

function INTERPRETER:fprojdir(wfilename)
	return wfilename:GetPath(wx.wxPATH_GET_VOLUME)
end

function INTERPRETER:fworkdir()
	return ide.config.path.projectdir .. "/" .. bin
end

function INTERPRETER:fattachdebug() 
	DebuggerAttachDefault() 
end

ide:AddInterpreter("goluwa", INTERPRETER)

ProjectSetInterpreter("goluwa")

do
	--ide.frame.bottomnotebook:RemovePage(0)

	local shellbox = wxstc.wxStyledTextCtrl(ide.frame.bottomnotebook, wx.wxID_ANY, wx.wxDefaultPosition, wx.wxDefaultSize, wx.wxBORDER_NONE)
	ide.frame.bottomnotebook:AddPage(shellbox, TR("Remote console"), false)
	SetupKeywords(shellbox,"lua",nil,ide.config.stylesoutshell,ide.font.oNormal,ide.font.oItalic)
		
	-- Copyright 2011-14 Paul Kulchenko, ZeroBrane LLC
	-- authors: Luxinia Dev (Eike Decker & Christoph Kubisch)
	---------------------------------------------------------

	local ide = ide
	local unpack = table.unpack or unpack
	--
	-- shellbox - a lua testbed environment within the IDE
	--

	local bottomnotebook = ide.frame.bottomnotebook
	local out = shellbox
	local remotesend

	local PROMPT_MARKER = StylesGetMarker("prompt")
	local PROMPT_MARKER_VALUE = 2^PROMPT_MARKER
	local ERROR_MARKER = StylesGetMarker("error")
	local OUTPUT_MARKER = StylesGetMarker("output")
	local MESSAGE_MARKER = StylesGetMarker("message")

	out:SetFont(ide.font.oNormal)
	out:StyleSetFont(wxstc.wxSTC_STYLE_DEFAULT, ide.font.oNormal)
	out:SetBufferedDraw(not ide.config.hidpi and true or false)
	out:StyleClearAll()

	out:SetTabWidth(ide.config.editor.tabwidth or 2)
	out:SetIndent(ide.config.editor.tabwidth or 2)
	out:SetUseTabs(ide.config.editor.usetabs and true or false)
	out:SetViewWhiteSpace(ide.config.editor.whitespace and true or false)
	out:SetIndentationGuides(true)

	out:SetWrapMode(wxstc.wxSTC_WRAP_WORD)
	out:SetWrapStartIndent(0)
	out:SetWrapVisualFlagsLocation(wxstc.wxSTC_WRAPVISUALFLAGLOC_END_BY_TEXT)
	out:SetWrapVisualFlags(wxstc.wxSTC_WRAPVISUALFLAG_END)

	out:MarkerDefine(StylesGetMarker("prompt"))
	out:MarkerDefine(StylesGetMarker("error"))
	out:MarkerDefine(StylesGetMarker("output"))
	out:MarkerDefine(StylesGetMarker("message"))
	out:SetReadOnly(false)

	SetupKeywords(out,"lua",nil,ide.config.stylesoutshell,ide.font.oNormal,ide.font.oItalic)

	local function getPromptLine()
		local totalLines = out:GetLineCount()
		return out:MarkerPrevious(totalLines+1, PROMPT_MARKER_VALUE)
	end

	local function getPromptText()
		local prompt = getPromptLine()
		return out:GetTextRange(out:PositionFromLine(prompt), out:GetLength())
	end

	local function setPromptText(text)
		local length = out:GetLength()
		out:SetTargetStart(length - string.len(getPromptText()))
		out:SetTargetEnd(length)
		out:ReplaceTarget(text)
		-- refresh the output window to force recalculation of wrapped lines;
		-- otherwise a wrapped part of the last line may not be visible.
		out:Update(); out:Refresh()
		out:GotoPosition(out:GetLength())
	end

	local function positionInLine(line)
		return out:GetCurrentPosition() - out:PositionFromLine(line)
	end

	local function caretOnPromptLine(disallowLeftmost, line)
		local promptLine = getPromptLine()
		local currentLine = line or out:GetCurrentLine()
		local boundary = disallowLeftmost and 0 or -1
		return (currentLine > promptLine
			or currentLine == promptLine and positionInLine(promptLine) > boundary)
	end

	local function chomp(line)
		return line:gsub("%s+$", "")
	end

	local function getInput(line)
		local nextMarker = line
		local count = out:GetLineCount()

		repeat -- check until we find at least some marker
			nextMarker = nextMarker+1
		until out:MarkerGet(nextMarker) > 0 or nextMarker > count-1
		return chomp(out:GetTextRange(out:PositionFromLine(line),
																	out:PositionFromLine(nextMarker)))
	end

	local currentHistory
	local function getNextHistoryLine(forward, promptText)
		local count = out:GetLineCount()
		if currentHistory == nil then currentHistory = count end

		if forward then
			currentHistory = out:MarkerNext(currentHistory+1, PROMPT_MARKER_VALUE)
			if currentHistory == -1 then
				currentHistory = count
				return ""
			end
		else
			currentHistory = out:MarkerPrevious(currentHistory-1, PROMPT_MARKER_VALUE)
			if currentHistory == -1 then
				return ""
			end
		end
		-- need to skip the current prompt line
		-- or skip repeated commands
		if currentHistory == getPromptLine()
		or getInput(currentHistory) == promptText then
			return getNextHistoryLine(forward, promptText)
		end
		return getInput(currentHistory)
	end

	local function getNextHistoryMatch(promptText)
		local count = out:GetLineCount()
		if currentHistory == nil then currentHistory = count end

		local current = currentHistory
		while true do
			currentHistory = out:MarkerPrevious(currentHistory-1, PROMPT_MARKER_VALUE)
			if currentHistory == -1 then -- restart search from the last item
				currentHistory = count
			elseif currentHistory ~= getPromptLine() then -- skip current prompt
				local input = getInput(currentHistory)
				if input:find(promptText, 1, true) == 1 then return input end
			end
			-- couldn't find anything and made a loop; get out
			if currentHistory == current then return end
		end

		assert(false, "getNextHistoryMatch coudn't find a proper match")
	end

	local function shellPrint(marker, ...)
		local cnt = select('#',...)
		if cnt == 0 then return end -- return if nothing to print

		local isPrompt = marker and (getPromptLine() > -1)

		local text = ''
		for i=1,cnt do
			local x = select(i,...)
			text = text .. tostring(x)..(i < cnt and "\t" or "")
		end
		-- add "\n" if it is missing
		if text then text = text:gsub("\n+$", "") .. "\n" end

		local lines = out:GetLineCount()
		local promptLine = isPrompt and getPromptLine() or nil
		local insertLineAt = isPrompt and getPromptLine() or out:GetLineCount()-1
		local insertAt = isPrompt and out:PositionFromLine(getPromptLine()) or out:GetLength()
		out:InsertText(insertAt, FixUTF8(text, function (s) return '\\'..string.byte(s) end))
		local linesAdded = out:GetLineCount() - lines

		if marker then
			if promptLine then out:MarkerDelete(promptLine, PROMPT_MARKER) end
			for line = insertLineAt, insertLineAt + linesAdded - 1 do
				out:MarkerAdd(line, marker)
			end
			if promptLine then out:MarkerAdd(promptLine+linesAdded, PROMPT_MARKER) end
		end

		out:EmptyUndoBuffer() -- don't allow the user to undo shell text
		out:GotoPosition(out:GetLength())
		out:EnsureVisibleEnforcePolicy(out:GetLineCount()-1)
	end

	local DisplayShell = function (...)
		shellPrint(OUTPUT_MARKER, ...)
	end
	local DisplayShellErr = function (...)
		shellPrint(ERROR_MARKER, ...)
	end
	local DisplayShellMsg = function (...)
		shellPrint(MESSAGE_MARKER, ...)
	end
	local DisplayShellDirect = function (...)
		shellPrint(nil, ...)
	end
	local DisplayShellPrompt = function (...)
		-- don't print anything; just mark the line with a prompt mark
		out:MarkerAdd(out:GetLineCount()-1, PROMPT_MARKER)
	end
	
	CONSOLE_OUT = DisplayShell
	
	local function executeShellCode(tx)
		if tx == nil or tx == '' then return end

		DisplayShellPrompt('')
		
		PLUGIN:onLineInput(tx)
	end

	out:Connect(wx.wxEVT_KEY_DOWN,
		function (event)
			-- this loop is only needed to allow to get to the end of function easily
			-- "return" aborts the processing and ignores the key
			-- "break" aborts the processing and processes the key normally
			while true do
				local key = event:GetKeyCode()
				if key == wx.WXK_UP or key == wx.WXK_NUMPAD_UP then
					-- if we are below the prompt line, then allow to go up
					-- through multiline entry
					if out:GetCurrentLine() > getPromptLine() then break end

					-- if we are not on the caret line, move normally
					if not caretOnPromptLine() then break end

					local promptText = getPromptText()
					
					setPromptText(getNextHistoryLine(false, promptText))
					return
				elseif key == wx.WXK_DOWN or key == wx.WXK_NUMPAD_DOWN then
					-- if we are above the last line, then allow to go down
					-- through multiline entry
					local totalLines = out:GetLineCount()-1
					if out:GetCurrentLine() < totalLines then break end

					-- if we are not on the caret line, move normally
					if not caretOnPromptLine() then break end

					local promptText = getPromptText()
					setPromptText(getNextHistoryLine(true, promptText))
					return
				elseif key == wx.WXK_TAB then
					-- if we are above the prompt line, then don't move
					local promptline = getPromptLine()
					if out:GetCurrentLine() < promptline then return end

					local promptText = getPromptText()
					-- save the position in the prompt text to restore
					local pos = out:GetCurrentPosition()
					local text = promptText:sub(1, positionInLine(promptline))
					if #text == 0 then return end

					-- find the next match and set the prompt text
					local match = getNextHistoryMatch(text)
					if match then
						setPromptText(match)
						-- restore the position to make it easier to find the next match
						out:GotoPosition(pos)
					end
					return
				elseif key == wx.WXK_ESCAPE then
					setPromptText("")
					return
				elseif key == wx.WXK_BACK then
					if not caretOnPromptLine(true) then return end
				elseif key == wx.WXK_DELETE or key == wx.WXK_NUMPAD_DELETE then
					if not caretOnPromptLine()
					or out:LineFromPosition(out:GetSelectionStart()) < getPromptLine() then
						return
					end
				elseif key == wx.WXK_PAGEUP or key == wx.WXK_NUMPAD_PAGEUP
						or key == wx.WXK_PAGEDOWN or key == wx.WXK_NUMPAD_PAGEDOWN
						or key == wx.WXK_END or key == wx.WXK_NUMPAD_END
						or key == wx.WXK_HOME or key == wx.WXK_NUMPAD_HOME
						or key == wx.WXK_LEFT or key == wx.WXK_NUMPAD_LEFT
						or key == wx.WXK_RIGHT or key == wx.WXK_NUMPAD_RIGHT
						or key == wx.WXK_SHIFT or key == wx.WXK_CONTROL
						or key == wx.WXK_ALT then
					break
				elseif key == wx.WXK_RETURN or key == wx.WXK_NUMPAD_ENTER then
					if not caretOnPromptLine()
					or out:LineFromPosition(out:GetSelectionStart()) < getPromptLine() then
						return
					end

					-- allow multiline entry for shift+enter
					if caretOnPromptLine(true) and event:ShiftDown() then break end

					local promptText = getPromptText()
					if #promptText == 0 then return end -- nothing to execute, exit
					if promptText == 'clear' then
						out:ClearAll()
						displayShellIntro()
					else
						DisplayShellDirect('\n')
						executeShellCode(promptText)
					end
					currentHistory = getPromptLine() -- reset history
					return -- don't need to do anything else with return
				else
					-- move cursor to end if not already there
					if not caretOnPromptLine() then
						out:GotoPosition(out:GetLength())
					-- check if the selection starts before the prompt line and reset it
					elseif out:LineFromPosition(out:GetSelectionStart()) < getPromptLine() then
						out:GotoPosition(out:GetLength())
						out:SetSelection(out:GetSelectionEnd()+1,out:GetSelectionEnd())
					end
				end
				break
			end
			event:Skip()
		end)

	local function inputEditable(line)
		return caretOnPromptLine(false, line) and
			not (out:LineFromPosition(out:GetSelectionStart()) < getPromptLine())
	end

	-- new Scintilla (3.2.1) changed the way markers move when the text is updated
	-- ticket: http://sourceforge.net/p/scintilla/bugs/939/
	-- discussion: https://groups.google.com/forum/?hl=en&fromgroups#!topic/scintilla-interest/4giFiKG4VXo
	if ide.wxver >= "2.9.5" then
		-- this is a workaround that stores a position of the last prompt marker
		-- before insert and restores the same position after (as the marker)
		-- could have moved if the text is added at the beginning of the line.
		local promptAt
		out:Connect(wxstc.wxEVT_STC_MODIFIED,
			function (event)
				local evtype = event:GetModificationType()
				if bit.band(evtype, wxstc.wxSTC_MOD_BEFOREINSERT) ~= 0 then
					local promptLine = getPromptLine()
					if promptLine and event:GetPosition() == out:PositionFromLine(promptLine)
					then promptAt = promptLine end
				end
				if bit.band(evtype, wxstc.wxSTC_MOD_INSERTTEXT) ~= 0 then
					local promptLine = getPromptLine()
					if promptLine and promptAt then
						out:MarkerDelete(promptLine, PROMPT_MARKER)
						out:MarkerAdd(promptAt, PROMPT_MARKER)
						promptAt = nil
					end
				end
			end)
	end

	out:Connect(wxstc.wxEVT_STC_UPDATEUI,
		function (event) out:SetReadOnly(not inputEditable()) end)

	-- only allow copy/move text by dropping to the input line
	out:Connect(wxstc.wxEVT_STC_DO_DROP,
		function (event)
			if not inputEditable(out:LineFromPosition(event:GetPosition())) then
				event:SetDragResult(wx.wxDragNone)
			end
		end)

	if ide.config.outputshell.nomousezoom then
		-- disable zoom using mouse wheel as it triggers zooming when scrolling
		-- on OSX with kinetic scroll and then pressing CMD.
		out:Connect(wx.wxEVT_MOUSEWHEEL,
			function (event)
				if wx.wxGetKeyState(wx.WXK_CONTROL) then return end
				event:Skip()
			end)
	end

end