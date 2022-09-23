--[[# --ANALYZE
local type { Token } = import("~/nattlua/lexer/token.lua")]]

local math = _G.math
local table = _G.table
local quote = require("nattlua.other.quote")
local type = _G.type
local pairs = _G.pairs
local assert = _G.assert
local tonumber = _G.tonumber
local tostring = _G.tostring
local next = _G.next
local error = _G.error
local ipairs = _G.ipairs
local jit = _G.jit--[[# as jit | nil]]
local pcall = _G.pcall
local unpack = _G.unpack
local helpers = {}

function helpers.LinePositionToSubPosition(code--[[#: string]], line--[[#: number]], character--[[#: number]])--[[#: number]]
	line = math.max(line, 1)
	character = math.max(character, 1)
	local line_pos = 1

	for i = 1, #code do
		local c = code:sub(i, i)

		if line_pos == line then
			local char_pos = 1

			for i = i, i + character do
				local c = code:sub(i, i)

				if char_pos == character then return i end

				char_pos = char_pos + 1
			end

			return i
		end

		if c == "\n" then line_pos = line_pos + 1 end
	end

	return #code
end

function helpers.SubPositionToLinePosition(code--[[#: string]], start--[[#: number]], stop--[[#: number]])
	local line = 1
	local line_start = 1
	local line_stop = nil
	local within_start = 1
	local within_stop = #code
	local character_start = 1
	local character_stop = 1
	local line_pos = 1
	local char_pos = 1

	for i = 1, #code do
		local char = code:sub(i, i)

		if i == stop then
			line_stop = line
			character_stop = char_pos
		end

		if i == start then
			line_start = line
			within_start = line_pos
			character_start = char_pos
		end

		if char == "\n" then
			if line_stop then
				within_stop = i

				break
			end

			line = line + 1
			line_pos = i
			char_pos = 1
		else
			char_pos = char_pos + 1
		end
	end

	if line_start ~= line_stop then
		character_start = within_start
		character_stop = within_stop
	end

	return {
		character_start = character_start,
		character_stop = character_stop,
		line_start = line_start,
		line_stop = line_stop,
		sub_line_before = {within_start, start - 1},
		sub_line_after = {stop + 1, within_stop},
	}
end

do
	do
		-- TODO: wtf am i doing here?
		local args--[[#: List<|string | List<|string|>|>]]
		local fmt = function(str--[[#: string]])
			local num = tonumber(str)

			if not num then error("invalid format argument " .. str) end

			if type(args[num]) == "table" then return quote.QuoteTokens(args[num]) end

			return quote.QuoteToken(args[num] or "?")
		end

		function helpers.FormatMessage(msg--[[#: string]], ...)
			args = {...}
			msg = msg:gsub("$(%d)", fmt)
			return msg
		end
	end

	local function clamp(num--[[#: number]], min--[[#: number]], max--[[#: number]])
		return math.min(math.max(num, min), max)
	end

	local function find_position_after_lines(str--[[#: string]], line_count--[[#: number]])
		local count = 0

		for i = 1, #str do
			local char = str:sub(i, i)

			if char == "\n" then count = count + 1 end

			if count >= line_count then return i - 1 end
		end

		return #str
	end

	local function split(self--[[#: string]], separator--[[#: string]])
		local tbl = {}
		local current_pos--[[#: number]] = 1

		for i = 1, #self do
			local start_pos, end_pos = self:find(separator, current_pos, true)

			if not start_pos or not end_pos then break end

			tbl[i] = self:sub(current_pos, start_pos - 1)
			current_pos = end_pos + 1
		end

		if current_pos > 1 then
			tbl[#tbl + 1] = self:sub(current_pos)
		else
			tbl[1] = self
		end

		return tbl
	end

	local function pad_left(str--[[#: string]], len--[[#: number]], char--[[#: string]])
		if #str < len + 1 then return char:rep(len - #str + 1) .. str end

		return str
	end

    
    local function string_lengthsplit(str, len)
        if #str > len then
            local tbl = {}

            local max = math.floor(#str/len)

            for i = 0, max do

                local left = i * len + 1
                local right = (i * len) + len
                local res = str:sub(left, right)

                if res ~= "" then
                    table.insert(tbl, res)
                end
            end

            return tbl
        end

        return {str}
    end

    local MAX_WIDTH = 127

	function helpers.BuildSourceCodePointMessage(
		lua_code--[[#: string]],
		path--[[#: nil | string]],
		msg--[[#: string]],
		start--[[#: number]],
		stop--[[#: number]],
		size--[[#: number]]
	)

        do
            local new_str = ""
            local pos = 1
            for i, chunk in ipairs(string_lengthsplit(lua_code, MAX_WIDTH)) do
                if pos < start and i > 1 then
                    start = start + 1
                end

                if pos < stop and i > 1 then
                    stop = stop + 1
                end

                new_str = new_str .. chunk .. "\n"
                pos = pos + #chunk

            end

            lua_code = new_str
        end

		size = size or 2
		start = clamp(start or 1, 1, #lua_code)
		stop = clamp(stop or 1, 1, #lua_code)
		local data = helpers.SubPositionToLinePosition(lua_code, start, stop)
		local code_before = lua_code:sub(1, data.sub_line_before[1] - 1) -- remove the newline
		local code_between = lua_code:sub(data.sub_line_before[1] + 1, data.sub_line_after[2] - 1)
		local code_after = lua_code:sub(data.sub_line_after[2] + 1, #lua_code) -- remove the newline
		code_before = code_before:reverse():sub(1, find_position_after_lines(code_before:reverse(), size)):reverse()
		code_after = code_after:sub(1, find_position_after_lines(code_after, size))
		local lines_before = split(code_before, "\n")
		local lines_between = split(code_between, "\n")
		local lines_after = split(code_after, "\n")
		local total_lines = #lines_before + #lines_between + #lines_after
		local number_length = #tostring(total_lines)
		local lines = {}
		local i = data.line_start - #lines_before

		for _, line in ipairs(lines_before) do
			table.insert(lines, pad_left(tostring(i), number_length, " ") .. " | " .. line)
			i = i + 1
		end

		for i2, line in ipairs(lines_between) do
			local prefix = pad_left(tostring(i), number_length, " ") .. " | "
			table.insert(lines, prefix .. line)

			if #lines_between > 1 then
				if i2 == 1 then
					-- first line or the only line
					local length_before = data.sub_line_before[2] - data.sub_line_before[1]
					local arrow_length = #line - length_before
					table.insert(lines, (" "):rep(#prefix + length_before) .. ("^"):rep(arrow_length))
				elseif i2 == #lines_between then
					-- last line
					local length_before = data.sub_line_after[2] - data.sub_line_after[1]
					local arrow_length = #line - length_before
					table.insert(lines, (" "):rep(#prefix) .. ("^"):rep(arrow_length))
				else
					-- lines between
					table.insert(lines, (" "):rep(#prefix) .. ("^"):rep(#line))
				end
			else
				-- one line
				local length_before = data.sub_line_before[2] - data.sub_line_before[1]
				local length_after = data.sub_line_after[2] - data.sub_line_after[1]
				local arrow_length = #line - length_before - length_after
				table.insert(lines, (" "):rep(#prefix + length_before) .. ("^"):rep(arrow_length))
			end

			i = i + 1
		end

		for _, line in ipairs(lines_after) do
			table.insert(lines, pad_left(tostring(i), number_length, " ") .. " | " .. line)
			i = i + 1
		end

		local longest_line = 0

		for _, line in ipairs(lines) do
			if #line > longest_line then longest_line = #line end
		end

        longest_line = math.min(longest_line, MAX_WIDTH)

		table.insert(
			lines,
			1,
			(" "):rep(number_length + 3) .. ("_"):rep(longest_line - number_length + 1)
		)
		table.insert(
			lines,
			(" "):rep(number_length + 3) .. ("-"):rep(longest_line - number_length + 1)
		)

		if path then
			if path:sub(1, 1) == "@" then path = path:sub(2) end

			local msg = path .. ":" .. data.line_start .. ":" .. data.character_start
			table.insert(lines, pad_left("->", number_length, " ") .. " | " .. msg)
		end

		table.insert(lines, pad_left("->", number_length, " ") .. " | " .. msg)
		local str = table.concat(lines, "\n")
		str = str:gsub("\t", " ")
		return str
	end
end

function helpers.JITOptimize()
	if not jit then return end

	jit.opt.start(
		"maxtrace=65535", -- 1000 1-65535: maximum number of traces in the cache
		"maxrecord=8000", -- 4000: maximum number of recorded IR instructions
		"maxirconst=8000", -- 500: maximum number of IR constants of a trace
		"maxside=5000", -- 100: maximum number of side traces of a root trace
		"maxsnap=500", -- 500: maximum number of snapshots for a trace
		"hotloop=56", -- 56: number of iterations to detect a hot loop or hot call
		"hotexit=50", -- 10: number of taken exits to start a side trace
		"tryside=4", -- 4: number of attempts to compile a side trace
		"instunroll=1000", -- 4: maximum unroll factor for instable loops
		"loopunroll=1000", -- 15: maximum unroll factor for loop ops in side traces
		"callunroll=1000", -- 3: maximum unroll factor for pseudo-recursive calls
		"recunroll=0", -- 2: minimum unroll factor for true recursion
		"maxmcode=" .. (512 * 64), -- 512: maximum total size of all machine code areas in KBytes
		--jit.os == "x64" and "sizemcode=64" or "sizemcode=32", -- Size of each machine code area in KBytes (Windows: 64K)
		"+fold", -- Constant Folding, Simplifications and Reassociation
		"+cse", -- Common-Subexpression Elimination
		"+dce", -- Dead-Code Elimination
		"+narrow", -- Narrowing of numbers to integers
		"+loop", -- Loop Optimizations (code hoisting)
		"+fwd", -- Load Forwarding (L2L) and Store Forwarding (S2L)
		"+dse", -- Dead-Store Elimination
		"+abc", -- Array Bounds Check Elimination
		"+sink", -- Allocation/Store Sinking
		"+fuse" -- Fusion of operands into instructions
	)

	if jit.version_num >= 20100 then
		jit.opt.start("minstitch=0") -- 0: minimum number of IR ins for a stitched trace.
	end
end

return helpers