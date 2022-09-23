local ipairs = ipairs
local pairs = pairs
local tostring = _G.tostring
local T = require("test.helpers")
local analyze = T.RunCode
local bit = _G.bit32 or _G.bit
analyze[[
        local function lt(x, y)
            if x < y then return true else return false end
        end

        local function le(x, y)
            if x <= y then return true else return false end
        end

        local function gt(x, y)
            if x > y then return true else return false end
        end

        local function ge(x, y)
            if x >= y then return true else return false end
        end

        local function eq(x, y)
            if x == y then return true else return false end
        end

        local function ne(x, y)
            if x ~= y then return true else return false end
        end


        local function ltx1(x)
            if x < 1 then return true else return false end
        end

        local function lex1(x)
            if x <= 1 then return true else return false end
        end

        local function gtx1(x)
            if x > 1 then return true else return false end
        end

        local function gex1(x)
            if x >= 1 then return true else return false end
        end

        local function eqx1(x)
            if x == 1 then return true else return false end
        end

        local function nex1(x)
            if x ~= 1 then return true else return false end
        end


        local function lt1x(x)
            if 1 < x then return true else return false end
        end

        local function le1x(x)
            if 1 <= x then return true else return false end
        end

        local function gt1x(x)
            if 1 > x then return true else return false end
        end

        local function ge1x(x)
            if 1 >= x then return true else return false end
        end

        local function eq1x(x)
            if 1 == x then return true else return false end
        end

        local function ne1x(x)
            if 1 ~= x then return true else return false end
        end

        do --- 1,2
            local x,y = 1,2

            attest.equal(x<y,	true)
            attest.equal(x<=y,	true)
            attest.equal(x>y,	false)
            attest.equal(x>=y,	false)
            attest.equal(x==y,	false)
            attest.equal(x~=y,	true)

            attest.equal(1<y,	true)
            attest.equal(1<=y,	true)
            attest.equal(1>y,	false)
            attest.equal(1>=y,	false)
            attest.equal(1==y,	false)
            attest.equal(1~=y,	true)

            attest.equal(x<2,	true)
            attest.equal(x<=2,	true)
            attest.equal(x>2,	false)
            attest.equal(x>=2,	false)
            attest.equal(x==2,	false)
            attest.equal(x~=2,	true)

            attest.equal(lt(x,y),	true)
            attest.equal(le(x,y),	true)
            attest.equal(gt(x,y),	false)
            attest.equal(ge(x,y),	false)
            attest.equal(eq(y,x),	false)
            attest.equal(ne(y,x),	true)
        end

        do --- 2,1
            local x,y = 2,1

            attest.equal(x<y,	false)
            attest.equal(x<=y,	false)
            attest.equal(x>y,	true)
            attest.equal(x>=y,	true)
            attest.equal(x==y,	false)
            attest.equal(x~=y,	true)

            attest.equal(2<y,	false)
            attest.equal(2<=y,	false)
            attest.equal(2>y,	true)
            attest.equal(2>=y,	true)
            attest.equal(2==y,	false)
            attest.equal(2~=y,	true)

            attest.equal(x<1,	false)
            attest.equal(x<=1,	false)
            attest.equal(x>1,	true)
            attest.equal(x>=1,	true)
            attest.equal(x==1,	false)
            attest.equal(x~=1,	true)

            attest.equal(lt(x,y),	false)
            attest.equal(le(x,y),	false)
            attest.equal(gt(x,y),	true)
            attest.equal(ge(x,y),	true)
            attest.equal(eq(y,x),	false)
            attest.equal(ne(y,x),	true)
        end

        do --- 1,1
            local x,y = 1,1

            attest.equal(x<y,	false)
            attest.equal(x<=y,	true)
            attest.equal(x>y,	false)
            attest.equal(x>=y,	true)
            attest.equal(x==y,	true)
            attest.equal(x~=y,	false)

            attest.equal(1<y,	false)
            attest.equal(1<=y,	true)
            attest.equal(1>y,	false)
            attest.equal(1>=y,	true)
            attest.equal(1==y,	true)
            attest.equal(1~=y,	false)

            attest.equal(x<1,	false)
            attest.equal(x<=1,	true)
            attest.equal(x>1,	false)
            attest.equal(x>=1,	true)
            attest.equal(x==1,	true)
            attest.equal(x~=1,	false)

            attest.equal(lt(x,y),	false)
            attest.equal(le(x,y),	true)
            attest.equal(gt(x,y),	false)
            attest.equal(ge(x,y),	true)
            attest.equal(eq(y,x),	true)
            attest.equal(ne(y,x),	false)
        end

        do --- 2
            attest.equal(lt1x(2),	true)
            attest.equal(le1x(2),	true)
            attest.equal(gt1x(2),	false)
            attest.equal(ge1x(2),	false)
            attest.equal(eq1x(2),	false)
            attest.equal(ne1x(2),	true)

            attest.equal(ltx1(2),	false)
            attest.equal(lex1(2),	false)
            attest.equal(gtx1(2),	true)
            attest.equal(gex1(2),	true)
            attest.equal(eqx1(2),	false)
            attest.equal(nex1(2),	true)
        end

        do --- 1
            attest.equal(lt1x(1),	false)
            attest.equal(le1x(1),	true)
            attest.equal(gt1x(1),	false)
            attest.equal(ge1x(1),	true)
            attest.equal(eq1x(1),	true)
            attest.equal(ne1x(1),	false)

            attest.equal(ltx1(1),	false)
            attest.equal(lex1(1),	true)
            attest.equal(gtx1(1),	false)
            attest.equal(gex1(1),	true)
            attest.equal(eqx1(1),	true)
            attest.equal(nex1(1),	false)
        end

        do --- 0
            attest.equal(lt1x(0),	false)
            attest.equal(le1x(0),	false)
            attest.equal(gt1x(0),	true)
            attest.equal(ge1x(0),	true)
            attest.equal(eq1x(0),	false)
            attest.equal(ne1x(0),	true)

            attest.equal(ltx1(0),	true)
            attest.equal(lex1(0),	true)
            attest.equal(gtx1(0),	false)
            attest.equal(gex1(0),	false)
            attest.equal(eqx1(0),	false)
            attest.equal(nex1(0),	true)
        end
    ]]
