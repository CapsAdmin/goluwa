---------------------------------------------------
-- logger 
---------------------------------------------------
local function log(...)
	-- print(...)
end
local function vlog(...)
	-- print(...)
end


---------------------------------------------------
-- symbol table
---------------------------------------------------
--[[
	sym = {
		symname1 = {
			deps = { dep_sym1, dep_sym2, ... },
			cdef = "string code"
		},
		symname2 = {
			...
		},
		...
	}
]]
local function make_sym_dep(sym, name, deps, cdef)
	local res = {}
	for _,dep in ipairs(deps or {}) do
		log(name.." depends on ["..dep.."]")
		assert(sym[dep], "["..dep .. "] not predefined")
	end
	local cdef = cdef:gsub("^%s+", ""):gsub("%s+$", "")
	if sym[name] then
		log('caution:'..name.." already exist:"..debug.traceback())
	end
	table.insert(sym[1], name)
	sym[name] = {
		name = name,
		deps = deps,
		cdef = cdef,
		prio = #(sym[1]),
	}
end

local function get_real_sym_name(pfx, name)
	return pfx.." "..name
end
local function get_func_sym_name(name)
	return get_real_sym_name("func", name)
end
local function make_func_dep(sym, name, deps, cdef)
	make_sym_dep(sym, get_func_sym_name(name), deps, cdef)
end

local function make_incomplete_decl(sym, name, cdef)
	if sym[name] and (not sym[name].temp) then
		log(name .. " already declared as:["..sym[name].cdef.."]")
		return
	end
	table.insert(sym[1], name)
	sym[name] = {
		name = name,
		cdef = cdef,
		temp = true,
		prio = #(sym[1]),
	}
end

local function has_sym(sym, name)
	return sym[name]
end

local function new_sym_table()
	local sym = {[1] = {}}
	make_sym_dep(sym, "void", nil, "")

	make_sym_dep(sym, "_Bool", nil, "")
	make_sym_dep(sym, "bool", nil, "")

	make_sym_dep(sym, "char", nil, "")
	make_sym_dep(sym, "signed char", nil, "")
	make_sym_dep(sym, "unsigned char", nil, "")

	make_sym_dep(sym, "int", nil, "")
	make_sym_dep(sym, "signed int", nil, "")
	make_sym_dep(sym, "unsigned int", nil, "")

	make_sym_dep(sym, "short int", nil, "")
	make_sym_dep(sym, "signed short int", nil, "")
	make_sym_dep(sym, "unsigned short int", nil, "")

	make_sym_dep(sym, "long int", nil, "")
	make_sym_dep(sym, "signed long int", nil, "")
	make_sym_dep(sym, "unsigned long int", nil, "")

	make_sym_dep(sym, "long long int", nil, "")
	make_sym_dep(sym, "signed long long int", nil, "")
	make_sym_dep(sym, "unsigned long long int", nil, "")

	make_sym_dep(sym, "double", nil, "")
	make_sym_dep(sym, "long double", nil, "")
	make_sym_dep(sym, "float", nil, "")

	make_sym_dep(sym, "__builtin_va_list", nil, "")

	return sym
end


