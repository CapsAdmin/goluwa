event.AddListener("WindowFileDrop", "file_drop", function(wnd, path)
	if vfs.IsFile(path) and path:endswith(".lua") then
		console.RunString("open " .. path)
	end
end)