-- boolean and or logic
-- when false, or returns its second argument
analyze("attest.equal(nil or false, false)")
analyze("attest.equal(false or nil, nil)")
-- when true, or returns its first argument
analyze("attest.equal(1 or false, 1)")
analyze("attest.equal(true or nil, true)")
analyze("attest.equal(nil or {}, {})")
-- boolean without any data can be true and false at the same time
analyze("attest.equal((_ as boolean) or (1), _ as true | 1)")
-- when false and returns its first argument
analyze("attest.equal(false and true, false)")
analyze("attest.equal(true and nil, nil)")
-- when true and returns its second argument
-- ????
-- smoke test
analyze("attest.equal(((1 or false) and true) or false, true)")

do --- allcases
	local basiccases = {
		{"nil", nil},
		{"false", false},
		{"true", true},
		{"10", 10},
	}
	local mem = {basiccases} -- for memoization
	local function allcases(n)
		if mem[n] then return mem[n] end

		local res = {}

		-- include all smaller cases
		for _, v in ipairs(allcases(n - 1)) do
			res[#res + 1] = v
		end

		for i = 1, n - 1 do
			for _, v1 in ipairs(allcases(i)) do
				for _, v2 in ipairs(allcases(n - i)) do
					res[#res + 1] = {
						"(" .. v1[1] .. " and " .. v2[1] .. ")",
						v1[2] and
						v2[2],
					}
					res[#res + 1] = {
						"(" .. v1[1] .. " or " .. v2[1] .. ")",
						v1[2] or
						v2[2],
					}
				end
			end
		end

		mem[n] = res -- memoize
		return res
	end

	local code = {}
	local done = {}
	local i = 1

	for _, v in pairs(allcases(4)) do
		local str = "attest.equal(" .. tostring(v[1]) .. ", " .. tostring(v[2]) .. ")\n"

		if not done[str] then
			code[i] = str
			i = i + 1
			done[str] = true
		end
	end

	analyze(table.concat(code))
end

if bit.tobit then
	analyze[[
            -- bit operations
            for i=1,100 do
                attest.truthy(bit.tobit(i+0x7fffffff) < 0)
            end
            for i=1,100 do
                attest.truthy(bit.tobit(i+0x7fffffff) <= 0)
            end
        ]]
end

analyze[[
        -- string comparisons
        do
            local a = "\255\255\255\255"
            local b = "\1\1\1\1"

            attest.truthy(a > b)
            attest.truthy(a > b)
            attest.truthy(a >= b)
            attest.truthy(b <= a)
        end

        do --- String comparisons:
            local function str_cmp(a, b, lt, gt, le, ge)
                attest.truthy(a<b == lt)
                attest.truthy(a>b == gt)
                attest.truthy(a<=b == le)
                attest.truthy(a>=b == ge)
                attest.truthy((not (a<b)) == (not lt))
                attest.truthy((not (a>b)) == (not gt))
                attest.truthy((not (a<=b)) == (not le))
                attest.truthy((not (a>=b)) == (not ge))
            end

            local function str_lo(a, b)
                str_cmp(a, b, true, false, true, false)
            end

            local function str_eq(a, b)
                str_cmp(a, b, false, false, true, true)
            end

            local function str_hi(a, b)
                str_cmp(a, b, false, true, false, true)
            end

            str_lo("a", "b")
            str_eq("a", "a")
            str_hi("b", "a")

            str_lo("a", "aa")
            str_hi("aa", "a")

            str_lo("a", "a\0")
            str_hi("a\0", "a")
        end
    ]]
analyze[[
        -- object equality
        local function obj_eq(a, b)
            attest.equal(a==b, true)
            attest.equal(a~=b, false)
        end

        local function obj_ne(a, b)
            attest.equal(a==b, false)
            attest.equal(a~=b, true)
        end

        obj_eq(nil, nil)
        obj_ne(nil, false)
        obj_ne(nil, true)

        obj_ne(false, nil)
        obj_eq(false, false)
        obj_ne(false, true)

        obj_ne(true, nil)
        obj_ne(true, false)
        obj_eq(true, true)

        obj_eq(1, 1)
        obj_ne(1, 2)
        obj_ne(2, 1)

        obj_eq("a", "a")
        obj_ne("a", "b")
        obj_ne("a", 1)
        obj_ne(1, "a")

        local t, t2 = {}, {}
        obj_eq(t, t)
        attest.equal(t==t2, _ as false)
        attest.equal(t~=t2, _ as true)
        obj_ne(t, 1)
        obj_ne(t, "")
    ]]
analyze[[
        local undef = nil
        local type assert = attest.truthy
        local type pcall = attest.pcall
        
        local mz <const> = -0.0
        local z <const> = 0.0
        assert(mz == z)
        assert(1/mz < 0 and 0 < 1/z)
        local a = {[mz] = 1}
        assert(a[z] == 1 and a[mz] == 1)
        a[z] = 2
        assert(a[z] == 2 and a[mz] == 2)
        local inf = math.huge * 2 + 1
        local mz <const> = -1/inf
        local z <const> = 1/inf
        assert(mz == z)
        assert(1/mz < 0 and 0 < 1/z)
        local NaN <const> = inf - inf
        assert(NaN ~= NaN)
        assert(not (NaN < NaN))
        assert(not (NaN <= NaN))
        assert(not (NaN > NaN))
        assert(not (NaN >= NaN))
        assert(not (0 < NaN) and not (NaN < 0))
        local NaN1 <const> = 0/0
        assert(NaN ~= NaN1 and not (NaN <= NaN1) and not (NaN1 <= NaN))
        local a = {}
        assert(not pcall(rawset, a, NaN, 1))
        assert(a[NaN] == undef)
        a[1] = 1
        assert(not pcall(rawset, a, NaN, 1))
        assert(a[NaN] == undef)
        -- strings with same binary representation as 0.0 (might create problems
        -- for constant manipulation in the pre-compiler)
        local a1, a2, a3, a4, a5 = 0, 0, "\0\0\0\0\0\0\0\0", 0, "\0\0\0\0\0\0\0\0"
        assert(a1 == a2 and a2 == a4 and a1 ~= a3)
        assert(a3 == a5)
    ]]
analyze[[
    local undef = nil
    local type assert = attest.truthy
    local type pcall = attest.pcall

    assert(tonumber('  0x2.5  ') == 0x25/16)
    assert(tonumber('  -0x2.5  ') == -0x25/16)
    assert(tonumber('  +0x0.51p+8  ') == 0x51)
    assert(0x.FfffFFFF == 1 - '0x.00000001')
    assert('0xA.a' + 0 == 10 + 10/16)
    assert(0xa.aP4 == 0XAA)
    assert(0x4P-2 == 1)
    assert(0x1.1 == '0x1.' + '+0x.1')
    assert(0Xabcdef.0 == 0x.ABCDEFp+24)
]]
analyze[[

    local undef = nil
    local type assert = attest.truthy
    local type pcall = attest.pcall
    
    local maxi <const> = math.maxinteger
    local mini <const> = math.mininteger
    
    
    local function checkerror (msg: ref string, f: ref Function, ...: ref ...any)
      local s, err = pcall(f, ...)
      if not (not s and string.find(err, msg)) then
        error("assertion failed", 2)
      end
    end
    
    
    -- testing string comparisons
    assert('alo' < 'alo1')
    assert('' < 'a')
    assert('alo\0alo' < 'alo\0b')
    assert('alo\0alo\0\0' > 'alo\0alo\0')
    assert('alo' < 'alo\0')
    assert('alo\0' > 'alo')
    assert('\0' < '\1')
    assert('\0\0' < '\0\1')
    assert('\1\0a\0a' <= '\1\0a\0a')
    assert(not ('\1\0a\0b' <= '\1\0a\0a'))
    assert('\0\0\0' < '\0\0\0\0')
    assert(not('\0\0\0\0' < '\0\0\0'))
    assert('\0\0\0' <= '\0\0\0\0')
    assert(not('\0\0\0\0' <= '\0\0\0'))
    assert('\0\0\0' <= '\0\0\0')
    assert('\0\0\0' >= '\0\0\0')
    assert(not ('\0\0b' < '\0\0a\0'))
    
    -- testing string.sub
    assert(string.sub("123456789",2,4) == "234")
    assert(string.sub("123456789",7) == "789")
    assert(string.sub("123456789",7,6) == "")
    assert(string.sub("123456789",7,7) == "7")
    assert(string.sub("123456789",0,0) == "")
    assert(string.sub("123456789",-10,10) == "123456789")
    assert(string.sub("123456789",1,9) == "123456789")
    assert(string.sub("123456789",-10,-20) == "")
    assert(string.sub("123456789",-1) == "9")
    assert(string.sub("123456789",-4) == "6789")
    assert(string.sub("123456789",-6, -4) == "456")
    assert(string.sub("\000123456789",3,5) == "234")
    assert(("\000123456789"):sub(8) == "789")
    
    
    -- testing string.find
    assert(string.find("123456789", "345") == 3)
    local a,b = string.find("123456789", "345")
    assert(string.sub("123456789", a, b) == "345")
    assert(string.find("1234567890123456789", "345", 3) == 3)
    assert(string.find("1234567890123456789", "345", 4) == 13)
    assert(not string.find("1234567890123456789", "346", 4))
    assert(string.find("1234567890123456789", ".45", -9) == 13)
    assert(not string.find("abcdefg", "\0", 5, true))
    assert(string.find("", "") == 1)
    assert(string.find("", "", 1) == 1)
    assert(not string.find('', 'aaa', 1))
    assert(('alo(.)alo'):find('(.)', 1, true) == 4)
    
    assert(string.len("") == 0)
    assert(string.len("\0\0\0") == 3)
    assert(string.len("1234567890") == 10)
    
    assert(#"" == 0)
    assert(#"\0\0\0" == 3)
    assert(#"1234567890" == 10)
    
    -- testing string.byte/string.char
    assert(string.byte("a") == 97)
    assert(string.byte("\xe4") > 127)
    assert(string.byte(string.char(255)) == 255)
    assert(string.byte(string.char(0)) == 0)
    assert(string.byte("\0") == 0)
    assert(string.byte("\0\0alo\0x", -1) == string.byte('x'))
    assert(string.byte("ba", 2) == 97)
    assert(string.byte("\n\n", 2, -1) == 10)
    assert(string.byte("\n\n", 2, 2) == 10)
    assert(string.byte("") == nil)
    assert(string.byte("hi", -3) == nil)
    assert(string.byte("hi", 3) == nil)
    assert(string.byte("hi", 9, 10) == nil)
    assert(string.byte("hi", 2, 1) == nil)
    assert(string.char() == "")
    assert(string.char(0, 255, 0) == "\0\255\0")
    assert(string.char(0, string.byte("\xe4"), 0) == "\0\xe4\0")
    assert(string.char(string.byte("\xe4l\0�u", 1, -1)) == "\xe4l\0�u")
    --assert(string.char(string.byte("\xe4l\0�u", 1, 0)) == "")
    assert(string.char(string.byte("\xe4l\0�u", -10, 100)) == "\xe4l\0�u")
    
    checkerror("out of range", string.char, 256)
    --checkerror("out of range", string.char, -1)
    --checkerror("out of range", string.char, math.maxinteger)
    --checkerror("out of range", string.char, math.mininteger)
    
    
    assert(string.upper("ab\0c") == "AB\0C")
    assert(string.lower("\0ABCc%$") == "\0abcc%$")
    assert(string.rep('teste', 0) == '')
    assert(string.rep('t�s\00t�', 2) == 't�s\0t�t�s\000t�')
    assert(string.rep('', 10) == '')
    
    if string.packsize("i") == 4 then
      -- result length would be 2^31 (int overflow)
      checkerror("too large", string.rep, 'aa', (1 << 30))
      checkerror("too large", string.rep, 'a', (1 << 30), ',')
    end
    
    -- repetitions with separator
    assert(string.rep('teste', 0, 'xuxu') == '')
    assert(string.rep('teste', 1, 'xuxu') == 'teste')
    assert(string.rep('\1\0\1', 2, '\0\0') == '\1\0\1\0\0\1\0\1')
    assert(string.rep('', 10, '.') == string.rep('.', 9))
    assert(not pcall(string.rep, "aa", maxi // 2 + 10))
    assert(not pcall(string.rep, "", maxi // 2 + 10, "aa"))
    
    assert(string.reverse"" == "")
    assert(string.reverse"\0\1\2\3" == "\3\2\1\0")
    assert(string.reverse"\0001234" == "4321\0")
    
    for i=0,30 do assert(string.len(string.rep('a', i)) == i) end
    
    assert(type(tostring(nil)) == 'string')
    assert(type(tostring(12)) == 'string')
    assert(not not string.find(tostring{}, 'table:'))
    assert(not not string.find(tostring(print), 'function:'))
    assert(#tostring('\0') == 1)
    assert(tostring(true) == "true")
    assert(tostring(false) == "false")
    assert(tostring(-1203) == "-1203")
    assert(tostring(1203.125) == "1203.125")
    assert(tostring(-0.5) == "-0.5")
    assert(tostring(-32767) == "-32767")
    
    if tostring(0.0) == "0.0" then   -- "standard" coercion float->string
      assert('' .. 12 == '12' and 12.0 .. '' == '12.0')
      assert(tostring(-1203 + 0.0) == "-1203.0")
    else   -- compatible coercion
      assert(tostring(0.0) == "0")
      assert('' .. 12 == '12' and 12.0 .. '' == '12')
      assert(tostring(-1203 + 0.0) == "-1203")
    end

]]
