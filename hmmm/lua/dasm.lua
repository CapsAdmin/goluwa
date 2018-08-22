
local ffi =  require("ffi")
local dasm = require'dasm'

local actions = ffi.new('const uint8_t[19]', {254,0,102,184,5,0,254,1,102,187,3,0,254,2,102,187,3,0,255})
local Dst, globals = dasm.new(actions, nil, 3)
--|.code
dasm.put(Dst, 0)
--| mov ax, 5
--|.sub1
dasm.put(Dst, 2)
--| mov bx, 3
--|.sub2
dasm.put(Dst, 8)
--| mov bx, 3
dasm.put(Dst, 14)
local addr, size = Dst:build()
dasm.dump(addr, size)