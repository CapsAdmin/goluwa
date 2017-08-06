local serializer = ...

serializer.AddLibrary(
	"von",
	function(...) return von.serialize(...) end,
	function(...) return von.deserialize(...) end,
	"von"
)
