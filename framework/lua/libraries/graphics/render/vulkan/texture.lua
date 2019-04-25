local vk = desire("vulkan")
local ffi = require("ffi")
local freeimage = require("freeimage")

function render.CreateTexture(file_name, format)
	format = format or "b8g8r8a8_unorm"

	local image_infos = freeimage.LoadImageMipMaps(file_name)

	local self = {}

	self.width = image_infos[1].width
	self.height = image_infos[1].height
	self.mip_levels = #image_infos

	local properties = render.physical_device:GetFormatProperties(format)

	local cmd = render.CreateCommandBuffer()
	cmd:Begin()

	if bit.band(properties.linearTilingFeatures, vk.e.format_feature.sampled_image) ~= 0 then
		local image = render.CreateImage({
			width = self.width,
			height = self.height,
			format = format,
			usage = {"transfer_dst", "transfer_src", "sampled"},
			tiling = "undefined",
			required_props = {"host_visible", "coherent"},
			levels = self.mip_levels,
		})

		cmd:SetImageLayout(image.image, "color", "undefined", "transfer_dst_optimal")

		self.image = image.image
		self.memory = image.memory
		self.size = image.size

		-- copy the mip maps into temporary images
		for i, image_info in ipairs(image_infos) do
			local image = render.CreateImage({
				width = image_info.width,
				height = image_info.height,
				format = format,
				usage = "transfer_src",
				tiling = "linear",
				required_props = {"host_visible", "coherent"},
			})

			image.width = image_info.width
			image.height = image_info.height
			image.format = format

			render.device:MapMemory(image.memory, 0, image.size, 0, "uint8_t", function(data)
				ffi.copy(data, image_info.data, image.size)
			end)

			cmd:SetImageLayout(image.image, "color", "undefined", "transfer_src_optimal")

			image_infos[i] = image
		end

		-- copy from temporary mip map images to main image
		for i, mip_map in ipairs(image_infos) do
			cmd:CopyImage(mip_map.image, self.image, mip_map.width, mip_map.height, i - 1)

			--render.device:DestroyImage(mip_map.image, nil)
			--render.device:FreeMemory(mip_map.memory, nil)
		end

		cmd:SetImageLayout(image.image, "color", "transfer_dst_optimal", "shader_read_only_optimal")
	else
		self.mip_levels = 1

		local info = render.CreateImage({
			width = self.width,
			height = self.height,
			format = format,
			usage = "sampled",
			tiling = "linear",
			required_props = {"host_visible"}
		})

		self.image = info.image
		self.memory = info.memory
		self.size = info.size

		render.device:MapMemory(info.memory, 0, info.size, 0, "uint8_t", function(data)
			ffi.copy(data, image_infos[1].data, image_infos[1].size)
		end)

		cmd:SetImageLayout(info.image, "color", "undefined", "shader_read_only_optimal")
	end

	self.sampler = render.device:CreateSampler({
		magFilter = "linear",
		minFilter = "linear",
		mipmapMode = "linear",
		addressModeU = "repeat",
		addressModeV = "repeat",
		addressModeW = "repeat",
		ipLodBias = 0.0,
		anisotropyEnable = true,
		maxAnisotropy = 8,
		compareOp = "never",
		minLod = 0.0,
		maxLod = self.mip_levels,
		borderColor = "float_opaque_white",
		unnormalizedCoordinates = 0,
	})

	self.view = render.device:CreateImageView({
		viewType = "2d",
		image = self.image,
		format = format,
		flags = 0,
		components = {r = "r", g = "g", b = "b", a = "a"},
		subresourceRange = {
			aspectMask = "color",

			levelCount = self.mip_levels,
			baseMipLevel = 0,

			layerCount = 1,
			baseLayerLevel = 0
		},
	})

	self.format = format
	self.image_infos = image_infos

	cmd:End()
	cmd:Flush()

	return self
end