local render = ... or _G.render
local ffi = require("ffi")
local META = prototype.CreateTemplate("shader_variables")

function render.CreateShaderVariables(typ, shader, name, extra_size, persistent)
	extra_size = extra_size or 0

	local properties = shader.program:GetProperties()
	local block

	if typ == "uniform" and properties.uniform_block then
		block = properties.uniform_block[name]
	elseif properties.shader_storage_block then
		block = properties.shader_storage_block[name]
	else
		block = {buffer_data_size = 0, variables = {}}
	end

	local total_size = block.buffer_data_size + extra_size
	local variables = {}
	local variables2 = {}

	for _, v in pairs(block.variables) do
		-- when using interface blocks the name will be prefixed with "foo."
		local name = v.name
		name = name:match(".+%.(.+)") or name
		name = name:match("(.+)%[") or name
		variables[name] = {}
		table.insert(variables2, name)

		local temp
		local set
		local get

		if v.type.size then
			local size = v.type.size
			local offset = v.offset

			total_size = math.max(offset+size, total_size)

			local length =  v.type.size / ffi.sizeof("float")
			temp = ffi.new("float[?]", length)

			if length == 16 or length == 9 then
				set = function(buffer, var, index)
					temp = var:GetFloatPointer()
					buffer:UpdateData(temp, size, offset + (index * v.array_stride))
				end
			elseif length == 4 then
				if SRGB then
				local linear2gamma = math.linear2gamma
					set = function(buffer, var, index)
						temp[0] = linear2gamma(var.r)
						temp[1] = linear2gamma(var.g)
						temp[2] = linear2gamma(var.b)
						temp[3] = var.a
						buffer:UpdateData(temp, size, offset + (index * v.array_stride))
					end
				else
					set = function(buffer, var, index)
						temp[0] = var.r
						temp[1] = var.g
						temp[2] = var.b
						temp[3] = var.a
						buffer:UpdateData(temp, size, offset + (index * v.array_stride))
					end
				end
			elseif length == 3 then
				set = function(buffer, var, index)
					temp[0] = var.x
					temp[1] = var.y
					temp[2] = var.z
					buffer:UpdateData(temp, size, offset + (index * v.array_stride))
				end
			elseif length == 2 then
				set = function(buffer, var, index)
					temp[0] = var.x
					temp[1] = var.y
					buffer:UpdateData(temp, size, offset + (index * v.array_stride))
				end
			elseif v.type.name == "float" then
				set = function(buffer, var, index)
					temp[0] = var
					buffer:UpdateData(temp, size, offset + (index * v.array_stride))
				end
			elseif v.type.name == "bool" then
				set = function(buffer, var, index)
					temp[0] = var and 1 or 0
					buffer:UpdateData(temp, size, offset + (index * v.array_stride))
				end
			end
		elseif v.type.name:find("sampler") then
			local size = ffi.sizeof("uint64_t")
			local offset = v.offset

			total_size = math.max(offset + size, total_size)

			temp = ffi.new("uint64_t[1]")

			set = function(buffer, var, index)
				if not var.gl_bindless_handle then
					var:SetBindless(true)
				end
				temp[0] = var.gl_bindless_handle
				buffer:UpdateData(temp, size, offset + (index * v.array_stride))
			end
		end

		variables[name].set = set
		variables[name].get = function() return temp end
	end

	local self = META:CreateObject()

	self.last_variables = {}
	self.variables = variables
	self.variables2 = variables2
	self.buffer = render.CreateShaderVariableBuffer(typ, total_size, persistent)
	self.block = block
	self.type = typ

	return self
end

function META:BeginWrite()
	if self.buffer.ptr then
		self.buffer:WaitForLockedRange()
	end
end

function META:EndWrite()
	if self.buffer.ptr then
		self.buffer:LockRange()
	end
end

function META:SetBindLocation(shader, bind_location)
	if self.type == "uniform" then
		shader.program:BindUniformBuffer(self.block.block_index, bind_location)
	else
		shader.program:BindShaderBlock(self.block.block_index, bind_location)
	end
end

function META:UpdateVariable(key, val, index)
	if self.variables[key] and self.last_variables[key] ~= val then
		self.variables[key].set(self.buffer, val, index or 0)
		if type(val) == "cdata" then
			val = val:Copy()
		end
		self.last_variables[key] = val
	end
end

local last_bound

function META:Bind(bind_location)
	if last_bound ~= self then
		self.buffer:Bind(bind_location)
		last_bound = self
	end
end

META:Register()