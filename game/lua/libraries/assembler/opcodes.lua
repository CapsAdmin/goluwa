local ffi = require("ffi")

local map = {}
local keyval = {}
local opcodes = {}

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
	}

	local function parse(name, bytes, args, everything)
        opcodes[name] = opcodes[name] or {}

        args = args

        if args:sub(2,2) == ":" then
            --info.write = args:sub(1, 1)
            args = args:sub(3)
        end

        args = args:replace(" ", "")

        local tbl = {}
        local max = 0
        for i, arg in ipairs(args:split(",")) do
            tbl[i] = tbl[i] or {}
            for z, var in ipairs(arg:split("/")) do
                tbl[i][z] = var
            end
            max = math.max(max, #tbl[i])
        end

        for z = 1, max do
            local str = {}
            for i = 1, #args:split(",") do
                table.insert(str, tbl[i][math.min(z, #tbl[i])])
            end
            str = table.concat(str,",")
            opcodes[name][str] = everything
        end
        
do return end

        local splt = args:split(",")                
        local node = opcodes[name]
        for i, key in ipairs(splt) do
            key = key:trim()

            if key:startswith("rm") then
                local bits = tonumber(key:sub(3, 4)) or tonumber(key:sub(3, 3))
                key = "rm" .. bits
            elseif key:startswith("r") and tonumber(key:sub(2)) then
                local bits = tonumber(key:sub(2, 3)) or tonumber(key:sub(2, 2))
                key = "r" .. bits
            end

            node[key] = node[key] or {}
            node = node[key]

            
            if i == #splt then 
                node.DONE = everything
            end
        end
do return end

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

  --  print(table.concat(lua))
end)

local base = {
	"ax", "cx", "dx", "bx",
	"sp", "bp", "si", "di",
}

local x86_64 = {}

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

local REX_PATTERN = 0b01000000 -- Fixed base bit pattern
local REX = {
	W = 0b00001000, -- 64bit mode
	R = 0b00000100, -- r8-r15
	X = 0b00000010, -- r8-r15
	B = 0b00000001, -- r8-r15
}

local VEX_2_BYTES_PREFIX = 0xC5
local VEX_3_BYTES_PREFIX = 0xC4
local XOP_PREFIX = 0x8F

x86_64.KnownBits = {64, 32, 16, 8}

x86_64.RegLookup = {}

for _, bit in ipairs(x86_64.KnownBits) do
	for i, reg in ipairs(asm["Reg" .. bit]) do
        local info = {}

		info.bits = bit

        if i >= 8 then
            info.extra = true
        end

		info.index = (i - 1)%7

        x86_64.RegLookup[reg] = info
	end
end

local function REG(name, disp, scale)
    return {
        reg = x86_64.RegLookup[name],   
        disp = disp,
        scale = scale,
    }
end


--asm.mov(reg32|m32, int32_t|uint32_t) -- W:r32/m32, id/ud | MI | C7 /0 id
-- movw IMM_0x1 0xdeadbee       : 66 c7 04 25  ee db ea 0d  01 00
-- movw IMM_0x1 0xdeadbee(eax)  : 67 66 c7 80  ee db ea 0d  01 00
--asm.PrintGAS("mov %eax, 0xfff(%ecx, %eax)", format_func)

-- table means register

local numtypes = {
    {ctype = "uint8_t", index = "ub"},
    {ctype = "int8_t", index = "ib"},
    {ctype = "uint16_t", index = "uw"},
    {ctype = "int16_t", index = "iw"},
    {ctype = "uint32_t", index = "ud"},
    {ctype = "int32_t", index = "id"},
    {ctype = "uint64_t", index = "uq"},
    {ctype = "int64_t", index = "iq"},
}

local function handle_arg(node, i, arg)
    if type(arg) == "table" then
        if arg.disp or arg.scale then
            local key = "r" .. arg.reg.bits .. "/m" .. arg.reg.bits
            if not node[key] then
                table.print(node)
                error("unexpected register memory to argument "..i..": " .. tostring(arg), 3)
            end

            return node[key]
        elseif node["r" .. arg.reg.bits] then
            return node["r" .. arg.reg.bits]
        elseif node["r" .. arg.reg.bits .. "/m" .. arg.reg.bits] then
            return node["r" .. arg.reg.bits .. "/m" .. arg.reg.bits]
        end
        table.print(node)
        error("unexpected register to argument "..i..": " .. tostring(arg), 3)
    elseif type(arg) == "number" then
        if node["ib/ub"] or node["iw/uw"] or node["id/ud"] then
            return node["ib/ub"] or node["iw/uw"] or node["id/ud"]
        end
        table.print(node)
        error("unexpected number to argument: "..i..": " .. tostring(arg), 3)
    else
        for _, info in ipairs(numtypes) do
            if ffi.istype(arg, info.ctype) and node[info.index] then
                return node[info.index]
            end             
        end

        table.print(node)
        error("unexpected cdata to argument: "..i..": " .. tostring(arg), 3)
    end
end   

local function run(func, ...)
    local node = opcodes[func]
    if not node then
        error("no such function " .. func, 2)
    end
    local str = ""
    local max = select("#", ...)
    for i = 1, max do
        local arg = select(i, ...)

        if type(arg) == "table" then
            if arg.disp or arg.scale then
                str = str .. "m" .. arg.reg.bits
            else
                str = str .. "r" .. arg.reg.bits
            end
        elseif type(arg) == "number" then
            str = str .. "id"
        end

        if i ~= max then
            str = str .. ","
        end

        --[[node = handle_arg(node, i + 1, select(i, ...))
        
        if node.DONE then
            return node.DONE
        end]]
    end
    print(str)
    --table.print(node)
    return node[str]
end

table.print(run("mov", REG("ecx", scale), 3))