# About

NattLua is a superset of LuaJIT that adds a structural typesystem. It's built to do accurate analysis with the ability to optionally constrain variables.

The typesystem itself follows the same philosophy as Lua. It has low level concepts that give you the freedom to choose how much you want to constrain your program. (🦶🔫!)

There is a [playground](https://capsadmin.github.io/NattLua/) you can try. It supports hover type information and other diagnostics.

Complex type structures, such as array-like tables, map-like tables, metatables, and more are supported:

```lua
local list: {[number] = string | nil} = {} -- -1 index is alllowed
local list: {[1..inf] = string | nil} = {} -- only 1..inf index is allowed

local map: {[string] = string | nil} = {} -- any string is allowed
local map: {foo = string, bar = string} = {foo = "hello", bar = "world"} -- only foo and bar is allowed as keys, but value can be any string type

-- note that we add | nil so we can start with an empty table

local a = "fo"
local b = string.char(string.byte("o"))
map[a..b] = "hello"
--"fo" and "o" are literals and will be treated as such by the type inference
```

```lua
local Vec3 = {}
Vec3.__index = Vec3

-- give the type a friendly name for diagnostics
type Vec3.@Name = "Vector"

-- define the type of the first argument in setmetatable
type Vec3.@Self = {
    x = number,
    y = number,
    z = number,
}

function Vec3.__add(a: Vec3, b: Vec3)
    return Vec3(a.x + b.x, a.y + b.y, a.z + b.z)
end

setmetatable(Vec3, {
    __call = function(_, x: number, y: number, z: number)
        return setmetatable({x=x,y=y,z=z}, Vec3)
    end
})

local new_vector = Vector(1,2,3) + Vector(100,100,100) -- OK
```

It aims to be compatible with luajit, 5.1, 5.2, 5.3, 5.4 and Garry's Mod Lua (a variant of Lua 5.1).

The `build_output.lua` file is a bundle of this project that can be required in your project. It also works in garry's mod.

# Code analysis and typesystem

The analyzer works by evaluating the syntax tree. It runs similar to how Lua runs, but on a more general level and can take take multiple branches if its not sure about if conditions, loops and so on. If everything is known about a program and you did not add any types to generalize types you may get its actual output at type-check time.

```lua
local cfg = [[
    name=Lua
    cycle=123
    debug=yes
]]

local function parse(str: ref string)
    local tbl = {}
    for key, val in str:gmatch("(%S-)=(.-)\n") do
        tbl[key] = val
    end
    return tbl
end

local tbl = parse(cfg)
print<|tbl|>
>>
--[[
{
    "name" = "Lua",
    "cycle" = "123",
    "debug" = "yes"
}
]]
```

The ref keyword here means that the `cfg` variable would be passed in as a type reference. In this context it's similar to how type arguments in a generic function is passed to the function itself. If we removed the ref keyword, the output of the function would be inferred to `{ string = string }` because str would become a non literal string.

We can also enforce the output type of parse by writing `parse(str: ref string): {[string] = string}`, but if you don't it will be inferred.

When the analyzer detects an error, it will try to recover from the error and continue. For example:

```lua
local obj: nil | (function(): number)
local x = obj()
local y = x + 1
```

This code will report an error about potentially calling a nil value. Internally the analyzer would duplicate the scope, remove nil from the union `nil | (function(): number)` so that `obj` contains all the values that are valid in a call operation.

# Current status and goals

My long term goal is to develop a capable language to use for my other projects (such as [goluwa](https://github.com/CapsAdmin/goluwa)).

At the moment I focus strongly on type inference correctness, adding tests and keeping the codebase maintainable.

I'm also in the middle of bootstrapping the project with comment types. So far the lexer part of the project and some other parts are typed and is part of the test suite.

# Types

Fundamentally the typesystem consists of number, string, table, function, symbol, union, tuple and any. Tuples and unions exist only in the typesystem. Symbols are things like true, false, nil, etc.

These types can also be literals, so as a showcase example we can describe the fundamental types like this:

```lua
local type Boolean = true | false
local type Number = -inf .. inf | nan
local type String = $".*"
local type Any = Number | Boolean | String | nil

-- nil cannot be a key in tables
local type Table = { [exclude<|Any, nil|> | self] = Any | self }

-- extend the Any type to also include Table
type Any = Any | Table

-- CurrentType is a type function that lets us get the reference to the current type we're constructing
local type Function = function=(...Any | CurrentType<|"function"|>)>(...Any | CurrentType<|"function"|>)

-- extend the Any type to also include Function
type Any = Any | Function
```

So here all the PascalCase types should have semantically the same meaning as their lowercase counter parts.

# Numbers

From narrow to wide

```lua
type N = 1

local foo: N = 1
local foo: N = 2
      ^^^: 2 is not a subset of 1
```

```lua
type N = 1 .. 10

local foo: N = 1
local foo: N = 4
local foo: N = 11
      ^^^: 11 is not a subset of 1 .. 10
```

```lua
type N = 1 .. inf

local foo: N = 1
local bar: N = 2
local faz: N = -1
      ^^^: -1 is not a subset of 1 .. inf
```

```lua
type N = -inf .. inf

local foo: N = 0
local bar: N = 200
local faz: N = -10
local qux: N = 0/0
      ^^^: nan is not a subset of -inf .. inf
```

The logical progression is to define N as `-inf .. inf | nan` but that has semantically the same meaning as `number`

# Strings

Strings can be defined as lua string patterns to constrain them:

```lua
local type MyString = $"FOO_.-"

local a: MyString = "FOO_BAR"
local b: MyString = "lol"
                    ^^^^^ : the pattern failed to match
```

A narrow value:

```lua
type foo = "foo"
```

Or wide:

```lua
type foo = string
```

`$".-"` is semantically the same as `string`

# Tables

are similar to lua tables, where its key and value can be any type.

the only special syntax is `self` which is used for self referencing types

here are some natural ways to define a table:

```lua
local type MyTable = {
    foo = boolean,
    bar = string,
}

local type MyTable = {
    ["foo"] = boolean,
    [number] = string,
}

local type MyTable = {
    ["foo"] = boolean,
    [number] = string,
    faz = {
        [any] = any
    }
}
```

# Unions

A Union is a type separated by `|` I feel these tend to show up in uncertain conditions.

For example this case:

```lua
local x = 0
-- x is 0 here

if math.random() > 0.5 then
    -- x is 0 here
    x = 1
    -- x is 1 here
else
    -- x is 0 here
    x = 2
    -- x is 2 here
end

-- x is 1 | 2 here
```

This happens because `math.random()` returns `number` and `number > 0.5` is `true | false`.

One of these if blocks must execute, so that's why we end up with `1 | 2` instead of `0 | 1 | 2`.

```lua
local x = 0
-- x is 0 here
if true then
    x = 1
    -- x is 1 here
end
-- x is still 1 here because the mutation = 1 occured in a certain branch
```

This happens because `true` is true as opposed to `true | false` and so there's no uncertainty in executing the if block.

# Analyzer functions

Analyzer functions help us bind advanced type functions to the analyzer. We can for example define math.ceil and a print function like this:

```lua
analyzer function print(...)
    print(...)
end

analyzer function math.floor(T: number)
    if T:IsLiteral() then
        return types.Number(math.floor(T:GetData())):SetLiteral(true)
    end

    return types.Number()
end

local x = math.floor(5.5)
print<|x|>
-->> 5
```

When transpiled to lua, the result is just:

```lua
local x = math.floor(5.5)
```

So analyzer functions only exist when analyzing. The body of these functions are not analyzed like the rest of the code. For example, if this project was written in Python the contents of the analyzer functions would be written in Python as well.

They exist to provide a way to define advanced custom types and functions that cannot easily be made into a normal type function.

# Type functions

Type functions is the recommended way to write type functions. We can define an assertion function like this:

```lua
local function assert_whole_number<|T: number|>
    assert(math.floor(T) == T, "Expected whole number")
end

local x = assert_whole_number<|5.5|>
          ^^^^^^^^^^^^^^^^^^^: assertion failed!
```

`<|` `|>` here means that we are writing a type function that only exist in the type system. Unlike `analyzer` functions, its content is actually analyzed.

When the code above is transpiled to lua, the result is still just:

```lua
local x = 5.5
```

`<|a,b,c|>` is the way to call type functions. In other languages it tends to be `<a,b,c>` but I chose this syntax to avoid conflicts with the `<` and `>` comparison operators. This syntax may change in the future.

```lua
local function Array<|T: any, L: number|>
    return {[1..L] = T}
end

local list: Array<|number, 3|> = {1, 2, 3, 4}
                                 ^^^^^^^^^^^^: 4 is not a subset of 1..3
```

In type functions, the type is by default passed by reference. So `T: any` does not meant that T will be any. It just means that T is allowed to be anything.

In Typescript it would be something like

```ts
type Array<T extends any, length extends number> = {[key: 1..length]: T} // assuming typescript supports number ranges
```

Type function arguments always need to be explicitly typed.

# More examples

## List type

```lua
function List<|T: any|>
	return {[1..inf] = T | nil}
end

local names: List<|string|> = {} -- the | nil above is required to allow nil values, or an empty table in this case
names[1] = "foo"
names[2] = "bar"
names[-1] = "faz"
^^^^^^^^^: -1 is not a subset of 1 .. inf
```

## ffi.cdef errors in the compiler

```lua
analyzer function ffi.cdef(c_declaration: string)
    -- this requires using analyzer functions

    if c_declaration:IsLiteral() then
        local ffi = require("ffi")
        ffi.cdef(c_declaration:GetData()) -- if this function throws it's propagated up to the compiler as an error
    end
end

ffi.cdef("bad c declaration")
```

```lua
4 | d
5 | end
6 |
8 | ffi.cdef("bad c declaration")
    ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
-> | test.lua:8:0 : declaration specifier expected near 'bad'
```

## `load` evaluation

```lua
local function build_summary_function(tbl)
    local lua = {}
    table.insert(lua, "local sum = 0")
    table.insert(lua, "for i = " .. tbl.init .. ", " .. tbl.max .. " do")
    table.insert(lua, tbl.body)
    table.insert(lua, "end")
    table.insert(lua, "return sum")
    return load(table.concat(lua, "\n"), tbl.name)
end

local func = build_summary_function({
    name = "myfunc",
    init = 1,
    max = 10,
    body = "sum = sum + i !!ManuallyInsertedSyntaxError!!"
})
```

```lua
----------------------------------------------------------------------------------------------------
    4 | )
    5 |  table.insert(lua, "end")
    6 |  table.insert(lua, "return sum")
    8 |  return load(table.concat(lua, "\n"))
                ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    9 | end
10 |
----------------------------------------------------------------------------------------------------
-> | test.lua:8:8
    ----------------------------------------------------------------------------------------------------
    1 | local sum = 0
    2 | for i = 1, 10 do
    3 | sum = sum + i !!ManuallyInsertedSyntaxError!!
                      ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
    4 | end
    5 | return sum
    ----------------------------------------------------------------------------------------------------
    -> | myfunc:3:14 : expected assignment or call expression got ❲symbol❳ (❲!❳)
```

This works because there is no uncertainty about the code generated passed to the load function. If we did `body = "sum = sum + 1" .. (unknown_global as string)`, that would make the table itself become uncertain so that table.concat would return `string` and not the actual results of the concatenation.

## anagram proof

```lua
local bytes = {}
for i,v in ipairs({
    "P", "S", "E", "L", "E",
}) do
    bytes[i] = string.byte(v)
end
local all_letters = _ as bytes[number] ~ nil -- remove nil from the union
local anagram = string.char(all_letters, all_letters, all_letters, all_letters, all_letters)

print<|anagram|> -- >> "EEEEE" | "EEEEL" | "EEEEP" | "EEEES" | "EEELE" | "EEELL" | ...
assert(anagram == "SLEEP")
print<|anagram|> -- >> "SLEEP"
```

This is true because `anagram` becomes a union of all possible letter combinations which contains the string "SLEEP".

It's arguably also false as it contains all the other combinations, but since we use assert to check the result at runtime, it's not a problem.

# Parsing and transpiling

As a learning experience I wrote the lexer and parser trying not to look at existing Lua parsers, but this makes it different in some ways. The syntax errors it can report are not standard and are bit more detailed. It's also written in a way to be easily extendable for new syntax.

- Syntax errors can be nicer than standard Lua parsers. Errors are reported with character ranges.
- The lexer and parser can continue after encountering an error, which is useful for editor integration.
- Whitespace can be preserved if needed
- Both single-line C comments (from GLua) and the Lua 5.4 division operator can be used in the same source file.
- Transpiles bitwise operators, integer division, \_ENV, etc down to valid LuaJIT code.
- Supports inline importing via require, loadfile, and dofile.
- Supports teal syntax, but does not currently support its scoping rules.

I have not fully decided the syntax for the language and runtime semantics for lua 5.3/4 features. But I feel this is more of a detail that can easily be changed later.

# Development

To run tests run `luajit test.lua`
To build run `luajit build.lua`
To format the codebase with NattLua run `luajit format.lua`

I've setup vscode to run the task `onsave` when a file is saved with the plugin `gruntfuggly.triggertaskonsave`. This runs `on_editor_save.lua` which has some logic to choose which files to run when modifying project.

I also locally have a file called `test_focus.nlua` in root which will override the test suite when the file is not empty. This makes it easier to debug specific tests and code.

Some debug language features are:

`§` followed by lua code. This invokes the analyzer so you can inspect or modify its state.

```lua
local x = 1337
§print(env.runtime.x:GetUpvalue())
§print(analyzer:GetScope())
```

`£` followed by lua code. This invokes the parser so you can inspect or modify its state.

```lua
local x = 1337
£print(parser.current_statement)
```

# Similar projects

[Teal](https://github.com/teal-language/tl) is a language similar to this which has a more pragmatic approach. I'm thinking a nice goal is that I can contribute what I've learned here, be it through tests or other things.

[Luau](https://github.com/Roblox/luau) is another project similar to this, but I have not looked so much into it yet.

[sumneko lua](https://github.com/sumneko/lua-language-server) a language server for lua that supports analyzing lua code. It a typesystem that can be controlled by using comments.

[EmmyLua](https://github.com/EmmyLua/VSCode-EmmyLua) Similar to sumneko lua.
