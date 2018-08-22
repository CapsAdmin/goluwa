
-- DynASM x86 loader module.

--unload dasm_x86x64 if it's already loaded.
if not package then package = {loaded = {}} end --for compat. with minilua
package.loaded.dasm_x86x64 = nil
dasm_x64 = false -- Using a global is an ugly, but effective solution.
local dasm = require'dasm_x86x64'
dasm_x64 = nil
package.loaded.dasm_x86x64 = true
return dasm
