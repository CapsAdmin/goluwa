local PLUGIN = {
	name = "discord copy",
	description = "copy code to be pasted in discord",
	author = "CapsAdmin",
}

local id = ID("discord.copy")

function PLUGIN:onMenuEditor(menu, editor, event)
	menu:Append(id, "Copy for Discord")
	menu:Enable(id, true)

	editor:Connect(id, wx.wxEVT_COMMAND_MENU_SELECTED, function()
		local code = editor:GetSelectedText()

		ide:CopyToClipboard("```lua\n" .. code .. "\n```")
	end)
end

return PLUGIN