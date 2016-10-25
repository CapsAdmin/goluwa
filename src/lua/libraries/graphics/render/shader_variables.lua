local render = ... or _G.render
local ffi = require("ffi")
local META = prototype.CreateTemplate("shader_variables")

function render.CreateShaderVariables(typ, shader, name)
	local total_size = 0

	local properties = shader.program:GetProperties()
	local block = typ == "uniform" and properties.uniform_block[name] or properties.shader_storage_block[name]
	local variables = {}

	for _, v in pairs(block.variables) do

		variables[v.name] = {}

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
				set = function(buffer, var)
					temp = var:GetFloatPointer()
					buffer:UpdateData(temp, size, offset)
				end
			elseif length == 4 then
				set = function(buffer, var)
					temp[0] = var.r
					temp[1] = var.g
					temp[2] = var.b
					temp[3] = var.a
					buffer:UpdateData(temp, size, offset)
				end
			elseif length == 3 then
				set = function(buffer, var)
					temp[0] = var.x
					temp[1] = var.y
					temp[2] = var.z
					buffer:UpdateData(temp, size, offset)
				end
			elseif length == 2 then
				set = function(buffer, var)
					temp[0] = var.x
					temp[1] = var.y
					buffer:UpdateData(temp, size, offset)
				end
			elseif v.type.name == "float" then
				set = function(buffer, var)
					temp[0] = var
					buffer:UpdateData(temp, size, offset)
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

		variables[v.name].set = set
		variables[v.name].get = function() return temp end
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

function META:UpdateVariable(key, val)
	if self.variables[key] and self.last_variables[key] ~= val then
		self.variables[key].set(self.buffer, val)
		self.last_variables[key] = val
	end
end

function META:Bind(bind_location)
	self.buffer:Bind(bind_location)
end

META:Register()