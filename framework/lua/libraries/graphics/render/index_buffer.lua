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

function META:LoadIndices(val)
	local tbl

	if type(val) == "number" then
		if val > 0xFFFF then
			self:SetIndicesType("uint32_t")
		end

		tbl = {}
		for i = 1, val do
			tbl[i] = i-1
		end
	elseif type(val[1]) == "table" then
		if #val > 0xFFFF then
			self:SetIndicesType("uint32_t")
		end

		tbl = {}
		for i in ipairs(val) do
			tbl[i] = i-1
		end
	else
		tbl = val

		local max = 0
		for _, i in ipairs(val) do
			max = math.max(max, i)
		end

		if max > 0xFFFF then
			self:SetIndicesType("uint32_t")
		end
	end

	self:SetIndices(Array(self:GetIndicesType(), #tbl, tbl))

	return tbl
end

function META:UpdateBuffer()
	self:SetIndices(self.Indices)
end

META:Register()