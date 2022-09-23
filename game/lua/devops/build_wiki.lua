local luadata = serializer.GetLibrary("luadata")
local ffi = require("ffi")
local blacklist = {
	NULL = true,
}
local out = {}

local function add(f, ...)
	list.insert(out, f:format(...))
end

local function add_func(lib_name, name, func, nolibname, meta)
	local url
	local args

	if type(func) == "function" then
		args = debug.get_params(func)

		if meta then list.remove(args, 1) end

		args = list.concat(args, ", ")
		local info = debug.getinfo(func)

		if args == "" and info.isvararg then args = "..." end

		local where = info.source:match("@.-" .. e.ROOT_FOLDER .. "(.+)") or info.source:match("@(.+)")

		if where then
			url = "https://gitlab.com/CapsAdmin/goluwa/blob/master/" .. where .. "#L" .. info.linedefined
		elseif info.source == "=[C]" then
			if nolibname then
				url = "http://pgl.yoyo.org/luai/i/" .. name
			else
				url = "http://pgl.yoyo.org/luai/i/" .. lib_name .. "." .. name
			end

			args = "[C]"
		end
	else
		args = "[C]"
		url = "https://www.google.com/search?q=" .. lib_name .. "+AND+\"" .. lib_name .. name .. "\"+OR+\"*" .. name .. "\""
	end

	if nolibname then
		add("- [%s](%s)(%s)", name, url, args)
	elseif meta then
		add("- [%s:%s](%s)(%s)", lib_name, name, url, args)
	else
		add("- [%s.%s](%s)(%s)", lib_name, name, url, args)
	end
end

local function is_function(obj)
	return type(obj) == "function" or
		(
			type(obj) == "cdata" and
			tostring(ffi.typeof(obj)):find("%(%)")
		)
end

local function add_lib(lib_name, val, nolibname)
	for name, obj in pairs(val) do
		if not is_function(obj) and type(obj) ~= "table" then
			if nolibname then
				add("- %s = %s", name, luadata.ToString(obj))
			else
				add("- %s.%s = %s", lib_name, name, luadata.ToString(obj))
			end
		end
	end

	for name, func in pairs(val) do
		if
			type(func) == "function" or
			(
				type(func) == "cdata" and
				tostring(ffi.typeof(func)):find("%(%)")
			)
		then
			add_func(lib_name, name, func, nolibname)
		end
	end
end

local function add_meta(meta)
	local lib_name = meta.ClassName
	add("# %s", lib_name)
	add("- %s.%s = %s", lib_name, "Type", luadata.ToString(meta.Type))
	add("- %s.%s = %s", lib_name, "ClassName", luadata.ToString(meta.ClassName))
	add("- %s.%s = %s", lib_name, "Name", luadata.ToString(meta.Name))
	add("- %s.%s = %s", lib_name, "TypeBase", luadata.ToString(meta.TypeBase))

	for name, obj in pairs(meta) do
		if
			not is_function(obj) and
			type(obj) ~= "table" and
			name ~= "Base" and
			name ~= "Type" and
			name ~= "ClassName" and
			name ~= "TypeBase" and
			name ~= "Name"
		then
			add("- %s.%s = %s", lib_name, name, luadata.ToString(obj))
		end
	end

	for name, func in pairs(meta) do
		if
			type(func) == "function" or
			(
				type(func) == "cdata" and
				tostring(ffi.typeof(func)):find("%(%)")
			)
		then
			add_func(lib_name, name, func, false, true)
		end
	end
end

local function write(name)
	vfs.Write("data/wiki/" .. name .. ".md", list.concat(out, "\n"))
	out = {}
end

add_lib("globals", _G, true)
write("globals")

for _, meta in pairs(prototype.GetAllRegistered()) do
	add_meta(meta)
	write(meta.Type .. "_" .. meta.ClassName)
end

for lib_name, val in pairs(_G) do
	local T = type(val)

	if T == "table" then
		if lib_name:sub(1, 1) ~= "_" and not blacklist[lib_name] then
			add("\n## %s\n", "shared")
			add_lib(lib_name, val)
			write(lib_name)
		end
	end
end