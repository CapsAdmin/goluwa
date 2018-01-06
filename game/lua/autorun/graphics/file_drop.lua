event.AddListener("WindowFileDrop", "file_drop", function(wnd, path)
	if vfs.IsFile(path) and path:endswith(".lua") then
		commands.RunString("open " .. path)
	end
end)