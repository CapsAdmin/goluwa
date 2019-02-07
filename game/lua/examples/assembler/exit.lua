local obj = asm.CreateAssembler(32)

obj:MoveConst32Reg64(60, "rax")
obj:MoveConst32Reg64(0, "rdi")
obj:Syscall()

obj:GetFunctionPointer()()