local start_time = os.clock()

if not os.getenv("GOLUWA_CLI") then
	if os.getenv("GOLUWA_CLI_TIME") then
		io.write("[runfile] ", os.getenv("GOLUWA_CLI_TIME"), " seconds spent in ./goluwa", jit.os == "Windows" and ".cmd" or "", "\n")
	end

	if os.getenv("GOLUWA_BOOT_TIME") then
		io.write("[runfile] ", os.getenv("GOLUWA_BOOT_TIME"), " seconds spent in core/lua/boot.lua\n")
	end
end

os.setlocale("")
io.stdout:setvbuf("no")

do
	local ok, opt = pcall(require, "jit.opt")
	if ok then
		opt.start(
			"maxtrace=65535", -- 1000 1-65535: maximum number of traces in the cache
			"maxrecord=20000", -- 4000: maximum number of recorded IR instructions
			"maxirconst=2500", -- 500: maximum number of IR constants of a trace
			"maxside=100", -- 100: maximum number of side traces of a root trace
			"maxsnap=800", -- 500: maximum number of snapshots for a trace
			"minstitch=0", -- 0: minimum number of IR ins for a stitched trace.
			"hotloop=56", -- 56: number of iterations to detect a hot loop or hot call
			"hotexit=10", -- 10: number of taken exits to start a side trace
			"tryside=4", -- 4: number of attempts to compile a side trace
			"instunroll=500", -- 4: maximum unroll factor for instable loops
			"loopunroll=500", -- 15: maximum unroll factor for loop ops in side traces
			"callunroll=500", -- 3: maximum unroll factor for pseudo-recursive calls
			"recunroll=2", -- 2: minimum unroll factor for true recursion
			"maxmcode=8192", -- 512: maximum total size of all machine code areas in KBytes
			--jit.os == "x64" and "sizemcode=64" or "sizemcode=32", -- Size of each machine code area in KBytes (Windows: 64K)
			"+fold", -- Constant Folding, Simplifications and Reassociation
			"+cse", -- Common-Subexpression Elimination
			"+dce", -- Dead-Code Elimination
			"+narrow", -- Narrowing of numbers to integers
			"+loop", -- Loop Optimizations (code hoisting)
			"+fwd", -- Load Forwarding (L2L) and Store Forwarding (S2L)
			"+dse", -- Dead-Store Elimination
			"+abc", -- Array Bounds Check Elimination
			"+sink", -- Allocation/Store Sinking
			"+fuse" -- Fusion of operands into instructions
		)
	end
end

--loadfile("../../core/lua/modules/bytecode_cache.lua")()

local PROFILE_STARTUP = false

if PROFILE_STARTUP then
	local old = io.stdout
	io.stdout = {write = function(_, ...) io.write(...) end}
	require("jit.p").start("rplfvi1")
	io.stdout = old
end

-- put all c functions in a table so we can override them if needed
-- without doing the local oldfunc = print thing over and over again

if not _G._OLD_G then
	local _OLD_G = {}
	if pcall(require, "ffi") then
		_G.ffi = require("ffi")
	end

	for k,v in pairs(_G) do
		if k ~= "_G" then
			local t = type(v)
			if t == "function" then
				_OLD_G[k] = v
			elseif t == "table" then
				_OLD_G[k] = {}
				for k2, v2 in pairs(v) do
					if type(v2) == "function" then
						_OLD_G[k][k2] = v2
					end
				end
			end
		end
	end

	_G.ffi = nil
	_G._OLD_G = _OLD_G
end

local info = assert(debug.getinfo(1), "debug.getinfo(1) returns nothing")
local init_lua_path = info.source
local relative_root, internal_addon_name = init_lua_path:match("^@(.+/)(.+)/lua/init.lua$")

do -- constants

	-- enums table
	e = e or {}
	e.USERNAME = _G.USERNAME or tostring(os.getenv("USERNAME") or os.getenv("USER")):gsub(" ", "_"):gsub("%p", "")
	e.INTERNAL_ADDON_NAME = internal_addon_name

	-- _G constants. should only contain you need to access a lot like if LINUX then
	_G[e.USERNAME:upper()] = true
	_G[jit.os:upper()] = true
	_G[jit.arch:upper()] = true

	if not _G.PLATFORM then
		if jit.os == "Windows" then
			_G.PLATFORM = "windows"
		else
			_G.PLATFORM = "unix"
		end
	end

	_G.CLI = os.getenv("GOLUWA_CLI")
end

do
	-- force lookup modules in current directory rather than system
	if WINDOWS then
		package.cpath = "./?.dll"
	elseif OSX then
		package.cpath = "./?.dylib;./?.so"
	else
		package.cpath = "./?.so"
	end

	package.path = "./?.lua"
end

do
	local fs = loadfile(relative_root .. e.INTERNAL_ADDON_NAME .. "/lua/libraries/platforms/" .. PLATFORM .. "/filesystem.lua")()
	package.loaded.fs = fs

	-- create constants
	e.BIN_FOLDER = fs.getcd():gsub("\\", "/") .. "/"
	e.ROOT_FOLDER = e.BIN_FOLDER:match("(.+/)" .. (".-/"):rep(select(2, relative_root:gsub("/", ""))))
	e.CORE_FOLDER = e.ROOT_FOLDER .. e.INTERNAL_ADDON_NAME .. "/"
	e.DATA_FOLDER = e.ROOT_FOLDER .. "data/"
	e.USERDATA_FOLDER = e.DATA_FOLDER .. "users/" .. e.USERNAME:lower() .. "/"

	fs.createdir(e.DATA_FOLDER)
	fs.createdir(e.DATA_FOLDER .. "users/")
	fs.createdir(e.USERDATA_FOLDER)
end

_G.runfile = function(path, ...) return loadfile(e.CORE_FOLDER .. path)(...) end

