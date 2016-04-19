local c = require"tests.common"
local try, gmtry, iter, allchars, dumpacc = c.try, c.gmtry, c.iter, c.allchars, c.dumpacc

local strung = require"strung"

local bench = arg[1] == "bench"

--- Character classes and locales ---

try("find", allchars, "%a+")
gmtry(allchars, "%a+")

iter(1)

for _, locale in ipairs{
    -- let this out for now, LJ character classes are not sensitive to os.setlocale()
    -- "fr_FR",
    "C"
} do
    -- print("LOCALE: ", strung.setlocale(locale))
    for c in ("acdlpsuwxz"):gmatch"." do
        gmtry(allchars, "%"..c.."+")
        gmtry(allchars, "%"..c:upper().."+")
    end
end

iter(10)


---- The tests ----


--- %0 ---

assert(strung.find("\0", "\0"), "'\\0' pattern failed to match.")
assert(strung.find("\0", "[\0]"), "'\\0' pattern failed to match in charset.")


--- %f ---

try("find", "\0", "%z")
try("find", "\0", "[%z]")

try("find", "", "[%z]")


try("find", "AAAAAA", "%f[%l]a")
try("find", "AAAAAA", "%f[%l]")
try("find", "aAaAb", "%f[%l]a", 2)
try("find", "aAaAb", "%f[%l]a")
try("find", "aAaAb", "%f[%l]a", 4)
try("find", "AaAb", "%f[%l]a")
try("find", "aAb", "%f[%l]b")
try("find", "aAb", "%f[%l]a")


--- negative indices ---

try("find", "fof", "[^o]", -4)
try("find", "fof", "[^o]", -3)
try("find", "fof", "[^o]", -2)
try("find", "fof", "[^o]", -1)

try("match", "fof", "[^o]", -4)
try("match", "fof", "[^o]", -3)
try("match", "fof", "[^o]", -2)
try("match", "fof", "[^o]", -1)

try("match", "fof", "f", -4)
try("match", "fof", "f", -3)
try("match", "fof", "f", -2)
try("match", "fof", "f", -1)


--- gmatch ---

gmtry('abcdabcdabcd', "((a)(b)c)()(d)")
-- try("find", 'abcdabcdabcd', "((a)(b)c)()(d)")
-- try("find", 'abcdabcdabcd', "(a)(b)c(d)")
gmtry('abcdabcdabcd', "(a)(b)c(d)")
gmtry('abcdabcdabcd', "(a)(b)(d)")
gmtry('abcdabcdabcd', "(a)(b)(d)")
gmtry('abcabcabc', "(a)(b)")
gmtry('abcabcabc', "(ab)")

iter(10)
--- bug fix ---

try("match", "faa:foo:", "(.+):(%l+)")
try("match", ":foo:", "(%l*)")
try("match", "faa:foo:", ":%l+")
try("match", "faa:foo:", ":(%l+)")
try("match", "faa:foo:", "(%l+)")
try("match", ":foo:", "(%l+)")
try("match", "foo", "%l+")
try("match", "foo", "foo")

--- anchored patterns ---

try("find", "wwS", "^wS", 2)
try("find", "wwS", "^wS")
try("find", "wwS", "^ww", 2)
try("find", "wwS", "^ww")

--- %b ---

try("find", "a(f()g(h(d d))[[][]]K)", "%b()%b[]", 3)
try("find", "a(f()g(h(d d))[[][]]K)", "%b()%b[]", 2)
try("find", "a(f()g(h(d d))[[][]]K)", "%b()%b[]")
try("find", "a(f()g(h(d d))K)", "%b()")
try("find", "a(f()g(h(d d))K", "%b()")

--- references ---

iter(3)
try("find", "foobarfoo", "(foo)(bar)%2%1")
try("find", "foobarbarfoo", "(foo)(bar)%2%1")
try("find", "foobarbar", "(foo)(bar)%2")
try("find", "foobarfoo", "(foo)(bar)%2")
try("find", "foobarfoo", "(foo)(bar)%1")
try("find", "foobarfoo", "(foo)bar%1")

--- Captures ---

try("find", "wwS", "((w*)S)")
try("find", "wwwwS", "((w*)%u)")
try("find", "wwS", "((%l)%u)")
try("find", "SSw", "((%u)%l)")
try("find", "wwS", "((%l*)%u)")
try("find", "wwS", "((%l-)%u)")

try("find", "wwS", "((w*)%u)")
try("find", "wwS", "((ww)%u)")
try("find", "wwS", "((%l*)S)")
try("find", "wwS", "((%l*))")


try("find", "wwSS", "()(%u+)()")

--- Character sets  ---


try("find", "wwwww]wS", "[^%u%]]*")
try("find", "%]%]", "[%%%]]+")
try("find", "%]]]]%]", "[%%]]+")

try("find", "wwwwwwS", "[^%u]*")
try("find", "wwwwwwS", "[^%u]")
try("find", "wwwwwwS", "(%l*)")
try("find", "wwSS", "(%u+)")

try("find", "wwS", "%l%u")
try("find", "wwS", "()%l%u")

try("find", "wwwwwwS", "[^%U]")
try("find", "wwwwwwS", "[%U]*")
try("find", "wwwwwwS", "[%U]+")

try("find", "wwwwwwS", "%l*")

try("find", "wwwwwwS", "[%U]")
try("find", "wwwwwwS", "[%u]")

try("find", "wwwwwwS", "[%u]*")
try("find", "wwwwwwS", "[^kfdS]*")

try("find", "wwS", "%l*()")
try("find", "wwS", "()%u+")

--- escape sequeces ---

try("find", "w(wSESDFB)SFwe)fwe", "%(.-%)")
try("find", "w(wSESDFB)SFwe)fwe", "%(.*%)")

--- Basic patterns ---

try("find", "wawSESDFB)SFweafwe", "a.-a")
try("find", "wawSESDFBaSFwe)fwe", "a.*a")

try("find", "a", ".")
try("find", "a6ruyfhjgjk9", ".+")



try("find", "wawSESDFBaSFwe)fwe", "a[A-Za-z]*a")

try("find", "qwwSYUGJHDwefwe", "%u+")
try("find", "wwSESDFBSFwefwe", "[A-Z]+")

try("find", "SYUGJHD", "%u+")
try("find", "SESDFBSF", "[A-Z]+")
try("find", "qwwSYUGJHD", "%u+")
try("find", "wwSESDFBSF", "[A-Z]+")

try("find", "S", "%u")
try("find", "S", "[A-Z]")

iter(50)

try("find", "a", "a?a")
try("find", "ab", "a?b")
try("find", "b", "a?b")
try("find", "abbab", "a?ba?b$")
try("find", "abbabbab", "a?ba?b$")
try("find", "abbabbab", "a?ba?ba?ba?ba?b$")
try("find", "abbabbaba", "a?ba?ba?ba?ba?b$")

iter(10)

try("find", "aaaabaaaaabbaaaabb$", "a+bb$")
try("find", "aaaabaaaaabbaaaabb", "a*bb$")
try("find", "aaaaaaaabaaabaaaaabb", "a+bb")
try("find", "aaaaaaaabaaabaaaaabb", "a*bb")

try("find", "aaaaaaaabaaabaaaaab", "ba-bb")
try("find", "aaaaaaaabaaabaaaaabb", "ba-bb")

try("find", "aaa", "a+")
try("find", "aaaaaaaaaaaaaaaaaa", "a+")


if not bench then
    print "ok"
end