local header = [[
typedef void *btRigidBody;
typedef void *btGeneric6DofConstraint;
typedef void *btTriangleIndexVertexArray;

typedef struct
{
	btRigidBody *a;
	btRigidBody *b;
} bullet_collision_value;

void bulletInitialize();

void bulletStepSimulation(float time_step);
bool bulletReadCollision(bullet_collision_value *out);

typedef struct {
	float hit_pos[3];
	float hit_normal[3];

} bullet_raycast_result;

bool bulletRayCast(float from_x, float from_y, float from_z, float to_x, float to_y, float to_z, bullet_raycast_result *out);

// gravity
void bulletSetWorldGravity(float x, float y, float z);
void bulletGetWorldGravity(float* out);

btRigidBody *bulletCreateRigidBodyBox(float mass, float *matrix, float x, float y, float z);
btRigidBody *bulletCreateRigidBodySphere(float mass, float *matrix, float radius);

btTriangleIndexVertexArray *bulletCreateMesh(int num_indices, int* indices, int indices_stride, int num_vertices, float* vertices, int vertex_stride);

btRigidBody *bulletCreateRigidBodyConvexMesh(float mass, float *matrix, btTriangleIndexVertexArray *mesh);
btRigidBody *bulletCreateRigidBodyConcaveMesh(float mass, float *matrix, btTriangleIndexVertexArray *mesh, bool quantized_aabb_compression);
void bulletRemoveBody(btRigidBody *body);

// matrix44
void bulletRigidBodySetMatrix(btRigidBody *body, float *matrix);
void bulletRigidBodyGetMatrix(btRigidBody *body, float *out);

// mass
void bulletRigidBodySetMass(btRigidBody *body, float mass, float x, float y, float z);
void bulletRigidBodyGetMass(btRigidBody *body, float *out);
// gravity
void bulletRigidBodySetGravity(btRigidBody *body, float x, float y, float z);
void bulletRigidBodyGetGravity(btRigidBody *body, float *out);

// velocity
void bulletRigidBodySetVelocity(btRigidBody *body, float x, float y, float z);
void bulletRigidBodyGetVelocity(btRigidBody *body, float *out);
// angular velocity
void bulletRigidBodySetAngularVelocity(btRigidBody *body, float x, float y, float z);
void bulletRigidBodyGetAngularVelocity(btRigidBody *body, float *out);

// damping
void bulletRigidBodySetDamping(btRigidBody *body, float linear, float angular);
// constraint
btGeneric6DofConstraint *bulletCreate6DofConstraint(btRigidBody *a, btRigidBody *b, float *matrix_a, float *matrix_b, bool use_linear_frame_Reference);
void bullet6DofConstraintSetUpperAngularLimit(btGeneric6DofConstraint *constraint, float x, float y, float z);
void bullet6DofConstraintGetUpperAngularLimit(btGeneric6DofConstraint *constraint, float *out);
void bullet6DofConstraintSeLowerAngularLimit(btGeneric6DofConstraint *constraint, float x, float y, float z);
void bullet6DofConstraintGeLowerAngularLimit(btGeneric6DofConstraint *constraint, float *out);
void bullet6DofConstraintSetUpperLinearLimit(btGeneric6DofConstraint *constraint, float x, float y, float z);
void bullet6DofConstraintGetUpperLinearLimit(btGeneric6DofConstraint *constraint, float *out);
void bullet6DofConstraintSeLowerLinearLimit(btGeneric6DofConstraint *constraint, float x, float y, float z);
void bullet6DofConstraintGeLowerLinearLimit(btGeneric6DofConstraint *constraint, float *out);
]]
ffi.cdef(header)

local lib = ffi.load("bullet3")
local bullet = {}
local bodies = {}

function bullet.Initialize()
	if not bullet.init then
		lib.bulletInitialize()
		bullet.init = true
	end
end

function bullet.GetBodies()
	return bodies
end

do
	local out = ffi.new("bullet_raycast_result[1]")
	function bullet.RayCast(from_x, from_y, from_z, to_x, to_y, to_z)
		if lib.RayCast(from_x, from_y, from_z, to_x, to_y, to_z, out) then
			return {
				hit_pos = out[0].hit_pos,
				hit_normal = out[0].hit_normal,
				fraction = out[0].fraction,
			}
		end
	end
end

do
	local out = ffi.new("bullet_collision_value[1]")

	function bullet.Update(dt)
		lib.bulletStepSimulation(dt or 0)
		
		while lib.bulletReadCollision(out) do
			bullet.OnCollision(out[0].a, out[0].b)
		end
	end
