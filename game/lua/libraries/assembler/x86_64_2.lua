local asm, META = ...

if not asm then asm = _G.asm end
if not META then META = asm.asm_meta end

local ffi = require("ffi")

asm.Reg64 = {
	"rax", "rcx", "rdx", "rbx",
	"rsp", "rbp", "rsi", "rdi",
	"r8", "r9", "r10", "r11",
	"r12", "r13", "r14","r15",
}
asm.Reg32 = {
	"eax", "ecx", "edx", "ebx",
	"esp", "ebp", "esi", "edi",
	"r8d", "r9d", "r10d", "r11d",
	"r12d", "r13d", "r14d", "r15d",
}
asm.Reg16 = {
	"ax", "cx", "dx", "bx",
	"sp", "bp", "si", "di",
	"r8w", "r9w", "r10w", "r11w",
	"r12w", "r13w", "r14w", "r15w",
}
asm.Reg8 = {
	"al", "cl", "dl","bl",
	"ah", "ch", "dh", "bh",
	"spl", "bpl", "sil", "dil",
	"r8b", "r9b", "r10b", "r11b",
	"r12b", "r13b", "r14b", "r15b",
}

local REX = {
	_ = 0b01000000, -- Fixed base bit pattern

	W = 0b00001000, -- 64bit mode

	R = 0b00000100, -- r8-r15
	X = 0b00000010, -- r8-r15
	B = 0b00000001, -- r8-r15
}

local REG = {
	0b000, -- (r/e)-ax / r08-(d/w/b)
	0b001, -- (r/e)-cx / r09-(d/w/b)
	0b010, -- (r/e)-dx / r10-(d/w/b)
	0b011, -- (r/e)-bx / r11-(d/w/b)
	0b100, -- (r/e)-sp / r12-(d/w/b)
	0b101, -- (r/e)-bp / r13-(d/w/b)
	0b110, -- (r/e)-si / r14-(d/w/b)
	0b111, -- (r/e)-di / r15-(d/w/b)
}

asm.KnownBits = {"64", "32", "16", "8"}

asm.RegToSize = {}
asm.RegLookup = {}
asm.r = asm.RegLookup

for _, bit in ipairs(asm.KnownBits) do
	for i, reg in ipairs(asm["Reg" .. bit]) do
		asm.RegToSize[reg] = bit
		asm.RegLookup[reg] = i - 1
	end
end

function META:WriteInstruction(tbl)

    do -- gcc quirks
        if not tbl.dst then
            local idx = asm.RegLookup[tbl.idx]
            if idx == 5 or idx == 13 then
                tbl.scale = 2
                tbl.disp = ffi.new("uint8_t", 0)
            elseif idx == 4 or idx == 12 then
                tbl.postfix_qurik = "\x24"
            end
        end
    end

	local bytes = {}

	local rex
	local opcode = tbl.opcode
	local modrm
	local sib

	local num = tbl.imm or tbl.disp
	local num_size

	if num then
		if type(num) ~= "cdata" then
			num_size = 4
			num = ffi.new("uint32_t", num)
		end

		num_size = ffi.sizeof(num)
	end

	local src = tbl.src
	local src_bits

	local dst = tbl.dst
	local dst_bits

	local idx = tbl.idx
	local idx_bits

	if src then
		src_bits = asm.RegToSize[src]
		src = asm.RegLookup[src]
	end

	if dst then
		dst_bits = asm.RegToSize[dst]
		dst = asm.RegLookup[dst]
	end

	if idx then
		idx_bits = asm.RegToSize[idx]
		idx = asm.RegLookup[idx]
	end

	if src_bits == "64" then
		rex = bit.bor(rex or REX._, REX.W)
	end

	if src and src >= 8 then
		src = src - 8
		rex = bit.bor(rex or REX._, REX.R)
	end

	if dst and dst >= 8 then
		dst = dst - 8
		rex = bit.bor(rex or REX._, REX.B)
	end

	if idx and idx >= 8 then
		idx = idx - 8
		rex = bit.bor(rex or REX._, REX.X)
	end

	if src and dst then
		modrm = modrm or 0
		modrm = bit.bor(modrm, bit.lshift(REG[src + 1], 3))

		if tbl.disp and (num_size == 4 or num_size == 1) then
            modrm = bit.bor(modrm, 0b01000000)
        elseif tbl.disp and num_size == 8 then
            modrm = bit.bor(modrm, 0b10000000)
        elseif not tbl.scale and not tbl.idx then
			-- src and dst is a normal register
			modrm = bit.bor(modrm, 0b11000000)
		end

		if idx then
			modrm = bit.bor(modrm, 0b100)
		else
			modrm = bit.bor(modrm, REG[dst + 1])
		end
	end

	if idx then
		sib = sib or 0

		if dst then
			sib = bit.bor(sib, REG[dst + 1])
		end

		if not dst then
			sib = bit.bor(sib, REG[idx + 1])
		end

        sib = bit.bor(sib, bit.lshift(REG[idx + 1], 3))

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

	local bytes = ""

	if idx_bits == "32" then
		bytes = bytes .. string.char(0x67)
	end

	if rex then
		bytes = bytes .. string.char(rex)
	end

	bytes = bytes .. tbl.opcode

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

	self:WriteData(bytes)
end

asm.Compareinterleaved([[
    mov %rax, 0x5(%eax, %ebx, 4)
    obj:WriteInstruction({opcode = '\x89', src = 'rax', dst = 'eax', idx = 'ebx', scale=4, disp=require("ffi").new("uint8_t", 0x5)})
]], function(str) return str:binformat(16, " ", false) end)


	--[[




     )

	if false then

	compare(
		"mov %REG64A, (%REG64B)",
		"obj:WriteInstruction({opcode = '\x89', src = 'REG64A', idx = 'REG64B'})"
	)


	compare(
		"mov %REG32A, (%REG32B)",
		"obj:WriteInstruction({opcode = '\x67', src = 'REG32A', idx = 'REG32B'})"
	)
	compare(
		"mov %rcx, %rcx",
		"obj:WriteInstruction({opcode = '\x89', src = 'rcx', dst = 'rcx'})"
	)
	compare(
		"mov 0xFF+(%REG64A), %REG64B",
		"obj:WriteInstruction({opcode = '\x8B', src = 'REG64A', dst = 'REG64B', disp = 0xFF})"
	)
]]