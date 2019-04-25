local obj = asm.CreateAssembler(32)

obj:MoveImmReg(60, asm.r.rax, "32", "64")
obj:MoveImmReg(0, asm.r.rdi, "32", "64")
obj:Syscall()

obj:GetFunctionPointer()(0)