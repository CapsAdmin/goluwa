local ffi = require("ffi")

local bit_rshift = bit.rshift
local bit_lshift = bit.lshift
local bit_bor = bit.bor
local bit_band = bit.band

local function swap_endian(num, size)
	local result = 0
	for shift = 0, (size * 8) - 8, 8 do
		result = bit_bor(bit_lshift(result, 8), bit_band(bit_rshift(num, shift), 0xff))
	end
	return result
end

local ffi_cast = ffi.cast
local ffi_string = ffi.string

local bytepack = {}

bytepack.swap_endian = swap_endian

if ffi.abi("le") then
    bytepack.BE = swap_endian
    bytepack.LE = function(num, size) return num end
else
    bytepack.BE = function(num, size) return num end
    bytepack.LE = swap_endian
end

local function ENDIAN(num, size, big_endian)
    if big_endian then
        return bytepack.BE(num, size)
    end

    return bytepack.LE(num, size)
end

do
    local function generic(type)
        local boxed_ctor = ffi.typeof(type .. "[1]")
        local boxed_ctor2 = ffi.typeof(type .. "*")
        local size = ffi.sizeof(boxed_ctor)

        return {
            encode = function(num, big_endian)
                num = ENDIAN(num, size, big_endian)
                return ffi_string(boxed_ctor(num), size)
            end,
            decode = function(ptr, big_endian)
                if big_endian then
                    local temp = ffi.new("uint8_t[?]", size)
                    for i = 0, size - 1 do
                        temp[i] = ptr[-i + size]
                    end
                    ptr = temp
                end

                return ffi_cast(boxed_ctor2, ptr)[0]
            end,
            size = size,
        }
    end

    local types = {
        "int8_t",
        "int16_t",
        "int32_t",
        "int64_t",
        "uint8_t",
        "uint16_t",
        "uint32_t",
        "uint64_t",

        "double",
        "float",
    }

    for _, type in ipairs(types) do
        bytepack[type] = generic(type)
    end
end

bytepack.varint = {
    encode = function(value)
        local output_size = 1

        local str = {}

		while value > 127 do
            str[output_size] = string.char(tonumber(bit.bor(bit.band(value, 127), 128)))
			value = bit.rshift(value, 7)
			output_size = output_size + 1
		end

		str[output_size] = string.char(tonumber(bit.band(value, 127)))

        return table.concat(str)
    end,
    decode = function(str, byte_size)
        local ret = 0

        for i = 0, byte_size - 1 do
            local byte = str[i]
            ret = bit.bor(ret, bit.lshift(bit.band(byte, 127), 7 * i))
            if bit.band(byte, 128) == 0 then
                break
            end
        end

        if byte_size == 1 then
            ret = tonumber(ffi.cast("uint8_t", ret))
        elseif byte_size == 2 then
            ret = tonumber(ffi.cast("uint16_t", ret))
        elseif byte_size >= 2 and byte_size <= 4 then
            ret = tonumber(ffi.cast("uint32_t", ret))
        elseif byte_size > 4 then
            ret = ffi.cast("uint64_t", ret)
        end

        return ret
    end,
}

do -- taken from lua sources https://github.com/lua/lua/blob/master/lstrlib.c
    local NB = 8
    local MC = bit.lshift(1, NB) - 1
    local SZINT = ffi.sizeof("uint64_t")

    bytepack.packint = {
        encode = function(n, size, signed, big_endian)
            n = ENDIAN(n, size, big_endian)

            local buff = ffi.new("char[?]", size)

            for i = 0, size - 1 do
                buff[i] = tonumber(bit.band(n, MC))
                n = bit.rshift(n, NB)
            end

            if signed and size > SZINT then
                for i = SZINT, size - 1 do
                    buff[i] = MC
                end
            end

            return ffi.string(buff, size)
        end,
        decode = function(str, size, signed, big_endian)
            str = ffi.cast("uint8_t *", str)

            if big_endian then
                local temp = ffi.new("uint8_t[?]", size)
                for i = 0, size - 1 do
                    temp[i] = str[-i + size]
                end
                str = temp
            end

            local res = 0
            local limit = (size <= SZINT) and size or SZINT

            for i = limit - 1, 0, -1 do
                res = bit.lshift(res, NB)
                res = bit.bor(res, str[i])
            end

            if size < SZINT then
                if signed then
                    local mask = bit.lshift(1, size*NB - 1)
                    res = bit.bxor(res, mask) - mask
                end
            elseif size > SZINT then
                local mask = (not signed or res >= 0) and 0 or MC
                for i = limit, size - 1 do
                    if str[i] ~= mask then
                        errorf("%d-byte integer does not fit into Lua Integer", size);
                    end
                end
            end

            return res
        end,
    }
end

