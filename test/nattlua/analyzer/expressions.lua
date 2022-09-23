local T = require("test.helpers")
local analyze = T.RunCode
analyze[[
    local function foo(x: {foo = boolean | nil}) 
        if x.foo and attest.equal(x.foo, true) then end
        attest.equal(x.foo, _ as boolean | nil)
    end
]]
analyze[[
    local a: number | string
    
    if type(a) == "number" then
        attest.equal(a, _ as number)
    end

    attest.equal(a, _ as number | string)
]]
analyze[[
    local x = _ as false | 1
    local y = not x and attest.equal(x, false) or attest.equal(x, 1)
]]
analyze[[
    local x = _ as 1 | 2
    local y = x == 1 and attest.equal(x, 1) or attest.equal(x, 2)
    attest.equal(x, _ as 1 | 2)
]]
analyze[[
    local x = _ as 1|2|3
    local y = x == 1 and attest.equal(x, 1) or x == 2 and attest.equal(x, 2) or false
    attest.equal(y, _ as 1|2|false)
]]
analyze[[
    local x = _ as 1|2|3

    if x == 1 or attest.equal(x, _ as 2|3) then

    end
]]
analyze[[
    local x: 1 | "str"
    if x ~= 1 or attest.equal(x, 1) then
    
    end
]]
analyze[[
    local x: 1 | "str"
    if x == 1 or attest.equal(x, "str") then
    
    end
]]
analyze[[
    local a = true
    local result = not a or 1
    attest.equal(result, 1)
]]
analyze[[
    local a = function(arg: ref any) 
        attest.equal(arg, 1)
        return 1337
    end
    
    local b = a(1) or a(2)
    attest.equal(b, 1337)
]]
analyze[[
    local a: 1, b: 2
    local result = a and b


    attest.equal(result, 2)
]]
analyze[[
    local x = _ as number
    if not x then return false end
    local x = true and attest.equal(x, _ as number)
]]
analyze[[
    local a: 1 | 2 | 3
    if a == 1 or a == 3 then
        attest.equal(a, _ as 1 | 3)
    end
]]
analyze[[
    local a: 1 | 2 | 3 | nil
    local b: true | nil
    if (a == 1 or a == 3) and b then
        attest.equal(a, _ as 1 | 3)
        attest.equal(b, true)
    end
]]
analyze[[
    local c: {foo = true } | nil

    if c and c.foo then
        attest.equal(c.foo, true)
    end
]]
analyze[[
    local tbl = {} as {foo = nil | {bar = 1337 | false}}

    if tbl.foo and tbl.foo.bar then
        attest.equal(tbl.foo.bar, 1337)
    end
]]
analyze[[
    -- make sure table key values clear affected upvalues

    local buff: {x = number, y = number} | {x = number, y = string}
    
    local x = {
        bar = buff.y,
        foo = bit.band(buff.x, 1) ~= 0 and "directory" or "file" 
    }
]]
analyze[[
    local tbl = {} as {foo = nil | {bar = 1337 | false}}

    if tbl.foo and attest.equal(tbl.foo.bar, _ as 1337 | false) then
        attest.equal(tbl.foo.bar, 1337)
    end
]]
analyze[[
    local a: nil | 1

    if a or true and a or false then
        attest.equal(a, _ as 1)
    end

    attest.equal(a, _ as 1 | nil)
]]
analyze[[
    local x: 1 | 2 | 3
    if x == 1 or x == 2 then
        attest.equal(x, _ as 1 | 2)
    else
        attest.equal(x, _ as 3)
    end
]]
analyze[[
    local x: {foo = nil | 1}

    if not x.foo then return end
    attest.equal(x.foo, _ as 1)
]]
analyze[[
    local x: {foo = nil | 1}

    if x.foo == nil then return end
    attest.equal(x.foo, 1)
]]
analyze[[
    local x: {foo = nil | 1}

    if x.foo ~= nil then return end
    attest.equal(x.foo, nil)
]]
analyze[[
    local x: {foo = 1 | 2 | 3}

    if x.foo == 1 or x.foo == 2 then
        attest.equal(x.foo, _ as 1 | 2)
    end
]]
analyze[[
    local x: 1 | 2 | 3 | 4 | 5 | 6 | 7

    if x == 1 or x == 2 then
        attest.equal(x, _ as 1 | 2)
    elseif x == 3 or x == 4 then
        attest.equal(x, _ as 3 | 4)
    else
        attest.equal(x, _ as 5 | 6 | 7)
    end
]]
analyze[[
    local x: {y = 1 | 2 | 3 | 4 | 5 | 6 | 7}

    if x.y == 1 or x.y == 2 then
        attest.equal(x.y, _ as 1 | 2)
    elseif x.y == 3 or x.y == 4 then
        attest.equal(x.y, _ as 3 | 4)
    else
        attest.equal(x.y, _ as 5 | 6 | 7)
    end
]]
analyze[[
    local function foo(s: ref any)
        attest.equal(s, _ as string)
        return s
    end

    local function get_address_info(data: {socket_type = string | nil})
        attest.equal(data.socket_type, _ as string | nil)

        if data.socket_type then
            attest.equal(data.socket_type, _ as string)
        end

        local hints = {
            ai_socktype = data.socket_type and foo(data.socket_type) or nil,
        }

        attest.equal(hints.ai_socktype, _ as string | nil)
    end

    local info = {socket_type = "stream"}

    get_address_info(info)
]]
analyze[[
    local x: {foo = nil | true}

    if x.foo == nil then
    return
    end

    attest.equal(x.foo, true)
]]
analyze[[
    local x: {foo = nil | true}

    if x.foo ~= nil then
        return
    end

    attest.equal(x.foo, nil)
]]
analyze[[
    local x: {foo = nil | true}

    if not x.foo then
    return
    end

    attest.equal(x.foo, true)
]]
analyze[[
    local x: {foo = nil | true}

    if x.foo then
        return
    end

    attest.equal(x.foo, nil)
]]
analyze[[
    local args: List<|string | List<|string|>|>

    local x =_ as number

    if type(args[x]) == "string" then
        attest.equal(args[x], _ as string)
    else
        attest.equal(args[x], _ as nil | {[number | nil] = string})
    end
]]
pending[[
    local a: nil | number
    local b: nil | number

    if a ~= nil and b == nil then 
        attest.equal(a, _ as number)
        attest.equal(b, _ as nil)
    else 
        attest.equal(a, _ as number | nil)
        attest.equal(b, _ as number | nil)
    end
]]
pending[[
    local type A = {Type = "human"}
    local type B = {Type = "cat"}

    local x: A | B

    -- x.Type becomes a union of A.Type and B.Type
    -- 

    if x.Type == "human" then
    print("x.Type:" , x.Type)
    print(x)
    end
]]
analyze[[
    local level = _ as 1 | 2
    local info = level == 1 and (level + 10) or level
    attest.equal(info, _ as 11|2)
]]