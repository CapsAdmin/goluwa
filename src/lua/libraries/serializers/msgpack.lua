local serializer = ...

local msgpack = require("msgpack")
serializer.AddLibrary("msgpack", function(val) return msgpack.encode(val) end, function(var) return msgpack.decode(var) end, msgpack)