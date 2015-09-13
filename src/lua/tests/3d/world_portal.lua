local fb = render.CreateFrameBuffer(2048, 2048)

local portal_a_cam = render.CreateCamera()

local pos_a = Vec3(-37, -26, 0)
local ang_a = Ang3(math.pi/2, math.pi/2, 0)

portal_a_cam:SetPosition(pos_a)
portal_a_cam:SetAngles(ang_a + Deg3(-90,0,0))

local function fill_discard(invert)
	render.gbuffer_discard:Begin()
	
		if invert then
			render.gbuffer_discard:Clear("color", 1,1,1,1)
		else
			render.gbuffer_discard:Clear("color", 0,0,0,0)
		end

		surface.Start3D2D(pos_a, ang_a)

			local w, h = surface.GetSize()
			w = w / 200
			h = h / 200
			if invert then 
				surface.SetColor(0,0,0,0)
			else
				surface.SetColor(1,1,1,1)
			end
			surface.SetWhiteTexture()
			surface.DrawRect(0, 0, w, h, math.pi, w/2, h/2)

		surface.End3D2D()	
	render.gbuffer_discard:End()
end

event.AddListener("PreGBufferModelPass", "portal", function()
	fill_discard(false)
end)

event.AddListener("PostGBufferModelPass", "portal", function()
	fill_discard(true)
	
	render.camera_3d:SetView(portal_a_cam:GetMatrices().view)
		render.Draw3DScene("portal")	
	render.camera_3d:SetView()
end)