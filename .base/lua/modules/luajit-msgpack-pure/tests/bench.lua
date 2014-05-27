local mp = require "luajit-msgpack-pure"
local ok,socket = pcall(require,"socket")
local gettime = ok and socket.gettime or os.clock

if #arg ~= 1 then
  error("Usage: luajit bench.lua 1000000")
end
local nloop = arg[1]

local printf = function(p,...)
  io.stdout:write(string.format(p,...)); io.stdout:flush()
end

local makeiary = function(n)
  local out = {}
  for i=1,n do table.insert(out,math.floor(i-n/2)) end
  return out
end

local makedary = function(n)
  local out = {}
  for i=1,n do table.insert(out,1.5e+35*i) end
  return out
end

local makestr = function(n)
  local out = ""
  for i=1,n-1 do out = out .. "a" end
  out = out .. "b"
  return out
end

local datasets = {
  { "empty", {}, nloop },
  { "iary1", {1}, nloop },
  { "iary10", {-5,-4,-3,-2,-1,0,1,2,3,4}, nloop },
  { "iary100", makeiary(100), nloop/10 },
  { "iary1000", makeiary(1000), nloop/100 },
  { "iary10000", makeiary(10000), nloop/1000 },
  { "dary1", {1.5e+35}, nloop/50 },
  { "dary10", makedary(10), nloop/100 },
  { "dary100", makedary(100), nloop/1000 },
  { "dary1000", makedary(1000), nloop/1000 },
  { "str1", { "a"}, nloop },
  { "str10", { makestr(10) }, nloop },
  { "str100", { makestr(100) }, nloop },
  { "str1000", { makestr(1000) }, nloop },
  { "str10000", { makestr(10000) }, nloop/10 },
  { "str20000", { makestr(20000) }, nloop/10 },
  { "str30000", { makestr(30000) }, nloop/10 },
  { "str40000", { makestr(40000) }, nloop/100 },
  { "str80000", { makestr(80000) }, nloop/100 },
}

local n,st,et
for i,v in ipairs(datasets) do
  st,n = gettime(),v[3]
  local offset,res
  local x = v[2]
  for j=1,n do
    offset,res = mp.unpack(mp.pack(x))
  end
  assert(offset == #mp.pack(x))
  et = gettime()
  printf(
    "%9s\t %f sec\t%d times/sec\n",
    v[1],(et-st),n/(et-st)
  )
end
