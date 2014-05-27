local encode, decode

local test_module = ... -- command line argument
--local test_module = 'cmj-json'
--local test_module = 'dkjson'
--local test_module = 'dkjson-nopeg'
--local test_module = 'fleece'
--local test_module = 'jf-json'
--locel test_module = 'lua-yajl'
--local test_module = 'mp-cjson'
--local test_module = 'nm-json'
--local test_module = 'sb-json'
--local test_module = 'th-json'


if test_module == 'cmj-json' then
  -- http://json.luaforge.net/
  local json = require "cmjjson" -- renamed, the original file was just 'json'
  encode = json.encode
  decode = json.decode
elseif test_module == 'dkjson' then
  -- http://chiselapp.com/user/dhkolf/repository/dkjson/
  local dkjson = require "dkjson"
  encode = dkjson.encode
  decode = dkjson.decode
elseif test_module == 'dkjson-nopeg' then
  package.preload["lpeg"] = function () error "lpeg disabled" end
  package.loaded["lpeg"] = nil
  lpeg = nil
  local dkjson = require "dkjson"
  encode = dkjson.encode
  decode = dkjson.decode
elseif test_module == 'fleece' then
  -- http://www.eonblast.com/fleece/
  local fleece = require "fleece"
  encode = function(x) return fleece.json(x, "E4") end
elseif test_module == 'jf-json' then
  -- http://regex.info/blog/lua/json
  local json = require "jfjson" -- renamed, the original file was just 'JSON'
  encode = function(x) return json:encode(x) end
  decode = function(x) return json:decode(x) end
elseif test_module == 'lua-yajl' then
  -- http://github.com/brimworks/lua-yajl
  local yajl = require ("yajl")
  encode = yajl.to_string
  decode = yajl.to_value
elseif test_module == 'mp-cjson' then
  -- http://www.kyne.com.au/~mark/software/lua-cjson.php
  local json = require "cjson"
  encode = json.encode
  decode = json.decode
elseif test_module == 'nm-json' then
  -- http://luaforge.net/projects/luajsonlib/
  local json = require "LuaJSON"
  encode = json.encode or json.stringify
  decode = json.decode or json.parse
elseif test_module == 'sb-json' then
  -- http://www.chipmunkav.com/downloads/Json.lua
  local json = require "sbjson" -- renamed, the original file was just 'Json'
  encode = json.Encode
  decode = json.Decode
elseif test_module == 'th-json' then
  -- http://luaforge.net/projects/luajson/
  local json = require "json"
  encode = json.encode
  decode = json.decode
else
  print "No module specified"
  return
end

-- example data taken from
-- http://de.wikipedia.org/wiki/JavaScript_Object_Notation

local str = [[
{
  "Herausgeber": "Xema",
  "Nummer": "1234-5678-9012-3456",
  "Deckung": 26,
  "Währung": "EUR",
  "Inhaber": {
    "Name": "Mustermann",
    "Vorname": "Max",
    "männlich": true,
    "Depot": {},
    "Hobbys": [ "Reiten", "Golfen", "Lesen" ],
    "Alter": 42,
    "Kinder": [0],
    "Partner": null
  }
}
]]

local tbl = {
  Herausgeber= "Xema",
  Nummer= "1234-5678-9012-3456",
  Deckung= 2e+6,
  ["Währung"]= "EUR",
  Inhaber= {
    Name= "Mustermann",
    Vorname= "Max",
    ["männlich"]= true,
    Depot= {},
    Hobbys= { "Reiten", "Golfen", "Lesen" },
    Alter= 42,
    Kinder= {},
    Partner= nil
    --Partner= json.null
  }
}

local t1, t2

if decode then
  t1 = os.clock ()
  for i = 1,100000 do
    decode (str)
  end
  t2 = os.clock ()
  print ("Decoding:", t2 - t1)
end

if encode then
  t1 = os.clock ()
  for i = 1,100000 do
    encode (tbl)
  end
  t2 = os.clock ()
  print ("Encoding:", t2 - t1)
end

