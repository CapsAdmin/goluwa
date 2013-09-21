local done = {}

local skip =
{
	UTIL_REMAKES = true,
	ffi = true,
}

local keywords =
{
	AND = function(a, func, x,y) return func(a, x) and func(a, y) end	
}

local function args_call(a, func, ...)
	local tbl = {...}
	
	for i = 1, #tbl do
		local val = tbl[i]
		
		if not keywords[val] then
			local keyword = tbl[i+1]
			if keywords[keyword] and tbl[i+2] then
				local ret = keywords[keyword](a, func, val, tbl[i+2])
				if ret ~= nil then
					return ret
				end
			else
				local ret = func(a, val)
				if ret ~= nil then
					return ret
				end
			end
		end
	end
end

local function strfind(str, ...)
	return args_call(str, string.compare, ...) or args_call(str, string.find, ...)
end

local function find(tbl, name, level, ...)
	if level > 3 then return end
		
	for key, val in pairs(tbl) do	
		local T = type(val)
		key = tostring(key)
			
		if not skip[key] and T == "table" and not done[val] then
			done[val] = true
			find(val, name .. "." .. key, level + 1, ...)
		else
			if (T == "function" or T == "number") and (strfind(key, ...) or strfind(name, ...)) then
				if T == "function" then
					val = "(" .. table.concat(debug.getparams(val), ", ") .. ")"
				elseif T ~= "table" then
					val = luadata.ToString(val)
				else
					val = tostring(val)	
				end
				
				if name == "_G" or name == "_M" then
					logf("\t%s = %s", key, val)
				else
					name = name:gsub("_G%.", "")
					name = name:gsub("_M%.", "")
					if T == "function" then
						logf("\t%s.%s%s", name, key, val)
					else
						logf("\t%s.%s = %s", name, key, val)
					end
				end
			end
		end
	end
end

console.AddCommand("find", function(line, ...)			
	done = 
	{
		[_G] = true,
		[_R] = true,
		[package] = true,
		[_OLD_G] = true,
	}
		
	logf("searched for %q", table.concat(tostring_args(...), ", "))
	logn("globals:")
	find(_G, "_G", 1, ...)
	logn("metatables:")
	find(utilities.GetMetaTables(), "_M", 1, ...)
end)