---------------------------------------------------
-- basic elements 
---------------------------------------------------
local TYPEDEF_SYMBOL="typedef"
local SPACE="%s+"
local OPTSPACE="%s*"
local OPT_UNDERSCORE="%_*"
local SPACE_OR_STAR="[%s%*]+"
local OPT_SPACE_OR_STAR="[%s%*]*"
local TYPENAME="[_%w]+"
local OPT_TYPENAME="[_%w]*"
local ALL_REMAINS="[^%;]*"
local ALL_REMAINS_IN_ARG_DECL="[^%,]*"
local VAR_DECL=OPT_SPACE_OR_STAR.."[_%w]+%s*[%[%]%w%s]*"
local BLACKET1="%b()"
local BLACKET2="%b{}"
local MAY_HAVE_ARRAY_BLACKET="[%[%]%w%s]*"
local STRUCTURE_SYMBOL=TYPENAME
local STRUCT_VAR_LIST=BLACKET2
local ARG_VAR_LIST=BLACKET1
local CODE_BLOCK=BLACKET2
local EXT_ATTR_TAG="%$([0-9]+)" -- replace to actual __attribute__(...)/__asm(...)/__declspec(...)
-- combination of extern/static/inline/auto/register/volatile/signed/unsigned/EXT_ATTR_TAG+typename
local QUALIFIER="[_%w%s%$]*[_%w]"
local OPT_QUALIFIER="[_%w%s%$]*[_%w]?"
local QUALIFY_KEYWORD = {
	"int",
	"char",
	"const",
	"signed",
	"unsigned",
	"long long",
	"long",
	"short",
	"struct",
	"enum",
	"union",
	"extern",
	"static",
	"inline",
	"volatile",
	"auto",
	"register",
}
local QUALIFY_KEYWORD_CAPTURE = {
	EXT_ATTR_TAG, 
}
local FUNC_TYPE_SYMBOL="%(?"..VAR_DECL..OPTSPACE.."%)?"
local HO_FUNC_TYPE_SYMBOL="%(?"..VAR_DECL..OPTSPACE..ARG_VAR_LIST..OPTSPACE.."%)?"

local function init_qualifer_keywords()
	local tmp = {}
	for _,kw in ipairs(QUALIFY_KEYWORD) do
		table.insert(tmp, "^"..OPT_UNDERSCORE.."("..kw..")"..OPT_UNDERSCORE)
	end
	QUALIFY_KEYWORD = tmp
end
init_qualifer_keywords()


-- element definition with capture

---------------------------------------------------
-- element parser
---------------------------------------------------
local function match(src, pattern)
	local m = {src:find(pattern)}
	local s, e = table.remove(m, 1), table.remove(m, 1)
	if s and e >= s then
		return s, e, m
	else
		return nil
	end
end

local function restore_src(src, ext_attr_list)
	return src:gsub(EXT_ATTR_TAG, function (n)
		return ext_attr_list[tonumber(n)]
	end)
end

