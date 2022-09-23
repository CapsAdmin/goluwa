local function promise(func)
	return func
end

local function await(func, ...)
	assert(coroutine.running())
	local ret = nil

	func(function(...)
		ret = {...}
	end)

	while ret == nil do
		tasks.Wait()
	end

	return unpack(ret)
end

foo = promise(function(resolve, ...)
	return (
		function(someval)
			local val = nil

			timer.Delay(5, function()
				resolve(someval)
			end)
		end
	)(...)
end)
tasks.enabled = true

tasks.CreateTask(function()
	local val = await(foo, 5)
end)