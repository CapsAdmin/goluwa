local code = vfs.Read("lua/modules/lua_parser.lua")
code = [[
    local a = 5
    local b = 30
    do
        local c = a
        local lol = true

        local hmm = function(rofl, lmao) lol = rofl end

        function test(hah)
            local test = test
        end
    end
    local test = c

    local b = 2
    local a = b

    do
        c = b

        function test(hah)
            local test = test
        end
    end

    local test = c

    local lol = true
    lol = false

    local c = 2
    local a = LOL + b + test

    local a = function() end

    if math.random() > 0.5 then
        a = 1337
    else
        a = "foo"
    end

    local a = true
    local b = a

    local b = 1337
    if false or true then
        b = false
        local test = ""
    end
    local b = b

    local b = 1337
    if false then
        b = false
        local test = ""
    end
    local b = b

    local b = true
    local test = false or b
    if test then
        test = 1
    end
]]

local tokenizer = oh.Tokenizer(code)
local tokens = tokenizer:GetTokens()
local parser = oh.Parser()
local ast = parser:BuildAST(tokens)

local found = {}
local assignment = false

local level = 1
local scope_stack = {}
local scope
local branch_evaluation = nil

local function is_type(val, typ)
    if not val.value_types then return false end
    for _, str in ipairs(val.value_types) do
        if str == typ then
            return true
        end
    end
    return false
end

local function get_types(val)
    return table.concat(val.value_types, "|")
end


local function copy_scope()
    local copy = {}
    for i,v in ipairs(scope) do
        copy[i] = v
    end
    return copy
end

local function push_scope()
    local parent = scope
    scope = {type = "scope", parent = parent, children = {}}
    if parent then
        table.insert(parent.children, scope)
    end
end

local function pop_scope()
    scope = scope.parent
end

local function lookup(key, scp)
    scp = scp or scope
    for i = #scp.children, 1, -1 do
        local var = scp.children[i]
        if var.type == "variable" and var.key.value == key.value then
            return var
        end
    end
    if scp.parent then
        return lookup(key, scp.parent)
    end
end
local function set_variable(key, val, type)
    local reassign = false
    if type == "global" then
        local test = lookup(key)
        if test then
            key = test.key
            type = "upvalue"
            reassign = true
            if val.value_types then
                for i,v in ipairs(test.val.value_types) do
                    if not is_type(val, v) then
                        table.insert(val.value_types, v)
                    end
                end
                for i,v in ipairs(val.value_types) do
                    if not is_type(test.val, v) then
                        table.insert(test.val.value_types, v)
                    end
                end
            end
        end
    end
    table.insert(scope.children, {
        type = "variable",
        variable_type = type,
        key = key,
        val = val,
        reassign = reassign,
    })
end

local function get_value(node)
    if node.type == "value" then
        if node.value.type == "letter" then
            if node.value.value == "nil" then
                return {
                    type = "constant",
                    value_types = {"nil"},
                    value = node.value
                }
            elseif node.value.value == "true" or node.value.value == "false" then
                return {
                    type = "constant",
                    value_types = {"boolean"},
                    value = node.value
                }
            else
                local res = lookup(node.value)
                if res then
                    return {
                        type = "upvalue",
                        value = res
                    }
                else
                    return {
                        type = "global",
                        value_types = {"any"},
                        value = node.value
                    }
                end
            end
        else
            return {
                type = "constant",
                value_types = {node.value.type},
                value = node.value
            }
        end
    end

    if node.type == "operator" then
        return {
            type = "constant",
            value_types = {node.type},
            value = node,
            right = get_value(node.right),
            left = get_value(node.left),
        }
    end

    return {
        type = "constant",
        value_types = {node.type},
        value = node.value,
        not_found = true,
    }
end

local function get_root_value(node)
    if node.type == "value" and node.value.type == "letter" then
        local cur = node
        while true do
            local test = lookup(cur.value)
            if not test or test.variable_type ~= "upvalue" then
                break
            end
            cur = test.val
        end
        return cur.value
    end
    return node
end

local function truthy(node)
    node = get_root_value(node)

    if node.type == "operator" then
        local a = truthy(get_root_value(node.left))
        local b = truthy(get_root_value(node.right))

        if node.operator == "and" then
            return a and b
        elseif node.operator == "or" then
            return a or b
        end

        return true
    end

    if node.type == "letter" then
        if node.value == "false" or node.value == "nil" then
            return false
        end
    end

    return true
end

