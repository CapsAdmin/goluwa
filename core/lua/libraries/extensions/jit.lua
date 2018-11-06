local out = {
	write = function(t, ...) log(...) end,
	close = function(t) end,
	flush = function(t) end,
}

jit.vmdef = desire("jit.vmdef")
jit.util = desire("jit.util")

if jit.util then
	local old = jit.util.funcinfo

	function jit.util.funcinfo(...)
		local t = old(...)

		if t.loc and t.source and t.source:startswith("@") then
			t.loc = t.source:sub(2) .. ":" .. t.loc:match(".+:(.+)")
		end

		return t
	end
end

jit.profiler = desire("jit.profile")
jit.bc = desire("jit.bc")
jit.v = desire("jit.v")
jit.opt = desire("jit.opt")
jit.dump = desire("jit.dump")
jit.dis = desire("jit.dis_x64")

if jit.dump and jit.opt then
	function jit.dumpinfo(cb, output)
		local old = jit.getoptions().hotloop
		jit.opt.start("hotloop=1")
		jit.dump.on("tbimrsXaT", output)
		local ok, err = pcall(function() cb()cb()cb()cb() end) -- uhhh
		jit.dump.off()
		jit.opt.start("hotloop="..old)
		if not ok then logn(err) end
	end
end

if jit.bc then
	function jit.dumpbytecode(func)
		local str = {}
		jit.bc.dump(func, {flush = function() end, write = function(_, s) str[#str + 1] = s end}, true)

		return table.concat(str)
	end
end

if jit.v then
	function jit.debug(b)
		if b then
			jit.v.on()
		else
			jit.v.off()
		end
	end
end

if not jit.tracebarrier then
	jit.tracebarrier = function() debug.gethook() end
end

do
	local current = {
		-- maximum number of traces in the cache
		-- default = 1000
		-- min = 1
		-- max = 65535
		maxtrace = 65535,

		-- maximum number of recorded IR instructions
		-- default = 4000
		maxrecord = 20000,

		-- maximum number of IR constants of a trace
		-- default = 500
		maxirconst = 2500,

		-- maximum number of side traces of a root trace
		-- default = 100
		maxside = 100,

		-- maximum number of snapshots for a trace
		-- default = 500
		maxsnap = 800,

		-- minimum number of IR ins for a stitched trace.
		-- default = 0
		minstitch = 0,

		-- number of iterations to detect a hot loop or hot call
		-- default = 56
		hotloop = 56,

		-- number of taken exits to start a side trace
		-- default = 10
		hotexit = 10,

		-- number of attempts to compile a side trace
		-- default = 4
		tryside = 4,

		-- maximum unroll factor for instable loops
		-- default = 4
		instunroll = 500,

		-- maximum unroll factor for loop ops in side traces
		-- default = 15
		loopunroll = 500,

		-- maximum unroll factor for pseudo-recursive calls
		-- default = 3
		callunroll = 500,

		-- minimum unroll factor for true recursion
		-- default = 2
		recunroll = 2,

		-- maximum total size of all machine code areas in KBytes
		-- default = 512
		maxmcode = 8192,

		--sizemcode = X64 and 64 or 32, -- Size of each machine code area in KBytes (Windows: 64K)

		-- Constant Folding, Simplifications and Reassociation
		fold = true,

		-- Common-Subexpression Elimination
		cse = true,

		-- Dead-Code Elimination
		dce = true,

		-- Narrowing of numbers to integers
		narrow = true,

		-- Loop Optimizations (code hoisting)
		loop = true,

		-- Load Forwarding (L2L) and Store Forwarding (S2L)
		fwd = true,

		-- Dead-Store Elimination
		dse = true,

		-- Array Bounds Check Elimination
		abc = true,

		-- Allocation/Store Sinking
		sink = true,

		-- Fusion of operands into instructions
		fuse = true,
	}

	if current.minstitch then
		if jit.version:find("LuaJIT 2.0", nil, true) then
			current.minstitch = nil
		end
	end

	function jit.getoptions()
		return current
	end

	local last = {}

	local function update()
		local options = {}

		for k, v in pairs(current) do
			if type(v) == "number" then
				table.insert(options, k .. "=" .. v)
			elseif type(v) == "boolean" then
				table.insert(options, v and ("+" .. k) or ("-" .. k))
			end
		end

		jit.opt.start(unpack(options))
		jit.flush()
	end

	function jit.setoption(option, val)
		if current[option] == nil then error("not a valid option", 2) end

		current[option] = val

		if last[option] ~= val then
			logn("jit option ", option, " = ", val)

			update()

			last[option] = val
		end
	end
end