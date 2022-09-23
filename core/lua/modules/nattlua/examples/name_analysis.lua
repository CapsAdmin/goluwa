-- split by casing as well? SetCleint GetClient TransferCleint
local nl = require("nattlua")
local runtime_syntax = require("nattlua.syntax.runtime")
local util = require("examples.util")

local function levenshtein(s, t, lim)
	local s_len, t_len = #s, #t -- Calculate the sizes of the strings or arrays
	if lim and math.abs(s_len - t_len) >= lim then -- If sizes differ by lim, we can stop here
		return lim
	end

	-- Convert string arguments to arrays of ints (ASCII values)
	if type(s) == "string" then s = {string.byte(s, 1, s_len)} end

	if type(t) == "string" then t = {string.byte(t, 1, t_len)} end

	local min = math.min -- Localize for performance
	local num_columns = t_len + 1 -- We use this a lot
	local d = {} -- (s_len+1) * (t_len+1) is going to be the size of this array
	-- This is technically a 2D array, but we're treating it as 1D. Remember that 2D access in the
	-- form my_2d_array[ i, j ] can be converted to my_1d_array[ i * num_columns + j ], where
	-- num_columns is the number of columns you had in the 2D array assuming row-major order and
	-- that row and column indices start at 0 (we're starting at 0).
	for i = 0, s_len do
		d[i * num_columns] = i -- Initialize cost of deletion
	end

	for j = 0, t_len do
		d[j] = j -- Initialize cost of insertion
	end

	for i = 1, s_len do
		local i_pos = i * num_columns
		local best = lim -- Check to make sure something in this row will be below the limit
		for j = 1, t_len do
			local add_cost = (s[i] ~= t[j] and 1 or 0)
			local val = min(
				d[i_pos - num_columns + j] + 1, -- Cost of deletion
				d[i_pos + j - 1] + 1, -- Cost of insertion
				d[i_pos - num_columns + j - 1] + add_cost -- Cost of substitution, it might not cost anything if it's the same
			)
			d[i_pos + j] = val

			-- Is this eligible for tranposition?
			if i > 1 and j > 1 and s[i] == t[j - 1] and s[i - 1] == t[j] then
				d[i_pos + j] = min(val, -- Current cost
				d[i_pos - num_columns - num_columns + j - 2] + add_cost -- Cost of transposition
				)
			end

			if lim and val < best then best = val end
		end

		if lim and best >= lim then return lim end
	end

	return d[#d]
end

local blacklist = {}
blacklist.self = true

for k, v in pairs(_G) do
	blacklist[k] = true

	if type(v) == "table" then
		for k, v in pairs(v) do
			blacklist[k] = true
		end
	end
end

local function check_tokens(tokens)
	local words = {}
	local score = {}

	for i, tk in ipairs(tokens) do
		if tk.type == "letter" and not runtime_syntax:IsKeyword(tk) then
			score[tk.value] = score[tk.value] or {}

			if tk.value:sub(1, 1) == tk.value:sub(1, 1):upper() then
				for word in tk.value:gmatch("(%u%l.-)%u") do
					word = word:lower()
					words[word] = words[word] or {}
					table.insert(words[word], tk)
				end
			elseif tk.value:find("_", nil, true) then
				for word in (tk.value .. "_"):gmatch("([^_]+)_") do
					word = word:lower()
					words[word] = words[word] or {}
					table.insert(words[word], tk)
				end
			else
				words[tk.value] = words[tk.value] or {}
				table.insert(words[tk.value], tk)
			end

			table.insert(score[tk.value], tk)
		end
	end

	local temp = {}

	for k, v in pairs(score) do
		table.insert(temp, {value = k, tokens = v})
	end

	local temp2 = {}

	for k, v in pairs(words) do
		table.insert(temp2, {value = k, tokens = v})
	end

	table.sort(temp, function(a, b)
		return #a.tokens > #b.tokens
	end)

	table.sort(temp2, function(a, b)
		return #a.tokens > #b.tokens
	end)

	print("there are " .. #temp2 .. " different names")
	print("these are all the names:")

	for _, token in ipairs(temp2) do
		if not blacklist[token.value] then io.write(token.value, " ") end
	end

	print("these identifiers are very similar:")

	for _, a in ipairs(temp) do
		local astr = a.value:lower()

		for _, b in ipairs(temp) do
			local bstr = b.value:lower()
			local score = levenshtein(astr, bstr) / #a.value

			if score < 0.2 and astr ~= bstr then
				if astr:sub(-1) == "s" and astr:sub(0, -2) == bstr then

				elseif bstr:sub(-1) == "s" and bstr:sub(0, -2) == astr then

				else
					print("\t", a.value .. " ~ " .. b.value)
				end
			end
		end
	end

	collectgarbage()
end

local paths = util.GetFilesRecursively("./nattlua")
local all_tokens = {}

for _, path in ipairs(paths) do
	local code = assert(assert(nl.File(path)):Parse())
	local tokens = code.Tokens

	for _, token in ipairs(tokens) do
		table.insert(all_tokens, token)
	end
end

local time = os.clock()
check_tokens(all_tokens)
print(os.clock() - time)
