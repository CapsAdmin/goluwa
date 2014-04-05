local blacklist = {
	NULL = true,	
}

local out = {}

local function add(f, ...)
	table.insert(out, f:format(...))
end

local function add_func(lib_name, name, func, nolibname, meta)
	local url
	local args
	
	if type(func) == "function" then
		args = debug.getparams(func)
		args = table.concat(args, ", ")
		local info = debug.getinfo(func)
		
		if args == "" and info.isvararg then
			args = "..."
		end
		
		local where = info.source:match(".-/goluwa/(.+)")
		
		if info.source == "@../../../lua/init.lua" then
			where = ".base/lua/init.lua"
		end
		
		if where then
			url = "https://github.com/CapsAdmin/goluwa/blob/master/" .. where .. "#L" ..info.linedefined
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
		url = "https://www.google.com/search?q=" .. lib_name.. "+AND+\"" .. lib_name..name .. "\"+OR+\"*" .. name .. "\""
	end
	
	if nolibname then
		add("- [%s](%s)(%s)", name, url, args)  
	elseif meta then
		add("- [%s:%s](%s)(%s)", lib_name, name, url, args)  
	else
		add("- [%s.%s](%s)(%s)", lib_name, name, url, args)  
	end
end
 
local function add_lib(lib_name, val, nolibname, meta)
	for name, func in pairs(val) do
		if type(func) == "function" or (type(func) == "cdata" and tostring(ffi.typeof(func)):find("%(%)")) then
			add_func(lib_name, name, func, nolibname, meta)
		elseif type(func) ~= "table" then 
			if nolibname then
				add("- %s = %s", name, luadata.ToString(func), nolibname)
			else
				add("- %s.%s = %s", lib_name, name, luadata.ToString(func), nolibname)
			end
		end
	end
end
 
local function write(name)
	if ELIAS then
		vfs.Write("D:/dropbox/goluwa_wiki/goluwa.wiki/" .. name .. ".md", table.concat(out, "\n"))
	else
		vfs.Write("wiki/" .. name .. ".md", table.concat(out, "\n"))
	end
	out = {}
end

add_lib("globals", _G, true) 	
write("globals")

for name, meta in pairs(utilities.GetMetaTables()) do
	add_lib(name, meta, nil, true)
	write(name) 
end

for name, classes in pairs(class.GetAllTypes()) do
	for class, meta in pairs(classes) do
		add_lib(class, meta, nil, true)
		write(name .. "_" .. class) 
	end
end
 
for lib_name, val in pairs(_G) do	 
	local T = type(val)
	
	if T == "table" then
		if lib_name:sub(1,1) ~= "_" and not blacklist[lib_name] then  
			add("\n##%s\n", "shared")
			
			add_lib(lib_name, val)
			
			write(lib_name)
		end
	end 
end