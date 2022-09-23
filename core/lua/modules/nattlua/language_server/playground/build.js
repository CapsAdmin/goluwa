const { execSync } = require("child_process")
const fs = require("fs")
const path = require("path")

const getAllFiles = function (dirPath, arrayOfFiles) {
	files = fs.readdirSync(dirPath)

	arrayOfFiles = arrayOfFiles || []

	files.forEach(function (file) {
		if (fs.statSync(dirPath + "/" + file).isDirectory()) {
			arrayOfFiles = getAllFiles(dirPath + "/" + file, arrayOfFiles)
		} else {
			arrayOfFiles.push(path.join(__dirname, dirPath, "/", file))
		}
	})

	return arrayOfFiles
}

let tests = []

for (let path of getAllFiles("../../test/nattlua/analyzer/")) {
	if (path.endsWith(".nlua")) {
		tests.push(fs.readFileSync(path).toString())
	} else {
		let data = fs.readFileSync(path).toString()
		let matches = data.matchAll(/analyze\s*\[\[(.*?)\]\]/gms)
		for (let match of matches) {
			tests.push(match[1])
		}
	}
}

fs.writeFileSync("src/random.json", JSON.stringify(tests))

execSync("cd ../../ && luajit build.lua fast")

require("esbuild")
	.build({
		format: "iife",
		platform: "node",
		entryPoints: {
			app: "src/index.ts",
			"editor.worker": "monaco-editor/esm/vs/editor/editor.worker.js",
		},
		entryNames: "[name].bundle",
		loader: "expose-loader",
		bundle: true,
		outdir: "public/",
		loader: {
			".ttf": "dataurl",
			".lua": "text",
			".nlua": "text",
		},
	})
	.catch(() => process.exit(1))