end


function bullet.OnCollision(body_a, body_b)

end

do
	function bullet.SetGravity(x, y, z)
		lib.bulletSetWorldGravity(x, y, z)
	end

	local out = ffi.new("float[3]")
	function bullet.GetGravity(x, y, z)
		lib.bulletGetWorldGravity(out)
		return out[0], out[1], out[2]
	end
end


local function ADD_FUNCTION(func, size)
	
	if size then
		local val = ffi.new("float[?]", size)
		
		if size == 3 then
			return function(self, ...)
				func(self.body, val, ...)
				return val[0], val[1], val[2]
			end
		elseif size == 1 then
			return function(self, ...)
				func(self.body, val, ...)
				return val[0]
			end
		else
			return function(self, ...)
				func(self.body, val, ...)
				return val
			end
		end
	else
		return function(self, ...)
			return func(self.body, ...)
		end
	end
end

local BODY = {
	SetMatrix = ADD_FUNCTION(lib.bulletRigidBodySetMatrix),
	GetMatrix = ADD_FUNCTION(lib.bulletRigidBodyGetMatrix, 16),
	SetMass = ADD_FUNCTION(lib.bulletRigidBodySetMass),
	GetMass = ADD_FUNCTION(lib.bulletRigidBodyGetMass, 1),
	SetGravity = ADD_FUNCTION(lib.bulletRigidBodySetGravity),
	GetGravity = ADD_FUNCTION(lib.bulletRigidBodyGetGravity, 3),
	SetVelocity = ADD_FUNCTION(lib.bulletRigidBodySetVelocity),
	GetVelocity = ADD_FUNCTION(lib.bulletRigidBodyGetVelocity, 3),
	SetAngularVelocity = ADD_FUNCTION(lib.bulletRigidBodySetAngularVelocity),
	GetAngularVelocity = ADD_FUNCTION(lib.bulletRigidBodyGetAngularVelocity, 3),
	SetDamping = ADD_FUNCTION(lib.bulletRigidBodySetDamping),
	Remove = function(self) 
		for k,v in ipairs(bodies) do 
			if v == self then 
				table.remove(bodies, k) 
				break 
			end 
		end 
		lib.bulletRemoveBody(self.body) 
		utilities.MakeNULL(self) 
	end,
}

BODY.__index = BODY

function bullet.CreateRigidBody(typ, mass, matrix, ...)
	local self = setmetatable({}, BODY)
	
	if typ == "box" then
		self.body = lib.bulletCreateRigidBodyBox(mass, matrix, ...)
	elseif typ == "sphere" then
		self.body = lib.bulletCreateRigidBodySphere(mass, matrix, ...)
	elseif typ == "concave" then
		self.body = lib.bulletCreateRigidBodyConcaveMesh(mass, matrix, ...)
	elseif typ == "convex" then
		self.body = lib.bulletCreateRigidBodyConvexMesh(mass, matrix, ...)
	else
		error("unknown shape type", 2)
	end
	
	utilities.SetGCCallback(self)
	
	table.insert(bodies, self)
	
	return self
end

local DOF6CONSTRAINT = {
	SetUpperAngularLimit = ADD_FUNCTION(lib.bullet6DofConstraintSetUpperAngularLimit),
	GetUpperAngularLimit = ADD_FUNCTION(lib.bullet6DofConstraintGetUpperAngularLimit, 3),
	SeLowerAngularLimit = ADD_FUNCTION(lib.bullet6DofConstraintSeLowerAngularLimit),
	GeLowerAngularLimit = ADD_FUNCTION(lib.bullet6DofConstraintGeLowerAngularLimit, 3),
	SetUpperLinearLimit = ADD_FUNCTION(lib.bullet6DofConstraintSetUpperLinearLimit),
	GetUpperLinearLimit = ADD_FUNCTION(lib.bullet6DofConstraintGetUpperLinearLimit, 3),
	SeLowerLinearLimit = ADD_FUNCTION(lib.bullet6DofConstraintSeLowerLinearLimit),
	GeLowerLinearLimit = ADD_FUNCTION(lib.bullet6DofConstraintGeLowerLinearLimit, 3),
}

DOF6CONSTRAINT.__index = DOF6CONSTRAINT

function bullet.CreateBallsocketConstraint(body_a, body_b, matrix_a, matrix_b, linear_frame_ref)
	return ffi.metatype("btGeneric6DofConstraint", lib.bulletCreate6DofConstraint(body_a, body_b, matrix_a, matrix_b, linear_frame_ref or 1))
end
 
return bullet