do
	function Foo()
		local tbl = {}

		tbl.bar = 5

		function tbl:foo(a)
			return self.bar + 1
		end

		return tbl
	end
end

-------------------
do
	local meta = {}

	function meta:__index(key)
		return meta[key]
	end

	function meta:foo(a)
		return self.bar + 1
	end

	function foo()
		local tbl = {}
		tbl.bar = 5

		setmetatable(tbl, meta)

		return tbl
	end
end

local obj = foo()
print(obj:foo(1))