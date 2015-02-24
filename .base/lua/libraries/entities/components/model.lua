local COMPONENT = {}

COMPONENT.Name = "model"
COMPONENT.Require = {"transform"}
COMPONENT.Events = {"Draw3DGeometry"}

prototype.StartStorable()
	prototype.GetSet(COMPONENT, "Color", Color(1, 1, 1, 1))
	prototype.GetSet(COMPONENT, "IlluminationColor", Color(1, 1, 1, 1))
	prototype.GetSet(COMPONENT, "Alpha", 1)
	prototype.GetSet(COMPONENT, "Cull", true)
	prototype.GetSet(COMPONENT, "ModelPath", "")
	prototype.GetSet(COMPONENT, "DiffuseTexturePath", "")
	prototype.GetSet(COMPONENT, "BumpTexturePath", "")
	prototype.GetSet(COMPONENT, "SpecularTexturePath", "")

	prototype.GetSet(COMPONENT, "BBMin", Vec3())
	prototype.GetSet(COMPONENT, "BBMax", Vec3())
prototype.EndStorable()

prototype.GetSet(COMPONENT, "DiffuseTexture")
prototype.GetSet(COMPONENT, "BumpTexture")
prototype.GetSet(COMPONENT, "SpecularTexture")
prototype.GetSet(COMPONENT, "IlluminationTexture")
prototype.GetSet(COMPONENT, "Model", nil)

COMPONENT.Network = {
	ModelPath = {"string", 1/5, "reliable", true},
	Cull = {"boolean", 1/5},
	Alpha = {"float", 1/30, "unreliable"},
	Color = {"color", 1/5},
}

