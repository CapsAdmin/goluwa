--[[
LPEGLJ
lpprint.lua
Tree, code and debug print function (only for debuging)
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
local band, rshift, lshift = bit.band, bit.rshift, bit.lshift

ffi.cdef[[
  int isprint ( int c );
]]

local RuleLR = 0x10000
local Ruleused = 0x20000

-- {======================================================
-- Printing patterns (for debugging)
-- =======================================================

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
local IChar = 1 -- if char != aux, fail
local ISet = 2 -- if char not in val, fail
local ITestAny = 3 -- in no char, jump to 'offset'
local ITestChar = 4 -- if char != aux, jump to 'offset'
local ITestSet = 5 -- if char not in val, jump to 'offset'
local ISpan = 6 -- read a span of chars in val
local IBehind = 7 -- walk back 'aux' characters (fail if not possible)
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


-- number of siblings for each tree
local numsiblings = {
    [TRep] = 1,
    [TSeq] = 2,
    [TChoice] = 2,
    [TNot] = 1,
    [TAnd] = 1,
    [TRule] = 2,
    [TGrammar] = 1,
    [TBehind] = 1,
    [TCapture] = 1,
    [TRunTime] = 1,
}
local names = {
    [IAny] = "any",
    [IChar] = "char",
    [ISet] = "set",
    [ITestAny] = "testany",
    [ITestChar] = "testchar",
    [ITestSet] = "testset",
    [ISpan] = "span",
    [IBehind] = "behind",
    [IRet] = "ret",
    [IEnd] = "end",
    [IChoice] = "choice",
    [IJmp] = "jmp",
    [ICall] = "call",
    [IOpenCall] = "open_call",
    [ICommit] = "commit",
    [IPartialCommit] = "partial_commit",
    [IBackCommit] = "back_commit",
    [IFailTwice] = "failtwice",
    [IFail] = "fail",
    [IGiveup] = "giveup",
    [IFullCapture] = "fullcapture",
    [IOpenCapture] = "opencapture",
    [ICloseCapture] = "closecapture",
    [ICloseRunTime] = "closeruntime"
}

local function printcharset(st)
    io.write("[");
    local i = 0
    while i <= 255 do
        local first = i;
        while band(st[rshift(i, 5)], lshift(1, band(i, 31))) ~= 0 and i <= 255 do
            i = i + 1
        end
        if i - 1 == first then -- unary range?
            io.write(("(%02x)"):format(first))
        elseif i - 1 > first then -- non-empty range?
            io.write(("(%02x-%02x)"):format(first, i - 1))
        end
        i = i + 1
    end
    io.write("]")
end

local modes = {
    [Cclose] = "close",
    [Cposition] = "position",
    [Cconst] = "constant",
    [Cbackref] = "backref",
    [Carg] = "argument",
    [Csimple] = "simple",
    [Ctable] = "table",
    [Cfunction] = "function",
    [Cquery] = "query",
    [Cstring] = "string",
    [Cnum] = "num",
    [Csubst] = "substitution",
    [Cfold] = "fold",
    [Cruntime] = "runtime",
    [Cgroup] = "group"
}

local function printcapkind(kind)
    io.write(("%s"):format(modes[kind]))
end

local function printjmp(p, index)
    io.write(("-> %d"):format(index + p[index].offset))
end

local function printrulename(p, index, rulenames)
    if rulenames and rulenames[index + p[index].offset] then
        io.write(' ', rulenames[index + p[index].offset])
    end
end

local function printinst(p, index, valuetable, rulenames)
    local code = p[index].code
    if rulenames and rulenames[index] then
        io.write(rulenames[index], '\n')
    end
    io.write(("%04d: %s "):format(index, names[code]))
    if code == IChar then
        io.write(("'%s'"):format(string.char(p[index].val)))
    elseif code == ITestChar then
        io.write(("'%s'"):format(string.char(p[index].val)))
        printjmp(p, index)
        printrulename(p, index, rulenames)
    elseif code == IFullCapture then
        printcapkind(band(p[index].val, 0x0f));
        io.write((" (size = %d)  (idx = %s)"):format(band(rshift(p[index].val, 4), 0xF), tostring(valuetable[p[index].offset])))
    elseif code == IOpenCapture then
        printcapkind(band(p[index].val, 0x0f))
        io.write((" (idx = %s)"):format(tostring(valuetable[p[index].offset])))
    elseif code == ISet then
        printcharset(valuetable[p[index].val]);
    elseif code == ITestSet then
        printcharset(valuetable[p[index].val])
        printjmp(p, index);
        printrulename(p, index, rulenames)
    elseif code == ISpan then
        printcharset(valuetable[p[index].val]);
    elseif code == IOpenCall then
        io.write(("-> %d"):format(p[index].offset))
    elseif code == IBehind then
        io.write(("%d"):format(p[index].val))
    elseif code == IJmp or code == ICall or code == ICommit or code == IChoice or
            code == IPartialCommit or code == IBackCommit or code == ITestAny then
        printjmp(p, index);
        if (code == ICall or code == IJmp) and p[index].aux > 0 then
            io.write(' ', valuetable[p[index].aux])
        else
            printrulename(p, index, rulenames)
        end
    end
    io.write("\n")
end


local function printpatt(p, valuetable)
    local ruleNames = {}
    for i = 0, p.size - 1 do
        local code = p.p[i].code
        if (code == ICall or code == IJmp) and p.p[i].aux > 0 then
            local index = i + p.p[i].offset
            ruleNames[index] = valuetable[p.p[i].aux]
        end
    end
    for i = 0, p.size - 1 do
        printinst(p.p, i, valuetable, ruleNames)
    end
end


local function printcap(cap, index, valuetable)
    printcapkind(cap[index].kind)
    io.write((" (idx: %s - size: %d) -> %d\n"):format(valuetable[cap[index].idx], cap[index].siz, cap[index].s))
end


local function printcaplist(cap, limit, valuetable)
    io.write(">======\n")
    local index = 0
    while cap[index].s and index < limit do
        printcap(cap, index, valuetable)
        index = index + 1
    end
    io.write("=======\n")
end

-- ======================================================



-- {======================================================
-- Printing trees (for debugging)
-- =======================================================

local tagnames = {
    [TChar] = "char",
    [TSet] = "set",
    [TAny] = "any",
    [TTrue] = "true",
    [TFalse] = "false",
    [TRep] = "rep",
    [TSeq] = "seq",
    [TChoice] = "choice",
    [TNot] = "not",
    [TAnd] = "and",
    [TCall] = "call",
    [TOpenCall] = "opencall",
    [TRule] = "rule",
    [TGrammar] = "grammar",
    [TBehind] = "behind",
    [TCapture] = "capture",
    [TRunTime] = "run-time"
}


local function printtree(tree, ident, index, valuetable)
    for i = 1, ident do
        io.write(" ")
    end
    local tag = tree[index].tag
    io.write(("%s"):format(tagnames[tag]))
    if tag == TChar then
        local c = tree[index].val
        if ffi.C.isprint(c) then
            io.write((" '%c'\n"):format(c))
        else
            io.write((" (%02X)\n"):format(c))
        end
    elseif tag == TSet then
        printcharset(valuetable[tree[index].val]);
        io.write("\n")
    elseif tag == TOpenCall or tag == TCall then
        io.write((" key: %s\n"):format(tostring(valuetable[tree[index].val])))
    elseif tag == TBehind then
        io.write((" %d\n"):format(tree[index].val))
        printtree(tree, ident + 2, index + 1, valuetable);
    elseif tag == TCapture then
        io.write((" cap: %s   n: %s\n"):format(modes[bit.band(tree[index].cap, 0xffff)], valuetable[tree[index].val]))
        printtree(tree, ident + 2, index + 1, valuetable);
    elseif tag == TRule then
        local extra = bit.band(tree[index].cap, RuleLR) == RuleLR and ' left recursive' or ''
        extra = extra .. (bit.band(tree[index].cap, Ruleused) ~= Ruleused and ' not used' or '')
        io.write((" n: %d  key: %s%s\n"):format(bit.band(tree[index].cap, 0xffff) - 1, valuetable[tree[index].val], extra))
        printtree(tree, ident + 2, index + 1, valuetable);
        -- do not print next rule as a sibling
    elseif tag == TGrammar then
        local ruleindex = index + 1
        io.write((" %d\n"):format(tree[index].val)) -- number of rules
        for i = 1, tree[index].val do
            printtree(tree, ident + 2, ruleindex, valuetable);
            ruleindex = ruleindex + tree[ruleindex].ps
        end
        assert(tree[ruleindex].tag == TTrue); -- sentinel
    else
        local sibs = numsiblings[tree[index].tag] or 0
        io.write("\n")
        if sibs >= 1 then
            printtree(tree, ident + 2, index + 1, valuetable);
            if sibs >= 2 then
                printtree(tree, ident + 2, index + tree[index].ps, valuetable)
            end
        end
    end
end

-- }====================================================== */

return {
    printtree = printtree,
    printpatt = printpatt,
    printcaplist = printcaplist,
    printinst = printinst
}