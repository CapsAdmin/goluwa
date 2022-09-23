local T = require("test.helpers")
local analyze = T.RunCode
analyze[[

    attest.equal<|
        Partial<|{
            foo = 1337 | nil,
            bar = 666,
        }|>, 
        {
            foo = 1337 | nil,
            bar = 666 | nil,
        }
    |>

]]
analyze[[

    attest.equal<|
        Required<|{
            foo = 1337 | nil,
            bar = 666,
        }|>, 
        {
            foo = 1337,
            bar = 666,
        }
    |>

]]
analyze(
	[[

    local tbl = Readonly<|{
        foo = 1337 | nil,
        bar = 666,
    }|>

    tbl.bar = 444

]],
	"444 is not a subset of 666"
)
analyze[[

    local type CatInfo = {
        age = number,
        breed = string,
    }

    local type CatName = "miffy" | "boris" | "mordred"

    local cats = Record<|CatName, CatInfo|> = {
        miffy = { age = 10, breed = "tabby" },
        boris = { age = 20, breed = "shiba" },
        mordred = { age = 30, breed = "sphynx" },
    }

    attest.equal(cats.boris.age, _ as number)
]]
analyze[[

    local type Todo = {
        title = string,
        description = string,
        done = boolean,
    }

    local TodoPreview = Pick<|Todo, "title" | "done"|>

    local todo: TodoPreview = {
        title = "Get a new car",
        done = false,
    }

]]
analyze(
	[[

    local type Todo = {
        title = string,
        description = string,
        done = boolean,
    }

    local TodoPreview = Omit<|Todo, "done" | "description"|>

    local todo: TodoPreview = {
        title = "Get a new car",
    }

    local todo: TodoPreview = {
        title = "Get a new car",
        done = false,
    }
]],
	"done"
)
analyze[[
    attest.equal<|
        Exclude<|1 | 2 | 3, 2|>, 
        1 | 3
    |>
]]
analyze[[
    attest.equal<|
        Extract<|1337 | "deadbeef", number|>, 
        1337
    |>
]]
analyze[[
    attest.equal<|
        Extract<|1337 | 231 | "deadbeef", number|>, 
        1337 | 231
    |>  
]]
analyze[[
    local function foo(a: number, b: string, c: Table): boolean
        return true
    end

    attest.equal<|Parameters<|foo|>[1], number|>
    attest.equal<|Parameters<|foo|>[2], string|>
    attest.equal<|Parameters<|foo|>[3], Table|>    

    attest.equal<|ReturnType<|foo|>[1], boolean|>
]]
analyze[[
    attest.equal<|Uppercase<|"foo"|>, "FOO"|>
    attest.equal<|Lowercase<|"FOO"|>, "foo"|>

    -- something is up with chained calls in the typesystem
    --attest.equal<|Capitalize<|"foo"|>, "Foo"|>
    --attest.equal<|Uncapitalize<|"FOO"|>, "fOO"|>
]]
analyze[[
    local x: {
        [string] = true,
        foo = 1337,
    }
    
    local y: Omit<|x, string|>
    attest.equal(y, {
        foo = 1337,
    })
]]
