local args = ...

if args == "vscode" then
	os.execute("cd language_server/vscode && yarn && yarn build && code --install-extension nattlua-0.0.1.vsix")
	return
end

local nl = require("nattlua")
local entry = "./nattlua.lua"
io.write("parsing " .. entry)
local c = assert(
	nl.Compiler([[
		_G.ARGS = {...}

		if _G.IMPORTS then
			for k, v in pairs(_G.IMPORTS) do
				if not k:find("/") then package.preload[k] = v end
			end
	
			package.preload.nattlua = package.preload["nattlua.init"]
		end

		return require("nattlua")
	]],
	"nattlua",
		{
			type_annotations = false,
			inline_require = true,
			emit_environment = true,
		}
	)
)
local lua_code = c:Emit(
	{
		preserve_whitespace = false,
		string_quote = "\"",
		no_semicolon = true,
		omit_invalid_code = true,
		comment_type_annotations = true,
		type_annotations = true,
		force_parenthesis = true,
		module_encapsulation_method = "loadstring",
		extra_indent = {
			Start = {to = "Stop"},
			Toggle = "toggle",
		},
	}
)
lua_code = "_G.BUNDLE = true\n" .. lua_code
io.write(" - OK\n")
io.write("output is " .. #lua_code .. " bytes\n")
-- double check that the lua_code is valid
io.write("checking if lua_code is loadable")
local func, err = loadstring(lua_code)

if not func then
	io.write(" - FAILED\n")
	io.write(err .. "\n")
	local f = io.open("temp_build_output.lua", "w")
	f:write(lua_code)
	f:close()
	nl.File("temp_build_output.lua"):Parse()
	return
end

io.write(" - OK\n")

if args ~= "fast" then
	-- run tests before we write the file
	local f = io.open("temp_build_output.lua", "w")
	f:write(lua_code)
	f:close()
	io.write("running tests with temp_build_output.lua ")
	io.flush()
	local exit_code = os.execute("luajit -e 'require(\"temp_build_output\") assert(loadfile(\"test.lua\"))()'")

	if exit_code ~= 0 then
		io.write(" - FAIL\n")
		return
	end

	io.write(" - OK\n")
	io.write("checking if file can be required outside of the working directory")
	io.flush()
	local exit_code = os.execute("cd .github && luajit -e 'local nl = loadfile(\"../temp_build_output.lua\")'")

	if exit_code ~= 0 then
		io.write(" - FAIL\n")
		return
	end

	io.write(" - OK\n")
end

io.write("writing build_output.lua")
local f = assert(io.open("build_output.lua", "w"))
local shebang = "#!/usr/local/bin/luajit\n"
f:write(shebang .. lua_code)
f:close()
os.execute("chmod +x ./build_output.lua")
io.write(" - OK\n")
os.remove("temp_build_output.lua")