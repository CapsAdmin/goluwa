local VISUALIZE = false
local render = ... or _G.render
local gl = system.GetFFIBuildLibrary("opengl", true)
local ffi = require("ffi")

local SCENE = true


if SCENE then
	render3d.Initialize()

	entities.Panic()

	local mat = render.CreateMaterial("model")
	mat:SetTranslucent(true)

	local i = 0
	local oh = 7
	for x = -oh, oh do
	for y = -oh, oh do
	for z = -oh, oh do
		local ent = entities.CreateEntity("visual")
		ent:SetModelPath("models/cube.obj")
		ent:SetMaterialOverride(mat)
		ent:SetPosition(Vec3(x,y,z)*2)
		ent:SetColor(ColorHSV(i,1,1))
		i = i + 0.1
	end
	end
	end

	local ent = entities.CreateEntity("visual")
	ent:SetModelPath("models/cube.obj")
	ent:SetMaterialOverride(mat)
	ent:SetPosition(Vec3(1,1,1)+50)
	ent:SetSize(5)
	ent:SetColor(ColorHSV(i,1,1))
	ent:SetName("LOL")
end

local SHADER = {
	name = "occlusion_query",
	vertex = {
		mesh_layout = {
			{pos = "vec3"},
		},
		variables = {
			size = 1,
			model = "mat4",
		},
		source = [[
			void main()
			{
				gl_Position = g_projection_view * model * vec4(pos, 1);
			}
		]],
	},
	fragment = {
		source = [[
			void main()
			{

			}
		]],
	},
}

if VISUALIZE then
	SHADER.fragment.variables = {
		waiting = 0,
		visible = 0,
		model_pos = Vec3(),
	}

	SHADER.fragment.source = [[
		out vec4 out_color;
		void main()
		{
			out_color = vec4(visible,waiting,1,1);
		}
	]]
end

local bounding_box = gfx.CreatePolygon3D()

bounding_box:AddVertex({pos = Vec3(1, 1, 1)})
bounding_box:AddVertex({pos = Vec3(1, -1, 1)})
bounding_box:AddVertex({pos = Vec3(-1, -1, 1)})
bounding_box:AddVertex({pos = Vec3(-1, 1, 1)})
bounding_box:AddVertex({pos = Vec3(1, 1, 1)})
bounding_box:AddVertex({pos = Vec3(-1, -1, 1)})

-- bottom
bounding_box:AddVertex({pos = Vec3(-1, -1, -1)})
bounding_box:AddVertex({pos = Vec3(1, -1, -1)})
bounding_box:AddVertex({pos = Vec3(-1, 1, -1)})
bounding_box:AddVertex({pos = Vec3(1, -1, -1)})
bounding_box:AddVertex({pos = Vec3(1, 1, -1)})
bounding_box:AddVertex({pos = Vec3(-1, 1, -1)})

-- left
bounding_box:AddVertex({pos = Vec3(1, 1, 1)})
bounding_box:AddVertex({pos = Vec3(1, 1, -1)})
bounding_box:AddVertex({pos = Vec3(1, -1, -1)})
bounding_box:AddVertex({pos = Vec3(1, -1, 1)})
bounding_box:AddVertex({pos = Vec3(1, 1, 1)})
bounding_box:AddVertex({pos = Vec3(1, -1, -1)})

-- right
bounding_box:AddVertex({pos = Vec3(-1, -1, -1)})
bounding_box:AddVertex({pos = Vec3(-1, 1, -1)})
bounding_box:AddVertex({pos = Vec3(-1, -1, 1)})
bounding_box:AddVertex({pos = Vec3(-1, 1, -1)})
bounding_box:AddVertex({pos = Vec3(-1, 1, 1)})
bounding_box:AddVertex({pos = Vec3(-1, -1, 1)})

-- front
bounding_box:AddVertex({pos = Vec3(1, -1, 1)})
bounding_box:AddVertex({pos = Vec3(1, -1, -1)})
bounding_box:AddVertex({pos = Vec3(-1, -1, -1)})
bounding_box:AddVertex({pos = Vec3(-1, -1, 1)})
bounding_box:AddVertex({pos = Vec3(1, -1, 1)})
bounding_box:AddVertex({pos = Vec3(-1, -1, -1)})

-- back
bounding_box:AddVertex({pos = Vec3(-1, 1, -1)})
bounding_box:AddVertex({pos = Vec3(1, 1, -1)})
bounding_box:AddVertex({pos = Vec3(-1, 1, 1)})
bounding_box:AddVertex({pos = Vec3(1, 1, -1)})
bounding_box:AddVertex({pos = Vec3(1, 1, 1)})
bounding_box:AddVertex({pos = Vec3(-1, 1, 1)})

bounding_box:AddSubMesh(bounding_box:GetVertices())
bounding_box:Upload()


local shader = render.CreateShader(SHADER)

for i, model in ipairs(render3d.GetDistanceSortedScene()) do
	if SCENE then
		model:RemoveSubModels()
		model:AddSubModel(bounding_box)
	end

	local id = ffi.new("GLuint[1]")
	gl.GenQueries(1, id)

	model.occluder_id = id[0]
end

pcall(function()
	entities.world:SetSunShadow(false)
end)

local fb = render.CreateFrameBuffer()

local size = Vec2()+512

if VISUALIZE then
	local tex = render.CreateTexture("2d")
	tex:SetSize(size)
	tex:SetInternalFormat("rgb8")
	tex:SetupStorage()

	fb:SetTexture(1, tex)
end

fb:SetTexture("depth", {
	size = size,
	internal_format = "depth_component16",
})
fb:SetSize(size)

local available = ffi.new("GLuint[1]")
local passed = ffi.new("GLuint[1]")

event.Timer("occluder", 0.25, function()
	if input.IsMouseDown("button_1") then

		render.PushDepth(true)
		fb:Begin()
		fb:ClearDepth(1)

		if VISUALIZE then
			fb:ClearAll()
		end
		gl.ColorMask(0,0,0,0)
		--gl.DepthMask(0)
		render.PushCullMode("none")

		profiler.StartTimer("sort")
		render3d.SortDistanceScene()

		for i, model in ipairs(render3d.GetDistanceSortedScene(true)) do
			if model.occluder_id then
				shader.model = model:GetComponent("transform"):GetMatrix()
				if VISUALIZE then
					shader.visible = model.occlusion_visible and 1 or 0
					shader.waiting = model.occlusion_waiting and 1 or 0
				end
				shader:Bind()

				gl.BeginQuery("GL_ANY_SAMPLES_PASSED", model.occluder_id)
				--bounding_box:Draw()
				for _, sub_model in ipairs(model:GetSubModels()) do
					for i, sub_mesh in ipairs(sub_model:GetSubMeshes()) do
						sub_model:Draw(i)
					end
				end
				gl.EndQuery("GL_ANY_SAMPLES_PASSED")
			end
		end

		fb:End()
		render.PopDepth()
		gl.ColorMask(1,1,1,1)
		--gl.DepthMask(1)
		render.PopCullMode()
	end
end)

if VISUALIZE then
	function goluwa.PreDrawGUI()
		gfx.DrawRect(0,0,window.GetSize().x/4, window.GetSize().y/4, fb:GetTexture())
	end
end