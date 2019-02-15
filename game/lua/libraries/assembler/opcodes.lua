local asm = {}
local ffi = require("ffi")

local map = {}
local keyval = {}
local opcodes = {}

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
	for i, reg in ipairs(x86_64["Reg" .. bit]) do
		local info = {}

		info.bits = bit

		if i >= 8 then
			info.extra = true
		end

		info.index = (i - 1)%7

		x86_64.RegLookup[reg] = info
	end
end

--asm.mov(reg32|m32, int32_t|uint32_t) -- W:r32/m32, id/ud | MI | C7 /0 id
-- movw IMM_0x1 0xdeadbee       : 66 c7 04 25  ee db ea 0d  01 00
-- movw IMM_0x1 0xdeadbee(eax)  : 67 66 c7 80  ee db ea 0d  01 00
--asm.PrintGAS("mov %eax, 0xfff(%ecx, %eax)", format_func)

-- table means register

function asm.REX(W, op1, op2)
	local R = op1 and op1.reg

	local X = op2 and op2.index and op2.index
	local B = op2 and op2.reg

	local rex = REX_PATTERN

	if W or op1.reg.bits == "64" then
		rex = bit.bor(rex, REX.W)
	end

	if R and R.extra then
		rex = bit.bor(rex, REX.R)
	end

	if B and B.extra then
		base = base - 8
		rex = bit.bor(rex, REX.B)
	end

	if X and X.extra then
		index = index - 8
		rex = bit.bor(rex, REX.X)
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
	local reg = op1.reg.index

	local index
	local base
	local displacement
	local scale

	if type(op2) == "number" then
		base = op2
	else
		index = op2.index and op2.index.index
		base = op2.reg.index

		displacement = op2.disp
		scale = op2.scale
	end

	-- build modrm byte
	if reg and base then

		-- 00 000 000
		modrm = 0

		-- 00 src 000 - place
		modrm = bit.bor(modrm, bit.lshift(reg, 3))


		if displacement then
			if displacement_size == 1 then
				-- 10 src 000
				modrm = bit.bor(modrm, 0b01000000)
			elseif displacement_size == 4 then
				modrm = bit.bor(modrm, 0b10000000)
			else
				error("invalid displacement size " .. displacement_size)
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
			modrm = bit.bor(modrm, base)
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
	end

	if type(int) == "number" then
		int = ffi.new(t, int)
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

local SWAP_ARGS = false
local SWAP_STRB = SWAP_ARGS and "op1, op2" or "op2, op1"
local SWAP_STRA = SWAP_ARGS and "op2, op1" or "op1, op2"

