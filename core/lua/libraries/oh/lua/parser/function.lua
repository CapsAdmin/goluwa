local META = ...

function META:IsFunctionStatement()
    return
        self:IsValue("function") or
        (self:IsValue("local") and self:GetTokenOffset(1).value == "function")
end

local function read_short_call_body(self, node)

    local implicit_return = false

    if self:IsValue("(") then
        node.tokens["func("] = self:ReadToken("(")
    else
        implicit_return = true
    end

    node.arguments = self:IdentifierList()

    if self:IsValue(")") then
        node.tokens["func)"] = self:ReadToken(")")
    end

    if implicit_return then
        --[[

        node.block = {type = "block", statements = {ret}}
        node.no_end = true
        ]]
        node.block = self:Block({["end"] = true, [")"] = true}, true)
        node.no_end = true
    else
        node.block = self:Block({["end"] = true})
        node.tokens["end"] = self:ReadToken("end")
    end

    return node
end

local function read_call_body(self, node)
    local start = self:GetToken()

    node.tokens["func("] = self:ReadExpectValue("(")
    node.arguments = self:IdentifierList()
    node.tokens["func)"] = self:ReadExpectValue(")", start, start)
    node.block = self:Block({["end"] = true})
    node.tokens["end"] = self:ReadExpectValue("end")

    return node
end

function META:ReadFunctionStatement()
    local node = self:Node("function")

    if self:IsValue("local") then
        node.tokens["local"] = self:ReadToken("local")
		node.tokens["function"] = self:ReadExpectValue("function")

		node.value = self:Node("value")
		node.value.value = self:ReadExpectType("letter")
		node.is_local = true
    else
        node.tokens["function"] = self:ReadExpectValue("function")
        node.value = self:Expression(0, true)
    end

    return read_call_body(self, node)
end

function META:IsAnonymousFunction()
    return
        self:IsValue("function") or self:IsValue("do")
end

function META:AnonymousFunction()
    if self:IsValue("do") then
        local node = self:Node("function")
        node.tokens["function"] = self:ReadExpectValue("do")
        return read_short_call_body(self, node)
    else
        local node = self:Node("function")
        node.tokens["function"] = self:ReadExpectValue("function")

        return read_call_body(self, node)
    end
end