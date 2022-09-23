local nl = require("nattlua")

local function check(config, input, expect)
	expect = expect or input
	expect = expect:gsub("    ", "\t")
	config = config or {}

	if config.comment_type_annotations == nil then
		config.comment_type_annotations = false
	end

	local new_lua_code = assert(nl.Compiler(input, nil, config):Emit())

	if new_lua_code ~= expect then diff(new_lua_code, expect) end

	equal(new_lua_code, expect, 2)
end

local function identical(str)
	check({preserve_whitespace = false}, str)
end

check(
	{preserve_whitespace = false, force_parenthesis = true, string_quote = "\""},
	[[local foo = aaa 'aaa'-- dawdwa
local x = 1]],
	[[local foo = aaa("aaa") -- dawdwa
local x = 1]]
)
check({preserve_whitespace = false, string_quote = "\""}, [[local x = "'"]])
check({preserve_whitespace = false, string_quote = "'"}, [[local x = '"']])
identical([[x = "" -- foo]])
identical([[new_str[i] = "\\" .. c]])
identical([[local x = "\xFE\xFF\n\u{1F602}\t\t1"]])
check(
	{preserve_whitespace = false, comment_type_annotations = true},
	[[local type x = ""]],
	[=[--[[#local type x = ""]]]=]
)
check({string_quote = "'"}, [[x = "foo"]], [[x = 'foo']])
check({string_quote = "\""}, [[x = 'foo']], [[x = "foo"]])
check({string_quote = "\"", preserve_whitespace = false}, [[x = '\"']], [[x = "\""]])
check({string_quote = "\""}, [[x = '"foo"']], [[x = "\"foo\""]])
check({preserve_whitespace = false}, [[x         = 
	
	1]], [[x = 1]])
check({no_semicolon = true}, [[x = 1;]], [[x = 1]])
check(
	{no_semicolon = true},
	[[
x = 1;
x = 2;--lol
x = 3;
]],
	[[
x = 1
x = 2--lol
x = 3
]]
)
check(
	{
		extra_indent = {StartSomething = {to = "EndSomething"}},
		preserve_whitespace = false,
	},
	[[
x = 1
StartSomething()
x = 2
x = 3
EndSomething()
x = 4
]],
	[[
x = 1
StartSomething()
	x = 2
	x = 3
EndSomething()
x = 4]]
)
check(
	{
		extra_indent = {StartSomething = {to = "EndSomething"}},
		preserve_whitespace = false,
	},
	[[
x = 1
pac.StartSomething()
x = 2
x = 3
pac.EndSomething()
x = 4
]],
	[[
x = 1
pac.StartSomething()
	x = 2
	x = 3
pac.EndSomething()
x = 4]]
)
identical([==[local x = {[ [[foo]] ] = "bar"}]==])
check(
	{preserve_whitespace = false},
	[==[local x = a && b || c && a != c || !c]==],
	[==[local x = a and b or c and a ~= c or not c]==]
)
identical([[local escape_char_map = {
	["\\"] = "\\\\",
	["\""] = "\\\"",
	["\b"] = "\\b",
	["\f"] = "\\f",
	["\n"] = "\\n",
	["\r"] = "\\r",
	["\t"] = "\\t",
}]])
identical([==[--[#[analyzer function coroutine.wrap(cb: Function) end]]]==])
identical([[local tbl = {
	foo = true,
	foo = true,
	foo = true,
	foo = true,
	foo = true,
	foo = true,
	foo = true,
	foo = true,
	foo = true,
}]])
-- TODO, double indent because of assignment and call
identical([[pos, ang = LocalToWorld(
	lexer.Position or Vector(),
	lexer.Angles or Angle(),
	pos or owner:GetPos(),
	ang or owner:GetAngles()
)]])
identical([[if not ply.pac_cameras then return end]])
check(
	{preserve_whitespace = false, comment_type_annotations = true},
	[=[--[[#type Vector.__mul = function=(Vector, number | Vector)>(Vector)]]]=]
)
check(
	{preserve_whitespace = false, comment_type_annotations = true},
	[=[--[[#type start = function=(...string)>(nil)]]]=]
)
check(
	{preserve_whitespace = false, comment_type_annotations = true},
	[[return {lol = Partial<|{foo = true}|>}]],
	[=[return {lol = --[[#Partial<|{foo = true}|>]]nil}]=]
)
check(
	{
		preserve_whitespace = false,
		comment_type_annotations = true,
		omit_invalid_code = true,
	},
	[[return {lol = Partial<|{foo = true}|>}]],
	[[return {lol = nil}]]
)
check(
	{
		preserve_whitespace = false,
		comment_type_annotations = true,
		omit_invalid_code = true,
	},
	[[local lol = Partial<|{foo = true}|>]],
	[[local lol = nil]]
)
check(
	{
		preserve_whitespace = false,
		comment_type_annotations = true,
		omit_invalid_code = true,
	},
	[[lol = Partial<|{foo = true}|>]],
	[[lol = nil]]
)
check(
	{
		preserve_whitespace = false,
		comment_type_annotations = true,
		omit_invalid_code = true,
	},
	[[x = {...todo, ...fieldsToUpdate, foo = true}]],
	[[x = table.mergetables{todo, fieldsToUpdate, {foo = true}}]]
)
check(
	{
		preserve_whitespace = false,
		comment_type_annotations = true,
		omit_invalid_code = false,
	},
	[[x = {...todo, ...fieldsToUpdate, foo = true}]],
	[[x = {...todo, ...fieldsToUpdate, foo = true}]]
)
check(
	{
		preserve_whitespace = false,
		comment_type_annotations = true,
		omit_invalid_code = true,
	},
	[[foo<|"lol"|>]],
	[[]]
)
check(
	{preserve_whitespace = false, type_annotations = true},
	[=[local type x = (...,)]=]
)
check(
	{
		preserve_whitespace = false,
		comment_type_annotations = true,
		type_annotations = true,
	},
	[=[local args--[[#: List<|string | List<|string|>|>]]]=]
)
check(
	{
		preserve_whitespace = false,
		comment_type_annotations = true,
		type_annotations = true,
	},
	[=[return function()--[[#: number]] end]=]
)
check(
	{
		preserve_whitespace = false,
		comment_type_annotations = true,
		type_annotations = true,
	},
	[=[--[[#analyzer function load(code: string | function=()>(string | nil), chunk_name: string | nil) end]]]=]
)
identical([[local x = lexer.OnDraw and
	(
		draw_type == "viewmodel" or
		draw_type == "hands" or
		(
			(
				lexer.Translucent == true or
				lexer.force_translucent == true
			)
			and
			draw_type == "translucent"
		)
		or
		(
			(
				lexer.Translucent == false or
				lexer.force_translucent == false
			)
			and
			draw_type == "opaque"
		)
	)]])
identical([[local cond = key ~= "ParentUID" and
	key ~= "ParentName" and
	key ~= "UniqueID" and
	(
		key ~= "AimPartName" and
		not (
			pac.PartNameKeysToIgnore and
			pac.PartNameKeysToIgnore[key]
		)
		or
		key == "AimPartName" and
		table.HasValue(pac.AimPartNames, value)
	)]])
identical([[ent = pac.HandleOwnerName(
		lexer:GetPlayerOwner(),
		lexer.OwnerName,
		ent,
		lexer,
		function(e)
			return e.pac_duplicate_attach_uid ~= lexer.UniqueID
		end
	) or
	NULL]])
identical([[render.OverrideBlendFunc(
	true,
	lexer.blend_override[1],
	lexer.blend_override[2],
	lexer.blend_override[3],
	lexer.blend_override[4]
)

foo(function() end)

foo(function() end)

pac.AimPartNames = {
	["local eyes"] = "LOCALEYES",
	["player eyes"] = "PLAYEREYES",
	["local eyes yaw"] = "LOCALEYES_YAW",
	["local eyes pitch"] = "LOCALEYES_PITCH",
}]])
identical([[return function(config)
	local self = setmetatable({}, META)
	self.config = config or {}
	self:Initialize()
	return self
end]])
identical([[if
	val == "string" or
	val == "number" or
	val == "boolean" or
	val == "true" or
	val == "false" or
	val == "nil"
then

end]])
identical([[function META:IsShortIfStatement(node)
	return #node.statements == 1 and
		node.statements[1][1] and
		is_short_statement(node.statements[1][1].kind) and
		not self:ShouldBreakExpressionList({node.expressions[1]})
end]])
identical([[local x = val == "string" or
	val == "number" or
	val == "boolean" or
	val == "true" or
	val == "false" or
	val == "nil"]])
identical([[if true then return end]])
identical([[ok, err = pcall(function()
	s = s .. tostring(node)
end)]])
identical([[local str = {}

for i = 1, select("#", ...) do
	str[i] = tostring(select(i, ...))
end]])
identical([[if
	scope.node and
	scope.node.inferred_type and
	scope.node.inferred_type.Type == "function" and
	not scope:Contains(from)
then
	return not scope.node.inferred_type:IsCalled()
end]])
identical([[if upvalue:IsImmutable() then
	return self:Error({"cannot assign to const variable ", key})
end]])
identical([[if self:IsRuntime() then
	return self:GetMutatedUpvalue(upvalue) or upvalue:GetValue()
end]])
identical([[if line then str = 1 else str = 2 end]])
identical([[if t > 0 then msg = "\n" .. msg end]])
identical([[return function()
	if obj.Type == "upvalue" then union:SetUpvalue(obj) end
end]])
identical([[local foo = {
	x = 1,
	y = 2,
	z = 3,
	z = 3,
	z = 3,
	z = 3,
	z = 3,
	z = 3,
	z = 3,
	z = 3,
	z = 3,
}
local foo = function()
	for i = 1, 100 do

	end
end
local foo = x(
	{
		x = 1,
		y = 2,
		z = 3,
		z = 3,
		z = 3,
		z = 3,
		z = 3,
		z = 3,
		z = 3,
		z = 3,
		z = 3,
	}
)]])
identical([[local union = stack[#stack].falsy --:Copy()
if obj.Type == "upvalue" then union:SetUpvalue(obj) end

if not ok then
	print("DebugStateString: failed to render node: " .. tostring(err))
	ok, err = pcall(function()
		s = s .. tostring(node)
	end)

	if not ok then
		print("DebugStateString: failed to tostring node: " .. tostring(err))
		s = s .. "* error in rendering statement * "
	end
end]])
identical([[setmetatable(
	{
		Code = Code(lua_code, name),
		parent_line = parent_line,
		parent_name = parent_name,
		config = config,
		Lexer = requirew("nattlua.lexer"),
		Parser = requirew("nattlua.parser"),
		Analyzer = requirew("nattlua.analyzer"),
		Emitter = config and
			config.js and
			requirew("nattlua.transpiler.javascript_emitter") or
			requirew("nattlua.transpiler.emitter"),
	},
	META
)]])
identical([[if not ok then
	assert(err)
	return ok, err
end]])
identical([[return {
	AnalyzeImport = function(self, node)
		local args = self:AnalyzeExpressions(node.expressions)
		return self:AnalyzeRootStatement(node.root, table.unpack(args))
	end,
}]])
identical([[local foo = 1
-- hello
-- world
local union = stack[#stack].falsy --:Copy()
local x = 1]])
identical([[return {
	AnalyzeContinue = function(self, statement)
		self._continue_ = true
	end,
}]])
identical([[if name:sub(1, 1) == "@" then -- is this a name that is a location?
	local line, rest = msg:sub(#name):match("^:(%d+):(.+)") -- remove the file name and grab the line number
end

-- foo
-- bar
local foo = aaa'aaa' -- dawdwa
local x = 1]])
identical([=[local type { 
	ExpressionKind,
	StatementKind,
	FunctionAnalyzerStatement,
	FunctionTypeStatement,
	FunctionAnalyzerExpression,
	FunctionTypeExpression,
	FunctionExpression,
	FunctionLocalStatement,
	FunctionLocalTypeStatement,
	FunctionStatement,
	FunctionLocalAnalyzerStatement,
	ValueExpression
 } = importawd("~/nattlua/parser/nodes.nlua")]=])
check(
	{
		preserve_whitespace = false,
		comment_type_annotations = true,
		type_annotations = true,
	},
	[=[function META:OnError(
	code--[[#: Code]],
	message--[[#: string]],
	start--[[#: number]],
	stop--[[#: number]],
	...--[[#: ...any]]
) end]=]
)
identical([[local type Context = {
	tab = number,
	tab_limit = number,
	done = Table,
}]])
check(
	{
		preserve_whitespace = false,
		comment_type_annotations = true,
		type_annotations = true,
	},
	[=[--[[#type coroutine = {
	create = function=(empty_function)>(thread),
	close = function=(thread)>(boolean, string),
	isyieldable = function=()>(boolean),
	resume = function=(thread, ...)>(boolean, ...),
	running = function=()>(thread, boolean),
	status = function=(thread)>(string),
	wrap = function=(empty_function)>(empty_function),
	yield = function=(...)>(...),
}]]]=]
)
identical([[return {
	character_start = character_start or 0,
	character_stop = character_stop or 0,
	sub_line_before = {within_start + 1, start - 1},
	sub_line_after = {stop + 1, within_stop - 1},
	line_start = line_start or 0,
	line_stop = line_stop or 0,
}]])
identical([[return function(config)
	config = config or {}
	local self = setmetatable({config = config}, META)

	for _, func in ipairs(META.OnInitialize) do
		func(self)
	end

	return self
end]])
identical([[
local name = ReadSpace(self) or
	ReadCommentEscape(self) or
	ReadMultilineCComment(self) or
	ReadLineCComment(self) or
	ReadMultilineComment(self) or
	ReadLineComment(self)]])
identical([[do
	while
		runtime_syntax:GetBinaryOperatorInfo(self:GetToken()) and
		runtime_syntax:GetBinaryOperatorInfo(self:GetToken()).left_priority > priority
	do

	end
end]])
check(
	{
		preserve_whitespace = false,
		comment_type_annotations = true,
		type_annotations = true,
	},
	[=[if B.Type == "tuple" then B = (B--[[# as any]]):Get(1) end]=]
)
check(
	{
		preserve_whitespace = false,
		comment_type_annotations = true,
		type_annotations = true,
	},
	[=[return ffi.string(A, (B)--[[# as number]])
return ffi.string(A, (((B))--[[# as number]]))
return ffi.string(A, (B--[[# as number]]))]=]
)
check(
	{
		preserve_whitespace = false,
		comment_type_annotations = true,
		type_annotations = true,
	},
	[=[--[[#£parser.config.skip_import = true]]

local x = import("platforms/windows/filesystem.nlua")]=]
)
identical([[hook.Add("Foo", "bar_foo", function(ply, pos)
    for i = 1, 10 do
        ply:SetPos(pos + VectorRand())
    end
end)]])
identical([=[run[[
aw
d
aw
dawd
]]]=])
identical([=[run([[
aw
d
aw
dawd
]])]=])
identical([[local x = "\xFE\xFF"]])
check(
	{string_quote = "\""},
	[[
	code = code:gsub('\\"', "____DOUBLE_QUOTE_ESCAPE")
]],
	[[
	code = code:gsub("\\\"", "____DOUBLE_QUOTE_ESCAPE")
]]
)
check(
	{string_quote = "\""},
	[[
	code = code:gsub('\\\"', "____DOUBLE_QUOTE_ESCAPE")
]],
	[[
	code = code:gsub("\\\"", "____DOUBLE_QUOTE_ESCAPE")
]]
)
check(
	{string_quote = "\""},
	[[
	code = code:gsub('\\\\"', "____DOUBLE_QUOTE_ESCAPE")
]],
	[[
	code = code:gsub("\\\\\"", "____DOUBLE_QUOTE_ESCAPE")
]]
)