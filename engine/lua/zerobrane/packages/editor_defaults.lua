local PLUGIN = {
	name = "editor defaults",
	description = "sets default interpreter and hides some things that are not needed",
	author = "CapsAdmin",
}
local default_project_dir = "../../"
local default_file = "/game/lua/examples/hello_world.lua"
local default_interpreter-- = "goluwa"

function PLUGIN:onAppLoad()
	if default_project_dir then
		local obj = wx.wxFileName(default_project_dir)
		obj:Normalize()

		ide:SetProject(obj:GetFullPath())
	end

	if default_interpreter then
		ide:SetInterpreter(default_interpreter)
	end
end

local function table_count(t)
	local n = 0
	for k,v in pairs(t) do
		n = n + 1
	end
	return n
end

function PLUGIN:onProjectLoad()
	if default_file then
		local count = table_count(ide:GetDocuments())
		if count == 0 or (count == 1 and select(2, next(ide:GetDocuments())).editor:GetText() == "") then
			ide:LoadFile(ide.config.path.projectdir .. default_file)
		end
	end

	ide:GetProjectTree():MapDirectory(ide:GetProject() .. "game/lua/examples")
	ide:GetProjectTree():MapDirectory(ide:GetProject() .. "game/lua/libraries/love")
	ide:GetProjectTree():MapDirectory(ide:GetProject() .. "data/ide")

	local gmod_path = GetGMODDir and GetGMODDir()

	if gmod_path then
		ide:GetProjectTree():MapDirectory(ide:GetProject() .. "game/lua/libraries/gmod")

		ide:GetProjectTree():MapDirectory(ide:GetProject() .. "pac3_server/addons/notagain/lua/notagain/")
		ide:GetProjectTree():MapDirectory(ide:GetProject() .. "pac3_server/addons/pac3/lua/pac3/")
		ide:GetProjectTree():MapDirectory(gmod_path .. "lua/")
		ide:GetProjectTree():MapDirectory(gmod_path .. "gamemodes/")
		ide:GetProjectTree():MapDirectory(gmod_path .. "addons/")
	end
end

function PLUGIN:onIdleOnce()
	--ide:GetProjectTree():SetItemText(ide:GetProjectTree():GetRootItem(), "goluwa")
end

return PLUGIN
