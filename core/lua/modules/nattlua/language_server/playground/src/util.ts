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
export const loadLuaModule = async (lua: LuaEngine, p: Promise<{ default: string }>, moduleName: string) => {
	const { default: code } = await p
	await lua.doString(`assert(load([==========[ package.preload["${moduleName}"] = function() ${code} end ]==========], "${moduleName}"))()`)
}