local MAIN_PATTERN_LIST
local PARSER_MAP
local function common_parser(sym, deps, body, patterns, sep, opaque)
	-- trim
	body = body:gsub("^%s+", ""):gsub("%s+$", "")
	while true do
		local found
		for _, pattern in ipairs(patterns) do
			local s, e, m = match(body, pattern..(sep or "").."%s*")
			vlog('try match:', "["..(#body <= 100 and body or body:sub(1, 100).."<...snip...>").."]", s, e, _, pattern)
			if s then
				found = true
				local src = body:sub(s, e)
				--print("src="..src:gsub("^%s+", ""):gsub("%s+$", ""))
				body = body:sub(e+1)
				local cb = PARSER_MAP[patterns][pattern]
				log('match result:', pattern, "["..src.."]")
				for _,mm in ipairs(m) do
					vlog('matches:', _, "["..mm.."]")
				end
				local symbol = cb(sym, opaque, deps, m, src)
				if symbol then
					if type(symbol) == "string" then
						vlog("match result2:["..tostring(symbol).."]")
						table.insert(deps, symbol)
					end
				end
				break
			end
		end
		if not found or (#body <= 0) then
			if #body > 0 then
				log("no pattern matched:["..body.."]")
			end
			break
		end
	end
	return sym
end

local qualifier_patterns = {
	"^(long long)"..OPTSPACE, 
	"^([_%w$]+)"..OPTSPACE,
}
local function common_parse_qualifier(sym, src, ext_attr_list)
	local attr = {}
	local symbol
	local varname
	-- trim
	src = src:gsub("^%s+", ""):gsub("%s+$", "")
	while true do
		local found
		local s, e, m 
		-- special treatment for evil "long long" (has space in keyword)
		for _,pattern in ipairs(qualifier_patterns) do
			s, e, m = match(src, pattern)
			if s then break end
		end
		if s then
			src = src:sub(e + 1)
			local token = m[1]
			for _, kw in ipairs(QUALIFY_KEYWORD) do
				s, e, m = match(token, kw)
				--print('token and kw:'..token.."|"..kw, s, e, #token, m and m[1])
				if s and (e == #token) then
					attr[m[1]] = true
					found = true
					break
				end
			end
			if not found then
				for _, kw in ipairs(QUALIFY_KEYWORD_CAPTURE) do
					s, e, m = token:find(kw)
					if s then
						attr[kw] = ext_attr_list[tostring(m)]
						found = true
						break
					end
				end
			end
			if not found then
				if not symbol then
					symbol = token
				else
					-- var name decl also contained in qualifier.
					-- it occurs in most cases. eg) long x;
					-- its not harmful because we only want to know type dependency,
					-- don't need to care about varname.
					varname = token
				end
			end
		end
		if #src <= 0 then
			break
		end
	end
	-- in the case of [long x], symbol will be [x] but actually it means [long int x]
	local base_type
	for _,kw in ipairs({"char", "int"}) do
		if attr[kw] then
			log("attr has kw:"..kw)
			if symbol and (not base_type) and (not varname) then
				varname = symbol
				vlog('varname => ', varname)
			end
			base_type = kw
			break
		end
	end
	for _,kw in ipairs({"short", "long", "long long", "unsigned", "signed"}) do
		if attr[kw] then
			log("attr has kw:"..kw)
			if symbol and (not base_type) and (not varname) then
				varname = symbol
				vlog('varname => ', varname)
			end
			base_type = kw.." "..(base_type or "int")
		end
	end

	-- otherwise symbol is actually typename.
	vlog('ret:', base_type or symbol, attr, varname)
	if base_type then
		symbol = base_type
	else
		for _,kw in ipairs({"struct", "union", "enum"}) do
			if attr[kw] then
				log("attr has kw:"..kw)
				symbol = kw.." "..symbol
				break
			end
		end
	end
	if not has_sym(sym, symbol) then
		make_incomplete_decl(sym, symbol, src)
	end
	return symbol, attr, varname
end

local TYPEDECL_PATTERN_LIST
local function common_parse_type_decls(sym, deps, src)
	local depslist = {}
	common_parser(
		sym, 
		deps, 
		src:gsub("^%,", ""), 
		TYPEDECL_PATTERN_LIST,
		"%,?",
		depslist
	)
	return deps, depslist
end

local STRUCT_PATTERN_LIST
local function common_parse_struct_deps(sym, deps, struct_body, parent_struct)
	return common_parser(
		sym, 
		deps, 
		struct_body:sub(2, -2), 
		STRUCT_PATTERN_LIST,
		"%;",
		parent_struct
	)
end

local ARG_PATTERN_LIST
local function common_parse_argument_deps(sym, deps, args_body)
	return common_parser(
		sym,
		deps, 
		args_body:sub(2, -2), 
		ARG_PATTERN_LIST,
		"%,?"
	)
end


---------------------------------------------------
-- type or var decl 
---------------------------------------------------
local VAR_DECL_CAPTURE=OPT_SPACE_OR_STAR..
	"([_%w]+)"..OPTSPACE..
	MAY_HAVE_ARRAY_BLACKET

-- *var[size]
local VAR_DECL_VAR="^"..
	VAR_DECL_CAPTURE..OPTSPACE
local function parse_var_decl_var(sym, opaque, deps, matches, src)
	table.insert(deps, matches[1])
end

-- (*var[size])(...)
local VAR_DECL_VAR_FUNC="^"..OPT_SPACE_OR_STAR.."%(?"..
	VAR_DECL_CAPTURE..OPTSPACE.."%)?"..OPTSPACE..
	"("..ARG_VAR_LIST..")"..OPTSPACE
local function parse_var_decl_var_func(sym, opaque, deps, matches, src)
	table.insert(deps, matches[1])
	local argdeps = {}
	common_parse_argument_deps(sym, argdeps, matches[2])
	opaque[matches[1]] = argdeps
end

-- (*(*var[size])(...))(...)
local VAR_DECL_VAR_HO_FUNC="^"..OPT_SPACE_OR_STAR.."%(?"..
	VAR_DECL_CAPTURE..OPTSPACE..
	"("..ARG_VAR_LIST..")"..OPTSPACE.."%)?"..OPTSPACE..
	"("..ARG_VAR_LIST..")"..OPTSPACE
local function parse_var_decl_var_high_order_func(sym, opaque, deps, matches, src)
	table.insert(deps, matches[1])
	local argdeps = {}
	common_parse_argument_deps(sym, argdeps, matches[2])
	common_parse_argument_deps(sym, argdeps, matches[3])
	opaque[matches[1]] = argdeps
end

---------------------------------------------------
-- typedef 
---------------------------------------------------
-- typedef qualifier *type1_t[size1], *type2_t[size2], ..., *typeN_t[sizeN], 
-- *ftype1[fsize1](...), 
-- (*(*hoftype[hofsize])(...))(...); (currently upto 2 level higher order function)
local TYPEDEF="^"..TYPEDEF_SYMBOL..SPACE..
	"("..QUALIFIER..")"..OPTSPACE..
	"("..ALL_REMAINS..")"..";"
local function parse_typedef(sym, opaque, deps, matches, src)
	src = restore_src(src, opaque)
	local typename, attr, varname = common_parse_qualifier(sym, matches[1], opaque)
	local typedecls, depslist = common_parse_type_decls(sym, {}, matches[2])
	if varname then
		-- first type declarator may contains in qualifier
		table.insert(typedecls, varname)
	end
	for _,typedecl in ipairs(typedecls) do
		local depends = depslist[typedecl]
		-- predecl is not counted as dependency (because no actual declaration required)
		if depends then
			table.insert(depends, typename)
		else
			depends = {typename}
		end
		if typename == typedecl then
			log('typedecl same name as typename:'..typename)
			make_incomplete_decl(sym, typename, src)
		else
			make_sym_dep(sym, typedecl, depends, src)
		end
	end
end

-- typedef struct __struct_t {...} *struct1_t[size1], *struct2_t[size2], ..., *structN_t[sizeN];
-- typedef union __union_t {...} *union1_t[size1], *union2_t[size2], ..., *unionN_t[sizeN];
-- typedef enum __enum_t {...} *enum1_t[size1], *enum2_t[size2], ..., *enumN_t[sizeN];
local STRUCTURE_TYPEDEF="^"..TYPEDEF_SYMBOL..SPACE..
	"("..STRUCTURE_SYMBOL..")"..SPACE..
	"("..TYPENAME..")"..OPTSPACE..
	"("..STRUCT_VAR_LIST..")"..OPTSPACE..
	"("..ALL_REMAINS..")"..";"
local function parse_structure_typedef(sym, opaque, deps, matches, src)
	src = restore_src(src, opaque)
	local typename = get_real_sym_name(matches[1], matches[2])
	local vardeps = {}
	if matches[1] == "enum" then
		make_sym_dep(sym, typename, {}, src)
	else
		common_parse_struct_deps(sym, vardeps, matches[3], typename)
		make_sym_dep(sym, typename, vardeps, src)
	end
	local typedecls, depslist = common_parse_type_decls(sym, {}, matches[4])
	for _,typedecl in ipairs(typedecls) do
		make_sym_dep(sym, typedecl, {typename}, src)
	end
end

-- typedef struct {...} *struct1_t[size1], *struct2_t[size2], ..., *structN_t[sizeN];
-- typedef union {...} *union1_t[size1], *union2_t[size2], ..., *unionN_t[sizeN];
-- typedef enum {...} *enum1_t[size1], *enum2_t[size2], ..., *enumN_t[sizeN];
local ANON_STRUCTURE_TYPEDEF="^"..TYPEDEF_SYMBOL..SPACE..
	"("..STRUCTURE_SYMBOL..")"..OPTSPACE..
	"("..STRUCT_VAR_LIST..")"..OPTSPACE..
	"("..ALL_REMAINS..")"..";"
local function parse_anon_structure_typedef(sym, opaque, deps, matches, src)
	src = restore_src(src, opaque)
	local vardeps = {}
	if matches[1] ~= "enum" then
		common_parse_struct_deps(sym, vardeps, matches[2])
	end
	local typedecls, depslist = common_parse_type_decls(sym, {}, matches[3])
	for _,typedecl in ipairs(typedecls) do
		make_sym_dep(sym, typedecl, vardeps, src)
	end
end


---------------------------------------------------
-- declaration
---------------------------------------------------

-- qualifier func(...) qualifier;
-- qualifier (func)(...) qualifier;
local FUNC_DECL_CAPTURE="^"..
	"("..QUALIFIER..")"..SPACE_OR_STAR.."%(?"..OPT_SPACE_OR_STAR..
	"("..TYPENAME..")"..OPTSPACE.."%)?"..OPTSPACE..
	"("..ARG_VAR_LIST..")"..
	OPT_QUALIFIER
local FUNC_DECL = FUNC_DECL_CAPTURE..";"
local function parse_func_decl(sym, opaque, deps, matches, src)
	src = assert(restore_src(src, opaque), "invalid restore src")
	local typename, attr = common_parse_qualifier(sym, matches[1], opaque)
	local funcdecl = matches[2]
	local depends = {}
	common_parse_argument_deps(sym, depends, matches[3])
	table.insert(depends, typename)
	make_func_dep(sym, funcdecl, depends, src)
end

-- qualifier (*ho_func(...))(...) qualifier;
local HO_FUNC_DECL_CAPTURE="^"..
	"("..QUALIFIER..")"..SPACE_OR_STAR.."%("..OPT_SPACE_OR_STAR..
	"("..OPT_TYPENAME..")"..OPTSPACE..
	"(".."%b()"..")"..OPTSPACE.."%)"..OPTSPACE..
	"("..ARG_VAR_LIST..")"..
	OPT_QUALIFIER
local HO_FUNC_DECL = HO_FUNC_DECL_CAPTURE..";"
local function parse_high_order_func_decl(sym, opaque, deps, matches, src)
	src = restore_src(src, opaque)
	local typename, attr = common_parse_qualifier(sym, matches[1], opaque)
	local funcdecl = matches[2]
	local depends = {}
	common_parse_argument_deps(sym, depends, matches[3])
	common_parse_argument_deps(sym, depends, matches[4])
	table.insert(depends, typename)
	make_func_dep(sym, funcdecl, depends, src)
end

-- qualifier func(...) qualifier { ... };
local INLINE_FUNC_DECL = FUNC_DECL_CAPTURE .. CODE_BLOCK
local function parse_inline_func_decl(sym, opaque, deps, matches, src)
	-- because lj cannot access inline function (I think), no dependency added.
	-- src = restore_src(src, opaque)
end

-- struct struct_t {...};
-- union union_t {...};
-- enum enum_t {...};
local STRUCTURE_DECL="^"..
	"("..STRUCTURE_SYMBOL..")"..SPACE..
	"("..TYPENAME..")"..OPTSPACE..
	"("..STRUCT_VAR_LIST..")"..OPT_QUALIFIER..";"
local function parse_structure_decl(sym, opaque, deps, matches, src)
	src = restore_src(src, opaque)
	local typename, vardeps = get_real_sym_name(matches[1], matches[2]), {}
	common_parse_struct_deps(sym, vardeps, matches[3], typename)
	make_sym_dep(sym, typename, vardeps, src)
end

-- enum {...};
local ANON_STRUCTURE_DECL="^"..
	"("..STRUCTURE_SYMBOL..")"..OPTSPACE..
	"("..STRUCT_VAR_LIST..")"..OPTSPACE..";"
local function parse_anon_structure_decl(sym, opaque, deps, matches, src)
	-- no new dependency added
	-- src = restore_src(src, opaque)
end

-- struct struct_t;
-- union union_t;
-- enum enum_t;
local STRUCTURE_PREDECL="^"..
	"("..STRUCTURE_SYMBOL..")"..SPACE..
	"("..TYPENAME..")"..OPTSPACE..";"
local function parse_structure_predecl(sym, opaque, deps, matches, src)
	src = restore_src(src, opaque)
	local typename = get_real_sym_name(matches[1], matches[2])
	make_incomplete_decl(sym, typename, src)
end

-- qualifier *val1[size1], *val2[size2], ..., *valN[sizeN];
local EXTERN_DECL_CAPTURE="^"..
	"("..QUALIFIER..")"..
	"("..ALL_REMAINS..")"
local EXTERN_DECL = EXTERN_DECL_CAPTURE .. ";"
local function parse_extern_decl(sym, opaque, deps, matches, src)
	-- no new dependency added
	-- src = restore_src(src, opaque)
end

-- qualifier (*fval1)(...) qualifier;
local EXTERN_FUNC_DECL="^"..
	"("..QUALIFIER..")"..
	"("..FUNC_TYPE_SYMBOL..")"..
	OPT_QUALIFIER..";"
local function parse_extern_func_decl(sym, opaque, deps, matches, src)
	-- no new dependency added
	-- src = restore_src(src, opaque)
end


---------------------------------------------------
-- struct decl
---------------------------------------------------
-- qualifier *val1[size1], ..., *valN[size2];
-- qualifier val1:bit1, val2:bit2, ..., valN:bitN;
local STRUCT_VAR_VARIABLE=EXTERN_DECL_CAPTURE
local function parse_struct_var_variable(sym, opaque, deps, matches, src)
	-- $1 : qualifier
	-- $2 : vardecls
	local typename, attr = common_parse_qualifier(sym, matches[1], opaque)
	assert(#typename > 0, "invalid qualifier:", matches[1])
	table.insert(deps, typename)
end

-- qualifier (**fval)(...) qualifier;
local STRUCT_VAR_FUNC=FUNC_DECL_CAPTURE
local function parse_struct_var_func(sym, opaque, deps, matches, src)
	local typename, attr = common_parse_qualifier(sym, matches[1], opaque)
	local argdeps = {}
	common_parse_argument_deps(sym, deps, matches[3])
	table.insert(deps, typename)
end

-- qualifier (**hofval(...))(...) qualifier;
local STRUCT_VAR_HO_FUNC=HO_FUNC_DECL_CAPTURE
local function parse_struct_var_high_order_func(sym, opaque, deps, matches, src)
	local typename, attr = common_parse_qualifier(sym, matches[1], opaque)
	local argdeps = {}
	common_parse_argument_deps(sym, deps, matches[3])
	common_parse_argument_deps(sym, deps, matches[4])
	table.insert(deps, typename)		
end

-- (struct/union/enum) {...} *val1, *val2, ..., *valN;
local STRUCT_VAR_ANON_STRUCT="^"..
	"("..STRUCTURE_SYMBOL..")"..SPACE..
	"("..STRUCT_VAR_LIST..")"..OPT_SPACE_OR_STAR..
	"("..ALL_REMAINS..")"
local function parse_struct_var_anon_struct(sym, opaque, deps, matches, src)
	common_parse_struct_deps(sym, deps, matches[2], opaque)
end

-- (struct/union/enum) typename_t {...} *val1, *val2, ..., *valN;
local STRUCT_VAR_STRUCT="^"..
	"("..STRUCTURE_SYMBOL..")"..SPACE..
	"("..TYPENAME..")"..OPTSPACE..
	"("..STRUCT_VAR_LIST..")"..OPTSPACE..
	"("..ALL_REMAINS..")"
local function parse_struct_var_struct(sym, opaque, deps, matches, src)
	local vardeps = {}
	local typename = get_real_sym_name(matches[1], matches[2])
	common_parse_struct_deps(sym, vardeps, matches[3], opaque)
	-- currently, struct declaration in struct cannot be injected (empty string returns)
	make_sym_dep(sym, typename, vardeps, "")
	table.insert(deps, typename)
end


---------------------------------------------------
-- argument decl
---------------------------------------------------
-- non_ext_qualifier type_t *val[size], 
local ARG_VAR="^"..
	"("..QUALIFIER..")"..
	"("..ALL_REMAINS_IN_ARG_DECL..")"
local function parse_arg_var(sym, opaque, deps, matches, src)
	-- $1 : qualifier
	-- $2 : vardecls
	local typename, attr = common_parse_qualifier(sym, matches[1], opaque)
	assert(typename and #typename > 0, "invalid qualifier:["..matches[1].."]")
	table.insert(deps, typename)	
end

-- qualifier retval_t (**fval)(...) qualifier, 
local ARG_VAR_FUNC="^"..
	"("..QUALIFIER..")"..SPACE_OR_STAR.."%(?"..SPACE_OR_STAR..
	"("..OPT_TYPENAME..")"..OPTSPACE.."%)?"..OPTSPACE..
	"("..ARG_VAR_LIST..")"..
	OPT_QUALIFIER
local function parse_arg_var_func(sym, opaque, deps, matches, src)
	local typename, attr = common_parse_qualifier(sym, matches[1], opaque)
	assert(typename and #typename > 0, "invalid qualifier:["..matches[1].."]")
	common_parse_argument_deps(sym, deps, matches[3])
	table.insert(deps, typename)
end

-- qualifier retval_t ((**fval)(...))(...) qualifier, 
local ARG_VAR_HO_FUNC=HO_FUNC_DECL_CAPTURE
local function parse_arg_var_high_order_func(sym, opaque, deps, matches, src)
	local typename, attr = common_parse_qualifier(sym, matches[1], opaque)
	assert(typename and #typename > 0, "invalid qualifier:["..matches[1].."]")
	common_parse_argument_deps(sym, deps, matches[3])
	common_parse_argument_deps(sym, deps, matches[4])
	table.insert(deps, typename)
end


---------------------------------------------------
-- pattern list (define its matching order)
---------------------------------------------------
MAIN_PATTERN_LIST = {
	-- structure contains ; in its declaration, so check before other pattern.
	-- to prevent from matching wrongly.
	STRUCTURE_TYPEDEF,
	ANON_STRUCTURE_TYPEDEF,
	STRUCTURE_DECL,
	ANON_STRUCTURE_DECL,
	TYPEDEF,
	INLINE_FUNC_DECL,
	HO_FUNC_DECL,
	FUNC_DECL,
	STRUCTURE_PREDECL,
	EXTERN_DECL,
	EXTERN_FUNC_DECL,
}

STRUCT_PATTERN_LIST = {
	STRUCT_VAR_HO_FUNC,
	STRUCT_VAR_FUNC,
	STRUCT_VAR_STRUCT,	
	STRUCT_VAR_ANON_STRUCT,
	STRUCT_VAR_VARIABLE,
}

ARG_PATTERN_LIST = {
	ARG_VAR_HO_FUNC,
	ARG_VAR_FUNC,
	ARG_VAR,
}

TYPEDECL_PATTERN_LIST = {
	VAR_DECL_VAR_HO_FUNC,
	VAR_DECL_VAR_FUNC, 
	VAR_DECL_VAR,
}

PARSER_MAP = {
	-- main
	[MAIN_PATTERN_LIST] = {
		[TYPEDEF] = parse_typedef,
		[STRUCTURE_TYPEDEF] = parse_structure_typedef,
		[ANON_STRUCTURE_TYPEDEF] = parse_anon_structure_typedef,
		[FUNC_DECL] = parse_func_decl,
		[HO_FUNC_DECL] = parse_high_order_func_decl,
		[STRUCTURE_DECL] = parse_structure_decl,
		[ANON_STRUCTURE_DECL] = parse_anon_structure_decl,
		[STRUCTURE_PREDECL] = parse_structure_predecl,
		[EXTERN_DECL] = parse_extern_decl,
		[EXTERN_FUNC_DECL] = parse_extern_func_decl,
		[INLINE_FUNC_DECL] = parse_inline_func_decl,
	},
	-- struct var decl
	[STRUCT_PATTERN_LIST] = {
		[STRUCT_VAR_VARIABLE] = parse_struct_var_variable,
		[STRUCT_VAR_FUNC] = parse_struct_var_func,
		[STRUCT_VAR_HO_FUNC] = parse_struct_var_high_order_func,
		[STRUCT_VAR_ANON_STRUCT] = parse_struct_var_anon_struct,
		[STRUCT_VAR_STRUCT] = parse_struct_var_struct,	
	},
	-- arg decl
	[ARG_PATTERN_LIST] = {
		[ARG_VAR] = parse_arg_var,
		[ARG_VAR_FUNC] = parse_arg_var_func,
		[ARG_VAR_HO_FUNC] = parse_arg_var_high_order_func,
		[ARG_VAR_FUNC] = parse_arg_var_func,	
	},
	-- type decl
	[TYPEDECL_PATTERN_LIST] = {
		[VAR_DECL_VAR] = parse_var_decl_var,
		[VAR_DECL_VAR_FUNC] = parse_var_decl_var_func, 
		[VAR_DECL_VAR_HO_FUNC] = parse_var_decl_var_high_order_func,
	}
}

---------------------------------------------------
-- parse main
---------------------------------------------------
local function parse(tree, code)
	local sym = tree or new_sym_table()
	local attrs = {}
	local function inject_ext(a)
		table.insert(attrs, a)
		return "$"..#attrs.." "
	end
	-- parse and replace all __attribute__/__declspec/__asm
	code = code:gsub("__attribute__%s*%b()", inject_ext)
		:gsub("__declspec%s*%b()", inject_ext)
		:gsub("__asm_*%s*%b()", inject_ext)
		:gsub("__extension__", "") -- its ignored.
	return common_parser(
		sym,
		{},
		code:gsub("^%s+", ""),
		MAIN_PATTERN_LIST,
		nil, -- pattern list itself define sep.
		attrs
	)
end

local function traverse_cdef(tree, symbol, injected, depth)
	local sym = assert(tree[symbol], "cdef not found:["..symbol.."]")
	assert(#sym.name > 0, "invalid sym:"..sym.name)
	for _,dep in ipairs(sym.deps or {}) do
		if not injected.lookup[dep] then
			if not injected.seen[dep] then
				injected.seen[dep] = true
				traverse_cdef(tree, dep, injected, depth + 1)
			end
		end
	end
	if not injected.lookup[symbol] then
		injected.lookup[symbol] = true
		-- it is possible that multiple symbols defined in same cdef
		-- eg) typedef struct A {...} B; >> A and B is declared at the same time, 
		-- so has same cdef. de-dupe that
		if not injected.chunks[sym.cdef] then
			injected.chunks[sym.cdef] = true
			table.insert(injected.list, sym)
		end
	end
end

local function get_name_in_sym(tree, symbol)
	local s, e = symbol:find('%s+')
	if s then
		local pfx = symbol:sub(1, s - 1)
		return pfx == "typename" and symbol:sub(e+1) or symbol
	else
		for _,pfx in ipairs({"struct", "func", "union", "enum"}) do
			local fsym = get_real_sym_name(pfx, symbol)
			if tree[fsym] then
				return fsym
			end
		end
		return symbol
	end
end

local function inject(tree, symbols, already_imported)
	local injected = {
		lookup = already_imported or {},
		list = {},
		seen = {},
		chunks = {},
	}
	if type(symbols) == 'table' then
		for _,symbol in ipairs(symbols) do
			if not injected.lookup[symbol] then
				traverse_cdef(tree, get_name_in_sym(tree, symbol), injected, 0)
			end
		end
	else
		for _,k in pairs(tree[1]) do
			if not injected.lookup[k] then
				-- print('inject:'..k..'['..tree[k].cdef..']')
				traverse_cdef(tree, k, injected, 0)
			end
		end
	end
	local cdef = ""
	table.sort(injected.list, function (e1, e2) return e1.prio < e2.prio end)
	for _,sym in ipairs(injected.list) do
		log("sym injected:["..sym.name.."]["..sym.cdef.."]")
		assert(sym.cdef, "invalid sym no cdef:"..sym.name)
		cdef = (cdef .. "\n" .. (sym.cdef or ""))
	end
	log("cdef injected:[["..cdef.."]]")
	return cdef
end

-- module
return {
	parse = parse,
	inject = inject,
	name = get_name_in_sym,
}
