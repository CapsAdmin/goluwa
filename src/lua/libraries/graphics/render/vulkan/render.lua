local render = ... or _G.render

runfile("../null/render.lua", render)

local vk = desire("vulkan")
local ffi = require("ffi")

runfile("buffer.lua", render)
runfile("command_buffer.lua", render)
runfile("image.lua", render)
runfile("texture.lua", render)

function render.AllocateMemory(size, type_bits, requirements_mask)
	requirements_mask = vk.e.memory_property.make_enums(requirements_mask)

	local index = 0

	for i = 0, 32 - 1 do
		if bit.band(type_bits, 1) == 1 then
			if bit.band(render.device_memory_properties.memoryTypes[i].propertyFlags, requirements_mask) == requirements_mask then
				index = i
			end
		end
		type_bits = bit.rshift(type_bits, 1)
	end

	return render.device:AllocateMemory({
		allocationSize = size,
		memoryTypeIndex = index,
	})
end

function render._Initialize(wnd)
	local width, height = wnd:GetSize():Unpack()

	do -- create vulkan instance
		local instance = vk.Assert(vk.CreateInstance({
			pApplicationInfo = {
				pApplicationName = "goluwa",
				applicationVersion = 0,
				pEngineName = "goluwa",
				engineVersion = 0,
				--apiVersion = vk.macros.MAKE_VERSION(1, 0, 2),
			},
			ppEnabledLayerNames = {
				--"VK_LAYER_LUNARG_threading",
				--"VK_LAYER_LUNARG_mem_tracker",
				--"VK_LAYER_LUNARG_object_tracker",
				--"VK_LAYER_LUNARG_draw_state",
				--"VK_LAYER_LUNARG_parameter_validation",
				--"VK_LAYER_LUNARG_core_validation",
				--"VK_LAYER_LUNARG_standard_validation",
				--"VK_LAYER_LUNARG_parameter_validation",
				--"VK_LAYER_LUNARG_swapchain",
				--"VK_LAYER_LUNARG_device_limits",
				--"VK_LAYER_LUNARG_image",
				--"VK_LAYER_LUNARG_api_dump",
			},
			ppEnabledExtensionNames = render.GetRequiredInstanceExtensions({
				"VK_EXT_debug_report",
			}),
		}))

		if instance:LoadProcAddr("vkCreateDebugReportCallbackEXT") then
			instance:CreateDebugReportCallback({
				flags = {"information", "warning", "performance_warning", "error", "debug"},
				pfnCallback = function(msgFlags, objType, srcObject, location, msgCode, pLayerPrefix, pMsg, pUserData)

					local level = 3
					local info = debug.getinfo(level, "Sln")
					local lines = {}
					for i = 3, 10 do
						local info = debug.getinfo(i, "Sln")
						if not info or info.currentline == -1 then break end
						table.insert(lines, info.currentline)
					end
					io.write(string.format("Line %s %s: %s: %s\n", table.concat(lines, ", "), info.name or "unknown", ffi.string(pLayerPrefix), ffi.string(pMsg)))

					return 0
				end,
			})
		end

		instance:LoadProcAddr("vkGetPhysicalDeviceSurfacePresentModesKHR")
		instance:LoadProcAddr("vkGetPhysicalDeviceSurfaceSupportKHR")
		instance:LoadProcAddr("vkCreateSwapchainKHR")
		instance:LoadProcAddr("vkDestroySwapchainKHR")
		instance:LoadProcAddr("vkGetSwapchainImagesKHR")
		instance:LoadProcAddr("vkAcquireNextImageKHR")
		instance:LoadProcAddr("vkQueuePresentKHR")
		instance:LoadProcAddr("vkGetPhysicalDeviceSurfaceCapabilitiesKHR")
		instance:LoadProcAddr("vkGetPhysicalDeviceSurfaceFormatsKHR")

		render.instance = instance
	end

	do -- find and use a gpu
		for _, physical_device in ipairs(render.instance:GetPhysicalDevices()) do			-- get a list of vulkan capable hardware
			for queue_index, info in ipairs(physical_device:GetQueueFamilyProperties()) do			-- get a list of queues the hardware supports
				if bit.band(info.queueFlags, vk.e.queue.graphics) ~= 0 then				-- if this queue supports graphics use it
					queue_index = queue_index - 1

					local device = physical_device:CreateDevice({
						ppEnabledLayerNames = {
							--"VK_LAYER_LUNARG_threading",
							--"VK_LAYER_LUNARG_mem_tracker",
							--"VK_LAYER_LUNARG_object_tracker",
							--"VK_LAYER_LUNARG_draw_state",
							"VK_LAYER_LUNARG_parameter_validation",
							"VK_LAYER_LUNARG_core_validation",
							"VK_LAYER_LUNARG_standard_validation",
							--"VK_LAYER_LUNARG_swapchain",
							--"VK_LAYER_LUNARG_device_limits",
							--"VK_LAYER_LUNARG_image",
							--"VK_LAYER_LUNARG_api_dump",
						},
						ppEnabledExtensionNames = {
							"VK_KHR_swapchain",
						},
						pQueueCreateInfos = {
							{
								queueFamilyIndex = queue_index,
								queueCount = 1,
								pQueuePriorities = ffi.new("float[1]", 0), -- todo: public ffi use is bad!
								pEnabledFeatures = nil,
							}
						}
					})

					render.device_queue = device:GetQueue(queue_index, 0)
					render.device_command_pool = device:CreateCommandPool({queueFamilyIndex = queue_index})
					render.device_memory_properties = physical_device:GetMemoryProperties()

					render.physical_device = physical_device
					render.device = device

					break
				end
			end
		end
	end

	do -- setup the glfw window buffer
		local surface = assert(render.CreateVulkanSurface(wnd, render.instance))
		local formats = render.physical_device:GetSurfaceFormats(surface)
		local capabilities = render.physical_device:GetSurfaceCapabilities(surface)

		local prefered_format = formats[1].format

		if prefered_format == vk.e.format.undefined then
			prefered_format = "b8g8r8a8_unorm"
		end

		if capabilities.currentExtent.width ~= 0xFFFFFFFF then
			width = capabilities.currentExtent.width
			height = capabilities.currentExtent.height
		end

		local present_mode = "immediate"

		for _, mode in ipairs(render.physical_device:GetSurfacePresentModes(surface)) do
			if mode == vk.e.present_mode.fifo or mode == vk.e.present_mode.mailbox then
				present_mode = mode
				break
			end
		end

		render.surface = surface

		render.swap_chain = render.device:CreateSwapchain({
			surface = surface,
			minImageCount = math.min(capabilities.minImageCount + 1, capabilities.maxImageCount == 0 and math.huge or capabilities.maxImageCount),
			imageFormat = prefered_format,
			imagecolorSpace = formats[1].colorSpace,
			imageExtent = {width, height},
			imageUsage = "color_attachment",
			preTransform = bit.band(capabilities.supportedTransforms, vk.e.surface_transform.identity) ~= 0 and "identity" or capabilities.currentTransform,
			compositeAlpha = "opaque",
			imageArrayLayers = 1,
			imageSharingMode = "exclusive",

			queueFamilyIndexCount = 0,
			pQueueFamilyIndices = nil,

			presentMode = present_mode,
			oldSwapchain = nil,
			clipped = true,
		})

		do -- depth buffer to use in render pass
			local format = "d16_unorm"

			local depth_buffer = render.CreateImage({
				width = width,
				height = height,
				format = format,
				usage = "depth_stencil_attachment",
				tiling = "optimal",
				required_props = {"device_local"},
			})

			depth_buffer.view = render.device:CreateImageView({
				viewType = "2d",
				image = depth_buffer.image,
				format = format,
				flags = 0,
				subresourceRange = {
					aspectMask = "depth",

					levelCount = 1,
					baseMipLevel = 0,

					layerCount = 1,
					baseLayerLevel = 0
				},
			})

			depth_buffer.format = format
			render.depth_buffer = depth_buffer
		end

		render.render_pass = render.device:CreateRenderPass({
			pAttachments = {
				{
					format = prefered_format,
					samples = "1",
					loadOp = "clear",
					storeOp = "store",
					stencilLoadOp = "dont_care",
					stencilStoreOp = "dont_care",
					initialLayout = "present_src",
					finalLayout = "present_src",
				},
				{
					format = render.depth_buffer.format,
					samples = "1",
					loadOp = "clear",
					storeOp = "dont_care",
					stencilLoadOp = "dont_care",
					stencilStoreOp = "dont_care",
					initialLayout = "depth_stencil_attachment_optimal",
					finalLayout = "depth_stencil_attachment_optimal",
				},
			},
			pSubpasses = {
				{
					pipelineBindPoint = "graphics",
					flags = 0,

					inputAttachmentCount = 0,
					pInputAttachments = nil,

					pColorAttachments = {
						{
							attachment = 0,
							layout = "present_src",
						},
					},

					pResolveAttachments = nil,

					pDepthStencilAttachment = {
						attachment = 1,
						layout = "depth_stencil_attachment_optimal",
					},

					preserveAttachmentCount = 0,
					pPreserveAttachments = nil,
				},
			},

			dependencyCount = 0,
			pDependencies = nil,
		})

		render.swap_chain_buffers = {}

		for i, image in ipairs(render.device:GetSwapchainImages(render.swap_chain)) do
			local view = render.device:CreateImageView({
				viewType = "2d",
				image = image,
				format = prefered_format,
				flags = 0,
				components = {r = "r", g = "g", b = "b", a = "a"},
				subresourceRange = {
					aspectMask = "color",

					levelCount = 1,
					baseMipLevel = 0,

					layerCount = 1,
					baseLayerLevel = 0
				},
			})

			render.swap_chain_buffers[i] = {
				command_buffer = render.CreateCommandBuffer(),
				framebuffer = render.device:CreateFramebuffer({
					renderPass = render.render_pass,

					pAttachments = {
						view,
						render.depth_buffer.view
					},

					width = width,
					height = height,
					layers = 1,
				}),
				image = image,
				view = view,
			}
		end
	end

	do -- data layout
		local descriptorsets_layout = render.device:CreateDescriptorSetLayout({
			pBindings = {
				{
					binding = 0,
					descriptorType = "uniform_buffer",
					descriptorCount = 1,
					stageFlags = "vertex",
					pImmutableSamplers = nil,
				},
				{
					binding = 1,
					descriptorType = "combined_image_sampler",
					descriptorCount = 1,
					stageFlags = "fragment",
					pImmutableSamplers = nil,
				},
			},
		})

		render.pipeline_layout = render.device:CreatePipelineLayout({
			pSetLayouts = {
				descriptorsets_layout,
			},
		})

		render.descriptorsets = render.device:AllocateDescriptorSets({
			descriptorPool = render.device:CreateDescriptorPool({
				maxSets = 2,
				pPoolSizes = {
					{
						type = "uniform_buffer",
						descriptorCount = 1
					},
					{
						type = "combined_image_sampler",
						descriptorCount = 1
					},
				}
			}),

			pSetLayouts = {
				descriptorsets_layout
			},
		})
	end

	do
		-- CreateTexture is a function defined further up that returns a lua object
		render.texture = render.CreateTexture("../../../src/lua/build/vulkan/test/volcano.png", "b8g8r8a8_unorm")
	end

	do -- vertices
		local vertex_type = ffi.typeof([[
			struct
			{
				float pos[3];
				float uv[2];
				float color[3];
			}
		]])

		local vertices_type = ffi.typeof("$[?]", vertex_type)

		local create_vertices = function(tbl) return vertices_type(#tbl, tbl) end

		local vertices = {
			{ pos = { -1, -1, -1 },  	uv = { 0, 0 } },
			{ pos = { -1, 1, 1 },  		uv = { 1, 1 } },
			{ pos = { -1, -1, 1 }, 		uv = { 1, 0 } },
			{ pos = { -1, 1, 1 },  		uv = { 1, 1 } },
			{ pos = { -1, -1, -1 },  	uv = { 0, 0 } },
			{ pos = { -1, 1, -1 },  	uv = { 0, 1 } },

			{ pos = { -1, -1, -1 },  	uv = { 1, 0 } },
			{ pos = { 1, -1, -1 },  	uv = { 0, 0 } },
			{ pos = { 1, 1, -1 },  		uv = { 0, 1 } },
			{ pos = { -1, -1, -1 },  	uv = { 1, 0 } },
			{ pos = { 1, 1, -1 },  		uv = { 0, 1 } },
			{ pos = { -1, 1, -1 },  	uv = { 1, 1 } },

			{ pos = { -1, -1, -1 },  	uv = { 1, 1 } },
			{ pos = { 1, -1, 1 },  		uv = { 0, 0 } },
			{ pos = { 1, -1, -1 },  	uv = { 1, 0 } },
			{ pos = { -1, -1, -1 },  	uv = { 1, 1 } },
			{ pos = { -1, -1, 1 },  	uv = { 0, 1 } },
			{ pos = { 1, -1, 1 },  		uv = { 0, 0 } },

			{ pos = { -1, 1, -1 },  	uv = { 1, 1 } },
			{ pos = { 1, 1, 1 },  		uv = { 0, 0 } },
			{ pos = { -1, 1, 1 },  		uv = { 0, 1 } },
			{ pos = { -1, 1, -1 }, 	 	uv = { 1, 1 } },
			{ pos = { 1, 1, -1 },  		uv = { 1, 0 } },
			{ pos = { 1, 1, 1 },  		uv = { 0, 0 } },

			{ pos = { 1, 1, -1 },  		uv = { 1, 1 } },
			{ pos = { 1, -1, 1 }, 	 	uv = { 0, 0 } },
			{ pos = { 1, 1, 1 },  		uv = { 0, 1 } },
			{ pos = { 1, -1, 1 },  		uv = { 0, 0 } },
			{ pos = { 1, 1, -1 }, 	 	uv = { 1, 1 } },
			{ pos = { 1, -1, -1 },  	uv = { 1, 0 } },

			{ pos = { -1, 1, 1 }, 	 	uv = { 0, 1 } },
			{ pos = { 1, 1, 1 },  		uv = { 1, 1 } },
			{ pos = { -1, -1, 1 }, 		uv = { 0, 0 } },
			{ pos = { -1, -1, 1 },  	uv = { 0, 0 } },
			{ pos = { 1, 1, 1 },  		uv = { 1, 1 } },
			{ pos = { 1, -1, 1 },  		uv = { 1, 0 } },
		}

		for _, vertex in ipairs(vertices) do
			vertex.color = {math.random(), math.random(), math.random()}
		end

		-- CreateBuffer is a function defined further up that returns a lua object
		render.vertices = render.CreateBuffer("vertex_buffer", create_vertices(vertices))
		render.vertices.tbl = vertices
	end

	do -- indices
		local indices_type = ffi.typeof("uint32_t[?]")

		local create_indices = function(tbl) return indices_type(#tbl, tbl) end

		-- kind of pointless to use indices like this but whatever
		local indices = {}
		for i = 0, #render.vertices.tbl - 1 do
			table.insert(indices, i)
		end

		render.indices = render.CreateBuffer("index_buffer", create_indices(indices))
		render.indices.tbl = indices
		render.indices.count = #indices
	end

	do -- uniforms
		local matrix_type = ffi.typeof(Matrix44())

		local uniforms_type = ffi.typeof("struct { $ projection; $ view; $ world; }", matrix_type, matrix_type, matrix_type)
		local create_uniforms = uniforms_type

		local uniforms = create_uniforms
		{
			projection = Matrix44(),
			view = Matrix44(),
			world = Matrix44(),
		}

		render.projection_matrix = uniforms.projection
		render.view_matrix = uniforms.view
		render.model_matrix = uniforms.world

		render.projection_matrix:Perspective(math.rad(90), 32000, 0.1, width / height)
		render.view_matrix:Translate(0,0,-5)
		render.model_matrix:Rotate(0.5, 0,1,0)

		render.uniforms = render.CreateBuffer("uniform_buffer", uniforms)

		--render.view_matrix:Translate(5,3,10)
		--render.view_matrix:Rotate(math.rad(90), 0,-1,0)
	end

	-- update uniforms
	render.device:UpdateDescriptorSets(
		nil, {
			{
				dstSet = render.descriptorsets,
				descriptorType = "uniform_buffer",
				dstBinding = 0,

				pBufferInfo = {
					{
						buffer = render.uniforms.buffer,
						range = render.uniforms.size,
						offset = 0,
					}
				}
			},
			{
				dstSet = render.descriptorsets,
				descriptorType = "combined_image_sampler",
				dstBinding = 1,

				pImageInfo = {
					{
						sampler = render.texture.sampler,
						imageView = render.texture.view,
						imageLayout = "general",
					}
				}
			},
		},
		0, nil
	)

	render.pipeline = render.device:CreateGraphicsPipelines(
		nil,
		nil, {
			{
				layout = render.pipeline_layout,
				renderPass = render.render_pass,

				pVertexInputState = {
					pVertexBindingDescriptions = {
						{
							binding = 0,
							stride = ffi.sizeof(render.vertices.data[0]),
							inputRate = "vertex"
						}
					},
					pVertexAttributeDescriptions = {
						-- layout(location = 0) in vec3 position;
						{
							binding = 0,
							location = 0,
							format = "r32g32b32_sfloat",
							offset = 0,
						},
						-- layout(location = 1) in vec2 uv;
						{
							binding = 0,
							location = 1,
							format = "r32g32_sfloat",
							offset = ffi.sizeof(render.vertices.data[0].pos),
						},
						-- layout(location = 2) in vec3 color;
						{
							binding = 0,
							location = 2,
							format = "r32g32b32_sfloat",
							offset = ffi.sizeof(render.vertices.data[0].pos)  + ffi.sizeof(render.vertices.data[0].uv),
						},
					},
				},

				pStages = {
					{
						stage = "vertex",
						module = render.device:CreateShaderModule(vk.util.GLSLToSpirV("vert", [[
							#version 450

							in layout(location = 0) vec3 position;
							in layout(location = 1) vec2 uv;
							in layout(location = 2) vec3 color;

							uniform layout (std140, binding = 0) matrices_t
							{
								mat4 projection;
								mat4 view;
								mat4 world;
							} matrices;

							// to fragment
							out layout(location = 0) vec2 frag_uv;
							out layout(location = 1) vec3 frag_color;

							void main()
							{
								gl_Position = (matrices.projection * matrices.view * matrices.world) * vec4(position, 1);

								// to fragment
								frag_uv = uv;
								frag_color = color;
							}
						]])),
						pName = "main",
					},
					{
						stage = "fragment",
						module = render.device:CreateShaderModule(vk.util.GLSLToSpirV("frag", [[
							#version 450

							//from descriptor sets
							uniform layout(binding = 1) sampler2D tex;

							//from vertex
							in layout(location = 0) vec2 uv;
							in layout(location = 1) vec3 color;

							//to render pass (kinda)
							out layout(location = 0) vec4 frag_color;

							void main()
							{
								frag_color =  texture(tex, uv) * vec4(color, 1);
							}
						]])),
						pName = "main",
					},
				},

				pInputAssemblyState = {
					topology = "triangle_list",
				},

				pRasterizationState = {
					polygonMode = "fill",
					cullMode = "none", -- "BACK",
					frontFace = "clockwise",
					depthClampEnable = false,
					rasterizerDiscardEnable = false,
					depthBiasEnable = false,
				},

				pColorBlendState = {
					pAttachments = {
						{
							colorWriteMask = 0xf,
							blendEnable = false,
						}
					}
				},

				pMultisampleState = {
					pSampleMask = nil,
					rasterizationSamples = "1",
				},

				pViewportState = {
					viewportCount = 1,
					scissorCount = 1,
				},

				pDepthStencilState = {
					depthTestEnable = true,
					depthWriteEnable = true,
					depthCompareOp = "less_or_equal",
					depthBoundsTestEnable = false,
					stencilTestEnable = false,
					back = {
						failOp = "keep",
						passOp = "keep",
						compareOp = "always",
					},
					front = {
						failOp = "keep",
						passOp = "keep",
						compareOp = "always",
					},
				},

				pDynamicState = {
					dynamicStateCount = 2,
					pDynamicStates = ffi.new("enum VkDynamicState[2]",
						vk.e.dynamic_state.viewport,
						vk.e.dynamic_state.scissor
					),
				},
			}
		}
	)

	for _, buffer in ipairs(render.swap_chain_buffers) do
		buffer.command_buffer:Begin()

		local cmd = buffer.command_buffer.cmd

		cmd:BeginRenderPass(
			{
				renderPass = render.render_pass,
				framebuffer = buffer.framebuffer,
				renderArea = {offset = {0, 0}, extent = {width, height}},
				pClearValues = {
					{color = {float32 = {0.2, 0.2, 0.2, 0.2}}},
					{depthStencil = {1, 0}}
				},
			},
			"inline"
		)

		cmd:SetViewport(0, nil,
			{
				{0,0,height,width, 0,1}
			}
		)
		cmd:SetScissor(0, nil,
			{
				{
					offset = {0, 0},
					extent = {height, width}
				}
			}
		)

		cmd:BindPipeline("graphics", render.pipeline)
		cmd:BindDescriptorSets("graphics", render.pipeline_layout, 0, nil, {render.descriptorsets}, 0, nil)

		cmd:BindVertexBuffers(0, nil, {render.vertices.buffer}, ffi.new("unsigned long[1]", 0))
		cmd:BindIndexBuffer(render.indices.buffer, 0, "uint32")

		cmd:DrawIndexed(render.indices.count, 1, 0, 0, 0)

		cmd:EndRenderPass()

		buffer.command_buffer:End()
	end

	event.AddListener("Update", "vulkan_test", function()
		render.device_queue:WaitIdle()
		render.device:WaitIdle()

		local semaphore = render.device:CreateSemaphore({
			flags = 0,
		})

		local index = render.device:AcquireNextImage(render.swap_chain, vk.e.WHOLE_SIZE, semaphore, nil)
		index = index + 1

		--render.projection_matrix:Perspective(math.rad(90), 32000, 0.1, width / height)
		render.uniforms:Update()

		render.device_queue:Submit(nil,
			{
				{
					pWaitDstStageMask = ffi.new("enum VkPipelineStageFlagBits [1]", vk.e.pipeline_stage.bottom_of_pipe),


					pWaitSemaphores = {
						semaphore
					},

					signalSemaphoreCount = 0,
					pSignalSemaphores = nil,


					pCommandBuffers = {
						render.swap_chain_buffers[index].command_buffer.cmd
					},
				},
			},
			nil
		)

		render.device_queue:Present({
			pSwapchains = {
				render.swap_chain
			},
			pImageIndices = ffi.new("unsigned int [1]", index - 1),
		})

		render.device:DestroySemaphore(semaphore, nil)
	end)

end