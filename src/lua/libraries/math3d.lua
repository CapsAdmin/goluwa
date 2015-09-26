local math3d = _G.math3d or {}

function math3d.WorldToLocal(local_pos, local_ang, world_pos, world_ang)
	local pos, ang

	if world_ang and local_ang then
		local lmat = Matrix44():SetRotation(Quat():SetAngles(local_ang))
		local wmat = Matrix44():SetRotation(Quat():SetAngles(world_ang))
		ang = (lmat * wmat):GetRotation():GetAngles()
	end

	if world_pos and local_pos then
		local lmat = Matrix44():SetTranslation(local_pos:Unpack())
		local wmat = Matrix44():SetTranslation(world_pos:Unpack())
		pos = Vec3((lmat * wmat):GetTranslation())
	end

	return pos, ang
end


function math3d.LocalToWorld(local_pos, local_ang, world_pos, world_ang)
	local pos, ang

	if world_ang and local_ang then
		local lmat = Matrix44():SetRotation(Quat():SetAngles(local_ang)):GetInverse()
		local wmat = Matrix44():SetRotation(Quat():SetAngles(world_ang))
		ang = (lmat * wmat):GetRotation():GetAngles()
	end

	if world_pos and local_pos then
		local lmat = Matrix44():SetTranslation(local_pos:Unpack()):GetInverse()
		local wmat = Matrix44():SetTranslation(world_pos:Unpack())
		pos = Vec3((lmat * wmat):GetTranslation())
	end

	return pos, ang
end

function math3d.LinePlaneIntersection(pos, normal, screen_pos)
	local ln = math3d.ScreenToWorldDirection(screen_pos)
	local lp = render.camera_3d:GetPosition() - pos
	local t = lp:GetDot(normal) / ln:GetDot(normal)

	if t < 0 then
		return lp + ln * -t
	end
end

function math3d.PointToAxis(pos, axis, screen_pos)
	local origin = math3d.WorldPositionToScreen(pos)
	local point = math3d.WorldPositionToScreen(pos + (axis * 8))

	local a = math.atan2(point.y - origin.y, point.x - origin.x)
	local d = math.cos(a) * (point.x - screen_pos.x) + math.sin(a) * (point.y - screen_pos.y)

	return Vec2(point.x + math.cos(a) * -d, point.y + math.sin(a) * -d)
end

function math3d.ScreenToWorldDirection(screen_pos, cam_pos, cam_ang, cam_fov, screen_width, screen_height)
	cam_pos = cam_pos or render.camera_3d:GetPosition()
	cam_ang = cam_ang or render.camera_3d:GetAngles()
	cam_fov = cam_fov or render.camera_3d:GetFOV()
	screen_width = screen_width or render.GetWidth()
	screen_height = screen_height or render.GetHeight()

    --This code works by basically treating the camera like a frustrum of a pyramid.
    --We slice this frustrum at a distance "d" from the camera, where the slice will be a rectangle whose width equals the "4:3" width corresponding to the given screen height.
    local d = 4 * screen_height / (8 * math.tan(0.5 * cam_fov))

    --Forward, right, and up vectors (need these to convert from local to world coordinates
    local fwd = cam_ang:GetForward()
    local rgt = -cam_ang:GetRight()
    local upw = cam_ang:GetUp()

    --Then convert vec to proper world coordinates and return it
	local dir = (fwd * d) + (rgt * (0.5 * screen_width - screen_pos.x)) + (upw * (0.5 * screen_height - screen_pos.y))

	dir:Normalize()

    return dir
end

function math3d.WorldPositionToScreen(position, cam_pos, cam_ang, screen_width, screen_height, cam_fov)
	cam_pos = cam_pos or render.camera_3d:GetPosition()
	cam_ang = cam_ang or render.camera_3d:GetAngles()
	screen_width = screen_width or render.GetWidth()
	screen_height = screen_height or render.GetHeight()
	cam_fov = cam_fov or render.camera_3d:GetFOV()

	local dir = cam_pos - position
	dir:Normalize()

    --Same as we did above, we found distance the camera to a rectangular slice of the camera's frustrum, whose width equals the "4:3" width corresponding to the given screen height.
    local d = 4 * screen_height / (8 * math.tan(0.5 * cam_fov))
    local fdp = cam_ang:GetForward():GetDot(dir)

    --fdp must be nonzero ( in other words, vDir must not be perpendicular to angCamRot:Forward() )
    --or we will get a divide by zero error when calculating vProj below.
    if fdp == 0 then
        return Vec2(0, 0), -1
    end

    --Using linear projection, project this vector onto the plane of the slice
    local proj = dir * (d / fdp)

    --Dotting the projected vector onto the right and up vectors gives us screen positions relative to the center of the screen.
    --We add half-widths / half-heights to these coordinates to give us screen positions relative to the upper-left corner of the screen.
    --We have to subtract from the "up" instead of adding, since screen coordinates decrease as they go upwards.
    local x = 0.5 * screen_width + cam_ang:GetRight():GetDot(proj)
    local y = 0.5 * screen_height - cam_ang:GetUp():GetDot(proj)

    --Lastly we have to ensure these screen positions are actually on the screen.
    local vis

	--Simple check to see if the object is in front of the camera
    if fdp < 0 then
        vis = 1
    elseif x < 0 or x > screen_width or y < 0 or y > screen_height then  --We've already determined the object is in front of us, but it may be lurking just outside our field of vision.
        vis = 0
    else
        vis = -1
    end

    return Vec2(x, y), vis
end

return math3d