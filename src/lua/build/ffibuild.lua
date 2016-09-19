local ffibuild = {}

function ffibuild.Clone(str, dir)
	dir = dir or "repo"
	if str:find("%.git$") then
		os.execute("if [ -d ./" .. dir .. " ]; then git -C ./" .. dir .. " pull; else git clone " .. str .. " " .. dir .. " --depth 1; fi")
	elseif str:find("hg%.") then
		local clone_, branch = str:match("(.+);(.+)")
		str = clone_ or str
		if branch then
			os.execute("hg clone " .. str .. " " .. dir .. " -r " .. branch)
		else
			os.execute("hg clone " .. str .. " " .. dir)
		end
	else
		os.execute(str)
	end
end

function ffibuild.BuildSharedLibrary(name, clone, build, copy)
	--os.execute("git --git-dir=./repo/.git pull")
	local ext = jit.os == "OSX" and ".dylib" or ".so"
	local f = io.open("lib"..name..ext, "r")
	if not f then
		ffibuild.Clone(clone)
		if build then
			os.execute("cd repo && " .. build .. " && cd ..")
		end
		if not copy then
			-- there's an -o switch for cp but depending on which one you find first it doesn't work
			-- so screw it
			os.execute("cp $(find . -name 'lib"..name.."*"..ext..".*' -type f -print -quit) lib"..name..ext)
			local f = io.open("lib"..name..ext, "r")
			if not f then
				os.execute("cp $(find . -name 'lib"..name.."*"..ext.."' -type f -print -quit) lib"..name..ext)
			else
				f:close()
			end
		else
			os.execute(copy)
		end
	else
		f:close()
	end

	ffibuild.lib_name = name
end

function ffibuild.BuildCHeader(c_source, flags)
	flags = flags or ""
	local temp_name = os.tmpname()
	local temp_file = io.open(temp_name, "w")
	temp_file:write(c_source)
	temp_file:close()

	local gcc = io.popen("gcc -xc -E -P " .. flags .. " " .. temp_name)
	local header = gcc:read("*all")

	gcc:close()
	os.remove(temp_name)

	return header
end

function ffibuild.SplitHeader(header, ...)
	header = header:gsub("/%*.-%*/", "")

	local found = {}

	for _, what in ipairs({...}) do
		local _, stop_pos = header:find(".-" .. what)

		if stop_pos then
			stop_pos = stop_pos - #what
		end
		table.insert(found, stop_pos)
	end

	table.sort(found, function(a, b) return a < b end)

	local stop = found[1]

	for i = 1, math.huge do
		local char = header:sub(stop - i, stop - i)
		if char == ";" or char == "}" then
			stop = stop - i + 1
			break
		end
	end

	return header:sub(0, stop), header:sub(stop)
end


local function match_type_declaration(str)
	local declaration, name, array_size = str:match("^([%a%d%s_%*]-) ([%a%d_]-)$")

	if not declaration then
		declaration, name, array_size = str:match("^([%a%d%s_%*]-) ([%a%d_]-) (%[.+%])")
	end

	return declaration, name, array_size
end

