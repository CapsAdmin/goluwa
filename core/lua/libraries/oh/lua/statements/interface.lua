local META = ...

function META:IsInterfaceStatemenet()
    return self:IsValue("interface")
end

function META:ReadInterfaceStatement()
    local node = self:Node("interface")
    node.tokens["interface"] = self:ReadToken()
    node.name = self:ReadExpectType("letter")
    node.interface = self:Table()
    return node
end