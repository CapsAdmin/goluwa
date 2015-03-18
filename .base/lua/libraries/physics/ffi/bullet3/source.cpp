#include "btBulletDynamicsCommon.h"
#include "LinearMath/btVector3.h"
#include "LinearMath/btAlignedObjectArray.h"
#include <stack>

#if defined(_MSC_VER)
	//  Microsoft 
	#define EXPORT __declspec(dllexport)
#elif defined(_GCC)
	//  GCC
	#define EXPORT __attribute__((visibility("default")))
#else
	//  do nothing and hope for the best?
	#pragma warning Unknown dynamic link import/export semantics.
	#define EXPORT 
#endif

btDefaultCollisionConfiguration *collision_config;
btCollisionDispatcher *dispatcher;
btDbvtBroadphase *broadphase;
btSequentialImpulseConstraintSolver *solver;
btDiscreteDynamicsWorld *world;

struct bullet_collision_value
{
	btRigidBody *a;
	btRigidBody *b;
};

struct body_contact_callback;
std::stack<bullet_collision_value> collision_stack;

#define OUT_THING(WHAT, WHERE){auto vec = WHAT;\
WHERE[0] = vec.x();\
WHERE[1] = vec.y();\
WHERE[2] = vec.z();}

extern "C"
{
	EXPORT void bulletInitialize()
	{
		if (world) delete world;
		if (solver) delete solver;
		if (broadphase) delete broadphase;
		if (dispatcher) delete dispatcher;
		if (collision_config) delete collision_config;

		///collision configuration contains default setup for memory, collision setup
		collision_config = new btDefaultCollisionConfiguration();
		//m_collisionConfiguration->setConvexConvexMultipointIterations();

		///use the default collision dispatcher. For parallel processing you can use a diffent dispatcher (see Extras/BulletMultiThreaded)
		dispatcher = new	btCollisionDispatcher(collision_config);

		broadphase = new btDbvtBroadphase();

		///the default constraint solver. For parallel processing you can use a different solver (see Extras/BulletMultiThreaded)
		solver = new btSequentialImpulseConstraintSolver;

		world = new btDiscreteDynamicsWorld(dispatcher, broadphase, solver, collision_config);
	}

	// update
	EXPORT void bulletStepSimulation(float time_step)
	{
		world->stepSimulation(time_step);
	}

	// gravity
	EXPORT void bulletSetWorldGravity(float x, float y, float z)
	{
		world->setGravity(btVector3(x, y, z));
	}
	EXPORT void bulletGetWorldGravity(float* out)
	{
		OUT_THING(world->getGravity(), out)
	}

	typedef struct {
		float hit_pos[3];
		float hit_normal[3];

	} bullet_raycast_result;

	EXPORT int bulletRayCast(float from_x, float from_y, float from_z, float to_x, float to_y, float to_z, bullet_raycast_result *out)
	{
		auto from = btVector3(from_x, from_y, from_z);
		auto to = btVector3(to_x, to_y, to_z);

		auto cb = btCollisionWorld::ClosestRayResultCallback(from, to);

		world->rayTest(from, to, cb);
		
		auto hit = cb.hasHit() ? 1 : 0;
		
		if (hit)
		{
			auto res = bullet_raycast_result();

			OUT_THING(cb.m_hitPointWorld, res.hit_pos)
			OUT_THING(cb.m_hitNormalWorld, res.hit_normal)

			out = &res;
		}

		return hit;
	}

	EXPORT int bulletReadCollision(bullet_collision_value *out)
	{
		if (collision_stack.empty())
			return 0;

		out[0] = collision_stack.top();
		collision_stack.pop();

		return 1;
	}

	struct body_contact_callback : public btCollisionWorld::ContactResultCallback
	{
		virtual	btScalar addSingleResult(btManifoldPoint& cp, const btCollisionObjectWrapper* colObj0Wrap, int partId0, int index0, const btCollisionObjectWrapper* colObj1Wrap, int partId1, int index1)
		{
			auto val = bullet_collision_value();

			val.a = (btRigidBody *)colObj0Wrap->getCollisionObject();
			val.b = (btRigidBody *)colObj1Wrap->getCollisionObject();

			collision_stack.push(val);

			return 0;
		}
	};
}

