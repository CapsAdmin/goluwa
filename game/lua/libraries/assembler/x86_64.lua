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

function META:MoveConst32Reg64(src, dst)
    if dst < 8 then
        self:WriteData("\x48\xC7" .. string.char(0xc0 + dst))
    else
        self:WriteData("\x49\xC7" .. string.char(0xc0 + (dst - 8)))
    end

    self:WriteData(ffi.new("uint32_t[1]", src))
end

function META:MoveConst64Reg64(src, dst)
    if dst < 8 then
        self:WriteData("\x48" .. string.char(0xB8 + dst))
    else
        self:WriteData("\x49" .. string.char(0xB8 + (dst - 8)))
    end

    self:WriteData(ffi.new("uint64_t[1]", src))
end

function META:PushReg64(src)
    if src < 8 then
        self:WriteData(string.char(0x50 + src))
    else
        self:WriteData(string.char(0x41, 0x50 + src - 8))
    end
end

function META:PopReg64(src)
    if src < 8 then
        self:WriteData(string.char(0x58 + src))
    else
        self:WriteData(string.char(0x41, 0x58 + src - 8))
    end
end

local function increase_decrease(what, base)
    META[what .. "Reg64"] = function(self, src)
        self:WriteData(
            0x48 + (src >= 8 and 1 or 0),
            0xFF,
            base + bit.band(src, 7)
        )
    end

    META[what .. "Reg32"] = function(self, src)
        if src >= 8 then
            self:WriteData("\x41")
        end

        self:WriteData(0xFF, base + bit.band(src, 7))
    end

    META[what .. "Reg16"] = function(self, src)
        self:WriteData("\x66")

        if src >= 8 then
            self:WriteData("\x41")
        end

        self:WriteData(0xFF, base + bit.band(src, 7))
    end

    META[what .. "Reg8"] = function(self, src)
        if src < 8 then
            self:WriteData("\xFE")
            self:WriteData(base + src)
        elseif src < 12 then
            self:WriteData("\x40\xFE")
            self:WriteData(base + src - 4)
        else
            self:WriteData("\x41\xFE")
            self:WriteData(base + src - 12)
        end
    end
end

increase_decrease("Increase", 0xc0)
increase_decrease("Decrease", 0xc8)

local function generic_reg64_reg64(name, byte, swap)
    META[name] = function(self, dst, src)
        if swap then
            dst, src = src, dst
        end

        if dst < 8 then
            if src < 8 then
                self:WriteData("\x48" .. byte)
            else
                self:WriteData("\x49" .. byte)
            end
        else
            if src < 8 then
                self:WriteData("\x4c" .. byte)
            else
                self:WriteData("\x4d" .. byte)
            end
        end

        self:WriteData(bit.bor(0xc0, bit.bor(bit.lshift(dst, 3), bit.band(src, 7))))
    end
end

generic_reg64_reg64("SubtractReg64Reg64", "\x29")
generic_reg64_reg64("AddReg64Reg64", "\x01")
generic_reg64_reg64("IntegerMultiplyReg64Reg64", "\x0f\xaf", true)
generic_reg64_reg64("MoveReg64Reg64", "\x89")

function META:DivideReg64(src) self:WriteData(0x48 + src < 8 and 0 or 1, 0xF7, 0xF0 + bit.band(i, 7)) end
function META:MultiplyReg64(src) self:WriteData(0x48 + src < 8 and 0 or 1, 0xF7, 0xE0 + bit.band(i, 7)) end

function META:MoveReg8Reg64(dst, src)
    local shift = src

    if shift >= 8 then
        shift = shift - 8

        if src >= 12 then
            error("NYI")
        else
            if dst < 8 then
                self:WriteData(string.char(0x41, 0x8a, (8*dst) + shift))
            elseif dst < 12 then
                self:WriteData(string.char(0x41, 0x8a, (8*dst) + shift - 32))
            else
                self:WriteData(string.char(0x45, 0x8a, (8*dst) + shift - 96))
            end
        end
    else
        if dst < 8 then
            self:WriteData(string.char(0x8a, (8*dst) + shift ))
        elseif dst < 12 then
            self:WriteData(string.char(0x40, 0x8a, (8*dst)  + shift - 32 ))
        else
            self:WriteData(string.char(0x44, 0x8a, (8*dst)  + shift - 96))
        end
    end
