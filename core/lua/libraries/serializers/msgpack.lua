local serializer = ...

serializer.AddLibrary(
	"msgpack",
	function(msgpack, val) return msgpack.encode(val) end,
	function(msgpack, val) return msgpack.decode(val) end,
	desire("msgpack_ffi")
)
