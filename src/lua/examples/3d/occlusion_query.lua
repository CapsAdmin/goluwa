local VISUALIZE = true
local render = ... or _G.render
local gl = require("opengl")
local ffi = require("ffi")

local SCENE = false


if SCENE then
	render3d.Initialize()

	entities.Panic()

	local mat = render.CreateMaterial("model")
	mat:SetTranslucent(true)

	local i = 0
	local oh = 10
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

bounding_box:Upload()


local shader = render.CreateShader(SHADER)

for i, model in ipairs(render3d.GetDistanceSortedScene()) do
	if SCENE then
		model:RemoveMeshes()
		model:AddMesh(bounding_box)
	end

	local id = ffi.new("GLuint[1]")
	gl.GenQueries(1, id)

	model.occluder_id = id[0]
end

pcall(function()
	entities.world:SetSunShadow(false)
end)

local tex = render.CreateTexture("2d")
tex:SetSize(window.GetSize())
tex:SetInternalFormat("rgb8")
tex:SetupStorage()

local fb = render.CreateFrameBuffer()

if VISUALIZE then
	fb:SetTexture(1, tex)
end

fb:SetTexture("depth", {
	size = tex:GetSize(),
	internal_format = "depth_component16",
})
fb:SetSize(tex:GetSize())

local last_recorded = math.huge

event.Timer("occluder", 1/30, function()
	if input.IsMouseDown("button_1") then

		render.PushDepth(true)
		fb:Begin()
		fb:ClearDepth(1)

		if VISUALIZE then
			fb:ClearAll()
		end
		render.PushCullMode("back")

		last_recorded = 0

		profiler.StartTimer("sort")
		render3d.SortDistanceScene()

		for i, model in ipairs(render3d.GetDistanceSortedScene()) do
			if model.occluder_id then
				if not model.occluder_recorded then
					shader.model = model:GetComponent("transform"):GetMatrix()
					if VISUALIZE then
						shader.visible = model.occlusion_visible and 1 or 0
						shader.waiting = model.occlusion_waiting and 1 or 0
					end
					shader:Bind()

					gl.BeginQuery("GL_SAMPLES_PASSED_ARB", model.occluder_id)
					---bounding_box:Draw()
					for _, mesh in ipairs(model.sub_meshes) do
						mesh.vertex_buffer:Draw()
					end
					gl.EndQuery("GL_SAMPLES_PASSED_ARB")
					model.occluder_recorded = true
					last_recorded = last_recorded + 1
				end
			end
		end

		fb:End()
		render.PopDepth()
		render.PopCullMode()
	end

	if last_recorded == #render3d.scene then
		for i, model in ipairs(render3d.GetDistanceSortedScene()) do
			if model.occluder_recorded then
				local available = ffi.new("GLuint[1]")
				gl.GetQueryObjectuiv(model.occluder_id, "GL_QUERY_RESULT_AVAILABLE", available)
				available = available[0] == 1

				model.occlusion_waiting = not available

				if available then
					last_recorded = last_recorded - 1
				end
			end
		end
	end

	if last_recorded == 0 then

		local total_visible = 0
		for i, model in ipairs(render3d.GetDistanceSortedScene()) do

			if not model.occlusion_waiting and model.occluder_recorded then

				local passed = ffi.new("GLuint[1]")
				gl.GetQueryObjectuiv(model.occluder_id, "GL_QUERY_RESULT", passed)
				passed = passed[0]

				model.occlusion_visible = passed > 0

				if model.occlusion_visible then
					total_visible = total_visible + 1
					--model:GetColor():SetAlpha(1)
				else
					--model:GetColor():SetAlpha(i/#render3d.GetDistanceSortedScene()%0.5)
				end

				model.is_visible = model.occlusion_visible

				model.occluder_recorded = false
			end
		end

		if total_visible > 0 then
			if wait(0.5) then
				print(math.round((total_visible / #render3d.GetDistanceSortedScene())*100), "% visible")
			end
		end
	end
end)

if VISUALIZE then
	event.AddListener("PostDrawGUI", "lol", function()
		gfx.DrawRect(0,0,window.GetSize().x/4, window.GetSize().y/4, fb:GetTexture())
	end)
end