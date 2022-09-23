local nl = require("nattlua")
local Emitter = require("examples.projects.typescript_transpiler.emitter").New
local code = assert(io.open("examples/projects/typescript_transpiler/input.lua")):read("*all")
local ast = assert(assert(nl.Compiler(code):Parse()):Analyze()).SyntaxTree
local em = Emitter()
local f = loadstring(code)

if f then pcall(f) end

local code = em:BuildCode(ast)
code = (
		[[

let globalThis = {}

globalThis.print = console.log;
globalThis.tonumber = (str) => {
    let n = parseFloat(str)
    if (isNaN(n)) {
        return undefined
    }
    return n
};
globalThis.arg = []

globalThis.math = {}
globalThis.math.sqrt = Math.sqrt


globalThis.io = {}
globalThis.io.write = console.log

require("sprintf.js")

globalThis.string = {}
globalThis.string.format = sprintf

let metatables = new Map()

globalThis.table = {}
globalThis.table.insert = (tbl, i, val) => {
    if (!val) {
        val = i
    }

    tbl.push(val)
}

globalThis.setmetatable = (obj, meta) => {
    metatables.set(obj, meta)
    return obj
}
globalThis.getmetatable = (obj) => {
    return metatables.get(obj)
}

let nil = undefined

let OP = {}
{
    OP["#"] = (val) => val.length
    OP["="] = (obj, key, val) => {
        obj[key] = val
    }

    OP["."] = (l, r) => {
        if (Array.isArray(l)) {
            return l[r - 1]
        }

        if (l[r] != undefined) {
            return l[r]
        }

        let lmeta = globalThis.getmetatable(l)
        
        if (lmeta && lmeta.__index) {
            if (lmeta.__index === lmeta) {
                return lmeta[r]
            }

            return lmeta.__index(l, r)
        }

        return nil
    }

    let self = undefined

    $OPERATORS$

    OP["and"] = (l, r) => l !== undefined && l !== false && r !== undefined && r !== false
    OP["or"] = (l, r) => (l !== undefined && l !== false) ? l : (r !== undefined && r !== false) ? r : undefined

    OP[":"] = (l, r) => {
        self = l
        return OP["."](l,r)
    }

    OP["call"] = (obj, ...args) => {
        if (!obj) {
            throw "attempt to call a nil value"
        }
        if (self) {
            let a = self
            self = undefined
            return obj.apply(obj, [a, ...args])
        }

        return obj.apply(obj, args)
    }
}
]]
	):gsub("%$OPERATORS%$", function()
		local operators = {
			["+"] = "__add",
			["-"] = "__sub",
			["*"] = "__mul",
			["/"] = "__div",
			["/idiv/"] = "__idiv",
			["%"] = "__mod",
			["^"] = "__pow",
			["&"] = "__band",
			["|"] = "__bor",
			["<<"] = "__lshift",
			[">>"] = "__rshift",
		}
		local code = ""

		for operator, name in pairs(operators) do
			code = code .. [[
            OP["]] .. operator .. [["] = (l,r) => {
                let lmeta = globalThis.getmetatable(l)
                if (lmeta && lmeta.]] .. name .. [[) {
                    return lmeta.]] .. name .. [[(l, r)
                }
        
                let rmeta = globalThis.getmetatable(r)
        
                if (rmeta && rmeta.]] .. name .. [[) {
                    return rmeta.]] .. name .. [[(l, r)
                }
        
                return l ]] .. operator .. [[ r
            }
        ]]
		end

		return code
	end) .. code
print(code)
os.execute("mkdir -p jstest/src")
os.execute("cd jstest && yarn && yarn add sprintf.js")
local f = io.open("jstest/src/test.js", "wb")
f:write(code)
f:close()
os.execute("node --trace-uncaught jstest/src/test.js") --os.remove("temp.js")
