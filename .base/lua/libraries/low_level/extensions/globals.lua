do -- wait
	local temp = {}
	
	function wait(seconds)
		if not temp[seconds] or (temp[seconds] + seconds) < os.clock() then
			temp[seconds] = os.clock()
			return true
		end
		return false
	end
end

do -- check
	local level = 3

	local function check_custom(var, method, ...)
		local name = debug.getinfo(level, "n").name
		
		local types = {...}
		local allowed = ""
		local typ = method(var)

		local matched = false

		for key, expected in ipairs(types) do
			if typ == expected then
				matched = true
			end
		end

		if not matched then
			local arg = ""

		for i = 1, 32 do
			local key, value = debug.getlocal(level, i)
				-- I'm not sure what to do about this part with vars that have no reference
				if value == var then				
					if #arg > 0 then
						arg = arg .. " or #" .. i
					else
						arg = arg .. "#" ..i
					end
				end
				
				if not key then
					break
				end
			end
		
			local allowed = ""
					
			for key, expected in ipairs(types) do
				if #types ~= key then
					allowed = allowed .. expected .. " or "
				else
					allowed = allowed .. expected
				end
			end
			
			error(("bad argument %s to '%s' (%s expected, got %s)"):format(arg, name, allowed, typ), level + 1)
		end
	end

	function check(var, ...)
		check_custom(var, _G.type, ...)
	end
	
	function checkx(var, ...)
		check_custom(var, _G.typex, ...)
	end
end

local idx = function(var) return var.TypeX or var.Type end

function hasindex(var)
	if getmetatable(var) == getmetatable(NULL) then return false end

	local T = type(var)
	
	if T == "string" then
		return false
	end
	
	if T == "table" then
		return true
	end
	
	if not pcall(idx, var) then return false end
	
	local meta = getmetatable(var)
	
	if meta == "ffi" then return true end
	
	T = type(meta)
		
	return T == "table" and meta.__index ~= nil
end

function typex(var)
	
	if getmetatable(var) == getmetatable(NULL) then return "null" end

	if hasindex(var) then
		-- why does ffi throw error when trying to index instead of nil?
		local ok, res = pcall(idx, var)
		if ok and res then
			return res
		end
	end

	return type(var)
end

local pretty_prints = {}

pretty_prints.table = function(t)
	local str = tostring(t)
			
	str = str .. " [" .. table.count(t) .. " subtables]"
	
	-- guessing the location of a library
	local sources = {}
	for k,v in pairs(t) do	
		if type(v) == "function" then
			local src = debug.getinfo(v).source
			sources[src] = (sources[src] or 0) + 1
		end
	end
	
	local tmp = {}
	for k,v in pairs(sources) do
		table.insert(tmp, {k=k,v=v})
	end
	
	table.sort(tmp, function(a,b) return a.v > b.v end)
	if #tmp > 0 then 
		str = str .. "[" .. tmp[1].k:gsub("!/%.%./", "") .. "]"
	end
	
	
	return str
end

function tostringx(val)
	local t = type(val)
	
	if t == "table" and getmetatable(val) then return tostring(val) end
	
	return pretty_prints[t] and pretty_prints[t](val) or tostring(val)
end

function tostring_args(...)
	local copy = {}
	
	for i = 1, select("#", ...) do
		table.insert(copy, tostringx(select(i, ...)))
	end
	
	return copy
end

function istype(var, ...)
	for _, str in pairs({...}) do
		if typex(var) == str then
			return true
		end
	end

	return false
end

do -- negative pairs
	local v
	local function iter(a, i)
		i = i - 1
		v = a[i]
		if v then
			return i, v
		end
	end

	function npairs(a)
		return iter, a, #a + 1
	end
end

do
	local META = utilities.CreateBaseMeta("array")
	
	META.__index = function(self, key) 
		if key == "Type" then 
			return "Array" 
		end 
		
		if key == "ArrayType" then
			return self.type
		end
		
		if key == "data" then
			return self.ptr
		end
		
		return self.ptr[key]
	end

	META.__newindex = function(self, key, val) 
		self.ptr[key] = val 
	end
		
	META.__tostring = function(self) 
		return string.format("%sArray[%i]", self.type, self.size) 
	end
	
	function Array(type, size)	
		return META:New({type = type, size = size, ptr = ffi.new(type .. "[?]", size)})
	end
end