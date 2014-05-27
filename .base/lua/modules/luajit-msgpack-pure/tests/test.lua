#!/usr/bin/env luajit

local RUN_LARGE_TESTS = false
local IS_LUAFFI = not rawget(_G,"jit")

local pathx = require "pl.path"
local pretty = require "pl.pretty"
local tablex = require "pl.tablex"
require "pl.strict"

local mp = require "luajit-msgpack-pure"
local ffi = require "ffi"

local display = function(m,x)
  local _t = type(x)
  io.stdout:write(string.format("\n%s: %s ",m,_t))
  if _t == "table" then pretty.dump(x) else print(x) end
end

local printf = function(p,...)
  io.stdout:write(string.format(p,...)); io.stdout:flush()
end

local msgpack_cases = {
  false,true,nil,0,0,0,0,0,0,0,0,0,-1,-1,-1,-1,-1,127,127,255,2^16-1,
  2^32-1,-32,-32,-128,-2^15,-2^31,0.0,-0.0,1.0,-1.0,
  "a","a","a","","","",
  {0},{0},{0},{},{},{},{},{},{},{a=97},{a=97},{a=97},{{}},{{"a"}},
}

local data = {
  true,
  false,
  42,
  -42,
  0.79,
  "Hello world!",
  {},
  {true,false,42,-42,0.79,"Hello","World!"},
  {[0]=17,21,27},
  {[-6]=17,21,27},
  {[-1]=4,1,nil,3},
  {[1]=17,[99999999]=21},
  {[1.2]=5, [2]=7},
  {{"multi","level",{"lists","used",45,{{"trees"}}},"work",{}},"too"},
  {foo="bar",spam="eggs"},
  {nested={maps={"work","too"}}},
  {"we","can",{"mix","integer"},{keys="and"},{2,{maps="as well"}}},
  msgpack_cases,
}

local offset,res

-- Custom tests
printf("Custom tests ")
for i=0,#data do -- 0 tests nil!
  printf(".")
  offset,res = mp.unpack(mp.pack(data[i]))
  assert(offset,"decoding failed")
  if not tablex.deepcompare(res,data[i]) then
    display("expected",data[i])
    display("found",res)
    assert(false,string.format("wrong value %d",i))
  end
end
print(" OK")

-- Integer tests

printf("Integer tests ")

local nb_test = function(n,sz,epsilon)
  offset,res = mp.unpack(mp.pack(n))
  assert(offset,"decoding failed")
  if epsilon then
    local diff = math.abs(res - n)
    if diff > epsilon then
      assert(false,string.format(
        "wrong value %g, expected %g, difference %g > epsilon %g",
        res,n,diff,epsilon
      ))
    end
  else
    if res ~= n then
      assert(false,string.format("wrong value %g, expected %g",res,n))
    end
  end
  assert(offset == sz,string.format(
    "wrong size %d for number %g (expected %d)",
    offset,n,sz
  ))
end

printf(".")
for n=0,127 do -- positive fixnum
  nb_test(n,1)
end

printf(".")
for n=128,255 do -- uint8
  nb_test(n,2)
end

printf(".")
for n=256,2^16-1 do -- uint16
  nb_test(n,3)
end

 -- uint32
printf(".")
for n=2^16,2^16+100 do
  nb_test(n,5)
end
for n=2^32-101,2^32-1 do
  nb_test(n,5)
end

printf(".")
for n=2^32,2^32+100 do -- uint64
  nb_test(n,9)
end

printf(".")
for n=-1,-32,-1 do -- negative fixnum
  nb_test(n,1)
end

printf(".")
for n=-33,-128,-1 do -- int8
  nb_test(n,2)
end

printf(".")
for n=-129,-2^15,-1 do -- int16
  nb_test(n,3)
end

-- int32
printf(".")
for n=-2^15-1,-2^15-101,-1 do
  nb_test(n,5)
end
for n=-2^31+100,-2^31,-1 do
  nb_test(n,5)
end

printf(".")
for n=-2^31-1,-2^31-101,-1 do -- int64
  nb_test(n,9)
end

print(" OK")

-- Floating point tests
printf("Floating point tests ")

printf(".") -- default is double
for i=1,100 do
  local n = math.random()*200-100
  nb_test(n,9)
end

printf(".")

mp.set_fp_type("float")
for i=1,100 do
  local n = math.random()*200-100
  nb_test(n,5,1e-5)
end

printf(".")
mp.set_fp_type("double")
for i=1,100 do
  local n = math.random()*200-100
  nb_test(n,9)
end

print(" OK")

-- Quasi-numbers tests
printf("Quasi-numbers tests ")

-- Notes and conventions:

-- IEEE 754 format remainder:
-- - Float:  [1] sign | [8] exp  | [23] frac
-- - Double: [1] sign | [11] exp | [52] frac

-- Inifinities have an exponent of all ones and a fraction of zero:
-- - +inf: 0x7f800000 / 0x7ff0000000000000
-- - -inf: 0xff800000 / 0xfff0000000000000

-- NaNs have any sign, an exponent of all ones and any fraction except 0.
-- If the MSB of the fraction is set then it is a QNaN, otherwise it is a SNaN.

-- NaNs are *packed* as QNaNs (non-signaling), specifically
-- 0xff880000 / 0xfff8000000000000.
-- All QNaNs and SNaNs should be decoded as `nan`, but this might not
-- always be the case currently because of specificities of LuaJIT.

local _pos_inf,_neg_inf = 1/0,-1/0

local nan_test = function(sz)
  local n = 0/0
  offset,res = mp.unpack(mp.pack(n))
  assert(offset,"decoding failed")
  if not ((type(res) == "number") and (res ~= res)) then
    print(type(res))
    assert(false,string.format("wrong value %g, expected %g",res,n))
  end
  assert(offset == sz,string.format(
    "wrong size %d for number %g (expected %d)",
    offset,n,sz
  ))
