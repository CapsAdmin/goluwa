local blacklist = {
	NULL = true,
	
}

local out = {}

local function add(f, ...)
	table.insert(out, f:format(...))
end

local function add_func(lib_name, name, func)
	local args = table.concat(debug.getparams(func), ", ")
	if args == "" and debug.getinfo(func).isvararg then
		args = "..."
	end
	add("- %s.%s(%s)", lib_name, name, args) 
end

local function add_lib(lib_name, val)
	for name, func in pairs(val) do
		if type(func) == "function" then
			add_func(lib_name, name, func)
		elseif type(func) ~= "table" then 
			add("- %s.%s = %s", lib_name, name, luadata.ToString(func))
		end
	end
end
 
local function write(name)
	if CAPSADMIN then
		vfs.Write("X:/dropbox/goluwa_wiki/goluwa.wiki/" .. name .. ".md", table.concat(out, "\n"))
	else
		vfs.Write("wiki/" .. name .. ".md", table.concat(out, "\n"))
	end
	out = {}
end

do -- globals
	add("\n##%s\n", "shared")

	for name, func in pairs(_G) do	
		local T = typex(val)
		
		if T == "function" then
			add_func("_G", name, func)
		end
	end

	write("globals")
end

for lib_name, val in pairs(_G) do	 
	local T = typex(val)
	
	if T == "table" then
		if lib_name:sub(1,1) ~= "_" and not blacklist[lib_name] then  
			add("\n##%s\n", "shared")
			
			add_lib(lib_name, val)
			
			write(lib_name)
		end
	end
end