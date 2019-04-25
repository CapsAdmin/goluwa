profiler.MeasureFunction(function()
	local m = Matrix44()
	for i = 1, 1000 do
		m:Translate(math.random()*2-1, math.random()*2-1, math.random()*2-1)
	end
end, 10000, "translate")

profiler.MeasureFunction(function()
	local m = Matrix44()
	for i = 1, 1000 do
		m:Rotate((math.random()*2-1) * math.pi*2, math.random()*2-1, math.random()*2-1, math.random()*2-1)
	end
end, 10000, "rotate")