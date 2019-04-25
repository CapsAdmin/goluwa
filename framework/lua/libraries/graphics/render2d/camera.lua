local render2d = ... or _G.render2d

render2d.camera = camera.CreateCamera()
render2d.camera:Set3D(false)
render2d._camera = render2d.camera

function render2d.SetCamera(cam)
	render2d.camera = cam or render2d._camera
end

function render2d.GetSize()
	return render2d.camera.Viewport.w, render2d.camera.Viewport.h
end

do
	local ceil = math.ceil
	function render2d.Translate(x, y, z)
		render2d.camera:TranslateWorld(ceil(x), ceil(y), z or 0)
	end
end

function render2d.Translatef(x, y, z)
	render2d.camera:TranslateWorld(x, y, z or 0)
end

function render2d.Rotate(a)
	render2d.camera:RotateWorld(a, 0, 0, 1)
end

function render2d.Scale(w, h, z)
	render2d.camera:ScaleWorld(w, h or w, z or 1)
end

function render2d.Shear(x, y)
	render2d.camera:ShearWorld(x, y, 0)
end

function render2d.LoadIdentity()
	render2d.camera:LoadIdentityWorld()
end

function render2d.PushMatrix(x,y, w,h, a, dont_multiply)
	render2d.camera:PushWorld(nil, dont_multiply)

	if x and y then render2d.Translate(x, y) end
	if w and h then render2d.Scale(w, h) end
	if a then render2d.Rotate(a) end
end

function render2d.PopMatrix()
	render2d.camera:PopWorld()
end

function render2d.SetWorldMatrix(mat)
	render2d.camera:SetWorld(mat)
end

function render2d.GetWorldMatrix()
	return render2d.camera:GetWorld()
end

function render2d.ScreenToWorld(x, y)
	return render2d.camera:ScreenToWorld(x, y)
end

function render2d.ScreenTo3DWorld(x, y)
	return render3d.camera:ScreenToWorld(x, y)
end

function render2d.Start3D2D(pos, ang, scale)
	render2d.camera:Start3D2DEx(pos, ang, scale)
end

function render2d.End3D2D()
	render2d.camera:End3D2D()
end
