local obj = asm.CreateAssembler(32)

local STDOUT = 1
local WRITE = 1

local msg = "hello world!\n"

local address = asm.ObjectToAddress(msg)

obj:MoveConst64Reg64(WRITE, "rax") -- write
obj:MoveConst64Reg64(STDOUT, "rdi") -- stdout
obj:MoveConst64Reg64(address, "rsi") -- message address
obj:MoveConst64Reg64(#msg, "rdx") -- length
obj:Syscall()
obj:Return()

local func = obj:GetFunctionPointer()

func()