local function junction(c_left,c_right)
	local v_sorted = {}

	local left,right = 1,1
	while (left <= #c_left and right <= #c_right) do
		if c_left[left] <= c_right[right] then
		
			table.insert(v_sorted,c_left[left])
			left=left+1
			
		else
		
			table.insert(v_sorted,c_right[right])
			right=right+1

		end
	end

	while (left <= #c_left) do
	
		table.insert(v_sorted,c_left[left])
		left=left+1
	end

	while (right <= #c_right) do
	

		table.insert(v_sorted,c_right[right])
		right=right+1
	end
	return v_sorted
end

local function merge_sort(elements)

	if #elements <= 2 then
		return elements
	end

	local v_half = math.ceil(#elements / 2)

	local v_left = {}
	local v_right  = {}

	for i = 1, v_half-1 do
	
		table.insert(v_left,elements[i])
	end

	for i = v_half, #elements do
	
		table.insert(v_right,elements[i])

	end

	return junction(merge_sort(v_left), merge_sort(v_right))
end

local sizes = {1000,8000,40000,110000}

do
	for _, size in ipairs(sizes) do
		local elements = {}
		
		for i = 1, size do
			elements[i] = math.random(i, i + 32)
		end
		
		logf("Sorting %i items", size)
		local time = glfw.GetTime()
		merge_sort(elements)
		
		logf("Time: %f", glfw.GetTime() - time)
	end
end