local function test2(i)
	return 0.5/i
end

local function test()
	local lol = 5 + 5

	for i = 1, 3 do
		lol = lol + test2(i)
	end
	return lol
end

local function main()
	for i = 1, 3 do test() end
end

S""
for i = 1, 1000000 do
main()
end
S""
