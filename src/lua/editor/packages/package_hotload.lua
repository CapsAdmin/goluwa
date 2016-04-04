local PLUGIN = {
	name = "package hotload",
	description = "reload package on save",
	author = "CapsAdmin"
}

local function GetPackagePathFixed(name)
	local lol = ide.oshome
	ide.oshome = nil
	local path = ide:GetPackagePath(name)
	ide.oshome = lol

	return path .. ".lua"
end

function PLUGIN:onEditorSave(editor)
	for name in pairs(ide.packages) do
		if GetPackagePathFixed(name) == ide:GetDocument(editor).filePath then

			PackageUnRegister(name)
			PackageRegister(name)

			ide:Print("reloaded package: " .. name)

			return
		end
	end
end

return PLUGIN