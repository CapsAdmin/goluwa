local asm = _G.asm or {}

local ffi = require("ffi")

ffi.cdef[[
    char *mmap(void *addr, size_t length, int prot, int flags, int fd, long int offset);
    int munmap(void *addr, size_t length);
]]

local PROT_READ = 0x1 -- Page can be read.
local PROT_WRITE = 0x2 -- Page can be written.
local PROT_EXEC = 0x4 -- Page can be executed.
local PROT_NONE = 0x0 -- Page can not be accessed.
local PROT_GROWSDOWN = 0x01000000 -- Extend change to start of growsdown vma (mprotect only).
local PROT_GROWSUP = 0x02000000 -- Extend change to start of growsup vma (mprotect only).
local MAP_SHARED = 0x01 -- Share changes.
local MAP_PRIVATE = 0x02
local MAP_ANONYMOUS = 0x20

local META = {}
META.__index = META

function asm.CreateAssembler(size)
    size = size or 4096
    local mem = ffi.C.mmap(nil, size, bit.bor(PROT_READ, PROT_WRITE, PROT_EXEC), bit.bor(MAP_PRIVATE, MAP_ANONYMOUS), -1, 0)

    if mem == nil then
        return nil, "failed to map memory"
    end

    local self = setmetatable({}, META)

    self.Size = size
    self.Memory = mem
    self.Position = 0
    self.Instructions = {}

    return self
end

