local function bubble_sort(elements, size)
	local temp = 0
	local checks = 0
	
	for i = 0, size - 1  do
		for  order = 0, size - 1 do
			if elements[order] > elements[order + 1] then
				temp = elements[order + 1]
				elements[order + 1] = elements[order]
				elements[order] = temp
			end
		end
		checks = checks + 1
	end
end

local sizes = {1000,8000,40000,110000}

do
	for _, size in ipairs(sizes) do
		local elements = ffi.new("int[?]", size)
		
		for i = 0, size do
			elements[i] = math.random(i, i + 32)
		end
		
		logf("Sorting %i items", size)
		local time = glfw.GetTime()
		bubble_sort(elements, size)
		logf("Time: %f", glfw.GetTime() - time)
	end
end