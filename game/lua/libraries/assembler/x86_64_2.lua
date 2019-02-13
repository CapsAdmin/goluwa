--[[
	write encoder and decoder

	bytes = x86_64.encode({
		opcode = "\xC7",
		reg = "rax",
		base = "rax",
		index = "rax",
		imm = require("ffi").new("uint8_t", 1),
		disp = require("ffi").new("uint32_t", 0xDEADBEEF),
	})

	-- bytes can be unlimited length
	info, pos = x86_64.decode(bytes, length)
]]

local x86_64 = {}

local ffi = require("ffi")

local base = {
	"ax", "cx", "dx", "bx",
	"sp", "bp", "si", "di",
}

x86_64.Reg64 = {} for i, v in ipairs(base) do x86_64.Reg64[i] = "r" .. v x86_64.Reg64[i + 7 + 1] = "r" .. (i+7) end
x86_64.Reg32 = {} for i, v in ipairs(base) do x86_64.Reg32[i] = "e" .. v x86_64.Reg32[i + 7 + 1] = "r" .. (i+7) .. "d" end
x86_64.Reg16 = {} for i, v in ipairs(base) do x86_64.Reg16[i] = v x86_64.Reg16[i + 7 + 1] = "r" .. (i+7) .. "w" end

x86_64.Reg8 = {
	"al", "cl", "dl","bl",
	"ah", "ch", "dh", "bh",
	"spl", "bpl", "sil", "dil",
	"r8b", "r9b", "r10b", "r11b",
	"r12b", "r13b", "r14b", "r15b",
}

local REX = {
	FIXED = 0b01000000, -- Fixed base bit pattern
	_64BIT = 0b00001000, -- 64bit mode
	REG = 0b00000100, -- r8-r15
	INDEX = 0b00000010, -- r8-r15
	BASE = 0b00000001, -- r8-r15
}

local VEX_2_BYTES_PREFIX = 0xC5
local VEX_3_BYTES_PREFIX = 0xC4
local XOP_PREFIX = 0x8F

x86_64.KnownBits = {"64", "32", "16", "8"}

x86_64.RegToSize = {}
x86_64.RegLookup = {}

for _, bit in ipairs(x86_64.KnownBits) do
	for i, reg in ipairs(asm["Reg" .. bit]) do
		x86_64.RegToSize[reg] = bit
		x86_64.RegLookup[reg] = i - 1
	end
end

