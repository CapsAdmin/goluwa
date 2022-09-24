do
	function utility.NumberToBytes(num, endian, signed)
		if num < 0 and not signed then
			num = -num
			print("warning, dropping sign from number converting to unsigned")
		end

		local res = {}
		local n = math.ceil(select(2, math.frexp(num)) / 8) -- number of bytes to be used.
		if signed and num < 0 then num = num + 2 ^ n end

		for k = n, 1, -1 do -- 256 = 2^8 bits per char.
			local mul = 2 ^ (8 * (k - 1))
			res[k] = math.floor(num / mul)
			num = num - res[k] * mul
		end

		assert(num == 0)

		if endian == "big" then
			local t = {}

			for k = 1, n do
				t[k] = res[n - k + 1]
			end

			res = t
		end

		local bytes = string.char(unpack(res))

		if #bytes ~= 4 then bytes = bytes .. ("\0"):rep(4 - #bytes) end

		return bytes
	end

	function utility.BytesToNumber(str, endian, signed)
		local t = {str:byte(1, -1)}

		if endian == "big" then --reverse bytes
			local tt = {}

			for k = 1, #t do
				tt[#t - k + 1] = t[k]
			end

			t = tt
		end

		local n = 0

		for k = 1, #t do
			n = n + t[k] * 2 ^ ((k - 1) * 8)
		end

		if signed then
			n = (n > 2 ^ (#t * 8 - 1) - 1) and (n - 2 ^ (#t * 8)) or n -- if last bit set, negative.
		end

		return n
	end
end

do
	function utility.TableToFlags(flags, valid_flags, operation)
		if type(flags) == "string" then flags = {flags} end

		local out = 0

		for k, v in pairs(flags) do
			local flag = valid_flags[v] or valid_flags[k]

			if not flag then error("invalid flag", 2) end

			if type(operation) == "function" then
				out = operation(out, tonumber(flag))
			else
				out = bit.band(out, tonumber(flag))
			end
		end

		return out
	end

	function utility.FlagsToTable(flags, valid_flags)
		if not flags then return valid_flags.default_valid_flag end

		local out = {}

		for k, v in pairs(valid_flags) do
			if bit.band(flags, v) > 0 then out[k] = true end
		end

		return out
	end
end

do
	function utility.NumberToBinary(num, bits)
		bits = bits or 32
		local bin = {}

		for i = 1, bits do
			if num > 0 then
				rest = math.fmod(num, 2)
				list.insert(bin, rest)
				num = (num - rest) / 2
			else
				list.insert(bin, 0)
			end
		end

		return list.concat(bin):reverse()
	end

	function utility.BinaryToNumber(bin)
		return tonumber(bin, 2)
	end
end

do
	function utility.NumberToHex(num)
		return ("0x%X"):format(num)
	end

	function utility.HexToNumber(hex)
		return tonumber(hex, 16)
	end
end

do
	function utility.NumberToOctal(num)
		return ("%o"):format(num)
	end

	function utility.OctalToNumber(hex)
		return tonumber(hex, 8)
	end
end

do -- long long
	local ffi = desire("ffi")

	if ffi then
		local btl = ffi.typeof([[union {
			char b[8];
			int64_t i;
		  }]])

		function utility.StringToLongLong(str)
			return btl(str).i
		end
	end
end

function utility.SwapEndian(num, size)
	if size == 4 then return bit.bswap(num) end

	if size == 2 then return bit.rshift(bit.bswap(num), 16) end

	local result = 0

	for shift = 0, (size * 8) - 8, 8 do
		result = bit.bor(bit.lshift(result, 8), bit.band(bit.rshift(num, shift), 0xff))
	end

	return result
end