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
	prototype.GetSet(COMPONENT, "ModelPath", "models/face.obj")
prototype.EndStorable()

prototype.GetSet(COMPONENT, "Model", nil)

COMPONENT.Network = {
	ModelPath = {"string", 1/5},
	Cull = {"boolean", 1/5},
	Alpha = {"float", 1/30, "unreliable"},
	--Color = {"boolean", 1/5},	
}

if CLIENT then				
	
	do -- shader
		local gl = require("lj-opengl") -- OpenGL
		
		local PASS = render.CreateGBufferPass("mesh", 1)

		PASS:AddBuffer("diffuse", "RGBA8") 
		PASS:AddBuffer("normal", "RGB16F") 
		PASS:AddBuffer("position", "RGB16F")

		local gl = require("lj-opengl") -- OpenGL

		function PASS:Draw3D()
			gl.DepthMask(gl.e.GL_TRUE)
			gl.Enable(gl.e.GL_DEPTH_TEST)
			gl.Disable(gl.e.GL_BLEND)	
			render.SetCullMode("back")
			
			render.gbuffer:Begin()
				render.gbuffer:Clear()
				event.Call("Draw3DGeometry", render.gbuffer_mesh_shader)
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
				out vec4 out_color[4];

				void main() 
				{
					// diffuse
					out_color[0] = mix(texture(diffuse, uv), texture(diffuse2, uv), texture_blend) * color;			
					
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
					out_color[2] = vm_matrix * vec4(pos, 1);
									
					//out_color.rgb *= texture(detail, uv * detailscale).rgb;
				}
			]]
		})


		--[==[
		PASS:ShaderStage("tess_control", { 
			uniform = {
				cam_pos = "vec3",
				tess_scale = 4;
			},
			attributes = {
				{pos = "vec3"},
			},
			source = [[			
				layout(vertices = 3) out;
				
				out vec4 SIGH[];
				
				void main()
				{			
					SIGH[gl_InvocationID] = LOL[gl_InvocationID];

					if(gl_InvocationID == 0) {
					   vec3 terrainpos = cam_pos;
					   terrainpos.z -= clamp(terrainpos.z,-0.1, 0.1); 
					   
					   vec4 center = (LOL[1]+LOL[2])/2.0;
					   gl_TessLevelOuter[0] = min(6.0, 1+tess_scale*0.5/distance(center.xyz, terrainpos));
					   
					   center = (LOL[2]+LOL[0])/2.0;				   
					   gl_TessLevelOuter[1] = min(6.0, 1+tess_scale*0.5/distance(center.xyz, terrainpos));
					   
					   center = (LOL[0]+LOL[1])/2.0;				   
					   gl_TessLevelOuter[2] = min(6.0, 1+tess_scale*0.5/distance(center.xyz, terrainpos));
					   
					   center = (LOL[0]+LOL[1]+LOL[2])/3.0;				   
					   gl_TessLevelInner[0] = min(7.0, 1+tess_scale*0.7/distance(center.xyz, terrainpos));
					}
				};
			]]
		})

		PASS:ShaderStage("tess_eval", { 
			uniform = {
				v_matrix = "mat4",
			},
			attributes = {
				{pos = "vec3"},
			}, 
			source = [[
				uniform sampler2D displacement;
				
				layout(triangles, equal_spacing, cw) in;
				
				in vec4 SIGH[];
				out vec2 tecoord;
				out vec4 teposition;
				
				void main()
				{
				   teposition = gl_TessCoord.x * SIGH[0];
				   teposition += gl_TessCoord.y * SIGH[1];
				   teposition += gl_TessCoord.z * SIGH[2];
				   tecoord = teposition.xy;
				   vec3 offset = texture(displacement, tecoord).xyz;
				   teposition.xyz = offset;
				   gl_Position = v_matrix * teposition;
				};
			]]
		})]==]
	end
			
	function COMPONENT:OnAdd(ent)
	end

	function COMPONENT:OnRemove(ent)

	end	

	function COMPONENT:SetModelPath(path)
		self.ModelPath = path
		self.Model = render.Create3DMesh(path)
	end

	function COMPONENT:OnDraw3DGeometry(shader, vp_matrix)
		if not self.Model then return end
		
		vp_matrix = vp_matrix or render.matrices.vp_matrix

		local matrix = self:GetComponent("transform"):GetMatrix() 
		local model = self.Model
		
		local visible = false
		
		if model.corners and self.Cull then
			local temp = Matrix44()
			
			model.matrix_cache = model.matrix_cache or {}
			
			for i, pos in ipairs(model.corners) do
				model.matrix_cache[i] = model.matrix_cache[i] or Matrix44()
				model.matrix_cache[i]:Identity()
				model.matrix_cache[i]:Translate(pos.x, pos.y, pos.z)
				
				model.matrix_cache[i]:Multiply(matrix, temp)
				temp:Multiply(vp_matrix, model.matrix_cache[i])
				
				local x, y, z = model.matrix_cache[i]:GetClipCoordinates()
				
				if 	
					(x > -1 and x < 1) and 
					(y > -1 and y < 1) and 
					(z > -1 and z < 1) 
				then
					visible = true
					break
				end
			end
		else
			visible = true
		end
		
		if true or visible then
			local screen = matrix * vp_matrix
			
			shader.pvm_matrix = screen.m
			shader.vm_matrix = matrix.m
			shader.v_matrix = render.GetViewMatrix3D()
			shader.color = self.Color
			
			for i, model in ipairs(model.sub_models) do
				shader.diffuse = self.DiffuseTexture or model.diffuse or render.GetErrorTexture()
				shader.diffuse2 = self.DiffuseTexture or model.diffuse2 or render.GetErrorTexture()
				shader.specular = self.SpecularTexture or model.specular or render.GetWhiteTexture()
				shader.bump = self.BumpTexture or model.bump or render.GetBlackTexture()
				
				--shader.detail = model.detail or render.GetWhiteTexture()
				
				shader:Bind()
				model.mesh:Draw()
			end
		end
	end 
	
	COMPONENT.OnDraw2D = COMPONENT.OnDraw3DGeometry
end

prototype.RegisterComponent(COMPONENT)

if RELOAD then
	render.InitializeGBuffer()
end