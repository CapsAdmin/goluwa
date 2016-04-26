local PLUGIN = {
	name = "Goluwa",
	description = "",
	author = "CapsAdmin",
	version = 0.1,
}

function PLUGIN:onIdle()
	if self.ready then
		if not self.connected and self.socket:connect("localhost", self.port) then
			self.connected = true
		end
	end

	if not self.connected then return end

	local res = self.socket:receive("*line")

	if res and res ~= "" then
		GetEditor():UserListShow(1, res)
	else
		--GetEditor():AutoCompCancel()
	end
end

function PLUGIN:onRegister()
	local sockets = require("socket")

	self.socket = sockets.tcp()
	self.socket:settimeout(0)
	self.connected = false
	self.ready = false
	self.port = math.random(5000, 64000)

	function GoluwaInput(str)
		ide:Print(str, self.connected)
		if self.connected then
			self.socket:send(str)
		end
	end

	ide:AddInterpreter("goluwa", {
		name = "Goluwa",
		description = "A game framework written in luajit",
		hasdebugger = true,
		api = {"baselib", "goluwa"},
		unhideanywindow = true,
		frun = function(intepreter, wfile, run_debug)
			wx.wxSetEnv("LD_LIBRARY_PATH", ".:$LD_LIBRARY_PATH")

			local lua = ""..
			"ZEROBRANE_LINEINPUT=sockets.CreateServer([[tcp]],[[localhost]],"..self.port..")"..
			"ZEROBRANE_LINEINPUT.OnClientConnected=function(s,client)return\32true\32end;"..
			"ZEROBRANE_LINEINPUT.OnReceive=function(s,str)commands.RunString(str)end;"..
			"zb=function(s)ZEROBRANE_LINEINPUT:Broadcast(s,true)end;"..
			"ZEROBRANE_LINEINPUT.debug=true;" ..
			"pvars.Set([[editor_path]],[[./../../editor/zbstudio.sh %PATH%:%LINE%]])"

			if run_debug then
				lua = "include[["..ide:GetDocument(ide:GetEditor()):GetFilePath().."]]" .. lua
			end

			local root = ide.config.path.projectdir .. "/"
			local bin = "data/bin/" .. jit.os:lower() ..	"_" .. "x64" .. "/"

			local pid = CommandLineRun(
				("%q -e \"io.stdout:setvbuf('no');CURSES=false;ARGS={[==[%s]==]};dofile[[%s]]\""):
				format(root .. bin .. "luajit", lua, root .. "src/lua/init.lua"),
				root .. bin,
				true,--tooutput,
				true,--nohide,
				function(s) CONSOLE_OUT(s) end,
				nil,--uid,
				function()
					self.connected = false
					self.ready = false
					self.socket = sockets.tcp()
					self.socket:settimeout(0)
					self.port = math.random(5000, 64000)
				end
			)

			self.ready = true

			if GOLUWA_SHELLBOX then
				GOLUWA_SHELLBOX:SetFocus()
			end

			return pid
		end,
		fprojdir = function(intepreter, wfilename)
			return wfilename:GetPath(wx.wxPATH_GET_VOLUME)
		end,
		fworkdir = function(intepreter)
			local root = ide.config.path.projectdir .. "/"

			return root .. "/" .. bin
		end,
	})

	ProjectSetInterpreter("goluwa")

	do
		--ide.frame.bottomnotebook:RemovePage(0)

		local shellbox = ide:CreateStyledTextCtrl(ide.frame.bottomnotebook, wx.wxID_ANY, wx.wxDefaultPosition, wx.wxDefaultSize, wx.wxBORDER_NONE)
		ide.frame.bottomnotebook:AddPage(shellbox, TR("Remote console"), false)

		GOLUWA_SHELLBOX = shellbox

		-- Copyright 2011-15 Paul Kulchenko, ZeroBrane LLC
		-- authors: Luxinia Dev (Eike Decker & Christoph Kubisch)
		---------------------------------------------------------

		local ide = ide
		local unpack = table.unpack or unpack

		local bottomnotebook = ide.frame.bottomnotebook
		local out = shellbox
		local remotesend

		local PROMPT_MARKER = StylesGetMarker("prompt")
		local PROMPT_MARKER_VALUE = 2^PROMPT_MARKER
		local ERROR_MARKER = StylesGetMarker("error")
		local OUTPUT_MARKER = StylesGetMarker("output")
		local MESSAGE_MARKER = StylesGetMarker("message")
		local ANY_MARKER_VALUE = 2^25-1 -- marker numbers 0 to 24 have no pre-defined function

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

		local jumptopatterns = {
			-- <filename>(line,linepos):
			"^%s*(.-)%((%d+),(%d+)%)%s*:",
			-- <filename>(line):
			"^%s*(.-)%((%d+).*%)%s*:",
			--[string "<filename>"]:line:
			'^.-%[string "([^"]+)"%]:(%d+)%s*:',
			-- <filename>:line:linepos
			"^%s*(.-):(%d+):(%d+):",
			-- <filename>:line:
			"^%s*(.-):(%d+)%s*:",
			-- <filename>:line
			"(%S+%.lua):(%d+)",
			"@(%S+%.lua)",
		}

		out:Connect(wxstc.wxEVT_STC_DOUBLECLICK, function(event)
			local line = out:GetCurrentLine()
			local linetx = out:GetLineDyn(line)

			-- try to detect a filename and line in linetx
			local fname, jumpline, jumplinepos
			for _,pattern in ipairs(jumptopatterns) do
				ide:Print(linetx, pattern)
				fname,jumpline,jumplinepos = linetx:match(pattern)
				if (fname and jumpline) then break end
			end

			if not (fname and jumpline) then return end

			-- fname may include name of executable, as in "path/to/lua: file.lua";
			-- strip it and try to find match again if needed.
			-- try the stripped name first as if it doesn't match, the longer
			-- name may have parts that may be interpreter as network path and
			-- may take few seconds to check.
			local name
			local fixedname = fname:match(":%s+(.+)")
			if fixedname then
				name = GetFullPathIfExists(FileTreeGetDir(), fixedname)
					or FileTreeFindByPartialName(fixedname)
			end
			name = name
				or GetFullPathIfExists(FileTreeGetDir(), fname)
				or FileTreeFindByPartialName(fname)

			local editor = LoadFile(name or fname,nil,true)
			if not editor then
				local ed = GetEditor()
				if ed and ide:GetDocument(ed):GetFileName() == (name or fname) then
					editor = ed
				end
			end
			if editor then
				jumpline = tonumber(jumpline)
				jumplinepos = tonumber(jumplinepos)

				editor:GotoPos(editor:PositionFromLine(math.max(0,jumpline-1))
					+ (jumplinepos and (math.max(0,jumplinepos-1)) or 0))
				editor:EnsureVisibleEnforcePolicy(jumpline)
				editor:SetFocus()
			end

			-- doubleclick can set selection, so reset it
			local pos = event:GetPosition()
			if pos == -1 then pos = out:GetLineEndPosition(event:GetLine()) end
			out:SetSelection(pos, pos)
		end)

		SetupKeywords(out,"lua",nil,ide.config.stylesoutshell,ide.font.oNormal,ide.font.oItalic)

		local function getPromptLine()
			local totalLines = out:GetLineCount()
			return out:MarkerPrevious(totalLines+1, PROMPT_MARKER_VALUE)
		end

		local function getPromptText()
			local prompt = getPromptLine()
			return out:GetTextRangeDyn(out:PositionFromLine(prompt), out:GetLength())
		end

		local function setPromptText(text)
			local length = out:GetLength()
			out:SetSelectionStart(length - string.len(getPromptText()))
			out:SetSelectionEnd(length)
			out:ClearAny()
			out:AddTextDyn(text)
			-- refresh the output window to force recalculation of wrapped lines;
			-- otherwise a wrapped part of the last line may not be visible.
			out:Update(); out:Refresh()
			out:GotoPos(out:GetLength())
		end

		local function positionInLine(line)
			return out:GetCurrentPos() - out:PositionFromLine(line)
		end

		local function caretOnPromptLine(disallowLeftmost, line)
			local promptLine = getPromptLine()
			local currentLine = line or out:GetCurrentLine()
			local boundary = disallowLeftmost and 0 or -1
			return (currentLine > promptLine
			or currentLine == promptLine and positionInLine(promptLine) > boundary)
		end

		local function chomp(line) return (line:gsub("%s+$", "")) end

		local function getInput(line)
			local nextMarker = line
			local count = out:GetLineCount()

			repeat -- check until we find at least some marker
			nextMarker = nextMarker+1
			until out:MarkerGet(nextMarker) > 0 or nextMarker > count-1
			return chomp(out:GetTextRangeDyn(
			out:PositionFromLine(line), out:PositionFromLine(nextMarker)))
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

		local function concat(sep, ...)
			local text = ""
			for i=1, select('#',...) do
			text = text .. (i > 1 and sep or "") .. tostring(select(i,...))
			end

			-- split the text into smaller chunks as one large line
			-- is difficult to handle for the editor
			local prev, maxlength = 0, ide.config.debugger.maxdatalength
			if #text > maxlength and not text:find("\n.") then
			text = text:gsub("()(%s+)", function(p, s)
				if p-prev >= maxlength then
					prev = p
					return "\n"
				else
					return s
				end
				end)
			end
			return text
		end

		local partial = false
		local function shellPrint(marker, text, newline)
			if not text or text == "" then return end -- return if nothing to print
			if newline then text = text:gsub("\n+$", "").."\n" end
			local isPrompt = marker and (getPromptLine() > -1)
			local lines = out:GetLineCount()
			local promptLine = isPrompt and getPromptLine() or nil
			local insertLineAt = isPrompt and not partial and getPromptLine() or out:GetLineCount()-1
			local insertAt = isPrompt and not partial and out:PositionFromLine(getPromptLine()) or out:GetLength()
			out:InsertTextDyn(insertAt, out.useraw and text or FixUTF8(text, function (s) return '\\'..string.byte(s) end))
			local linesAdded = out:GetLineCount() - lines

			partial = text:find("\n$") == nil

			if marker then
			if promptLine then out:MarkerDelete(promptLine, PROMPT_MARKER) end
			for line = insertLineAt, insertLineAt + linesAdded - 1 do
				out:MarkerAdd(line, marker)
			end
			if promptLine then out:MarkerAdd(promptLine+linesAdded, PROMPT_MARKER) end
			end

			out:EmptyUndoBuffer() -- don't allow the user to undo shell text
			out:GotoPos(out:GetLength())
			out:EnsureVisibleEnforcePolicy(out:GetLineCount()-1)
		end

		local DisplayShell = function (...) shellPrint(OUTPUT_MARKER, concat("\t", ...), true) end
		local DisplayShellErr = function (...) shellPrint(ERROR_MARKER, concat("\t", ...), true) end
		local DisplayShellMsg = function (...) shellPrint(MESSAGE_MARKER, concat("\t", ...), true) end
		local DisplayShellDirect = function (...) shellPrint(nil, concat("\t", ...), true) end
			-- don't print anything; just mark the line with a prompt mark
		local DisplayShellPrompt = function (...) out:MarkerAdd(out:GetLineCount()-1, PROMPT_MARKER) end

		function out:Print(...) return DisplayShell(...) end
		function out:Write(...) return shellPrint(OUTPUT_MARKER, concat("", ...), false) end

		CONSOLE_OUT = DisplayShell

		local function executeShellCode(tx)
			if tx == nil or tx == '' then return end

			local forcelocalprefix = '^!'
			local forcelocal = tx:find(forcelocalprefix)
			tx = tx:gsub(forcelocalprefix, '')

			DisplayShellPrompt('')

			if GoluwaInput then
				GoluwaInput(tx)
			end
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
					local pos = out:GetCurrentPos()
					local text = promptText:sub(1, positionInLine(promptline))
					if #text == 0 then return end

					-- find the next match and set the prompt text
					local match = getNextHistoryMatch(text)
					if match then
						setPromptText(match)
						-- restore the position to make it easier to find the next match
						out:GotoPos(pos)
					end
					return
				elseif key == wx.WXK_ESCAPE then
					setPromptText("")
					return
				elseif key == wx.WXK_BACK then
					if not caretOnPromptLine(true) then return end
				elseif key == wx.WXK_DELETE or key == wx.WXK_NUMPAD_DELETE then
					if not caretOnPromptLine() or out:LineFromPosition(out:GetSelectionStart()) < getPromptLine() then
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
						out:Erase()
					else
						DisplayShellDirect('\n')
						executeShellCode(promptText)
					end
					currentHistory = getPromptLine() -- reset history
					return -- don't need to do anything else with return
				elseif event:GetModifiers() == wx.wxMOD_NONE or out:GetSelectedText() == "" then
					-- move cursor to end if not already there
					if not caretOnPromptLine() then
						out:GotoPos(out:GetLength())
					-- check if the selection starts before the prompt line and reset it
					elseif out:LineFromPosition(out:GetSelectionStart()) < getPromptLine() then
						out:GotoPos(out:GetLength())
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

		function out:Erase()
			self:ClearAll()
		end
	end

end

return PLUGIN