function x86_64.Encode(tbl)

	-- these are some quirks observed by comparing gcc generated machine code to ours
	if true then -- gcc quirks
		if tbl.base then
			local idx = x86_64.RegLookup[tbl.base]

			if idx == 5 or idx == 13 then
				tbl.scale = tbl.scale or 2
				tbl.disp = tbl.disp or ffi.new("uint8_t", 0)
			elseif idx == 4 or idx == 12 then
				if tbl.disp then

				else
					tbl.postfix_qurik = "\x24"
				end
			end
		end
	end

	local rex
	local opcode = tbl.opcode
	local modrm
	local sib

	local num = tbl.imm or tbl.disp or tbl.disp8
	local num_size

	if num then
		if type(num) ~= "cdata" then
			if tbl.disp8 then
				num_size = 1
			else
				num_size = 4
			end
			num = ffi.new("uint32_t", num)
		else
			num_size = ffi.sizeof(num)
		end
	end

	local reg, reg_bits = x86_64.RegLookup[tbl.reg], x86_64.RegToSize[tbl.reg]
	local base, base_bits = x86_64.RegLookup[tbl.base], x86_64.RegToSize[tbl.base]
	local index, index_bits = x86_64.RegLookup[tbl.index], x86_64.RegToSize[tbl.index]

	do -- build REX prefix byte
		if reg_bits == "64" or base_bits == "64" then
			rex = bit.bor(rex or REX.FIXED, REX._64BIT)
		end

		if reg and reg >= 8 then
			reg = reg - 8
			rex = bit.bor(rex or REX.FIXED, REX.REG)
		end

		if base and base >= 8 then
			base = base - 8
			rex = bit.bor(rex or REX.FIXED, REX.BASE)
		end

		if index and index >= 8 then
			index = index - 8
			rex = bit.bor(rex or REX.FIXED, REX.INDEX)
		end
	end

	-- build modrm byte
	if reg and base then

		-- 00 000 000
		modrm = 0

		-- 00 src 000 - place
		modrm = bit.bor(modrm, bit.lshift(reg, 3))


		if num then
			if num_size == 1 then
				-- 10 src 000
				modrm = bit.bor(modrm, 0b01000000)
			elseif num_size == 4 then
				modrm = bit.bor(modrm, 0b10000000)
			else
				error("invalid displacement size " .. num_size)
			end
		elseif not base then
			-- 11 src 000
			modrm = bit.bor(modrm, 0b11000000)
		end

		if index then
			-- 10 src idx
			modrm = bit.bor(modrm, 0b100)
		else
			-- 10 src dst
			modrm = bit.bor(modrm, base)
		end
	elseif base then
		modrm = 0b11000000
		modrm = bit.bor(modrm, base)
	elseif reg then
		modrm = 0b11111000
		modrm = bit.bor(modrm, reg)
	end

	-- build sib byte
	if base and index then
		sib = sib or 0

		sib = bit.bor(sib, base)
		sib = bit.bor(sib, bit.lshift(index, 3))

		if tbl.scale then
			local pattern = 0b00

			if tbl.scale == 1 then
				pattern = 0b00
			elseif tbl.scale == 2 then
				pattern = 0b01
			elseif tbl.scale == 4 then
				pattern = 0b10
			elseif tbl.scale == 8 then
				pattern = 0b11
			else
				error("invalid sib scale: " .. tostring(tbl.sib.scale))
			end

			sib = bit.bor(sib, bit.lshift(pattern, 6))
		end
	end

	-- put it all together
	local bytes = ""

	if index_bits == "32" or base_bits == "32" then
		bytes = bytes .. string.char(0x67)
	end

	if rex then
		bytes = bytes .. string.char(rex)
	end

	if opcode then
		bytes = bytes .. opcode
	end

	if modrm then
		bytes = bytes .. string.char(modrm)
	end

	if sib then
		bytes = bytes .. string.char(sib)
	end

	if num then
		bytes = bytes .. ffi.string(ffi.new(ffi.typeof("$[1]", num), num), num_size)
	end

	if tbl.postfix_qurik then
		bytes = bytes .. tbl.postfix_qurik
	end

	return bytes
end

local function byte2bits(byte, format)
	local bin = utility.NumberToBinary(byte, 8)
	local out = {}
	local pos = 1
	for i = 1, #format do
		local size = tonumber(format:sub(i, i))
		out[i] = tonumber(bin:sub(pos, pos + size - 1), 2)
		pos = pos + size
	end
	return unpack(out)
end

local function bytes2int(a,b,c,d)
	return ffi.cast("uint32_t *", ffi.new("uint8_t[4]", a or 0,b or 0 ,c or 0,d or 0))[0]
end

local shortened = {
	[0x90] = true,
	[0xb0] = "imm8",
	[0xb8] = "imm16",
	[0xC8] = true,
	[0x50] = true,
	[0x58] = true,
}

