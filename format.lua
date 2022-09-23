local nl = require("nattlua")
local runtime_syntax = require("nattlua.syntax.runtime")
local helpers = require("nattlua.other.helpers")

local function GetFilesRecursively(dir, ext)
	ext = ext or {".lua"}
	local f = assert(io.popen("find " .. dir))
	local lines = f:read("*all")
	local paths = {}

	for line in lines:gmatch("(.-)\n") do
		for _, ext in ipairs(ext) do
			if line:sub(-#ext) == ext then table.insert(paths, line) end
		end
	end

	return paths
end

local function read_file(path)
	local f = assert(io.open(path, "r"))
	local contents = f:read("*all")
	f:close()
	return contents
end

local function write_file(path, contents)
	local f = assert(io.open(path, "w"))
	f:write(contents)
	f:close()
end

local lua_files = GetFilesRecursively("./", {".lua", ".nlua"})
local config = {
	preserve_whitespace = false,
	string_quote = "\"",
	no_semicolon = true,
	comment_type_annotations = true,
	type_annotations = "explicit",
	force_parenthesis = true,
	skip_import = true,
}
local blacklist = {
	"test_focus_result%.lua",
	"test_focus%.lua",
	"build_output%.lua",
	"nattlua/other/cparser%.lua",
	"nattlua/other/json%.lua",
	"examples/benchmarks/temp/10mb%.lua",
	"examples/projects/luajit/out%.lua",
	"test/nattlua/analyzer/file_importing/deep_error/.*",
	"examples/projects/love2d/love%-api/.*",
}

local function is_blacklisted(path)
	for _, pattern in ipairs(blacklist) do
		if path:find(pattern) then return true end
	end

	return false
end

local dictionary -- = {}
local AUTOFIX = false
local bad_names = { --v = "val",
--k = "key",
}

for _, path in ipairs(lua_files) do
	local lua_code = read_file(path)
	config.comment_type_annotations = path:sub(-#".lua") == ".lua"
	config.comment_type_annotations = config.comment_type_annotations
	local compiler = nl.Compiler(lua_code, "@" .. path, config)

	if not is_blacklisted(path) then
		for _, token in ipairs(assert(compiler:Lex()).Tokens) do
			if token.type == "letter" and not runtime_syntax:IsKeyword(token) then
				if dictionary then
					dictionary[token.value] = (dictionary[token.value] or 0) + 1
				end

				if bad_names[token.value] then
					print(
						compiler:GetCode():BuildSourceCodePointMessage("non descriptive variable name", token.start, token.stop)
					)

					if AUTOFIX and type(bad_names[token.value]) == "string" then
						token.value = bad_names[token.value]
					end
				end
			end
		end

		assert(compiler:Parse())
		local new_lua_code = assert(compiler:Emit())

		if config.comment_type_annotations then
			local ok, err = loadstring(new_lua_code, "@" .. path)

			if not ok then
				print(path)
				print(new_lua_code)
				error(err)
			end
		end

		if new_lua_code:sub(#new_lua_code, #new_lua_code) ~= "\n" then
			new_lua_code = new_lua_code .. "\n"
		end

		write_file(path, new_lua_code)
	end
end

if dictionary then
	local function levenshtein(str1, str2)
		local len1 = string.len(str1)
		local len2 = string.len(str2)
		local matrix = {}
		local cost = 0

		-- quick cut-offs to save time
		if (len1 == 0) then
			return len2
		elseif (len2 == 0) then
			return len1
		elseif (str1 == str2) then
			return 0
		end

		-- initialise the base matrix values
		for i = 0, len1, 1 do
			matrix[i] = {}
			matrix[i][0] = i
		end

		for j = 0, len2, 1 do
			matrix[0][j] = j
		end

		-- actual Levenshtein algorithm
		for i = 1, len1, 1 do
			for j = 1, len2, 1 do
				if (str1:byte(i) == str2:byte(j)) then
					cost = 0
				else
					cost = 1
				end

				matrix[i][j] = math.min(matrix[i - 1][j] + 1, matrix[i][j - 1] + 1, matrix[i - 1][j - 1] + cost)
			end
		end

		-- return the last value - this is the Levenshtein distance
		return matrix[len1][len2]
	end

	local sorted = {}

	for word, count in pairs(dictionary) do
		table.insert(sorted, {word = word, count = count})
	end

	table.sort(sorted, function(a, b)
		return a.count > b.count
	end)

	for _, data in ipairs(sorted) do
		print(data.word, " = ", data.count)
	end

	print("these identifiers are very similar:")

	for _, a in ipairs(sorted) do
		local astr = a.word:lower()

		for _, b in ipairs(sorted) do
			local bstr = b.word:lower()
			local skip = astr == bstr

			if
				not skip and
				(
					astr:sub(1, 3) == "set" or
					astr:sub(1, 3) == "get"
				)
				and
				(
					bstr:sub(1, 3) == "get" or
					bstr:sub(1, 3) == "set"
				)
				and
				astr:sub(4) == bstr:sub(4)
			then
				skip = true
			end

			if not skip then
				local score = levenshtein(astr, bstr) / #a.word

				if score < 0.2 then
					if astr:sub(-1) == "s" and astr:sub(0, -2) == bstr then

					elseif bstr:sub(-1) == "s" and bstr:sub(0, -2) == astr then

					else
						print("\t", a.word .. " ~ " .. b.word)
					end
				end
			end
		end
	end
end