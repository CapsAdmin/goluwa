local vk = desire("vulkan")
local ffi = require("ffi")

local META = {}
META.__index = META

function META:SetImageLayout(image, aspect_mask, old_layout, new_layout)
	local src_mask = {}
	local dst_mask = {}

	if old_layout == "undefined" then
	--	src_mask = {0}
	elseif old_layout == "preinitialized" then
		src_mask = {"host_write"}
	elseif old_layout == "transfer_dst_optimal" then
		src_mask = {"transfer_write"}
	end

	if new_layout == "transfer_src_optimal" then
		dst_mask = {"transfer_read"}
	elseif new_layout == "transfer_dst_optimal" then
		dst_mask = {"transfer_write"}
	elseif new_layout == "shader_read_only_optimal" then
		dst_mask = {"shader_read"}
	end

	--[[
	if old_layout == "color_attachment_optimal" then
		table.insert(src_mask, "color_attachment_write")
	end

	if new_layout == "transfer_dst_optimal" then
		table.insert(dst_mask, "memory_read")
		table.insert(dst_mask, "transfer_write")
	end

	if new_layout == "transfer_src_optimal" then
		table.insert(dst_mask, "transfer_read")
	end

	if new_layout == "shader_read_only_optimal" then
		table.insert(src_mask, "host_write")
		table.insert(src_mask, "transfer_write")

		table.insert(dst_mask, "shader_read")
	end

	if new_layout == "color_attachment_optimal" then
		table.insert(dst_mask, "color_attachment_read")
	end

	if new_layout == "depth_stencil_attachment_optimal" then
		table.insert(dst_mask, "depth_stencil_attachment_read")
		table.insert(dst_mask, "depth_stencil_attachment_write")
	end
]]
	self.cmd:PipelineBarrier(
		"top_of_pipe", "top_of_pipe", 0,
		0, nil,
		0, nil,
		nil, {
			{
				srcAccessMask = src_mask,
				dstAccessMask = dst_mask,
				oldLayout = old_layout,
				newLayout = new_layout,
				image = image,
				subresourceRange = {
					aspectMask = aspect_mask,

					levelCount = 1,
					baseMipLevel = 0,

					layerCount = 1,
					baseLayerLevel = 0
				},
			}
		}
	)
end

function META:CopyImage(src, dst, w, h, mip_level)
	self.cmd:CopyImage(
		src, "transfer_src_optimal",
		dst, "transfer_dst_optimal",
		nil, {
			{
				extent = {w, h, 1},

				srcSubresource = {
					aspectMask = "color",
					baseArrayLayer = 0,
					mipLevel = 0,
					layerCount = 1,
				},
				srcOffset = { 0, 0, 0 },

				dstSubresource = {
					aspectMask = "color",
					baseArrayLayer = 0,
					mipLevel = mip_level,
					layerCount = 1,
				},
				dstOffset = { 0, 0, 0 },
			}
		}
	)
end

function META:Begin()
	self.cmd:Begin({
		flags = 0,
		pInheritanceInfo = {
			renderPass = nil,
			subpass = 0,
			framebuffer = nil,
			offclusionQueryEnable = false,
			queryFlags = 0,
			pipelineStatistics = 0,
		}
	})
end

function META:End()
	self.cmd:End()
end

function META:Flush()
	if not self.cmd then return end

	render.device_queue:Submit(
		nil, {
			{
				waitSemaphoreCount = 0,
				pWaitSemaphores = nil,
				pWaitDstStageMask = nil,

				pCommandBuffers = {
					self.cmd
				},

				signalSemaphoreCount = 0,
				pSignalSemaphores = nil
			}
		},
		nil
	)

	render.device_queue:WaitIdle()

	render.device:FreeCommandBuffers(
		render.device_command_pool,
		nil, {
			self.cmd
		}
	)
end

function render.CreateCommandBuffer()
	local self = {}
	self.cmd = render.device:AllocateCommandBuffers({
		commandPool = render.device_command_pool,
		level = "primary",
		commandBufferCount = 1,
	})
	return setmetatable(self, META)
end