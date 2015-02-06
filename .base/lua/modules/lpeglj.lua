--[[
LPEGLJ
lpeglj.lua
Main module and tree generation
Copyright (C) 2014 Rostislav Sacek.
based on LPeg v0.12 - PEG pattern matching for Lua
Lua.org & PUC-Rio  written by Roberto Ierusalimschy
http://www.inf.puc-rio.br/~roberto/lpeg/

** Permission is hereby granted, free of charge, to any person obtaining
** a copy of this software and associated documentation files (the
** "Software"), to deal in the Software without restriction, including
** without limitation the rights to use, copy, modify, merge, publish,
** distribute, sublicense, and/or sell copies of the Software, and to
** permit persons to whom the Software is furnished to do so, subject to
** the following conditions:
**
** The above copyright notice and this permission notice shall be
** included in all copies or substantial portions of the Software.
**
** THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
** EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
** MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
** IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
** CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
** TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
** SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
**
** [ MIT license: http://www.opensource.org/licenses/mit-license.php ]
--]]


local ffi = require"ffi"
local lpcode = require"lpcode"
local lpprint = require"lpprint"
local lpvm = require"lpvm"

local band, bor, bnot, rshift, lshift = bit.band, bit.bor, bit.bnot, bit.rshift, bit.lshift

ffi.cdef[[
 int isalnum(int c);
 int isalpha(int c);
 int iscntrl(int c);
 int isdigit(int c);
 int isgraph(int c);
 int islower(int c);
 int isprint(int c);
 int ispunct(int c);
 int isspace(int c);
 int isupper(int c);
 int isxdigit(int c);
]]

local MAXBEHIND = 255
local MAXRULES = 200
local VERSION = "0.12.2LJ"

local TChar = 0
local TSet = 1
local TAny = 2 -- standard PEG elements
local TTrue = 3
local TFalse = 4
local TRep = 5
local TSeq = 6
local TChoice = 7
local TNot = 8
local TAnd = 9
local TCall = 10
local TOpenCall = 11
local TRule = 12 -- sib1 is rule's pattern, sib2 is 'next' rule
local TGrammar = 13 -- sib1 is initial (and first) rule
local TBehind = 14 -- match behind
local TCapture = 15 -- regular capture
local TRunTime = 16 -- run-time capture

local IAny = 0 -- if no char, fail
local IChar = 1 -- if char != val, fail
local ISet = 2 -- if char not in val, fail
local ITestAny = 3 -- in no char, jump to 'offset'
local ITestChar = 4 -- if char != val, jump to 'offset'
local ITestSet = 5 -- if char not in val, jump to 'offset'
local ISpan = 6 -- read a span of chars in val
local IBehind = 7 -- walk back 'val' characters (fail if not possible)
local IRet = 8 -- return from a rule
local IEnd = 9 -- end of pattern
local IChoice = 10 -- stack a choice; next fail will jump to 'offset'
local IJmp = 11 -- jump to 'offset'
local ICall = 12 -- call rule at 'offset'
local IOpenCall = 13 -- call rule number 'offset' (must be closed to a ICall)
local ICommit = 14 -- pop choice and jump to 'offset'
local IPartialCommit = 15 -- update top choice to current position and jump
local IBackCommit = 16 -- "fails" but jump to its own 'offset'
local IFailTwice = 17 -- pop one choice and then fail
local IFail = 18 -- go back to saved state on choice and jump to saved offset
local IGiveup = 19 -- internal use
local IFullCapture = 20 -- complete capture of last 'off' chars
local IOpenCapture = 21 -- start a capture
local ICloseCapture = 22
local ICloseRunTime = 23

local Cclose = 0
local Cposition = 1
local Cconst = 2
local Cbackref = 3
local Carg = 4
local Csimple = 5
local Ctable = 6
local Cfunction = 7
local Cquery = 8
local Cstring = 9
local Cnum = 10
local Csubst = 11
local Cfold = 12
local Cruntime = 13
local Cgroup = 14

local PEnullable = 0
local PEnofail = 1
local PEleftrecursion = 2

local newgrammar

local RuleLR = 0x10000
local Ruleused = 0x20000
local BCapcandelete = 0x30000

local LREnable = false

-- number of siblings for each tree
local numsiblings = {
    0, 0, 0, -- char, set, any
    0, 0, -- true, false
    1, -- rep
    2, 2, -- seq, choice
    1, 1, -- not, and
    0, 0, 2, 1, -- call, opencall, rule, grammar
    1, -- behind
    1, 1 -- capture, runtime capture
}



local patternid = 0
local valuetable = {}

local funcnames = setmetatable({}, { __mode = 'k' })

local treepatternelement = ffi.typeof('TREEPATTERN_ELEMENT')
local treepattern = ffi.typeof('TREEPATTERN')
local patternelement = ffi.typeof('PATTERN_ELEMENT')
local pattern = ffi.typeof('PATTERN')
local settype = ffi.typeof('int32_t[8]')
local uint32 = ffi.typeof('uint32_t[1]')

-- Fix a TOpenCall into a TCall node, using table 'postable' to
-- translate a key to its rule address in the tree. Raises an
-- error if key does not exist.

local function fixonecall(postable, grammar, index, valuetable)
    local name = valuetable[grammar.p[index].val] -- get rule's name
    local n = postable[name] -- query name in position table
    if not n then -- no position?
        error(("rule '%s' undefined in given grammar"):format(type(name) == 'table' and '(a table)' or name), 0)
    end
    grammar.p[index].tag = TCall;
    grammar.p[index].ps = n - index -- position relative to node
    grammar.p[index + grammar.p[index].ps].cap = bit.bor(grammar.p[index + grammar.p[index].ps].cap, Ruleused)
end


-- Transform left associative constructions into right
-- associative ones, for sequence and choice; that is:
-- (t11 + t12) + t2  =>  t11 + (t12 + t2)
-- (t11 * t12) * t2  =>  t11 * (t12 * t2)
-- (that is, Op (Op t11 t12) t2 => Op t11 (Op t12 t2))

local function correctassociativity(tree, index)
    local t1 = index + 1
    assert(tree.p[index].tag == TChoice or tree.p[index].tag == TSeq)
    while tree.p[t1].tag == tree.p[index].tag do
        local n1size = tree.p[index].ps - 1; -- t1 == Op t11 t12
        local n11size = tree.p[t1].ps - 1;
        local n12size = n1size - n11size - 1
        for i = 1, n11size do
            ffi.copy(tree.p + index + i, tree.p + t1 + i, ffi.sizeof(treepatternelement))
        end
        tree.p[index].ps = n11size + 1
        tree.p[index + tree.p[index].ps].tag = tree.p[index].tag
        tree.p[index + tree.p[index].ps].ps = n12size + 1
    end
end


-- Make final adjustments in a tree. Fix open calls in tree,
-- making them refer to their respective rules or raising appropriate
-- errors (if not inside a grammar). Correct associativity of associative
-- constructions (making them right associative).

local function finalfix(fix, postable, grammar, index, valuetable)

    local tag = grammar.p[index].tag
    if tag == TGrammar then --subgrammars were already fixed
        return
    elseif tag == TOpenCall then
        if fix then -- inside a grammar?
            fixonecall(postable, grammar, index, valuetable)
        else -- open call outside grammar
            error(("rule '%s' used outside a grammar"):format(tostring(valuetable[grammar.p[index].val])), 0)
        end
    elseif tag == TSeq or tag == TChoice then
        correctassociativity(grammar, index)
    end
    local ns = numsiblings[tag + 1]
    if ns == 0 then
    elseif ns == 1 then
        return finalfix(fix, postable, grammar, index + 1, valuetable)
    elseif ns == 2 then
        finalfix(fix, postable, grammar, index + 1, valuetable)
        return finalfix(fix, postable, grammar, index + grammar.p[index].ps, valuetable)
    else
        assert(false)
    end
end


-- {======================================================
-- Tree generation
-- =======================================================

local function newcharset()
    local tree = treepattern(1)
    valuetable[tree.id] = { settype() }
    tree.p[0].tag = TSet
    tree.p[0].val = 1
    return tree, valuetable[tree.id][1]
end


-- add to tree a sequence where first sibling is 'sib' (with size
-- 'sibsize')

local function seqaux(tree, sib, start, sibsize)
    tree.p[start].tag = TSeq;
    tree.p[start].ps = sibsize + 1
    ffi.copy(tree.p + start + 1, sib.p, ffi.sizeof(treepatternelement) * sibsize)
end


-- Build a sequence of 'n' nodes, each with tag 'tag' and 'val' got
-- from the array 's' (or 0 if array is NULL). (TSeq is binary, so it
-- must build a sequence of sequence of sequence...)

local function fillseq(tree, tag, start, n, s)
    for i = 1, n - 1 do -- initial n-1 copies of Seq tag; Seq ...
        tree.p[start].tag = TSeq
        tree.p[start].ps = 2
        tree.p[start + 1].tag = tag
        if s then
            tree.p[start + 1].val = s:sub(i, i):byte()
        end
        start = start + tree.p[start].ps
    end
    tree.p[start].tag = tag -- last one does not need TSeq
    if s then
        tree.p[start].val = s:sub(n, n):byte()
    end
end


-- Numbers as patterns:
-- 0 == true (always match); n == TAny repeated 'n' times;
-- -n == not (TAny repeated 'n' times)

local function numtree(n)
    if n == 0 then
        local tree = treepattern(1)
        tree.p[0].tag = TTrue
        return tree
    else
        local tree, start
        if n > 0 then
            tree = treepattern(2 * n - 1)
            start = 0
        else -- negative: code it as !(-n)
            n = -n;
            tree = treepattern(2 * n)
            tree.p[0].tag = TNot
            start = 1
        end
        fillseq(tree, TAny, start, n) -- sequence of 'n' any's
        return tree;
    end
end


-- Convert value to a pattern

local function getpatt(val, name)
    local typ = type(val)
    if typ == 'string' then
        if #val == 0 then -- empty?
            local pat = treepattern(1)
            pat.p[0].tag = TTrue -- always match
            return pat
        else
            local tree = treepattern(2 * (#val - 1) + 1)
            fillseq(tree, TChar, 0, #val, val) -- sequence of '#val' chars
            return tree
        end
    elseif typ == 'number' then
        return numtree(val)
    elseif typ == 'boolean' then
        local pat = treepattern(1)
        pat.p[0].tag = val and TTrue or TFalse
        return pat
    elseif typ == 'table' then
        return newgrammar(val)
    elseif typ == 'function' then
        if name and type(name) == 'string' then
            funcnames[val] = name
        end
        local pat = treepattern(2)
        valuetable[pat.id] = { val }
        pat.p[0].tag = TRunTime
        pat.p[0].val = 1
        pat.p[1].tag = TTrue
        return pat
    elseif ffi.istype(treepattern, val) then
        assert(val.treesize > 0)
        return val
    end
    assert(false)
end

local function copykeys(ktable1, ktable2)
    local ktable, offset = {}, 0
    if not ktable1 and not ktable2 then
        return ktable, 0
    elseif ktable1 then
        for i = 1, #ktable1 do
            ktable[#ktable + 1] = ktable1[i]
        end
        offset = #ktable1
        if not ktable2 then
            return ktable, 0
        end
    end
    if ktable2 then
        for i = 1, #ktable2 do
            ktable[#ktable + 1] = ktable2[i]
        end
    end
    return ktable, offset
end

local function correctkeys(tree, index, offset)
    local tag = tree.p[index].tag
    if (tag == TSet or tag == TRule or tag == TCall or tag == TRunTime or tag == TOpenCall or tag == TCapture) and
            tree.p[index].val ~= 0 then
        tree.p[index].val = tree.p[index].val + offset
    end
    local ns = numsiblings[tag + 1]
    if ns == 0 then
    elseif ns == 1 then
        return correctkeys(tree, index + 1, offset)
    elseif ns == 2 then
        correctkeys(tree, index + 1, offset)
        return correctkeys(tree, index + tree.p[index].ps, offset)
    else
        assert(false)
    end
end



-- create a new tree, with a new root and one sibling.

local function newroot1sib(tag, pat)
    local tree1 = getpatt(pat)
    local tree = treepattern(1 + tree1.treesize) -- create new tree
    valuetable[tree.id] = copykeys(valuetable[tree1.id])
    tree.p[0].tag = tag
    ffi.copy(tree.p + 1, tree1.p, ffi.sizeof(treepatternelement) * tree1.treesize)
    return tree
end


-- create a new tree, with a new root and 2 siblings.

local function newroot2sib(tag, pat1, pat2)
    local tree1 = getpatt(pat1)
    local tree2 = getpatt(pat2)
    local tree = treepattern(1 + tree1.treesize + tree2.treesize) -- create new tree
    local ktable, offset = copykeys(valuetable[tree1.id], valuetable[tree2.id])
    valuetable[tree.id] = ktable
    tree.p[0].tag = tag
    tree.p[0].ps = 1 + tree1.treesize
    ffi.copy(tree.p + 1, tree1.p, ffi.sizeof(treepatternelement) * tree1.treesize)
    ffi.copy(tree.p + 1 + tree1.treesize, tree2.p, ffi.sizeof(treepatternelement) * tree2.treesize)
    if offset > 0 then
        correctkeys(tree, 1 + tree1.treesize, offset)
    end
    return tree;
end


local function lp_P(val, name)
    assert(type(val) ~= 'nil')
    return getpatt(val, name)
end


-- sequence operator; optimizations:
-- false x => false, x true => x, true x => x
-- (cannot do x . false => false because x may have runtime captures)

local function lp_seq(pat1, pat2)
    local tree1 = getpatt(pat1)
    local tree2 = getpatt(pat2)
    if tree1.p[0].tag == TFalse or tree2.p[0].tag == TTrue then --  false . x == false, x . true = x
        return tree1
    elseif tree1.p[0].tag == TTrue then -- true . x = x
        return tree2
    else
        return newroot2sib(TSeq, tree1, tree2)
    end
end


-- choice operator; optimizations:
-- charset / charset => charset
-- true / x => true, x / false => x, false / x => x
-- (x / true is not equivalent to true)

local function lp_choice(pat1, pat2)
    local tree1 = getpatt(pat1)
    local tree2 = getpatt(pat2)
    local charset1 = lpcode.tocharset(tree1, 0, valuetable[tree1.id])
    local charset2 = lpcode.tocharset(tree2, 0, valuetable[tree2.id])
    if charset1 and charset2 then
        local t, set = newcharset()
        for i = 0, 7 do
            set[i] = bor(charset1[i], charset2[i])
        end
        return t
    elseif lpcode.checkaux(tree1, PEnofail, 0) or tree2.p[0].tag == TFalse then
        return tree1 -- true / x => true, x / false => x
    elseif tree1.p[0].tag == TFalse then
        return tree2 -- false / x => x
    else
        return newroot2sib(TChoice, tree1, tree2)
    end
end


-- p^n

local function lp_star(tree1, n)
    local tree
    n = tonumber(n)
    assert(type(n) == 'number')
    if n >= 0 then -- seq tree1 (seq tree1 ... (seq tree1 (rep tree1)))
        tree = treepattern((n + 1) * (tree1.treesize + 1))
        if lpcode.checkaux(tree1, PEnullable, 0) then
            error("loop body may accept empty string", 0)
        end
        valuetable[tree.id] = copykeys(valuetable[tree1.id])
        local start = 0
        for i = 1, n do -- repeat 'n' times
            seqaux(tree, tree1, start, tree1.treesize)
            start = start + tree.p[start].ps
        end
        tree.p[start].tag = TRep
        ffi.copy(tree.p + start + 1, tree1.p, ffi.sizeof(treepatternelement) * tree1.treesize)
    else -- choice (seq tree1 ... choice tree1 true ...) true
        n = -n;
        -- size = (choice + seq + tree1 + true) * n, but the last has no seq
        tree = treepattern(n * (tree1.treesize + 3) - 1)
        valuetable[tree.id] = copykeys(valuetable[tree1.id])
        local start = 0
        for i = n, 2, -1 do -- repeat (n - 1) times
            tree.p[start].tag = TChoice;
            tree.p[start].ps = i * (tree1.treesize + 3) - 2
            tree.p[start + tree.p[start].ps].tag = TTrue;
            start = start + 1
            seqaux(tree, tree1, start, tree1.treesize)
            start = start + tree.p[start].ps
        end
        tree.p[start].tag = TChoice;
        tree.p[start].ps = tree1.treesize + 1
        tree.p[start + tree.p[start].ps].tag = TTrue
        ffi.copy(tree.p + start + 1, tree1.p, ffi.sizeof(treepatternelement) * tree1.treesize)
    end
    return tree
end


-- #p == &p

local function lp_and(pat)
    return newroot1sib(TAnd, pat)
end


-- -p == !p

local function lp_not(pat)
    return newroot1sib(TNot, pat)
end


-- [t1 - t2] == Seq (Not t2) t1
-- If t1 and t2 are charsets, make their difference.

local function lp_sub(pat1, pat2)
    local tree1 = getpatt(pat1)
    local tree2 = getpatt(pat2)
    local charset1 = lpcode.tocharset(tree1, 0, valuetable[tree1.id])
    local charset2 = lpcode.tocharset(tree2, 0, valuetable[tree2.id])
    if charset1 and charset2 then
        local tree, set = newcharset()
        for i = 0, 7 do
            set[i] = band(charset1[i], bnot(charset2[i]))
        end
        return tree
    else
        local tree = treepattern(2 + tree1.treesize + tree2.treesize)
        local ktable, offset = copykeys(valuetable[tree2.id], valuetable[tree1.id])
        valuetable[tree.id] = ktable
        tree.p[0].tag = TSeq; -- sequence of...
        tree.p[0].ps = 2 + tree2.treesize
        tree.p[1].tag = TNot; -- ...not...
        ffi.copy(tree.p + 2, tree2.p, ffi.sizeof(treepatternelement) * tree2.treesize)
        ffi.copy(tree.p + tree2.treesize + 2, tree1.p, ffi.sizeof(treepatternelement) * tree1.treesize)
        if offset > 0 then
            correctkeys(tree, 2 + tree2.treesize, offset)
        end
        return tree
    end
end


local function lp_set(val)
    assert(type(val) == 'string')
    local tree, set = newcharset()
    for i = 1, #val do
        local b = val:sub(i, i):byte()
        set[rshift(b, 5)] = bor(set[rshift(b, 5)], lshift(1, band(b, 31)))
    end
    return tree
end


local function lp_range(...)
    local args = { ... }
    local top = #args
    local tree, set = newcharset()
    for i = 1, top do
        assert(#args[i] == 2, args[i] .. " range must have two characters")
        for b = args[i]:sub(1, 1):byte(), args[i]:sub(2, 2):byte() do
            set[rshift(b, 5)] = bor(set[rshift(b, 5)], lshift(1, band(b, 31)))
        end
    end
    return tree
end


-- Look-behind predicate

local function lp_behind(pat)
    local tree1 = getpatt(pat)
    local n = lpcode.fixedlenx(tree1, 0, 0, 0)
    assert(not lpcode.hascaptures(tree1, 0), "pattern have captures")
    assert(n > 0, "pattern may not have fixed length")
    assert(n <= MAXBEHIND, "pattern too long to look behind")
    local tree = newroot1sib(TBehind, pat)
    tree.p[0].val = n;
    return tree
end


-- Create a non-terminal

local function lp_V(val, p)
    assert(val, "non-nil value expected")
    local tree = treepattern(1)
    valuetable[tree.id] = { val }
    tree.p[0].tag = TOpenCall
    tree.p[0].val = 1
    tree.p[0].cap = p or 0
    return tree
end


-- Create a tree for a non-empty capture, with a body and
-- optionally with an associated value

local function capture_aux(cap, pat, val)
    local tree = newroot1sib(TCapture, pat)
    tree.p[0].cap = cap
    if val then
        local ind = #valuetable[tree.id] + 1
        valuetable[tree.id][ind] = val
        tree.p[0].val = ind
    end
    return tree
end


-- Fill a tree with an empty capture, using an empty (TTrue) sibling.

local function auxemptycap(tree, cap, par, start)
    tree.p[start].tag = TCapture;
    tree.p[start].cap = cap
    if type(par) ~= 'nil' then
        local ind = #valuetable[tree.id] + 1
        valuetable[tree.id][ind] = par
        tree.p[start].val = ind
    end
    tree.p[start + 1].tag = TTrue;
end


-- Create a tree for an empty capture

local function newemptycap(cap, par)
    local tree = treepattern(2)
    if type(par) ~= 'nil' then valuetable[tree.id] = {} end
    auxemptycap(tree, cap, par, 0)
    return tree
end


-- Captures with syntax p / v
-- (function capture, query capture, string capture, or number capture)

local function lp_divcapture(pat, par, xxx)
    local typ = type(par)
    if typ == "function" then
        return capture_aux(Cfunction, pat, par)
    elseif typ == "table" then
        return capture_aux(Cquery, pat, par)
    elseif typ == "string" then
        return capture_aux(Cstring, pat, par)
    elseif typ == "number" then
        local tree = newroot1sib(TCapture, pat)
        assert(0 <= par and par <= 0xffff, "invalid number")
        tree.p[0].cap = Cnum;
        local ind = #valuetable[tree.id] + 1
        valuetable[tree.id][ind] = par
        tree.p[0].val = ind
        return tree
    else
        error("invalid replacement value", 0)
    end
end


local function lp_substcapture(pat)
    return capture_aux(Csubst, pat, 0)
end


local function lp_tablecapture(pat)
    return capture_aux(Ctable, pat, 0)
end


local function lp_groupcapture(pat, val)
    if not val then
        return capture_aux(Cgroup, pat, 0)
    else
        return capture_aux(Cgroup, pat, val)
    end
end


local function lp_foldcapture(pat, fce)
    assert(type(fce) == 'function')
    return capture_aux(Cfold, pat, fce)
end


local function lp_simplecapture(pat)
    return capture_aux(Csimple, pat, 0)
end


local function lp_poscapture()
    return newemptycap(Cposition, 0)
end


local function lp_argcapture(val)
    assert(type(val) == 'number')
    local tree = newemptycap(Carg, 0)
    local ind = #valuetable[tree.id] + 1
    valuetable[tree.id][ind] = val
    tree.p[0].val = ind
    assert(0 < val and val <= 0xffff, "invalid argument index")
    return tree
end


local function lp_backref(val)
    assert(type(val) == 'string')
    return newemptycap(Cbackref, val)
end


-- Constant capture

local function lp_constcapture(...)
    local tree
    local args = { ... }
    local n = select('#', ...) -- number of values
    if n == 0 then -- no values?
        tree = treepattern(1) -- no capture
        tree.p[0].tag = TTrue
    elseif n == 1 then
        tree = newemptycap(Cconst, args[1]) -- single constant capture
    else -- create a group capture with all values
        tree = treepattern(3 + 3 * (n - 1))
        valuetable[tree.id] = { 0 }
        tree.p[0].tag = TCapture
        tree.p[0].cap = Cgroup
        tree.p[0].val = 1
        local start = 1
        for i = 1, n - 1 do
            tree.p[start].tag = TSeq
            tree.p[start].ps = 3
            auxemptycap(tree, Cconst, args[i], start + 1)
            start = start + tree.p[start].ps
        end
        auxemptycap(tree, Cconst, args[n], start)
    end
    return tree
end


local function lp_matchtime(pat, fce, name)
    assert(type(fce) == 'function')
    if name and type(name) == 'string' then
        funcnames[fce] = name
    end
    local tree = newroot1sib(TRunTime, pat)
    local ind = #valuetable[tree.id] + 1
    valuetable[tree.id][ind] = fce
    tree.p[0].val = ind
    return tree
end

-- ======================================================



-- ======================================================
-- Grammar - Tree generation
-- =======================================================


-- return index and the pattern for the
-- initial rule of grammar;
-- also add that index into position table.

local function getfirstrule(pat, postab)
    local key
    if type(pat[1]) == 'string' then -- access first element
        key = pat[1]
    else
        key = 1
    end
    local rule = pat[key]
    if not rule then
        error("grammar has no initial rule", 0)
    end
    if not ffi.istype(treepattern, rule) then -- initial rule not a pattern?
        error(("initial rule '%s' is not a pattern"):format(tostring(key)), 0)
    end
    postab[key] = 1
    return key, rule
end


-- traverse grammar, collect  all its keys and patterns
-- into rule table. Create a new table (before all pairs key-pattern) to
-- collect all keys and their associated positions in the final tree
-- (the "position table").
-- Return the number of rules and the total size
-- for the new tree.

local function collectrules(pat)
    local n = 1; -- to count number of rules
    local postab = {}
    local firstkeyrule, firstrule = getfirstrule(pat, postab)
    local rules = { firstkeyrule, firstrule }
    local size = 2 + firstrule.treesize -- TGrammar + TRule + rule
    for key, val in pairs(pat) do
        if key ~= 1 and tostring(val) ~= tostring(firstrule) then -- initial rule?
            if not ffi.istype(treepattern, val) then -- value is not a pattern?
                error(("rule '%s' is not a pattern"):format(tostring(key)), 0)
            end
            rules[#rules + 1] = key
            rules[#rules + 1] = val
            postab[key] = size
            size = 1 + size + val.treesize
            n = n + 1
        end
    end
    size = size + 1; -- TTrue to finish list of rules
    return n, size, rules, postab
end


local function buildgrammar(grammar, rules, n, index, valuetable)
    local ktable, offset = {}, 0
    for i = 1, n do -- add each rule into new tree
        local size = rules[i * 2].treesize
        grammar.p[index].tag = TRule;
        grammar.p[index].cap = i; -- rule number
        grammar.p[index].ps = size + 1; -- point to next rule
        local ind = #ktable + 1
        ktable[ind] = rules[i * 2 - 1]
        grammar.p[index].val = ind
        ffi.copy(grammar.p + index + 1, rules[i * 2].p, ffi.sizeof(treepatternelement) * size) -- copy rule
        ktable, offset = copykeys(ktable, valuetable[rules[i * 2].id])
        if offset > 0 then
            correctkeys(grammar, index + 1, offset)
        end
        index = index + grammar.p[index].ps; -- move to next rule
    end
    grammar.p[index].tag = TTrue; -- finish list of rules
    return ktable
end


-- Check whether a tree has potential infinite loops

local function checkloops(tree, index)
    local tag = tree.p[index].tag
    if tag == TRep and lpcode.checkaux(tree, PEnullable, index + 1) then
        return true
    elseif tag == TGrammar then
        return -- sub-grammars already checked
    else
        local tag = numsiblings[tree.p[index].tag + 1]
        if tag == 0 then
            return
        elseif tag == 1 then
            return checkloops(tree, index + 1)
        elseif tag == 2 then
            if checkloops(tree, index + 1) then
                return true
            else
                return checkloops(tree, index + tree.p[index].ps)
            end
        else
            assert(false)
        end
    end
end

-- Check whether a rule can be left recursive; returns PEleftrecursion in that
-- case; otherwise return 1 iff pattern is nullable.

local function verifyrule(rulename, tree, passed, nullable, index, valuetable)
    local tag = tree.p[index].tag
    if tag == TChar or tag == TSet or tag == TAny or tag == TFalse then
        return nullable; -- cannot pass from here
    elseif tag == TTrue or tag == TBehind then
        return true;
    elseif tag == TNot or tag == TAnd or tag == TRep then
        return verifyrule(rulename, tree, passed, true, index + 1, valuetable)
    elseif tag == TCapture or tag == TRunTime then
        return verifyrule(rulename, tree, passed, nullable, index + 1, valuetable)
    elseif tag == TCall then
        local rule = valuetable[tree.p[index].val]
        if rule == rulename then return PEleftrecursion end
        if passed[rule] and passed[rule] > MAXRULES then
            return nullable
        end
        return verifyrule(rulename, tree, passed, nullable, index + tree.p[index].ps, valuetable)
    elseif tag == TSeq then -- only check 2nd child if first is nullable
        local res = verifyrule(rulename, tree, passed, false, index + 1, valuetable)
        if res == PEleftrecursion then
            return res
        elseif not res then
            return nullable
        else
            return verifyrule(rulename, tree, passed, nullable, index + tree.p[index].ps, valuetable)
        end
    elseif tag == TChoice then -- must check both children
        nullable = verifyrule(rulename, tree, passed, nullable, index + 1, valuetable)
        if nullable == PEleftrecursion then return nullable end
        return verifyrule(rulename, tree, passed, nullable, index + tree.p[index].ps, valuetable)
    elseif tag == TRule then
        local rule = valuetable[tree.p[index].val]
        passed[rule] = (passed[rule] or 0) + 1
        return verifyrule(rulename, tree, passed, nullable, index + 1, valuetable)
    elseif tag == TGrammar then
        return lpcode.checkaux(tree, PEnullable, index) -- sub-grammar cannot be left recursive
    else
        assert(false)
    end
end


local function verifygrammar(rule, index, valuetable)
    -- check left-recursive rules
    local LR = {}
    local ind = index + 1
    while rule.p[ind].tag == TRule do
        local rulename = valuetable[rule.p[ind].val]
        if rulename then -- used rule
            if verifyrule(rulename, rule, {}, false, ind + 1, valuetable) == PEleftrecursion then
                if not LREnable then
                    error(("rule '%s' may be left recursive"):format(rulename), 0)
                end
                LR[rulename] = true
            end
        end
        ind = ind + rule.p[ind].ps
    end
    assert(rule.p[ind].tag == TTrue)

    for i = 0, rule.treesize - 1 do
        if rule.p[i].tag == TRule and LR[valuetable[rule.p[i].val]] then
            rule.p[i].cap = bor(rule.p[i].cap, RuleLR) --TRule can be left recursive
        end
        if rule.p[i].tag == TCall and LR[valuetable[rule.p[i].val]] then
            if rule.p[i].cap == 0 then
                rule.p[i].cap = 1 --TCall can be left recursive
            end
        end
    end

    -- check infinite loops inside rules
    ind = index + 1
    while rule.p[ind].tag == TRule do
        if rule.p[ind].val then -- used rule
            if checkloops(rule, ind + 1) then
                error(("empty loop in rule '%s'"):format(tostring(valuetable[rule.p[ind].val])), 0)
            end
        end
        ind = ind + rule.p[ind].ps
    end
    assert(rule.p[ind].tag == TTrue)
end


-- Give a name for the initial rule if it is not referenced

local function initialrulename(grammar, val, valuetable)
    grammar.p[1].cap = bit.bor(grammar.p[1].cap, Ruleused)
    if grammar.p[1].val == 0 then -- initial rule is not referenced?
        local ind = #valuetable + 1
        valuetable[ind] = val
        grammar.p[1].val = ind
    end
end


function newgrammar(pat)
    -- traverse grammar. Create a new table (before all pairs key-pattern) to
    -- collect all keys and their associated positions in the final tree
    -- (the "position table").
    -- Return new tree.

    local n, size, rules, postab = collectrules(pat)
    local grammar = treepattern(size)
    local start = 0
    grammar.p[start].tag = TGrammar
    grammar.p[start].val = n
    valuetable[grammar.id] = buildgrammar(grammar, rules, n, start + 1, valuetable)
    finalfix(true, postab, grammar, start + 1, valuetable[grammar.id])
    initialrulename(grammar, rules[1], valuetable[grammar.id])
    verifygrammar(grammar, 0, valuetable[grammar.id])
    return grammar
end

-- ======================================================

-- remove duplicity from value table

local function reducevaluetable(p)
    local vtable = valuetable[p.id]
    local value = {}
    local newvaluetable = {}

    local function check(v)
        if v > 0 then
            local ord = value[vtable[v]]
            if not ord then
                newvaluetable[#newvaluetable + 1] = vtable[v]
                ord = #newvaluetable
                value[vtable[v]] = ord
            end
            return ord
        end
        return 0
    end

    local function itertree(p, index)
        local tag = p.p[index].tag
        if tag == TSet or tag == TCall or tag == TOpenCall or
                tag == TRule or tag == TCapture or tag == TRunTime then
            p.p[index].val = check(p.p[index].val)
        end
        local ns = numsiblings[tag + 1]
        if ns == 0 then
        elseif ns == 1 then
            return itertree(p, index + 1)
        elseif ns == 2 then
            itertree(p, index + 1)
            return itertree(p, index + p.p[index].ps)
        else
            assert(false)
        end
    end

    if p.treesize > 0 then
        itertree(p, 0)
    end
    if p.code ~= nil then
        for i = 0, p.code.size - 1 do
            local code = p.code.p[i].code
            if code == ICall or code == IJmp then
                p.code.p[i].aux = check(p.code.p[i].aux)
            elseif code == ISet or code == ITestSet or code == ISpan then
                p.code.p[i].val = check(p.code.p[i].val)
            elseif code == IOpenCapture or code == IFullCapture then
                p.code.p[i].offset = check(p.code.p[i].offset)
            end
        end
    end
    valuetable[p.id] = newvaluetable
end


local function checkalt(tree)
    local notchecked = {}
    local notinalternativerules = {}

    local function iter(tree, index, choice, rule)
        local tag = tree[index].tag
        if tag == TCapture and bit.band(tree[index].cap, 0xffff) == Cgroup then
            if not choice then
                if rule then
                    notchecked[rule] = index
                end
            else
                tree[index].cap = bit.bor(tree[index].cap, BCapcandelete)
            end
        elseif tag == TChoice then
            choice = true
        elseif tag == TRule then
            rule = tree[index].val
            if bit.band(tree[index].cap, 0xffff) - 1 == 0 then
                notinalternativerules[rule] = notinalternativerules[rule] or true
            end
        elseif tag == TCall then
            local r = tree[index].val
            if not choice then
                notinalternativerules[r] = notinalternativerules[r] or true
            end
        end
        local sibs = numsiblings[tree[index].tag + 1] or 0
        if sibs >= 1 then
            iter(tree, index + 1, choice, rule)
            if sibs >= 2 then
                iter(tree, index + tree[index].ps, choice, rule)
            end
        end
    end

    iter(tree, 0)
    for k, v in pairs(notchecked) do
        if not notinalternativerules[k] then
            tree[v].cap = bit.bor(tree[v].cap, BCapcandelete)
        end
    end
end


local function prepcompile(p, index)
    finalfix(false, nil, p, index, valuetable[p.id])
    checkalt(p.p)
    lpcode.compile(p, index, valuetable[p.id])
    reducevaluetable(p)
    return p.code
end


local function lp_printtree(pat, c)
    assert(pat.treesize > 0)
    if c then
        finalfix(false, nil, pat, 0, valuetable[pat.id])
    end
    lpprint.printtree(pat.p, 0, 0, valuetable[pat.id])
end


local function lp_printcode(pat)
    if pat.code == nil then -- not compiled yet?
        prepcompile(pat, 0)
    end
    lpprint.printpatt(pat.code, valuetable[pat.id])
end


-- Main match function

local function lp_match(pat, s, init, ...)
    local p = ffi.istype(treepattern, pat) and pat or getpatt(pat)
    p.code = p.code ~= nil and p.code or prepcompile(p, 0)
    return lpvm.match(p, s, init, valuetable[p.id], ...)
end

local function lp_streammatch(pat, init, ...)
    local p = ffi.istype(treepattern, pat) and pat or getpatt(pat)
    p.code = p.code ~= nil and p.code or prepcompile(p, 0)
    return lpvm.streammatch(p, init, valuetable[p.id], ...)
end

-- Only for testing purpose
local function lp_emulatestreammatch(pat, s, init, ...) -- stream emulation (send all chars from string one char after char)
    local p = ffi.istype(treepattern, pat) and pat or getpatt(pat)
    p.code = p.code ~= nil and p.code or prepcompile(p, 0)
    return lpvm.emulatestreammatch(p, s, init, valuetable[p.id], ...)
end

-- {======================================================
-- Library creation and functions not related to matching
-- =======================================================

local function lp_setmax(val)
    lpvm.setmax(val)
end

local function lp_setmaxbehind(val)
    lpvm.setmaxbehind(val)
end

local function lp_enableleftrecursion(val)
    LREnable = val
end

local function lp_version()
    return VERSION
end


local function lp_type(pat)
    if ffi.istype(treepattern, pat) then
        return "pattern"
    end
end


local function createcat(tab, catname, catfce)
    local t, set = newcharset()
    for i = 0, 255 do
        if catfce(i) ~= 0 then
            set[rshift(i, 5)] = bor(set[rshift(i, 5)], lshift(1, band(i, 31)))
        end
    end
    tab[catname] = t
end


local function lp_locale(tab)
    tab = tab or {}
    createcat(tab, "alnum", function(c) return ffi.C.isalnum(c) end)
    createcat(tab, "alpha", function(c) return ffi.C.isalpha(c) end)
    createcat(tab, "cntrl", function(c) return ffi.C.iscntrl(c) end)
    createcat(tab, "digit", function(c) return ffi.C.isdigit(c) end)
    createcat(tab, "graph", function(c) return ffi.C.isgraph(c) end)
    createcat(tab, "lower", function(c) return ffi.C.islower(c) end)
    createcat(tab, "print", function(c) return ffi.C.isprint(c) end)
    createcat(tab, "punct", function(c) return ffi.C.ispunct(c) end)
    createcat(tab, "space", function(c) return ffi.C.isspace(c) end)
    createcat(tab, "upper", function(c) return ffi.C.isupper(c) end)
    createcat(tab, "xdigit", function(c) return ffi.C.isxdigit(c) end)
    return tab
end


local function lp_new(ct, size)
    local pat = ffi.new(ct, size)
    pat.treesize = size
    patternid = patternid + 1
    pat.id = patternid
    return pat
end


local function lp_gc(ct)
    valuetable[ct.id] = nil
    if ct.code ~= nil then
        ffi.C.free(ct.code.p)
        ffi.C.free(ct.code)
    end
end

local function lp_eq(ct1, ct2)
    return tostring(ct1) == tostring(ct2)
end

local function lp_load(str, fcetab)
    local pat, t = lpvm.load(str, fcetab, true)
    valuetable[pat.id] = t
    return pat
end

local function lp_loadfile(fname, fcetab)
    local pat, t = lpvm.loadfile(fname, fcetab, true)
    valuetable[pat.id] = t
    return pat
end

local function lp_dump(ct, tree)
    local funccount = 0
    if ct.code == nil then -- not compiled yet?
        prepcompile(ct, 0)
    end
    local out = {}
    if tree then
        out[#out + 1] = ffi.string(uint32(ct.treesize), 4)
        out[#out + 1] = ffi.string(ct.p, ffi.sizeof(treepatternelement) * ct.treesize)
    else
        out[#out + 1] = ffi.string(uint32(0), 4)
    end
    out[#out + 1] = ffi.string(uint32(ct.code.size), 4)
    out[#out + 1] = ffi.string(ct.code.p, ct.code.size * ffi.sizeof(patternelement))
    local t = valuetable[ct.id]
    local len = t and #t or 0
    out[#out + 1] = ffi.string(uint32(len), 4)
    if len > 0 then
        for _, val in ipairs(t) do
            local typ = type(val)
            if typ == 'string' then
                out[#out + 1] = 'str'
                out[#out + 1] = ffi.string(uint32(#val), 4)
                out[#out + 1] = val
            elseif typ == 'number' then
                local val = tostring(val)
                out[#out + 1] = 'num'
                out[#out + 1] = ffi.string(uint32(#val), 4)
                out[#out + 1] = val
            elseif typ == 'cdata' then
                out[#out + 1] = 'cdt'
                out[#out + 1] = ffi.string(val, ffi.sizeof(val))
            elseif typ == 'function' then
                out[#out + 1] = 'fnc'
                funccount = funccount + 1
                local name = funcnames[val] or ('FNAME%03d'):format(funccount)
                out[#out + 1] = ffi.string(uint32(#name), 4)
                out[#out + 1] = name
                if not funcnames[val] and debug.getupvalue(val, 1) then
                    io.write(("Patterns function (%d) contains upvalue (%s) - use symbol name for function (%s).\n"):format(funccount, debug.getupvalue(val, 1), name), 0)
                end
                local data = string.dump(val, true)
                out[#out + 1] = ffi.string(uint32(#data), 4)
                out[#out + 1] = data
            else
                error(("Type '%s' NYI for dump"):format(typ), 0)
            end
        end
    end
    return table.concat(out)
end

local function lp_save(ct, fname, tree)
    local file = assert(io.open(fname, 'wb'))
    file:write(lp_dump(ct, tree))
    file:close()
end


local pattreg = {
    ["ptree"] = lp_printtree,
    ["pcode"] = lp_printcode,
    ["match"] = lp_match,
    ["streammatch"] = lp_streammatch,
    ["emulatestreammatch"] = lp_emulatestreammatch,
    ["setmaxbehind"] = lp_setmaxbehind,
    ["B"] = lp_behind,
    ["V"] = lp_V,
    ["C"] = lp_simplecapture,
    ["Cc"] = lp_constcapture,
    ["Cmt"] = lp_matchtime,
    ["Cb"] = lp_backref,
    ["Carg"] = lp_argcapture,
    ["Cp"] = lp_poscapture,
    ["Cs"] = lp_substcapture,
    ["Ct"] = lp_tablecapture,
    ["Cf"] = lp_foldcapture,
    ["Cg"] = lp_groupcapture,
    ["P"] = lp_P,
    ["S"] = lp_set,
    ["R"] = lp_range,
    ["L"] = lp_and,
    ["locale"] = lp_locale,
    ["version"] = lp_version,
    ["setmaxstack"] = lp_setmax,
    ["type"] = lp_type,
    ["enableleftrecursion"] = lp_enableleftrecursion,
    ["enablememoization"] = lpvm.enablememoization,
    ["enabletracing"] = lpvm.enabletracing,
    ["save"] = lp_save,
    ["dump"] = lp_dump,
    ["load"] = lp_load,
    ["loadfile"] = lp_loadfile,
    ["__mul"] = lp_seq,
    ["__add"] = lp_choice,
    ["__pow"] = lp_star,
    ["__len"] = lp_and,
    ["__div"] = lp_divcapture,
    ["__unm"] = lp_not,
    ["__sub"] = lp_sub,
}

local metareg = {
    ["__gc"] = lp_gc,
    ["__new"] = lp_new,
    ["__mul"] = lp_seq,
    ["__add"] = lp_choice,
    ["__pow"] = lp_star,
    ["__len"] = lp_and,
    ["__div"] = lp_divcapture,
    ["__unm"] = lp_not,
    ["__sub"] = lp_sub,
    ["__eq"] = lp_eq,
    ["__index"] = pattreg
}

ffi.metatype(treepattern, metareg)

return pattreg
