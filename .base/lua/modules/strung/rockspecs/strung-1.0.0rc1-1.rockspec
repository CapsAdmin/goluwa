package = "strung"
version = "1.0.0-rc1-1"
source = {
   url = "git://github.com/pygy/strung.lua.git",
   tag = "v1.0.0-rc1"
}

description = {
   summary = "The Lua string pattern matching functions, rewritten in Lua + FFI, for LuaJIT 2.1+",
   detailed = [[
`string.find()`, `.match()`, `.gmatch()` and `.gsub()` rewritten in Lua + FFI, for LuaJIT 2.1+

Improves performance in some cases, see the README for more details.
]],
   homepage = "https://github.com/pygy/strung.lua",
   license = "MIT/X11"
}

dependencies = {
   "lua >= 5.1, < 5.3"
}

build = {
  type = "builtin",
  modules = {
    strung = "./strung.lua"
  }
}

