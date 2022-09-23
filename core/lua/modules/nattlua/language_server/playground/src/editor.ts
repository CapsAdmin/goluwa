import { editor } from "monaco-editor"

export const createEditor = () => {
	;(globalThis as any).MonacoEnvironment = {
		getWorkerUrl: function (moduleId, label) {
			if (label === "typescript" || label === "javascript") {
				return "./ts.worker.bundle.js"
			}
			return "./editor.worker.bundle.js"
		},
	}

	const editorInstance = editor.create(document.getElementById("container"), {
		minimap: { enabled: false },
		scrollBeyondLastLine: true,
		theme: "vs-dark",
	})

	window.addEventListener("resize", () => {
		editorInstance.layout()
	})

	return editorInstance
}
