local test = _G.test or {}
test.failed = false

function test.fail(what, reason)
	if not test.failed then logn(" - FAIL") end

	if reason:find("\n", nil, true) then
		reason = "\n" .. reason
		reason = string.indent(reason, 1)
	end

	logf("%s: %s\n", what, reason)
	test.failed = true
end

function test.start(what)
	if not what then
		local info = debug.getinfo(2)
		table.print(info)
	end

	log("testing ", what)
	test.failed = false
end

function test.stop()
	if test.failed then  else logn(" - OK") end
end

function test.test(func, ...)
	local ret = list.pack(pcall(func, ...))

	if not ret[1] then
		test.fail(debug.get_name(func), ret[2])
		return
	end

	ret = list.pack(unpack(ret, 2))
	return {
		expect = function(...)
			local exp = list.pack(...)
			local msg = ""

			for i = 1, exp.n do
				if ret[i] ~= exp[i] then
					msg = msg .. i .. ": expected " .. tostring(ret[i]) .. " got " .. tostring(exp[i]) .. "\n"
				end
			end

			if msg ~= "" then test.fail(debug.get_name(func), msg) end
		end,
		expect_compare = function(...)
			local exp = list.pack(...)
			local msg = ""

			for i = 1, exp.n do
				local b = ret[i] == exp[i]

				if type(exp[i]) == "function" then b = exp[i](ret[i]) end

				if not b then
					msg = msg .. i .. ": expected " .. tostring(ret[i]) .. " got " .. tostring(exp[i]) .. "\n"
				end
			end

			if msg ~= "" then test.fail(debug.get_name(func), msg) end
		end,
	}
end

do
	local meta = {}
	meta.__index = meta

	function meta:fail(what, reason)
		test.fail(what, reason)
	end

	function meta:expect(what, a, b)
		if a ~= b then
			self:fail(what, "expected " .. a .. " got " .. b)
		else
			self.expect_count = self.expect_count - 1
			print(self.expect_count)
		end

		if self.expect_count <= 0 then self.fail = function() end end
	end

	function test.create()
		return setmetatable({expect_count = 1}, meta)
	end
end

setmetatable(test, {
	__call = function(_, ...)
		return test.test(...)
	end,
})
return test