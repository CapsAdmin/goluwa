local META = ...

function META:IsForStatement()
    return self:IsValue("for")
end

function META:ReadForStatement()
    local node
    local for_token = self:ReadToken()

    self:PushLoopBlock(node)

    local identifier = self:ReadExpectType("letter")

    if self:IsValue("=") then
        node = self:Node("for_i")
        node.identifier = self:Node("value")
        node.identifier.value = identifier
        node.tokens["="] = self:ReadToken("=")
        node.expression = self:Expression()
        node.tokens[",1"] = self:ReadExpectValue(",")
        node.max = self:Expression()

        if self:IsValue(",") then
            node.tokens[",2"] = self:ReadToken()
            node.step = self:Expression()
        end

    else
        node = self:Node("for_kv")
        local name = self:Node("value")
        name.value = identifier

        if self:IsValue(",") then
            name.tokens[","] = self:ReadToken()
            node.identifiers = self:NameList({name})
        else
            node.identifiers = {name}
        end

        node.tokens["in"] = self:ReadExpectValue("in")
        node.expressions = self:ExpressionList()
    end

    node.tokens["do"] = self:ReadExpectValue("do")
    node.tokens["for"] = for_token

    local block = self:Block({["end"] = true})
    node.tokens["end"] = self:ReadExpectValue("end", for_token, for_token)
    node.block = block

    self:PopLoopBlock()

    return node
end