local world  = nil; -- world
local ball   = nil; -- body
local radius = 0.2;
local mass = 1.0; --(kg)

local ode = desire("libode")
local ffi = require"ffi"

ode.InitODE()
world = ode.WorldCreate()
ode.WorldSetGravity(world,0,0,-0.001);

-- ball position
local x0 = 0.0;
local y0 = 0.0;
local z0 = 1.0;
local m1 = ffi.new("struct dMass[1]"); --

ball = ode.BodyCreate(world);
ode.MassSetZero(m1);
ode.MassSetSphereTotal(m1,mass,radius);
ode.BodySetMass(ball,m1);
ode.BodySetPosition(ball, x0, y0, z0);

event.AddListener("Update", "ode", function()
	ode.WorldStep(world,0.05); --world step

	local pos = ode.BodyGetPosition(ball); --get Pos
	local q = ode.BodyGetQuaternion(ball) --get Rot

	pos = Vec3(pos[0], pos[1], pos[2])
	q = Quat(q[0], q[1], q[2], q[3])
end)