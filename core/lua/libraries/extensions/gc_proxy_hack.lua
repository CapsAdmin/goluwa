local rawset = rawset
local rawget = rawget
local getmetatable = getmetatable
local newproxy = newproxy

if pcall(require, "table.gcnew") then
	local function gc(s)
		local tbl = s.tbl
		rawset(tbl, "__gc_proxy", nil)
		local new_meta = getmetatable(tbl)

		if new_meta then
			local __gc = rawget(new_meta, "__gc")

			if __gc then __gc(tbl) end
		end
	end

	-- 52 compat
	function setmetatable(tbl, meta)
		if meta and rawget(meta, "__gc") and not rawget(tbl, "__gc_proxy") then
			local proxy = _OLD_G.setmetatable(table.gcnew(), {__gc = gc})
			proxy.tbl = tbl
			rawset(tbl, "__gc_proxy", proxy)
		end

		return _OLD_G.setmetatable(tbl, meta)
	end
else
	local function gc(s)
		local tbl = getmetatable(s).__div
		rawset(tbl, "__gc_proxy", nil)
		local new_meta = getmetatable(tbl)

		if new_meta then
			local __gc = rawget(new_meta, "__gc")

			if __gc then __gc(tbl) end
		end
	end

	-- 52 compat
	function setmetatable(tbl, meta)
		if meta and rawget(meta, "__gc") and not rawget(tbl, "__gc_proxy") then
			local proxy = newproxy(true)
			rawset(tbl, "__gc_proxy", proxy)
			getmetatable(proxy).__div = tbl
			getmetatable(proxy).__gc = gc
		end

		return _OLD_G.setmetatable(tbl, meta)
	end
end