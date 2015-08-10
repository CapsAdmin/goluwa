event.AddListener("WindowFileDrop", "file_drop", function(wnd, path)
	console.RunString("open " .. path)
end)