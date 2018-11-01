if CLI then
    event.AddListener("VFSPreWrite", "log_write", function(path, data)
        if path:startswith("data/") or vfs.GetPathInfo(path).full_path:startswith(e.STORAGE_FOLDER) then
            return
        end

        if path:startswith(system.GetWorkingDirectory()) then
            path = path:sub(#system.GetWorkingDirectory() + 1)
        end

        logn("[vfs] writing ", path, " - ", utility.FormatFileSize(#data))
    end)
end 
