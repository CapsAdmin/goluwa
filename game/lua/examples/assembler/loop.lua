-- some constants
local STDOUT = 1
local WRITE = 1
local msg = "hello world!\n"
local msg_address = asm.ObjectToAddress(msg)

-- this code is essentially:
--[[
    local r12 = ...
    ::loop_pos::
        io.write("hello world\n")

        r12 = r12 + 1

        local res = r12 == 10
        if not res then
            goto loop_pos
        end
    return r12
]]

-- create memory of 256 bytes in size
local obj = asm.CreateAssembler(256)

-- use the r12 register as our i counter
-- also move rdi to r12
obj:MoveReg64Reg64(asm.r.rdi, asm.r.r12)

-- ::loop_pos::
local loop_pos = obj:GetPosition()

    -- syscall(WRITE, STDOUT, msg_adress, #msg)
    obj:MoveImmReg(WRITE, "rax") -- write
    obj:MoveImmReg(STDOUT, "rdi") -- stdout
    obj:MoveImmReg(msg_address, "rsi") -- message address
    obj:MoveImmReg(#msg, "rdx") -- length
    obj:Syscall()

    -- i = i + 1
    obj:IncrementReg64(asm.r.r12)

-- local res = 10 == r12
obj:CompareImm8Reg64(10, asm.r.r12)

-- if not res then goto loop_pos end
obj:JumpNotEqualImm8(loop_pos)

-- move r12 into rax so that we can retrieve the value from lua
obj:MoveReg64Reg64(asm.r.r12, asm.r.rax)

-- return, otherwise we get a segfault
obj:Return()

-- get the funciton that we built and run it
local func = obj:GetFunctionPointer()
local count = func()