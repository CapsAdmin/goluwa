-- Copyright (C) 2014 Chris Emerson <github@mail.nosreme.org>
-- See LICENSE for details (MIT license).

-- Support for regular expressions (parsed and implemented with LPeg).
local M = {}

local lpeg = require('lpeglj')
local P = lpeg.P
local R = lpeg.R
local S = lpeg.S
local C = lpeg.C
local V = lpeg.V
local B = lpeg.B
local Carg = lpeg.Carg
local Cb = lpeg.Cb
local Cc = lpeg.Cc
local Cf = lpeg.Cf
local Cp = lpeg.Cp
local Cg = lpeg.Cg
local Ct = lpeg.Ct
local Cmt = lpeg.Cmt

-- We use the algorithm to convert from a regular expression to a Peg
-- expression from:
-- http://www.inf.puc-rio.br/~roberto/docs/ry10-01.pdf

local function sub1(x)
    return x - 1
end

-- Parts of a regular expression, returning an LPEG pattern which matches it.
local _start = Cg(Cp(), "_start")
local _end = Cg(Cp()/sub1, "_end")
local mt = {
    __index = {
        match = function(t, s, index)
            local result = t._pat:match(s, index)

            if result == nil then return result end
            -- Post-process to put the matches into a nicer form
            local groups = nil
            for k,v in pairs(result) do
                if k:sub(1,1) == "s" then
                    local grpname= k:sub(2)
                    local endpos = result["e"..grpname]
                    if v and endpos then
                        if grpname:match("(%d+)") then
                            grpname = tonumber(grpname)
                        end
                        groups = groups or {}
                        groups[grpname] = {v,endpos}
                        result[k] = nil
                        result["e"..grpname] = nil
                    end
                end
            end
            result.groups = groups
            return result
        end,
    },
}

-- Make special character sets
local function make_b_s()
    return { { " \t\v\n\r", [0]="set" }, [0]="charset" }
end
local function make_b_S()
    return { { " \t\v\n\r", [0]="set" }, [0]="charset",
             negate=true}
end
local function make_b_w()
    return { [0]="charset",
             { [0]="range", "a", "z" },
             { [0]="range", "A", "Z" },
             { [0]="char", "_" },
           }
end
local function make_b_W()
    return { [0]="charset",
             { [0]="range", "a", "z" },
             { [0]="range", "A", "Z" },
             { [0]="char", "_" },
             negate=true
           }
end
local function make_b_d()
    return { [0]="charset",
             { [0]="range", "0", "9" },
           }
end
local function make_b_D()
    return { [0]="charset",
             { [0]="range", "0", "9" },
             negate=true,
           }
end

local special = S"()\\?*+|."
local any = P"." * Cc({[0] = "."})

-- Perl-style character classes
local b_s = P"\\s" / make_b_s
local b_S = P"\\S" / make_b_S
local b_w = P"\\w" / make_b_w
local b_W = P"\\W" / make_b_W
local b_d = P"\\d" / make_b_d
local b_D = P"\\D" / make_b_D

local backcharset = b_s + b_S + b_w + b_W + b_d + b_D
local charset_special = S"]-"
local charset_char = C(P(1) - charset_special) /
     function(c) return { [0] = "char", c } end
local range = (C(P(1) - charset_special) * P"-" * C(P(1) - charset_special)) /
            function(a,b) return { [0]="range", a, b } end
local charset = (P"[" *
                 Ct((Cg(P"^"*Cc(true), "negate") + P(0))
                 * (range + charset_char)^0) *
                 P"]") /
    function(x) x[0] = "charset" return x end
local char = C(P(1) - special) / function(c) return { [0] = "char", c } end
local escapechar = (P"\\" * C(special)) / function(c) return { [0] = "char", c } end
local backref = (P"\\" * C(R"19")) / function(c) return { tonumber(c), [0] = "backref" } end

local wordchar = R("AZ", "az") + S("_")
local nonwordchar = 1 - wordchar

-- word boundaries
local word_start = P"\\<" * Cc({[0] = "\\<"})
local word_end = P"\\>" * Cc({[0] = "\\>"})

