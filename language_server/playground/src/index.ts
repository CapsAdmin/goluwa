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

	const lsp = lua.global.get("lsp")

	const recompile = () => {
		let response: DidChangeTextDocumentParams = {
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

		lsp.methods["textDocument/didChange"](lsp, response)
	}

	tab.onDidChangeContent((e) => {
		recompile()
	})

	languages.registerInlayHintsProvider("nattlua", {
		provideInlayHints(model, range) {
			let response = {
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

			let result = lsp.methods["textDocument/inlay"](lsp, response)

			return result
		},
	})

	languages.registerRenameProvider("nattlua", {
		provideRenameEdits: (model, position, newName, token) => {
			let response = {
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

			let result = lsp.methods["textDocument/rename"](lsp, response) as {
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
			for (const [uri, changes] of Object.entries(result.changes)) {
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
			let response = {
				textDocument: {
					uri: "file:///test.nlua",
					text: model.getValue(),
				},
				position: {
					line: position.lineNumber - 1,
					character: position.column - 1,
				},
			}

			let result = lsp.methods["textDocument/hover"](lsp, response) as
				| undefined
				| {
						range: Range
						contents: string
				  }

			if (!result) return

			// TODO: how to highlight non letters?

			return {
				contents: [
					{
						value: result.contents,
					},
				],
				// these start at 1, but according to LSP they should be zero indexed
				startLineNumber: result.range.start.line + 1,
				startColumn: result.range.start.character + 1,
				endLineNumber: result.range.end.line + 1,
				endColumn: result.range.end.character + 1,
			}
		},
	})

	lsp.On("textDocument/publishDiagnostics", (params) => {
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
}

main()
