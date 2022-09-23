local load = loadstring or load
local noise = {}
local patterns = {"...", "..", "=", "==", "~=", ">>>", "<<", ">", ">>"}

for i = 1, 10000000 do
	noise[i] = math.random() > 0.5 and
		patterns[math.random(1, #patterns)] or
		math.random(32, 127)
end

noise = table.concat(noise)
local i = 1

local function char(offset)
	if offset then return noise:sub(i + offset, i + offset) end

	return noise:sub(i, i)
end

local function byte(offset)
	if offset then return noise:byte(i + offset) end

	return noise:byte(i)
end

local function is_byte(b, offset)
	return byte(offset) == b
end

local function advance(len)
	i = i + len
end

table.sort(patterns, function(a, b)
	return #a > #b
end)

jit.flush()

if true then
	local ipairs = ipairs

	local function find_longest()
		for _, v in ipairs(patterns) do
			if noise:sub(i, i + #v - 1) == v then return v end
		end

		return false
	end

	i = 1
	--local found = {}
	print("================")
	print("longest iterate sub")
	local time = os.clock()

	for _ = 1, #noise do
		local sym = find_longest()

		if sym then
			--found[sym] = (found[sym] or 0) + 1
			advance(#sym)
		else
			advance(1)
		end
	end

	--for k,v in pairs(found) do print(k,v) end
	print(os.clock() - time)
	print("================")
end

jit.flush()

if true then
	local longest = 0
	local map = {}

	for _, str in ipairs(patterns) do
		local node = map

		for i = 1, #str do
			local char = str:sub(i, i)
			node[char] = node[char] or {}
			node = node[char]
		end

		node.DONE = {str = str, length = #str}
		longest = math.max(longest, #str)
	end

	longest = longest - 1

	local function find_longest()
		local node = map

		for i = 0, longest do
			local found = node[char(i)]

			if not found and i == 0 then return end

			if not found then break end

			node = found
		end

		if node.DONE then return node.DONE.str end
	end

	i = 1
	--local found = {}
	print("================")
	print("char (string) map")
	local time = os.clock()

	for _ = 1, #noise do
		local sym = find_longest()

		if sym then
			--found[sym] = (found[sym] or 0) + 1
			advance(#sym)
		else
			advance(1)
		end
	end

	--for k,v in pairs(found) do print(k,v) end
	print(os.clock() - time)
	print("================")
end

jit.flush()

if true then
	local longest = 0
	local map = {}

	for _, str in ipairs(patterns) do
		local node = map

		for i = 1, #str do
			local char = str:byte(i)
			node[char] = node[char] or {}
			node = node[char]
		end

		node.DONE = {str = str, length = #str}
		longest = math.max(longest, #str)
	end

	longest = longest - 1

	local function find_longest()
		local node = map

		for i = 0, longest do
			local found = node[byte(i)]

			if not found and i == 0 then return end

			if not found then break end

			node = found
		end

		if node.DONE then return node.DONE.str end
	end

	i = 1
	-- local found = {}
	print("================")
	print("byte map")
	local time = os.clock()

	for _ = 1, #noise do
		local sym = find_longest()

		if sym then
			--   found[sym] = (found[sym] or 0) + 1
			advance(#sym)
		else
			advance(1)
		end
	end

	--for k,v in pairs(found) do print(k,v) end
	print(os.clock() - time)
	print("================")
end

jit.flush()

if true then
	local longest = 0
	local map = {}
	local kernel = "local is_byte = ...; return function()\n"

	for _, str in ipairs(patterns) do
		local lua = "if "

		for i = 1, #str do
			lua = lua .. "is_byte(" .. str:byte(i) .. "," .. i - 1 .. ") "

			if i ~= #str then lua = lua .. "and " end
		end

		lua = lua .. "then"
		lua = lua .. " return '" .. str .. "' end"
		kernel = kernel .. lua .. "\n"
	end

	kernel = kernel .. "\nend"
	local find_longest = load(kernel)(is_byte)
	i = 1
	--local found = {}
	print("================")
	print("if map")
	local time = os.clock()

	for _ = 1, #noise do
		local sym = find_longest()

		if sym then
			-- found[sym] = (found[sym] or 0) + 1
			advance(#sym)
		else
			advance(1)
		end
	end

	--for k,v in pairs(found) do print(k,v) end
	print(os.clock() - time)
	print("================")
end
