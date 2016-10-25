local render = ... or _G.render
local ffi = require("ffi")
local META = prototype.CreateTemplate("shader_variables")

function render.CreateShaderVariables(typ, shader, name, extra_size)
	extra_size = extra_size or 0

	local properties = shader.program:GetProperties()
	local block = typ == "uniform" and properties.uniform_block[name] or properties.shader_storage_block[name]
	local total_size = block.buffer_data_size + extra_size
	local variables = {}

	for _, v in pairs(block.variables) do
		-- when using interface blocks the name will be prefixed with "foo."
		local name = v.name
		name = name:match(".+%.(.+)") or name
		name = name:match("(.+)%[") or name
		variables[name] = {}

		local temp
		local set
		local get
		if v.type.size then
			local size = v.type.size
			local offset = v.offset

			total_size = math.max(offset, total_size)

			local length =  v.type.size / ffi.sizeof("float")
			temp = ffi.new("float[?]", length)

			if length == 16 then
				set = function(buffer, var, index)
					temp = var:GetFloatPointer()
					buffer:UpdateData(temp, size, offset + (index * v.array_stride))
				end
			elseif length == 4 then
				set = function(buffer, var, index)
					temp[0] = var.r
					temp[1] = var.g
					temp[2] = var.b
					temp[3] = var.a
					buffer:UpdateData(temp, size, offset + (index * v.array_stride))
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
			end
		--[[else
			local size = ffi.typeof("uint64_t")
			local offset = v.offset

			total_size = math.max(offset, total_size)

			temp = ffi.new("uint16_t[1]")

			set = function(buffer, var)
				temp[0] = var
				buffer:UpdateData(temp, size, offset)
			end]]
		end

		variables[name].set = set
		variables[name].get = function() return temp end
	end

	local self = META:CreateObject()

	self.last_variables = {}
	self.variables = variables
	self.buffer = render.CreateShaderVariableBuffer(typ, "dynamic_draw", total_size)
	self.block = block
	self.type = typ

	return self
end

function META:SetBindLocation(shader, bind_location)
	if self.type == "uniform" then
		shader.program:BindUniformBuffer(self.block.block_index, bind_location)
	else
		shader.program:BindShaderBlock(self.block.block_index, bind_location)
	end
end

function META:UpdateVariable(key, val, index)
	index = index or 1

	if self.variables[key] and self.last_variables[key] ~= val then
		self.variables[key].set(self.buffer, val, index)
		self.last_variables[key] = val
	end
end

function META:Bind(bind_location)
	self.buffer:Bind(bind_location)
end

META:Register()