if GRAPHICS then 
	do -- shader
		local gl = require("lj-opengl") -- OpenGL

		local PASS = render.CreateGBufferPass(COMPONENT.Name, 1)

		PASS:AddBuffer("diffuse", "RGBA8")
		PASS:AddBuffer("normal", "RGB16f")
		PASS:AddBuffer("illumination", "RGBA8")

		local gl = require("lj-opengl") -- OpenGL

		function PASS:Draw3D()
			--gl.DepthMask(gl.e.GL_TRUE)
			--gl.Enable(gl.e.GL_DEPTH_TEST)
			--gl.Disable(gl.e.GL_BLEND)
			--gl.Disable(gl.e.GL_BLEND)
			render.SetCullMode("front")

			render.gbuffer:Begin()
				render.gbuffer:Clear()
				
				--gl.Clear(gl.e.GL_DEPTH_BUFFER_BIT)
				event.Call("Draw3DGeometry", render.gbuffer_model_shader)
				
				--skybox?				
				
				--local scale = 16
				--local view = Matrix44()
				--view = render.SetupView3D(Vec3(234.1, -234.1, 361.967)*scale + render.GetCameraPosition(), render.GetCameraAngles(), render.GetCameraFOV(), view)
				--view:Scale(scale,scale,scale)
				--event.Call("Draw3DGeometry", render.gbuffer_model_shader, view * render.matrices.projection_3d, true)			
			render.gbuffer:End()
		end

		PASS:ShaderStage("vertex", {
			uniform = {
				pvm_matrix = "mat4",
			},
			attributes = {
				{pos = "vec3"},
				{normal = "vec3"},
				{uv = "vec2"},
				{texture_blend = "float"},
			},
			source = "gl_Position = pvm_matrix * vec4(pos, 1.0);"
		})

		PASS:ShaderStage("fragment", {
			uniform = {
				color = Color(1,1,1,1),
				diffuse = "sampler2D",
				diffuse2 = "sampler2D",
				vm_matrix = "mat4",
				
				detail = "sampler2D",
				detail_scale = 1,
				detail_blend_factor = 0,
				alpha_test = 0,

				bump = "sampler2D",
				bump2 = "sampler2D",
				specular = "sampler2D",
				illumination = "sampler2D",
				illumination_color = Color(1,1,1,1),
			},
			attributes = {
				{pos = "vec3"},
				{normal = "vec3"},
				{uv = "vec2"},
				{texture_blend = "float"},
			},
			source = [[
				out vec4 out_color[3];

				float rand(vec2 co){
					return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
				}
				
				void main()
				{				
					// diffuse
					out_color[0] = mix(texture(diffuse, uv), texture(diffuse2, uv), texture_blend) * color;
					
					if (alpha_test == 1)
					{
						//if (out_color[0].a < pow(rand(uv), 0.5))
						//if (pow(out_color[0].a+0.5, 4) < 0.5)
						if (out_color[0].a < 0.25)
							discard;
					}
					
					//if (detail_blend_factor > 0)
						//out_color[0].rgb = (out_color[0].rgb - texture(detail, uv * detail_scale*10).rgb);
					
					// specular
					out_color[1].a = texture(specular, uv).r;

					// normals
					{
						out_color[1].rgb = mat3(vm_matrix) * normal;
						
						vec3 bump_detail = mix(texture(bump, uv).rgb, texture(bump2, uv).rgb, texture_blend);
						
					//	bump_detail.rgb = normalize(bump_detail.grb);
						
						if (bump_detail != vec3(0,0,0))
						{
							//bump_detail = normalize(bump_detail);
							out_color[1].rgb += (mat3(vm_matrix)) * -(normalize(bump_detail.grb) - vec3(0.5));
							out_color[1].rgb = normalize(out_color[1].rgb);
						}
					}

					out_color[2] = texture(illumination, uv)*illumination_color;
				}
			]]
		})
	end

	function COMPONENT:OnAdd(ent)
	end

	function COMPONENT:OnRemove(ent)

	end

	function COMPONENT:SetModelPath(path)
		self.ModelPath = path
		
		utility.LoadRenderModel(
			path, 
			function() 
				if steam.LoadMap and path:endswith(".bsp") then
					steam.SpawnMapEntities(path, self:GetEntity())
				end
			end, 
			function(mesh)
				self:AddMesh(mesh)
				self:BuildBoundingBox()
			end,
			function(err)
				logf("%s failed to load model %q: %s\n", self, path, err)
				self:RemoveMeshes()
			end
		)
		
	end

	function COMPONENT:SetDiffuseTexturePath(path)
		self.DiffuseTexturePath = path
		self.DiffuseTexture = Texture(path)
	end
	
	function COMPONENT:SetBumpTexturePath(path)
		self.BumpTexturePath = path
		self.BumpTexture = Texture(path)
	end
	
	function COMPONENT:SetSpecularTexturePath(path)
		self.SpecularTexturePath = path
		self.SpecularTexture = Texture(path)
	end

	do		
		function COMPONENT:AddMesh(mesh)
			self.sub_models = self.sub_models or {}
			checkx(mesh, "mesh_builder")
			table.insert(self.sub_models, mesh)
			mesh:CallOnRemove(function()
				if self:IsValid() then
					self:RemoveMesh(mesh)
				end
			end, self)
		end
		
		function COMPONENT:RemoveMesh(mesh)
			self.sub_models = self.sub_models or {}
			for i, _mesh in ipairs(self.sub_models) do
				if mesh == _mesh then
					table.remove(self.sub_models, i)
					break
				end
			end
		end
		
		function COMPONENT:RemoveMeshes()
			self.sub_models = {}
			collectgarbage("step")
		end
		
		function COMPONENT:GetMeshes()
			self.sub_models = self.sub_models or {}
			return self.sub_models
		end
	end

	do		
		local function corner_helper(self, i, j)
			return bit.band(bit.rshift(i, j), 1) == 0 and self.BBMin or self.BBMax
		end
		
		function COMPONENT:BuildBoundingBox()	
			self.sub_models = self.sub_models or {}
			local min, max = Vec3(), Vec3()

			for i, sub_model in ipairs(self.sub_models) do				
				if sub_model.BBMin.x < min.x then min.x = sub_model.BBMin.x end
				if sub_model.BBMin.y < min.y then min.y = sub_model.BBMin.y end
				if sub_model.BBMin.z < min.z then min.z = sub_model.BBMin.z end
				
				if sub_model.BBMax.x > max.x then max.x = sub_model.BBMax.x end
				if sub_model.BBMax.y > max.y then max.y = sub_model.BBMax.y end
				if sub_model.BBMax.z > max.z then max.z = sub_model.BBMax.z end
			end
			
			self.BBMin = min
			self.BBMax = max
			
			self.corners = {}
			
			for i = 0, 7 do
				local x = corner_helper(self, i, 2).x
				local y = corner_helper(self, i, 1).y
				local z = corner_helper(self, i, 0).z
				
				self.corners[i+1] = Vec3(x, y, z)
			end
		end
	end

	function COMPONENT:OnDraw3DGeometry(shader, vp_matrix)
		self.sub_models = self.sub_models or {}
		vp_matrix = vp_matrix or render.matrices.vp_matrix

		local matrix = self:GetComponent("transform"):GetMatrix()
		
		if not self.Cull or not self.corners or self:GetComponent("transform"):IsPointsVisible(self.corners, vp_matrix) then

			if TESS then
				shader.m_matrix = matrix.m
				shader.pv_matrix = (render.matrices.view_3d * render.matrices.projection_3d).m
				shader.p_matrix = render.matrices.projection_3d
				shader.vm_matrix = matrix.m
				
				shader.pvm_matrix = matrix * vp_matrix

			else
				local screen = matrix * vp_matrix

				shader.pvm_matrix = screen.m
				shader.vm_matrix = (matrix * render.matrices.view_3d).m
				shader.v_matrix = render.GetViewMatrix3D()
			end
			shader.color = self.Color

			for i, model in ipairs(self.sub_models) do
				if model.no_cull then render.SetCullMode("none") else render.SetCullMode("front") end
				shader.alpha_test = model.alpha_test and 1 or 0
				shader.diffuse = self.DiffuseTexture or model.diffuse or render.GetErrorTexture()
				shader.diffuse2 = self.DiffuseTexture2 or model.diffuse2 or render.GetErrorTexture()
				shader.specular = self.SpecularTexture or model.specular or render.GetWhiteTexture()
				shader.illumination = self.IlluminationTexture or model.illumination or render.GetBlackTexture()
				shader.illumination_color = model.illumination_color or self.IlluminationColor
				shader.bump = self.BumpTexture or model.bump or render.GetBlackTexture()
				shader.bump2 = self.BumpTexture2 or model.bump2 or render.GetBlackTexture()
				shader.displacement = self.Displacement or model.displacement or render.GetWhiteTexture()
				shader.detail = model.detail or render.GetWhiteTexture()
				shader.detail_blend_factor = model.detail_blend_factor 

				shader:Bind()
				model:Draw()
			end
		end
	end
end

prototype.RegisterComponent(COMPONENT)

if RELOAD then
	render.InitializeGBuffer()
end