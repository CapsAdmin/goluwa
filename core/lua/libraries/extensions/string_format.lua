function string.safe_format(str, ...)
	str = str:gsub("%%(%d+)", "%%s")
	local count = select(2, str:gsub("(%%)", ""))

	if str:find("%...", nil, true) then
		local temp = {}

		for i = count, select("#", ...) do
			list.insert(temp, tostringx(select(i, ...)))
		end

		str = str:replace("%...", list.concat(temp, ", "))
		count = count - 1
	end

	if count == 0 then return list.concat({str, ...}, "") end

	local copy = {}

	for i = 1, count do
		list.insert(copy, tostringx(select(i, ...)))
	end

	return string.format(str, unpack(copy))
end

function string.indent(str, count)
	count = count or 1
	local tbl = str:split("\n")

	for i, line in ipairs(tbl) do
		tbl[i] = ("\t"):rep(count) .. line
	end

	return list.concat(tbl, "\n")
end

function string.trim(self, char)
	if char then char = char:patternsafe() .. "*" else char = "%s*" end

	local _, start = self:find(char, 0)
	local end_start, end_stop = self:reverse():find(char, 0)

	if start and end_start then
		return self:sub(start + 1, (end_start - end_stop) - 2)
	elseif start then
		return self:sub(start + 1)
	elseif end_start then
		return self:sub(0, (end_start - end_stop) - 2)
	end

	return self
end

-- gsub doesn't seem to remove \0
function string.remove_padding(str, padding)
	padding = padding or "\0"
	local new = {}

	for i = 1, #str do
		local char = str:sub(i, i)

		if char ~= padding then list.insert(new, char) end
	end

	return list.concat(new)
end

function string.hex(str)
	local copy = {}

	for i = 1, #str do
		copy[i] = ("%x"):format(str:byte(i, i))
	end

	return list.concat(copy)
end

function string.readable_hex(str)
	return (
		str:gsub("(.)", function(str)
			str = ("%X"):format(str:byte())

			if #str == 1 then str = "0" .. str end

			return str .. " "
		end)
	)
end

do
	local map = {
		[0] = {"NUL", "␀", "^@", "\\0", "Null character"},
		[1] = {"SOH", "␁", "^A", "", "Start of Header"},
		[2] = {"STX", "␂", "^B", "", "Start of Text"},
		[3] = {"ETX", "␃", "^C", "", "End of Text"},
		[4] = {"EOT", "␄", "^D", "", "End of Transmission"},
		[5] = {"ENQ", "␅", "^E", "", "Enquiry"},
		[6] = {"ACK", "␆", "^F", "", "Acknowledgment"},
		[7] = {"BEL", "␇", "^G", "\\a", "Bell"},
		[8] = {"BS", "␈", "^H", "\\b", "Backspace"},
		[9] = {"HT", "␉", "^I", "\\t", "Horizontal Tab"},
		[10] = {"LF", "␊", "^J", "\\n", "Line feed"},
		[11] = {"VT", "␋", "^K", "\\v", "Vertical Tab"},
		[12] = {"FF", "␌", "^L", "\\f", "Form feed"},
		[13] = {"CR", "␍", "^M", "\\r", "Carriage return"},
		[14] = {"SO", "␎", "^N", "", "Shift Out"},
		[15] = {"SI", "␏", "^O", "", "Shift In"},
		[16] = {"DLE", "␐", "^P", "", "Data Link Escape"},
		[17] = {"DC1", "␑", "^Q", "", "Device Control 1 (oft. XON)"},
		[18] = {"DC2", "␒", "^R", "", "Device Control 2"},
		[19] = {"DC3", "␓", "^S", "", "Device Control 3 (oft. XOFF)"},
		[20] = {"DC4", "␔", "^T", "", "Device Control 4"},
		[21] = {"NAK", "␕", "^U", "", "Negative Acknowledgment"},
		[22] = {"SYN", "␖", "^V", "", "Synchronous Idle"},
		[23] = {"ETB", "␗", "^W", "", "End of Trans. Block"},
		[24] = {"CAN", "␘", "^X", "", "Cancel"},
		[25] = {"EM", "␙", "^Y", "", "End of Medium"},
		[26] = {"SUB", "␚", "^Z", "", "Substitute"},
		[27] = {"ESC", "␛", "^[", "\\e", "Escape"},
		[28] = {"FS", "␜", "^\\", "", "File Separator"},
		[29] = {"GS", "␝", "^]", "", "Group Separator"},
		[30] = {"RS", "␞", "^^", "", "Record Separator"},
		[31] = {"US", "␟", "^_", "", "Unit Separator"},
		[127] = {"DEL", "␡", "^?", "", "Delete"},
	}
	local number_map = {
		["0"] = "𝟶",
		["1"] = "𝟷",
		["2"] = "𝟸",
		["3"] = "𝟹",
		["4"] = "𝟺",
		["5"] = "𝟻",
		["6"] = "𝟼",
		["7"] = "𝟽",
		["8"] = "𝟾",
		["9"] = "𝟿",
		["A"] = "𝙰",
		["B"] = "𝙱",
		["C"] = "𝙲",
		["D"] = "𝙳",
		["E"] = "𝙴",
		["F"] = "𝙵",
	}

	function string.readablebinary(str)
		local str = (
			str:gsub("(.)", function(str)
				local byte = str:byte()

				if map[byte] then return map[byte][2] end

				if byte > 127 then
					return string.format("｢%X｣", byte):gsub(".", number_map)
				end

				return str
			end)
		)
		str = str:gsub("(␀+)", function(nulls)
			return "NX" .. #nulls
		end)
		return str
	end
