if not jit then return end

local out = {
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
	local str = {}
	jit.bc.dump(func, {flush = function() end, write = function(_, s) str[#str + 1] = s end}, true)

	return table.concat(str)
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
end