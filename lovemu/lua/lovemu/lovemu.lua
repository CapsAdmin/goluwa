lovemu = {}

lovemu.version = "0.9.0"

include("boot.lua")

function lovemu.NewObject(name, ...)
	local obj = {__lovemu_type = name, ...}
		
	obj.typeOf = function(_, str)
		return str == name
	end
	
	obj.type = function()
		return name
	end
	
	return obj
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
			lovemu.boot(name)
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
