local strung = require"strung"
local s_gsub = string.gsub
-- [[]] local v = require"jit.v"
-- [[]] v.on("-")

bench = arg[1] == "bench"

--- First, the test and benchmark infrastructure.
--- `try` and `gmtry` run both the original and strung version of the functions, 
--- and compare either their ouput, or their speed if "bench" is passed as a 
--- parameter to the script.

local ttstr = require"util".val_to_string
local BASE = 10000
local iter, try, gmtry

local acc, _acc = {string = {}, strung = {}}
local function dumpacc()
     _acc, acc = acc, {string = {}, strung = {}}
    return _acc
end
if bench then 
    function try(f, a, s, d, g, h)
        -- jit.off() jit.on()
        tstring, tstrung = {}, {}
        local ri, Ros
        -- print(("-_"):rep(30))
        -- print("Test: ", )
        for i = 1, 1 do
            local tic = os.clock()
            for i = 1, II do
                ri = {string[f](a, s, d, g, h)}
            end
            tstring[i] = os.clock() - tic

            local tic = os.clock()
            for i = 1, II do
                Ro = {strung[f](a, s, d, g, h)}
            end
            tstrung[i] = os.clock() - tic
        end
        a = s_gsub(a, "[%z\1-\31\127-\255\\\"]", ""):sub(1,60)
        if type(d) == "table" or type(d) == "function" then
            d = tostring(d)
        end
        args = '"' .. table.concat({f, a, s, d or 1, g and "true" or nil, h}, '","') ..'"'
        table.sort(tstrung)
        table.sort(tstring)
        print(table.concat({tstring[1]/tstrung[1], tstrung[1], tstring[1], args}, ","))
    end
    local ri, ro = {}, {}
    function gmtry(s, p)
        -- print(("-_"):rep(30))
        -- print("Test: ", "gmatch", s, p)
        local tstring, tstrung = {}, {}
        for i = 1, 1 do
            local tic = os.clock()
            for i = 1, II do
                for a, b, c, d, e, f in string.gmatch(s, p) do
                    ri[1] = {a, b, c, d, e, f}
                end
            end
            tstring[i] = os.clock() - tic
            local tic = os.clock()
            for i = 1, II do
                for a, b, c, d, e, f in strung.gmatch(s, p) do
                    ro[1] = {a, b, c, d, e, f}
                end
            end
            tstrung[i] = os.clock() - tic
        end
        s = s_gsub(s, "[%z\1-\31\127-\255\\\"]", ""):sub(1,15)
        args = '"gmatch","'..s..'","'..p..'"'
        print(table.concat({tstring[1]/tstrung[1], tstrung[1], tstring[1], args},","))
    end
    -- [[]] function gmtry()end
    function iter(n) II = BASE * n end
    iter(10)
else
    function try(f, ...)
        local params = {...}
        local ri, Ros
        -- print(("-_"):rep(30))
        -- print("Test: ", f, ...)
        ri = {string[f](...)}
        Ro = {strung[f](...)}
        for i, v in ipairs(params) do params[i] = tostring(v) end
        for i = 1, math.max(#ri, #Ro) do
            strung.assert(ri[i] == Ro[i], params[2], table.concat({ 
                table.concat(params, ", "), 
                "ri:", table.concat(ri, ",  "), 
                " \tRo:", table.concat(Ro, ", ")
            }, " | "))
        end
    end
    function gmtry(s, p)
        local desc = "Test:  gmatch ".. s .." -- ".. p
        local ri, ro = {}, {}
        for a, b, c, d, e, f in strung.gmatch(s, p) do
            ro[#ro + 1] = {a, b, c, d, e, f}
        end
        for a, b, c, d, e, f in string.gmatch(s, p) do
            ri[#ri + 1] = {a, b, c, d, e, f}
        end
        strung.assert(#ro == #ri, p, desc.."\nstring: \n"..ttstr(ri).."\n=/=/=/=/=/=/=/=/\nstrung:\n"..ttstr(ro))
        for i = 1, #ro do
        strung.assert(#ro[i] == #ri[i], p, desc.."\nstring: \n"..ttstr(ri).."\n=/=/=/=/=/=/=/=/\nstrung:\n"..ttstr(ro))
            for j = 1, #ri[i] do
                strung.assert(ri[i][j] == ro[i][j], p, desc.."\nstring: \n"..ttstr(ri).."\n=/=/=/=/=/=/=/=/\nstrung:\n"..ttstr(ro))
            end
        end
    end
    iter = function()end
    -- gmtry = iter
end

local allchars do
    local acc = {}
    for i = 0, 255 do acc[i+1] = string.char(i) end
    allchars = table.concat(acc)
end



return {try = try, gmtry = gmtry, iter = iter, allchars = allchars, dumpacc = dumpacc}