if not ffi then return end

structs = structs or {}

function structs.Register(META)
	local arg_line = ""
	local translation = {}
	
	for i, trans in pairs(META.Args) do
		local arg = trans
		
		if type(trans) == "table" then
			arg = trans[1]
			table.remove(trans, 1)
			for _, val in pairs(trans) do
				translation[val] = arg
			end
		end
		
		arg_line = arg_line .. arg
		
		if i ~= #META.Args then
			arg_line = arg_line .. ", "
		end
	end
		
	local tr
	META.__index = function(self, key)
		if META[key] then
			return META[key]
		end
		
		tr = translation[key]
		if tr then
			return self[tr]
		end
	end
	
	local tr
	META.__newindex = function(self, key, val)
		tr = translation[key]
		if tr then
			self[tr] = val
		end
	end
		
	META.Type = META.ClassName:lower()
	
	local obj
	
	if META.StructOverride then
		obj = META.StructOverride()
	else
		ffi.cdef("typedef struct " .. META.ClassName .. " { " .. META.NumberType .. " " .. arg_line .. "; }" .. META.ClassName .. ";")
		obj = ffi.metatype(META.ClassName, META)
	end
	
	if META.Constructor then
		structs[META.ClassName] = function(...) return obj(META.Constructor(...)) end
	else
		-- speed? runtime checks are bad
		
		local count = #META.Args
		
		if count == 2 then
			structs[META.ClassName] = function(a, b) return obj(a or 0, b or 0) end
		elseif count == 3 then
			structs[META.ClassName] = function(a, b, c) return obj(a or 0, b or 0, c or 0) end
		elseif count == 4 then
			structs[META.ClassName] = function(a, b, c, d) return obj(a or 0, b or 0, c or 0, d or 0) end
		elseif count == 5 then
			structs[META.ClassName] = function(a, b, c, d, e) return obj(a or 0, b or 0, c or 0, d or 0, e or 0) end
		else
			structs[META.ClassName] = function(...) return obj(...) end
		end
 	end
	_G[META.ClassName] = structs[META.ClassName]
end 
 
-- helpers

function structs.AddGetFunc(META, name, name2)
	META["Get"..(name2 or name)] = function(self, ...)
		return self[name](self:Copy(), ...)
	end
end

structs.OperatorTranslate = 
{
	["+"] = "__add",
	["-"] = "__sub",
	["*"] = "__mul",
	["/"] = "__div",
	["^"] = "__pow",
	["%"] = "__mod",
}
 
local function parse_args(META, lua, sep, protect)
	sep = sep or ", "
	
	local str = ""
	
	local count = #META.Args
	
	for _, line in pairs(lua:explode("\n")) do
		if line:find("KEY") then
			local str = ""
			for i, trans in pairs(META.Args) do
				local arg = trans
				
				if type(trans) == "table" then
					arg = trans[1]
				end
								
				if protect and META.ProtectedFields and META.ProtectedFields[arg] then
					str = str .. "PROTECT " .. arg
				else
					str = str .. line:gsub("KEY", arg)	
				end
				
				if i ~= count then
					str = str .. sep
				end	
				
				str = str .. "\n"
			end		
			line = str
		end
		str = str .. line .. "\n"
	end
	
	return str
end
 
