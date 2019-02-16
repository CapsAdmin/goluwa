local asm2 = _G.asm

local asm = {}
local ffi = require("ffi")

local map = {}
local luamap = {}

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

local REX_FIXED_BIT = 0b01000000
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
asm.RegLookup = x86_64.RegLookup

for _, bit in ipairs(x86_64.KnownBits) do
	for i, reg in ipairs(x86_64["Reg" .. bit]) do
		local info = {}

		info.bits = bit

		if i > 8 then
			info.extra = true
		end

		info.index = (i - 1)%8

		x86_64.RegLookup[reg] = info
	end
end

--asm.mov(reg32|m32, int32_t|uint32_t) -- W:r32/m32, id/ud | MI | C7 /0 id
-- movw IMM_0x1 0xdeadbee       : 66 c7 04 25  ee db ea 0d  01 00
-- movw IMM_0x1 0xdeadbee(eax)  : 67 66 c7 80  ee db ea 0d  01 00
--asm.PrintGAS("mov %eax, 0xfff(%ecx, %eax)", format_func)

-- table means register

function asm.REX(W, B, R, X)
	local rex = REX_FIXED_BIT -- Fixed base bit pattern

	if W then
		rex = bit.bor(rex, REX.W)
	end

	if R then
		rex = bit.bor(rex, REX.R)
	end

	if X then
		rex = bit.bor(rex, REX.X)
	end

	if B then
		rex = bit.bor(rex, REX.B)
	end

	return string.char(rex)
end

function asm.ObjectToAddress(var)
    if type(var) == "cdata" or type (var) == "string" then
        return assert(loadstring("return " .. tostring(ffi.cast("void *", var)):match(": (0x.+)") .. "ULL"))()
    end

    return loadstring("return " .. string.format("%p", var) .. "ULL")()
end

function asm.MODRM(op1, op2)
	local reg = asm.RegLookup[op1.reg].index
	local index
	local base
	local scale
	local disp

	reg = asm.RegLookup[op1.reg].index

	if type(op2) == "number" then
		base = op2
	else
		index = asm.RegLookup[op2.index] and asm.RegLookup[op2.index].index
		base = asm.RegLookup[op2.reg] and asm.RegLookup[op2.reg].index

		disp = op2.disp
		scale = op2.scale
	end

	-- build modrm byte
	if reg and base then
		-- 00 000 000
		modrm = 0

		-- 00 src 000 - place
		modrm = bit.bor(modrm, bit.lshift(base, 3))

		if disp then
			if disp >= -127 and disp <= 127 == 1 then
				-- 10 src 000
				modrm = bit.bor(modrm, 0b01000000)
			else
				modrm = bit.bor(modrm, 0b10000000)
			end
		else
			-- 11 src 000
			modrm = bit.bor(modrm, 0b11000000)
		end

		if index then
			-- 10 src idx
			modrm = bit.bor(modrm, 0b100)
		else
			-- 10 src dst
			modrm = bit.bor(modrm, reg)
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

	local str = ""

	if modrm then
		str = str .. string.char(modrm)
	end

	if sib then
		str = str .. string.char(sib)
	end

	return str
end

function asm.INT2BYTES(t, int)
	if type(int) == "cdata" then
		int = ffi.cast(t, int)
	elseif type(int) == "number" then
		int = ffi.new(t, int)
	elseif type(int) == "string" then
		int = asm.ObjectToAddress(int)
	end

	return ffi.string(ffi.new(t.."[1]", int), ffi.sizeof(t))
end


local type_translate = {
	i8 = "int8_t",
	i16 = "int16_t",
	i32 = "int32_t",
	i64 = "int64_t",

	u8 = "uint8_t",
	u16 = "uint16_t",
	u32 = "uint32_t",
	u64 = "uint64_t",
}

local type_translate2 = {
	ib = "i8",
	iw = "i16",
	id = "i32",
	iq = "i64",

	ub = "u8",
	uw = "u16",
	ud = "u32",
	uq = "u64",

	rel8 = "i8",
	rel16 = "i16",
	rel32 = "i32",
}

