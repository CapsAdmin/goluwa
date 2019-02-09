print("building gas instructions..")

local tbl = {}

local function test(fmt, ...)

    fmt = fmt:format(...)

    local args = fmt:split(" ")
    local gas_name = table.remove(args, 1)
    local lua_name = table.remove(args, 1)

    local gas_args = {}
    local lua_args = {}

    for i, arg in ipairs(args) do
        if asm.RegToSize[arg] or arg:startswith("$") or arg:startswith("(") or tonumber(arg) then

            if asm.RegToSize[arg] then
                gas_args[i] = "%" .. arg
            else
                gas_args[i] = arg
            end

            if arg:startswith("$") then
                arg = tonumber(arg:sub(2))
            elseif arg:startswith("(") then
                arg = loadstring("return " .. arg:sub(2, -2) .. "ULL")()
            else
                arg = asm.RegLookup[arg]
            end

            args[i] = arg
        else
            error("unknown argument " .. arg)
        end
    end
    table.insert(tbl, {gas_name .. " " .. table.concat(gas_args, ", "), lua_name, unpack(args)})
end

for _, bit in ipairs(asm.KnownBits) do
    for _, reg in pairs(asm["Reg"..bit]) do
        test("inc IncreaseReg%s %s", bit, reg)
        test("dec DecreaseReg%s %s", bit, reg)
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
    test("cmp CompareConst8Reg64 $%s %s", "0xf", reg)
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

--test("mov MoveReg64Reg8 cl rsi")

for _, bit in ipairs(asm.KnownBits) do
    local reg = asm["Reg" .. bit][1]
    test("mov MoveReg"..bit.."ToMem64 %s (0xDEADBEEFCAFEBABE)", reg)
end

for _, bit in ipairs(asm.KnownBits) do
    for _, reg in ipairs(asm["Reg" .. bit]) do
        test("mov MoveReg%sToMem32 %s (0xDEADB)", bit, reg)
        test("mov MoveMem32Reg%s (0xFFFFFF) %s", bit, reg)
    end
end

print("comparing " .. #tbl .. " instructions..")
local ok, err = asm.CompareGAS(tbl, true)

if ok then
    print("comparison OK!")
else
    print(err)
end