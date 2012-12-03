local oldrequire = require
local args
local i = 0
function require(var, ...)
	args = {...}
	print(i, ...)
	i = i + 1
	return oldrequire(var)
end

-- supports ending with .lua
table.insert(package.loaders, function(path)
	local func = loadfile(path)
	if func then
		print(i, unpack(args))
		return function() return func(unpack(args)) end
	end
end)

-- loads relative to current dir
table.insert(package.loaders, function(path)
	local dir = debug.getinfo(3).source:match("@(.+/)")
	local func = loadfile(dir .. path)
	if func then 
		print(func)
		print(unpack(args))
		return function() return func(unpack(args)) end
	end
end)

-- loads relative to current dir with .lua support
table.insert(package.loaders, function(path)
	local dir = debug.getinfo(3).source:match("@(.+/)")
	local func = loadfile(dir .. path .. ".lua")
	if func then
		print(unpack(args))
		return function() return func(unpack(args)) end
	end
end)

local function asdsadasd()
	return require("asdf/okay.lua")
end

print(asdsadasd())