function x86_64.Decode(bin)
	local pos = 1
	local str = ""

	local rex = {}
	local _32bit = false

	if bin:byte(pos) == 0x67 then
		str = str .. "32bit "
		_32bit = true
		pos = pos + 1
	end

	if bin:byte(pos) >= 64 and bin:byte(pos) <= 79 then
		str = str .. "REX."
		for k,v in pairs(REX) do
			if k ~= "FIXED" and bit.band(bin:byte(pos), v) ~= 0 then
				str = str .. k:sub(1,1)
				rex[k] = true
			end
		end
		str = str .. " "
		pos = pos + 1
	end

	local function toreg(i, ext)
		local lookup = x86_64.Reg32

		if rex._64BIT then
			lookup = x86_64.Reg64
		end

		if ext then
			return lookup[i + 1 + 8] or i
		end

		return lookup[i + 1] or i
	end

	do
		local a,b,c

		a = bin:byte(pos)
		pos = pos + 1

		if a == 0x0F then
			b = bin:byte(pos)
			pos = pos + 1

			if b == 0x38 or b == 0x3A then
				c = bin:byte(pos)
				pos = pos + 1
			end
		end

		if a and b and c then
			str = str .. string.format("\"\\x%x\\x%x\\x%x\"", a,b,c)
		elseif a and b then
			str = str .. string.format("\"\\x%x\\x%x\\x%x\"", a,b)
		elseif a then
			str = str .. string.format("\"\\x%x\"", a)
		end
	end

	if not bin:byte(pos) then
		return str
	end

	local mod, reg, rm = byte2bits(bin:byte(pos), "233")
	pos = pos + 1

	local sib = rm == 4

	local scale, index, base

	-- this means we are either using 8 or 32 bit displacement
	if sib then
		scale, index, base = byte2bits(bin:byte(pos), "233")
		pos = pos + 1
	end

	if mod == 0 and not sib then
		-- mov rax, (rcx) indirect
		str = str .. string.format("%%%s, (%%%s)", toreg(reg, rex.REG), toreg(rm, rex.BASE))
	elseif mod == 3 then
		-- mov rax, rcx direct
		str = str .. string.format("%%%s, %%%s", toreg(reg, rex.REG), toreg(rm, rex.BASE))
	end

	if mod == 0 and rm == 4 then
		pos = pos + 1

		-- scale but no displacement
		str = str .. ("%%%s, (%%%s, %%%s, %i)"):format(
			toreg(reg, rex.REG),
			toreg(base, rex.BASE),
			toreg(index, rex.INDEX),
			2^scale
		)
	elseif mod == 1 or mod == 2 then
		-- indirect with 1 or 4 byte displacement

		local num

		if mod == 1 then
			-- 1 byte displacement
			num = bin:byte(pos) or 0
		else
			-- 4 byte displacement
			num = bytes2int(bin:byte(pos, pos + 4))
		end

		if sib then
			str = str .. ("%%%s, 0x%x(%%%s, %%%s, %i)"):format(
				toreg(reg, rex.REG),
				num,
				toreg(base, rex.BASE),
				toreg(index, rex.INDEX),
				2^scale
			)
		else
			str = str .. ("%%%s, 0x%x(%%%s)"):format(
				toreg(reg, rex.REG),
				num,
				toreg(rm, rex.BASE)
			)
		end
	end

	return str
end

function x86_64.Decode2(bin)
	local pos = 1

	local out = {}

	if bin:byte(pos) == 0x67 then
		pos = pos + 1
		out.prefixes = out.prefixes or {}
		out.prefixes._32bit = true
	end

	if bin:byte(pos) >= 64 and bin:byte(pos) <= 79 then
		pos = pos + 1
		out.rex = {}

		for k,v in pairs(REX) do
			out.rex[k] = true
		end
	end

	do
		local a,b,c

		a = bin:byte(pos)
		pos = pos + 1

		if a == 0x0F then
			b = bin:byte(pos)
			pos = pos + 1

			if b == 0x38 or b == 0x3A then
				c = bin:byte(pos)
				pos = pos + 1
			end
		end

		out.opcode = {a,b,c}
	end

	-- this assumes we're always at the end of the byte stream
	if bin:byte(pos) then
		local mod, reg, rm = byte2bits(bin:byte(pos), "233")
		pos = pos + 1
		out.modrm = {
			mod = mod,
			reg = reg,
			rm = rm,
		}

		-- this means we are either using 8 or 32 bit displacement
		if sib then
			local scale, index, base = byte2bits(bin:byte(pos), "233")
			pos = pos + 1
			out.sib = {
				scale = scale,
				index = index,
				base = base,
			}
		end

		if mod == 1 or mod == 2 then
			local num

			if mod == 1 then
				-- 1 byte displacement
				num = bin:byte(pos) or 0
			else
				-- 4 byte displacement
				num = bytes2int(bin:byte(pos, pos + 4))
			end

			out.displacement = num
		end
	end

	return out
end


local format_func = function(str)
	local ok, res = pcall(decode, str)
	if ok then
		return res-- .. str:binformat(16, " ", true)
	end
	return str:binformat(16, " ", true) .. ": " .. res
end

-- rex opcode

local bytes = x86_64.Encode({opcode="\x89", reg="rax", base="r12", disp=require("ffi").new("uint8_t", 0x2)})
print(bytes:binformat(16, " ", true))
table.print(x86_64.Decode2("\x48\x89\x94\xC3\x00\x10\x00"))
--print(x86_64.Decode(bytes))

do return end

asm.PrintGAS("mov %ecx, (%eax, %r12d,2)", format_func) do return end

