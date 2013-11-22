/*
Bullet Continuous Collision Detection and Physics Library
Copyright (c) 2003-2006 Erwin Coumans  http://continuousphysics.com/Bullet/

This software is provided 'as-is', without any express or implied warranty.
In no event will the authors be held liable for any damages arising from the use of this software.
Permission is granted to anyone to use this software for any purpose,
including commercial applications, and to alter it and redistribute it freely,
subject to the following restrictions:

1. The origin of this software must not be misrepresented; you must not claim that you wrote the original software. If you use this software in a product, an acknowledgment in the product documentation would be appreciated but is not required.
2. Altered source versions must be plainly marked as such, and must not be misrepresented as being the original software.
3. This notice may not be removed or altered from any source distribution.
*/

/*
  Draft high-level generic physics C-API. For low-level access, use the physics SDK native API's.
  Work in progress, functionality will be added on demand.

  If possible, use the richer Bullet C++ API, by including "btBulletDynamicsCommon.h"
*/

#ifndef BULLET_C_API_H
#define BULLET_C_API_H


#include "btBulletCollisionCommon.h"
#include "btBulletDynamicsCommon.h"

#define PL_DECLARE_HANDLE(name) typedef struct name##__ { int unused; } *name
#define PI 3.141592654F

#ifdef BT_USE_DOUBLE_PRECISION
typedef double  plReal;
#else
typedef float  plReal;
#endif

struct FILEFORMAT_HEIGHTFIELD_HEADER
{
	unsigned __int32 Magic;
	unsigned __int32 Version;
	unsigned __int32 NumXVertices;
	unsigned __int32 NumZVertices;
	unsigned __int32 Width;
	unsigned __int32 Length;
	unsigned __int32 Height;
	unsigned __int32 Future[25];
};

typedef plReal  plVector3[3];
typedef plReal  plQuaternion[4];

