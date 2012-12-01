local types =
{
	number = 0,
	string = "",
	table = {},
	boolean = false,
	["function"] = function() end,
	userdata = newproxy(),
}

local function get_params(func)
	local args = {types.userdata}
	local returns

	for i=1, 100 do
		local data = {pcall(func, unpack(args))}
		local ok = data[1]
		local msg = data[2]

		if not ok then
			local pos, type = msg:match("bad argument #(%d+).+%((.+) expected")
			if pos and type then
				if type:find("/", nil, true) then
					args[tonumber(pos)] = type:gsub("/", "_")
					type = type:match("(.-)/")
				else
					args[tonumber(pos)] = types[type]
				end

				args[#args+1] = types.userdata
			else
				break
			end
		else
			table.remove(data, 1)
			returns = data
		end

		if ok or #args > 10 then
			break
		end
	end

	for pos, var in pairs(args) do
		if type(var) ~= "string" or not var:find("_") then
			args[pos] = {type = typex(var)}
		end
	end

	if returns then
		for pos, var in pairs(returns) do
			returns[pos] = {type = typex(var)}
		end
	end

	args[#args] = nil

	return args, returns
end

local func_template =
[[_DESCRIPTION_
== Function ==
=== Synopsis ===
<source lang="lua">
_LIB_NAME_._FUNC_NAME_( _ARGS_ )
</source>
=== Arguments ===
_PARAMS_
=== Returns ===
_RETURNS_
== Examples ==
_EXAMPLES_
== Notes ==
_NOTES_
== See Also ==
_SEE_ALSO_]]

local function generate_func_source(lib_name, func_name, args, returns, description, examples, notes, see_also)
	local str = func_template

	see_also = (see_also or "") .. ('* [[%s]]\n'):format(lib_name)

	str = str:gsub("_DESCRIPTION_", description or "")
	str = str:gsub("_EXAMPLES_", examples or "")
	str = str:gsub("_NOTES_", notes or "")
	str = str:gsub("_SEE_ALSO_", see_also or "")

	str = str:gsub("_LIB_NAME_", lib_name)
	str = str:gsub("_FUNC_NAME_", func_name)

	if args then
		local line = ""
		local params = ""
		for key, val in ipairs(args) do
			params = params .. ('{{param|%s|%s|%s}}\n'):format(val.type or "nil", val.name or "", val.desc or "")
			line = line .. val.type
			if key ~= #args then
				line = line .. ", "
			end
		end
		str = str:gsub("_ARGS_", line)
		str = str:gsub("_PARAMS_", params)
	else
		str = str:gsub("_ARGS_", "")
		str = str:gsub("_PARAMS_", "")
	end

	if returns then
		local line = ""
		local params = ""
		for key, val in ipairs(returns) do
			params = params .. ('{{param|%s|%s|%s}}\n'):format(val.type or "nil", val.name or "", val.desc or "")
		end
		str = str:gsub("_RETURNS_", params)
	else
		str = str:gsub("_RETURNS_", "")
	end

	return str
end

local str = ""
for lib_name, funcs in pairs(_G) do
    if type(funcs) == "table" and lib_name:lower() == lib_name then
		str = str .. string.format("\n\n__description__\n== Functions ==\n", lib_name)

		for func_name, func in pairs(funcs) do
			if type(func) == "function" then
				str = str .. string.format("* [[%s.%s()]]\n", lib_name, func_name, lib_name, func_name)
				file.Write("wiki/"..lib_name.."/"..func_name..".txt", generate_func_source(lib_name, func_name, get_params(func)))
			end
		end

		str = str .. "\n"
		str = str .. "== See Also ==\n\n"
    end
end
file.Write("libraries.txt", str)