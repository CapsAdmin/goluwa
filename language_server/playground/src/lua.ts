import { LuaEngine, LuaFactory } from "wasmoon"
import { registerSyntax } from "./syntax"
import { loadLuaModule } from "./util"

export const loadLua = async () => {
	const factory = new LuaFactory("https://unpkg.com/wasmoon/dist/glue.wasm")
	const lua = await factory.createEngine({
		openStandardLibs: true,
	})

	await loadLuaModule(lua, import("./../../../build_output.lua"), "nattlua")
	await lua.doString("for k, v in pairs(package.preload) do print(k,v) end require('nattlua') for k,v in pairs(IMPORTS) do package.preload[k] = v end")
	await loadLuaModule(lua, import("./../../server/lsp.lua"), "lsp")

	await lua.doString(`
		local lsp = require("lsp")

		local listeners = {}

		function lsp.Call(data)
			if listeners[data.method] then
				listeners[data.method](data.params)
			end
		end

		function lsp.On(method, callback)
			listeners[method] = callback
		end

		_G.lsp = lsp`)

	return lua
}

export const prettyPrint = (lua: LuaEngine, code: string) => {
	lua.doStringSync(`
		function _G.prettyPrint(code)
			local nl = require("nattlua")
			local compiler = nl.Compiler(code, "temp", {
				preserve_whitespace = false,
				string_quote = "\\"",
				no_semicolon = true,
				comment_type_annotations = true,
				type_annotations = "explicit",
				force_parenthesis = true,
				skip_import = true,
				comment_type_annotations = false,
			})
			return assert(compiler:Emit())
		end    
	`)

	return lua.global.get("prettyPrint")(code) as string
}