local rel

local function parse_db(db)
-- /r = modrm + sib and displacement
	-- /0 = modrm only

	-- +r = preceeding byte + 0-7


	local function parse_instruction(name, operands, encoding, opcode, metadata, operands2)
		--print(" ")
		--print(name, table.concat(operands, ", "), operands2, encoding, table.concat(opcode, " "), metadata)

		local real_operands = {}
		local arg_line = {}
		for i, v in ipairs(operands) do
			real_operands[i] = v
			v = type_translate2[v] or v
			operands[i] = v
			arg_line[i] =  "op" .. i
		end


		local key = table.concat(operands, ",")

		if map[name] and map[name][key] and luamap[name][key].encoding == "MR" then
			return
		end

		arg_line = table.concat(arg_line, ", ")


		local lua = ""
		lua = lua .. table.concat({"--", name, table.concat(operands, ","), operands2, encoding, table.concat(opcode, " "), metadata}, " | ") .. "\n"
		lua = lua .. "local e = ...\nreturn function("..arg_line..")"

		local instr_length = 0



		local instr = {}

		if opcode[1] == "REX.W" then
			local op2 = ")"

			if operands[2] and (operands[2]:startswith("r") or operands[2]:startswith("m")) then
				op2 = ", op2.reg and e.RegLookup[op2.reg].extra, op2.index and e.RegLookup[op2.index].extra)"
			end

			table.insert(instr, "e.REX(true, e.RegLookup[op1.reg].extra" .. op2)
		end

		for _, byte in ipairs(opcode) do
			if byte == "/r" then
				table.insert(instr, "e.MODRM(op1, op2)")
			elseif byte:startswith("c") then
				local s = byte:sub(2,2)
				if s == "b" then
					table.insert(instr, "e.INT2BYTES('int8_t', op"..#operands..")")
				elseif s == "w" then
					table.insert(instr, "e.INT2BYTES('int16_t', op"..#operands..")")
				elseif s == "d" then
					table.insert(instr, "e.INT2BYTES('int32_t', op"..#operands..")")
				end
			elseif byte:startswith("/") and tonumber(byte:sub(2,2)) then
				table.insert(instr, "e.MODRM(op1, "..byte:sub(2,2)..")")
			elseif byte:endswith("+r") then
				table.insert(instr, "string.char(0x"..byte:sub(1, 2).." + e.RegLookup[op1.reg].index)")
			elseif type_translate[type_translate2[byte]] then
				table.insert(instr, "e.INT2BYTES(\""..type_translate[type_translate2[byte]].."\", op"..#operands..")")
			elseif tonumber(byte, 16) then
				table.insert(instr, "\"\\x"..byte.."\"")
				instr_length = instr_length + 1
			end
		end

		for i, v in ipairs(real_operands) do
			if v:startswith("rel") then
				instr_length = instr_length + tonumber(v:sub(4)) / 8
				lua = lua .. "\nop" .. i .. " = op" .. i .. " - " .. instr_length .. "\n"
			end
		end

		lua = lua .. " return\n" .. table.concat(instr, "..")
		lua = lua:gsub("\"%s*%.%.%s*\"", "")
		lua = lua .."\nend"

		map[name] = map[name] or {}
		map[name][key] = loadstring(lua)(asm)

		luamap[name] = luamap[name] or {}
		luamap[name][key] = {lua = lua, real_operands = real_operands, encoding = encoding}


	end

	for i, v in ipairs(db.instructions) do
		local name, operands, encoding, opcode, metadata = unpack(v)

		local args = {}

		local tbl = operands:split(",")
		--for i = #tbl, 1, -1 do local arg = tbl[i]
		for i, arg in ipairs(tbl) do
			arg = arg:trim()

			local mode
			if arg:sub(2,2) == ":" then
				mode = arg:sub(1, 1)
				arg = arg:sub(3)
			end

			if arg:startswith("~") then
				arg = arg:sub(2) -- also swap args?
			end

			if not arg:startswith("<") then
				table.insert(args, arg:trim())
			end
		end

		do
			local temp = {}
			local max = 0

			for i, arg in ipairs(args) do
				temp[i] = temp[i] or {}
				for z, var in ipairs(arg:split("/")) do
					temp[i][z] = var
				end
				max = math.max(max, #temp[i])
			end

			for z = 1, max do
				local args2 = {}
				for i = 1, #args do
					table.insert(args2, temp[i][math.min(z, #temp[i])])
				end

				for _, name in ipairs(name:split("/")) do
					parse_instruction(name, args2, encoding, opcode:split(" "), metadata, operands)
				end
			end
		end
	end
end


resource.Download("https://raw.githubusercontent.com/asmjit/asmdb/master/x86data.js"):Then(function(path)
	local js = vfs.Read(path)
	local json = js:match("// %$%{JSON:BEGIN%}(.+)// ${JSON:END}")
	json = json:gsub("%/%*.-%*/", "")

	local db = serializer.Decode("json", json)

	system.pcall(parse_db, db)
end)









local function run(func, ...)
	local str = {}
	local max = select("#", ...)
	local lua_number = false
	local lua_address = false

	for i = 1, max do
		local arg = select(i, ...)

		if type(arg) == "table" then
			if arg.disp or arg.scale then
				str[i] = "rm" .. x86_64.RegLookup[arg.reg].bits
			else
				str[i] = "r" .. x86_64.RegLookup[arg.reg].bits
			end
		elseif type(arg) == "number" then
			str[i] = "i?"
			lua_number = true
		elseif type(arg) == "cdata" then
			for k,v in pairs(type_translate) do
				if ffi.istype(v, arg) then
					str = str .. k
					break
				end
			end
		elseif type(arg) == "string" then
			str[i] = "i64"
		else
			str[i] = type(arg)
		end
	end

	if not map[func] then
		local candidates = {}

		for args in pairs(map) do
			table.insert(candidates, {args = args, score = string.levenshtein(args, func)})
		end

		table.sort(candidates, function(a, b) return a.score < b.score end)

		local found = ""
		for i = 1, 5 do
			if candidates[i] then
				found = found  .. "\t" .. candidates[i].args .. "\n"
			end
		end

		error("no such function " .. func .. "\ndid you mean one of these?\n" .. found)
	end

	if lua_number then
		for i, arg in ipairs(str) do
			if arg:endswith("?") then
				local num = select(i, ...)

				for _, bits in ipairs({"8", "16", "32"}) do
					str[i] = arg:sub(0, 1) .. bits
					local test = table.concat(str, ",")

					if bits == "8" and num > -128 and num < 128 and map[func][test] then
						break
					elseif bits == "16" and num > -13824 and num < 13824 and map[func][test] then
						break
					elseif bits == "32" and num > -2147483648 and num < 2147483648 and map[func][test] then
						break
					end
				end
			end
		end
	end

	str = table.concat(str, ",")

	if not map[func][str] then
		local candidates = {}

		for args in pairs(map[func]) do
			table.insert(candidates, {args = args, score = string.levenshtein(args, str)})
		end

		table.sort(candidates, function(a, b) return a.score < b.score end)

		local found = ""
		for i = 1, 5 do
			if candidates[i] then
				found = found  .. "\t" .. func .. " " .. candidates[i].args .. "\n"
			end
		end

		error(func .. " does not take arguments " .. str .. "\ndid you mean one of these?\n" .. found)
	end

	local bin = map[func][str](...)

	return bin, {
		func = func,
		arg_types = str,
		args = {...},
		bytes = bin,
		lua = luamap[func][str].lua,
		real_operands = luamap[func][str].real_operands,
	}
end

local format_func = function(str)
	return str:binformat(16, " ", true)
end


local REG
local reg_meta = {}
reg_meta.__index = reg_meta
function reg_meta:__tostring()
	if self.disp or self.index or self.scale then
		return string.format("%s(%s, %s, %s)", self.disp or "", self.reg, self.index or "", self.scale or "")
	end
	return self.reg
end

function reg_meta.__add(l, r)
	if getmetatable(r) == reg_meta then
		return REG(l.reg, r.reg, r.disp, r.scale)
	end

	if type(r) == "number" then
		l.disp = r
	end

	return l
end

function reg_meta.__sub(l, r)
	if type(r) == "number" then
		l.disp = -r
	end

	return l
end

function reg_meta.__mul(l, r)
	if type(r) == "number" then
		l.scale = r
	end

	return l
end

function REG(reg, index, disp, scale)
	return setmetatable({
		reg = reg,
		index = index,
		disp = disp,
		scale = scale,
	}, reg_meta)
end

local r = setmetatable({}, {__index = function(s, key)
	return REG(key)
end})


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

local function GAS(data)
	local gas = data.func .. " "
	local types = data.arg_types:split(",")
	for i = #data.args, 1, -1 do
		local arg, type = data.args[i], types[i]

		if type:startswith("i") then
			if _G.type(arg) == "string" then
				arg = tostring(asm.ObjectToAddress(arg)):sub(0,-3)
			elseif _G.type(arg) == "cdata" then
				arg = tonumber(arg)
			end

			if data.real_operands[i]:startswith("i") then
				gas = gas .. "$"
			end
			gas = gas .. tostring(arg)
		end
		if type:startswith("r") or type:startswith("m") then
			gas = gas .. "%" .. tostring(arg)
		end
		if i ~= 1 then
			gas = gas .. ","
		end
	end

	asm2.PrintGAS(gas, format_func, data.bytes, false)

	if false then
		print(gas)
		print(format_func(data.bytes))
		data.bytes = nil
		print(data.lua) data.lua = nil
		table.print(data)
	end
end

local function Assemble(func, validate)
	local str = {}
	local size = 0
	setfenv(func, setmetatable({}, {__index = function(s, key)
		if map[key] then
			return function(...)
				local bin, info = run(key, ...)
				table.insert(str, bin)
				size = size + #bin
				if validate then
					GAS(info)
				end
			end
		end

		if type_translate[key] then
			return function(num) return ffi.new(type_translate[key], num) end
		end

		if x86_64.RegLookup[key] then
			return r[key]
		end

		if key == "pos" then
			return function() return size end
		end

		return _G[key]
	end}))()

	if #str == 0 then
		return nil, "nothing to assemble"
	end
	str = table.concat(str)

	local mem = ffi.C.mmap(nil, #str, bit.bor(PROT_READ, PROT_WRITE, PROT_EXEC), bit.bor(MAP_PRIVATE, MAP_ANONYMOUS), -1, 0)

	ffi.copy(mem, str)

    if mem == nil then
        return nil, "failed to map memory"
	end

	return mem, #str
end

local mcode, len = Assemble(function()
	local msg = "hello world!\n"

	local STDOUT_FILENO = 1
	local WRITE = 1

	mov(r12, rdi)

	local loop = pos()
		mov(rax, WRITE)
		mov(rdi, STDOUT_FILENO)
		mov(rsi, msg)
		mov(rdx, #msg)
		syscall()
		inc(r12)
	cmp(r12, 10)

	jne(loop - pos())
	mov(rax, r12)
	ret()
end)

print(ffi.cast("uint64_t (*)(uint64_t)", mcode)(0))

do return end

asm2.GASToTable([[

.text                           # section declaration

# we must export the entry point to the ELF linker or
.global _start              # loader. They conventionally recognize _start as their
# entry point. Use ld -e foo to override the default.

_start:

# write our string to stdout

mov $0, %rcx

mov    $4,%rax             # system call number (sys_write)
mov    $1,%rdi             # first argument: file handle (stdout)
mov    $len,%rdx           # third argument: message length
mov    $msg,%rsi           # second argument: pointer to message to write
syscall               		# call kernel

inc %rcx
cmp $10, %rcx
jne -42

# and exit

mov    $1,%rax             # system call number (sys_exit)
mov    $0,%rdi             # first argument: exit code
syscall						# call kernel

.data                           # section declaration

msg:
.ascii    "Hello, world!\n"   # our dear string
len = . - msg                 # length of our dear string
]], nil, true)
