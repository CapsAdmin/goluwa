local cam = gine.env.cam

function cam.Start()

end

function cam.End()

end

function cam.End3D()

end

function cam.IgnoreZ()

end

function cam.PushModelMatrix(mat)
	camera.camera_2d:PushWorld(mat.ptr, true)
end

function cam.PopModelMatrix()
	camera.camera_2d:PopWorld()
end

function cam.Start3D2D()

end

function cam.Start3D()

end

function cam.End3D2D()

end

function cam.End3D()

end

function cam.End2D()

end

function gine.env.EyeVector()
	return gine.env.Vector(camera.camera_3d:GetAngles():GetForward())
end

function gine.env.EyePos()
	return gine.env.Vector(camera.camera_3d:GetPosition())
end

function gine.env.EyeAngles()
	return gine.env.Angle(camera.camera_3d:GetAngles())
end
