local PLUGIN = {
	name = "gmod bridge",
	description = "",
	author = "CapsAdmin",
	version = 0.1,
}

local errored = false

function PLUGIN:onEditorSave(editor)
	local f = io.open("gmod_path", "r")
	if f then
		local gmod_path = f:read("*all")
		f:close()

		local f = io.open(gmod_path .. "addons/zerobrane_bridge/lua/autorun/zerobrane_bridge.lua", "r")
		if f then
			f:close()

			local f = io.open(gmod_path .. "data/zerobrane_bridge.txt", "a")
			f:write(ide:GetDocument(editor).editor:GetText())
			f:write("¥$£@DELIMITER@£$¥")
			f:close()
		else
			ide:Print("gmod path found but not zerobrane_bridge.lua")
			ide:Print("run setup_gmod_bridge in goluwa to setup zerobrane bridge")
		end
	else
		ide:Print("run setup_gmod_bridge in goluwa to setup zerobrane bridge")
	end
end

return PLUGIN