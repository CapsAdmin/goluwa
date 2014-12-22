strung = require"strung"

print('testing pattern matching')

function f(s, p)
  local i,e = strung.find(s, p)
  if i then return string.sub(s, i, e) end
end

function f1(s, p)
  p = strung.gsub(p, "%%([0-9])", function (s) return "%" .. (s+1) end)
  p = strung.gsub(p, "^(^?)", "%1()", 1)
  p = strung.gsub(p, "($?)$", "()%1", 1)
  local t = {strung.match(s, p)}
  return string.sub(s, t[1], t[#t] - 1)
end

a,b = strung.find('', '')    -- empty patterns are tricky
assert(a == 1 and b == 0);
a,b = strung.find('alo', '')
assert(a == 1 and b == 0)
a,b = strung.find('a\0o a\0o a\0o', 'a', 1)   -- first position
assert(a == 1 and b == 1)
a,b = strung.find('a\0o a\0o a\0o', 'a\0o', 2)   -- starts in the midle
assert(a == 5 and b == 7)
a,b = strung.find('a\0o a\0o a\0o', 'a\0o', 9)   -- starts in the midle
assert(a == 9 and b == 11)
a,b = strung.find('a\0a\0a\0a\0\0ab', '\0ab', 2);  -- finds at the end
assert(a == 9 and b == 11);
a,b = strung.find('a\0a\0a\0a\0\0ab', 'b')    -- last position
assert(a == 11 and b == 11)
assert(strung.find('a\0a\0a\0a\0\0ab', 'b\0') == nil)   -- check ending
assert(strung.find('', '\0') == nil)
assert(strung.find('alo123alo', '12') == 4)
assert(strung.find('alo123alo', '^12') == nil)

assert(f('aloALO', '%l*') == 'alo')
assert(f('aLo_ALO', '%a*') == 'aLo')

assert(f('aaab', 'a*') == 'aaa');
assert(f('aaa', '^.*$') == 'aaa');
assert(f('aaa', 'b*') == '');
assert(f('aaa', 'ab*a') == 'aa')
assert(f('aba', 'ab*a') == 'aba')
assert(f('aaab', 'a+') == 'aaa')
assert(f('aaa', '^.+$') == 'aaa')
assert(f('aaa', 'b+') == nil)
assert(f('aaa', 'ab+a') == nil)
assert(f('aba', 'ab+a') == 'aba')
assert(f('a$a', '.$') == 'a')
assert(f('a$a', '.%$') == 'a$')
assert(f('a$a', '.$.') == 'a$a')
assert(f('a$a', '$$') == nil)
assert(f('a$b', 'a$') == nil)
assert(f('a$a', '$') == '')
assert(f('', 'b*') == '')
assert(f('aaa', 'bb*') == nil)
assert(f('aaab', 'a-') == '')
assert(f('aaa', '^.-$') == 'aaa')
assert(f('aabaaabaaabaaaba', 'b.*b') == 'baaabaaabaaab')
assert(f('aabaaabaaabaaaba', 'b.-b') == 'baaab')
assert(f('alo xo', '.o$') == 'xo')
assert(f(' \n isto ? assim', '%S%S*') == 'isto')
assert(f(' \n isto ? assim', '%S*$') == 'assim')
assert(f(' \n isto ? assim', '[a-z]*$') == 'assim')
assert(f('um caracter ? extra', '[^%sa-z]') == '?')
assert(f('', 'a?') == '')
assert(f('?', '??') == '?')
assert(f('?bl', '??b?l?') == '?bl')
assert(f('  ?bl', '??b?l?') == '')
assert(f('aa', '^aa?a?a') == 'aa')
assert(f(']]]?b', '[^]]') == '?')
assert(f("0alo alo", "%x*") == "0a")
assert(f("alo alo", "%C+") == "alo alo")
print('+')

assert(f1('alo alx 123 b\0o b\0o', '(..*) %1') == "b\0o b\0o")
assert(f1('axz123= 4= 4 34', '(.+)=(.*)=%2 %1') == '3= 4= 4 3')
assert(f1('=======', '^(=*)=%1$') == '=======')
assert(strung.match('==========', '^([=]*)=%1$') == nil)

local function range (i, j)
  if i <= j then
    return i, range(i+1, j)
  end
end

local abc = string.char(range(0, 255));

assert(string.len(abc) == 256)

local function strset (p)
  local res = {s=''}
  strung.gsub(abc, p, function (c)
    res.s = res.s .. c
  end)
  return res.s
end;

assert(string.len(strset('[\110-\120]')) == 11)
assert(string.len(strset('[\200-\210]')) == 11)

assert(strset('[a-z]') == "abcdefghijklmnopqrstuvwxyz")
assert(strset('[a-z%d]') == strset('[%da-uu-z]'))
assert(strset('[a-]') == "-a")
assert(strset('[^%W]') == strset('[%w]'))
assert(strset('[]%%]') == '%]')
assert(strset('[a%-z]') == '-az')
assert(strset('[%^%[%-a%]%-b]') == '-[]^ab')
assert(strset('%Z') == strset('[\1-\255]'))
assert(strset('.') == strset('[\1-\255%z]'))
print('+');

assert(strung.match("alo xyzK", "(%w+)K") == "xyz")
assert(strung.match("254 K", "(%d*)K") == "")
assert(strung.match("alo ", "(%w*)$") == "")
assert(strung.match("alo ", "(%w+)$") == nil)
assert(strung.find("(?lo)", "%(?") == 1)
local a, b, c, d, e = strung.match("?lo alo", "^(((.).).* (%w*))$")
assert(a == '?lo alo' and b == '?l' and c == '?' and d == 'alo' and e == nil)
a, b, c, d  = strung.match('0123456789', '(.+(.?)())')
assert(a == '0123456789' and b == '' and c == 11 and d == nil)
print('+')

assert(strung.gsub('?lo ?lo', '?', 'x') == 'xlo xlo')
assert(strung.gsub('alo ?lo  ', ' +$', '') == 'alo ?lo')  -- trim
assert(strung.gsub('  alo alo  ', '^%s*(.-)%s*$', '%1') == 'alo alo')  -- double trim
assert(strung.gsub('alo  alo  \n 123\n ', '%s+', ' ') == 'alo alo 123 ')
t = "ab? d"
a, b = strung.gsub(t, '(.)', '%1@')
assert('@'..a == strung.gsub(t, '', '@') and b == 5)
a, b = strung.gsub('ab?d', '(.)', '%0@', 2)
assert(a == 'a@b@?d' and b == 2)
assert(strung.gsub('alo alo', '()[al]', '%1') == '12o 56o')
assert(strung.gsub("abc=xyz", "(%w*)(%p)(%w+)", "%3%2%1-%0") ==
              "xyz=abc-abc=xyz")
assert(strung.gsub("abc", "%w", "%1%0") == "aabbcc")
assert(strung.gsub("abc", "%w+", "%0%1") == "abcabc")
assert(strung.gsub('???', '$', '\0??') == '???\0??')
assert(strung.gsub('', '^', 'r') == 'r')
assert(strung.gsub('', '$', 'r') == 'r')
print('+')

assert(strung.gsub("um (dois) tres (quatro)", "(%(%w+%))", string.upper) ==
            "um (DOIS) tres (QUATRO)")

do
  local function setglobal (n,v) rawset(_G, n, v) end
  strung.gsub("a=roberto,roberto=a", "(%w+)=(%w%w*)", setglobal)
  assert(_G.a=="roberto" and _G.roberto=="a")
end

function f(a,b) return strung.gsub(a,'.',b) end
assert(strung.gsub("trocar tudo em |teste|b| ? |beleza|al|", "|([^|]*)|([^|]*)|", f) ==
            "trocar tudo em bbbbb ? alalalalalal")

local function dostring (s) return loadstring(s)() or "" end
assert(strung.gsub("alo $a=1$ novamente $return a$", "$([^$]*)%$", dostring) ==
            "alo  novamente 1")

x = strung.gsub("$x=strung.gsub('alo', '.', string.upper)$ assim vai para $return x$",
         "$([^$]*)%$", dostring)
assert(x == ' assim vai para ALO')

t = {}
s = 'a alo jose  joao'
r = strung.gsub(s, '()(%w+)()', function (a,w,b)
      assert(string.len(w) == b-a);
      t[a] = b-a;
    end)
assert(s == r and t[1] == 1 and t[3] == 3 and t[7] == 4 and t[13] == 4)


function isbalanced (s)
  return strung.find(strung.gsub(s, "%b()", ""), "[()]") == nil
end

assert(isbalanced("(9 ((8))(\0) 7) \0\0 a b ()(c)() a"))
assert(not isbalanced("(9 ((8) 7) a b (\0 c) a"))
assert(strung.gsub("alo 'oi' alo", "%b''", '"') == 'alo " alo')


local t = {"apple", "orange", "lime"; n=0}
assert(strung.gsub("x and x and x", "x", function () t.n=t.n+1; return t[t.n] end)
        == "apple and orange and lime")

t = {n=0}
strung.gsub("first second word", "%w%w*", function (w) t.n=t.n+1; t[t.n] = w end)
assert(t[1] == "first" and t[2] == "second" and t[3] == "word" and t.n == 3)

t = {n=0}
assert(strung.gsub("first second word", "%w+",
         function (w) t.n=t.n+1; t[t.n] = w end, 2) == "first second word")
assert(t[1] == "first" and t[2] == "second" and t[3] == nil)

assert(not pcall(strung.gsub, "alo", "(.", print))
assert(not pcall(strung.gsub, "alo", ".)", print))
assert(not pcall(strung.gsub, "alo", "(.", {}))
assert(not pcall(strung.gsub, "alo", "(.)", "%2"))
assert(not pcall(strung.gsub, "alo", "(%1)", "a"))
assert(not pcall(strung.gsub, "alo", "(%0)", "a"))

-- big strings
local a = string.rep('a', 300000)
assert(strung.find(a, '^a*.?$'))
assert(not strung.find(a, '^a*.?b$'))
assert(strung.find(a, '^a-.?$'))

-- deep nest of gsubs
function rev (s)
  return strung.gsub(s, "(.)(.+)", function (c,s1) return rev(s1)..c end)
end

local x = string.rep('012345', 10)
assert(rev(rev(x)) == x)


-- gsub with tables
assert(strung.gsub("alo alo", ".", {}) == "alo alo")
assert(strung.gsub("alo alo", "(.)", {a="AA", l=""}) == "AAo AAo")
assert(strung.gsub("alo alo", "(.).", {a="AA", l="K"}) == "AAo AAo")
assert(strung.gsub("alo alo", "((.)(.?))", {al="AA", o=false}) == "AAo AAo")

assert(strung.gsub("alo alo", "().", {2,5,6}) == "256 alo")

t = {}; setmetatable(t, {__index = function (t,s) return string.upper(s) end})
assert(strung.gsub("a alo b hi", "%w%w+", t) == "a ALO b HI")


-- tests for gmatch
assert(strung.gfind == strung.gmatch)
local a = 0
for i in strung.gmatch('abcde', '()') do 
    assert(i == a+1); a=i
end
assert(a==6)

t = {n=0}
for w in strung.gmatch("first second word", "%w+") do
      t.n=t.n+1; t[t.n] = w
end
assert(t[1] == "first" and t[2] == "second" and t[3] == "word")

t = {3, 6, 9}
for i in strung.gmatch ("xuxx uu ppar r", "()(.)%2") do
  assert(i == table.remove(t, 1))
end
assert(table.getn(t) == 0)

t = {}
for i,j in strung.gmatch("13 14 10 = 11, 15= 16, 22=23", "(%d+)%s*=%s*(%d+)") do
  t[i] = j
end
a = 0
for k,v in pairs(t) do assert(k+1 == v+0); a=a+1 end
assert(a == 3)


-- -- tests for `%f' (`frontiers')

assert(strung.gsub("aaa aa a aaa a", "%f[%w]a", "x") == "xaa xa x xaa x")
assert(strung.gsub("[[]] [][] [[[[", "%f[[].", "x") == "x[]] x]x] x[[[")
assert(strung.gsub("01abc45de3", "%f[%d]", ".") == ".01abc.45de.3")
assert(strung.gsub("01abc45 de3x", "%f[%D]%w", ".") == "01.bc45 de3.")
assert(strung.gsub("function", "%f[\1-\255]%w", ".") == ".unction")
assert(strung.gsub("function", "%f[^\1-\255]", ".") == "function.")

local i, e = strung.find(" alo aalo allo", "%f[%S].-%f[%s].-%f[%S]")
assert(i == 2 and e == 5)
local k = strung.match(" alo aalo allo", "%f[%S](.-%f[%s].-%f[%S])")
assert(k == 'alo ')

local a = {1, 5, 9, 14, 17,}
for k in strung.gmatch("alo alo th02 is 1hat", "()%f[%w%d]") do
  assert(table.remove(a, 1) == k)
end
assert(table.getn(a) == 0)


print('OK')
