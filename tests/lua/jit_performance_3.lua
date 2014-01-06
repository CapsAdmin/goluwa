local function test1()
	local bar = 0

	local function foo()
		bar = bar + 1
	end

	local start = timer.clock()

	local foo = {}
	
	for i = 1, 10000000 do
		foo[#foo+1] = math.random()
	end
	
	local bar = 0
	for k,v in ipairs(foo) do
		bar = bar + v
	end    
	
	print(bar)
		
	return timer.clock() - start
end

jit.on(test1) 
jit.flush(test1)

logf("took %s seconds with jit ON", test1())

jit.off(test1) 
jit.flush(test1)

logf("took %s seconds with jit OFF", test1())       