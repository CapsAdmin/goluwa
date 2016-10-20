local serializer = ...

local msgpack = require("msgpack")
serializer.AddLibrary("msgpack", function(val) return msgpack.encode(val) end, function(var) return msgpack.decode(var) end, msgpack)

local msgpack2 = require("msgpack2")
serializer.AddLibrary("msgpack2", function(val) return msgpack2.pack(val) end, function(var) return select(2, msgpack2.unpack(var)) end, msgpack2)