local test = {}
for i = 1, 10000 do
	test[i] = math.random()
end

local ipairs = ipairs

LOOM""

profiler.MeasureFunctions(
	{
		["ipairs"] = function()
			local lol = 0
			for i, v in ipairs(test) do
				lol = lol + v
			end
		end,
		["while i < #test"] = function()
			local lol = 0
			local i = 1
			while i < #test do
				lol = lol + test[i]
				i = i + 1
			end
		end,
		["while i < max"] = function()
			local lol = 0
			local i = 1
			local max = #test
			while i < max do
				lol = lol + test[i]
				i = i + 1
			end
		end,
		["repeat until i == max"] = function()
			local lol = 0
			local i = 1
			local max = #test
			repeat
				lol = lol + test[i]
				i = i + 1
			until i == max
		end,
		["for i = 1, #test do"] = function()
			local lol = 0
			for i = 1, #test do
				local v = test[i]
				lol = lol + v
			end
		end,
		["for i = 1, 10000 do"] = function()
			local lol = 0
			for i = 1, 10000 do
				local v = test[i]
				lol = lol + v
			end
		end,
		["for i = 1, 10000 do 2"] = function()
			local lol = 0
			for i = 1, 10000 do
				lol = lol + test[i]
			end
		end,
	},
	100000
)

LOOM""