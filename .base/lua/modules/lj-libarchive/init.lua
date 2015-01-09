local header = require("lj-libarchive.header")
local enums = require("lj-libarchive.enums")

local lib = ffi.load("archive")

ffi.cdef(header)  

header = header:gsub("%s+", " ")
header = header:gsub(";", "%1\n")

local libarchive = {lib = lib, e = enums}

for line in header:gmatch("(.-)\n") do
	if not line:find("typedef") then
		local func = line:match("(archive_%S-)%(")
		if func then
			local friendly = func:match("archive_(.+)")
			local ok, err = pcall(function() libarchive[friendly] = lib[func] end)
			if not ok then
				print(err)
			end
		end
	end
end 

return libarchive