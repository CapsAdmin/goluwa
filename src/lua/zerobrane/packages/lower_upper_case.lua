local PLUGIN = {
	name = "upper and lower case context menu",
	description = "adds lowercase and UPPERCASE to context menu",
	author = "CapsAdmin",
}

function PLUGIN:onMenuEditor(menu, editor, event)
	local id = ID("uppercase.contextmenu")
	menu:Append(id, "UPPERCASE")
	menu:Enable(id, true)
	editor:Connect(id, wx.wxEVT_COMMAND_MENU_SELECTED, function()
		local code = editor:GetText()
		local start, stop = editor:GetSelectionStart(), editor:GetSelectionEnd()

		editor:SetText(code:sub(0, start-1) .. code:sub(start, stop):upper() .. code:sub(stop+1))
		editor:GotoPos(stop)
	end)

	local id = ID("lowercase.contextmenu")
	menu:Append(id, "lowercase")
	menu:Enable(id, true)
	editor:Connect(id, wx.wxEVT_COMMAND_MENU_SELECTED, function()
		local code = editor:GetText()
		local start, stop = editor:GetSelectionStart(), editor:GetSelectionEnd()

		editor:SetText(code:sub(0, start-1) .. code:sub(start, stop):lower() .. code:sub(stop+1))
		editor:GotoPos(stop)
	end)
end

return PLUGIN