local ffi = require("ffi")
local header = [[
typedef void *btRigidBody;
typedef void *btGeneric6DofConstraint;
typedef void *btTriangleIndexVertexArray;

typedef struct
{
	btRigidBody a;
	btRigidBody b;
} bullet_collision_value;

void bulletInitialize();

void bulletStepSimulation(float time_step, int sub_steps, float fixed_time_step);
bool bulletReadCollision(bullet_collision_value *out);
void bulletDrawDebugWorld();

typedef struct {
	float hit_pos[3];
	float hit_normal[3];
	btRigidBody body;

} bullet_raycast_result;

bool bulletRayCast(float from_x, float from_y, float from_z, float to_x, float to_y, float to_z, bullet_raycast_result *out);

void bulletSetWorldGravity(float x, float y, float z);
void bulletGetWorldGravity(float* out);

btTriangleIndexVertexArray *bulletCreateMesh(int num_triangles, int* triangles, int triangles_stride, int num_vertices, float* vertices, int vertex_stride);

btRigidBody bulletCreateRigidBodyBox(float mass, float *matrix, float x, float y, float z);
btRigidBody bulletCreateCapsuleZ(float mass, float *matrix, float radius, float scale);
btRigidBody bulletCreateRigidBodySphere(float mass, float *matrix, float radius);

btRigidBody bulletCreateRigidBodyConvexHull(float mass, float *matrix, float *mesh);
btRigidBody bulletCreateRigidBodyConvexTriangleMesh(float mass, float *matrix, btTriangleIndexVertexArray *mesh);
btRigidBody bulletCreateRigidBodyTriangleMesh(float mass, float *matrix, btTriangleIndexVertexArray *mesh, bool quantized_aabb_compression);

void bulletRemoveBody(btRigidBody body);
void bulletRigidBodySetMatrix(btRigidBody body, float *matrix);
void bulletRigidBodyGetMatrix(btRigidBody body, float *out);
void bulletRigidBodySetMass(btRigidBody body, float mass, float x, float y, float z);
void bulletRigidBodyGetMass(btRigidBody body, float *out);
void bulletRigidBodySetGravity(btRigidBody body, float x, float y, float z);
void bulletRigidBodyGetGravity(btRigidBody body, float *out);
void bulletRigidBodySetVelocity(btRigidBody body, float x, float y, float z);
void bulletRigidBodyGetVelocity(btRigidBody body, float *out);
void bulletRigidBodySetAngularVelocity(btRigidBody body, float x, float y, float z);
void bulletRigidBodyGetAngularVelocity(btRigidBody body, float *out);
void bulletRigidBodySetInvInertiaDiagLocal(btRigidBody body, float x, float y, float z);
void bulletRigidBodyGetInvInertiaDiagLocal(btRigidBody body, float *out);

void bulletRigidBodySetLinearFactor(btRigidBody body, float x, float y, float z);
void bulletRigidBodyGetLinearFactor(btRigidBody body, float *out);
void bulletRigidBodySetAngularFactor(btRigidBody body, float x, float y, float z);
void bulletRigidBodyGetAngularFactor(btRigidBody body, float *out);

void bulletRigidBodySetDamping(btRigidBody body, float linear, float angular);

void bulletRigidBodyGetLinearSleepingThreshold(btRigidBody body, float *out);
void bulletRigidBodySetLinearSleepingThreshold(btRigidBody body, float threshold);

void bulletRigidBodyGetAngularSleepingThreshold(btRigidBody body, float *out);
void bulletRigidBodySetAngularSleepingThreshold(btRigidBody body, float threshold);

void *bulletRigidBodyGetUserData(btRigidBody body);
void bulletRigidBodySetUserData(btRigidBody body, void *data);

// constraint
btGeneric6DofConstraint *bulletCreate6DofConstraint(btRigidBody a, btRigidBody b, float *matrix_a, float *matrix_b, bool use_linear_frame_Reference);
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


typedef void(*bulletOnCollision)(btRigidBody a, btRigidBody b);
void bulletSetCollisionCallback(bulletOnCollision cb);

void bulletEnableDebug(bulletDrawLine draw_line, bulletDrawContactPoint contact_point, bulletDraw3DText _3d_text, bulletReportErrorWarning report_error_warning);
void bulletDisableDebug();
void bulletDrawDebugWorld();
]]
ffi.cdef(header)

local lib = assert(ffi.load("bullet3"))

local bullet = {
	header = header,
	lib = lib,
}

-- put all the functions in the glfw table
for line in header:gmatch("(.-)\n") do
	local name = line:match("bullet(.-)%(")

	if name then
		local ok, err = pcall(function()
			bullet[name] = lib["bullet" .. name]
		end)
	end
end

return bullet