extern "C"
{
	// constraint
	EXPORT btTypedConstraint *bulletCreate6DofConstraint(btRigidBody *a, btRigidBody *b, float *matrix_a, float *matrix_b, int use_linear_frame_Reference)
	{
		auto transform_a = btTransform();
		transform_a.setFromOpenGLMatrix(matrix_a);

		auto transform_b = btTransform();
		transform_b.setFromOpenGLMatrix(matrix_b);

		auto constraint = new btGeneric6DofConstraint(*a, *b, transform_a, transform_b, use_linear_frame_Reference == 1);

		return constraint;
	}

	EXPORT void bullet6DofConstraintSetUpperAngularLimit(btGeneric6DofConstraint *constraint, float x, float y, float z)
	{
		constraint->setAngularUpperLimit(btVector3(x, y, z));
	}
	EXPORT void bullet6DofConstraintGetUpperAngularLimit(btGeneric6DofConstraint *constraint, float *out)
	{
		btVector3 vec = btVector3(0, 0, 0);
		constraint->getAngularUpperLimit(vec);
		out[0] = vec.x();
		out[1] = vec.y();
		out[2] = vec.z();
	}

	EXPORT void bullet6DofConstraintSeLowerAngularLimit(btGeneric6DofConstraint *constraint, float x, float y, float z)
	{
		constraint->setAngularLowerLimit(btVector3(x, y, z));
	}
	EXPORT void bullet6DofConstraintGeLowerAngularLimit(btGeneric6DofConstraint *constraint, float *out)
	{
		btVector3 vec = btVector3();
		constraint->getAngularLowerLimit(vec);
		out[0] = vec.x();
		out[1] = vec.y();
		out[2] = vec.z();
	}

	EXPORT void bullet6DofConstraintSetUpperLinearLimit(btGeneric6DofConstraint *constraint, float x, float y, float z)
	{
		constraint->setLinearUpperLimit(btVector3(x, y, z));
	}
	EXPORT void bullet6DofConstraintGetUpperLinearLimit(btGeneric6DofConstraint *constraint, float *out)
	{
		btVector3 vec = btVector3(0, 0, 0);
		constraint->getLinearUpperLimit(vec);
		out[0] = vec.x();
		out[1] = vec.y();
		out[2] = vec.z();
	}

	EXPORT void bullet6DofConstraintSeLowerLinearLimit(btGeneric6DofConstraint *constraint, float x, float y, float z)
	{
		constraint->setLinearLowerLimit(btVector3(x, y, z));
	}
	EXPORT void bullet6DofConstraintGeLowerLinearLimit(btGeneric6DofConstraint *constraint, float *out)
	{
		btVector3 vec = btVector3();
		constraint->getLinearLowerLimit(vec);
		out[0] = vec.x();
		out[1] = vec.y();
		out[2] = vec.z();
	}
}

int indices_[36] = {
	2, 6, 5,
	6, 2, 1,
	0, 4, 7,

	4, 0, 3,
	0, 6, 1,
	6, 0, 7,

	4, 2, 5,
	2, 4, 3,
	6, 4, 5,

	4, 6, 7,
	0, 2, 3,
	2, 0, 1,
};

btScalar vertices_[24] = {
	-1, -1, -1,
	1, -1, -1,
	1, -1, 1,

	-1, -1, 1,
	-1, 1, 1,
	1, 1, 1,

	1, 1, -1,
	-1, 1, -1
};

extern "C"
{
	btRigidBody *create_body(float mass, float *matrix, btCollisionShape *shape)
	{
		auto transform = btTransform();
		transform.setFromOpenGLMatrix(matrix);

		auto motion = new btDefaultMotionState(transform);
		btVector3 local_inertia(0, 0, 0);

		if (mass > 0)
		{
			shape->calculateLocalInertia(mass, local_inertia);
		}

		auto info = btRigidBody::btRigidBodyConstructionInfo(mass, motion, shape, local_inertia);

		auto body = new btRigidBody(info);

		world->addRigidBody(body);

		auto callback = body_contact_callback();
		world->contactTest(body, callback);

		return body;
	}

	EXPORT btRigidBody *bulletCreateRigidBodyBox(float mass, float *matrix, float x, float y, float z)
	{
		auto shape = new btBoxShape(btVector3(x, y, z));

		return create_body(mass, matrix, shape);
	}

	EXPORT btRigidBody *bulletCreateRigidBodySphere(float mass, float *matrix, float radius)
	{
		auto shape = new btSphereShape(radius);

		return create_body(mass, matrix, shape);
	}

	EXPORT btTriangleIndexVertexArray *bulletCreateMesh(int num_triangles, int* triangles, int triangles_stride, int num_vertices, float* vertices, int vertex_stride)
	{
		/*
		//auto indices_copy = btAlignedAlloc(sizeof(int) * num_vertices, 16);
		//memcpy(indices_copy, vertices, sizeof(int) * num_vertices);
		auto indices_copy = new int[num_vertices];
		memcpy(indices_copy, vertices, sizeof(indices_copy));

		//auto vertices_copy = btAlignedAlloc(sizeof(float) * num_vertices, 16);
		auto vertices_copy = new float[num_vertices];
		memcpy(vertices_copy, vertices, sizeof(float) * num_vertices);*/

		return new btTriangleIndexVertexArray(num_triangles, triangles, triangles_stride, num_vertices, vertices, vertex_stride);

		//return new btTriangleIndexVertexArray(12, indices_, sizeof(int) * 3, 24, vertices_, sizeof(float) * 3);
	}

	EXPORT btRigidBody *bulletCreateRigidBodyConvexMesh(float mass, float *matrix, btTriangleIndexVertexArray *mesh)
	{

		btCollisionShape *shape = new btConvexTriangleMeshShape(mesh);

		return create_body(mass, matrix, shape);
	}

	EXPORT btRigidBody *bulletCreateRigidBodyConcaveMesh(float mass, float *matrix, btTriangleIndexVertexArray *mesh, int quantized_aabb_compression)
	{
		btCollisionShape *shape = new btBvhTriangleMeshShape(mesh, quantized_aabb_compression == 1);

		return create_body(mass, matrix, shape);
	}

	EXPORT void bulletRemoveBody(btRigidBody *body)
	{
		world->removeRigidBody(body);
	}

	// matrix44
	EXPORT void bulletRigidBodySetMatrix(btRigidBody *body, float *matrix)
	{
		auto transform = btTransform();
		transform.setFromOpenGLMatrix(matrix);

		body->setWorldTransform(transform);
	}
	EXPORT void bulletRigidBodyGetMatrix(btRigidBody *body, float *out)
	{
		body->getWorldTransform().getOpenGLMatrix(out);
	}

	// mass
	EXPORT void bulletRigidBodySetMass(btRigidBody *body, float mass, float x, float y, float z)
	{
		body->setMassProps(mass, btVector3(x, y, z));
	}
	EXPORT void bulletRigidBodyGetMass(btRigidBody *body, float *out)
	{
		out[0] = body->getInvMass();
	}

	// gravity
	EXPORT void bulletRigidBodySetGravity(btRigidBody *body, float x, float y, float z)
	{
		body->setGravity(btVector3(x, y, z));
	}
	EXPORT void bulletRigidBodyGetGravity(btRigidBody *body, float *out)
	{
		OUT_THING(body->getGravity(), out)
	}

	// velocity
	EXPORT void bulletRigidBodySetVelocity(btRigidBody *body, float x, float y, float z)
	{
		body->setLinearVelocity(btVector3(x, y, z));
	}
	EXPORT void bulletRigidBodyGetVelocity(btRigidBody *body, float *out)
	{
		OUT_THING(body->getLinearVelocity(), out)
	}

	// angular velocity
	EXPORT void bulletRigidBodySetAngularVelocity(btRigidBody *body, float x, float y, float z)
	{
		body->setAngularVelocity(btVector3(x, y, z));
	}
	EXPORT void bulletRigidBodyGetAngularVelocity(btRigidBody *body, float *out)
	{
		OUT_THING(body->getAngularVelocity(), out)
	}

	// damping
	EXPORT void bulletRigidBodySetDamping(btRigidBody *body, float linear, float angular)
	{
		body->setDamping(linear, angular);
	}
}

