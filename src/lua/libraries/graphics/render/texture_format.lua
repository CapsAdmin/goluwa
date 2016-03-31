local render = ... or _G.render
local ffi = require("ffi")

local texture_formats = {
	depth_component16 = {bits = {16}},
	depth_component24 = {bits = {24}},
	depth_component32f = {bits = {32}, float = true},
	r8 = {normalized = true, bits = {8}},
	r8_snorm = {signed = true, normalized = true, bits = {8}},
	r16 = {normalized = true, bits = {16}},
	r16_snorm = {signed = true, normalized = true, bits = {16}},
	rg8 = {normalized = true, bits = {8, 8}},
	rg8_snorm = {signed = true, normalized = true, bits = {8, 8}},
	rg16 = {normalized = true, bits = {16, 16}},
	rg16_snorm = {signed = true, normalized = true, bits = {16, 16}},
	r3_g3_b2 = {normalized = true, bits = {3, 3, 2}},
	rgb4 = {normalized = true, bits = {4, 4, 4}},
	rgb5 = {normalized = true, bits = {5, 5, 5}},
	rgb8 = {normalized = true, bits = {8, 8, 8}},
	rgb8_snorm = {signed = true, normalized = true, bits = {8, 8, 8}},
	rgb10 = {normalized = true, bits = {10, 10, 10}},
	rgb12 = {normalized = true, bits = {12, 12, 12}},
	rgb16_snorm = {normalized = true, bits = {16, 16, 16}},
	rgba2 = {normalized = true, bits = {2, 2, 2, 2}},
	rgba4 = {normalized = true, bits = {4, 4, 4, 4}},
	rgb5_a1 = {normalized = true, bits = {5, 5, 5, 1}},
	rgba8 = {normalized = true, bits = {8, 8, 8, 8}},
	rgba8_snorm = {signed = true, normalized = true, bits = {8, 8, 8, 8}},
	rgb10_a2 = {normalized = true, bits = {10, 10, 10, 2}},
	rgb10_a2ui = {bits = {10, 10, 10, 2}},
	rgba12 = {normalized = true, bits = {12, 12, 12, 12}},
	rgba16 = {normalized = true, bits = {16, 16, 16, 16}},
	srgb8 = {normalized = true, bits = {8, 8, 8}},
	srgb8_alpha8 = {normalized = true, bits = {8, 8, 8, 8}},
	r16f = {float = true, bits = {16}},
	rg16f = {float = true, bits = {16, 16}},
	rgb16f = {float = true, bits = {16, 16, 16}},
	rgba16f = {float = true, bits = {16, 16, 16, 16}},
	r32f = {float = true, bits = {32}},
	rg32f = {float = true, bits = {32, 32}},
	rgb32f = {float = true, bits = {32, 32, 32}},
	rgba32f = {float = true, bits = {32, 32, 32, 32}},
	r11f_g11f_b10f = {float = true, bits = {11, 11, 10}},
	rgb9_e5 = {normalized = true, bits = {9, 9, 9}},
	r8i = {signed = true, bits = {8}},
	r8ui = {bits = {8}},
	r16i = {signed = true, bits = {16}},
	r16ui = {bits = {16}},
	r32i = {signed = true, bits = {32}},
	r32ui = {bits = {32}},
	rg8i = {signed = true, bits = {8, 8}},
	rg8ui = {bits = {8, 8}},
	rg16i = {signed = true, bits = {16, 16}},
	rg16ui = {bits = {16, 16}},
	rg32i = {signed = true, bits = {32, 32}},
	rg32ui = {bits = {32, 32}},
	rgb8i = {signed = true, bits = {8, 8, 8}},
	rgb8ui = {bits = {8, 8, 8}},
	rgb16i = {signed = true, bits = {16, 16, 16}},
	rgb16ui = {bits = {16, 16, 16}},
	rgb32i = {signed = true, bits = {32, 32, 32}},
	rgb32ui = {bits = {32, 32, 32}},
	rgba8i = {signed = true, bits = {8, 8, 8, 8}},
	rgba8ui = {bits = {8, 8, 8, 8}},
	rgba16i = {signed = true, bits = {16, 16, 16, 16}},
	rgba16ui = {bits = {16, 16, 16, 16}},
	rgba32i = {signed = true, bits = {32, 32, 32, 32}},
	rgba32ui = {bits = {32, 32, 32, 32}},
}

