local structs = _G.structs or {}

local _, ffi = pcall(require, "ffi")

local istype
local gettype

if ffi then
	istype = ffi.istype
	gettype = function(a) return  end
else
	istype = function(a, b) return getmetatable(a) == getmetatable(b) end
	gettype = function(a) return getmetatable(a) end
end

structs.IsType = istype

structs.type_lookup = structs.type_lookup or {}
if ffi then
	local tostring = tostring
	local typeof = ffi.typeof

	function structs.GetStructMeta(cdata)
		return structs.type_lookup[tostring(typeof(cdata))]
	end
else
	function structs.GetStructMeta(obj)
		local meta = getmetatable(obj)
		if meta and meta.ClassName then
			return structs.type_lookup[meta.ClassName]
		end
	end
end

function structs.Register(META)

	META.__index = META
	META.Type = META.ClassName:lower()

	local ctor

	if ffi then
		local number_types = META.NumberType
		if type(number_types) == "string" then number_types = {number_types} end

		local i = 1

		for prepend, number_type in pairs(number_types) do
			local arg_lines = {}

			if i >= 2 then
				local copy = {}
				for k,v in pairs(META) do copy[k] = v end
				META = copy
				META.ClassName = META.ClassName .. prepend

				META.byte_size = ffi.sizeof(number_type) * #META.Args
			else
				META.byte_size = ffi.sizeof(number_type) * #META.Args
			end

			i = i + 1

			local lua = "local META = ...\n"
			lua = lua .. "function META:__index(key)\n"

			local found = false

			for arg_i, arg in pairs(META.Args) do
				if type(arg) ~= "table" then arg = {arg} end

				for i, v in pairs(arg) do
					if i == 1 then
						if arg_i == 1 then
							arg_lines[i] = number_type .. " "
						end

						arg_lines[i] = arg_lines[i] .. v

						if arg_i ~= #META.Args then
							arg_lines[i] = arg_lines[i] .. ", "
						else
							arg_lines[i] = arg_lines[i] .. ";"
						end
					else
						lua = lua .. "\t" .. (not found and "if" or "elseif")  .. " key == \""..v.."\" then\n"
						lua = lua .. "\t\treturn self." .. arg[1] .. "\n"
						found = true
					end
				end
			end

			if found then
				lua = lua .. "\tend\n"
			end

			if META.__swizzle then
				lua = lua .. "\tif META.__swizzle[key] then\n"
				lua = lua .. "\t\treturn META.__swizzle[key](self)\n"
				lua = lua .. "\tend\n"
				found = true
			end

			if found then
				lua = lua .. "\treturn META[key]\n"
				lua = lua .. "end"
				assert(loadstring(lua))(META)
			end


			table.insert(arg_lines, "\t" .. number_type .. " ptr[" .. #META.Args .. "];")

			if META.StructOverride then
				ctor = META.StructOverride()
			else
				ctor = assert(ffi.metatype("struct {\n" .. arg_lines[1] .. "\n}", META))
			end
		end
	else
		META.byte_size = #META.Args * 8 -- double

		local arg_line = "("
		local tbl_line = "{"
		for arg_i, arg in pairs(META.Args) do
			if type(arg) ~= "table" then arg = {arg} end

			tbl_line = tbl_line .. arg[1] .. " = " .. arg[1] .. " or 0,"
			arg_line = arg_line .. arg[1]

			if arg_i ~= #META.Args then
				arg_line = arg_line .. ","
			end
		end
		arg_line = arg_line .. ")"
		tbl_line = tbl_line .. "}"

		ctor = loadstring(
			"local META, setmetatable = ... return function" .. arg_line ..
			" return setmetatable(" .. tbl_line .. ", META) end"
		)(META, setmetatable)
	end

	if META.Constructor then
		structs[META.ClassName] = function() local self = ctor() self:Constructor() return self end
	else
		structs[META.ClassName] = ctor
	end

	_G[META.ClassName] = structs[META.ClassName]

	if ffi then
		structs.type_lookup[tostring(ffi.typeof(ctor))] = META
	else
		structs.type_lookup[META.ClassName] = META
	end

	META:Register()
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

	for _, line in pairs(lua:split("\n")) do
		if line:find("KEY") or line:find("ARG") then
			local str = ""
			for i, trans in pairs(META.Args) do
				local arg = trans

				if type(trans) == "table" then
					arg = trans[1]
				end

				if protect and META.ProtectedFields and META.ProtectedFields[arg] then
					str = str .. "PROTECT " .. arg
				elseif line:find("ARG") then
					str = str .. arg
					if i ~= count then
						str = str .. ", "
					end
				else
					str = str .. line:gsub("KEY", arg)
				end

				if i ~= count and not line:find("ARG") then
					str = str .. sep
				end

				if line:find("KEY") then
					str = str .. "\n"
				end
			end

			if line:find("ARG") then
				str = line:gsub("ARG", str)
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
		local META, structs = ...
		local string_format = string.format
		META["__tostring"] = function(a)
				return
				string_format(
					"CLASSNAME(LINE)",
					a.KEY
				)
			end
		]==]

		local str = ""
		for i in pairs(META.Args) do
			str = str .. "%%f"
			if i ~= #META.Args then
				str = str .. ", "
			end
		end

		lua = lua:gsub("CLASSNAME", META.ClassName)
		lua = lua:gsub("LINE", str)

		lua = parse_args(META, lua, ", ")

		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META, structs)
	elseif operator == "unpack" then
		local lua = [==[
		local META, structs = ...
		META["Unpack"] = function(a,...)
				return
				a.KEY
				,...
			end
		]==]

		lua = parse_args(META, lua, ", ")

		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META, structs)
	elseif operator == "==" then
		local lua = [==[
		local META, structs, istype = ...
		local type = type
		META["__eq"] = function(a, b)
				return
				type(a) == "]==] .. (ffi and "cdata" or "table") .. [==[" and
				istype(a, b) and
				a.KEY == b.KEY
			end
		]==]

		lua = parse_args(META, lua, " and ")

		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META, structs, istype)

		local lua = [==[
		local META, structs = ...
		META["IsEqual"] = function(self, ARG)
			return
				self.KEY == KEY
			end
		]==]

		lua = parse_args(META, lua, " and ")

		assert(loadstring(lua, META.ClassName .. " operator IsEqual"))(META, structs)
	elseif operator == "unm" then
		local lua = [==[
		local META, structs = ...
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

		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META, structs)
	elseif operator == "zero" then
		local lua = [==[
		local META, structs = ...
		META["Zero"] = function(a)
				a.KEY = 0
				return a
			end
		]==]

		lua = parse_args(META, lua, "")

		lua = lua:gsub("CTOR", "structs."..META.ClassName)

		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META, structs)
	elseif operator == "set" then
		local lua = [==[
		local META, structs = ...
		META["Set"] = function(a, ARG)
				a.KEY = KEY
				return a
			end
		]==]

		lua = parse_args(META, lua, "")

		lua = lua:gsub("CTOR", "structs."..META.ClassName)
		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META, structs)
	elseif operator == "copy" then
		local lua = [==[
		local META, structs = ...
		META["Copy"] = function(a)
			return CTOR(
				a.KEY
			)
		end
		META["CopyTo"] = function(a, b)
			a:Set(b:Unpack())
			return a
		end
		META.__copy = META.Copy
		]==]


		lua = parse_args(META, lua, ", ")

		lua = lua:gsub("CTOR", "structs."..META.ClassName)

		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META, structs)
	elseif operator == "math" then
		local args = {...}
		local func_name = args[1]
		local accessor_name = args[2]
		local accessor_name_get = args[3]
		local self_arg = args[4]

		local lua = [==[
		local META, structs, func = ...
		META["ACCESSOR_NAME"] = function(a, ]==] .. (self_arg and "b, c" or "...") .. [==[)
			a.KEY = func(a.KEY, ]==] .. (self_arg and "b.KEY, c.KEY" or "...") .. [==[)

			return a
		end
		]==]

		lua = parse_args(META, lua, "")

		lua = lua:gsub("CTOR", "structs."..META.ClassName)
		lua = lua:gsub("ACCESSOR_NAME", accessor_name)

		assert(loadstring(lua, META.ClassName .. " operator math." .. func_name))(META, structs, math[func_name])

		structs.AddGetFunc(META, accessor_name, accessor_name_get)
	elseif operator == "random" then
		local lua = [==[
		local META, structs, randomf = ...
		META["Random"] = function(a, ...)
				a.KEY = randomf(...)

				return a
			end
		]==]

		lua = parse_args(META, lua, "")

		lua = lua:gsub("CTOR", "structs."..META.ClassName)

		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META, structs, math.randomf)

		structs.AddGetFunc(META, "Random")

		--_G[META.ClassName .. "Rand"] = function(min, max)
		--	return structs[META.ClassName]():GetRandom(min or -1, max or 1)
		--end
	elseif structs.OperatorTranslate[operator] then
		local lua = [==[
		local META, structs, istype = ...
		local type = type
		META[structs.OperatorTranslate["OPERATOR"]] = function(a, b)
			if type(b) == "number" then
				return CTOR(
					a.KEY OPERATOR b
				)
			elseif type(a) == "number" then
				return CTOR(
					a OPERATOR b.KEY
				)
			elseif a and istype(a, b) then
				return CTOR(
					a.KEY OPERATOR b.KEY
				)
			else
				error(("%s OPERATOR %s"):format(tostring(a), tostring(b)), 2)
			end
		end
		]==]

		lua = parse_args(META, lua, ", ", true)

		lua = lua:gsub("CTOR", "structs."..META.ClassName)

		lua = lua:gsub("OPERATOR", operator == "%" and "%%" or operator)
		lua = lua:gsub("PROTECT", "a.")

		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META, structs, istype)
	elseif operator == "iszero" then
		local lua = [==[
		local META, structs = ...
		META["IsZero"] = function(a)
				return
				a.KEY == 0
			end
		]==]

		lua = parse_args(META, lua, " and ")

		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META, structs)
	elseif operator == "isvalid" then
		local lua = [==[
		local META, structs, isvalid = ...
		META["IsValid"] = function(a)
				return
				isvalid(a.KEY)
			end
		]==]

		lua = parse_args(META, lua, " and ")

		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META, structs, math.isvalid)
	elseif operator == "generic_vector" then
		local lua = [==[
		local META, structs = ...

		function META:SetLength(num)
			if num == 0 then
				self.KEY = 0

				return
			end

			local scale = math.sqrt(self:GetLengthSquared()) * num

			self.KEY = self.KEY / scale

			return self
		end

		function META:SetMaxLength(num)
			local length = self:GetLengthSquared()

			if length * length > num then
				local scale = math.sqrt(length) * num

				self.KEY = self.KEY / scale
			end

			return self
		end

		function META:Normalize(scale)
			scale = scale or 1

			local length = self:GetLengthSquared()

			if length == 0 then
				self.KEY = 0
				self.KEY = 0
				return self
			end

			local inverted_length = scale / math.sqrt(length)

			self.KEY = self.KEY * inverted_length

			return self
		end
		structs.AddGetFunc(META, "Normalize", "Normalized")
		]==]

		lua = parse_args(META, lua, "")

		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META, structs)


		local lua = [[
		local META, structs = ...

		function META:GetLengthSquared()
			return
			self.KEY * self.KEY
		end

		function META.GetDot(a, b)
			return
			a.KEY * b.KEY
		end
		]]

		lua = parse_args(META, lua, " + ")

		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META, structs)

		local lua = [[
		local META, structs = ...

		function META:GetVolume()
			return
			self.KEY
		end
		]]

		lua = parse_args(META, lua, " * ")

		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META, structs)

		function META:GetLength()
			return math.sqrt(self:GetLengthSquared())
		end

		function META.Distance(a, b)
			return (a - b):GetLength()
		end

		META.__len = META.GetLength

		function META.__lt(a, b)
			if structs.IsType(a, b) and type(b) == "number" then
				return a:GetLength() < b
			elseif structs.IsType(b, a) and type(a) == "number" then
				return b:GetLength() < a
			end
		end

		function META.__le(a, b)
			if structs.IsType(a, b) and type(b) == "number" then
				return a:GetLength() <= b
			elseif structs.IsType(b, a) and type(a) == "number" then
				return b:GetLength() <= a
			end
		end
	elseif operator == "lerp" then
		local lua = [[
		local META, structs = ...

		function META.Lerp(a, mult, b)
			a.KEY = (b.KEY - a.KEY) * mult + a.KEY

			return a
		end
		]]

		lua = parse_args(META, lua, "")

		assert(loadstring(lua, META.ClassName .. " operator " .. operator))(META, structs)

		structs.AddGetFunc(META, "Lerp", "Lerped")

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
	structs.AddOperator(META, "iszero")
	structs.AddOperator(META, "isvalid")
	structs.AddOperator(META, "unpack")
	structs.AddOperator(META, "tostring")
	structs.AddOperator(META, "zero")
	structs.AddOperator(META, "random")
	structs.AddOperator(META, "lerp")
	structs.AddOperator(META, "set")
	structs.AddOperator(META, "math", "abs", "Abs")
	structs.AddOperator(META, "math", "round", "Round", "Rounded")
	structs.AddOperator(META, "math", "ceil", "Ceil", "Ceiled")
	structs.AddOperator(META, "math", "floor", "Floor", "Floored")
	structs.AddOperator(META, "math", "min", "Min", "Min")
	structs.AddOperator(META, "math", "max", "Max", "Max")
	structs.AddOperator(META, "math", "clamp", "Clamp", "Clamped", true)
