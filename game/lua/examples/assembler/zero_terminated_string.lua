-- some constants
local STDOUT = 1
local WRITE = 1
local msg = "hello world!\n"
local msg_address = asm.ObjectToAddress(msg)

local obj = asm.CreateAssembler(256)

obj:MoveConst32Reg64(0, "rdx")
obj:MoveConst32Reg64(msg_address, "rsi")

local loop_pos = obj:GetPosition()
    obj:IncreaseReg64("rsi")
    obj:IncreaseReg64("rdx")
    obj:CompareConst8Reg64(0, "rsi")
obj:JumpNotEqualConst8(loop_pos)

obj:SubtractReg64Reg64("rdx", "rsi")

-- syscall(WRITE, STDOUT, msg_adress, #msg)
obj:MoveConst64Reg64(WRITE, "rax") -- write
obj:MoveConst64Reg64(STDOUT, "rdi") -- stdout
obj:Syscall()

obj:Return()

local func = obj:GetFunctionPointer()
local count = func(0)