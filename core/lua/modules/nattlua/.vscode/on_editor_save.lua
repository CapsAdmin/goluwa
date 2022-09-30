_G.ON_EDITOR_SAVE = true
local nl = require("nattlua")
local did_something = false

local function run_lua(path, ...)
	did_something = true
	print("running ", path, ...)
	assert(loadfile(path))(...)
end

local function run_nattlua(path)
	did_something = true

	if io.open(path, "r"):read("*all"):find("%-%-%s-PLAIN_LUA") then
		return assert(loadfile(path))()
	end

	local f = assert(io.open(path, "r"))
	local lua_code = f:read("*all")
	f:close()
	local c = assert(
		nl.File(
			path,
			{
				type_annotations = true,
			--inline_require = lua_code:find("%-%-%s-INLINE_REQUIRE") ~= nil,
			--emit_environment = true,
			}
		)
	)
	local preserve_whitespace = nil

	if lua_code:find("%-%-%s-PRETTY_PRINT") then preserve_whitespace = false end

	if lua_code:find("%-%-%s-VERBOSE_STACKTRACE") then c.debug = true end

	if lua_code:find("%-%-%s-DISABLE_BASE_ENV") then
		_G.DISABLE_BASE_ENV = true
	end

	if lua_code:find("%-%-%s-PROFILE") then require("jit.p").start("Flp") end

	local ok, err

	if not lua_code:find("%-%-%s-DISABLE_ANALYSIS") then ok, err = c:Analyze() end

	if lua_code:find("--DISABLE_BASE_ENV", nil, true) then
		_G.DISABLE_BASE_ENV = nil
	end

	if lua_code:find("%-%-%s-PROFILE") then require("jit.p").stop() end

	if not ok and err then
		io.write(err, "\n")
		return
	end

	local res = assert(
		c:Emit(
			{
				preserve_whitespace = preserve_whitespace,
				string_quote = "\"",
				no_semicolon = true,
				transpile_extensions = lua_code:find("%-%-%s-TRANSPILE_EXTENSIONS") ~= nil,
				comment_type_annotations = lua_code:find("%-%-%s-COMMENT_TYPE_ANNOTATIONS") ~= nil,
				type_annotations = true,
				force_parenthesis = true,
				omit_invalid_code = lua_code:find("%-%-%s-OMIT_INVALID_LUA_CODE") ~= nil,
				extra_indent = {
					Start = {to = "Stop"},
					Toggle = "toggle",
				},
			}
		)
	)

	if lua_code:find("%-%-%s-ENABLE_CODE_RESULT_TO_FILE") then
		local f = assert(io.open("test_focus_result.lua", "w"))
		f:write(res)
		f:close()
	elseif lua_code:find("%-%-%s-ENABLE_CODE_RESULT") then
		io.write("== code result ==\n")

		if lua_code:find("%-%-%s-SHOW_NEWLINES") then
			res = res:gsub("\n", "⏎\n")
		end

		io.write(res, "\n")
		io.write("=================\n")
	end

	if lua_code:find("%-%-%s-RUN_CODE") then assert(load(res))() end
end

local function has_test_focus()
	local f = io.open("test_focus.nlua")

	if not f or (f and #f:read("*all") == 0) then
		if f then f:close() end

		return false
	end

	return true
end

local path = ...
local normalized = path:lower():gsub("\\", "/")

if normalized:find("on_editor_save.lua", nil, true) then return end

if normalized:find("/nattlua/", nil, true) then
	if not path then error("no path") end

	local is_lua = path:sub(-4) == ".lua"
	local is_nattlua = path:sub(-5) == ".nlua"

	if not is_lua and not is_nattlua then return end

	if normalized:find("other/coverage", nil, true) then
		run_lua("test/run.lua", "test/nattlua/coverage.lua")
	elseif normalized:find("language_server/server", nil, true) then
		os.execute("luajit build.lua fast && luajit install.lua")
		return
	elseif normalized:find("typed_ffi.nlua", nil, true) and has_test_focus() then
		print("running test focus")
		run_nattlua("./test_focus.nlua")
	elseif normalized:find("lint.lua", nil, true) then
		run_lua(path)
	elseif normalized:find("build_glua_base.lua", nil, true) then
		run_lua(path)
	elseif
		normalized:find("examples/projects/luajit/", nil, true) or
		normalized:find("cparser.lua", nil, true)
	then
		run_lua("examples/projects/luajit/build.lua", path)
	elseif normalized:find("examples/projects/gmod/", nil, true) then
		run_lua("examples/projects/gmod/nattlua.lua", path)
	elseif normalized:find("examples/projects/love2d/", nil, true) then
		run_lua("examples/projects/love2d/nlconfig.lua", path)
	elseif is_nattlua and not normalized:find("/definitions/", nil, true) then
		run_nattlua(path)
	elseif normalized:find("helpers.lua", nil, true) then
		run_lua("test/run.lua", "test/nattlua/helper_test.lua")
	elseif normalized:find("test/", nil, true) then
		run_lua("test/run.lua", path)
	elseif normalized:find("javascript_emitter") then
		run_lua("./examples/lua_to_js.lua")
	elseif normalized:find("examples/", nil, true) then
		run_lua(path)
	elseif has_test_focus() then
		print("running test focus")
		run_nattlua("./test_focus.nlua")
	elseif
		(
			normalized:find("/nattlua/nattlua/", nil, true) or
			normalized:find("/nattlua/nattlua.lua", nil, true)
		) and
		not normalized:find("nattlua/other")
	then
		if normalized:find("lexer.lua", nil, true) then
			run_lua("test/run.lua", "test/nattlua/lexer.lua")
			run_lua("test/run.lua", "test/performance/lexer.lua")
		elseif normalized:find("parser.lua", nil, true) and false then
			run_lua("test/run.lua", "test/nattlua/parser.lua")
			run_lua("test/run.lua", "test/performance/parser.lua")
		else
			run_lua("test/run.lua")
		end
	end
end

if not did_something then
	print("not sure how to run " .. path)
	print("running as normal lua")
	run_lua(path)
end