
function debug.openscript(lua_script, line)
	local path = pvars.Get("system_texteditor_path")

	if path == "default" then
		path = system.FindFirstTextEditor(true, true)
	end


	if not path then
		logn("cannot open ", lua_script)
		commands.RunString("system_texteditor_path")
		return false
	end

	lua_script = R(lua_script) or  R(e.ROOT_FOLDER .. lua_script) or lua_script

	if not vfs.IsFile(lua_script) then
		logf("debug.openscript: script %q doesn't exist\n", lua_script)
		return false
	end

	path = path:gsub("%%LINE%%", line or 0)
	path = path:gsub("%%PATH%%", lua_script)

	llog("os.execute(%q)", path)

	os.execute(path)

	return true
end

function debug.openfunction(func, line)
	local info = debug.getinfo(func)
	if info.what == "Lua" or info.what == "main" then
		if info.source:sub(1, 1) == "@" then
			info.source = info.source:sub(2)
		end
		return debug.openscript(e.ROOT_FOLDER .. info.source, line or info.linedefined)
	end
end

