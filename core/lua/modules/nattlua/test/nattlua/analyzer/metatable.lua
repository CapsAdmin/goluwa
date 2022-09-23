local T = require("test.helpers")
local analyze = T.RunCode
local String = T.String

do
	local analyzer = analyze[[
        -- index function
        local t = setmetatable({}, {__index = function(self, key) return 1 end})
        local a = t.lol
    ]]
	local a = analyzer:GetLocalOrGlobalValue(String("a"))
	equal(1, a:GetData())
end

analyze[[
    local meta = {} as {num = number, __index = self}

    local a = setmetatable({}, meta)

    attest.equal(a.num, _ as number)
]]

do -- basic inheritance
	local analyzer = analyze[[
        local META = {}
        META.__index = META

        META.Foo = 2
        META.Bar = 0 as number

        function META:Test(v)
            return self.Bar + v, META.Foo + v
        end

        local obj = setmetatable({Bar = 1}, META)
        local a, b = obj:Test(1)
    ]]
	local obj = analyzer:GetLocalOrGlobalValue(String("obj"))
	local a = analyzer:GetLocalOrGlobalValue(String("a"))
	local b = analyzer:GetLocalOrGlobalValue(String("b"))
	equal(2, a:GetData())
	equal(3, b:GetData())
end

do -- __call method
	local analyzer = analyze[[
        local META = {}
        META.__index = META

        function META:__call(a,b,c)
            return a+b+c
        end

        local obj = setmetatable({}, META)

        local lol = obj(100,2,3)
    ]]
	local obj = analyzer:GetLocalOrGlobalValue(String("obj"))
	equal(105, analyzer:GetLocalOrGlobalValue(String("lol")):GetData())
end

do -- __call method should not mess with scopes
	local analyzer = analyze[[
        local META = {}
        META.__index = META

        function META:__call(a,b,c)
            return a+b+c
        end

        local a = setmetatable({}, META)(100,2,3)
    ]]
	local a = analyzer:GetLocalOrGlobalValue(String("a"))
	equal(105, a:GetData())
end

do -- vector test
	local analyzer = analyze[[
        local Vector = {}
        Vector.__index = Vector

        setmetatable(Vector, {
            __call = function(_, a)
                return setmetatable({lol = a}, Vector)
            end
        })

        local v = Vector(123).lol
    ]]
	local v = analyzer:GetLocalOrGlobalValue(String("v"))
	equal(123, v:GetData())
end

do -- vector test
	local analyzer = analyze[[
        local Vector = {}
        Vector.__index = Vector

        function Vector.__add(a, b)
            return Vector(a.x + b.x, a.y + b.y, a.z + b.z)
        end

        setmetatable(Vector, {
            __call = function(_, x,y,z)
                return setmetatable({x=x,y=y,z=z}, Vector)
            end
        })

        local v = Vector(1,2,3) + Vector(100,100,100)
        local x, y, z = v.x, v.y, v.z
    ]]
	local x = assert(analyzer:GetLocalOrGlobalValue(String("x")))
	local y = assert(analyzer:GetLocalOrGlobalValue(String("y")))
	local z = assert(analyzer:GetLocalOrGlobalValue(String("z")))
	equal(101, x:GetData())
	equal(102, y:GetData())
	equal(103, z:GetData())
end

analyze[[
        -- interface extensions
        local type Vec2 = {x = number, y = number}
        local type Vec3 = {z = number} extends Vec2

        local type Base = {
            Test = function=(self)>(number),
        }

        local type Foo = Base extends {
            SetPos = function=(self, pos: Vec3)>(nil),
            GetPos = function=(self)>(Vec3),
        }

        -- have to use the as operator here because {} would not be a subset of Foo
        local x = _ as Foo

        x:SetPos({x = 1, y = 2, z = 3})
        local a = x:GetPos()
        local z = a.x + 1

        attest.equal(z, _ as number)

        local test = x:Test()
        attest.equal(test, _ as number)
    ]]