end

function META:MoveReg64Reg8(dst, src)
    local shift = src

    if shift >= 8 then
        shift = shift - 8

        if src >= 12 then
            error("NYI")
        else
            if dst < 8 then
                self:WriteData(string.char(0x41, 0x8a, (8*dst) + shift))
            elseif dst < 12 then
                self:WriteData(string.char(0x41, 0x8a, (8*dst) + shift - 32))
            else
                self:WriteData(string.char(0x45, 0x8a, (8*dst) + shift - 96))
            end
        end
    else
        if dst < 8 then
            self:WriteData(string.char(0x8a, (8*dst) + shift ))
        elseif dst < 12 then
            self:WriteData(string.char(0x40, 0x8a, (8*dst)  + shift - 32 ))
        else
            self:WriteData(string.char(0x44, 0x8a, (8*dst)  + shift - 96))
        end
    end
end

function META:MoveReg64ToMem64(src, dst)
    if src ~= 0 then error("not supported", 2) end
    self:WriteData("\x48\xa3")
    self:WriteData(ffi.new("uint64_t[1]", dst))
end

function META:MoveReg32ToMem64(src, dst)
    if src ~= 0 then error("not supported", 2) end
    self:WriteData("\xa3")
    self:WriteData(ffi.new("uint64_t[1]", dst))
end

function META:MoveReg16ToMem64(src, dst)
    if src ~= 0 then error("not supported", 2) end
    self:WriteData("\x66\xa3")
    self:WriteData(ffi.new("uint64_t[1]", dst))
end

function META:MoveReg8ToMem64(src, dst)
    if src ~= 0 then error("not supported", 2) end
    self:WriteData("\xa2")
    self:WriteData(ffi.new("uint64_t[1]", dst))
end

function META:MoveReg64ToMem32(src, dst)
    if src < 8 then
        self:WriteData(string.char(0x48, 0x89, 0x04 + (8*src), 0x25))
    else
        self:WriteData(string.char(0x4c, 0x89, 0x04 + (8*(src-8)), 0x25 ))
    end

    self:WriteData(ffi.new("uint32_t[1]", dst))
end

function META:MoveReg32ToMem32(src, dst)
    if src < 8 then
        self:WriteData(string.char(0x89, 0x04 + (8*src), 0x25), 0x25)
    else
        self:WriteData(string.char(0x44, 0x89, 0x04 + (8*(src-8)), 0x25 ))
    end

    self:WriteData(ffi.new("uint32_t[1]", dst))
end

function META:MoveReg16ToMem32(src, dst)
    if src < 8 then
        self:WriteData(string.char(0x66, 0x89, 0x04 + (8*src), 0x25))
    else
        self:WriteData(string.char(0x66, 0x44, 0x89, 0x04 + (8*(src-8)), 0x25 ))
    end

    self:WriteData(ffi.new("uint32_t[1]", dst))
end

function META:MoveReg8ToMem32(src, dst)
    if src < 8 then
        self:WriteData(string.char(0x88, 0x04 + (8*src), 0x25))
    elseif src < 12 then
        self:WriteData(string.char(0x40, 0x88, 0x04 + (8*(src)) - 32, 0x25 ))
    else
        self:WriteData(string.char(0x44, 0x88, 0x04 + (8*(src)) - 32 - 64, 0x25 ))
    end

    self:WriteData(ffi.new("uint32_t[1]", dst))
end

function META:MoveMem32Reg64(src, dst)
    if dst < 8 then
        self:WriteData(string.char(0x48, 0x8b, 0x04 + (8*dst), 0x25))
    else
        self:WriteData(string.char(0x4c, 0x8b, 0x04 + (8*(dst-8)), 0x25 ))
    end

    self:WriteData(ffi.new("uint32_t[1]", src))
