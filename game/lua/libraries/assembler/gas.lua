local asm = _G.asm or ...

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

                        if RELOAD then
                            return false
                        end
                    end
                elseif compare_hex then
                    if compare_hex ~= data.bytes then
                        logn((" "):rep(longest+2), compare_hex)
                        logn((" "):rep(longest + 2), ("^"):rep(#compare_hex))
                        logn()
                        ok = false

                        if RELOAD then
                            return false
                        end
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

            if not obj[func] then
                print("comparison failed: no such function in lua obj:" .. func)
                return false
            end

            obj[func](obj, unpack(data, 3))

            gas_asm = gas_asm .. data[1] .. "\n"

            table.insert(our_bytes, obj:GetString(pos, obj:GetPosition() - pos):hexformat(32))
        end

        local res, err = asm.GASToTable(gas_asm)
        if not res then
            print("comparison failed: " .. err)
            return false
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
    asm.PrintGAS(gas, obj:GetString():hexformat(32):trim())
    obj:Unmap()
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
        os.execute("./temp")

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