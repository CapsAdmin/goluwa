local c = require"tests.common"
local try, gmtry, iter, allchars = c.try, c.gmtry, c.iter, c.allchars

try("find", allchars, "a")

try("find", "fof", "f", -4)
try("find", "fof", "f", -3)
try("find", "fof", "f", -2)
try("find", "fof", "f", -1)

try("find", allchars, "a", 1, true)

try("find", "fof", "f", -4, true)
try("find", "fof", "f", -3, true)
try("find", "fof", "f", -2, true)
try("find", "fof", "f", -1, true)

try("match", "fof", "f", -4)
try("match", "fof", "f", -3)
try("match", "fof", "f", -2)
try("match", "fof", "f", -1)

iter(0.0001)
try("find", ("Long 1 -- aaaaaaaaabaaaaaaaabbaaaaaaaaaaaabbaaaaaaaaaaabbaaaaaaaaaaaabb"):rep(10000), "aaaaaaaaaaaaabbb")
try("find", ("Long 2 -- aaaaaaaaabaaaaaaaabbaaaaaaaaaaaabbaaaaaaaaaaabbaaaaaaaaaaaabb"):rep(10000), "aaaaaaaaaaaaaaaaaaaaaaaabbb")
try("find", ("Long 3 -- aaaaaaaaabaaaaaaaabbaaaaaaaaaaaabbaaaaaaaaaaabbaaaaaaaaaaaabb"):rep(10000), "aaaaaaaabbb")
try("find", ("Long 4 -- aaaaaaaaabaaaaaaaabbaaaaaaaaaaaabbaaaaaaaaaaabbaaaaaaaaaaaabb"):rep(10000), "c")
iter(10)

s = {}
for i = 1, 10000 do
    s[#s+1] = string.char(math.random(255))
end
s = table.concat(s)
collectgarbage()
try("find", s, "aaaaaaaaaaaaabbb")

try("find", "aaaaabaaaaabaaaaaaaaabb", "aabb")
try("find", "aaaaaaaaabbaaaaaaaabbaaaaaaaaaaaabbaaaaaaaaaaabbaaaaaaaaaaaabb", "aaaaaaaaaaaaabbb")


try("find", "baa", "aa")
try("find", "ba", "a")

try("find", "a", "aa")
try("find", "aa", "a")
try("find", "aa", "aa")
try("find", "a", "a")

try("find", "aaaaabaaaaabaaaaaaaaabb", "aabb", nil, true)
try("find", "aaaaaaaaabbaaaaaaaabbaaaaaaaaaaaabbaaaaaaaaaaabbaaaaaaaaaaaabb", "aaaaaaaaaaaaabbb", nil, true)

iter(10)

try("find", "baa", "aa", nil, true)
try("find", "ba", "a", nil, true)

try("find", "a", "aa", nil, true)
try("find", "aa", "a", nil, true)
try("find", "aa", "aa", nil, true)
try("find", "a", "a", nil, true)

if not bench then print"ok" end