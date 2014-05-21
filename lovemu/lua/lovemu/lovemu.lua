lovemu = {}

lovemu.version = "0.9.0"

include("boot.lua")

do
	local BASE = {}

	function BASE:__index(key)
		return BASE[key] or self.meta[key]
	end

	function BASE:typeOf(str)
		return str == self.name
	end

	function BASE:type()
		return self.name
	end
	
	local created = {}

	function lovemu.CreateObject(META)
		local self = setmetatable({__lovemu_type = META.Type, meta = META}, BASE)
		
		created[META.Type] = created[META.Type] or {}
		table.insert(created[META.Type], self)
		
		return self
	end
	
	function lovemu.Type(v)
		if type(v) == "table" and v.__lovemu_type then
			return v.__lovemu_type
		end
		return type(v)
	end
	
	function lovemu.GetCreatedObjects(name)
		return created[name] or {}
	end
end

function lovemu.ErrorNotSupported(str, level)
	error("[lovemu] " .. str, level or 4)
end

function lovemu.CheckSupported(demo)
	local supported = {}
	
	for path in vfs.Iterate("lua/lovemu/love/", nil, true) do
		local file = vfs.GetFile(path)
		for line in file:lines() do
			local name = line:match("(love%..-)%b()")
			if name then
				local partial = line:match("--partial(.+)\n", nil, true)

				if partial then
					partial = partial:trim()
					
					if partial ~= "" then
						partial = "partial"
					end
					
					supported[name] = partial
				else
					supported[name] = true
				end
			end
		end
	end

	local found = {}
	
	for _, path in pairs(vfs.Search("lovers/" .. demo .. "/", "lua")) do
		local file = vfs.GetFile(path)
		for line in file:lines() do
			local name = line:match("(love%.[_%a]-%.[_%a]-)[^_%a]")
			if name then
				found[name] = true
			end
		end
	end

	for k in pairs(found) do
		if supported[k] then
			if type(supported[k]) == "string" then
				logn("partial:\t", k, " -- ", supported[k])
			end
		else
			logn("not supported: ", k)
		end
	end
end

console.AddCommand("lovemu", function(line, command, ...)	
	if command == "run" then
		local name = tostring((...))
		if vfs.IsDir("lovers/" .. name) then
			lovemu.RunGame(name)
		else
			return false, "love game " .. name .. " does not exist"
		end
	elseif command == "check" then
		local name = tostring((...))
		if vfs.IsDir("lovers/" .. name) then
			lovemu.CheckSupported(name)
		else
			return false, "love game " .. name .. " does not exist"
		end
	elseif command == "version" then
		local name = tostring((...))
		lovemu.version = version
		logn("Changed internal version to " .. version)
	else	
		return false, "no such command"
	end
end, function() 
	logn("Usage:")
	logn("\tlovemu     <command> <params>\n\nCommands:\n")
	logn("\tcheck      <folder name>        //check game compatibility with lovemu")
	logn("\trun        <folder name>        //runs a game  ")
	logn("\tversion    <version>            //change internal love version, default: 0.9.0")
end)