function ffibuild.GetMetaData(header)

	local meta_data = {
		functions = {},
		structs = {},
		unions = {},
		typedefs = {},
		variables = {},
		enums = {},
		global_enums = {},
	}

	do -- cleanup header
		-- this assumes the header has been preprocessed with gcc -E -P
		header = " " .. header

		-- process all single quote strings
		header = header:gsub("('%S+')", function(val) return assert(loadstring("return (" .. val .. "):byte()"))() end)
		header = header:gsub("' '", string.byte(" "))

		-- remove comments
		header = header:gsub("/%*.-%*/", "")

		-- TODO: remove things like #pragma
			header = header:gsub("#.-\n", "")

		 -- normalize everything to have equal spacing even between punctation
		header = header:gsub("([*%(%){}&%[%],;&|<>=])", " %1 ")

		header = header:gsub("%s+", " ")

		-- insert a newline after ;
		header = header:gsub(";", ";\n")

		-- this will explode structs and and whatnot so make sure we remove newlines inside {} and ()
		header = header:gsub("%b{}", function(s) return s:gsub("%s+", " ") end)
		header = header:gsub("%b()", function(s) return s:gsub("%s+", " ") end)

		--TODO
			-- remove compiler __attribute__
			header = header:gsub("__%a-__ %b() ", "")

			-- remove __extension__
			header = header:gsub("__extension__ ", "")

			-- remove __restrict
			header = header:gsub("__restrict__ ", "")
			header = header:gsub("__restrict", "")

			header = header:gsub("__max_align_..", "")

			-- remove volatile
			header = header:gsub(" volatile ", " ")

		-- remove inline functions
		header = header:gsub(" static __inline.-%b().-%b{}", "")
		header = header:gsub(" static inline.-%b().-%b{}", "")

		header = header:gsub(" extern __inline.-%b().-%b{}", "")
		header = header:gsub(" extern inline.-%b().-%b{}", "")

		-- int foo(void); >> int foo();
		header = header:gsub(" %( void %) ", " ( ) ")

		-- TODO: support more than 2 definitions
		-- struct foo {} foo_t, * pfoo_t;
		-- >>
		-- struct foo {} foo_t;
		-- struct foo {} * pfoo_t;
		header = header:gsub("typedef %a- [%a%d_]+ %b{} [^;]- ;", function(statement)
			if statement:find(",") then
				local tag, huh = statement:match("^typedef (%a- [%a%d_]+) %b{} .+,(.+);$")
				if tag then
					return statement:match("(typedef %a- [%a%d_]+ %b{} .-),") .. ";\n" .. "typedef " .. tag .. huh .. ";"
				end
			end
		end)

		-- void * foo ( int , int ) >> void * ( foo ) ( int , int )
		-- this makes things easier to parse
		header = header:gsub("([^\n]-) ([%a%d_]+) (%b() ;)", function(a,b,c)
			local line = a .. " ( " .. b .. " ) " .. c
			line = line:gsub("%( %(", "(")
			line = line:gsub("%) %)", ")")
			return line
		end)
	end

	local function is_function(str) return str:find("^.-%b() %b() $") end

	local i = 1

	local function create_type(...)
		local t = ffibuild.CreateType(...)
		t.i = i
		return t
	end


	for line in header:gmatch(" (.-);\n") do

		local extern
		local typedef

		if line:find("^typedef") then
			typedef = true
			line = line:match("^typedef (.+)")

			if is_function(line) then
				local type = create_type("function", line:sub(0, -2), meta_data)
				meta_data.typedefs[type.name] = type
				line = nil
			else
				local content, alias = line:match("^(.+) ([%a%d_]+)")

				if content:find("^struct ") or content:find("^union ") or content:find("^enum ") then

					local tag, found = content:gsub(" %b{}", "")

					if not tag:find("%s") then
						tag = tag .. " " .. alias
						content = content:gsub("^(%l+ )", tag .. " ")
					end

					meta_data.typedefs[alias] = create_type("type", tag)

					line = content
				else
					local array_size

					if line:find("%b[]") then
						content, alias, arr = line:match("^(.+) ([%a%d_]+) (%b[])")
						array_size = arr
					end

					meta_data.typedefs[alias] = create_type("type", content, array_size)

					line = nil
				end
			end
		elseif line:find("^extern") then
			extern = true
			line = line:match("^extern (.+)")
		--elseif line:find("^static") then
		--	print(line)
		end

		if line then
			if is_function(line) then
				local type = create_type("function", line:sub(0, -2), meta_data)
				meta_data.functions[type.name] = type
			elseif line:find("^enum") then
				local tag, content = line:match("(enum [%a%d_]+) ({.+})")

				if tag then
					local test = tag:match("^enum (.+)")
					if meta_data.typedefs[test] and meta_data.typedefs[test]:GetBasicType() == "int" then
						meta_data.typedefs[test].last_node.type = tag
						meta_data.typedefs[test].last_node.enum = true
					end

					meta_data.enums[tag] = create_type("enums", content, meta_data)
					meta_data.enums[tag].name = tag
				else
					content = line:match("enum ({.+})")
					-- no type name = global enum

					table.insert(meta_data.global_enums, create_type("enums", content, meta_data))
				end
			elseif line:find("^struct") or line:find("^union") then
				local keyword = line:match("^([%a%d_]+)")

				local tag, content = line:match("("..keyword.." [%a%d_]+) ({.+})")

				if not tag then
					-- just a forward declaration or an opaque struct
					tag = line:match("("..keyword.." [%a%d_]+)")
					content = "{ }"
				end

				local tbl = keyword == "struct" and meta_data.structs or meta_data.unions
				if not tbl[tag] or tbl[tag]:GetDeclaration():find("{%s+}") then
					tbl[tag] = create_type("struct", content, keyword == "union", meta_data)
				end
			elseif extern then
				local declaration, name, array_size = match_type_declaration(line:sub(0, -2))

				meta_data.variables[name] = create_type("type", declaration, array_size)
			end
		end

		i = i + 1
	end

	function meta_data:GetStructTypes(pattern)
		local out = {}

		-- find all types that start with *pattern* and are also structs
		for type_name, type in pairs(self.typedefs) do
			local name = type_name:match(pattern)
			if name and type:GetSubType() == "struct" then
				table.insert(out, {
					name = name,
					type = type,
				})
			end
		end

		-- sort them by length to avoid functions like purple_>>conversation<<_foo_bar() to conflict with purple_>>conversation_im<<_foo_bar()
		table.sort(out, function(a, b) return #a.name > #b.name end)

		return out
	end

	function meta_data:GetFunctionsStartingWithType(type)
		local out = {}

		for func_name, func_type in pairs(self.functions) do
			if func_type.arguments then
				local evaluated = func_type.arguments[1]
				if evaluated:GetBasicType(self) == type:GetBasicType(self) then
					out[func_name] = func_type
				end
			end
		end

		return out
	end

	function meta_data:FindFunctions(pattern, from, to)
		local out = {}
		for func_name, func_type in pairs(self.functions) do
			local capture = func_name:match(pattern)
			if capture then
				if from and to then
					capture = ffibuild.ChangeCase(capture, from, to)
				end
				out[capture] = func_type
			end
		end
		return out
	end

	function meta_data:BuildMinimalHeader(check_function, check_enum, keep_structs, iterate_all_enums)
		local required = {}

		local bottom = ""

		for func_name, func_type in pairs(self.functions) do
			if not check_function or check_function(func_name, func_type) then
				func_type:FetchRequired(self, required)
				bottom = bottom .. func_type:GetDeclaration(self) .. ";\n"
			end
		end

		local top = ""

		-- global enums
		if #self.global_enums > 0 then
			local str = {}

			for i, enums in ipairs(self.global_enums) do
				local line = {}

				for _, v in ipairs(enums:FetchEnums(check_enum)) do
					table.insert(line, v)
				end

				if #line > 0 then
					table.insert(str, table.concat(line, ",") .. ",")
				end
			end

			if #str > 0 then
				top = top .. "enum {" .. table.concat(str, "\n") .. "};"
			end
		end

		-- typedef enums
		if iterate_all_enums then
			for name, enums in pairs(self.enums) do
				local declaration = enums:GetDeclaration(self, check_enum)
				if declaration then
					top = top .. declaration .. "\n"
				end
			end
		else
			for _, type in pairs(required) do
				if type:GetSubType() == "enum" then
					local enums = self.enums[type:GetBasicType(self)]
					local declaration = enums:GetDeclaration(self, check_enum)
					if declaration then
						top = top .. declaration .. "\n"
					end
				end
			end
		end

		local temp = {}

		for _, type in pairs(required) do
			local basic_type = type:GetBasicType(self)

			if type:GetSubType() == "struct" then
				table.insert(temp, {type = type, i = self.structs[basic_type].i})
			elseif type:GetSubType() == "union" then
				table.insert(temp, {type = type, i = self.unions[basic_type].i})
			end
		end

		table.sort(temp, function(a, b) return a.i < b.i end)

		required = temp

		for _, val in ipairs(required) do
			local type = val.type

			local basic_type = type:GetBasicType(self)

			if type:GetSubType() == "struct" then
				if keep_structs then
					top = top .. basic_type .. " " .. self.structs[basic_type]:GetDeclaration(self) .. ";\n"
				else
					top = top .. basic_type .. " { };\n"
				end
			elseif type:GetSubType() == "union" then
				if keep_structs then
					top = top .. basic_type .. " " .. self.unions[basic_type]:GetDeclaration(self) .. ";\n"
				else
					top = top .. basic_type .. " { };\n"
				end
			end
		end

		local header = top .. bottom

		--struct _GList { void * data; struct _GList * next; struct _GList * prev; };
		header = header:gsub(" ([^%a%d%s_])", "%1"):gsub("([^%a%d%s_]) ", "%1")
		--struct _GList{void*data;struct _GList*next;struct _GList*prev;};

		return header
	end

	function meta_data:BuildFunctions(pattern, from, to, clib)
		local s = "{\n"
		for func_name, func_type in pairs(self.functions) do
			local friendly_name

			if pattern then
				friendly_name = func_name:match(pattern)
			else
				friendly_name = func_name
			end

			if friendly_name then
				if from then friendly_name = ffibuild.ChangeCase(friendly_name, from, to) end
				s = s .. "\t" .. friendly_name .. " = " .. ffibuild.BuildLuaFunction(func_type.name, func_type, nil, nil, nil, clib) .. ",\n"
			end
		end
		s = s .. "}\n"
		return s
	end

	do
		local function get_enum_name(name, pattern, group, basic_type)
			if not pattern and group then
				if basic_type:find(group) then
					return name
				end
			end

			local key

			if pattern then
				key = name:match(pattern)
			else
				key = name
			end

			-- if the prefix has been stripped the key might start with a number
			if key and key:find("^%d") then
				print("enum " .. key .. " starts with a number. prepending _")
				key = "_" .. key
			end

			return key
		end

		function meta_data:BuildEnums(pattern, define_file, define_starts_with, group)
			local s = "{\n"
			for basic_type, type in pairs(self.enums) do
				for _, enum in ipairs(type.enums) do
					local key = get_enum_name(enum.key, pattern, group, basic_type)

					if key then
						s =  s .. "\t" .. key .. " = ffi.cast(\""..basic_type.."\", \""..enum.key.."\"),\n"
					end
				end
			end

			if not group then
				for _, enums in pairs(self.global_enums) do
					for _, enum in ipairs(enums.enums) do
						local key = get_enum_name(enum.key, pattern, group, basic_type)

						if key then
							s =  s .. "\t" .. key .. " = "..enum.val..",\n"
						end
					end
				end
			end

			if type(define_file) == "table" then
				for i,v in ipairs(define_file) do
					if type(v) == "string" then
						s = s .. ffibuild.BuildDefineEnums(v, define_starts_with, "\t", ",\n", pattern)
					else
						s = s .. ffibuild.BuildDefineEnums(v[1], v[2], "\t", ",\n", pattern)
					end
				end
			else
				if define_file and define_starts_with then
					s = s .. ffibuild.BuildDefineEnums(define_file, define_starts_with, "\t", ",\n", pattern)
				end
			end
			s = s .. "}\n"
			return s
		end
	end

	function meta_data:BuildLuaMetaTable(meta_name, declaration, functions, argument_translate, return_translate, clib, ffi_metatype)
		return ffibuild.BuildLuaMetaTable(meta_name, declaration, functions, argument_translate, return_translate, self, clib, ffi_metatype)
	end

	function meta_data:BuildLuaFunction(real_name, func_type, call_translate, return_translate, first_argument_self, clib)
		return ffibuild.BuildLuaFunction(real_name, func_type, call_translate, return_translate, self, first_argument_self, clib)
	end

	return meta_data
end

function ffibuild.ChangeCase(str, from, to)
	if from == "fooBar" then
		if to == "FooBar" then
			return str:sub(1, 1):upper() .. str:sub(2)
		elseif to == "foo_bar" then
			return ffibuild.ChangeCase(str:sub(1, 1):upper() .. str:sub(2), "FooBar", "foo_bar")
		end
	elseif from == "FooBar" then
		if to == "foo_bar" then
			return str:gsub("(%l)(%u)", function(a, b) return a.."_"..b:lower() end):lower()
		elseif to == "fooBar" then
			return str:sub(1, 1):lower() .. str:sub(2)
		end
	elseif from == "foo_bar" then
		if to == "FooBar" then
			return ("_" .. str):gsub("_(%l)", function(s) return s:upper() end)
		elseif to == "fooBar" then
			return ffibuild.ChangeCase(ffibuild.ChangeCase(str, "foo_bar", "FooBar"), "FooBar", "fooBar")
		end
	elseif from == "Foo_Bar" then
		return ffibuild.ChangeCase(("_" .. str):gsub("_(%u)", function(s) return s:upper() end), "FooBar", to)
	end
	return str
end

do -- type metatables
	local metatables = {}

	for _, name in ipairs({"function", "struct", "type", "var_arg", "enums"}) do
		local META = {}
		META.__index = META
		META.MetaType = name

		--META.__tostring = function(s) return ("%s[%s]"):format(s:GetDeclaration(), name) end

		function META:GetDeclaration(meta_data, ...) end
		function META:GetCopy() end
		function META:GetBasicType() end
		function META:GetSubType() return self:GetBasicType() end
		function META:FetchRequired(meta_data, out, temp) temp = temp or {} table.insert(out, 1, self) end

		metatables[name] = META
	end

	function ffibuild.CreateType(type, ...)
		return setmetatable(metatables[type]:Create(...), metatables[type])
	end

	do -- enums
		local ENUMS = metatables.enums

		local operators = {}

		local LR = function(operator, name)
			local func = bit[name]
			operators[operator] = setmetatable({find = operator:gsub("(.)", "%%%1"), replace = "%%_O['"..operator.."']%%"}, {__mod = function(a) return setmetatable({}, {__mod = function(_,b) return func(a, b) end}) end})
		end

		local L = function(operator, name)
			local func = bit[name]
			operators[operator] = setmetatable({find = operator:gsub("(.)", "%%%1"), replace = "_O['"..operator.."']"}, {__call = function(_, a) return func(a) end})
		end

		LR("&", "band")
		LR("|", "bor")
		LR("^", "bxor")
		LR("<<", "lshift")
		LR(">>", "rshift")
		L("~", "bnot")

		local function parse_bit_declaration(expression, original_expression)
			expression = expression:gsub("([%dxXabcdefABCDEF]+)", "(%1)")

			for operator, info in pairs(operators) do
				expression = expression:gsub(info.find, info.replace)
			end

			expression = expression:gsub("%?", " ~= 0 and "):gsub(":", " or ")

			local func, err = loadstring("local _O = ... return " .. expression)
			if func then
				local ok, msg = pcall(func, operators)
				if ok then
					return msg
				end
				error(original_expression .. "\n\nunable to run '"..expression.."' : " .. msg)
			end
			error(original_expression .. "\n\nunable to parse '"..expression.."': " .. err)
		end

		local function find_enum(current_meta_data, out, what)
			if out[1] then
				for _, info in ipairs(out) do
					if info.key == what then
						return info.val
					end
				end
			else
				if out[what] then
					return out[what]
				end
			end

			if current_meta_data then
				for _, info in pairs(current_meta_data.global_enums) do
					for _, info in ipairs(info.enums) do
						if info.key == what then
							return info.val
						end
					end
				end

				for _, info in pairs(current_meta_data.enums) do
					for _, info in ipairs(info.enums) do
						if info.key == what then
							return info.val
						end
					end
				end
			end
		end

		function ffibuild.ParseEnumValue(val, current_meta_data, enums)
			local num = tonumber(val)

			if not num then
				val = val:gsub("> >", ">>"):gsub("< <", "<<")

				do
					-- kind of hacky but removes "( unsigned long )" and the like which have space
					val = val:gsub("(%([%s%l]-%))", "")

					local found
					local test = val:gsub("([%a_][%a%d_]+)", function(what)
						local val = find_enum(current_meta_data, enums, what)

						if val then
							found = true
							return val
						end

						-- don't bother with type casting
						if current_meta_data and current_meta_data.typedefs[what] then
							found = true
							return "_REMOVE_ME_"
						end
					end)

					-- remove all typecasts
					if test:find("_REMOVE_ME_") then
						test = test:gsub("%( _REMOVE_ME_ %) ", "")
					end

					if found then
						val = test
					else
						val = find_enum(current_meta_data, enums, val) or val

						if type(val) == "string" and val:sub(#val, #val) == "u" then
							val = val:sub(0, -2)
						end

						local test = tonumber(val)

						if test then
							num = test
						end
					end
				end
			end

			if not num then
				num = parse_bit_declaration(val, "")
			end

			return num
		end

		function ENUMS:Create(declaration, current_meta_data)
			declaration = declaration:sub(3, -3)

			local num = 0
			local enums = {}

			for line in (declaration .. " , "):gmatch("(.-) , ") do
				local key, val = line:match("(.+) = (.+)")

				if key and val then
					num = ffibuild.ParseEnumValue(val, current_meta_data, enums)

					if not num then
						error("unable to parse enum:\n\t" .. val)
					end
				else
					key = line
				end

				table.insert(enums, {key = key, val = num})

				num = num + 1
			end

			return {enums = enums}
		end

		function ENUMS:GetCopy() return self end

		function ENUMS:GetDeclaration(meta_data, check_enums)
			local str = {}

			for i, info in ipairs(self.enums) do
				if not check_enums or check_enums(info.key, info) then
					table.insert(str, info.key .. " = " .. info.val)
				end
			end

			if check_enums and #str == 0 then return end

			str = table.concat(str, ", ")

			if self.name then
				return "typedef " .. self.name .. " { " .. str .. " };"
			else
				return "enum {\n" .. str .. "\n};"
			end
		end

		function ENUMS:FetchEnums(check_enums)
			local out = {}
			for i, info in ipairs(self.enums) do
				if check_enums(info.key, info) then
					table.insert(out, info.key .. " = " .. info.val)
				end
			end
			return out
		end

		function ENUMS:GetBasicType()
			return "enum"
		end
	end

	do -- type
		local TYPE = metatables.type

		local flags = {
			const = true,
			volatile = true,
			struct = true,
			enum = true,
			union = true,
			unsigned = true,
			signed = true,
			pointer = true,
		}

		function TYPE:Create(declaration, array_size)
			if declaration == "unsigned" then
				declaration = declaration .. " int"
			end

			local tree = {}

			local node = tree

			local prev_token
			local prev_node

			for token in declaration:reverse():gmatch("(%S+) ?") do
				token = token:reverse()

				if token == "*" then
					token = "pointer"
				end

				if flags[token] then
					node[token] = true
				else
					node.type = token
				end

				if token == "struct" or token == "union" or token == "enum" then
					prev_node[prev_token] = nil
					node.type = token .. " " .. prev_token
				end

				if token == "pointer" then
					prev_node = node
					node.to = {}
					node = node.to
				end

				prev_token = token
				prev_node = node
			end

			return {
				last_node = node,
				tree = tree,
				array_size = array_size,
			}
		end

		function TYPE:GetDeclaration(meta_data, type_replace, ...)
			local type = self:GetPrimitive(meta_data)

			if not type.tree then return type:GetDeclaration(meta_data) end

			local node = type.tree

			local declaration = {}

			while true do
				if node.type then
					table.insert(declaration, (type_replace or node.type):reverse())
				end

				for _, flag in ipairs({"signed", "unsigned", "const", "volatile"}) do
					if node[flag] then
						table.insert(declaration, flag:reverse())
					end
				end

				if node.pointer then
					table.insert(declaration, "*")
					node = node.to
				else
					break
				end
			end

			if self.array_size then
				table.insert(declaration, 1, self.array_size:reverse())
			end

			return table.concat(declaration, " "):reverse()
		end

		function TYPE:GetBasicType(meta_data)
			if meta_data then return self:GetPrimitive(meta_data):GetBasicType() end
			return self.last_node.type
		end

		function TYPE:GetSubType()
			if self.last_node.struct then return "struct" end
			if self.last_node.enum then return "enum" end
			if self.last_node.union then return "union" end

			return self:GetBasicType()
		end

		function TYPE:GetCopy()
			-- TODO
			local array_size = self.array_size
			self.array_size = nil

			local copy = ffibuild.CreateType("type", self:GetDeclaration())


			for k,v in pairs(self) do
				if type(v) ~= "table" then
					copy[k] = v
				end
			end

			copy.array_size = array_size
			self.array_size = array_size

			return copy
		end

		function TYPE:GetPrimitive(meta_data)
			if not meta_data or not meta_data.typedefs[self:GetBasicType()] then return self end

			local copy = self:GetCopy()
			local type = copy

			for _ = 1, 10 do
				type = meta_data.typedefs[type:GetBasicType()]

				if not type then break end

				local type = type:GetCopy(meta_data)

				if getmetatable(type) ~= getmetatable(copy) then
					local name = copy.name
					for k in pairs(copy) do copy[k] = nil end
					for k,v in pairs(type) do copy[k] = v end
					copy.name = name

					setmetatable(copy, getmetatable(type))

					return copy
				elseif type.tree then
					copy.last_node.type = nil
					for k, v in pairs(type.tree) do
						copy.last_node[k] = v
					end
					if type.last_node ~= type.tree then
						copy.last_node = type.last_node
					end
				else
					break
				end
			end

			return copy
		end

		function TYPE:FetchRequired(meta_data, out)
			local basic_type = self:GetBasicType(meta_data)


			if basic_type and not out[basic_type] then
				out[basic_type] = self:GetPrimitive(meta_data)

				if meta_data.structs[basic_type] then
					meta_data.structs[basic_type]:FetchRequired(meta_data, out)
				elseif meta_data.unions[basic_type] then
					meta_data.unions[basic_type]:FetchRequired(meta_data, out)
				end
			end
		end
	end

	do -- function
		local FUNCTION = metatables["function"]

		local basic_types = {
			["char"] = true,
			["signed char"] = true,
			["unsigned char"] = true,
			["short"] = true,
			["short int"] = true,
			["signed short"] = true,
			["signed short int"] = true,
			["unsigned short"] = true,
			["unsigned short int "] = true,
			["int"] = true,
			["signed"] = true,
			["signed int"] = true,
			["unsigned"] = true,
			["unsigned int"] = true,
			["long"] = true,
			["long int"] = true,
			["signed long"] = true,
			["signed long int"] = true,
			["unsigned long"] = true,
			["unsigned long int"] = true,
			["long long"] = true,
			["long long int"] = true,
			["signed long long"] = true,
			["signed long long int"] = true,
			["unsigned long long"] = true,
			["unsigned long long int"] = true,
			["float"] = true,
			["double"] = true,
			["long double"] = true,
		}

		local function explode(str, split)

			local temp = {}
			str = str:gsub("(%b())", function(str) table.insert(temp, str) return "___TEMP___" end)

			local out = {}

			for val in (str .. split):gmatch("(.-)"..split) do
				if val:find("___TEMP___", nil, true) then val = val:gsub("___TEMP___", function() return table.remove(temp, 1) end) end
				table.insert(out, val)
			end

			return out
		end

		function FUNCTION:Create(declaration, meta_data)
			local return_line, func_type, func_name, arg_line = declaration:match("^(.-) %((.-)([%a%d_]*) %) (%b())$")

			func_type = func_type:match "^%s*(.-)%s*$"
			arg_line = arg_line:sub(3, -3)

			local arguments

			if #arg_line > 0 then
				arguments = explode(arg_line, " , ")
				for i, arg in ipairs(arguments) do
					local type

					if arg == "..." then
						type = ffibuild.CreateType("var_arg", arg)
					elseif basic_types[arg] then
						type = ffibuild.CreateType("type", arg)
					elseif arg:find("%b() %b()") then
						type = ffibuild.CreateType("function", arg, meta_data)
					else
						local declaration, name = arg:match("^([%a%d%s_%*]-) ([%a%d_]-)$")

						if not declaration or (meta_data and meta_data.typedefs[name]) or basic_types[name] then
							declaration = arg
							name = "unknown_" .. i
						end

                        if meta_data then
                            if meta_data.enums["enum " .. declaration] then
                                declaration = "enum " .. declaration
                            end
                        end

						type = ffibuild.CreateType("type", declaration)

                        -- TODO
                        if meta_data and meta_data.typedefs[type:GetBasicType()] then
                            type.array_size = meta_data.typedefs[type:GetBasicType()].array_size
                        end

						type.name = name
					end

					arguments[i] = type
				end
			end

			return {
				name = func_name,
				arguments = arguments,
				return_type = ffibuild.CreateType("type", return_line),
				func_type = func_type,
			}
		end

		function FUNCTION:GetCopy()
			-- TODO: this doesn't work because i :Create does not handle callbacks that return callbacks
			--return ffibuild.CreateType("function", self:GetDeclaration(), self.callback)
			local copy = {}

			for k,v in pairs(self) do
				if k == "return_type" then
					copy[k] = v:GetCopy()
				elseif k == "arguments" then
					local new_arguments = {}
					for i,v in ipairs(v) do
						new_arguments[i] = v:GetCopy()
					end
					copy[k] = new_arguments
				else
					copy[k] = v
				end
			end

			return setmetatable(copy, FUNCTION)
		end

		function FUNCTION:GetBasicType()
			return "function"
		end

		function FUNCTION:GetSubType()
			return self:GetBasicType()
		end

		function FUNCTION:GetDeclaration(meta_data, func_type, func_name)
			local arg_line = {}

			if self.arguments then
				for i, arg in ipairs(self.arguments) do
					arg_line[i] = arg:GetDeclaration(meta_data)
				end
			end

			arg_line = "( " .. table.concat(arg_line, " , ") .. " )"

			local return_type = self.return_type

			return_type = return_type:GetPrimitive(meta_data)

			if return_type.func_type then
				local ret, urn = return_type:GetDeclaration(meta_data, "*", ""):match("^(.-%(%*) (.+)")
				local res = ret .. " " .. self.name .. " " .. arg_line .. " " .. urn

				return res
			end

			return return_type:GetDeclaration(meta_data)  .. "(" .. (func_type or self.func_type) .. " " .. (func_name or self.name or "") .. ")" .. arg_line
		end

		function FUNCTION:GetParameters(meta, check, max_arguments)
			if not self.arguments then return "", "" end

			if max_arguments and max_arguments < 0 then max_arguments = #self.arguments + max_arguments end

			local done = {}

			local parameters = {}
			local call = {}
			local types = {}

			for i, arg in ipairs(self.arguments) do
				if max_arguments and i > max_arguments then break end

				local name = arg.name or "_" .. i

				if ffibuild.IsKeyword(name) then
					name = name .. "_"
				end

				if meta and i == 1 then
					name = "self"
				end

				do -- fixes argument names that are the same
					if done[name] then
						name = name .. done[name]
					end

					done[name] = (done[name] or 0) + 1
				end

				table.insert(parameters, name)

				local res = check and check(arg, name) or name

				table.insert(call, res)
				table.insert(types, arg)
			end

			return table.concat(parameters, ", "), table.concat(call, ", "), types
		end

		function FUNCTION:FetchRequired(meta_data, out)
			if self.arguments then
				for _, type in ipairs(self.arguments) do
					type:FetchRequired(meta_data, out)
				end
			end

			self.return_type:FetchRequired(meta_data, out)
		end
	end

	do -- struct
		local STRUCT = metatables["struct"]

		local function explode(str, split)

			local temp = {}
			str = str:gsub("(%b{})", function(str) table.insert(temp, str) return "___TEMP___" end)

			local out = {}

			for val in str:gmatch("(.-)"..split) do
				if val:find("___TEMP___", nil, true) then val = val:gsub("___TEMP___", function() return table.remove(temp, 1) end) end
				table.insert(out, val)
			end

			return out
		end

		function STRUCT:Create(declaration, is_union, meta_data)
			declaration = declaration:sub(3, -2)

			local out = {}

			for _, line in ipairs(explode(declaration, " ; ")) do
				if line:find("^struct") or line:find("^union") then
					local keyword = line:match("^([%a%d_]+)")

					if line:find("%b{}") then
						local tag, content, name = line:match("^(" .. keyword .. " [%a%d_]+) (%b{}) (.+)")
						if not tag then
							content, name = line:match("^" .. keyword .. " (%b{}) (.+)")
						end

						if not content then
							content = line:match("^" .. keyword .. " (%b{})$")
							name = ""
							tag = ""
						end

						local type = ffibuild.CreateType("struct", content, keyword == "union")
						type.name = name
						type.tag = tag

						table.insert(out, type)

						if meta_data and tag then
							(keyword == "struct" and meta_data.structs or meta_data.unions)[tag] = type
						end
					elseif line:find(" , ") then
						local declaration, names = line:match("^("..keyword.." [%a%d_]+) (.+)")
						for name in (names .. " , "):gmatch("(.-) , ") do
							local type = ffibuild.CreateType("type", declaration)
							type.name = name
							table.insert(out, type)
						end
					else
						local declaration, name, array_size = match_type_declaration(line:match("^" .. keyword .. " (.+)"))
						declaration = keyword .. " " .. declaration
						local type = ffibuild.CreateType("type", declaration, array_size)
						type.name = name

						table.insert(out, type)
					end
				elseif line:find("%b() %b()") then
					table.insert(out, ffibuild.CreateType("function", (line:gsub("%( %(", "("):gsub("%) %)", ")"))))
				elseif line:find(" , ") then
					local declaration, names = line:match("([%a%d_]+) (.+)")
					for name in (names .. " , "):gmatch("(%S-) , ") do
						local type = ffibuild.CreateType("type", declaration)
						type.name = name
						table.insert(out, type)
					end
				elseif line:find(":") then
					local declaration, name = line:match("^([%a%d%s_%*]-) ([%a%d_:]-)$")


				else
					local declaration, name, array_size = match_type_declaration(line)

					local type
					if meta_data and meta_data.typedefs[declaration] then
						type = meta_data.typedefs[declaration]:GetCopy()
						type.prev_type = ffibuild.CreateType("type", declaration, array_size)
					else
						type = ffibuild.CreateType("type", declaration, array_size)
					end
					type.array_size = type.array_size or array_size
					type.name = name

					table.insert(out, type)
				end
			end

			return {
				data = out,
				struct = not is_union,
			}
		end

		function STRUCT:GetCopy()
			local copy = {data = {}, struct = self.struct, i = self.i}
			for i,v in ipairs(self.data) do
				copy.data[i] = v:GetCopy()
				copy.data[i].name = v.name
			end
			return setmetatable(copy, STRUCT)
		end

		function STRUCT:GetBasicType()
			return self.struct and "struct" or "union"
		end

		function STRUCT:GetSubType()
			return self:GetBasicType()
		end

		--TODO
		function STRUCT:GetDeclaration(meta_data)

			local str = " { "
			for _, type in ipairs(self.data) do
				if type.GetPrimitive and meta_data then
					type = type:GetPrimitive(meta_data)
				end

				if type.MetaType == "function" then
					str = str .. type:GetDeclaration(meta_data) .. " ; "
				elseif type.MetaType == "struct" then
					str = str .. type:GetBasicType() .. " " ..type:GetDeclaration(meta_data) .. " " .. type.name .. " ; "
				elseif type.array_size then

					-- TODO
					local array_size = type.array_size
					type.array_size = nil
					str = str .. type:GetDeclaration(meta_data) .. " " .. type.name .. array_size .. " ; "
					type.array_size = array_size
				else
					str = str .. type:GetDeclaration(meta_data) .. " " .. type.name .. " ; "
				end
			end
			str = str .. " }"

			return str
		end

		function STRUCT:FetchRequired(meta_data, out)
			for _, type in ipairs(self.data) do
				if type.FetchRequired then
					type:FetchRequired(meta_data, out)
				end
			end
		end
	end

	do -- var arg
		local VARARG = metatables.var_arg

		function VARARG:Create()
			return {}
		end

		function VARARG:GetDeclaration()
			return "..."
		end

		function VARARG:GetCopy()
			return VARARG:Create()
		end

		function VARARG:GetBasicType()
			return "var_arg"
		end
	end
end

do -- lua helper functions

	ffibuild.helper_functions = {
		chars_to_string = [[
	local function chars_to_string(ctyp)
		if ctyp ~= nil then
			return ffi.string(ctyp)
		end
		return ""
	end]],

		metatables = [[
	local metatables = {}
	local object_cache = {}

	local function wrap_pointer(ptr, meta_name)
		-- TODO
		-- you should be able to use cdata as key and it would use the address
		-- but apparently that doesn't work
		local id = tostring(ptr)

		if not object_cache[meta_name] then
			object_cache[meta_name] = setmetatable({}, {__mode = "v"})
		end

		if not object_cache[meta_name][id] then
			object_cache[meta_name][id] = setmetatable({ptr = ptr}, metatables[meta_name])
		end

		return object_cache[meta_name][id]
	end]],
		safe_clib_index = [[
		function SAFE_INDEX(clib)
			return setmetatable({}, {__index = function(_, k)
				local ok, val = pcall(function() return clib[k] end)
				if ok then
					return val
				elseif clib_index then
					return clib_index(k)
				end
			end})
		end
	]],
	}

	function ffibuild.StartLibrary(ffi_header, ...)
		local lua =
		"local ffi = require(\"ffi\")\n" ..
		"ffi.cdef([["..ffi_header.."]])\n" ..
		"local CLIB = ffi.load(_G.FFI_LIB or \""..ffibuild.lib_name.."\")\n" ..
		"local library = {}\n"

		if ... then
			for _, which in ipairs({...}) do
				if ffibuild.helper_functions[which] then
					lua = lua .. "\n\n--====helper " .. which .. "====\n"
					lua = lua .. ffibuild.helper_functions[which] .. "\n"
					lua = lua .. "--====helper " .. which .. "====\n\n"
				end
			end

		end

		return lua
	end

	function ffibuild.BuildLuaMetaTable(meta_name, declaration, functions, argument_translate, return_translate, meta_data, clib, ffi_metatype)
		local lua = ""
		lua = lua .. "do\n"
		lua = lua .. "\tlocal META = {\n"
		if not ffi_metatype then
			lua = lua .. "\t\tctype = ffi.typeof(\"" .. declaration .. "\"),\n"
		end
		for friendly_name, func_type in pairs(functions) do
			if type(func_type) == "string" then
				lua = lua .. "\t\t" .. friendly_name .. " = " .. func_type .. ",\n"
			else
				lua = lua .. "\t\t" .. friendly_name .. " = " .. ffibuild.BuildLuaFunction(func_type.name, func_type, argument_translate, return_translate, meta_data, true, clib) .. ",\n"
			end
		end
		lua = lua .. "\t}\n"
		lua = lua .. "\tMETA.__index = META\n"
		if ffi_metatype then
			lua = lua .. "\tffi.metatype(\"" .. declaration .. "\", META)\n"
		else
			lua = lua .. "\tmetatables." .. meta_name .. " = META\n"
		end
		lua = lua .. "end\n"
		return lua
	end

	function ffibuild.BuildLuaFunction(real_name, func_type, call_translate, return_translate, meta_data, first_argument_self, clib)
		clib = clib or "CLIB"

		local s = ""

		if call_translate or return_translate then
			local parameters, call = func_type:GetParameters(first_argument_self, call_translate and function(type, name)
				return	call_translate(type:GetDeclaration(meta_data), name, type, func_type) or name
			end)


			s = s .. "function(" .. parameters .. ") "
			s = s .. "local v = " .. clib .. "." .. real_name .. "(" .. call .. ") "
		else
			s = s .. clib .. "." .. real_name
		end

		if return_translate then
			local return_type = func_type.return_type
			local declaration = return_type:GetDeclaration(meta_data)

			local ret, func = return_translate(declaration, return_type, func_type)

			s = s .. (ret or "")

			if func then
				s = func(s)
			end
		end

		if call_translate or return_translate then
			s = s .. " return v "
			s = s .. "end"
		end

		return s
	end

	function ffibuild.BuildDefineEnums(file, starts_with, prepend, append, pattern)
		append = append or "\n"

		local temp = assert(io.open(file))
		local raw_header = temp:read("*all")
		temp:close()

		local temp_enums = {}

		local s = ""

		raw_header = raw_header:gsub("/%*.-%*/", "")

		raw_header:gsub("#define%s-(.-)[\n\r]", function(chunk)
			-- process all single quote strings
			chunk = chunk:gsub("('%S+')", function(val) return assert(loadstring("return (" .. val .. "):byte()"))() end)
			chunk = chunk:gsub("' '", string.byte(" "))


			-- handle *INT*_C macros

			-- UINT64_C needs to append ULL to the number
			chunk = chunk:gsub("UINT64_C%((.-)%)", "%1ULL")
			-- LL
			chunk = chunk:gsub("INT64_C%((.-)%)", "%1LL")

			-- don't care about the other casting functions
			chunk = chunk:gsub(".INT%d-_C%((.-)%)", "%1")

			-- remove C++ comments..
			chunk = chunk:gsub("(.*)//.+", "%1")

			 -- normalize everything to have equal spacing even between punctation
			chunk = chunk:gsub("([*%(%){}&%[%],;&|<>=])", " %1 ")
			chunk = chunk:gsub("%s+", " ")
			chunk = chunk:gsub(" %((.+)%) ", "%1")

			local key, val = chunk:match(" (%S+) (.+)")

			if not key then
				key = chunk:match(" (%S+)")
				val = "1"
				print("unable to find value for: ", key)
			end

			if temp_enums[val] then
				val = temp_enums[val]
			end

			temp_enums[key] = val

			local matched_key

			if pattern then
				matched_key = key:match(pattern)
			else
				matched_key = key
			end

			key = matched_key

			if key then
				-- if the prefix has been stripped the key might start with a number
				if key:find("^%d") then
					print("enum " .. key .. " starts with a number. prepending _")
					key = "_" .. key
				end

				if val:sub(#val-1, #val-1) == "f" then
					val = val:sub(0, -3)
					val = tonumber(val)
				elseif val:sub(1, 1) == "\"" then
					val = val:gsub("([%a_][%a%d_]+)", temp_enums)
					val = val:gsub('(".-)(" ")(.-")', "%1%3")
				else
					local ok, v = pcall(ffibuild.ParseEnumValue, val, nil, temp_enums)
					if ok then
						val = v
					else
						val = val:gsub("([%a_][%a%d_]+)", temp_enums)
					end
				end

				if val and loadstring("return " .. val) then
					s = s .. prepend .. key .. " = " .. tostring(val) .. append
				else
					print("unable to parse define enum: ", chunk)
				end
			end
		end)

		return s
	end

	function ffibuild.EndLibrary(lua, header)
		lua = lua .. "library.clib = CLIB\n"
		lua = lua .. "return library\n"

		local file = io.open("./lib"..ffibuild.lib_name..".lua", "wb")
		file:write(lua)
		file:close()

		-- check if this wokrs if possible
		local ok, err = pcall(function()
			assert(loadstring(lua))()
		end)
		if not ok then
			print(err)
			local line = tonumber(err:match("line (%d+)"))
			if line then
				local i = 1
				for s in header:gmatch("(.-)\n") do
					if line > i - 3 and line < i + 3 then
						print(i .. ": " .. s)
					end
					i = i + 1
				end
			end
		else
			local path = "../../../../data/bin/" .. jit.os:lower() .. "_" .. jit.arch:lower() .. "/"
			print("copying lib* files to: ", path)
			os.execute("mkdir -p " .. path)
			os.execute("cp lib* " .. path)
		end
	end

	local keywords = {
		["and"] = true,
		["break"] = true,
		["do"] = true,
		["else"] = true,
		["elseif"] = true,
		["end"] = true,
		["false"] = true,
		["for"] = true,
		["function"] = true,
		["if"] = true,
		["in"] = true,
		["local"] = true,
		["nil"] = true,
		["not"] = true,
		["or"] = true,
		["repeat"] = true,
		["return"] = true,
		["then"] = true,
		["true"] = true,
		["until"] = true,
		["while"] = true,
	}

	function ffibuild.IsKeyword(str)
		return keywords[str] ~= nil
	end
end

return ffibuild
