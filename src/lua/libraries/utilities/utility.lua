local utility = _G.utility or {}

runfile("packed_rectangle.lua", utility)
runfile("quickbms.lua", utility)
runfile("find_color.lua", utility)

function utility.VDFToTable(str, lower_or_modify_keys, preprocess)
	if not str or str == "" then return nil, "data is empty" end
	if lower_or_modify_keys == true then lower_or_modify_keys = string.lower end

	str = str:gsub("http://", "___L_O_L___")
	str = str:gsub("https://", "___L_O_L_2___")

	str = str:gsub("//.-\n", "")

	str = str:gsub("___L_O_L___", "http://")
	str = str:gsub("___L_O_L_2___", "https://")

	local function replace(start, stop, def)
		local os = def:match("%$(.+)")

		if os == "WIN32" or os == "WINDOWS" then
			os = "Windows"
		elseif os == "LINUX" then
			os = "Linux"
		elseif os == "OSX" then
			os = "OSX"
		elseif os == "POSIX" then
			os = "Posix,BSD"
		else
			os = "Other" -- xbox360 ?
		end

		if def:startswith("!") then
			if os:find(jit.os, nil, true) then
				return ""
			else
				return start .. stop
			end
		end

		if os:find(jit.os, nil, true) then
			return start .. stop
		else
			return ""
		end
	end

	str = str:gsub("([%d%a.\"_]+%s-)(%b\"\"%s-)%[(%p+%S-)%]", function(start, stop, def)
		return replace(start, stop, def)
	end)

	str = str:gsub("([%d%a.\"_]+%s-)%[(%p+%S-)%](%s-%b{})", function(start, def, stop)
		return replace(start, stop, def)
	end)

	local tbl = {}

	for uchar in str:gmatch("([%z\1-\127\194-\244][\128-\191]*)") do
		tbl[#tbl + 1] = uchar
	end

	local in_string = false
	local capture = {}
	local no_quotes = false

	local out = {}
	local current = out
	local stack = {current}

	local key

	for i = 1, #tbl do
		local char = tbl[i]

		if (char == [["]] or (no_quotes and char:find("%s"))) and tbl[i-1] ~= "\\" then
			if in_string then

				if key then
					if lower_or_modify_keys then
						key = lower_or_modify_keys(key)
					end

					local val = table.concat(capture, "")

					if preprocess and val:find("|") then
						for k, v in pairs(preprocess) do
							val = val:gsub("|" .. k .. "|", v)
						end
					end

					if val:lower() == "false" then
						val = false
					elseif val:lower() ==  "true" then
						val =  true
					elseif val:find("%b{}") then
						local values = val:match("{(.+)}"):trim():split(" ")
						if #values == 3 or #values == 4 then
							val = ColorBytes(tonumber(values[1]), tonumber(values[2]), tonumber(values[3]), values[4] or 255)
						end
					elseif val:find("%b[]") then
						local values = val:match("%[(.+)%]"):trim():split(" ")
						if #values == 3 and tonumber(values[1]) and tonumber(values[2]) and tonumber(values[3]) then
							val = Vec3(tonumber(values[1]), tonumber(values[2]), tonumber(values[3]))
						end
					else
						val = tonumber(val) or val
					end

					if type(current[key]) == "table" then
						table.insert(current[key], val)
					elseif current[key] and current[key] ~= val then
						current[key] = {current[key], val}
					else
						if key:find("+", nil, true) then
							for _, key in ipairs(key:split("+")) do
								if type(current[key]) == "table" then
									table.insert(current[key], val)
								elseif current[key] and current[key] ~= val then
									current[key] = {current[key], val}
								else
									current[key] = val
								end

							end
						else
							current[key] = val
						end
					end

					key = nil
				else
					key = table.concat(capture, "")
				end

				in_string = false
				no_quotes = false
				table.clear(capture)
			else
				in_string = true
			end
		else
			if in_string then
				table.insert(capture, char)
			elseif char == [[{]] then
				if key then
					if lower_or_modify_keys then
						key = lower_or_modify_keys(key)
					end

					table.insert(stack, current)
					current[key] = {}
					current = current[key]
					key = nil
				else
					return nil, "stack imbalance at char " .. i
				end
			elseif char == [[}]] then
				current = table.remove(stack) or out
			elseif not char:find("%s") then
				in_string = true
				no_quotes = true
				table.insert(capture, char)
			end
		end
	end

	return out
end

function utility.GenerateCheckLastFunction(func, arg_count)
	local lua = ""

	lua = lua .. "local func = ...\n"
	for i = 1, arg_count do
		lua = lua .. "local last_" .. i .. "\n"
	end
	lua = lua .. "return function("
	for i = 1, arg_count do
		lua = lua .. "_" .. i
		if i ~= arg_count then
			lua = lua .. ", "
		end
	end
	lua = lua .. ")\n"

	lua = lua .. "\tif\n"

	for i = 1, arg_count do
		lua = lua .. "\t\t_" .. i .. " ~= last_" .. i
		if i ~= arg_count then
			lua = lua .. " or\n"
		else
			lua = lua .. "\n"
		end
	end

	lua = lua .. "\tthen\n"
	lua = lua .. "\t\tfunc("
	for i = 1, arg_count do
		lua = lua .. "_" .. i
		if i ~= arg_count then
			lua = lua .. ", "
		end
	end
	lua = lua .. ")\n"

	for i = 1, arg_count do
		lua = lua .. "\t\tlast_" .. i .. " = _" .. i .. "\n"
	end

	lua = lua .. "\tend\n"
	lua = lua .. "end"

	return assert(loadstring(lua))(func)
end

do
	local stack = {}

	function utility.PushTimeWarning()
		table.insert(stack, os.clock())
	end

	function utility.PopTimeWarning(what, threshold)
		threshold = threshold or 0.1
		local start_time = table.remove(stack)
		if not start_time then return end
		local delta = os.clock() - start_time

		if delta > threshold then
			logf("%s took %f seconds to load\n", what, delta)
		end
	end
end

do
	local function mapToHemisphere(point, maxVertAngle)
		maxVertAngle = maxVertAngle or math.pi / 2

		local point = point:Copy()
		point = point * 2 - 1

		if point:IsZero() then
			return Vec3(0,0,1)
		end

		local sinTheta
		if point.y > -point.x then
			if point.y < point.x then
				sinTheta = point.x
			else
				sinTheta = point.y
			end
		else
			if point.y > point.x then
				sinTheta = -point.x
			else
				sinTheta = -point.y
			end
		end

		local theta = math.asin(sinTheta)
		theta = theta * maxVertAngle / (math.pi / 2)
		point:Normalize()
		local phi = math.atan2(point.y, point.x)

		return Vec3(
			math.cos(phi) * math.cos(theta),
			math.sin(phi) * math.sin(theta),
			math.cos(theta)
		)
	end

	function utility.CreateHemisphereNormalsTexture(size, hemiAngle)
		-- allocate memory for texture
		local components = 3
		local data = Array("uint8_t", components*size*size)

		-- half texel offset
		local base = 0.5 / size
		-- calculate direction for each texel in texture
		for x = 0, size-1 do
			local xx = x / size
			for y = 0, size-1 do
				local yy = y / size

				local res = mapToHemisphere(Vec2(xx + base, yy + base), hemiAngle)
				local offset = x * components + y * size * components
				data[offset + 0] = (res.x + 1) / 2 * 255
				data[offset + 1] = (res.y + 1) / 2 * 255
				data[offset + 2] = (res.z + 1) / 2 * 255
			end
		end

		local tex = render.CreateTexture("2d")
		tex:SetSize(Vec2() + size)
		tex:SetInternalFormat("rgb8")
		tex:SetupStorage()
		tex:Upload({
			format = "rgb",
			buffer = data:GetPointer(),
		})

		return tex
	end
end

function utility.CreateDeferredLibrary(name)
	return setmetatable(
		{
			queue = {},
			Start = function(self)
				_G[name] = self
			end,
			Stop = function()
				_G[name] = nil
			end,
			Call = function(self, lib)
				for _, v in ipairs(self.queue) do
					if not lib[v.key] then error(v.key .. " was not found", 2) end
					print(self, lib)
					lib[v.key](unpack(v.args))
				end
				return lib
			end,
		},
		{
			__index = function(self, key)
				return function(...)
					table.insert(self.queue, {key = key, args = {...}})
				end
			end,
		}
	)
end

function utility.LuaAutoComplete(text)
	local found = {}
	local node = _G

	print(text)

	if text:find("(", nil, true) then
		local ok, func = loadstring("return " .. text:match("(.+)%("))
		if ok then
			local ok, func = pcall(func)
			if ok then
				print(func)
			end
		end

	else
		local keys = text:split(".")
		local found_string = ""

		local current_func

		for _, index in ipairs(keys) do
			if node[index] and type(node[index]) == "table" then
				node = node[index]

				--found_string  = found_string  .. index

				--if type(node) == "table" then
				--	found_string = found_string .. "."
				--end

			else
				for key, val in pairs(node) do
					local str = tostring(key)
					if current_func then
						local params = debug.getparams(current_func)
						--event.AddListener( todo
					elseif str:find("^.-" .. index) then

						if type(val) == "table" then
							str = str .. "."
						elseif type(val) == "function" then
							str = str .. "("
						elseif type(val) == "number" then
							str = str .. "["
						end

						table.insert(found, found_string .. str)
					end
				end
			end
		end
	end

	return found
end

do
	function utility.StripLuaCommentsAndStrings(code, post_process)
		code = code:gsub("\\\\", "____ESCAPE_ESCAPE")
		code = code:gsub("\\'", "____SINGLE_QUOTE_ESCAPE")
		code = code:gsub('\\"', "____DOUBLE_QUOTE_ESCAPE")

		local singleline_comments = {}
		local multiline_comments = {}
		local double_quote_strings = {}
		local single_quote_strings = {}
		local multiline_strings = {}

		code = code:gsub("(%-%-%[(=*)%[.-%]%2%])", function(str) table.insert(multiline_comments, str) return "____COMMENT_MULTILINE_" .. #multiline_comments .. "____" .. " "  end)
		code = code:gsub("(%[(=*)%[.-%]%2%])", function(str) table.insert(multiline_strings, str) return "____STRING_MULTILINE_" .. #multiline_strings .. "____" .. " "  end)
		code = code:gsub("%b\"\"", function(str) table.insert(double_quote_strings, str) return "____STRING_DOUBLE_QUOTE_" .. #double_quote_strings .. "____" .. " "  end)
		code = code:gsub("(%-%-.-)\n", function(str) table.insert(singleline_comments, str) return "____COMMENT_SINGLELINE_" .. #singleline_comments .. "____" .. " " end)
		code = code:gsub("%b''", function(str) table.insert(single_quote_strings, str) return "____STRING_SINGLE_QUOTE_" .. #single_quote_strings .. "____" .. " "  end)

		local res = {
			singleline_comments = singleline_comments,
			multiline_comments = multiline_comments,
			double_quote_strings = double_quote_strings,
			single_quote_strings = single_quote_strings,
			multiline_strings = multiline_strings,
		}

		if post_process then
			code = post_process(code, res) or code
		end

		return code, res
	end

	function utility.RestoreLuaCommentsAndStrings(code, data)
		for i, v in ipairs(data.multiline_comments) do code = code:replace("____COMMENT_MULTILINE_" .. i .. "____", v) end
		for i, v in ipairs(data.multiline_strings) do code = code:replace("____STRING_MULTILINE_" .. i .. "____", v) end
		for i, v in ipairs(data.double_quote_strings) do code = code:replace("____STRING_DOUBLE_QUOTE_" .. i .. "____", v) end
		for i, v in ipairs(data.singleline_comments) do code = code:replace("____COMMENT_SINGLELINE_" .. i .. "____", v .. "\n") end
		for i, v in ipairs(data.single_quote_strings) do code = code:replace("____STRING_SINGLE_QUOTE_" .. i .. "____", v) end

		code = code:gsub("____ESCAPE_ESCAPE", "\\\\")
		code = code:gsub("____SINGLE_QUOTE_ESCAPE", "\\'")
		code = code:gsub("____DOUBLE_QUOTE_ESCAPE", '\\"')

		return code
	end
end

function utility.CreateCallbackThing(cache)
	cache = cache or {}
	local self = {}

	function self:check(path, callback, extra)
		if cache[path] then
			if cache[path].extra_callbacks then
				for key, old in pairs(cache[path].extra_callbacks) do
					local callback = extra[key]
					if callback then
						cache[path].extra_callbacks[key] = function(...)
							old(...)
							callback(...)
						end
					end

				end
			end

			if cache[path].callback then
				local old = cache[path].callback

				cache[path].callback = function(...)
					old(...)
					callback(...)
				end
				return true
			end
		end
	end

	function self:start(path, callback, extra)
		cache[path] = {callback = callback, extra_callbacks = extra}
	end

	function self:callextra(path, key, out)
		if not cache[path] or not cache[path].extra_callbacks[key] then return end
		return cache[path].extra_callbacks[key](out)
	end

	function self:stop(path, out, ...)
		if not cache[path] then return end
		cache[path].callback(out, ...)
		cache[path] = out
	end

	function self:get(path)
		return cache[path]
	end

	function self:uncache(path)
		cache[path] = nil
	end

	return self
end

do
	local ffi = require("ffi")
	local ok, lib = pcall(ffi.load, "lz4")

	if ok then
		ffi.cdef[[
			int LZ4_compress        (const char* source, char* dest, int inputSize);
			int LZ4_decompress_safe (const char* source, char* dest, int inputSize, int maxOutputSize);
		]]

		function utility.Compress(data)
			local size = #data
			local buf = ffi.new("uint8_t[?]", ((size) + ((size)/255) + 16))
			local res = lib.LZ4_compress(data, buf, size)

			if res ~= 0 then
				return ffi.string(buf, res)
			end
		end

		function utility.Decompress(source, orig_size)
			local dest = ffi.new("uint8_t[?]", orig_size)
			local res = lib.LZ4_decompress_safe(source, dest, #source, orig_size)

			if res > 0 then
				return ffi.string(dest, res)
			end
		end
	else
		(logn or print)(lib) -- aaaaa

		utility.Compress = function() error("lz4 is not avaible: " .. lib, 2) end
		utility.Decompress = utility.Compress
	end
end

function utility.MakePushPopFunction(lib, name, func_set, func_get, reset)
	func_set = func_set or lib["Set" .. name]
	func_get = func_get or lib["Get" .. name]

	local stack = {}
	local i = 1

	lib["Push" .. name] = function(...)
		stack[i] = stack[i] or {}
		stack[i][1], stack[i][2], stack[i][3], stack[i][4] = func_get()

		func_set(...)

		i = i + 1
	end

	lib["Pop" .. name] = function()
		i = i - 1

		if i < 1 then
			error("stack underflow", 2)
		end

		if i == 1 and reset then
			reset()
		end

		func_set(stack[i][1], stack[i][2], stack[i][3], stack[i][4])
	end
end

function utility.FindReferences(reference)
	local done = {}
	local found = {}
	local found2 = {}

	local revg = {}
	for k,v in pairs(_G) do revg[v] = tostring(k) end

	local function search(var, str)
		if done[var] then return end

		if revg[var] then str = revg[var] end

		if rawequal(var, reference) then
			local res = str .. " = " .. tostring(reference)
			if not found2[res] then
				table.insert(found, res)
				found2[res] = true
			end
		end

		local t = type(var)

		if t == "table" then
			done[var] = true

			for k, v in pairs(var) do
				search(k, str .. "." .. tostring(k))
				search(v, str .. "." .. tostring(k))
			end
		elseif t == "function" then
			done[var] = true

			for _, v in pairs(debug.getupvalues(var)) do
				if v.val then
					search(v.val, str .. "^" .. v.key)
				end
			end
		end
	end

	search(_G, "_G")

	return table.concat(found, "\n")
end

local diffuse_suffixes = {
	"_diff",
	"_d",
}

function utility.FindTextureFromSuffix(path, ...)
	path = path:lower()

	local suffixes = {...}

	-- try to find the normal texture
	for _, suffix in pairs(suffixes) do
		local new = path:gsub("(.+)(%.)", "%1" .. suffix .. "%2")

		if new ~= path and vfs.Exists(new) then
			return new
		end
	end

	-- try again without the __diff suffix
	for _, diffuse_suffix in pairs(diffuse_suffixes) do
		for _, suffix in pairs(suffixes) do
			local new = path:gsub(diffuse_suffix .. "%.", suffix ..".")

			if new ~= path and vfs.Exists(new) then
				return new
			end
		end
	end
end

function utility.CreateWeakTable()
	return setmetatable({}, {__mode = "kv"})
end

function utility.TableToColumns(title, tbl, columns, check, sort_key)

	if false and gui then
		local frame = gui.CreatePanel("frame", nil, "table_to_columns_" .. title)
		frame:SetSize(Vec2() + 300)
		frame:SetTitle(title)

		local list = frame:CreatePanel("list")
		list:SetupLayout("fill")

		local keys = {}
		for i,v in ipairs(columns) do keys[i] = v.friendly or v.key end
		list:SetupSorted(unpack(keys))

		for _, data in ipairs(tbl) do
			local args = {}
			for i, info in ipairs(columns) do
				if info.tostring then
					args[i] = info.tostring(data[info.key], data, tbl)
				else
					args[i] = data[info.key]
				end
				if type(args[i]) == "string" then
					args[i] = args[i]:trim()
				end
			end
			list:AddEntry(unpack(args))
		end

		return
	end

	local top = {}

	for k, v in pairs(tbl) do
		if not check or check(v) then
			table.insert(top, {key = k, val = v})
		end
	end

	if type(sort_key) == "function" then
		table.sort(top, function(a, b)
			return sort_key(a.val, b.val)
		end)
	else
		table.sort(top, function(a, b)
			return a.val[sort_key] > b.val[sort_key]
		end)
	end

	local max_lengths = {}
	local temp = {}

	for _, column in ipairs(top) do
		for key, data in ipairs(columns) do
			data.tostring = data.tostring or function(...) return ... end
			data.friendly = data.friendly or data.key

			max_lengths[data.key] = max_lengths[data.key] or 0

			local str = tostring(data.tostring(column.val[data.key], column.val, top))
			column.str = column.str or {}
			column.str[data.key] = str

			if #str > max_lengths[data.key] then
				max_lengths[data.key] = #str
			end

			temp[key] = data
		end
	end

	columns = temp

	local width = 0

	for _,v in pairs(columns) do
		if max_lengths[v.key] > #v.friendly then
			v.length = max_lengths[v.key]
		else
			v.length = #v.friendly + 1
		end
		width = width + #v.friendly + max_lengths[v.key] - 2
	end

	local out = " "

	out = out .. ("_"):rep(width - 1) .. "\n"
	out = out .. "|" .. (" "):rep(width / 2 - math.floor(#title / 2)) .. title .. (" "):rep(math.floor(width / 2) - #title + math.floor(#title / 2)) .. "|\n"
	out = out .. "|" .. ("_"):rep(width - 1) .. "|\n"

	for _,v in ipairs(columns) do
		out = out .. "| " .. v.friendly .. ": " .. (" "):rep(-#v.friendly + max_lengths[v.key] - 1)  -- 2 = : + |
	end
	out = out .. "|\n"


	for _,v in ipairs(columns) do
		out = out .. "|" .. ("_"):rep(v.length + 2)
	end
	out = out .. "|\n"

	for _,v in ipairs(top) do
		for _,column in ipairs(columns) do
			out = out .. "| " .. v.str[column.key] .. (" "):rep(-#v.str[column.key] + column.length + 1)
		end
		out = out .. "|\n"
	end

	out = out .. "|"

	out = out .. ("_"):rep(width-1) .. "|\n"


	return out
end

do -- tree
	local META = prototype.CreateTemplate("tree")

	function META:SetEntry(str, value)
		local keys = str:split(self.delimiter)
		local next = self.tree

		for _, key in ipairs(keys) do
			if key ~= "" then
				if type(next[key]) ~= "table" then
					next[key] = {}
				end
				next = next[key]
			end
		end

		next.key = str
		next.value = value
	end

	function META:GetEntry(str)
		local keys = str:split(self.delimiter)
		local next = self.tree

		for _, key in ipairs(keys) do
			if key ~= "" then
				if not next[key] then
					return false, "key ".. key .." not found"
				end
				next = next[key]
			end
		end

		return next.value
	end

	function META:GetChildren(str)
		local keys = str:split(self.delimiter)
		local next = self.tree

		for _, key in ipairs(keys) do
			if key ~= "" then
				if not next[key] then
					return false, "not found"
				end
				next = next[key]
			end
		end

		return next
	end

	META:Register()

	function utility.CreateTree(delimiter, tree)
		local self = META:CreateObject()

		self.tree = tree or {}
		self.delimiter = delimiter

		return self
	end
end

function utility.TableToFlags(flags, valid_flags)
	if type(flags) == "string" then
		flags = {flags}
	end

	local out = 0

	for k, v in pairs(flags) do
		local flag = valid_flags[v] or valid_flags[k]
		if not flag then
			error("invalid flag", 2)
		end
		out = bit.band(out, tonumber(flag))
	end

	return out
end

function utility.FlagsToTable(flags, valid_flags)

	if not flags then return valid_flags.default_valid_flag end

	local out = {}

	for k, v in pairs(valid_flags) do
		if bit.band(flags, v) > 0 then
			out[k] = true
		end
	end

	return out
end

do -- long long
	local ffi = require("ffi")

	local btl = ffi.typeof([[union {
		char b[8];
		int64_t i;
	  }]])

	function utility.StringToLongLong(str)
		return btl(str).i
	end
end

do -- find value
	local found =  {}
	local done = {}

	local skip =
	{
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

	local function _find(tbl, name, dot, level, ...)
		if level >= 3 then return end

		for key, val in pairs(tbl) do
			local T = type(val)
			key = tostring(key)

			if name == "_M" then
				if val.Type == val.ClassName then
					key = val.Type
				else
					key = val.Type .. "." .. val.ClassName
				end
			end

			if not skip[key] and T == "table" and not done[val] then
				done[val] = true
				_find(val, name .. "." .. key, dot, level + 1, ...)
			else
				if (T == "function" or T == "number") and strfind(name .. "." .. key, ...) then

					local nice_name

					if type(val) == "function" then
						local params = debug.getparams(val)

						if dot == ":" and params[1] == "self" then
							table.remove(params, 1)
						end

						nice_name = ("%s%s%s(%s)"):format(name, dot, key, table.concat(params, ", "))
					else
						nice_name = ("%s.%s = %s"):format(name, key, val)
					end

					if name == "_G" or name == "_M" then
						table.insert(found, {key = key, val = val, name = name, nice_name = nice_name})
					else
						table.insert(found, {key = ("%s%s%s"):format(name, dot, key), val = val, name = name, nice_name = nice_name})
					end
				end
			end
		end
	end

	local function find(tbl, ...)
		found = {}
		_find(...)
		table.sort(found, function(a, b) return #a.key < #b.key end)
		for _,v in ipairs(found) do table.insert(tbl, v) end
	end

	function utility.FindValue(...)
		local found = {}
		done =
		{
			[_G] = true,
			[package] = true,
			[_OLD_G] = true,
		}

		find(found, _G, "_G", ".", 1, ...)
		find(found, prototype.GetAllRegistered(), "_M", ":", 1, ...)

		local temp = {}
		for cmd, v in pairs(commands.GetCommands()) do
			if strfind(cmd, ...) then
				local arg_line = table.concat(debug.getparams(v.callback), ", ")
				arg_line = arg_line:gsub("line, ", "")
				arg_line = arg_line:gsub("line", "")

				table.insert(temp, {key = cmd, val = v.callback, name = ("commands.GetCommands().%s.callback"):format(cmd), nice_name = ("_C->%s(%s)"):format(cmd, arg_line)})
			end
		end
		table.sort(temp, function(a, b) return #a.key < #b.key end)
		for _, v in ipairs(temp) do table.insert(found, v) end

		return found
	end
end

do -- find in files
	function utility.FindInLoadedLuaFiles(find)
		local out = {}
		for path in pairs(vfs.GetLoadedLuaFiles()) do
			if not path:find("modules") or (path:find("ffi", nil, true) and (not path:find("header.lua") and not path:find("enums"))) then
				local str = vfs.Read(path)
				if str then
					for i, line in ipairs(str:split("\n")) do
						local start, stop = line:find(find)
						if start then
							out[path] = out[path] or {}
							table.insert(out[path], {str = line, line = i, start = start, stop = stop})
						end
					end
				end
			end
		end
		return out
	end
end

do
	-- http://cakesaddons.googlecode.com/svn/trunk/glib/lua/glib/stage1.lua
	local size_units =
	{
		"B",
		"KiB",
		"MiB",
		"GiB",
		"TiB",
		"PiB",
		"EiB",
		"ZiB",
		"YiB"
	}
	function utility.FormatFileSize(size)
		local unit_index = 1

		while size >= 1024 and size_units[unit_index + 1] do
			size = size / 1024
			unit_index = unit_index + 1
		end

		return tostring(math.floor(size * 100 + 0.5) / 100) .. " " .. size_units[unit_index]
	end
end

function utility.SafeRemove(obj, gc)
	if hasindex(obj) then

		if obj.IsValid and not obj:IsValid() then return end

		if type(obj.Remove) == "function" then
			obj:Remove()
		elseif type(obj.Close) == "function" then
			obj:Close()
		end

		if gc and type(obj.__gc) == "function" then
			obj:__gc()
		end
	end
end

utility.remakes = utility.CreateWeakTable()

function utility.RemoveOldObject(obj, id)

	if hasindex(obj) and type(obj.Remove) == "function" then
		id = id or (debug.getinfo(2).currentline .. debug.getinfo(2).source)

		if typex(utility.remakes[id]) == typex(obj) then
			utility.remakes[id]:Remove()
		end

		utility.remakes[id] = obj
	end

	return obj
end

do
	local hooks = {}

	function utility.SetFunctionHook(tag, tbl, func_name, type, callback)
		local old = hooks[tag] or tbl[func_name]

		if type == "pre" then
			tbl[func_name] = function(...)
				local args = {callback(old, ...)}

				if args[1] == "abort_call" then return end
				if #args == 0 then return old(...) end

				return unpack(args)
			end
		elseif type == "post" then
			tbl[func_name] = function(...)
				local args = {old(...)}
				if callback(old, unpack(args)) == false then return end
				return unpack(args)
			end
		end

		return old
	end

	function utility.RemoveFunctionHook(tag, tbl, func_name)
		local old = hooks[tag]

		if old then
			tbl[func_name] = old
			hooks[tag] = nil
		end
	end
end

return utility