asm.PrintC([[
	#include <stdio.h>

	int main() {
		/* Add 10 and 20 and store result into register %eax */
		__asm__ ( "movl $10, %eax;"
					"movl $20, %ebx;"
					"addl %ebx, %eax;"
		);

		/* Subtract 20 from 10 and store result into register %eax */
		__asm__ ( "movl $10, %eax;"
						"movl $20, %ebx;"
						"subl %ebx, %eax;"
		);

		/* Multiply 10 and 20 and store result into register %eax */
		__asm__ ( "movl $10, %eax;"
						"movl $20, %ebx;"
						"imull %ebx, %eax;"
		);

		return 0 ;
	}
]], format_func)
--asm.PrintGAS("mov %ecx, (%rax, %rax, 8)", format_func)
--asm.PrintGAS("mov %eax, (%rax, %rbx, 2)", format_func)

do return end

asm.CompareInterleaved([[
mov %rdi, %r12
obj:WriteInstruction({opcode="\x89", src="rdi", dst="r12"})

mov $1, %rax
obj:WriteInstruction({opcode="\xC7", dst="rax", imm=require("ffi").new("uint8_t", 1)})

mov 0x1, %r12
obj:WriteInstruction({opcode="\x8B", src="r12", disp=1})

inc %r12
obj:WriteInstruction({opcode="\xFF", dst="r12"})
]], format_func)

do return end

asm.CompareInterleaved([[
mov %REG64A, %REG64B
obj:WriteInstruction({opcode="\x89", src="REG64A", dst="REG64B"})

mov %REG64A, (%REG64B)
obj:WriteInstruction({opcode="\x89", src="REG64A", base="REG64B"})

mov %REG64A, 0x1(%REG64B)
obj:WriteInstruction({opcode="\x89", src="REG64A", base="REG64B", disp=require("ffi").new("uint8_t", 0x1)})

mov %rax, 0xFFF(%rcx)
obj:WriteInstruction({opcode ="\x89", src="rax", base="rcx", disp=0xFFF})

mov %rax, 0xFFF(%rcx, %rbx)
obj:WriteInstruction({opcode="\x89", src="rax", base="rcx", index="rbx", disp=0xFFF})

mov %rax, 0xFFF(%rcx, %rbx, 4)
obj:WriteInstruction({opcode="\x89", src="rax", base="rcx", index="rbx", scale=4, disp=0xFFF})

mov %rax, -0xFFF(%rcx, %rbx, 4)
obj:WriteInstruction({opcode="\x89", src="rax", base="rcx", index="rbx", scale=4, disp=-0xFFF})

mov %rax, 0x1(%eax)
obj:WriteInstruction({opcode="\x89", src="rax", base="eax", disp=require("ffi").new("uint8_t", 0x1)})

]], format_func)
do return end
asm.CompareInterleaved([[

mov %REG32A, %REG32B
obj:WriteInstruction({opcode = "\x89", src = "REG32A", dst = "REG32B"})

mov %REG64A, %REG64B
obj:WriteInstruction({opcode = "\x89", src = "REG64A", dst = "REG64B"})

mov %REG64A, (%REG64B)
obj:WriteInstruction({opcode = "\x89", src = "REG64A", idx = "REG64B"})

mov %rax, (%rcx, %rbx)
obj:WriteInstruction({opcode = "\x89", src = "rax", dst = "rcx", idx = "rbx"})

mov %rax, -0x5(%rax)
obj:WriteInstruction({opcode = "\x89", src = "rax", dst = "rax", disp=require("ffi").new("int8_t", -0x5)})

mov %rax, 0x5(%rax)
obj:WriteInstruction({opcode = "\x89", src = "rax", dst = "rax", disp=require("ffi").new("int8_t", 0x5)})

mov %rax, -0x5(%rax, %rax)
obj:WriteInstruction({opcode = "\x89", src = "rax", dst = "rax", idx = "rax", disp=require("ffi").new("int8_t", -0x5)})

mov %rax, -0x5(%rax, %rax, 4)
obj:WriteInstruction({opcode = "\x89", src = "rax", dst = "rax", idx = "rax", scale = 4, disp=require("ffi").new("int8_t", -0x5)})

mov %eax, -0x5(%rax, %rax, 4)
obj:WriteInstruction({opcode = "\x89", src = "eax", dst = "rax", idx = "rax", scale = 4, disp=require("ffi").new("int8_t", -0x5)})

mov (%rax), %rcx
obj:WriteInstruction({opcode = "\x8B", idx = "rax", src = "rcx"})
]], format_func)