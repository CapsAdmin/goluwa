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

function META:WriteData(data, ...)
    if type(data) == "string" then
        ffi.copy(self.Memory + self.Position, data, #data)
        self:Advance(#data)
    elseif type(data) == "cdata" then
        local size = ffi.sizeof(data)
        ffi.copy(self.Memory + self.Position, data, size)
        self:Advance(size)
    elseif type(data) == "number" then
        self:WriteData(string.char(data, ...))
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

function META:GetFunctionPointer(type)
    return ffi.cast(type or "void (*)()", self.Memory)
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
    print(self:GetString():hexformat(32))
end

function asm.ObjectToAddress(str)
    return assert(loadstring("return " .. tostring(ffi.cast("void *", str)):match(": (0x.+)") .. "ULL"))()
end

asm.asm_meta = META

local old = _G.RELOAD
_G.RELOAD = nil
runfile("x86_64.lua", asm, META)
runfile("gas.lua", asm)
_G.RELOAD = old

if RELOAD then
    _G.asm = asm

    runfile("test.lua")
end

return asm