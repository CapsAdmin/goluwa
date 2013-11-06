local function test1()
	local bar = 0

	local function foo()
		bar = bar + 1
	end

	local start = glfw.GetTime()

	for i = 1, 100000000 do
		foo()
	end

	return glfw.GetTime() - start
end

logf("test1 took %s ms with jit ON", test1())

jit.off(test1) 
jit.flush(test1)

logf("test1 took %s ms with jit OFF", test1())  