-- standard library extensions
(function(...) local out = {
	write = function(t, ...) log(...) end,
	close = function(t) end,
	flush = function(t) end,
}

pcall(function()

jit.vmdef = require("jit.vmdef")
jit.util = require("jit.util")

local old = jit.util.funcinfo

function jit.util.funcinfo(...)
	local t = old(...)

	if t.loc and t.source and t.source:startswith("@") then
		t.loc = t.source:sub(2) .. ":" .. t.loc:match(".+:(.+)")
	end

	return t
end

jit.profiler = require("jit.profile")
jit.bc = require("jit.bc")
jit.v = require("jit.v")
jit.opt = require("jit.opt")
jit.dump = require("jit.dump")
jit.dis = require("jit.dis_x64")

end)

function jit.dumpinfo(cb, output)
	local old = jit.getoptions().hotloop
	jit.opt.start("hotloop=1")
	jit.dump.on("tbimrsXaT", output)
	local ok, err = pcall(function() cb()cb()cb()cb() end) -- uhhh
	jit.dump.off()
	jit.opt.start("hotloop="..old)
	if not ok then logn(err) end
end

function jit.dumpbytecode(func)
	jit.bc.dump(func, dummy_file, true)
end

function jit.debug(b)
	if b then
		jit.v.on()
	else
		jit.v.off()
	end
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

pcall(function()
	local loom = loadfile("../../../"..e.INTERNAL_ADDON_NAME.."/lua/modules/loom.lua")()
	package.preload["jit.loom"] = function() return loom end
	jit.loom = require("jit.loom")

	local html_template = [[<!DOCTYPE html>
<html lang="en">
	{@ traces, funcs}
	{%
		local loom = require 'jit.loom'
		local function class(t)
			if not t then return '' end
			o = {}
			for k, v in pairs(t) do
				if v then o[#o+1] = k end
			end
			if #o == 0 then return '' end
			return 'class="'..table.concat(o, ' ')..'"'
		end

		local _ft_, _fndx_ = {}, 0
		local function funclabel(f)
			if not f then return '' end
			if _ft_[f] == nil then
				_fndx_ = _fndx_+1
				_ft_[f] = ('fn%03d'):format(_fndx_)
			end
			return _ft_[f]
		end

		local function lines(s)
			s = s or ''
			local o = {}
			for l in s:gmatch('[^\r\n]+') do
				o[#o+1] = l
			end
			return o
		end

		local function cols(s, cwl)
			local o, start = {}, 1
			for i, w in ipairs(cwl) do
				o[i] = s:sub(start, start+w-1):gsub('%s+$', '')
				start = start+w
			end
			return o
		end

		local function is_irref(f)
			if f:match('^%d%d%d%d$') then
				return 'ref_'..f
			end
		end

		local function all_refs(s)
			c = {}
			for ref in s:gmatch('%d+') do
				c[#c+1] = is_irref(ref)
			end
			return table.concat(c, ' ')
		end

		local function table_ir(txt)
			local o = lines(txt)
			local cwl = {5, 6, 3, 4, 7, 6, 1000}
			for i, l in ipairs(o) do
				l = cols(l, cwl)
				local class = {is_irref(l[1])}
				if l[5] == 'SNAP' then
					class[#class+1] = 'snap_'..l[6]:sub(2)
					l.title = l[7]
					l[7] = ('<span class="opt">%s</span>'):format(l[7])
				end
				l.class = next(class) and table.concat(class, ' ')
				o[i] = l
			end
			return o
		end

		local function annot_mcode(txt)
			if type(txt) ~= 'string' then return '' end
			txt = txt:gsub('%(exit (%d+)/(%d+)%)', function (a, b)
				a, b = tonumber(a), tonumber(b)
				return ('(exit %d/%d [n=%d])'):format(a, b, traces[a].exits[b] or 0)
			end)
			txt = _e(txt)
			txt = txt:gsub('Trace #(%d+)', function (tr)
				return ('<span class="tr%03d">Trace #%d</span>'):format(
					tr, tr)
			end)
			return txt
		end

		local cmdline = ''
		do
			local minarg, maxarg = 1000,-1000
			for k in pairs(arg) do
				if type(k) == 'number' then
					minarg = math.min(k, minarg)
					maxarg = math.max(k, maxarg)
				end
			end
			local newarg = {}
			for i = minarg, maxarg do
				local v = tostring(arg[i])
				if v:find('[^%w.,/=_-]') then
					v = ('%q'):format(v)
				end
				newarg[i] = v
			end
			cmdline = table.concat(newarg, ' ', minarg, maxarg)
		end

		local annotated = loom.annotated(funcs, traces)
	%}
	<head>
		<meta charset="utf-8" />
		<style media="screen" type="text/css">
			.code {
				font-family: monospace;
				white-space: pre;
				tab-size: 4;
			}
			.opt { display: none; }
			.codespan {
				width: 100%;
			}
			.bordertop td {
				border-top: thin lightgray solid;
			}
			.phantom {
				color: #ccc;
			}
			.white {
				background-color: white;
			}
			.hilight {
				background-color: lightsteelblue;
			}
			{% for f, fi in pairs(funcs) do %}.{{funclabel(f)}} {
				background-color: hsla({{math.random(360)}}, 100%, 90%, 1);
			}
			{% end %}

			{% for i = 1, table.maxn(traces) do %}{{:'.tr%03d', i}} {
				background-color: hsla({{math.random(360)}}, 80%, 75%, 1);
			}
			{% end %}
		</style>
		<script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
		<script>
			var sameref = function (elm, parent) {
				var refmatch = elm.className.match(/ref_\d+/);
				return refmatch ? $(elm).closest(parent).find('.'+refmatch[0])
						: $();
				return $(elm).closest(parent).find('.'+refclass);
			}
			$(function() {
				$('th.bc').click(function(e) {
					$('.bc .opt').toggle();
				});
				$('th.ir').click(function(e) {
					$('.ir .opt').toggle();
				});
				$('th.titlebar').click(function(e) {
					$(e.target).closest('tr').siblings().toggle();
				});
				$('[class^="ref_"]').mouseenter(function(e) {
					sameref(e.target, '.ir').addClass('hilight');
				}).mouseleave(function(e){
					sameref(e.target, '.ir').removeClass('hilight');
				});
			});
		</script>
		<title>{{cmdline}}</title>
	</head>
	<body>
	<h2>{{=cmdline:gsub('\\[\r\n]+',"<br/>")}}</h2>
	<table class="code" cellpadding="0" cellspacing="0">
		{% for filename, filedata in pairs(annotated) do
			local lastline
			%}
			<tr>
				<th colspan="2">{{ filename }}</th>
				<th colspan="3">Bytecode</th>
			</th>
			{% for i, l in loom.sortedpairs(filedata) do
				local notsame = l.i ~= lastline
				lastline = l.i
				%}
			<tr {{= class{bordertop=notsame and l.bc ~= ''} }}>
				<td {{= class{phantom=l.back} }}> {{ notsame and l.i or '' }} </td>
				<td {{= class{phantom=l.back} }}> {{ notsame and l.src or '' }} </td>
				<td {{= class{[funclabel(l.func)] = l.bc ~= ''} }}> {{ l.bc }} </td>
				<td>{% for i, tr in ipairs(l.tr or {}) do
					local trref = ('tr%03d'):format(tr[1])
					local lnref = ('tr%03d_%03d'):format(tr[1], tr[2])
					%} <a href="#{{trref}}" name="{{lnref}}"><span
						id="{{lnref}}"
						class="{{trref}}"
					>{{tr[1]}}/{{tr[2]}}</span></a> {%
				end %}</td>
				<td>{% for msg, n in pairs(l.evt or {}) do
					%} <span>"{{msg}}" [n={{n}}]</span> {%
				end %}</td>
			</tr>
			{% end %}
		{% end %}
	</table>

	{% for i, tr in loom.allipairs(traces) do local prevsrc%}
		<br/>
		<a name="#{{:'tr%0dd', i}}"><table class="popup trace {{:'tr%03d', i}}" id="{{:'tr%03d', i}}" cellpadding="4">
			<tr>
				<th colspan="3" class="titlebar">Trace #{{i}}: {{tr.tracelabel}}</th>
			</tr>
			<tr class="white">
				<th class="bc" >bytecode</th>
				<th class="ir" >IR</th>
				<th class="mcode" >mcode</th>
			</tr>
			<tr class="white" valign="top">
				<td class="code bc"><table cellpadding="0" cellspacing="0">
					{% for j, rec in ipairs(tr.rec) do
						local f, pc, l, src = unpack(rec)
						local srcline = src and ('%s:%d %s'):format(src.name, src.i, src.l or '')
						local lnref = ('tr%03d_%03d'):format(i, j)
						%}
					<tr class="code">
						<td class="{{:'tr%03d', i}}"><a href="#{{lnref}}">{{i}}/{{j}}</a> </td>
						<td class="{{funclabel(f)}}"> {{l}} </td>
						<td class="src opt">{{srcline ~= prevsrc and srcline or ''}}</td>
					</tr>
					{% prevsrc = srcline
					end %}
				</table></td>
				<td class="code ir"><table>
					{%for _, l in ipairs(table_ir(tr.ir)) do %}
						<tr class="{{=l.class or ''}}" title="{{=l.title}}">{% for _, f in ipairs(l) do %}
							<td class="{{=all_refs(f)}}">{{=f}}</td>
						{% end %}</tr>
					{% end %}
				</table></td>
				<td class="code mcode">{{=annot_mcode(tr.mcode)}}</td>
			</tr>
		</table></a>
	{% end %}
	</body>
</html>
]]
	local dot_template = [[{@ traces, funcs}
{%
	local loom = require 'jit.loom'
	local funcinfo = require ('jit.util').funcinfo
	local nodeshape = {
		none = 'shape=none',
		root = 'shape=ellipse',
		loop = 'penwidth=3.0',
		['tail-recursion'] = 'shape=diamond',
		['up-recursion'] = 'shape=house',
		['down-recursion'] = 'ishape=nvhouse',
		interpreter = 'shape=egg',
		['return'] = 'shape=parallelogram',
		stitch = 'shape=Mdiamond',
	}
%}
digraph G {
	{% for i, tr in loom.allipairs(traces) do
		local entryinfo = funcinfo(tr.rec[1][1], tr.rec[1][2])
		local shape = nodeshape[tr.info.linktype] or 'circle' %}
		T{{ i }} [{{ shape }}, label="#{{ i }}\n{{ entryinfo.loc }}", href="#tr{{ i }}"]
	{% end %}

	{% for i, tr in loom.allipairs(traces) do %}
		{% if false and tr.info.linktype == 'loop' then %}
			T{{ i }} -> T{{ i }};
		{% end %}
		{% if tr.parent and tr.p_exit and tr.p_exit>0 then %}
			T{{ tr.parent }} -> T{{ i }} [taillabel=">{{ tr.p_exit }}"];
		{% end %}
		{% if tonumber(tr.info.link) then %}
			T{{ i }} -> T{{ tr.info.link }} [dir=both, arrowtail=odot];
		{% end %}
	{% end %}

}]]

	local tmpl
	function loom.start2(type, clear)
		_G.arg = {}
		tmpl = loom.template(type == "html" and html_template or dot_template)
		loom.on(clear)
		--_G.arg = nil
	end

	function loom.stop()
		_G.arg = {}
		local res = loom.off(tmpl)
		--_G.arg = nil
		return res
	end
end)

if not jit.tracebarrier then
	jit.tracebarrier = function() debug.gethook() end
end end)()
(function(...) do
	local rawset = rawset
	local rawget = rawget
	local getmetatable = getmetatable
	local newproxy = newproxy

	if pcall(require, "table.gcnew") then
		local function gc(s)
			local tbl = s.tbl
			rawset(tbl, "__gc_proxy", nil)

			local new_meta = getmetatable(tbl)

			if new_meta then
				local __gc = rawget(new_meta, "__gc")
				if __gc then
					__gc(tbl)
				end
			end
		end

		-- 52 compat
		function setmetatable(tbl, meta)
			if meta and rawget(meta, "__gc") and not rawget(tbl, "__gc_proxy") then
				local proxy = _OLD_G.setmetatable(table.gcnew(), {__gc = gc})
				proxy.tbl = tbl

				rawset(tbl, "__gc_proxy", proxy)
			end

			return _OLD_G.setmetatable(tbl, meta)
		end
	else
		local function gc(s)
			local tbl = getmetatable(s).__div
			rawset(tbl, "__gc_proxy", nil)

			local new_meta = getmetatable(tbl)

			if new_meta then
				local __gc = rawget(new_meta, "__gc")
				if __gc then
					__gc(tbl)
				end
			end
		end

		-- 52 compat
		function setmetatable(tbl, meta)
			if meta and rawget(meta, "__gc") and not rawget(tbl, "__gc_proxy") then
				local proxy = newproxy(true)
				rawset(tbl, "__gc_proxy", proxy)

				getmetatable(proxy).__div = tbl
				getmetatable(proxy).__gc = gc
			end

			return _OLD_G.setmetatable(tbl, meta)
		end
	end
end
do -- logging
	local pretty_prints = {}

	pretty_prints.table = function(t)
		local str = tostring(t) or "nil"

		str = str .. " [" .. table.count(t) .. " subtables]"

		-- guessing the location of a library
		local sources = {}

		for _, v in pairs(t) do
			if type(v) == "function" then
				local src = debug.getinfo(v).source
				sources[src] = (sources[src] or 0) + 1
			end
		end

		local tmp = {}

		for k, v in pairs(sources) do
			table.insert(tmp, {k = k, v = v})
		end

		table.sort(tmp, function(a,b) return a.v > b.v end)

		if #tmp > 0 then
			str = str .. "[" .. tmp[1].k:gsub("!/%.%./", "") .. "]"
		end

		return str
	end

	local function tostringx(val)
		local t = (typex or type)(val)

		return pretty_prints[t] and pretty_prints[t](val) or tostring(val)
	end

	local function tostring_args(...)
		local copy = {}

		for i = 1, select("#", ...) do
			table.insert(copy, tostringx(select(i, ...)))
		end

		return copy
	end

	local function formatx(str, ...)
		local copy = {}
		local i = 1

		for arg in str:gmatch("%%(.)") do
			arg = arg:lower()

			if arg == "s" then
				table.insert(copy, tostringx(select(i, ...)))
			else
				table.insert(copy, (select(i, ...)))
			end

			i = i + 1
		end

		return string.format(str, unpack(copy))
	end

	local base_log_dir = e.USERDATA_FOLDER .. "logs/"

	local log_files = {}
	local log_file

	function getlogpath(name)
		name = name or "console"

		return base_log_dir .. name .. "_" .. jit.os:lower() .. ".txt"
	end

	function setlogfile(name)
		name = name or "console"

		if not log_files[name] then
			local file = assert(io.open(getlogpath(name), "w"))

			log_files[name] = file
		end

		log_file = log_files[name]
	end

	function getlogfile(name)
		name = name or "console"

		return log_files[name]
	end

	local last_line
	local count = 0
	local last_count_length = 0

	require("fs").createdir(base_log_dir)


	local suppress_print = false

	local function can_print(str)
		if suppress_print then return end

		if event then
			suppress_print = true

			if event.Call("ReplPrint", str) == false then
				suppress_print = false
				return false
			end

			suppress_print = false
		end

		return true
	end

	local silence

	local function raw_log(args, sep, append)
		if silence then return end
		local line = type(args) == "string" and args or table.concat(args, sep)

		if append then
			line = line .. append
		end

		if vfs then
			if not log_file then
				setlogfile()
			end

			if line == last_line then
				if count > 0 then
					local count_str = ("[%i x] "):format(count)
					log_file:seek("cur", -#line-1-last_count_length)
					log_file:write(count_str, line)
					last_count_length = #count_str
				end
				count = count + 1
			else
				log_file:write(line)
				count = 0
				last_count_length = 0
			end

			log_file:flush()

			last_line = line
		end

		if log_files.console == log_file then
			if repl and repl.Print and repl.curses_init then
				repl.Print(line)
			elseif can_print(line) then
				io.write(line)
			end
		end
	end

	function silence_log(b)
		silence = b
	end

	function log(...)
		raw_log(tostring_args(...), "")
		return ...
	end

	function logn(...)
		raw_log(tostring_args(...), "", "\n")
		return ...
	end

	function print(...)
		raw_log(tostring_args(...), ",\t", "\n")
		return ...
	end

	function logf(str, ...)
		raw_log(formatx(str, ...), "")
		return ...
	end

	function errorf(str, level, ...)
		error(formatx(str, ...), level)
	end

	function logsection(type, b)
		event.Call("LogSection", type, b)
	end

	do
		local level = 1
		function logsourcelevel(n)
			if n then
				level = n
			end
			return level
		end
	end

	-- library log
	function llog(fmt, ...)
		fmt = tostringx(fmt)

		local level = tonumber(select(fmt:count("%") + 1, ...) or 1) or 1

		local source = debug.getprettysource(level + 1, false, true)
		local main_category = source:match(".+/libraries/(.-)/")
		local sub_category = source:match(".+/libraries/.-/(.-)/") or source:match(".+/(.-)%.lua")

		if sub_category == "libraries" then
			sub_category = source:match(".+/libraries/(.+)%.lua")
		end

		local str = fmt:safeformat(...)

		if not main_category or not sub_category or main_category == sub_category then
			return logf("[%s] %s\n", main_category or sub_category, str)
		else
			return logf("[%s][%s] %s\n", main_category, sub_category, str)
		end

		return str
	end

	-- warning log
	function wlog(fmt, ...)
		fmt = tostringx(fmt)

		local level = tonumber(select(fmt:count("%") + 1, ...) or 1) or 1

		local str = fmt:safeformat(...)
		local source = debug.getprettysource(level + 1, true)

		logn(source, ": ", str)

		return fmt, ...
	end
end

do
	local luadata

	function fromstring(str)
		local num = tonumber(str)
		if num then return num end
		luadata = luadata or serializer.GetLibrary("luadata")
		return unpack(luadata.Decode(str, true)) or str
	end
end

function vprint(...)
	logf("%s:\n", debug.getinfo(logsourcelevel() + 1, "n").name or "unknown")

	for i = 1, select("#", ...) do
		local name = debug.getlocal(logsourcelevel() + 1, i)
		local arg = select(i, ...)
		logf("\t%s:\n\t\ttype: %s\n\t\tprty: %s\n", name or "arg" .. i, type(arg), tostring(arg), serializer.Encode("luadata", arg))
		if type(arg) == "string" then
			logn("\t\tsize: ", #arg)
		end
		if typex(arg) ~= type(arg) then
			logn("\t\ttypx: ", typex(arg))
		end
	end
end

function desire(name)
	local ok, res = pcall(require, name)

	if not ok then
		wlog("unable to require %s:\n\t%s", name, res, 2)

		return nil, res
	end

	if not res and package.loaded[name] then
		return package.loaded[name]
	end

	return res
end

do -- nospam
	local last = {}

	function logf_nospam(str, ...)
		local str = string.format(str, ...)
		local t = system.GetElapsedTime()

		if not last[str] or last[str] < t then
			logn(str)
			last[str] = t + 3
		end
	end

	function logn_nospam(...)
		logf_nospam(("%s "):rep(select("#", ...)), ...)
	end
end

do -- wait
	local temp = {}

	function wait(seconds)
		local time = system.GetElapsedTime()
		if not temp[seconds] or (temp[seconds] + seconds) <= time then
			temp[seconds] = system.GetElapsedTime()
			return true
		end
		return false
	end
end

local idx = function(var) return var.Type end

function hasindex(var)
	if getmetatable(var) == getmetatable(NULL) then return false end

	local T = type(var)

	if T == "string" then
		return false
	end

	if T == "table" then
		return true
	end

	if not pcall(idx, var) then return false end

	local meta = getmetatable(var)

	if meta == "ffi" then return true end

	T = type(meta)

	return T == "table" and meta.__index ~= nil
end

function typex(var)
	local t = type(var)

	if
		t == "nil" or
		t == "boolean" or
		t == "number" or
		t == "string" or
		t == "userdata" or
		t == "function" or
		t == "thread"
	then
		return t
	end

	local ok, res = pcall(idx, var)

	if ok and res then
		return res
	end

	return t
end

function istype(var, t)
	if
		t == "nil" or
		t == "boolean" or
		t == "number" or
		t == "string" or
		t == "userdata" or
		t == "function" or
		t == "thread" or
		t == "table" or
		t == "cdata"
	then
		return type(var) == t
	end

	return typex(var) == t
end

local pretty_prints = {}

pretty_prints.table = function(t)
	local str = tostring(t)

	str = str .. " [" .. table.count(t) .. " subtables]"

	-- guessing the location of a library
	local sources = {}
	for _, v in pairs(t) do
		if type(v) == "function" then
			local src = debug.getinfo(v).source
			sources[src] = (sources[src] or 0) + 1
		end
	end

	local tmp = {}
	for k, v in pairs(sources) do
		table.insert(tmp, {k = k, v = v})
	end

	table.sort(tmp, function(a,b) return a.v > b.v end)
	if #tmp > 0 then
		str = str .. "[" .. tmp[1].k:gsub("!/%.%./", "") .. "]"
	end


	return str
end

pretty_prints["function"] = function(self)
	return ("function[%p][%s](%s)"):format(self, debug.getprettysource(self, true), table.concat(debug.getparams(self), ", "))
end

function tostringx(val)
	local t = type(val)

	if t == "table" and getmetatable(val) then return tostring(val) end

	return pretty_prints[t] and pretty_prints[t](val) or tostring(val)
end

function tostring_args(...)
	local copy = {}

	for i = 1, select("#", ...) do
		table.insert(copy, tostringx(select(i, ...)))
	end

	return copy
end

function istype(var, ...)
	for _, str in pairs({...}) do
		if typex(var) == str then
			return true
		end
	end

	return false
end

do -- negative pairs
	local v
	local function iter(a, i)
		i = i - 1
		v = a[i]
		if v then
			return i, v
		end
	end

	function npairs(a)
		return iter, a, #a + 1
	end
end

function rpairs(tbl)
	local sorted = {}

	for key, val in pairs(tbl) do
		table.insert(sorted, {key = key, val = val, rand = math.random()})
	end

	table.sort(sorted, function(a,b) return a.rand > b.rand end)

	local i = 0

	return function()
		i = i + 1
		if sorted[i] then
			return sorted[i].key, sorted[i].val--, sorted[i].rand
		end
	end
end

function spairs(tbl, desc)
	local sorted = {}

	for key, val in pairs(tbl) do
		table.insert(sorted, {key = key, val = val})
	end

	if desc then
		table.sort(sorted, function(a,b) return a.key > b.key end)
	else
		table.sort(sorted, function(a,b) return a.key < b.key end)
	end

	local i = 0

	return function()
		i = i + 1
		if sorted[i] then
			return sorted[i].key, sorted[i].val--, sorted[i].rand
		end
	end
end end)()
(function(...) 
do
	local file
	local max_lines = 10000

	function debug.loglines(b)
		if b == nil then b = not file end

		if b then
			local path = R"data/" .. "debug_lines.lua"
			file = assert(io.open(path, "wb"))
			jit.off()
			jit.flush()
			local i = 0
			debug.sethook(function()
				if not file then debug.sethook() return end
				local info = debug.getinfo(2)

				if i > max_lines then
					file:close()
					file = assert(io.open(path, "wb"))
					i = 0
				end

				file:write(info.source, ":", info.currentline, "\n")
				file:flush()

				i = i + 1
			end, "l")
		else
			if file then file:close() file = nil end
			jit.on()
			jit.flush()
			debug.sethook()
		end
	end
end

function debug.getsource(func)
	local info = debug.getinfo(func)
	local src = vfs.Read(e.ROOT_FOLDER .. "/" .. info.source:sub(2))
	if not src then
		src = vfs.Read(info.source:sub(2))
	end
	if src then
		local lines = src:split("\n")
		local str = {}
		for i = info.linedefined, info.lastlinedefined do
			table.insert(str, lines[i])
		end
		return table.concat(str, "\n")
	end
	return "source unavailble for: " .. info.source
end
function debug.getprettysource(level, append_line, full_folder)
	local info = debug.getinfo(type(level) == "number" and (level + 1) or level)
	local pretty_source = "debug.getinfo = nil"

	if info then
		if info.source:sub(1, 1) == "@" then
			pretty_source = info.source:sub(2)

			if not full_folder and vfs then
				pretty_source = vfs.FixPathSlashes(pretty_source:replace(e.ROOT_FOLDER, ""))
			end

			if append_line then
				local line = info.currentline
				if line == -1 then
					line = info.linedefined
				end
				pretty_source = pretty_source .. ":" .. line
			end
		else
			pretty_source = info.source:sub(0, 25)

			if pretty_source ~= info.source then
				pretty_source = pretty_source .. "...(+"..#info.source - #pretty_source.." chars)"
			end
		end
	end

	return pretty_source
end

do
	local started = {}

	function debug.loglibrary(library, filter, post_calls_only, lib_name)
		if type(library) == "string" then
			lib_name = library
			library = _G[library]
		end

		if not lib_name then
			for k,v in pairs(_G) do
				if v == library then
					lib_name = k
				end
			end

			if not lib_name then
				for k,v in pairs(package.loaded) do
					if v == library then
						lib_name = k
					end
				end
			end
			lib_name = lib_name or "unknown"
		end

		local log_name = lib_name .. "_calls"
		local arg_line

		if started[library] then
			for name, func in pairs(started[library]) do
				library[name] = func
			end
		else
			if type(filter) == "string" then
				filter = {filter}
			end

			filter = filter or {}

			for _, v in pairs(filter) do filter[v] = true end

			started[library] = {}

			local function log_return(...)
				if not filter[name] then
					if (post_calls_only or post_calls_only == nil) and arg_line then
						local ret = {}
						for i = 1, select("#", ...) do
							table.insert(ret, serializer.GetLibrary("luadata").ToString((select(i, ...))):sub(0,20))
						end

						if #ret ~= 0 then
							logf("%s = %s\n", table.concat(ret, ", "), arg_line)
						else
							logn(arg_line)
						end

						arg_line = nil
					end
				end

				setlogfile()

				return ...
			end

			for name, func in pairs(library) do
				if type(func) == "function" or type(func) == "cdata" then
					library[name] = function(...)
						setlogfile(log_name)

						if not post_calls_only and not filter[name] then

							local args = {}
							for i = 1, select("#", ...) do
								table.insert(args, serializer.GetLibrary("luadata").ToString((select(i, ...))))
							end

							arg_line = ("%s.%s(%s) "):format(lib_name, name, table.concat(args, ", "):sub(0,100))
						end

						return log_return(func(...))
					end

					started[library][name] = func
				end
			end
		end
	end

end

function debug.trace(skip_print)
	local lines = {}

	for level = 1, math.huge do
		local info = debug.getinfo(level, "Sln")

		if info then
			lines[#lines + 1] = ("%i: Line %d\t\"%s\"\t%s"):format(level, info.currentline, info.name or "unknown", info.source or "")
		else
			break
		end
    end


	local str

	if debug.debugging then
		str = {}

		-- this doesn't really be long here..
		local stop = #lines

		for i = 2, #lines do
			if lines[i]:find("event") then
				stop = i - 2
			end
		end

		for i = 2, stop do
			table.insert(str, lines[i])
		end
	else
		str = lines
	end

	str = table.concat(str, "\n")

	if not skip_print then
		logn(str)
	end

	return str
end

function debug.getparams(func)
    local params = {}

	for i = 1, math.huge do
		local key = debug.getlocal(func, i)
		if key then
			table.insert(params, key)
		else
			break
		end
	end

    return params
end

function debug.getparamsx(func)
    local params = {}

	for i = 1, math.huge do
		local key, val = debug.getlocal(func, i)
		if key then
			table.insert(params, {key = key, val = val})
		else
			break
		end
	end

    return params
end

function debug.getupvalues(func)
	local params = {}

	for i = 1, math.huge do
		local key, val = debug.getupvalue(func, i)
		if key then
			table.insert(params, {key = key, val = val})
		else
			break
		end
	end

    return params
end

function debug.dumpcall(level, line, info_match)
	level = level + 1
	local info = debug.getinfo(level)
	local path = e.ROOT_FOLDER .. info.source:sub(2)
	local currentline = line or info.currentline

	if info_match and info.func ~= info_match.func then
		return
	end

	if info.source == "=[C]" then return end
	if info.source:find("ffi_binds") then return end
	if info.source:find("console%.lua") then return end
	if info.source:find("string%.lua") then return end
	if info.source:find("globals%.lua") then return end
	if info.source:find("strung%.lua") then return end
	if path == "../../../lua/init.lua" then return end

	if vfs.IsFile(path) then
		local script = vfs.Read(path)

		local lines = script:split("\n")

		for i = -20, 20 do
			local line = lines[currentline + i]

			if line then
				line = line:gsub("\t", "  ")
				if i == 0 then
					line = (currentline + i) .. ":==>\t" ..  line
				else
					line = (currentline + i) .. ":\t" .. line
				end

				logn(line)
			else
				if i == 0 then
					line = (">"):rep(string.len(currentline)) .. ":"
				else
					line = (currentline + i) .. ":"
				end

				logn(line, " ", "This line does not exist. It may be due to inlining so try running jit.off()")
			end
		end
	end

	logn(path)


	logn("LOCALS: ")
	for _, data in pairs(debug.getparamsx(level+1)) do
		--if not data.key:find("(",nil,true) then
			local val

			if type(data.val) == "table" then
				val = tostring(data.val)
			elseif type(data.val) == "string" then
				val = data.val:sub(0, 10)

				if val ~= data.val then
					val = val .. " .. " .. utility.FormatFileSize(#data.val)
				end
			else
				val = serializer.GetLibrary("luadata").ToString(data.val)
			end

			logf("%s = %s\n", data.key, val)
		--end
	end
	logn(debug.traceback())

	if info_match then
		print(info_match.func)
		print(info.func)
	end

	return true
end

function debug.logcalls(b, type)
	if not b then
		debug.sethook()
		return
	end

	type = type or "r"

	local hook

	hook = function()
		debug.sethook()

		setlogfile("lua_calls")
			logn(debug.traceback())
		setlogfile()

		debug.sethook(hook, type)
	end

	debug.sethook(hook, type)
end
 end)()
(function(...) function string.buildclass(...)
	local classes = {...}
	local check

	if type(classes[#classes]) == "function" then
		check = table.remove(classes, #classes)
	end

	local out = ""

	for i = 0, 255 do
		for _, class in ipairs(classes) do
			local char = string.char(i)
			if char:find(class) and (not check or check(char) ~= false) then
				out = out .. char
			end
		end
	end

	return out
end

function string.iswhitespace(char)
	return
		char == "\32" or
		char == "\9" or
		char == "\10" or
		char == "\11" or
		char == "\12"
end

function string.haswhitespace(str)
	for i = 1, #str do
		local b = str:byte(i)
		if b == 32 or (b >= 9 and b <= 12) then
			return true
		end
	end
end


function string.upperchar(self, pos)
	return self:sub(0, pos-1) .. self:sub(pos, pos):upper() .. self:sub(pos + 1)
end

function string.wholeword(self, what)
	return self:find("%f[%a%d_]"..what.."%f[^%a%d_]") ~= nil
end

function string.slice(self, what, from, offset)
	offset = offset or 0
	local _, pos = self:find(what, from, true)

	if pos then
		return self:sub(0, pos - offset), self:sub(pos + offset)
	end
end

do
	local vowels = {"e", "a", "o", "i", "u", "y"}
	local consonants = {"t", "n", "s", "h", "r", "d", "l", "c", "m", "w", "f", "g", "p", "b", "v", "k", "j", "x", "q", "z"}
	local first_letters = {"t", "a", "s", "h", "w", "i", "o", "b", "m", "f", "c", "l", "d", "p", "n", "e", "g", "r", "y", "u", "v", "j", "k", "q", "z", "x"}

	function string.randomwords(word_count, seed)
		word_count = word_count or 8
		seed = seed or 0

		local text = {}

		local last_punctation = 1
		local capitalize = true

		for i = 1, word_count do
			math.randomseed(seed + i)
			local word = ""

			local consonant_start = 1

			local length = math.ceil((math.random()^3)*8) + math.random(2, 3)

			for i = 1, length do
				if i == 1 then
					word = word .. first_letters[math.floor((math.random()^3) * #first_letters) + 1]
					if table.hasvalue(vowels, word[i]) then
						consonant_start = 0
					end
				elseif i%2 == consonant_start then
					word = word .. consonants[math.floor((math.random()^4) * #consonants) + 1]
				else
					if i ~= length or math.random() < 0.25 then
						word = word .. vowels[math.floor((math.random()^3) * #vowels) + 1]
					end
				end

				if capitalize then
					word = word:upper()
					capitalize =  false
				end
			end

			text[i] = word

			last_punctation = last_punctation + 1

			if last_punctation > math.random(4,16) then
				if math.random() > 0.9 then
					text[i] = text[i] .. ","
				else
					text[i] = text[i] .. "."
					capitalize = true
				end
				last_punctation = 1
			end

			text[i] = text[i]  .. " "
		end

		return table.concat(text)
	end
end

function string.random(length, min, max)
	length = length or 10
	min = min or 32
	max = max or 126

	local tbl = {}

	for i = 1, length do
		tbl[i] = string.char(math.random(min, max))
	end

	return table.concat(tbl)
end

function string.readablehex(str)
	return (str:gsub("(.)", function(str) str = ("%X"):format(str:byte()) if #str == 1 then str = "0" .. str end return str .. " " end))
end

-- gsub doesn't seem to remove \0

function string.removepadding(str, padding)
	padding = padding or "\0"

	local new = {}

	for i = 1, #str do
		local char = str:sub(i, i)
		if char ~= padding then
			table.insert(new, char)
		end
	end

	return table.concat(new)
end

function string.dumphex(str)
	local str = str:readablehex():lower():split(" ")
	local out = {}

	for i, char in pairs(str) do
		table.insert(out, char)
		table.insert(out, " ")
		if i%16 == 0 then
			table.insert(out, "\n")
		end
		if i%16 == 4 or i%16 == 12 then
			table.insert(out, " ")
		end
		if i%16 == 8 then
			table.insert(out, "  ")
		end

	end
	table.insert(out, "\n")
	return table.concat(out)
end

string.hexdump = string.dumphex

function string.endswith(a, b)
	return a:sub(-#b) == b
end

function string.endswiththese(a, b)
	for _, str in ipairs(b) do
		if a:sub(-#str) == str then
			return true
		end
	end
end

function string.startswith(a, b)
	return a:sub(0, #b) == b
end

function string.levenshtein(a, b)
	local distance = {}

	for i = 0, #a do
	  distance[i] = {}
	  distance[i][0] = i
	end

	for i = 0, #b do
	  distance[0][i] = i
	end

	local str1 = utf8.totable(a)
	local str2 = utf8.totable(b)

	for i = 1, #a do
		for j = 1, #b do
			distance[i][j] = math.min(
				distance[i-1][j] + 1,
				distance[i][j-1] + 1,
				distance[i-1][j-1] + (str1[i-1] == str2[j-1] and 0 or 1)
			)
		end
	end

	return distance[#a][#b]
end

function string.lengthsplit(str, len)
	if #str > len then
		local tbl = {}

		local max = math.floor(#str/len)

		for i = 0, max do

			local left = i * len + 1
			local right = (i * len) + len
			local res = str:sub(left, right)

			if res ~= "" then
				table.insert(tbl, res)
			end
		end

		return tbl
	end

	return {str}
end

function string.getchartype(char)

	if char:find("%p") and char ~= "_" then
		return "punctation"
	elseif char:find("%s") then
		return "space"
	elseif char:find("%d") then
		return "digit"
	elseif char:find("%a") or char == "_" then
		return "letters"
	end

	return "unknown"
end

local types = {
	"%a",
	"%c",
	"%d",
	"%l",
	"%p",
	"%u",
	"%w",
	"%x",
	"%z",
}

function string.charclass(char)
	for _, v in ipairs(types) do
		if char:find(v) then
			return v
		end
	end
end

function string.safeformat(str, ...)
	str = str:gsub("%%(%d+)", "%%s")
	local count = select(2, str:gsub("(%%)", ""))

	if str:find("%...", nil, true) then
		local temp = {}

		for i = count, select("#", ...) do
			table.insert(temp, tostringx(select(i, ...)))
		end
		str = str:replace("%...", table.concat(temp, ", "))

		count = count - 1
	end

	if count == 0 then
		return table.concat({str, ...}, "")
	end

	local copy = {}
	for i = 1, count do
		table.insert(copy, tostringx(select(i, ...)))
	end
	return string.format(str, unpack(copy))
end

function string.findsimple(self, find)
	return self:find(find, nil, true) ~= nil
end

function string.findsimplelower(self, find)
	return self:lower():find(find:lower(), nil, true) ~= nil
end

function string.compare(self, target)
	return
		self == target or
		self:findsimple(target) or
		self:lower() == target:lower() or
		self:findsimplelower(target)
end

function string.trim(self, char)
	if char then
		char = char:patternsafe() .. "*"
	else
		char = "%s*"
	end

	local _, start = self:find(char, 0)
	local end_start, end_stop = self:reverse():find(char, 0)

	if start and end_start then
		return self:sub(start + 1, (end_start - end_stop) - 2)
	elseif start then
		return self:sub(start + 1)
	elseif end_start then
		return self:sub(0, (end_start - end_stop) - 2)
	end

	return self
end

function string.getchar(self, pos)
	return string.sub(self, pos, pos)
end

function string.getbyte(self, pos)
	return self:getchar(pos):byte() or 0
end

function string.totable(self)
	local tbl = table.new(#self, 0)
	for i = 1, #self do
		tbl[i] = self:sub(i, i)
	end
	return tbl
end

function string.split(self, separator, plain_search)
	if separator == nil or separator == "" then
		return self:totable()
	end

	if plain_search == nil then
		plain_search = true
	end

	local tbl = {}
	local current_pos = 1

	for i = 1, #self do
		local start_pos, end_pos = self:find(separator, current_pos, plain_search)
		if not start_pos then break end
		tbl[i] = self:sub(current_pos, start_pos - 1)
		current_pos = end_pos + 1
	end

	if current_pos > 1 then
		tbl[#tbl + 1] = self:sub(current_pos)
	else
		tbl[1] = self
	end

	return tbl
end

function string.count(self, what, plain)
	if plain == nil then plain = true end

	local count = 0
	local current_pos = 1

	for _ = 1, #self do
		local start_pos, end_pos = self:find(what, current_pos, plain)
		if not start_pos then break end
		count = count + 1
		current_pos = end_pos + 1
	end
	return count
end

function string.containsonly(self, pattern)
	return self:gsub(pattern, "") == ""
end

function string.replace(self, what, with)
	local tbl = {}
	local current_pos = 1
	local last_i

	for i = 1, #self do
		local start_pos, end_pos = self:find(what, current_pos, true)
		if not start_pos then last_i = i break end
		tbl[i] = self:sub(current_pos, start_pos - 1)
		current_pos = end_pos + 1
	end

	if current_pos > 1 and last_i then
		tbl[last_i] = self:sub(current_pos)

		return table.concat(tbl, with)
	end

	return self
end

local pattern_escape_replacements = {
	["("] = "%(",
	[")"] = "%)",
	["."] = "%.",
	["%"] = "%%",
	["+"] = "%+",
	["-"] = "%-",
	["*"] = "%*",
	["?"] = "%?",
	["["] = "%[",
	["]"] = "%]",
	["^"] = "%^",
	["$"] = "%$",
	["\0"] = "%z"
}

function string.escapepattern(str)
	return (str:gsub(".", pattern_escape_replacements))
end

function string.getchar(self, pos)
	return self:sub(pos, pos)
end end)()
(function(...) table.new = table.new or desire("table.new") or function() return {} end
table.clear = table.clear or desire("table.clear") or function(t) for k in pairs(t) do t[k] = nil end end

if not table.pack then
    function table.pack(...)
        return {
			n = select("#", ...),
			...
		}
    end
end

if not table.unpack then
	function table.unpack(tbl)
		return unpack(tbl)
	end
end

function table.tolist(tbl, sort)
	local list = {}
	for key, val in pairs(tbl) do
		table.insert(list, {key = key, val = val})
	end

	return list
end

function table.sortedpairs(tbl, sort)
	local list = table.tolist(tbl)
	table.sort(list, sort)
	local i = 0
	return function()
		i = i + 1
		if list[i] then
			return list[i].key, list[i].val
		end
	end
end

function table.slice(tbl, first, last, step)
	local sliced = {}

	for i = first or 1, last or #tbl, step or 1 do
		sliced[#sliced+1] = tbl[i]
	end

	return sliced
end


function table.shuffle(a, times)
	times = times or 1
	local c = #a

	for _ = 1, c * times do
		local ndx0 = math.random(1, c)
		local ndx1 = math.random(1, c)

		local temp = a[ndx0]
		a[ndx0] = a[ndx1]
		a[ndx1] = temp
	end

    return a
end

function table.scroll(tbl, offset)
	if offset == 0 then return end

	if offset > 0 then
		for _ = 1, offset do
			local val = table.remove(tbl, 1)
			table.insert(tbl, val)
		end
	else
		for _ = 1, math.abs(offset) do
			local val = table.remove(tbl)
			table.insert(tbl, 1, val)
		end
	end
end

-- http://stackoverflow.com/questions/6077006/how-can-i-check-if-a-lua-table-contains-only-sequential-numeric-indices
function table.isarray(t)
	local i = 0
	for _ in pairs(t) do
		i = i + 1
		if t[i] == nil then
			return false
		end
	end
	return true
end

function table.reverse(tbl)
	for i = 1, math.floor(#tbl / 2) do
		tbl[i], tbl[#tbl - i + 1] = tbl[#tbl - i + 1], tbl[i]
	end

	return tbl
end

-- 12:34 - <mniip> http://codepad.org/cLaX7lVn
function table.multiremove(tbl, locations)

	if locations[1] then
		local off = 0
		local idx = 1

		for i = 1, #tbl do
			while i + off == locations[idx] do
				off = off + 1
				idx = idx + 1
			end

			tbl[i] = tbl[i + off]
		end
	end

	return tbl
end

function table.removevalue(tbl, val)
	for i,v in ipairs(tbl) do
		if v == val then
			table.remove(tbl, i)
			break
		end
	end
end

function table.fixindices(tbl)
	local temp = {}

	for k, v in pairs(tbl) do
		table.insert(temp, {v = v, k = tonumber(k) or 0})
		tbl[k] = nil
	end

	table.sort(temp, function(a, b) return a.k < b.k end)

	for k, v in ipairs(temp) do
		tbl[k] = v.v
	end

	return temp
end

function table.hasvalue(tbl, val)
	for k,v in pairs(tbl) do
		if v == val then
			return k
		end
	end

	return false
end

function table.getkey(tbl, val)
	for k in pairs(tbl) do
		if k == val then
			return k
		end
	end

	return nil
end

function table.getindex(tbl, val)
	for i, v in ipairs(tbl) do
		if i == v then
			return i
		end
	end

	return nil
end

function table.removevalues(tbl, val)
	local index = table.getindex(tbl, val)

	while index ~= nil do
		table.removevalues(tbl, index)
		index = table.getindex(tbl, val)
	end
end

function table.count(tbl)
	local i = 0

	for _ in pairs(tbl) do
		i = i + 1
	end

	return i
end

function table.merge(a, b, merge_aray)
	for k,v in pairs(b) do
		if type(v) == "table" and type(a[k]) == "table" then
			if merge_aray and table.isarray(a[k]) and table.isarray(v) then
				local offset = #a[k]
				for i = 1, #v do
					a[k][i + offset] = v[i]
				end
			else
				table.merge(a[k], v, merge_aray)
			end
		else
			a[k] = v
		end
	end

	return a
end

function table.add(a, b)
	for _, v in pairs(b) do
		table.insert(a, v)
	end
end

function table.random(tbl)
	local key = math.random(1, table.count(tbl))
	local i = 1
	for _key, _val in pairs(tbl) do
		if i == key then
			return _val, _key
		end
		i = i + 1
	end
end

function table.print(...)
	local tbl = {...}

	local max_level

	if type(tbl[1]) == "table" and type(tbl[2]) == "number" and type(tbl[3]) == "nil" then
		max_level = tbl[2]
		tbl[2] = nil
	end

	local luadata = serializer.GetLibrary("luadata")
	luadata.SetModifier("function", function(var)
		return ("function(%s) --[==[ptr: %p    src: %s]==] end"):format(table.concat(debug.getparams(var), ", "), var, debug.getprettysource(var))
	end)
	luadata.SetModifier("fallback", function(var)
		return "--[==[  " .. tostringx(var) .. "  ]==]"
	end)

	logn(luadata.ToString(tbl, {tab_limit = max_level, done = {}}))

	luadata.SetModifier("function", nil)
end

do
	local indent = 0
	function table.print2(tbl)
		for k,v in pairs(tbl) do
			log(("\t"):rep(indent))

			if type(v) == "table" then
				logn(k, ":")
				indent = indent + 1
				table.print2(v)
				indent = indent - 1
			else
				local v = v
				if type(v) == "string" then
					v = "\"" .. v .. "\""
				end

				logn(k, " = ", v)
			end
		end
	end
end

do -- table copy
	local lookup_table = {}

	local type = type
	local pairs = pairs
	local getmetatable = getmetatable

	local function copy(obj, skip_meta)

		local t = type(obj)

		if t == "number" or t == "string" or t == "function" or t == "boolean" then
			return obj
		end

		if ((t == "table" or (t == "cdata" and structs.GetStructMeta(obj))) and obj.__copy) then
			return obj:__copy()
		elseif lookup_table[obj] then
			return lookup_table[obj]
		elseif t == "table" then
			local new_table = {}

			lookup_table[obj] = new_table

			for key, val in pairs(obj) do
				new_table[copy(key, skip_meta)] = copy(val, skip_meta)
			end

			if skip_meta then
				return new_table
			end

			local meta = getmetatable(obj)

			if meta then
				setmetatable(new_table, meta)
			end

			return new_table
		end

		return obj
	end

	function table.copy(obj, skip_meta)
		table.clear(lookup_table)
		return copy(obj, skip_meta)
	end
end

do
	local setmetatable = setmetatable
	local ipairs = ipairs

	local META = {}

	META.__index = META

	META.concat = table.concat
	META.insert = table.insert
	META.remove = table.remove
	META.unpack = table.unpack
	META.sort = table.sort

	function META:pairs()
		return ipairs(self)
	end

	function table.list(count)
		return setmetatable(table.new(count or 1, 0), META)
	end
end

function table.weak(k, v)
	if k and v then
		mode = "kv"
	elseif k then
		mode = "k"
	elseif v then
		mode = "v"
	else
		mode = "kv"
	end

	return setmetatable({__mode  = mode})
end end)()
(function(...) do
	local ffi = desire("ffi")

	if ffi then
		if WINDOWS then
			ffi.cdef([[
				int _putenv_s(const char *var_name, const char *new_value);
				int _putenv(const char *var_name);

			]])

			function os.setenv(key, val)
				if not val then
					ffi.C._putenv(key)
				else
					ffi.C._putenv_s(key, val)
				end
			end
		else
			ffi.cdef([[
				int setenv(const char *var_name, const char *new_value, int change_flag);
				int unsetenv(const char *name);
			]])

			function os.setenv(key, val)
				if not val then
					ffi.C.unsetenv(key)
				else
					ffi.C.setenv(key, val, 0)
				end
			end
		end
	else
		function os.setenv(key, val)
			logn("ffi.C.setenv(", key, val, ")")
		end
	end
end

do -- by Python1320
	local dd=60*60*24
	local hh=60*60
	local mm=60

	function os.datetable(a)
		local negative=false
		if a<0 then negative=true a=a*-1 end
		local f,s,m,h,d
		f=a - math.floor(a)
		f=math.round(f*10)*0.1
		a=math.floor(a)
		d=math.floor(a/dd)
		a=a-d*dd
		h=math.floor(a/hh)
		a=a-h*hh
		m=math.floor(a/mm)
		a=a-m*mm
		s=a
		return {
			f=f,
			sec=s,
			min=m,
			hour=h,
			day=d,
			n=negative
		}
	end
end

do -- by Python1320
	local conjunction=  " and"
	local conjunction2= ","

	function os.prettydate(t, just_time)
		if type(t)=="number" then
			t = os.datetable(t)
		end

		if just_time then t.n = nil end

		local tbl={}
		if t.day~=0 then
			table.insert(tbl,t.day .." day"..(t.day==1 and "" or "s"))
		end

		local lastand
		if t.hour~=0 then
			if #tbl>0 then lastand=table.insert(tbl,conjunction)table.insert(tbl," ")end
			table.insert(tbl,t.hour .." hour"..(t.hour==1 and "" or "s"))
		end
		if t.min~=0 then
			if #tbl>0 then lastand=table.insert(tbl,conjunction)table.insert(tbl," ")end
			table.insert(tbl,t.min .." minute"..(t.min==1 and "" or "s"))
		end
		if t.sec~=0 or #tbl==0 then
			if #tbl>0 then lastand=table.insert(tbl,conjunction)table.insert(tbl," ")end
			table.insert(tbl,t.sec .."."..math.round((t.f or 0)*10).." seconds")
		end
		if t.n then
			table.insert(tbl," in the past")
		end
		for k,v in pairs(tbl) do
			if v==conjunction and k~=lastand then
				tbl[k]=conjunction2
			end
		end

		return table.concat ( tbl , "" )
	end
end

function os.executeasync(str)
	if LINUX then
		return os.execute([[eval ']]..str..[[' &]])
	else
		return os.execute(str)
	end
end end)()
(function(...) --_G.ffi = require("ffi")
local ffi = require("ffi")

ffi.cdef("char *strerror(int)")

function ffi.strerror()
	local num = ffi.errno()
	local err = ffi.string(ffi.C.strerror(num))
	return err == "" and tostring(num) or err
end

if DEBUG_GC then
	local hooked = table.weak()

	local real_gc = ffi.gc
	local real_new = ffi.new

	function ffi.gc(cdata, finalizer)
		hooked[cdata] = finalizer
		return cdata
	end

	function ffi.new(...)
		local obj = real_new(...)

		logn("ffi.new: ", ...)

		real_gc(obj, function(...)
			logn("ffi.gc: ", ...)

			if hooked[obj] then
				return hooked[obj](...)
			end
		end)

		return obj
	end

	local old = setmetatable
	function setmetatable(tbl, meta)
		if meta then
			local __gc = meta.__gc

			if __gc then
				function meta.__gc(...)
					logn("META:__gc: ", ...)

					local a,b,c = pcall(__gc, ...)

					logn("OK")

					return a,b,c
				end
			end
		end

		return old(tbl, meta)
	end
end

local where = {
	"bin/" .. jit.os:lower() .. "_" .. jit.arch:lower() .. "/",
	"lua/modules/bin/" .. jit.os:lower() .. "_" .. jit.arch:lower() .. "/",
}


local function warn_pcall(func, ...)
	local res = {pcall(func, ...)}
	if not res[1] then
		logn(res[2]:trim())
	end

	return unpack(res, 2)
end

local function handle_stupid(path, clib, err, ...)
	if WINDOWS and clib then
		return setmetatable({}, {
			__index = function(s, k)
				if k == "Type" then return "ffi" end
				local ok, msg = pcall(function() return clib[k] end)
				if not ok then
					if  msg:find("cannot resolve symbol", nil, true)  then
						logf("[%s] could not find function %q in shared library\n", path, msg:match("cannot resolve symbol '(.-)': "))
						return nil
					else
						error(msg, 2)
					end
				end
				return msg
			end,
			__newindex = clib,
		})
	end
	return clib, err, ...
end

local function indent_error(str)
	local last_line
	str = "\n" .. str .. "\n"
	str = str:gsub("(.-\n)", function(line)
		line = "\t" .. line:trim() .. "\n"
		if line == last_line then
			return ""
		end
		last_line = line
		return line
	end)
	str= str:gsub("\n\n", "\n")
	return str
end

-- make ffi.load search using our file system
function ffi.load(path, ...)
	local args = {pcall(_OLD_G.ffi.load, path, ...)}

	if WINDOWS and not args[1] then
		args = {pcall(_OLD_G.ffi.load, "lib" .. path, ...)}
	end

	if not args[1] then
		if vfs and system and system.SetSharedLibraryPath then
			for _, where in ipairs(where) do
				for _, full_path in ipairs(vfs.GetFiles({path = where, filter = path, filter_plain = true, full_path = true})) do
					-- look first in the vfs' bin directories
					local old = system.GetSharedLibraryPath()
					system.SetSharedLibraryPath(full_path:match("(.+/)"))
					args = {pcall(_OLD_G.ffi.load, full_path, ...)}
					system.SetSharedLibraryPath(old)

					if args[1] then
						return handle_stupid(path, select(2, unpack(args)))
					end

					args[2] = args[2] .. "\n" .. system.GetLibraryDependencies(full_path)

					-- if not try the default OS specific dll directories
					args = {pcall(_OLD_G.ffi.load, full_path, ...)}
					if args[1] then
						return handle_stupid(path, select(2, unpack(args)))
					end

					args[2] = args[2] .. "\n" .. system.GetLibraryDependencies(full_path)
				end
			end

			error(indent_error(args[2]), 2)
		end
	end

	return handle_stupid(path, args[2])
end

ffi.cdef("void* malloc(size_t size); void free(void* ptr);")

function ffi.malloc(t, size)
	size = size * ffi.sizeof(t)
	local ptr = ffi.gc(ffi.C.malloc(size), ffi.C.free)

	return ffi.cast(ffi.typeof("$ *", t), ptr), ptr
end

local function warn_pcall(func, ...)
	local res = {pcall(func, ...)}
	if not res[1] then
		logn(res[2]:trim())
	end

	return unpack(res)
end

function ffi.cdef(str, ...)
	return warn_pcall(_OLD_G.ffi.cdef, str, ...)
end

local metatable_lookup = {}

function ffi.metatype(ct, meta)
	metatable_lookup[tostring((ct))] = meta
	return _OLD_G.ffi.metatype(ct, meta)
end

function ffi.getmetatable(ct)
	return metatable_lookup[tostring((ct))]
end end)()
(function(...) math.tau = math.pi*2

function math.linear2gamma(n, gamma)
	gamma = gamma or 2.4

	if n <= 0.04045 then
		return n / 12.92
	end

	return ((n + 0.055) / 1.055) ^ gamma
end

function math.gamma2linear(n, gamma)
	gamma = gamma or 2.4

	if n < 0.0031308 then
		return n * 12.92
	else
		return 1.055 * (n ^ (1.0 / gamma)) - 0.055
	end
end

function math.normalizeangle(a)
	return (a + math.pi) % math.tau - math.pi
end

function math.map(num, in_min, in_max, out_min, out_max)
	return (num - in_min) * (out_max - out_min) / (in_max - in_min) + out_min
end

function math.normalize(num, min, max)
	return (num - min) / (max - min)
end

function math.pow2ceil(n)
	return 2 ^ math.ceil(math.log(n) / math.log(2))
end

function math.pow2floor(n)
	return 2 ^ math.floor(math.log(n) / math.log(2))
end

function math.pow2round(n)
	return 2 ^ math.round(math.log(n) / math.log(2))
end

function math.round(num, idp)
	if idp and idp > 0 then
		local mult = 10 ^ idp
		return math.floor(num * mult + 0.5) / mult
	end

	return math.floor(num + 0.5)
end

function math.randomf(min, max)
	min = min or -1
	max = max or 1
	return min + (math.random() * (max-min))
end

function math.clamp(self, min, max)
	return math.min(math.max(self, min), max)
end

function math.lerp(m, a, b)
	return (b - a) * m + a
end

function math.len(x)
	local len = 1

	while x > 9999 do
		x = x / 10000
		len = len + 4
	end

	while x > 99 do
		x = x / 100
		len = len + 2
	end

	if x > 9 then
		len = len + 1
	end

	return len
end


function math.digit10(x, n)
    while n > 0 do
        x = x / 10
		n = n - 1
    end

    return math.floor(x % 10)
end

function math.approach(cur, target, inc)
    inc = math.abs(inc)

    if cur < target then
        return math.clamp(cur + inc, cur, target)
    elseif cur > target then
        return math.clamp(cur - inc, target, cur)
    end

    return target
end

local inf, ninf = math.huge, -math.huge

function math.isvalid(num)
	return
		num and
		num ~= inf and
		num ~= ninf and
		(num >= 0 or num <= 0)
end

function math.tostring(num)
	local t = {}
	local len = math.len(num)

	for i = 0, len - 1 do
		t[len - i] = math.digit10(num, i)
	end

	return table.concat(t)
end end)()

utility = (function(...) local utility = _G.utility or {}

do
	function utility.StartRecordingCalls(lib, filter)
		lib.old_funcs = lib.old_funcs or {}
		lib.call_log = lib.call_log or {}
		local i = 1
		for k,v in pairs(lib) do
			if (type(v) == "cdata" or type(v) == "function") and (not filter or filter(k)) then
				lib.old_funcs[k] = v

				lib[k] = function(...)
					local ret = v(...)
					lib.call_log[i] = {func_name = k, ret = ret, args = {...}}
					i = i  + 1
					return ret
				end
			end
		end
	end

	function utility.StopRecordingCalls(lib, name)
		if not lib.old_funcs then return end

		for k,v in pairs(lib.old_funcs) do
			lib[k] = v
		end

		local tbl = lib.call_log
		lib.call_log = nil

		for i,v in ipairs(tbl) do
			log(("%3i"):format(i), ": ")

			if v.ret ~= nil then
				log(v.ret, " ")
			end

			local args = {}

			for k,v in pairs(v.args) do
				table.insert(args, tostringx(v))
			end

			logn(name or "", ".", v.func_name, "(", table.concat(args, ", "), ")")
		end
	end
end

do
	local ran = {}

	function utility.RunOnNextGarbageCollection(callback, id)
		if id then
			ran[id] = false
			getmetatable(newproxy(true)).__gc = function(...)
				if not ran[id] then
					callback(...)
					ran[id] = true
				end
			end
		else
			getmetatable(newproxy(true)).__gc = callback
		end
	end
end

do
	local function handle_path(path)
		if vfs.IsPathAbsolute(path) then
			return path
		end

		if path == "." then
			path = ""
		end

		return system.GetWorkingDirectory() .. path
	end

	function utility.CLIPathInputToTable(str, extensions)
		local paths = {}
		str = str:trim()

		if handle_path(str):endswith("/**") then
			vfs.GetFilesRecursive(handle_path(str:sub(0, -3)), extensions, function(path)
				table.insert(paths, R(path))
			end)
		elseif handle_path(str):endswith("/*") then
			for _, path in ipairs(vfs.Find(handle_path(str:sub(0, -2)), true)) do
				if not extensions or vfs.GetExtensionFromPath(path):endswiththese(extensions) then
					table.insert(paths, path)
				end
			end
		elseif str:find(",", nil, true) then
			for i, path in ipairs(str:split(",")) do
				path = handle_path(vfs.FixPathSlashes(path:trim()))
				if vfs.IsFile(path) and (not extensions or vfs.GetExtensionFromPath(path):endswiththese(extensions)) then
					table.insert(paths, R(path))
				end
			end
		elseif LINUX and str:find("%s") then
			for i, path in ipairs(str:split(" ")) do
				path = handle_path(vfs.FixPathSlashes(path:trim()))
				if vfs.IsFile(path) and (not extensions or vfs.GetExtensionFromPath(path):endswiththese(extensions)) then
					table.insert(paths, R(path))
				end
			end
		elseif vfs.IsFile(handle_path(str)) and (not extensions or vfs.GetExtensionFromPath(str):endswiththese(extensions)) then
			table.insert(paths, R(handle_path(str)))
		else
			table.insert(paths, handle_path(str))
		end

		return paths
	end
end

function utility.GenerateCheckLastFunction(func, arg_count)
	local lua = ""

	lua = lua .. "local func = ...\n"
	for i = 1, arg_count do
		lua = lua .. "local last_" .. i .. "\n"
	end
	lua = lua .. "return function("
	for i = 1, arg_count do
		lua = lua .. "_" .. i
		if i ~= arg_count then
			lua = lua .. ", "
		end
	end
	lua = lua .. ")\n"

	lua = lua .. "\tif\n"

	for i = 1, arg_count do
		lua = lua .. "\t\t_" .. i .. " ~= last_" .. i
		if i ~= arg_count then
			lua = lua .. " or\n"
		else
			lua = lua .. "\n"
		end
	end

	lua = lua .. "\tthen\n"
	lua = lua .. "\t\tfunc("
	for i = 1, arg_count do
		lua = lua .. "_" .. i
		if i ~= arg_count then
			lua = lua .. ", "
		end
	end
	lua = lua .. ")\n"

	for i = 1, arg_count do
		lua = lua .. "\t\tlast_" .. i .. " = _" .. i .. "\n"
	end

	lua = lua .. "\tend\n"
	lua = lua .. "end"

	return assert(loadstring(lua))(func)
end

do
	local stack = {}

	function utility.PushTimeWarning()
		if CLI then return end

		table.insert(stack, os.clock())
	end

	function utility.PopTimeWarning(what, threshold, category)
		if CLI then return end

		threshold = threshold or 0.1
		local start_time = table.remove(stack)
		if not start_time then return end
		local delta = os.clock() - start_time

		if delta > threshold then
			if category then
				logf("%s %f seconds spent in %s\n", category, delta, what)
			else
				logf("%f seconds spent in %s\n", delta, what)
			end
		end
	end
end

function utility.CreateDeferredLibrary(name)
	return setmetatable(
		{
			queue = {},
			Start = function(self)
				_G[name] = self
			end,
			Stop = function()
				_G[name] = nil
			end,
			Call = function(self, lib)
				for _, v in ipairs(self.queue) do
					if not lib[v.key] then error(v.key .. " was not found", 2) end
					print(self, lib)
					lib[v.key](unpack(v.args))
				end
				return lib
			end,
		},
		{
			__index = function(self, key)
				return function(...)
					table.insert(self.queue, {key = key, args = {...}})
				end
			end,
		}
	)
end

do
	function utility.StripLuaCommentsAndStrings(code, post_process)
		code = code:gsub("\\\\", "____ESCAPE_ESCAPE")
		code = code:gsub("\\'", "____SINGLE_QUOTE_ESCAPE")
		code = code:gsub('\\"', "____DOUBLE_QUOTE_ESCAPE")

		local singleline_comments = {}
		local multiline_comments = {}
		local double_quote_strings = {}
		local single_quote_strings = {}
		local multiline_strings = {}

		code = code:gsub("(%-%-%[(=*)%[.-%]%2%])", function(str) table.insert(multiline_comments, str) return "____COMMENT_MULTILINE_" .. #multiline_comments .. "____" .. " "  end)
		code = code:gsub("(%[(=*)%[.-%]%2%])", function(str) table.insert(multiline_strings, str) return "____STRING_MULTILINE_" .. #multiline_strings .. "____" .. " "  end)
		code = code:gsub("%b\"\"", function(str) table.insert(double_quote_strings, str) return "____STRING_DOUBLE_QUOTE_" .. #double_quote_strings .. "____" .. " "  end)
		code = code:gsub("(%-%-.-)\n", function(str) table.insert(singleline_comments, str) return "____COMMENT_SINGLELINE_" .. #singleline_comments .. "____" .. " " end)
		code = code:gsub("%b''", function(str) table.insert(single_quote_strings, str) return "____STRING_SINGLE_QUOTE_" .. #single_quote_strings .. "____" .. " "  end)

		local res = {
			singleline_comments = singleline_comments,
			multiline_comments = multiline_comments,
			double_quote_strings = double_quote_strings,
			single_quote_strings = single_quote_strings,
			multiline_strings = multiline_strings,
		}

		if post_process then
			code = post_process(code, res) or code
		end

		return code, res
	end

	function utility.RestoreLuaCommentsAndStrings(code, data)
		for i, v in ipairs(data.multiline_comments) do code = code:replace("____COMMENT_MULTILINE_" .. i .. "____", v) end
		for i, v in ipairs(data.multiline_strings) do code = code:replace("____STRING_MULTILINE_" .. i .. "____", v) end
		for i, v in ipairs(data.double_quote_strings) do code = code:replace("____STRING_DOUBLE_QUOTE_" .. i .. "____", v) end
		for i, v in ipairs(data.singleline_comments) do code = code:replace("____COMMENT_SINGLELINE_" .. i .. "____", v .. "\n") end
		for i, v in ipairs(data.single_quote_strings) do code = code:replace("____STRING_SINGLE_QUOTE_" .. i .. "____", v) end

		code = code:gsub("____ESCAPE_ESCAPE", "\\\\")
		code = code:gsub("____SINGLE_QUOTE_ESCAPE", "\\'")
		code = code:gsub("____DOUBLE_QUOTE_ESCAPE", '\\"')

		return code
	end
end

function utility.CreateCallbackThing(cache)
	cache = cache or {}
	local self = {}

	function self:check(path, callback, extra)
		if cache[path] then
			if cache[path].extra_callbacks then
				for key, old in pairs(cache[path].extra_callbacks) do
					local callback = extra[key]
					if callback then
						cache[path].extra_callbacks[key] = function(...)
							old(...)
							callback(...)
						end
					end

				end
			end

			if cache[path].callback then
				local old = cache[path].callback

				cache[path].callback = function(...)
					old(...)
					callback(...)
				end
				return true
			end
		end
	end

	function self:start(path, callback, extra)
		cache[path] = {callback = callback, extra_callbacks = extra}
	end

	function self:callextra(path, key, out)
		if not cache[path] or not cache[path].extra_callbacks[key] then return end
		return cache[path].extra_callbacks[key](out)
	end

	function self:stop(path, out, ...)
		if not cache[path] then return end
		cache[path].callback(out, ...)
		cache[path] = out
	end

	function self:get(path)
		return cache[path]
	end

	function self:uncache(path)
		cache[path] = nil
	end

	return self
end

do
	local ffi = desire("ffi")
	local ok, lib

	if ffi then
		ok, lib = pcall(ffi.load, "lz4")

		if ok then
			ffi.cdef[[
				int LZ4_compress        (const char* source, char* dest, int inputSize);
				int LZ4_decompress_safe (const char* source, char* dest, int inputSize, int maxOutputSize);
			]]

			function utility.Compress(data)
				local size = #data
				local buf = ffi.new("uint8_t[?]", ((size) + ((size)/255) + 16))
				local res = lib.LZ4_compress(data, buf, size)

				if res ~= 0 then
					return ffi.string(buf, res)
				end
			end

			function utility.Decompress(source, orig_size)
				local dest = ffi.new("uint8_t[?]", orig_size)
				local res = lib.LZ4_decompress_safe(source, dest, #source, orig_size)

				if res > 0 then
					return ffi.string(dest, res)
				end
			end
		end
	end

	if not ok then
		utility.Compress = function() error("lz4 is not avaible: " .. lib, 2) end
		utility.Decompress = utility.Compress
	end
end

function utility.MakePushPopFunction(lib, name, func_set, func_get, reset)
	func_set = func_set or lib["Set" .. name]
	func_get = func_get or lib["Get" .. name]

	local stack = {}
	local i = 1

	lib["Push" .. name] = function(a,b,c,d)
		stack[i] = stack[i] or {}
		stack[i][1], stack[i][2], stack[i][3], stack[i][4] = func_get()

		func_set(a,b,c,d)

		i = i + 1
	end

	lib["Pop" .. name] = function()
		i = i - 1

		if i < 1 then
			error("stack underflow", 2)
		end

		if i == 1 and reset then
			reset()
		end

		func_set(stack[i][1], stack[i][2], stack[i][3], stack[i][4])
	end
end

function utility.FindReferences(reference)
	local done = {}
	local found = {}
	local found2 = {}

	local revg = {}
	for k,v in pairs(_G) do revg[v] = tostring(k) end

	local function search(var, str)
		if done[var] then return end

		if revg[var] then str = revg[var] end

		if rawequal(var, reference) then
			local res = str .. " = " .. tostring(reference)
			if not found2[res] then
				table.insert(found, res)
				found2[res] = true
			end
		end

		local t = type(var)

		if t == "table" then
			done[var] = true

			for k, v in pairs(var) do
				search(k, str .. "." .. tostring(k))
				search(v, str .. "." .. tostring(k))
			end
		elseif t == "function" then
			done[var] = true

			for _, v in pairs(debug.getupvalues(var)) do
				if v.val then
					search(v.val, str .. "^" .. v.key)
				end
			end
		end
	end

	search(_G, "_G")

	return table.concat(found, "\n")
end

function utility.TableToColumns(title, tbl, columns, check, sort_key)

	if false and gui then
		local frame = gui.CreatePanel("frame", nil, "table_to_columns_" .. title)
		frame:SetSize(Vec2() + 300)
		frame:SetTitle(title)

		local list = frame:CreatePanel("list")
		list:SetupLayout("fill")

		local keys = {}
		for i,v in ipairs(columns) do keys[i] = v.friendly or v.key end
		list:SetupSorted(unpack(keys))

		for _, data in ipairs(tbl) do
			local args = {}
			for i, info in ipairs(columns) do
				if info.tostring then
					args[i] = info.tostring(data[info.key], data, tbl)
				else
					args[i] = data[info.key]
				end
				if type(args[i]) == "string" then
					args[i] = args[i]:trim()
				end
			end
			list:AddEntry(unpack(args))
		end

		return
	end

	local top = {}

	for k, v in pairs(tbl) do
		if not check or check(v) then
			table.insert(top, {key = k, val = v})
		end
	end

	if type(sort_key) == "function" then
		table.sort(top, function(a, b)
			return sort_key(a.val, b.val)
		end)
	else
		table.sort(top, function(a, b)
			return a.val[sort_key] > b.val[sort_key]
		end)
	end

	local max_lengths = {}
	local temp = {}

	for _, column in ipairs(top) do
		for key, data in ipairs(columns) do
			data.tostring = data.tostring or function(...) return ... end
			data.friendly = data.friendly or data.key

			max_lengths[data.key] = max_lengths[data.key] or 0

			local str = tostring(data.tostring(column.val[data.key], column.val, top))
			column.str = column.str or {}
			column.str[data.key] = str

			if #str > max_lengths[data.key] then
				max_lengths[data.key] = #str
			end

			temp[key] = data
		end
	end

	columns = temp

	local width = 0

	for _,v in pairs(columns) do
		if max_lengths[v.key] > #v.friendly then
			v.length = max_lengths[v.key]
		else
			v.length = #v.friendly + 1
		end
		width = width + #v.friendly + max_lengths[v.key] - 2
	end

	local out = " "

	out = out .. ("_"):rep(width - 1) .. "\n"
	out = out .. "|" .. (" "):rep(width / 2 - math.floor(#title / 2)) .. title .. (" "):rep(math.floor(width / 2) - #title + math.floor(#title / 2)) .. "|\n"
	out = out .. "|" .. ("_"):rep(width - 1) .. "|\n"

	for _,v in ipairs(columns) do
		out = out .. "| " .. v.friendly .. ": " .. (" "):rep(-#v.friendly + max_lengths[v.key] - 1)  -- 2 = : + |
	end
	out = out .. "|\n"


	for _,v in ipairs(columns) do
		out = out .. "|" .. ("_"):rep(v.length + 2)
	end
	out = out .. "|\n"

	for _,v in ipairs(top) do
		for _,column in ipairs(columns) do
			out = out .. "| " .. v.str[column.key] .. (" "):rep(-#v.str[column.key] + column.length + 1)
		end
		out = out .. "|\n"
	end

	out = out .. "|"

	out = out .. ("_"):rep(width-1) .. "|\n"


	return out
end

function utility.TableToFlags(flags, valid_flags)
	if type(flags) == "string" then
		flags = {flags}
	end

	local out = 0

	for k, v in pairs(flags) do
		local flag = valid_flags[v] or valid_flags[k]
		if not flag then
			error("invalid flag", 2)
		end
		out = bit.band(out, tonumber(flag))
	end

	return out
end

function utility.FlagsToTable(flags, valid_flags)

	if not flags then return valid_flags.default_valid_flag end

	local out = {}

	for k, v in pairs(valid_flags) do
		if bit.band(flags, v) > 0 then
			out[k] = true
		end
	end

	return out
end

do -- long long
	local ffi = desire("ffi")

	if ffi then
		local btl = ffi.typeof([[union {
			char b[8];
			int64_t i;
		  }]])

		function utility.StringToLongLong(str)
			return btl(str).i
		end
	end
end

do -- find value
	local found =  {}
	local done = {}

	local skip =
	{
		ffi = true,
	}

	local keywords =
	{
		AND = function(a, func, x,y) return func(a, x) and func(a, y) end
	}

	local function args_call(a, func, ...)
		local tbl = {...}

		for i = 1, #tbl do
			local val = tbl[i]

			if not keywords[val] then
				local keyword = tbl[i+1]
				if keywords[keyword] and tbl[i+2] then
					local ret = keywords[keyword](a, func, val, tbl[i+2])
					if ret ~= nil then
						return ret
					end
				else
					local ret = func(a, val)
					if ret ~= nil then
						return ret
					end
				end
			end
		end
	end

	local function strfind(str, ...)
		return args_call(str, string.compare, ...) or args_call(str, string.find, ...)
	end

	local function _find(tbl, name, dot, level, ...)
		if level >= 3 then return end

		for key, val in pairs(tbl) do
			local T = type(val)
			key = tostring(key)

			if name == "_M" then
				if val.Type == val.ClassName then
					key = val.Type
				else
					key = val.Type .. "." .. val.ClassName
				end
			end

			if not skip[key] and T == "table" and not done[val] then
				done[val] = true
				_find(val, name .. "." .. key, dot, level + 1, ...)
			else
				if (T == "function" or T == "number") and strfind(name .. "." .. key, ...) then

					local nice_name

					if type(val) == "function" then
						local params = debug.getparams(val)

						if dot == ":" and params[1] == "self" then
							table.remove(params, 1)
						end

						nice_name = ("%s%s%s(%s)"):format(name, dot, key, table.concat(params, ", "))
					else
						nice_name = ("%s.%s = %s"):format(name, key, val)
					end

					if name == "_G" or name == "_M" then
						table.insert(found, {key = key, val = val, name = name, nice_name = nice_name})
					else
						table.insert(found, {key = ("%s%s%s"):format(name, dot, key), val = val, name = name, nice_name = nice_name})
					end
				end
			end
		end
	end

	local function find(tbl, ...)
		found = {}
		_find(...)
		table.sort(found, function(a, b) return #a.key < #b.key end)
		for _,v in ipairs(found) do table.insert(tbl, v) end
	end

	function utility.FindValue(...)
		local found = {}
		done =
		{
			[_G] = true,
			[package] = true,
			[_OLD_G] = true,
		}

		find(found, _G, "_G", ".", 1, ...)
		find(found, prototype.GetAllRegistered(), "_M", ":", 1, ...)

		return found
	end
end

do -- find in files
	function utility.FindInLoadedLuaFiles(find)
		local out = {}
		for path in pairs(vfs.GetLoadedLuaFiles()) do
			if not path:find("modules") or (path:find("ffi", nil, true) and (not path:find("header.lua") and not path:find("enums"))) then
				local str = vfs.Read(path)
				if str then
					for i, line in ipairs(str:split("\n")) do
						local start, stop = line:find(find)
						if start then
							out[path] = out[path] or {}
							table.insert(out[path], {str = line, line = i, start = start, stop = stop})
						end
					end
				end
			end
		end
		return out
	end
end

do
	-- http://cakesaddons.googlecode.com/svn/trunk/glib/lua/glib/stage1.lua
	local size_units =
	{
		"B",
		"KiB",
		"MiB",
		"GiB",
		"TiB",
		"PiB",
		"EiB",
		"ZiB",
		"YiB"
	}
	function utility.FormatFileSize(size)
		local unit_index = 1

		while size >= 1024 and size_units[unit_index + 1] do
			size = size / 1024
			unit_index = unit_index + 1
		end

		return tostring(math.floor(size * 100 + 0.5) / 100) .. " " .. size_units[unit_index]
	end
end

function utility.SafeRemove(obj, gc)
	if hasindex(obj) then

		if obj.IsValid and not obj:IsValid() then return end

		if type(obj.Remove) == "function" then
			obj:Remove()
		elseif type(obj.Close) == "function" then
			obj:Close()
		end

		if gc and type(obj.__gc) == "function" then
			obj:__gc()
		end
	end
end

utility.remakes = table.weak()

function utility.RemoveOldObject(obj, id)

	if hasindex(obj) and type(obj.Remove) == "function" then
		id = id or (debug.getinfo(2).currentline .. debug.getinfo(2).source)

		if typex(utility.remakes[id]) == typex(obj) then
			utility.remakes[id]:Remove()
		end

		utility.remakes[id] = obj
	end

	return obj
end

do
	local hooks = {}

	function utility.SetFunctionHook(tag, tbl, func_name, type, callback)
		local old = hooks[tag] or tbl[func_name]

		if type == "pre" then
			tbl[func_name] = function(...)
				local args = {callback(old, ...)}

				if args[1] == "abort_call" then return end
				if #args == 0 then return old(...) end

				return unpack(args)
			end
		elseif type == "post" then
			tbl[func_name] = function(...)
				local args = {old(...)}
				if callback(old, unpack(args)) == false then return end
				return unpack(args)
			end
		end

		return old
	end

	function utility.RemoveFunctionHook(tag, tbl, func_name)
		local old = hooks[tag]

		if old then
			tbl[func_name] = old
			hooks[tag] = nil
		end
	end
end

function utility.NumberToBinary(num, bits)
	bits = bits or 32
	local bin = {}

	for i = 1, bits do
		if num > 0 then
			rest = math.fmod(num,2)
			table.insert(bin, rest)
			num = (num - rest) / 2
		else
			table.insert(bin, 0)
		end
	end

	return table.concat(bin)
end

function utility.BinaryToNumber(bin)
	bin = string.reverse(bin)
	local sum = 0

	for i = 1, string.len(bin) do
		num = string.sub(bin, i,i) == "1" and 1 or 0
		sum = sum + num * math.pow(2, i-1)
	end

	return sum
end

function utility.NumberToHex(num)
	return "0x" .. bit.tohex(num):upper()
end

return utility
 end)()
prototype = (function(...) local prototype = _G.prototype or {}

prototype.registered = prototype.registered or {}
prototype.prepared_metatables = prototype.prepared_metatables or {}

local template_functions = {
	"GetSet",
	"IsSet",
	"Delegate",
	"GetSetDelegate",
	"DelegateProperties",
	"RemoveField",
	"StartStorable",
	"EndStorable",
	"Register",
	"RegisterComponent",
	"CreateObject",
}

function prototype.CreateTemplate(super_type, sub_type)
	local template = type(super_type) == "table" and super_type or {}

	if type(super_type) == "string" then
		template.Type = super_type
		template.ClassName = sub_type or super_type
	end

	for _, key in ipairs(template_functions) do
		template[key] = prototype[key]
	end

	return template
end

do
	local function checkfield(tbl, key, def)
		tbl[key] = tbl[key] or def

		if not tbl[key] then
			error(string.format("The type field %q was not found!", key), 3)
		end

		return tbl[key]
	end

	local blacklist = {
		prototype_variables = true,
		Events = true,
		Require = true,
		Network = true,
		write_functions = true,
		read_functions = true,
		Args = true,
		type_ids = true,
		storable_variables = true,
		ProtectedFields = true,
	}

	function prototype.Register(meta, super_type, sub_type)
		local super_type = checkfield(meta, "Type", super_type)
		sub_type = sub_type or super_type
		local sub_type = checkfield(meta, "ClassName", sub_type)

		for _, key in ipairs(template_functions) do
			if key ~= "CreateObject" and meta[key] == prototype[key] then
				meta[key] = nil
			end
		end

		prototype.registered[super_type] = prototype.registered[super_type] or {}
		prototype.registered[super_type][sub_type] = meta

		prototype.invalidate_meta = prototype.invalidate_meta or {}
		prototype.invalidate_meta[super_type] = true

		if RELOAD then
			prototype.UpdateObjects(meta)

			for k,v in pairs(meta) do
				if type(v) ~= "function" and not blacklist[k] then
					local found = false
					if meta.prototype_variables then
						for _,v in pairs(meta.prototype_variables) do
							if v.var_name == k then
								found = true
								break
							end
						end
					end
					local t = type(v)
					if t == "number" or t == "string" or t == "function" or t == "boolean" or typex(v) == "null" then
						found = true
					end
					if not found then
						wlog("%s: META.%s = %s is mutable", meta.ClassName, k, tostring(v), 2)
					end
				end
			end
		end

		return super_type, sub_type
	end
end

function prototype.RebuildMetatables(what)
	for super_type, sub_types in pairs(prototype.registered) do
		if what == nil or what == super_type then
			prototype.invalidate_meta[what or super_type] = nil

			for sub_type, meta in pairs(sub_types) do

				local copy = {}
				local prototype_variables = {}

				-- first add all the base functions from the base object
				for k, v in pairs(prototype.base_metatable) do
					copy[k] = v
					if k == "prototype_variables" then for k,v in pairs(v) do prototype_variables[k] = v end end
				end

				-- if this metatable has a type base derive from it first
				if meta.TypeBase then
					for k, v in pairs(sub_types[meta.TypeBase]) do
						copy[k] = v
						if k == "prototype_variables" then for k,v in pairs(v) do prototype_variables[k] = v end end
					end
				end

				-- then go through the list of bases and derive from them in reversed order
				local base_list = {}

				if meta.Base then
					table.insert(base_list, meta.Base)

					local base = meta

					for _ = 1, 50 do
						base = sub_types[base.Base]
						if not base or not base.Base then break end
						table.insert(base_list, 1, base.Base)
					end

					for _, v in ipairs(base_list) do
						local base = sub_types[v]

						-- the base might not be registered yet
						-- however this will be run again once it actually is
						if base then
							for k, v in pairs(base) do
								copy[k] = v
								if k == "prototype_variables" then for k,v in pairs(v) do prototype_variables[k] = v end end
							end
						end
					end
				end

				-- finally the actual metatable
				for k, v in pairs(meta) do
					copy[k] = v
					if k == "prototype_variables" then for k,v in pairs(v) do prototype_variables[k] = v end end
				end

				do
					local tbl = {}

					for _, info in pairs(prototype_variables) do
						if info.copy then
							table.insert(tbl, info)
						end
					end

					copy.copy_variables = tbl[1] and tbl
				end

				if copy.__index2 then
					copy.__index = function(s, k) return copy[k] or copy.__index2(s, k) end
				else
					copy.__index = copy
				end

				copy.BaseClass = sub_types[base_list[#base_list] or meta.TypeBase]
				meta.BaseClass = copy.BaseClass

				prototype.prepared_metatables[super_type] = prototype.prepared_metatables[super_type] or {}
				prototype.prepared_metatables[super_type][sub_type] = copy
			end
		end
	end
end

function prototype.GetRegistered(super_type, sub_type)
	sub_type = sub_type or super_type

	if prototype.registered[super_type] and prototype.registered[super_type][sub_type] then
		if prototype.invalidate_meta[super_type] then
			prototype.RebuildMetatables(super_type)
		end
		return prototype.prepared_metatables[super_type][sub_type]
	end
end

function prototype.GetRegisteredSubTypes(super_type)

	return prototype.registered[super_type]
end

function prototype.GetAllRegistered()
	local out = {}

	for _, sub_types in pairs(prototype.registered) do
		for _, meta in pairs(sub_types) do
			table.insert(out, meta)
		end
	end

	return out
end

local function remove_callback(self)
	if (not self.IsValid or self:IsValid()) and self.Remove then
		self:Remove()
	end

	if prototype.created_objects then
		prototype.created_objects[self] = nil
	end
end

function prototype.OverrideCreateObjectTable(obj)
	prototype.override_object = obj
end

do
	local DEBUG = DEBUG or DEBUG_OPENGL
	local setmetatable = setmetatable
	local type = type
	local ipairs = ipairs
	prototype.created_objects = prototype.created_objects or setmetatable({}, {__mode = "kv"})

	function prototype.CreateObject(meta, override, skip_gc_callback)
		override = override or prototype.override_object or {}

		if type(meta) == "string" then
			meta = prototype.GetRegistered(meta)
		end

		-- this has to be done in order to ensure we have the prepared metatable with bases
		meta = prototype.GetRegistered(meta.Type, meta.ClassName) or meta

		if not skip_gc_callback then
			meta.__gc = remove_callback
		end

		local self = setmetatable(override, meta)

		if meta.copy_variables then
			for _, info in ipairs(meta.copy_variables) do
				self[info.var_name] = info.copy()
			end
		end

		prototype.created_objects[self] = self

		if DEBUG then
			self:SetDebugTrace(debug.traceback())
			self:SetCreationTime(system and system.GetElapsedTime and system.GetElapsedTime() or os.clock())
		end

		return self
	end
end

do
	prototype.linked_objects = prototype.linked_objects or {}

	function prototype.AddPropertyLink(...)

		event.AddListener("Update", "update_object_properties", function()
			for i, data in ipairs(prototype.linked_objects) do
				if type(data.args[1]) == "table" and type(data.args[2]) == "table" then
					local obj_a = data.args[1]
					local obj_b = data.args[2]

					local field_a = data.args[3]
					local field_b = data.args[4]

					local key_a = data.args[5]
					local key_b = data.args[6]

					if obj_a:IsValid() and obj_b:IsValid() then
						local info_a = obj_a.prototype_variables[field_a]
						local info_b = obj_b.prototype_variables[field_b]

						if info_a and info_b then
							if key_a and key_b then
								-- local val = a:GeFieldA().key_a
								-- val.key_a = b:GetFieldB().key_b
								-- a:SetFieldA(val)

								local val = obj_a[info_a.get_name](obj_a)
								val[key_a] = obj_b[info_b.get_name](obj_b)[key_b]

								if data.store.last_val ~= val then
									obj_a[info_a.set_name](obj_a, val)
									data.store.last_val = val
								end
							elseif key_a and not key_b then
								-- local val = a:GeFieldA()
								-- val.key_a = b:GetFieldB()
								-- a:SetFieldA(val)

								local val = obj_a[info_a.get_name](obj_a)
								val[key_a] = obj_b[info_b.get_name](obj_b)

								if data.store.last_val ~= val then
									obj_a[info_a.set_name](obj_a, val)
									data.store.last_val = val
								end
							elseif key_b and not key_a then
								-- local val = b:GeFieldB().key_b
								-- a:SetFieldA(val)

								local val = obj_b[info_b.get_name](obj_b)[key_b]
								if data.store.last_val ~= val then
									obj_a[info_a.set_name](obj_a, val)
									data.store.last_val = val
								end
							else
								-- local val = b:GeFieldB()
								-- a:SetFieldA(val)

								local val = obj_b[info_b.get_name](obj_b)
								if data.store.last_val ~= val then
									obj_a[info_a.set_name](obj_a, val)
									data.store.last_val = val
								end
							end
						end

						if not info_b then
							wlog("unable to find property info for %s (%s)", field_b, obj_b)
						end
					else
						table.remove(prototype.linked_objects, i)
						break
					end
				elseif type(data.args[2]) == "function" and type(data.args[3]) == "function" then
					local obj = data.args[1]
					local get_func = data.args[2]
					local set_func = data.args[3]

					if obj:IsValid() then
						local val = get_func()

						if data.store.last_val ~= val then
							set_func(val)
							data.store.last_val = val
						end
					end
				end
			end
		end)

		table.insert(prototype.linked_objects, {store = table.weak(), args = {...}})
	end

	function prototype.RemovePropertyLink(obj_a, obj_b, field_a, field_b, key_a, key_b)
		for i, v in ipairs(prototype.linked_objects) do
			local obj_a_, obj_b_, field_a_, field_b_, key_a_, key_b_ = unpack(v)
			if
				obj_a == obj_a_ and
				obj_b == obj_b_ and
				field_a == field_a_ and
				field_b == field_b_ and
				key_a == key_a_ and
				key_b == key_b_
			then
				table.remove(prototype.linked_objects, i)
				break
			end
		end
	end

	function prototype.RemovePropertyLinks(obj)
		for i in pairs(prototype.linked_objects) do
			if v[1] == obj then
				prototype.linked_objects[i] = nil
			end
		end

		table.fixindices(prototype.linked_objects)
	end

	function prototype.GetPropertyLinks(obj)
		local out = {}

		for _, v in ipairs(prototype.linked_objects) do
			if v[1] == obj then
				table.insert(out, {unpack(v)})
			end
		end

		return out
	end
end

function prototype.CreateDerivedObject(super_type, sub_type, override, skip_gc_callback)
    local meta = prototype.GetRegistered(super_type, sub_type)

    if not meta then
        llog("tried to create unknown %s %q!", super_type or "no type", sub_type or "no class")
        return
    end

	return prototype.CreateObject(meta, override, skip_gc_callback)
end

function prototype.SafeRemove(obj)
	if hasindex(obj) and obj.IsValid and obj.Remove and obj:IsValid() then
		obj:Remove()
	end
end

function prototype.GetCreated(sorted, super_type, sub_type)
	if sorted then
		local out = {}
		for _, v in pairs(prototype.created_objects) do
			if (not super_type or v.Type == super_type) and (not sub_type or v.ClassName == sub_type) then
				table.insert(out, v)
			end
		end
		table.sort(out, function(a, b) return a:GetCreationTime() < b:GetCreationTime() end)
		return out
	end
	return prototype.created_objects or {}
end

function prototype.FindObject(str)
	local name, property = str:match("(.-):(.+)")
	if not name then name = str end

	local objects = prototype.GetCreated()
	local found

	local function try(compare)
		for obj in pairs(objects) do
			if compare(obj) then
				found = obj
				return true
			end
		end
	end

	local function find_property(obj)
		if not property then return true end
		for _, v in pairs(prototype.GetStorableVariables(obj)) do
			if tostring(obj[v.get_name](obj)):compare(property) then
				return true
			end
		end
	end

	if try(function(obj) return obj:GetName() == name and find_property(obj) end) then return found end
	if try(function(obj) return obj:GetName():compare(name) and find_property(obj) end) then return found end

	if try(function(obj) return obj:GetNiceClassName() == name and find_property(obj) end) then return found end
	if try(function(obj) return obj:GetNiceClassName():compare(name) and find_property(obj) end) then return found end
end

function prototype.UpdateObjects(meta)
	if type(meta) == "string" then
		meta = prototype.GetRegistered(meta)
	end

	if not meta then return end

	for _, obj in pairs(prototype.GetCreated()) do
		local tbl

		if obj.Type == meta.Type and obj.ClassName == meta.ClassName then
			tbl = meta
		elseif obj.Type == meta.Type and obj.TypeBase == meta.ClassName then
			tbl = prototype.GetRegistered(obj.Type, obj.ClassName)
		end

		if tbl then
			if RELOAD then
				for k, v in pairs(tbl) do
					if type(v) == "function" then
						if type(obj[k]) == "function" and debug.getinfo(v).source ~= debug.getinfo(obj[k]).source and #string.dump(v) < #string.dump(obj[k]) then
							llog("not overriding smaller function %s.%s:%s(%s)", tbl.Type, tbl.ClassName, k, table.concat(debug.getupvalues(v), ", "))
						else
							obj[k] = v
						end
					elseif obj[k] == nil then
						obj[k] = v
					end
				end
			else
				for k, v in pairs(tbl) do
					if type(v) == "function" then
						obj[k] = v
					end
				end
			end
		end
	end
end

function prototype.RemoveObjects(super_type, sub_type)
	sub_type = sub_type or super_type
	for _, obj in pairs(prototype.GetCreated()) do
		if obj.Type == super_type and obj.ClassName == sub_type then
			if obj:IsValid() then
				obj:Remove()
			end
		end
	end
end

function prototype.DumpObjectCount()
	local found = {}

	for obj in pairs(prototype.GetCreated()) do
		local name = obj.ClassName
		if obj.ClassName ~= obj.Type then
			name = obj.Type .. "_" .. name
		end
		found[name] = (found[name] or 0) + 1
	end

	local sorted = {}
	for k, v in pairs(found) do
		table.insert(sorted, {k = k, v = v})
	end

	table.sort(sorted, function(a, b) return a.v > b.v end)

	for _, v in ipairs(sorted) do
		logn(v.k, " = ", v.v)
	end
end

(function(...) local prototype = (...) or _G.prototype

local __store = false
local __meta

function prototype.StartStorable(meta)
	__store = true
	__meta = meta
end

function prototype.EndStorable()
	__store = false
	__meta = nil
end

function prototype.GetStorableVariables(meta)
	return meta.storable_variables or {}
end

function prototype.DelegateProperties(meta, from, var_name)
        meta[var_name] = NULL
	for _, info in pairs(prototype.GetStorableVariables(from)) do
		if not meta[info.var_name] then
			 prototype.SetupProperty({
				meta = meta,
				var_name = info.var_name,
				default = info.default,
				set_name = info.set_name,
				get_name = info.get_name,
			})

			meta[info.set_name] = function(self, var)
				self[info.var_name] = var

				if self[var_name]:IsValid() then
					self[var_name][info.set_name](self[var_name], var)
				end
			end

			meta[info.get_name] = function(self)
				if self[var_name]:IsValid() then
					return self[var_name][info.get_name](self[var_name])
				end

				return self[info.var_name]
			end
		end
	end
end

local function has_copy(obj)
	assert(type(obj.__copy) == "function")
end

function prototype.SetupProperty(info)
	local meta = info.meta or __meta
	local default = info.default
	local name = info.var_name
	local set_name = info.set_name
	local get_name = info.get_name
	local callback = info.callback

	if type(default) == "number" then
		if callback then
			meta[set_name] = meta[set_name] or function(self, var) self[name] = tonumber(var) or default self[callback](self) end
		else
			meta[set_name] = meta[set_name] or function(self, var) self[name] = tonumber(var) or default end
		end
		meta[get_name] = meta[get_name] or function(self) return self[name] or default end
	elseif type(default) == "string" then
		if callback then
			meta[set_name] = meta[set_name] or function(self, var) self[name] = tostring(var) self[callback](self) end
		else
			meta[set_name] = meta[set_name] or function(self, var) self[name] = tostring(var) end
		end
		meta[get_name] = meta[get_name] or function(self) if self[name] ~= nil then return self[name] end return default end
	else
		if callback then
			meta[set_name] = meta[set_name] or function(self, var) if var == nil then var = default end self[name] = var self[callback](self) end
		else
			meta[set_name] = meta[set_name] or function(self, var) if var == nil then var = default end self[name] = var end
		end
		meta[get_name] = meta[get_name] or function(self) if self[name] ~= nil then return self[name] end return default end
	end

    meta[name] = default

	if __store then
		info.type = typex(default)

		meta.storable_variables = meta.storable_variables or {}
		table.insert(meta.storable_variables, info)
	end

	do
		if pcall(has_copy, info.default) then
			info.copy = function()
				return info.default:__copy()
			end
		elseif typex(info.default) == "table" then
			if not next(info.default) then
				info.copy = function()
					return {}
				end
			else
				info.copy = function()
					return table.copy(info.default)
				end
			end
		end

		meta.prototype_variables = meta.prototype_variables or {}
		meta.prototype_variables[info.var_name] = info
	end

	return info
end

local function add(meta, name, default, extra_info, get)
	local info = {
		meta = meta,
		default = default,
		var_name = name,
		set_name = "Set" .. name,
		get_name = get .. name,
	}

	if extra_info then
		if table.isarray(extra_info) and #extra_info > 1 then
			extra_info = {enums = extra_info}
		end
		table.merge(info, extra_info)
	end

	return prototype.SetupProperty(info)
end

function prototype.GetSet(meta, name, default, extra_info)
	if type(meta) == "string" and __meta then
		return add(__meta, meta, name, default, "Get")
	else
		return add(meta, name, default, extra_info, "Get")
	end
end

function prototype.IsSet(meta, name, default, extra_info)
	if type(meta) == "string" and __meta then
		return add(__meta, meta, name, default, "Is")
	else
		return add(meta, name, default, extra_info, "Is")
	end
end

function prototype.Delegate(meta, key, func_name, func_name2)
	if not func_name2 then func_name2 = func_name end

	meta[func_name] = function(self, ...)
		return self[key][func_name2](self[key], ...)
	end
end

function prototype.GetSetDelegate(meta, func_name, def, key)
	local get = "Get" .. func_name
	local set = "Set" .. func_name
	local info = prototype.GetSet(meta, func_name, def)
	prototype.Delegate(meta, key, get)
	prototype.Delegate(meta, key, set)
	return info
end

function prototype.RemoveField(meta, name)
	meta["Set" .. name] = nil
    meta["Get" .. name] = nil
    meta["Is" .. name] = nil

    meta[name] = nil
end
 end)( prototype)
(function(...) local prototype = (...) or _G.prototype

local META = {}

prototype.GetSet(META, "DebugTrace", "")
prototype.GetSet(META, "CreationTime", os.clock())
prototype.GetSet(META, "PropertyIcon", "")
prototype.GetSet(META, "HideFromEditor", false)
prototype.GetSet(META, "GUID", "")

prototype.StartStorable(META)
	prototype.GetSet("Name", "")
	prototype.GetSet("Description", "")
prototype.EndStorable()

function META:GetGUID()
	self.GUID = self.GUID or ("%p%p"):format(self, getmetatable(META))
end

function META:GetNiceClassName()
	if self.ClassName ~= self.Type then
		return self.Type .. "_" .. self.ClassName
	end

	return self.ClassName
end

function META:GetEditorName()
	if self.Name == "" then
		return self.EditorName or ""
	end

	return self.Name
end

function META:__tostring()
	local additional_info = self:__tostring2()

	if self.Name ~= "" then
		if self.ClassName ~= self.Type then
			return ("%s:%s[%s]%s"):format(self.Type, self.ClassName, self.Name, additional_info)
		else
			return ("%s[%s]%s"):format(self.Type, self.Name, additional_info)
		end
	else
		if self.ClassName ~= self.Type then
			return ("%s:%s[%p]%s"):format(self.Type, self.ClassName, self, additional_info)
		else
			return ("%s[%p]%s"):format(self.Type, self, additional_info)
		end
	end
end

function META:__tostring2()
	return ""
end

function META:IsValid()
	return true
end

do
	prototype.remove_these = prototype.remove_these or {}
	local event_added = false

	function META:Remove(...)
		if self.__removed then return end

		if self.call_on_remove then
			for _, v in pairs(self.call_on_remove) do
				if v(self) == false then
					return
				end
			end
		end

		if self.added_events then
			for event in pairs(self.added_events) do
				self:RemoveEvent(event)
			end
		end

		if self.OnRemove then
			self:OnRemove(...)
		end

		if not event_added and _G.event then
			event.AddListener("Update", "prototype_remove_objects", function()
				if #prototype.remove_these > 0 then
					for _, obj in ipairs(prototype.remove_these) do
						prototype.created_objects[obj] = nil
						prototype.MakeNULL(obj)
					end
					table.clear(prototype.remove_these)
				end
			end)
			event_added = true
		end

		table.insert(prototype.remove_these, self)

		self.__removed = true
	end
end

do -- serializing
	local callbacks = {}

	function META:SetStorableTable(tbl)
		self:SetGUID(tbl.GUID)

		if self.OnDeserialize then
			self:OnDeserialize(tbl.__extra_data)
		end

		for _, info in ipairs(prototype.GetStorableVariables(self)) do
			if tbl[info.var_name] ~= nil then
				self[info.set_name](self, tbl[info.var_name])
			end
		end

		if tbl.__property_links then
			for _, v in ipairs(tbl.__property_links) do
				self:WaitForGUID(v[1], function(obj)
					v[1] = obj
					self:WaitForGUID(v[2], function(obj)
						v[2] = obj
						prototype.AddPropertyLink(unpack(v))
					end)
				end)
			end
		end
	end

	function META:GetStorableTable()
		local out = {}

		for _, info in ipairs(prototype.GetStorableVariables(self)) do
			out[info.var_name] = self[info.get_name](self)
		end

		out.GUID = self.GUID

		local info = prototype.GetPropertyLinks(self)

		if next(info) then
			for _, v in ipairs(info) do
				v[1] = v[1].GUID
				v[2] = v[2].GUID
			end
			out.__property_links = info
		end

		if self.OnSerialize then
			out.__extra_data = self:OnSerialize()
		end

		return table.copy(out)
	end

	function META:SetGUID(guid)
		prototype.created_objects_guid = prototype.created_objects_guid or table.weak()

		if prototype.created_objects_guid[self.GUID] then
			prototype.created_objects_guid[self.GUID] = nil
		end

		self.GUID = guid

		prototype.created_objects_guid[self.GUID] = self

		if callbacks[self.GUID] then
			for _, cb in ipairs(callbacks[self.GUID]) do
				cb(self)
			end
			callbacks[self.GUID] = nil
		end
	end

	function META:WaitForGUID(guid, callback)
		local obj = prototype.GetObjectByGUID(guid)
		if obj:IsValid() then
			callback(obj)
		else
			callbacks[guid] = callbacks[guid] or {}
			table.insert(callbacks[guid], callback)
			print("added callback for ", guid)
		end
	end

	function prototype.GetObjectByGUID(guid)
		prototype.created_objects_guid = prototype.created_objects_guid or table.weak()

		return prototype.created_objects_guid[guid] or NULL
	end
end

function META:CallOnRemove(callback, id)
	id = id or callback

	if type(callback) == "table" and callback.Remove then
		callback = function() prototype.SafeRemove(callback) end
	end

	self.call_on_remove = self.call_on_remove or {}
	self.call_on_remove[id] = callback
end

do -- events
	local events = {}

	function META:AddEvent(event_type)
		self.added_events = self.added_events or {}
		if self.added_events[event_type] then return end

		local func_name = "On" .. event_type

		events[event_type] = events[event_type] or {}
		table.insert(events[event_type], self)

		event.AddListener(event_type, "prototype_events", function(a_, b_, c_)
			--for _, self in ipairs(events[event_type]) do
			for i = 1, #events[event_type] do
				local self = events[event_type][i]

				if self[func_name] then
					self[func_name](self, a_, b_, c_)
				else
					wlog("%s.%s is nil", self, func_name)
					self:RemoveEvent(event_type)
				end
			end
		end, {on_error = function(str)
			system.OnError(str)
			self:RemoveEvent(event_type)
		end})

		self.added_events[event_type] = true
	end

	function META:RemoveEvent(event_type)
		self.added_events = self.added_events or {}
		if not self.added_events[event_type] then return end

		events[event_type] = events[event_type] or table.weak()

		for i, other in pairs(events[event_type]) do
			if other == self then
				events[event_type][i] = nil
				break
			end
		end

		table.fixindices(events[event_type])

		self.added_events[event_type] = nil

		if #events[event_type] <= 0 then
			event.RemoveListener(event_type, "prototype_events")
		end
	end

	prototype.added_events = events
end

prototype.base_metatable = META

if RELOAD then
	prototype.RebuildMetatables()
end end)( prototype)
(function(...) local prototype = ... or _G.prototype

do
	local NULL = {}

	NULL.Type = "null"
	NULL.IsNull = true

	local function FALSE()
		return false
	end

	function NULL:IsValid()
		return false
	end

	function NULL:__tostring()
		return "NULL"
	end

	function NULL:__copy()
		return self
	end

	function NULL:__index2(key)
		if type(key) == "string" and key:sub(0, 2) == "Is" then
			return FALSE
		end

		--error(("tried to index %q on a NULL value"):format(key), 2)
	end

	prototype.Register(NULL)
end

function prototype.MakeNULL(tbl)
	table.clear(tbl)
	tbl.Type = "null"
	setmetatable(tbl, prototype.GetRegistered("null"))

	if prototype.created_objects then
		prototype.created_objects[tbl] = nil
	end
end

_G.NULL = setmetatable({Type  = "null", ClassName = "ClassName"}, prototype.GetRegistered("null")) end)( prototype)

return prototype
 end)()
vfs = (function(...) local vfs = _G.vfs or {}

vfs.use_appdata = false
vfs.mounted_paths = vfs.mounted_paths or {}

do -- mounting/links
	function vfs.Mount(where, to, userdata)
		to = to or ""

		if not vfs.IsDirectory(where) then
			llog("attempted to mount non existing directory ", where)
			return false
		end

		vfs.ClearCallCache()

		vfs.Unmount(where, to)

		local path_info_where = vfs.GetPathInfo(where, true)
		local path_info_to = vfs.GetPathInfo(to, true)

		if path_info_where.filesystem == "unknown" then
			for context, info in pairs(vfs.DescribePath(where, true)) do
				if info.is_folder then
					path_info_where.filesystem = context.Name
					where = context.Name .. ":" .. where
				end
			end
		end

		if to ~= "" and not path_info_to.filesystem then
			error("a filesystem has to be provided when mounting /to/ somewhere")
		end

		--llog("mounting ", path_info_where.full_path, " -> ", path_info_to.full_path)

		table.insert(vfs.mounted_paths, {
			where = path_info_where,
			to = path_info_to,
			full_where = where,
			full_to = to,
			userdata = userdata
		})
	end

	function vfs.Unmount(where, to)
		to = to or ""

		vfs.ClearCallCache()

		for i, v in ipairs(vfs.mounted_paths) do
			if
				v.full_where:lower() == where:lower() and
				v.full_to:lower() == to:lower()
			then
				table.remove(vfs.mounted_paths, i)
				return true
			end
		end

		return false
	end

	function vfs.GetMounts()
		local out = {}
		for _, v in ipairs(vfs.mounted_paths) do
			out[v.full_where] = v
		end
		return out
	end

	function vfs.TranslatePath(path, is_folder)
		local path_info = vfs.GetPathInfo(path, is_folder)
		local out = {}
		local out_i = 1

		if path_info.relative then
			for _, mount_info in ipairs(vfs.mounted_paths) do
				local where

				if path_info.full_path:sub(0, #mount_info.to.full_path) == mount_info.to.full_path then
					where = vfs.GetPathInfo(mount_info.where.filesystem .. ":" .. mount_info.where.full_path .. path_info.full_path:sub(#mount_info.to.full_path+1), is_folder)
				elseif path_info.full_path ~= "/" then
					where = vfs.GetPathInfo(mount_info.where.filesystem .. ":" .. mount_info.where.full_path .. path_info.full_path, is_folder)
				else
					where = vfs.GetPathInfo(mount_info.where.filesystem .. ":" .. mount_info.to.full_path, is_folder)
				end

				if where then
					out[out_i] = {
						path_info = where,
						context = vfs.filesystems2[mount_info.where.filesystem],
						userdata = mount_info.userdata
					}
					out_i = out_i + 1
				end
			end
		else
			local filesystems = vfs.GetFileSystems()

			if path_info.filesystem ~= "unknown" then
				filesystems = {vfs.GetFileSystem(path_info.filesystem)}
			end

			for _, context in ipairs(filesystems) do
				if (is_folder and context:IsFolder(path_info)) or (not is_folder and context:IsFile(path_info)) then
					out[out_i] = {path_info = path_info, context = context, userdata = path_info.userdata}
					out_i = out_i + 1
				elseif not is_folder and context:IsFolder({full_path = vfs.GetParentFolderFromPath(path_info.full_path)}) then
					out[out_i] = {path_info = path_info, context = context, userdata = path_info.userdata}
					out_i = out_i + 1
				end
			end
		end

		return out
	end
end

do -- env vars/path preprocessing
	vfs.env_override = vfs.env_override or {}

	function vfs.GetEnv(key)
		local val = vfs.env_override[key]

		if type(val) == "function" then
			val = val()
		end

		return val or os.getenv(key)
	end

	function vfs.SetEnv(key, val)
		vfs.env_override[key] = val
	end

	function vfs.PreprocessPath(path)
		if path:find("%", nil, true) or path:find("$", nil, true) then
			-- windows
			path = path:gsub("%%(.-)%%", vfs.GetEnv)
			path = path:gsub("%%", "")
			path = path:gsub("%$%((.-)%)", vfs.GetEnv)

			-- linux
			path = path:gsub("%$%((.-)%)", "%1")
		end

		return path
	end
end

do -- file systems
	vfs.filesystems = vfs.filesystems or {}
	vfs.filesystems2 = vfs.filesystems2 or {}

	function vfs.RegisterFileSystem(META, is_base)
		META.TypeBase = "base"
		META.Position = META.Position or 0
		prototype.Register(META, "file_system", META.Name)

		if is_base then return end

		local context = prototype.CreateDerivedObject("file_system", META.Name)
		context.mounted_paths = {}

		for k,v in ipairs(vfs.filesystems) do
			if v.Name == META.Name then
				table.remove(vfs.filesystems, k)
				context.mounted_paths = v.mounted_paths
				break
			end
		end

		table.insert(vfs.filesystems, context)

		table.sort(vfs.filesystems, function(a, b)
			return a.Position < b.Position
		end)

		vfs.filesystems2[context.Name] = context
	end

	function vfs.GetFileSystems()
		return vfs.filesystems
	end

	function vfs.GetFileSystem(name)
		return vfs.filesystems2[name]
	end
end

do -- translate path to useful data
	function vfs.DescribePath(path, is_folder)
		local path_info = vfs.GetPathInfo(path, is_folder)
		local out = {}
		for _, context in ipairs(vfs.GetFileSystems()) do
			out[context] = {}
			if is_folder then
				out[context].is_folder = context:IsFolder(path_info)
			else
				out[context].is_folder = context:IsFolder(path_info)
				out[context].is_file = context:IsFile(path_info)
			end
		end
		return out
	end

	local function get_folders(self, typ)
		if typ == "full" then
			local folders = {}

			for i = 0, 100 do
				local folder = vfs.GetParentFolderFromPath(self.full_path, i)

				if folder == "" then
					break
				end

				table.insert(folders, 1, folder)
			end

			--table.remove(folders) -- remove the filename

			return folders
		else
			local folders = self.full_path:split("/")

			-- if the folder is something like "/foo/bar/" remove the first /
			if self.full_path:sub(1,1) == "/" then
				table.remove(folders, 1)
			end

			table.remove(folders) -- remove the filename

			return folders
		end
	end

	function vfs.IsPathAbsolute(path)
		if WINDOWS then
			return path:sub(2, 2) == ":" or path:sub(1, 2) == [[//]]
		end

		return path:sub(1, 1) == "/"
	end

	function vfs.GetPathInfo(path, is_folder)
		local out = {}
		local pos = path:find(":", 0, true)

		if pos then
			local filesystem = path:sub(0, pos - 1)

			if vfs.GetFileSystem(filesystem) then
				path = path:sub(pos + 1)
				out.filesystem = filesystem
			else
				out.filesystem = "unknown"
			end
		else
			out.filesystem = "unknown"
		end

		local relative = not vfs.IsPathAbsolute(path)

		if is_folder and not path:endswith("/") then
			path = path .. "/"
		end

		out.full_path = path
		out.relative = relative

		out.GetFolders = get_folders

		return out
	end
end

function vfs.Open(path, mode, sub_mode)
	mode = mode or "read"

	local errors = {}

	for i, data in ipairs(vfs.TranslatePath(path)) do
		local file = prototype.CreateDerivedObject("file_system", data.context.Name)
		file:SetMode(mode)

		local ok, err = file:Open(data.path_info)

		file.path_used = data.path_info.full_path

		if ok ~= false then
			if mode == "write" then
				vfs.ClearCallCache()
			end
			return file
		else
			file:Remove()
			local err = "\t" ..  data.context.Name .. ": " ..  err
			if errors[#errors] ~= err then
				table.insert(errors, err)
			end
		end
	end

	return false, "unable to open file: \n" .. table.concat(errors, "\n")
end

(function(...) local vfs = (...) or _G.vfs

function vfs.AbsoluteToRelativePath(root, abs)
	local root_info = vfs.GetPathInfo(root)
	local abs_info = vfs.GetPathInfo(abs)
	return abs_info.full_path:sub(#root_info.full_path + 2)
end

function vfs.GetParentFolderFromPath(str, level)
	level = level or 1
	for i = #str, 1, -1 do
		local char = str:sub(i, i)
		if char == "/" then
			level = level - 1
		end
		if level == -1 then
			return str:sub(0, i)
		end
	end
	return ""
end

function vfs.GetFolderNameFromPath(str)
	if str:sub(#str, #str) == "/" then
		str = str:sub(0, #str - 1)
	end
	return str:match(".+/(.+)") or str:match(".+/(.+)/") or str:match(".+/(.+)") or str:match("(.+)/")
end

function vfs.GetFileNameFromPath(str)
	local pos = (str):reverse():find("/", 0, true)
	return pos and str:sub(-pos + 1) or str
end

function vfs.RemoveExtensionFromPath(str)
	return str:match("(.+)%..+") or str
end

function vfs.GetExtensionFromPath(str)
	return vfs.GetFileNameFromPath(str):match(".+%.(%w+)") or ""
end

function vfs.GetFolderFromPath(str)
	return str:match("(.*)/") .. "/"
end

function vfs.GetFileFromPath(str)
	return str:match(".*/(.*)")
end

function vfs.IsPathAbsolutePath(path)
	if LINUX then
		return path:sub(1,1) == "/"
	end

	if WINDOWS then
		return path:sub(1, 2):find("%a:") ~= nil
	end

end
function vfs.ParsePathVariables(path)
	-- windows
	path = path:gsub("%%(.-)%%", vfs.GetEnv)
	path = path:gsub("%%", "")
	path = path:gsub("%$%((.-)%)", vfs.GetEnv)

	-- linux
	path = path:gsub("%$%((.-)%)", "%1")

	return path
end

local character_translation = {
	["\\"] = "⟍",
	[":"] = "⠅",
	["*"] = "✱",
	["?"] = "❔",
	["<"] = "ᐸ",
	[">"] = "𝈷",
	["|"] = "ᥣ",
	["~"] = "𝀈",
	["#"] = "⧣",
	["\""] = "‟",
	["^"] = "ᣔ",
}

function vfs.ReplaceIllegalPathSymbols(path, forward_slash)
	local out = path:gsub(".", character_translation)

	if forward_slash then
		out = out:gsub("/", "⟋")
	end

	return out
end

function vfs.ReplaceIllegalCharacters()

end

function vfs.FixPathSlashes(path)
	return (path:gsub("\\", "/"):gsub("(/+)", "/"))
end

function vfs.CreateDirectoriesFromPath(path, force)
	local path_info = vfs.GetPathInfo(path, true)
	local folders = path_info:GetFolders("full")

	local max = #folders

	if not path:endswith("/") then
		max = max - 1
	end

	for i = 1, max do
		local folder = folders[i]
		local ok, err = vfs.CreateDirectory(path_info.filesystem ..":"..  folder, force)
		if not ok then
			return nil, err
		end
	end

	return true
end

function vfs.GetAbsolutePath(path, is_folder)
	if vfs.IsPathAbsolute(path) then
		if
			(is_folder == true and vfs.IsDirectory(path)) or
			(is_folder == false and vfs.IsFile(path)) or
			vfs.Exists(path)
		then
			return path
		end
	end

	for _, data in ipairs(vfs.TranslatePath(path, is_folder)) do
		if data.context:CacheCall("IsFile", data.path_info) or data.context:CacheCall("IsFolder", data.path_info) then
			return data.path_info.full_path
		end
	end
end end)( vfs)
(function(...) local vfs = (...) or _G.vfs

local CONTEXT = {}

CONTEXT.Name = "base"

prototype.GetSet(CONTEXT, "Mode", "read")

function CONTEXT:__tostring2()
	return self.path_used or ""
end

do
	local cache = vfs.call_cache or {}
	local last_framenumber = 0

	function vfs.ClearCallCache()
		table.clear(cache)
	end

	function CONTEXT:CacheCall(func_name, path_info)
		if system then
			local frame_number = system.GetFrameNumber()
			if frame_number ~= last_framenumber then
				vfs.ClearCallCache()
				last_framenumber = frame_number
			end
		end

		cache[func_name] = cache[func_name] or {}
		cache[func_name][self.Name] = cache[func_name][self.Name] or {}

		if cache[func_name][self.Name][path_info.full_path] == nil then
			cache[func_name][self.Name][path_info.full_path] = self[func_name](self, path_info)
		end

		-- might have been cleared inbetween
		cache[func_name] = cache[func_name] or {}
		cache[func_name][self.Name] = cache[func_name][self.Name] or {}

		return cache[func_name][self.Name][path_info.full_path]
	end

	vfs.call_cache = cache
end

function CONTEXT:Write(str)
	return self:WriteBytes(str)
end

function CONTEXT:Read(bytes)
	return self:ReadBytes(bytes)
end

function CONTEXT:Lines()
	local temp = {}
	return function()
		while not self:TheEnd() do
			local char = self:ReadChar()

			if char == "\n" then
				local str = table.concat(temp)
				table.clear(temp)
				return str
			else
				table.insert(temp, char)
			end
		end
	end
end

function CONTEXT:ReadByte()
	local str = self:ReadBytes(1)
	if str then
		return str:byte()
	end
end

function CONTEXT:WriteByte(byte)
	self:WriteBytes(string.char(byte))
end

function CONTEXT:GetFiles(path_info)
	error(self.Name .. ": not implemented")
end

function CONTEXT:IsFile(path_info)
	error(self.Name .. ": not implemented")
end

function CONTEXT:IsFolder(path_info)
	error(self.Name .. ": not implemented")
end

function CONTEXT:CreateFolder(path_info)
	error(self.Name .. ": not implemented")
end

function CONTEXT:Open(path, mode, ...)
	error(self.Name .. ": not implemented")
end

function CONTEXT:SetPosition(pos)
	error(self.Name .. ": not implemented")
end

function CONTEXT:GetPosition()
	error(self.Name .. ": not implemented")
end

function CONTEXT:Close()
	error(self.Name .. ": not implemented")
end

function CONTEXT:GetSize()
	error(self.Name .. ": not implemented")
end

function CONTEXT:GetLastModified()
	error(self.Name .. ": not implemented")
end

function CONTEXT:GetLastAccessed()
	error(self.Name .. ": not implemented")
end

function CONTEXT:Flush()
	error(self.Name .. ": not implemented")
end

function CONTEXT:Close()
	self:Remove()
end

function CONTEXT:IsFolderValid(path_info)
	return self:IsFolder(path_info)
end

function CONTEXT:IsArchive(path_info)
	return false
end

runfile("lua/libraries/prototype/buffer_template.lua", CONTEXT)

prototype.Register(CONTEXT, "file_system", CONTEXT.Name)
 end)( vfs)
(function(...) local vfs = (...) or _G.vfs

function vfs.GetFiles(info)
	local out = {}

	if info.verbose then
		local i = 1
		for _, data in ipairs(vfs.TranslatePath(info.path, true)) do
			local found = data.context:CacheCall("GetFiles", data.path_info)
			if found then
				local prefix = data.context.Name .. ":" .. data.path_info.full_path
				for _, name in ipairs(found) do
					if not info.filter or name:find(info.filter, info.filter_pos, info.filter_plain) then
						out[i] = {
							name = name,
							filesystem = data.context.Name,
							full_path = prefix .. name,
							userdata = data.userdata,
						}
						i = i + 1
					end
				end
			end
		end

		if not info.no_sort then
			if info.reverse_sort then
				table.sort(out, function(a, b) return a.full_path:lower() > b.full_path:lower() end)
			else
				table.sort(out, function(a, b) return a.full_path:lower() < b.full_path:lower() end)
			end
		end
	else
		local done = {}
		local i = 1

		for _, data in ipairs(vfs.TranslatePath(info.path, true)) do
			local found = data.context:CacheCall("GetFiles", data.path_info)

			if found then
				for _, name in ipairs(found) do
					if not done[name] then
						done[name] = true

						if info.full_path then
							name = data.path_info.full_path .. name
						end

						if not info.filter or name:find(info.filter, info.filter_pos, info.filter_plain) then
							out[i] = name
							i = i + 1
						end
					end
				end
			end
		end

		done = nil

		if not info.no_sort then
			if info.reverse_sort then
				table.sort(out, function(a, b) return a:lower() > b:lower() end)
			else
				table.sort(out, function(a, b) return a:lower() < b:lower() end)
			end
		end
	end

	return out
end

function vfs.Find(path, full_path, reverse_sort, start, plain, verbose)
	local path_, filter = path:match("(.+)/(.*)")
	if filter then path = path_ end

	if filter == "" then filter = nil end

	return vfs.GetFiles({
		path = path,

		filter = filter,
		filter_pos = start,
		filter_plain = plain,

		verbose = verbose,
		full_path = full_path,
		reverse_sort = reverse_sort,
		no_filter = reverse_sort == nil,
	})
end

function vfs.Iterate(path, ...)
	local tbl = vfs.Find(path, ...)
	local i = 1

	return function()
		local val = tbl[i]

		i = i + 1

		if val then
			return val
		end
	end
end

do
	local out
	local function search(path, ext, callback, dir_blacklist, include_directories, userdata)
		for _, v in ipairs(vfs.GetFiles({path = path, verbose = true, no_sort = true})) do
			local is_dir = vfs.IsDirectory(v.full_path)

			if (not ext or v.name:endswiththese(ext)) and (not is_dir or include_directories) then
				if callback then
					if callback(v.full_path, v.userdata or userdata, v) ~= nil then
						return
					end
				else
					table.insert(out, v.full_path)
				end
			end

			if is_dir then
				local okay = true
				if dir_blacklist then
					for i,v in ipairs(dir_blacklist) do
						if v.full_path:find(v) then
							okay = false
							break
						end
					end
				end
				if okay then
					search(v.full_path .. "/", ext, callback, dir_blacklist, include_directories, v.userdata or userdata)
				end
			end
		end
	end

	function vfs.GetFilesRecursive(path, ext, callback, dir_blacklist)
		out = {}
		search(path, ext, callback, dir_blacklist, include_directories)
		return out
	end
end end)( vfs)
(function(...) local vfs = (...) or _G.vfs

function vfs.FindMixedCasePath(path)
	-- try all lower case first just in case
	if vfs.IsFile(path:lower()) then
		return path:lower()
	end

	local dir = ""
	for _, str in ipairs(path:split("/")) do
		for _, found in ipairs(vfs.Find(dir)) do
			if found:lower() == str:lower() then
				str = found
				dir = dir .. str .. "/"
				break
			end
		end
	end
	dir = dir:sub(0,-2)


	if #dir == #path then
		wlog("found mixed case path for %s: found %s", dir, path)
		return dir
	end

	wlog("tried to find mixed case path for %s but nothing was found", path, 2)
end

local fs = require("fs")

vfs.OSCreateDirectory = fs.createdir
vfs.OSGetAttributes = fs.getattributes

do
	vfs.SetWorkingDirectory = fs.setcd
	vfs.GetWorkingDirectory = fs.getcd

	if utility.MakePushPopFunction then
		utility.MakePushPopFunction(vfs, "WorkingDirectory")
	end
end

function vfs.Delete(path, ...)
	local abs_path = vfs.GetAbsolutePath(path, ...)

	if abs_path then
		local ok, err = os.remove(abs_path)

		return ok, err
	end

	local err = ("No such file or directory %q"):format(path)

	if CLI then
		error(err, 2)
	end

	return nil, err
end

function vfs.Rename(path, name, ...)
	local abs_path = vfs.GetAbsolutePath(path, ...)

	if abs_path then
		local dst = abs_path:match("(.+/)") .. name

		if WINDOWS then
			if vfs.IsFile(dst) then
				vfs.Delete(dst)
			end
		end

		local ok, err = os.rename(abs_path, dst)

		if not ok then
			if CLI then
				error(err, 2)
			else
				wlog(err)
			end
		end

		return ok, err
	end

	local err = ("No such file or directory %q"):format(path)

	if CLI then
		error(err, 2)
	end

	return nil, err
end

local function add_helper(name, func, mode, cb)
	vfs[name] = function(path, ...)
		if cb then cb(path, ...) end

		local file, err = vfs.Open(path, mode)

		if file then
			local args = {...}

			if event then
				local ret = {event.Call("VFSPre" .. name, path, ...)}
				if ret[1] ~= nil then
					for i,v in ipairs(args) do
						if ret[i] ~= nil then
							args[i] = ret[i]
						end
					end
				end
			end

			local res, err = file[func](file, unpack(args))

			file:Close()

			if res and event then
				local res, err = event.Call("VFSPost" .. name, path, res)
				if res ~= nil or err then
					if CLI then
						debug.trace()
						error(err, 2)
					end

					return res, err
				end
			end

			return res, err
		end

		if CLI then
			logn(path)
			error(err, 2)
		end

		return nil, err
	end
end

add_helper("Read", "ReadAll", "read")
add_helper("Write", "WriteBytes", "write", function(path, content, on_change)
	path = path:gsub("(.+/)(.+)", function(folder, file_name)
		for _, char in ipairs({--[['\\', '/', ]]':', '%*', '%?', '"', '<', '>', '|'}) do
			file_name = file_name:gsub(char, "_il" .. char:byte() .. "_")
		end
		return folder .. file_name
	end)

	if type(on_change) == "function" then
		vfs.MonitorFile(path, function(file_path)
			on_change(vfs.Read(file_path), file_path)
		end)
		on_change(content)
	end

	if path:startswith("data/") or path:sub(4):startswith("data/") then

		if path:startswith("os:") then
			path = path:sub(4)
		end

		path = path:sub(#"data/" + 1)

		local fs = vfs.GetFileSystem("os")

		if fs then
			local base = e.USERDATA_FOLDER
			local dir = ""
			for folder in path:gmatch("(.-/)") do
				dir = dir .. folder
				fs:CreateFolder({full_path = base .. dir})
			end
		end
	elseif CLI then
		vfs.CreateDirectoriesFromPath(path, true)
	end
end)

add_helper("GetLastModified", "GetLastModified", "read")
add_helper("GetLastAccessed", "GetLastAccessed", "read")
add_helper("GetSize", "GetSize", "read")

function vfs.CreateDirectory(path, force)
	if vfs.IsDirectory(path) then return true end

	local path_info = vfs.GetPathInfo(path, true)
	local dir_name = vfs.GetFolderNameFromPath(path_info.full_path) or path_info.full_path

	local parent_dir = vfs.GetParentFolderFromPath(path_info.full_path)
	local full_path = vfs.GetAbsolutePath(parent_dir, true)

	if not full_path then return nil, "directory " .. parent_dir .. " does not exist" end

	local path_info = vfs.GetPathInfo(path_info.filesystem .. ":" .. full_path)

	if path_info.filesystem == "unknown" then
		return nil, "filesystem must be explicit when creating directories"
	end

	path_info.full_path = path_info.full_path .. dir_name .. "/"

	return vfs.GetFileSystem(path_info.filesystem):CreateFolder(path_info, force)
end

function vfs.IsDirectory(path)
	if path == "" then return false end

	for _, data in ipairs(vfs.TranslatePath(path, true)) do
		if data.context:CacheCall("IsFolder", data.path_info) then
			return true
		end
	end

	return false
end

function vfs.IsFile(path)
	if path == "" then return false end

	for _, data in ipairs(vfs.TranslatePath(path)) do
		if data.context:CacheCall("IsFile", data.path_info) then
			return true
		end
	end

	return false
end

function vfs.IsFolderValid(path)
	if path == "" then return false, "path is nothing" end

	local path, err = vfs.GetAbsolutePath(path)
	if not path then
		return false, err
	end

	local path_info = vfs.GetPathInfo(path, true)

	local errors = ""

	for _, context in ipairs(vfs.GetFileSystems()) do
		if context:IsArchive(path_info) then
			local ok, err = context:IsFolderValid(path_info)

			if ok then
				return true
			end

			if err then
				errors = errors .. err .. "\n"
			end
		end
	end

	return false, errors
end

function vfs.Exists(path)
	return vfs.IsDirectory(path) or vfs.IsFile(path)
end end)( vfs)
(function(...) local vfs = (...) or _G.vfs

vfs.loaded_addons = vfs.loaded_addons or {}
vfs.disabled_addons = vfs.disabled_addons or {}

function vfs.MountAddons(dir)
	for info in vfs.Iterate(dir, true, nil, nil, nil, true) do
		if info.name ~= e.INTERNAL_ADDON_NAME then
			if
				vfs.IsDirectory(info.full_path:sub(#info.filesystem + 2)) and
				not info.name:startswith(".") and
				not info.name:startswith("__") and
				(info.name ~= "data" and info.filesystem == "os")
			then
				vfs.MountAddon(info.full_path:sub(#info.filesystem + 2) .. "/")
			end
		end
	end
end

function vfs.SortAddonsAfterPriority()
	local vfs_loaded_addons = copy

	local found = {}
	local not_found = {}
	local done = {}

	local function sort_dependencies(info)
		if done[info] then return end
		done[info] = true

		local found_addon = false

		if info.dependencies then
			for _, name in ipairs(info.dependencies) do
				for _, info in ipairs(vfs.loaded_addons) do
					if info.name == name and info.dependencies then
						sort_dependencies(info)
						found_addon = true
						break
					end
				end
			end
		end

		if found_addon then
			table.insert(found, info)
		else
			table.insert(not_found, info)
		end
	end

	for _, info in ipairs(vfs.loaded_addons) do
		sort_dependencies(info)
	end

	table.sort(not_found, function(a,b) return a.priority > b.priority end)

	table.add(found, not_found)

	vfs.loaded_addons = found
end

function vfs.GetAddonInfo(addon)
	for _, info in pairs(vfs.loaded_addons) do
		if info.name == addon then
			return info
		end
	end

	return {}
end

local function check_dependencies(info, what)
	if info.dependencies then
		for i, name in ipairs(info.dependencies) do
			local found = false
			for i,v in ipairs(vfs.loaded_addons) do
				if v.name == name then
					found = true
					break
				end
			end
			if not found then
				if what then llog(info.name, ": could not ", what ," because it depends on ", name) end
				return false
			end
		end
	end

	return true
end

function vfs.InitAddons()
	for _, info in pairs(vfs.GetMountedAddons()) do
		if info.startup and check_dependencies(info, "init") then
			runfile(info.startup)
		end
	end
end

function vfs.AutorunAddon(addon, folder, force)
	local info =  type(addon) == "table" and addon or vfs.GetAddonInfo(addon)
	if force or info.load ~= false and not info.core then
		_G.INFO = info

			local function run()
				if not check_dependencies(info, "run autorun " .. folder .. "*") then
					return
				end

				-- autorun folders
				for path in vfs.Iterate(info.path .. "lua/autorun/" .. folder, true) do
					if path:find("%.lua") then
						local ok, err = system.pcall(vfs.RunFile, path)
						if not ok then
							wlog(err)
						end
					end
				end
			end

			if info.event then
				event.AddListener(info.event, "addon_" .. folder, function()
					run()
					return e.EVENT_DESTROY
				end)
			else
				run()
			end

		_G.INFO = nil
	else
		--logf("the addon %q does not want to be loaded\n", info.name)
	end
end

function vfs.GetMountedAddons()
	return vfs.loaded_addons
end

function vfs.AutorunAddons(folder, force)
	folder = folder or ""
	if not CLI then
		utility.PushTimeWarning()
	end
	for _, info in pairs(vfs.GetMountedAddons()) do
		vfs.AutorunAddon(info, folder, force)
	end
	if not CLI then
		utility.PopTimeWarning("autorun " .. folder .. "*", 0.1)
	end
end

function vfs.MountAddon(path, force)
	local info = {}

	if vfs.IsFile(path .. "config.lua") then
		local func, err = vfs.LoadFile(path .. "config.lua")
		if func then
			info = func() or info
		else
			wlog(err)
		end
	end

	if vfs.IsFile(path .. "addon.json") then
		info.load = false
		info.gmod_addon = true
	end

	local folder = path:match(".+/(.+)/")

	info.path = path
	info.file_info = folder
	info.name = info.name or folder
	info.folder = folder
	info.priority = info.priority or -1

	if not info.startup and vfs.IsFile(path .. "lua/init.lua") then
		info.startup = path .. "lua/init.lua"
	end

	if info.dependencies and type(info.dependencies) == "string" then
		info.dependencies = {info.dependencies}
	end

	table.insert(vfs.loaded_addons, info)

	e["ADDON_" .. info.name:upper()] = info

	vfs.SortAddonsAfterPriority()

	if info.load == false and not force then
		table.insert(vfs.disabled_addons, info)
		return false
	end

	vfs.Mount(path)

	if vfs.IsDirectory(path .. "addons") then
		vfs.MountAddons(path .. "addons/")
	end

	return true
end

return vfs
 end)( vfs)
(function(...) local vfs = (...) or _G.vfs

vfs.files_ran_ = vfs.files_ran_ or {}

local function store_run_file_path(path)
	vfs.files_ran = nil
	table.insert(vfs.files_ran_, path)
end


function loadfile(path, ...)
	store_run_file_path(path)
	return _OLD_G.loadfile(path, ...)
end

function dofile(path, ...)
	store_run_file_path(path)
	return _OLD_G.dofile(path, ...)
end

do
	local first = true
	local resolved = {}

	function vfs.GetLoadedLuaFiles()
		if not vfs.files_ran then
			vfs.files_ran = {}
			for _, path in ipairs(vfs.files_ran_) do
				local full_path = vfs.GetAbsolutePath(path, false) or path
				vfs.files_ran[full_path] = vfs.OSGetAttributes(full_path)
			end
		end

		return vfs.files_ran
	end
end

function vfs.LoadFile(path, chunkname)
	local full_path = vfs.GetAbsolutePath(path, false)

	if full_path then
		if event then full_path = event.Call("PreLoadFile", full_path) or full_path end

		local res, err = vfs.Read(full_path)

		if not res and not err then
			res = ""
		end

		if not res then
			return res, err, full_path
		end

		if event then res = event.Call("PreLoadString", res, full_path) or res end

		-- prepend "@" in front of the path so it will be treated as a lua file and not a string by lua internally
		-- for nicer error messages and debug

		if vfs.modify_chunkname then
			chunkname = vfs.modify_chunkname(full_path)
		end

		res, err = loadstring(res, chunkname or "@" .. full_path:replace(e.ROOT_FOLDER, ""))

		if event and res then res = event.Call("PostLoadString", res, full_path) or res end

		store_run_file_path(full_path)

		return res, err, full_path
	end

	return nil, path .. ": No such file or directory"
end

function vfs.DoFile(path, ...)
	return assert(vfs.LoadFile(path))(...)
end

do -- runfile
	local filerun_stack = vfs.filerun_stack or {}
	vfs.filerun_stack = filerun_stack

	function vfs.PushToFileRunStack(path)
		table.insert(filerun_stack, path)
	end

	function vfs.PopFromFileRunStack()
		table.remove(filerun_stack)
	end

	function vfs.GetFileRunStack()
		return filerun_stack
	end

	local function not_found(err)
		return
			err and
			(
				err:find("No such file or directory", nil, true) or
				err:find("Invalid argument", nil, true)
			)
	end

	local system_pcall = true

	function vfs.RunFile(source, ...)

		if type(source) == "table" then
			system_pcall = false
			local ok, err
			local errors = {}
			for _, path in ipairs(source) do
				ok, err = vfs.RunFile(path)
				if ok == false then
					table.insert(errors, err .. ": " .. path)
				else
					return ok
				end
			end
			system_pcall = true

			if ok == false then
				err = table.concat(errors, "\n")
			else
				ok = true
				err = nil
			end

			return ok, err
		end

		if source:startswith("!") then
			source = source:sub(2)
			if filerun_stack[#filerun_stack] then
				source = filerun_stack[#filerun_stack]:match("(.+/).-/") .. source
			end
		end

		local dir, file = source:match("(.+/)(.+)")

		if not dir then
			dir = ""
			file = source
		end

		if file == "*" then
			local previous_dir = filerun_stack[#filerun_stack]
			local original_dir = dir

			if previous_dir then
				dir = previous_dir .. dir
			end

			if not vfs.IsDirectory(dir) then
				dir = original_dir
			end

			for script in vfs.Iterate(dir .. ".+%.lua", true) do
				local func, err, full_path = vfs.LoadFile(script)

				if func then
					vfs.PushToFileRunStack(full_path:match("(.+/)") or dir)

					_G.FILE_PATH = full_path
					_G.FILE_NAME = full_path:match(".*/(.+)%.") or full_path
					_G.FILE_EXTENSION = full_path:match(".*/.+%.(.+)")

					if not CLI and utility and utility.PushTimeWarning then
						utility.PushTimeWarning()
					end

					local ok, err

					if system_pcall and system and system.pcall then
						ok, err = system.pcall(func, ...)
					else
						ok, err = pcall(func, ...)
					end

					if not CLI and utility and utility.PushTimeWarning then
						utility.PopTimeWarning(full_path, 0.01)
					end

					_G.FILE_NAME = nil
					_G.FILE_PATH = nil
					_G.FILE_EXTENSION = nil

					if not ok then logn(err) end

					vfs.PopFromFileRunStack()
				end

				if not func then
					logn(err)
				end
			end

			return
		end

		local previous_dir = filerun_stack[#filerun_stack]

		if previous_dir then
			dir = previous_dir .. dir
		end

		local full_path
		local err
		local func
		local path = source

		if vfs.IsPathAbsolute(path) then
			func, err, full_path = vfs.LoadFile(path)
		else
			if path:startswith("lua/") then
				func, err, full_path = vfs.LoadFile(path)
			end

			if not func then
				-- try first with the last directory
				-- once with lua prepended
				path = dir .. file
				func, err, full_path = vfs.LoadFile(path)

				if not_found(err) then

					if path ~= dir .. file then
						path = dir .. file
						func, err, full_path = vfs.LoadFile(path)
					end

					-- and without the last directory
					-- once with lua prepended
					if not_found(err) then
						path = source
						func, err, full_path = vfs.LoadFile(path)
					end
				end
			end
		end

		if func then
			dir = path:match("(.+/)(.+)")

			if not full_path:startswith(e.ROOT_FOLDER) then
				vfs.PushWorkingDirectory(dir)
			end

			vfs.PushToFileRunStack(dir)

			_G.FILE_PATH = full_path
			_G.FILE_NAME = full_path:match(".*/(.+)%.") or full_path
			_G.FILE_EXTENSION = full_path:match(".*/.+%.(.+)")

			if full_path:find(e.ROOT_FOLDER, nil, true) then
				utility.PushTimeWarning()
			end

			local res
			if system_pcall and system and system.pcall then
				res = {system.pcall(func, ...)}
			else
				res = {pcall(func, ...)}
			end

			if full_path:find(e.ROOT_FOLDER, nil, true) then
				utility.PopTimeWarning(full_path:gsub(e.ROOT_FOLDER, ""), 0.025, "[runfile]")
			end

			_G.FILE_PATH = nil
			_G.FILE_NAME = nil
			_G.FILE_EXTENSION = nil

			if not res[1] then
				logn(res[2])
			end

			vfs.PopFromFileRunStack()

			if not full_path:startswith(e.ROOT_FOLDER) then
				vfs.PopWorkingDirectory(dir)
			end

			return select(2, unpack(res))
		end

		if system_pcall and full_path then
			err = err or "no error"

			logn(source:sub(1) .. " " .. err)

			debug.openscript(full_path, err:match(":(%d+)"))
		end

		return false, err
	end
end

-- although vfs will add a loader for each mount, the module folder has to be an exception for modules only
-- this loader should support more ways of loading than just adding ".lua"

function vfs.AddPackageLoader(func, loaders)
	loaders = loaders or package.loaders

	for i, v in ipairs(loaders) do
		if v == func then
			table.remove(loaders, i)
			break
		end
	end
	table.insert(loaders, func)
end

local function handle_dir(dir, path)
	if path:startswith("..") then
		local last_dir = vfs.GetFileRunStack()[#vfs.GetFileRunStack()]
		local dir = vfs.FixPathSlashes(vfs.GetParentFolderFromPath(last_dir, 1) .. path:sub(3))
		return dir
	elseif path:startswith(".") then
		return vfs.FixPathSlashes(vfs.GetFileRunStack()[#vfs.GetFileRunStack()] .. path:sub(2))
	end

	return dir .. path
end

function vfs.AddModuleDirectory(dir, loaders)
	loaders = loaders or package.loaders

	do -- relative path
		vfs.AddPackageLoader(function(path)
			return vfs.LoadFile(handle_dir(dir, path) .. ".lua")
		end, loaders)

		vfs.AddPackageLoader(function(path)
			local path, count = path:gsub("(.)%.(.)", "%1/%2")
			if count == 0 then return end
			return vfs.LoadFile(handle_dir(dir, path) .. ".lua")
		end, loaders)

		vfs.AddPackageLoader(function(path)
			return vfs.LoadFile(handle_dir(dir, path))
		end, loaders)
	end

	vfs.AddPackageLoader(function(path)
		return vfs.LoadFile(handle_dir(dir, path) .. "/"..path..".lua")
	end, loaders)

	vfs.AddPackageLoader(function(path)
		return vfs.LoadFile(handle_dir(dir, path) .. "/init.lua")
	end, loaders)

	-- again but with . replaced with /
	vfs.AddPackageLoader(function(path)
		path = path:gsub("\\", "/"):gsub("(%a)%.(%a)", "%1/%2")
		return vfs.LoadFile(handle_dir(dir, path) .. ".lua")
	end, loaders)

	vfs.AddPackageLoader(function(path)
		path = path:gsub("\\", "/"):gsub("(%a)%.(%a)", "%1/%2")
		return vfs.LoadFile(handle_dir(dir, path) .. "/init.lua")
	end, loaders)

	vfs.AddPackageLoader(function(path)
		path = path:gsub("\\", "/"):gsub("(%a)%.(%a)", "%1/%2")
		return vfs.LoadFile(handle_dir(dir, path) .. "/" .. path ..  ".lua")
	end, loaders)
end end)( vfs)

(function(...) local vfs = (...) or _G.vfs

local CONTEXT = {}

CONTEXT.Name = "generic_archive"

function CONTEXT:AddEntry(entry)
	self.tree.done_directories = self.tree.done_directories or {}

	local directory = entry.full_path:match("(.+)/")
	entry.file_name = entry.full_path:match(".+/(.+)")

	entry.size = tonumber(entry.size) or 0
	--entry.crc = entry.crc or 0
	entry.offset = tonumber(entry.offset) or 0
	entry.is_file = true

	local full_path = entry.full_path
	entry.full_path = nil

	self.tree:SetEntry(full_path, entry)
	self.tree:SetEntry(directory, {path = directory, is_dir = true, file_name = directory:match(".+/(.+)") or directory})

	for i = #directory, 1, -1 do
		local char = directory:sub(i, i)
		if char == "/" then
			local dir = directory:sub(0, i)
			if dir == "" or self.tree.done_directories[dir] then break end
			local file_name = dir:match(".+/(.+)") or dir

			if file_name:sub(-1) == "/" then
				file_name = file_name:sub(0, -2)
			end

			self.tree:SetEntry(dir, {path = dir, is_dir = true, file_name = file_name})
			self.tree.done_directories[dir] = true
		end
	end
end

--self:ParseArchive(vfs.Open("os:G:/SteamLibrary/SteamApps/common/Skyrim/Data/Skyrim - Sounds.gma"), "os:G:/SteamLibrary/SteamApps/common/Skyrim/Data/Skyrim - Sounds.gma")

local cache = table.weak()
local never

local modified_cache = {}

function CONTEXT:GetFileTree(path_info)
	if never then return false, "recursive call to GetFileTree" end

	local archive_path, relative = path_info.full_path:slice((self.NameEndsWith or "") .. "." .. self.Extension .. "/", 0, 1)

	if not archive_path then
		return false, "not a valid archive path"
	end

	if not modified_cache[archive_path] then
		never = true
		modified_cache[archive_path] = vfs.GetLastModified(archive_path) or ""
		never = false
	end

	local cache_key = archive_path .. modified_cache[archive_path]
	if cache[cache_key] then
		return cache[cache_key], relative, archive_path
	end

	if not vfs.IsFile(archive_path) then
		return false, "not a valid archive path"
	end

	local cache_path = "os:data/archive_cache/" .. crypto.CRC32(cache_key)
	if vfs.IsFile(cache_path) then
		never = true
		local tree_data, err, what = serializer.ReadFile("msgpack", cache_path)
		never = false

		if tree_data then
			local tree = utility.CreateTree("/", tree_data)
			cache[cache_key] = tree
			return cache[cache_key], relative, archive_path
		end
	end

	never = true
	local file, err = vfs.Open("os:" .. archive_path)
	never = false
	if not file then
		return false, err
	end

	if not CLI then
		llog("generating tree data cache for ", archive_path)
	end

	local tree = utility.CreateTree("/")
	self.tree = tree

	local ok, err = self:OnParseArchive(file, archive_path)

	self.tree.done_directories = nil

	file:Close()

	if not ok then
		return false, err
	end

	cache[cache_key] = tree

	utility.RunOnNextGarbageCollection(function()
		serializer.WriteFile("msgpack", cache_path, tree.tree)
	end)

	return tree, relative, archive_path
end

function CONTEXT:IsFile(path_info)
	local tree, relative, archive_path = self:GetFileTree(path_info)
	if not tree then return tree, relative end
	local entry, err = tree:GetEntry(relative)

	if entry and entry.is_file then
		return true
	end
end

function CONTEXT:IsFolder(path_info)
	local tree, relative, archive_path = self:GetFileTree(path_info)
	if relative == "" then return true end
	if not tree then return tree, relative end
	local entry = tree:GetEntry(relative)
	if entry and entry.is_dir then
		return true
	end
end

function CONTEXT:GetFiles(path_info)
	local tree, relative, archive_path = self:GetFileTree(path_info)
	if not tree then return tree, relative end

	local children, err = tree:GetChildren(relative:match("(.*)/") or relative)

	if not children then return false, err end

	local out = {}
	for _, v in pairs(children) do
		if type(v) == "table" and v.v then -- fix me!!
			table.insert(out, v.v.file_name)
		end
	end

	return out
end

function CONTEXT:TranslateArchivePath(file_info)
	return file_info.archive_path
end

local cache = table.weak()

function CONTEXT:Open(path_info, mode, ...)
	if self:GetMode() == "read" then
		local tree, relative, archive_path = self:GetFileTree(path_info)
		if not tree then
			return false, relative
		end
		local file_info = tree:GetEntry(relative)
		if not file_info then
			return false, "file not found in archive"
		end

		if file_info.is_dir then
			return false, "file is a directory"
		end

		local archive_path = self:TranslateArchivePath(file_info, archive_path)
		local file, err = cache[archive_path] or vfs.Open(archive_path)

		cache[archive_path] = file

		if not file then
			return false, err
		end

		file:SetPosition(file_info.offset)
		self.position = 0
		self.file_info = file_info

		if file_info.preload_data then
			if file_info.size == #file_info.preload_data then
				self.data = file_info.preload_data
			else
				self.data = file_info.preload_data .. file:ReadBytes(file_info.size-#file_info.preload_data)
			end
			self.file = nil
		else
			self.file = file
		end

		return true
	elseif self:GetMode() == "write" then
		return false, "write mode not implemented"
	end

	return false, "read mode " .. self:GetMode() .. " not supported"
end

function CONTEXT:ReadByte()
	if self.file_info.preload_data then
		local char = self.data:sub(self.position+1, self.position+1)
		self.position = math.clamp(self.position + 1, 0, self.file_info.size)
		return char:byte()
	else
		self.file:SetPosition(self.file_info.offset + self.position)
		local char = self.file:ReadByte(1)
		self.position = math.clamp(self.position + 1, 0, self.file_info.size)
		return char
	end
end

function CONTEXT:ReadBytes(bytes)
	if bytes == math.huge then bytes = self:GetSize() end

	if self.file_info.preload_data then
		local str = {}
		for i = 1, bytes do
			local byte = self:ReadByte()
			if not byte then return table.concat(str, "") end
			str[i] = string.char(byte)
		end
		return table.concat(str, "")
	else
		bytes = math.min(bytes, self.file_info.size - self.position)

		self.file:SetPosition(self.file_info.offset + self.position)
		local str = self.file:ReadBytes(bytes)
		self.position = math.clamp(self.position + bytes, 0, self.file_info.size)

		if str == "" then str = nil end

		return str
	end
end

function CONTEXT:SetPosition(pos)
	self.position = math.clamp(pos, 0, self.file_info.size)
end

function CONTEXT:GetPosition()
	return self.position
end

function CONTEXT:OnRemove()
	if self.file and self.file:IsValid() then
		self.file = nil -- just unref
	end
end

function CONTEXT:GetSize()
	return self.file_info.size
end

vfs.RegisterFileSystem(CONTEXT, true) end)( vfs)
(function(...) local vfs = (...) or _G.vfs

local fs = require("fs")
local ffi = require("ffi")

local CONTEXT = {}

CONTEXT.Name = "os"
CONTEXT.Position = 0

function CONTEXT:CreateFolder(path_info, force)
	if force or path_info.full_path:startswith(e.DATA_FOLDER) or path_info.full_path:startswith(e.USERDATA_FOLDER) or path_info.full_path:startswith(e.ROOT_FOLDER) then
		if self:IsFolder(path_info) then return true end

		if force then
			if not CLI then
				llog("creating directory: ", path_info.full_path)
			end
		end

		local path = path_info.full_path
		--if path:endswith("/") then path = path:sub(0, -2) end
		local ok, err = fs.createdir(path)
		vfs.ClearCallCache()
		return ok, err
	end
	return false, "directory does not start from goluwa"
end

function CONTEXT:GetFiles(path_info)
	if not self:IsFolder(path_info) then
		return false, "not a directory"
	end

	return fs.find(path_info.full_path)
end

function CONTEXT:IsFile(path_info)
	local info = fs.getattributes(path_info.full_path)
	return info and info.type ~= "directory"
end

function CONTEXT:IsFolder(path_info)
	if path_info.full_path:endswith("/") then
		local info = fs.getattributes(path_info.full_path:sub(0, -2))
		return info and info.type == "directory"
	end
end

function CONTEXT:ReadAll()
	return self:ReadBytes(math.huge)
end

if fs.open then

	-- if CONTEXT:Open errors the virtual file system will assume
	-- the file doesn't exist and will go to the next mounted context

	local translate_mode = {
		read = "r",
		write = "w",
	}

	function CONTEXT:Open(path_info, ...)
		local mode = translate_mode[self:GetMode()]

		if not mode then return false, "mode not supported" end

		self.file = fs.open(path_info.full_path, mode .. "b")

		if self.file == nil then
			return false, "unable to open file: " .. ffi.strerror()
		end

		self.attributes = fs.getattributes(path_info.full_path)
	end

	function CONTEXT:WriteBytes(str)
		return fs.write(str, 1, #str, self.file)
	end

	local ctype = ffi.typeof("uint8_t[?]")
	local ffi_string = ffi.string
	local math_min = math.min
	-- without this cache thing loading gm_construct takes 30 sec opposed to 15
	local cache = {}

	for i = 1, 32 do
		cache[i] = ctype(i)
	end

	function CONTEXT:ReadBytes(bytes)
		bytes = math_min(bytes, self.attributes.size)

		local buff = bytes > 32 and ctype(bytes) or cache[bytes]

		if self.memory then
			local mem_pos_start = math_min(tonumber(self.mem_pos), self.attributes.size)
			local mem_pos_stop = math_min(tonumber(mem_pos_start + bytes), self.attributes.size)

			local i = 0
			for mem_i = mem_pos_start, mem_pos_stop-1 do
				buff[i] = self.memory[mem_i]
				i = i + 1
			end

			self.mem_pos = self.mem_pos + bytes

			return ffi.string(buff, bytes)
		else
			local len = fs.read(buff, bytes, 1, self.file)

			if len > 0 or fs.eof(self.file) == 1 then
				return ffi_string(buff, bytes)
			end
		end
	end

	function CONTEXT:LoadToMemory()
		local bytes = self:GetSize()
		local buffer = ctype(bytes)
		local len = fs.read(buffer, bytes, 1, self.file)
		self.memory = buffer
		self:SetPosition(ffi.new("uint64_t", 0))
		self:OnRemove()
	end

	function CONTEXT:SetPosition(pos)
		if self.memory then
			self.mem_pos = pos
		else
			fs.seek(self.file, pos, 0)
		end
	end

	function CONTEXT:GetPosition()
		if self.memory then
			return self.mem_pos
		else
			return fs.tell(self.file)
		end
	end

	function CONTEXT:OnRemove()
		if self.file ~= nil then
			fs.close(self.file)
			self.file = nil
		end
	end
else
	local translate_mode = {
		read = "r",
		write = "w",
	}

	function CONTEXT:Open(path_info, ...)
		local mode = translate_mode[self:GetMode()]

		if not mode then return false, "mode not supported" end

		local f, err = io.open(path_info.full_path, mode .. "b")

		self.file = f

		if self.file == nil then
			return false, "unable to open file: " .. err
		end

		self.attributes = fs.getattributes(path_info.full_path)
	end

	function CONTEXT:WriteBytes(str)
		return self.file:write(str)
	end

	function CONTEXT:ReadBytes(bytes)
		bytes = math.min(bytes, self.attributes.size)

		return self.file:read(bytes)
	end

	function CONTEXT:SetPosition(pos)
		self.file:seek("set", pos)
	end

	function CONTEXT:GetPosition()
		return self.file:seek("cur")
	end

	function CONTEXT:OnRemove()
		if self.file ~= nil then
			self.file:close()
			self.file = nil
		end
	end
end

function CONTEXT:GetSize()
	return self.attributes.size
end

function CONTEXT:GetLastModified()
	return self.attributes.last_modified
end

function CONTEXT:GetLastAccessed()
	return self.attributes.last_accessed
end

function CONTEXT:Flush()
	--self.file:flush()
end

vfs.RegisterFileSystem(CONTEXT) end)( vfs)

for _, context in ipairs(vfs.GetFileSystems()) do
	if context.VFSOpened then
		context:VFSOpened()
	end
end

return vfs
 end)()

vfs.Mount("os:" .. e.USERDATA_FOLDER, "os:data") -- mount "ROOT/data/users/*username*/" to "/data/"
vfs.MountAddon("os:" .. e.CORE_FOLDER) -- mount "ROOT/"..e.INTERNAL_ADDON_NAME to "/"
vfs.GetAddonInfo(e.INTERNAL_ADDON_NAME).dependencies = {e.INTERNAL_ADDON_NAME} -- prevent init.lua from running later on again
vfs.GetAddonInfo(e.INTERNAL_ADDON_NAME).startup = nil -- prevent init.lua from running later on again

vfs.AddModuleDirectory("lua/modules/")

_G.runfile = vfs.RunFile
_G.R = vfs.GetAbsolutePath -- a nice global for loading resources externally from current dir

-- libraries
crypto = (function(...) local crypto = _G.crypto or {}

do
	-- https://github.com/lancelijade/qqwry.lua/blob/master/crc32.lua#L133

	local CRC32 = {
		0x00000000, 0x77073096, 0xee0e612c, 0x990951ba,
		0x076dc419, 0x706af48f, 0xe963a535, 0x9e6495a3,
		0x0edb8832, 0x79dcb8a4, 0xe0d5e91e, 0x97d2d988,
		0x09b64c2b, 0x7eb17cbd, 0xe7b82d07, 0x90bf1d91,
		0x1db71064, 0x6ab020f2, 0xf3b97148, 0x84be41de,
		0x1adad47d, 0x6ddde4eb, 0xf4d4b551, 0x83d385c7,
		0x136c9856, 0x646ba8c0, 0xfd62f97a, 0x8a65c9ec,
		0x14015c4f, 0x63066cd9, 0xfa0f3d63, 0x8d080df5,
		0x3b6e20c8, 0x4c69105e, 0xd56041e4, 0xa2677172,
		0x3c03e4d1, 0x4b04d447, 0xd20d85fd, 0xa50ab56b,
		0x35b5a8fa, 0x42b2986c, 0xdbbbc9d6, 0xacbcf940,
		0x32d86ce3, 0x45df5c75, 0xdcd60dcf, 0xabd13d59,
		0x26d930ac, 0x51de003a, 0xc8d75180, 0xbfd06116,
		0x21b4f4b5, 0x56b3c423, 0xcfba9599, 0xb8bda50f,
		0x2802b89e, 0x5f058808, 0xc60cd9b2, 0xb10be924,
		0x2f6f7c87, 0x58684c11, 0xc1611dab, 0xb6662d3d,
		0x76dc4190, 0x01db7106, 0x98d220bc, 0xefd5102a,
		0x71b18589, 0x06b6b51f, 0x9fbfe4a5, 0xe8b8d433,
		0x7807c9a2, 0x0f00f934, 0x9609a88e, 0xe10e9818,
		0x7f6a0dbb, 0x086d3d2d, 0x91646c97, 0xe6635c01,
		0x6b6b51f4, 0x1c6c6162, 0x856530d8, 0xf262004e,
		0x6c0695ed, 0x1b01a57b, 0x8208f4c1, 0xf50fc457,
		0x65b0d9c6, 0x12b7e950, 0x8bbeb8ea, 0xfcb9887c,
		0x62dd1ddf, 0x15da2d49, 0x8cd37cf3, 0xfbd44c65,
		0x4db26158, 0x3ab551ce, 0xa3bc0074, 0xd4bb30e2,
		0x4adfa541, 0x3dd895d7, 0xa4d1c46d, 0xd3d6f4fb,
		0x4369e96a, 0x346ed9fc, 0xad678846, 0xda60b8d0,
		0x44042d73, 0x33031de5, 0xaa0a4c5f, 0xdd0d7cc9,
		0x5005713c, 0x270241aa, 0xbe0b1010, 0xc90c2086,
		0x5768b525, 0x206f85b3, 0xb966d409, 0xce61e49f,
		0x5edef90e, 0x29d9c998, 0xb0d09822, 0xc7d7a8b4,
		0x59b33d17, 0x2eb40d81, 0xb7bd5c3b, 0xc0ba6cad,
		0xedb88320, 0x9abfb3b6, 0x03b6e20c, 0x74b1d29a,
		0xead54739, 0x9dd277af, 0x04db2615, 0x73dc1683,
		0xe3630b12, 0x94643b84, 0x0d6d6a3e, 0x7a6a5aa8,
		0xe40ecf0b, 0x9309ff9d, 0x0a00ae27, 0x7d079eb1,
		0xf00f9344, 0x8708a3d2, 0x1e01f268, 0x6906c2fe,
		0xf762575d, 0x806567cb, 0x196c3671, 0x6e6b06e7,
		0xfed41b76, 0x89d32be0, 0x10da7a5a, 0x67dd4acc,
		0xf9b9df6f, 0x8ebeeff9, 0x17b7be43, 0x60b08ed5,
		0xd6d6a3e8, 0xa1d1937e, 0x38d8c2c4, 0x4fdff252,
		0xd1bb67f1, 0xa6bc5767, 0x3fb506dd, 0x48b2364b,
		0xd80d2bda, 0xaf0a1b4c, 0x36034af6, 0x41047a60,
		0xdf60efc3, 0xa867df55, 0x316e8eef, 0x4669be79,
		0xcb61b38c, 0xbc66831a, 0x256fd2a0, 0x5268e236,
		0xcc0c7795, 0xbb0b4703, 0x220216b9, 0x5505262f,
		0xc5ba3bbe, 0xb2bd0b28, 0x2bb45a92, 0x5cb36a04,
		0xc2d7ffa7, 0xb5d0cf31, 0x2cd99e8b, 0x5bdeae1d,
		0x9b64c2b0, 0xec63f226, 0x756aa39c, 0x026d930a,
		0x9c0906a9, 0xeb0e363f, 0x72076785, 0x05005713,
		0x95bf4a82, 0xe2b87a14, 0x7bb12bae, 0x0cb61b38,
		0x92d28e9b, 0xe5d5be0d, 0x7cdcefb7, 0x0bdbdf21,
		0x86d3d2d4, 0xf1d4e242, 0x68ddb3f8, 0x1fda836e,
		0x81be16cd, 0xf6b9265b, 0x6fb077e1, 0x18b74777,
		0x88085ae6, 0xff0f6a70, 0x66063bca, 0x11010b5c,
		0x8f659eff, 0xf862ae69, 0x616bffd3, 0x166ccf45,
		0xa00ae278, 0xd70dd2ee, 0x4e048354, 0x3903b3c2,
		0xa7672661, 0xd06016f7, 0x4969474d, 0x3e6e77db,
		0xaed16a4a, 0xd9d65adc, 0x40df0b66, 0x37d83bf0,
		0xa9bcae53, 0xdebb9ec5, 0x47b2cf7f, 0x30b5ffe9,
		0xbdbdf21c, 0xcabac28a, 0x53b39330, 0x24b4a3a6,
		0xbad03605, 0xcdd70693, 0x54de5729, 0x23d967bf,
		0xb3667a2e, 0xc4614ab8, 0x5d681b02, 0x2a6f2b94,
		0xb40bbe37, 0xc30c8ea1, 0x5a05df1b, 0x2d02ef8d
	}

	local xor = bit.bxor
	local lshift = bit.lshift
	local rshift = bit.rshift
	local band = bit.band

	local cache = table.weak()

	function crypto.CRC32(val)
		if cache[val] then
			return cache[val]
		end
		local str = tostring(val)
		local count = string.len(str)
		local crc = 2 ^ 32 - 1
		local i = 1

		while count > 0 do
			local byte = string.byte(str, i)
			crc = xor(rshift(crc, 8), CRC32[xor(band(crc, 0xFF), byte) + 1])
			i = i + 1
			count = count - 1
		end
		crc = xor(crc, 0xFFFFFFFF)
		-- dirty hack for bitop return number < 0
		if crc < 0 then crc = crc + 2 ^ 32 end

		cache[val] = tostring(crc)

		return cache[val]
	end
end

-- Lua 5.1+ base64 v3.0 (c) 2009 by Alex Kloss <alexthkloss@web.de>
-- licensed under the terms of the LGPL2

-- character table string
local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'

-- encoding
function crypto.Base64Encode(data)
	return ((data:gsub('.', function(x)
		local r,b='',x:byte()
		for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
		return r;
	end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
		if (#x < 6) then return '' end
		local c=0
		for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
		return b:sub(c+1,c+1)
	end)..({ '', '==', '=' })[#data%3+1])
end

-- decoding
function crypto.Base64Decode(data)
	data = string.gsub(data, '[^'..b..'=]', '')
	return (data:gsub('.', function(x)
		if (x == '=') then return '' end
		local r,f='',(b:find(x)-1)
		for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and '1' or '0') end
		return r;
	end):gsub('%d%d%d?%d?%d?%d?%d?%d?', function(x)
		if (#x ~= 8) then return '' end
		local c=0
		for i=1,8 do c=c+(x:sub(i,i)=='1' and 2^(8-i) or 0) end
		return string.char(c)
	end))
end

return crypto end)() -- base64 and other hash functions
serializer = (function(...) local serializer = _G.serializer or {}

serializer.libraries = {}

function serializer.AddLibrary(id, encode, decode, lib)
	serializer.libraries[id] = {encode = encode, decode = decode, lib = lib}
end

function serializer.GetAvailible()
	return serializer.libraries
end

function serializer.GetLibrary(name)
	local lib = serializer.libraries[name] and serializer.libraries[name].lib

	if type(lib) == "string" then
		lib = require(lib)
		serializer.libraries[name].lib = lib
	end

	return lib
end

function serializer.Encode(lib, ...)
	lib = lib or "luadata"

	local data = serializer.libraries[lib]

	if not data then
		error("serializer " .. lib .. " not found", 2)
	end

	if data.encode then
		return data.encode(serializer.GetLibrary(lib), ...)
	end

	error("encoding not supported", 2)
end

function serializer.Decode(lib, ...)
	lib = lib or "luadata"

	local data = serializer.libraries[lib]

	if not data then
		error("serializer " .. lib .. " not found", 2)
	end

	if data.decode then
		return data.decode(serializer.GetLibrary(lib), ...)
	end

	error("decoding not supported", 2)
end

do -- vfs extension
	function serializer.WriteFile(lib, path, ...)
		return vfs.Write(path, serializer.Encode(lib, ...))
	end

	function serializer.ReadFile(lib, path, ...)
		local str = vfs.Read(path)
		if str then
			return serializer.Decode(lib, str)
		end
		return false, "no such file"
	end

	function serializer.SetKeyValueInFile(lib, path, key, value)
		local tbl = serializer.ReadFile(lib, path) or {}
		tbl[key] = value
		serializer.WriteFile(lib, path, tbl)
	end

	function serializer.GetKeyFromFile(lib, path, key, def)
		local tbl = serializer.ReadFile(lib, path)

		if tbl then
			local val = serializer.ReadFile(lib, path)[key]

			if val == nil then
				return def
			end

			return val
		end

		return def
	end

	function serializer.AppendToFile(lib, path, value)
		local tbl = serializer.ReadFile(lib, path) or {}
		table.insert(tbl, value)
		serializer.WriteFile(lib, path, tbl)
	end
end



return serializer end)() -- for serializing lua data in different formats
system = (function(...) local system = _G.system or {}

if PLATFORM == "gmod" then
	(function(...) local system = ... or _G.system
local ffi = require("ffi")

function system.OpenURL(url)
	gmod.gui.OpenURL(url)
end

function system.Sleep(ms)

end

local SysTime = gmod.SysTime
function system.GetTime()
	return SysTime()
end

function system.SetConsoleTitleRaw(str)

end

function system.FindFirstTextEditor(os_execute, with_args)

end

function system.SetSharedLibraryPath(path)

end

function system.GetSharedLibraryPath()
	return ""
end

function system._OSCommandExists(cmd)
	return false
end end)( system)
elseif PLATFORM == "unix" then
	(function(...) local system = ... or _G.system
local ffi = require("ffi")

do
	local attempts = {
		"sensible-browser",
		"xdg-open",
		"kde-open",
		"gnome-open",
	}

	function system.OpenURL(url)
		for _, cmd in ipairs(attempts) do
			if os.execute(cmd .. " " .. url) then
				return
			end
		end

		wlog("don't know how to open an url (tried: %s)", table.concat(attempts, ", "), 2)
	end
end

do
	ffi.cdef("void usleep(unsigned int ns);")
	function system.Sleep(ms)
		ffi.C.usleep(ms*1000)
	end
end

do
	ffi.cdef([[
		struct timespec {
			long int tv_sec;
			long tv_nsec;
		};
		int clock_gettime(int clock_id, struct timespec *tp);
	]])

	local ts = ffi.new("struct timespec")
	local enum = 1
	local func = ffi.C.clock_gettime

	function system.GetTime()
		func(enum, ts)
		return tonumber(ts.tv_sec) + tonumber(ts.tv_nsec) * 0.000000001
	end
end

do
	if CURSES then
		local iowrite = _OLD_G.io.write

		function system.SetConsoleTitleRaw(str)
			return iowrite and iowrite('\27]0;', str, '\7') or nil
		end
	elseif CLI then
		local last
		function system.SetConsoleTitleRaw(str)
			if str ~= last then
				for i, v in ipairs(str:split("|")) do
					local s = v:trim()
					if s ~= "" then
						logn(s)
					end
				end
				last = str
			end
		end
	else
		function system.SetConsoleTitleRaw(str)

		end
	end
end

do
	local text_editors = {
		{
			name = "atom",
			args = "%PATH%:%LINE%",
		},
		{
			name = "scite",
			args = "%PATH% -goto:%LINE%",
		},
		{
			name = "emacs",
			args = "+%LINE% %PATH%",
			terminal = true,
		},
		{
			name = "vim",
			args = "%PATH%:%LINE%",
			terminal = true,
		},
		{
			name = "kate",
			args = "-l %LINE% %PATH%",
		},
		{
			name = "gedit",
			args = "+%LINE% %PATH%",
		},
		{
			name = "nano",
			args = "+%LINE% %PATH%",
			terminal = true,
		},
	}

	function system.FindFirstTextEditor(os_execute, with_args)
		for _, v in pairs(text_editors) do

			if io.popen("command -v " .. v.name):read() then
				local cmd = v.name

				if v.terminal then
					cmd = "x-terminal-emulator -e " .. cmd
				end

				if with_args then
					cmd = cmd .. " " .. v.args

				end

				if os_execute then
					cmd = cmd .. " &"
				end

				return cmd
			end
		end
	end
end

do
	function system.SetSharedLibraryPath(path)
		os.setenv("LD_LIBRARY_PATH", path)
	end

	function system.GetSharedLibraryPath()
		return os.getenv("LD_LIBRARY_PATH") or ""
	end
end

function system._OSCommandExists(cmd)
	if io.popen("command -v " .. cmd):read("*all") ~= "" then
		return true
	end
end end)( system)
elseif PLATFORM == "windows" then
	(function(...) local system = ... or _G.system
local ffi = require("ffi")

function system.OpenURL(url)
	os.execute(([[explorer "%s"]]):format(url))
end

ffi.cdef("void Sleep(uint32_t);")
function system.Sleep(ms)
	ffi.C.Sleep(ms)
end

do
	require("winapi.time")

	local winapi = require("winapi")

	local freq = tonumber(winapi.QueryPerformanceFrequency().QuadPart)
	local start_time = winapi.QueryPerformanceCounter()

	function system.GetTime()
		local time = winapi.QueryPerformanceCounter()

		time.QuadPart = time.QuadPart - start_time.QuadPart
		return tonumber(time.QuadPart) / freq
	end
end

do
	ffi.cdef("int SetConsoleTitleA(const char* blah);")
	function system.SetConsoleTitleRaw(str)
		return ffi.C.SetConsoleTitleA(str)
	end
end

do
	local text_editors = {
		["ZeroBrane.Studio"] = "%PATH%:%LINE%",
		["notepad++.exe"] = "\"%PATH%\" -n%LINE%",
		["notepad2.exe"] = "/g %LINE% %PATH%",
		["sublime_text.exe"] = "%PATH%:%LINE%",
		["notepad.exe"] = "/A %PATH%",
	}

	function system.FindFirstTextEditor(os_execute, with_args)
		local app = system.GetRegistryValue("ClassesRoot/.lua/default")
		if app then
			local path = system.GetRegistryValue("ClassesRoot/" .. app .. "/shell/edit/command/default")
			if path then
				path = path and path:match("(.-) %%") or path:match("(.-) \"%%")
				if path then
					if os_execute then
						path = "start \"\" " .. path
					end

					if with_args and text_editors[app] then
						path = path .. " " .. text_editors[app]
					end

					return path
				end
			end
		end
	end
end

do
	ffi.cdef[[
		BOOL SetDllDirectoryA(LPCTSTR lpPathName);
		DWORD GetDllDirectoryA(DWORD nBufferLength, LPTSTR lpBuffer);
	]]

	function system.SetSharedLibraryPath(path)
		ffi.C.SetDllDirectoryA(path or "")
	end

	local str = ffi.new("char[1024]")

	function system.GetSharedLibraryPath()
		ffi.C.GetDllDirectoryA(1024, str)

		return ffi.string(str)
	end
end

do
	ffi.cdef([[
		typedef unsigned goluwa_hkey;
		LONG RegGetValueA(goluwa_hkey, LPCTSTR, LPCTSTR, DWORD, LPDWORD, PVOID, LPDWORD);
	]])

	local advapi = ffi.load("advapi32")

	local ERROR_SUCCESS = 0
	local HKEY_CLASSES_ROOT  = 0x80000000
	local HKEY_CURRENT_USER = 0x80000001
	local HKEY_LOCAL_MACHINE = 0x80000002
	local HKEY_CURRENT_CONFIG = 0x80000005

	local RRF_RT_REG_SZ = 0x00000002

	local translate = {
		HKEY_CLASSES_ROOT  = 0x80000000,
		HKEY_CURRENT_USER = 0x80000001,
		HKEY_LOCAL_MACHINE = 0x80000002,
		HKEY_CURRENT_CONFIG = 0x80000005,

		ClassesRoot  = 0x80000000,
		CurrentUser = 0x80000001,
		LocalMachine = 0x80000002,
		CurrentConfig = 0x80000005,
	}

	function system.GetRegistryValue(str)
		local where, key1, key2 = str:match("(.-)/(.+)/(.*)")

		if where then
			where, key1 = str:match("(.-)/(.+)/")
		end

		where = translate[where] or where
		key1 = key1:gsub("/", "\\")
		key2 = key2 or ""

		if key2 == "default" then key2 = nil end

		local value = ffi.new("char[4096]")
		local value_size = ffi.new("unsigned[1]")
		value_size[0] = 4096

		local err = advapi.RegGetValueA(where, key1, key2, RRF_RT_REG_SZ, nil, value, value_size)

		if err ~= ERROR_SUCCESS then
			return
		end

		return ffi.string(value)
	end
end

function system._OSCommandExists(cmd)
	return false, "NYI"
end end)( system)
end

function system.ForceMainLoop()
	system.force_main_loop = true
end

function system.GetWorkingDirectory()

	if CLI then
		local dir = os.getenv("GOLUWA_WORKING_DIRECTORY")
		if dir then
			return vfs.FixPathSlashes("os:" .. dir .. "/")
		end
	end

	return "os:" .. e.USERDATA_FOLDER
end

function system.OSCommandExists(...)
	if select("#", ...) > 1 then
		for _, cmd in ipairs({...}) do
			local ok, err = system.OSCommandExists(cmd)
			if not ok then
				return false, err
			end
		end
	end

	return system._OSCommandExists(...)
end

function system.GetLibraryDependencies(path)
	if system.OSCommandExists("ldd", "otool") then
		local cmd = system.OSCommandExists("ldd") and "ldd" or "otool -L"
		local f = io.popen(cmd .. " " .. path .. " 2>&1")
		if f then
			local str = f:read("*all")
			f:close()

			str = str:gsub("(.-\n)", function(line) if not line:find("not found") then return "" end end)

			return str
		end
	end
	return "unable to find library dependencies for " .. path .. " because ldd is not an os command"
end

do -- console title
	local titles = {}
	local titlesi = {}
	local str = ""
	local last_title

	local lasttbl = {}

	function system.SetConsoleTitle(title, id)
		local time = system.GetElapsedTime()

		if not lasttbl[id] or lasttbl[id] < time then
			if id then
				if title then
					if not titles[id] then
						titles[id] = {title = title}
						table.insert(titlesi, titles[id])
					end

					titles[id].title = title
				else
					for _, v in ipairs(titlesi) do
						if v == titles[id] then
							table.remove(titlesi, i)
							break
						end
					end
				end

				str = "| "
				for _, v in ipairs(titlesi) do
					str = str ..  v.title .. " | "
				end
				if str ~= last_title then
					system.SetConsoleTitleRaw(str)
				end
			else
				str = title
				if str ~= last_title then
					system.SetConsoleTitleRaw(title)
				end
			end
			last_title = str
			lasttbl[id] = system.GetElapsedTime() + 0.05
		end
	end

	function system.GetConsoleTitle()
		return str
	end
end

do
	system.run = true

	function system.ShutDown(code)
		code = code or 0
		if not CLI then
			logn("shutting down with code ", code)
		end
		system.run = code
	end

	local old = os.exit

	function os.exit(code)
		wlog("os.exit() called with code %i", code or 0, 2)
		--system.ShutDown(code)
	end

	function os.realexit(code)
		old(code)
	end
end

local function not_implemented() debug.trace() logn("this function is not yet implemented!") end

do -- frame time
	local frame_time = 0.1

	function system.GetFrameTime()
		return frame_time
	end

	-- used internally in main_loop.lua
	function system.SetFrameTime(dt)
		frame_time = dt
	end
end

do -- frame time
	local frame_time = 0.1

	function system.GetInternalFrameTime()
		return frame_time
	end

	-- used internally in main_loop.lua
	function system.SetInternalFrameTime(dt)
		frame_time = dt
	end
end

do -- frame number
	local frame_number = 0

	function system.GetFrameNumber()
		return frame_number
	end

	-- used internally in main_loop.lua
	function system.SetFrameNumber(num)
		frame_number = num
	end
end

do -- elapsed time (avanved from frame time)
	local elapsed_time = 0

	function system.GetElapsedTime()
		return elapsed_time
	end

	-- used internally in main_loop.lua
	function system.SetElapsedTime(num)
		elapsed_time = num
	end
end

do -- server time (synchronized across client and server)
	local server_time = 0

	function system.SetServerTime(time)
		server_time = time
	end

	function system.GetServerTime()
		return server_time
	end
end

do -- arg is made from luajit.exe
	local arg = _G.arg or {}
	_G.arg = nil

	arg[0] = nil
	arg[-1] = nil
	table.remove(arg, 1)

	function system.GetStartupArguments()
		return arg
	end
end

do
	-- this should be used for xpcall
	local suppress = false
	function system.OnError(msg, ...)
		logsection("lua error", true)
		if msg then logn(msg) end
		msg = msg or "no error"
		if suppress then logn("error in system.OnError: ", msg, ...) logn(debug.traceback())  return end
		suppress = true

		if event.Call("LuaError", msg) == false then return end

		if msg:find("stack overflow") then
			logn(msg)
			table.print(debug.getinfo(3))
		elseif msg:find("\n") then
			-- if the message contains a newline it's
			-- probably not a good idea to do anything fancy
			logn(msg)
		else
			logn("STACK TRACE:")
			logn("{")

			local data = {}

			for level = 3, 100 do
				local info = debug.getinfo(level)
				if info then
					info.source = debug.getprettysource(level)

					local args = {}

					for arg = 1, info.nparams do
						local key, val = debug.getlocal(level, arg)
						if type(val) == "table" then
							val = tostring(val)
						else
							val = serializer.GetLibrary("luadata").ToString(val)
							if val and #val > 200 then
								val = val:sub(0, 200) .. "...."
							end
						end
						table.insert(args, ("%s = %s"):format(key, val))
					end

					info.arg_line = table.concat(args, ", ")

					info.name = info.name or "unknown"

					table.insert(data, info)
				else
					break
				end
			end

			local function resize_field(tbl, field)
				local length = 0

				for _, info in pairs(tbl) do
					local str = tostring(info[field])
					if str then
						if #str > length then
							length = #str
						end
						info[field] = str
					end
				end

				for _, info in pairs(tbl) do
					local str = info[field]
					if str then
						local diff = length - #str:split("\n")[1]

						if diff > 0 then
							info[field] = str .. (" "):rep(diff)
						end
					end
				end
			end

			table.insert(data, {currentline = "LINE:", source = "SOURCE:", name = "FUNCTION:", arg_line = " ARGUMENTS "})

			resize_field(data, "currentline")
			resize_field(data, "source")
			resize_field(data, "name")

			for _, info in npairs(data) do
				logf("  %s   %s   %s  (%s)\n", info.currentline, info.source, info.name, info.arg_line)
			end

			table.clear(data)

			logn("}")
			logn("LOCALS: ")
			logn("{")
			for _, param in pairs(debug.getparamsx(4)) do
				--if not param.key:find("(",nil,true) then
					local val

					if type(param.val) == "table" then
						val = tostring(param.val)
					elseif type(param.val) == "string" then
						val = param.val:sub(0, 10)

						if val ~= param.val then
							val = val .. " .. " .. utility.FormatFileSize(#param.val)
						end
					else
						val = serializer.GetLibrary("luadata").ToString(param.val)
					end

					table.insert(data, {key = param.key, value = val})
				--end
			end

			table.insert(data, {key = "KEY:", value = "VALUE:"})

			resize_field(data, "key")
			resize_field(data, "value")

			for _, info in npairs(data) do
				logf("  %s   %s\n", info.key, info.value)
			end
			logn("}")

			logn("ERROR:")
			logn("{")
			local source, _msg = msg:match("(.+): (.+)")

			if source then
				source = source:trim()
				local info = debug.getinfo(2)

				logn("  ", info.currentline, " ", info.source)
				logn("  ", _msg:trim())
			else
				logn(msg)
			end

			logn("}")
			logn("")
		end

		logsection("lua error", false)
		suppress = false
	end

	function system.pcall(func, ...)
		return xpcall(func, system.OnError, ...)
	end
end

return system
 end)() -- os and luajit related functions like creating windows or changing jit options
event = (function(...) local event = _G.event or {}

event.active = event.active or {}
event.destroy_tag = {}

e.EVENT_DESTROY = event.destroy_tag

local function sort_events()
	for key, tbl in pairs(event.active) do
		local new = {}
		for _, v in pairs(tbl) do table.insert(new, v) end
		table.sort(new, function(a, b) return a.priority > b.priority end)
		event.active[key] = new
	end
end

function event.AddListener(event_type, id, callback, config)
	if type(event_type) == "table" then
		config = event_type
	end

	if not callback and type(id) == "function" then
		callback = id
		id = nil
	end

	config = config or {}

	config.event_type = config.event_type or event_type
	config.id = config.id or id
	config.callback = config.callback or callback
	config.priority = config.priority or 0

	-- useful for initialize events
	if config.id == nil then
		config.id = {}
		config.remove_after_one_call = true
	end

	config.print_str = config.event_type .. "->" .. tostring(config.id)

	event.RemoveListener(config.event_type, config.id)

	event.active[config.event_type] = event.active[config.event_type] or {}

	table.insert(event.active[config.event_type], config)

	sort_events()

	if event_type ~= "EventAdded" then
		event.Call("EventAdded", config)
	end
end

event.fix_indices = {}

function event.RemoveListener(event_type, id)

	if type(event_type) == "table" then
		id = id or event_type.id
		event_type = event_type or event_type.event_type
	end

	if id ~= nil and event.active[event_type] then

		if event_type ~= "EventRemoved" then
			event.Call("EventRemoved", event.active[event_type])
		end

		for index, val in pairs(event.active[event_type]) do
			if id == val.id then
				event.active[event_type][index] = nil

				event.fix_indices[event_type] = true

				break
			end
		end
	else
		--logn(("Tried to remove non existing event '%s:%s'"):format(event, tostring(unique)))
	end
end

function event.Call(event_type, a_, b_, c_, d_, e_)
	local status, a,b,c,d,e

	if event.active[event_type] then
		for index = 1, #event.active[event_type] do
			local data = event.active[event_type][index]
			if not data then break end

			if data.self_arg then
				if data.self_arg:IsValid() then
					if data.self_arg_with_callback then
						status, a,b,c,d,e = xpcall(data.callback, data.on_error or system.OnError, a_, b_, c_, d_, e_)
					else
						status, a,b,c,d,e = xpcall(data.callback, data.on_error or system.OnError, data.self_arg, a_, b_, c_, d_, e_)
					end
				else
					event.RemoveListener(event_type, data.id)

					event.active[event_type][index] = nil
					sort_events()
					llog("[%q][%q] removed because self is invalid", event_type, data.unique)
					return
				end
			else
				status, a,b,c,d,e = xpcall(data.callback, data.on_error or system.OnError, a_, b_, c_, d_, e_)
			end

			if a == event.destroy_tag or data.remove_after_one_call then
				event.RemoveListener(event_type, data.id)
			else
				if status == false then
					if type(data.on_error) == "function" then
						data.on_error(a, event_type, data.id)
					else
						event.RemoveListener(event_type, data.id)
						llog("[%q][%q] removed", event_type, data.id)
					end
				end

				if a ~= nil then
					return a,b,c,d,e
				end
			end
		end
	end

	if event.fix_indices[event_type] then
		table.fixindices(event.active[event_type])
		event.fix_indices[event_type] =  nil

		sort_events()
	end
end

do -- helpers
	function event.CreateRealm(config)
		if type(config) == "string" then
			config = {id = config}
		end
		return setmetatable({}, {
			__index = function(_, key, val)
				for i, data in ipairs(event.active[key]) do
					if data.id == config.id then
						return config.callback
					end
				end
			end,
			__newindex = function(_, key, val)
				if type(val) == "function" then
					config = table.copy(config)
					config.event_type = key
					config.callback = val
					event.AddListener(config)
				elseif val == nil then
					config = table.copy(config)
					config.event_type = key
					event.RemoveListener(config)
				end
			end,
		})
	end
end

return event
 end)() -- event handler
utf8 = (function(...) local utf8 = _G.utf8 or {}

function utf8.midsplit(str)
	local half = math.round(str:ulength()/2+1)
	return str:usub(1, half-1), str:usub(half)
end

local math_floor = math.floor

function utf8.byte(char, offset)
	if char == "" then return -1 end

	offset = offset or 1

	local byte = char:byte(offset)

	if byte and byte >= 128 then
		if byte >= 240 then
			if #char < 4 then return -1 end
			byte = (byte % 8) * 262144
			byte = byte + (char:byte(offset + 1) % 64) * 4096
			byte = byte + (char:byte(offset + 2) % 64) * 64
			byte = byte + (char:byte(offset + 3) % 64)
		elseif byte >= 224 then
			if #char < 3 then return -1 end
			byte = (byte % 16) * 4096
			byte = byte + (char:byte(offset + 1) % 64) * 64
			byte = byte + (char:byte(offset + 2) % 64)
		elseif byte >= 192 then
			if #char < 2 then return -1 end
			byte = (byte % 32) * 64
			byte = byte + (char:byte(offset + 1) % 64)
		else
			byte = -1
		end
	end

	return byte
end

function utf8.bytelength(char, offset)
	local byte = char:byte(offset or 1)
	local length = 1

	if byte and byte >= 128 then
		if byte >= 240 then
			length = 4
		elseif byte >= 224 then
			length = 3
		elseif byte >= 192 then
			length = 2
		end
	end

	return length
end

function utf8.char(byte)
	local utf8 = ""

	if byte <= 127 then
		utf8 = string.char(byte)
	elseif byte < 2048 then
		utf8 = ("%c%c"):format(
			192 + math_floor(byte / 64),
			128 + (byte % 64)
		)
	elseif byte < 65536 then
		utf8 = ("%c%c%c"):format(
			224 + math_floor(byte / 4096),
			128 + (math_floor(byte / 64) % 64),
			128 + (byte % 64)
		)
	elseif byte < 2097152 then
		utf8 = ("%c%c%c%c"):format(
			240 + math_floor(byte / 262144),
			128 + (math_floor(byte / 4096) % 64),
			128 + (math_floor(byte / 64) % 64),
			128 + (byte % 64)
		)
	end

	return utf8
end

function utf8.sub(str, i, j)
	j = j or -1

	local length = 0

	-- only set l if i or j is negative
	local l = (i >= 0 and j >= 0) or utf8.length(str)
	local start_char = (i >= 0) and i or l + i + 1
	local end_char   = (j >= 0) and j or l + j + 1

	-- can't have start before end!
	if start_char > end_char then
		return ""
	end

	local pos = 1
	local bytes = #str
	local start_byte = 1
	local end_byte = bytes

	for _ = 1, bytes do
		length = length + 1

		if length == start_char then
			start_byte = pos
		end

		pos = pos + utf8.bytelength(str, pos)

		if length == end_char then
			end_byte = pos - 1
			break
		end
	end

	return str:sub(start_byte, end_byte)
end

local function utf8replace(str, mapping)
	local out = {}
	for i, char in ipairs(utf8.totable(str)) do
		table.insert(out, mapping[char] or char)
	end
	return table.concat(out)
end

local upper, lower, translate = (function(...) return{a="A",b="B",c="C",d="D",e="E",f="F",g="G",h="H",i="I",j="J",k="K",l="L",m="M",n="N",o="O",p="P",q="Q",r="R",s="S",t="T",u="U",v="V",w="W",x="X",y="Y",z="Z",µ="Μ",à="À",á="Á",â="Â",ã="Ã",ä="Ä",å="Å",æ="Æ",ç="Ç",è="È",é="É",ê="Ê",ë="Ë",ì="Ì",í="Í",î="Î",ï="Ï",ð="Ð",ñ="Ñ",ò="Ò",ó="Ó",ô="Ô",õ="Õ",ö="Ö",ø="Ø",ù="Ù",ú="Ú",û="Û",ü="Ü",ý="Ý",þ="Þ",ÿ="Ÿ",ā="Ā",ă="Ă",ą="Ą",ć="Ć",ĉ="Ĉ",ċ="Ċ",č="Č",ď="Ď",đ="Đ",ē="Ē",ĕ="Ĕ",ė="Ė",ę="Ę",ě="Ě",ĝ="Ĝ",ğ="Ğ",ġ="Ġ",ģ="Ģ",ĥ="Ĥ",ħ="Ħ",ĩ="Ĩ",ī="Ī",ĭ="Ĭ",į="Į",ı="I",ĳ="Ĳ",ĵ="Ĵ",ķ="Ķ",ĺ="Ĺ",ļ="Ļ",ľ="Ľ",ŀ="Ŀ",ł="Ł",ń="Ń",ņ="Ņ",ň="Ň",ŋ="Ŋ",ō="Ō",ŏ="Ŏ",ő="Ő",œ="Œ",ŕ="Ŕ",ŗ="Ŗ",ř="Ř",ś="Ś",ŝ="Ŝ",ş="Ş",š="Š",ţ="Ţ",ť="Ť",ŧ="Ŧ",ũ="Ũ",ū="Ū",ŭ="Ŭ",ů="Ů",ű="Ű",ų="Ų",ŵ="Ŵ",ŷ="Ŷ",ź="Ź",ż="Ż",ž="Ž",ſ="S",ƀ="Ƀ",ƃ="Ƃ",ƅ="Ƅ",ƈ="Ƈ",ƌ="Ƌ",ƒ="Ƒ",ƕ="Ƕ",ƙ="Ƙ",ƚ="Ƚ",ƞ="Ƞ",ơ="Ơ",ƣ="Ƣ",ƥ="Ƥ",ƨ="Ƨ",ƭ="Ƭ",ư="Ư",ƴ="Ƴ",ƶ="Ƶ",ƹ="Ƹ",ƽ="Ƽ",ƿ="Ƿ",ǅ="Ǆ",ǆ="Ǆ",ǈ="Ǉ",ǉ="Ǉ",ǋ="Ǌ",ǌ="Ǌ",ǎ="Ǎ",ǐ="Ǐ",ǒ="Ǒ",ǔ="Ǔ",ǖ="Ǖ",ǘ="Ǘ",ǚ="Ǚ",ǜ="Ǜ",ǝ="Ǝ",ǟ="Ǟ",ǡ="Ǡ",ǣ="Ǣ",ǥ="Ǥ",ǧ="Ǧ",ǩ="Ǩ",ǫ="Ǫ",ǭ="Ǭ",ǯ="Ǯ",ǲ="Ǳ",ǳ="Ǳ",ǵ="Ǵ",ǹ="Ǹ",ǻ="Ǻ",ǽ="Ǽ",ǿ="Ǿ",ȁ="Ȁ",ȃ="Ȃ",ȅ="Ȅ",ȇ="Ȇ",ȉ="Ȉ",ȋ="Ȋ",ȍ="Ȍ",ȏ="Ȏ",ȑ="Ȑ",ȓ="Ȓ",ȕ="Ȕ",ȗ="Ȗ",ș="Ș",ț="Ț",ȝ="Ȝ",ȟ="Ȟ",ȣ="Ȣ",ȥ="Ȥ",ȧ="Ȧ",ȩ="Ȩ",ȫ="Ȫ",ȭ="Ȭ",ȯ="Ȯ",ȱ="Ȱ",ȳ="Ȳ",ȼ="Ȼ",ɂ="Ɂ",ɇ="Ɇ",ɉ="Ɉ",ɋ="Ɋ",ɍ="Ɍ",ɏ="Ɏ",ɓ="Ɓ",ɔ="Ɔ",ɖ="Ɖ",ɗ="Ɗ",ə="Ə",ɛ="Ɛ",ɠ="Ɠ",ɣ="Ɣ",ɨ="Ɨ",ɩ="Ɩ",ɫ="Ɫ",ɯ="Ɯ",ɲ="Ɲ",ɵ="Ɵ",ɽ="Ɽ",ʀ="Ʀ",ʃ="Ʃ",ʈ="Ʈ",ʉ="Ʉ",ʊ="Ʊ",ʋ="Ʋ",ʌ="Ʌ",ʒ="Ʒ",ͅ="Ι",ͻ="Ͻ",ͼ="Ͼ",ͽ="Ͽ",ά="Ά",έ="Έ",ή="Ή",ί="Ί",α="Α",β="Β",γ="Γ",δ="Δ",ε="Ε",ζ="Ζ",η="Η",θ="Θ",ι="Ι",κ="Κ",λ="Λ",μ="Μ",ν="Ν",ξ="Ξ",ο="Ο",π="Π",ρ="Ρ",ς="Σ",σ="Σ",τ="Τ",υ="Υ",φ="Φ",χ="Χ",ψ="Ψ",ω="Ω",ϊ="Ϊ",ϋ="Ϋ",ό="Ό",ύ="Ύ",ώ="Ώ",ϐ="Β",ϑ="Θ",ϕ="Φ",ϖ="Π",ϙ="Ϙ",ϛ="Ϛ",ϝ="Ϝ",ϟ="Ϟ",ϡ="Ϡ",ϣ="Ϣ",ϥ="Ϥ",ϧ="Ϧ",ϩ="Ϩ",ϫ="Ϫ",ϭ="Ϭ",ϯ="Ϯ",ϰ="Κ",ϱ="Ρ",ϲ="Ϲ",ϵ="Ε",ϸ="Ϸ",ϻ="Ϻ",а="А",б="Б",в="В",г="Г",д="Д",е="Е",ж="Ж",з="З",и="И",й="Й",к="К",л="Л",м="М",н="Н",о="О",п="П",р="Р",с="С",т="Т",у="У",ф="Ф",х="Х",ц="Ц",ч="Ч",ш="Ш",щ="Щ",ъ="Ъ",ы="Ы",ь="Ь",э="Э",ю="Ю",я="Я",ѐ="Ѐ",ё="Ё",ђ="Ђ",ѓ="Ѓ",є="Є",ѕ="Ѕ",і="І",ї="Ї",ј="Ј",љ="Љ",њ="Њ",ћ="Ћ",ќ="Ќ",ѝ="Ѝ",ў="Ў",џ="Џ",ѡ="Ѡ",ѣ="Ѣ",ѥ="Ѥ",ѧ="Ѧ",ѩ="Ѩ",ѫ="Ѫ",ѭ="Ѭ",ѯ="Ѯ",ѱ="Ѱ",ѳ="Ѳ",ѵ="Ѵ",ѷ="Ѷ",ѹ="Ѹ",ѻ="Ѻ",ѽ="Ѽ",ѿ="Ѿ",ҁ="Ҁ",ҋ="Ҋ",ҍ="Ҍ",ҏ="Ҏ",ґ="Ґ",ғ="Ғ",ҕ="Ҕ",җ="Җ",ҙ="Ҙ",қ="Қ",ҝ="Ҝ",ҟ="Ҟ",ҡ="Ҡ",ң="Ң",ҥ="Ҥ",ҧ="Ҧ",ҩ="Ҩ",ҫ="Ҫ",ҭ="Ҭ",ү="Ү",ұ="Ұ",ҳ="Ҳ",ҵ="Ҵ",ҷ="Ҷ",ҹ="Ҹ",һ="Һ",ҽ="Ҽ",ҿ="Ҿ",ӂ="Ӂ",ӄ="Ӄ",ӆ="Ӆ",ӈ="Ӈ",ӊ="Ӊ",ӌ="Ӌ",ӎ="Ӎ",ӏ="Ӏ",ӑ="Ӑ",ӓ="Ӓ",ӕ="Ӕ",ӗ="Ӗ",ә="Ә",ӛ="Ӛ",ӝ="Ӝ",ӟ="Ӟ",ӡ="Ӡ",ӣ="Ӣ",ӥ="Ӥ",ӧ="Ӧ",ө="Ө",ӫ="Ӫ",ӭ="Ӭ",ӯ="Ӯ",ӱ="Ӱ",ӳ="Ӳ",ӵ="Ӵ",ӷ="Ӷ",ӹ="Ӹ",ӻ="Ӻ",ӽ="Ӽ",ӿ="Ӿ",ԁ="Ԁ",ԃ="Ԃ",ԅ="Ԅ",ԇ="Ԇ",ԉ="Ԉ",ԋ="Ԋ",ԍ="Ԍ",ԏ="Ԏ",ԑ="Ԑ",ԓ="Ԓ",ա="Ա",բ="Բ",գ="Գ",դ="Դ",ե="Ե",զ="Զ",է="Է",ը="Ը",թ="Թ",ժ="Ժ",ի="Ի",լ="Լ",խ="Խ",ծ="Ծ",կ="Կ",հ="Հ",ձ="Ձ",ղ="Ղ",ճ="Ճ",մ="Մ",յ="Յ",ն="Ն",շ="Շ",ո="Ո",չ="Չ",պ="Պ",ջ="Ջ",ռ="Ռ",ս="Ս",վ="Վ",տ="Տ",ր="Ր",ց="Ց",ւ="Ւ",փ="Փ",ք="Ք",օ="Օ",ֆ="Ֆ",ᵽ="Ᵽ",ḁ="Ḁ",ḃ="Ḃ",ḅ="Ḅ",ḇ="Ḇ",ḉ="Ḉ",ḋ="Ḋ",ḍ="Ḍ",ḏ="Ḏ",ḑ="Ḑ",ḓ="Ḓ",ḕ="Ḕ",ḗ="Ḗ",ḙ="Ḙ",ḛ="Ḛ",ḝ="Ḝ",ḟ="Ḟ",ḡ="Ḡ",ḣ="Ḣ",ḥ="Ḥ",ḧ="Ḧ",ḩ="Ḩ",ḫ="Ḫ",ḭ="Ḭ",ḯ="Ḯ",ḱ="Ḱ",ḳ="Ḳ",ḵ="Ḵ",ḷ="Ḷ",ḹ="Ḹ",ḻ="Ḻ",ḽ="Ḽ",ḿ="Ḿ",ṁ="Ṁ",ṃ="Ṃ",ṅ="Ṅ",ṇ="Ṇ",ṉ="Ṉ",ṋ="Ṋ",ṍ="Ṍ",ṏ="Ṏ",ṑ="Ṑ",ṓ="Ṓ",ṕ="Ṕ",ṗ="Ṗ",ṙ="Ṙ",ṛ="Ṛ",ṝ="Ṝ",ṟ="Ṟ",ṡ="Ṡ",ṣ="Ṣ",ṥ="Ṥ",ṧ="Ṧ",ṩ="Ṩ",ṫ="Ṫ",ṭ="Ṭ",ṯ="Ṯ",ṱ="Ṱ",ṳ="Ṳ",ṵ="Ṵ",ṷ="Ṷ",ṹ="Ṹ",ṻ="Ṻ",ṽ="Ṽ",ṿ="Ṿ",ẁ="Ẁ",ẃ="Ẃ",ẅ="Ẅ",ẇ="Ẇ",ẉ="Ẉ",ẋ="Ẋ",ẍ="Ẍ",ẏ="Ẏ",ẑ="Ẑ",ẓ="Ẓ",ẕ="Ẕ",ẛ="Ṡ",ạ="Ạ",ả="Ả",ấ="Ấ",ầ="Ầ",ẩ="Ẩ",ẫ="Ẫ",ậ="Ậ",ắ="Ắ",ằ="Ằ",ẳ="Ẳ",ẵ="Ẵ",ặ="Ặ",ẹ="Ẹ",ẻ="Ẻ",ẽ="Ẽ",ế="Ế",ề="Ề",ể="Ể",ễ="Ễ",ệ="Ệ",ỉ="Ỉ",ị="Ị",ọ="Ọ",ỏ="Ỏ",ố="Ố",ồ="Ồ",ổ="Ổ",ỗ="Ỗ",ộ="Ộ",ớ="Ớ",ờ="Ờ",ở="Ở",ỡ="Ỡ",ợ="Ợ",ụ="Ụ",ủ="Ủ",ứ="Ứ",ừ="Ừ",ử="Ử",ữ="Ữ",ự="Ự",ỳ="Ỳ",ỵ="Ỵ",ỷ="Ỷ",ỹ="Ỹ",ἀ="Ἀ",ἁ="Ἁ",ἂ="Ἂ",ἃ="Ἃ",ἄ="Ἄ",ἅ="Ἅ",ἆ="Ἆ",ἇ="Ἇ",ἐ="Ἐ",ἑ="Ἑ",ἒ="Ἒ",ἓ="Ἓ",ἔ="Ἔ",ἕ="Ἕ",ἠ="Ἠ",ἡ="Ἡ",ἢ="Ἢ",ἣ="Ἣ",ἤ="Ἤ",ἥ="Ἥ",ἦ="Ἦ",ἧ="Ἧ",ἰ="Ἰ",ἱ="Ἱ",ἲ="Ἲ",ἳ="Ἳ",ἴ="Ἴ",ἵ="Ἵ",ἶ="Ἶ",ἷ="Ἷ",ὀ="Ὀ",ὁ="Ὁ",ὂ="Ὂ",ὃ="Ὃ",ὄ="Ὄ",ὅ="Ὅ",ὑ="Ὑ",ὓ="Ὓ",ὕ="Ὕ",ὗ="Ὗ",ὠ="Ὠ",ὡ="Ὡ",ὢ="Ὢ",ὣ="Ὣ",ὤ="Ὤ",ὥ="Ὥ",ὦ="Ὦ",ὧ="Ὧ",ὰ="Ὰ",ά="Ά",ὲ="Ὲ",έ="Έ",ὴ="Ὴ",ή="Ή",ὶ="Ὶ",ί="Ί",ὸ="Ὸ",ό="Ό",ὺ="Ὺ",ύ="Ύ",ὼ="Ὼ",ώ="Ώ",ᾀ="ᾈ",ᾁ="ᾉ",ᾂ="ᾊ",ᾃ="ᾋ",ᾄ="ᾌ",ᾅ="ᾍ",ᾆ="ᾎ",ᾇ="ᾏ",ᾐ="ᾘ",ᾑ="ᾙ",ᾒ="ᾚ",ᾓ="ᾛ",ᾔ="ᾜ",ᾕ="ᾝ",ᾖ="ᾞ",ᾗ="ᾟ",ᾠ="ᾨ",ᾡ="ᾩ",ᾢ="ᾪ",ᾣ="ᾫ",ᾤ="ᾬ",ᾥ="ᾭ",ᾦ="ᾮ",ᾧ="ᾯ",ᾰ="Ᾰ",ᾱ="Ᾱ",ᾳ="ᾼ",ι="Ι",ῃ="ῌ",ῐ="Ῐ",ῑ="Ῑ",ῠ="Ῠ",ῡ="Ῡ",ῥ="Ῥ",ῳ="ῼ",ⅎ="Ⅎ",ⅰ="Ⅰ",ⅱ="Ⅱ",ⅲ="Ⅲ",ⅳ="Ⅳ",ⅴ="Ⅴ",ⅵ="Ⅵ",ⅶ="Ⅶ",ⅷ="Ⅷ",ⅸ="Ⅸ",ⅹ="Ⅹ",ⅺ="Ⅺ",ⅻ="Ⅻ",ⅼ="Ⅼ",ⅽ="Ⅽ",ⅾ="Ⅾ",ⅿ="Ⅿ",ↄ="Ↄ",ⓐ="Ⓐ",ⓑ="Ⓑ",ⓒ="Ⓒ",ⓓ="Ⓓ",ⓔ="Ⓔ",ⓕ="Ⓕ",ⓖ="Ⓖ",ⓗ="Ⓗ",ⓘ="Ⓘ",ⓙ="Ⓙ",ⓚ="Ⓚ",ⓛ="Ⓛ",ⓜ="Ⓜ",ⓝ="Ⓝ",ⓞ="Ⓞ",ⓟ="Ⓟ",ⓠ="Ⓠ",ⓡ="Ⓡ",ⓢ="Ⓢ",ⓣ="Ⓣ",ⓤ="Ⓤ",ⓥ="Ⓥ",ⓦ="Ⓦ",ⓧ="Ⓧ",ⓨ="Ⓨ",ⓩ="Ⓩ",ⰰ="Ⰰ",ⰱ="Ⰱ",ⰲ="Ⰲ",ⰳ="Ⰳ",ⰴ="Ⰴ",ⰵ="Ⰵ",ⰶ="Ⰶ",ⰷ="Ⰷ",ⰸ="Ⰸ",ⰹ="Ⰹ",ⰺ="Ⰺ",ⰻ="Ⰻ",ⰼ="Ⰼ",ⰽ="Ⰽ",ⰾ="Ⰾ",ⰿ="Ⰿ",ⱀ="Ⱀ",ⱁ="Ⱁ",ⱂ="Ⱂ",ⱃ="Ⱃ",ⱄ="Ⱄ",ⱅ="Ⱅ",ⱆ="Ⱆ",ⱇ="Ⱇ",ⱈ="Ⱈ",ⱉ="Ⱉ",ⱊ="Ⱊ",ⱋ="Ⱋ",ⱌ="Ⱌ",ⱍ="Ⱍ",ⱎ="Ⱎ",ⱏ="Ⱏ",ⱐ="Ⱐ",ⱑ="Ⱑ",ⱒ="Ⱒ",ⱓ="Ⱓ",ⱔ="Ⱔ",ⱕ="Ⱕ",ⱖ="Ⱖ",ⱗ="Ⱗ",ⱘ="Ⱘ",ⱙ="Ⱙ",ⱚ="Ⱚ",ⱛ="Ⱛ",ⱜ="Ⱜ",ⱝ="Ⱝ",ⱞ="Ⱞ",ⱡ="Ⱡ",ⱥ="Ⱥ",ⱦ="Ⱦ",ⱨ="Ⱨ",ⱪ="Ⱪ",ⱬ="Ⱬ",ⱶ="Ⱶ",ⲁ="Ⲁ",ⲃ="Ⲃ",ⲅ="Ⲅ",ⲇ="Ⲇ",ⲉ="Ⲉ",ⲋ="Ⲋ",ⲍ="Ⲍ",ⲏ="Ⲏ",ⲑ="Ⲑ",ⲓ="Ⲓ",ⲕ="Ⲕ",ⲗ="Ⲗ",ⲙ="Ⲙ",ⲛ="Ⲛ",ⲝ="Ⲝ",ⲟ="Ⲟ",ⲡ="Ⲡ",ⲣ="Ⲣ",ⲥ="Ⲥ",ⲧ="Ⲧ",ⲩ="Ⲩ",ⲫ="Ⲫ",ⲭ="Ⲭ",ⲯ="Ⲯ",ⲱ="Ⲱ",ⲳ="Ⲳ",ⲵ="Ⲵ",ⲷ="Ⲷ",ⲹ="Ⲹ",ⲻ="Ⲻ",ⲽ="Ⲽ",ⲿ="Ⲿ",ⳁ="Ⳁ",ⳃ="Ⳃ",ⳅ="Ⳅ",ⳇ="Ⳇ",ⳉ="Ⳉ",ⳋ="Ⳋ",ⳍ="Ⳍ",ⳏ="Ⳏ",ⳑ="Ⳑ",ⳓ="Ⳓ",ⳕ="Ⳕ",ⳗ="Ⳗ",ⳙ="Ⳙ",ⳛ="Ⳛ",ⳝ="Ⳝ",ⳟ="Ⳟ",ⳡ="Ⳡ",ⳣ="Ⳣ",ⴀ="Ⴀ",ⴁ="Ⴁ",ⴂ="Ⴂ",ⴃ="Ⴃ",ⴄ="Ⴄ",ⴅ="Ⴅ",ⴆ="Ⴆ",ⴇ="Ⴇ",ⴈ="Ⴈ",ⴉ="Ⴉ",ⴊ="Ⴊ",ⴋ="Ⴋ",ⴌ="Ⴌ",ⴍ="Ⴍ",ⴎ="Ⴎ",ⴏ="Ⴏ",ⴐ="Ⴐ",ⴑ="Ⴑ",ⴒ="Ⴒ",ⴓ="Ⴓ",ⴔ="Ⴔ",ⴕ="Ⴕ",ⴖ="Ⴖ",ⴗ="Ⴗ",ⴘ="Ⴘ",ⴙ="Ⴙ",ⴚ="Ⴚ",ⴛ="Ⴛ",ⴜ="Ⴜ",ⴝ="Ⴝ",ⴞ="Ⴞ",ⴟ="Ⴟ",ⴠ="Ⴠ",ⴡ="Ⴡ",ⴢ="Ⴢ",ⴣ="Ⴣ",ⴤ="Ⴤ",ⴥ="Ⴥ",ａ="Ａ",ｂ="Ｂ",ｃ="Ｃ",ｄ="Ｄ",ｅ="Ｅ",ｆ="Ｆ",ｇ="Ｇ",ｈ="Ｈ",ｉ="Ｉ",ｊ="Ｊ",ｋ="Ｋ",ｌ="Ｌ",ｍ="Ｍ",ｎ="Ｎ",ｏ="Ｏ",ｐ="Ｐ",ｑ="Ｑ",ｒ="Ｒ",ｓ="Ｓ",ｔ="Ｔ",ｕ="Ｕ",ｖ="Ｖ",ｗ="Ｗ",ｘ="Ｘ",ｙ="Ｙ",ｚ="Ｚ",𐐨="𐐀",𐐩="𐐁",𐐪="𐐂",𐐫="𐐃",𐐬="𐐄",𐐭="𐐅",𐐮="𐐆",𐐯="𐐇",𐐰="𐐈",𐐱="𐐉",𐐲="𐐊",𐐳="𐐋",𐐴="𐐌",𐐵="𐐍",𐐶="𐐎",𐐷="𐐏",𐐸="𐐐",𐐹="𐐑",𐐺="𐐒",𐐻="𐐓",𐐼="𐐔",𐐽="𐐕",𐐾="𐐖",𐐿="𐐗",𐑀="𐐘",𐑁="𐐙",𐑂="𐐚",𐑃="𐐛",𐑄="𐐜",𐑅="𐐝",𐑆="𐐞",𐑇="𐐟",𐑈="𐐠",𐑉="𐐡",𐑊="𐐢",𐑋="𐐣",𐑌="𐐤",𐑍="𐐥",𐑎="𐐦",𐑏="𐐧",},{A="a",B="b",C="c",D="d",E="e",F="f",G="g",H="h",I="i",J="j",K="k",L="l",M="m",N="n",O="o",P="p",Q="q",R="r",S="s",T="t",U="u",V="v",W="w",X="x",Y="y",Z="z",À="à",Á="á",Â="â",Ã="ã",Ä="ä",Å="å",Æ="æ",Ç="ç",È="è",É="é",Ê="ê",Ë="ë",Ì="ì",Í="í",Î="î",Ï="ï",Ð="ð",Ñ="ñ",Ò="ò",Ó="ó",Ô="ô",Õ="õ",Ö="ö",Ø="ø",Ù="ù",Ú="ú",Û="û",Ü="ü",Ý="ý",Þ="þ",Ā="ā",Ă="ă",Ą="ą",Ć="ć",Ĉ="ĉ",Ċ="ċ",Č="č",Ď="ď",Đ="đ",Ē="ē",Ĕ="ĕ",Ė="ė",Ę="ę",Ě="ě",Ĝ="ĝ",Ğ="ğ",Ġ="ġ",Ģ="ģ",Ĥ="ĥ",Ħ="ħ",Ĩ="ĩ",Ī="ī",Ĭ="ĭ",Į="į",İ="i",Ĳ="ĳ",Ĵ="ĵ",Ķ="ķ",Ĺ="ĺ",Ļ="ļ",Ľ="ľ",Ŀ="ŀ",Ł="ł",Ń="ń",Ņ="ņ",Ň="ň",Ŋ="ŋ",Ō="ō",Ŏ="ŏ",Ő="ő",Œ="œ",Ŕ="ŕ",Ŗ="ŗ",Ř="ř",Ś="ś",Ŝ="ŝ",Ş="ş",Š="š",Ţ="ţ",Ť="ť",Ŧ="ŧ",Ũ="ũ",Ū="ū",Ŭ="ŭ",Ů="ů",Ű="ű",Ų="ų",Ŵ="ŵ",Ŷ="ŷ",Ÿ="ÿ",Ź="ź",Ż="ż",Ž="ž",Ɓ="ɓ",Ƃ="ƃ",Ƅ="ƅ",Ɔ="ɔ",Ƈ="ƈ",Ɖ="ɖ",Ɗ="ɗ",Ƌ="ƌ",Ǝ="ǝ",Ə="ə",Ɛ="ɛ",Ƒ="ƒ",Ɠ="ɠ",Ɣ="ɣ",Ɩ="ɩ",Ɨ="ɨ",Ƙ="ƙ",Ɯ="ɯ",Ɲ="ɲ",Ɵ="ɵ",Ơ="ơ",Ƣ="ƣ",Ƥ="ƥ",Ʀ="ʀ",Ƨ="ƨ",Ʃ="ʃ",Ƭ="ƭ",Ʈ="ʈ",Ư="ư",Ʊ="ʊ",Ʋ="ʋ",Ƴ="ƴ",Ƶ="ƶ",Ʒ="ʒ",Ƹ="ƹ",Ƽ="ƽ",Ǆ="ǆ",ǅ="ǆ",Ǉ="ǉ",ǈ="ǉ",Ǌ="ǌ",ǋ="ǌ",Ǎ="ǎ",Ǐ="ǐ",Ǒ="ǒ",Ǔ="ǔ",Ǖ="ǖ",Ǘ="ǘ",Ǚ="ǚ",Ǜ="ǜ",Ǟ="ǟ",Ǡ="ǡ",Ǣ="ǣ",Ǥ="ǥ",Ǧ="ǧ",Ǩ="ǩ",Ǫ="ǫ",Ǭ="ǭ",Ǯ="ǯ",Ǳ="ǳ",ǲ="ǳ",Ǵ="ǵ",Ƕ="ƕ",Ƿ="ƿ",Ǹ="ǹ",Ǻ="ǻ",Ǽ="ǽ",Ǿ="ǿ",Ȁ="ȁ",Ȃ="ȃ",Ȅ="ȅ",Ȇ="ȇ",Ȉ="ȉ",Ȋ="ȋ",Ȍ="ȍ",Ȏ="ȏ",Ȑ="ȑ",Ȓ="ȓ",Ȕ="ȕ",Ȗ="ȗ",Ș="ș",Ț="ț",Ȝ="ȝ",Ȟ="ȟ",Ƞ="ƞ",Ȣ="ȣ",Ȥ="ȥ",Ȧ="ȧ",Ȩ="ȩ",Ȫ="ȫ",Ȭ="ȭ",Ȯ="ȯ",Ȱ="ȱ",Ȳ="ȳ",Ⱥ="ⱥ",Ȼ="ȼ",Ƚ="ƚ",Ⱦ="ⱦ",Ɂ="ɂ",Ƀ="ƀ",Ʉ="ʉ",Ʌ="ʌ",Ɇ="ɇ",Ɉ="ɉ",Ɋ="ɋ",Ɍ="ɍ",Ɏ="ɏ",Ά="ά",Έ="έ",Ή="ή",Ί="ί",Ό="ό",Ύ="ύ",Ώ="ώ",Α="α",Β="β",Γ="γ",Δ="δ",Ε="ε",Ζ="ζ",Η="η",Θ="θ",Ι="ι",Κ="κ",Λ="λ",Μ="μ",Ν="ν",Ξ="ξ",Ο="ο",Π="π",Ρ="ρ",Σ="σ",Τ="τ",Υ="υ",Φ="φ",Χ="χ",Ψ="ψ",Ω="ω",Ϊ="ϊ",Ϋ="ϋ",Ϙ="ϙ",Ϛ="ϛ",Ϝ="ϝ",Ϟ="ϟ",Ϡ="ϡ",Ϣ="ϣ",Ϥ="ϥ",Ϧ="ϧ",Ϩ="ϩ",Ϫ="ϫ",Ϭ="ϭ",Ϯ="ϯ",ϴ="θ",Ϸ="ϸ",Ϲ="ϲ",Ϻ="ϻ",Ͻ="ͻ",Ͼ="ͼ",Ͽ="ͽ",Ѐ="ѐ",Ё="ё",Ђ="ђ",Ѓ="ѓ",Є="є",Ѕ="ѕ",І="і",Ї="ї",Ј="ј",Љ="љ",Њ="њ",Ћ="ћ",Ќ="ќ",Ѝ="ѝ",Ў="ў",Џ="џ",А="а",Б="б",В="в",Г="г",Д="д",Е="е",Ж="ж",З="з",И="и",Й="й",К="к",Л="л",М="м",Н="н",О="о",П="п",Р="р",С="с",Т="т",У="у",Ф="ф",Х="х",Ц="ц",Ч="ч",Ш="ш",Щ="щ",Ъ="ъ",Ы="ы",Ь="ь",Э="э",Ю="ю",Я="я",Ѡ="ѡ",Ѣ="ѣ",Ѥ="ѥ",Ѧ="ѧ",Ѩ="ѩ",Ѫ="ѫ",Ѭ="ѭ",Ѯ="ѯ",Ѱ="ѱ",Ѳ="ѳ",Ѵ="ѵ",Ѷ="ѷ",Ѹ="ѹ",Ѻ="ѻ",Ѽ="ѽ",Ѿ="ѿ",Ҁ="ҁ",Ҋ="ҋ",Ҍ="ҍ",Ҏ="ҏ",Ґ="ґ",Ғ="ғ",Ҕ="ҕ",Җ="җ",Ҙ="ҙ",Қ="қ",Ҝ="ҝ",Ҟ="ҟ",Ҡ="ҡ",Ң="ң",Ҥ="ҥ",Ҧ="ҧ",Ҩ="ҩ",Ҫ="ҫ",Ҭ="ҭ",Ү="ү",Ұ="ұ",Ҳ="ҳ",Ҵ="ҵ",Ҷ="ҷ",Ҹ="ҹ",Һ="һ",Ҽ="ҽ",Ҿ="ҿ",Ӏ="ӏ",Ӂ="ӂ",Ӄ="ӄ",Ӆ="ӆ",Ӈ="ӈ",Ӊ="ӊ",Ӌ="ӌ",Ӎ="ӎ",Ӑ="ӑ",Ӓ="ӓ",Ӕ="ӕ",Ӗ="ӗ",Ә="ә",Ӛ="ӛ",Ӝ="ӝ",Ӟ="ӟ",Ӡ="ӡ",Ӣ="ӣ",Ӥ="ӥ",Ӧ="ӧ",Ө="ө",Ӫ="ӫ",Ӭ="ӭ",Ӯ="ӯ",Ӱ="ӱ",Ӳ="ӳ",Ӵ="ӵ",Ӷ="ӷ",Ӹ="ӹ",Ӻ="ӻ",Ӽ="ӽ",Ӿ="ӿ",Ԁ="ԁ",Ԃ="ԃ",Ԅ="ԅ",Ԇ="ԇ",Ԉ="ԉ",Ԋ="ԋ",Ԍ="ԍ",Ԏ="ԏ",Ԑ="ԑ",Ԓ="ԓ",Ա="ա",Բ="բ",Գ="գ",Դ="դ",Ե="ե",Զ="զ",Է="է",Ը="ը",Թ="թ",Ժ="ժ",Ի="ի",Լ="լ",Խ="խ",Ծ="ծ",Կ="կ",Հ="հ",Ձ="ձ",Ղ="ղ",Ճ="ճ",Մ="մ",Յ="յ",Ն="ն",Շ="շ",Ո="ո",Չ="չ",Պ="պ",Ջ="ջ",Ռ="ռ",Ս="ս",Վ="վ",Տ="տ",Ր="ր",Ց="ց",Ւ="ւ",Փ="փ",Ք="ք",Օ="օ",Ֆ="ֆ",Ⴀ="ⴀ",Ⴁ="ⴁ",Ⴂ="ⴂ",Ⴃ="ⴃ",Ⴄ="ⴄ",Ⴅ="ⴅ",Ⴆ="ⴆ",Ⴇ="ⴇ",Ⴈ="ⴈ",Ⴉ="ⴉ",Ⴊ="ⴊ",Ⴋ="ⴋ",Ⴌ="ⴌ",Ⴍ="ⴍ",Ⴎ="ⴎ",Ⴏ="ⴏ",Ⴐ="ⴐ",Ⴑ="ⴑ",Ⴒ="ⴒ",Ⴓ="ⴓ",Ⴔ="ⴔ",Ⴕ="ⴕ",Ⴖ="ⴖ",Ⴗ="ⴗ",Ⴘ="ⴘ",Ⴙ="ⴙ",Ⴚ="ⴚ",Ⴛ="ⴛ",Ⴜ="ⴜ",Ⴝ="ⴝ",Ⴞ="ⴞ",Ⴟ="ⴟ",Ⴠ="ⴠ",Ⴡ="ⴡ",Ⴢ="ⴢ",Ⴣ="ⴣ",Ⴤ="ⴤ",Ⴥ="ⴥ",Ḁ="ḁ",Ḃ="ḃ",Ḅ="ḅ",Ḇ="ḇ",Ḉ="ḉ",Ḋ="ḋ",Ḍ="ḍ",Ḏ="ḏ",Ḑ="ḑ",Ḓ="ḓ",Ḕ="ḕ",Ḗ="ḗ",Ḙ="ḙ",Ḛ="ḛ",Ḝ="ḝ",Ḟ="ḟ",Ḡ="ḡ",Ḣ="ḣ",Ḥ="ḥ",Ḧ="ḧ",Ḩ="ḩ",Ḫ="ḫ",Ḭ="ḭ",Ḯ="ḯ",Ḱ="ḱ",Ḳ="ḳ",Ḵ="ḵ",Ḷ="ḷ",Ḹ="ḹ",Ḻ="ḻ",Ḽ="ḽ",Ḿ="ḿ",Ṁ="ṁ",Ṃ="ṃ",Ṅ="ṅ",Ṇ="ṇ",Ṉ="ṉ",Ṋ="ṋ",Ṍ="ṍ",Ṏ="ṏ",Ṑ="ṑ",Ṓ="ṓ",Ṕ="ṕ",Ṗ="ṗ",Ṙ="ṙ",Ṛ="ṛ",Ṝ="ṝ",Ṟ="ṟ",Ṡ="ṡ",Ṣ="ṣ",Ṥ="ṥ",Ṧ="ṧ",Ṩ="ṩ",Ṫ="ṫ",Ṭ="ṭ",Ṯ="ṯ",Ṱ="ṱ",Ṳ="ṳ",Ṵ="ṵ",Ṷ="ṷ",Ṹ="ṹ",Ṻ="ṻ",Ṽ="ṽ",Ṿ="ṿ",Ẁ="ẁ",Ẃ="ẃ",Ẅ="ẅ",Ẇ="ẇ",Ẉ="ẉ",Ẋ="ẋ",Ẍ="ẍ",Ẏ="ẏ",Ẑ="ẑ",Ẓ="ẓ",Ẕ="ẕ",Ạ="ạ",Ả="ả",Ấ="ấ",Ầ="ầ",Ẩ="ẩ",Ẫ="ẫ",Ậ="ậ",Ắ="ắ",Ằ="ằ",Ẳ="ẳ",Ẵ="ẵ",Ặ="ặ",Ẹ="ẹ",Ẻ="ẻ",Ẽ="ẽ",Ế="ế",Ề="ề",Ể="ể",Ễ="ễ",Ệ="ệ",Ỉ="ỉ",Ị="ị",Ọ="ọ",Ỏ="ỏ",Ố="ố",Ồ="ồ",Ổ="ổ",Ỗ="ỗ",Ộ="ộ",Ớ="ớ",Ờ="ờ",Ở="ở",Ỡ="ỡ",Ợ="ợ",Ụ="ụ",Ủ="ủ",Ứ="ứ",Ừ="ừ",Ử="ử",Ữ="ữ",Ự="ự",Ỳ="ỳ",Ỵ="ỵ",Ỷ="ỷ",Ỹ="ỹ",Ἀ="ἀ",Ἁ="ἁ",Ἂ="ἂ",Ἃ="ἃ",Ἄ="ἄ",Ἅ="ἅ",Ἆ="ἆ",Ἇ="ἇ",Ἐ="ἐ",Ἑ="ἑ",Ἒ="ἒ",Ἓ="ἓ",Ἔ="ἔ",Ἕ="ἕ",Ἠ="ἠ",Ἡ="ἡ",Ἢ="ἢ",Ἣ="ἣ",Ἤ="ἤ",Ἥ="ἥ",Ἦ="ἦ",Ἧ="ἧ",Ἰ="ἰ",Ἱ="ἱ",Ἲ="ἲ",Ἳ="ἳ",Ἴ="ἴ",Ἵ="ἵ",Ἶ="ἶ",Ἷ="ἷ",Ὀ="ὀ",Ὁ="ὁ",Ὂ="ὂ",Ὃ="ὃ",Ὄ="ὄ",Ὅ="ὅ",Ὑ="ὑ",Ὓ="ὓ",Ὕ="ὕ",Ὗ="ὗ",Ὠ="ὠ",Ὡ="ὡ",Ὢ="ὢ",Ὣ="ὣ",Ὤ="ὤ",Ὥ="ὥ",Ὦ="ὦ",Ὧ="ὧ",ᾈ="ᾀ",ᾉ="ᾁ",ᾊ="ᾂ",ᾋ="ᾃ",ᾌ="ᾄ",ᾍ="ᾅ",ᾎ="ᾆ",ᾏ="ᾇ",ᾘ="ᾐ",ᾙ="ᾑ",ᾚ="ᾒ",ᾛ="ᾓ",ᾜ="ᾔ",ᾝ="ᾕ",ᾞ="ᾖ",ᾟ="ᾗ",ᾨ="ᾠ",ᾩ="ᾡ",ᾪ="ᾢ",ᾫ="ᾣ",ᾬ="ᾤ",ᾭ="ᾥ",ᾮ="ᾦ",ᾯ="ᾧ",Ᾰ="ᾰ",Ᾱ="ᾱ",Ὰ="ὰ",Ά="ά",ᾼ="ᾳ",Ὲ="ὲ",Έ="έ",Ὴ="ὴ",Ή="ή",ῌ="ῃ",Ῐ="ῐ",Ῑ="ῑ",Ὶ="ὶ",Ί="ί",Ῠ="ῠ",Ῡ="ῡ",Ὺ="ὺ",Ύ="ύ",Ῥ="ῥ",Ὸ="ὸ",Ό="ό",Ὼ="ὼ",Ώ="ώ",ῼ="ῳ",Ω="ω",K="k",Å="å",Ⅎ="ⅎ",Ⅰ="ⅰ",Ⅱ="ⅱ",Ⅲ="ⅲ",Ⅳ="ⅳ",Ⅴ="ⅴ",Ⅵ="ⅵ",Ⅶ="ⅶ",Ⅷ="ⅷ",Ⅸ="ⅸ",Ⅹ="ⅹ",Ⅺ="ⅺ",Ⅻ="ⅻ",Ⅼ="ⅼ",Ⅽ="ⅽ",Ⅾ="ⅾ",Ⅿ="ⅿ",Ↄ="ↄ",Ⓐ="ⓐ",Ⓑ="ⓑ",Ⓒ="ⓒ",Ⓓ="ⓓ",Ⓔ="ⓔ",Ⓕ="ⓕ",Ⓖ="ⓖ",Ⓗ="ⓗ",Ⓘ="ⓘ",Ⓙ="ⓙ",Ⓚ="ⓚ",Ⓛ="ⓛ",Ⓜ="ⓜ",Ⓝ="ⓝ",Ⓞ="ⓞ",Ⓟ="ⓟ",Ⓠ="ⓠ",Ⓡ="ⓡ",Ⓢ="ⓢ",Ⓣ="ⓣ",Ⓤ="ⓤ",Ⓥ="ⓥ",Ⓦ="ⓦ",Ⓧ="ⓧ",Ⓨ="ⓨ",Ⓩ="ⓩ",Ⰰ="ⰰ",Ⰱ="ⰱ",Ⰲ="ⰲ",Ⰳ="ⰳ",Ⰴ="ⰴ",Ⰵ="ⰵ",Ⰶ="ⰶ",Ⰷ="ⰷ",Ⰸ="ⰸ",Ⰹ="ⰹ",Ⰺ="ⰺ",Ⰻ="ⰻ",Ⰼ="ⰼ",Ⰽ="ⰽ",Ⰾ="ⰾ",Ⰿ="ⰿ",Ⱀ="ⱀ",Ⱁ="ⱁ",Ⱂ="ⱂ",Ⱃ="ⱃ",Ⱄ="ⱄ",Ⱅ="ⱅ",Ⱆ="ⱆ",Ⱇ="ⱇ",Ⱈ="ⱈ",Ⱉ="ⱉ",Ⱊ="ⱊ",Ⱋ="ⱋ",Ⱌ="ⱌ",Ⱍ="ⱍ",Ⱎ="ⱎ",Ⱏ="ⱏ",Ⱐ="ⱐ",Ⱑ="ⱑ",Ⱒ="ⱒ",Ⱓ="ⱓ",Ⱔ="ⱔ",Ⱕ="ⱕ",Ⱖ="ⱖ",Ⱗ="ⱗ",Ⱘ="ⱘ",Ⱙ="ⱙ",Ⱚ="ⱚ",Ⱛ="ⱛ",Ⱜ="ⱜ",Ⱝ="ⱝ",Ⱞ="ⱞ",Ⱡ="ⱡ",Ɫ="ɫ",Ᵽ="ᵽ",Ɽ="ɽ",Ⱨ="ⱨ",Ⱪ="ⱪ",Ⱬ="ⱬ",Ⱶ="ⱶ",Ⲁ="ⲁ",Ⲃ="ⲃ",Ⲅ="ⲅ",Ⲇ="ⲇ",Ⲉ="ⲉ",Ⲋ="ⲋ",Ⲍ="ⲍ",Ⲏ="ⲏ",Ⲑ="ⲑ",Ⲓ="ⲓ",Ⲕ="ⲕ",Ⲗ="ⲗ",Ⲙ="ⲙ",Ⲛ="ⲛ",Ⲝ="ⲝ",Ⲟ="ⲟ",Ⲡ="ⲡ",Ⲣ="ⲣ",Ⲥ="ⲥ",Ⲧ="ⲧ",Ⲩ="ⲩ",Ⲫ="ⲫ",Ⲭ="ⲭ",Ⲯ="ⲯ",Ⲱ="ⲱ",Ⲳ="ⲳ",Ⲵ="ⲵ",Ⲷ="ⲷ",Ⲹ="ⲹ",Ⲻ="ⲻ",Ⲽ="ⲽ",Ⲿ="ⲿ",Ⳁ="ⳁ",Ⳃ="ⳃ",Ⳅ="ⳅ",Ⳇ="ⳇ",Ⳉ="ⳉ",Ⳋ="ⳋ",Ⳍ="ⳍ",Ⳏ="ⳏ",Ⳑ="ⳑ",Ⳓ="ⳓ",Ⳕ="ⳕ",Ⳗ="ⳗ",Ⳙ="ⳙ",Ⳛ="ⳛ",Ⳝ="ⳝ",Ⳟ="ⳟ",Ⳡ="ⳡ",Ⳣ="ⳣ",Ａ="ａ",Ｂ="ｂ",Ｃ="ｃ",Ｄ="ｄ",Ｅ="ｅ",Ｆ="ｆ",Ｇ="ｇ",Ｈ="ｈ",Ｉ="ｉ",Ｊ="ｊ",Ｋ="ｋ",Ｌ="ｌ",Ｍ="ｍ",Ｎ="ｎ",Ｏ="ｏ",Ｐ="ｐ",Ｑ="ｑ",Ｒ="ｒ",Ｓ="ｓ",Ｔ="ｔ",Ｕ="ｕ",Ｖ="ｖ",Ｗ="ｗ",Ｘ="ｘ",Ｙ="ｙ",Ｚ="ｚ",𐐀="𐐨",𐐁="𐐩",𐐂="𐐪",𐐃="𐐫",𐐄="𐐬",𐐅="𐐭",𐐆="𐐮",𐐇="𐐯",𐐈="𐐰",𐐉="𐐱",𐐊="𐐲",𐐋="𐐳",𐐌="𐐴",𐐍="𐐵",𐐎="𐐶",𐐏="𐐷",𐐐="𐐸",𐐑="𐐹",𐐒="𐐺",𐐓="𐐻",𐐔="𐐼",𐐕="𐐽",𐐖="𐐾",𐐗="𐐿",𐐘="𐑀",𐐙="𐑁",𐐚="𐑂",𐐛="𐑃",𐐜="𐑄",𐐝="𐑅",𐐞="𐑆",𐐟="𐑇",𐐠="𐑈",𐐡="𐑉",𐐢="𐑊",𐐣="𐑋",𐐤="𐑌",𐐥="𐑍",𐐦="𐑎",𐐧="𐑏",},{ᔡ={"s",},く={"<",},ᖱ={"d",},⋓={"u",},б={"b","6",},ฝ={"w","u",},Ա={"u","U",},ݒ={"u",},ᘬ={"s",},ꇘ={"S",},≻={">",},‵={"'",},[6]={"b",},ฑ={"n",},Ҟ={"K",},ı={"i",},Ξ={"E",},₩={"W",},ᑙ={"n",},ʞ={"k",},ڹ={"U",},ƃ={"b",},☊={"n",},ƞ={"n",},ʃ={"s","f",},ҹ={"u","h",},Ꮽ={"9",},˵={"\"",},ʹ={"'",},ս={"u",},ι={"i","l","L",},ڃ={"c","z",},ѽ={"w","o",},ɇ={"e",},ͽ={"c","E",},━={"-",},ƹ={"E","z","3",},╤={"T",},ɽ={"r","l",},ч={"ch","u","y","h",},‘={"'",},Ᏺ={"h",},⓱={"17",},┮={"T",},ه={"o","a",},ᑢ={"c",},Շ={"o",},ԋ={"H",},ˏ={",",},‹={"<",},Ѣ={"b",},ᑝ={"c",},բ={"f","p",},Ｒ={"R",},Ꮜ={"a","u",},٢={"2","r",},Ħ={"H",},≿={">",},ғ={"F",},˪={"L","i",},ᵾ={"Au",},Ϫ={"Y","a","v",},ⅴ={"V",},ᒶ={"L",},ê={"E",},Ꮹ={"G","c",},╙={"L",},⓬={"12",},ᴦ={"G","L","R",},☣={"o",},〡={"i","l",},ʮ={"h","u",},⊂={"<",},Ɠ={"G",},Ʈ={"T",},ʓ={"E","z","3",},®={"R",},Γ={"G","L","r","T",},ת={"n",},ᶈ={"A","p","o",},ԛ={"q",},ᐏ={"A","n","v",},Ѳ={"f","th","o",},ᑦ={"c",},Ү={"U","Y",},⓵={"1",},Л={"L","N",},∪={"u",},ٲ={"i",},≳={">",},♈={"v",},‽={"!?","?!","?","!",},ㄘ={"c","s",},ж={"x","k",},｛={"{",},ɲ={"n",},丨={"i","l",},ᙄ={"e","c",},Ԁ={"d",},˟={"x",},ᄇ={"A",},τ={"t","T",},Ｊ={"J",},ᶕ={"e",},๑={"a",},ß={"ss","B",},ศ={"a",},╅={"t","+",},ȶ={"t",},ᴢ={"Z",},ᗷ={"E","B",},ʈ={"t",},⊆={"<",},˺={"'",},ᴩ={"R","P",},ઠ={"s",},ۄ={"a","g",},⏋={"L",},ƈ={"c",},†={"+","t",},Ɍ={"R",},⓹={"5",},£={"L","E",},১={"1",},ʾ={"'",},ᑪ={"c",},ƾ={"s",},ʣ={"dz",},Σ={"S","E",},А={"A",},ң={"H",},ㄤ={"ang",},Ռ={"n",},ь={"b",},ɧ={"h",},ｗ={"W",},☺={"o",},ŧ={"t",},ฬ={"n","w","m",},ѧ={"A",},ᶑ={"d",},╁={"t","+",},٧={"7","v",},ｏ={"/","O",},է={"t",},⊚={"o",},ژ={"j",},ث={"u",},ᒎ={"j","i",},⓽={"9",},Ҙ={"E",},Ꮐ={"G",},⏇={"T",},ʘ={"O",},ᑮ={"p",},Θ={"TH","O",},[8]={"B",},ᕫ={"w","u",},ڳ={"S",},ᐐ={"A","n","v",},Ƙ={"K",},ㄠ={"au",},ɜ={"e","3",},Ł={"L",},☾={"c",},Ɂ={"?",},Ƴ={"Y",},≨={"<",},ᴍ={"M",},ᒢ={"i",},с={"s","c","C",},γ={"g","y","b","Y",},ᄏ={"F",},շ={"2",},Ձ={"2",},Ի={"r","R",},["!"]={"i",},ᖆ={"A",},ᴪ={"W",},ᗿ={"B",},ɷ={"w","o",},л={"l","n",},ᇫ={"A","n","v",},ᒇ={"d",},ˉ={"'",},ᔓ={"s",},⋧={">",},ω={"aw","w",},Ȼ={"C",},义={"X",},Ƞ={"n",},É={"E",},ӿ={"x",},ㄍ={"g",},ᵮ={"f",},৯={"9",},Р={"R","P",},ۉ={"g",},ᶅ={"l","I",},ʍ={"w","m",},Ꮋ={"H",},ƍ={"o",},Ϥ={"h","b","p","q",},Ӊ={"H",},♄={"h",},ᅅ={"ON","OA",},Ｂ={"B",},ʨ={"tc","ts","t",},Ց={"s","/",},▍={"|",},Ψ={"PS","U","W",},ҍ={"b",},ᄋ={"O",},ƨ={"s",},ᶙ={"u",},Е={"E",},ɬ={"l","I",},╉={"t","+",},₠={"C",},[1]={"I","l",},～={"~",},⁓={"~",},｝={"}",},⊒={"c",},ᖂ={"d",},ᴉ={"i","!",},｜={"|",},＿={"_",},｀={"`",},а={"a","A",},נ={"i","c","j",},］={"]",},ᕲ={"D",},լ={"L",},〤={"X",},［={"[",},〨={"E",},ذ={"s",},ݑ={"u",},Ｚ={"Z",},ĕ={"E",},ฅ={"n","a",},ᑐ={"c",},ઙ={"s",},☂={"j",},ᗋ={"A",},ᶁ={"d",},ᔍ={"c",},➏={"6",},∺={"H",},ϙ={"o",},ⅹ={"X",},Ê={"E",},Ｗ={"W",},Ꮇ={"M",},＊={"*",},ҝ={"x","k",},۴={"r",},Ƃ={"b",},Ｖ={"V",},Ν={"N",},ʬ={"w",},ʂ={"s",},╌={"-",},ʝ={"j","i",},ᑱ={"d",},Ｕ={"U",},ｔ={"T",},Ɲ={"N",},ᒪ={"L",},⋜={"<",},Ꭼ={"E",},Ｔ={"T",},Ҹ={"u","y","h",},ւ={"L",},ｓ={"S",},แ={"ii",},Ｓ={"S",},ڂ={"c","z",},ᚤ={"n",},Ⴝ={"S",},ټ={"u",},Ɇ={"E",},–={"-",},ｒ={"R",},θ={"th","o",},੫={"5",},฿={"B",},ᚱ={"R",},Ѽ={"w","u",},ц={"ts","u",},┆={"|",},ᔛ={"s",},ͼ={"c","E",},Ꮃ={"W",},Ｑ={"Q",},ᕾ={"p",},ɼ={"r","l",},ن={"u",},は={"t",},Ⴓ={"Q",},Ⴍ={"Q",},ɡ={"g","G",},ｐ={"P",},Ｐ={"P",},匸={"C",},ᑔ={"c",},ᶍ={"x",},Ⅰ={"I",},ｍ={"M",},ѡ={"W","v",},Ｍ={"M",},ⅿ={"M",},∔={"i",},ˎ={",",},ઝ={"K",},Ϻ={"M",},ｌ={"L",},١={"1",},Ｌ={"L",},ȥ={"z",},ⅼ={"L",},Ғ={"F",},Ⅼ={"L",},ｋ={"K",},Ⅽ={"C",},１={"/",},K={"K",},Х={"H","X",},ｊ={"J",},˩={"l","i",},❷={"2",},ᅃ={"OO",},☪={"c",},ผ={"w","u",},Ｉ={"I",},ⅰ={"I",},ᑵ={"q",},ӎ={"m",},Ｎ={"N",},ｈ={"H",},┈={"-",},і={"i","I",},ｇ={"G",},Ｇ={"G",},╱={"/",},ʒ={"E","z","3",},ｆ={"F",},ʭ={"n",},Ｆ={"F",},Β={"B",},੯={"9",},ƭ={"E",},‟={"\"",},ө={"th","o",},ᒐ={"l","i",},Ꮤ={"W",},ᗣ={"A",},Ｅ={"E",},ꇙ={"S",},ᕺ={"b",},ѱ={"ps","w",},Ԛ={"Q",},ě={"E",},Ꮠ={"i",},ձ={"do",},ɖ={"d",},ē={"E",},⓮={"14",},ٱ={"i",},ᑘ={"u",},ᔢ={"s",},ҭ={"t",},ݔ={"u",},К={"K",},Ė={"E",},Ĕ={"E",},ミ={"E",},Ě={"E",},е={"e","E",},Ē={"E",},ᵵ={"t",},۞={"O",},ë={"E",},ᚽ={"I",},ɱ={"m",},מ={"a",},é={"E",},ᗬ={"D",},Ⅹ={"X",},ǃ={"!",},Ե={"t",},È={"E",},ᑹ={"p",},ݖ={"u",},ⱷ={"w",},ᴻ={"N",},۹={"q",},σ={"s","o",},Ꭴ={"u",},ｄ={"D",},Ｄ={"D",},ᑜ={"n",},ȵ={"n",},ⅾ={"D",},Ⅾ={"D",},Þ={"b","p",},ฐ={"s",},Ƈ={"C",},╽={"|",},ۃ={"s","o","j",},‛={"'",},à={"A",},˹={"'",},Ď={"D",},ڽ={"o","u",},ｃ={"C",},Ϲ={"C",},丶={"'",},ب={"u",},ʇ={"t","f",},ϲ={"C",},¢={"c",},ҽ={"e",},ｚ={"Z",},乚={"L",},Ƣ={"a",},ν={"n","v","V",},ᴧ={"L","A","n","v",},♑={"N",},ʢ={"?","c",},ʽ={"'",},ᴨ={"P","N",},€={"E",},ɍ={"r",},ƽ={"s",},ڇ={"c",},ᗫ={"D",},Ң={"H",},å={"A",},ä={"A",},ã={"A",},♊={"o",},‖={"||","ll",},ď={"D",},ᐄ={"A","n",},凢={"N",},ด={"n","a",},ห={"n",},ᑽ={"d",},ɦ={"h",},⋉={"K",},丫={"Y",},ᵱ={"p",},ы={"bl",},⓭={"13",},Å={"A",},Ä={"A",},Ѧ={"A",},Ã={"A",},ԏ={"T",},☢={"o",},ㄝ={"eh",},Â={"A",},Џ={"U","Y",},﹝={"(",},٦={"6",},─={"-",},Á={"A",},À={"A",},զ={"q",},≪={"<<",},？={"?",},₰={"I",},＞={">",},ᴚ={"R",},＝={"=",},⁁={"l","/",},Ϯ={"I","t","l",},੧={"1",},җ={"x","k",},ᑍ={"n","h",},ت={"u",},➆={"7",},;={";",},ઈ={"d",},∑={"S","E",},：={":",},ڗ={"j",},Т={"T",},Ҳ={"X",},∶={":",},Ɨ={"I",},܄={":",},⺇={"n",},♏={"m",},Ӻ={"F",},Ꮟ={"b",},ۮ={"j",},ᒘ={"j",},Η={"H",},ʠ={"q",},８={"/",},Ꭰ={"a","d","D",},ʗ={"c",},ョ={"E",},ћ={"ts","h",},〃={"\"",},Ꮸ={"c",},ᵽ={"p",},Ʋ={"u",},７={"/",},６={"/",},ɀ={"z",},ɛ={"e",},２={"/",},П={"P","N",},５={"/",},β={"b","B",},ᘂ={"i",},４={"/",},ᑡ={"c",},ն={"u","G",},３={"/",},Ｋ={"K",},Հ={"R",},ᗶ={"R",},Ｏ={"/","O",},ﾉ={"/",},Ϟ={"N","X",},Ժ={"o","a",},┌={"r",},⫽={"/",},տ={"s",},غ={"E",},ㄆ={"p","r",},∕={"/",},╥={"T",},ˈ={"'",},ᴆ={"D",},ᴅ={"D",},｡={".",},ψ={"ps","u","w",},ฤ={"n","a",},．={".",},₴={"S",},Ԅ={"R",},‧={".",},․={".",},܂={".",},Ⱥ={"A",},܁={".",},≼={"<",},Ꮛ={"e",},ۈ={"g",},۔={".",},ᴯ={"B","D",},♉={"u",},Ӿ={"X",},٠={".",},サ={"H",},－={"-",},ӈ={"H","A",},ю={"io","o",},，={",",},ᵹ={"d",},ϣ={"w",},╘={"L",},ｖ={"V",},⁎={"*",},ݫ={"j",},〇={"o",},⓶={"2",},）={")",},þ={"b","p",},ᗑ={"A",},ร={"s",},﹞={")",},ڌ={"j",},ᒀ={"b",},Ꮴ={"v",},ⅽ={"C",},Ր={"r",},ᘺ={"w",},Χ={"X",},ᶒ={"e",},Ҍ={"b",},Ᵽ={"p",},ʧ={"ts","a",},＇={"'",},Ɯ={"w",},％={"%",},⊙={"o",},ᑥ={"c",},＄={"\"",},∈={"E",},ҧ={"n",},☦={"t",},ɫ={"l","I",},＂={"\"",},ㄑ={"q","k",},״={"\"",},ɐ={"a",},ᴂ={"ae",},ᙂ={"c",},！={},💀={"oo",},⊺={"T",},ᚩ={"F",},乃={"B",},ի={"h",},ꆿ={"H",},厂={"R",},卩={"P","N",},٫={",",},Պ={"n",},ｎ={"N",},匚={"C",},ט={"u",},ᛘ={"Y",},Ꮰ={"j",},♍={"m",},ݐ={"u",},凵={"U",},凣={"N",},凡={"N",},ᐑ={"A","n","v",},ᒔ={"r",},从={"M",},ᒏ={"j","i",},۳={"r",},╕={"F",},Я={"Y","R",},▄={"_",},❿={"10",},乛={"-",},⓺={"6",},乙={"z",},Ҝ={"K",},么={"G",},乇={"T",},Ɓ={"B",},৬={"6",},�={"?","-","/","=","C","I","O","S",},丷={"''",},ʁ={"R",},ʜ={"H",},➒={"9",},ҷ={"u","y","h",},ᑩ={"c",},ϳ={"j","J",},Ⱨ={"H",},Ｃ={"C",},ҁ={"k","c",},ᗾ={"B",},▁={"_",},Ꮄ={"S",},ց={"g",},ᗻ={"R",},Ʌ={"^","N",},Ʒ={"E","z","3",},ځ={"c","z",},上={"T",},三={"3","E",},·={"'",},╭={"r",},ٻ={"u",},х={"h","x","X",},η={"e","n",},丅={"T",},ͻ={"c",},丄={"T",},ƒ={"f",},ᑭ={"p",},ѻ={"o",},م={"p",},ә={"e",},丁={"T",},一={"-",},Յ={"3","d",},Կ={"u",},ᖺ={"n","h",},ɻ={"r","l",},ᅄ={"OU","OR","OA",},п={"p","n",},ㇶ={"t",},ɠ={"g",},ᗦ={"D",},ᵎ={"i","!",},ㄩ={"iu","U",},ㄨ={"u","X",},ㄧ={"i",},ȿ={"s",},ᵰ={"n",},Ѡ={"w",},ˍ={",",},ㄥ={"eng","L","C",},Ꮓ={"Z",},ㄣ={"en",},╃={"t","+",},⓾={"10",},Љ={"N",},Ф={"F","O",},ㄡ={"ou","A","r",},ᗺ={"E","B",},ґ={"r",},˨={"l","i",},＆={"&",},ㄜ={"e",},ㄛ={"o",},Ϩ={"s",},ۍ={"s",},⁃={"-",},ڑ={"j",},ㄙ={"s","A",},Ⱬ={"Z",},—={"-",},。={".",},ㄕ={"sh","p","r",},Ӎ={"M",},ƕ={"h",},⊑={"c",},ᛖ={"M",},┰={"T",},∀={"A",},Ƒ={"F",},ㄓ={"zh","z","w",},ㄒ={"x","T",},Ꮀ={"E",},ʑ={"z",},Ө={"th","O",},Օ={"O","/",},″={"\"",},Α={"A",},Ƭ={"T",},ค={"n","a",},ㄐ={"j","u",},⋞={"<",},¬={"-","!",},ㄎ={"k","s","e",},ᑓ={"c",},ઘ={"u",},ㄌ={"l",},ɕ={"c",},ㄋ={"n",},ム={"A",},Ѱ={"PS","W",},[5]={"S",},ㄉ={"d",},♅={"H",},հ={"h",},ㄈ={"f","c",},ㄇ={"m","n",},ㄅ={"b","s",},Ꮯ={"c","C",},ᑰ={"d",},ᒈ={"b",},⓸={"4",},ヨ={"E",},モ={"E","T",},ㄊ={"t","g",},マ={"R",},▌={"|",},ᅀ={"A",},⋝={">",},ᵭ={"d",},ᆺ={"A","n","v",},ם={"a","o",},ヒ={"t",},ᶆ={"m",},ɰ={"w",},ݕ={"u",},ノ={"J",},エ={"I",},ๆ={"r",},ǂ={"|",},‚={",",},イ={"T",},ᅡ={"t",},˂={"<",},∣={"l",},ァ={"P",},Ꭳ={"o",},ς={"s","c",},┾={"t","+",},り={"n",},ら={"s",},と={"y",},┼={"t","+",},て={"t",},ᕵ={"p",},ᒚ={"j",},ｂ={"B",},＼={"\\",},ϸ={"b","p",},ʆ={"l",},〓={"=",},〞={"\"",},ڼ={"i",},ֆ={"S","$",},ป={"u",},〝={"\"",},〜={"~",},Ŋ={"N",},ᑗ={"u",},Ᏼ={"B",},Ҽ={"e",},Ɋ={"q","a",},〕={")",},〔={"(",},μ={"m","u","U",},چ={"c",},ᒌ={"i",},ʡ={"?",},ʼ={"'",},》={">>",},《={"<<",},Ρ={"R","P",},Ƽ={"s",},ᑴ={"q",},Ø={"O",},੨={"2",},〈={"<",},ي={"s",},ㄖ={"r","o",},、={",",},⺋={"e",},ɥ={"h","u",},☒={"X",},ᵼ={"i",},ⱳ={"w",},ъ={"b",},ξ={"x","E",},ᴎ={"N",},ⱬ={"z",},ѥ={"ie","E",},⋑={"c",},ⱪ={"k",},Ⱪ={"K",},ס={"o",},ᘪ={"s",},ᶂ={"f",},ⱦ={"t","l",},٥={"5","o",},ⱥ={"a",},Ɽ={"R",},Ɫ={"L","t",},ե={"t","b",},Ⱡ={"L",},⦿={"o",},➓={"10",},ᑼ={"d",},➑={"8",},ᒑ={"l","i",},ᄔ={"LL",},Җ={"X","K",},➐={"7",},Ｘ={"X",},➎={"5",},ϭ={"d","o",},※={"X",},ة={"o",},⏆={"l",},­={"-",},ฟ={"w","m",},➋={"2",},➊={"1",},Ɩ={"I",},ᑛ={"n",},Щ={"SH","W",},ᵴ={"s",},➉={"10",},ұ={"u","y","v",},➈={"9",},➇={"8",},Ζ={"Z",},；={";",},੬={"6",},∋={"R",},ʖ={"?",},ڱ={"S",},า={"r",},۲={"r",},њ={"nj","Hb","H","b",},➃={"4",},➂={"3",},ѵ={"v","V",},Ֆ={"s",},±={"+","-",},➀={"1",},⊌={"u",},ɚ={"e",},Ʊ={"u",},二={"2",},Ҫ={"s","C",},ᶉ={"r",},❼={"7",},Ꭹ={"y","v","u",},յ={"j","i","J",},О={"O","/",},α={"a","A",},ᔣ={"s",},ᄐ={"E",},❻={"6",},ᘮ={"u",},Ŧ={"T",},❹={"4",},ᛂ={"I",},ᴟ={"m","E",},┃={"|",},ɵ={"o",},❸={"3",},ع={"E",},❶={"1",},❍={"o",},ᑠ={"c",},✞={"t",},ᒕ={"r",},✝={"t",},ɑ={"a","A",},✚={"t",},✘={"X",},≥={">",},χ={"x","X",},✗={"X",},ԃ={"d",},✖={"X",},ˇ={"'",},ȹ={"qp","cp",},♯={"#",},♭={"b",},る={"z",},ᑟ={"c",},܃={":",},♌={"n",},Ӈ={"H","A",},ㄞ={"ai",},ʋ={"u","v",},ӽ={"x",},â={"A",},♇={"B",},ᴇ={"E",},Ͻ={"C",},ۇ={"g",},ˋ={"'",},ᑌ={"u",},ɏ={"y",},๛={"c",},ᒸ={"L",},Ƌ={"d",},ᚺ={"H","N",},Ʀ={"R",},☽={"c",},⊥={"T",},ᅙ={"o",},¦={"|",},☼={"o",},Ƹ={"E","z","3",},☹={"o",},Φ={"PH","F","O",},ᗵ={"R",},ҋ={"i","N",},☸={"o",},ʦ={"ts","s",},☩={"t",},下={"T",},ᄜ={"OA","OU","OR",},ᗪ={"D",},ᘢ={"u",},☧={"t",},╼={"-",},Ҧ={"n",},Ϣ={"W",},Г={"G","L",},ᕹ={"b",},ɪ={"I",},╇={"t","+",},ԓ={"N",},☡={"Z","2",},ᑤ={"c",},∐={"U",},ᒙ={"j",},Đ={"D",},ח={"n",},∂={"d","a",},ᘃ={"i",},ᶊ={"s",},ժ={"d","D",},⺆={"n",},☋={"u",},ｙ={"Y",},٪={"%",},◯={"O",},ท={"n",},◎={"O",},Ꮞ={"4",},◌={"o",},／={"/",},◊={"o",},›={">",},△={"A",},ᑸ={"p",},▐={"|",},×={"x",},∞={"oo",},ᴃ={"B","D",},ᚾ={"I",},ϗ={"h","k","x",},▎={"|",},▋={"|",},⊐={"c",},[7]={"t",},մ={"u",},қ={"k",},个={"T",},Ю={"IO","O",},⊕={"o",},ᶋ={"s",},╾={"-",},☥={"t",},╻={"i",},ʛ={"G",},ƀ={"b",},Ҷ={"u","y","h",},ᗱ={"E",},Ꭱ={"e","R",},ʀ={"R",},╺={"-",},₱={"D",},╲={"\\",},⓳={"19",},џ={"dz","u",},⏉={"T",},ƛ={"A",},Ҁ={"k","c",},ƶ={"z",},╚={"L",},＋={"+",},ր={"n",},ɟ={"j","f",},人={"N",},⋎={"v",},ڀ={"u",},ᑨ={"n",},ᛙ={"I",},╔={"r",},╒={"F","r",},║={"ll","||",},ㄦ={"er",},╏={"|",},≽={">",},Ѻ={"O",},╎={"|",},╍={"-",},ｕ={"U",},ᒿ={"2",},╊={"t","+",},Ꮍ={"Y",},╈={"t","+",},ل={"j",},╆={"t","+",},ᗐ={"V",},Д={"D","A",},Ծ={"o",},ㄢ={"an",},╂={"t","+",},╀={"t","+",},о={"o","/","O",},┿={"t","+",},ᴏ={"O",},♩={"l","I",},ˌ={",",".",},┽={"t","+",},┳={"T",},ฮ={"a",},Ј={"J","I","l",},๓={"n","m",},ᒁ={"b",},В={"V","B",},ᶓ={"e",},┱={"T",},ȣ={"d","o",},ᔔ={"s",},ݟ={"E",},┭={"T",},┬={"T",},┗={"L",},Ґ={"L","r",},ᗽ={"B",},У={"U","Y",},ᴠ={"V",},ϧ={"3","c",},⏌={"L",},七={"t",},└={"L",},˧={"l","i",},┏={"r",},ɭ={"l",},┍={"r",},ק={"p",},⋥={"c",},ᴫ={"N",},⓷={"3",},є={"e",},⏅={"A",},ʫ={"lz",},Ѕ={"S",},Ɛ={"E",},∨={"v",},∏={"P","N",},ẞ={"ss","B",},ʐ={"z",},┉={"-",},«={"<<","<",},Ｈ={"H",},Ք={"p",},┇={"|",},ƫ={"t",},ｑ={"Q",},ᖳ={"q",},⓼={"8",},ګ={"S",},ٺ={"u",},Ꮖ={"C",},ヲ={"E",},⓴={"20",},⓲={"18",},ɔ={"c",},⓰={"16",},ҫ={"s","c",},ӌ={"u","y","h",},Ę={"E",},ᙃ={"e","c",},ᴋ={"K",},┖={"L",},⏊={"T",},⏈={"T",},➍={"4",},Ꮷ={"J",},⏄={"A",},⎾={"L",},ᒅ={"q",},⏃={"A",},կ={"u",},ᖄ={"b",},Գ={"q",},⊜={"o",},ѯ={"E",},ӄ={"b","h","k",},⋂={"n",},⏀={"O",},Ϝ={"F",},ᗹ={"E","B",},⎿={"L",},⌡={"j",},ӷ={"L",},ǁ={"II",},⋩={">",},⋨={"<",},ك={"j",},⋤={"c",},⋟={">",},ㄏ={"h",},۷={"v",},ρ={"r","p","P",},⋗={">",},ƅ={"b",},Ƿ={"P",},৭={"7",},ᗖ={"V",},⋒={"n",},÷={"-",},⋐={"c",},ڻ={"o","u",},⓻={"7",},Ϸ={"b","p",},⏁={"O","T",},⋁={"u",},ʅ={"s",},["@"]={"a",},⋀={"A","n",},һ={"h","H",},օ={"o",},⊦={"t",},ɉ={"j",},Ꮅ={"P",},ᔙ={"s",},⊝={"o",},ᑏ={"n",},ᑳ={"b",},∃={"E",},ٿ={"u",},ᖯ={"b",},λ={"l","A",},څ={"c","z",},Ꮒ={"h",},Չ={"o",},»={">>",">",},⊛={"o",},ѿ={"W",},ى={"s",},ƻ={"2",},ฦ={"n","a",},ᑬ={"p",},⊘={"o",},ᒉ={"i",},ᚪ={"F",},ɿ={"r",},щ={"sh","w",},ⱨ={"h",},Ꮳ={"c",},ɤ={"v",},⊖={"o",},⊔={"u",},ӡ={"3","z",},▃={"_",},ᕴ={"q",},ᗥ={"D",},ᚢ={"n",},Ѥ={"IE","E",},⊎={"u",},⊍={"u",},ԍ={"G",},ᔑ={"s",},⊋={">",},ɯ={"w",},⊇={">",},٤={"4","E",},ۑ={"s",},⊃={">",},≾={"<",},դ={"n",},ᚻ={"H","N",},ᑒ={"c",},≲={"<",},Ϭ={"d","o",},ᛕ={"K",},∠={"<",},ҕ={"b","a",},ᵬ={"b",},৩={"3",},Ƨ={"S",},＠={"?",},Ꮣ={"l","c",},ˑ={".",},≩={">",},ｉ={"I",},≦={"<",},≤={"<",},ϟ={"S",},Ꮁ={"T","G","F",},∩={"n",},ィ={"T",},ᑷ={"p",},ᵲ={"r",},Ұ={"U","Y","V",},▏={"|",},∝={"oo",},Ε={"E",},˴={"'",},љ={"lj","nb","n","b",},Ⅿ={"M",},ʕ={"?",},ڰ={"S",},ᕶ={"p",},➅={"6",},ᴔ={"oe",},∊={"R",},๏={"o",},∇={"A",},ᒍ={"j","i",},Ѵ={"V",},∆={"D","A",},☓={"X",},ԝ={"w",},℧={"u",},[9]={"g",},₸={"T",},Н={"N","H",},₵={"C",},₳={"A",},╳={"X",},₯={"Dp","D",},Ը={"c","l",},Ꮮ={"l","L",},۸={"A",},ȝ={"3","E",},ظ={"b",},₭={"K",},₫={"d",},₧={"Pts","P",},̸={"/",},₥={"m",},₤={"E","L",},₣={"F",},и={"i","N",},ᶔ={"3","e",},₡={"C",},ᑖ={"c",},ટ={"s",},⁅={"E",},ᛉ={"Y",},⁄={"/",},ȸ={"db","cb",},Æ={"AE",},ㄚ={"a","Y",},＜={"<",},◇={"o",},φ={"ph","o","w",},〷={"XX",},ｅ={"E",},„={",,",",",},ˆ={"^",},”={"\"",},“={"\"",},Ӽ={"X",},ェ={"I",},ᑻ={"d",},ᖃ={"b",},ϼ={"p",},á={"A",},凹={"U",},ㄗ={"z","p","n",},˼={",",},Ɗ={"D",},‒={"-",},ᶚ={"3",},ɶ={"OE","CE",},ۆ={"g",},ᶗ={"c",},บ={"u",},ᶖ={"i",},ϡ={"l",},₢={"G",},ƥ={"b",},ᄘ={"2L",},Ҋ={"I","N",},ڲ={"S",},¥={"Y",},ᚨ={"F",},Ꮪ={"s","S",},ᶎ={"z",},Υ={"U","Y",},੩={"3",},ᶌ={"v",},╿={"|",},ʥ={"dz",},❽={"8",},ᶇ={"n",},ᶄ={"k",},═={"-",},Ｙ={"Y",},ɩ={"i","I",},ز={"j",},ҥ={"H",},ڒ={"j",},ᄕ={"LC",},⺁={"r",},ઇ={"d",},ᵺ={"th",},Ԓ={"N",},ᵷ={"g","o","b",},ᑚ={"n",},ᅇ={"OO",},թ={"p",},ᘭ={"s",},∟={"L",},ᶃ={"g",},ז={"i",},ᵯ={"m",},ᘫ={"s",},ۯ={"j",},┋={"|",},ᐂ={"A","n",},ａ={"A",},ᴣ={"3",},ѩ={"IA","A",},ᴡ={"W",},պ={"w",},ᴛ={"T",},[2]={"z",},ᑿ={"b",},ᴙ={"R",},ᗏ={"A",},ᴕ={"o",},৫={"5",},ح={"c","z",},ⱱ={"v",},Қ={"K",},ƌ={"d",},ᴊ={"J",},੭={"7",},ᴈ={"3",},ᖰ={"p",},พ={"w","m",},۱={"i","l",},็={"r",},₦={"N",},ต={"n","a",},ᴁ={"AE",},Κ={"K",},ʊ={"u",},ᛞ={"M",},―={"-",},ᛗ={"M",},ҵ={"u",},Մ={"u",},ᛒ={"B",},ƚ={"l",},ᗩ={"A",},ᛊ={"E",},ᴜ={"U",},ᛇ={"S",},ڵ={"J",},ᚗ={"G",},չ={"Z",},ɞ={"e","B",},Ƶ={"Z",},ᚿ={"I",},ᚼ={"I",},≺={"<",},ᚹ={"P",},ᚫ={"F",},ᶏ={"a",},⊏={"c",},ε={"e",},ᑞ={"c",},ѹ={"oy",},Ƀ={"B",},ᛁ={"I",},Ҏ={"p",},⓫={"11",},ᙁ={"n",},ᙀ={"u",},ᘯ={"n",},Ᏻ={"G",},у={"u","y","Y",},ᘻ={"m",},ᘵ={"n",},г={"g","r","L",},Ճ={"bo",},ᵳ={"r",},ᘨ={"u",},ᘉ={"n",},Ꮾ={"6","G",},ᑣ={"c",},ζ={"z","s","c",},Ꭺ={"A","n",},ø={"o",},☨={"t",},ㄟ={"ei",},ᗸ={"E",},Ë={"E",},Ƚ={"L","t",},ᗴ={"E",},十={"T",},ɋ={"q","a",},ҡ={"k",},⋖={"<",},ᴘ={"P",},ݞ={"E",},㉿={"K",},ђ={"dj","h",},│={"|",},Ȣ={"d","o",},ᖇ={"R",},ᖅ={"b",},’={"'",},Ӌ={"u","y","h",},ᖁ={"d",},ʏ={"Y",},ᖀ={"p",},æ={"ae",},ڸ={"U",},Ə={"e",},ᕸ={"d",},Ϧ={"h","b",},ᕷ={"d",},∓={"T",},ᔤ={"s",},ʪ={"ls",},ᔜ={"s",},੦={"0",},⊤={"T",},ɾ={"r",},ᔕ={"s",},┯={"T",},⓯={"15",},ｘ={"X",},╋={"t","+",},ᒺ={"L",},ᒖ={"r",},Փ={"o",},ᒰ={"r",},ҏ={"p",},ᒮ={"r",},ᒫ={"L",},ᒛ={"j",},З={"E",},‡={"t","i",},ɮ={"B","k","z","3",},ᒗ={"r",},几={"N",},ᒋ={"i",},ษ={"u",},ᵿ={"A","u",},Ц={"TS","U","Li",},○={"O",},œ={"oe","ce",},ᑧ={"u",},╄={"t","+",},Ꮵ={"h",},ɓ={"b",},ɗ={"d",},Ы={"bl",},ф={"f","o",},ٮ={"u",},れ={"n",},♆={"W",},┎={"r",},ծ={"d","o",},к={"k",},Ʃ={"E",},ถ={"n","a",},Ѯ={"E",},₮={"T",},ė={"E",},ᅌ={"O",},Բ={"f",},ᅊ={"OE",},в={"v","B",},ᙅ={"c",},ݓ={"u",},[4]={"A","R",},ก={"n","a",},ǀ={"I","|",},꞉={":",},ᖸ={"u",},ડ={"s",},Ҡ={"K",},Ӷ={"L",},ݬ={"j",},ƣ={"a",},π={"p","n",},Ћ={"h",},վ={"u",},๐={"o",},Ӏ={"I",},ں={"i",},♋={"69",},Ο={"O","/",},ə={"e",},ݣ={"S",},Є={"E",},ʟ={"L",},ᴄ={"C",},Һ={"h",},Ꮙ={"v",},Ɵ={"O",},Ǝ={"E",},ʄ={"s","f",},Ͽ={"C","c","E",},Π={"P","N",},ᗗ={"A",},˶={"\"",},ᐎ={"A","n","v",},০={"0",},Ǥ={"G",},پ={"u",},ᵻ={"i",},Ȥ={"Z",},২={"2",},Ꮶ={"K",},ᑫ={"q",},∫={"s",},ᘀ={"B",},ƺ={"E","z","3",},І={"I",},Μ={"M",},Λ={"L","A","N",},Ո={"n",},°={"'","o",},ᗼ={"R",},ق={"g",},อ={"d","o",},м={"m","M",},ی={"s",},˃={">",},Ԃ={"d",},જ={"v",},ڷ={"J",},Ꭲ={"I","G","L","T",},ш={"shw",},Ӄ={"R","b","h","K",},☻={"o",},ۏ={"g",},Ԍ={"G",},˫={"l","i",},δ={"d","o",},Ɔ={"C",},א={"X","N",},˄={"^",},ŋ={"n",},ᴀ={"A",},ې={"s",},ȴ={"l",},ڄ={"c","z",},ƴ={"y",},գ={"q",},ϝ={"F",},ħ={"h","n",},⋃={"u","U",},٣={"3","r",},٩={"9","q",},Ч={"CH","u","h",},ƪ={"l",},ϫ={"a","v",},Ͼ={"C","c","E",},⋦={"<",},۝={"O",},ː={"i","¦",},϶={"e",},ا={"i","l","/","I","L","|",},Ɏ={"Y",},ʎ={"A","Y","l",},ᶐ={"q",},થ={"u",},（={"(",},ฃ={"u",},ϛ={"s",},ʙ={"B",},д={"d","A",},ม={"u","w",},ן={"i",},ɢ={"G",},Њ={"H",},Ƕ={"H",},ᑯ={"d",},ᆼ={"o",},Ь={"b","B",},Δ={"D","A",},☤={"t",},ռ={"n",},["$"]={"S",},ʔ={"?",},Ѩ={"IA","A",},ɘ={"e",},Ꮎ={"E",},Ԝ={"W",},ᔖ={"s",},ᑎ={"n",},Ⅴ={"V",},М={"M",},ɣ={"Y","v",},گ={"S",},┲={"T",},ѳ={"f","th","o","e",},➁={"2",},≫={">>",},ᅂ={"OC",},ճ={"d","o",},ǝ={"e",},ү={"u","Y","v",},§={"S",},ٳ={"i",},ѕ={"s","S",},з={"z","e","3",},ᴌ={"L",},┕={"L",},Ҕ={"b","h",},Ɉ={"J",},ɨ={"i",},இ={"I","A","O",},ɴ={"N",},ط={"b",},ᒂ={"b",},Ɣ={"Y",},♃={"u",},Է={"t",},Ԏ={"T",},ɳ={"n",},ј={"j","J",},ᑲ={"b",},ᅆ={"OA",},[3]={"E",},Ꮑ={"N",},Ϙ={"O",},ԁ={"d","D",},ݘ={"c",},υ={"u","U",},ȷ={"j","i",},ᗟ={"D",},〉={">",},˅={"v",},৮={"8",},ʉ={"u","A",},˻={",",},˦={"l","i",},Ȝ={"3","E",},➌={"3",},ʌ={"v","n","^",},ӏ={"l",},⏂={"O","T",},Ꮊ={"N",},Ａ={"A",},Ɖ={"D",},Ҭ={"T",},Ꮢ={"R",},Ꮲ={"p","P",},ۅ={"g",},ϯ={"i","t",},Ҿ={"e",},Ӡ={"3","z",},ᔒ={"s",},ҿ={"e",},ข={"u",},Ƥ={"P",},Ә={"e",},ο={"o","/","O",},丂={"S",},¤={"o","x",},⊓={"n",},ʿ={"'",},։={":",},Τ={"T",},ӻ={"f",},ƿ={"D",},Ԋ={"H",},ʤ={"dz",},Ս={"u","U",},¿={"?",},Ԑ={"E",},ʯ={"h","u",},э={"e","3",},✛={"t",},Б={"b",},Ҥ={"H",},ચ={"u",},ᛔ={"B",},ԑ={"E",},❾={"9",},Ն={"i",},ᗤ={"D",},Ð={"D",},Վ={"u",},Տ={"s","S",},ѣ={"b",},ᒆ={"p",},ը={"o","n",},ו={"i",},Ꮭ={"c",},ա={"w",},٨={"8","n",},ӕ={"ae",},[0]={"O",},đ={"d","D",},ղ={"n",},▂={"_",},Ѿ={"w",},ո={"n",},ج={"c","z",},ە={"o",},ᛈ={"C",},ڙ={"j",},κ={"k","x","K",},ᄆ={"O",},ʺ={"\"",},ք={"p",},װ={"ii",},ᶘ={"s",},ה={"n",},ҙ={"E",},Ƅ={"b",},ҟ={"k",},р={"r","p","P",},כ={"c",},Ꮆ={"G",},＾={"^",},ע={"v","u",},ฆ={"u",},ð={"d","o",},ʻ={"'",},৪={"4",},Ι={"I",},خ={"c","z",},ᶀ={"b",},Ъ={"b",},ف={"g",},Ҵ={"u",},ˮ={"\"",},و={"g",},ƙ={"k",},น={"u",},ɝ={"e","3","s",},я={"y","R",},Ӕ={"AE","E",},ڴ={"S",},❺={"5",},ٽ={"u",},ᄙ={"22",},ᑑ={"c",},ł={"l",},Ϛ={"S",},ڈ={"s","j",},ᒊ={"i",},ɂ={"?",},؟={"?",},н={"n","H",},੪={"4",},ڶ={"J",},ɹ={"r",},ᑺ={"d",},Ѹ={"Oy",},т={"t",},Ꮩ={"V","N",},ۋ={"g",},Լ={"L",},Ղ={"n",},ێ={"s",},И={"I","N",},ɸ={"o","ph","f",},Ꭿ={"A",},ᄖ={"LA","LR","LU",},ʚ={"a","d",},Э={"E",},ᵫ={"ue",},ױ={"ii",},➄={"5",},ȼ={"c",},ˊ={"'",},ᆠ={"T",},ݗ={"c",},ݙ={"S",},ϩ={"s",},เ={"i",},‐={"-",},ݢ={"S",},ݝ={"E",},ݤ={"S",},ᐃ={"A","n",},ᴑ={"O",},⊗={"o",},ᔚ={"s",},ȡ={"d",},☖={"o",},ۊ={"g",},Ђ={"h",},ĸ={"K",},√={"v",},ǥ={"g",},ᕿ={"p",},С={"S","C",},Ⱳ={"W",},ӊ={"H",},¡={"!","i",},ภ={"n","a",},ㄔ={"ch",},ϥ={"h","b","p","q",},Ш={"SH","W",},ๅ={"r",},⫻={"/",},˥={"l","i",},Ⱦ={"T",},ʩ={"fn",},９={"/",},ץ={"Y",},≧={">",},Ω={"aw","O","n",},┊={"|",},Ւ={"t","r",},ᵶ={"z",},©={"c",},ᑕ={"c",},੮={"8",},ᆷ={"o",},ᑾ={"b",},¶={"P",},Ꭻ={"j","J",},Ꮥ={"s",},ک={"S",},ᘴ={"u",},Ж={"X","K",},ҳ={"x",},ย={"u",},Ꭵ={"v","i","I",},Œ={"OE","CE",},⊊={",<",},Ꮚ={"w",},ɺ={"r","l",},ɒ={"a",},Ʉ={"U",},Ᏸ={"B",},ᐁ={"v",},٭={"*",},ᑶ={"p",},▕={"|",},}
 end)()

function utf8.upper(str)
	return utf8replace(str, upper)
end

function utf8.lower(str)
	return utf8replace(str, lower)
end

function utf8.getsimilarity(a, b)
	b = b:upper()
	local score = 0
	for i, char in ipairs(utf8.totable(a)) do
		if translate[char] then
			local test = b:usub(i, i)
			if table.hasvalue(translate[char], test) then
				score = score + 1
			end
		end
	end
	return score / #b
end

function utf8.length(str)
	local len = 0
	for i = 1, #str do
		local b = str:byte(i)
		if b < 128 or b > 191 then
			len = len + 1
		end
	end
	return len
end

utf8.len = utf8.length

function utf8.totable(str)
	local tbl = {}
	local i = 1

	for tbl_i = 1, #str do
		local byte = str:byte(i)

		if not byte then break end

		local length = 1

		if byte >= 128 then
			if byte >= 240 then
				length = 4
			elseif byte >= 224 then
				length = 3
			elseif byte >= 192 then
				length = 2
			end
		end

		tbl[tbl_i] = str:sub(i, i + length - 1)

		i = i + length
	end

	return tbl
end

for name, func in pairs(utf8) do
	string["u" .. name] = func
end

return utf8 end)() -- utf8 string library, also extends to string as utf8.len > string.ulen
profiler = (function(...) local profiler = _G.profiler or {}

profiler.data = profiler.data or {sections = {}, statistical = {}, trace_aborts = {}}
profiler.raw_data = profiler.raw_data or {sections = {}, statistical = {}, trace_aborts = {}}

local blacklist = {
	["leaving loop in root trace"] = true,
	["error thrown or hook fed during recording"] = true,
	["too many spill slots"] = true,
}

local function trace_dump_callback(what, trace_id, func, pc, trace_error_id, trace_error_arg)
	if what == "abort" then
		local info = jit.util.funcinfo(func, pc)
		table.insert(profiler.raw_data.trace_aborts, {info, trace_error_id, trace_error_arg})
	end
end

local function parse_raw_trace_abort_data()
	local data = profiler.data.trace_aborts

	for _ = 1, #profiler.raw_data.trace_aborts do
		local args = table.remove(profiler.raw_data.trace_aborts)

		local info = args[1]
		local trace_error_id = args[2]
		local trace_error_arg = args[3]

		local reason = jit.vmdef.traceerr[trace_error_id]

		if not blacklist[reason] then
			if type(trace_error_arg) == "number" and reason:find("bytecode") then
				trace_error_arg = string.sub(jit.vmdef.bcnames, trace_error_arg*6+1, trace_error_arg*6+6)
				reason = reason:gsub("(%%d)", "%%s")
			end

			reason = reason:format(trace_error_arg)

			local path = info.source
			local line = info.currentline or info.linedefined

			data[path] = data[path] or {}
			data[path][line] = data[path][line] or {}
			data[path][line][reason] = (data[path][line][reason] or 0) + 1
		end
	end
end

function profiler.EnableTraceAbortLogging(b)
	if b then
		jit.attach(function(...)
			local ok, err = xpcall(type(b) == "function" and b or trace_dump_callback, system.OnError, ...)
			if not ok then
				logn(err)
				profiler.EnableTraceAbortLogging(false)
			end
		end, "trace")
	else
		jit.attach(trace_dump_callback)
	end
end

local function parse_raw_statistical_data()
	local data = profiler.data.statistical

	for _ = 1, #profiler.raw_data.statistical do
		local args = table.remove(profiler.raw_data.statistical)
		local str, samples, vmstate = args[1], args[2], args[3]
		local children = {}

		for line in str:gmatch("(.-)\n") do
			local path, line_number = line:match("(.+):(%d+)")

			if not path and not line_number then
				line = line:gsub("%[builtin#(%d+)%]", function(x) return jit.vmdef.ffnames[tonumber(x)] end)
				table.insert(children, {name = line or -1, external_function = true})
			else
				table.insert(children, {path = path, line = tonumber(line_number) or -1, external_function = false})
			end
		end

		local info = children[#children]
		table.remove(children, #children)

		local path = info.path or info.name
		local line = tonumber(info.line) or -1

		data[path] = data[path] or {}
		data[path][line] = data[path][line] or {total_time = 0, samples = 0, children = {}, parents = {}, ready = false, func_name = path, vmstate = vmstate}

		data[path][line].samples = data[path][line].samples + samples
		data[path][line].start_time = data[path][line].start_time or system.GetTime()

		local parent = data[path][line]

		for _, info in ipairs(children) do
			local path = info.path or info.name
			local line = tonumber(info.line) or -1

			data[path] = data[path] or {}
			data[path][line] = data[path][line] or {total_time = 0, samples = 0, children = {}, parents = {}, ready = false, func_name = path, vmstate = vmstate}

			data[path][line].samples = data[path][line].samples + samples
			data[path][line].start_time = data[path][line].start_time or system.GetTime()

			data[path][line].parents[tostring(parent)] = parent
			parent.children[tostring(data[path][line])] = data[path][line]

			--table.insert(data[path][line].parents, parent)
			--table.insert(parent.children, data[path][line])
		end
	end
end

local function statistical_callback(thread, samples, vmstate)
	local str = jit.profiler.dumpstack(thread, "pl\n", 1000)
	table.insert(profiler.raw_data.statistical, {str, samples, vmstate})
end

function profiler.EnableStatisticalProfiling(b)
	profiler.busy = b
	if b then
		jit.profiler.start("li0", function(...)
			local ok, err = pcall(statistical_callback, ...)
			if not ok then
				logn(err)
				profiler.EnableStatisticalProfiling(false)
			end
		end)
	else
		jit.profiler.stop()
	end
end

do
	local started = false

	function profiler.ToggleStatistical()
		if not started then
			profiler.EnableStatisticalProfiling(true)
			started = true
		else
			profiler.EnableStatisticalProfiling(false)
			profiler.PrintStatistical(0)
			started = false
			profiler.Restart()
		end
	end
end

function profiler.Restart()
	profiler.data = {sections = {}, statistical = {}, trace_aborts = {}}
	profiler.raw_data = {sections = {}, statistical = {}, trace_aborts = {}}
end

do
	local stack = {}
	local enabled = false
	local i = 0

	function profiler.PushSection(section_name)
		if not enabled then return end

		local info = debug.getinfo(3)
		local start_time = system.GetTime()

		table.insert(stack, {
			section_name = section_name,
			start_time = start_time,
			info = info,
			level = #stack,
		})
	end

	function profiler.PopSection()
		if not enabled then return end

		local res = table.remove(stack)

		if res then
			local time = system.GetTime() - res.start_time
			local path, line = res.info.source, res.info.currentline
			if type(res.section_name) == "string" then line = res.section_name end

			local data = profiler.data.sections

			data[path] = data[path] or {}
			data[path][line] = data[path][line] or {total_time = 0, samples = 0, name = res.section_name, section_name = res.section_name, instrumental = true, section = true}

			data[path][line].total_time = data[path][line].total_time + time
			data[path][line].samples = data[path][line].samples + 1
			data[path][line].level = res.level
			data[path][line].start_time = res.start_time
			data[path][line].i = i

			i = i + 1

			return time
		end
	end

	function profiler.RemoveSection(name)
		profiler.data.sections[name] = nil
	end

	function profiler.EnableSectionProfiling(b, reset)
		enabled = b
		if reset then table.clear(profiler.data.sections) end
		table.clear(stack)
	end

	profiler.PushSection()
	profiler.PopSection()
end

do -- timer
	local stack = {}

	function profiler.StartTimer(str, ...)
		table.insert(stack, {str = str and str:format(...), level = #stack})
		local last = stack[#stack]
		last.time = system.GetTime() -- just to make sure there's overhead with table.insert and whatnot
	end

	function profiler.StopTimer(no_print)
		local time = system.GetTime()
		local data = table.remove(stack)
		local delta = time - data.time

		if not no_print then
			logf("%s%s: %1.22f\n", (" "):rep(data.level-1), data.str, math.round(delta, 5))
		end

		return delta
	end

	function profiler.ToggleTimer(val)
		if started then
			started = false
			return profiler.StopTimer(val == true)
		else
			started = true
			return profiler.StartTimer(val)
		end
	end
end

function profiler.GetBenchmark(type, file, dump_line)

	local benchmark_time
	if profiler.start_time and profiler.stop_time then
		benchmark_time = profiler.stop_time - profiler.start_time
	end

	if type == "statistical" then
	 	parse_raw_statistical_data()
	end

	local out = {}

	for path, lines in pairs(profiler.data[type]) do
		if path:startswith("@") then
			path = path:sub(2)
		end

		if not file or path:find(file) then
			for line, data in pairs(lines) do
				line = tonumber(line) or line

				local name = "unknown(file not found)"
				local debug_info

				if data.func then
					debug_info = debug.getinfo(data.func)

					-- remove some useless fields
					debug_info.source = nil
					debug_info.short_src = nil
					debug_info.currentline = nil
					debug_info.func = nil
				end

				if dump_line then
					local content = vfs.Read(path)

					if content then
						name = content:split("\n")[line]
						if name then
							name = name:gsub("function ", "")
							name = name:trim()
						end
					end
				elseif data.func then
					name = ("%s(%s)"):format(data.func_name, table.concat(debug.getparams(data.func), ", "))
				else
					local full_path = R(path) or path
					name = full_path .. ":" .. line
				end

				if data.section_name then
					data.section_name = data.section_name:match(".+lua/(.+)") or data.section_name
				end

				if name:find("\n", 1, true) then
					name = name:gsub("\n", "")
					name = name:sub(0, 50)
				end

				name = name:trim()
				data.path = path
				data.file_name = path:match(".+/(.+)%.") or path
				data.line = line
				data.name = name
				data.debug_info = debug_info
				data.ready = true

				if data.total_time then
					data.average_time = data.total_time / data.samples
					--data.total_time = data.average_time * data.samples
				end

				if benchmark_time then
					data.fraction_time = data.total_time / benchmark_time
				end

				data.start_time = data.start_time or 0
				data.samples = data.samples or 0

				data.sample_duration = system.GetTime() - data.start_time
				data.times_called = data.samples

				table.insert(out, data)
			end
		end
	end

	return out
end


function profiler.PrintTraceAborts(min_samples)
	min_samples = min_samples or 500

	parse_raw_statistical_data()
	parse_raw_trace_abort_data()

	logn("trace abort reasons for functions that were sampled by the profiler more than ", min_samples, " times:")

	local blacklist = {
		["NYI: return to lower frame"] = true,
		["inner loop in root trace"] = true,
		["blacklisted"] = true,
	}

	for path, lines in pairs(profiler.data.trace_aborts) do
		path = path:sub(2)

		local s = profiler.data.statistical

		if s[path] or not next(s) then
			local full_path = R(path) or path
			full_path = full_path:replace("../../../", e.CORE_FOLDER)
			full_path = full_path:lower():replace(e.ROOT_FOLDER:lower(), "")

			local temp = {}

			for line, reasons in pairs(lines) do
				if not next(s) or s[path][line] and s[path][line].samples > min_samples then
					local str = "unknown line"

					local content, err = vfs.Read(e.ROOT_FOLDER .. path)

					if content then
						local lines = content:split("\n")
						str = lines[line]
						str = "\"" .. str:trim() .. "\""
					else
						str = err
					end

					for reason, count in pairs(reasons) do
						if not blacklist[reason] then
							table.insert(temp, "\t\t" .. reason:trim() .. " (x" .. count .. ")")
							table.insert(temp, "\t\t\t" .. line .. ": " .. str)
						end
					end
				end
			end

			if #temp > 0 then
				logn("\t", full_path)
				logn(table.concat(temp, "\n"))
			end
		end
	end
end

function profiler.PrintSections()
	log(utility.TableToColumns(
		"sections",
		profiler.GetBenchmark("sections"),
		{
			{key = "times_called", friendly = "calls"},
			{key = "name", tostring = function(val, column) return ("    "):rep(column.level - 1) .. tostring(val) end},
			{key = "average_time", friendly = "time", tostring = function(val) return math.round(val * 100 * 100, 3) end},
		},
		function(a) return a.times_called > 50 end,
		"i"
	))
end

function profiler.PrintStatistical(min_samples)
	min_samples = min_samples or 100

	local tr = {
		N = "native",
		I = "interpreted",
		G = "garbage collector",
		J = "JIT compiler",
		C = "C",
	}

	log(utility.TableToColumns(
		"statistical",
		profiler.GetBenchmark("statistical"),
		{
			{key = "name"},
			{key = "times_called", friendly = "percent", tostring = function(val, column, columns)  return math.round((val / columns[#columns].val.times_called) * 100, 2) end},
			{key = "vmstate", tostring = function(str)
				return tr[str]
			end},
		},
		function(a) return a.name and a.times_called > min_samples end,
		function(a, b) return a.times_called < b.times_called end
	))
end

function profiler.StartInstrumental(file_filter, method)
	method = method or "cr"
	profiler.EnableSectionProfiling(true, true)
	profiler.busy = true

	local last_info
	debug.sethook(function(what, line)
		local info = debug.getinfo(2)

		if not file_filter or not info.source:find(file_filter, nil, true) then
			if what == "call" then
				if last_info and last_info.what == "C" then
					profiler.PopSection()
				end
				local name
				if info.what == "C" then
					name = info.name
					if not name then
						name = ""
					end
					local info = debug.getinfo(3)
					name = name .. " " .. info.source .. ":" .. info.currentline
				end
				profiler.PushSection(name)
			elseif what == "return"  then
				profiler.PopSection()
			end
		end
		last_info = info
	end, method)

	profiler.start_time = system.GetTime()
end

function profiler.StopInstrumental(file_filter, show_everything)
	profiler.EnableSectionProfiling(false)

	profiler.stop_time = system.GetTime()

	profiler.busy = false
	debug.sethook()
	profiler.PopSection()

	log(utility.TableToColumns(
		"instrumental",
		profiler.GetBenchmark("sections"),
		{
			{key = "times_called", friendly = "calls"},
			{key = "name"},
			{key = "average_time", friendly = "time", tostring = function(val) return ("%f"):format(val) end},
			{key = "total_time", friendly = "total time", tostring = function(val) return ("%f"):format(val) end},
			{key = "fraction_time", friendly = "percent", tostring = function(val) return math.round(val * 100, 2) end},
		},
		function(a) return show_everything or a.average_time > 0.5 or (file_filter or a.times_called > 100) end,
		function(a, b) return a.total_time < b.total_time end
	))
end

do
	local started = false

	function profiler.ToggleInstrumental(file_filter, method)
		if file_filter == "" then file_filter = nil end

		if not started then
			profiler.StartInstrumental(file_filter, method)
			started = true
		else
			profiler.StopInstrumental(file_filter, true)
			started = false
		end
	end
end

function profiler.MeasureInstrumental(time, file_filter, show_everything)
	profiler.StartInstrumental(file_filter)

	event.Delay(time, function()
		profiler.StopInstrumental(file_filter, show_everything)
	end)
end

function profiler.DumpZerobraneProfileTree(min, filter)
	min = min or 1
	local huh = serializer.ReadFile("msgpack", "zerobrane_statistical.msgpack")
	local most_samples
	local path, root
	for k,v in pairs(huh) do
		most_samples = most_samples or v
		if v.samples >= most_samples.samples then
			most_samples = v
			path = k
			root = v
		end
	end

	local level = 0

	local function dump(path, node)
		local percent = math.round((node.samples / root.samples) * 100, 3)
		if percent > min then
			if not filter or path:find(filter) then
				logf("%s%s (%s) %s\n", ("\t"):rep(level), percent, node.samples, path)
			else
				logf("%s%s\n", ("\t"):rep(level), "...")
			end

			for path, child in pairs(node.children) do
				level = level + 1
				dump(path, child)
				level = level - 1
			end
		end
	end

	dump(path, root)
end

function profiler.IsBusy()
	return profiler.busy
end

local blacklist = {
	["NYI: return to lower frame"] = true,
	["inner loop in root trace"] = true,
	["leaving loop in root trace"] = true,
	["blacklisted"] = true,
	["too many spill slots"] = true,
	["down-recursion, restarting"] = true,
}

function profiler.EnableRealTimeTraceAbortLogging(b)
	if b then
		local last_log
		jit.attach(function(what, trace_id, func, pc, trace_error_id, trace_error_arg)
			if what == "abort" then
				local info = jit.util.funcinfo(func, pc)
				local reason = jit.vmdef.traceerr[trace_error_id]

				if not blacklist[reason] then
					if type(trace_error_arg) == "number" and reason:find("bytecode") then
						trace_error_arg = string.sub(jit.vmdef.bcnames, trace_error_arg*6+1, trace_error_arg*6+6)
						reason = reason:gsub("(%%d)", "%%s")
					end

					reason = reason:format(trace_error_arg)

					local path = info.source
					local line = info.currentline or info.linedefined
					local content = vfs.Read(e.ROOT_FOLDER .. path:sub(2)) or vfs.Read(path:sub(2))

					local str

					if content then
						str = string.format("%s:%s\n%s:--\t%s\n\n", path:sub(2):replace(e.ROOT_FOLDER, ""), line, content:split("\n")[line]:trim(), reason)
					else
						str = string.format("%s:%s:\n\t%s\n\n", path, line, reason)
					end

					if str ~= last_log then
						log(str)
						last_log = str
					end
				end
			end
		end, "trace")
	else
		jit.attach(function() end)
	end
end

local system_GetTime = system.GetTime

function profiler.MeasureFunction(func, count, name, no_print)
	count = count or 1
	name = name or "measure result"

	local total_time = 0

	for _ = 1, count do
		local time = system_GetTime()
		jit.tracebarrier()
		func()
		jit.tracebarrier()
		total_time = total_time + system_GetTime() - time
	end

	if not no_print then
		logf("%s: average: %1.22f total: %f\n", name, total_time / count, total_time)
	end

	return total_time, func
end

function profiler.MeasureFunctions(tbl, count)
	local res = {}
	for name, func in pairs(tbl) do
		table.insert(res, {time = profiler.MeasureFunction(func, count, name, true), name = name})
	end
	table.sort(res, function(a, b) return a.time < b.time end)
	for i,v in ipairs(res) do
		logf("%s: average: %1.22f total: %f\n", v.name, v.time / count, v.time)
	end
end

function profiler.Compare(old, new, count)
	profiler.MeasureFunction(old, count, "OLD")
	profiler.MeasureFunction(new, count, "NEW")
end

profiler.Restart()

return profiler
 end)() -- for profiling

if THREAD then return end

-- tries to load all addons
-- some might not load depending on its info.lua file.
-- for instance: "load = CAPSADMIN ~= nil," will make it load
-- only if the CAPSADMIN constant is not nil.
-- this will skip the src folder though
vfs.MountAddons(e.ROOT_FOLDER)

if not CLI then
	logn("[runfile] ", os.clock() - start_time," seconds spent in core/lua/init.lua")
end


do -- autorun
	-- call goluwa/*/lua/init.lua if it exists
	vfs.InitAddons()

	-- load everything in goluwa/*/lua/autorun/*
	vfs.AutorunAddons()

	-- load everything in goluwa/*/lua/autorun/*USERNAME*/*
	vfs.AutorunAddons(e.USERNAME .. "/")
end

e.CLI_TIME = tonumber(os.getenv("GOLUWA_CLI_TIME")) or -1
e.BOOT_TIME = tonumber(os.getenv("GOLUWA_BOOT_TIME")) or -1
e.INIT_TIME = os.clock() - start_time
e.BOOTIME = os.clock()

event.Call("Initialize")

if not CLI then
	logn("[runfile] total init time took ", os.clock() - start_time, " seconds to execute")
end
system.MainLoop()

event.Call("ShutDown")
collectgarbage()
collectgarbage() -- https://stackoverflow.com/questions/28320213/why-do-we-need-to-call-luas-collectgarbage-twice
os.realexit(os.exitcode)
