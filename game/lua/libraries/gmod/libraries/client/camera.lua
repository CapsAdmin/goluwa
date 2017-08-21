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
	render2d.camera:PushWorld(mat.ptr, true)
end

function cam.PopModelMatrix()
	render2d.camera:PopWorld()
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
	return gine.env.Vector(render3d.camera:GetAngles():GetForward())
end

function gine.env.EyePos()
	return gine.env.Vector(render3d.camera:GetPosition())
end

function gine.env.EyeAngles()
	return gine.env.Angle(render3d.camera:GetAngles())
end
