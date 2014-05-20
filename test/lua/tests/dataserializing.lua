local von = require("von")

local lol = {
    1, -1337, -99.99, 2, 3, 100, 101, 121, 143, 144, "ma\"ra", "are", "mere",
    {
        500,600,700,800,900,9001,
        TROLOLOLOLOLOOOO = 666,
        [true] = false,
        [false] = "lol?",
        pere = true,
        [1997] = "vasile",
        [{ [true] = false, [false] = true }] = { [true] = "true", ["false"] = false }
    },
    true, false, false, true, false, true, true, false, true,
    [1337] = 1338,
    mara = "are",
    mere = false,
    [true] = false,
    [{ [true] = false, [false] = true }] = { [true] = "true", ["false"] = false }
}

local data = {}

for i = 1, 100000 do 
	table.insert(data, lol)
end  

local function test(func, name)
	local start = timer.clock()
	func(data)
	logf("%s spent %s seconds to serialize\n", name, timer.clock() - start)
end

test(von.serialize, "von")
test(luadata.Encode, "luadata")
test(msgpack.Encode, "msgpack")


