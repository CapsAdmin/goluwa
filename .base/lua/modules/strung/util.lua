
-- A collection of general purpose helpers.

local error, pairs, print, tonumber, tostring, type
    = error, pairs, print, tonumber, tostring, type

local s, t = require"string", require"table"
local s_gsub, s_match, t_concat
    = s.gsub, s.match, t.concat


local ffi = require"ffi"
local f_alignof, f_sizeof = ffi.alignof, ffi.sizeof

-- The no-op function:

local
function nop () end

-- No globals definition:

local noglobals do
   local function errR (_,i)
        error("illegal global read: " .. tostring(i), 2)
    end
    local function errW (_,i, v)
        error("illegal global write: " .. tostring(i)..": "..tostring(v), 2)
    end
    local env = setmetatable({}, { __index=errR, __newindex=errW })
    noglobals = function()
        pcall(setfenv, 3, env)
        return env
    end
end



local _ENV = noglobals() ------------------------------------------------------



local util = {
    nop = nop,
    noglobals = noglobals,
}

-- Array pretty-printer

local val_to_str_, key_to_str, table_tostring, cdata_to_str, t_cache
local multiplier = 2
local space, retu = " ", "\n"
function util.set_printer_space(s, r)
    space, retu = s, r
end

local
function val_to_string (v, indent)
    indent = indent or 0
    t_cache = {} -- upvalue.
    local acc = {}
    val_to_str_(v, acc, indent, indent)
    local res = t_concat(acc, "")
    return res
end
util.val_to_string = val_to_string

function val_to_str_ ( v, acc, indent, str_indent )
    str_indent = str_indent or 1
    if "string" == type( v ) then
        v = s_gsub( v, "\n",  "\n" .. (" "):rep( indent * multiplier + str_indent ) )
        if s_match( s_gsub( v,"[^'\"]",""), '^"+$' ) then
            acc[#acc+1] = t_concat{ "'", "", v, "'" }
        else
            acc[#acc+1] = t_concat{'"', s_gsub(v,'"', '\\"' ), '"' }
        end
    elseif "cdata" == type( v ) then
            cdata_to_str( v, acc, indent )
    elseif "table" == type(v) then
        if t_cache[v] then
            acc[#acc+1] = t_cache[v]
        else
            t_cache[v] = tostring( v )
            table_tostring( v, acc, indent )
        end
    else
        acc[#acc+1] = tostring( v )
    end
end

function key_to_str ( k, acc, indent )
    if "string" == type( k ) and s_match( k, "^[_%a][_%a%d]*$" ) then
        acc[#acc+1] = s_gsub( k, "\n", (space):rep( indent * multiplier + 1 ) .. "\n" )
    else
        acc[#acc+1] = "[ "
        val_to_str_( k, acc, indent )
        acc[#acc+1] = " ]"
    end
end

function cdata_to_str(v, acc, indent)
    acc[#acc+1] = ( space ):rep( indent * multiplier )
    if tostring(v):find("*", 1, true) then
        acc[#acc+1] = tostring(v)
        return
    end

    acc[#acc+1] = tostring(v).." ["
    for i = 0, f_sizeof(v) / f_alignof(v) - 1  do
        acc[#acc+1] = tostring(tonumber(v[i]))
        acc[#acc+1] = i ~= f_sizeof(v) / 4 - 1 and  ", " or ""
    end
    acc[#acc+1] = "]"
end

function table_tostring ( tbl, acc, indent )
    -- acc[#acc+1] = ( " " ):rep( indent * multiplier )
    -- acc[#acc+1] = t_cache[tbl]
    acc[#acc+1] = "{"..retu
    for k, v in pairs( tbl ) do
        local str_indent = 1
        acc[#acc+1] = (space):rep((indent + 1) * multiplier)
        key_to_str( k, acc, indent + 1)

        if acc[#acc] == " ]"
        and acc[#acc - 2] == "[ "
        then str_indent = 8 + #acc[#acc - 1]
        end

        acc[#acc+1] = " = "
        val_to_str_( v, acc, indent + 1, str_indent)
        acc[#acc+1] = retu
    end
    acc[#acc+1] = (space):rep( indent * multiplier )
    acc[#acc+1] = "}"
end
util.table_tostring = table_tostring

function util.expose(v) print("   "..val_to_string(v)) return v end

local
function _checkstrhelper(s)
    return s..""
end

function util.checkstring(s, func)
    local success, str = pcall(_checkstrhelper, s)
    if not success then 
        if func == nil then func = "?" end
        error("bad argument to '"
            ..tostring(func)
            .."' (string expected, got "
            ..type(s)
            ..")",
        2)
    end
    return str
end



return util