--[==[
local packed = bytepack.uint32_t.encode(0xdeadbeef, true)
print(packed:hexformat(), 0xdeadbeef)
local unpacked = bytepack.uint32_t.decode(packed, true)
print(("%x"):format(unpacked), unpacked == 0xdeadbeef, unpacked)
do return end
--[[
for k,v in pairs(bytepack) do
    local packed = bytepack[k].encode(0xDEADBEEF)
    local unpacked = bytepack[k].decode(packed)
    print(k, packed:hexformat():trim(), unpacked == 0xDEADBEEF)
end
]]

local buffer =
    bytepack.double.encode(1) ..
    bytepack.double.encode(2) ..
    bytepack.double.encode(3) ..
    bytepack.double.encode(4) ..
    bytepack.double.encode(5)

local ptr = ffi.cast("const char *", buffer)

--print(bytepack.double.decode(ptr + bytepack.double.size * 1))
local bytes = bytepack.varint.encode(0xffffffffffffffffull)
print(bytepack.varint.decode(ffi.cast("uint8_t*", bytes), #bytes), 0xffffffffffffffffull)
]==]



local commands = {
    ["<"] = "", -- sets little endian
    [">"] = "", -- sets big endian
    ["="] = "", -- sets native endian
    ["![n]"] = "", -- sets maximum alignment to n (default is native alignment)
    ["b"] = "int8_t", -- a signed byte (char)
    ["B"] = "uint8_t", -- an unsigned byte (char)
    ["h"] = "int16_t", -- a signed short (native size)
    ["H"] = "uint16_t", -- an unsigned short (native size)
    ["l"] = "int32_t", -- a signed long (native size)
    ["L"] = "uint32_t", -- an unsigned long (native size)

    ["j"] = "uint64_t", -- a lua_Integer
    ["J"] = "uint64_t", -- a lua_Unsigned

    ["T"] = "uint64_t", -- a size_t (native size)

    ["i[n]"] = "", -- a signed int with n bytes (default is native size)
    ["I[n]"] = "", -- an unsigned int with n bytes (default is native size)

    ["f"] = "float", -- a float (native size)
    ["d"] = "double", -- a double (native size)
    ["n"] = "double", -- a lua_Number

    ["c[n]"] = "", -- a fixed-sized string with n bytes
    ["z"] = "", -- a zero-terminated string
    ["s[n]"] = "", -- a string preceded by its length coded as an unsigned integer with n bytes (default is a size_t)
    ["x"] = "", -- one byte of padding
    ["X[op]"] = "", -- an empty item that aligns according to option op (which is otherwise ignored)
    [" "] = "", -- (empty space) ignored
}

do
    local arg_types = {
        n = function(str, pos)
            if pos == #str then
                print("!!!")
            end
            return str:find("%d+", pos)
        end,

        op = function(str, pos) return pos, pos end, -- this is a bit special
    }

    local temp = {}

    for k,v in pairs(commands) do
        local args = {}
        local capture
        local arg_type

        if k:endswith("]") then
            arg_type = k:match("%b[]"):sub(2, -2)
            capture = arg_types[arg_type] or error("unknown arg type " .. v)
            k = k:sub(0, -4)
        end

        table.insert(temp, {
            name = k,
            capture = capture,
            func = v,
            arg_type = arg_type,
        })
    end

    table.sort(temp, function(a, b) return #a.name > #b.name end)

    commands = temp
end

local function read(state)
    for _, cmd in ipairs(commands) do
        local start, stop = state.input:find(cmd.name, state.position, true)
        local capture
        if start then
            state.position = stop
            if cmd.capture then
                local start, stop = cmd.capture(state.input, state.position)
                if start then
                    state.position = stop
                    capture = state.input:sub(start, stop)

                    if cmd.arg_type == "n" then
                        capture = tonumber(capture)
                    end
                end
            end

            return cmd, capture
        end
    end
end

local function compile(str, decode)
    local state = {
        input = str,
        position = 1,
    }

    local lua = "local bytepack, input = ...\nlocal out = {}\n"

    local endianess = "nil"

    local i = 1

    while state.position <= #state.input do
        local cmd, arg = read(state)

        if cmd then
            if cmd.name == ">" then -- big
                endianess = "true"
            elseif cmd.name == "<" then -- small
                endianess = "false"
            elseif cmd.name == "=" then -- native
                endianess = "nil"
            else
                local first_arg
                local what

                lua = lua .. "out["..i.."] = "

                if decode then
                    first_arg = "input"
                    what = "decode"
                else
                    first_arg = "input["..i.."]"
                    what = "encode"
                end

                if cmd.name == "I" then
                    lua = lua .. "bytepack.packint."..what.."("..first_arg..", "..arg..", false, "..endianess..")\n"
                    if decode then
                        lua = lua .. "input = input + " .. arg .. "\n"
                    end
                elseif cmd.name == "i" then
                    lua = lua .. "bytepack.packint."..what.."("..first_arg..", "..arg..", true, "..endianess..")\n"
                    if decode then
                        lua = lua .. "input = input + " .. arg .. "\n"
                    end
                elseif cmd.func ~= "" then
                    lua = lua .. "bytepack."..cmd.func.."."..what.."("..first_arg..", "..endianess..")\n"
                    if decode then
                        lua = lua .. "input = input + " .. bytepack[cmd.func].size .. "\n"
                    end
                else
                    llog("n " .. cmd.name)
                end

                i = i + 1
            end
        end

        state.position = state.position + 1
    end

    if decode then
        lua = lua .. "return out"
    else
        lua = lua .. "return table.concat(out)"
    end

    return assert(loadstring(lua, fmt))
end

--local digest = spack("<I4I4I4I4", state[1], state[2], state[3], state[4])

function string.pack(fmt, ...)
    local func = compile(fmt, false)
    return func(bytepack, table.pack(...))
end

function string.unpack(fmt, str, pos)
    local func = compile(fmt, true)
    return unpack(func(bytepack, ffi.cast("uint8_t *", str)))
end

function string.packsize(fmt)
    local state = {
        input = fmt,
        position = 1,
    }

    local size = 0

    while state.position <= #state.input do
        local cmd, arg = read(state)

        if cmd then
            if cmd.name == "I" or cmd.name == "i" then
                size = size + arg
            elseif cmd.func ~= "" then
                size = size + ffi.sizeof(cmd.func)
            else
                llog("nyi " .. cmd.name)
            end
        end

        state.position = state.position + 1
    end

    return size
end

return bytepack