local function walk(node)
    if node.type == "assignment" then

        local variable_type = node.is_local and "upvalue" or "global"

        if node.sub_type == "function" then
            if node.value.index_expression.type == "value" then
                set_variable(node.value.index_expression.value, {
                    type = "constant",
                    value = node.value,
                    value_types = {node.value.type},
                }, variable_type)
            else
                walk(node.value.index_expression)
            end

            push_scope()
            for i, node in ipairs(node.value.arguments) do
                set_variable(node.value, {
                    type = "argument",
                    value = node.value,
                    index = i,
                    value_types = {"any"}
                }, "upvalue")
                walk(node)
            end
            for _, node in ipairs(node.value.block) do
                walk(node)
            end
            pop_scope()
        else
            local left = node.left
            local right = node.right

            for i, node in ipairs(left) do
                if node.type == "value" then
                    local key = left[i].value
                    local val = nil

                    if right and right[i] then
                        val = get_value(right[i])
                    end

                    if not val then
                        val = {
                            type = "undefined",
                            value_types = {"any"}
                        }
                    end

                    set_variable(key, val, variable_type)
                end
                walk(node)
            end

            if node.right then
                for _, node in ipairs(node.right) do
                    walk(node)
                end
            end
        end
    elseif node.type == "operator" then
        walk(node.left)
        walk(node.right)
    elseif node.type == "do" then
        push_scope()
        for _, node in ipairs(node.block) do
            walk(node)
        end
        pop_scope()
    elseif node.type == "expression" then
        walk(node.value)
    elseif node.type == "table" then
        for _, node in ipairs(node.children) do
            if node.type == "expression_value" then
                walk(node.value)
            elseif node.type == "key_value" then
                walk(node.key)
                walk(node.value)
            end
        end
    elseif node.type == "return" then
        for _, node in ipairs(node.expressions) do
            walk(node)
        end
    elseif node.type == "unary" then
        walk(node.expression)
    elseif node.type == "function" then -- anonymous function
        push_scope()
        for i, node in ipairs(node.arguments) do
            set_variable(node.value, {
                type = "argument",
                value = node.value,
                index = i,
                value_types = {"any"}
            }, "upvalue")
            walk(node)
        end
        for _, node in ipairs(node.block) do
            walk(node)
        end
        pop_scope()
    elseif node.type == "for" then
        if node.expressions then
            for _, node in ipairs(node.expressions) do
                walk(node)
            end
        end
        if node.val then
            walk(node.val)
        end
        for _, node in ipairs(node.block) do
            walk(node)
        end
    elseif node.type == "while" then
        walk(node.expr)
        for _, node in ipairs(node.block) do
            walk(node)
        end
    elseif node.type == "if" then
        for _, clause in ipairs(node.clauses) do
            if clause.expr then -- !!
                walk(clause.expr)
                branch_evaluation = truthy(clause.expr)
            end
            if branch_evaluation == nil or branch_evaluation == true then
                push_scope()
                for _, node in ipairs(clause.block) do
                    walk(node)
                end
                pop_scope()
            end
            if clause.expr then
                branch_evaluation = nil
            end
        end
    elseif node.type == "value" then
        if node.calls then
            for _, node in ipairs(node.calls) do
                if node.type == "index_expression" then
                    walk(node.value)
                elseif node.type == "call" then
                    for _, node in ipairs(node.arguments) do
                        walk(node)
                    end
                end
            end
        end
        if node.value.type == "letter" and node.value.value ~= "true" and node.value.value ~= "false" and node.value.value ~= "nil" then
            local str = node.value.value
            --found[str] = (found[str] or 0) + 1
        else
            -- constant
            --print(node.value.value)
        end
    elseif node.type ~= "break" then
        print(node.type)
    end
end
push_scope()
local tree = scope
for _, node in ipairs(ast) do
    walk(node)
end
pop_scope()

local value2string

local function expand_operator(val)
    if is_type(val, "operator") then
        local str = "("

        if val.left then
            str = str .. value2string(val.left)
        end

        str = str .. " " .. val.value.operator .. " "

        if val.right then
            str = str .. value2string(val.right)
        end

        str = str .. ")"

        return str
    end

    return "?"
end

function value2string(val)
    if val.type == "upvalue" then
        return val.value.variable_type .. " " .. get_types(val.value.val) .. " " .. val.value.key.value
    elseif val.type == "global" then
        return "_G." .. val.value.value
    elseif val.type == "constant" then
        if is_type(val.value_types, "operator") then
            return expand_operator(val)
        else
            local str = get_types(val)
            if val.value and val.value.value then
                str = str .. " " .. tostring(val.value.value)
            end
            return str
        end
    elseif val.type == "argument" then
        return "(arg " .. val.index .. ")"
    end

    table.print(val.type)

    return "undefined"
end

local level = 0
local function dump(scope)
    for _, v in ipairs(scope) do
        if v.type == "variable" then
            log(("       "):rep(level))
            if v.reassign then
                log("change ")
            elseif v.variable_type == "upvalue" then
                log("local  ")
            elseif v.variable_type == "global" then
                log("global ")
            end
            logf("%s = %s\n", v.key.value, value2string(v.val))
        else
            level = level + 1
            dump(v.children)
            level = level - 1
        end
    end
end

dump(tree.children)


---	table.print2(table.tolist(found, function(a,b) return a.val < b.val end))