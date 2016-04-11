
##shared

- [vfs.AddModuleDirectory](nil)(dir)
- [vfs.AutorunAddon](nil)(addon, folder, force)
- [vfs.AutorunAddons](nil)(folder, force)
- [vfs.ClearCallCache](nil)()
- [vfs.CreateFolder](nil)(path)
- [vfs.CreateFoldersFromPath](nil)(filesystem, path)
- [vfs.CreateFolders](nil)(fs, path)
- [vfs.DebugPrint](nil)(fmt)
- [vfs.Delete](nil)(path)
- [vfs.Exists](nil)(path)
- [vfs.Find](nil)(path, invert, full_path, start, plain, info)
- [vfs.FixIllegalCharactersInPath](nil)(path)
- [vfs.FixPath](nil)(path)
- [vfs.GeFolderFromPath](nil)(str)
- [vfs.GetAbsolutePath](nil)(path, is_folder)
- [vfs.GetAddonInfo](nil)(addon)
- [vfs.GetEnv](nil)(key)
- [vfs.GetExtensionFromPath](nil)(str)
- [vfs.GetFileFromPath](nil)()
- [vfs.GetFileNameFromPath](nil)(str)
- [vfs.GetFileSystem](nil)(name)
- [vfs.GetFileSystems](nil)()
- [vfs.GetFolderFromPath](nil)()
- [vfs.GetFolderNameFromPath](nil)(str)
- [vfs.GetIncludeStack](nil)()
- [vfs.GetLastAccessed](nil)(path)
- [vfs.GetLastModified](nil)(path)
- [vfs.GetLoadedLuaFiles](nil)()
- [vfs.GetMountedAddons](nil)()
- [vfs.GetMounts](nil)()
- [vfs.GetParentFolder](nil)(str, level)
- [vfs.GetPathInfo](nil)(path, is_folder)
- [vfs.GetWorkingDirectory](https://github.com/CapsAdmin/goluwa/blob/master/data/users/caps/../../../src/lua/modules/fs.lua#L196)()
- [vfs.IsDirectory](nil)(path)
- [vfs.IsFile](nil)(path)
- [vfs.IsPathAbsolute](nil)(path)
- [vfs.Iterate](nil)(path)
- [vfs.MonitorEverything](nil)(b)
- [vfs.MonitorFileInclude](nil)(source, target)
- [vfs.MonitorFile](nil)(file_path, callback)
- [vfs.MountAddon](nil)(path, force)
- [vfs.MountAddons](nil)(dir)
- [vfs.Mount](nil)(where, to, userdata)
- [vfs.OSCreateDirectory](https://github.com/CapsAdmin/goluwa/blob/master/data/users/caps/../../../src/lua/modules/fs.lua#L204)(path)
- [vfs.OSGetAttributes](https://github.com/CapsAdmin/goluwa/blob/master/data/users/caps/../../../src/lua/modules/fs.lua#L210)(path)
- [vfs.Open](nil)(path, mode, sub_mode)
- [vfs.ParseVariables](nil)(path)
- [vfs.PopFromIncludeStack](nil)()
- [vfs.PopWorkingDirectory](nil)()
- [vfs.PreprocessPath](nil)(path)
- [vfs.PushToIncludeStack](nil)(path)
- [vfs.PushWorkingDirectory](nil)(dir)
- [vfs.Read](nil)(path)
- [vfs.RegisterFileSystem](nil)(META, is_base)
- [vfs.Search](nil)(path, ext, callback)
- [vfs.SetEnv](nil)(key, val)
- [vfs.SetWorkingDirectory](https://github.com/CapsAdmin/goluwa/blob/master/data/users/caps/../../../src/lua/modules/fs.lua#L200)(path)
- [vfs.SortAddonsAfterPriority](nil)()
- [vfs.TranslatePath](nil)(path, is_folder)
- [vfs.Traverse](nil)(path, callback, level)
- [vfs.Unmount](nil)(where, to)
- [vfs.Write](nil)(path)
- [vfs.dofile](nil)(path)
- [vfs.include](nil)(source)
- [vfs.loadfile](nil)(path)