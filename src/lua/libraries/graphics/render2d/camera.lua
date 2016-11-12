local render2d = ... or _G.render2d

function render2d.GetSize()
	return camera.camera_2d.Viewport.w, camera.camera_2d.Viewport.h
end

do
	local ceil = math.ceil
	function render2d.Translate(x, y, z)
		camera.camera_2d:TranslateWorld(ceil(x), ceil(y), z or 0)
	end
end

function render2d.Translatef(x, y, z)
	camera.camera_2d:TranslateWorld(x, y, z or 0)
end

function render2d.Rotate(a)
	camera.camera_2d:RotateWorld(a, 0, 0, 1)
end

function render2d.Scale(w, h, z)
	camera.camera_2d:ScaleWorld(w, h or w, z or 1)
end

function render2d.Shear(x, y)
	camera.camera_2d:ShearWorld(x, y, 0)
end

function render2d.LoadIdentity()
	camera.camera_2d:LoadIdentityWorld()
end

function render2d.PushMatrix(x,y, w,h, a, dont_multiply)
	camera.camera_2d:PushWorld(nil, dont_multiply)

	if x and y then render2d.Translate(x, y) end
	if w and h then render2d.Scale(w, h) end
	if a then render2d.Rotate(a) end
end

function render2d.PopMatrix()
	camera.camera_2d:PopWorld()
end

function render2d.SetWorldMatrix(mat)
	camera.camera_2d:SetWorld(mat)
end

function render2d.GetWorldMatrix()
	return camera.camera_2d:GetWorld()
end

function render2d.ScreenToWorld(x, y)
	return camera.camera_2d:ScreenToWorld(x, y)
end

function render2d.ScreenTo3DWorld(x, y)
	return camera.camera_3d:ScreenToWorld(x, y)
end

function render2d.Start3D2D(pos, ang, scale)
	camera.camera_2d:Start3D2DEx(pos, ang, scale)
end

function render2d.End3D2D()
	camera.camera_2d:End3D2D()
end
