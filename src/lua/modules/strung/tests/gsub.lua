--- gsub ---

local c = require"tests.common"
local try, gmtry, iter, allchars, dumpacc = c.try, c.gmtry, c.iter, c.allchars, c.dumpacc

iter(10)

-- basic tests

try("gsub", "_d_d_", "d", "+")
try("gsub", "_da_da_", "(d)a", "+")

try("gsub", "_d_d_", "d", {})
try("gsub", "_d_d_", "d", {d = 9})
try("gsub", "_d_d_", "d", {d = "9"})

try("gsub", "_d_d_", "d", function()end)
try("gsub", "_do_d_", "(d)(.)", function(a,b) return b,a end)

-- the patterns used by f1() in pm.lua

try('gsub', '123abc123', "abc", "IVX%1IVX")

try("gsub", '(..*) %1', "%%([0-9])", function (s) return "%" .. (s+1) end)
try("gsub", '(..*) %1', "^(^?)", "%1()", 1)
try("gsub", '(..*) %1', "($?)$", "()%1", 1)

-- see issue #7

try("gsub", "os:d:/dropbox/goluwa/...", "^(.-:)", "")
try("gsub", "os:d:/dropbox/goluwa/...", "^(.-:)", "",2)

if not bench then print"ok" end
