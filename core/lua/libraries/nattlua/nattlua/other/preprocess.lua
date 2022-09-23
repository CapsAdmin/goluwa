local preprocess = {}

function preprocess.Init()
	if _G.load then
		_G.old_preprocess_load = _G.old_preprocess_load or _G.load
		local old_preprocess_load = _G.old_preprocess_load
		_G.load = function(code, name, ...)
			if type(code) == "string" then
				code = preprocess.Preprocess(code, name, nil, "load")
			end

			return old_preprocess_load(code, name, ...)
		end
	end

	if _G.loadstring then
		_G.old_preprocess_loadstring = _G.old_preprocess_loadstring or _G.loadstring
		local old_preprocess_loadstring = _G.old_preprocess_loadstring
		_G.loadstring = function(code, name, ...)
			if type(code) == "string" then
				code = preprocess.Preprocess(code, name, nil, "loadstring")
			end

			return old_preprocess_loadstring(code, name, ...)
		end
	end

	local load = _G.old_preprocess_load or _G.old_preprocess_loadstring

	if _G.loadfile then
		_G.old_preprocess_loadfile = _G.old_preprocess_loadfile or _G.loadfile
		_G.loadfile = function(path, ...)
			local f, err = io.open(path, "r")

			if not f then return f, err end

			local code = f:read("*a") or ""
			f:close()
			code = preprocess.Preprocess(code, "@" .. path, path, "loadfile")
			return load(code, "@" .. path)
		end
	end

	if _G.dofile then
		_G.old_preprocess_dofile = _G.old_preprocess_dofile or _G.dofile
		_G.dofile = function(path)
			local f, err = io.open(path, "r")

			if not f then return f, err end

			local code = f:read("*a") or ""
			f:close()
			code = preprocess.Preprocess(code, "@" .. path, path, "dofile")
			return load(code, "@" .. path)()
		end
	end

	do
		local found = false

		for _, func in ipairs(package.loaders) do
			if preprocess.package_load == func then
				found = true

				break
			end
		end

		if not found then
			table.insert(package.loaders, 1, preprocess.package_load)
		end

		for k, v in pairs(package.loaded) do
			if _G[k] ~= v then package.loaded[k] = nil end
		end
	end
end

function preprocess.Shutdown()
	if _G.old_preprocess_load then
		_G.load = _G.old_preprocess_load
		_G.old_preprocess_load = nil
	end

	if _G.old_preprocess_loadstring then
		_G.loadstring = _G.old_preprocess_loadstring
		_G.old_preprocess_loadstring = nil
	end

	if _G.old_preprocess_loadfile then
		_G.loadfile = _G.old_preprocess_loadfile
		_G.old_preprocess_loadfile = nil
	end

	if _G.old_preprocess_dofile then
		_G.dofile = _G.old_preprocess_dofile
		_G.old_preprocess_dofile = nil
	end

	for i, func in ipairs(package.loaders) do
		if preprocess.package_load == func then
			table.remove(package.loaders, i)

			break
		end
	end
end

function preprocess.package_load(name)
	local ok, err = pcall(function()
		local path = name:gsub("%.", "/") .. ".lua"
		local f, err = io.open(path, "r")

		if f then
			local load = _G.old_preprocess_load or _G.old_preprocess_loadstring
			local code = f:read("*all") or ""
			f:close()
			code = preprocess.Preprocess(code, name, path, "package")
			local func, err = load(code, "@" .. path)

			if not func then print(err) end

			return func
		end
	end)

	if ok and err then return err end

	if not ok then print(err) end

	return nil
end

function preprocess.Preprocess(code, name, path, from)
	--print(from .. "\t\t:", #code, name, path)
	return code
end

return preprocess
