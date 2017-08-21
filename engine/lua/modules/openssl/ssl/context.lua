local ctx = require"_openssl.ssl.context"

local pack = table.pack or function(...) return { n = select("#", ...); ... } end

-- Allow passing a vararg of ciphers, or an array
local setCipherList; setCipherList = ctx.interpose("setCipherList", function (self, ciphers, ...)
	if (...) then
		local ciphers_t = pack(ciphers, ...)
		ciphers = table.concat(ciphers_t, ":", 1, ciphers_t.n)
	elseif type(ciphers) == "table" then
		ciphers = table.concat(ciphers, ":")
	end
	return setCipherList(self, ciphers)
end)

return ctx
