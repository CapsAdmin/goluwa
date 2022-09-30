import { editor as MonacoEditor, IRange, languages, MarkerSeverity, Uri } from "monaco-editor"
import { PublishDiagnosticsParams, Range, DidChangeTextDocumentParams, Position } from "vscode-languageserver"
import { createEditor } from "./editor"
import { loadLua, prettyPrint } from "./lua"
import { registerSyntax } from "./syntax"
import randomExamples from "./random.json"
import { assortedExamples } from "./examples"

const getRandomExample = () => {
	return randomExamples[Math.floor(Math.random() * randomExamples.length)]
}

const main = async () => {
	const lua = await loadLua()
	await registerSyntax(lua)

	const editor = createEditor()
	const tab = MonacoEditor.createModel("local x = 1337", "nattlua")

	const select = document.getElementById("examples") as HTMLSelectElement

	select.addEventListener("change", () => {
		tab.setValue(select.value)
	})

	const lsp = lua.global.get("lsp")

	const callMethodOnServer = (method: string, params: any) => {
		console.log("calling", method, params)
		let response = lsp.methods[method](params)
		console.log("\tgot", response)
		return response
	}

	const onMessageFromServer = (method: string, callback: (params: any) => void) => {
		lsp.On(method, (params) => {
			console.log("received", method, params)
			callback(params)
		})
	}

	const recompile = () => {
		let request: DidChangeTextDocumentParams = {
			textDocument: {
				uri: "file:///test.nlua",
			} as DidChangeTextDocumentParams["textDocument"],
			contentChanges: [
				{
					text: tab.getValue(),
				},
			],
		}

		MonacoEditor.setModelMarkers(tab, "owner", [])
		callMethodOnServer("textDocument/didChange", request)
	}


	for (const [name, code] of Object.entries(assortedExamples)) {
		let str: string
		if (typeof code === "string") {
			str = code
		} else {
			str = (await code).default
		}

		// remove attest.expect_diagnostic() calls
		str = str.replaceAll(/attest\.expect_diagnostic\(.*\)/g, "")

		const option = new Option(name, str)
		select.options.add(option)
		if (name == "array") {
			option.selected = true
			tab.setValue(str)
		}
	}

	document.getElementById("random-example").addEventListener("click", () => {
		tab.setValue(getRandomExample())
	})

	document.getElementById("pretty-print").addEventListener("click", () => {
		tab.setValue(prettyPrint(lua, tab.getValue()))
	})


	tab.onDidChangeContent((e) => {
		recompile()
	})

	languages.registerInlayHintsProvider("nattlua", {
		provideInlayHints(model, range) {
			let request = {
				textDocument: {
					uri: model.uri,
					text: model.getValue(),
				},
				start: {
					line: range.getStartPosition().lineNumber - 1,
					character: range.getStartPosition().column - 1,
				},
				end: {
					line: range.getEndPosition().lineNumber - 1,
					character: range.getEndPosition().column - 1,
				},
			}

			return callMethodOnServer("textDocument/inlayHint", request)
		},
	})

	languages.registerRenameProvider("nattlua", {
		provideRenameEdits: (model, position, newName, token) => {
			let request = {
				textDocument: {
					uri: model.uri,
					text: model.getValue(),
				},
				position: {
					line: position.lineNumber - 1,
					character: position.column - 1,
				},
				newName,
			}

			let response = callMethodOnServer("textDocument/rename", request) as {
				changes: {
					[uri: string]: {
						textDocument: { version?: number }
						edits: Array<{
							range: { start: Position; end: Position }
							newText: string
						}>
					}
				}
			}
			let edits = []
			for (const [uri, changes] of Object.entries(response.changes)) {
				for (const change of changes.edits) {
					edits.push({
						resource: model.uri,
						edit: {
							range: {
								startLineNumber: change.range.start.line + 1,
								startColumn: change.range.start.character + 1,
								endLineNumber: change.range.end.line + 1,
								endColumn: change.range.end.character + 1,
							},
							text: change.newText,
						},
					})
				}
			}

			console.log(edits)

			return {
				edits,
			}
		},
	})

	languages.registerHoverProvider("nattlua", {
		provideHover: (model, position) => {
			let request = {
				textDocument: {
					uri: "file:///test.nlua",
					text: model.getValue(),
				},
				position: {
					line: position.lineNumber - 1,
					character: position.column - 1,
				},
			}

			let response = callMethodOnServer("textDocument/hover", request) as
				| undefined
				| {
					range: Range
					contents: string
				}

			if (!response) return

			// TODO: how to highlight non letters?

			return {
				contents: [
					{
						value: response.contents,
					},
				],
				// these start at 1, but according to LSP they should be zero indexed
				startLineNumber: response.range.start.line + 1,
				startColumn: response.range.start.character + 1,
				endLineNumber: response.range.end.line + 1,
				endColumn: response.range.end.character + 1,
			}
		},
	})

	onMessageFromServer("textDocument/publishDiagnostics", (params) => {
		const { diagnostics } = params as PublishDiagnosticsParams
		const markers: MonacoEditor.IMarkerData[] = []
		for (const diag of diagnostics) {
			let severity: number = diag.severity

			if (severity == 1) {
				severity = MarkerSeverity.Error
			} else if (severity == 2) {
				severity = MarkerSeverity.Warning
			} else if (severity == 3) {
				severity = MarkerSeverity.Info
			} else {
				severity = MarkerSeverity.Hint
			}

			markers.push({
				message: diag.message,
				startLineNumber: diag.range.start.line + 1,
				startColumn: diag.range.start.character + 1,
				endLineNumber: diag.range.end.line + 1,
				endColumn: diag.range.end.character + 1,
				severity: severity,
			})
		}

		MonacoEditor.setModelMarkers(tab, "owner", markers)
	})

	editor.setModel(tab)

	setTimeout(() => recompile(), 100)
}

main()
