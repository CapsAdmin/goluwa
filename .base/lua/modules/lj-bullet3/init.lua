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

void bulletStepSimulation(float time_step, int sub_steps, float fixed_time_step);
bool bulletReadCollision(bullet_collision_value *out);
void bulletDrawDebugWorld();

typedef struct {
	float hit_pos[3];
	float hit_normal[3];
	btRigidBody *body;

} bullet_raycast_result;

bool bulletRayCast(float from_x, float from_y, float from_z, float to_x, float to_y, float to_z, bullet_raycast_result *out);

void bulletSetWorldGravity(float x, float y, float z);
void bulletGetWorldGravity(float* out);

btTriangleIndexVertexArray *bulletCreateMesh(int num_triangles, int* triangles, int triangles_stride, int num_vertices, float* vertices, int vertex_stride);

btRigidBody *bulletCreateRigidBodyBox(float mass, float *matrix, float x, float y, float z);
btRigidBody *bulletCreateRigidBodySphere(float mass, float *matrix, float radius);

btRigidBody *bulletCreateRigidBodyConvexHull(float mass, float *matrix, float *mesh);
btRigidBody *bulletCreateRigidBodyConvexTriangleMesh(float mass, float *matrix, btTriangleIndexVertexArray *mesh);
btRigidBody *bulletCreateRigidBodyTriangleMesh(float mass, float *matrix, btTriangleIndexVertexArray *mesh, bool quantized_aabb_compression);

void bulletRemoveBody(btRigidBody *body);
void bulletRigidBodySetMatrix(btRigidBody *body, float *matrix);
void bulletRigidBodyGetMatrix(btRigidBody *body, float *out);
void bulletRigidBodySetMass(btRigidBody *body, float mass, float x, float y, float z);
void bulletRigidBodyGetMass(btRigidBody *body, float *out);
void bulletRigidBodySetGravity(btRigidBody *body, float x, float y, float z);
void bulletRigidBodyGetGravity(btRigidBody *body, float *out);
void bulletRigidBodySetVelocity(btRigidBody *body, float x, float y, float z);
void bulletRigidBodyGetVelocity(btRigidBody *body, float *out);
void bulletRigidBodySetAngularVelocity(btRigidBody *body, float x, float y, float z);
void bulletRigidBodyGetAngularVelocity(btRigidBody *body, float *out);
void bulletRigidBodySetDamping(btRigidBody *body, float linear, float angular);

void bulletRigidBodyGetLinearSleepingThreshold(btRigidBody *body, float *out);
void bulletRigidBodySetLinearSleepingThreshold(btRigidBody *body, float threshold);

void bulletRigidBodyGetAngularSleepingThreshold(btRigidBody *body, float *out);
void bulletRigidBodySetAngularSleepingThreshold(btRigidBody *body, float threshold);

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

typedef void(*bulletDrawLine)(float from_x, float from_y, float from_z, float to_x, float to_y, float to_z, float r, float g, float b);
typedef void(*bulletDrawContactPoint)(float pos_x, float pos_y, float pos_z, float normal_x, float normal_y, float normal_z, int distance, float life_time, float r, float g, float b);
typedef void(*bulletDraw3DText)(float x, float y, float z, const char *text);
typedef void(*bulletReportErrorWarning)(const char *warning);

void bulletEnableDebug(bulletDrawLine draw_line, bulletDrawContactPoint contact_point, bulletDraw3DText _3d_text, bulletReportErrorWarning report_error_warning);
void bulletDisableDebug();
void bulletDrawDebugWorld();
]]
ffi.cdef(header)

local lib = assert(ffi.load("bullet3"))
local bullet = {}
local bodies = {}
local body_lookup = {}

bullet.bodies = bodies

function bullet.Initialize()
	for k,v in pairs(bodies) do 
		if v:IsValid() then
			v:Remove() 
		end
	end
	
	bodies = {}

	lib.bulletInitialize()
end

function bullet.EnableDebug(draw_line, contact_point, _3d_text, report_error_warning)
	lib.bulletEnableDebug(draw_line, contact_point, _3d_text, report_error_warning)
end

function bullet.DisableDebug()
	lib.bulletDisableDebug()
end

function bullet.DrawDebugWorld()
	lib.bulletDrawDebugWorld()
end

function bullet.GetBodies()
	return bodies
end

do
	local out = ffi.new("bullet_raycast_result[1]")
	function bullet.RayCast(from_x, from_y, from_z, to_x, to_y, to_z)
		if lib.bulletRayCast(from_x, from_y, from_z, to_x, to_y, to_z, out) then
			return {
				hit_pos = out[0].hit_pos,
				hit_normal = out[0].hit_normal,
				body = body_lookup[out[0].body],
			}
		end
	end
end

