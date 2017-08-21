local PLUGIN = {
	name = "steam friends copy",
	description = "copy code to be pasted in steam friends",
	author = "CapsAdmin",
}

local id = ID("steamfriends.copy")

function PLUGIN:onMenuEditor(menu, editor, event)
	menu:Append(id, "Copy for steam friends")
	menu:Enable(id, true)

	editor:Connect(id, wx.wxEVT_COMMAND_MENU_SELECTED, function()
		local i = 0
		local str = ".\n" .. editor:GetSelectedText():gsub("\t", "    ")

		local width = #tostring(select(2, str:gsub("\n", "")))

		str = str:gsub("\n", function(char)
			i = i + 1
			return char .. i .. ":" .. (" "):rep(width - #tostring(i) + 2)
		end)

		ide:CopyToClipboard(str)
	end)
end

return PLUGIN