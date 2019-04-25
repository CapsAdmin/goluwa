local PLUGIN = {
	name = "search word fallback",
	description = "fallback to closest word if selection is empty when searching",
	author = "CapsAdmin",
}

function PLUGIN:onEditorKeyDown(editor, event)
	if event:GetModifiers() == wxstc.wxSTC_SCMOD_CTRL and event:GetKeyCode() == ("F"):byte() then
		local start, stop = editor:GetSelection()
		if start == stop then
			local pos = start
			start = editor:WordStartPosition(pos, true)
			stop = editor:WordEndPosition(pos, true)
			local word = editor:GetTextRange(start, stop)
			ide.findReplace:SetFind(word)
			editor:SetSelection(start, stop)
		end
	end
end

return PLUGIN