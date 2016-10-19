local fb = render.CreateFrameBuffer(Vec2(2048, 2048))

local portal_a_cam = camera.CreateCamera()

local pos_a = Vec3(-37, -26, 0)
local ang_a = Ang3(math.pi/2, math.pi/2, 0)

portal_a_cam:SetPosition(pos_a)
portal_a_cam:SetAngles(ang_a + Deg3(-90,0,0))

render3d.gbuffer_discard = render.CreateFrameBuffer(
	size,
	{
		internal_format = "r8",
	}
)

render.SetGlobalShaderVariable("tex_discard", function() return render3d.gbuffer_discard:GetTexture() end, "texture")

local function fill_discard(invert)
	render3d.gbuffer_discard:Begin()

		if invert then
			render3d.gbuffer_discard:ClearColor(1,1,1,1)
		else
			render3d.gbuffer_discard:ClearColor(0,0,0,0)
		end

		render2d.Start3D2D(pos_a, ang_a)

			local w, h = render2d.GetSize()
			w = w / 200
			h = h / 200
			if invert then
				render2d.SetColor(0,0,0,0)
			else
				render2d.SetColor(1,1,1,1)
			end
			render2d.SetTexture()
			render2d.DrawRect(0, 0, w, h, math.pi, w/2, h/2)

		render2d.End3D2D()
	render3d.gbuffer_discard:End()
end

event.AddListener("PreGBufferModelPass", "portal", function()
	fill_discard(false)
end)

event.AddListener("PostGBufferModelPass", "portal", function()
	fill_discard(true)

	camera.camera_3d:SetView(portal_a_cam:GetMatrices().view)
		render3d.DrawScene("portal")
	camera.camera_3d:SetView()
end)