end

mp.set_fp_type("float")

printf(".")
nb_test(_pos_inf,5)

printf(".")
nb_test(_neg_inf,5)

printf(".")
nan_test(5)

mp.set_fp_type("double")

printf(".")
nb_test(_pos_inf,9)

printf(".")
nb_test(_neg_inf,9)

printf(".")
nan_test(9)

print(" OK")

-- Raw tests

printf("Raw tests ")

local rand_raw = function(len)
  local t = {}
  for i=1,len do t[i] = string.char(math.random(0,255)) end
  return table.concat(t)
end

local raw_test = function(raw,overhead)
  offset,res = mp.unpack(mp.pack(raw))
  assert(offset,"decoding failed")
  if res ~= raw then
    assert(false,string.format("wrong raw (len %d - %d)",#res,#raw))
  end
  assert(offset-#raw == overhead,string.format(
    "wrong overhead %d for #raw %d (expected %d)",
    offset-#raw,#raw,overhead
  ))
end

printf(".")
for n=0,31 do -- fixraw
  raw_test(rand_raw(n),1)
end

-- raw16
printf(".")
for n=32,32+100 do
  raw_test(rand_raw(n),3)
end
for n=2^16-101,2^16-1 do
  raw_test(rand_raw(n),3)
end

 -- raw32
printf(".")
for n=2^16,2^16+100 do
  raw_test(rand_raw(n),5)
end
if RUN_LARGE_TESTS then
  for n=2^32-101,2^32-1 do
    raw_test(rand_raw(n),5)
  end
end

print(" OK")

-- Table tests
printf("Table tests ")

local rand_array = function(len) -- of positive fixnum-s
  local t = {}
  for i=1,len do t[i] = math.random(0,127) end
  return t
end

local array_test = function(t,expected_size,overhead)
  offset,res = mp.unpack(mp.pack(t))
  assert(offset,"decoding failed")
  assert((offset-expected_size) == overhead,string.format(
    "wrong overhead %d (expected %d)",
    (offset-expected_size),overhead
  ))
  assert(type(res) == "table",string.format("wrong type %s",type(res)))
  local n = #res
  assert(n == expected_size,string.format(
    "wrong size %d (expected %d)",
    n,expected_size
  ))
  for i=0,n-1 do
    assert(t[i] == res[i],"wrong value")
  end
end

-- fix array
printf(".")
for n=0,15 do
  array_test(rand_array(n),n,1)
end

-- array16
printf(".")
for n=16,16+100 do
  array_test(rand_array(n),n,3)
end
for n=2^16-101,2^16-1 do
  array_test(rand_array(n),n,3)
end

 -- array32
printf(".")
for n=2^16,2^16+100 do
  array_test(rand_array(n),n,5)
end
if RUN_LARGE_TESTS then
  for n=2^32-101,2^32-1 do
    array_test(rand_array(n),n,5)
  end
end

print(" OK")

-- TODO Map tests
printf("Map tests ")
print(" TODO")

-- From MessagePack test suite
local cases_dir = pathx.abspath(pathx.dirname(arg[0]))
local case_files = {
  standard = pathx.join(cases_dir,"cases.mpac"),
  compact = pathx.join(cases_dir,"cases_compact.mpac"),
}
local i,f,bindata,decoded
local ncases = #msgpack_cases
for case_name,case_file in pairs(case_files) do
  printf("MsgPack %s tests ",case_name)
  f = assert(io.open(case_file,'rb'))
  bindata = f:read("*all")
  f:close()
  offset,i = 0,0
  while true do
    i = i+1
    printf(".")
    offset,res = mp.unpack(bindata,offset)
    if not offset then break end
    if not tablex.deepcompare(res,msgpack_cases[i]) then
      display("expected",msgpack_cases[i])
      display("found",res)
      assert(false,string.format("wrong value %d",i))
    end
  end
  assert(
    i-1 == ncases,
    string.format("decoded %d values instead of %d",i-1,ncases)
  )
  print(" OK")
end

-- msgpack-js compatibility
printf("msgpack-js compatibility tests ")

local rand_buf = function(len)
  local buf = ffi.new("unsigned char[?]",len)
  for i=0,len-1 do buf[i] = math.random(0,255) end
  return buf
end

local buf_type = IS_LUAFFI and "userdata" or "cdata"
local buf_test = function(buf,expected_size,overhead)
  offset,res = mp.unpack(mp.pack(buf))
  assert(offset,"decoding failed")
  assert((offset-expected_size) == overhead,string.format(
    "wrong overhead %d (expected %d)",
    (offset-expected_size),overhead
  ))
  assert(type(res) == buf_type,string.format("wrong type %s",type(res)))
  local n = ffi.sizeof(res)
  assert(n == expected_size,string.format(
    "wrong size %d (expected %d)",
    n,expected_size
  ))
  for i=0,n-1 do
    assert(buf[i] == res[i],"wrong value")
  end
end

-- undefined
printf(".")
offset,res = mp.unpack(string.char(0xc4))
assert(offset,"decoding failed")
assert(offset == 1,"wrong size")
assert(res == nil,"wrong value")

-- buf16
printf(".")
for n=32,32+100 do
  buf_test(rand_buf(n),n,3)
end
for n=2^16-101,2^16-1 do
  buf_test(rand_buf(n),n,3)
end

 -- buf32
printf(".")
for n=2^16,2^16+100 do
  buf_test(rand_buf(n),n,5)
end
if RUN_LARGE_TESTS then
  for n=2^32-101,2^32-1 do
    buf_test(rand_buf(n),n,5)
  end
end

print(" OK")
