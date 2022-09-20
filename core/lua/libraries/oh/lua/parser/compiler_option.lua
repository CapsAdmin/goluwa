local META = ...

function META:IsCompilerOption()
	return self:IsType("compiler_option")
end

function META:ReadCompilerOption()
	local node = self:Node("compiler_option")
	node.lua = self:ReadToken().value:sub(2)

	if node.lua:startswith("P:") then
		assert(loadstring("local self = ...;" .. node.lua:sub(3)))(self)
	end

	return node
end