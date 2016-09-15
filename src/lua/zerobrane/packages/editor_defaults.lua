local PLUGIN = {
	name = "editor defaults",
	description = "sets default interpreter and hides some things that are not needed",
	author = "CapsAdmin",
}
local default_project_dir = "../../"
local default_file = "/src/lua/examples/hello_world.lua"
local default_interpreter = "goluwa"

function PLUGIN:onAppLoad()
	if default_project_dir then
		local obj = wx.wxFileName(default_project_dir)
		obj:Normalize()

		ide:SetProject(obj:GetFullPath())
	end

	if default_file then
		if not next(ide:GetDocuments()) then
			ide:LoadFile(ide.config.path.projectdir .. default_file)
		end
	end

	if default_interpreter then
		ide:SetInterpreter(default_interpreter)
	end
end

return PLUGIN
