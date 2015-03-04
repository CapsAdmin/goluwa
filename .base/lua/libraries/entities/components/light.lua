if not render then return end

local COMPONENT = {}

COMPONENT.Name = "light"
COMPONENT.Require = {"transform"}
COMPONENT.Events = {"Draw3DLights", "DrawShadowMaps", "DrawLensFlare"}

prototype.StartStorable()
	prototype.GetSet(COMPONENT, "Color", Color(1, 1, 1))
	
	-- automate this!!
	prototype.GetSet(COMPONENT, "Intensity", 0.5)

	prototype.GetSet(COMPONENT, "Shadow", false)
	prototype.GetSet(COMPONENT, "ShadowCubemap", false)
	prototype.GetSet(COMPONENT, "ShadowSize", 4096)
	prototype.GetSet(COMPONENT, "FOV", 90, {editor_min = 0, editor_max = 180})
	prototype.GetSet(COMPONENT, "NearZ", 1)
	prototype.GetSet(COMPONENT, "FarZ", 32000)
	prototype.GetSet(COMPONENT, "ProjectFromCamera", false) 
	prototype.GetSet(COMPONENT, "OrthoSize", 0)
	prototype.GetSet(COMPONENT, "LensFlare", false)
prototype.EndStorable()

if GRAPHICS then	
	local gl = require("libraries.ffi.opengl")
	
	render.shadow_maps = render.shadow_maps or utility.CreateWeakTable()
	
	function COMPONENT:OnAdd(ent)
		utility.LoadRenderModel("models/cube.obj", function(meshes)
			self.light_mesh = meshes[1]
		end)
	end

	function COMPONENT:OnRemove(ent)
		render.shadow_maps[self] = nil
	end
	
	function COMPONENT:OnDraw3DLights(shader)
		if not render.matrices.vp_matrix or not self.light_mesh then return end -- grr
		
		local transform = self:GetComponent("transform")
		local matrix = transform:GetMatrix() 
		local screen = matrix * render.matrices.vp_matrix
		
		shader.pvm_matrix = screen.m
		self.screen_matrix = screen
		
		local mat = matrix * render.matrices.view_3d
		local x,y,z = mat:GetTranslation()
		shader.light_view_pos:Set(x,y,z)
	--	shader.light_world_pos:Set(matrix:GetTranslation())
		shader.light_dir = -transform:GetRotation():GetForward()
		shader.light_radius = transform:GetSize()
		shader.inverse_projection = render.matrices.projection_3d_inverse.m
		shader.inverse_projection_view = (render.matrices.vp_3d_inverse).m
		
		-- automate this!!
		shader.light_color = self.Color
		shader.light_intensity = self.Intensity
		shader.light_shadow = self.Shadow and 1 or 0
		shader.light_point_shadow = self.ShadowCubemap and 1 or 0
		shader.project_from_camera = self.ProjectFromCamera and 1 or 0
		
		if self.Shadow then
			self:DrawShadowMap()
			shader.cascade_pass = i
			shader.tex_shadow_map = self.shadow_map:GetTexture("depth")
			if self.ShadowCubemap then 	
				shader.tex_shadow_map_cube = self.shadow_map:GetTexture("cubemap")
			end
			shader.light_vp_matrix = self.vp_matrix.m
			gl.Disable(gl.e.GL_DEPTH_TEST)
		end
		shader:Bind()
		self.light_mesh:Draw()
	end
						
	local directions = {
		{ e = gl.e.GL_TEXTURE_CUBE_MAP_POSITIVE_X, rot = QuatDeg3(0,90,0)},
		{ e = gl.e.GL_TEXTURE_CUBE_MAP_NEGATIVE_X, rot = QuatDeg3(0,-90,0)},
		{ e = gl.e.GL_TEXTURE_CUBE_MAP_POSITIVE_Y, rot = QuatDeg3(90,0,0)},
		{ e = gl.e.GL_TEXTURE_CUBE_MAP_NEGATIVE_Y, rot = QuatDeg3(-90,0,0)},
		{ e = gl.e.GL_TEXTURE_CUBE_MAP_POSITIVE_Z, rot = QuatDeg3(0,0,0)},
		{ e = gl.e.GL_TEXTURE_CUBE_MAP_NEGATIVE_Z, rot = QuatDeg3(180,0,0)},
	}
	
	render.shadow_map_shader = nil
						
	function COMPONENT:DrawShadowMap(shader, ortho_divider)
		if not self.Shadow then
			if render.shadow_maps[self] then
				render.shadow_maps[self] = nil
			end
			return 
		end
		
		if not render.shadow_map_shader then
			render.shadow_map_shader = render.CreateShader({
				name = "shadow_map",
				vertex = {
					attributes = {
						{pos = "vec3"},
						{normal = "vec3"},
						{uv = "vec2"},
						{texture_blend = "float"},
					},	
					source = "gl_Position = lua[projection_view_world = 'mat4'] * vec4(pos, 1);"
				},
				fragment = {
					attributes = {
						{uv = "vec2"},
					},
					source = [[
						out vec4 out_color;
						
						void main()
						{				
							if (lua[alpha_test = 0] == 1 && texture(lua[diffuse = "sampler2D"], uv).a < 0.25)
							{
								discard;
							}
						}
					]],
				},
			})
		end
			
		if not render.shadow_maps[self] then
			local cube_texture = {
				name = "cubemap",
				attach = "color0",
				texture_format = {
					type = "cubemap",
					internal_format = "r32f",
					upload_format = "red",
					min_filter = "linear",
					wrap_s = "clamp_to_edge",
					wrap_t = "clamp_to_edge",
					wrap_r = "clamp_to_edge",
					mip_map_levels = 0,
				}
			}
			
			local texture_2d = {
				name = "depth",
				attach = "depth",
				draw_manual = true,
				texture_format = {
					internal_format = "DEPTH_COMPONENT32",	 
					depth_texture_mode = gl.e.GL_RED,
				} 
			}
			
			if self.ShadowCubemap then
				self.shadow_map = render.CreateFrameBuffer(self.ShadowSize, self.ShadowSize, {texture_2d, texture_cube})
			else
				self.shadow_map = render.CreateFrameBuffer(self.ShadowSize, self.ShadowSize, texture_2d)
			end
			
			render.shadow_maps[self] = self.shadow_map
		end
		
		gl.Enable(gl.e.GL_DEPTH_TEST)	
		--render.SetBlendMode("additive")
		gl.BlendFunc(gl.e.GL_ONE, gl.e.GL_ONE)
		render.SetCullMode("front")
	
		local transform = self:GetComponent("transform")
		local pos = transform:GetPosition()
		local rot = transform:GetRotation()
		
		self.shadow_map:Begin()
		self.shadow_map:Clear()
				
		---self.shadow_map:SetWriteBuffer("depth")
		
		for i, info in ipairs(directions) do
			if self.ShadowCubemap then
				self.shadow_map:SetReadBuffer("depth")
				self.shadow_map:SetWriteBuffer("cubemap", info.e)
			end
			
			-- setup the view matrix
			local view = Matrix44()
			
			if self.ShadowCubemap then
				view:SetRotation(info.rot)
			else
				view:SetRotation(rot)
			end

			if self.ProjectFromCamera then
				pos = render.GetCameraPosition()
				view:Translate(pos.y, pos.x, pos.z)			
			else
				view:Translate(pos.y, pos.x, pos.z)			
			end
			
			-- setup the projection matrix
			local projection = Matrix44()
			
			if self.OrthoSize == 0 then
				projection:Perspective(math.rad(self.FOV), render.camera.farz, render.camera.nearz, render.camera.ratio) 
			else
				local size = self.OrthoSize * (ortho_divider or 1)
				projection:Ortho(-size, size, -size, size, size, -size) 
			end
				
			-- make a projection_view matrix
			self.vp_matrix = view * projection
						
			-- render the scene with this matrix
			render.SetCullMode("front")
			event.Call("Draw3DGeometry", render.shadow_map_shader, self.vp_matrix, true)
			
			if not self.ShadowCubemap then 
				break 
			end
		end
		self.shadow_map:End()
	end
end

function COMPONENT:OnDrawLensFlare(shader)
	if not self.LensFlare or not self.screen_matrix then return end
	local x, y, z = self.screen_matrix:GetClipCoordinates()
	
	shader.pvm_matrix = self.screen_matrix.m
	
	if z < 1 then
		shader.screen_pos:Set(x, y)
	else
		shader.screen_pos:Set(-2,-2)
	end
	
	shader.intensity = self.Intensity^0.25
	
	shader:Bind()
	self.light_mesh:Draw()
end

prototype.RegisterComponent(COMPONENT)

if RELOAD then
	render.InitializeGBuffer()
	
	do return end
	event.Delay(0.1, function()
	world.sun:SetShadow(true)
	world.sun:SetPosition(render.GetCameraPosition()) 
	world.sun:SetAngles(render.GetCameraAngles()) 
	world.sun:SetFOV(render.GetCameraFOV())
	world.sun:SetSize(1000) 
	end) 
end