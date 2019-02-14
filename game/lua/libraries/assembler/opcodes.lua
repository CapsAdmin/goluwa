local map = {}
local keyval = {}

resource.Download("https://raw.githubusercontent.com/asmjit/asmdb/master/x86data.js"):Then(function(path)
	local js = vfs.Read(path)
	local json = js:match("// %$%{JSON:BEGIN%}(.+)// ${JSON:END}")
	json = json:gsub("%/%*.-%*/", "")

	local db = serializer.Decode("json", json)

	-- /r = modrm + sib and displacement
    -- /0 = modrm only

	-- +r = preceeding byte + 0-7

	local type_translate = {
		ib = "int8_t",
		iw = "int16_t",
		id = "int32_t",
		iq = "int64_t",

		ub = "uint8_t",
		uw = "uint16_t",
		ud = "uint32_t",
        uq = "uint64_t",

        r64 = "reg64",
        r32 = "reg32",
        r16 = "reg16",
        r8 = "reg8",

        m32 = "disp32"
	}

	local function parse(name, bytes, args, everything)
        local node = map
        local tbl = bytes:split(" ")
        for i, byte in ipairs(tbl) do
            byte = tonumber(byte, 16) or byte

            node[byte] = node[byte] or {}
            if i == #tbl then
                local info = {}

                if args:sub(2,2) == ":" then
                    info.write = args:sub(1, 1)
                    args = args:sub(3)
                end

                info.args = {}

                local splt = args:split(",")

                for i, v in ipairs(splt) do
                    local shared = false
                    if v:startswith("~") then
                        v = splt[i + 1]:sub(2)
                        shared = true
                    end

                    v = v:trim()

                    info.args[i] = v:split("/")
                    for i2, v in ipairs(info.args[i]) do
                        info.args[i][i2] = type_translate[v] or v
                    end

                    if shared then
                        info.args[i + 1] = info.args[i]
                        break
                    end
                end
                node[byte].ARGS = info
                keyval[name] = keyval[name] or {}
                info.temp = everything
                table.insert(keyval[name], info)
            else
                node = node[byte]
            end
        end
	end

	for i, v in ipairs(db.instructions) do
		local name, args, a, bytes, dependencies = unpack(v)

		if false and bytes:find("+r", nil, true) then
			for i = 0, 7 do
				local newbytes = bytes:gsub("(..)+r", function(hex)
					return string.format("%X", tonumber(hex, 16) + i)
				end)
				parse(name, newbytes, args, v)
			end
		elseif false and bytes:find("+i", nil, true) then
			for i = 0, 7 do
				local newbytes = bytes:gsub("(..)+r", function(hex)
					return string.format("%X", tonumber(hex, 16) + i)
				end)
				parse(name, newbytes, args, v)
			end
		else
			parse(name, bytes, args, v)
		end
    end

    local lua = {}
    local function write(str) table.insert(lua, str) end
    for name, data in pairs(keyval) do
        if name == "mov" then
            write "function e.mov(_1, _2, _3)\n"

            for _, info in pairs(data) do


                    local args = {}
                if info.args then
                    for i,v in ipairs(info.args) do
                        args[i] = table.concat(v, "|")
                    end
                end
                print("asm.mov(" .. table.concat(args, ", ") .. ") -- " .. table.concat({info.temp[2], info.temp[3], info.temp[4], info.temp[5]}, " | "))
            end
        end
    end

    print(table.concat(lua))
end)

--asm.mov(reg32|m32, int32_t|uint32_t) -- W:r32/m32, id/ud | MI | C7 /0 id
-- movw IMM_0x1 0xdeadbee       : 66 c7 04 25  ee db ea 0d  01 00
-- movw IMM_0x1 0xdeadbee(eax)  : 67 66 c7 80  ee db ea 0d  01 00
asm.PrintGAS("mov %eax, 0xfff(%ecx, %eax)", format_func)