do
	local out = ffi.new("bullet_collision_value[1]")

	function bullet.Update(dt, sub_steps, fixed_time_step)
		sub_steps = sub_steps or 1
		fixed_time_step = fixed_time_step or 1/60
		
		lib.bulletStepSimulation(dt or 0, sub_steps, fixed_time_step)
		
		while lib.bulletReadCollision(out) do
			if body_lookup[out[0].a] and body_lookup[out[0].b] then
				bullet.OnCollision(body_lookup[out[0].a], body_lookup[out[0].b])
			end
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
			return function(self)
				if not self.body then return 0,0,0 end
				func(self.body, val)
				return val[0], val[1], val[2]
			end
		elseif size == 1 then
			return function(self)
				if not self.body then return 0 end
				func(self.body, val)
				return val[0]
			end
		else
			return function(self)
				if not self.body then return end
				func(self.body, val)
				return val
			end
		end
	else
		return function(self, ...)
			if not self.body then return end

			return func(self.body, ...)
		end
	end
end

local BODY = {
	IsValid = function() return true end,
	SetMatrix = ADD_FUNCTION(lib.bulletRigidBodySetMatrix),
	GetMatrix = ADD_FUNCTION(lib.bulletRigidBodyGetMatrix, 16),
	SetGravity = ADD_FUNCTION(lib.bulletRigidBodySetGravity),
	GetGravity = ADD_FUNCTION(lib.bulletRigidBodyGetGravity, 3),
	SetVelocity = ADD_FUNCTION(lib.bulletRigidBodySetVelocity),
	GetVelocity = ADD_FUNCTION(lib.bulletRigidBodyGetVelocity, 3),
	SetAngularVelocity = ADD_FUNCTION(lib.bulletRigidBodySetAngularVelocity),
	GetAngularVelocity = ADD_FUNCTION(lib.bulletRigidBodyGetAngularVelocity, 3),
	
	SetDamping = ADD_FUNCTION(lib.bulletRigidBodySetDamping),
	
	SetLinearSleepingThreshold = ADD_FUNCTION(lib.bulletRigidBodySetLinearSleepingThreshold),
	GetLinearSleepingThreshold = ADD_FUNCTION(lib.bulletRigidBodyGetLinearSleepingThreshold, 1),
	SetAngularSleepingThreshold = ADD_FUNCTION(lib.bulletRigidBodySetAngularSleepingThreshold),
	GetAngularSleepingThreshold = ADD_FUNCTION(lib.bulletRigidBodyGetAngularSleepingThreshold, 1),
	
	Remove = function(self) 
		for k,v in ipairs(bodies) do 
			if v == self then 
				table.remove(bodies, k) 
				break 
			end 
		end 
		lib.bulletRemoveBody(self.body) 
		prototype.MakeNULL(self) 
	end,
}

BODY.__index = BODY

function BODY:IsPhysicsValid()
	return self.body ~= nil
end

do -- damping
	BODY.linear_damping = 0
	BODY.angular_damping = 0

	function BODY:SetLinearDamping(damping)
		self.linear_damping = damping
		if not self.body then return end
		lib.bulletRigidBodySetDamping(self.body, self.linear_damping, self.angular_damping)
	end
	
	function BODY:GetLinearDamping()
		return self.linear_damping
	end

	function BODY:SetAngularDamping(damping)
		self.angular_damping = damping
		if not self.body then return end
		lib.bulletRigidBodySetDamping(self.body, self.linear_damping, self.angular_damping)
	end
	
	function BODY:GetAngularDamping()
		return self.angular_damping
	end
end

do -- mass
	BODY.mass = 1
	
	BODY.origin_x = 0
	BODY.origin_y = 0
	BODY.origin_z = 0

	function BODY:SetMassOrigin(x, y, z)
		self.origin_x = x
		self.origin_y = y
		self.origin_z = z
		
		-- update mass when mass origin is modified
		self:SetMass(self:GetMass())
	end

	function BODY:GetMassOrigin()
		return self.origin_x, self.origin_y, self.origin_z
	end

	function BODY:SetMass(val)
		self.mass = val
		
		if self.body then
			lib.bulletRigidBodySetMass(self.body, val, self.origin_x, self.origin_y, self.origin_z)
		end
	end
	
	local temp = ffi.new("float[1]")
	
	function BODY:GetMass()
		--if self.body then 
		--	lib.bulletRigidBodyGetMass(self.body, temp)
		--	return temp[0]
		--end
		
		return self.mass
	end
end

do
	local temp = ffi.new("float[16]", 0)

	function BODY:SetMatrix(mat)
		if self.body then
			lib.bulletRigidBodySetMatrix(self.body, mat)
		else
			self.matrix = mat
		end
	end

	function BODY:GetMatrix()
		if self.body then lib.bulletRigidBodyGetMatrix(self.body, temp) return temp end
		return self.matrix
	end
