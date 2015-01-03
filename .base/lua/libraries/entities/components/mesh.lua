local COMPONENT = {}

COMPONENT.Name = "mesh"
COMPONENT.Require = {"transform"}
COMPONENT.Events = {"Draw3DGeometry"}

prototype.StartStorable()
	prototype.GetSet(COMPONENT, "DiffuseTexture")
	prototype.GetSet(COMPONENT, "BumpTexture")
	prototype.GetSet(COMPONENT, "SpecularTexture")
	prototype.GetSet(COMPONENT, "Color", Color(1, 1, 1))
	prototype.GetSet(COMPONENT, "Alpha", 1)
	prototype.GetSet(COMPONENT, "Cull", true)
	prototype.GetSet(COMPONENT, "ModelPath", "")
	prototype.GetSet(COMPONENT, "BBMin", Vec3())
	prototype.GetSet(COMPONENT, "BBMax", Vec3())
prototype.EndStorable()

prototype.GetSet(COMPONENT, "Model", nil)

COMPONENT.Network = {
	ModelPath = {"string", 1/5},
	Cull = {"boolean", 1/5},
	Alpha = {"float", 1/30, "unreliable"},
	Color = {"color", 1/5},
}

if CLIENT then 
	do -- shader
		local gl = require("lj-opengl") -- OpenGL

		local PASS = render.CreateGBufferPass("mesh", 1)

		PASS:AddBuffer("diffuse", "RGBA8")
		PASS:AddBuffer("normal", "RGB16f")

		local gl = require("lj-opengl") -- OpenGL

		function PASS:Draw3D()
			gl.DepthMask(gl.e.GL_TRUE)
			gl.Enable(gl.e.GL_DEPTH_TEST)
			gl.Disable(gl.e.GL_BLEND)
			render.SetCullMode("back")

			render.gbuffer:Begin()
				render.gbuffer:Clear()
				
				--gl.Clear(gl.e.GL_DEPTH_BUFFER_BIT)
				event.Call("Draw3DGeometry", render.gbuffer_mesh_shader)
				
				--skybox?				
				
				--local scale = 16
				--local view = Matrix44()
				--view = render.SetupView3D(Vec3(234.1, -234.1, 361.967)*scale + render.GetCameraPosition(), render.GetCameraAngles(), render.GetCameraFOV(), view)
				--view:Scale(scale,scale,scale)
				--event.Call("Draw3DGeometry", render.gbuffer_mesh_shader, view * render.matrices.projection_3d, true)			
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
				--detail = "sampler2D",
				--detailscale = 1,

				bump = "sampler2D",
				specular = "sampler2D",
			},
			attributes = {
				{pos = "vec3"},
				{normal = "vec3"},
				{uv = "vec2"},
				{texture_blend = "float"},
			},
			source = [[
				out vec4 out_color[3];

				void main()
				{
					// diffuse
					out_color[0] = mix(texture(diffuse, uv), texture(diffuse2, uv), texture_blend) * color;

					// specular
					out_color[0].a = texture(specular, uv).r;

					// normals
					{
						out_color[1].rgb = mat3(vm_matrix) * normal;

						vec3 bump_detail = texture(bump, uv).rgb;

						if (bump_detail != vec3(0,0,0))
						{
							//bump_detail = normalize(bump_detail);
							out_color[1].rgb += (mat3(vm_matrix)) * -(bump_detail - vec3(0.5));
							out_color[1].rgb = normalize(out_color[1].rgb);
						}
					}

					//out_color.rgb *= texture(detail, uv * detailscale).rgb;
				}
			]]
		})

		local TESS  = false

		if CAPS and RELOAD and TESS then
			PASS:ShaderStage("vertex", {
				uniform = {
					m_matrix = "mat4",
					pv_matrix = "mat4",
				},
				attributes = {
					{pos = "vec3"},
					{normal = "vec3"},
					{uv = "vec2"},
					--{texture_blend = "float"},
				},
				source = [[
					out vec3 WorldPos_CS_in;
					out vec2 TexCoord_CS_in;
					out vec3 Normal_CS_in;

					void main()
					{
						WorldPos_CS_in = (pv_matrix * vec4(pos, 1.0)).xyz;
						TexCoord_CS_in = uv;
						Normal_CS_in = (pv_matrix * vec4(normal, 0.0)).xyz;
					}
				]]
			})
 
			PASS:ShaderStage("tess_control", {
				uniform = {
					cam_pos = "vec3",
				},
				source = [[
					// define the number of CPs in the output patch
					layout (vertices = 3) out;

					// attributes of the input CPs
					in vec3 WorldPos_CS_in[];
					in vec2 TexCoord_CS_in[];
					in vec3 Normal_CS_in[];

					// attributes of the output CPs
					out vec3 WorldPos_ES_in[];
					out vec2 TexCoord_ES_in[];
					out vec3 Normal_ES_in[];

					float GetTessLevel(float Distance0, float Distance1)
					{
						float AvgDistance = (Distance0 + Distance1) / 2.0;

						if (AvgDistance <= 2.0) {
							return 10.0;
						}
						else if (AvgDistance <= 5.0) {
							return 7.0;
						}
						else {
							return 3.0;
						}
					}

					void main()
					{
						// Set the control points of the output patch
						WorldPos_ES_in[gl_InvocationID] = WorldPos_CS_in[gl_InvocationID];
						TexCoord_ES_in[gl_InvocationID] = TexCoord_CS_in[gl_InvocationID];
						Normal_ES_in[gl_InvocationID]   = Normal_CS_in[gl_InvocationID];

						// Calculate the distance from the camera to the three control points
						float EyeToVertexDistance0 = distance(cam_pos, WorldPos_ES_in[0]);
						float EyeToVertexDistance1 = distance(cam_pos, WorldPos_ES_in[1]);
						float EyeToVertexDistance2 = distance(cam_pos, WorldPos_ES_in[2]);

						// Calculate the tessellation levels
						gl_TessLevelOuter[0] = GetTessLevel(EyeToVertexDistance1, EyeToVertexDistance2);
						gl_TessLevelOuter[1] = GetTessLevel(EyeToVertexDistance2, EyeToVertexDistance0);
						gl_TessLevelOuter[2] = GetTessLevel(EyeToVertexDistance0, EyeToVertexDistance1);
						gl_TessLevelInner[0] = gl_TessLevelOuter[2];
					}
				]]
			})

			PASS:ShaderStage("tess_eval", {
				uniform = {
					p_matrix = "mat4",
					displacement = "sampler2D",
					factor = 1,
				},
				source = [[
					layout(triangles, equal_spacing, ccw) in;

					in vec3 WorldPos_ES_in[];
					in vec2 TexCoord_ES_in[];
					in vec3 Normal_ES_in[];

					out vec3 WorldPos_FS_in;
					out vec2 TexCoord_FS_in;
					out vec3 Normal_FS_in;

					vec2 interpolate2D(vec2 v0, vec2 v1, vec2 v2)
					{
						return vec2(gl_TessCoord.x) * v0 + vec2(gl_TessCoord.y) * v1 + vec2(gl_TessCoord.z) * v2;
					}

					vec3 interpolate3D(vec3 v0, vec3 v1, vec3 v2)
					{
						return vec3(gl_TessCoord.x) * v0 + vec3(gl_TessCoord.y) * v1 + vec3(gl_TessCoord.z) * v2;
					}

					void main()
					{
						// Interpolate the attributes of the output vertex using the barycentric coordinates
						TexCoord_FS_in = interpolate2D(TexCoord_ES_in[0], TexCoord_ES_in[1], TexCoord_ES_in[2]);
						Normal_FS_in = interpolate3D(Normal_ES_in[0], Normal_ES_in[1], Normal_ES_in[2]);
						Normal_FS_in = normalize(Normal_FS_in);
						WorldPos_FS_in = interpolate3D(WorldPos_ES_in[0], WorldPos_ES_in[1], WorldPos_ES_in[2]);

						// Displace the vertex along the normal
						float Displacement = texture(displacement, TexCoord_FS_in.xy).x;
						WorldPos_FS_in += Normal_FS_in * 1;
						gl_Position = p_matrix * vec4(WorldPos_FS_in, 1.0);
					}
				]]
			})

			PASS:ShaderStage("fragment", {
				uniform = {
					color = Color(1,1,1,1),
					diffuse = "sampler2D",
					--diffuse2 = "sampler2D",
					vm_matrix = "mat4",
					--detail = "sampler2D",
					--detailscale = 1,

					bump = "sampler2D",
					specular = "sampler2D",
				},
			--	attributes = {
					--{texture_blend = "float"},
				--},
				source = [[
					in vec2 TexCoord_FS_in;
					in vec3 Normal_FS_in;
					in vec3 WorldPos_FS_in;

					#define uv TexCoord_FS_in
					#define normal Normal_FS_in
					#define pos WorldPos_FS_in
					
					out vec4 out_color[4];

					void main()
					{						
						// diffuse
						//out_color[0] = mix(texture(diffuse, uv), texture(diffuse2, uv), texture_blend) * color;
						out_color[0] = texture(diffuse, uv);

						// specular
						out_color[0].a = texture(specular, uv).r;

						// normals
						{
							out_color[1] = vec4(normalize(mat3(vm_matrix) * -normal), 1);

							vec3 bump_detail = texture(bump, uv).rgb;

							if (bump_detail != vec3(0,0,0))
							{
								out_color[1].rgb *= bump_detail;
								out_color[1].rgb = normalize(out_color[1].rgb);
							}
						}

						// position
						out_color[2].xyz = pos;

						//out_color.rgb *= texture(detail, uv * detailscale).rgb;
					}
				]]
			})

			TESS = true 
		end
	end 

	function COMPONENT:OnAdd(ent)
	end

	function COMPONENT:OnRemove(ent)

	end

	function COMPONENT:SetModelPath(path)
		self.ModelPath = path
		self:LoadModelFromDisk(path)		
	end

	do
		COMPONENT.sub_models = {}
		
		function COMPONENT:AddMesh(mesh)
			table.insert(self.sub_models, mesh)
		end
		
		function COMPONENT:RemoveMesh()
			
		end
		
		function COMPONENT:GetMesh()
		
		end		
	end
	
	do
		local assimp = require("lj-assimp") -- model decoder

		local default_texture_format = {
			mip_map_levels = 4,
			mag_filter = "linear",
			min_filter = "linear_mipmap_linear",
		}
		render.model_cache = render.model_cache or {}
		
		local function solve_material_paths(mesh, model_data, dir)
			if model_data.material then
				model_data.material.directory = dir							
				
				if model_data.material.paths_solved then
					if model_data.material.diffuse then
						mesh.diffuse = render.CreateTexture(model_data.material.diffuse, default_texture_format)
					elseif model_data.material.bump then
						mesh.bump = render.CreateTexture(model_data.material.bump, default_texture_format)
					elseif model_data.material.specular then
						mesh.specular = render.CreateTexture(model_data.material.specular, default_texture_format)
					end
				elseif model_data.material.path then
					local path = model_data.material.path
					
					-- this is kind of ue4 specific
					if model_data.material.name and model_data.material.name:sub(1, 1) == "/" then
						local ext = path:match("^.+(%..+)$")
						local path = model_data.material.name
						path = model_data.material.directory .. path:sub(2)
						
						mesh.diffuse = render.CreateTexture(path .. "_D" .. ext)
						mesh.bump = render.CreateTexture(path .. "_N" .. ext)
						mesh.specular = render.CreateTexture(path .. "_S" .. ext)
					else	
						local paths = {path, model_data.material.directory .. path}
						
						for _, path in ipairs(paths) do
							if vfs.Exists(path) then
								mesh.diffuse = render.CreateTexture(path, default_texture_format)

								do -- try to find normal map
									local path = utility.FindTextureFromSuffix(path, "_n", "_ddn", "_nrm")

									if path then
										mesh.bump = render.CreateTexture(path, default_texture_format)
									end
								end

								do -- try to find specular map
									local path = utility.FindTextureFromSuffix(path, "_s", "_spec")

									if path then
										mesh.specular = render.CreateTexture(path, default_texture_format)
									end
								end
								break
							end
						end
					end
				end
			end
		end
		
		function COMPONENT:LoadModelFromDisk(path, flags, callback)
			check(path, "string")
			
			if render.model_cache[path] then
				for i, mesh in ipairs(render.model_cache[path]) do
					self:AddMesh(mesh)
				end
				self:BuildBoundingBox()
				return
			end
						
			render.model_cache[path] = {}
								
			flags = flags or bit.bor(
				assimp.e.aiProcess_CalcTangentSpace, 
				assimp.e.aiProcess_GenSmoothNormals, 
				assimp.e.aiProcess_Triangulate,
				assimp.e.aiProcess_JoinIdenticalVertices			
			)
			
			flags = assimp.e.aiProcessPreset_TargetRealtime_Quality
			
			if render.debug then 
				logn("loading mesh: ", path) 
			end
			
			if not vfs.Exists(path) and vfs.Exists(path .. ".mdl") then
				path = path .. ".mdl"
			end

			if not vfs.Exists(path) then
				return nil, path .. " not found"
			end
			
			self.done = false
			local dir = path:match("(.+/)")
								
			self:BuildBoundingBox()
			
			local thread = utility.CreateThread()
			
			if path:endswith(".mdl") and steam.LoadModel then
				function thread.OnStart()
					steam.LoadModel(path, function(model_data)					
						local mesh = render.CreateMeshBuilder()
						
						solve_material_paths(mesh, model_data, dir)
												
						mesh:SetName(model_data.name)
						mesh:SetVertices(model_data.vertices)
						mesh:SetIndices(model_data.indices)						
						mesh:BuildBoundingBox()
						
						mesh:Upload()
						self:AddMesh(mesh)						
						table.insert(render.model_cache[path], mesh)						
						self:BuildBoundingBox()
						
					end, thread)
				end
			else
				function thread.OnStart()
					assimp.ImportFileEx(path, flags, function(model_data, i, total_meshes)
						if render.debug then logf("[render] %s loading %q %s\n", path, model_data.name, i .. "/" .. total_meshes) end
						
						local mesh = render.CreateMeshBuilder()
						
						solve_material_paths(mesh, model_data, dir)

						mesh:SetName(model_data.name)
						mesh:SetVertices(model_data.vertices)
						mesh:SetIndices(model_data.indices)						
						mesh:BuildBoundingBox()
						
						mesh:Upload()
						self:AddMesh(mesh)						
						table.insert(render.model_cache[path], mesh)						
						self:BuildBoundingBox()
						
					end, true)
				end
			end
			
			function thread.OnFinish()
				self.done = true
				if callback then callback() end
			end
			
			thread:SetIterationsPerTick(15)
			
			thread:Start()
		end
	end
	
	do		
		local function corner_helper(self, i, j)
			return bit.band(bit.rshift(i, j), 1) == 0 and self.BBMin or self.BBMax
		end
		
		function COMPONENT:BuildBoundingBox()
			local min, max = Vec3(), Vec3()

			for i, sub_model in ipairs(self.sub_models) do
				if 
					sub_model.BBMin.x < min.x and 
					sub_model.BBMin.y < min.y and 
					sub_model.BBMin.z < min.z 
				then
					min = sub_model.BBMin
				end
				
				if 
					sub_model.BBMax.x > max.x and 
					sub_model.BBMax.y > max.y and 
					sub_model.BBMax.z > max.z 
				then
					max = sub_model.BBMax
				end
			end
			
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
				shader.diffuse = self.DiffuseTexture or model.diffuse or render.GetErrorTexture()
				shader.diffuse2 = self.DiffuseTexture or model.diffuse2 or render.GetErrorTexture()
				shader.specular = self.SpecularTexture or model.specular or render.GetWhiteTexture()
				shader.bump = self.BumpTexture or model.bump or render.GetBlackTexture()
				shader.displacement = self.Displacement or model.displacement or render.GetNoiseTexture()

				--shader.detail = model.detail or render.GetWhiteTexture()

				shader:Bind()
				model:Draw()
			end
		end
	end
end

prototype.RegisterComponent(COMPONENT)