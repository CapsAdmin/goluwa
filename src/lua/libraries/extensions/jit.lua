jit.profiler = require("jit.profile")
jit.vmdef = require("jit.vmdef")
jit.util = require("jit.util")
jit.bc = require("jit.bc")
jit.v = require("jit.v")
jit.opt = require("jit.opt")
jit.dump = require("jit.dump")
jit.dis = require("jit.dis_x64")

function jit.dumpinfo(cb, output)
	local old = system.GetJITOptions().hotloop
	jit.opt.start("hotloop=1")
	jit.dump.on("tbimrsXaT", output)
	local ok, err = pcall(function() cb()cb()cb()cb() end) -- uhhh
	jit.dump.off()
	jit.opt.start("hotloop="..old)
	if not ok then logn(err) end
end

function jit.dumpbytecode(func)
	local out = {
		write = function(t, ...) log(...) end,
		close = function(t) end,
		flush = function(t) end,
	}

	jit.bc.dump(func, out)
end