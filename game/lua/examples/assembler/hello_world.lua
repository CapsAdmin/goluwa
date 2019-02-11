local obj = asm.CreateAssembler(32)

local STDOUT = 1
local WRITE = 1

local msg = "hello world!\n"

local address = asm.ObjectToAddress(msg)

obj:MoveImmReg(WRITE, "rax") -- write
obj:MoveImmReg(STDOUT, "rdi") -- stdout
obj:MoveImmReg(address, "rsi") -- message address
obj:MoveImmReg(#msg, "rdx") -- length
obj:Syscall()
obj:Return()

local func = obj:GetFunctionPointer("uint64_t (*)(uint64_t)")

func(0)