local obj = asm.CreateAssembler(32)

obj:MoveConst32Reg64(60, asm.r.rax)
obj:MoveConst32Reg64(0, asm.r.rdi)
obj:Syscall()

obj:GetFunctionPointer()(0)