local function parse_db(db)
-- /r = modrm + sib and displacement
	-- /0 = modrm only

	-- +r = preceeding byte + 0-7


	local function parse_instruction(name, operands, encoding, opcode, metadata, operands2)
		--print(" ")
		--print(name, table.concat(operands, ", "), operands2, encoding, table.concat(opcode, " "), metadata)

		local arg_line = {}
		for i, v in ipairs(operands) do
			v = type_translate2[v] or v
			operands[i] = v
			arg_line[i] =  "op" .. i
		end
		arg_line = table.concat(arg_line, ", ")

		local lua = "local e = ...\nreturn function("..arg_line..")"

		local instr = {}


		if opcode[1] == "REX.W" then
			table.insert(instr, "e.REX(true)")
		elseif false then
			local W = opcode[1] == (arg_line:find("r64") or arg_line:find("m64")) and "true, " or ""

			if encoding:startswith("MR") then
				table.insert(instr, "e.REX("..W..SWAP_STRA .. ")")
			elseif encoding:startswith("RM") then
				table.insert(instr, "e.REX("..W..SWAP_STRb .. ")")
			elseif encoding:startswith("M") then
				table.insert(instr, "e.REX("..W.."op1)")
			end
		end

		for _, byte in ipairs(opcode) do
			if tonumber(byte, 16) then
				table.insert(instr, "\"\\x"..byte.."\"")
			elseif byte == "/r" then
				if encoding:startswith("MR") then
					table.insert(instr, "e.MODRM("..SWAP_STRA..")")
				else
					table.insert(instr, "e.MODRM("..SWAP_STRB..")")
				end
			elseif byte:startswith("/") and tonumber(byte:sub(2,2)) then
				table.insert(instr, "e.MODRM(op1, "..byte:sub(2,2)..")")
			elseif byte:endswith("+r") then
				table.insert(instr, "string.char(0x"..byte:sub(1, 2).." + op1.reg.index)")
			elseif type_translate[byte] then
				table.insert(instr, "e.INT2BYTES(\""..type_translate[byte].."\", op1)")
			end
		end

		lua = lua .. "\n\treturn\n\t\t" .. table.concat(instr, "..\n\t\t")
		lua = lua:gsub("\"%s*%.%.%s*\"", "")
		lua = lua .."\nend"

		map[name] = map[name] or {}
		map[name][table.concat(operands, ",")] = loadstring(lua)(asm)

		lua = table.concat({"--", name, table.concat(operands, ","), operands2, encoding, table.concat(opcode, " "), metadata}, " | ") .. "\n" .. lua
		map[name][table.concat(operands, ",").."LUA"] = lua
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
			str = str .. "i?"
		elseif type(arg) == "cdata" then
			for k,v in pairs(type_translate) do
				if ffi.istype(v, arg) then
					str = str .. k
					break
				end
			end
		elseif type(arg) == "string" then
			str = str .. "i?"
		else
			str = str .. type(arg)
		end

		if i ~= max then
			str = str .. ","
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

	if str:find("?", nil, true) then
		for _, bits in ipairs({"32", "16", "8"}) do
			local test = str:replace("?", bits)
			if map[func][test] then
				str = test
				break
			end
		end
	end

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
	return map[func][str](...)
end

local format_func = function(str)
	return str:binformat(16, " ", true)
end


local REG
local reg_meta = {}
reg_meta.__index = reg_meta
function reg_meta:__tostring()
	if self.disp or self.index_name or self.scale then
		return string.format("%s(%s, %s, %s)", self.disp or "", self.name, self.index_name or "", self.scale or "")
	end
	return self.name
end

function reg_meta.__add(l, r)
	if getmetatable(r) == reg_meta then
		return REG(l.name, r.name, r.disp, r.scale)
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

function REG(name, index_name, disp, scale)
	return setmetatable({
		reg = x86_64.RegLookup[name],
		index = index_name and x86_64.RegLookup[index_name],

		name = name,
		index_name = index_name,

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

local META = {}
META.__index = META

local function Assemble(func)
	local str = {}
	setfenv(func, setmetatable({}, {__index = function(s, key)
		if map[key] then
			return function(...)
				local bin = run(key, ...)
				table.insert(str, bin)
			end
		end
		if x86_64.RegLookup[key] then
			return r[key]
		end

		return _G
	end}))()

	--[[local mem = ffi.C.mmap(ffi.cast("void *", table.concat(str)), #str, bit.bor(PROT_READ, PROT_WRITE, PROT_EXEC), bit.bor(MAP_PRIVATE, MAP_ANONYMOUS), -1, 0)
    if mem == nil then
        return nil, "failed to map memory"
	end
]]
	return table.concat(str)
end

local mcode = Assemble(function()
	local msg = "hello"

	mov(rax, 4)   	-- 'write' system call = 4
	mov(rbx, 1)   	-- file descriptor 1 = STDOUT
	mov(rcx, msg) 	-- string to write
	mov(rdx, #msg)	-- length of string to write
	int(0x80)    	-- call the kernel

	ret()
end)
print(mcode:binformat())
--ffi.cast("void (*)()", mcode)()

--asm.PrintGAS("mov %rax, -0x20(%rbx, %rcx, 4)", format_func)
--asm.PrintGAS("jmp 10(%rax)", format_func)

-- FIX MOD RM