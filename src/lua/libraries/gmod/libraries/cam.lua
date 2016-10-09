local gmod = ... or _G.gmod

local cam = gmod.env.cam

function cam.Start()

end

function cam.End()

end

function cam.End3D()

end

function cam.IgnoreZ()

end

function cam.PushModelMatrix(mat)

end

function cam.PopModelMatrix()
end

function cam.Start3D2D()

end

function cam.Start3D()

end

function cam.End3D2D()

end

function cam.End3D()

end

function gmod.env.EyeVector()
	return gmod.env.Vector(render.camera_3d:GetAngles():GetForward())
end

function gmod.env.EyePos()
	return gmod.env.Vector(render.camera_3d:GetPosition())
end

function gmod.env.EyeAngles()
	return gmod.env.Angle(render.camera_3d:GetAngles())
end