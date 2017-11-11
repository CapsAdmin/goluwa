local render = (...) or _G.render

local META = prototype.CreateTemplate("index_buffer")

META:StartStorable()
	META:GetSet("UpdateIndices", true)
	META:GetSet("IndicesType", "uint16_t")
	META:GetSet("DrawHint", "dynamic")
	META:GetSet("Indices")
META:EndStorable()

function render.CreateIndexBuffer()
	local self = META:CreateObject()

	render._CreateIndexBuffer(self)

	return self
end

function META:SetIndices(indices)
	self.Indices = indices
	self:_SetIndices(indices)
end

function META:UnreferenceMesh()
	self.Indices = nil
	collectgarbage("step")
end

function META:SetIndex(idx, idx2)
	self.Indices.Pointer[idx-1] = idx2
end

function META:GetIndex(idx)
	return self.Indices.Pointer[idx-1]
end

function META:LoadVertices(vertices)
	if type(vertices) == "number" then
		if vertices > 0xFFFF then
			self:SetIndicesType("uint32_t")
		end

		local size = vertices

		local indices = Array(self:GetIndicesType(), size)
		for i = 0, size - 1 do indices[i] = i end

		self:SetIndices(indices)

		return indices
	else
		if #vertices > 0xFFFF then
			self:SetIndicesType("uint32_t")
		end

		local indices = {}
		for i in ipairs(vertices) do
			indices[i] = i-1
		end

		self:SetIndices(Array(self:GetIndicesType(), #indices, indices))

		return indices
	end
end

function META:LoadIndices(indices)

	local max = 0
	for _, i in ipairs(indices) do
		max = math.max(max, i)
	end

	if max > 0xFFFF then
		self:SetIndicesType("uint32_t")
	end

	self:SetIndices(Array(self:GetIndicesType(), #indices, indices))
end

function META:UpdateBuffer()
	self:SetIndices(self.Indices)
end

META:Register()