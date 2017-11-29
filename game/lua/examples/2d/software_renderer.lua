-- based on https://github.com/mojaves/LEon3D/blob/master/dagon/leon3d.lua
local SWRenderer = {}
SWRenderer.__index = SWRenderer

function SWRenderer.new(size)
    local swr = {}
    setmetatable(swr, SWRenderer)
    return swr
end

function SWRenderer:drawframe(mesh)
	mesh:IterateFaces(function(a,b,c)
		self:drawface(a.pos, b.pos, c.pos)
	end)
end

-- TODO: pixel metatable
function SWRenderer:calcvertex(vertex)
-- TODO
--    local tr = self.cam:normal(vertex);
--    local wvnorm = normvector(vector({tr[1][1]/tr[4][1], tr[2][1]/tr[4][1], tr[3][1]/tr[4][1]}))
--    local normlightdir = normvector(vector({-1, 1, 0}))
--    local intensity = saturate(matrix.dot3(normlight, wvnmorm))

    return {
		position = render3d.camera:GetMatrices().projection_view * Matrix44():MultiplyVector(vertex.x, vertex.y, vertex.z, 1),
		color = 1,
	}
end

-- TODO
--function roundint(num)
--    return math.floor(num+.5)
--end

function pixeltargetcoords(pix, size)
    local w = pix.position.m03
    local posx = pix.position.m00/w
    local posy = pix.position.m01/w
    return Vec2(
		math.floor(((posx * size.x) + 1.0)/2.0),
		math.floor(((posy * size.y) + 1.0)/2.0)
	)
end

-- Bresenham's line algorithm, optimized, then simplified, as found in
-- http://en.wikipedia.org/wiki/Bresenham%27s_line_algorithm#Simplification
function SWRenderer:drawline(a, pa, b, pb)
    local dx = math.abs(a.x - b.x)
    local dy = math.abs(a.y - b.y)
    local sx = -1
    if a.x < b.x then
        sx = 1
    end
    local sy = -1
    if a.y < b.y then
        sy = 1
    end
    local err = dx - dy
    local x0 = a.x
    local y0 = a.y
	for i = 1, 100 do
		if x0 == b.x or y0 == b.y then break end
		gfx.DrawRect(x0,y0,1,1,nil,0,pa.color,0)
        local e2 = 2*err
        if e2 > -dy then
            err = err - dy
            x0 = x0 + sx
        end
        if e2 <  dx then
            err = err + dx
            y0 = y0 + sy
        end
    end
end


function SWRenderer:drawface(a, b, c)
    local size = render.GetScreenSize()

    local pa = self:calcvertex(a)
    local pb = self:calcvertex(b)
    local pc = self:calcvertex(c)

    local a = pixeltargetcoords(pa, size)
    local b = pixeltargetcoords(pb, size)
    local c = pixeltargetcoords(pc, size)

    self:drawline(a, pa, b, pb)
    self:drawline(a, pa, c, pc)
    self:drawline(b, pb, c, pc)
end

render3d.LoadModel("models/low-poly-sphere.obj", function(meshes)
	LOL = meshes[1]
end)

local swrend = SWRenderer.new()
--swrend:createzbuffer()

function goluwa.PreDrawGUI()
	if not LOL then return end
	swrend:drawframe(LOL)

	local dt = system.GetFrameTime()
	local cam_pos = render3d.camera:GetPosition()
	local cam_ang = render3d.camera:GetAngles()
	local cam_fov = render3d.camera:GetFOV()

	local dir, ang, fov = CalcMovement(dt, cam_ang, cam_fov)

	cam_pos = cam_pos + dir

	render3d.camera:SetPosition(cam_pos)
	render3d.camera:SetAngles(ang)
	render3d.camera:SetFOV(fov)
end


