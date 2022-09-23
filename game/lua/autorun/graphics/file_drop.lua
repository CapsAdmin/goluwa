event.AddListener("WindowDrop", "file_drop", function(wnd, path)
	if vfs.IsFile(path) and path:ends_with(".lua") then
		commands.RunString("open " .. path)
	end
end)