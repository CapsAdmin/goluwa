local asm = _G.asm or ...

function asm.PrintGAS(code, format_func, compare)
    local str = asm.GASTableToString(asm.GASToTable(code), nil, format_func, compare)
    logn(str)
end

function asm.GASTableToString(tbl, skip_print_matched, format_func, compare)
    format_func = format_func or string.hexformat
    local ok = true

    local out = {}

    do
        local longest = 0

        for _, data in ipairs(tbl) do
            for _, arg in ipairs(data.guess) do
                longest = math.max(longest, #arg)
            end
        end

        for _, data in ipairs(tbl) do
            local fmt = ("%-"..longest.."s "):rep(#data.guess - 1) .. "%s "
            data.guess = string.format(fmt, unpack(data.guess))
        end
    end

    do
        local longest_left = 0
        local longest_right = 0

        for _, data in ipairs(tbl) do
            data.hex = format_func(data.bytes)

            longest_left = math.min(math.max(longest_left, #data.guess), 99)
            longest_right = math.min(math.max(longest_right, #data.hex), 99)
        end

        for i, data in ipairs(tbl) do
            if not skip_print_matched then
                table.insert(out, string.format("%-"..longest_left.."s: %"..longest_right.."s", data.guess, data.hex))
            end

            local compare_bytes = data.compare_bytes or (compare and compare[i].bytes)

            if compare_bytes and compare_bytes ~= data.bytes then
                if skip_print_matched then
                    table.insert(out, string.format("%-"..longest_left.."s: %"..longest_right.."s", data.guess, data.hex))
                end

                local hex = format_func(compare_bytes)

                hex =  ("%"..longest_right.."s"):format(hex)

                table.insert(out, (" "):rep(longest_left + 2) .. hex)
                table.insert(out, (" "):rep(longest_left + 2) .. ("^"):rep(#hex))
                table.insert(out, "")

                ok = false
            end
        end
    end

    return table.concat(out, "\n"), ok
end

function asm.CompareGAS(tbl, skip_print_matched, compare)
    local obj = asm.CreateAssembler(4096)

    local gas_asm = ""
    local our_bytes = {}
    for _, data in ipairs(tbl) do
        local func = data[2]
        local pos = obj:GetPosition()

        if not obj[func] then
            return nil, "comparison failed: no such function in lua obj:" .. func
        end

        obj[func](obj, unpack(data, 3))

        gas_asm = gas_asm .. data[1] .. "\n"

        table.insert(our_bytes, obj:GetString(pos, obj:GetPosition() - pos))
    end

    local res, err = asm.GASToTable(gas_asm)
    if not res then
        return nil, "comparison failed: " .. err
    end

    for i,v in ipairs(res) do
        v.compare_bytes = our_bytes[i]
    end

    local str, ok = asm.GASTableToString(res, skip_print_matched)

    logn(str)

    if ok then
        return true
    end

    return nil, "comparison failed!"
end

function asm.LuaToTable(str)
    local out = {}
    local obj = asm.CreateAssembler(4096)

    for _, line in ipairs(str:split("\n")) do
        local pos = obj:GetPosition()
        local ok, err = pcall(loadstring("local obj = ...\n" .. line), obj)
        if ok then
            table.insert(out, {guess = line, bytes = obj:GetString(pos, obj:GetPosition() - pos)})
        else
            print(line .. ": " .. err)
        end
    end

    obj:Unmap()

    return out
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

            local bin = ""

            for _, hex in ipairs(bytes:split(" ")) do
                bin = bin .. string.char(tonumber(hex, 16))
            end

            table.insert(tbl, {address = address, bytes = bin, guess = guess})
        end

        return tbl
    end

    local res, err = go()

    os.remove("temp.o")
    os.remove("temp")
    os.remove("temp.dump")

    return res, err
end