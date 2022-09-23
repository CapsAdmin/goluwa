import { languages } from "monaco-editor"
import { LuaEngine } from "wasmoon"
import { arrayUnion, escapeRegex, mapsToArray } from "./util"

const uniqueCharacters = (str: string) => {
	const unique = new Set<string>()
	for (const char of str) {
		unique.add(char)
	}
	return Array.from(unique).join("")
}

export const registerSyntax = async (lua: LuaEngine) => {
	await lua.doString(`
    _G.syntax_typesystem = require("nattlua.syntax.typesystem")
    _G.syntax_runtime = require("nattlua.syntax.runtime")
  `)

	const syntax_typesystem = lua.global.get("syntax_typesystem")
	const syntax_runtime = lua.global.get("syntax_runtime")
	const syntax: languages.IMonarchLanguage = {
		defaultToken: "",
		tokenPostfix: ".nl",

		keywords: mapsToArray([syntax_runtime.Keywords, syntax_runtime.NonStandardKeywords]),
		typeKeywords: mapsToArray([syntax_typesystem.Keywords, syntax_typesystem.NonStandardKeywords]).concat(["string", "any", "nil", "boolean", "number"]),

		brackets: [
			{ token: "delimiter.bracket", open: "{", close: "}" },
			{ token: "delimiter.array", open: "[", close: "]" },
			{ token: "delimiter.parenthesis", open: "(", close: ")" },
		],

		operators: mapsToArray([
			syntax_runtime.PrefixOperators,
			syntax_runtime.BinaryOperators,
			syntax_runtime.PostfixOperators,
			syntax_runtime.PrimaryBinaryOperators,
			syntax_typesystem.PrefixOperators,
			syntax_typesystem.BinaryOperators,
			syntax_typesystem.PostfixOperators,
			syntax_typesystem.PrimaryBinaryOperators,
		]),

		//symbols: new RegExp("[" + escapeRegex(uniqueCharacters(arrayUnion(syntax_runtime.Symbols, syntax_typesystem.Symbols).join(""))) + "]+"),
		symbols: /[=><!~?:&|+\-*\/\^%]+/,

		escapes: /\\(?:[abfnrtv\\"']|x[0-9A-Fa-f]{1,4}|u[0-9A-Fa-f]{4}|U[0-9A-Fa-f]{8})/,

		// The main tokenizer for our languages
		tokenizer: {
			root: [
				// identifiers and keywords
				[
					/[a-zA-Z_@]\w*/,
					{
						cases: {
							"@typeKeywords": { token: "keyword.$0" },
							"@keywords": { token: "keyword.$0" },
							"@default": "identifier",
						},
					},
				],
				// whitespace
				{ include: "@whitespace" },

				// delimiters and operators
				[/[{}()\[\]]/, "@brackets"],
				[
					/@symbols/,
					{
						cases: {
							"@operators": "delimiter",
							"@default": "",
						},
					},
				],

				// numbers
				[/\d*\.\d+([eE][\-+]?\d+)?/, "number.float"],
				[/0[xX][0-9a-fA-F_]*[0-9a-fA-F]/, "number.hex"],
				[/\d+?/, "number"],

				// delimiter: after number because of .\d floats
				[/[;,.]/, "delimiter"],

				// strings: recover on non-terminated strings
				[/"([^"\\]|\\.)*$/, "string.invalid"], // non-teminated string
				[/'([^'\\]|\\.)*$/, "string.invalid"], // non-teminated string
				[/"/, "string", '@string."'],
				[/'/, "string", "@string.'"],
			],

			whitespace: [
				[/[ \t\r\n]+/, ""],
				[/--\[([=]*)\[/, "comment", "@comment.$1"],
				[/--.*$/, "comment"],
			],

			comment: [
				[/[^\]]+/, "comment"],
				[
					/\]([=]*)\]/,
					{
						cases: {
							"$1==$S2": { token: "comment", next: "@pop" },
							"@default": "comment",
						},
					},
				],
				[/./, "comment"],
			],

			string: [
				[/[^\\"']+/, "string"],
				[/@escapes/, "string.escape"],
				[/\\./, "string.escape.invalid"],
				[
					/["']/,
					{
						cases: {
							"$#==$S2": { token: "string", next: "@pop" },
							"@default": "string",
						},
					},
				],
			],
		},
	}

	const syntaxBrackets: languages.LanguageConfiguration = {
		comments: {
			lineComment: "--",
			blockComment: ["--[[", "]]"],
		},
		brackets: [],
		autoClosingPairs: [],
		surroundingPairs: [],
	}

	for (let [l, r] of Object.entries(syntax_runtime.SymbolPairs as { [key: string]: string })) {
		syntaxBrackets.brackets.push([l, r])
		syntaxBrackets.autoClosingPairs.push({ open: l, close: r })
		syntaxBrackets.surroundingPairs.push({ open: l, close: r })
	}

	languages.register({ id: "nattlua", extensions: [".lua", ".nl"] })
	languages.setMonarchTokensProvider("nattlua", syntax)
	languages.setLanguageConfiguration("nattlua", syntaxBrackets)
}
