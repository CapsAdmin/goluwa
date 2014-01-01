-- strung.lua, a rewrite of the Lua string patterns in Lua + FFI, for LuaJIT
-- Copyright (C) 2013 Pierre-Yves Gérardy
-- MIT licensed (see the LICENSE file for the detais).
--
-- strung compiles patterns to Lua functions, asssociated with an FFI array 
-- holding bit sets, for the character sets (`[...]`) and classes (`%x`), and
-- slots for the capture bounds. This array is allocated once at pattern
-- compile time, and reused for each matching attempt, minimizing memory
-- pressure.

local assert, error, getmetatable, ipairs, loadstring, pairs, print
    , rawset, require, setmetatable, tonumber, tostring, type, pcall
    = assert, error, getmetatable, ipairs, loadstring, pairs, print
    , rawset, require, setmetatable, tonumber, tostring, type, pcall

local _u, expose, noglobals

pcall(function() -- used only for development.
  _u = require"util"
  expose, noglobals = _u.expose, _u.noglobals
end)

local os, s, t = require"os", require"string", require"table"

local s_byte, s_char, s_find, s_gmatch, s_sub, s_match 
    = s.byte, s.char, s.find, s.gmatch, s.sub, s.match

local t_concat, t_insert, t_remove
    = t.concat, t.insert, t.remove

local o_setlocale = os.setlocale

local ffi = require"ffi"
local C = ffi.C

local bit = require("bit")
local band, bor, bxor = bit.band, bit.bor, bit.xor
local lshift, rshift, rol = bit.lshift, bit.rshift, bit.rol

;(noglobals or type)("") -------------------------------------------------------------

-- bit sets, code released by Mike Pall in the public domain.

local function bitnew(n)
  return ffi.new("int32_t[?]", rshift(n+31, 5))
end

local function bittest(b, i)
  return band(rshift(b[rshift(i, 5)], i), 1) ~= 0
end

local function bitset(b, i)
  local x = rshift(i, 5); b[x] = bor(b[x], lshift(1, i))
end

-- pseudo-enum, just for the kicks. This might as well be a Lua table.
ffi.cdef[[
struct placeholder {
  static const int POS = 1;
  static const int VAL = 2;
  static const int INV = 2;
  static const int NEG = 3;
  static const int SET = 4;
  static const int UNTIL = 5;
  static const int FRETCAPS = 6;
  static const int MRETCAPS = 7;
  static const int GRETCAPS = 8;
  static const int TEST = 9;
  static const int NEXT = 10;
  static const int OPEN = 11;
  static const int CLOSE = 12;
}
]]

local P = ffi.new"struct placeholder"

local g_i, g_subj, g_ins, g_start, g_end

-- patterns are compiled to Lua by stitching these:

local templates = {}

-- aux is the FFI array holding bit sets and capture bounds.
templates.head = {[=[ 
local bittest, aux, auxlen, anchored, expose = ...
return function(subj, _, i, g_, match)
  local len = #subj
  if i > len then return nil end
  local i0 = i - 1
  local c, open, close, diff, previous
  repeat
    i0 = i0 + 1
    repeat
      i = i0]=]
}
templates.tail = {[=[ 
      break until true
    until anchored or i or i0 >= len
    if not i then return nil end
  i = i - 1
  if g_ then --gsub/gmatch
    return i0, i]=], P.GRETCAPS, [=[ 
  elseif match then
    return ]=], P.MRETCAPS, [=[ 
  else -- find
    return ]=], P.FRETCAPS, [=[ 
  end
end]=]
}
local capstpl = {
  "aux[auxlen + ", 2, "] == 4294967295 and aux[auxlen + ", 4, "] or subj:sub(aux[auxlen + ", 6, "], aux[auxlen + ", 8, "]) "
}
templates.one = {[[ 
  i = (]], P.TEST, [[) and i + 1
  if not i then break end]]
}
templates['*'] = {[=[ 
    local i0, i1 = i
  while true do
    if (]=], P.TEST,[=[) then i = i + 1 else break end
  end
  i1 = i
  repeat
        i = i1
    repeat
      ]=],
      P.NEXT, [[ 
    break until true
    if i then break end
    i1 = i1 - 1
  until i1 < i0
  --if not i then break end]]
}
templates['-'] = {[[ 
  local i1 = i
  while true do
    i = i1
    repeat]],
      P.NEXT, [[ 
    break until true
    if i then break end
    i = i1
    if not (]],P.TEST, [[) then i = false; break end
    i1 = i1 + 1
  end
  if not i then break end]]
}
templates["?"] = {[[ 
  do 
    local _i, q = i
    if ]], P.TEST, [[ then q = true; i = i + 1 end
    goto first
    ::second::
    i = _i
    ::first::
    repeat]],
      P.NEXT, [[ 
    break until true
    if not i and q then q = false; goto second end
  end]]
}
templates.char = {[[subj:byte(i) == ]], P.VAL}
templates.any = {[[i <= len]]}
templates.set = {[[(i <= len) and ]], P.INV, [[ bittest(aux, ]], P.SET, [[ + subj:byte(i))]]}

