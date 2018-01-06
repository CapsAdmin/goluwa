local vk = desire("vulkan")
local ffi = require("ffi")

function render.CreateImage(info)
	local image = render.device:CreateImage({
		imageType = "2d",
		format = info.format,
		extent = {info.width, info.height, 1},
		mipLevels = info.levels or 1,
		arrayLayers = 1,
		samples = "1",
		tiling = info.tiling,
		usage = info.usage,
		flags = 0,
		queueFamilyIndexCount = 0,
		sharingMode = "exclusive",
		initialLayout = "preinitialized",
	})

	local memory_requirements = render.device:GetImageMemoryRequirements(image)

	local memory = render.AllocateMemory(memory_requirements.size, memory_requirements.memoryTypeBits, info.required_props)

	render.device:BindImageMemory(image, memory, 0)

	return {
		image = image,
		memory = memory,
		size = memory_requirements.size,
	}
end