end

function structs.Swizzle(META, arg_count, ctor)
	local count = #META.Args
	arg_count = arg_count or count
	ctor = ctor or "structs."..META.ClassName

	local lua = "local META = ...\nlocal out = {}\n"
	for i = 1, count do
		lua = lua .. "for _, _"..i.." in ipairs(META.Args) do\n"
	end

	local index_args = ""
	for i = 1, arg_count do
		index_args = index_args .. "_"..i.."[1]"

		if i ~= arg_count then
			index_args = index_args .. ".."
		end
	end

	local ctor_args = ""
	for i = 1, arg_count do
		ctor_args = ctor_args .. "_"..i.."[1]"

		if i ~= arg_count then
			ctor_args = ctor_args .. "..', a.'.. "
		end
	end

	lua = lua .. "out["..index_args.."] = loadstring('return function(a) return ".. ctor .."(a.'.."..ctor_args.."..') end')()\n"

	for i = 1, count do
		lua = lua .. "end\n"
	end

	lua = lua .. "return out"

	local tbl = assert(loadstring(lua))(META)


	for i2 = 2, #META.Args[1] do
		for k,v in pairs(tbl) do
			for i = 1, count do
				k = k:replace(META.Args[i][1], META.Args[i][i2])
			end
			tbl[k] = v
		end
	end

	if META.__swizzle then
		table.merge(META.__swizzle, tbl)
	else
		META.__swizzle = tbl
	end
end

runfile("structs/*", structs)

return structs