analyze(
	[[
        -- error on newindex

        local type error = analyzer function(msg: string)
            assert(type(msg:GetData()) == "string", "msg has no field a string?")
            error(msg:GetData())
        end

        local META = {}
        META.__index = META

        function META:__newindex(key, val)
            if key == "foo" then
                error("cannot use " .. key)
            end
        end

        local self = setmetatable({}, META)

        self.foo = true

        -- should error
        self.bar = true
    ]],
	"cannot use foo"
)
analyze[[
        -- tutorialspoint 

        mytable = setmetatable({key1 = "value1"}, {
            __index = function(mytable, key)
                if key == "key2" then
                    return "metatablevalue"
                else
                    return mytable[key]
                end
            end
        })

        attest.equal(mytable.key1, "value1")
        attest.equal(mytable.key2, "metatablevalue")
    ]]
analyze[[
        -- tutorialspoint 

        mymetatable = {}
        mytable = setmetatable({key1 = "value1"}, { __newindex = mymetatable })

        attest.equal(mytable.key1, "value1")

        mytable.newkey = "new value 2"
        attest.equal(mytable.newkey, nil)
        attest.equal(mymetatable.newkey, "new value 2")

        mytable.key1 = "new value 1"
        attest.equal(mytable.key1, "value1")
        attest.equal(mymetatable.newkey1, nil)
    ]]