templates.ballanced = {[[ 
  open, close = ]], P.OPEN,[[, ]], P.CLOSE, [[ 
  if subj:byte(i) ~= ]], P.OPEN, [[ then 
    i = false; break
  else
    count = 1
    repeat
      i = i + 1
      c = subj:byte(i)
      if not c then i = false; break end
      if c == ]], P.OPEN, [[ then
        count = count + 1 
      elseif c == ]], P.CLOSE, [[ then
        count = count - 1
      end
    until count == 0 or not c
  end
  if not c then i = false; break end
  i = i + 1]]
}
templates.frontier = {[[ 
  if i == 1 then
    i =  ((i <= len) and ]], P.POS, [[ bittest(aux, ]], P.SET, [[ + subj:byte(i))) and i
  else
    i = ((i <= len) and ]], P.POS, [[ bittest(aux, ]], P.SET, [[ + subj:byte(i))) 
    and ((i <= len) and ]], P.NEG, [[ bittest(aux, ]], P.SET, [[ + subj:byte(i-1)))
    and i
  end
  if not i then break end]]
}
templates.poscap = {[[ 
  aux[auxlen + ]], P.OPEN, [[] = i
  aux[auxlen + ]], P.CLOSE, [[] = 4294967295
]]
}
templates.refcap = {[[ 
  open, close = aux[auxlen + ]], P.OPEN, [[], aux[auxlen +]], P.CLOSE, [[]
  diff = close - open
  if subj:sub(open, close) == subj:sub(i, i + diff) then
    i = i + diff + 1
  else
    i = false; break
  end]]
}
templates.open = {[[ 
  aux[auxlen + ]], P.OPEN, [[] = i]]
}
templates.close = {[[ 
      aux[auxlen + ]], P.CLOSE, [[] = i - 1]]
}
  templates.dollar = {[[
  if i ~= #subj + 1 then i = false end]]
}


---- Simple pattern compiler ----

local function hash_find (s, p, i) --
  if p == "" then return i end
  local lp, ls = #p, #s
  if ls < lp then return nil end
  if p == s then return i, i + lp - 1 end
  local c = s_byte(p)
  p, lp = p:sub(2), lp -1
  local last = ls - lp
  repeat 
    while c ~= s_byte(s, i) do
      i = i + 1
      if i > last then return nil end
    end    
    if lp == 0 or s_sub(s, i + 1, i + lp) == p then return i, i + lp end
    i = i + 1
  until i > last
  return nil
end

local function simplewrp(s, p, i, _g, match)
  i = i or 1
  if not (_g or match) then return hash_find(s, p, i) end
  local st, e = hash_find(s, p, i)
  if not st then return nil end
  if _g then
    return st, e, nil
  else
    return s_sub(s, st, e)
  end
end

local function simple(pat) return {simplewrp, 0, "simple", 0} end

local specials = {} for _, c in ipairs{"^", "$", "*", "+", "?", ".", "(", "[", "%", "-"} do
  specials[c:byte()] = true
end

local function normal(s)
  for i = 1, #s do
    if specials[s:byte(i)] then return false end
  end
  return true
end


---- Main pattern compiler ---

local --[[function]] compile 

--- The cache for the compiled pattern matchers.
local codecache = setmetatable({}, {
  __mode="k",
  __index=function(codecache, pat)

        local code = normal(pat) and simple(pat) or compile(pat)
    rawset(codecache, pat, code)
    return code
  end
})

local function indent(i, s) return tostring(s):gsub('\n', '\n'..("  "):rep(i*2)) end

--- Push the template parts in two buffers.
local function push (tpl, data, buf, backbuf, ind)
  local back
  for _, o in ipairs(tpl) do
    if type(o) ~= "string" then
      if o == P.NEXT then back = true; break end
      buf[#buf + 1] = indent(ind, data[o])
    else
      buf[#buf + 1] = indent(ind, o)
    end
  end
  if back then for i = #tpl, 1, -1 do local o = tpl[i]
    if type(o) ~= "string" then
      if o == P.NEXT then break end
      backbuf[#backbuf + 1] = indent(ind, data[o])
    else
      backbuf[#backbuf + 1] = indent(ind, o)
    end
  end end
  for i = 1, #buf do
          end
    for i = #backbuf, 1, -1 do
          end
  end

-- Character classes...
ffi.cdef[[
  int isalpha (int c);
  int iscntrl (int c);
  int isdigit (int c);
  int islower (int c);
  int ispunct (int c);
  int isspace (int c);
  int isupper (int c);
  int isalnum (int c);
  int isxdigit (int c);
]]


local ccref = {
    a = "isalpha", c = "iscntrl", d = "isdigit",
    l = "islower", p = "ispunct", s = "isspace",
    u = "isupper", w = "isalnum", x = "isxdigit"
} 
local allchars = {}; for i = 0, 255 do
    allchars[i] = s_char(i)
end
local charclass = setmetatable({}, {__index = function(self, c)
  local func = ccref[c:lower()]
  local cc0, cc1 = ffi.new('uint32_t[8]'), ffi.new('uint32_t[8]')
  for i = 0, 255 do
    if C[func](i) ~= 0 then
      bitset(cc0, i)
    else
      bitset(cc1, i)
    end
  end 
  self[c:lower()] = cc0
  self[c:upper()] = cc1
  return self[c]
end})


local function key (cs)
  return t_concat({cs[0], cs[1], cs[2], cs[3], cs[4], cs[5], cs[6], cs[7]}, ":")
end

local function makecc(pat, i, sets)
  local c = pat:sub(i , i)
  local class = charclass[c]
  local k = key(class)
  if not sets[k] then
    sets[#sets + 1] = class
    sets[k]  = #sets
  end
  return "", (sets[k] - 1) * 256
end

local hat = ('^'):byte()
local function makecs(pat, i, sets)
  local inv if s_byte(pat,i) == hat then inv = true; i = i + 1 end
  local cl, last = i + 1, #pat
  while ']' ~= s_sub(pat, cl, cl) do cl = cl + 1 if i > last then error"unfinished character class" end end
  local cs = ffi.new('uint32_t[8]')
  local c
  while i < cl do
    c = s_sub(pat,i, i)
    if c == '%' then
      i = i + 1
      if i == cl then error"invalid escape sequence" end
      local cc = charclass[s_sub(pat, i, i)]
      if cc then
        for i = 0, 7 do 
          cs[i] = bor(cs[i], cc[i]) 
        end
        i = i + 1
        goto continue
      elseif s_sub(pat, i, i) == 'z'
        then bitset(cs, 0); i = i + 1; goto continue
      end -- else, skip the % and evaluate the character as itself.
    end
    if i + 2 < cl and s_sub(pat, i + 1, i + 1) == '-' then
      for i = s_byte(pat, i), s_byte(pat, i+2) do bitset(cs, i) end
      i = i + 3
    else
      bitset(cs, s_byte(pat, i)); i = i + 1
    end
    ::continue::
  end
  local k = key(cs)
  if not sets[k] then
    sets[#sets + 1] = cs
    sets[k]  = #sets
  end
  return inv, (sets[k] - 1) * 256, cl
end

ffi.cdef[[const char * strchr ( const char * str, int character );]]

local suffixes = {
  ["*"] = true,
  ["+"] = true,
  ["-"] = true,
  ["?"] = true
}

local function suffix(i, ind, len, pat, data, buf, backbuf)
  local c = pat:sub(i, i)
  if not suffixes[c] then
    push(templates.one, data, buf,backbuf, ind)
    return i - 1, ind
  end
  if c == "+" then 
    push(templates.one, data, buf,backbuf, ind)
    c = "*"
  end
  push(templates[c], data, buf,backbuf, ind + (c == "?" and 0 or 1))
  return i, ind + 2
end

local function _compile(pat, i, caps, sets, data, buf, backbuf)
    local len = #pat
  local ind = 1
  local c = pat:sub(i,i)
  while i <= len do
        local op = 0
    local canmod = false
    if c == '(' then -- position capture
      if pat:sub(i + 1, i + 1) == ")" then 
        caps[#caps + 1] = 1
        caps[#caps + 1] = 0
        data[P.OPEN] = -#caps
        data[P.CLOSE] = -#caps + 1
        push(templates.poscap, data, buf,backbuf, ind)
        i = i + 1
      else -- open capture
        caps[#caps + 1] = 1
        caps[#caps + 1] = -1
        caps.open = caps.open + 1
        data[P.OPEN] = -#caps
        push(templates.open, data, buf,backbuf, ind)
      end
    elseif c == ")" then -- open capture
      data[P.CLOSE] = false
      for j = #caps, 2, -2 do
        if caps[j] == -1 then
          caps[j] = 1
        caps.open = caps.open - 1
          data[P.CLOSE] = - j + 1;
          break end
      end
      if not data[P.CLOSE] then error"invalid closing parenthesis" end
      push(templates.close, data, buf,backbuf, ind)
    elseif  c == '.' then 
      data[P.TEST] = templates.any[1]
      i, ind = suffix(i + 1, ind, len, pat, data, buf, backbuf)
    elseif c == "[" then
      local inv
      inv, templates.set[P.SET], i = makecs(pat, i+1, sets)
      templates.set[P.INV] = inv and "not" or ""
      data[P.TEST] = t_concat(templates.set)
      i, ind = suffix(i + 1, ind, len, pat, data, buf, backbuf)
    elseif c == "%" then
      i = i + 1
      c = pat:sub(i, i)
      if not c then error"malformed pattern (ends with '%')" end
      if ccref[c:lower()] then -- a character class
        templates.set[P.INV], templates.set[P.SET] = makecc(pat, i, sets)
                data[P.TEST] = t_concat(templates.set)
      i, ind = suffix(i + 1, ind, len, pat, data, buf, backbuf)
      elseif "1" <= c and c <= "9" then
        local n = tonumber(c) * 2
        if n > #caps then error"attempt to reference a non-existing capture" end
        data[P.OPEN] = -n
        data[P.CLOSE] = -n + 1
        push(templates.refcap, data, buf,backbuf, ind)
      elseif c == "b" then
        data[P.OPEN], data[P.CLOSE] = pat:byte(i + 1, i + 2)
        i = i + 2
        push(templates.ballanced, data, buf, backbuf, ind)
      elseif c == 'f' then
        if pat:sub(i+1, i +1) ~= '[' then error"missing '['' after '%f' in pattern" end
        local inv, set_i
        inv, data[P.SET], i = makecs(pat, i+1, sets)
        data[P.POS] = inv and "not" or ""
        data[P.NEG] = inv and "" or "not"
        push(templates.frontier, data, buf, backbuf, ind)
      else
        if c == 'z'then c = '\0' end
        templates.char[P.VAL] = c:byte()
        data[P.TEST] = t_concat(templates.char)
        i, ind = suffix(i + 1, ind, len, pat, data, buf, backbuf)
      end
    else
      if c == '$' and i == #pat then
        push(templates.dollar, data, buf,backbuf, ind)
      else
        templates.char[P.VAL] = c:byte()
        data[P.TEST] = t_concat(templates.char)
        i, ind = suffix(i + 1, ind, len, pat, data, buf, backbuf)
      end
    end
    i = i + 1
    c = pat:sub(i, i)
  end ---- /while
  assert(caps.open == 0, "invalid pattern: one or more captures left open")
end

--- Create the uint32_t array that holds the character sets and capture bounds.
local function pack (sets, ncaps)
  local nsets = #sets
  local len = nsets*8 + ncaps
  local res = ffi.new("uint32_t[?]", len)

  local slot = res[0]
  for i = 1, nsets do
    for j = 0, 7 do
      res[(i - 1) * 8 + j] = sets[i][j]
    end
  end
      return res, len
end

ffi.cdef[[
struct M {
  static const int CODE = 1;
  static const int NCAPS = 2;
  static const int SOURCE = 3;
  static const int AUXLEN = 4;
}]] local M = ffi.new"struct M"

function compile (pat) -- local, declared above
  local anchored = (pat:sub(1,1) == "^")
  local caps, sets = {open = 0}, {}
  local data = {}
  local buf, backbuf = {templates.head[1]}, {}
  local i = anchored and 2 or 1

  _compile(pat, i, caps, sets, data, buf, backbuf)
  
  local aux, auxlen = pack(sets, #caps)
  for i = #backbuf, 1, -1 do buf[#buf + 1] = backbuf[i] end
  local rc = {}
  assert(#caps<400, "too many captures in pattern (max 200)")
  if #caps ~= 0 then
    for i = 2, #caps, 2 do
      capstpl[2], capstpl[8] = -i + 1, -i + 1
      capstpl[4], capstpl[6] = -i, -i
      rc[#rc + 1] = t_concat(capstpl)
    end
    data[P.MRETCAPS] = t_concat(rc, ", ")
    data[P.GRETCAPS] = ", aux"
  else
    data[P.MRETCAPS] = "subj:sub(i0, i)"
    data[P.GRETCAPS] = ""
  end
  t_insert(rc, 1, "i0, i") -- for find, prepend the bounds of the match
  data[P.FRETCAPS] = t_concat(rc, ", ")
  push(templates.tail, data, buf, backbuf, 0)
    local source = t_concat(buf)
  local loader, err = loadstring(source)
  if not loader then print(source,"\nERROR:\n", err); error() end
  local code = loader(bittest, aux, auxlen, anchored, expose) -- TODO move the anchored decision to the compiler rather than target code.
  return {code, #caps/2, source, auxlen} -- TODO replace arbitrary indices with enum-like names (especially for querying later on).
end


---- API ----

local function checki(i, subj)
  if not i then return 1 end
  if i < 0 then i = #subj + 1 + i end
  if i < 1 then i = 1 end
  return i
end

local function find(subj, pat, i, plain)
  i = checki(i, subj)
  if plain then 
    return hash_find(subj, pat, i)
  end
  -- [[DBG]] print("SOURCE", codecache[pat][M.SOURCE])
  return codecache[pat][M.CODE](subj, pat, i, false, false)
end

local function match(subj, pat, i, raw)
  return codecache[pat][M.CODE](subj, pat, checki(i, subj), false, true)
end


-- gmatch paraphernalia --

local rtpl = {[=[
local expose = ...
return function(c, subj)
  return ]=], 2,[[ 
end]]}

local ctpl = {"c[", 2, "] == 4294967295 and c[", 4, "] or subj:sub(c[", 6, "], c[", 8, "]) "}

--- lazily build a table of functions that produce n captures at a given offset.
--- the offset * n combo is encoded as a single number by lshifting the offset
--- by 8 then adding it to n.
local returning = setmetatable({}, {__index = function(self, a)
  local n, offset = band(a, 0xFF), rshift(a, 8)
  local acc = {}
  for i = 2, n * 2, 2 do
    ctpl[4], ctpl[2] = offset - i, offset - i + 1
    ctpl[6], ctpl[8] = offset - i, offset - i + 1
    acc[#acc + 1] = t_concat(ctpl)
  end
  rtpl[2] = t_concat(acc, ", ")
  local res = loadstring(t_concat(rtpl))(expose)
  self[a] = res
  return res
end})

local function gmatch_iter(state)
  local s, e, c = state[1](state[2], state[3], state[4], true)
  if s then state[4] = e + 1
    if c then
      return state[5](c, state[2])
    else
      return state[2]:sub(s, e)
    end
  else
    return nil
  end
end

local function gmatch(subj, pat)
  local c = codecache[pat]
  local state = {c[M.CODE], subj, pat, 1, returning[bor(lshift(c[M.AUXLEN], 8), c[M.NCAPS])]}
  -- see the returning .__index definition for the rationale for the bit twiddling.
  -- [[DBG]]print("PAT", pat)
  -- [[DBG]]print("SOURCE", codecache[pat][M.SOURCE])
  return gmatch_iter, state
end

local _gsub = setmetatable({
  -- foo
}, {__index = function(_, typ) error("strung.gsub can't handle replacement of type "..typ) end})


-- gsub helpers --

--- preprepl[o] --> preprocess then cache the replacement values for 
--- gsub. used for strings with 
local preprepl = setmetatable({}, {__index = function()
  -- return typ, res
end})

local function gsub(subj, pat, repl)
  local typ = type(repl)
  if typ == "string" then 
    repl = preprepl[repl]
    typ = type(repl) == "string" and "string" or "pat"
  end
  return _gsub[typ](subj, pat, repl)
end


-- used in the test suite.
local function _assert(test, pat, msg)
  if not test then
    local code = codecache[pat][3]
    print(("- -"):rep(60))
    print(code)
    print(("- "):rep(60))
    print(msg)
    error()
  end
end

-- reset the
local function reset ()
  codecache = setmetatable({}, getmetatable(codecache))
  charclass = setmetatable({}, getmetatable(charclass))
end
local function setlocale (loc, mode)
  reset()
  return o_setlocale(loc, mode)
end
-------------------------------------------------------------------------------

return {
  install = function()
    s.find = find
    s.match = match
    s.gmatch = gmatch
    -- s.gsub = gsub
    os.setlocale = setlocale
  end,
  find = find,
  match = match,
  gmatch = gmatch,
  gsub = function() error"strung.gsub: not yet implemented" end, --gsub,
  reset = reset,
  setlocale = setlocale,
  assert = _assert
}