function META:WriteData(data)
    if type(data) == "string" then
        ffi.copy(self.Memory + self.Position, data, #data)
        self:Advance(#data)
    elseif type(data) == "cdata" then
        local size = ffi.sizeof(data)
        ffi.copy(self.Memory + self.Position, data, size)
        self:Advance(size)
    end
end

function META:Advance(pos)
    self.Position = self.Position + pos
end

function META:GetPosition()
    return self.Position
end

function META:Unmap()
    ffi.C.munmap(self.Memory, self.Size)
end

function META:GetFunctionPointer()
    return ffi.cast("void (*)()", self.Memory)
end

function META:AddInstruction(name, bytes, dst)
    bytes = (bytes .. " "):gsub("(..) ", function(byte)
        return string.char(tonumber("0x"..byte))
    end)

    if type(dst) == "string" then
        local type = dst
        dst = function(num)
            return ffi.new(type .. "[1]", num)
        end
    end

    self.Instructions[name] = {
        bytes = bytes,
        dst = dst,
    }
end

function META:GetString(pos, len)
    if pos and len then
        return ffi.string(self.Memory + pos, len)
    end

    return ffi.string(self.Memory, pos or self.Position)
end

function META:Dump()
    print(self:GetString():hexdump(32))
end

do
    local reg64 = {
        "rax", "rcx", "rdx", "rbx",
        "rsp", "rbp", "rsi", "rdi",
        "r8", "r9", "r10", "r11",
        "r12", "r13", "r14","r15",
    }

    local reg32 = {
        "eax", "ecx", "edx", "ebx",
        "esp", "ebp", "esi", "edi",
        "r8d", "r9d", "r10d", "r11d",
        "r12d", "r13d", "r14d", "r15d",
    }

    local reg16 = {
        "ax", "cx", "dx", "bx",
        "sp", "bp", "si", "di",
        "r8w", "r9w", "r10w", "r11w",
        "r12w", "r13w", "r14w", "r15w",
    }

    local reg8 = {
        "al", "cl", "dl","bl",
        "ah", "ch", "dh", "bh",
        "spl", "bpl", "sil", "dil",
        "r8b", "r9b", "r10b", "r11b",
        "r12b", "r13b", "r14b", "r15b",
    }

    local function gen_lookup(list)
        local out = {}
        for i, v in ipairs(list) do
            out[v] = i - 1
        end
        return out
    end

    asm.Reg64 = reg64
    asm.Reg64ToIndex = gen_lookup(reg64)

    asm.Reg32 = reg32
    asm.Reg32ToIndex = gen_lookup(reg32)

    asm.Reg16 = reg16
    asm.Reg16ToIndex = gen_lookup(reg16)

    asm.Reg8 = reg8
    asm.Reg8ToIndex = gen_lookup(reg8)

    asm.KnownBits = {"64", "32", "16", "8"}

    asm.RegToSize = {}

    for _, bit in ipairs(asm.KnownBits) do
        for _, reg in ipairs(asm["Reg" .. bit]) do
            asm.RegToSize[reg] = bit
        end
    end

    function asm.GetMinimumBitsFromUnsigned(num)
        if num <= 0xFF then
            return "8"
        elseif num <= 0xFFFF then
            return "16"
        elseif num <= 0xFFFFFFFF then
            return "32"
        end

        return "64"
    end


    function META:MoveConst32Reg64(src, dst)
        local index = asm.Reg64ToIndex[dst]

        if index < 8 then
            self:WriteData("\x48\xC7" .. string.char(0xc0 + index))
        else
            self:WriteData("\x49\xC7" .. string.char(0xc0 + (index - 8)))
        end

        self:WriteData(ffi.new("uint32_t[1]", src))
    end

    function META:MoveConst64Reg64(src, dst)
        local index = asm.Reg64ToIndex[dst]

        if index < 8 then
            self:WriteData("\x48" .. string.char(0xB8 + index))
        else
            self:WriteData("\x49" .. string.char(0xB8 + (index - 8)))
        end

        self:WriteData(ffi.new("uint64_t[1]", src))
    end

    function META:MoveMem32Reg64(src, dst)
        local index = asm.Reg64ToIndex[dst]

        if index < 8 then
            self:WriteData("\x48\x8B" .. string.char(0x04+(8*index)))
        else
            self:WriteData("\x4c\x8B" .. string.char(0x04+(8*(index-8))))
        end

        self:WriteData("\x25")
        self:WriteData(ffi.new("uint32_t[1]", src))
    end

    function META:PushReg64(src)
        local index = asm.Reg64ToIndex[src]

        if index < 8 then
            self:WriteData(string.char(0x50 + index))
        else
            self:WriteData(string.char(0x41, 0x50 + index - 8))
        end
    end

    function META:PopReg64(src)
        local index = asm.Reg64ToIndex[src]

        if index < 8 then
            self:WriteData(string.char(0x58 + index))
        else
            self:WriteData(string.char(0x41, 0x58 + index - 8))
        end
    end


    function META:IncreaseReg64(src)
        local index = asm.Reg64ToIndex[src]

        self:WriteData(string.char(0x48 + math.floor(index/8), 0xFF, 0xC0 + index%8))
    end

    function META:IncreaseReg32(src)
        local index = asm.Reg32ToIndex[src]

        if index >= 8 then
            self:WriteData("\x41")
        end

        self:WriteData(string.char(0xFF, 0xC0 + index%8))
    end

    function META:IncreaseReg16(src)
        local index = asm.Reg16ToIndex[src]

        if index < 8 then
            self:WriteData("\x66")
        else
            self:WriteData("\x66\x41")
        end

        self:WriteData(string.char(0xFF, 0xC0 + index%8))
    end

    function META:IncreaseReg8(src)
        local index = asm.Reg8ToIndex[src]

        if index < 8 then
            self:WriteData("\xFE")
            self:WriteData(string.char(0xC0 + index))
        elseif index < 12 then
            self:WriteData("\x40\xFE")
            self:WriteData(string.char(0xC0 + index - 4))
        else
            self:WriteData("\x41\xFE")
            self:WriteData(string.char(0xC0 + index - 12))
        end
    end

    function META:DecreaseReg64(src)
        local index = asm.Reg64ToIndex[src]

        if index < 8 then
            self:WriteData(string.char(0x48, 0xFF, 0xC8 + index))
        else
            self:WriteData(string.char(0x49, 0xFF, 0xC8 + index - 8))
        end
    end

    local function generic_reg64_reg64(name, byte, swap)
        META[name] = function(self, dst, src)
            if swap then
                dst, src = src, dst
            end

            local index_dst = asm.Reg64ToIndex[dst]
            local index_src = asm.Reg64ToIndex[src]

            local index = bit.bor(0xc0, bit.bor(bit.lshift(index_dst, 3), index_src%8))
            if index_dst < 8 then
                if index_src < 8 then
                    self:WriteData("\x48" .. byte)
                else
                    self:WriteData("\x49" .. byte)
                end
            else
                if index_src < 8 then
                    self:WriteData("\x4c" .. byte)
                else
                    self:WriteData("\x4d" .. byte)
                end
            end

            self:WriteData(string.char(index))
        end
    end

    generic_reg64_reg64("SubtractReg64Reg64", "\x29")
    generic_reg64_reg64("AddReg64Reg64", "\x01")
    generic_reg64_reg64("IntegerMultiplyReg64Reg64", "\x0f\xaf", true)
    generic_reg64_reg64("MoveReg64Reg64", "\x89")

    function META:MultiplyReg64(src)
        local index = asm.Reg64ToIndex[src]

        if index < 8 then
            self:WriteData(string.char(0x48, 0xF7, 0xE0 + index))
        else
            self:WriteData(string.char(0x49, 0xF7, 0xE0 + index - 8))
        end
    end

    function META:DivideReg64(src)
        local index = asm.Reg64ToIndex[src]

        if index < 8 then
            self:WriteData(string.char(0x48, 0xF7, 0xF0 + index))
        else
            self:WriteData(string.char(0x49, 0xF7, 0xF0 + index - 8))
        end
    end

    function META:MoveReg8Reg64(dst, src)
        local index_reg64 = asm.Reg64ToIndex[src]
        local index_reg8 = asm.Reg8ToIndex[dst]

        local shift = index_reg64

        if shift >= 8 then
            shift = shift - 8

            if index_reg64 >= 12 then
                error("NYI")
            else
                if index_reg8 < 8 then
                    self:WriteData(string.char(0x41, 0x8a, (8*index_reg8) + shift))
                elseif index_reg8 < 12 then
                    self:WriteData(string.char(0x41, 0x8a, (8*index_reg8) + shift - 32))
                else
                    self:WriteData(string.char(0x45, 0x8a, (8*index_reg8) + shift - 96))
                end
            end
        else
            if index_reg8 < 8 then
                self:WriteData(string.char(0x8a, (8*index_reg8) + shift ))
            elseif index_reg8 < 12 then
                self:WriteData(string.char(0x40, 0x8a, (8*index_reg8)  + shift - 32 ))
            else
                self:WriteData(string.char(0x44, 0x8a, (8*index_reg8)  + shift - 96))
            end
        end
    end

    function META:CompareConst8Reg8(dst, src)
        local index = asm.Reg8ToIndex[src]

        if src == "al" then
            self:WriteData("\x3c")
        elseif index < 8 then
            self:WriteData(string.char(0x80, 0xf9 + index - 1))
        elseif index < 12 then
            self:WriteData(string.char(0x40, 0x80, 0xf9 + index - 4 - 1))
        else
            self:WriteData(string.char(0x41, 0x80, 0xf9 + index - 12 - 1))
        end

        self:WriteData(ffi.new("uint8_t[1]", dst))
    end

    function META:CompareConst32Reg64(dst, src)
        local index = asm.Reg64ToIndex[src]

        if index < 8 then
            self:WriteData(string.char(0x48, 0x3b, 0x04 + (8*index), 0x25))
        else
            self:WriteData(string.char(0x4c, 0x3b, 0x04 + (8*(index-8)), 0x25 ))
        end

        self:WriteData(ffi.new("uint32_t[1]", dst))
    end

    function META:CompareConst8Reg64(dst, src)
        local index = asm.Reg64ToIndex[src]

        if index < 8 then
            self:WriteData(string.char(0x48, 0x83, 0xf8 + index))
        else
            self:WriteData(string.char(0x49, 0x83, 0xf8 + index-8))
        end

        self:WriteData(ffi.new("uint8_t[1]", dst))
    end

    function META:Syscall()
        self:WriteData("\x0f\x05")
    end

    function META:Return()
        self:WriteData("\xc3")
    end

    function META:JumpNotEqualConst8(address)
        address = address - self.Position - 2

        self:WriteData("\x75")
        self:WriteData(ffi.new("int8_t[1]", address))
    end

    function META:JumpEqualConst8(address)
        address = address - self.Position - 2

        self:WriteData("\x74")
        self:WriteData(ffi.new("int8_t[1]", address))
    end
end

function asm.ObjectToAddress(str)
    return assert(loadstring("return " .. tostring(ffi.cast("void *", str)):match(": (0x.+)") .. "ULL"))()
end

function asm.GASToTable(str)
    if not str:find("_start", nil, true) then
        str = ".global _start\n.text\n_start:\n" .. str
        str = str:gsub("; ", "\n")
    end
    str = str .. "\n"

    local function go()

        local f, err = io.open("temp.S", "wb")

        if not f then
            return nil, "failed to read temp.S: " .. err
        end

        f:write(str)
        f:close()

        if not os.execute("as -o temp.o temp.S") then return nil, "failed to assemble temp.S" end
        if not os.execute("ld -s -o temp temp.o") then return nil, "failed to generate executable from temp.o" end

        -- we could execute it to try but usually
        --os.execute("./temp")

        if not os.execute("objdump -S --insn-width=16 --disassemble temp > temp.dump") then return nil, "failed to disassemble temp" end

        local f, err = io.open("temp.dump", "rb")
        if not f then
            return nil, "failed to read temp.dump: " .. err
        end
        local bin = f:read("*all")
        f:close()

        local chunk = bin:match("<.text>:(.+)"):trim():gsub("\n%s+", "\n")

        local tbl
        for line in (chunk.."\n"):gmatch("(.-)\n") do
            tbl = tbl or {}
            local address, bytes, guess = line:match("^(.-):%s+(%S.-)  %s+(%S.+)")
            guess = guess:gsub(",", ", ")
            guess = guess:gsub("%%", "")
            guess = guess:gsub("%$", "")
            guess = guess:gsub(",", "")
            guess = guess:gsub("%s+", " ")
            guess = guess:split(" ")

            table.insert(tbl, {address = address, bytes = bytes, guess = guess})
        end

        return tbl
    end

    local res, err = go()

    os.remove("temp.o")
    os.remove("temp")
    os.remove("temp.dump")

    return res, err
end

function asm.PrintGAS(code, compare_hex)
    local ok = true
    local skip_print_matched = type(code) == "table" and compare_hex
    local asm = type(code) == "table" and code or asm.GASToTable(code)

    if asm then
        do
            local longest = 0
            for _, data in ipairs(asm) do
                for _, arg in ipairs(data.guess) do
                    longest = math.max(longest, #arg)
                end
            end

            for _, data in ipairs(asm) do
                local fmt = ("%-"..longest.."s "):rep(#data.guess - 1) .. "%s "
                data.guess = string.format(fmt, unpack(data.guess))
            end
        end

        do
            local longest = 0

            for _, data in ipairs(asm) do
                longest = math.max(longest, #data.guess)
                longest = math.max(longest, #data.bytes)
            end

            for _, data in ipairs(asm) do
                if not skip_print_matched then
                    logf("%-"..longest.."s: %-"..longest.."s\n", data.guess, data.bytes)
                end

                if data.compare then
                    if data.compare ~= data.bytes then
                        if skip_print_matched then
                            logf("%-"..longest.."s: %-"..longest.."s\n", data.guess, data.bytes)
                        end

                        logn((" "):rep(longest + 2), data.compare)
                        logn((" "):rep(longest + 2), ("^"):rep(#data.compare))
                        logn()
                        ok = false
                    end
                elseif compare_hex then
                    if compare_hex ~= data.bytes then
                        compare_hex = compare_hex .. " << NOT EQUAL"

                        logn((" "):rep(longest+13), compare_hex)
                        ok = false
                    end
                end
            end
        end
    end

    return ok
end

function asm.CompareGAS(gas, func, ...)
    if type(gas) == "table" then
        local skip_print_matched = func
        local obj = asm.CreateAssembler(4096)

        local gas_asm = ""
        local our_bytes = {}
        for _, data in ipairs(gas) do
            local func = data[2]
            local pos = obj:GetPosition()
            obj[func](obj, unpack(data, 3))

            gas_asm = gas_asm .. data[1] .. "\n"

            table.insert(our_bytes, obj:GetString(pos, obj:GetPosition() - pos):hexdump(32):trim())
        end

        local res, err = asm.GASToTable(gas_asm)
        if not res then
            print("comparison failed: " .. err)
            return
        end

        for i,v in ipairs(res) do
            v.compare = our_bytes[i]
        end

        if asm.PrintGAS(res, skip_print_matched) then
            print("comparison ok!")
            return true
        end

        print("comparison failed!")
        return false
    end

    local obj = asm.CreateAssembler(32)
    obj[func](obj, ...)
    asm.PrintGAS(gas, obj:GetString():hexdump(32):trim())
    obj:Unmap()
end

function META:IncreaseReg(reg)
    local size = asm.RegToSize[reg]
    self["IncreaseReg" .. size](self, reg)
end

function asm.Test()

    local tbl = {}

    local function test(fmt, ...)
        fmt = fmt:format(...)

        local args = fmt:split(" ")
        local gas_name = table.remove(args, 1)
        local lua_name = table.remove(args, 1)

        local gas_args = {}
        local lua_args = {}

        for i, arg in ipairs(args) do
            if asm.RegToSize[arg] or arg:startswith("$") or tonumber(arg) then

                if asm.RegToSize[arg] then
                    gas_args[i] = "%" .. arg
                else
                    gas_args[i] = arg
                end

                if arg:startswith("$") then
                    arg = arg:sub(2)
                end

                args[i] = tonumber(arg) or args[i]
            else
                error("unknown argument " .. arg)
            end
        end

        table.insert(tbl, {gas_name .. " " .. table.concat(gas_args, ", "), lua_name, unpack(args)})
    end

    for _, bit in ipairs(asm.KnownBits) do
        for _, reg in pairs(asm["Reg"..bit]) do
            test("inc IncreaseReg%s %s", bit, reg)
        end
    end

    for _, what in ipairs({{"add", "Add"}, {"sub", "Subtract"}, {"imul", "IntegerMultiply"}, {"mov", "Move"}}) do
        for _, a in ipairs(asm.Reg64) do
            for _, b in ipairs(asm.Reg64) do
                test("%s %sReg64Reg64 %s %s", what[1], what[2], a, b)
            end
        end
    end

    for _, reg in ipairs(asm.Reg64) do
        test("push PushReg64 %s", reg)
    end
    for _, reg in ipairs(asm.Reg64) do
        test("pop PopReg64 %s", reg)
    end

    --mov 0xDEADBEEF causes gas to emit a MoveConst64Reg64
    for _, reg in ipairs(asm.Reg64) do
        test("mov MoveConst32Reg64 $0xDEAD %s", reg)
    end

    for _, reg in ipairs(asm.Reg64) do
        test("mov MoveConst64Reg64 $0xDEADBEEFCAFE %s", reg)
    end

    test("syscall Syscall")
    test("ret Return")

    -- this gets interpreted as an address relative to something, not sure how to test this with this setup
    --test("jne JumpNotEqualConst8 0x1")

    asm.CompareGAS(tbl, true)
end

if RELOAD then
    asm.Test()

    _G.asm = asm
end

return asm