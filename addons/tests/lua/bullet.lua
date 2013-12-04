local str = vfs.Read("bin/bullet_src/src/bullet_cffi_swig.cpp")
local objects = {}
local header = {}


for def in str:gmatch("EXPORT (.-) {") do
	if def:find("_wrap_new_") then
		local name = def:match("(.-) %*")
		table.insert(objects, ("typedef struct {} %s;"):format(name))
	end
	table.insert(header, def)
end

vfs.Write("bullet_cdef.lua", table.concat(objects, "\n") .. table.concat(header, ";\n"))