end

local function update_params(self)
	self:SetLinearDamping(self:GetLinearDamping())
	self:SetAngularDamping(self:GetAngularDamping())
	self:SetLinearSleepingThreshold(self:GetLinearSleepingThreshold())
	self:SetAngularSleepingThreshold(self:GetAngularSleepingThreshold())
end

do -- init sphere options
	BODY.sphere_radius = 1

	function BODY:SetPhysicsSphereRadius(val)
		self.sphere_radius = val
	end

	function BODY:GetPhysicsSphereRadius()
		return self.sphere_radius
	end
	
	function BODY:InitPhysicsSphere(rad)
		if rad then self:SetPhysicsSphereRadius(rad) end
		
		self.body = lib.bulletCreateRigidBodySphere(self:GetMass(), self.matrix, self:GetPhysicsSphereRadius())
		body_lookup[self.body] = self
		
		update_params(self)
	end
end

do -- init box options
	BODY.box_scale_x = 1
	BODY.box_scale_y = 1
	BODY.box_scale_z = 1

	function BODY:SetPhysicsBoxScale(x, y, z)
		self.box_scale_x = x
		self.box_scale_y = y
		self.box_scale_z = z
	end

	function BODY:GetPhysicsBoxScale()
		return self.box_scale_x, self.box_scale_y, self.box_scale_z
	end

	function BODY:InitPhysicsBox(x, y, z)
		if x and y and z then self:SetPhysicsBoxScale(x, y, z) end
		
		self.body = lib.bulletCreateRigidBodyBox(self:GetMass(), self.matrix, self:GetPhysicsBoxScale())
		body_lookup[self.body] = self
		
		update_params(self)
	end
end

do -- mesh init options
		
	function BODY:InitPhysicsConvexHull(tbl)	
	
		-- if you don't do this "tbl" will get garbage collected and bullet will crash
		-- because bullet says it does not make any copies of indices or vertices
		
		local mesh = ffi.new("float["..#tbl.."]", tbl)
		
		self.mesh = tbl
		
		self.body = lib.bulletCreateRigidBodyConvexHull(self:GetMass(), self.matrix, mesh)
		body_lookup[self.body] = self
		
		update_params(self)
	end
		
	function BODY:InitPhysicsConvexTriangles(tbl)	
	
		-- if you don't do this "tbl" will get garbage collected and bullet will crash
		-- because bullet says it does not make any copies of indices or vertices
		
		local mesh = lib.bulletCreateMesh(
			tbl.triangles.count, 
			tbl.triangles.pointer, 
			tbl.triangles.stride, 
			
			tbl.vertices.count, 
			tbl.vertices.pointer, 
			tbl.vertices.stride
		)
		
		self.mesh = tbl
		
		self.body = lib.bulletCreateRigidBodyConvexTriangleMesh(self:GetMass(), self.matrix, mesh)
		body_lookup[self.body] = self
		
		update_params(self)
	end
	
	function BODY:InitPhysicsTriangles(tbl, quantized_aabb_compression)	
	
		-- if you don't do this "tbl" will get garbage collected and bullet will crash
		-- because bullet says it does not make any copies of indices or vertices
		
		local mesh = lib.bulletCreateMesh(
			tbl.triangles.count, 
			tbl.triangles.pointer, 
			tbl.triangles.stride, 
			
			tbl.vertices.count, 
			tbl.vertices.pointer, 
			tbl.vertices.stride
		)
		
		self.mesh = tbl

		self.body = lib.bulletCreateRigidBodyTriangleMesh(self:GetMass(), self.matrix, mesh, not not quantized_aabb_compression)
		body_lookup[self.body] = self
		
		update_params(self)
	end

	function BODY:SetMeshScale(x, y, z)
		lib.bulletRemoveBody(self.body)
		
		local tri = self.mesh.triangles
		
		local done = {}
		
		for i = 0, tri.count - 1, tri.stride do
			i = tri.pointer[i]
			
			if not done[i] then
				v.pointer[i + 0] = v.pointer[i + 0] * x
				v.pointer[i + 1] = v.pointer[i + 1] * y
				v.pointer[i + 2] = v.pointer[i + 2] * z
				
				done[i] = true
			end
		end
		
		self:InitPhysicsBox(self.mesh)
	end
end

function BODY:__tostring()
	return ("bullet3 body[%p]:%p"):format(self, self.body)
end
	
function bullet.CreateRigidBody()
	local self = setmetatable({}, BODY)
		
	utility.SetGCCallback(self)
	
	table.insert(bodies, self)
	
	return self
end

local DOF6CONSTRAINT = {
	IsValid = function() return true end,
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