extern "C"
{
	typedef void(*bulletDrawLine)(float from_x, float from_y, float from_z, float to_x, float to_y, float to_z, float r, float g, float b);
	typedef void(*bulletDrawContactPoint)(float pos_x, float pos_y, float pos_z, float normal_x, float normal_y, float normal_z, int distance, float life_time, float r, float g, float b);
	typedef void(*bulletDraw3DText)(float x, float y, float z, const char *text);
	typedef void(*bulletReportErrorWarning)(const char *warning);

	bulletDrawLine draw_line_callback;
	bulletDrawContactPoint contact_point_callback;
	bulletDraw3DText _3d_text_callback;
	bulletReportErrorWarning report_error_warning_callback;

	class bullet_debug : public btIDebugDraw
	{
		void drawLine(const btVector3& from, const btVector3& to, const btVector3& color)
		{
			draw_line_callback(from.x(), from.y(), from.z(), to.x(), to.y(), to.z(), color.x(), color.y(), color.z());
		}

		void drawLine(const btVector3& from, const btVector3& to, const btVector3& colora, const btVector3& colorb)
		{
			draw_line_callback(from.x(), from.y(), from.z(), to.x(), to.y(), to.z(), colora.x(), colora.y(), colora.z());
		}
		void drawContactPoint(const btVector3& PointOnB, const btVector3& normalOnB, btScalar distance, int lifeTime, const btVector3& color)
		{
			contact_point_callback(PointOnB.x(), PointOnB.z(), PointOnB.z(), normalOnB.x(), normalOnB.y(), normalOnB.z(), distance, lifeTime, color.x(), color.y(), color.z());
		}

		void draw3dText(const btVector3& location, const char* textString)
		{
			_3d_text_callback(location.x(), location.y(), location.z(), textString);
		}

		void reportErrorWarning(const char* warningString)
		{
			report_error_warning_callback(warningString);
		}

		void setDebugMode(int debugMode)
		{
			// huh
		}

		int getDebugMode() const
		{
			// huh
			return 1;
		}
	};

	static bullet_debug debug_drawer;

	EXPORT void bulletEnableDebug(bulletDrawLine draw_line, bulletDrawContactPoint contact_point, bulletDraw3DText _3d_text, bulletReportErrorWarning report_error_warning)
	{
		draw_line_callback = draw_line;
		contact_point_callback = contact_point;
		_3d_text_callback = _3d_text;
		report_error_warning_callback = report_error_warning;

		world->setDebugDrawer(&debug_drawer);
	}

	EXPORT void bulletDisableDebug()
	{
		draw_line_callback = nullptr;
		contact_point_callback = nullptr;
		_3d_text_callback = nullptr;
		report_error_warning_callback = nullptr;

		world->setDebugDrawer(nullptr);
	}

	EXPORT void bulletDrawDebugWorld()
	{
		world->debugDrawWorld();
	}
}