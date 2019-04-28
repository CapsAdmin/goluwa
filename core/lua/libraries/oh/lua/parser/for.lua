local META = ...

function META:IsForStatement()
    return self:IsValue("for")
end

function META:ReadForStatement()
    local node
    local for_token = self:ReadToken()

    local identifier = self:ReadIdentifier()

    if self:IsValue("=") then
        node = self:Node("for_i")
        node.identifier = identifier
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

        if self:IsValue(",") then
            identifier.tokens[","] = self:ReadToken()
            node.identifiers = self:IdentifierList({identifier})
        else
            node.identifiers = {identifier}
        end

        node.tokens["in"] = self:ReadExpectValue("in")
        node.expressions = self:ExpressionList()
    end


    node.tokens["for"] = for_token

    self:PushLoopBlock(node)
    node.tokens["do"] = self:ReadExpectValue("do")
    node.block = self:Block({["end"] = true})
    node.tokens["end"] = self:ReadExpectValue("end", for_token, for_token)
    self:PopLoopBlock()

    return node
end