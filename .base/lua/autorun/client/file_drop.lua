event.AddListener("WindowFileDrop", "file_drop", function(wnd, paths)
	for _, path in pairs(paths) do
		if vfs.IsDir(path) then
			
		else
			include(path)
		end
	end
end)