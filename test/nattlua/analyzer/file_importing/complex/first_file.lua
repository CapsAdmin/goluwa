local foo = require("test.nattlua.analyzer.file_importing.complex.foo")()
local bar = require("test.nattlua.analyzer.file_importing.complex.bar")
return foo.get() + bar