function structs.AddOperator(META, operator, ...)
	if operator == "tostring" then
		local lua = [==[
		local META = ({...})[1]
		META["__tostring"] = function(a)
				return 
				string.format(
					"%s(LINE)", 
					META.ClassName, 
					a.KEY
				)
			end
		]==]
		
		local str = ""
		for i in pairs(META.Args) do
			str = str .. "%%s"
			if i ~= #META.Args then
				str = str .. ", "
			end
		end

		lua = lua:gsub("LINE", str)
		
		lua = parse_args(META, lua, ", ")
				
		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META)
	elseif operator == "unpack" then
		local lua = [==[
		local META = ({...})[1]
		META["Unpack"] = function(a)
				return
				a.KEY
			end
		]==]
		
		lua = parse_args(META, lua, ", ")
		
		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META)
	elseif operator == "==" then
		local lua = [==[
		local META = ({...})[1]
		META["__eq"] = function(a, b)
				return
				typex(a) == META.Type and
				typex(b) == META.Type and
				a.KEY == b.KEY
			end
		]==]
		
		lua = parse_args(META, lua, " and ")

		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META)
	elseif operator == "unm" then
		local lua = [==[
		local META = ({...})[1]
		META["__unm"] = function(a)
				return
				CTOR(
					-a.KEY
				)
			end
		]==]
		
		lua = parse_args(META, lua, ", ", true)
		lua = lua:gsub("PROTECT", "a.")

		
		lua = lua:gsub("CTOR", "structs."..META.ClassName)
		
		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META)
	elseif operator == "zero" then
		local lua = [==[
		local META = ({...})[1]
		META["Zero"] = function(a)
				a.KEY = 0
			end
		]==]
		
		lua = parse_args(META, lua, "")
		
		lua = lua:gsub("CTOR", "structs."..META.ClassName)
		
		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META)
	elseif operator == "copy" then
		local lua = [==[
		local META = ({...})[1]
		META["Copy"] = function(a)
				return
				CTOR(
					a.KEY
				)
			end
		]==]
		
		lua = parse_args(META, lua, ", ")
		
		lua = lua:gsub("CTOR", "structs."..META.ClassName)
		
		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META)
	elseif operator == "math" then
		local args = {...}
		local func_name = args[1]
		local accessor_name = args[2]
		local accessor_name_get = args[3]
		
		local lua = [==[
		local META = ({...})[1]
		META["ACCESSOR_NAME"] = function(a, ...)
			a.KEY = math.FUNC_NAME(a.KEY, ...)
			
			return a 
		end
		]==]
		
		lua = parse_args(META, lua, "")
		
		lua = lua:gsub("CTOR", "structs."..META.ClassName)
		lua = lua:gsub("FUNC_NAME", func_name)
		lua = lua:gsub("ACCESSOR_NAME", accessor_name)
				
		assert(loadstring(lua, META.ClassName .. " operator " .. func_name))(META)
		
		structs.AddGetFunc(META, accessor_name, accessor_name_get)
	elseif operator == "random" then
		local lua = [==[
		local META = ({...})[1]
		META["Random"] = function(a, ...)
				a.KEY = math.randomf(...)
				
				return a
			end
		]==]
		
		lua = parse_args(META, lua, "")
		
		lua = lua:gsub("CTOR", "structs."..META.ClassName)
		
		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META)
		
		structs.AddGetFunc(META, "Random")
		
		_G[META.ClassName .. "Rand"] = function(min, max)
			return structs[META.ClassName]():GetRandom(min or -1, max or 1)
		end
	elseif structs.OperatorTranslate[operator] then
		local lua = [==[
		local META = ({...})[1]
		META[structs.OperatorTranslate["OPERATOR"]] = function(a, b)
			if type(b) == "number" then
				return CTOR(
					a.KEY OPERATOR b
				)
			elseif type(a) == "number" then
				return CTOR(
					a OPERATOR b.KEY
				)
			elseif typex(a) == META.Type and typex(b) == META.Type then
				return CTOR(
					a.KEY OPERATOR b.KEY
				)
			end
		end
		]==]
		
		lua = parse_args(META, lua, ", ", true)
				
		lua = lua:gsub("CTOR", "structs."..META.ClassName)
		
		lua = lua:gsub("OPERATOR", operator == "%" and "%%" or operator)
		lua = lua:gsub("PROTECT", "a.")
				
		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META)
	else
		logn("unhandled operator " .. operator)
	end
end

function structs.AddAllOperators(META)
	structs.AddOperator(META, "+")
	structs.AddOperator(META, "-")
	structs.AddOperator(META, "*")
	structs.AddOperator(META, "/")
	structs.AddOperator(META, "^")
	structs.AddOperator(META, "unm")
	structs.AddOperator(META, "%")
	structs.AddOperator(META, "==")
	structs.AddOperator(META, "copy")
	structs.AddOperator(META, "unpack")
	structs.AddOperator(META, "tostring")
	structs.AddOperator(META, "zero")
	structs.AddOperator(META, "random")
	structs.AddOperator(META, "math", "abs", "Abs")
	structs.AddOperator(META, "math", "round", "Round", "Rounded")
	structs.AddOperator(META, "math", "ceil", "Ceil", "Ceiled")
	structs.AddOperator(META, "math", "floor", "Floor", "Floored")
	structs.AddOperator(META, "math", "clamp", "Clamp", "Clamped")
end

for script in vfs.Iterate("lua/structs/", nil, true) do
	dofile(script)
end