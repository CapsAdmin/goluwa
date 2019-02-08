local obj = asm.CreateAssembler(32)

local STDOUT = 1
local WRITE = 1

local msg = "hello world!\n"

local address = asm.ObjectToAddress(msg)

obj:MoveConst64Reg64(WRITE, asm.r.rax) -- write
obj:MoveConst64Reg64(STDOUT, asm.r.rdi) -- stdout
obj:MoveConst64Reg64(address, asm.r.rsi) -- message address
obj:MoveConst64Reg64(#msg, asm.r.rdx) -- length
obj:Syscall()
obj:Return()

local func = obj:GetFunctionPointer()

func(0)