#ifdef __cplusplus
extern "C" {
#endif

/*  Particular physics SDK */
PL_DECLARE_HANDLE(plPhysicsSdkHandle);

/* Dynamics world, belonging to some physics SDK */
PL_DECLARE_HANDLE(plDynamicsWorldHandle);

/* Rigid Body that can be part of a Dynamics World */
PL_DECLARE_HANDLE(plRigidBodyHandle);

/* Collision Shape/Geometry, property of a Rigid Body (wraps btCollisionShape) */
PL_DECLARE_HANDLE(plCollisionShapeHandle);

/* Constraint for Rigid Bodies (wraps btTypedConstraint) */
PL_DECLARE_HANDLE(plConstraintHandle);

/* Triangle Mesh interface */
PL_DECLARE_HANDLE(plMeshInterfaceHandle);

/* Triangle Mesh Height Field */
PL_DECLARE_HANDLE(plHeightFieldHandle);

/* Broadphase Scene/Proxy Handles */
PL_DECLARE_HANDLE(plCollisionBroadphaseHandle);
PL_DECLARE_HANDLE(plBroadphaseProxyHandle);
PL_DECLARE_HANDLE(plCollisionWorldHandle);
PL_DECLARE_HANDLE(plHingeConstraint);


#define PLPROTO extern __declspec(dllexport)
#define cast_to_rigid_body btRigidBody* body = reinterpret_cast< btRigidBody* >(object); \
	btAssert(body)


//btCollisionObject

/*
Create and Delete a Physics SDK
*/

PLPROTO plPhysicsSdkHandle  plNewBulletSdk(); //this could be also another sdk, like ODE, PhysX etc.
PLPROTO void    plDeletePhysicsSdk(plPhysicsSdkHandle  physicsSdk);

/* Collision World, not strictly necessary, you can also just create a Dynamics World with Rigid Bodies which internally manages the Collision World with Collision Objects */

typedef void(*btBroadphaseCallback)(void *clientData, void *object1, void *object2);
PLPROTO plCollisionBroadphaseHandle  plCreateSapBroadphase(btBroadphaseCallback beginCallback, btBroadphaseCallback endCallback);
PLPROTO void  plDestroyBroadphase(plCollisionBroadphaseHandle bp);
PLPROTO  plBroadphaseProxyHandle plCreateProxy(plCollisionBroadphaseHandle bp, void *clientData, plReal minX, plReal minY, plReal minZ, plReal maxX, plReal maxY, plReal maxZ);
PLPROTO void plDestroyProxy(plCollisionBroadphaseHandle bp, plBroadphaseProxyHandle proxyHandle);
PLPROTO void plSetBoundingBox(plBroadphaseProxyHandle proxyHandle, plReal minX, plReal minY, plReal minZ, plReal maxX, plReal maxY, plReal maxZ);

/* todo: add pair cache support with queries like add/remove/find pair */

PLPROTO plCollisionWorldHandle plCreateCollisionWorld(plPhysicsSdkHandle physicsSdk);

/* todo: add/remove objects */


/* Dynamics World */

PLPROTO plDynamicsWorldHandle  plCreateDynamicsWorld(plVector3 worldMin, plVector3 worldMax);
PLPROTO void                   plDeleteDynamicsWorld(plDynamicsWorldHandle world);
PLPROTO void                   plStepSimulation(plDynamicsWorldHandle, plReal timeStep);
PLPROTO void                   plAddRigidBody(plDynamicsWorldHandle world, plRigidBodyHandle object);
PLPROTO void                   plRemoveRigidBody(plDynamicsWorldHandle world, plRigidBodyHandle object);
PLPROTO int                    pl_DynamicsWorld_getNumCollisionObjects(plDynamicsWorldHandle world);
PLPROTO plRigidBodyHandle      pl_DynamicsWorld_getCollisionObject(plDynamicsWorldHandle world, int objectIndex);

PLPROTO void                   pl_DynamicsWorld_addVehicle(plDynamicsWorldHandle world, plConstraintHandle vehicle);
PLPROTO void                   pl_DynamicsWorld_removeVehicle(plDynamicsWorldHandle world, plConstraintHandle vehicle);

PLPROTO void                   pl_setCollisionProcessedCallback( ContactProcessedCallback fn );



/* plTransform */
struct plTransform
{
	plReal m_Matrix[16];
};

//PLPROTO plCollisionShapeHandle pl_Transform_getOpenGLMatrix(const* plTransform tr, );



/* Rigid Body  */

PLPROTO plRigidBodyHandle      plCreateRigidBody(  void *user_data, float mass, plCollisionShapeHandle cshape );
PLPROTO void                   plSetActivationState(plRigidBodyHandle body, int state);
PLPROTO void                   plDeleteRigidBody(plRigidBodyHandle body);
PLPROTO void                   pl_RigidBody_getOpenGLMatrix(plRigidBodyHandle cbody, plReal *mtx);
PLPROTO plCollisionShapeHandle pl_RigidBody_getCollisionShape(plRigidBodyHandle cbody);
PLPROTO void                   pl_RigidBody_setActivationState(plRigidBodyHandle cbody, int newState);
PLPROTO void                   pl_RigidBody_getRelPosition(plRigidBodyHandle object, const plReal *relPos, plReal *worldPos);
PLPROTO void                   pl_RigidBody_setWorldTransform(plRigidBodyHandle object, const btTransform *transform);
PLPROTO void				   pl_RigidBody_setCollisionFlags(plRigidBodyHandle cbody, int flags);
PLPROTO int					   pl_RigidBody_getCollisionFlags(plRigidBodyHandle cbody);

/* Collision Shape definition */

PLPROTO plCollisionShapeHandle plNewSphereShape(plReal radius);
PLPROTO plCollisionShapeHandle plNewBoxShape(plReal x, plReal y, plReal z);
PLPROTO plCollisionShapeHandle plNewCapsuleShape(plReal radius, plReal height);
PLPROTO plCollisionShapeHandle plNewConeShape(plReal radius, plReal height);
PLPROTO plCollisionShapeHandle plNewCylinderShape(plReal radius, plReal height);
PLPROTO plCollisionShapeHandle plNewCompoundShape();
PLPROTO void                   plAddChildShape(plCollisionShapeHandle compoundShape, plCollisionShapeHandle childShape, plVector3 childPos, plQuaternion childOrn);
PLPROTO void                   pl_CompoundShape_addChildShape(plCollisionShapeHandle compoundShapeHandle, plCollisionShapeHandle childShapeHandle,  const plTransform *transform);
PLPROTO void                   plDeleteShape(plCollisionShapeHandle shape);
PLPROTO int                    pl_CollisionShape_getShapeType(plCollisionShapeHandle shape);
PLPROTO int                    pl_CollisionShape_isConcave(plCollisionShapeHandle shape);
PLPROTO void                  *pl_CollisionShape_getUserPointer(plCollisionShapeHandle shape);
PLPROTO void                   pl_CollisionShape_setUserPointer(plCollisionShapeHandle shape, void *up);
PLPROTO plCollisionShapeHandle pl_UniformScalingShape_getChildShape(plCollisionShapeHandle shape);
PLPROTO plReal                 pl_UniformScalingShape_getUniformScalingFactor(plCollisionShapeHandle shape);
PLPROTO int                    pl_CompoundShape_getNumChildShapes(plCollisionShapeHandle shape);
PLPROTO plCollisionShapeHandle pl_CompoundShape_getChildShape(plCollisionShapeHandle shape, int childIndex);
PLPROTO void                   pl_CompoundShape_getChildTransform(plCollisionShapeHandle shape, int childIndex, plTransform *childTransform);

PLPROTO plCollisionShapeHandle plCreateBvhTriangleMeshShape(int numTriangles, int *triangleIndexBase, int triangleIndexStride, int numVertices, plReal *vertexBase, int vertexStride, int bUseQuantizedAabbCompression);
PLPROTO plCollisionShapeHandle plCreateDeserializedBvhTriangleMeshShape(
	int numTriangles, int *triangleIndexBase, int triangleIndexStride, int numVertices, plReal *vertexBase, int vertexStride, int bUseQuantizedAabbCompression,
	unsigned char *buffer, size_t bufferSize, int bSwapEndian);

PLPROTO void                   pl_BvhTriangleMeshShape_Serialize(plCollisionShapeHandle triShape, unsigned char **memBuf, size_t *memBufSize, int bSwapEndianness);
PLPROTO void                   pl_BvhTriangleMeshShape_SerializeDone(plCollisionShapeHandle triShape, unsigned char *memBuf);

PLPROTO void                   pl_BoxShape_getHalfExtentsWithMargin(plCollisionShapeHandle shape, plReal *halfExtents);

typedef void (*plprocessTriangle_t)(void *opaque, plReal *triangle, int partId, int triangleIndex);
PLPROTO void                   pl_ConcaveShape_processAllTriangles(plCollisionShapeHandle shape, plprocessTriangle_t callback, void *callbackOpaque, const plReal *aabbMin, const plReal *aabbMax);

/* Constraints */
PLPROTO plConstraintHandle     plCreateVehicle(plDynamicsWorldHandle world, const btRaycastVehicle::btVehicleTuning *tuning, plRigidBodyHandle chassis);
PLPROTO void                   plDeleteVehicle(plConstraintHandle);

PLPROTO void                   pl_Vehicle_applyEngineTorque(plConstraintHandle vehicle, btScalar force);
PLPROTO void                   pl_Vehicle_setBrake(plConstraintHandle vehicle, plReal brakePower, plReal parkingBrakePower);
PLPROTO void                   pl_Vehicle_setSteeringValue(plConstraintHandle vehicle, plReal steeringValue, int wheelIndex);
PLPROTO plReal                 pl_Vehicle_getCurrentSpeed(plConstraintHandle vehicle);
PLPROTO plRigidBodyHandle      pl_Vehicle_getRigidBody(plConstraintHandle vehicle);
PLPROTO void                   pl_Vehicle_setCoordinateSystem(plConstraintHandle vehicle, int rightIndex, int upIndex, int forwardIndex);
PLPROTO void                   pl_Vehicle_addWheel(plConstraintHandle vehicle, const plReal *connectionPointCS0, const plReal *wheelDirectionCS0, const plReal *wheelAxleCS, plReal suspensionRestLength, plReal wheelRadius, const btRaycastVehicle::btVehicleTuning *tuning, int isFrontWheel);
PLPROTO int                    pl_Vehicle_getNumWheels(plConstraintHandle vehicle);
PLPROTO void                   pl_Vehicle_resetSuspension(plConstraintHandle vehicle);

PLPROTO plReal                 pl_Vehicle_getRearAxleSpeed(plConstraintHandle vehicle);
PLPROTO void                   pl_Vehicle_setAirDragMultiplier(plConstraintHandle vehicle, plReal airDragMultiplier);
PLPROTO void                   pl_Vehicle_setRollingResistancePerWheel(plConstraintHandle vehicle, plReal rollingResistancePerWheel);
PLPROTO void                   pl_Vehicle_setSwayBarRate(plConstraintHandle vehicle, plReal swayBarRate);
//PLPROTO void                   pl_Vehicle_setRoadSurfaceProperties(plConstraintHandle vehicle, int materialIndex, const btRoadSurfaceProperties* roadSurfaceProps);

PLPROTO void                   pl_Vehicle_updateWheelTransform(plConstraintHandle vehicle, int wheelIndex, int bInterpolatedTransform);
PLPROTO void                   pl_Vehicle_getWheelTransform(plConstraintHandle vehicle, int wheelIndex, plTransform *wheelTransform);
PLPROTO const btWheelInfo     *pl_Vehicle_getWheelInfo(plConstraintHandle vehicle, int wheelIndex);


/* Convex Meshes */
PLPROTO plCollisionShapeHandle plNewConvexHullShape();
PLPROTO void                   plAddVertex(plCollisionShapeHandle convexHull, plReal x, plReal y, plReal z);
/* Concave static triangle meshes */
PLPROTO plMeshInterfaceHandle  plNewMeshInterface();
PLPROTO plHeightFieldHandle    plNewHeightField(double *&heightfieldData, FILE *heightFieldFile = NULL, FILEFORMAT_HEIGHTFIELD_HEADER *hdr = NULL);
PLPROTO void                   plAddTriangle(plMeshInterfaceHandle meshHandle, plVector3 v0, plVector3 v1, plVector3 v2);
PLPROTO plCollisionShapeHandle plNewStaticTriangleMeshShape(plMeshInterfaceHandle);

PLPROTO void                   plSetScaling(plCollisionShapeHandle shape, plVector3 scaling);

/* SOLID has Response Callback/Table/Management */
/* PhysX has Triggers, User Callbacks and filtering */
/* ODE has the typedef void dNearCallback (void *data, dGeomID o1, dGeomID o2); */

/*  typedef void plUpdatedPositionCallback(void* userData, plRigidBodyHandle  rbHandle, plVector3 pos); */
/*  typedef void plUpdatedOrientationCallback(void* userData, plRigidBodyHandle  rbHandle, plQuaternion orientation); */

/* get world transform */
PLPROTO void                    plGetOpenGLMatrix(plRigidBodyHandle object, plReal *matrix);
PLPROTO void                    plGetPosition(plRigidBodyHandle object, plVector3 position);
PLPROTO void                    plGetSize(plRigidBodyHandle object, plReal &width, plReal &height, plReal &length);
PLPROTO void                    plGetOrientation(plRigidBodyHandle object, plQuaternion orientation);

/* set world transform (position/orientation) */
PLPROTO void                    plSetPosition(plRigidBodyHandle object, const plVector3 position);
PLPROTO void                    plApplyImpulse(plRigidBodyHandle object, const plVector3 force);
PLPROTO void                    plApplyTorque(plRigidBodyHandle object, const plVector3 impulse);
PLPROTO void                    plApplyDamping(plRigidBodyHandle object, plReal timeStep);
PLPROTO void                    plGetLinearVelocity(plRigidBodyHandle object, plVector3 vel);
PLPROTO void                    plGetAngularVelocity(plRigidBodyHandle object, plVector3 vel);
PLPROTO plHingeConstraint       plCreateConstraint(plDynamicsWorldHandle world, plRigidBodyHandle object1, plRigidBodyHandle object2);
PLPROTO void                    plSetConstraintTransform(plHingeConstraint constraint, plQuaternion quat);
PLPROTO void                    plSetConstraintOrigin(plHingeConstraint constraintH, plVector3 pos);
PLPROTO void                    plGetConstraintOrigin(plHingeConstraint constraintH, plVector3 pos);
PLPROTO void                    plSetOrientation(plRigidBodyHandle object, const plQuaternion orientation);
PLPROTO void                    plSetDamping(plRigidBodyHandle object, plReal linDamping, plReal angDamping);
PLPROTO void                    plSetRestitution(plRigidBodyHandle object, plReal restitution);
PLPROTO void                    plSetMassProps(plRigidBodyHandle object, plReal mass);
PLPROTO void                    plSetGravity(plRigidBodyHandle object, plReal gravity);
PLPROTO void                    plSetLinVelocity(plRigidBodyHandle object, plReal vel);
PLPROTO void                    plSetEuler(plReal yaw, plReal pitch, plReal roll, plQuaternion orient);

/* Linalg functions */
PLPROTO void                    plInitVector(plVector3 vec, plReal x, plReal y, plReal z);
PLPROTO void                    plSetQuadIdentity(plQuaternion a);
PLPROTO void                    plMultiplyQuat(const plQuaternion a, const plQuaternion b, plQuaternion out);
PLPROTO void                    plTransformVector(const plQuaternion quat, const plReal x, const plReal y, const plReal z, plVector3 out);
PLPROTO void                    plAddVectors(const plVector3 &a, const plVector3 &b, plVector3 &res);

typedef struct plRayCastResult
{
	plRigidBodyHandle       m_body;
	plCollisionShapeHandle  m_shape;
	plVector3               m_positionWorld;
	plVector3               m_normalWorld;
} plRayCastResult;

/**
 * Do a raycast and return the hit closest to rayStart.
 * @param in: world     The world to do collisions with
 * @param in: rayStart  Start of the ray
 * @param in: rayEnd    End of the ray
 * @param out: res      The raycast result
 * @return              The number of ray hits (0 or 1). If nothing hit, the values
 *                      in res are undefined.
 */
PLPROTO int plClosestRayCast(plDynamicsWorldHandle world, const plVector3 &rayStart, const plVector3 &rayEnd, plRayCastResult &res);

/* Sweep API */

/* PLPROTO plRigidBodyHandle plObjectCast(plDynamicsWorldHandle world, const plVector3 rayStart, const plVector3 rayEnd, plVector3 hitpoint, plVector3 normal); */

/* Continuous Collision Detection API */

#if 0
// needed for source/blender/blenkernel/intern/collision.c
double plNearestPoints(float p1[3], float p2[3], float p3[3], float q1[3], float q2[3], float q3[3], float *pa, float *pb, float normal[3]);
#endif

#ifdef __cplusplus
}
#endif



#endif //BULLET_C_API_H

