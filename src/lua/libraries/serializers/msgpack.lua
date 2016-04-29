local serializer = ...

local msgpack = require("msgpack")
serializer.AddLibrary("msgpack", function(...) return msgpack.encode({...}) end, function(var) return unpack((msgpack.decode(var))) end, msgpack)