analyze[[
    local META = {}

    function META:Foo()
        return 1
    end
    
    function META:Bar()
        return 2
    end

    function META:Faz(a, b)
        return a, b
    end

    local a,b = META:Faz(META:Foo(), META:Bar())
    attest.equal(a, 1)
    attest.equal(b, 2)
]]
analyze[[
    local a = setmetatable({c = true}, {
        __index = {
            foo = true,
            bar = 2,
        }
    })
    
    attest.equal(rawget(a, "bar"), nil)
    attest.equal(rawget(a, "foo"), nil)
    attest.equal(rawget(a, "c"), true)
    
    rawset(a, "foo", "hello")
    attest.equal(rawget(a, "foo"), "hello")
]]
analyze[[
    local self = setmetatable({}, {
        __index = setmetatable({foo = true}, {
            __index = {
                bar = true,
            }
        })
    })
    
    attest.equal(self.foo, true)
    attest.equal(self.bar, true)
]]
analyze[[
    local META = {}
    META.__index = META

    type META.@Self = {
        foo = {[number] = string},
        i = number,
    }

    local type Foo = META.@Self

    local function test2(x: Foo)
        
    end

    local function test(x: Foo & {extra = boolean | nil})
        attest.equal(x.asdf, true) -- x.asdf will __index to META
        x.extra = true
        test2(x as Foo) -- x.extra should not be a valid field in test2
    end

    META.asdf = true

    function META:Lol()
        test(self)
    end
]]
analyze[[
    local meta = {}
    meta.__index = meta

    function meta:Test()
        return self.foo
    end

    local obj = setmetatable({
        foo = 1
    }, meta)

    attest.equal(obj:Test(), 1)
]]
analyze(
	[[
    local meta = {} as {
        __index = self,
        Test = function=(self)>(string)
    }
    meta.__index = meta
    
    function meta:Test()
        return self.foo
    end
    
    local obj = setmetatable({
        foo = 1
    }, meta)
    
    obj:Test()
]],
	"foo.- is not a subset of"
)
analyze([[
    local meta = {} as {
        __index = self, 
        Test = function=(self)>(number),
        foo = number,
    }
    meta.__index = meta

    function meta:Test()
        return self.foo
    end

    local obj = setmetatable({
        foo = 1
    }, meta)

    attest.equal(obj:Test(), _ as number)
]])
analyze([[
    local meta = {}
    meta.__index = meta

    function meta:foo()
        self.data = self.data + 1
        return self.data
    end

    local function foo()
        return setmetatable({data = 0}, meta)
    end

    local obj = foo()
    attest.equal(obj.data, 0)
    attest.equal(meta.data, nil)
    attest.equal(obj:foo(), 1)
]])
analyze[[
    local Vector = {}
    Vector.__index = Vector

    type Vector.x = number
    type Vector.y = number
    type Vector.z = number

    function Vector.__add(a: Vector, b: Vector)
        return Vector(a.x + b.x, a.y + b.y, a.z + b.z)
    end

    setmetatable(Vector, {
        __call = function(_, x: ref number, y: ref number, z: ref number)
            return setmetatable({x=x,y=y,z=z}, Vector)
        end
    })

    local newvector = Vector(1,2,3) + Vector(100,100,100)
    attest.equal(newvector, _ as {x = number, y = number, z = number})
]]
analyze(
	[[
    local Vector = {}
    Vector.__index = Vector

    type Vector.x = number
    type Vector.y = number
    type Vector.z = number

    function Vector.__add(a: Vector, b: Vector)
        return Vector(a.x + b.x, a.y + b.y, a.z + b.z)
    end

    setmetatable(Vector, {
        __call = function(_, x: number, y: number, z: number)
            return setmetatable({x=x,y=y,z=z}, Vector)
        end
    })

    local new_vector = Vector(1,2,3) + 4

    attest.equal(new_vector, _ as {x = number, y = number, z = number})
]],
	"4 is not the same type as"
)
analyze[[
    type code_ptr = {
        @Name = "codeptr",
        @MetaTable = self,
        [number] = number,
        __add = function=(self | number, number | self)>(self),
        __sub = function=(self | number, number | self)>(self)
    }
    
    local x: code_ptr
    local y = x + 50 - 1
    
    attest.equal(y, _ as code_ptr)
]]
analyze[[
    local type tbl = {}
    type tbl.@Name = "blackbox"
    setmetatable<|tbl, {__call = analyzer function(self: typeof tbl, tbl: {foo = nil | number}) return tbl:Get(types.LString("foo")) end}|>

    local lol = tbl({foo = 1337})

    attest.equal(lol, 1337)
]]
analyze[[
    local type tbl = {}
    type tbl.__call = analyzer function(self: typeof tbl, tbl: {foo = nil | number}) return tbl:Get(types.LString("foo")) end
    setmetatable<|tbl, tbl|>

    local lol = tbl({foo = 1337})
    attest.equal(lol, 1337)
]]
analyze[[
    local meta = {}
    meta.__index = meta
    
    local function ctor1()
        return setmetatable({foo = 1}, meta)
    end
    
    local function ctor2()
        local self = {}
        self.foo = 2
        setmetatable(self, meta)
        return self
    end
    
    §analyzer:AnalyzeUnreachableCode()
    
    function meta:Foo(a: number)
        return self.foo + 1
    end
    
    §analyzer:AnalyzeUnreachableCode()
    
    local type ret = return_type<|meta.Foo|>[1]
    attest.equal<|ret, 2 | 3|>
]]
analyze[[
    local META = {}
    META.__index = META

    type META.@Self = {
        Foo = number
    }

    function META:GetBar()
        return 1337
    end

    function META:GetFoo()
        return self.Foo + self:GetBar()
    end

    local s = setmetatable({Foo = 1337}, META)
    attest.equal(s:GetFoo(), _ as number)
]]
analyze[[
    local META = {}
    META.__index = META
    type META.@Self = {parent = number | nil}
    function META:SetParent(parent : number | nil)
        if parent then
            self.parent = parent
            attest.equal(self.parent, _ as number)
        else
            self.parent = nil
            attest.equal(self.parent, _ as nil)
        end

    attest.equal(self.parent, _ as nil | number)
    end
]]
analyze(
	[[
    local META = {}
    META.__index = META

    type META.@Self = {
        foo = {[number] = string},
        i = number,
    }

    function META:Lol()
        self.foo[self.i] = {"bad type"}
    end
]],
	"bad type.-is not a subset of string"
)
analyze[[
    local function GetSet(tbl: ref any, name: ref string, default: ref any)
        tbl[name] = default as NonLiteral<|default|>
        type tbl.@Self[name] = tbl[name]
        
        tbl["Set" .. name] = function(self: tbl.@Self, val: typeof tbl[name])
            self[name] = val
        end
        
        tbl["Get" .. name] = function(self: tbl.@Self): typeof tbl[name]
            return self[name]
        end
    end

    local META = {}
    META.__index = META
    type META.@Self = {}

    GetSet(META, "Foo", true)

    local self = setmetatable({} as META.@Self, META)
    self:SetFoo(true)
    local b = self:GetFoo()
    attest.equal<|b, boolean|>
    attest.equal<|self.Foo, boolean|>
]]
analyze[[
    local META =  {}
    META.__index = META

    type META.@Self = {
        foo = true,
    }

    local function test(x: META.@Self & {bar = false})
        attest.superset_of<|x, {foo = true, bar = false}|>
        attest.superset_of<|META.@Self, {foo = true}|>
    end

]]
analyze[[

    -- class.lua
    -- Compatible with Lua 5.1 (not 5.0).
    local function class(base: ref any, init: ref any)
        local c = {}    -- a new class instance
        if not init and type(base) == 'function' then
           init = base
           base = nil
        elseif type(base) == 'table' then
         -- our new class is a shallow copy of the base class!
           for i,v in pairs(base) do
              c[i] = v
           end
           c._base = base
        end
        -- the class will be the metatable for all its objects,
        -- and they will look up their methods in it.
        c.__index = c
     
        -- expose a constructor which can be called by <classname>(<args>)
        local mt = {}
        mt.__call = function(class_tbl, ...)
            local obj = {}
            setmetatable(obj,c)
            if init then
                init(obj,...)
            else 
            -- make sure that any stuff from the base class is initialized!
            if base and base.init then
            base.init(obj, ...)
            end
            end
            return obj
        end
        c.init = init
        c.is_a = function(self: ref any, klass: ref any)
           local m = getmetatable(self)
           while m do 
              if m == klass then return true end
              m = m._base
           end
           return false
        end
        setmetatable(c, mt)
        return c
     end
    
     
    local Animal = class(function(a: ref any,name: ref any)
        a.name = name
    end)
    
    function Animal:__tostring(): ref string -- we have to say that it's a literal string, otherwise the test won't work
        return self.name..': '..self:speak()
    end
    
    local Dog = class(Animal)
    
    function Dog:speak()
        return 'bark'
    end
    
    local Cat = class(Animal, function(c: ref any,name: ref any,breed: ref any)
        Animal.init(c,name)  -- must init base!
        c.breed = breed
    end)
    
    function Cat:speak()
        return 'meow'
    end
    
    local Lion = class(Cat)
    
    function Lion:speak()
        return 'roar'
    end
        
    local fido = Dog('Fido')
    local felix = Cat('Felix','Tabby')
    local leo = Lion('Leo','African')
    
    attest.equal(leo:is_a(Animal), true)
    attest.equal(leo:is_a(Cat), true)
    attest.equal(leo:is_a(Dog), false)
    attest.equal(leo:__tostring(), "Leo: roar")
    attest.equal(leo:speak(), "roar")


]]
analyze[[

    local function class()
        local meta = {}
        meta.__index = meta
        meta.Data = {}
        
        setmetatable(meta, meta)
        
        type meta.@Self = {}
        type meta.Data = meta.@Self
    
        function meta:__call(...)
    
            local analyzer function setmetatable(tbl: Table, meta: Table, ...: ...any)
    
                local data = meta:Get(types.LString("Data"))
                
                local constructor = analyzer:Assert(meta:Get(types.LString("constructor")))
    
                local self_arg = types.Any()
                self_arg:SetReferenceArgument(true)
                constructor:GetInputSignature():Set(1, self_arg)
            
                tbl:SetMetaTable(meta)
                analyzer:Assert(analyzer:Call(constructor, types.Tuple({tbl, ...})))
                analyzer:Assert(tbl:FollowsContract(data))
                tbl:CopyLiteralness(data)
            
                return tbl
            end
            
    
            return setmetatable({}, meta, ...)
        end
    
        
        return meta
    end
    
    local Animal = class()
    
    type Animal.Data.name = string
    type Animal.Data.age = number
    
    function Animal:constructor(theName: string)
        self.name = theName
        self.age = 123
    end
    
    function Animal:move(distanceInMeters: number | nil)
        distanceInMeters = distanceInMeters or 0
        attest.equal(self.name .. " moved " .. distanceInMeters .. "m.", _ as string)
    end
    

]]
analyze[[
    local type IPlayer = {}
    do
        type IPlayer.@MetaTable = IPlayer
        type IPlayer.@Name = "IPlayer"
        type IPlayer.__index = function<|self: IPlayer, key: string|>
            if key == "IsVisible" then
                return _ as function=(IPlayer, IPlayer)>(1337)
            end
        end
        
        type IPlayer.GetName = function=(IPlayer)>(string)
    
        type IPlayer.@Contract = IPlayer
    end
    
    type Player = function=(entityIndex: number)>(IPlayer)
    
    do
        local ply = Player(1337)
        ply:GetName()
        attest.equal(ply:IsVisible(ply), 1337)
    end
]]
analyze[[
    local type IPlayer = {}
    local type IEntity = {}

    do
        type IEntity.@Name = "IEntity"
        type IEntity.@MetaTable = IEntity
        type IEntity.__index = IEntity
        
        type IEntity.IsVisible = function=(IEntity, target: IEntity)>(boolean)

        type IEntity.@Contract = IEntity
    end

    do
        type IPlayer.@Name = "IPlayer"
        type IPlayer.@MetaTable = IPlayer
        type IPlayer.__index = IPlayer
        type IPlayer.@BaseTable = IEntity
        
        type IPlayer.GetName = function=(IPlayer)>(string)

        type IPlayer.@Contract = IPlayer
    end

    type Player = function=(entityIndex: number)>(IPlayer)


    do
        local ply = Player(1337)
        ply:GetName()
        attest.equal(ply:IsVisible(ply), _ as boolean)
    end
]]
analyze[[
local FALLBACK = "lol"

setmetatable(_G, {
    __index = function(t: ref any, n: ref any)
        return FALLBACK
    end
})

local x = NON_EXISTING_VARIABLE
attest.equal(x, FALLBACK)

setmetatable(_G)
]]
analyze[[
    setmetatable(_G, {__index = function(self: ref any, key: ref any) return "LOL" end})
    attest.equal(DUNNO, "LOL")
    setmetatable(_G)
]]
analyze[[
    local META = {}
    META.__index = META
    type META.@Name = "Syntax"
    type META.@Self = {
        Keywords = Map<|string, true|>,
    }
    
    function META.New() 
        local self = setmetatable({
            Keywords = {},
        }, META)
        return self
    end
    
    
    function META:AddSymbols(tbl: List<|string|>)
        
    end
    
    function META:AddKeywords(tbl: List<|string|>)
        self:AddSymbols(tbl)
        for _, str in ipairs(tbl) do
            self.Keywords[str] = true
        end
    end
    
    local Syntax = META.New
    local function lol()
        local runtime = Syntax()
    
        local s = {}
        runtime:AddKeywords(s)
    
        return runtime
    end
    lol()

]]
analyze(
	[[

    local type meta = {}
    type meta.@Self = {
        pointer = ref boolean,
        ffi_name = ref string,
        fields = {[string] = number | self | string},
    }
    
    function meta:__index<|key: string|>
        local type val = rawget<|self, key|>
    
        if val then return val end
    
        type_error<|("%q has no member named %q"):format(self.ffi_name, key), 2|>
    end
    
    function meta:__add<|other: number|>
        if self.pointer then return self end
    
        type_error<|("attempt to perform arithmetic on %q and %q"):format(self.ffi_name, TypeName<|other|>), 2|>
    end
    
    function meta:__sub<|other: number|>
        if self.pointer then return self end
    
        type_error<|("attempt to perform arithmetic on %q and %q"):format(self.ffi_name, TypeName<|other|>), 2|>
    end
    
    function meta:__len<||>
        type_error<|("attempt to get length of %q"):format(self.ffi_name), 2|>
    end
    
    local function CData<|data: Table, name: string, pointer: boolean|>
        local type self = setmetatable<|{
            pointer = pointer,
            ffi_name = name,
            fields = data,
        }, meta|>
        return self
    end
    
    local x = {} as CData<|{foo = number}, "struct 66", false|>
    local y = x + 2

]],
	"x %+ 2.+attempt to perform arithmetic on"
)
analyze[[
    local type meta = {}
    type meta.__index = meta

    type meta.@Self = {
        value = ref {[any] = any}
    }
    
    function meta:__index<|key: any|>
        local obj = setmetatable<|{value = {[any] = any}}, meta|>
        self.value[key] = obj | self.value[key]
        return obj | any
    end
    
    function meta:__newindex<|key: any, val: any|>
        self.value[key] = self.value[key] | val
    end
    
    function meta:__add<|other: any|>
        return Widen(other)
    end
    
    function meta:__concat<|other: any|>
        return Widen(other)
    end
    
    function meta:__len<||>
        return number
    end
    
    function meta:__unm<||>
        return any
    end
    
    function meta:__bnot<||>
        return any
    end
    
    function meta:__sub<|b: any|>
        return Widen(b)
    end
    
    function meta:__mul<|b: any|>
        return Widen(b)
    end
    
    function meta:__div<|b: any|>
        return Widen(b)
    end
    
    function meta:__idiv<|b: any|>
        return Widen(b)
    end
    
    function meta:__mod<|b: any|>
        return Widen(b)
    end
    
    function meta:__pow<|b: any|>
        return Widen(b)
    end
    
    function meta:__band<|b: any|>
        return Widen(b)
    end
    
    function meta:__bor<|b: any|>
        return Widen(b)
    end
    
    function meta:__bxor<|b: any|>
        return Widen(b)
    end
    
    function meta:__shl<|b: any|>
        return Widen(b)
    end
    
    function meta:__shr<|b: any|>
        return Widen(b)
    end
    
    function meta:__eq<|b: any|>
        return boolean
    end
    
    function meta:__lt<|b: any|>
        return Widen(b)
    end
    
    function meta:__le<|b: any|>
        return Widen(b)
    end
    
    function meta:__call<|...: ...any|>
        local ret = setmetatable<|{value = {[any] = any}}, meta|>
        self.value = function=((...))>((ret)) | self.value
        return ret
    end
    
    local function InferenceObject<||>
        return setmetatable<|{value = {[any] = any}}, meta|>
    end


    local type lib = InferenceObject<||>

    lib.foo.bar = true
    lib.foo(1,2,3)

    attest.equal<|lib, { ["value"] = { [any] = any } as {
        [any] = any,
        ["foo"] = any | { ["value"] = { [any] = any } },
        ["bar"] = any | true,
        ["value"] = any | function=(1, 2, 3)>({ ["value"] = { [any] = any }  },)
       } }
    |>
]]
analyze[[
    local meta = {}
    meta.__index = meta
    type meta.@Self = {
        type = number,
    }

    function meta:lol(foo: self.type)
        return foo + 1
    end

    local s = setmetatable({type = 1}, meta)
    attest.equal(s:lol(1), _  as number)
]]