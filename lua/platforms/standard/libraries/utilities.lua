local utilities = _G.utilities or {}

function utilities.SafeRemove(obj, gc)
	if hasindex(obj) then
		
		if obj.IsValid and not obj:IsValid() then return end
		
		if type(obj.Remove) == "function" then
			obj:Remove()
		elseif type(obj.Close) == "function" then
			obj:Close()
		end
		
		if gc and type(obj.__gc) == "function" then
			obj:__gc()
		end
	end
end

function utilities.RemoveOldObject(obj, id)
	
	if hasindex(obj) and type(obj.Remove) == "function" then
		UTIL_REMAKES = UTIL_REMAKES or {}
		
		id = id or debug.getinfo(2).short_src
		
		if typex(UTIL_REMAKES[id]) == typex(obj) then
			UTIL_REMAKES[id]:Remove()
		end
		
		UTIL_REMAKES[id] = obj
	end
	
	return obj
end

function utilities.OverrideUserDataMeta(udata, meta)
    local REAL = getmetatable(udata)
    local META = table.copy(REAL)

    META = table.merge(META, meta)

    function META:__index(key)
		if META[key] then
			return META[key]
		end

		return REAL.__index(self, key)
    end

    debug.setmetatable(udata, META)

    return udata
end

-- this was originally made for Texture, but it can be used for other things as well.
function utilities.UserDataToTable(udata)
	local META = getmetatable(udata)
	local udata = {udata = udata}

	for key, value in pairs(META) do
		if type(value) == "function" then
			udata[key] = function(self, ...)
				return META[key](self.udata, ...)
			end
		else
			udata[key] = value
		end
	end

	rawset(udata, "__newindex", nil)

	return udata
end

function utilities.FindMetaTable(var)
	if istype(var, "userdata", "table") then
		return getmetatable(T)
	elseif type(var) == "string" then
		return debug.getregistry()[var:lower()]
	end
end

function utilities.DeclareMetaTable(name, tbl)
	check(name, "string")
	check(tbl, "table")

	debug.getregistry()[name:lower()] = tbl
end

function utilities.DeriveMetaFromBase(meta_name, base_name, func_name)
	check(meta_name, "string", "userdata", "table")
	check(base_name, "string", "userdata", "table")
	check(func_name, "string")

	local meta = utilities.FindMetaTable(meta_name)
	local base = utilities.FindMetaTable(base_name)

	local func = meta[func_name]

	if not func then error("could not find the function name " .. func_name, 2) end
	
	local new
	for name in pairs(base) do
		if not meta[name] then
			meta[name] = base[name] or function(s, ...)
				new = func(s, ...)
				
				if new == s then
					error(("%s tried to use %s on self but returned itself"):format(meta_name, func_name))
				end
				
				return new[name](new, ...)
			end
		end
	end
end

function utilities.GetMetaTables()
	local temp = {}
	
	for key, val in pairs(debug.getregistry()) do
		if type(key) == "string" and type(val) == "table" and val.Type then
			temp[key] = val
		end
	end
	
	return temp
end

function utilities.MonitorFile(file_path, callback)
	check(file_path, "string")
	check(callback, "function")

	local last = vfs.GetAttributes(file_path)
	if last then
		last = last.modification
		timer.Create(file_path, 0, 0, function()
			local time = vfs.GetAttributes(file_path)
			if time then
				time = time.modification
				if last ~= time then
					logf("%s changed !", file_path)
					last = time
					return callback(file_path)
				end
			else
				logf("%s not found", file_path)
			end
		end)
	else
		logf("%s not found", file_path)
	end
end

function utilities.MonitorFileInclude(source, target)
	source = source or utilities.GetCurrentPath(3)
	target = target or source

	logf("monitoring %s", source)
	logf("to reload %s", target)
	
	utilities.MonitorFile(source, function()
		timer.Simple(0, function()
			dofile(target)
		end)
	end)
end

function utilities.MakeNULL(var)
	setmetatable(var, getmetatable(NULL))
end

function utilities.GetCurrentPath(level)
	return (debug.getinfo(level or 1).source:gsub("\\", "/"):sub(2):gsub("//", "/"))
end

function utilities.GeFolderFromPath(str)
	str = str or utilities.GetCurrentPath()
	return str:match("(.+/).+") or ""
end

function utilities.GetParentFolder(str, level)
	str = str or utilities.GetCurrentPath()
	return str:match("(.*/)" .. (level == 0 and "" or (".*/"):rep(level or 1))) or ""
end

function utilities.GetFolderNameFromPath(str)
	str = str or utilities.GetCurrentPath()
	if str:sub(#str, #str) == "/" then
		str = str:sub(0, #str - 1)
	end
	return str:match(".+/(.+)") or ""
end

function utilities.GetFileNameFromPath(str)
	str = str or utilities.GetCurrentPath()
	return str:match(".+/(.+)") or ""
end

function utilities.GetExtensionFromPath(str)
	str = str or utilities.GetCurrentPath()
	return str:match(".+%.(%a+)")
end

function utilities.GetFolderFromPath(self)
	return self:match("(.*)/") .. "/"
end

function utilities.GetFileFromPath(self)
	return self:match(".*/(.*)")
end

do 
	local hooks = {}

	function utilities.HookOntoFunction(tag, tbl, func_name, type, callback)
		local old = hooks[tag] or tbl[func_name]
		
		if type == "pre" then
			tbl[func_name] = function(...)
				local args = {callback(old, ...)}
				
				if args[1] == "abort_call" then return end
				if #args == 0 then return old(...) end
				
				return unpack(args)
			end
		elseif type == "post" then
			tbl[func_name] = function(...)
				local args = {old(...)}
				if callback(old, unpack(args)) == false then return end
				return unpack(args)
			end
		end
		
		return old
	end
end

return utilities