local number_types = {
	unsigned_byte = {type = "uint8_t"},
	byte = {type = "int8_t"},
	unsigned_short = {type = "uint16_t"},
	short = {type = "int16_t"},
	unsigned_int = {type = "uint32_t"},
	int = {type = "int32_t"},
	half_float = {type = "float", float = true},
	float = {type = "double", float = true},

	-- these are combined, so like rgba can be packed into one whole integer
	unsigned_byte_3_3_2 = {type = "uint8_t", combined = true},
	unsigned_byte_2_3_3_rev = {type = "uint8_t", combined = true},
	unsigned_short_5_6_5 = {type = "uint16_t", combined = true},
	unsigned_short_5_6_5_rev = {type = "uint16_t", combined = true},
	unsigned_short_4_4_4_4 = {type = "uint16_t", combined = true},
	unsigned_short_4_4_4_4_rev = {type = "uint16_t", combined = true},
	unsigned_short_5_5_5_1 = {type = "uint16_t", combined = true},
	unsigned_short_1_5_5_5_rev = {type = "uint16_t", combined = true},
	unsigned_int_8_8_8_8 = {type = "uint32_t", combined = true},
	unsigned_int_8_8_8_8_rev = {type = "uint32_t", combined = true},
	unsigned_int_10_10_10_2 = {type = "uint32_t", combined = true},
	unsigned_int_2_10_10_10_rev = {type = "uint32_t", combined = true},
	unsigned_int_24_8 = {type = "uint32_t", combined = true},
	unsigned_int_10f_11f_11f_rev = {type = "uint32_t", combined = true, float = true},
	unsigned_int_5_9_9_9_rev = {type = "uint32_t", combined = true, float = true},
	float_32_unsigned_int_24_8_rev = {type = "", combined = true},
}

for friendly, info in pairs(texture_formats) do
	local line = "struct {"
	local type

	for i, bit in ipairs(info.bits) do
		type = ""

		if not info.float then
			if not info.signed then
				type = type .. "u"
			end

			type = type .. "int"
		end

		if info.float then
			type = "float"
		else
			if bit > 0 and bit <= 8 then
				bit = 8
			elseif bit >= 8 and bit <= 16 then
				bit = 16
			elseif bit >= 16 and bit <= 32 then
				bit = 32
			end

			type = type .. bit .. "_t"
		end

		line = line .. type .. " " .. ({"r", "g", "b", "a"})[i] .. "; "
	end

	local ending = table.concat(info.bits, "_")

	info.combined_number_types = {}

	for friendly2, info2 in pairs(number_types) do
		if not info2.enum then
			info2.friendly = friendly2
		end

		if info2.combined then
			if friendly2:match(".-_.-_(.+)"):gsub("_rev", "") == ending then
				table.insert(info.combined_number_types, info2)
			end
		else
			if info2.type == type then
				info.number_type = info2
			end
		end
	end

	line = line .. "} "
	info.ctype = ffi.typeof(line)
	info.ptr_ctype = ffi.typeof(line .. " *")
end

local function get_upload_format(size, reverse, integer, depth, stencil)
	if depth and stencil then
		return "depth_stencil"
	elseif depth then
		return "depth_component"
	elseif stencil then
		return "stencil_index"
	end

	if size == 1 then
		if integer then
			return "red_integer"
		else
			return "red"
		end
	elseif size == 2 then
		if integer then
			return "rg_integer"
		else
			return "rg"
		end
	elseif size == 3 then
		if reverse then
			if integer then
				return "bgr_integer"
			else
				return "bgr"
			end
		else
			if integer then
				return "rgb_integer"
			else
				return "rgb"
			end
		end
	elseif size == 4 then
		if reverse then
			if integer then
				return "bgra_integer"
			else
				return "bgra"
			end
		else
			if integer then
				return "rgba_integer"
			else
				return "rgba"
			end
		end
	end
end

function render.GetTextureFormatInfo(format)
	local info = table.copy(texture_formats[format:lower()])

	info.preferred_upload_format = get_upload_format(#info.bits, false, false, format:lower():find("depth", nil, true), format:lower():find("stencil", nil, true))
	info.preferred_upload_type = info.number_type.friendly

	return info
end