-- Grouping
local newgrp = (Cb("groups") * Cp()) /
                   function(groups, pos)
                      local grp = #groups+1
                      groups[grp] = {pos}
                      groups.open[#groups.open] = grp
                   end

-- endgrp leaves the group number or name as a capture
local endgrp = (Cb("groups") * Cp()) /
                   function(groups, pos)
                       local grp = groups.open[#groups.open]
                       groups.open[#groups.open] = nil
                       groups[grp][2] = pos
                       return grp
                   end

local bra = P"(" * newgrp
local ket = P")" * endgrp

local anonbra = P"(?:"
local anonket = P")"

local pattern = P{
    "pattern",

    -- A complete pattern, starting from an empty pattern.
    pattern = Cg(Carg(1),"groups") * Ct((P"^"*Cg(Cc(1),"anchorstart") + P(0)) * V"subpat" * (P"$"*(-P(1))*Cg(Cc(1),"anchorend") + (-P(1)))) /
             function(t) t[0] = "pattern" ; return t end,

    -- A set of alternate branches
    subpat = (V"branch" * (P"|" * V"branch") ^ 0) /
             function(...) return { [0] = "alt", ... } end,

    branch = V"concat",

    -- A set of concatenated pieces
    concat = (V"piece" ^ 0) /
             function(...) return { [0] = "concat", ... } end,

    piece = V"atom_multi",

    atom_multi = V"atom_plus" + V"atom_star" + V"atom_query" + V"atom",

    atom_plus = (V"atom" * P"+") /
             function(atom) return { [0] = "+", atom } end,
    atom_star = (V"atom" * P"*") /
             function(atom) return { [0] = "*", atom } end,
    atom_query = (V"atom" * P"?") /
             function(atom) return { [0] = "?", atom } end,

    anongroup = (anonbra * V"subpat" * anonket),
    group = (bra * V"subpat" * ket) /
             function(subpat, grpname) return { [0] = "group", subpat, grpname } end,
    atom = any + word_start + word_end + escapechar + charset + V"anongroup" + V"group" + char + backref + backcharset,
}

local function foldr(f, t, init)
    local res = init
    local start = #t
    if res == nil then
        res = t[start]
        start = start - 1
    end

    for i=start,1,-1 do
        res = f(t[i], res)
    end
    return res
end

local function map(f, t)
    local result = {}
    for i=1,#t do
        result[i] = f(t[i])
    end
    return result
end

local function add(a,b)
    return a+b
end

-- Convert a charset fragment to a PEG
local function charset_to_peg(charfrag)
    local t = charfrag[0]
    if t == "char" then
        assert(#charfrag == 1)
        return P(charfrag[1])
    elseif t == "range" then
        assert(#charfrag == 2)
        return R(charfrag[1] .. charfrag[2])
    elseif t == "set" then
        return S(charfrag[1])
    else
        error("Got charset bit: "..tostring(t).."/"..tostring(t and t[0]))
    end
end

local function re_to_peg(retab, k, patternProps)
    local t = retab[0]
    if t == "pattern" then
        assert(#retab == 1)
        local pat = re_to_peg(retab[1], k, patternProps)
        -- Add match start/end markers
        pat = _start * pat * _end
        if not retab.anchorstart then
            -- Match the pattern, or a character and try again.
            pat = P{pat + 1*V(1)}
        end
        -- TODO: implement $
        if retab.anchorend then
            error("$ not implemented")
        end
        return pat
    elseif t == "group" then
        assert(#retab == 2)
        -- print(debug.traceback())
        patternProps.numGroups = patternProps.numGroups + 1
        local grpname = tostring(retab[2])
        local newk = Cg(Cp()/sub1, "e"..grpname) * k
        local pat = re_to_peg(retab[1], newk, patternProps)
        pat = Cg(Cp(), "s"..grpname) * pat
        return pat
    elseif t == "alt" then
        if #retab == 1 then
            return re_to_peg(retab[1], k, patternProps)
        else
            local parts = map(function(x)
                    return re_to_peg(x, k, patternProps)
                end, retab)
            return foldr(add, parts)
        end
    elseif t == "concat" then
        return foldr(function(retab_f, k_f) return re_to_peg(retab_f, k_f, patternProps) end, retab, k)
    elseif t == "char" then
        assert(#retab == 1)
        return P(retab[1]) * k
    elseif t == "charset" then
        local charset_pat = foldr(add, map(charset_to_peg, retab))
        if retab.negate then
            charset_pat = 1 - charset_pat
        end
        return charset_pat * k
    elseif t == "*" then
        return P{"A", A=re_to_peg(retab[1], V"A", patternProps) + k}
    elseif t == "+" then
        return re_to_peg(retab[1], P{"A", A=re_to_peg(retab[1], V"A", patternProps) + k}, patternProps)
    elseif t == "." then
        assert(#retab == 0)
        return (P(1) - P"\n") * k
    elseif t == "?" then
        assert(#retab == 1)
        return re_to_peg(retab[1], k, patternProps) + k
    elseif t == "\\<" then
        assert(#retab == 0)
        return -B(wordchar) * #wordchar * k
    elseif t == "\\>" then
        assert(#retab == 0)
        return B(wordchar) * (-#wordchar) * k
    elseif t == "backref" then
        local grpname = retab[1]
        return Cmt(P(0) * Cb("s"..grpname) * Cb("e"..grpname),
             function(subject, pos, s, e)
                 local backval = subject:sub(s, e)
                 local here = subject:sub(pos, pos+e-s)
                 if backval == here then
                     return pos+e-s+1
                 else
                     return false
                 end
             end)
    else
        error("Not implemented op: " ..tostring(t) .. "/" .. tostring(retab))
    end
end

function M.parse(re)
    return pattern:match(re, 1, {open={}})
end
function M.compile(re)
    -- Since the RE->Peg construction starts backwards (using the
    -- continuation), it's more convenient to parse the regular expression
    -- backwards.
    local retab = M.parse(re)
    if retab == nil then
        error("Failed to parse regular expression: {"..re.."}", 2)
    end
    local patternProps = { numGroups = 0 }
    local _pat = re_to_peg(retab, P(0), patternProps)
    return setmetatable({
        _pat = Ct(_pat),
        patternProps = patternProps
    }, mt)
end

return M