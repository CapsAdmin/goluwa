local vk = desire("vulkan")
local ffi = require("ffi")

function render.CreateBuffer(usage, data)
	local size = ffi.sizeof(data)
	local buffer = render.device:CreateBuffer({
		size = size,
		usage = usage,
	})

	local memory = render.AllocateMemory(size, render.device:GetBufferMemoryRequirements(buffer).memoryTypeBits, {"host_visible"})

	render.device:MapMemory(memory, 0, size, 0, "float", function(cdata)
		ffi.copy(cdata, data, size)
	end)

	render.device:BindBufferMemory(buffer, memory, 0)

	local self = {
		buffer = buffer,
		memory = memory,
		data = data,
		size = size,
	}

	function self:Update()
		ffi.copy(render.device:MapMemory(self.memory, 0, self.size, 0), self.data, self.size)
		render.device:UnmapMemory(self.memory)
	end

	return self
end