end

function string.hex_format(str, chunk_width, row_width, space_separator)
	row_width = row_width or 4
	chunk_width = chunk_width or 4
	space_separator = space_separator or " "
	local str = str:readable_hex():lower():split(" ")
	local out = {}
	local chunk_i = 1
	local row_i = 1

	for _, char in pairs(str) do
		list.insert(out, char)
		list.insert(out, " ")

		if row_i >= (row_width * chunk_width) then
			list.insert(out, "\n")
			chunk_i = 0
			row_i = 0
		end

		if chunk_i >= chunk_width then
			list.insert(out, space_separator)
			chunk_i = 0
		end

		row_i = row_i + 1
		chunk_i = chunk_i + 1
	end

	return list.concat(out):trim()
end

function string.bin_format(str, row_width, space_separator, with_hex, format)
	row_width = row_width or 8
	space_separator = space_separator or " "
	local str = str:to_list()
	local out = {}
	local chunk_i = 1
	local row_i = 1

	for _, char in pairs(str) do
		local bin = utility.NumberToBinary(char:byte(), 8)

		if with_hex then list.insert(out, ("%02X/"):format(char:byte())) end

		if format then
			local str = ""
			local bin = bin:to_list()
			local offset = 1

			for _, num in ipairs(format:to_list()) do
				num = tonumber(num)
				list.insert(bin, num + offset, "-")
				offset = offset + 1
			end

			list.insert(out, list.concat(bin))
		else
			list.insert(out, bin)
		end

		list.insert(out, space_separator)

		if row_i >= row_width then
			list.insert(out, "\n")
			row_i = 0
		end

		row_i = row_i + 1
	end

	return list.concat(out):trim()
end

function string.oct_format(str, row_width, space_separator, with_hex)
	row_width = row_width or 8
	space_separator = space_separator or " "
	local str = str:to_list()
	local out = {}
	local chunk_i = 1
	local row_i = 1

	for _, char in pairs(str) do
		local bin = string.format("%03o", char:byte())

		if with_hex then list.insert(out, ("%02X/"):format(char:byte())) end

		list.insert(out, bin) --:sub(0, 4) .. "-" .. bin:sub(5, 8))
		list.insert(out, space_separator)

		if row_i >= row_width then
			list.insert(out, "\n")
			row_i = 0
		end

		row_i = row_i + 1
	end

	return list.concat(out):trim()
end