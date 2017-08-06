local serializer = ...

serializer.AddLibrary(
	"json",
	function(json, ...) return json.encode(...) end,
	function(json, ...) return json.decode(...) end,
	"lunajson"
)
