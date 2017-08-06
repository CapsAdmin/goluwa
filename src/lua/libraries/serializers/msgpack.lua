local serializer = ...

serializer.AddLibrary(
	"msgpack",
	function(msgpack, val) return msgpack.encode(val) end,
	function(msgpack, val) return msgpack.decode(val) end,
	"msgpack"
)

serializer.AddLibrary(
	"msgpack2",
	function(msgpack2, val) return msgpack2.pack(val) end,
	function(msgpack2, val) return select(2, msgpack2.unpack(val)) end,
	"msgpack2"
)