end
function META:MoveMem32Reg32(src, dst)
    if dst < 8 then
        self:WriteData(string.char(0x8b, 0x04 + (8*dst), 0x25))
    else
        self:WriteData(string.char(0x44, 0x8b, 0x04 + (8*(dst-8)), 0x25 ))
    end

    self:WriteData(ffi.new("uint32_t[1]", src))
end
function META:MoveMem32Reg16(src, dst)
    if dst < 8 then
        self:WriteData(string.char(0x66, 0x8b, 0x04 + (8*dst), 0x25))
    else
        self:WriteData(string.char(0x66, 0x44, 0x8b, 0x04 + (8*(dst-8)), 0x25 ))
    end

    self:WriteData(ffi.new("uint32_t[1]", src))
end
function META:MoveMem32Reg8(src, dst)
    if dst < 8 then
        self:WriteData(string.char(0x8a, 0x04 + (8*dst), 0x25))
    elseif dst < 12 then
        self:WriteData(string.char(0x40, 0x8a, (8*dst) - 28, 0x25))
    else
        self:WriteData(string.char(0x44, 0x8a, (8*dst) - 92, 0x25))
    end

    self:WriteData(ffi.new("uint32_t[1]", src))
end

function META:CompareConst8Reg8(dst, src)
    if src == 0 then
        self:WriteData("\x3c")
    elseif index < 8 then
        self:WriteData(string.char(0x80, 0xf9 + src - 1))
    elseif index < 12 then
        self:WriteData(string.char(0x40, 0x80, 0xf9 + src - 4 - 1))
    else
        self:WriteData(string.char(0x41, 0x80, 0xf9 + src - 12 - 1))
    end

    self:WriteData(ffi.new("uint8_t[1]", dst))
end

function META:CompareConst32Reg64(dst, src)
    if src < 8 then
        self:WriteData(string.char(0x48, 0x3b, 0x04 + (8*src), 0x25))
    else
        self:WriteData(string.char(0x4c, 0x3b, 0x04 + (8*(src-8)), 0x25 ))
    end

    self:WriteData(ffi.new("uint32_t[1]", dst))
end

function META:CompareConst8Reg64(dst, src)
    if src < 8 then
        self:WriteData(string.char(0x48, 0x83, 0xf8 + src))
    else
        self:WriteData(string.char(0x49, 0x83, 0xf8 + src - 8))
    end

    self:WriteData(ffi.new("uint8_t[1]", dst))
end

function META:Syscall()
    self:WriteData("\x0f\x05")
end

function META:Return()
    self:WriteData("\xc3")
end

function META:JumpNotEqualConst8(dst)
    dst = dst - self.Position - 2

    self:WriteData("\x75")
    self:WriteData(ffi.new("int8_t[1]", dst))
end

function META:JumpEqualConst8(dst)
    dst = dst - self.Position - 2

    self:WriteData("\x74")
    self:WriteData(ffi.new("int8_t[1]", dst))
end

function META:MoveMemReg64Reg64(src, dst)
    local index = bit.bor(0x0, bit.bor(bit.lshift(dst, 3), src%8))

    -- to be identical to gcc these had to be for some reason
    if src == 5 and dst == 0 then
        self:WriteData(string.char(0x48, 0x8b, 0x45))
    elseif src == 12 and dst == 0 then
        -- (r12) rax: 49 8b 04 24
        self:WriteData(string.char(0x49, 0x8b, 0x04, 0x24))
    elseif src == 13 and dst == 0 then
        -- mov 0x0(r13) rax: 49 8b 45 00
        self:WriteData(string.char(0x49, 0x8b, 0x45, 0x00))
    else
        if src < 8 then
            self:WriteData(string.char(0x48, 0x8b, index))
        else
            self:WriteData(string.char(0x49, 0x8b, index))
        end
    end

    -- to be identical to gcc these had to be for some reason

    -- mov (rsp) rax: 48 8b 04 24
    if src == 4 and dst == 0 then
        self:WriteData("\x24")
    end

    -- mov 0x0(rbp) rax: 48 8b 45 00
    if src == 5 and dst == 0 then
        self:WriteData("\x00")
    end
end

if RELOAD then
    runfile("test.lua")
end
