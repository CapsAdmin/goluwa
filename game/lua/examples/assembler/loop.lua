-- some constants
local STDOUT = 1
local WRITE = 1
local msg = "hello world!\n"
local msg_address = asm.ObjectToAddress(msg)

-- this code is essentially:
--[[
    local r12 = 0
    ::loop_pos::
        io.write("hello world\n")

        r12 = r12 + 1

        local res = r12 == 10
        if not res then
            goto loop_pos
        end
]]

-- create memory of 256 bytes in size
local obj = asm.CreateAssembler(256)

-- use the r12 register as our i counter
obj:MoveConst64Reg64(0, "r12")

-- ::loop_pos::
local loop_pos = obj:GetPosition()

    -- syscall(WRITE, STDOUT, msg_adress, #msg)
    obj:MoveConst64Reg64(WRITE, "rax") -- write
    obj:MoveConst64Reg64(STDOUT, "rdi") -- stdout
    obj:MoveConst64Reg64(msg_address, "rsi") -- message address
    obj:MoveConst64Reg64(#msg, "rdx") -- length
    obj:Syscall()

    -- i = i + 1
    obj:IncreaseReg64("r12")

-- local res = 10 == r12
obj:CompareConst8Reg64(10, "r12")

-- if not res then goto loop_pos end
obj:JumpNotEqualConst8(loop_pos)

-- return, otherwise we get a segfault
obj:Return()

-- get the funciton that we built and run it
local func = obj:GetFunctionPointer()
func()