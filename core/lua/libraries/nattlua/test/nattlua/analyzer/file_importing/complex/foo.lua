local META = {}
require("test.nattlua.analyzer.file_importing.complex.baz")(META)
require("test.nattlua.analyzer.file_importing.complex.baz")(META)
require("test.nattlua.analyzer.file_importing.complex.baz")(META)
return function(config)
	return META
end
