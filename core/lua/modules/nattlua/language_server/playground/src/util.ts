import { LuaEngine } from "wasmoon"

export const mapsToArray = (maps: { [key: string]: unknown }[]) => {
	const set = new Set<string>()
	for (const map of maps) {
		for (const key in map) {
			set.add(key)
		}
	}
	return Array.from(set.values())
}

export const arrayUnion = (a: string[], b: string[]) => {
	const set = new Set<string>()
	for (const item of a) {
		set.add(item)
	}
	for (const item of b) {
		set.add(item)
	}
	return Array.from(set.values())
}

export const escapeRegex = (str: string) => {
	return str.replace(/[-\/\\^$*+?.()|[\]{}]/g, "\\$&")
}

function chunkSubstr(str: string, size: number) {
	const numChunks = Math.ceil(str.length / size)
	const chunks = new Array(numChunks)

	for (let i = 0, o = 0; i < numChunks; ++i, o += size) {
		chunks[i] = str.substr(o, size)
	}

	return chunks
}

export const loadLuaModule = async (lua: LuaEngine, p: Promise<{ default: string }>, moduleName: string, chunkName?: string) => {
	let { default: code } = await p

	if (code.startsWith("#")) {
		// remove shebang
		const index = code.indexOf("\n")
		if (index !== -1) {
			code = code.substring(index)
		}
	}

	// I think something broke with moonwasm. There seems to be a limit on how large the string can be.
	// This may be taking it too far but I've spent too much time on this already..

	let chunks = chunkSubstr(code, 4096)
	let i = 0
	for (let chunk of chunks) {
		let byteEscaped = ""
		for (let i = 0; i < chunk.length; i++) {
			byteEscaped += `\\${chunk.charCodeAt(i)}`
		}

		let str = `CHUNKS = CHUNKS or {};CHUNKS[#CHUNKS + 1] = "${byteEscaped}"`
		lua.doStringSync(str)
		i++
	}

	let str = `
	local code = "package.preload['${moduleName}'] = function(...) " .. table.concat(CHUNKS) .. " end"
	assert(load(code, "${chunkName}"))(...); CHUNKS = nil
	`
	lua.doStringSync(str)
}
