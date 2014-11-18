local frame = utility.RemoveOldObject(gui.CreatePanel("frame"), "resource_browser")
frame:SetSize(window.GetSize()*0.5)
frame:Center()
frame:SetCachedRendering(false)

local list = gui.CreatePanel("list", frame)
list:SetupLayoutChain("fill_x", "fill_y")
list:SetupSorted("name", "type", "size", "date modified")

for i, info in ipairs(vfs.Find(".", invert, full_path, start, plain, true)) do
	
	local is_folder = vfs.IsFolder(info.full_path)
	
	if is_folder then
		list:AddEntry("<texture=textures/silkicons/folder.png>" .. info.name, "folder", #vfs.Find(info.full_path .. "/") .. " files", os.date("%d/%m/%Y %H:%M", 0))
	else
		local file =  vfs.Open(info.full_path)
		list:AddEntry("<texture=textures/silkicons/page.png>" .. info.name, is_folder and "folder" or "file", utility.FormatFileSize(file:GetSize()), os.date("%d/%m/%Y %H:%M", file:GetLastModified()))
		file:Close()
	end
end

frame:Layout(true)

list:SizeColumnsToFit()