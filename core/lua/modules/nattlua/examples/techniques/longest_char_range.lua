local ffi = require("ffi")
ffi.cdef("size_t strspn ( const char * str1, const char * str2 );")
local string_span = ffi.C.strspn
local chars = "\\32\t\n\r"
local patterns = {"...", "..", "=", "==", "~=", ">>>", "<<", ">", ">>"}

local function random_whitespace()
	local w = {}

	for i = 1, math.random(1, 10) do
		w[i] = string.char(chars:byte(math.random(1, #chars)))
	end

	return table.concat(w)
end

local function build_noise()
	local noise = {}
	math.randomseed(0)

	for i = 1, 50000000 do
		noise[i] = math.random() > 0.8 and random_whitespace() or string.char(math.random(32, 127))
	end

	noise = table.concat(noise)
	return noise, ffi.cast("uint8_t *", noise), #noise
end

print("building noise...")
local noise, noise_pointer, noise_length = build_noise()
print("noise built, " .. #noise .. " bytes long")
local i = 1
local found
local foundi
local time

local function char(offset)
	if offset then return noise:sub(i + offset, i + offset) end

	return noise:sub(i, i)
end

local function byte(offset)
	if offset then return noise_pointer[i + offset - 1] end

	return noise_pointer[i - 1]
end

local function advance(len)
	i = i + len
end

local function is_space_byte()
	return byte() == 9 or byte() == 10 or byte() == 13 or byte() == 32
end

local function is_space_char()
	return char() == "\n" or char() == "\r" or char() == "\t" or char() == " "
end

local function start(msg)
	i = 1
	found = {}
	foundi = 1
	print("================")
	print(msg)
	time = os.clock()
end

local function add(str)
	found[foundi] = str
	foundi = foundi + 1
end

local function stop()
	print("found " .. foundi .. " spaces")
	print(os.clock() - time)
	print("================")

	for i, chars in ipairs(found) do
		if type(chars) ~= "string" then
			chars = ffi.string(noise_pointer + chars.start, chars.stop - chars.start)
		end

		for char = 1, #chars do
			local str = chars:sub(char, char)

			if not (str == "\n" or str == "\r" or str == "\t" or str == " ") then
				error(
					"chunk " .. i .. " contains invalid character " .. str .. " (" .. str:byte() .. ")",
					2
				)
			end
		end
	end
end

if true then
	local view = ffi.typeof([[
        struct {
            uint32_t start;
            uint32_t stop;
        }
    ]])
	local views = {}

	local function grow()
		for i = #views + 1, #views + 8242526 / 2 do
			views[i] = view()
		end
	end

	grow()
	start("advance(tonumber(strspn())) but with string views")

	while i <= noise_length do
		if is_space_byte() then
			local start = i
			advance(tonumber(string_span(noise_pointer + i - 1, chars)))
			local view = views[foundi]

			if not view then
				grow()
				view = views[foundi]
			end

			view.start = start
			view.stop = i - 1
			add(view)
		else
			advance(1)
		end
	end

	stop()
end

if true then
	local ipairs = ipairs
	start("while not is_space_char() do advance(1) end")

	while i <= noise_length do
		if is_space_char() then
			local start = i
			advance(1)

			while i <= noise_length do
				if not is_space_char() then break end

				advance(1)
			end

			add(noise:sub(start, i - 1))
		else
			advance(1)
		end
	end

	stop()
end

if true then
	local ipairs = ipairs
	start("while not is_space_byte() do advance(1) end")

	while i <= noise_length do
		if is_space_byte() then
			local start = i
			advance(1)

			while i <= noise_length do
				if not is_space_byte() then break end

				advance(1)
			end

			add(noise:sub(start, i - 1))
		else
			advance(1)
		end
	end

	stop()
end

if true then
	start("advance(tonumber(strspn()))")

	while i <= noise_length do
		if is_space_byte() then
			local start = i
			advance(tonumber(string_span(noise_pointer + i - 1, chars)))
			add(noise:sub(start, i - 1))
		else
			advance(1)
		end
	end

	stop()
end

if true then
	start("advance(tonumber(strspn())) but with string views")
	local view = ffi.typeof[[
        struct {
            size_t start;
            size_t stop;
        }
    ]]
	local time = os.clock()
	local views = {}

	for i = 1, 1648501 do
		views[i] = view()
	end

	print("allocating string views took " .. (os.clock() - time) .. " seconds")

	while i <= noise_length do
		if is_space_byte() then
			local start = i
			local ptr_start = noise_pointer + i - 1
			advance(tonumber(string_span(ptr_start, chars)))
			local view = views[foundi]
			view.start = start
			view.stop = i - 1
			add(view)
		else
			advance(1)
		end
	end

	stop()
end

if true then
	start("advance(string.find())")
	local find = string.find
	local pattern = "[" .. chars .. "]+"

	while i <= noise_length do
		if is_space_byte() then
			local start, stop = find(noise, pattern, i)
			advance(stop - start + 1)
			add(noise:sub(start, stop))
		else
			advance(1)
		end
	end

	stop()
end

if true then
	start("advance(string.find())")
	local find = string.find
	local pattern = "[" .. chars .. "]+"

	while i <= noise_length do
		if is_space_byte() then
			local start, stop = find(noise, pattern, i)
			advance(stop - start + 1)
			add(noise:sub(start, stop))
		else
			advance(1)
		end
	end

	stop()
end
