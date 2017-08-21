do
	local META = prototype.CreateTemplate("foo", "C")

	function META:Something()
		print("hello from C")
	end

	META:Register()
end

do
	local META = prototype.CreateTemplate("foo", "B")
	META.Base = "C"

	function META:Something()
		META.BaseClass.Something(self)
		print("hello from B")
	end

	META:Register()
end

do
	local META = prototype.CreateTemplate("foo", "A")
	META.Base = "B"

	function META:Something()
		print("hello from A")
		META.BaseClass.Something(self)
	end

	META:Register()

	TEST = function() return META:CreateObject() end
end

local obj = TEST()
obj:Something() -- stack overflow