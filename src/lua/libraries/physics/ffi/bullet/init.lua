ffi.cdef([[
typedef struct {} HACD_Vec3_long;
typedef struct {} HACD_Vec3_Real;
typedef struct {} HACD_CallBackFunction;
typedef struct {} HACD_HACD;
typedef struct {} btSoftBodyNodePtrArray;
typedef struct {} btStridingMeshInterfaceData;
typedef struct {} btWorldImporter;
typedef struct {} btWheelInfo_RaycastInfo;
typedef struct {} btWheelInfoConstructionInfo;
typedef struct {} btSubSimplexClosestResult;
typedef struct {} btUsageBitfield;
typedef struct {} btVehicleRaycaster_btVehicleRaycasterResult;
typedef struct {} btUniversalConstraint;
typedef struct {} btElement;
typedef struct {} btUniformScalingShape;
typedef struct {} btAngularLimit;
typedef struct {} btSolverBody;
typedef struct {} btConstraintArray;
typedef struct {} btTypedConstraintType;
typedef struct {} btJointFeedback;
typedef struct {} btTriangleShape;
typedef struct {} btTriangleMesh;
typedef struct {} btTriangleMeshShape;
typedef struct {} btTriangleInfoMapData;
typedef struct {} btTriangleInfo;
typedef struct {} btTriangleIndexVertexMaterialArray;
typedef struct {} btMaterialProperties;
typedef struct {} IndexedMeshArray;
typedef struct {} pInternalTriangleIndexCallback_InternalProcessTriangleIndex;
typedef struct {} btInternalTriangleIndexCallbackWrapper;
typedef struct {} pTriangleCallback_ProcessTriangle;
typedef struct {} btTriangleCallbackWrapper;
typedef struct {} btTriangleBuffer;
typedef struct {} btTriangle;
typedef struct {} btConvexSeparatingDistanceUtil;
typedef struct {} btBU_Simplex1to4;
typedef struct {} btInternalTriangleIndexCallback;
typedef struct {} btSphereTriangleCollisionAlgorithm;
typedef struct {} btSphereTriangleCollisionAlgorithm_CreateFunc;
typedef struct {} btSphereSphereCollisionAlgorithm;
typedef struct {} btSphereSphereCollisionAlgorithm_CreateFunc;
typedef struct {} btSphereShape;
typedef struct {} btSphereBoxCollisionAlgorithm;
typedef struct {} btSphereBoxCollisionAlgorithm_CreateFunc;
typedef struct {} btSoftSoftCollisionAlgorithm;
typedef struct {} btSoftSoftCollisionAlgorithm_CreateFunc;
typedef struct {} btSoftBodyArray;
typedef struct {} btSoftRigidDynamicsWorld;
typedef struct {} btSoftRigidCollisionAlgorithm;
typedef struct {} btSoftRigidCollisionAlgorithm_CreateFunc;
typedef struct {} btSoftBody_eSolverPresets;
typedef struct {} btSoftBody_eVSolver;
typedef struct {} btSoftBody_vsolver_t;
typedef struct {} btSoftBody_ePSolver;
typedef struct {} btSoftBody_psolver_t;
typedef struct {} btAlignedSoftBodySContactArray;
typedef struct {} btAlignedSoftBodyRContactArray;
typedef struct {} btAlignedSoftBodyNoteArray;
typedef struct {} btAlignedConstCollisionObjectArray;
typedef struct {} btAlignedBoolArray;
typedef struct {} btAlignedSoftBodyAnchorArray;
typedef struct {} btSoftBody_eFeature;
typedef struct {} btSoftBody_sRayCast;
typedef struct {} btSoftBody_SolverState;
typedef struct {} btSoftBody_sMedium;
typedef struct {} btSoftBody_SContact;
typedef struct {} btSoftBody_sCti;
typedef struct {} btSoftBody_RContact;
typedef struct {} btSoftBody_RayFromToCaster;
typedef struct {} btSoftBody_Pose;
typedef struct {} btSoftBody_Note;
typedef struct {} btSoftBody_LJoint;
typedef struct {} btSoftBody_LJoint_Specs;
typedef struct {} btSoftBody_Joint_eType;
typedef struct {} btSoftBody_Joint_Specs;
typedef struct {} pImplicitFn_Eval;
typedef struct {} btSoftBody_ImplicitFn;
typedef struct {} btSoftBody_Feature;
typedef struct {} btSoftBody_Element;
typedef struct {} btAlignedSoftBodyVSolverArray;
typedef struct {} btAlignedSoftBodyPSolverArray;
typedef struct {} btSoftBody_eAeroModel;
typedef struct {} btSoftBody_Config;
typedef struct {} btAlignedSoftBodyNodePtrArray;
typedef struct {} btSoftBody_CJoint;
typedef struct {} btSoftBody_Impulse;
typedef struct {} btSoftBody_Body;
typedef struct {} btSoftBody_Anchor;
typedef struct {} btSoftBody_AJoint_Specs;
typedef struct {} btSoftBody_AJoint;
typedef struct {} btSoftBody_AJoint_IControlWrapper;
typedef struct {} pIControl_Speed;
typedef struct {} pIControl_Prepare;
typedef struct {} btSoftBody_AJoint_IControl;
typedef struct {} btSparseSdf3;
typedef struct {} btSoftBodySolverOutput;
typedef struct {} btAlignedObjectArray;
typedef struct {} SolverTypes;
typedef struct {} btSoftBodySolver;
typedef struct {} btSoftBodyRigidBodyCollisionConfiguration;
typedef struct {} btSoftBodyWorldInfo;
typedef struct {} btSoftBodyConcaveCollisionAlgorithm;
typedef struct {} btSoftBodyConcaveCollisionAlgorithm_SwappedCreateFunc;
typedef struct {} btSoftBodyConcaveCollisionAlgorithm_CreateFunc;
typedef struct {} btSoftBodyTriangleCallback;
typedef struct {} btTriIndex;
typedef struct {} btSliderConstraint;
typedef struct {} btUnionFind;
typedef struct {} btSimulationIslandManager_IslandCallback;
typedef struct {} btShapeHull;
typedef struct {} btDefaultSerializer;
typedef struct {} btChunk;
typedef struct {} btSequentialImpulseConstraintSolver;
typedef struct {} btScaledBvhTriangleMeshShape;
typedef struct {} btRigidBody_btRigidBodyConstructionInfo;
typedef struct {} btDefaultVehicleRaycaster;
typedef struct {} btAlignedWheelInfoArray;
typedef struct {} btWheelInfo;
typedef struct {} btVehicleRaycaster;
typedef struct {} btRaycastVehicle;
typedef struct {} btRaycastVehicle_btVehicleTuning;
typedef struct {} btQuantizedBvh_btTraversalMode;
typedef struct {} BvhSubtreeInfoArray;
typedef struct {} QuantizedNodeArray;
typedef struct {} btQuantizedBvhFloatData;
typedef struct {} btQuantizedBvhDoubleData;
typedef struct {} btQuantizedBvh;
typedef struct {} btNodeOverlapCallback;
typedef struct {} btOptimizedBvhNode;
typedef struct {} btQuantizedBvhNode;
typedef struct {} btPolyhedralConvexAabbCachingShape;
typedef struct {} btPolyhedralConvexShape;
typedef struct {} btPolarDecomposition;
typedef struct {} btPointCollector;
typedef struct {} btPoint2PointConstraint;
typedef struct {} btConstraintSetting;
typedef struct {} btNullPairCache;
typedef struct {} btSortedOverlappingPairCache;
typedef struct {} btOverlapFilterCallback;
typedef struct {} btNNCGConstraintSolver;
typedef struct {} btMaterial;
typedef struct {} btMultimaterialTriangleMeshShape;
typedef struct {} btPositionAndRadius;
typedef struct {} btMultiSphereShape;
typedef struct {} btAlignedMatrix3x3Array;
typedef struct {} btMultiBodySolverConstraint;
typedef struct {} btMultiBodyPoint2Point;
typedef struct {} eFeatherstoneJointType;
typedef struct {} btSpatialMotionVector;
typedef struct {} btMultibodyLink;
typedef struct {} btMultiBodyLinkCollider;
typedef struct {} btMultiBodyJointMotor;
typedef struct {} btMultiBodyJointLimitConstraint;
typedef struct {} btMultiBodyDynamicsWorld;
typedef struct {} btMultiBody;
typedef struct {} btMultiBodyJacobianData;
typedef struct {} btMultiBodyConstraintArray;
typedef struct {} btMultiBodyConstraint;
typedef struct {} btMultiBodyConstraintSolver;
typedef struct {} btMotionState;
typedef struct {} pMotionState_SetWorldTransform;
typedef struct {} pMotionState_GetWorldTransform;
typedef struct {} btMotionStateWrapper;
typedef struct {} btMinkowskiSumShape;
typedef struct {} btMinkowskiPenetrationDepthSolver;
typedef struct {} ContactAddedCallback;
typedef struct {} btConstraintRow;
typedef struct {} btMLCPSolver;
typedef struct {} btVectorXf;
typedef struct {} btMatrixXf;
typedef struct {} btMLCPSolverInterface;
typedef struct {} btLemkeSolver;
typedef struct {} btKinematicCharacterController;
typedef struct {} btIDebugDrawWrapper;
typedef struct {} btHingeAccumulatedAngleConstraint;
typedef struct {} btHingeConstraint;
typedef struct {} btHinge2Constraint;
typedef struct {} btHeightfieldTerrainShape;
typedef struct {} btGjkPairDetector;
typedef struct {} btGjkEpaPenetrationDepthSolver;
typedef struct {} btGjkConvexCast;
typedef struct {} btGhostPairCallback;
typedef struct {} btHashedOverlappingPairCache;
typedef struct {} btPairCachingGhostObject;
typedef struct {} btGhostObject;
typedef struct {} btGeneric6DofSpringConstraint;
typedef struct {} RotateOrder;
typedef struct {} btGeneric6DofSpring2Constraint;
typedef struct {} btTranslationalLimitMotor2;
typedef struct {} btRotationalLimitMotor2;
typedef struct {} btTranslationalLimitMotor;
typedef struct {} btRotationalLimitMotor;
typedef struct {} btGearConstraint;
typedef struct {} btGImpactMeshShapePart;
typedef struct {} PHY_ScalarType;
typedef struct {} btGImpactMeshShapePart_TrimeshPrimitiveManager;
typedef struct {} btGImpactCompoundShape;
typedef struct {} btGImpactCompoundShape_CompoundPrimitiveManager;
typedef struct {} eGIMPACT_SHAPE_TYPE;
typedef struct {} btTriangleShapeEx;
typedef struct {} btGImpactBoxSet;
typedef struct {} btTetrahedronShapeEx;
typedef struct {} btGImpactQuantizedBvh;
typedef struct {} btQuantizedBvhTree;
typedef struct {} GIM_QUANTIZED_BVH_NODE_ARRAY;
typedef struct {} BT_QUANTIZED_BVH_NODE;
typedef struct {} btGImpactShapeInterface;
typedef struct {} btGImpactCollisionAlgorithm;
typedef struct {} btGImpactCollisionAlgorithm_CreateFunc;
typedef struct {} btGImpactBvh;
typedef struct {} btPrimitiveTriangle;
typedef struct {} btPrimitiveManagerBase;
typedef struct {} btBvhTree;
typedef struct {} GIM_BVH_TREE_NODE_ARRAY;
typedef struct {} GIM_BVH_DATA_ARRAY;
typedef struct {} GIM_BVH_TREE_NODE;
typedef struct {} GIM_BVH_DATA;
typedef struct {} btPairSet;
typedef struct {} GIM_PAIR;
typedef struct {} btFixedConstraint;
typedef struct {} btEmptyShape;
typedef struct {} btEmptyAlgorithm;
typedef struct {} btEmptyAlgorithm_CreateFunc;
typedef struct {} btInternalTickCallback;
typedef struct {} btDynamicsWorldType;
typedef struct {} btSimulationIslandManager;
typedef struct {} btTypedConstraint;
typedef struct {} btDiscreteDynamicsWorld;
typedef struct {} btStorageResult;
typedef struct {} btDiscreteCollisionDetectorInterface;
typedef struct {} btDiscreteCollisionDetectorInterface_Result;
typedef struct {} btDiscreteCollisionDetectorInterface_ClosestPointInput;
typedef struct {} btVertexBufferDescriptor;
typedef struct {} btDefaultSoftBodySolver;
typedef struct {} btDefaultMotionState;
typedef struct {} btDefaultCollisionConfiguration;
typedef struct {} btDefaultCollisionConstructionInfo;
typedef struct {} btAlignedStkNNArray;
typedef struct {} btAlignedDbvtNodeArray;
typedef struct {} btAlignedStkNpsArray;
typedef struct {} btDbvt_sStkNPS;
typedef struct {} btDbvt_sStkNP;
typedef struct {} btDbvt_sStkNN;
typedef struct {} btDbvt_sStkCLN;
typedef struct {} btDbvt_IWriter;
typedef struct {} btDbvt_ICollide;
typedef struct {} btDbvt_IClone;
typedef struct {} btDbvtVolume;
typedef struct {} btDbvtAabbMm;
typedef struct {} btDbvtBroadphase;
typedef struct {} btDbvtProxy;
typedef struct {} btDantzigSolver;
typedef struct {} btCylinderShapeZ;
typedef struct {} btCylinderShapeX;
typedef struct {} btCylinderShape;
typedef struct {} btConvexTriangleMeshShape;
typedef struct {} btAlignedFaceArray;
typedef struct {} btConvexPolyhedron;
typedef struct {} btAlignedIntArray;
typedef struct {} btFace;
typedef struct {} btConvexPointCloudShape;
typedef struct {} btConvexPlaneCollisionAlgorithm;
typedef struct {} btConvexPlaneCollisionAlgorithm_CreateFunc;
typedef struct {} btConvexInternalAabbCachingShape;
typedef struct {} btConvexInternalShape;
typedef struct {} btConvexHullShape;
typedef struct {} btConvexConvexAlgorithm;
typedef struct {} btConvexConvexAlgorithm_CreateFunc;
typedef struct {} btConvexConcaveCollisionAlgorithm;
typedef struct {} btConvexConcaveCollisionAlgorithm_SwappedCreateFunc;
typedef struct {} btConvexConcaveCollisionAlgorithm_CreateFunc;
typedef struct {} btConvexTriangleCallback;
typedef struct {} btConvexCast;
typedef struct {} btConvexCast_CastResult;
typedef struct {} btConvex2dShape;
typedef struct {} btConvex2dConvex2dAlgorithm;
typedef struct {} btConvex2dConvex2dAlgorithm_CreateFunc;
typedef struct {} btStaticPlaneShape;
typedef struct {} btConvexPenetrationDepthSolver;
typedef struct {} btVoronoiSimplexSolver;
typedef struct {} btContinuousConvexCollision;
typedef struct {} btContactSolverInfoData;
typedef struct {} btContactConstraint;
typedef struct {} btConstraintSolverType;
typedef struct {} btContactSolverInfo;
typedef struct {} btConstraintSolver;
typedef struct {} btTypedConstraint_btConstraintInfo2;
typedef struct {} btTypedConstraint_btConstraintInfo1;
typedef struct {} btConeTwistConstraint;
typedef struct {} btConeShapeZ;
typedef struct {} btConeShapeX;
typedef struct {} btConeShape;
typedef struct {} btConcaveShape;
typedef struct {} btDbvt;
typedef struct {} btDbvtNode;
typedef struct {} btCompoundShapeChild;
typedef struct {} btGImpactMeshShape;
typedef struct {} btCompoundShape;
typedef struct {} btCompoundCompoundCollisionAlgorithm;
typedef struct {} btCompoundCompoundCollisionAlgorithm_SwappedCreateFunc;
typedef struct {} btCompoundCompoundCollisionAlgorithm_CreateFunc;
typedef struct {} btCompoundCollisionAlgorithm;
typedef struct {} btCompoundCollisionAlgorithm_SwappedCreateFunc;
typedef struct {} btCompoundCollisionAlgorithm_CreateFunc;
typedef struct {} btCollisionObjectArray;
typedef struct {} btConvexShape;
typedef struct {} btCollisionWorld_RayResultCallback;
typedef struct {} pRayResultCallback_NeedsCollision;
typedef struct {} pRayResultCallback_AddSingleResult;
typedef struct {} btCollisionWorld_RayResultCallbackWrapper;
typedef struct {} btCollisionWorld_LocalRayResult;
typedef struct {} btCollisionWorld_LocalShapeInfo;
typedef struct {} btCollisionWorld_LocalConvexResult;
typedef struct {} btCollisionWorld_ConvexResultCallback;
typedef struct {} pConvexResultCallback_NeedsCollision;
typedef struct {} pConvexResultCallback_AddSingleResult;
typedef struct {} btCollisionWorld_ConvexResultCallbackWrapper;
typedef struct {} btManifoldPoint;
typedef struct {} btCollisionWorld_ContactResultCallback;
typedef struct {} pContactResultCallback_NeedsCollision;
typedef struct {} pContactResultCallback_AddSingleResult;
typedef struct {} btCollisionWorld_ContactResultCallbackWrapper;
typedef struct {} btCollisionWorld_ClosestRayResultCallback;
typedef struct {} btCollisionWorld_ClosestConvexResultCallback;
typedef struct {} btAlignedVector3Array;
typedef struct {} btAlignedScalarArray;
typedef struct {} btCollisionWorld_AllHitsRayResultCallback;
typedef struct {} btCollisionShape;
typedef struct {} btNearCallback;
typedef struct {} btCollisionDispatcher;
typedef struct {} btPoolAllocator;
typedef struct {} btCollisionConfiguration;
typedef struct {} btCollisionAlgorithmCreateFunc;
typedef struct {} btManifoldResult;
typedef struct {} btDispatcherInfo;
typedef struct {} btCharacterControllerInterface;
typedef struct {} btCapsuleShapeZ;
typedef struct {} btCapsuleShapeX;
typedef struct {} btCapsuleShape;
typedef struct {} btSerializer;
typedef struct {} btTriangleCallback;
typedef struct {} btTriangleInfoMap;
typedef struct {} btOptimizedBvh;
typedef struct {} btStridingMeshInterface;
typedef struct {} btBvhTriangleMeshShape;
typedef struct {} btBulletXmlWorldImporter;
typedef struct {} btDynamicsWorld;
typedef struct {} btBulletWorldImporter;
typedef struct {} btAligendCharPtrArray;
typedef struct {} btAlignedStructHandleArray;
typedef struct {} bParse_btBulletFile;
typedef struct {} btCollisionAlgorithm;
typedef struct {} btBroadphaseInterface;
typedef struct {} btBroadphaseRayCallback;
typedef struct {} btBroadphaseRayCallbackWrapper;
typedef struct {} btBroadphaseAabbCallback;
typedef struct {} pBroadphaseAabbCallback_Process;
typedef struct {} btBroadphaseAabbCallbackWrapper;
typedef struct {} eBT_PLANE_INTERSECTION_TYPE;
typedef struct {} btAABB;
typedef struct {} BT_BOX_BOX_TRANSFORM_CACHE;
typedef struct {} btBoxShape;
typedef struct {} btBoxBoxDetector;
typedef struct {} btBoxBoxCollisionAlgorithm;
typedef struct {} btBoxBoxCollisionAlgorithm_CreateFunc;
typedef struct {} btVector3;
typedef struct {} btBox2dShape;
typedef struct {} btCollisionObjectWrapper;
typedef struct {} btCollisionAlgorithmConstructionInfo;
typedef struct {} btBox2dBox2dCollisionAlgorithm;
typedef struct {} btBox2dBox2dCollisionAlgorithm_CreateFunc;
typedef struct {} bt32BitAxisSweep3_Handle;
typedef struct {} bt32BitAxisSweep3;
typedef struct {} btBroadphaseProxy;
typedef struct {} btOverlappingPairCallback;
typedef struct {} btOverlapCallback;
typedef struct {} btAxisSweep3_Handle;
typedef struct {} btDispatcher;
typedef struct {} btOverlappingPairCache;
typedef struct {} btAxisSweep3;
typedef struct {} btAlignedSoftBodyTetraArray;
typedef struct {} btSoftBody_Tetra;
typedef struct {} btAlignedSoftBodyNodeArray;
typedef struct {} btSoftBody_Node;
typedef struct {} btAlignedSoftBodyMaterialArray;
typedef struct {} btSoftBody_Material;
typedef struct {} btAlignedSoftBodyLinkArray;
typedef struct {} btSoftBody_Link;
typedef struct {} btAlignedSoftBodyJointArray;
typedef struct {} btSoftBody_Joint;
typedef struct {} btAlignedSoftBodyFaceArray;
typedef struct {} btSoftBody_Face;
typedef struct {} btAlignedSoftBodyClusterArray;
typedef struct {} btSoftBody_Cluster;
typedef struct {} btAlignedSoftBodyArray;
typedef struct {} btSoftBody;
typedef struct {} btPersistentManifold;
typedef struct {} btAlignedManifoldArray;
typedef struct {} btAlignedIndexedMeshArray;
typedef struct {} btIndexedMesh;
typedef struct {} btAlignedCollisionObjectArray;
typedef struct {} btCollisionObject;
typedef struct {} btAlignedBroadphasePairArray;
typedef struct {} btBroadphasePair;
typedef struct {} btCollisionWorld;
typedef struct {} btIDebugDraw;
typedef struct {} btActionInterface;
typedef struct {} pIAction_UpdateAction;
typedef struct {} pIAction_DebugDraw;
typedef struct {} btActionInterfaceWrapper;
typedef float btScalar;
btActionInterfaceWrapper* btActionInterfaceWrapper_new(pIAction_DebugDraw debugDrawCallback, pIAction_UpdateAction updateActionCallback);
void btActionInterface_debugDraw(btActionInterface* obj, btIDebugDraw* debugDrawer);
void btActionInterface_updateAction(btActionInterface* obj, btCollisionWorld* collisionWorld, btScalar deltaTimeStep);
void btActionInterface_delete(btActionInterface* obj);
btBroadphasePair* btAlignedBroadphasePairArray_at(btAlignedBroadphasePairArray* obj, int n);
void btAlignedBroadphasePairArray_push_back(btAlignedBroadphasePairArray* obj, btBroadphasePair* val);
void btAlignedBroadphasePairArray_resizeNoInitialize(btAlignedBroadphasePairArray* obj, int newSize);
int btAlignedBroadphasePairArray_size(btAlignedBroadphasePairArray* obj);
btCollisionObject* btAlignedCollisionObjectArray_at(btAlignedCollisionObjectArray* obj, int n);
void btAlignedCollisionObjectArray_push_back(btAlignedCollisionObjectArray* obj, btCollisionObject* val);
void btAlignedCollisionObjectArray_resizeNoInitialize(btAlignedCollisionObjectArray* obj, int newSize);
int btAlignedCollisionObjectArray_size(btAlignedCollisionObjectArray* obj);
btIndexedMesh* btAlignedIndexedMeshArray_at(btAlignedIndexedMeshArray* obj, int n);
void btAlignedIndexedMeshArray_push_back(btAlignedIndexedMeshArray* obj, btIndexedMesh* val);
void btAlignedIndexedMeshArray_resizeNoInitialize(btAlignedIndexedMeshArray* obj, int newSize);
int btAlignedIndexedMeshArray_size(btAlignedIndexedMeshArray* obj);
btAlignedManifoldArray* btAlignedManifoldArray_new();
btPersistentManifold* btAlignedManifoldArray_at(btAlignedManifoldArray* obj, int n);
void btAlignedManifoldArray_push_back(btAlignedManifoldArray* obj, btPersistentManifold* val);
void btAlignedManifoldArray_resizeNoInitialize(btAlignedManifoldArray* obj, int newSize);
int btAlignedManifoldArray_size(btAlignedManifoldArray* obj);
void btAlignedManifoldArray_delete(btAlignedManifoldArray* obj);
btSoftBody* btAlignedSoftBodyArray_at(btAlignedSoftBodyArray* obj, int n);
void btAlignedSoftBodyArray_push_back(btAlignedSoftBodyArray* obj, btSoftBody* val);
void btAlignedSoftBodyArray_resizeNoInitialize(btAlignedSoftBodyArray* obj, int newSize);
int btAlignedSoftBodyArray_size(btAlignedSoftBodyArray* obj);
btSoftBody_Cluster* btAlignedSoftBodyClusterArray_at(btAlignedSoftBodyClusterArray* obj, int n);
void btAlignedSoftBodyClusterArray_push_back(btAlignedSoftBodyClusterArray* obj, btSoftBody_Cluster* val);
void btAlignedSoftBodyClusterArray_resizeNoInitialize(btAlignedSoftBodyClusterArray* obj, int newSize);
int btAlignedSoftBodyClusterArray_size(btAlignedSoftBodyClusterArray* obj);
btSoftBody_Face* btAlignedSoftBodyFaceArray_at(btAlignedSoftBodyFaceArray* obj, int n);
void btAlignedSoftBodyFaceArray_push_back(btAlignedSoftBodyFaceArray* obj, btSoftBody_Face* val);
void btAlignedSoftBodyFaceArray_resizeNoInitialize(btAlignedSoftBodyFaceArray* obj, int newSize);
int btAlignedSoftBodyFaceArray_size(btAlignedSoftBodyFaceArray* obj);
btSoftBody_Joint* btAlignedSoftBodyJointArray_at(btAlignedSoftBodyJointArray* obj, int n);
void btAlignedSoftBodyJointArray_push_back(btAlignedSoftBodyJointArray* obj, btSoftBody_Joint* val);
void btAlignedSoftBodyJointArray_resizeNoInitialize(btAlignedSoftBodyJointArray* obj, int newSize);
int btAlignedSoftBodyJointArray_size(btAlignedSoftBodyJointArray* obj);
btSoftBody_Link* btAlignedSoftBodyLinkArray_at(btAlignedSoftBodyLinkArray* obj, int n);
void btAlignedSoftBodyLinkArray_push_back(btAlignedSoftBodyLinkArray* obj, btSoftBody_Link* val);
void btAlignedSoftBodyLinkArray_resizeNoInitialize(btAlignedSoftBodyLinkArray* obj, int newSize);
void btAlignedSoftBodyLinkArray_set(btAlignedSoftBodyLinkArray* obj, btSoftBody_Link* val, int index);
int btAlignedSoftBodyLinkArray_size(btAlignedSoftBodyLinkArray* obj);
btSoftBody_Material* btAlignedSoftBodyMaterialArray_at(btAlignedSoftBodyMaterialArray* obj, int n);
void btAlignedSoftBodyMaterialArray_push_back(btAlignedSoftBodyMaterialArray* obj, btSoftBody_Material* val);
void btAlignedSoftBodyMaterialArray_resizeNoInitialize(btAlignedSoftBodyMaterialArray* obj, int newSize);
int btAlignedSoftBodyMaterialArray_size(btAlignedSoftBodyMaterialArray* obj);
btSoftBody_Node* btAlignedSoftBodyNodeArray_at(btAlignedSoftBodyNodeArray* obj, int n);
int btAlignedSoftBodyNodeArray_index_of(btAlignedSoftBodyNodeArray* obj, btSoftBody_Node* val);
void btAlignedSoftBodyNodeArray_push_back(btAlignedSoftBodyNodeArray* obj, btSoftBody_Node* val);
void btAlignedSoftBodyNodeArray_resizeNoInitialize(btAlignedSoftBodyNodeArray* obj, int newSize);
int btAlignedSoftBodyNodeArray_size(btAlignedSoftBodyNodeArray* obj);
btSoftBody_Tetra* btAlignedSoftBodyTetraArray_at(btAlignedSoftBodyTetraArray* obj, int n);
void btAlignedSoftBodyTetraArray_push_back(btAlignedSoftBodyTetraArray* obj, btSoftBody_Tetra* val);
void btAlignedSoftBodyTetraArray_resizeNoInitialize(btAlignedSoftBodyTetraArray* obj, int newSize);
int btAlignedSoftBodyTetraArray_size(btAlignedSoftBodyTetraArray* obj);
btAxisSweep3* btAxisSweep3_new(const btScalar* worldAabbMin, const btScalar* worldAabbMax);
btAxisSweep3* btAxisSweep3_new2(const btScalar* worldAabbMin, const btScalar* worldAabbMax, unsigned short maxHandles);
btAxisSweep3* btAxisSweep3_new3(const btScalar* worldAabbMin, const btScalar* worldAabbMax, unsigned short maxHandles, btOverlappingPairCache* pairCache);
btAxisSweep3* btAxisSweep3_new4(const btScalar* worldAabbMin, const btScalar* worldAabbMax, unsigned short maxHandles, btOverlappingPairCache* pairCache, bool disableRaycastAccelerator);
unsigned short btAxisSweep3_addHandle(btAxisSweep3* obj, const btScalar* aabbMin, const btScalar* aabbMax, void* pOwner, unsigned short collisionFilterGroup, unsigned short collisionFilterMask, btDispatcher* dispatcher, void* multiSapProxy);
btAxisSweep3_Handle* btAxisSweep3_getHandle(btAxisSweep3* obj, unsigned short index);
unsigned short btAxisSweep3_getNumHandles(btAxisSweep3* obj, btOverlapCallback* callback);
btOverlappingPairCallback* btAxisSweep3_getOverlappingPairUserCallback(btAxisSweep3* obj);
void btAxisSweep3_processAllOverlappingPairs(btAxisSweep3* obj, btOverlapCallback* callback);
void btAxisSweep3_quantize(btAxisSweep3* obj, unsigned short* out, const btScalar* point, int isMax);
void btAxisSweep3_removeHandle(btAxisSweep3* obj, unsigned short handle, btDispatcher* dispatcher);
void btAxisSweep3_setOverlappingPairUserCallback(btAxisSweep3* obj, btOverlappingPairCallback* pairCallback);
bool btAxisSweep3_testAabbOverlap(btAxisSweep3* obj, btBroadphaseProxy* proxy0, btBroadphaseProxy* proxy1);
void btAxisSweep3_unQuantize(btAxisSweep3* obj, btBroadphaseProxy* proxy, btScalar* aabbMin, btScalar* aabbMax);
void btAxisSweep3_updateHandle(btAxisSweep3* obj, unsigned short handle, const btScalar* aabbMin, const btScalar* aabbMax, btDispatcher* dispatcher);
bt32BitAxisSweep3* bt32BitAxisSweep3_new(const btScalar* worldAabbMin, const btScalar* worldAabbMax);
bt32BitAxisSweep3* bt32BitAxisSweep3_new2(const btScalar* worldAabbMin, const btScalar* worldAabbMax, unsigned int maxHandles);
bt32BitAxisSweep3* bt32BitAxisSweep3_new3(const btScalar* worldAabbMin, const btScalar* worldAabbMax, unsigned int maxHandles, btOverlappingPairCache* pairCache);
bt32BitAxisSweep3* bt32BitAxisSweep3_new4(const btScalar* worldAabbMin, const btScalar* worldAabbMax, unsigned int maxHandles, btOverlappingPairCache* pairCache, bool disableRaycastAccelerator);
unsigned int bt32BitAxisSweep3_addHandle(bt32BitAxisSweep3* obj, const btScalar* aabbMin, const btScalar* aabbMax, void* pOwner, unsigned short collisionFilterGroup, unsigned short collisionFilterMask, btDispatcher* dispatcher, void* multiSapProxy);
bt32BitAxisSweep3_Handle* bt32BitAxisSweep3_getHandle(bt32BitAxisSweep3* obj, unsigned int index);
unsigned int bt32BitAxisSweep3_getNumHandles(bt32BitAxisSweep3* obj, btOverlapCallback* callback);
btOverlappingPairCache* bt32BitAxisSweep3_getOverlappingPairCache(bt32BitAxisSweep3* obj);
void bt32BitAxisSweep3_processAllOverlappingPairs(bt32BitAxisSweep3* obj, btOverlapCallback* callback);
void bt32BitAxisSweep3_quantize(btAxisSweep3* obj, unsigned int* out, const btScalar* point, int isMax);
void bt32BitAxisSweep3_removeHandle(bt32BitAxisSweep3* obj, unsigned int handle, btDispatcher* dispatcher);
void bt32BitAxisSweep3_setOverlappingPairUserCallback(bt32BitAxisSweep3* obj, btOverlappingPairCallback* pairCallback);
bool bt32BitAxisSweep3_testAabbOverlap(bt32BitAxisSweep3* obj, btBroadphaseProxy* proxy0, btBroadphaseProxy* proxy1);
void bt32BitAxisSweep3_unQuantize(bt32BitAxisSweep3* obj, btBroadphaseProxy* proxy, btScalar* aabbMin, btScalar* aabbMax);
void bt32BitAxisSweep3_updateHandle(bt32BitAxisSweep3* obj, unsigned int handle, const btScalar* aabbMin, const btScalar* aabbMax, btDispatcher* dispatcher);
btBox2dBox2dCollisionAlgorithm_CreateFunc* btBox2dBox2dCollisionAlgorithm_CreateFunc_new();
btBox2dBox2dCollisionAlgorithm* btBox2dBox2dCollisionAlgorithm_new(const btCollisionAlgorithmConstructionInfo* ci);
btBox2dBox2dCollisionAlgorithm* btBox2dBox2dCollisionAlgorithm_new2(btPersistentManifold* mf, const btCollisionAlgorithmConstructionInfo* ci, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap);
btBox2dShape* btBox2dShape_new(const btScalar* boxHalfExtents);
btBox2dShape* btBox2dShape_new2(btScalar boxHalfExtent);
btBox2dShape* btBox2dShape_new3(btScalar boxHalfExtentX, btScalar boxHalfExtentY, btScalar boxHalfExtentZ);
void btBox2dShape_getCentroid(btBox2dShape* obj, btScalar* value);
void btBox2dShape_getHalfExtentsWithMargin(btBox2dShape* obj, btScalar* value);
void btBox2dShape_getHalfExtentsWithoutMargin(btBox2dShape* obj, btScalar* value);
const btVector3* btBox2dShape_getNormals(btBox2dShape* obj);
void btBox2dShape_getPlaneEquation(btBox2dShape* obj, btScalar* plane, int i);
int btBox2dShape_getVertexCount(btBox2dShape* obj);
const btVector3* btBox2dShape_getVertices(btBox2dShape* obj);
btBoxBoxCollisionAlgorithm_CreateFunc* btBoxBoxCollisionAlgorithm_CreateFunc_new();
btBoxBoxCollisionAlgorithm* btBoxBoxCollisionAlgorithm_new(const btCollisionAlgorithmConstructionInfo* ci);
btBoxBoxCollisionAlgorithm* btBoxBoxCollisionAlgorithm_new2(btPersistentManifold* mf, const btCollisionAlgorithmConstructionInfo* ci, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap);
btBoxBoxDetector* btBoxBoxDetector_new(const btBoxShape* box1, const btBoxShape* box2);
const btBoxShape* btBoxBoxDetector_getBox1(btBoxBoxDetector* obj);
const btBoxShape* btBoxBoxDetector_getBox2(btBoxBoxDetector* obj);
void btBoxBoxDetector_setBox1(btBoxBoxDetector* obj, const btBoxShape* value);
void btBoxBoxDetector_setBox2(btBoxBoxDetector* obj, const btBoxShape* value);
BT_BOX_BOX_TRANSFORM_CACHE* BT_BOX_BOX_TRANSFORM_CACHE_new();
void BT_BOX_BOX_TRANSFORM_CACHE_calc_absolute_matrix(BT_BOX_BOX_TRANSFORM_CACHE* obj);
void BT_BOX_BOX_TRANSFORM_CACHE_calc_from_full_invert(BT_BOX_BOX_TRANSFORM_CACHE* obj, const btScalar* trans0, const btScalar* trans1);
void BT_BOX_BOX_TRANSFORM_CACHE_calc_from_homogenic(BT_BOX_BOX_TRANSFORM_CACHE* obj, const btScalar* trans0, const btScalar* trans1);
void BT_BOX_BOX_TRANSFORM_CACHE_getAR(BT_BOX_BOX_TRANSFORM_CACHE* obj, btScalar* value);
void BT_BOX_BOX_TRANSFORM_CACHE_getR1to0(BT_BOX_BOX_TRANSFORM_CACHE* obj, btScalar* value);
void BT_BOX_BOX_TRANSFORM_CACHE_getT1to0(BT_BOX_BOX_TRANSFORM_CACHE* obj, btScalar* value);
void BT_BOX_BOX_TRANSFORM_CACHE_setAR(BT_BOX_BOX_TRANSFORM_CACHE* obj, const btScalar* value);
void BT_BOX_BOX_TRANSFORM_CACHE_setR1to0(BT_BOX_BOX_TRANSFORM_CACHE* obj, const btScalar* value);
void BT_BOX_BOX_TRANSFORM_CACHE_setT1to0(BT_BOX_BOX_TRANSFORM_CACHE* obj, const btScalar* value);
void BT_BOX_BOX_TRANSFORM_CACHE_transform(BT_BOX_BOX_TRANSFORM_CACHE* obj, const btScalar* point, btScalar* value);
void BT_BOX_BOX_TRANSFORM_CACHE_delete(BT_BOX_BOX_TRANSFORM_CACHE* obj);
btAABB* btAABB_new();
btAABB* btAABB_new2(const btScalar* V1, const btScalar* V2, const btScalar* V3);
btAABB* btAABB_new3(const btScalar* V1, const btScalar* V2, const btScalar* V3, btScalar margin);
btAABB* btAABB_new4(const btAABB* other);
btAABB* btAABB_new5(const btAABB* other, btScalar margin);
void btAABB_appy_transform(btAABB* obj, const btScalar* trans);
void btAABB_appy_transform_trans_cache(btAABB* obj, const BT_BOX_BOX_TRANSFORM_CACHE* trans);
bool btAABB_collide_plane(btAABB* obj, const btScalar* plane);
bool btAABB_collide_ray(btAABB* obj, const btScalar* vorigin, const btScalar* vdir);
bool btAABB_collide_triangle_exact(btAABB* obj, const btScalar* p1, const btScalar* p2, const btScalar* p3, const btScalar* triangle_plane);
void btAABB_copy_with_margin(btAABB* obj, const btAABB* other, btScalar margin);
void btAABB_find_intersection(btAABB* obj, const btAABB* other, btAABB* intersection);
void btAABB_get_center_extend(btAABB* obj, btScalar* center, btScalar* extend);
void btAABB_getMax(btAABB* obj, btScalar* value);
void btAABB_getMin(btAABB* obj, btScalar* value);
bool btAABB_has_collision(btAABB* obj, const btAABB* other);
void btAABB_increment_margin(btAABB* obj, btScalar margin);
void btAABB_invalidate(btAABB* obj);
void btAABB_merge(btAABB* obj, const btAABB* box);
bool btAABB_overlapping_trans_cache(btAABB* obj, const btAABB* box, const BT_BOX_BOX_TRANSFORM_CACHE* transcache, bool fulltest);
bool btAABB_overlapping_trans_conservative(btAABB* obj, const btAABB* box, btScalar* trans1_to_0);
bool btAABB_overlapping_trans_conservative2(btAABB* obj, const btAABB* box, const BT_BOX_BOX_TRANSFORM_CACHE* trans1_to_0);
eBT_PLANE_INTERSECTION_TYPE btAABB_plane_classify(btAABB* obj, const btScalar* plane);
void btAABB_projection_interval(btAABB* obj, const btScalar* direction, btScalar* vmin, btScalar* vmax);
void btAABB_setMax(btAABB* obj, const btScalar* value);
void btAABB_setMin(btAABB* obj, const btScalar* value);
void btAABB_delete(btAABB* obj);
btBoxShape* btBoxShape_new(const btScalar* boxHalfExtents);
btBoxShape* btBoxShape_new2(btScalar boxHalfExtent);
btBoxShape* btBoxShape_new3(btScalar boxHalfExtentX, btScalar boxHalfExtentY, btScalar boxHalfExtentZ);
void btBoxShape_getHalfExtentsWithMargin(btBoxShape* obj, btScalar* value);
void btBoxShape_getHalfExtentsWithoutMargin(btBoxShape* obj, btScalar* value);
void btBoxShape_getPlaneEquation(btBoxShape* obj, btScalar* plane, int i);
btBroadphaseAabbCallbackWrapper* btBroadphaseAabbCallbackWrapper_new(pBroadphaseAabbCallback_Process processCallback);
bool btBroadphaseAabbCallback_process(btBroadphaseAabbCallback* obj, const btBroadphaseProxy* proxy);
void btBroadphaseAabbCallback_delete(btBroadphaseAabbCallback* obj);
btBroadphaseRayCallbackWrapper* btBroadphaseRayCallbackWrapper_new(pBroadphaseAabbCallback_Process processCallback);
btScalar btBroadphaseRayCallback_getLambda_max(btBroadphaseRayCallback* obj);
void btBroadphaseRayCallback_getRayDirectionInverse(btBroadphaseRayCallback* obj, btScalar* value);
unsigned int* btBroadphaseRayCallback_getSigns(btBroadphaseRayCallback* obj);
void btBroadphaseRayCallback_setLambda_max(btBroadphaseRayCallback* obj, btScalar value);
void btBroadphaseRayCallback_setRayDirectionInverse(btBroadphaseRayCallback* obj, const btScalar* value);
void btBroadphaseInterface_aabbTest(btBroadphaseInterface* obj, const btScalar* aabbMin, const btScalar* aabbMax, btBroadphaseAabbCallback* callback);
void btBroadphaseInterface_calculateOverlappingPairs(btBroadphaseInterface* obj, btDispatcher* dispatcher);
btBroadphaseProxy* btBroadphaseInterface_createProxy(btBroadphaseInterface* obj, const btScalar* aabbMin, const btScalar* aabbMax, int shapeType, void* userPtr, short collisionFilterGroup, short collisionFilterMask, btDispatcher* dispatcher, void* multiSapProxy);
void btBroadphaseInterface_destroyProxy(btBroadphaseInterface* obj, btBroadphaseProxy* proxy, btDispatcher* dispatcher);
void btBroadphaseInterface_getAabb(btBroadphaseInterface* obj, btBroadphaseProxy* proxy, btScalar* aabbMin, btScalar* aabbMax);
void btBroadphaseInterface_getBroadphaseAabb(btBroadphaseInterface* obj, btScalar* aabbMin, btScalar* aabbMax);
btOverlappingPairCache* btBroadphaseInterface_getOverlappingPairCache(btBroadphaseInterface* obj);
void btBroadphaseInterface_printStats(btBroadphaseInterface* obj);
void btBroadphaseInterface_rayTest(btBroadphaseInterface* obj, const btScalar* rayFrom, const btScalar* rayTo, btBroadphaseRayCallback* rayCallback);
void btBroadphaseInterface_rayTest2(btBroadphaseInterface* obj, const btScalar* rayFrom, const btScalar* rayTo, btBroadphaseRayCallback* rayCallback, const btScalar* aabbMin);
void btBroadphaseInterface_rayTest3(btBroadphaseInterface* obj, const btScalar* rayFrom, const btScalar* rayTo, btBroadphaseRayCallback* rayCallback, const btScalar* aabbMin, const btScalar* aabbMax);
void btBroadphaseInterface_resetPool(btBroadphaseInterface* obj, btDispatcher* dispatcher);
void btBroadphaseInterface_setAabb(btBroadphaseInterface* obj, btBroadphaseProxy* proxy, const btScalar* aabbMin, const btScalar* aabbMax, btDispatcher* dispatcher);
void btBroadphaseInterface_delete(btBroadphaseInterface* obj);
btBroadphaseProxy* btBroadphaseProxy_new();
btBroadphaseProxy* btBroadphaseProxy_new2(const btScalar* aabbMin, const btScalar* aabbMax, void* userPtr, short collisionFilterGroup, short collisionFilterMask);
btBroadphaseProxy* btBroadphaseProxy_new3(const btScalar* aabbMin, const btScalar* aabbMax, void* userPtr, short collisionFilterGroup, short collisionFilterMask, void* multiSapParentProxy);
void btBroadphaseProxy_getAabbMax(btBroadphaseProxy* obj, btScalar* value);
void btBroadphaseProxy_getAabbMin(btBroadphaseProxy* obj, btScalar* value);
void* btBroadphaseProxy_getClientObject(btBroadphaseProxy* obj);
short btBroadphaseProxy_getCollisionFilterGroup(btBroadphaseProxy* obj);
short btBroadphaseProxy_getCollisionFilterMask(btBroadphaseProxy* obj);
void* btBroadphaseProxy_getMultiSapParentProxy(btBroadphaseProxy* obj);
int btBroadphaseProxy_getUid(btBroadphaseProxy* obj);
int btBroadphaseProxy_getUniqueId(btBroadphaseProxy* obj);
bool btBroadphaseProxy_isCompound(int proxyType);
bool btBroadphaseProxy_isConcave(int proxyType);
bool btBroadphaseProxy_isConvex(int proxyType);
bool btBroadphaseProxy_isConvex2d(int proxyType);
bool btBroadphaseProxy_isInfinite(int proxyType);
bool btBroadphaseProxy_isNonMoving(int proxyType);
bool btBroadphaseProxy_isPolyhedral(int proxyType);
bool btBroadphaseProxy_isSoftBody(int proxyType);
void btBroadphaseProxy_setAabbMax(btBroadphaseProxy* obj, const btScalar* value);
void btBroadphaseProxy_setAabbMin(btBroadphaseProxy* obj, const btScalar* value);
void btBroadphaseProxy_setClientObject(btBroadphaseProxy* obj, void* value);
void btBroadphaseProxy_setCollisionFilterGroup(btBroadphaseProxy* obj, short value);
void btBroadphaseProxy_setCollisionFilterMask(btBroadphaseProxy* obj, short value);
void btBroadphaseProxy_setMultiSapParentProxy(btBroadphaseProxy* obj, void* value);
void btBroadphaseProxy_setUniqueId(btBroadphaseProxy* obj, int value);
void btBroadphaseProxy_delete(btBroadphaseProxy* obj);
btBroadphasePair* btBroadphasePair_new();
btBroadphasePair* btBroadphasePair_new2(const btBroadphasePair* other);
btBroadphasePair* btBroadphasePair_new3(btBroadphaseProxy* proxy0, btBroadphaseProxy* proxy1);
btCollisionAlgorithm* btBroadphasePair_getAlgorithm(btBroadphasePair* obj);
btBroadphaseProxy* btBroadphasePair_getPProxy0(btBroadphasePair* obj);
btBroadphaseProxy* btBroadphasePair_getPProxy1(btBroadphasePair* obj);
void btBroadphasePair_setAlgorithm(btBroadphasePair* obj, btCollisionAlgorithm* value);
void btBroadphasePair_setPProxy0(btBroadphasePair* obj, btBroadphaseProxy* value);
void btBroadphasePair_setPProxy1(btBroadphasePair* obj, btBroadphaseProxy* value);
void btBroadphasePair_delete(btBroadphasePair* obj);
bParse_btBulletFile* btBulletFile_new();
bParse_btBulletFile* btBulletFile_new2(const char* fileName);
bParse_btBulletFile* btBulletFile_new3(char* memoryBuffer, int len);
void btBulletFile_addStruct(bParse_btBulletFile* obj, const char* structType, void* data, int len, void* oldPtr, int code);
btAlignedStructHandleArray* btBulletFile_getBvhs(bParse_btBulletFile* obj);
btAlignedStructHandleArray* btBulletFile_getCollisionObjects(bParse_btBulletFile* obj);
btAlignedStructHandleArray* btBulletFile_getCollisionShapes(bParse_btBulletFile* obj);
btAlignedStructHandleArray* btBulletFile_getConstraints(bParse_btBulletFile* obj);
btAligendCharPtrArray* btBulletFile_getDataBlocks(bParse_btBulletFile* obj);
btAlignedStructHandleArray* btBulletFile_getDynamicsWorldInfo(bParse_btBulletFile* obj);
btAlignedStructHandleArray* btBulletFile_getRigidBodies(bParse_btBulletFile* obj);
btAlignedStructHandleArray* btBulletFile_getSoftBodies(bParse_btBulletFile* obj);
btAlignedStructHandleArray* btBulletFile_getTriangleInfoMaps(bParse_btBulletFile* obj);
void btBulletFile_parseData(bParse_btBulletFile* obj);
btBulletWorldImporter* btBulletWorldImporter_new();
btBulletWorldImporter* btBulletWorldImporter_new2(btDynamicsWorld* world);
bool btBulletWorldImporter_convertAllObjects(btBulletWorldImporter* obj, bParse_btBulletFile* file);
bool btBulletWorldImporter_loadFile(btBulletWorldImporter* obj, const char* fileName);
bool btBulletWorldImporter_loadFile2(btBulletWorldImporter* obj, const char* fileName, const char* preSwapFilenameOut);
bool btBulletWorldImporter_loadFileFromMemory(btBulletWorldImporter* obj, char* memoryBuffer, int len);
bool btBulletWorldImporter_loadFileFromMemory2(btBulletWorldImporter* obj, bParse_btBulletFile* file);
btBulletXmlWorldImporter* btBulletXmlWorldImporter_new(btDynamicsWorld* world);
bool btBulletXmlWorldImporter_loadFile(btBulletXmlWorldImporter* obj, const char* fileName);
btBvhTriangleMeshShape* btBvhTriangleMeshShape_new(btStridingMeshInterface* meshInterface, bool useQuantizedAabbCompression);
btBvhTriangleMeshShape* btBvhTriangleMeshShape_new2(btStridingMeshInterface* meshInterface, bool useQuantizedAabbCompression, bool buildBvh);
btBvhTriangleMeshShape* btBvhTriangleMeshShape_new3(btStridingMeshInterface* meshInterface, bool useQuantizedAabbCompression, const btScalar* bvhAabbMin, const btScalar* bvhAabbMax);
btBvhTriangleMeshShape* btBvhTriangleMeshShape_new4(btStridingMeshInterface* meshInterface, bool useQuantizedAabbCompression, const btScalar* bvhAabbMin, const btScalar* bvhAabbMax, bool buildBvh);
void btBvhTriangleMeshShape_buildOptimizedBvh(btBvhTriangleMeshShape* obj);
btOptimizedBvh* btBvhTriangleMeshShape_getOptimizedBvh(btBvhTriangleMeshShape* obj);
bool btBvhTriangleMeshShape_getOwnsBvh(btBvhTriangleMeshShape* obj);
btTriangleInfoMap* btBvhTriangleMeshShape_getTriangleInfoMap(btBvhTriangleMeshShape* obj);
void btBvhTriangleMeshShape_partialRefitTree(btBvhTriangleMeshShape* obj, const btScalar* aabbMin, const btScalar* aabbMax);
void btBvhTriangleMeshShape_performConvexcast(btBvhTriangleMeshShape* obj, btTriangleCallback* callback, const btScalar* boxSource, const btScalar* boxTarget, const btScalar* boxMin, const btScalar* boxMax);
void btBvhTriangleMeshShape_performRaycast(btBvhTriangleMeshShape* obj, btTriangleCallback* callback, const btScalar* raySource, const btScalar* rayTarget);
void btBvhTriangleMeshShape_refitTree(btBvhTriangleMeshShape* obj, const btScalar* aabbMin, const btScalar* aabbMax);
void btBvhTriangleMeshShape_serializeSingleBvh(btBvhTriangleMeshShape* obj, btSerializer* serializer);
void btBvhTriangleMeshShape_serializeSingleTriangleInfoMap(btBvhTriangleMeshShape* obj, btSerializer* serializer);
void btBvhTriangleMeshShape_setOptimizedBvh(btBvhTriangleMeshShape* obj, btOptimizedBvh* bvh);
void btBvhTriangleMeshShape_setOptimizedBvh2(btBvhTriangleMeshShape* obj, btOptimizedBvh* bvh, const btScalar* localScaling);
void btBvhTriangleMeshShape_setTriangleInfoMap(btBvhTriangleMeshShape* obj, btTriangleInfoMap* triangleInfoMap);
bool btBvhTriangleMeshShape_usesQuantizedAabbCompression(btBvhTriangleMeshShape* obj);
btCapsuleShape* btCapsuleShape_new(btScalar radius, btScalar height);
btScalar btCapsuleShape_getHalfHeight(btCapsuleShape* obj);
btScalar btCapsuleShape_getRadius(btCapsuleShape* obj);
int btCapsuleShape_getUpAxis(btCapsuleShape* obj);
btCapsuleShapeX* btCapsuleShapeX_new(btScalar radius, btScalar height);
btCapsuleShapeZ* btCapsuleShapeZ_new(btScalar radius, btScalar height);
bool btCharacterControllerInterface_canJump(btCharacterControllerInterface* obj);
void btCharacterControllerInterface_jump(btCharacterControllerInterface* obj);
bool btCharacterControllerInterface_onGround(btCharacterControllerInterface* obj);
void btCharacterControllerInterface_playerStep(btCharacterControllerInterface* obj, btCollisionWorld* collisionWorld, btScalar dt);
void btCharacterControllerInterface_preStep(btCharacterControllerInterface* obj, btCollisionWorld* collisionWorld);
void btCharacterControllerInterface_reset(btCharacterControllerInterface* obj, btCollisionWorld* collisionWorld);
void btCharacterControllerInterface_setUpInterpolate(btCharacterControllerInterface* obj, bool value);
void btCharacterControllerInterface_setWalkDirection(btCharacterControllerInterface* obj, const btScalar* walkDirection);
void btCharacterControllerInterface_setVelocityForTimeInterval(btCharacterControllerInterface* obj, const btScalar* velocity, btScalar timeInterval);
void btCharacterControllerInterface_warp(btCharacterControllerInterface* obj, const btScalar* origin);
btCollisionAlgorithmConstructionInfo* btCollisionAlgorithmConstructionInfo_new();
btCollisionAlgorithmConstructionInfo* btCollisionAlgorithmConstructionInfo_new2(btDispatcher* dispatcher, int temp);
btDispatcher* btCollisionAlgorithmConstructionInfo_getDispatcher1(btCollisionAlgorithmConstructionInfo* obj);
btPersistentManifold* btCollisionAlgorithmConstructionInfo_getManifold(btCollisionAlgorithmConstructionInfo* obj);
void btCollisionAlgorithmConstructionInfo_setDispatcher1(btCollisionAlgorithmConstructionInfo* obj, btDispatcher* value);
void btCollisionAlgorithmConstructionInfo_setManifold(btCollisionAlgorithmConstructionInfo* obj, btPersistentManifold* value);
void btCollisionAlgorithmConstructionInfo_delete(btCollisionAlgorithmConstructionInfo* obj);
btScalar btCollisionAlgorithm_calculateTimeOfImpact(btCollisionAlgorithm* obj, btCollisionObject* body0, btCollisionObject* body1, const btDispatcherInfo* dispatchInfo, btManifoldResult* resultOut);
void btCollisionAlgorithm_getAllContactManifolds(btCollisionAlgorithm* obj, btAlignedManifoldArray* manifoldArray);
void btCollisionAlgorithm_processCollision(btCollisionAlgorithm* obj, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap, const btDispatcherInfo* dispatchInfo, btManifoldResult* resultOut);
void btCollisionAlgorithm_delete(btCollisionAlgorithm* obj);
btCollisionAlgorithmCreateFunc* btCollisionConfiguration_getCollisionAlgorithmCreateFunc(btCollisionConfiguration* obj, int proxyType0, int proxyType1);
btPoolAllocator* btCollisionConfiguration_getCollisionAlgorithmPool(btCollisionConfiguration* obj);
btPoolAllocator* btCollisionConfiguration_getPersistentManifoldPool(btCollisionConfiguration* obj);
void btCollisionConfiguration_delete(btCollisionConfiguration* obj);
btCollisionAlgorithmCreateFunc* btCollisionAlgorithmCreateFunc_new();
btCollisionAlgorithm* btCollisionAlgorithmCreateFunc_CreateCollisionAlgorithm(btCollisionAlgorithmCreateFunc* obj, btCollisionAlgorithmConstructionInfo* __unnamed0, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap);
bool btCollisionAlgorithmCreateFunc_getSwapped(btCollisionAlgorithmCreateFunc* obj);
void btCollisionAlgorithmCreateFunc_setSwapped(btCollisionAlgorithmCreateFunc* obj, bool value);
void btCollisionAlgorithmCreateFunc_delete(btCollisionAlgorithmCreateFunc* obj);
btCollisionDispatcher* btCollisionDispatcher_new(btCollisionConfiguration* collisionConfiguration);
void btCollisionDispatcher_defaultNearCallback(btBroadphasePair* collisionPair, btCollisionDispatcher* dispatcher, const btDispatcherInfo* dispatchInfo);
const btCollisionConfiguration* btCollisionDispatcher_getCollisionConfiguration(btCollisionDispatcher* obj);
int btCollisionDispatcher_getDispatcherFlags(btCollisionDispatcher* obj);
btNearCallback btCollisionDispatcher_getNearCallback(btCollisionDispatcher* obj);
void btCollisionDispatcher_registerCollisionCreateFunc(btCollisionDispatcher* obj, int proxyType0, int proxyType1, btCollisionAlgorithmCreateFunc* createFunc);
void btCollisionDispatcher_setCollisionConfiguration(btCollisionDispatcher* obj, btCollisionConfiguration* config);
void btCollisionDispatcher_setDispatcherFlags(btCollisionDispatcher* obj, int flags);
void btCollisionDispatcher_setNearCallback(btCollisionDispatcher* obj, btNearCallback nearCallback);
const btCollisionObject* btCollisionObjectWrapper_getCollisionObject(btCollisionObjectWrapper* obj);
const btCollisionShape* btCollisionObjectWrapper_getCollisionShape(btCollisionObjectWrapper* obj);
int btCollisionObjectWrapper_getIndex(btCollisionObjectWrapper* obj);
const btCollisionObjectWrapper* btCollisionObjectWrapper_getParent(btCollisionObjectWrapper* obj);
int btCollisionObjectWrapper_getPartId(btCollisionObjectWrapper* obj);
void btCollisionObjectWrapper_getWorldTransform(btCollisionObjectWrapper* obj, btScalar* value);
void btCollisionObjectWrapper_setCollisionObject(btCollisionObjectWrapper* obj, const btCollisionObject* value);
void btCollisionObjectWrapper_setIndex(btCollisionObjectWrapper* obj, int value);
void btCollisionObjectWrapper_setParent(btCollisionObjectWrapper* obj, const btCollisionObjectWrapper* value);
void btCollisionObjectWrapper_setPartId(btCollisionObjectWrapper* obj, int value);
void btCollisionObjectWrapper_setShape(btCollisionObjectWrapper* obj, const btCollisionShape* value);
btCollisionObject* btCollisionObject_new();
void btCollisionObject_activate(btCollisionObject* obj);
void btCollisionObject_activate2(btCollisionObject* obj, bool forceActivation);
int btCollisionObject_calculateSerializeBufferSize(btCollisionObject* obj);
bool btCollisionObject_checkCollideWith(btCollisionObject* obj, const btCollisionObject* co);
bool btCollisionObject_checkCollideWithOverride(btCollisionObject* obj, const btCollisionObject* co);
void btCollisionObject_forceActivationState(btCollisionObject* obj, int newState);
int btCollisionObject_getActivationState(btCollisionObject* obj);
void btCollisionObject_getAnisotropicFriction(btCollisionObject* obj, btScalar* value);
btBroadphaseProxy* btCollisionObject_getBroadphaseHandle(btCollisionObject* obj);
btScalar btCollisionObject_getCcdMotionThreshold(btCollisionObject* obj);
btScalar btCollisionObject_getCcdSquareMotionThreshold(btCollisionObject* obj);
btScalar btCollisionObject_getCcdSweptSphereRadius(btCollisionObject* obj);
int btCollisionObject_getCollisionFlags(btCollisionObject* obj);
btCollisionShape* btCollisionObject_getCollisionShape(btCollisionObject* obj);
int btCollisionObject_getCompanionId(btCollisionObject* obj);
btScalar btCollisionObject_getContactProcessingThreshold(btCollisionObject* obj);
btScalar btCollisionObject_getDeactivationTime(btCollisionObject* obj);
btScalar btCollisionObject_getFriction(btCollisionObject* obj);
btScalar btCollisionObject_getHitFraction(btCollisionObject* obj);
int btCollisionObject_getInternalType(btCollisionObject* obj);
void btCollisionObject_getInterpolationAngularVelocity(btCollisionObject* obj, btScalar* angvel);
void btCollisionObject_getInterpolationLinearVelocity(btCollisionObject* obj, btScalar* linvel);
void btCollisionObject_getInterpolationWorldTransform(btCollisionObject* obj, btScalar* trans);
int btCollisionObject_getIslandTag(btCollisionObject* obj);
btScalar btCollisionObject_getRestitution(btCollisionObject* obj);
btScalar btCollisionObject_getRollingFriction(btCollisionObject* obj);
int btCollisionObject_getUserIndex(btCollisionObject* obj);
void* btCollisionObject_getUserPointer(btCollisionObject* obj);
void btCollisionObject_getWorldTransform(btCollisionObject* obj, btScalar* worldTrans);
bool btCollisionObject_hasAnisotropicFriction(btCollisionObject* obj);
bool btCollisionObject_hasAnisotropicFriction2(btCollisionObject* obj, int frictionMode);
bool btCollisionObject_hasContactResponse(btCollisionObject* obj);
void* btCollisionObject_internalGetExtensionPointer(btCollisionObject* obj);
void btCollisionObject_internalSetExtensionPointer(btCollisionObject* obj, void* pointer);
bool btCollisionObject_isActive(btCollisionObject* obj);
bool btCollisionObject_isKinematicObject(btCollisionObject* obj);
bool btCollisionObject_isStaticObject(btCollisionObject* obj);
bool btCollisionObject_isStaticOrKinematicObject(btCollisionObject* obj);
bool btCollisionObject_mergesSimulationIslands(btCollisionObject* obj);
const char* btCollisionObject_serialize(btCollisionObject* obj, void* dataBuffer, btSerializer* serializer);
void btCollisionObject_serializeSingleObject(btCollisionObject* obj, btSerializer* serializer);
void btCollisionObject_setActivationState(btCollisionObject* obj, int newState);
void btCollisionObject_setAnisotropicFriction(btCollisionObject* obj, const btScalar* anisotropicFriction);
void btCollisionObject_setAnisotropicFriction2(btCollisionObject* obj, const btScalar* anisotropicFriction, int frictionMode);
void btCollisionObject_setBroadphaseHandle(btCollisionObject* obj, btBroadphaseProxy* handle);
void btCollisionObject_setCcdMotionThreshold(btCollisionObject* obj, btScalar ccdMotionThreshold);
void btCollisionObject_setCcdSweptSphereRadius(btCollisionObject* obj, btScalar radius);
void btCollisionObject_setCollisionFlags(btCollisionObject* obj, int flags);
void btCollisionObject_setCollisionShape(btCollisionObject* obj, btCollisionShape* collisionShape);
void btCollisionObject_setCompanionId(btCollisionObject* obj, int id);
void btCollisionObject_setContactProcessingThreshold(btCollisionObject* obj, btScalar contactProcessingThreshold);
void btCollisionObject_setDeactivationTime(btCollisionObject* obj, btScalar time);
void btCollisionObject_setFriction(btCollisionObject* obj, btScalar frict);
void btCollisionObject_setHitFraction(btCollisionObject* obj, btScalar hitFraction);
void btCollisionObject_setIgnoreCollisionCheck(btCollisionObject* obj, const btCollisionObject* co, bool ignoreCollisionCheck);
void btCollisionObject_setInterpolationAngularVelocity(btCollisionObject* obj, const btScalar* angvel);
void btCollisionObject_setInterpolationLinearVelocity(btCollisionObject* obj, const btScalar* linvel);
void btCollisionObject_setInterpolationWorldTransform(btCollisionObject* obj, const btScalar* trans);
void btCollisionObject_setIslandTag(btCollisionObject* obj, int tag);
void btCollisionObject_setRestitution(btCollisionObject* obj, btScalar rest);
void btCollisionObject_setRollingFriction(btCollisionObject* obj, btScalar frict);
void btCollisionObject_setUserIndex(btCollisionObject* obj, int index);
void btCollisionObject_setUserPointer(btCollisionObject* obj, void* userPointer);
void btCollisionObject_setWorldTransform(btCollisionObject* obj, const btScalar* worldTrans);
void btCollisionObject_delete(btCollisionObject* obj);
void btCollisionShape_calculateLocalInertia(btCollisionShape* obj, btScalar mass, btScalar* inertia);
int btCollisionShape_calculateSerializeBufferSize(btCollisionShape* obj);
void btCollisionShape_calculateTemporalAabb(btCollisionShape* obj, const btScalar* curTrans, const btScalar* linvel, const btScalar* angvel, btScalar timeStep, btScalar* temporalAabbMin, btScalar* temporalAabbMax);
void btCollisionShape_getAabb(btCollisionShape* obj, const btScalar* t, btScalar* aabbMin, btScalar* aabbMax);
btScalar btCollisionShape_getAngularMotionDisc(btCollisionShape* obj);
void btCollisionShape_getAnisotropicRollingFrictionDirection(btCollisionShape* obj, btScalar* value);
void btCollisionShape_getBoundingSphere(btCollisionShape* obj, btScalar* center, btScalar* radius);
btScalar btCollisionShape_getContactBreakingThreshold(btCollisionShape* obj, btScalar defaultContactThresholdFactor);
void btCollisionShape_getLocalScaling(btCollisionShape* obj, btScalar* scaling);
btScalar btCollisionShape_getMargin(btCollisionShape* obj);
const char* btCollisionShape_getName(btCollisionShape* obj);
int btCollisionShape_getShapeType(btCollisionShape* obj);
int btCollisionShape_getUserIndex(btCollisionShape* obj);
void* btCollisionShape_getUserPointer(btCollisionShape* obj);
bool btCollisionShape_isCompound(btCollisionShape* obj);
bool btCollisionShape_isConcave(btCollisionShape* obj);
bool btCollisionShape_isConvex(btCollisionShape* obj);
bool btCollisionShape_isConvex2d(btCollisionShape* obj);
bool btCollisionShape_isInfinite(btCollisionShape* obj);
bool btCollisionShape_isNonMoving(btCollisionShape* obj);
bool btCollisionShape_isPolyhedral(btCollisionShape* obj);
bool btCollisionShape_isSoftBody(btCollisionShape* obj);
const char* btCollisionShape_serialize(btCollisionShape* obj, void* dataBuffer, btSerializer* serializer);
void btCollisionShape_serializeSingleShape(btCollisionShape* obj, btSerializer* serializer);
void btCollisionShape_setLocalScaling(btCollisionShape* obj, const btScalar* scaling);
void btCollisionShape_setMargin(btCollisionShape* obj, btScalar margin);
void btCollisionShape_setUserIndex(btCollisionShape* obj, int index);
void btCollisionShape_setUserPointer(btCollisionShape* obj, void* userPtr);
void btCollisionShape_delete(btCollisionShape* obj);
btCollisionWorld_AllHitsRayResultCallback* btCollisionWorld_AllHitsRayResultCallback_new(const btScalar* rayFromWorld, const btScalar* rayToWorld);
btAlignedCollisionObjectArray* btCollisionWorld_AllHitsRayResultCallback_getCollisionObjects(btCollisionWorld_AllHitsRayResultCallback* obj);
btAlignedScalarArray* btCollisionWorld_AllHitsRayResultCallback_getHitFractions(btCollisionWorld_AllHitsRayResultCallback* obj);
btAlignedVector3Array* btCollisionWorld_AllHitsRayResultCallback_getHitNormalWorld(btCollisionWorld_AllHitsRayResultCallback* obj);
btAlignedVector3Array* btCollisionWorld_AllHitsRayResultCallback_getHitPointWorld(btCollisionWorld_AllHitsRayResultCallback* obj);
void btCollisionWorld_AllHitsRayResultCallback_getRayFromWorld(btCollisionWorld_AllHitsRayResultCallback* obj, btScalar* value);
void btCollisionWorld_AllHitsRayResultCallback_getRayToWorld(btCollisionWorld_AllHitsRayResultCallback* obj, btScalar* value);
void btCollisionWorld_AllHitsRayResultCallback_setRayFromWorld(btCollisionWorld_AllHitsRayResultCallback* obj, const btScalar* value);
void btCollisionWorld_AllHitsRayResultCallback_setRayToWorld(btCollisionWorld_AllHitsRayResultCallback* obj, const btScalar* value);
btCollisionWorld_ClosestConvexResultCallback* btCollisionWorld_ClosestConvexResultCallback_new(const btScalar* convexFromWorld, const btScalar* convexToWorld);
void btCollisionWorld_ClosestConvexResultCallback_getConvexFromWorld(btCollisionWorld_ClosestConvexResultCallback* obj, btScalar* value);
void btCollisionWorld_ClosestConvexResultCallback_getConvexToWorld(btCollisionWorld_ClosestConvexResultCallback* obj, btScalar* value);
const btCollisionObject* btCollisionWorld_ClosestConvexResultCallback_getHitCollisionObject(btCollisionWorld_ClosestConvexResultCallback* obj);
void btCollisionWorld_ClosestConvexResultCallback_getHitNormalWorld(btCollisionWorld_ClosestConvexResultCallback* obj, btScalar* value);
void btCollisionWorld_ClosestConvexResultCallback_getHitPointWorld(btCollisionWorld_ClosestConvexResultCallback* obj, btScalar* value);
void btCollisionWorld_ClosestConvexResultCallback_setConvexFromWorld(btCollisionWorld_ClosestConvexResultCallback* obj, const btScalar* value);
void btCollisionWorld_ClosestConvexResultCallback_setConvexToWorld(btCollisionWorld_ClosestConvexResultCallback* obj, const btScalar* value);
void btCollisionWorld_ClosestConvexResultCallback_setHitCollisionObject(btCollisionWorld_ClosestConvexResultCallback* obj, const btCollisionObject* value);
void btCollisionWorld_ClosestConvexResultCallback_setHitNormalWorld(btCollisionWorld_ClosestConvexResultCallback* obj, const btScalar* value);
void btCollisionWorld_ClosestConvexResultCallback_setHitPointWorld(btCollisionWorld_ClosestConvexResultCallback* obj, const btScalar* value);
btCollisionWorld_ClosestRayResultCallback* btCollisionWorld_ClosestRayResultCallback_new(const btScalar* rayFromWorld, const btScalar* rayToWorld);
void btCollisionWorld_ClosestRayResultCallback_getHitNormalWorld(btCollisionWorld_ClosestRayResultCallback* obj, btScalar* value);
void btCollisionWorld_ClosestRayResultCallback_getHitPointWorld(btCollisionWorld_ClosestRayResultCallback* obj, btScalar* value);
void btCollisionWorld_ClosestRayResultCallback_getRayFromWorld(btCollisionWorld_ClosestRayResultCallback* obj, btScalar* value);
void btCollisionWorld_ClosestRayResultCallback_getRayToWorld(btCollisionWorld_ClosestRayResultCallback* obj, btScalar* value);
void btCollisionWorld_ClosestRayResultCallback_setHitNormalWorld(btCollisionWorld_ClosestRayResultCallback* obj, const btScalar* value);
void btCollisionWorld_ClosestRayResultCallback_setHitPointWorld(btCollisionWorld_ClosestRayResultCallback* obj, const btScalar* value);
void btCollisionWorld_ClosestRayResultCallback_setRayFromWorld(btCollisionWorld_ClosestRayResultCallback* obj, const btScalar* value);
void btCollisionWorld_ClosestRayResultCallback_setRayToWorld(btCollisionWorld_ClosestRayResultCallback* obj, const btScalar* value);
btCollisionWorld_ContactResultCallbackWrapper* btCollisionWorld_ContactResultCallbackWrapper_new(pContactResultCallback_AddSingleResult addSingleResultCallback, pContactResultCallback_NeedsCollision needsCollisionCallback);
bool btCollisionWorld_ContactResultCallbackWrapper_needsCollision(btCollisionWorld_ContactResultCallbackWrapper* obj, btBroadphaseProxy* proxy0);
btScalar btCollisionWorld_ContactResultCallback_addSingleResult(btCollisionWorld_ContactResultCallback* obj, btManifoldPoint* cp, const btCollisionObjectWrapper* colObj0Wrap, int partId0, int index0, const btCollisionObjectWrapper* colObj1Wrap, int partId1, int index1);
short btCollisionWorld_ContactResultCallback_getCollisionFilterGroup(btCollisionWorld_ContactResultCallback* obj);
short btCollisionWorld_ContactResultCallback_getCollisionFilterMask(btCollisionWorld_ContactResultCallback* obj);
bool btCollisionWorld_ContactResultCallback_needsCollision(btCollisionWorld_ContactResultCallback* obj, btBroadphaseProxy* proxy0);
void btCollisionWorld_ContactResultCallback_setCollisionFilterGroup(btCollisionWorld_ContactResultCallback* obj, short value);
void btCollisionWorld_ContactResultCallback_setCollisionFilterMask(btCollisionWorld_ContactResultCallback* obj, short value);
void btCollisionWorld_ContactResultCallback_delete(btCollisionWorld_ContactResultCallback* obj);
btCollisionWorld_ConvexResultCallbackWrapper* btCollisionWorld_ConvexResultCallbackWrapper_new(pConvexResultCallback_AddSingleResult addSingleResultCallback, pConvexResultCallback_NeedsCollision needsCollisionCallback);
bool btCollisionWorld_ConvexResultCallbackWrapper_needsCollision(btCollisionWorld_ConvexResultCallbackWrapper* obj, btBroadphaseProxy* proxy0);
btScalar btCollisionWorld_ConvexResultCallback_addSingleResult(btCollisionWorld_ConvexResultCallback* obj, btCollisionWorld_LocalConvexResult* convexResult, bool normalInWorldSpace);
btScalar btCollisionWorld_ConvexResultCallback_getClosestHitFraction(btCollisionWorld_ConvexResultCallback* obj);
short btCollisionWorld_ConvexResultCallback_getCollisionFilterGroup(btCollisionWorld_ConvexResultCallback* obj);
short btCollisionWorld_ConvexResultCallback_getCollisionFilterMask(btCollisionWorld_ConvexResultCallback* obj);
bool btCollisionWorld_ConvexResultCallback_hasHit(btCollisionWorld_ConvexResultCallback* obj);
bool btCollisionWorld_ConvexResultCallback_needsCollision(btCollisionWorld_ConvexResultCallback* obj, btBroadphaseProxy* proxy0);
void btCollisionWorld_ConvexResultCallback_setClosestHitFraction(btCollisionWorld_ConvexResultCallback* obj, btScalar value);
void btCollisionWorld_ConvexResultCallback_setCollisionFilterGroup(btCollisionWorld_ConvexResultCallback* obj, short value);
void btCollisionWorld_ConvexResultCallback_setCollisionFilterMask(btCollisionWorld_ConvexResultCallback* obj, short value);
void btCollisionWorld_ConvexResultCallback_delete(btCollisionWorld_ConvexResultCallback* obj);
btCollisionWorld_LocalConvexResult* btCollisionWorld_LocalConvexResult_new(const btCollisionObject* hitCollisionObject, btCollisionWorld_LocalShapeInfo* localShapeInfo, const btScalar* hitNormalLocal, const btScalar* hitPointLocal, btScalar hitFraction);
const btCollisionObject* btCollisionWorld_LocalConvexResult_getHitCollisionObject(btCollisionWorld_LocalConvexResult* obj);
btScalar btCollisionWorld_LocalConvexResult_getHitFraction(btCollisionWorld_LocalConvexResult* obj);
void btCollisionWorld_LocalConvexResult_getHitNormalLocal(btCollisionWorld_LocalConvexResult* obj, btScalar* value);
void btCollisionWorld_LocalConvexResult_getHitPointLocal(btCollisionWorld_LocalConvexResult* obj, btScalar* value);
btCollisionWorld_LocalShapeInfo* btCollisionWorld_LocalConvexResult_getLocalShapeInfo(btCollisionWorld_LocalConvexResult* obj);
void btCollisionWorld_LocalConvexResult_setHitCollisionObject(btCollisionWorld_LocalConvexResult* obj, const btCollisionObject* value);
void btCollisionWorld_LocalConvexResult_setHitFraction(btCollisionWorld_LocalConvexResult* obj, btScalar value);
void btCollisionWorld_LocalConvexResult_setHitNormalLocal(btCollisionWorld_LocalConvexResult* obj, const btScalar* value);
void btCollisionWorld_LocalConvexResult_setHitPointLocal(btCollisionWorld_LocalConvexResult* obj, const btScalar* value);
void btCollisionWorld_LocalConvexResult_setLocalShapeInfo(btCollisionWorld_LocalConvexResult* obj, btCollisionWorld_LocalShapeInfo* value);
void btCollisionWorld_LocalConvexResult_delete(btCollisionWorld_LocalConvexResult* obj);
btCollisionWorld_LocalRayResult* btCollisionWorld_LocalRayResult_new(const btCollisionObject* collisionObject, btCollisionWorld_LocalShapeInfo* localShapeInfo, const btScalar* hitNormalLocal, btScalar hitFraction);
const btCollisionObject* btCollisionWorld_LocalRayResult_getCollisionObject(btCollisionWorld_LocalRayResult* obj);
btScalar btCollisionWorld_LocalRayResult_getHitFraction(btCollisionWorld_LocalRayResult* obj);
void btCollisionWorld_LocalRayResult_getHitNormalLocal(btCollisionWorld_LocalRayResult* obj, btScalar* value);
btCollisionWorld_LocalShapeInfo* btCollisionWorld_LocalRayResult_getLocalShapeInfo(btCollisionWorld_LocalRayResult* obj);
void btCollisionWorld_LocalRayResult_setCollisionObject(btCollisionWorld_LocalRayResult* obj, const btCollisionObject* value);
void btCollisionWorld_LocalRayResult_setHitFraction(btCollisionWorld_LocalRayResult* obj, btScalar value);
void btCollisionWorld_LocalRayResult_setHitNormalLocal(btCollisionWorld_LocalRayResult* obj, const btScalar* value);
void btCollisionWorld_LocalRayResult_setLocalShapeInfo(btCollisionWorld_LocalRayResult* obj, btCollisionWorld_LocalShapeInfo* value);
void btCollisionWorld_LocalRayResult_delete(btCollisionWorld_LocalRayResult* obj);
btCollisionWorld_LocalShapeInfo* btCollisionWorld_LocalShapeInfo_new();
int btCollisionWorld_LocalShapeInfo_getShapePart(btCollisionWorld_LocalShapeInfo* obj);
int btCollisionWorld_LocalShapeInfo_getTriangleIndex(btCollisionWorld_LocalShapeInfo* obj);
void btCollisionWorld_LocalShapeInfo_setShapePart(btCollisionWorld_LocalShapeInfo* obj, int value);
void btCollisionWorld_LocalShapeInfo_setTriangleIndex(btCollisionWorld_LocalShapeInfo* obj, int value);
void btCollisionWorld_LocalShapeInfo_delete(btCollisionWorld_LocalShapeInfo* obj);
btCollisionWorld_RayResultCallbackWrapper* btCollisionWorld_RayResultCallbackWrapper_new(pRayResultCallback_AddSingleResult addSingleResultCallback, pRayResultCallback_NeedsCollision needsCollisionCallback);
bool btCollisionWorld_RayResultCallbackWrapper_needsCollision(btCollisionWorld_RayResultCallbackWrapper* obj, btBroadphaseProxy* proxy0);
btScalar btCollisionWorld_RayResultCallback_addSingleResult(btCollisionWorld_RayResultCallback* obj, btCollisionWorld_LocalRayResult* rayResult, bool normalInWorldSpace);
btScalar btCollisionWorld_RayResultCallback_getClosestHitFraction(btCollisionWorld_RayResultCallback* obj);
short btCollisionWorld_RayResultCallback_getCollisionFilterGroup(btCollisionWorld_RayResultCallback* obj);
short btCollisionWorld_RayResultCallback_getCollisionFilterMask(btCollisionWorld_RayResultCallback* obj);
const btCollisionObject* btCollisionWorld_RayResultCallback_getCollisionObject(btCollisionWorld_RayResultCallback* obj);
unsigned int btCollisionWorld_RayResultCallback_getFlags(btCollisionWorld_RayResultCallback* obj);
bool btCollisionWorld_RayResultCallback_hasHit(btCollisionWorld_RayResultCallback* obj);
bool btCollisionWorld_RayResultCallback_needsCollision(btCollisionWorld_RayResultCallback* obj, btBroadphaseProxy* proxy0);
void btCollisionWorld_RayResultCallback_setClosestHitFraction(btCollisionWorld_RayResultCallback* obj, btScalar value);
void btCollisionWorld_RayResultCallback_setCollisionFilterGroup(btCollisionWorld_RayResultCallback* obj, short value);
void btCollisionWorld_RayResultCallback_setCollisionFilterMask(btCollisionWorld_RayResultCallback* obj, short value);
void btCollisionWorld_RayResultCallback_setCollisionObject(btCollisionWorld_RayResultCallback* obj, const btCollisionObject* value);
void btCollisionWorld_RayResultCallback_setFlags(btCollisionWorld_RayResultCallback* obj, unsigned int value);
void btCollisionWorld_RayResultCallback_delete(btCollisionWorld_RayResultCallback* obj);
btCollisionWorld* btCollisionWorld_new(btDispatcher* dispatcher, btBroadphaseInterface* broadphasePairCache, btCollisionConfiguration* collisionConfiguration);
void btCollisionWorld_addCollisionObject(btCollisionWorld* obj, btCollisionObject* collisionObject);
void btCollisionWorld_addCollisionObject2(btCollisionWorld* obj, btCollisionObject* collisionObject, short collisionFilterGroup);
void btCollisionWorld_addCollisionObject3(btCollisionWorld* obj, btCollisionObject* collisionObject, short collisionFilterGroup, short collisionFilterMask);
void btCollisionWorld_computeOverlappingPairs(btCollisionWorld* obj);
void btCollisionWorld_contactPairTest(btCollisionWorld* obj, btCollisionObject* colObjA, btCollisionObject* colObjB, btCollisionWorld_ContactResultCallback* resultCallback);
void btCollisionWorld_contactTest(btCollisionWorld* obj, btCollisionObject* colObj, btCollisionWorld_ContactResultCallback* resultCallback);
void btCollisionWorld_convexSweepTest(btCollisionWorld* obj, const btConvexShape* castShape, const btScalar* from, const btScalar* to, btCollisionWorld_ConvexResultCallback* resultCallback);
void btCollisionWorld_convexSweepTest2(btCollisionWorld* obj, const btConvexShape* castShape, const btScalar* from, const btScalar* to, btCollisionWorld_ConvexResultCallback* resultCallback, btScalar allowedCcdPenetration);
void btCollisionWorld_debugDrawObject(btCollisionWorld* obj, const btScalar* worldTransform, const btCollisionShape* shape, const btScalar* color);
void btCollisionWorld_debugDrawWorld(btCollisionWorld* obj);
btBroadphaseInterface* btCollisionWorld_getBroadphase(btCollisionWorld* obj);
const btCollisionObjectArray* btCollisionWorld_getCollisionObjectArray(btCollisionWorld* obj);
btIDebugDraw* btCollisionWorld_getDebugDrawer(btCollisionWorld* obj);
const btDispatcher* btCollisionWorld_getDispatcher(btCollisionWorld* obj);
const btDispatcherInfo* btCollisionWorld_getDispatchInfo(btCollisionWorld* obj);
bool btCollisionWorld_getForceUpdateAllAabbs(btCollisionWorld* obj);
int btCollisionWorld_getNumCollisionObjects(btCollisionWorld* obj);
btOverlappingPairCache* btCollisionWorld_getPairCache(btCollisionWorld* obj);
void btCollisionWorld_objectQuerySingle(const btConvexShape* castShape, const btScalar* rayFromTrans, const btScalar* rayToTrans, btCollisionObject* collisionObject, const btCollisionShape* collisionShape, const btScalar* colObjWorldTransform, btCollisionWorld_ConvexResultCallback* resultCallback, btScalar allowedPenetration);
void btCollisionWorld_objectQuerySingleInternal(const btConvexShape* castShape, const btScalar* convexFromTrans, const btScalar* convexToTrans, const btCollisionObjectWrapper* colObjWrap, btCollisionWorld_ConvexResultCallback* resultCallback, btScalar allowedPenetration);
void btCollisionWorld_performDiscreteCollisionDetection(btCollisionWorld* obj);
void btCollisionWorld_rayTest(btCollisionWorld* obj, const btScalar* rayFromWorld, const btScalar* rayToWorld, btCollisionWorld_RayResultCallback* resultCallback);
void btCollisionWorld_rayTestSingle(const btScalar* rayFromTrans, const btScalar* rayToTrans, btCollisionObject* collisionObject, const btCollisionShape* collisionShape, const btScalar* colObjWorldTransform, btCollisionWorld_RayResultCallback* resultCallback);
void btCollisionWorld_rayTestSingleInternal(const btScalar* rayFromTrans, const btScalar* rayToTrans, const btCollisionObjectWrapper* collisionObjectWrap, btCollisionWorld_RayResultCallback* resultCallback);
void btCollisionWorld_removeCollisionObject(btCollisionWorld* obj, btCollisionObject* collisionObject);
void btCollisionWorld_serialize(btCollisionWorld* obj, btSerializer* serializer);
void btCollisionWorld_setBroadphase(btCollisionWorld* obj, btBroadphaseInterface* pairCache);
void btCollisionWorld_setDebugDrawer(btCollisionWorld* obj, btIDebugDraw* debugDrawer);
void btCollisionWorld_setForceUpdateAllAabbs(btCollisionWorld* obj, bool forceUpdateAllAabbs);
void btCollisionWorld_updateAabbs(btCollisionWorld* obj);
void btCollisionWorld_updateSingleAabb(btCollisionWorld* obj, btCollisionObject* colObj);
void btCollisionWorld_delete(btCollisionWorld* obj);
btCompoundCollisionAlgorithm_CreateFunc* btCompoundCollisionAlgorithm_CreateFunc_new();
btCompoundCollisionAlgorithm_SwappedCreateFunc* btCompoundCollisionAlgorithm_SwappedCreateFunc_new();
btCompoundCollisionAlgorithm* btCompoundCollisionAlgorithm_new(const btCollisionAlgorithmConstructionInfo* ci, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap, bool isSwapped);
btCollisionAlgorithm* btCompoundCollisionAlgorithm_getChildAlgorithm(btCompoundCollisionAlgorithm* obj, int n);
btCompoundCompoundCollisionAlgorithm_CreateFunc* btCompoundCompoundCollisionAlgorithm_CreateFunc_new();
btCompoundCompoundCollisionAlgorithm_SwappedCreateFunc* btCompoundCompoundCollisionAlgorithm_SwappedCreateFunc_new();
btCompoundCompoundCollisionAlgorithm* btCompoundCompoundCollisionAlgorithm_new(const btCollisionAlgorithmConstructionInfo* ci, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap, bool isSwapped);
btCompoundShape* btCompoundFromGImpact_btCreateCompoundFromGimpactShape(const btGImpactMeshShape* gimpactMesh, btScalar depth);
btCompoundShapeChild* btCompoundShapeChild_new();
btScalar btCompoundShapeChild_getChildMargin(btCompoundShapeChild* obj);
btCollisionShape* btCompoundShapeChild_getChildShape(btCompoundShapeChild* obj);
int btCompoundShapeChild_getChildShapeType(btCompoundShapeChild* obj);
btDbvtNode* btCompoundShapeChild_getNode(btCompoundShapeChild* obj);
void btCompoundShapeChild_getTransform(btCompoundShapeChild* obj, btScalar* value);
void btCompoundShapeChild_setChildMargin(btCompoundShapeChild* obj, btScalar value);
void btCompoundShapeChild_setChildShape(btCompoundShapeChild* obj, btCollisionShape* value);
void btCompoundShapeChild_setChildShapeType(btCompoundShapeChild* obj, int value);
void btCompoundShapeChild_setNode(btCompoundShapeChild* obj, btDbvtNode* value);
void btCompoundShapeChild_setTransform(btCompoundShapeChild* obj, const btScalar* value);
void btCompoundShapeChild_delete(btCompoundShapeChild* obj);
btCompoundShape* btCompoundShape_new();
btCompoundShape* btCompoundShape_new2(bool enableDynamicAabbTree);
void btCompoundShape_addChildShape(btCompoundShape* obj, const btScalar* localTransform, btCollisionShape* shape);
void btCompoundShape_calculatePrincipalAxisTransform(btCompoundShape* obj, btScalar* masses, btScalar* principal, btScalar* inertia);
void btCompoundShape_createAabbTreeFromChildren(btCompoundShape* obj);
btCompoundShapeChild* btCompoundShape_getChildList(btCompoundShape* obj);
const btCollisionShape* btCompoundShape_getChildShape(btCompoundShape* obj, int index);
void btCompoundShape_getChildTransform(btCompoundShape* obj, int index, btScalar* value);
btDbvt* btCompoundShape_getDynamicAabbTree(btCompoundShape* obj);
int btCompoundShape_getNumChildShapes(btCompoundShape* obj);
int btCompoundShape_getUpdateRevision(btCompoundShape* obj);
void btCompoundShape_recalculateLocalAabb(btCompoundShape* obj);
void btCompoundShape_removeChildShape(btCompoundShape* obj, btCollisionShape* shape);
void btCompoundShape_removeChildShapeByIndex(btCompoundShape* obj, int childShapeindex);
void btCompoundShape_updateChildTransform(btCompoundShape* obj, int childIndex, const btScalar* newChildTransform);
void btCompoundShape_updateChildTransform2(btCompoundShape* obj, int childIndex, const btScalar* newChildTransform, bool shouldRecalculateLocalAabb);
void btConcaveShape_processAllTriangles(btConcaveShape* obj, btTriangleCallback* callback, const btScalar* aabbMin, const btScalar* aabbMax);
btConeShape* btConeShape_new(btScalar radius, btScalar height);
int btConeShape_getConeUpIndex(btConeShape* obj);
btScalar btConeShape_getHeight(btConeShape* obj);
btScalar btConeShape_getRadius(btConeShape* obj);
void btConeShape_setConeUpIndex(btConeShape* obj, int upIndex);
btConeShapeX* btConeShapeX_new(btScalar radius, btScalar height);
btConeShapeZ* btConeShapeZ_new(btScalar radius, btScalar height);
btConeTwistConstraint* btConeTwistConstraint_new(btRigidBody* rbA, btRigidBody* rbB, const btScalar* rbAFrame, const btScalar* rbBFrame);
btConeTwistConstraint* btConeTwistConstraint_new2(btRigidBody* rbA, const btScalar* rbAFrame);
void btConeTwistConstraint_calcAngleInfo(btConeTwistConstraint* obj);
void btConeTwistConstraint_calcAngleInfo2(btConeTwistConstraint* obj, const btScalar* transA, const btScalar* transB, const btScalar* invInertiaWorldA, const btScalar* invInertiaWorldB);
void btConeTwistConstraint_enableMotor(btConeTwistConstraint* obj, bool b);
void btConeTwistConstraint_getAFrame(btConeTwistConstraint* obj, btScalar* value);
void btConeTwistConstraint_getBFrame(btConeTwistConstraint* obj, btScalar* value);
btScalar btConeTwistConstraint_getFixThresh(btConeTwistConstraint* obj);
void btConeTwistConstraint_getFrameOffsetA(btConeTwistConstraint* obj, btScalar* value);
void btConeTwistConstraint_getFrameOffsetB(btConeTwistConstraint* obj, btScalar* value);
void btConeTwistConstraint_getInfo1NonVirtual(btConeTwistConstraint* obj, btTypedConstraint_btConstraintInfo1* info);
void btConeTwistConstraint_getInfo2NonVirtual(btConeTwistConstraint* obj, btTypedConstraint_btConstraintInfo2* info, const btScalar* transA, const btScalar* transB, const btScalar* invInertiaWorldA, const btScalar* invInertiaWorldB);
void btConeTwistConstraint_GetPointForAngle(btConeTwistConstraint* obj, btScalar fAngleInRadians, btScalar fLength, btScalar* value);
int btConeTwistConstraint_getSolveSwingLimit(btConeTwistConstraint* obj);
int btConeTwistConstraint_getSolveTwistLimit(btConeTwistConstraint* obj);
btScalar btConeTwistConstraint_getSwingSpan1(btConeTwistConstraint* obj);
btScalar btConeTwistConstraint_getSwingSpan2(btConeTwistConstraint* obj);
btScalar btConeTwistConstraint_getTwistAngle(btConeTwistConstraint* obj);
btScalar btConeTwistConstraint_getTwistLimitSign(btConeTwistConstraint* obj);
btScalar btConeTwistConstraint_getTwistSpan(btConeTwistConstraint* obj);
bool btConeTwistConstraint_isPastSwingLimit(btConeTwistConstraint* obj);
void btConeTwistConstraint_setAngularOnly(btConeTwistConstraint* obj, bool angularOnly);
void btConeTwistConstraint_setDamping(btConeTwistConstraint* obj, btScalar damping);
void btConeTwistConstraint_setFixThresh(btConeTwistConstraint* obj, btScalar fixThresh);
void btConeTwistConstraint_setFrames(btConeTwistConstraint* obj, const btScalar* frameA, const btScalar* frameB);
void btConeTwistConstraint_setLimit(btConeTwistConstraint* obj, btScalar _swingSpan1, btScalar _swingSpan2, btScalar _twistSpan);
void btConeTwistConstraint_setLimit2(btConeTwistConstraint* obj, btScalar _swingSpan1, btScalar _swingSpan2, btScalar _twistSpan, btScalar _softness);
void btConeTwistConstraint_setLimit3(btConeTwistConstraint* obj, btScalar _swingSpan1, btScalar _swingSpan2, btScalar _twistSpan, btScalar _softness, btScalar _biasFactor);
void btConeTwistConstraint_setLimit4(btConeTwistConstraint* obj, btScalar _swingSpan1, btScalar _swingSpan2, btScalar _twistSpan, btScalar _softness, btScalar _biasFactor, btScalar _relaxationFactor);
void btConeTwistConstraint_setLimit5(btConeTwistConstraint* obj, int limitIndex, btScalar limitValue);
void btConeTwistConstraint_setMaxMotorImpulse(btConeTwistConstraint* obj, btScalar maxMotorImpulse);
void btConeTwistConstraint_setMaxMotorImpulseNormalized(btConeTwistConstraint* obj, btScalar maxMotorImpulse);
void btConeTwistConstraint_setMotorTarget(btConeTwistConstraint* obj, const btScalar* q);
void btConeTwistConstraint_setMotorTargetInConstraintSpace(btConeTwistConstraint* obj, const btScalar* q);
void btConeTwistConstraint_updateRHS(btConeTwistConstraint* obj, btScalar timeStep);
void btConstraintSolver_allSolved(btConstraintSolver* obj, const btContactSolverInfo* __unnamed0, btIDebugDraw* __unnamed1);
btConstraintSolverType btConstraintSolver_getSolverType(btConstraintSolver* obj);
void btConstraintSolver_prepareSolve(btConstraintSolver* obj, int __unnamed0, int __unnamed1);
void btConstraintSolver_reset(btConstraintSolver* obj);
void btConstraintSolver_delete(btConstraintSolver* obj);
const btPersistentManifold* btContactConstraint_getContactManifold(btContactConstraint* obj);
void btContactConstraint_setContactManifold(btContactConstraint* obj, btPersistentManifold* contactManifold);
btContactSolverInfoData* btContactSolverInfoData_new();
btScalar btContactSolverInfoData_getDamping(btContactSolverInfoData* obj);
btScalar btContactSolverInfoData_getErp(btContactSolverInfoData* obj);
btScalar btContactSolverInfoData_getErp2(btContactSolverInfoData* obj);
btScalar btContactSolverInfoData_getFriction(btContactSolverInfoData* obj);
btScalar btContactSolverInfoData_getGlobalCfm(btContactSolverInfoData* obj);
btScalar btContactSolverInfoData_getLinearSlop(btContactSolverInfoData* obj);
btScalar btContactSolverInfoData_getMaxErrorReduction(btContactSolverInfoData* obj);
btScalar btContactSolverInfoData_getMaxGyroscopicForce(btContactSolverInfoData* obj);
int btContactSolverInfoData_getMinimumSolverBatchSize(btContactSolverInfoData* obj);
int btContactSolverInfoData_getNumIterations(btContactSolverInfoData* obj);
int btContactSolverInfoData_getRestingContactRestitutionThreshold(btContactSolverInfoData* obj);
btScalar btContactSolverInfoData_getRestitution(btContactSolverInfoData* obj);
btScalar btContactSolverInfoData_getSingleAxisRollingFrictionThreshold(btContactSolverInfoData* obj);
int btContactSolverInfoData_getSolverMode(btContactSolverInfoData* obj);
btScalar btContactSolverInfoData_getSor(btContactSolverInfoData* obj);
int btContactSolverInfoData_getSplitImpulse(btContactSolverInfoData* obj);
btScalar btContactSolverInfoData_getSplitImpulsePenetrationThreshold(btContactSolverInfoData* obj);
btScalar btContactSolverInfoData_getSplitImpulseTurnErp(btContactSolverInfoData* obj);
btScalar btContactSolverInfoData_getTau(btContactSolverInfoData* obj);
btScalar btContactSolverInfoData_getTimeStep(btContactSolverInfoData* obj);
btScalar btContactSolverInfoData_getWarmstartingFactor(btContactSolverInfoData* obj);
void btContactSolverInfoData_setDamping(btContactSolverInfoData* obj, btScalar value);
void btContactSolverInfoData_setErp(btContactSolverInfoData* obj, btScalar value);
void btContactSolverInfoData_setErp2(btContactSolverInfoData* obj, btScalar value);
void btContactSolverInfoData_setFriction(btContactSolverInfoData* obj, btScalar value);
void btContactSolverInfoData_setGlobalCfm(btContactSolverInfoData* obj, btScalar value);
void btContactSolverInfoData_setLinearSlop(btContactSolverInfoData* obj, btScalar value);
void btContactSolverInfoData_setMaxErrorReduction(btContactSolverInfoData* obj, btScalar value);
void btContactSolverInfoData_setMaxGyroscopicForce(btContactSolverInfoData* obj, btScalar value);
void btContactSolverInfoData_setMinimumSolverBatchSize(btContactSolverInfoData* obj, int value);
void btContactSolverInfoData_setNumIterations(btContactSolverInfoData* obj, int value);
void btContactSolverInfoData_setRestingContactRestitutionThreshold(btContactSolverInfoData* obj, int value);
void btContactSolverInfoData_setRestitution(btContactSolverInfoData* obj, btScalar value);
void btContactSolverInfoData_setSingleAxisRollingFrictionThreshold(btContactSolverInfoData* obj, btScalar value);
void btContactSolverInfoData_setSolverMode(btContactSolverInfoData* obj, int value);
void btContactSolverInfoData_setSor(btContactSolverInfoData* obj, btScalar value);
void btContactSolverInfoData_setSplitImpulse(btContactSolverInfoData* obj, int value);
void btContactSolverInfoData_setSplitImpulsePenetrationThreshold(btContactSolverInfoData* obj, btScalar value);
void btContactSolverInfoData_setSplitImpulseTurnErp(btContactSolverInfoData* obj, btScalar value);
void btContactSolverInfoData_setTau(btContactSolverInfoData* obj, btScalar value);
void btContactSolverInfoData_setTimeStep(btContactSolverInfoData* obj, btScalar value);
void btContactSolverInfoData_setWarmstartingFactor(btContactSolverInfoData* obj, btScalar value);
void btContactSolverInfoData_delete(btContactSolverInfoData* obj);
btContactSolverInfo* btContactSolverInfo_new();
btContinuousConvexCollision* btContinuousConvexCollision_new(const btConvexShape* shapeA, const btConvexShape* shapeB, btVoronoiSimplexSolver* simplexSolver, btConvexPenetrationDepthSolver* penetrationDepthSolver);
btContinuousConvexCollision* btContinuousConvexCollision_new2(const btConvexShape* shapeA, const btStaticPlaneShape* plane);
btConvex2dConvex2dAlgorithm_CreateFunc* btConvex2dConvex2dAlgorithm_CreateFunc_new(btVoronoiSimplexSolver* simplexSolver, btConvexPenetrationDepthSolver* pdSolver);
int btConvex2dConvex2dAlgorithm_CreateFunc_getMinimumPointsPerturbationThreshold(btConvex2dConvex2dAlgorithm_CreateFunc* obj);
int btConvex2dConvex2dAlgorithm_CreateFunc_getNumPerturbationIterations(btConvex2dConvex2dAlgorithm_CreateFunc* obj);
btConvexPenetrationDepthSolver* btConvex2dConvex2dAlgorithm_CreateFunc_getPdSolver(btConvex2dConvex2dAlgorithm_CreateFunc* obj);
btVoronoiSimplexSolver* btConvex2dConvex2dAlgorithm_CreateFunc_getSimplexSolver(btConvex2dConvex2dAlgorithm_CreateFunc* obj);
void btConvex2dConvex2dAlgorithm_CreateFunc_setMinimumPointsPerturbationThreshold(btConvex2dConvex2dAlgorithm_CreateFunc* obj, int value);
void btConvex2dConvex2dAlgorithm_CreateFunc_setNumPerturbationIterations(btConvex2dConvex2dAlgorithm_CreateFunc* obj, int value);
void btConvex2dConvex2dAlgorithm_CreateFunc_setPdSolver(btConvex2dConvex2dAlgorithm_CreateFunc* obj, btConvexPenetrationDepthSolver* value);
void btConvex2dConvex2dAlgorithm_CreateFunc_setSimplexSolver(btConvex2dConvex2dAlgorithm_CreateFunc* obj, btVoronoiSimplexSolver* value);
btConvex2dConvex2dAlgorithm* btConvex2dConvex2dAlgorithm_new(btPersistentManifold* mf, const btCollisionAlgorithmConstructionInfo* ci, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap, btVoronoiSimplexSolver* simplexSolver, btConvexPenetrationDepthSolver* pdSolver, int numPerturbationIterations, int minimumPointsPerturbationThreshold);
const btPersistentManifold* btConvex2dConvex2dAlgorithm_getManifold(btConvex2dConvex2dAlgorithm* obj);
void btConvex2dConvex2dAlgorithm_setLowLevelOfDetail(btConvex2dConvex2dAlgorithm* obj, bool useLowLevel);
btConvex2dShape* btConvex2dShape_new(btConvexShape* convexChildShape);
const btConvexShape* btConvex2dShape_getChildShape(btConvex2dShape* obj);
btConvexCast_CastResult* btConvexCast_CastResult_new();
void btConvexCast_CastResult_DebugDraw(btConvexCast_CastResult* obj, btScalar fraction);
void btConvexCast_CastResult_drawCoordSystem(btConvexCast_CastResult* obj, const btScalar* trans);
btScalar btConvexCast_CastResult_getAllowedPenetration(btConvexCast_CastResult* obj);
btIDebugDraw* btConvexCast_CastResult_getDebugDrawer(btConvexCast_CastResult* obj);
btScalar btConvexCast_CastResult_getFraction(btConvexCast_CastResult* obj);
void btConvexCast_CastResult_getHitPoint(btConvexCast_CastResult* obj, btScalar* value);
void btConvexCast_CastResult_getHitTransformA(btConvexCast_CastResult* obj, btScalar* value);
void btConvexCast_CastResult_getHitTransformB(btConvexCast_CastResult* obj, btScalar* value);
void btConvexCast_CastResult_getNormal(btConvexCast_CastResult* obj, btScalar* value);
void btConvexCast_CastResult_reportFailure(btConvexCast_CastResult* obj, int errNo, int numIterations);
void btConvexCast_CastResult_setAllowedPenetration(btConvexCast_CastResult* obj, btScalar value);
void btConvexCast_CastResult_setDebugDrawer(btConvexCast_CastResult* obj, btIDebugDraw* value);
void btConvexCast_CastResult_setFraction(btConvexCast_CastResult* obj, btScalar value);
void btConvexCast_CastResult_setHitPoint(btConvexCast_CastResult* obj, const btScalar* value);
void btConvexCast_CastResult_setHitTransformA(btConvexCast_CastResult* obj, const btScalar* value);
void btConvexCast_CastResult_setHitTransformB(btConvexCast_CastResult* obj, const btScalar* value);
void btConvexCast_CastResult_setNormal(btConvexCast_CastResult* obj, const btScalar* value);
void btConvexCast_CastResult_delete(btConvexCast_CastResult* obj);
bool btConvexCast_calcTimeOfImpact(btConvexCast* obj, const btScalar* fromA, const btScalar* toA, const btScalar* fromB, const btScalar* toB, btConvexCast_CastResult* result);
void btConvexCast_delete(btConvexCast* obj);
btConvexTriangleCallback* btConvexTriangleCallback_new(btDispatcher* dispatcher, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap, bool isSwapped);
void btConvexTriangleCallback_clearCache(btConvexTriangleCallback* obj);
void btConvexTriangleCallback_clearWrapperData(btConvexTriangleCallback* obj);
void btConvexTriangleCallback_getAabbMax(btConvexTriangleCallback* obj, btScalar* value);
void btConvexTriangleCallback_getAabbMin(btConvexTriangleCallback* obj, btScalar* value);
btPersistentManifold* btConvexTriangleCallback_getManifoldPtr(btConvexTriangleCallback* obj);
int btConvexTriangleCallback_getTriangleCount(btConvexTriangleCallback* obj);
void btConvexTriangleCallback_setManifoldPtr(btConvexTriangleCallback* obj, btPersistentManifold* value);
void btConvexTriangleCallback_setTimeStepAndCounters(btConvexTriangleCallback* obj, btScalar collisionMarginTriangle, const btDispatcherInfo* dispatchInfo, const btCollisionObjectWrapper* convexBodyWrap, const btCollisionObjectWrapper* triBodyWrap, btManifoldResult* resultOut);
void btConvexTriangleCallback_setTriangleCount(btConvexTriangleCallback* obj, int value);
btConvexConcaveCollisionAlgorithm_CreateFunc* btConvexConcaveCollisionAlgorithm_CreateFunc_new();
btConvexConcaveCollisionAlgorithm_SwappedCreateFunc* btConvexConcaveCollisionAlgorithm_SwappedCreateFunc_new();
btConvexConcaveCollisionAlgorithm* btConvexConcaveCollisionAlgorithm_new(const btCollisionAlgorithmConstructionInfo* ci, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap, bool isSwapped);
void btConvexConcaveCollisionAlgorithm_clearCache(btConvexConcaveCollisionAlgorithm* obj);
btConvexConvexAlgorithm_CreateFunc* btConvexConvexAlgorithm_CreateFunc_new(btVoronoiSimplexSolver* simplexSolver, btConvexPenetrationDepthSolver* pdSolver);
int btConvexConvexAlgorithm_CreateFunc_getMinimumPointsPerturbationThreshold(btConvexConvexAlgorithm_CreateFunc* obj);
int btConvexConvexAlgorithm_CreateFunc_getNumPerturbationIterations(btConvexConvexAlgorithm_CreateFunc* obj);
btConvexPenetrationDepthSolver* btConvexConvexAlgorithm_CreateFunc_getPdSolver(btConvexConvexAlgorithm_CreateFunc* obj);
btVoronoiSimplexSolver* btConvexConvexAlgorithm_CreateFunc_getSimplexSolver(btConvexConvexAlgorithm_CreateFunc* obj);
void btConvexConvexAlgorithm_CreateFunc_setMinimumPointsPerturbationThreshold(btConvexConvexAlgorithm_CreateFunc* obj, int value);
void btConvexConvexAlgorithm_CreateFunc_setNumPerturbationIterations(btConvexConvexAlgorithm_CreateFunc* obj, int value);
void btConvexConvexAlgorithm_CreateFunc_setPdSolver(btConvexConvexAlgorithm_CreateFunc* obj, btConvexPenetrationDepthSolver* value);
void btConvexConvexAlgorithm_CreateFunc_setSimplexSolver(btConvexConvexAlgorithm_CreateFunc* obj, btVoronoiSimplexSolver* value);
btConvexConvexAlgorithm* btConvexConvexAlgorithm_new(btPersistentManifold* mf, const btCollisionAlgorithmConstructionInfo* ci, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap, btVoronoiSimplexSolver* simplexSolver, btConvexPenetrationDepthSolver* pdSolver, int numPerturbationIterations, int minimumPointsPerturbationThreshold);
const btPersistentManifold* btConvexConvexAlgorithm_getManifold(btConvexConvexAlgorithm* obj);
void btConvexConvexAlgorithm_setLowLevelOfDetail(btConvexConvexAlgorithm* obj, bool useLowLevel);
btConvexHullShape* btConvexHullShape_new();
btConvexHullShape* btConvexHullShape_new2(const btScalar* points);
btConvexHullShape* btConvexHullShape_new3(const btScalar* points, int numPoints);
btConvexHullShape* btConvexHullShape_new4(const btScalar* points, int numPoints, int stride);
void btConvexHullShape_addPoint(btConvexHullShape* obj, const btScalar* point);
void btConvexHullShape_addPoint2(btConvexHullShape* obj, const btScalar* point, bool recalculateLocalAabb);
int btConvexHullShape_getNumPoints(btConvexHullShape* obj);
const btVector3* btConvexHullShape_getPoints(btConvexHullShape* obj);
void btConvexHullShape_getScaledPoint(btConvexHullShape* obj, int i, btScalar* value);
const btVector3* btConvexHullShape_getUnscaledPoints(btConvexHullShape* obj);
void btConvexHullShape_project(btConvexHullShape* obj, const btScalar* trans, const btScalar* dir, btScalar* minProj, btScalar* maxProj, btScalar* witnesPtMin, btScalar* witnesPtMax);
btConvexInternalShape* btConvexInternalShape_new();
void btConvexInternalShape_getImplicitShapeDimensions(btConvexInternalShape* obj, btScalar* dimensions);
void btConvexInternalShape_getLocalScalingNV(btConvexInternalShape* obj, btScalar* value);
btScalar btConvexInternalShape_getMarginNV(btConvexInternalShape* obj);
void btConvexInternalShape_setImplicitShapeDimensions(btConvexInternalShape* obj, const btScalar* dimensions);
void btConvexInternalShape_setSafeMargin(btConvexInternalShape* obj, btScalar minDimension);
void btConvexInternalShape_setSafeMargin2(btConvexInternalShape* obj, btScalar minDimension, btScalar defaultMarginMultiplier);
void btConvexInternalShape_setSafeMargin3(btConvexInternalShape* obj, const btScalar* halfExtents);
void btConvexInternalShape_setSafeMargin4(btConvexInternalShape* obj, const btScalar* halfExtents, btScalar defaultMarginMultiplier);
btConvexInternalAabbCachingShape* btConvexInternalAabbCachingShape_new();
void btConvexInternalAabbCachingShape_recalcLocalAabb(btConvexInternalAabbCachingShape* obj);
bool btConvexPenetrationDepthSolver_calcPenDepth(btConvexPenetrationDepthSolver* obj, btVoronoiSimplexSolver* simplexSolver, const btConvexShape* convexA, const btConvexShape* convexB, const btScalar* transA, const btScalar* transB, btScalar* v, btScalar* pa, btScalar* pb, btIDebugDraw* debugDraw);
void btConvexPenetrationDepthSolver_delete(btConvexPenetrationDepthSolver* obj);
btConvexPlaneCollisionAlgorithm_CreateFunc* btConvexPlaneCollisionAlgorithm_CreateFunc_new();
int btConvexPlaneCollisionAlgorithm_CreateFunc_getMinimumPointsPerturbationThreshold(btConvexPlaneCollisionAlgorithm_CreateFunc* obj);
int btConvexPlaneCollisionAlgorithm_CreateFunc_getNumPerturbationIterations(btConvexPlaneCollisionAlgorithm_CreateFunc* obj);
void btConvexPlaneCollisionAlgorithm_CreateFunc_setMinimumPointsPerturbationThreshold(btConvexPlaneCollisionAlgorithm_CreateFunc* obj, int value);
void btConvexPlaneCollisionAlgorithm_CreateFunc_setNumPerturbationIterations(btConvexPlaneCollisionAlgorithm_CreateFunc* obj, int value);
btConvexPlaneCollisionAlgorithm* btConvexPlaneCollisionAlgorithm_new(btPersistentManifold* mf, const btCollisionAlgorithmConstructionInfo* ci, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap, bool isSwapped, int numPerturbationIterations, int minimumPointsPerturbationThreshold);
void btConvexPlaneCollisionAlgorithm_collideSingleContact(btConvexPlaneCollisionAlgorithm* obj, const btScalar* perturbeRot, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap, const btDispatcherInfo* dispatchInfo, btManifoldResult* resultOut);
btConvexPointCloudShape* btConvexPointCloudShape_new();
btConvexPointCloudShape* btConvexPointCloudShape_new2(btVector3* points, int numPoints, const btScalar* localScaling);
btConvexPointCloudShape* btConvexPointCloudShape_new3(btVector3* points, int numPoints, const btScalar* localScaling, bool computeAabb);
int btConvexPointCloudShape_getNumPoints(btConvexPointCloudShape* obj);
void btConvexPointCloudShape_getScaledPoint(btConvexPointCloudShape* obj, int index, btScalar* value);
btVector3* btConvexPointCloudShape_getUnscaledPoints(btConvexPointCloudShape* obj);
void btConvexPointCloudShape_setPoints(btConvexPointCloudShape* obj, btVector3* points, int numPoints);
void btConvexPointCloudShape_setPoints2(btConvexPointCloudShape* obj, btVector3* points, int numPoints, bool computeAabb);
void btConvexPointCloudShape_setPoints3(btConvexPointCloudShape* obj, btVector3* points, int numPoints, bool computeAabb, const btScalar* localScaling);
btFace* btFace_new();
btAlignedIntArray* btFace_getIndices(btFace* obj);
btScalar* btFace_getPlane(btFace* obj);
void btFace_delete(btFace* obj);
btConvexPolyhedron* btConvexPolyhedron_new();
void btConvexPolyhedron_getExtents(btConvexPolyhedron* obj, btScalar* value);
btAlignedFaceArray* btConvexPolyhedron_getFaces(btConvexPolyhedron* obj);
void btConvexPolyhedron_getLocalCenter(btConvexPolyhedron* obj, btScalar* value);
void btConvexPolyhedron_getMC(btConvexPolyhedron* obj, btScalar* value);
void btConvexPolyhedron_getME(btConvexPolyhedron* obj, btScalar* value);
btScalar btConvexPolyhedron_getRadius(btConvexPolyhedron* obj);
btAlignedVector3Array* btConvexPolyhedron_getUniqueEdges(btConvexPolyhedron* obj);
btAlignedVector3Array* btConvexPolyhedron_getVertices(btConvexPolyhedron* obj);
void btConvexPolyhedron_initialize(btConvexPolyhedron* obj);
void btConvexPolyhedron_project(btConvexPolyhedron* obj, const btScalar* trans, const btScalar* dir, btScalar* minProj, btScalar* maxProj, btScalar* witnesPtMin, btScalar* witnesPtMax);
void btConvexPolyhedron_setExtents(btConvexPolyhedron* obj, const btScalar* value);
void btConvexPolyhedron_setLocalCenter(btConvexPolyhedron* obj, const btScalar* value);
void btConvexPolyhedron_setMC(btConvexPolyhedron* obj, const btScalar* value);
void btConvexPolyhedron_setME(btConvexPolyhedron* obj, const btScalar* value);
void btConvexPolyhedron_setRadius(btConvexPolyhedron* obj, btScalar value);
bool btConvexPolyhedron_testContainment(btConvexPolyhedron* obj);
void btConvexPolyhedron_delete(btConvexPolyhedron* obj);
void btConvexShape_batchedUnitVectorGetSupportingVertexWithoutMargin(btConvexShape* obj, const btVector3* vectors, btVector3* supportVerticesOut, int numVectors);
void btConvexShape_getAabbNonVirtual(btConvexShape* obj, const btScalar* t, btScalar* aabbMin, btScalar* aabbMax);
void btConvexShape_getAabbSlow(btConvexShape* obj, const btScalar* t, btScalar* aabbMin, btScalar* aabbMax);
btScalar btConvexShape_getMarginNonVirtual(btConvexShape* obj);
int btConvexShape_getNumPreferredPenetrationDirections(btConvexShape* obj);
void btConvexShape_getPreferredPenetrationDirection(btConvexShape* obj, int index, btScalar* penetrationVector);
void btConvexShape_localGetSupportingVertex(btConvexShape* obj, const btScalar* vec, btScalar* value);
void btConvexShape_localGetSupportingVertexWithoutMargin(btConvexShape* obj, const btScalar* vec, btScalar* value);
void btConvexShape_localGetSupportVertexNonVirtual(btConvexShape* obj, const btScalar* vec, btScalar* value);
void btConvexShape_localGetSupportVertexWithoutMarginNonVirtual(btConvexShape* obj, const btScalar* vec, btScalar* value);
void btConvexShape_project(btConvexShape* obj, const btScalar* trans, const btScalar* dir, btScalar* min, btScalar* max);
btConvexTriangleMeshShape* btConvexTriangleMeshShape_new(btStridingMeshInterface* meshInterface);
btConvexTriangleMeshShape* btConvexTriangleMeshShape_new2(btStridingMeshInterface* meshInterface, bool calcAabb);
void btConvexTriangleMeshShape_calculatePrincipalAxisTransform(btConvexTriangleMeshShape* obj, btScalar* principal, btScalar* inertia, btScalar* volume);
const btStridingMeshInterface* btConvexTriangleMeshShape_getMeshInterface(btConvexTriangleMeshShape* obj);
btCylinderShape* btCylinderShape_new(const btScalar* halfExtents);
btCylinderShape* btCylinderShape_new2(btScalar halfExtentX, btScalar halfExtentY, btScalar halfExtentZ);
void btCylinderShape_getHalfExtentsWithMargin(btCylinderShape* obj, btScalar* value);
void btCylinderShape_getHalfExtentsWithoutMargin(btCylinderShape* obj, btScalar* value);
btScalar btCylinderShape_getRadius(btCylinderShape* obj);
int btCylinderShape_getUpAxis(btCylinderShape* obj);
btCylinderShapeX* btCylinderShapeX_new(const btScalar* halfExtents);
btCylinderShapeX* btCylinderShapeX_new2(btScalar halfExtentX, btScalar halfExtentY, btScalar halfExtentZ);
btCylinderShapeZ* btCylinderShapeZ_new(const btScalar* halfExtents);
btCylinderShapeZ* btCylinderShapeZ_new2(btScalar halfExtentX, btScalar halfExtentY, btScalar halfExtentZ);
btDantzigSolver* btDantzigSolver_new();
btDbvtProxy* btDbvtProxy_new(const btScalar* aabbMin, const btScalar* aabbMax, void* userPtr, short collisionFilterGroup, short collisionFilterMask);
btDbvtNode* btDbvtProxy_getLeaf(btDbvtProxy* obj);
btDbvtProxy** btDbvtProxy_getLinks(btDbvtProxy* obj);
int btDbvtProxy_getStage(btDbvtProxy* obj);
void btDbvtProxy_setLeaf(btDbvtProxy* obj, btDbvtNode* value);
void btDbvtProxy_setStage(btDbvtProxy* obj, int value);
btDbvtBroadphase* btDbvtBroadphase_new();
btDbvtBroadphase* btDbvtBroadphase_new2(btOverlappingPairCache* paircache);
void btDbvtBroadphase_benchmark(btBroadphaseInterface* __unnamed0);
void btDbvtBroadphase_collide(btDbvtBroadphase* obj, btDispatcher* dispatcher);
int btDbvtBroadphase_getCid(btDbvtBroadphase* obj);
int btDbvtBroadphase_getCupdates(btDbvtBroadphase* obj);
bool btDbvtBroadphase_getDeferedcollide(btDbvtBroadphase* obj);
int btDbvtBroadphase_getDupdates(btDbvtBroadphase* obj);
int btDbvtBroadphase_getFixedleft(btDbvtBroadphase* obj);
int btDbvtBroadphase_getFupdates(btDbvtBroadphase* obj);
int btDbvtBroadphase_getGid(btDbvtBroadphase* obj);
bool btDbvtBroadphase_getNeedcleanup(btDbvtBroadphase* obj);
int btDbvtBroadphase_getNewpairs(btDbvtBroadphase* obj);
btOverlappingPairCache* btDbvtBroadphase_getPaircache(btDbvtBroadphase* obj);
int btDbvtBroadphase_getPid(btDbvtBroadphase* obj);
btScalar btDbvtBroadphase_getPrediction(btDbvtBroadphase* obj);
bool btDbvtBroadphase_getReleasepaircache(btDbvtBroadphase* obj);
btDbvt* btDbvtBroadphase_getSets(btDbvtBroadphase* obj);
int btDbvtBroadphase_getStageCurrent(btDbvtBroadphase* obj);
btDbvtProxy** btDbvtBroadphase_getStageRoots(btDbvtBroadphase* obj);
unsigned int btDbvtBroadphase_getUpdates_call(btDbvtBroadphase* obj);
unsigned int btDbvtBroadphase_getUpdates_done(btDbvtBroadphase* obj);
btScalar btDbvtBroadphase_getUpdates_ratio(btDbvtBroadphase* obj);
btScalar btDbvtBroadphase_getVelocityPrediction(btDbvtBroadphase* obj);
void btDbvtBroadphase_optimize(btDbvtBroadphase* obj);
void btDbvtBroadphase_performDeferredRemoval(btDbvtBroadphase* obj, btDispatcher* dispatcher);
void btDbvtBroadphase_setAabbForceUpdate(btDbvtBroadphase* obj, btBroadphaseProxy* absproxy, const btScalar* aabbMin, const btScalar* aabbMax, btDispatcher* __unnamed3);
void btDbvtBroadphase_setCid(btDbvtBroadphase* obj, int value);
void btDbvtBroadphase_setCupdates(btDbvtBroadphase* obj, int value);
void btDbvtBroadphase_setDeferedcollide(btDbvtBroadphase* obj, bool value);
void btDbvtBroadphase_setDupdates(btDbvtBroadphase* obj, int value);
void btDbvtBroadphase_setFixedleft(btDbvtBroadphase* obj, int value);
void btDbvtBroadphase_setFupdates(btDbvtBroadphase* obj, int value);
void btDbvtBroadphase_setGid(btDbvtBroadphase* obj, int value);
void btDbvtBroadphase_setNeedcleanup(btDbvtBroadphase* obj, bool value);
void btDbvtBroadphase_setNewpairs(btDbvtBroadphase* obj, int value);
void btDbvtBroadphase_setPaircache(btDbvtBroadphase* obj, btOverlappingPairCache* value);
void btDbvtBroadphase_setPid(btDbvtBroadphase* obj, int value);
void btDbvtBroadphase_setPrediction(btDbvtBroadphase* obj, btScalar value);
void btDbvtBroadphase_setReleasepaircache(btDbvtBroadphase* obj, bool value);
void btDbvtBroadphase_setStageCurrent(btDbvtBroadphase* obj, int value);
void btDbvtBroadphase_setUpdates_call(btDbvtBroadphase* obj, unsigned int value);
void btDbvtBroadphase_setUpdates_done(btDbvtBroadphase* obj, unsigned int value);
void btDbvtBroadphase_setUpdates_ratio(btDbvtBroadphase* obj, btScalar value);
void btDbvtBroadphase_setVelocityPrediction(btDbvtBroadphase* obj, btScalar prediction);
btDbvtAabbMm* btDbvtAabbMm_new();
void btDbvtAabbMm_Center(btDbvtAabbMm* obj, btScalar* value);
int btDbvtAabbMm_Classify(btDbvtAabbMm* obj, const btScalar* n, btScalar o, int s);
bool btDbvtAabbMm_Contain(btDbvtAabbMm* obj, const btDbvtAabbMm* a);
void btDbvtAabbMm_Expand(btDbvtAabbMm* obj, const btScalar* e);
void btDbvtAabbMm_Extents(btDbvtAabbMm* obj, btScalar* value);
btDbvtAabbMm* btDbvtAabbMm_FromCE(const btScalar* c, const btScalar* e);
btDbvtAabbMm* btDbvtAabbMm_FromCR(const btScalar* c, btScalar r);
btDbvtAabbMm* btDbvtAabbMm_FromMM(const btScalar* mi, const btScalar* mx);
btDbvtAabbMm* btDbvtAabbMm_FromPoints(const btVector3** ppts, int n);
btDbvtAabbMm* btDbvtAabbMm_FromPoints2(const btVector3* pts, int n);
void btDbvtAabbMm_Lengths(btDbvtAabbMm* obj, btScalar* value);
void btDbvtAabbMm_Maxs(btDbvtAabbMm* obj, btScalar* value);
void btDbvtAabbMm_Mins(btDbvtAabbMm* obj, btScalar* value);
btScalar btDbvtAabbMm_ProjectMinimum(btDbvtAabbMm* obj, const btScalar* v, unsigned int signs);
void btDbvtAabbMm_SignedExpand(btDbvtAabbMm* obj, const btScalar* e);
void btDbvtAabbMm_tMaxs(btDbvtAabbMm* obj, btScalar* value);
void btDbvtAabbMm_tMins(btDbvtAabbMm* obj, btScalar* value);
void btDbvtAabbMm_delete(btDbvtAabbMm* obj);
btDbvtNode* btDbvtNode_new();
btDbvtNode** btDbvtNode_getChilds(btDbvtNode* obj);
void* btDbvtNode_getData(btDbvtNode* obj);
int btDbvtNode_getDataAsInt(btDbvtNode* obj);
btDbvtNode* btDbvtNode_getParent(btDbvtNode* obj);
btDbvtVolume* btDbvtNode_getVolume(btDbvtNode* obj);
bool btDbvtNode_isinternal(btDbvtNode* obj);
bool btDbvtNode_isleaf(btDbvtNode* obj);
void btDbvtNode_setData(btDbvtNode* obj, void* value);
void btDbvtNode_setDataAsInt(btDbvtNode* obj, int value);
void btDbvtNode_setParent(btDbvtNode* obj, btDbvtNode* value);
void btDbvtNode_delete(btDbvtNode* obj);
btDbvt_IClone* btDbvt_IClone_new();
void btDbvt_IClone_CloneLeaf(btDbvt_IClone* obj, btDbvtNode* __unnamed0);
void btDbvt_IClone_delete(btDbvt_IClone* obj);
btDbvt_ICollide* btDbvt_ICollide_new();
bool btDbvt_ICollide_AllLeaves(btDbvt_ICollide* obj, const btDbvtNode* __unnamed0);
bool btDbvt_ICollide_Descent(btDbvt_ICollide* obj, const btDbvtNode* __unnamed0);
void btDbvt_ICollide_Process(btDbvt_ICollide* obj, const btDbvtNode* __unnamed0, const btDbvtNode* __unnamed1);
void btDbvt_ICollide_Process2(btDbvt_ICollide* obj, const btDbvtNode* __unnamed0);
void btDbvt_ICollide_Process3(btDbvt_ICollide* obj, const btDbvtNode* n, btScalar __unnamed1);
void btDbvt_ICollide_delete(btDbvt_ICollide* obj);
void btDbvt_IWriter_Prepare(btDbvt_IWriter* obj, const btDbvtNode* root, int numnodes);
void btDbvt_IWriter_WriteLeaf(btDbvt_IWriter* obj, const btDbvtNode* __unnamed0, int index, int parent);
void btDbvt_IWriter_WriteNode(btDbvt_IWriter* obj, const btDbvtNode* __unnamed0, int index, int parent, int child0, int child1);
void btDbvt_IWriter_delete(btDbvt_IWriter* obj);
btDbvt_sStkCLN* btDbvt_sStkCLN_new(const btDbvtNode* n, btDbvtNode* p);
const btDbvtNode* btDbvt_sStkCLN_getNode(btDbvt_sStkCLN* obj);
btDbvtNode* btDbvt_sStkCLN_getParent(btDbvt_sStkCLN* obj);
void btDbvt_sStkCLN_setNode(btDbvt_sStkCLN* obj, const btDbvtNode* value);
void btDbvt_sStkCLN_setParent(btDbvt_sStkCLN* obj, btDbvtNode* value);
void btDbvt_sStkCLN_delete(btDbvt_sStkCLN* obj);
btDbvt_sStkNN* btDbvt_sStkNN_new();
btDbvt_sStkNN* btDbvt_sStkNN_new2(const btDbvtNode* na, const btDbvtNode* nb);
const btDbvtNode* btDbvt_sStkNN_getA(btDbvt_sStkNN* obj);
const btDbvtNode* btDbvt_sStkNN_getB(btDbvt_sStkNN* obj);
void btDbvt_sStkNN_setA(btDbvt_sStkNN* obj, const btDbvtNode* value);
void btDbvt_sStkNN_setB(btDbvt_sStkNN* obj, const btDbvtNode* value);
void btDbvt_sStkNN_delete(btDbvt_sStkNN* obj);
btDbvt_sStkNP* btDbvt_sStkNP_new(const btDbvtNode* n, unsigned int m);
int btDbvt_sStkNP_getMask(btDbvt_sStkNP* obj);
const btDbvtNode* btDbvt_sStkNP_getNode(btDbvt_sStkNP* obj);
void btDbvt_sStkNP_setMask(btDbvt_sStkNP* obj, int value);
void btDbvt_sStkNP_setNode(btDbvt_sStkNP* obj, const btDbvtNode* value);
void btDbvt_sStkNP_delete(btDbvt_sStkNP* obj);
btDbvt_sStkNPS* btDbvt_sStkNPS_new();
btDbvt_sStkNPS* btDbvt_sStkNPS_new2(const btDbvtNode* n, unsigned int m, btScalar v);
int btDbvt_sStkNPS_getMask(btDbvt_sStkNPS* obj);
const btDbvtNode* btDbvt_sStkNPS_getNode(btDbvt_sStkNPS* obj);
btScalar btDbvt_sStkNPS_getValue(btDbvt_sStkNPS* obj);
void btDbvt_sStkNPS_setMask(btDbvt_sStkNPS* obj, int value);
void btDbvt_sStkNPS_setNode(btDbvt_sStkNPS* obj, const btDbvtNode* value);
void btDbvt_sStkNPS_setValue(btDbvt_sStkNPS* obj, btScalar value);
void btDbvt_sStkNPS_delete(btDbvt_sStkNPS* obj);
btDbvt* btDbvt_new();
int btDbvt_allocate(btAlignedIntArray* ifree, btAlignedStkNpsArray* stock, const btDbvt_sStkNPS* value);
void btDbvt_benchmark();
void btDbvt_clear(btDbvt* obj);
void btDbvt_clone(btDbvt* obj, btDbvt* dest);
void btDbvt_clone2(btDbvt* obj, btDbvt* dest, btDbvt_IClone* iclone);
void btDbvt_collideKDOP(const btDbvtNode* root, const btVector3* normals, const btScalar* offsets, int count, const btDbvt_ICollide* policy);
void btDbvt_collideOCL(const btDbvtNode* root, const btVector3* normals, const btScalar* offsets, const btScalar* sortaxis, int count, const btDbvt_ICollide* policy);
void btDbvt_collideOCL2(const btDbvtNode* root, const btVector3* normals, const btScalar* offsets, const btScalar* sortaxis, int count, const btDbvt_ICollide* policy, bool fullsort);
void btDbvt_collideTT(btDbvt* obj, const btDbvtNode* root0, const btDbvtNode* root1, const btDbvt_ICollide* policy);
void btDbvt_collideTTpersistentStack(btDbvt* obj, const btDbvtNode* root0, const btDbvtNode* root1, const btDbvt_ICollide* policy);
void btDbvt_collideTU(const btDbvtNode* root, const btDbvt_ICollide* policy);
void btDbvt_collideTV(btDbvt* obj, const btDbvtNode* root, const btDbvtVolume* volume, const btDbvt_ICollide* policy);
int btDbvt_countLeaves(const btDbvtNode* node);
bool btDbvt_empty(btDbvt* obj);
void btDbvt_enumLeaves(const btDbvtNode* root, const btDbvt_ICollide* policy);
void btDbvt_enumNodes(const btDbvtNode* root, const btDbvt_ICollide* policy);
void btDbvt_extractLeaves(const btDbvtNode* node, btAlignedDbvtNodeArray* leaves);
btDbvtNode* btDbvt_getFree(btDbvt* obj);
int btDbvt_getLeaves(btDbvt* obj);
int btDbvt_getLkhd(btDbvt* obj);
unsigned int btDbvt_getOpath(btDbvt* obj);
btAlignedDbvtNodeArray* btDbvt_getRayTestStack(btDbvt* obj);
btDbvtNode* btDbvt_getRoot(btDbvt* obj);
btAlignedStkNNArray* btDbvt_getStkStack(btDbvt* obj);
btDbvtNode* btDbvt_insert(btDbvt* obj, const btDbvtVolume* box, void* data);
int btDbvt_maxdepth(const btDbvtNode* node);
int btDbvt_nearest(const int* i, const btDbvt_sStkNPS* a, btScalar v, int l, int h);
void btDbvt_optimizeBottomUp(btDbvt* obj);
void btDbvt_optimizeIncremental(btDbvt* obj, int passes);
void btDbvt_optimizeTopDown(btDbvt* obj);
void btDbvt_optimizeTopDown2(btDbvt* obj, int bu_treshold);
void btDbvt_rayTest(const btDbvtNode* root, const btScalar* rayFrom, const btScalar* rayTo, const btDbvt_ICollide* policy);
void btDbvt_rayTestInternal(btDbvt* obj, const btDbvtNode* root, const btScalar* rayFrom, const btScalar* rayTo, const btScalar* rayDirectionInverse, unsigned int* signs, btScalar lambda_max, const btScalar* aabbMin, const btScalar* aabbMax, const btDbvt_ICollide* policy);
void btDbvt_remove(btDbvt* obj, btDbvtNode* leaf);
void btDbvt_setFree(btDbvt* obj, btDbvtNode* value);
void btDbvt_setLeaves(btDbvt* obj, int value);
void btDbvt_setLkhd(btDbvt* obj, int value);
void btDbvt_setOpath(btDbvt* obj, unsigned int value);
void btDbvt_setRoot(btDbvt* obj, btDbvtNode* value);
void btDbvt_update(btDbvt* obj, btDbvtNode* leaf, btDbvtVolume* volume);
void btDbvt_update2(btDbvt* obj, btDbvtNode* leaf);
void btDbvt_update3(btDbvt* obj, btDbvtNode* leaf, int lookahead);
bool btDbvt_update4(btDbvt* obj, btDbvtNode* leaf, btDbvtVolume* volume, btScalar margin);
bool btDbvt_update5(btDbvt* obj, btDbvtNode* leaf, btDbvtVolume* volume, const btScalar* velocity);
bool btDbvt_update6(btDbvt* obj, btDbvtNode* leaf, btDbvtVolume* volume, const btScalar* velocity, btScalar margin);
void btDbvt_write(btDbvt* obj, btDbvt_IWriter* iwriter);
void btDbvt_delete(btDbvt* obj);
btDefaultCollisionConstructionInfo* btDefaultCollisionConstructionInfo_new();
btPoolAllocator* btDefaultCollisionConstructionInfo_getCollisionAlgorithmPool(btDefaultCollisionConstructionInfo* obj);
int btDefaultCollisionConstructionInfo_getCustomCollisionAlgorithmMaxElementSize(btDefaultCollisionConstructionInfo* obj);
int btDefaultCollisionConstructionInfo_getDefaultMaxCollisionAlgorithmPoolSize(btDefaultCollisionConstructionInfo* obj);
int btDefaultCollisionConstructionInfo_getDefaultMaxPersistentManifoldPoolSize(btDefaultCollisionConstructionInfo* obj);
btPoolAllocator* btDefaultCollisionConstructionInfo_getPersistentManifoldPool(btDefaultCollisionConstructionInfo* obj);
int btDefaultCollisionConstructionInfo_getUseEpaPenetrationAlgorithm(btDefaultCollisionConstructionInfo* obj);
void btDefaultCollisionConstructionInfo_setCollisionAlgorithmPool(btDefaultCollisionConstructionInfo* obj, btPoolAllocator* value);
void btDefaultCollisionConstructionInfo_setCustomCollisionAlgorithmMaxElementSize(btDefaultCollisionConstructionInfo* obj, int value);
void btDefaultCollisionConstructionInfo_setDefaultMaxCollisionAlgorithmPoolSize(btDefaultCollisionConstructionInfo* obj, int value);
void btDefaultCollisionConstructionInfo_setDefaultMaxPersistentManifoldPoolSize(btDefaultCollisionConstructionInfo* obj, int value);
void btDefaultCollisionConstructionInfo_setPersistentManifoldPool(btDefaultCollisionConstructionInfo* obj, btPoolAllocator* value);
void btDefaultCollisionConstructionInfo_setUseEpaPenetrationAlgorithm(btDefaultCollisionConstructionInfo* obj, int value);
void btDefaultCollisionConstructionInfo_delete(btDefaultCollisionConstructionInfo* obj);
btDefaultCollisionConfiguration* btDefaultCollisionConfiguration_new();
btDefaultCollisionConfiguration* btDefaultCollisionConfiguration_new2(const btDefaultCollisionConstructionInfo* constructionInfo);
btVoronoiSimplexSolver* btDefaultCollisionConfiguration_getSimplexSolver(btDefaultCollisionConfiguration* obj);
void btDefaultCollisionConfiguration_setConvexConvexMultipointIterations(btDefaultCollisionConfiguration* obj);
void btDefaultCollisionConfiguration_setConvexConvexMultipointIterations2(btDefaultCollisionConfiguration* obj, int numPerturbationIterations);
void btDefaultCollisionConfiguration_setConvexConvexMultipointIterations3(btDefaultCollisionConfiguration* obj, int numPerturbationIterations, int minimumPointsPerturbationThreshold);
void btDefaultCollisionConfiguration_setPlaneConvexMultipointIterations(btDefaultCollisionConfiguration* obj);
void btDefaultCollisionConfiguration_setPlaneConvexMultipointIterations2(btDefaultCollisionConfiguration* obj, int numPerturbationIterations);
void btDefaultCollisionConfiguration_setPlaneConvexMultipointIterations3(btDefaultCollisionConfiguration* obj, int numPerturbationIterations, int minimumPointsPerturbationThreshold);
btDefaultMotionState* btDefaultMotionState_new();
btDefaultMotionState* btDefaultMotionState_new2(const btScalar* startTrans);
btDefaultMotionState* btDefaultMotionState_new3(const btScalar* startTrans, const btScalar* centerOfMassOffset);
void btDefaultMotionState_getCenterOfMassOffset(btDefaultMotionState* obj, btScalar* value);
void btDefaultMotionState_getGraphicsWorldTrans(btDefaultMotionState* obj, btScalar* value);
void btDefaultMotionState_getStartWorldTrans(btDefaultMotionState* obj, btScalar* value);
void* btDefaultMotionState_getUserPointer(btDefaultMotionState* obj);
void btDefaultMotionState_setCenterOfMassOffset(btDefaultMotionState* obj, const btScalar* value);
void btDefaultMotionState_setGraphicsWorldTrans(btDefaultMotionState* obj, const btScalar* value);
void btDefaultMotionState_setStartWorldTrans(btDefaultMotionState* obj, const btScalar* value);
void btDefaultMotionState_setUserPointer(btDefaultMotionState* obj, void* value);
btDefaultSoftBodySolver* btDefaultSoftBodySolver_new();
void btDefaultSoftBodySolver_copySoftBodyToVertexBuffer(btDefaultSoftBodySolver* obj, const btSoftBody* softBody, btVertexBufferDescriptor* vertexBuffer);
btDiscreteCollisionDetectorInterface_ClosestPointInput* btDiscreteCollisionDetectorInterface_ClosestPointInput_new();
btScalar btDiscreteCollisionDetectorInterface_ClosestPointInput_getMaximumDistanceSquared(btDiscreteCollisionDetectorInterface_ClosestPointInput* obj);
void btDiscreteCollisionDetectorInterface_ClosestPointInput_getTransformA(btDiscreteCollisionDetectorInterface_ClosestPointInput* obj, btScalar* value);
void btDiscreteCollisionDetectorInterface_ClosestPointInput_getTransformB(btDiscreteCollisionDetectorInterface_ClosestPointInput* obj, btScalar* value);
void btDiscreteCollisionDetectorInterface_ClosestPointInput_setMaximumDistanceSquared(btDiscreteCollisionDetectorInterface_ClosestPointInput* obj, btScalar value);
void btDiscreteCollisionDetectorInterface_ClosestPointInput_setTransformA(btDiscreteCollisionDetectorInterface_ClosestPointInput* obj, const btScalar* value);
void btDiscreteCollisionDetectorInterface_ClosestPointInput_setTransformB(btDiscreteCollisionDetectorInterface_ClosestPointInput* obj, const btScalar* value);
void btDiscreteCollisionDetectorInterface_ClosestPointInput_delete(btDiscreteCollisionDetectorInterface_ClosestPointInput* obj);
void btDiscreteCollisionDetectorInterface_Result_addContactPoint(btDiscreteCollisionDetectorInterface_Result* obj, const btScalar* normalOnBInWorld, const btScalar* pointInWorld, btScalar depth);
void btDiscreteCollisionDetectorInterface_Result_setShapeIdentifiersA(btDiscreteCollisionDetectorInterface_Result* obj, int partId0, int index0);
void btDiscreteCollisionDetectorInterface_Result_setShapeIdentifiersB(btDiscreteCollisionDetectorInterface_Result* obj, int partId1, int index1);
void btDiscreteCollisionDetectorInterface_Result_delete(btDiscreteCollisionDetectorInterface_Result* obj);
void btDiscreteCollisionDetectorInterface_getClosestPoints(btDiscreteCollisionDetectorInterface* obj, const btDiscreteCollisionDetectorInterface_ClosestPointInput* input, btDiscreteCollisionDetectorInterface_Result* output, btIDebugDraw* debugDraw);
void btDiscreteCollisionDetectorInterface_getClosestPoints2(btDiscreteCollisionDetectorInterface* obj, const btDiscreteCollisionDetectorInterface_ClosestPointInput* input, btDiscreteCollisionDetectorInterface_Result* output, btIDebugDraw* debugDraw, bool swapResults);
void btDiscreteCollisionDetectorInterface_delete(btDiscreteCollisionDetectorInterface* obj);
btStorageResult* btStorageResult_new();
void btStorageResult_getClosestPointInB(btStorageResult* obj, btScalar* value);
btScalar btStorageResult_getDistance(btStorageResult* obj);
void btStorageResult_getNormalOnSurfaceB(btStorageResult* obj, btScalar* value);
void btStorageResult_setClosestPointInB(btStorageResult* obj, const btScalar* value);
void btStorageResult_setDistance(btStorageResult* obj, btScalar value);
void btStorageResult_setNormalOnSurfaceB(btStorageResult* obj, const btScalar* value);
btDiscreteDynamicsWorld* btDiscreteDynamicsWorld_new(btDispatcher* dispatcher, btBroadphaseInterface* pairCache, btConstraintSolver* constraintSolver, btCollisionConfiguration* collisionConfiguration);
void btDiscreteDynamicsWorld_applyGravity(btDiscreteDynamicsWorld* obj);
void btDiscreteDynamicsWorld_debugDrawConstraint(btDiscreteDynamicsWorld* obj, btTypedConstraint* constraint);
bool btDiscreteDynamicsWorld_getApplySpeculativeContactRestitution(btDiscreteDynamicsWorld* obj);
btCollisionWorld* btDiscreteDynamicsWorld_getCollisionWorld(btDiscreteDynamicsWorld* obj);
bool btDiscreteDynamicsWorld_getLatencyMotionStateInterpolation(btDiscreteDynamicsWorld* obj);
btSimulationIslandManager* btDiscreteDynamicsWorld_getSimulationIslandManager(btDiscreteDynamicsWorld* obj);
bool btDiscreteDynamicsWorld_getSynchronizeAllMotionStates(btDiscreteDynamicsWorld* obj);
void btDiscreteDynamicsWorld_setApplySpeculativeContactRestitution(btDiscreteDynamicsWorld* obj, bool enable);
void btDiscreteDynamicsWorld_setLatencyMotionStateInterpolation(btDiscreteDynamicsWorld* obj, bool latencyInterpolation);
void btDiscreteDynamicsWorld_setNumTasks(btDiscreteDynamicsWorld* obj, int numTasks);
void btDiscreteDynamicsWorld_setSynchronizeAllMotionStates(btDiscreteDynamicsWorld* obj, bool synchronizeAll);
void btDiscreteDynamicsWorld_synchronizeSingleMotionState(btDiscreteDynamicsWorld* obj, btRigidBody* body);
void btDiscreteDynamicsWorld_updateVehicles(btDiscreteDynamicsWorld* obj, btScalar timeStep);
btDispatcherInfo* btDispatcherInfo_new();
btScalar btDispatcherInfo_getAllowedCcdPenetration(btDispatcherInfo* obj);
btScalar btDispatcherInfo_getConvexConservativeDistanceThreshold(btDispatcherInfo* obj);
btIDebugDraw* btDispatcherInfo_getDebugDraw(btDispatcherInfo* obj);
int btDispatcherInfo_getDispatchFunc(btDispatcherInfo* obj);
bool btDispatcherInfo_getEnableSatConvex(btDispatcherInfo* obj);
bool btDispatcherInfo_getEnableSPU(btDispatcherInfo* obj);
int btDispatcherInfo_getStepCount(btDispatcherInfo* obj);
btScalar btDispatcherInfo_getTimeOfImpact(btDispatcherInfo* obj);
btScalar btDispatcherInfo_getTimeStep(btDispatcherInfo* obj);
bool btDispatcherInfo_getUseContinuous(btDispatcherInfo* obj);
bool btDispatcherInfo_getUseConvexConservativeDistanceUtil(btDispatcherInfo* obj);
bool btDispatcherInfo_getUseEpa(btDispatcherInfo* obj);
void btDispatcherInfo_setAllowedCcdPenetration(btDispatcherInfo* obj, btScalar value);
void btDispatcherInfo_setConvexConservativeDistanceThreshold(btDispatcherInfo* obj, btScalar value);
void btDispatcherInfo_setDebugDraw(btDispatcherInfo* obj, btIDebugDraw* value);
void btDispatcherInfo_setDispatchFunc(btDispatcherInfo* obj, int value);
void btDispatcherInfo_setEnableSatConvex(btDispatcherInfo* obj, bool value);
void btDispatcherInfo_setEnableSPU(btDispatcherInfo* obj, bool value);
void btDispatcherInfo_setStepCount(btDispatcherInfo* obj, int value);
void btDispatcherInfo_setTimeOfImpact(btDispatcherInfo* obj, btScalar value);
void btDispatcherInfo_setTimeStep(btDispatcherInfo* obj, btScalar value);
void btDispatcherInfo_setUseContinuous(btDispatcherInfo* obj, bool value);
void btDispatcherInfo_setUseConvexConservativeDistanceUtil(btDispatcherInfo* obj, bool value);
void btDispatcherInfo_setUseEpa(btDispatcherInfo* obj, bool value);
void btDispatcherInfo_delete(btDispatcherInfo* obj);
void* btDispatcher_allocateCollisionAlgorithm(btDispatcher* obj, int size);
void btDispatcher_clearManifold(btDispatcher* obj, btPersistentManifold* manifold);
void btDispatcher_dispatchAllCollisionPairs(btDispatcher* obj, btOverlappingPairCache* pairCache, const btDispatcherInfo* dispatchInfo, btDispatcher* dispatcher);
btCollisionAlgorithm* btDispatcher_findAlgorithm(btDispatcher* obj, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap);
btCollisionAlgorithm* btDispatcher_findAlgorithm2(btDispatcher* obj, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap, btPersistentManifold* sharedManifold);
void btDispatcher_freeCollisionAlgorithm(btDispatcher* obj, void* ptr);
btPersistentManifold** btDispatcher_getInternalManifoldPointer(btDispatcher* obj);
btPoolAllocator* btDispatcher_getInternalManifoldPool(btDispatcher* obj);
btPersistentManifold* btDispatcher_getManifoldByIndexInternal(btDispatcher* obj, int index);
btPersistentManifold* btDispatcher_getNewManifold(btDispatcher* obj, const btCollisionObject* b0, const btCollisionObject* b1);
int btDispatcher_getNumManifolds(btDispatcher* obj);
bool btDispatcher_needsCollision(btDispatcher* obj, const btCollisionObject* body0, const btCollisionObject* body1);
bool btDispatcher_needsResponse(btDispatcher* obj, const btCollisionObject* body0, const btCollisionObject* body1);
void btDispatcher_releaseManifold(btDispatcher* obj, btPersistentManifold* manifold);
void btDispatcher_delete(btDispatcher* obj);
void btDynamicsWorld_addAction(btDynamicsWorld* obj, btActionInterface* action);
void btDynamicsWorld_addConstraint(btDynamicsWorld* obj, btTypedConstraint* constraint);
void btDynamicsWorld_addConstraint2(btDynamicsWorld* obj, btTypedConstraint* constraint, bool disableCollisionsBetweenLinkedBodies);
void btDynamicsWorld_addRigidBody(btDynamicsWorld* obj, btRigidBody* body);
void btDynamicsWorld_addRigidBody2(btDynamicsWorld* obj, btRigidBody* body, short group, short mask);
void btDynamicsWorld_clearForces(btDynamicsWorld* obj);
btTypedConstraint* btDynamicsWorld_getConstraint(btDynamicsWorld* obj, int index);
btConstraintSolver* btDynamicsWorld_getConstraintSolver(btDynamicsWorld* obj);
void btDynamicsWorld_getGravity(btDynamicsWorld* obj, btScalar* gravity);
int btDynamicsWorld_getNumConstraints(btDynamicsWorld* obj);
btContactSolverInfo* btDynamicsWorld_getSolverInfo(btDynamicsWorld* obj);
btDynamicsWorldType btDynamicsWorld_getWorldType(btDynamicsWorld* obj);
void* btDynamicsWorld_getWorldUserInfo(btDynamicsWorld* obj);
void btDynamicsWorld_removeAction(btDynamicsWorld* obj, btActionInterface* action);
void btDynamicsWorld_removeConstraint(btDynamicsWorld* obj, btTypedConstraint* constraint);
void btDynamicsWorld_removeRigidBody(btDynamicsWorld* obj, btRigidBody* body);
void btDynamicsWorld_setConstraintSolver(btDynamicsWorld* obj, btConstraintSolver* solver);
void btDynamicsWorld_setGravity(btDynamicsWorld* obj, const btScalar* gravity);
void btDynamicsWorld_setInternalTickCallback(btDynamicsWorld* obj, btInternalTickCallback cb);
void btDynamicsWorld_setInternalTickCallback2(btDynamicsWorld* obj, btInternalTickCallback cb, void* worldUserInfo);
void btDynamicsWorld_setInternalTickCallback3(btDynamicsWorld* obj, btInternalTickCallback cb, void* worldUserInfo, bool isPreTick);
void btDynamicsWorld_setWorldUserInfo(btDynamicsWorld* obj, void* worldUserInfo);
int btDynamicsWorld_stepSimulation(btDynamicsWorld* obj, btScalar timeStep);
int btDynamicsWorld_stepSimulation2(btDynamicsWorld* obj, btScalar timeStep, int maxSubSteps);
int btDynamicsWorld_stepSimulation3(btDynamicsWorld* obj, btScalar timeStep, int maxSubSteps, btScalar fixedTimeStep);
void btDynamicsWorld_synchronizeMotionStates(btDynamicsWorld* obj);
btEmptyAlgorithm_CreateFunc* btEmptyAlgorithm_CreateFunc_new();
btEmptyAlgorithm* btEmptyAlgorithm_new(const btCollisionAlgorithmConstructionInfo* ci);
btEmptyShape* btEmptyShape_new();
btFixedConstraint* btFixedConstraint_new(btRigidBody* rbA, btRigidBody* rbB, const btScalar* frameInA, const btScalar* frameInB);
GIM_PAIR* GIM_PAIR_new();
GIM_PAIR* GIM_PAIR_new2(const GIM_PAIR* p);
GIM_PAIR* GIM_PAIR_new3(int index1, int index2);
int GIM_PAIR_getIndex1(GIM_PAIR* obj);
int GIM_PAIR_getIndex2(GIM_PAIR* obj);
void GIM_PAIR_setIndex1(GIM_PAIR* obj, int value);
void GIM_PAIR_setIndex2(GIM_PAIR* obj, int value);
void GIM_PAIR_delete(GIM_PAIR* obj);
btPairSet* btPairSet_new();
void btPairSet_push_pair(btPairSet* obj, int index1, int index2);
void btPairSet_push_pair_inv(btPairSet* obj, int index1, int index2);
GIM_BVH_DATA* GIM_BVH_DATA_new();
btAABB* GIM_BVH_DATA_getBound(GIM_BVH_DATA* obj);
int GIM_BVH_DATA_getData(GIM_BVH_DATA* obj);
void GIM_BVH_DATA_setBound(GIM_BVH_DATA* obj, const btAABB* value);
void GIM_BVH_DATA_setData(GIM_BVH_DATA* obj, int value);
void GIM_BVH_DATA_delete(GIM_BVH_DATA* obj);
GIM_BVH_TREE_NODE* GIM_BVH_TREE_NODE_new();
btAABB* GIM_BVH_TREE_NODE_getBound(GIM_BVH_TREE_NODE* obj);
int GIM_BVH_TREE_NODE_getDataIndex(GIM_BVH_TREE_NODE* obj);
int GIM_BVH_TREE_NODE_getEscapeIndex(GIM_BVH_TREE_NODE* obj);
bool GIM_BVH_TREE_NODE_isLeafNode(GIM_BVH_TREE_NODE* obj);
void GIM_BVH_TREE_NODE_setBound(GIM_BVH_TREE_NODE* obj, const btAABB* value);
void GIM_BVH_TREE_NODE_setDataIndex(GIM_BVH_TREE_NODE* obj, int index);
void GIM_BVH_TREE_NODE_setEscapeIndex(GIM_BVH_TREE_NODE* obj, int index);
void GIM_BVH_TREE_NODE_delete(GIM_BVH_TREE_NODE* obj);
GIM_BVH_DATA_ARRAY* GIM_BVH_DATA_ARRAY_new();
GIM_BVH_TREE_NODE_ARRAY* GIM_BVH_TREE_NODE_ARRAY_new();
btBvhTree* btBvhTree_new();
void btBvhTree_build_tree(btBvhTree* obj, GIM_BVH_DATA_ARRAY* primitive_boxes);
void btBvhTree_clearNodes(btBvhTree* obj);
const GIM_BVH_TREE_NODE* btBvhTree_get_node_pointer(btBvhTree* obj);
const GIM_BVH_TREE_NODE* btBvhTree_get_node_pointer2(btBvhTree* obj, int index);
int btBvhTree_getEscapeNodeIndex(btBvhTree* obj, int nodeindex);
int btBvhTree_getLeftNode(btBvhTree* obj, int nodeindex);
void btBvhTree_getNodeBound(btBvhTree* obj, int nodeindex, btAABB* bound);
int btBvhTree_getNodeCount(btBvhTree* obj);
int btBvhTree_getNodeData(btBvhTree* obj, int nodeindex);
int btBvhTree_getRightNode(btBvhTree* obj, int nodeindex);
bool btBvhTree_isLeafNode(btBvhTree* obj, int nodeindex);
void btBvhTree_setNodeBound(btBvhTree* obj, int nodeindex, const btAABB* bound);
void btBvhTree_delete(btBvhTree* obj);
void btPrimitiveManagerBase_get_primitive_box(btPrimitiveManagerBase* obj, int prim_index, btAABB* primbox);
int btPrimitiveManagerBase_get_primitive_count(btPrimitiveManagerBase* obj);
void btPrimitiveManagerBase_get_primitive_triangle(btPrimitiveManagerBase* obj, int prim_index, btPrimitiveTriangle* triangle);
bool btPrimitiveManagerBase_is_trimesh(btPrimitiveManagerBase* obj);
void btPrimitiveManagerBase_delete(btPrimitiveManagerBase* obj);
btGImpactBvh* btGImpactBvh_new();
btGImpactBvh* btGImpactBvh_new2(btPrimitiveManagerBase* primitive_manager);
bool btGImpactBvh_boxQuery(btGImpactBvh* obj, const btAABB* box, btAlignedIntArray* collided_results);
bool btGImpactBvh_boxQueryTrans(btGImpactBvh* obj, const btAABB* box, const btScalar* transform, btAlignedIntArray* collided_results);
void btGImpactBvh_buildSet(btGImpactBvh* obj);
void btGImpactBvh_find_collision(btGImpactBvh* boxset1, const btScalar* trans1, btGImpactBvh* boxset2, const btScalar* trans2, btPairSet* collision_pairs);
const GIM_BVH_TREE_NODE* btGImpactBvh_get_node_pointer(btGImpactBvh* obj);
const GIM_BVH_TREE_NODE* btGImpactBvh_get_node_pointer2(btGImpactBvh* obj, int index);
int btGImpactBvh_getEscapeNodeIndex(btGImpactBvh* obj, int nodeindex);
btAABB* btGImpactBvh_getGlobalBox(btGImpactBvh* obj);
int btGImpactBvh_getLeftNode(btGImpactBvh* obj, int nodeindex);
void btGImpactBvh_getNodeBound(btGImpactBvh* obj, int nodeindex, btAABB* bound);
int btGImpactBvh_getNodeCount(btGImpactBvh* obj);
int btGImpactBvh_getNodeData(btGImpactBvh* obj, int nodeindex);
void btGImpactBvh_getNodeTriangle(btGImpactBvh* obj, int nodeindex, btPrimitiveTriangle* triangle);
btPrimitiveManagerBase* btGImpactBvh_getPrimitiveManager(btGImpactBvh* obj);
int btGImpactBvh_getRightNode(btGImpactBvh* obj, int nodeindex);
bool btGImpactBvh_hasHierarchy(btGImpactBvh* obj);
bool btGImpactBvh_isLeafNode(btGImpactBvh* obj, int nodeindex);
bool btGImpactBvh_isTrimesh(btGImpactBvh* obj);
bool btGImpactBvh_rayQuery(btGImpactBvh* obj, const btScalar* ray_dir, const btScalar* ray_origin, btAlignedIntArray* collided_results);
void btGImpactBvh_setNodeBound(btGImpactBvh* obj, int nodeindex, const btAABB* bound);
void btGImpactBvh_setPrimitiveManager(btGImpactBvh* obj, btPrimitiveManagerBase* primitive_manager);
void btGImpactBvh_update(btGImpactBvh* obj);
void btGImpactBvh_delete(btGImpactBvh* obj);
btGImpactCollisionAlgorithm_CreateFunc* btGImpactCollisionAlgorithm_CreateFunc_new();
btGImpactCollisionAlgorithm* btGImpactCollisionAlgorithm_new(const btCollisionAlgorithmConstructionInfo* ci, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap);
int btGImpactCollisionAlgorithm_getFace0(btGImpactCollisionAlgorithm* obj);
int btGImpactCollisionAlgorithm_getFace1(btGImpactCollisionAlgorithm* obj);
int btGImpactCollisionAlgorithm_getPart0(btGImpactCollisionAlgorithm* obj);
int btGImpactCollisionAlgorithm_getPart1(btGImpactCollisionAlgorithm* obj);
void btGImpactCollisionAlgorithm_gimpact_vs_compoundshape(btGImpactCollisionAlgorithm* obj, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap, const btGImpactShapeInterface* shape0, const btCompoundShape* shape1, bool swapped);
void btGImpactCollisionAlgorithm_gimpact_vs_concave(btGImpactCollisionAlgorithm* obj, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap, const btGImpactShapeInterface* shape0, const btConcaveShape* shape1, bool swapped);
void btGImpactCollisionAlgorithm_gimpact_vs_gimpact(btGImpactCollisionAlgorithm* obj, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap, const btGImpactShapeInterface* shape0, const btGImpactShapeInterface* shape1);
void btGImpactCollisionAlgorithm_gimpact_vs_shape(btGImpactCollisionAlgorithm* obj, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap, const btGImpactShapeInterface* shape0, const btCollisionShape* shape1, bool swapped);
btManifoldResult* btGImpactCollisionAlgorithm_internalGetResultOut(btGImpactCollisionAlgorithm* obj);
void btGImpactCollisionAlgorithm_registerAlgorithm(btCollisionDispatcher* dispatcher);
void btGImpactCollisionAlgorithm_setFace0(btGImpactCollisionAlgorithm* obj, int value);
void btGImpactCollisionAlgorithm_setFace1(btGImpactCollisionAlgorithm* obj, int value);
void btGImpactCollisionAlgorithm_setPart0(btGImpactCollisionAlgorithm* obj, int value);
void btGImpactCollisionAlgorithm_setPart1(btGImpactCollisionAlgorithm* obj, int value);
BT_QUANTIZED_BVH_NODE* BT_QUANTIZED_BVH_NODE_new();
int BT_QUANTIZED_BVH_NODE_getDataIndex(BT_QUANTIZED_BVH_NODE* obj);
int BT_QUANTIZED_BVH_NODE_getEscapeIndex(BT_QUANTIZED_BVH_NODE* obj);
int BT_QUANTIZED_BVH_NODE_getEscapeIndexOrDataIndex(BT_QUANTIZED_BVH_NODE* obj);
unsigned short* BT_QUANTIZED_BVH_NODE_getQuantizedAabbMax(BT_QUANTIZED_BVH_NODE* obj);
unsigned short* BT_QUANTIZED_BVH_NODE_getQuantizedAabbMin(BT_QUANTIZED_BVH_NODE* obj);
bool BT_QUANTIZED_BVH_NODE_isLeafNode(BT_QUANTIZED_BVH_NODE* obj);
void BT_QUANTIZED_BVH_NODE_setDataIndex(BT_QUANTIZED_BVH_NODE* obj, int index);
void BT_QUANTIZED_BVH_NODE_setEscapeIndex(BT_QUANTIZED_BVH_NODE* obj, int index);
void BT_QUANTIZED_BVH_NODE_setEscapeIndexOrDataIndex(BT_QUANTIZED_BVH_NODE* obj, int value);
bool BT_QUANTIZED_BVH_NODE_testQuantizedBoxOverlapp(BT_QUANTIZED_BVH_NODE* obj, unsigned short* quantizedMin, unsigned short* quantizedMax);
void BT_QUANTIZED_BVH_NODE_delete(BT_QUANTIZED_BVH_NODE* obj);
GIM_QUANTIZED_BVH_NODE_ARRAY* GIM_QUANTIZED_BVH_NODE_ARRAY_new();
btQuantizedBvhTree* btQuantizedBvhTree_new();
void btQuantizedBvhTree_build_tree(btQuantizedBvhTree* obj, GIM_BVH_DATA_ARRAY* primitive_boxes);
void btQuantizedBvhTree_clearNodes(btQuantizedBvhTree* obj);
const BT_QUANTIZED_BVH_NODE* btQuantizedBvhTree_get_node_pointer(btQuantizedBvhTree* obj);
const BT_QUANTIZED_BVH_NODE* btQuantizedBvhTree_get_node_pointer2(btQuantizedBvhTree* obj, int index);
int btQuantizedBvhTree_getEscapeNodeIndex(btQuantizedBvhTree* obj, int nodeindex);
int btQuantizedBvhTree_getLeftNode(btQuantizedBvhTree* obj, int nodeindex);
void btQuantizedBvhTree_getNodeBound(btQuantizedBvhTree* obj, int nodeindex, btAABB* bound);
int btQuantizedBvhTree_getNodeCount(btQuantizedBvhTree* obj);
int btQuantizedBvhTree_getNodeData(btQuantizedBvhTree* obj, int nodeindex);
int btQuantizedBvhTree_getRightNode(btQuantizedBvhTree* obj, int nodeindex);
bool btQuantizedBvhTree_isLeafNode(btQuantizedBvhTree* obj, int nodeindex);
void btQuantizedBvhTree_quantizePoint(btQuantizedBvhTree* obj, unsigned short* quantizedpoint, const btScalar* point);
void btQuantizedBvhTree_setNodeBound(btQuantizedBvhTree* obj, int nodeindex, const btAABB* bound);
bool btQuantizedBvhTree_testQuantizedBoxOverlapp(btQuantizedBvhTree* obj, int node_index, unsigned short* quantizedMin, unsigned short* quantizedMax);
void btQuantizedBvhTree_delete(btQuantizedBvhTree* obj);
btGImpactQuantizedBvh* btGImpactQuantizedBvh_new();
btGImpactQuantizedBvh* btGImpactQuantizedBvh_new2(btPrimitiveManagerBase* primitive_manager);
bool btGImpactQuantizedBvh_boxQuery(btGImpactQuantizedBvh* obj, const btAABB* box, btAlignedIntArray* collided_results);
bool btGImpactQuantizedBvh_boxQueryTrans(btGImpactQuantizedBvh* obj, const btAABB* box, const btScalar* transform, btAlignedIntArray* collided_results);
void btGImpactQuantizedBvh_buildSet(btGImpactQuantizedBvh* obj);
void btGImpactQuantizedBvh_find_collision(const btGImpactQuantizedBvh* boxset1, const btScalar* trans1, const btGImpactQuantizedBvh* boxset2, const btScalar* trans2, btPairSet* collision_pairs);
const BT_QUANTIZED_BVH_NODE* btGImpactQuantizedBvh_get_node_pointer(btGImpactQuantizedBvh* obj);
const BT_QUANTIZED_BVH_NODE* btGImpactQuantizedBvh_get_node_pointer2(btGImpactQuantizedBvh* obj, int index);
int btGImpactQuantizedBvh_getEscapeNodeIndex(btGImpactQuantizedBvh* obj, int nodeindex);
btAABB* btGImpactQuantizedBvh_getGlobalBox(btGImpactQuantizedBvh* obj);
int btGImpactQuantizedBvh_getLeftNode(btGImpactQuantizedBvh* obj, int nodeindex);
void btGImpactQuantizedBvh_getNodeBound(btGImpactQuantizedBvh* obj, int nodeindex, btAABB* bound);
int btGImpactQuantizedBvh_getNodeCount(btGImpactQuantizedBvh* obj);
int btGImpactQuantizedBvh_getNodeData(btGImpactQuantizedBvh* obj, int nodeindex);
void btGImpactQuantizedBvh_getNodeTriangle(btGImpactQuantizedBvh* obj, int nodeindex, btPrimitiveTriangle* triangle);
btPrimitiveManagerBase* btGImpactQuantizedBvh_getPrimitiveManager(btGImpactQuantizedBvh* obj);
int btGImpactQuantizedBvh_getRightNode(btGImpactQuantizedBvh* obj, int nodeindex);
bool btGImpactQuantizedBvh_hasHierarchy(btGImpactQuantizedBvh* obj);
bool btGImpactQuantizedBvh_isLeafNode(btGImpactQuantizedBvh* obj, int nodeindex);
bool btGImpactQuantizedBvh_isTrimesh(btGImpactQuantizedBvh* obj);
bool btGImpactQuantizedBvh_rayQuery(btGImpactQuantizedBvh* obj, const btScalar* ray_dir, const btScalar* ray_origin, btAlignedIntArray* collided_results);
void btGImpactQuantizedBvh_setNodeBound(btGImpactQuantizedBvh* obj, int nodeindex, const btAABB* bound);
void btGImpactQuantizedBvh_setPrimitiveManager(btGImpactQuantizedBvh* obj, btPrimitiveManagerBase* primitive_manager);
void btGImpactQuantizedBvh_update(btGImpactQuantizedBvh* obj);
void btGImpactQuantizedBvh_delete(btGImpactQuantizedBvh* obj);
btTetrahedronShapeEx* btTetrahedronShapeEx_new();
void btTetrahedronShapeEx_setVertices(btTetrahedronShapeEx* obj, const btScalar* v0, const btScalar* v1, const btScalar* v2, const btScalar* v3);
bool btGImpactShapeInterface_childrenHasTransform(btGImpactShapeInterface* obj);
const btGImpactBoxSet* btGImpactShapeInterface_getBoxSet(btGImpactShapeInterface* obj);
void btGImpactShapeInterface_getBulletTetrahedron(btGImpactShapeInterface* obj, int prim_index, btTetrahedronShapeEx* tetrahedron);
void btGImpactShapeInterface_getBulletTriangle(btGImpactShapeInterface* obj, int prim_index, btTriangleShapeEx* triangle);
void btGImpactShapeInterface_getChildAabb(btGImpactShapeInterface* obj, int child_index, const btScalar* t, btScalar* aabbMin, btScalar* aabbMax);
btCollisionShape* btGImpactShapeInterface_getChildShape(btGImpactShapeInterface* obj, int index);
void btGImpactShapeInterface_getChildTransform(btGImpactShapeInterface* obj, int index, btScalar* value);
eGIMPACT_SHAPE_TYPE btGImpactShapeInterface_getGImpactShapeType(btGImpactShapeInterface* obj);
const btAABB* btGImpactShapeInterface_getLocalBox(btGImpactShapeInterface* obj);
int btGImpactShapeInterface_getNumChildShapes(btGImpactShapeInterface* obj);
const btPrimitiveManagerBase* btGImpactShapeInterface_getPrimitiveManager(btGImpactShapeInterface* obj);
void btGImpactShapeInterface_getPrimitiveTriangle(btGImpactShapeInterface* obj, int index, btPrimitiveTriangle* triangle);
bool btGImpactShapeInterface_hasBoxSet(btGImpactShapeInterface* obj);
void btGImpactShapeInterface_lockChildShapes(btGImpactShapeInterface* obj);
bool btGImpactShapeInterface_needsRetrieveTetrahedrons(btGImpactShapeInterface* obj);
bool btGImpactShapeInterface_needsRetrieveTriangles(btGImpactShapeInterface* obj);
void btGImpactShapeInterface_postUpdate(btGImpactShapeInterface* obj);
void btGImpactShapeInterface_processAllTrianglesRay(btGImpactShapeInterface* obj, btTriangleCallback* __unnamed0, const btScalar* __unnamed1, const btScalar* __unnamed2);
void btGImpactShapeInterface_rayTest(btGImpactShapeInterface* obj, const btScalar* rayFrom, const btScalar* rayTo, btCollisionWorld_RayResultCallback* resultCallback);
void btGImpactShapeInterface_setChildTransform(btGImpactShapeInterface* obj, int index, const btScalar* transform);
void btGImpactShapeInterface_unlockChildShapes(btGImpactShapeInterface* obj);
void btGImpactShapeInterface_updateBound(btGImpactShapeInterface* obj);
btGImpactCompoundShape_CompoundPrimitiveManager* btGImpactCompoundShape_CompoundPrimitiveManager_new(const btGImpactCompoundShape_CompoundPrimitiveManager* compound);
btGImpactCompoundShape_CompoundPrimitiveManager* btGImpactCompoundShape_CompoundPrimitiveManager_new2(btGImpactCompoundShape* compoundShape);
btGImpactCompoundShape_CompoundPrimitiveManager* btGImpactCompoundShape_CompoundPrimitiveManager_new3();
btGImpactCompoundShape* btGImpactCompoundShape_CompoundPrimitiveManager_getCompoundShape(btGImpactCompoundShape_CompoundPrimitiveManager* obj);
void btGImpactCompoundShape_CompoundPrimitiveManager_setCompoundShape(btGImpactCompoundShape_CompoundPrimitiveManager* obj, btGImpactCompoundShape* value);
btGImpactCompoundShape* btGImpactCompoundShape_new();
btGImpactCompoundShape* btGImpactCompoundShape_new2(bool children_has_transform);
void btGImpactCompoundShape_addChildShape(btGImpactCompoundShape* obj, const btScalar* localTransform, btCollisionShape* shape);
void btGImpactCompoundShape_addChildShape2(btGImpactCompoundShape* obj, btCollisionShape* shape);
btGImpactCompoundShape_CompoundPrimitiveManager* btGImpactCompoundShape_getCompoundPrimitiveManager(btGImpactCompoundShape* obj);
btGImpactMeshShapePart_TrimeshPrimitiveManager* btGImpactMeshShapePart_TrimeshPrimitiveManager_new(btStridingMeshInterface* meshInterface, int part);
btGImpactMeshShapePart_TrimeshPrimitiveManager* btGImpactMeshShapePart_TrimeshPrimitiveManager_new2(const btGImpactMeshShapePart_TrimeshPrimitiveManager* manager);
btGImpactMeshShapePart_TrimeshPrimitiveManager* btGImpactMeshShapePart_TrimeshPrimitiveManager_new3();
void btGImpactMeshShapePart_TrimeshPrimitiveManager_get_bullet_triangle(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj, int prim_index, btTriangleShapeEx* triangle);
void btGImpactMeshShapePart_TrimeshPrimitiveManager_get_indices(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj, int face_index, unsigned int* i0, unsigned int* i1, unsigned int* i2);
void btGImpactMeshShapePart_TrimeshPrimitiveManager_get_vertex(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj, unsigned int vertex_index, btScalar* vertex);
int btGImpactMeshShapePart_TrimeshPrimitiveManager_get_vertex_count(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj);
const unsigned char* btGImpactMeshShapePart_TrimeshPrimitiveManager_getIndexbase(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj);
int btGImpactMeshShapePart_TrimeshPrimitiveManager_getIndexstride(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj);
PHY_ScalarType btGImpactMeshShapePart_TrimeshPrimitiveManager_getIndicestype(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj);
int btGImpactMeshShapePart_TrimeshPrimitiveManager_getLock_count(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj);
btScalar btGImpactMeshShapePart_TrimeshPrimitiveManager_getMargin(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj);
btStridingMeshInterface* btGImpactMeshShapePart_TrimeshPrimitiveManager_getMeshInterface(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj);
int btGImpactMeshShapePart_TrimeshPrimitiveManager_getNumfaces(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj);
int btGImpactMeshShapePart_TrimeshPrimitiveManager_getNumverts(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj);
int btGImpactMeshShapePart_TrimeshPrimitiveManager_getPart(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj);
void btGImpactMeshShapePart_TrimeshPrimitiveManager_getScale(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj, btScalar* value);
int btGImpactMeshShapePart_TrimeshPrimitiveManager_getStride(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj);
PHY_ScalarType btGImpactMeshShapePart_TrimeshPrimitiveManager_getType(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj);
const unsigned char* btGImpactMeshShapePart_TrimeshPrimitiveManager_getVertexbase(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj);
void btGImpactMeshShapePart_TrimeshPrimitiveManager_lock(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj);
void btGImpactMeshShapePart_TrimeshPrimitiveManager_setIndexbase(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj, const unsigned char* value);
void btGImpactMeshShapePart_TrimeshPrimitiveManager_setIndexstride(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj, int value);
void btGImpactMeshShapePart_TrimeshPrimitiveManager_setIndicestype(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj, PHY_ScalarType value);
void btGImpactMeshShapePart_TrimeshPrimitiveManager_setLock_count(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj, int value);
void btGImpactMeshShapePart_TrimeshPrimitiveManager_setMargin(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj, btScalar value);
void btGImpactMeshShapePart_TrimeshPrimitiveManager_setMeshInterface(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj, btStridingMeshInterface* value);
void btGImpactMeshShapePart_TrimeshPrimitiveManager_setNumfaces(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj, int value);
void btGImpactMeshShapePart_TrimeshPrimitiveManager_setNumverts(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj, int value);
void btGImpactMeshShapePart_TrimeshPrimitiveManager_setPart(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj, int value);
void btGImpactMeshShapePart_TrimeshPrimitiveManager_setScale(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj, const btScalar* value);
void btGImpactMeshShapePart_TrimeshPrimitiveManager_setStride(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj, int value);
void btGImpactMeshShapePart_TrimeshPrimitiveManager_setType(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj, PHY_ScalarType value);
void btGImpactMeshShapePart_TrimeshPrimitiveManager_setVertexbase(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj, const unsigned char* value);
void btGImpactMeshShapePart_TrimeshPrimitiveManager_unlock(btGImpactMeshShapePart_TrimeshPrimitiveManager* obj);
btGImpactMeshShapePart* btGImpactMeshShapePart_new();
btGImpactMeshShapePart* btGImpactMeshShapePart_new2(btStridingMeshInterface* meshInterface, int part);
int btGImpactMeshShapePart_getPart(btGImpactMeshShapePart* obj);
btGImpactMeshShapePart_TrimeshPrimitiveManager* btGImpactMeshShapePart_getTrimeshPrimitiveManager(btGImpactMeshShapePart* obj);
void btGImpactMeshShapePart_getVertex(btGImpactMeshShapePart* obj, int vertex_index, btScalar* vertex);
int btGImpactMeshShapePart_getVertexCount(btGImpactMeshShapePart* obj);
btGImpactMeshShape* btGImpactMeshShape_new(btStridingMeshInterface* meshInterface);
btStridingMeshInterface* btGImpactMeshShape_getMeshInterface(btGImpactMeshShape* obj);
btGImpactMeshShapePart* btGImpactMeshShape_getMeshPart(btGImpactMeshShape* obj, int index);
int btGImpactMeshShape_getMeshPartCount(btGImpactMeshShape* obj);
btGearConstraint* btGearConstraint_new(btRigidBody* rbA, btRigidBody* rbB, const btScalar* axisInA, const btScalar* axisInB);
btGearConstraint* btGearConstraint_new2(btRigidBody* rbA, btRigidBody* rbB, const btScalar* axisInA, const btScalar* axisInB, btScalar ratio);
void btGearConstraint_getAxisA(btGearConstraint* obj, btScalar* axisA);
void btGearConstraint_getAxisB(btGearConstraint* obj, btScalar* axisB);
btScalar btGearConstraint_getRatio(btGearConstraint* obj);
void btGearConstraint_setAxisA(btGearConstraint* obj, btScalar* axisA);
void btGearConstraint_setAxisB(btGearConstraint* obj, btScalar* axisB);
void btGearConstraint_setRatio(btGearConstraint* obj, btScalar ratio);
btRotationalLimitMotor* btRotationalLimitMotor_new();
btRotationalLimitMotor* btRotationalLimitMotor_new2(const btRotationalLimitMotor* limot);
btScalar btRotationalLimitMotor_getAccumulatedImpulse(btRotationalLimitMotor* obj);
btScalar btRotationalLimitMotor_getBounce(btRotationalLimitMotor* obj);
int btRotationalLimitMotor_getCurrentLimit(btRotationalLimitMotor* obj);
btScalar btRotationalLimitMotor_getCurrentLimitError(btRotationalLimitMotor* obj);
btScalar btRotationalLimitMotor_getCurrentPosition(btRotationalLimitMotor* obj);
btScalar btRotationalLimitMotor_getDamping(btRotationalLimitMotor* obj);
bool btRotationalLimitMotor_getEnableMotor(btRotationalLimitMotor* obj);
btScalar btRotationalLimitMotor_getHiLimit(btRotationalLimitMotor* obj);
btScalar btRotationalLimitMotor_getLimitSoftness(btRotationalLimitMotor* obj);
btScalar btRotationalLimitMotor_getLoLimit(btRotationalLimitMotor* obj);
btScalar btRotationalLimitMotor_getMaxLimitForce(btRotationalLimitMotor* obj);
btScalar btRotationalLimitMotor_getMaxMotorForce(btRotationalLimitMotor* obj);
btScalar btRotationalLimitMotor_getNormalCFM(btRotationalLimitMotor* obj);
btScalar btRotationalLimitMotor_getStopCFM(btRotationalLimitMotor* obj);
btScalar btRotationalLimitMotor_getStopERP(btRotationalLimitMotor* obj);
btScalar btRotationalLimitMotor_getTargetVelocity(btRotationalLimitMotor* obj);
bool btRotationalLimitMotor_isLimited(btRotationalLimitMotor* obj);
bool btRotationalLimitMotor_needApplyTorques(btRotationalLimitMotor* obj);
void btRotationalLimitMotor_setAccumulatedImpulse(btRotationalLimitMotor* obj, btScalar value);
void btRotationalLimitMotor_setBounce(btRotationalLimitMotor* obj, btScalar value);
void btRotationalLimitMotor_setCurrentLimit(btRotationalLimitMotor* obj, int value);
void btRotationalLimitMotor_setCurrentLimitError(btRotationalLimitMotor* obj, btScalar value);
void btRotationalLimitMotor_setCurrentPosition(btRotationalLimitMotor* obj, btScalar value);
void btRotationalLimitMotor_setDamping(btRotationalLimitMotor* obj, btScalar value);
void btRotationalLimitMotor_setEnableMotor(btRotationalLimitMotor* obj, bool value);
void btRotationalLimitMotor_setHiLimit(btRotationalLimitMotor* obj, btScalar value);
void btRotationalLimitMotor_setLimitSoftness(btRotationalLimitMotor* obj, btScalar value);
void btRotationalLimitMotor_setLoLimit(btRotationalLimitMotor* obj, btScalar value);
void btRotationalLimitMotor_setMaxLimitForce(btRotationalLimitMotor* obj, btScalar value);
void btRotationalLimitMotor_setMaxMotorForce(btRotationalLimitMotor* obj, btScalar value);
void btRotationalLimitMotor_setNormalCFM(btRotationalLimitMotor* obj, btScalar value);
void btRotationalLimitMotor_setStopCFM(btRotationalLimitMotor* obj, btScalar value);
void btRotationalLimitMotor_setStopERP(btRotationalLimitMotor* obj, btScalar value);
void btRotationalLimitMotor_setTargetVelocity(btRotationalLimitMotor* obj, btScalar value);
btScalar btRotationalLimitMotor_solveAngularLimits(btRotationalLimitMotor* obj, btScalar timeStep, btScalar* axis, btScalar jacDiagABInv, btRigidBody* body0, btRigidBody* body1);
int btRotationalLimitMotor_testLimitValue(btRotationalLimitMotor* obj, btScalar test_value);
void btRotationalLimitMotor_delete(btRotationalLimitMotor* obj);
btTranslationalLimitMotor* btTranslationalLimitMotor_new();
btTranslationalLimitMotor* btTranslationalLimitMotor_new2(const btTranslationalLimitMotor* other);
void btTranslationalLimitMotor_getAccumulatedImpulse(btTranslationalLimitMotor* obj, btScalar* value);
int* btTranslationalLimitMotor_getCurrentLimit(btTranslationalLimitMotor* obj);
void btTranslationalLimitMotor_getCurrentLimitError(btTranslationalLimitMotor* obj, btScalar* value);
void btTranslationalLimitMotor_getCurrentLinearDiff(btTranslationalLimitMotor* obj, btScalar* value);
btScalar btTranslationalLimitMotor_getDamping(btTranslationalLimitMotor* obj);
bool* btTranslationalLimitMotor_getEnableMotor(btTranslationalLimitMotor* obj);
btScalar btTranslationalLimitMotor_getLimitSoftness(btTranslationalLimitMotor* obj);
void btTranslationalLimitMotor_getLowerLimit(btTranslationalLimitMotor* obj, btScalar* value);
void btTranslationalLimitMotor_getMaxMotorForce(btTranslationalLimitMotor* obj, btScalar* value);
void btTranslationalLimitMotor_getNormalCFM(btTranslationalLimitMotor* obj, btScalar* value);
btScalar btTranslationalLimitMotor_getRestitution(btTranslationalLimitMotor* obj);
void btTranslationalLimitMotor_getStopCFM(btTranslationalLimitMotor* obj, btScalar* value);
void btTranslationalLimitMotor_getStopERP(btTranslationalLimitMotor* obj, btScalar* value);
void btTranslationalLimitMotor_getTargetVelocity(btTranslationalLimitMotor* obj, btScalar* value);
void btTranslationalLimitMotor_getUpperLimit(btTranslationalLimitMotor* obj, btScalar* value);
bool btTranslationalLimitMotor_isLimited(btTranslationalLimitMotor* obj, int limitIndex);
bool btTranslationalLimitMotor_needApplyForce(btTranslationalLimitMotor* obj, int limitIndex);
void btTranslationalLimitMotor_setAccumulatedImpulse(btTranslationalLimitMotor* obj, const btScalar* value);
void btTranslationalLimitMotor_setCurrentLimitError(btTranslationalLimitMotor* obj, const btScalar* value);
void btTranslationalLimitMotor_setCurrentLinearDiff(btTranslationalLimitMotor* obj, const btScalar* value);
void btTranslationalLimitMotor_setDamping(btTranslationalLimitMotor* obj, btScalar value);
void btTranslationalLimitMotor_setLimitSoftness(btTranslationalLimitMotor* obj, btScalar value);
void btTranslationalLimitMotor_setLowerLimit(btTranslationalLimitMotor* obj, const btScalar* value);
void btTranslationalLimitMotor_setMaxMotorForce(btTranslationalLimitMotor* obj, const btScalar* value);
void btTranslationalLimitMotor_setNormalCFM(btTranslationalLimitMotor* obj, const btScalar* value);
void btTranslationalLimitMotor_setRestitution(btTranslationalLimitMotor* obj, btScalar value);
void btTranslationalLimitMotor_setStopCFM(btTranslationalLimitMotor* obj, const btScalar* value);
void btTranslationalLimitMotor_setStopERP(btTranslationalLimitMotor* obj, const btScalar* value);
void btTranslationalLimitMotor_setTargetVelocity(btTranslationalLimitMotor* obj, const btScalar* value);
void btTranslationalLimitMotor_setUpperLimit(btTranslationalLimitMotor* obj, const btScalar* value);
btScalar btTranslationalLimitMotor_solveLinearAxis(btTranslationalLimitMotor* obj, btScalar timeStep, btScalar jacDiagABInv, btRigidBody* body1, const btScalar* pointInA, btRigidBody* body2, const btScalar* pointInB, int limit_index, const btScalar* axis_normal_on_a, const btScalar* anchorPos);
int btTranslationalLimitMotor_testLimitValue(btTranslationalLimitMotor* obj, int limitIndex, btScalar test_value);
void btTranslationalLimitMotor_delete(btTranslationalLimitMotor* obj);
btGeneric6DofConstraint* btGeneric6DofConstraint_new(btRigidBody* rbA, btRigidBody* rbB, const btScalar* frameInA, const btScalar* frameInB, bool useLinearReferenceFrameA);
btGeneric6DofConstraint* btGeneric6DofConstraint_new2(btRigidBody* rbB, const btScalar* frameInB, bool useLinearReferenceFrameB);
void btGeneric6DofConstraint_calcAnchorPos(btGeneric6DofConstraint* obj);
void btGeneric6DofConstraint_calculateTransforms(btGeneric6DofConstraint* obj, const btScalar* transA, const btScalar* transB);
void btGeneric6DofConstraint_calculateTransforms2(btGeneric6DofConstraint* obj);
int btGeneric6DofConstraint_get_limit_motor_info2(btGeneric6DofConstraint* obj, btRotationalLimitMotor* limot, const btScalar* transA, const btScalar* transB, const btScalar* linVelA, const btScalar* linVelB, const btScalar* angVelA, const btScalar* angVelB, btTypedConstraint_btConstraintInfo2* info, int row, btScalar* ax1, int rotational);
int btGeneric6DofConstraint_get_limit_motor_info22(btGeneric6DofConstraint* obj, btRotationalLimitMotor* limot, const btScalar* transA, const btScalar* transB, const btScalar* linVelA, const btScalar* linVelB, const btScalar* angVelA, const btScalar* angVelB, btTypedConstraint_btConstraintInfo2* info, int row, btScalar* ax1, int rotational, int rotAllowed);
btScalar btGeneric6DofConstraint_getAngle(btGeneric6DofConstraint* obj, int axis_index);
void btGeneric6DofConstraint_getAngularLowerLimit(btGeneric6DofConstraint* obj, btScalar* angularLower);
void btGeneric6DofConstraint_getAngularUpperLimit(btGeneric6DofConstraint* obj, btScalar* angularUpper);
void btGeneric6DofConstraint_getAxis(btGeneric6DofConstraint* obj, int axis_index, btScalar* value);
void btGeneric6DofConstraint_getCalculatedTransformA(btGeneric6DofConstraint* obj, btScalar* value);
void btGeneric6DofConstraint_getCalculatedTransformB(btGeneric6DofConstraint* obj, btScalar* value);
void btGeneric6DofConstraint_getFrameOffsetA(btGeneric6DofConstraint* obj, btScalar* value);
void btGeneric6DofConstraint_getFrameOffsetB(btGeneric6DofConstraint* obj, btScalar* value);
void btGeneric6DofConstraint_getInfo1NonVirtual(btGeneric6DofConstraint* obj, btTypedConstraint_btConstraintInfo1* info);
void btGeneric6DofConstraint_getInfo2NonVirtual(btGeneric6DofConstraint* obj, btTypedConstraint_btConstraintInfo2* info, const btScalar* transA, const btScalar* transB, const btScalar* linVelA, const btScalar* linVelB, const btScalar* angVelA, const btScalar* angVelB);
void btGeneric6DofConstraint_getLinearLowerLimit(btGeneric6DofConstraint* obj, btScalar* linearLower);
void btGeneric6DofConstraint_getLinearUpperLimit(btGeneric6DofConstraint* obj, btScalar* linearUpper);
btScalar btGeneric6DofConstraint_getRelativePivotPosition(btGeneric6DofConstraint* obj, int axis_index);
btRotationalLimitMotor* btGeneric6DofConstraint_getRotationalLimitMotor(btGeneric6DofConstraint* obj, int index);
btTranslationalLimitMotor* btGeneric6DofConstraint_getTranslationalLimitMotor(btGeneric6DofConstraint* obj);
bool btGeneric6DofConstraint_getUseFrameOffset(btGeneric6DofConstraint* obj);
bool btGeneric6DofConstraint_getUseSolveConstraintObsolete(btGeneric6DofConstraint* obj);
bool btGeneric6DofConstraint_isLimited(btGeneric6DofConstraint* obj, int limitIndex);
void btGeneric6DofConstraint_setAngularLowerLimit(btGeneric6DofConstraint* obj, const btScalar* angularLower);
void btGeneric6DofConstraint_setAngularUpperLimit(btGeneric6DofConstraint* obj, const btScalar* angularUpper);
void btGeneric6DofConstraint_setAxis(btGeneric6DofConstraint* obj, const btScalar* axis1, const btScalar* axis2);
void btGeneric6DofConstraint_setFrames(btGeneric6DofConstraint* obj, const btScalar* frameA, const btScalar* frameB);
void btGeneric6DofConstraint_setLimit(btGeneric6DofConstraint* obj, int axis, btScalar lo, btScalar hi);
void btGeneric6DofConstraint_setLinearLowerLimit(btGeneric6DofConstraint* obj, const btScalar* linearLower);
void btGeneric6DofConstraint_setLinearUpperLimit(btGeneric6DofConstraint* obj, const btScalar* linearUpper);
void btGeneric6DofConstraint_setUseFrameOffset(btGeneric6DofConstraint* obj, bool frameOffsetOnOff);
void btGeneric6DofConstraint_setUseSolveConstraintObsolete(btGeneric6DofConstraint* obj, bool value);
bool btGeneric6DofConstraint_testAngularLimitMotor(btGeneric6DofConstraint* obj, int axis_index);
void btGeneric6DofConstraint_updateRHS(btGeneric6DofConstraint* obj, btScalar timeStep);
btRotationalLimitMotor2* btRotationalLimitMotor2_new();
btRotationalLimitMotor2* btRotationalLimitMotor2_new2(const btRotationalLimitMotor2* limot);
btScalar btRotationalLimitMotor2_getBounce(btRotationalLimitMotor2* obj);
int btRotationalLimitMotor2_getCurrentLimit(btRotationalLimitMotor2* obj);
btScalar btRotationalLimitMotor2_getCurrentLimitError(btRotationalLimitMotor2* obj);
btScalar btRotationalLimitMotor2_getCurrentLimitErrorHi(btRotationalLimitMotor2* obj);
btScalar btRotationalLimitMotor2_getCurrentPosition(btRotationalLimitMotor2* obj);
bool btRotationalLimitMotor2_getEnableMotor(btRotationalLimitMotor2* obj);
bool btRotationalLimitMotor2_getEnableSpring(btRotationalLimitMotor2* obj);
btScalar btRotationalLimitMotor2_getEquilibriumPoint(btRotationalLimitMotor2* obj);
btScalar btRotationalLimitMotor2_getHiLimit(btRotationalLimitMotor2* obj);
btScalar btRotationalLimitMotor2_getLoLimit(btRotationalLimitMotor2* obj);
btScalar btRotationalLimitMotor2_getMaxMotorForce(btRotationalLimitMotor2* obj);
btScalar btRotationalLimitMotor2_getMotorCFM(btRotationalLimitMotor2* obj);
btScalar btRotationalLimitMotor2_getMotorERP(btRotationalLimitMotor2* obj);
bool btRotationalLimitMotor2_getServoMotor(btRotationalLimitMotor2* obj);
btScalar btRotationalLimitMotor2_getServoTarget(btRotationalLimitMotor2* obj);
btScalar btRotationalLimitMotor2_getSpringDamping(btRotationalLimitMotor2* obj);
btScalar btRotationalLimitMotor2_getSpringStiffness(btRotationalLimitMotor2* obj);
btScalar btRotationalLimitMotor2_getStopCFM(btRotationalLimitMotor2* obj);
btScalar btRotationalLimitMotor2_getStopERP(btRotationalLimitMotor2* obj);
btScalar btRotationalLimitMotor2_getTargetVelocity(btRotationalLimitMotor2* obj);
bool btRotationalLimitMotor2_isLimited(btRotationalLimitMotor2* obj);
void btRotationalLimitMotor2_setBounce(btRotationalLimitMotor2* obj, btScalar value);
void btRotationalLimitMotor2_setCurrentLimit(btRotationalLimitMotor2* obj, int value);
void btRotationalLimitMotor2_setCurrentLimitError(btRotationalLimitMotor2* obj, btScalar value);
void btRotationalLimitMotor2_setCurrentLimitErrorHi(btRotationalLimitMotor2* obj, btScalar value);
void btRotationalLimitMotor2_setCurrentPosition(btRotationalLimitMotor2* obj, btScalar value);
void btRotationalLimitMotor2_setEnableMotor(btRotationalLimitMotor2* obj, bool value);
void btRotationalLimitMotor2_setEnableSpring(btRotationalLimitMotor2* obj, bool value);
void btRotationalLimitMotor2_setEquilibriumPoint(btRotationalLimitMotor2* obj, btScalar value);
void btRotationalLimitMotor2_setHiLimit(btRotationalLimitMotor2* obj, btScalar value);
void btRotationalLimitMotor2_setLoLimit(btRotationalLimitMotor2* obj, btScalar value);
void btRotationalLimitMotor2_setMaxMotorForce(btRotationalLimitMotor2* obj, btScalar value);
void btRotationalLimitMotor2_setMotorCFM(btRotationalLimitMotor2* obj, btScalar value);
void btRotationalLimitMotor2_setMotorERP(btRotationalLimitMotor2* obj, btScalar value);
void btRotationalLimitMotor2_setServoMotor(btRotationalLimitMotor2* obj, bool value);
void btRotationalLimitMotor2_setServoTarget(btRotationalLimitMotor2* obj, btScalar value);
void btRotationalLimitMotor2_setSpringDamping(btRotationalLimitMotor2* obj, btScalar value);
void btRotationalLimitMotor2_setSpringStiffness(btRotationalLimitMotor2* obj, btScalar value);
void btRotationalLimitMotor2_setStopCFM(btRotationalLimitMotor2* obj, btScalar value);
void btRotationalLimitMotor2_setStopERP(btRotationalLimitMotor2* obj, btScalar value);
void btRotationalLimitMotor2_setTargetVelocity(btRotationalLimitMotor2* obj, btScalar value);
void btRotationalLimitMotor2_testLimitValue(btRotationalLimitMotor2* obj, btScalar test_value);
void btRotationalLimitMotor2_delete(btRotationalLimitMotor2* obj);
btTranslationalLimitMotor2* btTranslationalLimitMotor2_new();
btTranslationalLimitMotor2* btTranslationalLimitMotor2_new2(const btTranslationalLimitMotor2* other);
void btTranslationalLimitMotor2_getBounce(btTranslationalLimitMotor2* obj, btScalar* value);
int* btTranslationalLimitMotor2_getCurrentLimit(btTranslationalLimitMotor2* obj);
void btTranslationalLimitMotor2_getCurrentLimitError(btTranslationalLimitMotor2* obj, btScalar* value);
void btTranslationalLimitMotor2_getCurrentLimitErrorHi(btTranslationalLimitMotor2* obj, btScalar* value);
void btTranslationalLimitMotor2_getCurrentLinearDiff(btTranslationalLimitMotor2* obj, btScalar* value);
bool* btTranslationalLimitMotor2_getEnableMotor(btTranslationalLimitMotor2* obj);
bool* btTranslationalLimitMotor2_getEnableSpring(btTranslationalLimitMotor2* obj);
void btTranslationalLimitMotor2_getEquilibriumPoint(btTranslationalLimitMotor2* obj, btScalar* value);
void btTranslationalLimitMotor2_getLowerLimit(btTranslationalLimitMotor2* obj, btScalar* value);
void btTranslationalLimitMotor2_getMaxMotorForce(btTranslationalLimitMotor2* obj, btScalar* value);
void btTranslationalLimitMotor2_getMotorCFM(btTranslationalLimitMotor2* obj, btScalar* value);
void btTranslationalLimitMotor2_getMotorERP(btTranslationalLimitMotor2* obj, btScalar* value);
bool* btTranslationalLimitMotor2_getServoMotor(btTranslationalLimitMotor2* obj);
void btTranslationalLimitMotor2_getServoTarget(btTranslationalLimitMotor2* obj, btScalar* value);
void btTranslationalLimitMotor2_getSpringDamping(btTranslationalLimitMotor2* obj, btScalar* value);
void btTranslationalLimitMotor2_getSpringStiffness(btTranslationalLimitMotor2* obj, btScalar* value);
void btTranslationalLimitMotor2_getStopCFM(btTranslationalLimitMotor2* obj, btScalar* value);
void btTranslationalLimitMotor2_getStopERP(btTranslationalLimitMotor2* obj, btScalar* value);
void btTranslationalLimitMotor2_getTargetVelocity(btTranslationalLimitMotor2* obj, btScalar* value);
void btTranslationalLimitMotor2_getUpperLimit(btTranslationalLimitMotor2* obj, btScalar* value);
bool btTranslationalLimitMotor2_isLimited(btTranslationalLimitMotor2* obj, int limitIndex);
void btTranslationalLimitMotor2_setBounce(btTranslationalLimitMotor2* obj, const btScalar* value);
void btTranslationalLimitMotor2_setCurrentLimitError(btTranslationalLimitMotor2* obj, const btScalar* value);
void btTranslationalLimitMotor2_setCurrentLimitErrorHi(btTranslationalLimitMotor2* obj, const btScalar* value);
void btTranslationalLimitMotor2_setCurrentLinearDiff(btTranslationalLimitMotor2* obj, const btScalar* value);
void btTranslationalLimitMotor2_setEquilibriumPoint(btTranslationalLimitMotor2* obj, const btScalar* value);
void btTranslationalLimitMotor2_setLowerLimit(btTranslationalLimitMotor2* obj, const btScalar* value);
void btTranslationalLimitMotor2_setMaxMotorForce(btTranslationalLimitMotor2* obj, const btScalar* value);
void btTranslationalLimitMotor2_setMotorCFM(btTranslationalLimitMotor2* obj, const btScalar* value);
void btTranslationalLimitMotor2_setMotorERP(btTranslationalLimitMotor2* obj, const btScalar* value);
void btTranslationalLimitMotor2_setServoTarget(btTranslationalLimitMotor2* obj, const btScalar* value);
void btTranslationalLimitMotor2_setSpringDamping(btTranslationalLimitMotor2* obj, const btScalar* value);
void btTranslationalLimitMotor2_setSpringStiffness(btTranslationalLimitMotor2* obj, const btScalar* value);
void btTranslationalLimitMotor2_setStopCFM(btTranslationalLimitMotor2* obj, const btScalar* value);
void btTranslationalLimitMotor2_setStopERP(btTranslationalLimitMotor2* obj, const btScalar* value);
void btTranslationalLimitMotor2_setTargetVelocity(btTranslationalLimitMotor2* obj, const btScalar* value);
void btTranslationalLimitMotor2_setUpperLimit(btTranslationalLimitMotor2* obj, const btScalar* value);
void btTranslationalLimitMotor2_testLimitValue(btTranslationalLimitMotor2* obj, int limitIndex, btScalar test_value);
void btTranslationalLimitMotor2_delete(btTranslationalLimitMotor2* obj);
btGeneric6DofSpring2Constraint* btGeneric6DofSpring2Constraint_new(btRigidBody* rbA, btRigidBody* rbB, const btScalar* frameInA, const btScalar* frameInB);
btGeneric6DofSpring2Constraint* btGeneric6DofSpring2Constraint_new2(btRigidBody* rbA, btRigidBody* rbB, const btScalar* frameInA, const btScalar* frameInB, RotateOrder rotOrder);
btGeneric6DofSpring2Constraint* btGeneric6DofSpring2Constraint_new3(btRigidBody* rbB, const btScalar* frameInB);
btGeneric6DofSpring2Constraint* btGeneric6DofSpring2Constraint_new4(btRigidBody* rbB, const btScalar* frameInB, RotateOrder rotOrder);
void btGeneric6DofSpring2Constraint_calculateTransforms(btGeneric6DofSpring2Constraint* obj, const btScalar* transA, const btScalar* transB);
void btGeneric6DofSpring2Constraint_calculateTransforms2(btGeneric6DofSpring2Constraint* obj);
void btGeneric6DofSpring2Constraint_enableMotor(btGeneric6DofSpring2Constraint* obj, int index, bool onOff);
void btGeneric6DofSpring2Constraint_enableSpring(btGeneric6DofSpring2Constraint* obj, int index, bool onOff);
btScalar btGeneric6DofSpring2Constraint_getAngle(btGeneric6DofSpring2Constraint* obj, int axis_index);
void btGeneric6DofSpring2Constraint_getAngularLowerLimit(btGeneric6DofSpring2Constraint* obj, btScalar* angularLower);
void btGeneric6DofSpring2Constraint_getAngularLowerLimitReversed(btGeneric6DofSpring2Constraint* obj, btScalar* angularLower);
void btGeneric6DofSpring2Constraint_getAngularUpperLimit(btGeneric6DofSpring2Constraint* obj, btScalar* angularUpper);
void btGeneric6DofSpring2Constraint_getAngularUpperLimitReversed(btGeneric6DofSpring2Constraint* obj, btScalar* angularUpper);
void btGeneric6DofSpring2Constraint_getAxis(btGeneric6DofSpring2Constraint* obj, int axis_index, btScalar* value);
void btGeneric6DofSpring2Constraint_getCalculatedTransformA(btGeneric6DofSpring2Constraint* obj, btScalar* value);
void btGeneric6DofSpring2Constraint_getCalculatedTransformB(btGeneric6DofSpring2Constraint* obj, btScalar* value);
void btGeneric6DofSpring2Constraint_getFrameOffsetA(btGeneric6DofSpring2Constraint* obj, btScalar* value);
void btGeneric6DofSpring2Constraint_getFrameOffsetB(btGeneric6DofSpring2Constraint* obj, btScalar* value);
void btGeneric6DofSpring2Constraint_getLinearLowerLimit(btGeneric6DofSpring2Constraint* obj, btScalar* linearLower);
void btGeneric6DofSpring2Constraint_getLinearUpperLimit(btGeneric6DofSpring2Constraint* obj, btScalar* linearUpper);
btScalar btGeneric6DofSpring2Constraint_getRelativePivotPosition(btGeneric6DofSpring2Constraint* obj, int axis_index);
btRotationalLimitMotor2* btGeneric6DofSpring2Constraint_getRotationalLimitMotor(btGeneric6DofSpring2Constraint* obj, int index);
RotateOrder btGeneric6DofSpring2Constraint_getRotationOrder(btGeneric6DofSpring2Constraint* obj);
btTranslationalLimitMotor2* btGeneric6DofSpring2Constraint_getTranslationalLimitMotor(btGeneric6DofSpring2Constraint* obj);
bool btGeneric6DofSpring2Constraint_isLimited(btGeneric6DofSpring2Constraint* obj, int limitIndex);
void btGeneric6DofSpring2Constraint_setAngularLowerLimit(btGeneric6DofSpring2Constraint* obj, const btScalar* angularLower);
void btGeneric6DofSpring2Constraint_setAngularLowerLimitReversed(btGeneric6DofSpring2Constraint* obj, const btScalar* angularLower);
void btGeneric6DofSpring2Constraint_setAngularUpperLimit(btGeneric6DofSpring2Constraint* obj, const btScalar* angularUpper);
void btGeneric6DofSpring2Constraint_setAngularUpperLimitReversed(btGeneric6DofSpring2Constraint* obj, const btScalar* angularUpper);
void btGeneric6DofSpring2Constraint_setAxis(btGeneric6DofSpring2Constraint* obj, const btScalar* axis1, const btScalar* axis2);
void btGeneric6DofSpring2Constraint_setBounce(btGeneric6DofSpring2Constraint* obj, int index, btScalar bounce);
void btGeneric6DofSpring2Constraint_setDamping(btGeneric6DofSpring2Constraint* obj, int index, btScalar damping);
void btGeneric6DofSpring2Constraint_setEquilibriumPoint(btGeneric6DofSpring2Constraint* obj);
void btGeneric6DofSpring2Constraint_setEquilibriumPoint2(btGeneric6DofSpring2Constraint* obj, int index, btScalar val);
void btGeneric6DofSpring2Constraint_setEquilibriumPoint3(btGeneric6DofSpring2Constraint* obj, int index);
void btGeneric6DofSpring2Constraint_setFrames(btGeneric6DofSpring2Constraint* obj, const btScalar* frameA, const btScalar* frameB);
void btGeneric6DofSpring2Constraint_setLimit(btGeneric6DofSpring2Constraint* obj, int axis, btScalar lo, btScalar hi);
void btGeneric6DofSpring2Constraint_setLimitReversed(btGeneric6DofSpring2Constraint* obj, int axis, btScalar lo, btScalar hi);
void btGeneric6DofSpring2Constraint_setLinearLowerLimit(btGeneric6DofSpring2Constraint* obj, const btScalar* linearLower);
void btGeneric6DofSpring2Constraint_setLinearUpperLimit(btGeneric6DofSpring2Constraint* obj, const btScalar* linearUpper);
void btGeneric6DofSpring2Constraint_setMaxMotorForce(btGeneric6DofSpring2Constraint* obj, int index, btScalar force);
void btGeneric6DofSpring2Constraint_setRotationOrder(btGeneric6DofSpring2Constraint* obj, RotateOrder order);
void btGeneric6DofSpring2Constraint_setServo(btGeneric6DofSpring2Constraint* obj, int index, bool onOff);
void btGeneric6DofSpring2Constraint_setServoTarget(btGeneric6DofSpring2Constraint* obj, int index, btScalar target);
void btGeneric6DofSpring2Constraint_setStiffness(btGeneric6DofSpring2Constraint* obj, int index, btScalar stiffness);
void btGeneric6DofSpring2Constraint_setTargetVelocity(btGeneric6DofSpring2Constraint* obj, int index, btScalar velocity);
btGeneric6DofSpringConstraint* btGeneric6DofSpringConstraint_new(btRigidBody* rbA, btRigidBody* rbB, const btScalar* frameInA, const btScalar* frameInB, bool useLinearReferenceFrameA);
btGeneric6DofSpringConstraint* btGeneric6DofSpringConstraint_new2(btRigidBody* rbB, const btScalar* frameInB, bool useLinearReferenceFrameB);
void btGeneric6DofSpringConstraint_enableSpring(btGeneric6DofSpringConstraint* obj, int index, bool onOff);
void btGeneric6DofSpringConstraint_setDamping(btGeneric6DofSpringConstraint* obj, int index, btScalar damping);
void btGeneric6DofSpringConstraint_setEquilibriumPoint(btGeneric6DofSpringConstraint* obj);
void btGeneric6DofSpringConstraint_setEquilibriumPoint2(btGeneric6DofSpringConstraint* obj, int index);
void btGeneric6DofSpringConstraint_setEquilibriumPoint3(btGeneric6DofSpringConstraint* obj, int index, btScalar val);
void btGeneric6DofSpringConstraint_setStiffness(btGeneric6DofSpringConstraint* obj, int index, btScalar stiffness);
bool btGeometryUtil_areVerticesBehindPlane(const btScalar* planeNormal, const btAlignedVector3Array* vertices, btScalar margin);
void btGeometryUtil_getPlaneEquationsFromVertices(btAlignedVector3Array* vertices, btAlignedVector3Array* planeEquationsOut);
void btGeometryUtil_getVerticesFromPlaneEquations(const btAlignedVector3Array* planeEquations, btAlignedVector3Array* verticesOut);
bool btGeometryUtil_isInside(const btAlignedVector3Array* vertices, const btScalar* planeNormal, btScalar margin);
bool btGeometryUtil_isPointInsidePlanes(const btAlignedVector3Array* planeEquations, const btScalar* point, btScalar margin);
btGhostObject* btGhostObject_new();
void btGhostObject_addOverlappingObjectInternal(btGhostObject* obj, btBroadphaseProxy* otherProxy);
void btGhostObject_addOverlappingObjectInternal2(btGhostObject* obj, btBroadphaseProxy* otherProxy, btBroadphaseProxy* thisProxy);
void btGhostObject_convexSweepTest(btGhostObject* obj, const btConvexShape* castShape, const btScalar* convexFromWorld, const btScalar* convexToWorld, btCollisionWorld_ConvexResultCallback* resultCallback);
void btGhostObject_convexSweepTest2(btGhostObject* obj, const btConvexShape* castShape, const btScalar* convexFromWorld, const btScalar* convexToWorld, btCollisionWorld_ConvexResultCallback* resultCallback, btScalar allowedCcdPenetration);
int btGhostObject_getNumOverlappingObjects(btGhostObject* obj);
btCollisionObject* btGhostObject_getOverlappingObject(btGhostObject* obj, int index);
btAlignedCollisionObjectArray* btGhostObject_getOverlappingPairs(btGhostObject* obj);
void btGhostObject_rayTest(btGhostObject* obj, const btScalar* rayFromWorld, const btScalar* rayToWorld, btCollisionWorld_RayResultCallback* resultCallback);
void btGhostObject_removeOverlappingObjectInternal(btGhostObject* obj, btBroadphaseProxy* otherProxy, btDispatcher* dispatcher);
void btGhostObject_removeOverlappingObjectInternal2(btGhostObject* obj, btBroadphaseProxy* otherProxy, btDispatcher* dispatcher, btBroadphaseProxy* thisProxy);
btGhostObject* btGhostObject_upcast(btCollisionObject* colObj);
btPairCachingGhostObject* btPairCachingGhostObject_new();
btHashedOverlappingPairCache* btPairCachingGhostObject_getOverlappingPairCache(btPairCachingGhostObject* obj);
btGhostPairCallback* btGhostPairCallback_new();
btGjkConvexCast* btGjkConvexCast_new(const btConvexShape* convexA, const btConvexShape* convexB, btVoronoiSimplexSolver* simplexSolver);
btGjkEpaPenetrationDepthSolver* btGjkEpaPenetrationDepthSolver_new();
btGjkPairDetector* btGjkPairDetector_new(const btConvexShape* objectA, const btConvexShape* objectB, btVoronoiSimplexSolver* simplexSolver, btConvexPenetrationDepthSolver* penetrationDepthSolver);
btGjkPairDetector* btGjkPairDetector_new2(const btConvexShape* objectA, const btConvexShape* objectB, int shapeTypeA, int shapeTypeB, btScalar marginA, btScalar marginB, btVoronoiSimplexSolver* simplexSolver, btConvexPenetrationDepthSolver* penetrationDepthSolver);
void btGjkPairDetector_getCachedSeparatingAxis(btGjkPairDetector* obj, btScalar* value);
btScalar btGjkPairDetector_getCachedSeparatingDistance(btGjkPairDetector* obj);
int btGjkPairDetector_getCatchDegeneracies(btGjkPairDetector* obj);
void btGjkPairDetector_getClosestPointsNonVirtual(btGjkPairDetector* obj, const btDiscreteCollisionDetectorInterface_ClosestPointInput* input, btDiscreteCollisionDetectorInterface_Result* output, btIDebugDraw* debugDraw);
int btGjkPairDetector_getCurIter(btGjkPairDetector* obj);
int btGjkPairDetector_getDegenerateSimplex(btGjkPairDetector* obj);
int btGjkPairDetector_getFixContactNormalDirection(btGjkPairDetector* obj);
int btGjkPairDetector_getLastUsedMethod(btGjkPairDetector* obj);
void btGjkPairDetector_setCachedSeparatingAxis(btGjkPairDetector* obj, const btScalar* seperatingAxis);
void btGjkPairDetector_setCatchDegeneracies(btGjkPairDetector* obj, int value);
void btGjkPairDetector_setCurIter(btGjkPairDetector* obj, int value);
void btGjkPairDetector_setDegenerateSimplex(btGjkPairDetector* obj, int value);
void btGjkPairDetector_setFixContactNormalDirection(btGjkPairDetector* obj, int value);
void btGjkPairDetector_setIgnoreMargin(btGjkPairDetector* obj, bool ignoreMargin);
void btGjkPairDetector_setLastUsedMethod(btGjkPairDetector* obj, int value);
void btGjkPairDetector_setMinkowskiA(btGjkPairDetector* obj, const btConvexShape* minkA);
void btGjkPairDetector_setMinkowskiB(btGjkPairDetector* obj, const btConvexShape* minkB);
void btGjkPairDetector_setPenetrationDepthSolver(btGjkPairDetector* obj, btConvexPenetrationDepthSolver* penetrationDepthSolver);
btHeightfieldTerrainShape* btHeightfieldTerrainShape_new(int heightStickWidth, int heightStickLength, const void* heightfieldData, btScalar heightScale, btScalar minHeight, btScalar maxHeight, int upAxis, PHY_ScalarType heightDataType, bool flipQuadEdges);
btHeightfieldTerrainShape* btHeightfieldTerrainShape_new2(int heightStickWidth, int heightStickLength, const void* heightfieldData, btScalar maxHeight, int upAxis, bool useFloatData, bool flipQuadEdges);
void btHeightfieldTerrainShape_setUseDiamondSubdivision(btHeightfieldTerrainShape* obj);
void btHeightfieldTerrainShape_setUseDiamondSubdivision2(btHeightfieldTerrainShape* obj, bool useDiamondSubdivision);
void btHeightfieldTerrainShape_setUseZigzagSubdivision(btHeightfieldTerrainShape* obj);
void btHeightfieldTerrainShape_setUseZigzagSubdivision2(btHeightfieldTerrainShape* obj, bool useZigzagSubdivision);
btHinge2Constraint* btHinge2Constraint_new(btRigidBody* rbA, btRigidBody* rbB, btScalar* anchor, btScalar* axis1, btScalar* axis2);
void btHinge2Constraint_getAnchor(btHinge2Constraint* obj, btScalar* value);
void btHinge2Constraint_getAnchor2(btHinge2Constraint* obj, btScalar* value);
btScalar btHinge2Constraint_getAngle1(btHinge2Constraint* obj);
btScalar btHinge2Constraint_getAngle2(btHinge2Constraint* obj);
void btHinge2Constraint_getAxis1(btHinge2Constraint* obj, btScalar* value);
void btHinge2Constraint_getAxis2(btHinge2Constraint* obj, btScalar* value);
void btHinge2Constraint_setLowerLimit(btHinge2Constraint* obj, btScalar ang1min);
void btHinge2Constraint_setUpperLimit(btHinge2Constraint* obj, btScalar ang1max);
btHingeConstraint* btHingeConstraint_new(btRigidBody* rbA, btRigidBody* rbB, const btScalar* pivotInA, const btScalar* pivotInB, const btScalar* axisInA, const btScalar* axisInB);
btHingeConstraint* btHingeConstraint_new2(btRigidBody* rbA, btRigidBody* rbB, const btScalar* pivotInA, const btScalar* pivotInB, const btScalar* axisInA, const btScalar* axisInB, bool useReferenceFrameA);
btHingeConstraint* btHingeConstraint_new3(btRigidBody* rbA, const btScalar* pivotInA, const btScalar* axisInA);
btHingeConstraint* btHingeConstraint_new4(btRigidBody* rbA, const btScalar* pivotInA, const btScalar* axisInA, bool useReferenceFrameA);
btHingeConstraint* btHingeConstraint_new5(btRigidBody* rbA, btRigidBody* rbB, const btScalar* rbAFrame, const btScalar* rbBFrame);
btHingeConstraint* btHingeConstraint_new6(btRigidBody* rbA, btRigidBody* rbB, const btScalar* rbAFrame, const btScalar* rbBFrame, bool useReferenceFrameA);
btHingeConstraint* btHingeConstraint_new7(btRigidBody* rbA, const btScalar* rbAFrame);
btHingeConstraint* btHingeConstraint_new8(btRigidBody* rbA, const btScalar* rbAFrame, bool useReferenceFrameA);
void btHingeConstraint_enableAngularMotor(btHingeConstraint* obj, bool enableMotor, btScalar targetVelocity, btScalar maxMotorImpulse);
void btHingeConstraint_enableMotor(btHingeConstraint* obj, bool enableMotor);
void btHingeConstraint_getAFrame(btHingeConstraint* obj, btScalar* value);
bool btHingeConstraint_getAngularOnly(btHingeConstraint* obj);
void btHingeConstraint_getBFrame(btHingeConstraint* obj, btScalar* value);
bool btHingeConstraint_getEnableAngularMotor(btHingeConstraint* obj);
void btHingeConstraint_getFrameOffsetA(btHingeConstraint* obj, btScalar* value);
void btHingeConstraint_getFrameOffsetB(btHingeConstraint* obj, btScalar* value);
btScalar btHingeConstraint_getHingeAngle(btHingeConstraint* obj, const btScalar* transA, const btScalar* transB);
btScalar btHingeConstraint_getHingeAngle2(btHingeConstraint* obj);
void btHingeConstraint_getInfo1NonVirtual(btHingeConstraint* obj, btTypedConstraint_btConstraintInfo1* info);
void btHingeConstraint_getInfo2Internal(btHingeConstraint* obj, btTypedConstraint_btConstraintInfo2* info, const btScalar* transA, const btScalar* transB, const btScalar* angVelA, const btScalar* angVelB);
void btHingeConstraint_getInfo2InternalUsingFrameOffset(btHingeConstraint* obj, btTypedConstraint_btConstraintInfo2* info, const btScalar* transA, const btScalar* transB, const btScalar* angVelA, const btScalar* angVelB);
void btHingeConstraint_getInfo2NonVirtual(btHingeConstraint* obj, btTypedConstraint_btConstraintInfo2* info, const btScalar* transA, const btScalar* transB, const btScalar* angVelA, const btScalar* angVelB);
btScalar btHingeConstraint_getLimitSign(btHingeConstraint* obj);
btScalar btHingeConstraint_getLowerLimit(btHingeConstraint* obj);
btScalar btHingeConstraint_getMaxMotorImpulse(btHingeConstraint* obj);
btScalar btHingeConstraint_getMotorTargetVelosity(btHingeConstraint* obj);
int btHingeConstraint_getSolveLimit(btHingeConstraint* obj);
btScalar btHingeConstraint_getUpperLimit(btHingeConstraint* obj);
bool btHingeConstraint_getUseFrameOffset(btHingeConstraint* obj);
bool btHingeConstraint_hasLimit(btHingeConstraint* obj);
void btHingeConstraint_setAngularOnly(btHingeConstraint* obj, bool angularOnly);
void btHingeConstraint_setAxis(btHingeConstraint* obj, btScalar* axisInA);
void btHingeConstraint_setFrames(btHingeConstraint* obj, const btScalar* frameA, const btScalar* frameB);
void btHingeConstraint_setLimit(btHingeConstraint* obj, btScalar low, btScalar high);
void btHingeConstraint_setLimit2(btHingeConstraint* obj, btScalar low, btScalar high, btScalar _softness);
void btHingeConstraint_setLimit3(btHingeConstraint* obj, btScalar low, btScalar high, btScalar _softness, btScalar _biasFactor);
void btHingeConstraint_setLimit4(btHingeConstraint* obj, btScalar low, btScalar high, btScalar _softness, btScalar _biasFactor, btScalar _relaxationFactor);
void btHingeConstraint_setMaxMotorImpulse(btHingeConstraint* obj, btScalar maxMotorImpulse);
void btHingeConstraint_setMotorTarget(btHingeConstraint* obj, btScalar targetAngle, btScalar dt);
void btHingeConstraint_setMotorTarget2(btHingeConstraint* obj, const btScalar* qAinB, btScalar dt);
void btHingeConstraint_setUseFrameOffset(btHingeConstraint* obj, bool frameOffsetOnOff);
void btHingeConstraint_testLimit(btHingeConstraint* obj, const btScalar* transA, const btScalar* transB);
void btHingeConstraint_updateRHS(btHingeConstraint* obj, btScalar timeStep);
btHingeAccumulatedAngleConstraint* btHingeAccumulatedAngleConstraint_new(btRigidBody* rbA, btRigidBody* rbB, const btScalar* pivotInA, const btScalar* pivotInB, const btScalar* axisInA, const btScalar* axisInB);
btHingeAccumulatedAngleConstraint* btHingeAccumulatedAngleConstraint_new2(btRigidBody* rbA, btRigidBody* rbB, const btScalar* pivotInA, const btScalar* pivotInB, const btScalar* axisInA, const btScalar* axisInB, bool useReferenceFrameA);
btHingeAccumulatedAngleConstraint* btHingeAccumulatedAngleConstraint_new3(btRigidBody* rbA, const btScalar* pivotInA, const btScalar* axisInA);
btHingeAccumulatedAngleConstraint* btHingeAccumulatedAngleConstraint_new4(btRigidBody* rbA, const btScalar* pivotInA, const btScalar* axisInA, bool useReferenceFrameA);
btHingeAccumulatedAngleConstraint* btHingeAccumulatedAngleConstraint_new5(btRigidBody* rbA, btRigidBody* rbB, const btScalar* rbAFrame, const btScalar* rbBFrame);
btHingeAccumulatedAngleConstraint* btHingeAccumulatedAngleConstraint_new6(btRigidBody* rbA, btRigidBody* rbB, const btScalar* rbAFrame, const btScalar* rbBFrame, bool useReferenceFrameA);
btHingeAccumulatedAngleConstraint* btHingeAccumulatedAngleConstraint_new7(btRigidBody* rbA, const btScalar* rbAFrame);
btHingeAccumulatedAngleConstraint* btHingeAccumulatedAngleConstraint_new8(btRigidBody* rbA, const btScalar* rbAFrame, bool useReferenceFrameA);
btScalar btHingeAccumulatedAngleConstraint_getAccumulatedHingeAngle(btHingeAccumulatedAngleConstraint* obj);
void btHingeAccumulatedAngleConstraint_setAccumulatedHingeAngle(btHingeAccumulatedAngleConstraint* obj, btScalar accAngle);
void* btIDebugDrawWrapper_getGCHandle(btIDebugDrawWrapper* obj);
void btIDebugDraw_delete(btIDebugDraw* obj);
btKinematicCharacterController* btKinematicCharacterController_new(btPairCachingGhostObject* ghostObject, btConvexShape* convexShape, btScalar stepHeight);
btKinematicCharacterController* btKinematicCharacterController_new2(btPairCachingGhostObject* ghostObject, btConvexShape* convexShape, btScalar stepHeight, int upAxis);
btPairCachingGhostObject* btKinematicCharacterController_getGhostObject(btKinematicCharacterController* obj);
btScalar btKinematicCharacterController_getGravity(btKinematicCharacterController* obj);
btScalar btKinematicCharacterController_getMaxSlope(btKinematicCharacterController* obj);
void btKinematicCharacterController_setFallSpeed(btKinematicCharacterController* obj, btScalar fallSpeed);
void btKinematicCharacterController_setGravity(btKinematicCharacterController* obj, btScalar gravity);
void btKinematicCharacterController_setJumpSpeed(btKinematicCharacterController* obj, btScalar jumpSpeed);
void btKinematicCharacterController_setMaxJumpHeight(btKinematicCharacterController* obj, btScalar maxJumpHeight);
void btKinematicCharacterController_setMaxSlope(btKinematicCharacterController* obj, btScalar slopeRadians);
void btKinematicCharacterController_setUpAxis(btKinematicCharacterController* obj, int axis);
void btKinematicCharacterController_setUseGhostSweepTest(btKinematicCharacterController* obj, bool useGhostObjectSweepTest);
btLemkeSolver* btLemkeSolver_new();
int btLemkeSolver_getDebugLevel(btLemkeSolver* obj);
int btLemkeSolver_getMaxLoops(btLemkeSolver* obj);
btScalar btLemkeSolver_getMaxValue(btLemkeSolver* obj);
bool btLemkeSolver_getUseLoHighBounds(btLemkeSolver* obj);
void btLemkeSolver_setDebugLevel(btLemkeSolver* obj, int value);
void btLemkeSolver_setMaxLoops(btLemkeSolver* obj, int value);
void btLemkeSolver_setMaxValue(btLemkeSolver* obj, btScalar value);
void btLemkeSolver_setUseLoHighBounds(btLemkeSolver* obj, bool value);
bool btMLCPSolverInterface_solveMLCP(btMLCPSolverInterface* obj, const btMatrixXf* A, const btVectorXf* b, btVectorXf* x, const btVectorXf* lo, const btVectorXf* hi, const btAlignedIntArray* limitDependency, int numIterations);
bool btMLCPSolverInterface_solveMLCP2(btMLCPSolverInterface* obj, const btMatrixXf* A, const btVectorXf* b, btVectorXf* x, const btVectorXf* lo, const btVectorXf* hi, const btAlignedIntArray* limitDependency, int numIterations, bool useSparsity);
void btMLCPSolverInterface_delete(btMLCPSolverInterface* obj);
btMLCPSolver* btMLCPSolver_new(btMLCPSolverInterface* solver);
btScalar btMLCPSolver_getCfm(btMLCPSolver* obj);
int btMLCPSolver_getNumFallbacks(btMLCPSolver* obj);
void btMLCPSolver_setCfm(btMLCPSolver* obj, btScalar cfm);
void btMLCPSolver_setMLCPSolver(btMLCPSolver* obj, btMLCPSolverInterface* solver);
void btMLCPSolver_setNumFallbacks(btMLCPSolver* obj, int num);
btConstraintRow* btConstraintRow_new();
btScalar btConstraintRow_getAccumImpulse(btConstraintRow* obj);
btScalar btConstraintRow_getJacDiagInv(btConstraintRow* obj);
btScalar btConstraintRow_getLowerLimit(btConstraintRow* obj);
void btConstraintRow_getNormal(btConstraintRow* obj, btScalar* value);
btScalar btConstraintRow_getRhs(btConstraintRow* obj);
btScalar btConstraintRow_getUpperLimit(btConstraintRow* obj);
void btConstraintRow_setAccumImpulse(btConstraintRow* obj, btScalar value);
void btConstraintRow_setJacDiagInv(btConstraintRow* obj, btScalar value);
void btConstraintRow_setLowerLimit(btConstraintRow* obj, btScalar value);
void btConstraintRow_setNormal(btConstraintRow* obj, btScalar* value);
void btConstraintRow_setRhs(btConstraintRow* obj, btScalar value);
void btConstraintRow_setUpperLimit(btConstraintRow* obj, btScalar value);
void btConstraintRow_delete(btConstraintRow* obj);
btManifoldPoint* btManifoldPoint_new();
btManifoldPoint* btManifoldPoint_new2(const btScalar* pointA, const btScalar* pointB, const btScalar* normal, btScalar distance);
btScalar btManifoldPoint_getAppliedImpulse(btManifoldPoint* obj);
btScalar btManifoldPoint_getAppliedImpulseLateral1(btManifoldPoint* obj);
btScalar btManifoldPoint_getAppliedImpulseLateral2(btManifoldPoint* obj);
btScalar btManifoldPoint_getCombinedFriction(btManifoldPoint* obj);
btScalar btManifoldPoint_getCombinedRestitution(btManifoldPoint* obj);
btScalar btManifoldPoint_getCombinedRollingFriction(btManifoldPoint* obj);
btScalar btManifoldPoint_getContactCFM1(btManifoldPoint* obj);
btScalar btManifoldPoint_getContactCFM2(btManifoldPoint* obj);
btScalar btManifoldPoint_getContactMotion1(btManifoldPoint* obj);
btScalar btManifoldPoint_getContactMotion2(btManifoldPoint* obj);
btScalar btManifoldPoint_getDistance(btManifoldPoint* obj);
btScalar btManifoldPoint_getDistance1(btManifoldPoint* obj);
int btManifoldPoint_getIndex0(btManifoldPoint* obj);
int btManifoldPoint_getIndex1(btManifoldPoint* obj);
void btManifoldPoint_getLateralFrictionDir1(btManifoldPoint* obj, btScalar* value);
void btManifoldPoint_getLateralFrictionDir2(btManifoldPoint* obj, btScalar* value);
bool btManifoldPoint_getLateralFrictionInitialized(btManifoldPoint* obj);
int btManifoldPoint_getLifeTime(btManifoldPoint* obj);
void btManifoldPoint_getLocalPointA(btManifoldPoint* obj, btScalar* value);
void btManifoldPoint_getLocalPointB(btManifoldPoint* obj, btScalar* value);
void btManifoldPoint_getNormalWorldOnB(btManifoldPoint* obj, btScalar* value);
int btManifoldPoint_getPartId0(btManifoldPoint* obj);
int btManifoldPoint_getPartId1(btManifoldPoint* obj);
void btManifoldPoint_getPositionWorldOnA(btManifoldPoint* obj, btScalar* value);
void btManifoldPoint_getPositionWorldOnB(btManifoldPoint* obj, btScalar* value);
void* btManifoldPoint_getUserPersistentData(btManifoldPoint* obj);
void btManifoldPoint_setAppliedImpulse(btManifoldPoint* obj, btScalar value);
void btManifoldPoint_setAppliedImpulseLateral1(btManifoldPoint* obj, btScalar value);
void btManifoldPoint_setAppliedImpulseLateral2(btManifoldPoint* obj, btScalar value);
void btManifoldPoint_setCombinedFriction(btManifoldPoint* obj, btScalar value);
void btManifoldPoint_setCombinedRestitution(btManifoldPoint* obj, btScalar value);
void btManifoldPoint_setCombinedRollingFriction(btManifoldPoint* obj, btScalar value);
void btManifoldPoint_setContactCFM1(btManifoldPoint* obj, btScalar value);
void btManifoldPoint_setContactCFM2(btManifoldPoint* obj, btScalar value);
void btManifoldPoint_setContactMotion1(btManifoldPoint* obj, btScalar value);
void btManifoldPoint_setContactMotion2(btManifoldPoint* obj, btScalar value);
void btManifoldPoint_setDistance(btManifoldPoint* obj, btScalar dist);
void btManifoldPoint_setDistance1(btManifoldPoint* obj, btScalar value);
void btManifoldPoint_setIndex0(btManifoldPoint* obj, int value);
void btManifoldPoint_setIndex1(btManifoldPoint* obj, int value);
void btManifoldPoint_setLateralFrictionDir1(btManifoldPoint* obj, const btScalar* value);
void btManifoldPoint_setLateralFrictionDir2(btManifoldPoint* obj, const btScalar* value);
void btManifoldPoint_setLateralFrictionInitialized(btManifoldPoint* obj, bool value);
void btManifoldPoint_setLifeTime(btManifoldPoint* obj, int value);
void btManifoldPoint_setLocalPointA(btManifoldPoint* obj, const btScalar* value);
void btManifoldPoint_setLocalPointB(btManifoldPoint* obj, const btScalar* value);
void btManifoldPoint_setNormalWorldOnB(btManifoldPoint* obj, const btScalar* value);
void btManifoldPoint_setPartId0(btManifoldPoint* obj, int value);
void btManifoldPoint_setPartId1(btManifoldPoint* obj, int value);
void btManifoldPoint_setPositionWorldOnA(btManifoldPoint* obj, const btScalar* value);
void btManifoldPoint_setPositionWorldOnB(btManifoldPoint* obj, const btScalar* value);
void btManifoldPoint_setUserPersistentData(btManifoldPoint* obj, void* value);
void btManifoldPoint_delete(btManifoldPoint* obj);
ContactAddedCallback getGContactAddedCallback();
void setGContactAddedCallback(ContactAddedCallback value);
btManifoldResult* btManifoldResult_new();
btManifoldResult* btManifoldResult_new2(const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap);
btScalar btManifoldResult_calculateCombinedFriction(const btCollisionObject* body0, const btCollisionObject* body1);
btScalar btManifoldResult_calculateCombinedRestitution(const btCollisionObject* body0, const btCollisionObject* body1);
const btCollisionObject* btManifoldResult_getBody0Internal(btManifoldResult* obj);
const btCollisionObjectWrapper* btManifoldResult_getBody0Wrap(btManifoldResult* obj);
const btCollisionObject* btManifoldResult_getBody1Internal(btManifoldResult* obj);
const btCollisionObjectWrapper* btManifoldResult_getBody1Wrap(btManifoldResult* obj);
btPersistentManifold* btManifoldResult_getPersistentManifold(btManifoldResult* obj);
void btManifoldResult_refreshContactPoints(btManifoldResult* obj);
void btManifoldResult_setBody0Wrap(btManifoldResult* obj, const btCollisionObjectWrapper* obj0Wrap);
void btManifoldResult_setBody1Wrap(btManifoldResult* obj, const btCollisionObjectWrapper* obj1Wrap);
void btManifoldResult_setPersistentManifold(btManifoldResult* obj, btPersistentManifold* manifoldPtr);
btMinkowskiPenetrationDepthSolver* btMinkowskiPenetrationDepthSolver_new();
btMinkowskiSumShape* btMinkowskiSumShape_new(const btConvexShape* shapeA, const btConvexShape* shapeB);
const btConvexShape* btMinkowskiSumShape_getShapeA(btMinkowskiSumShape* obj);
const btConvexShape* btMinkowskiSumShape_getShapeB(btMinkowskiSumShape* obj);
void btMinkowskiSumShape_getTransformA(btMinkowskiSumShape* obj, btScalar* transA);
void btMinkowskiSumShape_GetTransformB(btMinkowskiSumShape* obj, btScalar* transB);
void btMinkowskiSumShape_setTransformA(btMinkowskiSumShape* obj, const btScalar* transA);
void btMinkowskiSumShape_setTransformB(btMinkowskiSumShape* obj, const btScalar* transB);
btMotionStateWrapper* btMotionStateWrapper_new(pMotionState_GetWorldTransform getWorldTransformCallback, pMotionState_SetWorldTransform setWorldTransformCallback);
void btMotionState_getWorldTransform(btMotionState* obj, btScalar* worldTrans);
void btMotionState_setWorldTransform(btMotionState* obj, const btScalar* worldTrans);
void btMotionState_delete(btMotionState* obj);
btMultiBodyConstraintSolver* btMultiBodyConstraintSolver_new();
btScalar btMultiBodyConstraintSolver_solveGroupCacheFriendlyFinish(btMultiBodyConstraintSolver* obj, btCollisionObject** bodies, int numBodies, const btContactSolverInfo* infoGlobal);
void btMultiBodyConstraintSolver_solveMultiBodyGroup(btMultiBodyConstraintSolver* obj, btCollisionObject** bodies, int numBodies, btPersistentManifold** manifold, int numManifolds, btTypedConstraint** constraints, int numConstraints, btMultiBodyConstraint** multiBodyConstraints, int numMultiBodyConstraints, const btContactSolverInfo* info, btIDebugDraw* debugDrawer, btDispatcher* dispatcher);
void btMultiBodyConstraint_createConstraintRows(btMultiBodyConstraint* obj, btMultiBodyConstraintArray* constraintRows, btMultiBodyJacobianData* data, const btContactSolverInfo* infoGlobal);
void btMultiBodyConstraint_debugDraw(btMultiBodyConstraint* obj, btIDebugDraw* drawer);
int btMultiBodyConstraint_getIslandIdA(btMultiBodyConstraint* obj);
int btMultiBodyConstraint_getIslandIdB(btMultiBodyConstraint* obj);
btScalar btMultiBodyConstraint_getMaxAppliedImpulse(btMultiBodyConstraint* obj);
btMultiBody* btMultiBodyConstraint_getMultiBodyA(btMultiBodyConstraint* obj);
btMultiBody* btMultiBodyConstraint_getMultiBodyB(btMultiBodyConstraint* obj);
int btMultiBodyConstraint_getNumRows(btMultiBodyConstraint* obj);
btScalar btMultiBodyConstraint_getPosition(btMultiBodyConstraint* obj, int row);
bool btMultiBodyConstraint_isUnilateral(btMultiBodyConstraint* obj);
btScalar* btMultiBodyConstraint_jacobianA(btMultiBodyConstraint* obj, int row);
btScalar* btMultiBodyConstraint_jacobianB(btMultiBodyConstraint* obj, int row);
void btMultiBodyConstraint_setMaxAppliedImpulse(btMultiBodyConstraint* obj, btScalar maxImp);
void btMultiBodyConstraint_setPosition(btMultiBodyConstraint* obj, int row, btScalar pos);
void btMultiBodyConstraint_delete(btMultiBodyConstraint* obj);
btMultiBodyDynamicsWorld* btMultiBodyDynamicsWorld_new(btDispatcher* dispatcher, btBroadphaseInterface* pairCache, btMultiBodyConstraintSolver* constraintSolver, btCollisionConfiguration* collisionConfiguration);
void btMultiBodyDynamicsWorld_addMultiBody(btMultiBodyDynamicsWorld* obj, btMultiBody* body);
void btMultiBodyDynamicsWorld_addMultiBody2(btMultiBodyDynamicsWorld* obj, btMultiBody* body, short group);
void btMultiBodyDynamicsWorld_addMultiBody3(btMultiBodyDynamicsWorld* obj, btMultiBody* body, short group, short mask);
void btMultiBodyDynamicsWorld_addMultiBodyConstraint(btMultiBodyDynamicsWorld* obj, btMultiBodyConstraint* constraint);
void btMultiBodyDynamicsWorld_debugDrawMultiBodyConstraint(btMultiBodyDynamicsWorld* obj, btMultiBodyConstraint* constraint);
void btMultiBodyDynamicsWorld_integrateTransforms(btMultiBodyDynamicsWorld* obj, btScalar timeStep);
void btMultiBodyDynamicsWorld_removeMultiBody(btMultiBodyDynamicsWorld* obj, btMultiBody* body);
void btMultiBodyDynamicsWorld_removeMultiBodyConstraint(btMultiBodyDynamicsWorld* obj, btMultiBodyConstraint* constraint);
btMultiBodyJointLimitConstraint* btMultiBodyJointLimitConstraint_new(btMultiBody* body, int link, btScalar lower, btScalar upper);
btMultiBodyJointMotor* btMultiBodyJointMotor_new(btMultiBody* body, int link, btScalar desiredVelocity, btScalar maxMotorImpulse);
btMultiBodyJointMotor* btMultiBodyJointMotor_new2(btMultiBody* body, int link, int linkDoF, btScalar desiredVelocity, btScalar maxMotorImpulse);
void btMultiBodyJointMotor_setVelocityTarget(btMultiBodyJointMotor* obj, btScalar velTarget);
btMultiBodyLinkCollider* btMultiBodyLinkCollider_new(btMultiBody* multiBody, int link);
int btMultiBodyLinkCollider_getLink(btMultiBodyLinkCollider* obj);
btMultiBody* btMultiBodyLinkCollider_getMultiBody(btMultiBodyLinkCollider* obj);
void btMultiBodyLinkCollider_setLink(btMultiBodyLinkCollider* obj, int value);
void btMultiBodyLinkCollider_setMultiBody(btMultiBodyLinkCollider* obj, btMultiBody* value);
btMultiBodyLinkCollider* btMultiBodyLinkCollider_upcast(btCollisionObject* colObj);
btMultibodyLink* btMultibodyLink_new();
btSpatialMotionVector* btMultibodyLink_getAbsFrameLocVelocity(btMultibodyLink* obj);
btSpatialMotionVector* btMultibodyLink_getAbsFrameTotVelocity(btMultibodyLink* obj);
void btMultibodyLink_getAppliedForce(btMultibodyLink* obj, btScalar* value);
void btMultibodyLink_getAppliedTorque(btMultibodyLink* obj, btScalar* value);
btSpatialMotionVector* btMultibodyLink_getAxes(btMultibodyLink* obj);
void btMultibodyLink_getAxisBottom(btMultibodyLink* obj, int dof, btScalar* value);
void btMultibodyLink_getAxisTop(btMultibodyLink* obj, int dof, btScalar* value);
void btMultibodyLink_getCachedRotParentToThis(btMultibodyLink* obj, btScalar* value);
void btMultibodyLink_getCachedRVector(btMultibodyLink* obj, btScalar* value);
int btMultibodyLink_getCfgOffset(btMultibodyLink* obj);
btMultiBodyLinkCollider* btMultibodyLink_getCollider(btMultibodyLink* obj);
int btMultibodyLink_getDofCount(btMultibodyLink* obj);
int btMultibodyLink_getDofOffset(btMultibodyLink* obj);
void btMultibodyLink_getDVector(btMultibodyLink* obj, btScalar* value);
void btMultibodyLink_getEVector(btMultibodyLink* obj, btScalar* value);
int btMultibodyLink_getFlags(btMultibodyLink* obj);
void btMultibodyLink_getInertiaLocal(btMultibodyLink* obj, btScalar* value);
btScalar* btMultibodyLink_getJointPos(btMultibodyLink* obj);
btScalar* btMultibodyLink_getJointTorque(btMultibodyLink* obj);
eFeatherstoneJointType btMultibodyLink_getJointType(btMultibodyLink* obj);
btScalar btMultibodyLink_getMass(btMultibodyLink* obj);
int btMultibodyLink_getParent(btMultibodyLink* obj);
int btMultibodyLink_getPosVarCount(btMultibodyLink* obj);
void btMultibodyLink_getZeroRotParentToThis(btMultibodyLink* obj, btScalar* value);
void btMultibodyLink_setAbsFrameLocVelocity(btMultibodyLink* obj, const btSpatialMotionVector* value);
void btMultibodyLink_setAbsFrameTotVelocity(btMultibodyLink* obj, const btSpatialMotionVector* value);
void btMultibodyLink_setAppliedForce(btMultibodyLink* obj, const btScalar* value);
void btMultibodyLink_setAppliedTorque(btMultibodyLink* obj, const btScalar* value);
void btMultibodyLink_setAxisBottom(btMultibodyLink* obj, int dof, const btScalar* x, const btScalar* y, const btScalar* z);
void btMultibodyLink_setAxisBottom2(btMultibodyLink* obj, int dof, const btScalar* axis);
void btMultibodyLink_setAxisTop(btMultibodyLink* obj, int dof, const btScalar* axis);
void btMultibodyLink_setAxisTop2(btMultibodyLink* obj, int dof, const btScalar* x, const btScalar* y, const btScalar* z);
void btMultibodyLink_setCachedRotParentToThis(btMultibodyLink* obj, const btScalar* value);
void btMultibodyLink_setCachedRVector(btMultibodyLink* obj, const btScalar* value);
void btMultibodyLink_setCfgOffset(btMultibodyLink* obj, int value);
void btMultibodyLink_setCollider(btMultibodyLink* obj, btMultiBodyLinkCollider* value);
void btMultibodyLink_setDofCount(btMultibodyLink* obj, int value);
void btMultibodyLink_setDofOffset(btMultibodyLink* obj, int value);
void btMultibodyLink_setDVector(btMultibodyLink* obj, const btScalar* value);
void btMultibodyLink_setEVector(btMultibodyLink* obj, const btScalar* value);
void btMultibodyLink_setFlags(btMultibodyLink* obj, int value);
void btMultibodyLink_setInertiaLocal(btMultibodyLink* obj, const btScalar* value);
void btMultibodyLink_setJointType(btMultibodyLink* obj, eFeatherstoneJointType value);
void btMultibodyLink_setMass(btMultibodyLink* obj, btScalar value);
void btMultibodyLink_setParent(btMultibodyLink* obj, int value);
void btMultibodyLink_setPosVarCount(btMultibodyLink* obj, int value);
void btMultibodyLink_setZeroRotParentToThis(btMultibodyLink* obj, const btScalar* value);
void btMultibodyLink_updateCache(btMultibodyLink* obj);
void btMultibodyLink_updateCacheMultiDof(btMultibodyLink* obj);
void btMultibodyLink_updateCacheMultiDof2(btMultibodyLink* obj, btScalar* pq);
void btMultibodyLink_delete(btMultibodyLink* obj);
btMultiBodyPoint2Point* btMultiBodyPoint2Point_new(btMultiBody* body, int link, btRigidBody* bodyB, const btScalar* pivotInA, const btScalar* pivotInB);
btMultiBodyPoint2Point* btMultiBodyPoint2Point_new2(btMultiBody* bodyA, int linkA, btMultiBody* bodyB, int linkB, const btScalar* pivotInA, const btScalar* pivotInB);
void btMultiBodyPoint2Point_getPivotInB(btMultiBodyPoint2Point* obj, btScalar* pivotInB);
void btMultiBodyPoint2Point_setPivotInB(btMultiBodyPoint2Point* obj, const btScalar* pivotInB);
btMultiBodySolverConstraint* btMultiBodySolverConstraint_new();
void btMultiBodySolverConstraint_getAngularComponentA(btMultiBodySolverConstraint* obj, btScalar* value);
void btMultiBodySolverConstraint_getAngularComponentB(btMultiBodySolverConstraint* obj, btScalar* value);
btScalar btMultiBodySolverConstraint_getAppliedImpulse(btMultiBodySolverConstraint* obj);
btScalar btMultiBodySolverConstraint_getAppliedPushImpulse(btMultiBodySolverConstraint* obj);
btScalar btMultiBodySolverConstraint_getCfm(btMultiBodySolverConstraint* obj);
void btMultiBodySolverConstraint_getContactNormal1(btMultiBodySolverConstraint* obj, btScalar* value);
void btMultiBodySolverConstraint_getContactNormal2(btMultiBodySolverConstraint* obj, btScalar* value);
int btMultiBodySolverConstraint_getDeltaVelAindex(btMultiBodySolverConstraint* obj);
int btMultiBodySolverConstraint_getDeltaVelBindex(btMultiBodySolverConstraint* obj);
btScalar btMultiBodySolverConstraint_getFriction(btMultiBodySolverConstraint* obj);
int btMultiBodySolverConstraint_getFrictionIndex(btMultiBodySolverConstraint* obj);
int btMultiBodySolverConstraint_getJacAindex(btMultiBodySolverConstraint* obj);
int btMultiBodySolverConstraint_getJacBindex(btMultiBodySolverConstraint* obj);
btScalar btMultiBodySolverConstraint_getJacDiagABInv(btMultiBodySolverConstraint* obj);
int btMultiBodySolverConstraint_getLinkA(btMultiBodySolverConstraint* obj);
int btMultiBodySolverConstraint_getLinkB(btMultiBodySolverConstraint* obj);
btScalar btMultiBodySolverConstraint_getLowerLimit(btMultiBodySolverConstraint* obj);
btMultiBody* btMultiBodySolverConstraint_getMultiBodyA(btMultiBodySolverConstraint* obj);
btMultiBody* btMultiBodySolverConstraint_getMultiBodyB(btMultiBodySolverConstraint* obj);
void* btMultiBodySolverConstraint_getOriginalContactPoint(btMultiBodySolverConstraint* obj);
int btMultiBodySolverConstraint_getOverrideNumSolverIterations(btMultiBodySolverConstraint* obj);
void btMultiBodySolverConstraint_getRelpos1CrossNormal(btMultiBodySolverConstraint* obj, btScalar* value);
void btMultiBodySolverConstraint_getRelpos2CrossNormal(btMultiBodySolverConstraint* obj, btScalar* value);
btScalar btMultiBodySolverConstraint_getRhs(btMultiBodySolverConstraint* obj);
btScalar btMultiBodySolverConstraint_getRhsPenetration(btMultiBodySolverConstraint* obj);
int btMultiBodySolverConstraint_getSolverBodyIdA(btMultiBodySolverConstraint* obj);
int btMultiBodySolverConstraint_getSolverBodyIdB(btMultiBodySolverConstraint* obj);
btScalar btMultiBodySolverConstraint_getUnusedPadding4(btMultiBodySolverConstraint* obj);
btScalar btMultiBodySolverConstraint_getUpperLimit(btMultiBodySolverConstraint* obj);
void btMultiBodySolverConstraint_setAngularComponentA(btMultiBodySolverConstraint* obj, const btScalar* value);
void btMultiBodySolverConstraint_setAngularComponentB(btMultiBodySolverConstraint* obj, const btScalar* value);
void btMultiBodySolverConstraint_setAppliedImpulse(btMultiBodySolverConstraint* obj, btScalar value);
void btMultiBodySolverConstraint_setAppliedPushImpulse(btMultiBodySolverConstraint* obj, btScalar value);
void btMultiBodySolverConstraint_setCfm(btMultiBodySolverConstraint* obj, btScalar value);
void btMultiBodySolverConstraint_setContactNormal1(btMultiBodySolverConstraint* obj, const btScalar* value);
void btMultiBodySolverConstraint_setContactNormal2(btMultiBodySolverConstraint* obj, const btScalar* value);
void btMultiBodySolverConstraint_setDeltaVelAindex(btMultiBodySolverConstraint* obj, int value);
void btMultiBodySolverConstraint_setDeltaVelBindex(btMultiBodySolverConstraint* obj, int value);
void btMultiBodySolverConstraint_setFriction(btMultiBodySolverConstraint* obj, btScalar value);
void btMultiBodySolverConstraint_setFrictionIndex(btMultiBodySolverConstraint* obj, int value);
void btMultiBodySolverConstraint_setJacAindex(btMultiBodySolverConstraint* obj, int value);
void btMultiBodySolverConstraint_setJacBindex(btMultiBodySolverConstraint* obj, int value);
void btMultiBodySolverConstraint_setJacDiagABInv(btMultiBodySolverConstraint* obj, btScalar value);
void btMultiBodySolverConstraint_setLinkA(btMultiBodySolverConstraint* obj, int value);
void btMultiBodySolverConstraint_setLinkB(btMultiBodySolverConstraint* obj, int value);
void btMultiBodySolverConstraint_setLowerLimit(btMultiBodySolverConstraint* obj, btScalar value);
void btMultiBodySolverConstraint_setMultiBodyA(btMultiBodySolverConstraint* obj, btMultiBody* value);
void btMultiBodySolverConstraint_setMultiBodyB(btMultiBodySolverConstraint* obj, btMultiBody* value);
void btMultiBodySolverConstraint_setOriginalContactPoint(btMultiBodySolverConstraint* obj, void* value);
void btMultiBodySolverConstraint_setOverrideNumSolverIterations(btMultiBodySolverConstraint* obj, int value);
void btMultiBodySolverConstraint_setRelpos1CrossNormal(btMultiBodySolverConstraint* obj, const btScalar* value);
void btMultiBodySolverConstraint_setRelpos2CrossNormal(btMultiBodySolverConstraint* obj, const btScalar* value);
void btMultiBodySolverConstraint_setRhs(btMultiBodySolverConstraint* obj, btScalar value);
void btMultiBodySolverConstraint_setRhsPenetration(btMultiBodySolverConstraint* obj, btScalar value);
void btMultiBodySolverConstraint_setSolverBodyIdA(btMultiBodySolverConstraint* obj, int value);
void btMultiBodySolverConstraint_setSolverBodyIdB(btMultiBodySolverConstraint* obj, int value);
void btMultiBodySolverConstraint_setUnusedPadding4(btMultiBodySolverConstraint* obj, btScalar value);
void btMultiBodySolverConstraint_setUpperLimit(btMultiBodySolverConstraint* obj, btScalar value);
void btMultiBodySolverConstraint_delete(btMultiBodySolverConstraint* obj);
btMultiBody* btMultiBody_new(int n_links, btScalar mass, const btScalar* inertia, bool fixedBase, bool canSleep);
btMultiBody* btMultiBody_new2(int n_links, btScalar mass, const btScalar* inertia, bool fixedBase, bool canSleep, bool multiDof);
void btMultiBody_addBaseForce(btMultiBody* obj, const btScalar* f);
void btMultiBody_addBaseTorque(btMultiBody* obj, const btScalar* t);
void btMultiBody_addJointTorque(btMultiBody* obj, int i, btScalar Q);
void btMultiBody_addJointTorqueMultiDof(btMultiBody* obj, int i, const btScalar* Q);
void btMultiBody_addJointTorqueMultiDof2(btMultiBody* obj, int i, int dof, btScalar Q);
void btMultiBody_addLinkForce(btMultiBody* obj, int i, const btScalar* f);
void btMultiBody_addLinkTorque(btMultiBody* obj, int i, const btScalar* t);
void btMultiBody_applyDeltaVee(btMultiBody* obj, const btScalar* delta_vee, btScalar multiplier);
void btMultiBody_applyDeltaVee2(btMultiBody* obj, const btScalar* delta_vee);
void btMultiBody_applyDeltaVeeMultiDof(btMultiBody* obj, const btScalar* delta_vee, btScalar multiplier);
void btMultiBody_calcAccelerationDeltas(btMultiBody* obj, const btScalar* force, btScalar* output, btAlignedScalarArray* scratch_r, btAlignedVector3Array* scratch_v);
void btMultiBody_calcAccelerationDeltasMultiDof(btMultiBody* obj, const btScalar* force, btScalar* output, btAlignedScalarArray* scratch_r, btAlignedVector3Array* scratch_v);
void btMultiBody_checkMotionAndSleepIfRequired(btMultiBody* obj, btScalar timestep);
void btMultiBody_clearForcesAndTorques(btMultiBody* obj);
void btMultiBody_clearVelocities(btMultiBody* obj);
void btMultiBody_filConstraintJacobianMultiDof(btMultiBody* obj, int link, const btScalar* contact_point, const btScalar* normal_ang, const btScalar* normal_lin, btScalar* jac, btAlignedScalarArray* scratch_r, btAlignedVector3Array* scratch_v, btAlignedMatrix3x3Array* scratch_m);
void btMultiBody_fillContactJacobian(btMultiBody* obj, int link, const btScalar* contact_point, const btScalar* normal, btScalar* jac, btAlignedScalarArray* scratch_r, btAlignedVector3Array* scratch_v, btAlignedMatrix3x3Array* scratch_m);
void btMultiBody_fillContactJacobianMultiDof(btMultiBody* obj, int link, const btScalar* contact_point, const btScalar* normal, btScalar* jac, btAlignedScalarArray* scratch_r, btAlignedVector3Array* scratch_v, btAlignedMatrix3x3Array* scratch_m);
void btMultiBody_finalizeMultiDof(btMultiBody* obj);
btScalar btMultiBody_getAngularDamping(btMultiBody* obj);
void btMultiBody_getAngularMomentum(btMultiBody* obj, btScalar* value);
btMultiBodyLinkCollider* btMultiBody_getBaseCollider(btMultiBody* obj);
void btMultiBody_getBaseForce(btMultiBody* obj, btScalar* value);
void btMultiBody_getBaseInertia(btMultiBody* obj, btScalar* inertia);
btScalar btMultiBody_getBaseMass(btMultiBody* obj);
void btMultiBody_getBaseOmega(btMultiBody* obj, btScalar* omega);
void btMultiBody_getBasePos(btMultiBody* obj, btScalar* pos);
void btMultiBody_getBaseTorque(btMultiBody* obj, btScalar* value);
void btMultiBody_getBaseVel(btMultiBody* obj, btScalar* vel);
bool btMultiBody_getCanSleep(btMultiBody* obj);
int btMultiBody_getCompanionId(btMultiBody* obj);
btScalar btMultiBody_getJointPos(btMultiBody* obj, int i);
btScalar* btMultiBody_getJointPosMultiDof(btMultiBody* obj, int i);
btScalar btMultiBody_getJointTorque(btMultiBody* obj, int i);
btScalar* btMultiBody_getJointTorqueMultiDof(btMultiBody* obj, int i);
btScalar btMultiBody_getJointVel(btMultiBody* obj, int i);
btScalar* btMultiBody_getJointVelMultiDof(btMultiBody* obj, int i);
btScalar btMultiBody_getKineticEnergy(btMultiBody* obj);
btScalar btMultiBody_getLinearDamping(btMultiBody* obj);
btMultibodyLink* btMultiBody_getLink(btMultiBody* obj, int index);
void btMultiBody_getLinkForce(btMultiBody* obj, int i, btScalar* value);
void btMultiBody_getLinkInertia(btMultiBody* obj, int i, btScalar* value);
btScalar btMultiBody_getLinkMass(btMultiBody* obj, int i);
void btMultiBody_getLinkTorque(btMultiBody* obj, int i, btScalar* value);
btScalar btMultiBody_getMaxAppliedImpulse(btMultiBody* obj);
btScalar btMultiBody_getMaxCoordinateVelocity(btMultiBody* obj);
int btMultiBody_getNumDofs(btMultiBody* obj);
int btMultiBody_getNumLinks(btMultiBody* obj);
int btMultiBody_getNumPosVars(btMultiBody* obj);
int btMultiBody_getParent(btMultiBody* obj, int link_num);
void btMultiBody_getParentToLocalRot(btMultiBody* obj, int i, btScalar* value);
void btMultiBody_getRVector(btMultiBody* obj, int i, btScalar* value);
bool btMultiBody_getUseGyroTerm(btMultiBody* obj);
const btScalar* btMultiBody_getVelocityVector(btMultiBody* obj);
void btMultiBody_getWorldToBaseRot(btMultiBody* obj, btScalar* rot);
void btMultiBody_goToSleep(btMultiBody* obj);
bool btMultiBody_hasFixedBase(btMultiBody* obj);
bool btMultiBody_hasSelfCollision(btMultiBody* obj);
bool btMultiBody_isAwake(btMultiBody* obj);
bool btMultiBody_isMultiDof(btMultiBody* obj);
bool btMultiBody_isPosUpdated(btMultiBody* obj);
bool btMultiBody_isUsingGlobalVelocities(btMultiBody* obj);
bool btMultiBody_isUsingRK4Integration(btMultiBody* obj);
void btMultiBody_localDirToWorld(btMultiBody* obj, int i, const btScalar* vec, btScalar* value);
void btMultiBody_localPosToWorld(btMultiBody* obj, int i, const btScalar* vec, btScalar* value);
void btMultiBody_setAngularDamping(btMultiBody* obj, btScalar damp);
void btMultiBody_setBaseCollider(btMultiBody* obj, btMultiBodyLinkCollider* collider);
void btMultiBody_setBaseInertia(btMultiBody* obj, const btScalar* inertia);
void btMultiBody_setBaseMass(btMultiBody* obj, btScalar mass);
void btMultiBody_setBaseOmega(btMultiBody* obj, const btScalar* omega);
void btMultiBody_setBasePos(btMultiBody* obj, const btScalar* pos);
void btMultiBody_setBaseVel(btMultiBody* obj, const btScalar* vel);
void btMultiBody_setCanSleep(btMultiBody* obj, bool canSleep);
void btMultiBody_setCompanionId(btMultiBody* obj, int id);
void btMultiBody_setHasSelfCollision(btMultiBody* obj, bool hasSelfCollision);
void btMultiBody_setJointPos(btMultiBody* obj, int i, btScalar q);
void btMultiBody_setJointPosMultiDof(btMultiBody* obj, int i, btScalar* q);
void btMultiBody_setJointVel(btMultiBody* obj, int i, btScalar qdot);
void btMultiBody_setJointVelMultiDof(btMultiBody* obj, int i, btScalar* qdot);
void btMultiBody_setLinearDamping(btMultiBody* obj, btScalar damp);
void btMultiBody_setMaxAppliedImpulse(btMultiBody* obj, btScalar maxImp);
void btMultiBody_setMaxCoordinateVelocity(btMultiBody* obj, btScalar maxVel);
void btMultiBody_setNumLinks(btMultiBody* obj, int numLinks);
void btMultiBody_setPosUpdated(btMultiBody* obj, bool updated);
void btMultiBody_setupFixed(btMultiBody* obj, int linkIndex, btScalar mass, const btScalar* inertia, int parent, const btScalar* rotParentToThis, const btScalar* parentComToThisPivotOffset, const btScalar* thisPivotToThisComOffset, bool disableParentCollision);
void btMultiBody_setupPlanar(btMultiBody* obj, int i, btScalar mass, const btScalar* inertia, int parent, const btScalar* rotParentToThis, const btScalar* rotationAxis, const btScalar* parentComToThisComOffset);
void btMultiBody_setupPlanar2(btMultiBody* obj, int i, btScalar mass, const btScalar* inertia, int parent, const btScalar* rotParentToThis, const btScalar* rotationAxis, const btScalar* parentComToThisComOffset, bool disableParentCollision);
void btMultiBody_setupPrismatic(btMultiBody* obj, int i, btScalar mass, const btScalar* inertia, int parent, const btScalar* rotParentToThis, const btScalar* jointAxis, const btScalar* parentComToThisComOffset, const btScalar* thisPivotToThisComOffset, bool disableParentCollision);
void btMultiBody_setupRevolute(btMultiBody* obj, int linkIndex, btScalar mass, const btScalar* inertia, int parentIndex, const btScalar* rotParentToThis, const btScalar* jointAxis, const btScalar* parentComToThisPivotOffset, const btScalar* thisPivotToThisComOffset);
void btMultiBody_setupRevolute2(btMultiBody* obj, int linkIndex, btScalar mass, const btScalar* inertia, int parentIndex, const btScalar* rotParentToThis, const btScalar* jointAxis, const btScalar* parentComToThisPivotOffset, const btScalar* thisPivotToThisComOffset, bool disableParentCollision);
void btMultiBody_setupSpherical(btMultiBody* obj, int linkIndex, btScalar mass, const btScalar* inertia, int parent, const btScalar* rotParentToThis, const btScalar* parentComToThisPivotOffset, const btScalar* thisPivotToThisComOffset);
void btMultiBody_setupSpherical2(btMultiBody* obj, int linkIndex, btScalar mass, const btScalar* inertia, int parent, const btScalar* rotParentToThis, const btScalar* parentComToThisPivotOffset, const btScalar* thisPivotToThisComOffset, bool disableParentCollision);
void btMultiBody_setUseGyroTerm(btMultiBody* obj, bool useGyro);
void btMultiBody_setWorldToBaseRot(btMultiBody* obj, const btScalar* rot);
void btMultiBody_stepPositions(btMultiBody* obj, btScalar dt);
void btMultiBody_stepPositionsMultiDof(btMultiBody* obj, btScalar dt);
void btMultiBody_stepPositionsMultiDof2(btMultiBody* obj, btScalar dt, btScalar* pq);
void btMultiBody_stepPositionsMultiDof3(btMultiBody* obj, btScalar dt, btScalar* pq, btScalar* pqd);
void btMultiBody_stepVelocities(btMultiBody* obj, btScalar dt, btAlignedScalarArray* scratch_r, btAlignedVector3Array* scratch_v, btAlignedMatrix3x3Array* scratch_m);
void btMultiBody_stepVelocitiesMultiDof(btMultiBody* obj, btScalar dt, btAlignedScalarArray* scratch_r, btAlignedVector3Array* scratch_v, btAlignedMatrix3x3Array* scratch_m);
void btMultiBody_useGlobalVelocities(btMultiBody* obj, bool use);
void btMultiBody_useRK4Integration(btMultiBody* obj, bool use);
void btMultiBody_wakeUp(btMultiBody* obj);
void btMultiBody_worldDirToLocal(btMultiBody* obj, int i, const btScalar* vec, btScalar* value);
void btMultiBody_worldPosToLocal(btMultiBody* obj, int i, const btScalar* vec, btScalar* value);
void btMultiBody_delete(btMultiBody* obj);
btMultiSphereShape* btMultiSphereShape_new(const btScalar* positions, const btScalar* radi, int numSpheres);
btMultiSphereShape* btMultiSphereShape_new2(const btVector3* positions, const btScalar* radi, int numSpheres);
int btMultiSphereShape_getSphereCount(btMultiSphereShape* obj);
void btMultiSphereShape_getSpherePosition(btMultiSphereShape* obj, int index, btScalar* value);
btScalar btMultiSphereShape_getSphereRadius(btMultiSphereShape* obj, int index);
btPositionAndRadius* btPositionAndRadius_new();
void btPositionAndRadius_getPos(btPositionAndRadius* obj, btScalar* value);
float btPositionAndRadius_getRadius(btPositionAndRadius* obj);
void btPositionAndRadius_setPos(btPositionAndRadius* obj, const btScalar* value);
void btPositionAndRadius_setRadius(btPositionAndRadius* obj, float value);
void btPositionAndRadius_delete(btPositionAndRadius* obj);
btMultimaterialTriangleMeshShape* btMultimaterialTriangleMeshShape_new(btStridingMeshInterface* meshInterface, bool useQuantizedAabbCompression);
btMultimaterialTriangleMeshShape* btMultimaterialTriangleMeshShape_new2(btStridingMeshInterface* meshInterface, bool useQuantizedAabbCompression, bool buildBvh);
btMultimaterialTriangleMeshShape* btMultimaterialTriangleMeshShape_new3(btStridingMeshInterface* meshInterface, bool useQuantizedAabbCompression, const btScalar* bvhAabbMin, const btScalar* bvhAabbMax);
btMultimaterialTriangleMeshShape* btMultimaterialTriangleMeshShape_new4(btStridingMeshInterface* meshInterface, bool useQuantizedAabbCompression, const btScalar* bvhAabbMin, const btScalar* bvhAabbMax, bool buildBvh);
const btMaterial* btMultimaterialTriangleMeshShape_getMaterialProperties(btMultimaterialTriangleMeshShape* obj, int partID, int triIndex);
btNNCGConstraintSolver* btNNCGConstraintSolver_new();
bool btNNCGConstraintSolver_getOnlyForNoneContact(btNNCGConstraintSolver* obj);
void btNNCGConstraintSolver_setOnlyForNoneContact(btNNCGConstraintSolver* obj, bool value);
btOptimizedBvh* btOptimizedBvh_new();
void btOptimizedBvh_build(btOptimizedBvh* obj, btStridingMeshInterface* triangles, bool useQuantizedAabbCompression, const btScalar* bvhAabbMin, const btScalar* bvhAabbMax);
btOptimizedBvh* btOptimizedBvh_deSerializeInPlace(void* i_alignedDataBuffer, unsigned int i_dataBufferSize, bool i_swapEndian);
void btOptimizedBvh_refit(btOptimizedBvh* obj, btStridingMeshInterface* triangles, const btScalar* aabbMin, const btScalar* aabbMax);
void btOptimizedBvh_refitPartial(btOptimizedBvh* obj, btStridingMeshInterface* triangles, const btScalar* aabbMin, const btScalar* aabbMax);
bool btOptimizedBvh_serializeInPlace(btOptimizedBvh* obj, void* o_alignedDataBuffer, unsigned int i_dataBufferSize, bool i_swapEndian);
void btOptimizedBvh_updateBvhNodes(btOptimizedBvh* obj, btStridingMeshInterface* meshInterface, int firstNode, int endNode, int index);
bool btOverlapCallback_processOverlap(btOverlapCallback* obj, btBroadphasePair* pair);
void btOverlapCallback_delete(btOverlapCallback* obj);
bool btOverlapFilterCallback_needBroadphaseCollision(btOverlapFilterCallback* obj, btBroadphaseProxy* proxy0, btBroadphaseProxy* proxy1);
void btOverlapFilterCallback_delete(btOverlapFilterCallback* obj);
void btOverlappingPairCache_cleanOverlappingPair(btOverlappingPairCache* obj, btBroadphasePair* pair, btDispatcher* dispatcher);
void btOverlappingPairCache_cleanProxyFromPairs(btOverlappingPairCache* obj, btBroadphaseProxy* proxy, btDispatcher* dispatcher);
btBroadphasePair* btOverlappingPairCache_findPair(btOverlappingPairCache* obj, btBroadphaseProxy* proxy0, btBroadphaseProxy* proxy1);
int btOverlappingPairCache_getNumOverlappingPairs(btOverlappingPairCache* obj);
btAlignedBroadphasePairArray* btOverlappingPairCache_getOverlappingPairArray(btOverlappingPairCache* obj);
btBroadphasePair* btOverlappingPairCache_getOverlappingPairArrayPtr(btOverlappingPairCache* obj);
bool btOverlappingPairCache_hasDeferredRemoval(btOverlappingPairCache* obj);
void btOverlappingPairCache_processAllOverlappingPairs(btOverlappingPairCache* obj, btOverlapCallback* __unnamed0, btDispatcher* dispatcher);
void btOverlappingPairCache_setInternalGhostPairCallback(btOverlappingPairCache* obj, btOverlappingPairCallback* ghostPairCallback);
void btOverlappingPairCache_setOverlapFilterCallback(btOverlappingPairCache* obj, btOverlapFilterCallback* callback);
void btOverlappingPairCache_sortOverlappingPairs(btOverlappingPairCache* obj, btDispatcher* dispatcher);
btHashedOverlappingPairCache* btHashedOverlappingPairCache_new();
int btHashedOverlappingPairCache_GetCount(btHashedOverlappingPairCache* obj);
btOverlapFilterCallback* btHashedOverlappingPairCache_getOverlapFilterCallback(btHashedOverlappingPairCache* obj);
bool btHashedOverlappingPairCache_needsBroadphaseCollision(btHashedOverlappingPairCache* obj, btBroadphaseProxy* proxy0, btBroadphaseProxy* proxy1);
btSortedOverlappingPairCache* btSortedOverlappingPairCache_new();
btOverlapFilterCallback* btSortedOverlappingPairCache_getOverlapFilterCallback(btSortedOverlappingPairCache* obj);
bool btSortedOverlappingPairCache_needsBroadphaseCollision(btSortedOverlappingPairCache* obj, btBroadphaseProxy* proxy0, btBroadphaseProxy* proxy1);
btNullPairCache* btNullPairCache_new();
btBroadphasePair* btOverlappingPairCallback_addOverlappingPair(btOverlappingPairCallback* obj, btBroadphaseProxy* proxy0, btBroadphaseProxy* proxy1);
void* btOverlappingPairCallback_removeOverlappingPair(btOverlappingPairCallback* obj, btBroadphaseProxy* proxy0, btBroadphaseProxy* proxy1, btDispatcher* dispatcher);
void btOverlappingPairCallback_removeOverlappingPairsContainingProxy(btOverlappingPairCallback* obj, btBroadphaseProxy* proxy0, btDispatcher* dispatcher);
void btOverlappingPairCallback_delete(btOverlappingPairCallback* obj);
btPersistentManifold* btPersistentManifold_new();
btPersistentManifold* btPersistentManifold_new2(const btCollisionObject* body0, const btCollisionObject* body1, int __unnamed2, btScalar contactBreakingThreshold, btScalar contactProcessingThreshold);
int btPersistentManifold_addManifoldPoint(btPersistentManifold* obj, const btManifoldPoint* newPoint);
int btPersistentManifold_addManifoldPoint2(btPersistentManifold* obj, const btManifoldPoint* newPoint, bool isPredictive);
void btPersistentManifold_clearManifold(btPersistentManifold* obj);
void btPersistentManifold_clearUserCache(btPersistentManifold* obj, btManifoldPoint* pt);
const btCollisionObject* btPersistentManifold_getBody0(btPersistentManifold* obj);
const btCollisionObject* btPersistentManifold_getBody1(btPersistentManifold* obj);
int btPersistentManifold_getCacheEntry(btPersistentManifold* obj, const btManifoldPoint* newPoint);
int btPersistentManifold_getCompanionIdA(btPersistentManifold* obj);
int btPersistentManifold_getCompanionIdB(btPersistentManifold* obj);
btScalar btPersistentManifold_getContactBreakingThreshold(btPersistentManifold* obj);
btManifoldPoint* btPersistentManifold_getContactPoint(btPersistentManifold* obj, int index);
btScalar btPersistentManifold_getContactProcessingThreshold(btPersistentManifold* obj);
int btPersistentManifold_getIndex1a(btPersistentManifold* obj);
int btPersistentManifold_getNumContacts(btPersistentManifold* obj);
void btPersistentManifold_refreshContactPoints(btPersistentManifold* obj, const btScalar* trA, const btScalar* trB);
void btPersistentManifold_removeContactPoint(btPersistentManifold* obj, int index);
void btPersistentManifold_replaceContactPoint(btPersistentManifold* obj, const btManifoldPoint* newPoint, int insertIndex);
void btPersistentManifold_setBodies(btPersistentManifold* obj, const btCollisionObject* body0, const btCollisionObject* body1);
void btPersistentManifold_setCompanionIdA(btPersistentManifold* obj, int value);
void btPersistentManifold_setCompanionIdB(btPersistentManifold* obj, int value);
void btPersistentManifold_setContactBreakingThreshold(btPersistentManifold* obj, btScalar contactBreakingThreshold);
void btPersistentManifold_setContactProcessingThreshold(btPersistentManifold* obj, btScalar contactProcessingThreshold);
void btPersistentManifold_setIndex1a(btPersistentManifold* obj, int value);
void btPersistentManifold_setNumContacts(btPersistentManifold* obj, int cachedPoints);
bool btPersistentManifold_validContactDistance(btPersistentManifold* obj, const btManifoldPoint* pt);
btConstraintSetting* btConstraintSetting_new();
btScalar btConstraintSetting_getDamping(btConstraintSetting* obj);
btScalar btConstraintSetting_getImpulseClamp(btConstraintSetting* obj);
btScalar btConstraintSetting_getTau(btConstraintSetting* obj);
void btConstraintSetting_setDamping(btConstraintSetting* obj, btScalar value);
void btConstraintSetting_setImpulseClamp(btConstraintSetting* obj, btScalar value);
void btConstraintSetting_setTau(btConstraintSetting* obj, btScalar value);
void btConstraintSetting_delete(btConstraintSetting* obj);
btPoint2PointConstraint* btPoint2PointConstraint_new(btRigidBody* rbA, btRigidBody* rbB, const btScalar* pivotInA, const btScalar* pivotInB);
btPoint2PointConstraint* btPoint2PointConstraint_new2(btRigidBody* rbA, const btScalar* pivotInA);
void btPoint2PointConstraint_getInfo1NonVirtual(btPoint2PointConstraint* obj, btTypedConstraint_btConstraintInfo1* info);
void btPoint2PointConstraint_getInfo2NonVirtual(btPoint2PointConstraint* obj, btTypedConstraint_btConstraintInfo2* info, const btScalar* body0_trans, const btScalar* body1_trans);
void btPoint2PointConstraint_getPivotInA(btPoint2PointConstraint* obj, btScalar* value);
void btPoint2PointConstraint_getPivotInB(btPoint2PointConstraint* obj, btScalar* value);
btConstraintSetting* btPoint2PointConstraint_getSetting(btPoint2PointConstraint* obj);
bool btPoint2PointConstraint_getUseSolveConstraintObsolete(btPoint2PointConstraint* obj);
void btPoint2PointConstraint_setPivotA(btPoint2PointConstraint* obj, const btScalar* pivotA);
void btPoint2PointConstraint_setPivotB(btPoint2PointConstraint* obj, const btScalar* pivotB);
void btPoint2PointConstraint_setUseSolveConstraintObsolete(btPoint2PointConstraint* obj, bool value);
void btPoint2PointConstraint_updateRHS(btPoint2PointConstraint* obj, btScalar timeStep);
btPointCollector* btPointCollector_new();
btScalar btPointCollector_getDistance(btPointCollector* obj);
bool btPointCollector_getHasResult(btPointCollector* obj);
void btPointCollector_getNormalOnBInWorld(btPointCollector* obj, btScalar* value);
void btPointCollector_getPointInWorld(btPointCollector* obj, btScalar* value);
void btPointCollector_setDistance(btPointCollector* obj, btScalar value);
void btPointCollector_setHasResult(btPointCollector* obj, bool value);
void btPointCollector_setNormalOnBInWorld(btPointCollector* obj, const btScalar* value);
void btPointCollector_setPointInWorld(btPointCollector* obj, const btScalar* value);
btPolarDecomposition* btPolarDecomposition_new();
btPolarDecomposition* btPolarDecomposition_new2(btScalar tolerance);
btPolarDecomposition* btPolarDecomposition_new3(btScalar tolerance, unsigned int maxIterations);
unsigned int btPolarDecomposition_decompose(btPolarDecomposition* obj, const btScalar* a, btScalar* u, btScalar* h);
unsigned int btPolarDecomposition_maxIterations(btPolarDecomposition* obj);
void btPolarDecomposition_delete(btPolarDecomposition* obj);
const btConvexPolyhedron* btPolyhedralConvexShape_getConvexPolyhedron(btPolyhedralConvexShape* obj);
void btPolyhedralConvexShape_getEdge(btPolyhedralConvexShape* obj, int i, btScalar* pa, btScalar* pb);
int btPolyhedralConvexShape_getNumEdges(btPolyhedralConvexShape* obj);
int btPolyhedralConvexShape_getNumPlanes(btPolyhedralConvexShape* obj);
int btPolyhedralConvexShape_getNumVertices(btPolyhedralConvexShape* obj);
void btPolyhedralConvexShape_getPlane(btPolyhedralConvexShape* obj, btScalar* planeNormal, btScalar* planeSupport, int i);
void btPolyhedralConvexShape_getVertex(btPolyhedralConvexShape* obj, int i, btScalar* vtx);
bool btPolyhedralConvexShape_initializePolyhedralFeatures(btPolyhedralConvexShape* obj);
bool btPolyhedralConvexShape_initializePolyhedralFeatures2(btPolyhedralConvexShape* obj, int shiftVerticesByMargin);
bool btPolyhedralConvexShape_isInside(btPolyhedralConvexShape* obj, const btScalar* pt, btScalar tolerance);
void btPolyhedralConvexAabbCachingShape_getNonvirtualAabb(btPolyhedralConvexAabbCachingShape* obj, const btScalar* trans, btScalar* aabbMin, btScalar* aabbMax, btScalar margin);
void btPolyhedralConvexAabbCachingShape_recalcLocalAabb(btPolyhedralConvexAabbCachingShape* obj);
btQuantizedBvhNode* btQuantizedBvhNode_new();
int btQuantizedBvhNode_getEscapeIndex(btQuantizedBvhNode* obj);
int btQuantizedBvhNode_getEscapeIndexOrTriangleIndex(btQuantizedBvhNode* obj);
int btQuantizedBvhNode_getPartId(btQuantizedBvhNode* obj);
unsigned short* btQuantizedBvhNode_getQuantizedAabbMax(btQuantizedBvhNode* obj);
unsigned short* btQuantizedBvhNode_getQuantizedAabbMin(btQuantizedBvhNode* obj);
int btQuantizedBvhNode_getTriangleIndex(btQuantizedBvhNode* obj);
bool btQuantizedBvhNode_isLeafNode(btQuantizedBvhNode* obj);
void btQuantizedBvhNode_setEscapeIndexOrTriangleIndex(btQuantizedBvhNode* obj, int value);
void btQuantizedBvhNode_delete(btQuantizedBvhNode* obj);
btOptimizedBvhNode* btOptimizedBvhNode_new();
void btOptimizedBvhNode_getAabbMaxOrg(btOptimizedBvhNode* obj, btScalar* value);
void btOptimizedBvhNode_getAabbMinOrg(btOptimizedBvhNode* obj, btScalar* value);
int btOptimizedBvhNode_getEscapeIndex(btOptimizedBvhNode* obj);
char* btOptimizedBvhNode_getPadding(btOptimizedBvhNode* obj);
int btOptimizedBvhNode_getSubPart(btOptimizedBvhNode* obj);
int btOptimizedBvhNode_getTriangleIndex(btOptimizedBvhNode* obj);
void btOptimizedBvhNode_setAabbMaxOrg(btOptimizedBvhNode* obj, const btScalar* value);
void btOptimizedBvhNode_setAabbMinOrg(btOptimizedBvhNode* obj, const btScalar* value);
void btOptimizedBvhNode_setEscapeIndex(btOptimizedBvhNode* obj, int value);
void btOptimizedBvhNode_setSubPart(btOptimizedBvhNode* obj, int value);
void btOptimizedBvhNode_setTriangleIndex(btOptimizedBvhNode* obj, int value);
void btOptimizedBvhNode_delete(btOptimizedBvhNode* obj);
void btNodeOverlapCallback_processNode(btNodeOverlapCallback* obj, int subPart, int triangleIndex);
void btNodeOverlapCallback_delete(btNodeOverlapCallback* obj);
btQuantizedBvh* btQuantizedBvh_new();
void btQuantizedBvh_buildInternal(btQuantizedBvh* obj);
unsigned int btQuantizedBvh_calculateSerializeBufferSize(btQuantizedBvh* obj);
int btQuantizedBvh_calculateSerializeBufferSizeNew(btQuantizedBvh* obj);
void btQuantizedBvh_deSerializeDouble(btQuantizedBvh* obj, btQuantizedBvhDoubleData* quantizedBvhDoubleData);
void btQuantizedBvh_deSerializeFloat(btQuantizedBvh* obj, btQuantizedBvhFloatData* quantizedBvhFloatData);
btQuantizedBvh* btQuantizedBvh_deSerializeInPlace(void* i_alignedDataBuffer, unsigned int i_dataBufferSize, bool i_swapEndian);
unsigned int btQuantizedBvh_getAlignmentSerializationPadding();
QuantizedNodeArray* btQuantizedBvh_getLeafNodeArray(btQuantizedBvh* obj);
QuantizedNodeArray* btQuantizedBvh_getQuantizedNodeArray(btQuantizedBvh* obj);
BvhSubtreeInfoArray* btQuantizedBvh_getSubtreeInfoArray(btQuantizedBvh* obj);
bool btQuantizedBvh_isQuantized(btQuantizedBvh* obj);
void btQuantizedBvh_quantize(btQuantizedBvh* obj, unsigned short* out, const btScalar* point, int isMax);
void btQuantizedBvh_quantizeWithClamp(btQuantizedBvh* obj, unsigned short* out, const btScalar* point2, int isMax);
void btQuantizedBvh_reportAabbOverlappingNodex(btQuantizedBvh* obj, btNodeOverlapCallback* nodeCallback, const btScalar* aabbMin, const btScalar* aabbMax);
void btQuantizedBvh_reportBoxCastOverlappingNodex(btQuantizedBvh* obj, btNodeOverlapCallback* nodeCallback, const btScalar* raySource, const btScalar* rayTarget, const btScalar* aabbMin, const btScalar* aabbMax);
void btQuantizedBvh_reportRayOverlappingNodex(btQuantizedBvh* obj, btNodeOverlapCallback* nodeCallback, const btScalar* raySource, const btScalar* rayTarget);
bool btQuantizedBvh_serialize(btQuantizedBvh* obj, void* o_alignedDataBuffer, unsigned int i_dataBufferSize, bool i_swapEndian);
const char* btQuantizedBvh_serialize2(btQuantizedBvh* obj, void* dataBuffer, btSerializer* serializer);
void btQuantizedBvh_setQuantizationValues(btQuantizedBvh* obj, const btScalar* bvhAabbMin, const btScalar* bvhAabbMax);
void btQuantizedBvh_setQuantizationValues2(btQuantizedBvh* obj, const btScalar* bvhAabbMin, const btScalar* bvhAabbMax, btScalar quantizationMargin);
void btQuantizedBvh_setTraversalMode(btQuantizedBvh* obj, btQuantizedBvh_btTraversalMode traversalMode);
void btQuantizedBvh_unQuantize(btQuantizedBvh* obj, const unsigned short* vecIn, btScalar* value);
void btQuantizedBvh_delete(btQuantizedBvh* obj);
btRaycastVehicle_btVehicleTuning* btRaycastVehicle_btVehicleTuning_new();
btScalar btRaycastVehicle_btVehicleTuning_getFrictionSlip(btRaycastVehicle_btVehicleTuning* obj);
btScalar btRaycastVehicle_btVehicleTuning_getMaxSuspensionForce(btRaycastVehicle_btVehicleTuning* obj);
btScalar btRaycastVehicle_btVehicleTuning_getMaxSuspensionTravelCm(btRaycastVehicle_btVehicleTuning* obj);
btScalar btRaycastVehicle_btVehicleTuning_getSuspensionCompression(btRaycastVehicle_btVehicleTuning* obj);
btScalar btRaycastVehicle_btVehicleTuning_getSuspensionDamping(btRaycastVehicle_btVehicleTuning* obj);
btScalar btRaycastVehicle_btVehicleTuning_getSuspensionStiffness(btRaycastVehicle_btVehicleTuning* obj);
void btRaycastVehicle_btVehicleTuning_setFrictionSlip(btRaycastVehicle_btVehicleTuning* obj, btScalar value);
void btRaycastVehicle_btVehicleTuning_setMaxSuspensionForce(btRaycastVehicle_btVehicleTuning* obj, btScalar value);
void btRaycastVehicle_btVehicleTuning_setMaxSuspensionTravelCm(btRaycastVehicle_btVehicleTuning* obj, btScalar value);
void btRaycastVehicle_btVehicleTuning_setSuspensionCompression(btRaycastVehicle_btVehicleTuning* obj, btScalar value);
void btRaycastVehicle_btVehicleTuning_setSuspensionDamping(btRaycastVehicle_btVehicleTuning* obj, btScalar value);
void btRaycastVehicle_btVehicleTuning_setSuspensionStiffness(btRaycastVehicle_btVehicleTuning* obj, btScalar value);
void btRaycastVehicle_btVehicleTuning_delete(btRaycastVehicle_btVehicleTuning* obj);
btRaycastVehicle* btRaycastVehicle_new(const btRaycastVehicle_btVehicleTuning* tuning, btRigidBody* chassis, btVehicleRaycaster* raycaster);
btWheelInfo* btRaycastVehicle_addWheel(btRaycastVehicle* obj, const btScalar* connectionPointCS0, const btScalar* wheelDirectionCS0, const btScalar* wheelAxleCS, btScalar suspensionRestLength, btScalar wheelRadius, const btRaycastVehicle_btVehicleTuning* tuning, bool isFrontWheel);
void btRaycastVehicle_applyEngineForce(btRaycastVehicle* obj, btScalar force, int wheel);
void btRaycastVehicle_getChassisWorldTransform(btRaycastVehicle* obj, btScalar* value);
btScalar btRaycastVehicle_getCurrentSpeedKmHour(btRaycastVehicle* obj);
int btRaycastVehicle_getForwardAxis(btRaycastVehicle* obj);
void btRaycastVehicle_getForwardVector(btRaycastVehicle* obj, btScalar* value);
int btRaycastVehicle_getNumWheels(btRaycastVehicle* obj);
int btRaycastVehicle_getRightAxis(btRaycastVehicle* obj);
btRigidBody* btRaycastVehicle_getRigidBody(btRaycastVehicle* obj);
btScalar btRaycastVehicle_getSteeringValue(btRaycastVehicle* obj, int wheel);
int btRaycastVehicle_getUpAxis(btRaycastVehicle* obj);
int btRaycastVehicle_getUserConstraintId(btRaycastVehicle* obj);
int btRaycastVehicle_getUserConstraintType(btRaycastVehicle* obj);
btWheelInfo* btRaycastVehicle_getWheelInfo(btRaycastVehicle* obj, int index);
btAlignedWheelInfoArray* btRaycastVehicle_getWheelInfo2(btRaycastVehicle* obj);
void btRaycastVehicle_getWheelTransformWS(btRaycastVehicle* obj, int wheelIndex, btScalar* value);
btScalar btRaycastVehicle_rayCast(btRaycastVehicle* obj, btWheelInfo* wheel);
void btRaycastVehicle_resetSuspension(btRaycastVehicle* obj);
void btRaycastVehicle_setBrake(btRaycastVehicle* obj, btScalar brake, int wheelIndex);
void btRaycastVehicle_setCoordinateSystem(btRaycastVehicle* obj, int rightIndex, int upIndex, int forwardIndex);
void btRaycastVehicle_setPitchControl(btRaycastVehicle* obj, btScalar pitch);
void btRaycastVehicle_setSteeringValue(btRaycastVehicle* obj, btScalar steering, int wheel);
void btRaycastVehicle_setUserConstraintId(btRaycastVehicle* obj, int uid);
void btRaycastVehicle_setUserConstraintType(btRaycastVehicle* obj, int userConstraintType);
void btRaycastVehicle_updateFriction(btRaycastVehicle* obj, btScalar timeStep);
void btRaycastVehicle_updateSuspension(btRaycastVehicle* obj, btScalar deltaTime);
void btRaycastVehicle_updateVehicle(btRaycastVehicle* obj, btScalar step);
void btRaycastVehicle_updateWheelTransform(btRaycastVehicle* obj, int wheelIndex);
void btRaycastVehicle_updateWheelTransform2(btRaycastVehicle* obj, int wheelIndex, bool interpolatedTransform);
void btRaycastVehicle_updateWheelTransformsWS(btRaycastVehicle* obj, btWheelInfo* wheel);
void btRaycastVehicle_updateWheelTransformsWS2(btRaycastVehicle* obj, btWheelInfo* wheel, bool interpolatedTransform);
btDefaultVehicleRaycaster* btDefaultVehicleRaycaster_new(btDynamicsWorld* world);
btRigidBody_btRigidBodyConstructionInfo* btRigidBody_btRigidBodyConstructionInfo_new(btScalar mass, btMotionState* motionState, btCollisionShape* collisionShape);
btRigidBody_btRigidBodyConstructionInfo* btRigidBody_btRigidBodyConstructionInfo_new2(btScalar mass, btMotionState* motionState, btCollisionShape* collisionShape, const btScalar* localInertia);
btScalar btRigidBody_btRigidBodyConstructionInfo_getAdditionalAngularDampingFactor(btRigidBody_btRigidBodyConstructionInfo* obj);
btScalar btRigidBody_btRigidBodyConstructionInfo_getAdditionalAngularDampingThresholdSqr(btRigidBody_btRigidBodyConstructionInfo* obj);
bool btRigidBody_btRigidBodyConstructionInfo_getAdditionalDamping(btRigidBody_btRigidBodyConstructionInfo* obj);
btScalar btRigidBody_btRigidBodyConstructionInfo_getAdditionalDampingFactor(btRigidBody_btRigidBodyConstructionInfo* obj);
btScalar btRigidBody_btRigidBodyConstructionInfo_getAdditionalLinearDampingThresholdSqr(btRigidBody_btRigidBodyConstructionInfo* obj);
btScalar btRigidBody_btRigidBodyConstructionInfo_getAngularDamping(btRigidBody_btRigidBodyConstructionInfo* obj);
btScalar btRigidBody_btRigidBodyConstructionInfo_getAngularSleepingThreshold(btRigidBody_btRigidBodyConstructionInfo* obj);
btCollisionShape* btRigidBody_btRigidBodyConstructionInfo_getCollisionShape(btRigidBody_btRigidBodyConstructionInfo* obj);
btScalar btRigidBody_btRigidBodyConstructionInfo_getFriction(btRigidBody_btRigidBodyConstructionInfo* obj);
btScalar btRigidBody_btRigidBodyConstructionInfo_getLinearDamping(btRigidBody_btRigidBodyConstructionInfo* obj);
btScalar btRigidBody_btRigidBodyConstructionInfo_getLinearSleepingThreshold(btRigidBody_btRigidBodyConstructionInfo* obj);
void btRigidBody_btRigidBodyConstructionInfo_getLocalInertia(btRigidBody_btRigidBodyConstructionInfo* obj, btScalar* value);
btScalar btRigidBody_btRigidBodyConstructionInfo_getMass(btRigidBody_btRigidBodyConstructionInfo* obj);
btMotionState* btRigidBody_btRigidBodyConstructionInfo_getMotionState(btRigidBody_btRigidBodyConstructionInfo* obj);
btScalar btRigidBody_btRigidBodyConstructionInfo_getRestitution(btRigidBody_btRigidBodyConstructionInfo* obj);
btScalar btRigidBody_btRigidBodyConstructionInfo_getRollingFriction(btRigidBody_btRigidBodyConstructionInfo* obj);
void btRigidBody_btRigidBodyConstructionInfo_getStartWorldTransform(btRigidBody_btRigidBodyConstructionInfo* obj, btScalar* value);
void btRigidBody_btRigidBodyConstructionInfo_setAdditionalAngularDampingFactor(btRigidBody_btRigidBodyConstructionInfo* obj, btScalar value);
void btRigidBody_btRigidBodyConstructionInfo_setAdditionalAngularDampingThresholdSqr(btRigidBody_btRigidBodyConstructionInfo* obj, btScalar value);
void btRigidBody_btRigidBodyConstructionInfo_setAdditionalDamping(btRigidBody_btRigidBodyConstructionInfo* obj, bool value);
void btRigidBody_btRigidBodyConstructionInfo_setAdditionalDampingFactor(btRigidBody_btRigidBodyConstructionInfo* obj, btScalar value);
void btRigidBody_btRigidBodyConstructionInfo_setAdditionalLinearDampingThresholdSqr(btRigidBody_btRigidBodyConstructionInfo* obj, btScalar value);
void btRigidBody_btRigidBodyConstructionInfo_setAngularDamping(btRigidBody_btRigidBodyConstructionInfo* obj, btScalar value);
void btRigidBody_btRigidBodyConstructionInfo_setAngularSleepingThreshold(btRigidBody_btRigidBodyConstructionInfo* obj, btScalar value);
void btRigidBody_btRigidBodyConstructionInfo_setCollisionShape(btRigidBody_btRigidBodyConstructionInfo* obj, btCollisionShape* value);
void btRigidBody_btRigidBodyConstructionInfo_setFriction(btRigidBody_btRigidBodyConstructionInfo* obj, btScalar value);
void btRigidBody_btRigidBodyConstructionInfo_setLinearDamping(btRigidBody_btRigidBodyConstructionInfo* obj, btScalar value);
void btRigidBody_btRigidBodyConstructionInfo_setLinearSleepingThreshold(btRigidBody_btRigidBodyConstructionInfo* obj, btScalar value);
void btRigidBody_btRigidBodyConstructionInfo_setLocalInertia(btRigidBody_btRigidBodyConstructionInfo* obj, const btScalar* value);
void btRigidBody_btRigidBodyConstructionInfo_setMass(btRigidBody_btRigidBodyConstructionInfo* obj, btScalar value);
void btRigidBody_btRigidBodyConstructionInfo_setMotionState(btRigidBody_btRigidBodyConstructionInfo* obj, btMotionState* value);
void btRigidBody_btRigidBodyConstructionInfo_setRestitution(btRigidBody_btRigidBodyConstructionInfo* obj, btScalar value);
void btRigidBody_btRigidBodyConstructionInfo_setRollingFriction(btRigidBody_btRigidBodyConstructionInfo* obj, btScalar value);
void btRigidBody_btRigidBodyConstructionInfo_setStartWorldTransform(btRigidBody_btRigidBodyConstructionInfo* obj, const btScalar* value);
void btRigidBody_btRigidBodyConstructionInfo_delete(btRigidBody_btRigidBodyConstructionInfo* obj);
btRigidBody* btRigidBody_new(const btRigidBody_btRigidBodyConstructionInfo* constructionInfo);
btRigidBody* btRigidBody_new2(btScalar mass, btMotionState* motionState, btCollisionShape* collisionShape);
btRigidBody* btRigidBody_new3(btScalar mass, btMotionState* motionState, btCollisionShape* collisionShape, const btScalar* localInertia);
void btRigidBody_addConstraintRef(btRigidBody* obj, btTypedConstraint* c);
void btRigidBody_applyCentralForce(btRigidBody* obj, const btScalar* force);
void btRigidBody_applyCentralImpulse(btRigidBody* obj, const btScalar* impulse);
void btRigidBody_applyDamping(btRigidBody* obj, btScalar timeStep);
void btRigidBody_applyForce(btRigidBody* obj, const btScalar* force, const btScalar* rel_pos);
void btRigidBody_applyGravity(btRigidBody* obj);
void btRigidBody_applyImpulse(btRigidBody* obj, const btScalar* impulse, const btScalar* rel_pos);
void btRigidBody_applyTorque(btRigidBody* obj, const btScalar* torque);
void btRigidBody_applyTorqueImpulse(btRigidBody* obj, const btScalar* torque);
void btRigidBody_clearForces(btRigidBody* obj);
btScalar btRigidBody_computeAngularImpulseDenominator(btRigidBody* obj, const btScalar* axis);
void btRigidBody_computeGyroscopicForceExplicit(btRigidBody* obj, btScalar maxGyroscopicForce, btScalar* value);
void btRigidBody_computeGyroscopicImpulseImplicit_Body(btRigidBody* obj, btScalar step, btScalar* value);
void btRigidBody_computeGyroscopicImpulseImplicit_World(btRigidBody* obj, btScalar dt, btScalar* value);
btScalar btRigidBody_computeImpulseDenominator(btRigidBody* obj, const btScalar* pos, const btScalar* normal);
void btRigidBody_getAabb(btRigidBody* obj, btScalar* aabbMin, btScalar* aabbMax);
btScalar btRigidBody_getAngularDamping(btRigidBody* obj);
void btRigidBody_getAngularFactor(btRigidBody* obj, btScalar* angFac);
btScalar btRigidBody_getAngularSleepingThreshold(btRigidBody* obj);
void btRigidBody_getAngularVelocity(btRigidBody* obj, btScalar* ang_vel);
btBroadphaseProxy* btRigidBody_getBroadphaseProxy(btRigidBody* obj);
void btRigidBody_getCenterOfMassPosition(btRigidBody* obj, btScalar* value);
void btRigidBody_getCenterOfMassTransform(btRigidBody* obj, btScalar* xform);
btTypedConstraint* btRigidBody_getConstraintRef(btRigidBody* obj, int index);
int btRigidBody_getContactSolverType(btRigidBody* obj);
int btRigidBody_getFlags(btRigidBody* obj);
int btRigidBody_getFrictionSolverType(btRigidBody* obj);
void btRigidBody_getGravity(btRigidBody* obj, btScalar* acceleration);
void btRigidBody_getInvInertiaDiagLocal(btRigidBody* obj, btScalar* diagInvInertia);
void btRigidBody_getInvInertiaTensorWorld(btRigidBody* obj, btScalar* value);
btScalar btRigidBody_getInvMass(btRigidBody* obj);
btScalar btRigidBody_getLinearDamping(btRigidBody* obj);
void btRigidBody_getLinearFactor(btRigidBody* obj, btScalar* linearFactor);
btScalar btRigidBody_getLinearSleepingThreshold(btRigidBody* obj);
void btRigidBody_getLinearVelocity(btRigidBody* obj, btScalar* lin_vel);
void btRigidBody_getLocalInertia(btRigidBody* obj, btScalar* value);
btMotionState* btRigidBody_getMotionState(btRigidBody* obj);
int btRigidBody_getNumConstraintRefs(btRigidBody* obj);
void btRigidBody_getOrientation(btRigidBody* obj, btScalar* value);
void btRigidBody_getTotalForce(btRigidBody* obj, btScalar* value);
void btRigidBody_getTotalTorque(btRigidBody* obj, btScalar* value);
void btRigidBody_getVelocityInLocalPoint(btRigidBody* obj, const btScalar* rel_pos, btScalar* value);
void btRigidBody_integrateVelocities(btRigidBody* obj, btScalar step);
bool btRigidBody_isInWorld(btRigidBody* obj);
void btRigidBody_predictIntegratedTransform(btRigidBody* obj, btScalar step, btScalar* predictedTransform);
void btRigidBody_proceedToTransform(btRigidBody* obj, const btScalar* newTrans);
void btRigidBody_removeConstraintRef(btRigidBody* obj, btTypedConstraint* c);
void btRigidBody_saveKinematicState(btRigidBody* obj, btScalar step);
void btRigidBody_setAngularFactor(btRigidBody* obj, const btScalar* angFac);
void btRigidBody_setAngularFactor2(btRigidBody* obj, btScalar angFac);
void btRigidBody_setAngularVelocity(btRigidBody* obj, const btScalar* ang_vel);
void btRigidBody_setCenterOfMassTransform(btRigidBody* obj, const btScalar* xform);
void btRigidBody_setContactSolverType(btRigidBody* obj, int value);
void btRigidBody_setDamping(btRigidBody* obj, btScalar lin_damping, btScalar ang_damping);
void btRigidBody_setFlags(btRigidBody* obj, int flags);
void btRigidBody_setFrictionSolverType(btRigidBody* obj, int value);
void btRigidBody_setGravity(btRigidBody* obj, const btScalar* acceleration);
void btRigidBody_setInvInertiaDiagLocal(btRigidBody* obj, const btScalar* diagInvInertia);
void btRigidBody_setLinearFactor(btRigidBody* obj, const btScalar* linearFactor);
void btRigidBody_setLinearVelocity(btRigidBody* obj, const btScalar* lin_vel);
void btRigidBody_setMassProps(btRigidBody* obj, btScalar mass, const btScalar* inertia);
void btRigidBody_setMotionState(btRigidBody* obj, btMotionState* motionState);
void btRigidBody_setNewBroadphaseProxy(btRigidBody* obj, btBroadphaseProxy* broadphaseProxy);
void btRigidBody_setSleepingThresholds(btRigidBody* obj, btScalar linear, btScalar angular);
void btRigidBody_translate(btRigidBody* obj, const btScalar* v);
btRigidBody* btRigidBody_upcast(btCollisionObject* colObj);
void btRigidBody_updateDeactivation(btRigidBody* obj, btScalar timeStep);
void btRigidBody_updateInertiaTensor(btRigidBody* obj);
bool btRigidBody_wantsSleeping(btRigidBody* obj);
btScaledBvhTriangleMeshShape* btScaledBvhTriangleMeshShape_new(btBvhTriangleMeshShape* childShape, const btScalar* localScaling);
btBvhTriangleMeshShape* btScaledBvhTriangleMeshShape_getChildShape(btScaledBvhTriangleMeshShape* obj);
btSequentialImpulseConstraintSolver* btSequentialImpulseConstraintSolver_new();
unsigned long btSequentialImpulseConstraintSolver_btRand2(btSequentialImpulseConstraintSolver* obj);
int btSequentialImpulseConstraintSolver_btRandInt2(btSequentialImpulseConstraintSolver* obj, int n);
unsigned long btSequentialImpulseConstraintSolver_getRandSeed(btSequentialImpulseConstraintSolver* obj);
void btSequentialImpulseConstraintSolver_setRandSeed(btSequentialImpulseConstraintSolver* obj, unsigned long seed);
btChunk* btChunk_new();
int btChunk_getChunkCode(btChunk* obj);
int btChunk_getDna_nr(btChunk* obj);
int btChunk_getLength(btChunk* obj);
int btChunk_getNumber(btChunk* obj);
void* btChunk_getOldPtr(btChunk* obj);
void btChunk_setChunkCode(btChunk* obj, int value);
void btChunk_setDna_nr(btChunk* obj, int value);
void btChunk_setLength(btChunk* obj, int value);
void btChunk_setNumber(btChunk* obj, int value);
void btChunk_setOldPtr(btChunk* obj, void* value);
void btChunk_delete(btChunk* obj);
void btSerializer_delete(btSerializer* obj);
btDefaultSerializer* btDefaultSerializer_new();
btDefaultSerializer* btDefaultSerializer_new2(int totalSize);
unsigned char* btDefaultSerializer_internalAlloc(btDefaultSerializer* obj, size_t size);
void btDefaultSerializer_writeHeader(btDefaultSerializer* obj, unsigned char* buffer);
btShapeHull* btShapeHull_new(const btConvexShape* shape);
bool btShapeHull_buildHull(btShapeHull* obj, btScalar margin);
const unsigned int* btShapeHull_getIndexPointer(btShapeHull* obj);
const btVector3* btShapeHull_getVertexPointer(btShapeHull* obj);
int btShapeHull_numIndices(btShapeHull* obj);
int btShapeHull_numTriangles(btShapeHull* obj);
int btShapeHull_numVertices(btShapeHull* obj);
void btShapeHull_delete(btShapeHull* obj);
void btSimulationIslandManager_IslandCallback_delete(btSimulationIslandManager_IslandCallback* obj);
btSimulationIslandManager* btSimulationIslandManager_new();
void btSimulationIslandManager_buildAndProcessIslands(btSimulationIslandManager* obj, btDispatcher* dispatcher, btCollisionWorld* collisionWorld, btSimulationIslandManager_IslandCallback* callback);
void btSimulationIslandManager_buildIslands(btSimulationIslandManager* obj, btDispatcher* dispatcher, btCollisionWorld* colWorld);
void btSimulationIslandManager_findUnions(btSimulationIslandManager* obj, btDispatcher* dispatcher, btCollisionWorld* colWorld);
bool btSimulationIslandManager_getSplitIslands(btSimulationIslandManager* obj);
btUnionFind* btSimulationIslandManager_getUnionFind(btSimulationIslandManager* obj);
void btSimulationIslandManager_initUnionFind(btSimulationIslandManager* obj, int n);
void btSimulationIslandManager_setSplitIslands(btSimulationIslandManager* obj, bool doSplitIslands);
void btSimulationIslandManager_storeIslandActivationState(btSimulationIslandManager* obj, btCollisionWorld* world);
void btSimulationIslandManager_updateActivationState(btSimulationIslandManager* obj, btCollisionWorld* colWorld, btDispatcher* dispatcher);
void btSimulationIslandManager_delete(btSimulationIslandManager* obj);
btSliderConstraint* btSliderConstraint_new(btRigidBody* rbA, btRigidBody* rbB, const btScalar* frameInA, const btScalar* frameInB, bool useLinearReferenceFrameA);
btSliderConstraint* btSliderConstraint_new2(btRigidBody* rbB, const btScalar* frameInB, bool useLinearReferenceFrameA);
void btSliderConstraint_calculateTransforms(btSliderConstraint* obj, const btScalar* transA, const btScalar* transB);
void btSliderConstraint_getAncorInA(btSliderConstraint* obj, btScalar* value);
void btSliderConstraint_getAncorInB(btSliderConstraint* obj, btScalar* value);
btScalar btSliderConstraint_getAngDepth(btSliderConstraint* obj);
btScalar btSliderConstraint_getAngularPos(btSliderConstraint* obj);
void btSliderConstraint_getCalculatedTransformA(btSliderConstraint* obj, btScalar* value);
void btSliderConstraint_getCalculatedTransformB(btSliderConstraint* obj, btScalar* value);
btScalar btSliderConstraint_getDampingDirAng(btSliderConstraint* obj);
btScalar btSliderConstraint_getDampingDirLin(btSliderConstraint* obj);
btScalar btSliderConstraint_getDampingLimAng(btSliderConstraint* obj);
btScalar btSliderConstraint_getDampingLimLin(btSliderConstraint* obj);
btScalar btSliderConstraint_getDampingOrthoAng(btSliderConstraint* obj);
btScalar btSliderConstraint_getDampingOrthoLin(btSliderConstraint* obj);
void btSliderConstraint_getFrameOffsetA(btSliderConstraint* obj, btScalar* value);
void btSliderConstraint_getFrameOffsetB(btSliderConstraint* obj, btScalar* value);
void btSliderConstraint_getInfo1NonVirtual(btSliderConstraint* obj, btTypedConstraint_btConstraintInfo1* info);
void btSliderConstraint_getInfo2NonVirtual(btSliderConstraint* obj, btTypedConstraint_btConstraintInfo2* info, const btScalar* transA, const btScalar* transB, const btScalar* linVelA, const btScalar* linVelB, btScalar rbAinvMass, btScalar rbBinvMass);
btScalar btSliderConstraint_getLinDepth(btSliderConstraint* obj);
btScalar btSliderConstraint_getLinearPos(btSliderConstraint* obj);
btScalar btSliderConstraint_getLowerAngLimit(btSliderConstraint* obj);
btScalar btSliderConstraint_getLowerLinLimit(btSliderConstraint* obj);
btScalar btSliderConstraint_getMaxAngMotorForce(btSliderConstraint* obj);
btScalar btSliderConstraint_getMaxLinMotorForce(btSliderConstraint* obj);
bool btSliderConstraint_getPoweredAngMotor(btSliderConstraint* obj);
bool btSliderConstraint_getPoweredLinMotor(btSliderConstraint* obj);
btScalar btSliderConstraint_getRestitutionDirAng(btSliderConstraint* obj);
btScalar btSliderConstraint_getRestitutionDirLin(btSliderConstraint* obj);
btScalar btSliderConstraint_getRestitutionLimAng(btSliderConstraint* obj);
btScalar btSliderConstraint_getRestitutionLimLin(btSliderConstraint* obj);
btScalar btSliderConstraint_getRestitutionOrthoAng(btSliderConstraint* obj);
btScalar btSliderConstraint_getRestitutionOrthoLin(btSliderConstraint* obj);
btScalar btSliderConstraint_getSoftnessDirAng(btSliderConstraint* obj);
btScalar btSliderConstraint_getSoftnessDirLin(btSliderConstraint* obj);
btScalar btSliderConstraint_getSoftnessLimAng(btSliderConstraint* obj);
btScalar btSliderConstraint_getSoftnessLimLin(btSliderConstraint* obj);
btScalar btSliderConstraint_getSoftnessOrthoAng(btSliderConstraint* obj);
btScalar btSliderConstraint_getSoftnessOrthoLin(btSliderConstraint* obj);
bool btSliderConstraint_getSolveAngLimit(btSliderConstraint* obj);
bool btSliderConstraint_getSolveLinLimit(btSliderConstraint* obj);
btScalar btSliderConstraint_getTargetAngMotorVelocity(btSliderConstraint* obj);
btScalar btSliderConstraint_getTargetLinMotorVelocity(btSliderConstraint* obj);
btScalar btSliderConstraint_getUpperAngLimit(btSliderConstraint* obj);
btScalar btSliderConstraint_getUpperLinLimit(btSliderConstraint* obj);
bool btSliderConstraint_getUseFrameOffset(btSliderConstraint* obj);
bool btSliderConstraint_getUseLinearReferenceFrameA(btSliderConstraint* obj);
void btSliderConstraint_setDampingDirAng(btSliderConstraint* obj, btScalar dampingDirAng);
void btSliderConstraint_setDampingDirLin(btSliderConstraint* obj, btScalar dampingDirLin);
void btSliderConstraint_setDampingLimAng(btSliderConstraint* obj, btScalar dampingLimAng);
void btSliderConstraint_setDampingLimLin(btSliderConstraint* obj, btScalar dampingLimLin);
void btSliderConstraint_setDampingOrthoAng(btSliderConstraint* obj, btScalar dampingOrthoAng);
void btSliderConstraint_setDampingOrthoLin(btSliderConstraint* obj, btScalar dampingOrthoLin);
void btSliderConstraint_setFrames(btSliderConstraint* obj, const btScalar* frameA, const btScalar* frameB);
void btSliderConstraint_setLowerAngLimit(btSliderConstraint* obj, btScalar lowerLimit);
void btSliderConstraint_setLowerLinLimit(btSliderConstraint* obj, btScalar lowerLimit);
void btSliderConstraint_setMaxAngMotorForce(btSliderConstraint* obj, btScalar maxAngMotorForce);
void btSliderConstraint_setMaxLinMotorForce(btSliderConstraint* obj, btScalar maxLinMotorForce);
void btSliderConstraint_setPoweredAngMotor(btSliderConstraint* obj, bool onOff);
void btSliderConstraint_setPoweredLinMotor(btSliderConstraint* obj, bool onOff);
void btSliderConstraint_setRestitutionDirAng(btSliderConstraint* obj, btScalar restitutionDirAng);
void btSliderConstraint_setRestitutionDirLin(btSliderConstraint* obj, btScalar restitutionDirLin);
void btSliderConstraint_setRestitutionLimAng(btSliderConstraint* obj, btScalar restitutionLimAng);
void btSliderConstraint_setRestitutionLimLin(btSliderConstraint* obj, btScalar restitutionLimLin);
void btSliderConstraint_setRestitutionOrthoAng(btSliderConstraint* obj, btScalar restitutionOrthoAng);
void btSliderConstraint_setRestitutionOrthoLin(btSliderConstraint* obj, btScalar restitutionOrthoLin);
void btSliderConstraint_setSoftnessDirAng(btSliderConstraint* obj, btScalar softnessDirAng);
void btSliderConstraint_setSoftnessDirLin(btSliderConstraint* obj, btScalar softnessDirLin);
void btSliderConstraint_setSoftnessLimAng(btSliderConstraint* obj, btScalar softnessLimAng);
void btSliderConstraint_setSoftnessLimLin(btSliderConstraint* obj, btScalar softnessLimLin);
void btSliderConstraint_setSoftnessOrthoAng(btSliderConstraint* obj, btScalar softnessOrthoAng);
void btSliderConstraint_setSoftnessOrthoLin(btSliderConstraint* obj, btScalar softnessOrthoLin);
void btSliderConstraint_setTargetAngMotorVelocity(btSliderConstraint* obj, btScalar targetAngMotorVelocity);
void btSliderConstraint_setTargetLinMotorVelocity(btSliderConstraint* obj, btScalar targetLinMotorVelocity);
void btSliderConstraint_setUpperAngLimit(btSliderConstraint* obj, btScalar upperLimit);
void btSliderConstraint_setUpperLinLimit(btSliderConstraint* obj, btScalar upperLimit);
void btSliderConstraint_setUseFrameOffset(btSliderConstraint* obj, bool frameOffsetOnOff);
void btSliderConstraint_testAngLimits(btSliderConstraint* obj);
void btSliderConstraint_testLinLimits(btSliderConstraint* obj);
btTriIndex* btTriIndex_new(int partId, int triangleIndex, btCollisionShape* shape);
btCollisionShape* btTriIndex_getChildShape(btTriIndex* obj);
int btTriIndex_getPartId(btTriIndex* obj);
int btTriIndex_getPartIdTriangleIndex(btTriIndex* obj);
int btTriIndex_getTriangleIndex(btTriIndex* obj);
int btTriIndex_getUid(btTriIndex* obj);
void btTriIndex_setChildShape(btTriIndex* obj, btCollisionShape* value);
void btTriIndex_setPartIdTriangleIndex(btTriIndex* obj, int value);
void btTriIndex_delete(btTriIndex* obj);
btSoftBodyTriangleCallback* btSoftBodyTriangleCallback_new(btDispatcher* dispatcher, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap, bool isSwapped);
void btSoftBodyTriangleCallback_clearCache(btSoftBodyTriangleCallback* obj);
void btSoftBodyTriangleCallback_getAabbMax(btSoftBodyTriangleCallback* obj, btScalar* value);
void btSoftBodyTriangleCallback_getAabbMin(btSoftBodyTriangleCallback* obj, btScalar* value);
int btSoftBodyTriangleCallback_getTriangleCount(btSoftBodyTriangleCallback* obj);
void btSoftBodyTriangleCallback_setTimeStepAndCounters(btSoftBodyTriangleCallback* obj, btScalar collisionMarginTriangle, const btCollisionObjectWrapper* triObjWrap, const btDispatcherInfo* dispatchInfo, btManifoldResult* resultOut);
void btSoftBodyTriangleCallback_setTriangleCount(btSoftBodyTriangleCallback* obj, int value);
btSoftBodyConcaveCollisionAlgorithm_CreateFunc* btSoftBodyConcaveCollisionAlgorithm_CreateFunc_new();
btSoftBodyConcaveCollisionAlgorithm_SwappedCreateFunc* btSoftBodyConcaveCollisionAlgorithm_SwappedCreateFunc_new();
btSoftBodyConcaveCollisionAlgorithm* btSoftBodyConcaveCollisionAlgorithm_new(const btCollisionAlgorithmConstructionInfo* ci, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap, bool isSwapped);
void btSoftBodyConcaveCollisionAlgorithm_clearCache(btSoftBodyConcaveCollisionAlgorithm* obj);
float btSoftBodyHelpers_CalculateUV(int resx, int resy, int ix, int iy, int id);
btSoftBody* btSoftBodyHelpers_CreateEllipsoid(btSoftBodyWorldInfo* worldInfo, const btScalar* center, const btScalar* radius, int res);
btSoftBody* btSoftBodyHelpers_CreateFromConvexHull(btSoftBodyWorldInfo* worldInfo, const btScalar* vertices, int nvertices);
btSoftBody* btSoftBodyHelpers_CreateFromConvexHull2(btSoftBodyWorldInfo* worldInfo, const btScalar* vertices, int nvertices, bool randomizeConstraints);
btSoftBody* btSoftBodyHelpers_CreateFromTetGenData(btSoftBodyWorldInfo* worldInfo, const char* ele, const char* face, const char* node, bool bfacelinks, bool btetralinks, bool bfacesfromtetras);
btSoftBody* btSoftBodyHelpers_CreateFromTriMesh(btSoftBodyWorldInfo* worldInfo, const btScalar* vertices, const int* triangles, int ntriangles);
btSoftBody* btSoftBodyHelpers_CreateFromTriMesh2(btSoftBodyWorldInfo* worldInfo, const btScalar* vertices, const int* triangles, int ntriangles, bool randomizeConstraints);
btSoftBody* btSoftBodyHelpers_CreatePatch(btSoftBodyWorldInfo* worldInfo, const btScalar* corner00, const btScalar* corner10, const btScalar* corner01, const btScalar* corner11, int resx, int resy, int fixeds, bool gendiags);
btSoftBody* btSoftBodyHelpers_CreatePatchUV(btSoftBodyWorldInfo* worldInfo, const btScalar* corner00, const btScalar* corner10, const btScalar* corner01, const btScalar* corner11, int resx, int resy, int fixeds, bool gendiags);
btSoftBody* btSoftBodyHelpers_CreatePatchUV2(btSoftBodyWorldInfo* worldInfo, const btScalar* corner00, const btScalar* corner10, const btScalar* corner01, const btScalar* corner11, int resx, int resy, int fixeds, bool gendiags, float* tex_coords);
btSoftBody* btSoftBodyHelpers_CreateRope(btSoftBodyWorldInfo* worldInfo, const btScalar* from, const btScalar* to, int res, int fixeds);
void btSoftBodyHelpers_Draw(btSoftBody* psb, btIDebugDraw* idraw);
void btSoftBodyHelpers_Draw2(btSoftBody* psb, btIDebugDraw* idraw, int drawflags);
void btSoftBodyHelpers_DrawClusterTree(btSoftBody* psb, btIDebugDraw* idraw);
void btSoftBodyHelpers_DrawClusterTree2(btSoftBody* psb, btIDebugDraw* idraw, int mindepth);
void btSoftBodyHelpers_DrawClusterTree3(btSoftBody* psb, btIDebugDraw* idraw, int mindepth, int maxdepth);
void btSoftBodyHelpers_DrawFaceTree(btSoftBody* psb, btIDebugDraw* idraw);
void btSoftBodyHelpers_DrawFaceTree2(btSoftBody* psb, btIDebugDraw* idraw, int mindepth);
void btSoftBodyHelpers_DrawFaceTree3(btSoftBody* psb, btIDebugDraw* idraw, int mindepth, int maxdepth);
void btSoftBodyHelpers_DrawFrame(btSoftBody* psb, btIDebugDraw* idraw);
void btSoftBodyHelpers_DrawInfos(btSoftBody* psb, btIDebugDraw* idraw, bool masses, bool areas, bool stress);
void btSoftBodyHelpers_DrawNodeTree(btSoftBody* psb, btIDebugDraw* idraw);
void btSoftBodyHelpers_DrawNodeTree2(btSoftBody* psb, btIDebugDraw* idraw, int mindepth);
void btSoftBodyHelpers_DrawNodeTree3(btSoftBody* psb, btIDebugDraw* idraw, int mindepth, int maxdepth);
void btSoftBodyHelpers_ReoptimizeLinkOrder(btSoftBody* psb);
btSoftBodyRigidBodyCollisionConfiguration* btSoftBodyRigidBodyCollisionConfiguration_new();
btSoftBodyRigidBodyCollisionConfiguration* btSoftBodyRigidBodyCollisionConfiguration_new2(const btDefaultCollisionConstructionInfo* constructionInfo);
bool btSoftBodySolver_checkInitialized(btSoftBodySolver* obj);
void btSoftBodySolver_copyBackToSoftBodies(btSoftBodySolver* obj);
void btSoftBodySolver_copyBackToSoftBodies2(btSoftBodySolver* obj, bool bMove);
int btSoftBodySolver_getNumberOfPositionIterations(btSoftBodySolver* obj);
int btSoftBodySolver_getNumberOfVelocityIterations(btSoftBodySolver* obj);
SolverTypes btSoftBodySolver_getSolverType(btSoftBodySolver* obj);
float btSoftBodySolver_getTimeScale(btSoftBodySolver* obj);
void btSoftBodySolver_optimize(btSoftBodySolver* obj, btAlignedObjectArray* softBodies);
void btSoftBodySolver_optimize2(btSoftBodySolver* obj, btAlignedObjectArray* softBodies, bool forceUpdate);
void btSoftBodySolver_predictMotion(btSoftBodySolver* obj, float solverdt);
void btSoftBodySolver_processCollision(btSoftBodySolver* obj, btSoftBody* __unnamed0, const btCollisionObjectWrapper* __unnamed1);
void btSoftBodySolver_processCollision2(btSoftBodySolver* obj, btSoftBody* __unnamed0, btSoftBody* __unnamed1);
void btSoftBodySolver_setNumberOfPositionIterations(btSoftBodySolver* obj, int iterations);
void btSoftBodySolver_setNumberOfVelocityIterations(btSoftBodySolver* obj, int iterations);
void btSoftBodySolver_solveConstraints(btSoftBodySolver* obj, float solverdt);
void btSoftBodySolver_updateSoftBodies(btSoftBodySolver* obj);
void btSoftBodySolver_delete(btSoftBodySolver* obj);
void btSoftBodySolverOutput_copySoftBodyToVertexBuffer(btSoftBodySolverOutput* obj, const btSoftBody* softBody, btVertexBufferDescriptor* vertexBuffer);
void btSoftBodySolverOutput_delete(btSoftBodySolverOutput* obj);
btSoftBodyWorldInfo* btSoftBodyWorldInfo_new();
btScalar btSoftBodyWorldInfo_getAir_density(btSoftBodyWorldInfo* obj);
btBroadphaseInterface* btSoftBodyWorldInfo_getBroadphase(btSoftBodyWorldInfo* obj);
btDispatcher* btSoftBodyWorldInfo_getDispatcher(btSoftBodyWorldInfo* obj);
void btSoftBodyWorldInfo_getGravity(btSoftBodyWorldInfo* obj, btScalar* value);
btScalar btSoftBodyWorldInfo_getMaxDisplacement(btSoftBodyWorldInfo* obj);
btSparseSdf3* btSoftBodyWorldInfo_getSparsesdf(btSoftBodyWorldInfo* obj);
btScalar btSoftBodyWorldInfo_getWater_density(btSoftBodyWorldInfo* obj);
void btSoftBodyWorldInfo_getWater_normal(btSoftBodyWorldInfo* obj, btScalar* value);
btScalar btSoftBodyWorldInfo_getWater_offset(btSoftBodyWorldInfo* obj);
void btSoftBodyWorldInfo_setAir_density(btSoftBodyWorldInfo* obj, btScalar value);
void btSoftBodyWorldInfo_setBroadphase(btSoftBodyWorldInfo* obj, btBroadphaseInterface* value);
void btSoftBodyWorldInfo_setDispatcher(btSoftBodyWorldInfo* obj, btDispatcher* value);
void btSoftBodyWorldInfo_setGravity(btSoftBodyWorldInfo* obj, const btScalar* value);
void btSoftBodyWorldInfo_setMaxDisplacement(btSoftBodyWorldInfo* obj, btScalar value);
void btSoftBodyWorldInfo_setWater_density(btSoftBodyWorldInfo* obj, btScalar value);
void btSoftBodyWorldInfo_setWater_normal(btSoftBodyWorldInfo* obj, const btScalar* value);
void btSoftBodyWorldInfo_setWater_offset(btSoftBodyWorldInfo* obj, btScalar value);
void btSoftBodyWorldInfo_delete(btSoftBodyWorldInfo* obj);
btSoftBody_AJoint_IControl* btSoftBody_AJoint_IControlWrapper_new(pIControl_Prepare PrepareCallback, pIControl_Speed SpeedCallback);
void* btSoftBody_AJoint_IControlWrapper_getWrapperData(btSoftBody_AJoint_IControlWrapper* obj);
void btSoftBody_AJoint_IControlWrapper_setWrapperData(btSoftBody_AJoint_IControlWrapper* obj, void* data);
btSoftBody_AJoint_IControl* btSoftBody_AJoint_IControl_new();
btSoftBody_AJoint_IControl* btSoftBody_AJoint_IControl_Default();
void btSoftBody_AJoint_IControl_Prepare(btSoftBody_AJoint_IControl* obj, btSoftBody_AJoint* __unnamed0);
btScalar btSoftBody_AJoint_IControl_Speed(btSoftBody_AJoint_IControl* obj, btSoftBody_AJoint* __unnamed0, btScalar current);
void btSoftBody_AJoint_IControl_delete(btSoftBody_AJoint_IControl* obj);
btSoftBody_AJoint_Specs* btSoftBody_AJoint_Specs_new();
void btSoftBody_AJoint_Specs_getAxis(btSoftBody_AJoint_Specs* obj, btScalar* value);
btSoftBody_AJoint_IControl* btSoftBody_AJoint_Specs_getIcontrol(btSoftBody_AJoint_Specs* obj);
void btSoftBody_AJoint_Specs_setAxis(btSoftBody_AJoint_Specs* obj, const btScalar* value);
void btSoftBody_AJoint_Specs_setIcontrol(btSoftBody_AJoint_Specs* obj, btSoftBody_AJoint_IControl* value);
btSoftBody_AJoint* btSoftBody_AJoint_new();
btVector3* btSoftBody_AJoint_getAxis(btSoftBody_AJoint* obj);
btSoftBody_AJoint_IControl* btSoftBody_AJoint_getIcontrol(btSoftBody_AJoint* obj);
void btSoftBody_AJoint_setIcontrol(btSoftBody_AJoint* obj, btSoftBody_AJoint_IControl* value);
btSoftBody_Anchor* btSoftBody_Anchor_new();
btRigidBody* btSoftBody_Anchor_getBody(btSoftBody_Anchor* obj);
void btSoftBody_Anchor_getC0(btSoftBody_Anchor* obj, btScalar* value);
void btSoftBody_Anchor_getC1(btSoftBody_Anchor* obj, btScalar* value);
btScalar btSoftBody_Anchor_getC2(btSoftBody_Anchor* obj);
btScalar btSoftBody_Anchor_getInfluence(btSoftBody_Anchor* obj);
void btSoftBody_Anchor_getLocal(btSoftBody_Anchor* obj, btScalar* value);
btSoftBody_Node* btSoftBody_Anchor_getNode(btSoftBody_Anchor* obj);
void btSoftBody_Anchor_setBody(btSoftBody_Anchor* obj, btRigidBody* value);
void btSoftBody_Anchor_setC0(btSoftBody_Anchor* obj, const btScalar* value);
void btSoftBody_Anchor_setC1(btSoftBody_Anchor* obj, const btScalar* value);
void btSoftBody_Anchor_setC2(btSoftBody_Anchor* obj, btScalar value);
void btSoftBody_Anchor_setInfluence(btSoftBody_Anchor* obj, btScalar value);
void btSoftBody_Anchor_setLocal(btSoftBody_Anchor* obj, const btScalar* value);
void btSoftBody_Anchor_setNode(btSoftBody_Anchor* obj, btSoftBody_Node* value);
void btSoftBody_Anchor_delete(btSoftBody_Anchor* obj);
btSoftBody_Body* btSoftBody_Body_new();
btSoftBody_Body* btSoftBody_Body_new2(const btCollisionObject* colObj);
btSoftBody_Body* btSoftBody_Body_new3(btSoftBody_Cluster* p);
void btSoftBody_Body_activate(btSoftBody_Body* obj);
void btSoftBody_Body_angularVelocity(btSoftBody_Body* obj, const btScalar* rpos, btScalar* value);
void btSoftBody_Body_angularVelocity2(btSoftBody_Body* obj, btScalar* value);
void btSoftBody_Body_applyAImpulse(btSoftBody_Body* obj, const btSoftBody_Impulse* impulse);
void btSoftBody_Body_applyDAImpulse(btSoftBody_Body* obj, const btScalar* impulse);
void btSoftBody_Body_applyDCImpulse(btSoftBody_Body* obj, const btScalar* impulse);
void btSoftBody_Body_applyDImpulse(btSoftBody_Body* obj, const btScalar* impulse, const btScalar* rpos);
void btSoftBody_Body_applyImpulse(btSoftBody_Body* obj, const btSoftBody_Impulse* impulse, const btScalar* rpos);
void btSoftBody_Body_applyVAImpulse(btSoftBody_Body* obj, const btScalar* impulse);
void btSoftBody_Body_applyVImpulse(btSoftBody_Body* obj, const btScalar* impulse, const btScalar* rpos);
const btCollisionObject* btSoftBody_Body_getCollisionObject(btSoftBody_Body* obj);
btRigidBody* btSoftBody_Body_getRigid(btSoftBody_Body* obj);
btSoftBody_Cluster* btSoftBody_Body_getSoft(btSoftBody_Body* obj);
btScalar btSoftBody_Body_invMass(btSoftBody_Body* obj);
void btSoftBody_Body_invWorldInertia(btSoftBody_Body* obj, btScalar* value);
void btSoftBody_Body_linearVelocity(btSoftBody_Body* obj, btScalar* value);
void btSoftBody_Body_setCollisionObject(btSoftBody_Body* obj, const btCollisionObject* value);
void btSoftBody_Body_setRigid(btSoftBody_Body* obj, btRigidBody* value);
void btSoftBody_Body_setSoft(btSoftBody_Body* obj, btSoftBody_Cluster* value);
void btSoftBody_Body_velocity(btSoftBody_Body* obj, const btScalar* rpos, btScalar* value);
void btSoftBody_Body_xform(btSoftBody_Body* obj, btScalar* value);
void btSoftBody_Body_delete(btSoftBody_Body* obj);
btSoftBody_CJoint* btSoftBody_CJoint_new();
btScalar btSoftBody_CJoint_getFriction(btSoftBody_CJoint* obj);
int btSoftBody_CJoint_getLife(btSoftBody_CJoint* obj);
int btSoftBody_CJoint_getMaxlife(btSoftBody_CJoint* obj);
void btSoftBody_CJoint_getNormal(btSoftBody_CJoint* obj, btScalar* value);
btVector3* btSoftBody_CJoint_getRpos(btSoftBody_CJoint* obj);
void btSoftBody_CJoint_setFriction(btSoftBody_CJoint* obj, btScalar value);
void btSoftBody_CJoint_setLife(btSoftBody_CJoint* obj, int value);
void btSoftBody_CJoint_setMaxlife(btSoftBody_CJoint* obj, int value);
void btSoftBody_CJoint_setNormal(btSoftBody_CJoint* obj, const btScalar* value);
btSoftBody_Cluster* btSoftBody_Cluster_new();
btScalar btSoftBody_Cluster_getAdamping(btSoftBody_Cluster* obj);
void btSoftBody_Cluster_getAv(btSoftBody_Cluster* obj, btScalar* value);
int btSoftBody_Cluster_getClusterIndex(btSoftBody_Cluster* obj);
bool btSoftBody_Cluster_getCollide(btSoftBody_Cluster* obj);
void btSoftBody_Cluster_getCom(btSoftBody_Cluster* obj, btScalar* value);
bool btSoftBody_Cluster_getContainsAnchor(btSoftBody_Cluster* obj);
btVector3* btSoftBody_Cluster_getDimpulses(btSoftBody_Cluster* obj);
btAlignedVector3Array* btSoftBody_Cluster_getFramerefs(btSoftBody_Cluster* obj);
void btSoftBody_Cluster_getFramexform(btSoftBody_Cluster* obj, btScalar* value);
btScalar btSoftBody_Cluster_getIdmass(btSoftBody_Cluster* obj);
btScalar btSoftBody_Cluster_getImass(btSoftBody_Cluster* obj);
void btSoftBody_Cluster_getInvwi(btSoftBody_Cluster* obj, btScalar* value);
btScalar btSoftBody_Cluster_getLdamping(btSoftBody_Cluster* obj);
btDbvtNode* btSoftBody_Cluster_getLeaf(btSoftBody_Cluster* obj);
void btSoftBody_Cluster_getLocii(btSoftBody_Cluster* obj, btScalar* value);
void btSoftBody_Cluster_getLv(btSoftBody_Cluster* obj, btScalar* value);
btAlignedScalarArray* btSoftBody_Cluster_getMasses(btSoftBody_Cluster* obj);
btScalar btSoftBody_Cluster_getMatching(btSoftBody_Cluster* obj);
btScalar btSoftBody_Cluster_getMaxSelfCollisionImpulse(btSoftBody_Cluster* obj);
btScalar btSoftBody_Cluster_getNdamping(btSoftBody_Cluster* obj);
int btSoftBody_Cluster_getNdimpulses(btSoftBody_Cluster* obj);
btAlignedSoftBodyNodePtrArray* btSoftBody_Cluster_getNodes(btSoftBody_Cluster* obj);
int btSoftBody_Cluster_getNvimpulses(btSoftBody_Cluster* obj);
btScalar btSoftBody_Cluster_getSelfCollisionImpulseFactor(btSoftBody_Cluster* obj);
btVector3* btSoftBody_Cluster_getVimpulses(btSoftBody_Cluster* obj);
void btSoftBody_Cluster_setAdamping(btSoftBody_Cluster* obj, btScalar value);
void btSoftBody_Cluster_setAv(btSoftBody_Cluster* obj, const btScalar* value);
void btSoftBody_Cluster_setClusterIndex(btSoftBody_Cluster* obj, int value);
void btSoftBody_Cluster_setCollide(btSoftBody_Cluster* obj, bool value);
void btSoftBody_Cluster_setCom(btSoftBody_Cluster* obj, const btScalar* value);
void btSoftBody_Cluster_setContainsAnchor(btSoftBody_Cluster* obj, bool value);
void btSoftBody_Cluster_setFramexform(btSoftBody_Cluster* obj, const btScalar* value);
void btSoftBody_Cluster_setIdmass(btSoftBody_Cluster* obj, btScalar value);
void btSoftBody_Cluster_setImass(btSoftBody_Cluster* obj, btScalar value);
void btSoftBody_Cluster_setInvwi(btSoftBody_Cluster* obj, const btScalar* value);
void btSoftBody_Cluster_setLdamping(btSoftBody_Cluster* obj, btScalar value);
void btSoftBody_Cluster_setLeaf(btSoftBody_Cluster* obj, btDbvtNode* value);
void btSoftBody_Cluster_setLocii(btSoftBody_Cluster* obj, const btScalar* value);
void btSoftBody_Cluster_setLv(btSoftBody_Cluster* obj, const btScalar* value);
void btSoftBody_Cluster_setMatching(btSoftBody_Cluster* obj, btScalar value);
void btSoftBody_Cluster_setMaxSelfCollisionImpulse(btSoftBody_Cluster* obj, btScalar value);
void btSoftBody_Cluster_setNdamping(btSoftBody_Cluster* obj, btScalar value);
void btSoftBody_Cluster_setNdimpulses(btSoftBody_Cluster* obj, int value);
void btSoftBody_Cluster_setNvimpulses(btSoftBody_Cluster* obj, int value);
void btSoftBody_Cluster_setSelfCollisionImpulseFactor(btSoftBody_Cluster* obj, btScalar value);
void btSoftBody_Cluster_setVimpulses(btSoftBody_Cluster* obj, btScalar* value);
void btSoftBody_Cluster_delete(btSoftBody_Cluster* obj);
btSoftBody_Config* btSoftBody_Config_new();
btSoftBody_eAeroModel btSoftBody_Config_getAeromodel(btSoftBody_Config* obj);
int btSoftBody_Config_getCiterations(btSoftBody_Config* obj);
int btSoftBody_Config_getCollisions(btSoftBody_Config* obj);
int btSoftBody_Config_getDiterations(btSoftBody_Config* obj);
btAlignedSoftBodyPSolverArray* btSoftBody_Config_getDsequence(btSoftBody_Config* obj);
btScalar btSoftBody_Config_getKAHR(btSoftBody_Config* obj);
btScalar btSoftBody_Config_getKCHR(btSoftBody_Config* obj);
btScalar btSoftBody_Config_getKDF(btSoftBody_Config* obj);
btScalar btSoftBody_Config_getKDG(btSoftBody_Config* obj);
btScalar btSoftBody_Config_getKDP(btSoftBody_Config* obj);
btScalar btSoftBody_Config_getKKHR(btSoftBody_Config* obj);
btScalar btSoftBody_Config_getKLF(btSoftBody_Config* obj);
btScalar btSoftBody_Config_getKMT(btSoftBody_Config* obj);
btScalar btSoftBody_Config_getKPR(btSoftBody_Config* obj);
btScalar btSoftBody_Config_getKSHR(btSoftBody_Config* obj);
btScalar btSoftBody_Config_getKSK_SPLT_CL(btSoftBody_Config* obj);
btScalar btSoftBody_Config_getKSKHR_CL(btSoftBody_Config* obj);
btScalar btSoftBody_Config_getKSR_SPLT_CL(btSoftBody_Config* obj);
btScalar btSoftBody_Config_getKSRHR_CL(btSoftBody_Config* obj);
btScalar btSoftBody_Config_getKSS_SPLT_CL(btSoftBody_Config* obj);
btScalar btSoftBody_Config_getKSSHR_CL(btSoftBody_Config* obj);
btScalar btSoftBody_Config_getKVC(btSoftBody_Config* obj);
btScalar btSoftBody_Config_getKVCF(btSoftBody_Config* obj);
btScalar btSoftBody_Config_getMaxvolume(btSoftBody_Config* obj);
int btSoftBody_Config_getPiterations(btSoftBody_Config* obj);
btAlignedSoftBodyPSolverArray* btSoftBody_Config_getPsequence(btSoftBody_Config* obj);
btScalar btSoftBody_Config_getTimescale(btSoftBody_Config* obj);
int btSoftBody_Config_getViterations(btSoftBody_Config* obj);
btAlignedSoftBodyVSolverArray* btSoftBody_Config_getVsequence(btSoftBody_Config* obj);
void btSoftBody_Config_setAeromodel(btSoftBody_Config* obj, btSoftBody_eAeroModel value);
void btSoftBody_Config_setCiterations(btSoftBody_Config* obj, int value);
void btSoftBody_Config_setCollisions(btSoftBody_Config* obj, int value);
void btSoftBody_Config_setDiterations(btSoftBody_Config* obj, int value);
void btSoftBody_Config_setKAHR(btSoftBody_Config* obj, btScalar value);
void btSoftBody_Config_setKCHR(btSoftBody_Config* obj, btScalar value);
void btSoftBody_Config_setKDF(btSoftBody_Config* obj, btScalar value);
void btSoftBody_Config_setKDG(btSoftBody_Config* obj, btScalar value);
void btSoftBody_Config_setKDP(btSoftBody_Config* obj, btScalar value);
void btSoftBody_Config_setKKHR(btSoftBody_Config* obj, btScalar value);
void btSoftBody_Config_setKLF(btSoftBody_Config* obj, btScalar value);
void btSoftBody_Config_setKMT(btSoftBody_Config* obj, btScalar value);
void btSoftBody_Config_setKPR(btSoftBody_Config* obj, btScalar value);
void btSoftBody_Config_setKSHR(btSoftBody_Config* obj, btScalar value);
void btSoftBody_Config_setKSK_SPLT_CL(btSoftBody_Config* obj, btScalar value);
void btSoftBody_Config_setKSKHR_CL(btSoftBody_Config* obj, btScalar value);
void btSoftBody_Config_setKSR_SPLT_CL(btSoftBody_Config* obj, btScalar value);
void btSoftBody_Config_setKSRHR_CL(btSoftBody_Config* obj, btScalar value);
void btSoftBody_Config_setKSS_SPLT_CL(btSoftBody_Config* obj, btScalar value);
void btSoftBody_Config_setKSSHR_CL(btSoftBody_Config* obj, btScalar value);
void btSoftBody_Config_setKVC(btSoftBody_Config* obj, btScalar value);
void btSoftBody_Config_setKVCF(btSoftBody_Config* obj, btScalar value);
void btSoftBody_Config_setMaxvolume(btSoftBody_Config* obj, btScalar value);
void btSoftBody_Config_setPiterations(btSoftBody_Config* obj, int value);
void btSoftBody_Config_setTimescale(btSoftBody_Config* obj, btScalar value);
void btSoftBody_Config_setViterations(btSoftBody_Config* obj, int value);
void btSoftBody_Config_delete(btSoftBody_Config* obj);
btSoftBody_Element* btSoftBody_Element_new();
void* btSoftBody_Element_getTag(btSoftBody_Element* obj);
void btSoftBody_Element_setTag(btSoftBody_Element* obj, void* value);
void btSoftBody_Element_delete(btSoftBody_Element* obj);
btSoftBody_Face* btSoftBody_Face_new();
btDbvtNode* btSoftBody_Face_getLeaf(btSoftBody_Face* obj);
btSoftBody_Node** btSoftBody_Face_getN(btSoftBody_Face* obj);
void btSoftBody_Face_getNormal(btSoftBody_Face* obj, btScalar* value);
btScalar btSoftBody_Face_getRa(btSoftBody_Face* obj);
void btSoftBody_Face_setLeaf(btSoftBody_Face* obj, btDbvtNode* value);
void btSoftBody_Face_setNormal(btSoftBody_Face* obj, const btScalar* value);
void btSoftBody_Face_setRa(btSoftBody_Face* obj, btScalar value);
btSoftBody_Feature* btSoftBody_Feature_new();
btSoftBody_Material* btSoftBody_Feature_getMaterial(btSoftBody_Feature* obj);
void btSoftBody_Feature_setMaterial(btSoftBody_Feature* obj, btSoftBody_Material* value);
btSoftBody_ImplicitFn* btSoftBody_ImplicitFnWrapper_new(pImplicitFn_Eval evalCallback);
btScalar btSoftBody_ImplicitFn_Eval(btSoftBody_ImplicitFn* obj, const btScalar* x);
void btSoftBody_ImplicitFn_delete(btSoftBody_ImplicitFn* obj);
btSoftBody_Impulse* btSoftBody_Impulse_new();
int btSoftBody_Impulse_getAsDrift(btSoftBody_Impulse* obj);
int btSoftBody_Impulse_getAsVelocity(btSoftBody_Impulse* obj);
void btSoftBody_Impulse_getDrift(btSoftBody_Impulse* obj, btScalar* value);
void btSoftBody_Impulse_getVelocity(btSoftBody_Impulse* obj, btScalar* value);
btSoftBody_Impulse* btSoftBody_Impulse_operator_n(btSoftBody_Impulse* obj);
btSoftBody_Impulse* btSoftBody_Impulse_operator_m(btSoftBody_Impulse* obj, btScalar x);
void btSoftBody_Impulse_setAsDrift(btSoftBody_Impulse* obj, int value);
void btSoftBody_Impulse_setAsVelocity(btSoftBody_Impulse* obj, int value);
void btSoftBody_Impulse_setDrift(btSoftBody_Impulse* obj, const btScalar* value);
void btSoftBody_Impulse_setVelocity(btSoftBody_Impulse* obj, const btScalar* value);
void btSoftBody_Impulse_delete(btSoftBody_Impulse* obj);
btSoftBody_Joint_Specs* btSoftBody_Joint_Specs_new();
btScalar btSoftBody_Joint_Specs_getCfm(btSoftBody_Joint_Specs* obj);
btScalar btSoftBody_Joint_Specs_getErp(btSoftBody_Joint_Specs* obj);
btScalar btSoftBody_Joint_Specs_getSplit(btSoftBody_Joint_Specs* obj);
void btSoftBody_Joint_Specs_setCfm(btSoftBody_Joint_Specs* obj, btScalar value);
void btSoftBody_Joint_Specs_setErp(btSoftBody_Joint_Specs* obj, btScalar value);
void btSoftBody_Joint_Specs_setSplit(btSoftBody_Joint_Specs* obj, btScalar value);
void btSoftBody_Joint_Specs_delete(btSoftBody_Joint_Specs* obj);
btSoftBody_Body* btSoftBody_Joint_getBodies(btSoftBody_Joint* obj);
btScalar btSoftBody_Joint_getCfm(btSoftBody_Joint* obj);
bool btSoftBody_Joint_getDelete(btSoftBody_Joint* obj);
void btSoftBody_Joint_getDrift(btSoftBody_Joint* obj, btScalar* value);
btScalar btSoftBody_Joint_getErp(btSoftBody_Joint* obj);
void btSoftBody_Joint_getMassmatrix(btSoftBody_Joint* obj, btScalar* value);
btVector3* btSoftBody_Joint_getRefs(btSoftBody_Joint* obj);
void btSoftBody_Joint_getSdrift(btSoftBody_Joint* obj, btScalar* value);
btScalar btSoftBody_Joint_getSplit(btSoftBody_Joint* obj);
void btSoftBody_Joint_Prepare(btSoftBody_Joint* obj, btScalar dt, int iterations);
void btSoftBody_Joint_setCfm(btSoftBody_Joint* obj, btScalar value);
void btSoftBody_Joint_setDelete(btSoftBody_Joint* obj, bool value);
void btSoftBody_Joint_setDrift(btSoftBody_Joint* obj, const btScalar* value);
void btSoftBody_Joint_setErp(btSoftBody_Joint* obj, btScalar value);
void btSoftBody_Joint_setMassmatrix(btSoftBody_Joint* obj, const btScalar* value);
void btSoftBody_Joint_setSdrift(btSoftBody_Joint* obj, const btScalar* value);
void btSoftBody_Joint_setSplit(btSoftBody_Joint* obj, btScalar value);
void btSoftBody_Joint_Solve(btSoftBody_Joint* obj, btScalar dt, btScalar sor);
void btSoftBody_Joint_Terminate(btSoftBody_Joint* obj, btScalar dt);
btSoftBody_Joint_eType btSoftBody_Joint_Type(btSoftBody_Joint* obj);
void btSoftBody_Joint_delete(btSoftBody_Joint* obj);
btSoftBody_Link* btSoftBody_Link_new();
btSoftBody_Link* btSoftBody_Link_new2(btSoftBody_Link* obj);
int btSoftBody_Link_getBbending(btSoftBody_Link* obj);
btScalar btSoftBody_Link_getC0(btSoftBody_Link* obj);
btScalar btSoftBody_Link_getC1(btSoftBody_Link* obj);
btScalar btSoftBody_Link_getC2(btSoftBody_Link* obj);
void btSoftBody_Link_getC3(btSoftBody_Link* obj, btScalar* value);
btSoftBody_Node** btSoftBody_Link_getN(btSoftBody_Link* obj);
btScalar btSoftBody_Link_getRl(btSoftBody_Link* obj);
void btSoftBody_Link_setBbending(btSoftBody_Link* obj, int value);
void btSoftBody_Link_setC0(btSoftBody_Link* obj, btScalar value);
void btSoftBody_Link_setC1(btSoftBody_Link* obj, btScalar value);
void btSoftBody_Link_setC2(btSoftBody_Link* obj, btScalar value);
void btSoftBody_Link_setC3(btSoftBody_Link* obj, const btScalar* value);
void btSoftBody_Link_setRl(btSoftBody_Link* obj, btScalar value);
btSoftBody_LJoint_Specs* btSoftBody_LJoint_Specs_new();
void btSoftBody_LJoint_Specs_getPosition(btSoftBody_LJoint_Specs* obj, btScalar* value);
void btSoftBody_LJoint_Specs_setPosition(btSoftBody_LJoint_Specs* obj, const btScalar* value);
btSoftBody_LJoint* btSoftBody_LJoint_new();
btVector3* btSoftBody_LJoint_getRpos(btSoftBody_LJoint* obj);
btSoftBody_Material* btSoftBody_Material_new();
int btSoftBody_Material_getFlags(btSoftBody_Material* obj);
btScalar btSoftBody_Material_getKAST(btSoftBody_Material* obj);
btScalar btSoftBody_Material_getKLST(btSoftBody_Material* obj);
btScalar btSoftBody_Material_getKVST(btSoftBody_Material* obj);
void btSoftBody_Material_setFlags(btSoftBody_Material* obj, int value);
void btSoftBody_Material_setKAST(btSoftBody_Material* obj, btScalar value);
void btSoftBody_Material_setKLST(btSoftBody_Material* obj, btScalar value);
void btSoftBody_Material_setKVST(btSoftBody_Material* obj, btScalar value);
btSoftBody_Node* btSoftBody_Node_new();
btScalar btSoftBody_Node_getArea(btSoftBody_Node* obj);
int btSoftBody_Node_getBattach(btSoftBody_Node* obj);
void btSoftBody_Node_getF(btSoftBody_Node* obj, btScalar* value);
btScalar btSoftBody_Node_getIm(btSoftBody_Node* obj);
btDbvtNode* btSoftBody_Node_getLeaf(btSoftBody_Node* obj);
void btSoftBody_Node_getN(btSoftBody_Node* obj, btScalar* value);
void btSoftBody_Node_getQ(btSoftBody_Node* obj, btScalar* value);
void btSoftBody_Node_getV(btSoftBody_Node* obj, btScalar* value);
void btSoftBody_Node_getX(btSoftBody_Node* obj, btScalar* value);
void btSoftBody_Node_setArea(btSoftBody_Node* obj, btScalar value);
void btSoftBody_Node_setBattach(btSoftBody_Node* obj, int value);
void btSoftBody_Node_setF(btSoftBody_Node* obj, const btScalar* value);
void btSoftBody_Node_setIm(btSoftBody_Node* obj, btScalar value);
void btSoftBody_Node_setLeaf(btSoftBody_Node* obj, btDbvtNode* value);
void btSoftBody_Node_setN(btSoftBody_Node* obj, const btScalar* value);
void btSoftBody_Node_setQ(btSoftBody_Node* obj, const btScalar* value);
void btSoftBody_Node_setV(btSoftBody_Node* obj, const btScalar* value);
void btSoftBody_Node_setX(btSoftBody_Node* obj, const btScalar* value);
btSoftBody_Note* btSoftBody_Note_new();
btScalar* btSoftBody_Note_getCoords(btSoftBody_Note* obj);
btSoftBody_Node** btSoftBody_Note_getNodes(btSoftBody_Note* obj);
void btSoftBody_Note_getOffset(btSoftBody_Note* obj, btScalar* value);
int btSoftBody_Note_getRank(btSoftBody_Note* obj);
const char* btSoftBody_Note_getText(btSoftBody_Note* obj);
void btSoftBody_Note_setOffset(btSoftBody_Note* obj, const btScalar* value);
void btSoftBody_Note_setRank(btSoftBody_Note* obj, int value);
void btSoftBody_Note_setText(btSoftBody_Note* obj, const char* value);
btSoftBody_Pose* btSoftBody_Pose_new();
void btSoftBody_Pose_getAqq(btSoftBody_Pose* obj, btScalar* value);
bool btSoftBody_Pose_getBframe(btSoftBody_Pose* obj);
bool btSoftBody_Pose_getBvolume(btSoftBody_Pose* obj);
void btSoftBody_Pose_getCom(btSoftBody_Pose* obj, btScalar* value);
btAlignedVector3Array* btSoftBody_Pose_getPos(btSoftBody_Pose* obj);
void btSoftBody_Pose_getRot(btSoftBody_Pose* obj, btScalar* value);
void btSoftBody_Pose_getScl(btSoftBody_Pose* obj, btScalar* value);
btAlignedScalarArray* btSoftBody_Pose_getWgh(btSoftBody_Pose* obj);
btScalar btSoftBody_Pose_getVolume(btSoftBody_Pose* obj);
void btSoftBody_Pose_setAqq(btSoftBody_Pose* obj, const btScalar* value);
void btSoftBody_Pose_setBframe(btSoftBody_Pose* obj, bool value);
void btSoftBody_Pose_setBvolume(btSoftBody_Pose* obj, bool value);
void btSoftBody_Pose_setCom(btSoftBody_Pose* obj, const btScalar* value);
void btSoftBody_Pose_setRot(btSoftBody_Pose* obj, const btScalar* value);
void btSoftBody_Pose_setScl(btSoftBody_Pose* obj, const btScalar* value);
void btSoftBody_Pose_setVolume(btSoftBody_Pose* obj, btScalar value);
void btSoftBody_Pose_delete(btSoftBody_Pose* obj);
btSoftBody_RayFromToCaster* btSoftBody_RayFromToCaster_new(const btScalar* rayFrom, const btScalar* rayTo, btScalar mxt);
btSoftBody_Face* btSoftBody_RayFromToCaster_getFace(btSoftBody_RayFromToCaster* obj);
btScalar btSoftBody_RayFromToCaster_getMint(btSoftBody_RayFromToCaster* obj);
void btSoftBody_RayFromToCaster_getRayFrom(btSoftBody_RayFromToCaster* obj, btScalar* value);
void btSoftBody_RayFromToCaster_getRayNormalizedDirection(btSoftBody_RayFromToCaster* obj, btScalar* value);
void btSoftBody_RayFromToCaster_getRayTo(btSoftBody_RayFromToCaster* obj, btScalar* value);
int btSoftBody_RayFromToCaster_getTests(btSoftBody_RayFromToCaster* obj);
btScalar btSoftBody_RayFromToCaster_rayFromToTriangle(const btScalar* rayFrom, const btScalar* rayTo, const btScalar* rayNormalizedDirection, const btScalar* a, const btScalar* b, const btScalar* c);
btScalar btSoftBody_RayFromToCaster_rayFromToTriangle2(const btScalar* rayFrom, const btScalar* rayTo, const btScalar* rayNormalizedDirection, const btScalar* a, const btScalar* b, const btScalar* c, btScalar maxt);
void btSoftBody_RayFromToCaster_setFace(btSoftBody_RayFromToCaster* obj, btSoftBody_Face* value);
void btSoftBody_RayFromToCaster_setMint(btSoftBody_RayFromToCaster* obj, btScalar value);
void btSoftBody_RayFromToCaster_setRayFrom(btSoftBody_RayFromToCaster* obj, const btScalar* value);
void btSoftBody_RayFromToCaster_setRayNormalizedDirection(btSoftBody_RayFromToCaster* obj, const btScalar* value);
void btSoftBody_RayFromToCaster_setRayTo(btSoftBody_RayFromToCaster* obj, const btScalar* value);
void btSoftBody_RayFromToCaster_setTests(btSoftBody_RayFromToCaster* obj, int value);
btSoftBody_RContact* btSoftBody_RContact_new();
void btSoftBody_RContact_getC0(btSoftBody_RContact* obj, btScalar* value);
void btSoftBody_RContact_getC1(btSoftBody_RContact* obj, btScalar* value);
btScalar btSoftBody_RContact_getC2(btSoftBody_RContact* obj);
btScalar btSoftBody_RContact_getC3(btSoftBody_RContact* obj);
btScalar btSoftBody_RContact_getC4(btSoftBody_RContact* obj);
btSoftBody_sCti* btSoftBody_RContact_getCti(btSoftBody_RContact* obj);
btSoftBody_Node* btSoftBody_RContact_getNode(btSoftBody_RContact* obj);
void btSoftBody_RContact_setC0(btSoftBody_RContact* obj, const btScalar* value);
void btSoftBody_RContact_setC1(btSoftBody_RContact* obj, const btScalar* value);
void btSoftBody_RContact_setC2(btSoftBody_RContact* obj, btScalar value);
void btSoftBody_RContact_setC3(btSoftBody_RContact* obj, btScalar value);
void btSoftBody_RContact_setC4(btSoftBody_RContact* obj, btScalar value);
void btSoftBody_RContact_setNode(btSoftBody_RContact* obj, btSoftBody_Node* value);
void btSoftBody_RContact_delete(btSoftBody_RContact* obj);
btSoftBody_SContact* btSoftBody_SContact_new();
btScalar* btSoftBody_SContact_getCfm(btSoftBody_SContact* obj);
btSoftBody_Face* btSoftBody_SContact_getFace(btSoftBody_SContact* obj);
btScalar btSoftBody_SContact_getFriction(btSoftBody_SContact* obj);
btScalar btSoftBody_SContact_getMargin(btSoftBody_SContact* obj);
btSoftBody_Node* btSoftBody_SContact_getNode(btSoftBody_SContact* obj);
void btSoftBody_SContact_getNormal(btSoftBody_SContact* obj, btScalar* value);
void btSoftBody_SContact_getWeights(btSoftBody_SContact* obj, btScalar* value);
void btSoftBody_SContact_setFace(btSoftBody_SContact* obj, btSoftBody_Face* value);
void btSoftBody_SContact_setFriction(btSoftBody_SContact* obj, btScalar value);
void btSoftBody_SContact_setMargin(btSoftBody_SContact* obj, btScalar value);
void btSoftBody_SContact_setNode(btSoftBody_SContact* obj, btSoftBody_Node* value);
void btSoftBody_SContact_setNormal(btSoftBody_SContact* obj, const btScalar* value);
void btSoftBody_SContact_setWeights(btSoftBody_SContact* obj, const btScalar* value);
void btSoftBody_SContact_delete(btSoftBody_SContact* obj);
btSoftBody_sCti* btSoftBody_sCti_new();
const btCollisionObject* btSoftBody_sCti_getColObj(btSoftBody_sCti* obj);
void btSoftBody_sCti_getNormal(btSoftBody_sCti* obj, btScalar* value);
btScalar btSoftBody_sCti_getOffset(btSoftBody_sCti* obj);
void btSoftBody_sCti_setColObj(btSoftBody_sCti* obj, const btCollisionObject* value);
void btSoftBody_sCti_setNormal(btSoftBody_sCti* obj, const btScalar* value);
void btSoftBody_sCti_setOffset(btSoftBody_sCti* obj, btScalar value);
void btSoftBody_sCti_delete(btSoftBody_sCti* obj);
btSoftBody_sMedium* btSoftBody_sMedium_new();
btScalar btSoftBody_sMedium_getDensity(btSoftBody_sMedium* obj);
btScalar btSoftBody_sMedium_getPressure(btSoftBody_sMedium* obj);
void btSoftBody_sMedium_getVelocity(btSoftBody_sMedium* obj, btScalar* value);
void btSoftBody_sMedium_setDensity(btSoftBody_sMedium* obj, btScalar value);
void btSoftBody_sMedium_setPressure(btSoftBody_sMedium* obj, btScalar value);
void btSoftBody_sMedium_setVelocity(btSoftBody_sMedium* obj, const btScalar* value);
void btSoftBody_sMedium_delete(btSoftBody_sMedium* obj);
btSoftBody_SolverState* btSoftBody_SolverState_new();
btScalar btSoftBody_SolverState_getIsdt(btSoftBody_SolverState* obj);
btScalar btSoftBody_SolverState_getRadmrg(btSoftBody_SolverState* obj);
btScalar btSoftBody_SolverState_getSdt(btSoftBody_SolverState* obj);
btScalar btSoftBody_SolverState_getUpdmrg(btSoftBody_SolverState* obj);
btScalar btSoftBody_SolverState_getVelmrg(btSoftBody_SolverState* obj);
void btSoftBody_SolverState_setIsdt(btSoftBody_SolverState* obj, btScalar value);
void btSoftBody_SolverState_setRadmrg(btSoftBody_SolverState* obj, btScalar value);
void btSoftBody_SolverState_setSdt(btSoftBody_SolverState* obj, btScalar value);
void btSoftBody_SolverState_setUpdmrg(btSoftBody_SolverState* obj, btScalar value);
void btSoftBody_SolverState_setVelmrg(btSoftBody_SolverState* obj, btScalar value);
void btSoftBody_SolverState_delete(btSoftBody_SolverState* obj);
btSoftBody_sRayCast* btSoftBody_sRayCast_new();
btSoftBody* btSoftBody_sRayCast_getBody(btSoftBody_sRayCast* obj);
btSoftBody_eFeature btSoftBody_sRayCast_getFeature(btSoftBody_sRayCast* obj);
btScalar btSoftBody_sRayCast_getFraction(btSoftBody_sRayCast* obj);
int btSoftBody_sRayCast_getIndex(btSoftBody_sRayCast* obj);
void btSoftBody_sRayCast_setBody(btSoftBody_sRayCast* obj, btSoftBody* value);
void btSoftBody_sRayCast_setFeature(btSoftBody_sRayCast* obj, btSoftBody_eFeature value);
void btSoftBody_sRayCast_setFraction(btSoftBody_sRayCast* obj, btScalar value);
void btSoftBody_sRayCast_setIndex(btSoftBody_sRayCast* obj, int value);
void btSoftBody_sRayCast_delete(btSoftBody_sRayCast* obj);
btSoftBody_Tetra* btSoftBody_Tetra_new();
btVector3* btSoftBody_Tetra_getC0(btSoftBody_Tetra* obj);
btScalar btSoftBody_Tetra_getC1(btSoftBody_Tetra* obj);
btScalar btSoftBody_Tetra_getC2(btSoftBody_Tetra* obj);
btDbvtNode* btSoftBody_Tetra_getLeaf(btSoftBody_Tetra* obj);
btSoftBody_Node** btSoftBody_Tetra_getN(btSoftBody_Tetra* obj);
btScalar btSoftBody_Tetra_getRv(btSoftBody_Tetra* obj);
void btSoftBody_Tetra_setC1(btSoftBody_Tetra* obj, btScalar value);
void btSoftBody_Tetra_setC2(btSoftBody_Tetra* obj, btScalar value);
void btSoftBody_Tetra_setLeaf(btSoftBody_Tetra* obj, btDbvtNode* value);
void btSoftBody_Tetra_setRv(btSoftBody_Tetra* obj, btScalar value);
btSoftBody* btSoftBody_new(btSoftBodyWorldInfo* worldInfo, int node_count, const btScalar* x, const btScalar* m);
btSoftBody* btSoftBody_new2(btSoftBodyWorldInfo* worldInfo);
void btSoftBody_addAeroForceToFace(btSoftBody* obj, const btScalar* windVelocity, int faceIndex);
void btSoftBody_addAeroForceToNode(btSoftBody* obj, const btScalar* windVelocity, int nodeIndex);
void btSoftBody_addForce(btSoftBody* obj, const btScalar* force);
void btSoftBody_addForce2(btSoftBody* obj, const btScalar* force, int node);
void btSoftBody_addVelocity(btSoftBody* obj, const btScalar* velocity, int node);
void btSoftBody_addVelocity2(btSoftBody* obj, const btScalar* velocity);
void btSoftBody_appendAnchor(btSoftBody* obj, int node, btRigidBody* body, const btScalar* localPivot);
void btSoftBody_appendAnchor2(btSoftBody* obj, int node, btRigidBody* body, const btScalar* localPivot, bool disableCollisionBetweenLinkedBodies);
void btSoftBody_appendAnchor3(btSoftBody* obj, int node, btRigidBody* body, const btScalar* localPivot, bool disableCollisionBetweenLinkedBodies, btScalar influence);
void btSoftBody_appendAnchor4(btSoftBody* obj, int node, btRigidBody* body);
void btSoftBody_appendAnchor5(btSoftBody* obj, int node, btRigidBody* body, bool disableCollisionBetweenLinkedBodies);
void btSoftBody_appendAnchor6(btSoftBody* obj, int node, btRigidBody* body, bool disableCollisionBetweenLinkedBodies, btScalar influence);
void btSoftBody_appendAngularJoint(btSoftBody* obj, const btSoftBody_AJoint_Specs* specs);
void btSoftBody_appendAngularJoint2(btSoftBody* obj, const btSoftBody_AJoint_Specs* specs, btSoftBody_Body* body);
void btSoftBody_appendAngularJoint3(btSoftBody* obj, const btSoftBody_AJoint_Specs* specs, btSoftBody* body);
void btSoftBody_appendAngularJoint4(btSoftBody* obj, const btSoftBody_AJoint_Specs* specs, btSoftBody_Cluster* body0, btSoftBody_Body* body1);
void btSoftBody_appendFace(btSoftBody* obj);
void btSoftBody_appendFace2(btSoftBody* obj, int model);
void btSoftBody_appendFace3(btSoftBody* obj, int model, btSoftBody_Material* mat);
void btSoftBody_appendFace4(btSoftBody* obj, int node0, int node1, int node2);
void btSoftBody_appendFace5(btSoftBody* obj, int node0, int node1, int node2, btSoftBody_Material* mat);
void btSoftBody_appendLinearJoint(btSoftBody* obj, const btSoftBody_LJoint_Specs* specs, btSoftBody* body);
void btSoftBody_appendLinearJoint2(btSoftBody* obj, const btSoftBody_LJoint_Specs* specs);
void btSoftBody_appendLinearJoint3(btSoftBody* obj, const btSoftBody_LJoint_Specs* specs, btSoftBody_Body* body);
void btSoftBody_appendLinearJoint4(btSoftBody* obj, const btSoftBody_LJoint_Specs* specs, btSoftBody_Cluster* body0, btSoftBody_Body* body1);
void btSoftBody_appendLink(btSoftBody* obj, int node0, int node1);
void btSoftBody_appendLink2(btSoftBody* obj, int node0, int node1, btSoftBody_Material* mat);
void btSoftBody_appendLink3(btSoftBody* obj, int node0, int node1, btSoftBody_Material* mat, bool bcheckexist);
void btSoftBody_appendLink4(btSoftBody* obj);
void btSoftBody_appendLink5(btSoftBody* obj, int model);
void btSoftBody_appendLink6(btSoftBody* obj, int model, btSoftBody_Material* mat);
void btSoftBody_appendLink7(btSoftBody* obj, btSoftBody_Node* node0, btSoftBody_Node* node1);
void btSoftBody_appendLink8(btSoftBody* obj, btSoftBody_Node* node0, btSoftBody_Node* node1, btSoftBody_Material* mat);
void btSoftBody_appendLink9(btSoftBody* obj, btSoftBody_Node* node0, btSoftBody_Node* node1, btSoftBody_Material* mat, bool bcheckexist);
btSoftBody_Material* btSoftBody_appendMaterial(btSoftBody* obj);
void btSoftBody_appendNode(btSoftBody* obj, const btScalar* x, btScalar m);
void btSoftBody_appendNote(btSoftBody* obj, const char* text, const btScalar* o, btSoftBody_Face* feature);
void btSoftBody_appendNote2(btSoftBody* obj, const char* text, const btScalar* o, btSoftBody_Link* feature);
void btSoftBody_appendNote3(btSoftBody* obj, const char* text, const btScalar* o, btSoftBody_Node* feature);
void btSoftBody_appendNote4(btSoftBody* obj, const char* text, const btScalar* o);
void btSoftBody_appendNote5(btSoftBody* obj, const char* text, const btScalar* o, const btScalar* c);
void btSoftBody_appendNote6(btSoftBody* obj, const char* text, const btScalar* o, const btScalar* c, btSoftBody_Node* n0);
void btSoftBody_appendNote7(btSoftBody* obj, const char* text, const btScalar* o, const btScalar* c, btSoftBody_Node* n0, btSoftBody_Node* n1);
void btSoftBody_appendNote8(btSoftBody* obj, const char* text, const btScalar* o, const btScalar* c, btSoftBody_Node* n0, btSoftBody_Node* n1, btSoftBody_Node* n2);
void btSoftBody_appendNote9(btSoftBody* obj, const char* text, const btScalar* o, const btScalar* c, btSoftBody_Node* n0, btSoftBody_Node* n1, btSoftBody_Node* n2, btSoftBody_Node* n3);
void btSoftBody_appendTetra(btSoftBody* obj, int model, btSoftBody_Material* mat);
void btSoftBody_appendTetra2(btSoftBody* obj, int node0, int node1, int node2, int node3);
void btSoftBody_appendTetra3(btSoftBody* obj, int node0, int node1, int node2, int node3, btSoftBody_Material* mat);
void btSoftBody_applyClusters(btSoftBody* obj, bool drift);
void btSoftBody_applyForces(btSoftBody* obj);
bool btSoftBody_checkContact(btSoftBody* obj, const btCollisionObjectWrapper* colObjWrap, const btScalar* x, btScalar margin, btSoftBody_sCti* cti);
bool btSoftBody_checkFace(btSoftBody* obj, int node0, int node1, int node2);
bool btSoftBody_checkLink(btSoftBody* obj, const btSoftBody_Node* node0, const btSoftBody_Node* node1);
bool btSoftBody_checkLink2(btSoftBody* obj, int node0, int node1);
void btSoftBody_cleanupClusters(btSoftBody* obj);
void btSoftBody_clusterAImpulse(btSoftBody_Cluster* cluster, const btSoftBody_Impulse* impulse);
void btSoftBody_clusterCom(btSoftBody* obj, int cluster, btScalar* value);
void btSoftBody_clusterCom2(const btSoftBody_Cluster* cluster, btScalar* value);
int btSoftBody_clusterCount(btSoftBody* obj);
void btSoftBody_clusterDAImpulse(btSoftBody_Cluster* cluster, const btScalar* impulse);
void btSoftBody_clusterDCImpulse(btSoftBody_Cluster* cluster, const btScalar* impulse);
void btSoftBody_clusterDImpulse(btSoftBody_Cluster* cluster, const btScalar* rpos, const btScalar* impulse);
void btSoftBody_clusterImpulse(btSoftBody_Cluster* cluster, const btScalar* rpos, const btSoftBody_Impulse* impulse);
void btSoftBody_clusterVAImpulse(btSoftBody_Cluster* cluster, const btScalar* impulse);
void btSoftBody_clusterVelocity(const btSoftBody_Cluster* cluster, const btScalar* rpos, btScalar* value);
void btSoftBody_clusterVImpulse(btSoftBody_Cluster* cluster, const btScalar* rpos, const btScalar* impulse);
bool btSoftBody_cutLink(btSoftBody* obj, const btSoftBody_Node* node0, const btSoftBody_Node* node1, btScalar position);
bool btSoftBody_cutLink2(btSoftBody* obj, int node0, int node1, btScalar position);
void btSoftBody_dampClusters(btSoftBody* obj);
void btSoftBody_defaultCollisionHandler(btSoftBody* obj, const btCollisionObjectWrapper* pcoWrap);
void btSoftBody_defaultCollisionHandler2(btSoftBody* obj, btSoftBody* psb);
void btSoftBody_evaluateCom(btSoftBody* obj, btScalar* value);
int btSoftBody_generateBendingConstraints(btSoftBody* obj, int distance);
int btSoftBody_generateBendingConstraints2(btSoftBody* obj, int distance, btSoftBody_Material* mat);
int btSoftBody_generateClusters(btSoftBody* obj, int k);
int btSoftBody_generateClusters2(btSoftBody* obj, int k, int maxiterations);
void btSoftBody_getAabb(btSoftBody* obj, btScalar* aabbMin, btScalar* aabbMax);
btAlignedSoftBodyAnchorArray* btSoftBody_getAnchors(btSoftBody* obj);
btVector3* btSoftBody_getBounds(btSoftBody* obj);
bool btSoftBody_getBUpdateRtCst(btSoftBody* obj);
btDbvt* btSoftBody_getCdbvt(btSoftBody* obj);
btSoftBody_Config* btSoftBody_getCfg(btSoftBody* obj);
btAlignedBoolArray* btSoftBody_getClusterConnectivity(btSoftBody* obj);
btAlignedSoftBodyClusterArray* btSoftBody_getClusters(btSoftBody* obj);
btAlignedConstCollisionObjectArray* btSoftBody_getCollisionDisabledObjects(btSoftBody* obj);
btAlignedSoftBodyFaceArray* btSoftBody_getFaces(btSoftBody* obj);
btDbvt* btSoftBody_getFdbvt(btSoftBody* obj);
void btSoftBody_getInitialWorldTransform(btSoftBody* obj, btScalar* value);
btAlignedSoftBodyJointArray* btSoftBody_getJoints(btSoftBody* obj);
btAlignedSoftBodyLinkArray* btSoftBody_getLinks(btSoftBody* obj);
btScalar btSoftBody_getMass(btSoftBody* obj, int node);
btAlignedSoftBodyMaterialArray* btSoftBody_getMaterials(btSoftBody* obj);
btDbvt* btSoftBody_getNdbvt(btSoftBody* obj);
btAlignedSoftBodyNodeArray* btSoftBody_getNodes(btSoftBody* obj);
btAlignedSoftBodyNoteArray* btSoftBody_getNotes(btSoftBody* obj);
btSoftBody_Pose* btSoftBody_getPose(btSoftBody* obj);
btAlignedSoftBodyRContactArray* btSoftBody_getRcontacts(btSoftBody* obj);
btScalar btSoftBody_getRestLengthScale(btSoftBody* obj);
btAlignedSoftBodySContactArray* btSoftBody_getScontacts(btSoftBody* obj);
btSoftBodySolver* btSoftBody_getSoftBodySolver(btSoftBody* obj);
btSoftBody_psolver_t btSoftBody_getSolver(btSoftBody_ePSolver solver);
btSoftBody_vsolver_t btSoftBody_getSolver2(btSoftBody_eVSolver solver);
btSoftBody_SolverState* btSoftBody_getSst(btSoftBody* obj);
void* btSoftBody_getTag(btSoftBody* obj);
btAlignedSoftBodyTetraArray* btSoftBody_getTetras(btSoftBody* obj);
btScalar btSoftBody_getTimeacc(btSoftBody* obj);
btScalar btSoftBody_getTotalMass(btSoftBody* obj);
btAlignedIntArray* btSoftBody_getUserIndexMapping(btSoftBody* obj);
void btSoftBody_getWindVelocity(btSoftBody* obj, btScalar* velocity);
btScalar btSoftBody_getVolume(btSoftBody* obj);
btSoftBodyWorldInfo* btSoftBody_getWorldInfo(btSoftBody* obj);
void btSoftBody_indicesToPointers(btSoftBody* obj);
void btSoftBody_indicesToPointers2(btSoftBody* obj, const int* map);
void btSoftBody_initDefaults(btSoftBody* obj);
void btSoftBody_initializeClusters(btSoftBody* obj);
void btSoftBody_initializeFaceTree(btSoftBody* obj);
void btSoftBody_integrateMotion(btSoftBody* obj);
void btSoftBody_pointersToIndices(btSoftBody* obj);
void btSoftBody_predictMotion(btSoftBody* obj, btScalar dt);
void btSoftBody_prepareClusters(btSoftBody* obj, int iterations);
void btSoftBody_PSolve_Anchors(btSoftBody* psb, btScalar kst, btScalar ti);
void btSoftBody_PSolve_Links(btSoftBody* psb, btScalar kst, btScalar ti);
void btSoftBody_PSolve_RContacts(btSoftBody* psb, btScalar kst, btScalar ti);
void btSoftBody_PSolve_SContacts(btSoftBody* psb, btScalar __unnamed1, btScalar ti);
void btSoftBody_randomizeConstraints(btSoftBody* obj);
bool btSoftBody_rayTest(btSoftBody* obj, const btScalar* rayFrom, const btScalar* rayTo, btSoftBody_sRayCast* results);
int btSoftBody_rayTest2(btSoftBody* obj, const btScalar* rayFrom, const btScalar* rayTo, btScalar* mint, btSoftBody_eFeature feature, int* index, bool bcountonly);
void btSoftBody_refine(btSoftBody* obj, btSoftBody_ImplicitFn* ifn, btScalar accurary, bool cut);
void btSoftBody_releaseCluster(btSoftBody* obj, int index);
void btSoftBody_releaseClusters(btSoftBody* obj);
void btSoftBody_resetLinkRestLengths(btSoftBody* obj);
void btSoftBody_rotate(btSoftBody* obj, const btScalar* rot);
void btSoftBody_scale(btSoftBody* obj, const btScalar* scl);
void btSoftBody_setBUpdateRtCst(btSoftBody* obj, bool value);
void btSoftBody_setInitialWorldTransform(btSoftBody* obj, const btScalar* value);
void btSoftBody_setMass(btSoftBody* obj, int node, btScalar mass);
void btSoftBody_setNdbvt(btSoftBody* obj, btDbvt* value);
void btSoftBody_setPose(btSoftBody* obj, bool bvolume, bool bframe);
void btSoftBody_setRestLengthScale(btSoftBody* obj, btScalar restLength);
void btSoftBody_setSoftBodySolver(btSoftBody* obj, btSoftBodySolver* softBodySolver);
void btSoftBody_setSolver(btSoftBody* obj, btSoftBody_eSolverPresets preset);
void btSoftBody_setTag(btSoftBody* obj, void* value);
void btSoftBody_setTimeacc(btSoftBody* obj, btScalar value);
void btSoftBody_setTotalDensity(btSoftBody* obj, btScalar density);
void btSoftBody_setTotalMass(btSoftBody* obj, btScalar mass);
void btSoftBody_setTotalMass2(btSoftBody* obj, btScalar mass, bool fromfaces);
void btSoftBody_setVelocity(btSoftBody* obj, const btScalar* velocity);
void btSoftBody_setWindVelocity(btSoftBody* obj, const btScalar* velocity);
void btSoftBody_setVolumeDensity(btSoftBody* obj, btScalar density);
void btSoftBody_setVolumeMass(btSoftBody* obj, btScalar mass);
void btSoftBody_setWorldInfo(btSoftBody* obj, btSoftBodyWorldInfo* value);
void btSoftBody_solveClusters(const btAlignedSoftBodyArray* bodies);
void btSoftBody_solveClusters2(btSoftBody* obj, btScalar sor);
void btSoftBody_solveCommonConstraints(btSoftBody** bodies, int count, int iterations);
void btSoftBody_solveConstraints(btSoftBody* obj);
void btSoftBody_staticSolve(btSoftBody* obj, int iterations);
void btSoftBody_transform(btSoftBody* obj, const btScalar* trs);
void btSoftBody_translate(btSoftBody* obj, const btScalar* trs);
btSoftBody* btSoftBody_upcast(btCollisionObject* colObj);
void btSoftBody_updateArea(btSoftBody* obj);
void btSoftBody_updateArea2(btSoftBody* obj, bool averageArea);
void btSoftBody_updateBounds(btSoftBody* obj);
void btSoftBody_updateClusters(btSoftBody* obj);
void btSoftBody_updateConstants(btSoftBody* obj);
void btSoftBody_updateLinkConstants(btSoftBody* obj);
void btSoftBody_updateNormals(btSoftBody* obj);
void btSoftBody_updatePose(btSoftBody* obj);
void btSoftBody_VSolve_Links(btSoftBody* psb, btScalar kst);
int btSoftBody_getFaceVertexData(btSoftBody* obj, btScalar* vertices);
int btSoftBody_getFaceVertexNormalData(btSoftBody* obj, btScalar* vertices);
int btSoftBody_getFaceVertexNormalData2(btSoftBody* obj, btScalar* vertices, btScalar* normals);
int btSoftBody_getLinkVertexData(btSoftBody* obj, btScalar* vertices);
int btSoftBody_getLinkVertexNormalData(btSoftBody* obj, btScalar* vertices);
int btSoftBody_getTetraVertexData(btSoftBody* obj, btScalar* vertices);
int btSoftBody_getTetraVertexNormalData(btSoftBody* obj, btScalar* vertices);
int btSoftBody_getTetraVertexNormalData2(btSoftBody* obj, btScalar* vertices, btScalar* normals);
btSoftRigidCollisionAlgorithm_CreateFunc* btSoftRigidCollisionAlgorithm_CreateFunc_new();
btSoftRigidCollisionAlgorithm* btSoftRigidCollisionAlgorithm_new(btPersistentManifold* mf, const btCollisionAlgorithmConstructionInfo* ci, const btCollisionObjectWrapper* col0, const btCollisionObjectWrapper* col1Wrap, bool isSwapped);
btSoftRigidDynamicsWorld* btSoftRigidDynamicsWorld_new(btDispatcher* dispatcher, btBroadphaseInterface* pairCache, btConstraintSolver* constraintSolver, btCollisionConfiguration* collisionConfiguration);
btSoftRigidDynamicsWorld* btSoftRigidDynamicsWorld_new2(btDispatcher* dispatcher, btBroadphaseInterface* pairCache, btConstraintSolver* constraintSolver, btCollisionConfiguration* collisionConfiguration, btSoftBodySolver* softBodySolver);
void btSoftRigidDynamicsWorld_addSoftBody(btSoftRigidDynamicsWorld* obj, btSoftBody* body);
void btSoftRigidDynamicsWorld_addSoftBody2(btSoftRigidDynamicsWorld* obj, btSoftBody* body, short collisionFilterGroup);
void btSoftRigidDynamicsWorld_addSoftBody3(btSoftRigidDynamicsWorld* obj, btSoftBody* body, short collisionFilterGroup, short collisionFilterMask);
int btSoftRigidDynamicsWorld_getDrawFlags(btSoftRigidDynamicsWorld* obj);
btSoftBodyArray* btSoftRigidDynamicsWorld_getSoftBodyArray(btSoftRigidDynamicsWorld* obj);
btSoftBodyWorldInfo* btSoftRigidDynamicsWorld_getWorldInfo(btSoftRigidDynamicsWorld* obj);
void btSoftRigidDynamicsWorld_removeSoftBody(btSoftRigidDynamicsWorld* obj, btSoftBody* body);
void btSoftRigidDynamicsWorld_setDrawFlags(btSoftRigidDynamicsWorld* obj, int f);
btSoftSoftCollisionAlgorithm_CreateFunc* btSoftSoftCollisionAlgorithm_CreateFunc_new();
btSoftSoftCollisionAlgorithm* btSoftSoftCollisionAlgorithm_new(const btCollisionAlgorithmConstructionInfo* ci);
btSoftSoftCollisionAlgorithm* btSoftSoftCollisionAlgorithm_new2(btPersistentManifold* mf, const btCollisionAlgorithmConstructionInfo* ci, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap);
btSparseSdf3* btSparseSdf_new();
void btSparseSdf3_GarbageCollect(btSparseSdf3* obj, int lifetime);
void btSparseSdf3_GarbageCollect2(btSparseSdf3* obj);
void btSparseSdf3_Initialize(btSparseSdf3* obj, int hashsize, int clampCells);
void btSparseSdf3_Initialize2(btSparseSdf3* obj, int hashsize);
void btSparseSdf3_Initialize3(btSparseSdf3* obj);
int btSparseSdf3_RemoveReferences(btSparseSdf3* obj, btCollisionShape* pcs);
void btSparseSdf3_Reset(btSparseSdf3* obj);
void btSparseSdf_delete(btSparseSdf3* obj);
btSphereBoxCollisionAlgorithm_CreateFunc* btSphereBoxCollisionAlgorithm_CreateFunc_new();
btSphereBoxCollisionAlgorithm* btSphereBoxCollisionAlgorithm_new(btPersistentManifold* mf, const btCollisionAlgorithmConstructionInfo* ci, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap, bool isSwapped);
bool btSphereBoxCollisionAlgorithm_getSphereDistance(btSphereBoxCollisionAlgorithm* obj, const btCollisionObjectWrapper* boxObjWrap, btScalar* v3PointOnBox, btScalar* normal, btScalar* penetrationDepth, const btScalar* v3SphereCenter, btScalar fRadius, btScalar maxContactDistance);
btScalar btSphereBoxCollisionAlgorithm_getSpherePenetration(btSphereBoxCollisionAlgorithm* obj, const btScalar* boxHalfExtent, const btScalar* sphereRelPos, btScalar* closestPoint, btScalar* normal);
btSphereShape* btSphereShape_new(btScalar radius);
btScalar btSphereShape_getRadius(btSphereShape* obj);
void btSphereShape_setUnscaledRadius(btSphereShape* obj, btScalar radius);
btSphereSphereCollisionAlgorithm_CreateFunc* btSphereSphereCollisionAlgorithm_CreateFunc_new();
btSphereSphereCollisionAlgorithm* btSphereSphereCollisionAlgorithm_new(btPersistentManifold* mf, const btCollisionAlgorithmConstructionInfo* ci, const btCollisionObjectWrapper* col0Wrap, const btCollisionObjectWrapper* col1Wrap);
btSphereSphereCollisionAlgorithm* btSphereSphereCollisionAlgorithm_new2(const btCollisionAlgorithmConstructionInfo* ci);
btSphereTriangleCollisionAlgorithm_CreateFunc* btSphereTriangleCollisionAlgorithm_CreateFunc_new();
btSphereTriangleCollisionAlgorithm* btSphereTriangleCollisionAlgorithm_new(btPersistentManifold* mf, const btCollisionAlgorithmConstructionInfo* ci, const btCollisionObjectWrapper* body0Wrap, const btCollisionObjectWrapper* body1Wrap, bool swapped);
btSphereTriangleCollisionAlgorithm* btSphereTriangleCollisionAlgorithm_new2(const btCollisionAlgorithmConstructionInfo* ci);
btStaticPlaneShape* btStaticPlaneShape_new(const btScalar* planeNormal, btScalar planeConstant);
btScalar btStaticPlaneShape_getPlaneConstant(btStaticPlaneShape* obj);
void btStaticPlaneShape_getPlaneNormal(btStaticPlaneShape* obj, btScalar* value);
void btStridingMeshInterface_calculateAabbBruteForce(btStridingMeshInterface* obj, btScalar* aabbMin, btScalar* aabbMax);
int btStridingMeshInterface_calculateSerializeBufferSize(btStridingMeshInterface* obj);
void btStridingMeshInterface_getLockedReadOnlyVertexIndexBase(btStridingMeshInterface* obj, const unsigned char** vertexbase, int* numverts, PHY_ScalarType* type, int* stride, const unsigned char** indexbase, int* indexstride, int* numfaces, PHY_ScalarType* indicestype);
void btStridingMeshInterface_getLockedReadOnlyVertexIndexBase2(btStridingMeshInterface* obj, const unsigned char** vertexbase, int* numverts, PHY_ScalarType* type, int* stride, const unsigned char** indexbase, int* indexstride, int* numfaces, PHY_ScalarType* indicestype, int subpart);
void btStridingMeshInterface_getLockedVertexIndexBase(btStridingMeshInterface* obj, unsigned char** vertexbase, int* numverts, PHY_ScalarType* type, int* stride, unsigned char** indexbase, int* indexstride, int* numfaces, PHY_ScalarType* indicestype);
void btStridingMeshInterface_getLockedVertexIndexBase2(btStridingMeshInterface* obj, unsigned char** vertexbase, int* numverts, PHY_ScalarType* type, int* stride, unsigned char** indexbase, int* indexstride, int* numfaces, PHY_ScalarType* indicestype, int subpart);
int btStridingMeshInterface_getNumSubParts(btStridingMeshInterface* obj);
void btStridingMeshInterface_getPremadeAabb(btStridingMeshInterface* obj, btScalar* aabbMin, btScalar* aabbMax);
void btStridingMeshInterface_getScaling(btStridingMeshInterface* obj, btScalar* scaling);
bool btStridingMeshInterface_hasPremadeAabb(btStridingMeshInterface* obj);
void btStridingMeshInterface_InternalProcessAllTriangles(btStridingMeshInterface* obj, btInternalTriangleIndexCallback* callback, const btScalar* aabbMin, const btScalar* aabbMax);
void btStridingMeshInterface_preallocateIndices(btStridingMeshInterface* obj, int numindices);
void btStridingMeshInterface_preallocateVertices(btStridingMeshInterface* obj, int numverts);
const char* btStridingMeshInterface_serialize(btStridingMeshInterface* obj, void* dataBuffer, btSerializer* serializer);
void btStridingMeshInterface_setPremadeAabb(btStridingMeshInterface* obj, const btScalar* aabbMin, const btScalar* aabbMax);
void btStridingMeshInterface_setScaling(btStridingMeshInterface* obj, const btScalar* scaling);
void btStridingMeshInterface_unLockReadOnlyVertexBase(btStridingMeshInterface* obj, int subpart);
void btStridingMeshInterface_unLockVertexBase(btStridingMeshInterface* obj, int subpart);
void btStridingMeshInterface_delete(btStridingMeshInterface* obj);
btBU_Simplex1to4* btBU_Simplex1to4_new();
btBU_Simplex1to4* btBU_Simplex1to4_new2(const btScalar* pt0);
btBU_Simplex1to4* btBU_Simplex1to4_new3(const btScalar* pt0, const btScalar* pt1);
btBU_Simplex1to4* btBU_Simplex1to4_new4(const btScalar* pt0, const btScalar* pt1, const btScalar* pt2);
btBU_Simplex1to4* btBU_Simplex1to4_new5(const btScalar* pt0, const btScalar* pt1, const btScalar* pt2, const btScalar* pt3);
void btBU_Simplex1to4_addVertex(btBU_Simplex1to4* obj, const btScalar* pt);
int btBU_Simplex1to4_getIndex(btBU_Simplex1to4* obj, int i);
void btBU_Simplex1to4_reset(btBU_Simplex1to4* obj);
void btTransformUtil_calculateDiffAxisAngle(const btScalar* transform0, const btScalar* transform1, btScalar* axis, btScalar* angle);
void btTransformUtil_calculateDiffAxisAngleQuaternion(const btScalar* orn0, const btScalar* orn1a, btScalar* axis, btScalar* angle);
void btTransformUtil_calculateVelocity(const btScalar* transform0, const btScalar* transform1, btScalar timeStep, btScalar* linVel, btScalar* angVel);
void btTransformUtil_calculateVelocityQuaternion(const btScalar* pos0, const btScalar* pos1, const btScalar* orn0, const btScalar* orn1, btScalar timeStep, btScalar* linVel, btScalar* angVel);
void btTransformUtil_integrateTransform(const btScalar* curTrans, const btScalar* linvel, const btScalar* angvel, btScalar timeStep, btScalar* predictedTransform);
btConvexSeparatingDistanceUtil* btConvexSeparatingDistanceUtil_new(btScalar boundingRadiusA, btScalar boundingRadiusB);
btScalar btConvexSeparatingDistanceUtil_getConservativeSeparatingDistance(btConvexSeparatingDistanceUtil* obj);
void btConvexSeparatingDistanceUtil_initSeparatingDistance(btConvexSeparatingDistanceUtil* obj, const btScalar* separatingVector, btScalar separatingDistance, const btScalar* transA, const btScalar* transB);
void btConvexSeparatingDistanceUtil_updateSeparatingDistance(btConvexSeparatingDistanceUtil* obj, const btScalar* transA, const btScalar* transB);
void btConvexSeparatingDistanceUtil_delete(btConvexSeparatingDistanceUtil* obj);
btTriangle* btTriangle_new();
int btTriangle_getPartId(btTriangle* obj);
int btTriangle_getTriangleIndex(btTriangle* obj);
void btTriangle_getVertex0(btTriangle* obj, btScalar* value);
void btTriangle_getVertex1(btTriangle* obj, btScalar* value);
void btTriangle_getVertex2(btTriangle* obj, btScalar* value);
void btTriangle_setPartId(btTriangle* obj, int value);
void btTriangle_setTriangleIndex(btTriangle* obj, int value);
void btTriangle_setVertex0(btTriangle* obj, const btScalar* value);
void btTriangle_setVertex1(btTriangle* obj, const btScalar* value);
void btTriangle_setVertex2(btTriangle* obj, const btScalar* value);
void btTriangle_delete(btTriangle* obj);
btTriangleBuffer* btTriangleBuffer_new();
void btTriangleBuffer_clearBuffer(btTriangleBuffer* obj);
int btTriangleBuffer_getNumTriangles(btTriangleBuffer* obj);
const btTriangle* btTriangleBuffer_getTriangle(btTriangleBuffer* obj, int index);
btTriangleCallbackWrapper* btTriangleCallbackWrapper_new(pTriangleCallback_ProcessTriangle processTriangleCallback);
void btTriangleCallback_delete(btTriangleCallback* obj);
btInternalTriangleIndexCallbackWrapper* btInternalTriangleIndexCallbackWrapper_new(pInternalTriangleIndexCallback_InternalProcessTriangleIndex internalProcessTriangleIndexCallback);
void btInternalTriangleIndexCallback_delete(btInternalTriangleIndexCallback* obj);
btIndexedMesh* btIndexedMesh_new();
PHY_ScalarType btIndexedMesh_getIndexType(btIndexedMesh* obj);
int btIndexedMesh_getNumTriangles(btIndexedMesh* obj);
int btIndexedMesh_getNumVertices(btIndexedMesh* obj);
const unsigned char* btIndexedMesh_getTriangleIndexBase(btIndexedMesh* obj);
int btIndexedMesh_getTriangleIndexStride(btIndexedMesh* obj);
const unsigned char* btIndexedMesh_getVertexBase(btIndexedMesh* obj);
int btIndexedMesh_getVertexStride(btIndexedMesh* obj);
PHY_ScalarType btIndexedMesh_getVertexType(btIndexedMesh* obj);
void btIndexedMesh_setIndexType(btIndexedMesh* obj, PHY_ScalarType value);
void btIndexedMesh_setNumTriangles(btIndexedMesh* obj, int value);
void btIndexedMesh_setNumVertices(btIndexedMesh* obj, int value);
void btIndexedMesh_setTriangleIndexBase(btIndexedMesh* obj, const unsigned char* value);
void btIndexedMesh_setTriangleIndexStride(btIndexedMesh* obj, int value);
void btIndexedMesh_setVertexBase(btIndexedMesh* obj, const unsigned char* value);
void btIndexedMesh_setVertexStride(btIndexedMesh* obj, int value);
void btIndexedMesh_setVertexType(btIndexedMesh* obj, PHY_ScalarType value);
void btIndexedMesh_delete(btIndexedMesh* obj);
btTriangleIndexVertexArray* btTriangleIndexVertexArray_new();
btTriangleIndexVertexArray* btTriangleIndexVertexArray_new2(int numTriangles, int* triangleIndexBase, int triangleIndexStride, int numVertices, btScalar* vertexBase, int vertexStride);
void btTriangleIndexVertexArray_addIndexedMesh(btTriangleIndexVertexArray* obj, const btIndexedMesh* mesh);
void btTriangleIndexVertexArray_addIndexedMesh2(btTriangleIndexVertexArray* obj, const btIndexedMesh* mesh, PHY_ScalarType indexType);
IndexedMeshArray* btTriangleIndexVertexArray_getIndexedMeshArray(btTriangleIndexVertexArray* obj);
btMaterialProperties* btMaterialProperties_new();
const unsigned char* btMaterialProperties_getMaterialBase(btMaterialProperties* obj);
int btMaterialProperties_getMaterialStride(btMaterialProperties* obj);
PHY_ScalarType btMaterialProperties_getMaterialType(btMaterialProperties* obj);
int btMaterialProperties_getNumMaterials(btMaterialProperties* obj);
int btMaterialProperties_getNumTriangles(btMaterialProperties* obj);
const unsigned char* btMaterialProperties_getTriangleMaterialsBase(btMaterialProperties* obj);
int btMaterialProperties_getTriangleMaterialStride(btMaterialProperties* obj);
PHY_ScalarType btMaterialProperties_getTriangleType(btMaterialProperties* obj);
void btMaterialProperties_setMaterialBase(btMaterialProperties* obj, const unsigned char* value);
void btMaterialProperties_setMaterialStride(btMaterialProperties* obj, int value);
void btMaterialProperties_setMaterialType(btMaterialProperties* obj, PHY_ScalarType value);
void btMaterialProperties_setNumMaterials(btMaterialProperties* obj, int value);
void btMaterialProperties_setNumTriangles(btMaterialProperties* obj, int value);
void btMaterialProperties_setTriangleMaterialsBase(btMaterialProperties* obj, const unsigned char* value);
void btMaterialProperties_setTriangleMaterialStride(btMaterialProperties* obj, int value);
void btMaterialProperties_setTriangleType(btMaterialProperties* obj, PHY_ScalarType value);
void btMaterialProperties_delete(btMaterialProperties* obj);
btTriangleIndexVertexMaterialArray* btTriangleIndexVertexMaterialArray_new();
btTriangleIndexVertexMaterialArray* btTriangleIndexVertexMaterialArray_new2(int numTriangles, int* triangleIndexBase, int triangleIndexStride, int numVertices, btScalar* vertexBase, int vertexStride, int numMaterials, unsigned char* materialBase, int materialStride, int* triangleMaterialsBase, int materialIndexStride);
void btTriangleIndexVertexMaterialArray_addMaterialProperties(btTriangleIndexVertexMaterialArray* obj, const btMaterialProperties* mat);
void btTriangleIndexVertexMaterialArray_addMaterialProperties2(btTriangleIndexVertexMaterialArray* obj, const btMaterialProperties* mat, PHY_ScalarType triangleType);
void btTriangleIndexVertexMaterialArray_getLockedMaterialBase(btTriangleIndexVertexMaterialArray* obj, unsigned char** materialBase, int* numMaterials, PHY_ScalarType* materialType, int* materialStride, unsigned char** triangleMaterialBase, int* numTriangles, int* triangleMaterialStride, PHY_ScalarType* triangleType);
void btTriangleIndexVertexMaterialArray_getLockedMaterialBase2(btTriangleIndexVertexMaterialArray* obj, unsigned char** materialBase, int* numMaterials, PHY_ScalarType* materialType, int* materialStride, unsigned char** triangleMaterialBase, int* numTriangles, int* triangleMaterialStride, PHY_ScalarType* triangleType, int subpart);
void btTriangleIndexVertexMaterialArray_getLockedReadOnlyMaterialBase(btTriangleIndexVertexMaterialArray* obj, const unsigned char** materialBase, int* numMaterials, PHY_ScalarType* materialType, int* materialStride, const unsigned char** triangleMaterialBase, int* numTriangles, int* triangleMaterialStride, PHY_ScalarType* triangleType);
void btTriangleIndexVertexMaterialArray_getLockedReadOnlyMaterialBase2(btTriangleIndexVertexMaterialArray* obj, const unsigned char** materialBase, int* numMaterials, PHY_ScalarType* materialType, int* materialStride, const unsigned char** triangleMaterialBase, int* numTriangles, int* triangleMaterialStride, PHY_ScalarType* triangleType, int subpart);
btTriangleInfo* btTriangleInfo_new();
btScalar btTriangleInfo_getEdgeV0V1Angle(btTriangleInfo* obj);
btScalar btTriangleInfo_getEdgeV1V2Angle(btTriangleInfo* obj);
btScalar btTriangleInfo_getEdgeV2V0Angle(btTriangleInfo* obj);
int btTriangleInfo_getFlags(btTriangleInfo* obj);
void btTriangleInfo_setEdgeV0V1Angle(btTriangleInfo* obj, btScalar value);
void btTriangleInfo_setEdgeV1V2Angle(btTriangleInfo* obj, btScalar value);
void btTriangleInfo_setEdgeV2V0Angle(btTriangleInfo* obj, btScalar value);
void btTriangleInfo_setFlags(btTriangleInfo* obj, int value);
void btTriangleInfo_delete(btTriangleInfo* obj);
btTriangleInfoMap* btTriangleInfoMap_new();
int btTriangleInfoMap_calculateSerializeBufferSize(btTriangleInfoMap* obj);
void btTriangleInfoMap_deSerialize(btTriangleInfoMap* obj, btTriangleInfoMapData* data);
btScalar btTriangleInfoMap_getConvexEpsilon(btTriangleInfoMap* obj);
btScalar btTriangleInfoMap_getEdgeDistanceThreshold(btTriangleInfoMap* obj);
btScalar btTriangleInfoMap_getEqualVertexThreshold(btTriangleInfoMap* obj);
btScalar btTriangleInfoMap_getMaxEdgeAngleThreshold(btTriangleInfoMap* obj);
btScalar btTriangleInfoMap_getPlanarEpsilon(btTriangleInfoMap* obj);
btScalar btTriangleInfoMap_getZeroAreaThreshold(btTriangleInfoMap* obj);
const char* btTriangleInfoMap_serialize(btTriangleInfoMap* obj, void* dataBuffer, btSerializer* serializer);
void btTriangleInfoMap_setConvexEpsilon(btTriangleInfoMap* obj, btScalar value);
void btTriangleInfoMap_setEdgeDistanceThreshold(btTriangleInfoMap* obj, btScalar value);
void btTriangleInfoMap_setEqualVertexThreshold(btTriangleInfoMap* obj, btScalar value);
void btTriangleInfoMap_setMaxEdgeAngleThreshold(btTriangleInfoMap* obj, btScalar value);
void btTriangleInfoMap_setPlanarEpsilon(btTriangleInfoMap* obj, btScalar value);
void btTriangleInfoMap_setZeroAreaThreshold(btTriangleInfoMap* obj, btScalar value);
void btTriangleMeshShape_getLocalAabbMax(btTriangleMeshShape* obj, btScalar* value);
void btTriangleMeshShape_getLocalAabbMin(btTriangleMeshShape* obj, btScalar* value);
btStridingMeshInterface* btTriangleMeshShape_getMeshInterface(btTriangleMeshShape* obj);
void btTriangleMeshShape_localGetSupportingVertex(btTriangleMeshShape* obj, const btScalar* vec, btScalar* value);
void btTriangleMeshShape_localGetSupportingVertexWithoutMargin(btTriangleMeshShape* obj, const btScalar* vec, btScalar* value);
void btTriangleMeshShape_recalcLocalAabb(btTriangleMeshShape* obj);
btTriangleMesh* btTriangleMesh_new();
btTriangleMesh* btTriangleMesh_new2(bool use32bitIndices);
btTriangleMesh* btTriangleMesh_new3(bool use32bitIndices, bool use4componentVertices);
void btTriangleMesh_addIndex(btTriangleMesh* obj, int index);
void btTriangleMesh_addTriangle(btTriangleMesh* obj, const btScalar* vertex0, const btScalar* vertex1, const btScalar* vertex2);
void btTriangleMesh_addTriangle2(btTriangleMesh* obj, const btScalar* vertex0, const btScalar* vertex1, const btScalar* vertex2, bool removeDuplicateVertices);
int btTriangleMesh_findOrAddVertex(btTriangleMesh* obj, const btScalar* vertex, bool removeDuplicateVertices);
int btTriangleMesh_getNumTriangles(btTriangleMesh* obj);
bool btTriangleMesh_getUse32bitIndices(btTriangleMesh* obj);
bool btTriangleMesh_getUse4componentVertices(btTriangleMesh* obj);
btScalar btTriangleMesh_getWeldingThreshold(btTriangleMesh* obj);
void btTriangleMesh_setWeldingThreshold(btTriangleMesh* obj, btScalar value);
btTriangleShape* btTriangleShape_new();
btTriangleShape* btTriangleShape_new2(const btScalar* p0, const btScalar* p1, const btScalar* p2);
void btTriangleShape_calcNormal(btTriangleShape* obj, btScalar* normal);
void btTriangleShape_getPlaneEquation(btTriangleShape* obj, int i, btScalar* planeNormal, btScalar* planeSupport);
const btScalar* btTriangleShape_getVertexPtr(btTriangleShape* obj, int index);
btVector3* btTriangleShape_getVertices1(btTriangleShape* obj);
btJointFeedback* btJointFeedback_new();
void btJointFeedback_getAppliedForceBodyA(btJointFeedback* obj, btScalar* value);
void btJointFeedback_getAppliedForceBodyB(btJointFeedback* obj, btScalar* value);
void btJointFeedback_getAppliedTorqueBodyA(btJointFeedback* obj, btScalar* value);
void btJointFeedback_getAppliedTorqueBodyB(btJointFeedback* obj, btScalar* value);
void btJointFeedback_setAppliedForceBodyA(btJointFeedback* obj, const btScalar* value);
void btJointFeedback_setAppliedForceBodyB(btJointFeedback* obj, const btScalar* value);
void btJointFeedback_setAppliedTorqueBodyA(btJointFeedback* obj, const btScalar* value);
void btJointFeedback_setAppliedTorqueBodyB(btJointFeedback* obj, const btScalar* value);
void btJointFeedback_delete(btJointFeedback* obj);
btTypedConstraint_btConstraintInfo1* btTypedConstraint_btConstraintInfo1_new();
int btTypedConstraint_btConstraintInfo1_getNub(btTypedConstraint_btConstraintInfo1* obj);
int btTypedConstraint_btConstraintInfo1_getNumConstraintRows(btTypedConstraint_btConstraintInfo1* obj);
void btTypedConstraint_btConstraintInfo1_setNub(btTypedConstraint_btConstraintInfo1* obj, int value);
void btTypedConstraint_btConstraintInfo1_setNumConstraintRows(btTypedConstraint_btConstraintInfo1* obj, int value);
void btTypedConstraint_btConstraintInfo1_delete(btTypedConstraint_btConstraintInfo1* obj);
btTypedConstraint_btConstraintInfo2* btTypedConstraint_btConstraintInfo2_new();
btScalar* btTypedConstraint_btConstraintInfo2_getCfm(btTypedConstraint_btConstraintInfo2* obj);
btScalar* btTypedConstraint_btConstraintInfo2_getConstraintError(btTypedConstraint_btConstraintInfo2* obj);
btScalar btTypedConstraint_btConstraintInfo2_getDamping(btTypedConstraint_btConstraintInfo2* obj);
btScalar btTypedConstraint_btConstraintInfo2_getErp(btTypedConstraint_btConstraintInfo2* obj);
int* btTypedConstraint_btConstraintInfo2_getFindex(btTypedConstraint_btConstraintInfo2* obj);
btScalar btTypedConstraint_btConstraintInfo2_getFps(btTypedConstraint_btConstraintInfo2* obj);
btScalar* btTypedConstraint_btConstraintInfo2_getJ1angularAxis(btTypedConstraint_btConstraintInfo2* obj);
btScalar* btTypedConstraint_btConstraintInfo2_getJ1linearAxis(btTypedConstraint_btConstraintInfo2* obj);
btScalar* btTypedConstraint_btConstraintInfo2_getJ2angularAxis(btTypedConstraint_btConstraintInfo2* obj);
btScalar* btTypedConstraint_btConstraintInfo2_getJ2linearAxis(btTypedConstraint_btConstraintInfo2* obj);
btScalar* btTypedConstraint_btConstraintInfo2_getLowerLimit(btTypedConstraint_btConstraintInfo2* obj);
int btTypedConstraint_btConstraintInfo2_getNumIterations(btTypedConstraint_btConstraintInfo2* obj);
int btTypedConstraint_btConstraintInfo2_getRowskip(btTypedConstraint_btConstraintInfo2* obj);
btScalar* btTypedConstraint_btConstraintInfo2_getUpperLimit(btTypedConstraint_btConstraintInfo2* obj);
void btTypedConstraint_btConstraintInfo2_setCfm(btTypedConstraint_btConstraintInfo2* obj, btScalar* value);
void btTypedConstraint_btConstraintInfo2_setConstraintError(btTypedConstraint_btConstraintInfo2* obj, btScalar* value);
void btTypedConstraint_btConstraintInfo2_setDamping(btTypedConstraint_btConstraintInfo2* obj, btScalar value);
void btTypedConstraint_btConstraintInfo2_setErp(btTypedConstraint_btConstraintInfo2* obj, btScalar value);
void btTypedConstraint_btConstraintInfo2_setFindex(btTypedConstraint_btConstraintInfo2* obj, int* value);
void btTypedConstraint_btConstraintInfo2_setFps(btTypedConstraint_btConstraintInfo2* obj, btScalar value);
void btTypedConstraint_btConstraintInfo2_setJ1angularAxis(btTypedConstraint_btConstraintInfo2* obj, btScalar* value);
void btTypedConstraint_btConstraintInfo2_setJ1linearAxis(btTypedConstraint_btConstraintInfo2* obj, btScalar* value);
void btTypedConstraint_btConstraintInfo2_setJ2angularAxis(btTypedConstraint_btConstraintInfo2* obj, btScalar* value);
void btTypedConstraint_btConstraintInfo2_setJ2linearAxis(btTypedConstraint_btConstraintInfo2* obj, btScalar* value);
void btTypedConstraint_btConstraintInfo2_setLowerLimit(btTypedConstraint_btConstraintInfo2* obj, btScalar* value);
void btTypedConstraint_btConstraintInfo2_setNumIterations(btTypedConstraint_btConstraintInfo2* obj, int value);
void btTypedConstraint_btConstraintInfo2_setRowskip(btTypedConstraint_btConstraintInfo2* obj, int value);
void btTypedConstraint_btConstraintInfo2_setUpperLimit(btTypedConstraint_btConstraintInfo2* obj, btScalar* value);
void btTypedConstraint_btConstraintInfo2_delete(btTypedConstraint_btConstraintInfo2* obj);
void btTypedConstraint_buildJacobian(btTypedConstraint* obj);
int btTypedConstraint_calculateSerializeBufferSize(btTypedConstraint* obj);
void btTypedConstraint_enableFeedback(btTypedConstraint* obj, bool needsFeedback);
btScalar btTypedConstraint_getAppliedImpulse(btTypedConstraint* obj);
btScalar btTypedConstraint_getBreakingImpulseThreshold(btTypedConstraint* obj);
btTypedConstraintType btTypedConstraint_getConstraintType(btTypedConstraint* obj);
btScalar btTypedConstraint_getDbgDrawSize(btTypedConstraint* obj);
btRigidBody* btTypedConstraint_getFixedBody();
void btTypedConstraint_getInfo1(btTypedConstraint* obj, btTypedConstraint_btConstraintInfo1* info);
void btTypedConstraint_getInfo2(btTypedConstraint* obj, btTypedConstraint_btConstraintInfo2* info);
btJointFeedback* btTypedConstraint_getJointFeedback(btTypedConstraint* obj);
int btTypedConstraint_getOverrideNumSolverIterations(btTypedConstraint* obj);
btScalar btTypedConstraint_getParam(btTypedConstraint* obj, int num);
btScalar btTypedConstraint_getParam2(btTypedConstraint* obj, int num, int axis);
btRigidBody* btTypedConstraint_getRigidBodyA(btTypedConstraint* obj);
btRigidBody* btTypedConstraint_getRigidBodyB(btTypedConstraint* obj);
int btTypedConstraint_getUid(btTypedConstraint* obj);
int btTypedConstraint_getUserConstraintId(btTypedConstraint* obj);
void* btTypedConstraint_getUserConstraintPtr(btTypedConstraint* obj);
int btTypedConstraint_getUserConstraintType(btTypedConstraint* obj);
btScalar btTypedConstraint_internalGetAppliedImpulse(btTypedConstraint* obj);
void btTypedConstraint_internalSetAppliedImpulse(btTypedConstraint* obj, btScalar appliedImpulse);
bool btTypedConstraint_isEnabled(btTypedConstraint* obj);
bool btTypedConstraint_needsFeedback(btTypedConstraint* obj);
const char* btTypedConstraint_serialize(btTypedConstraint* obj, void* dataBuffer, btSerializer* serializer);
void btTypedConstraint_setBreakingImpulseThreshold(btTypedConstraint* obj, btScalar threshold);
void btTypedConstraint_setDbgDrawSize(btTypedConstraint* obj, btScalar dbgDrawSize);
void btTypedConstraint_setEnabled(btTypedConstraint* obj, bool enabled);
void btTypedConstraint_setJointFeedback(btTypedConstraint* obj, btJointFeedback* jointFeedback);
void btTypedConstraint_setOverrideNumSolverIterations(btTypedConstraint* obj, int overideNumIterations);
void btTypedConstraint_setParam(btTypedConstraint* obj, int num, btScalar value);
void btTypedConstraint_setParam2(btTypedConstraint* obj, int num, btScalar value, int axis);
void btTypedConstraint_setupSolverConstraint(btTypedConstraint* obj, btConstraintArray* ca, int solverBodyA, int solverBodyB, btScalar timeStep);
void btTypedConstraint_setUserConstraintId(btTypedConstraint* obj, int uid);
void btTypedConstraint_setUserConstraintPtr(btTypedConstraint* obj, void* ptr);
void btTypedConstraint_setUserConstraintType(btTypedConstraint* obj, int userConstraintType);
void btTypedConstraint_solveConstraintObsolete(btTypedConstraint* obj, btSolverBody* __unnamed0, btSolverBody* __unnamed1, btScalar __unnamed2);
void btTypedConstraint_delete(btTypedConstraint* obj);
btAngularLimit* btAngularLimit_new();
void btAngularLimit_fit(btAngularLimit* obj, btScalar* angle);
btScalar btAngularLimit_getBiasFactor(btAngularLimit* obj);
btScalar btAngularLimit_getCorrection(btAngularLimit* obj);
btScalar btAngularLimit_getError(btAngularLimit* obj);
btScalar btAngularLimit_getHalfRange(btAngularLimit* obj);
btScalar btAngularLimit_getHigh(btAngularLimit* obj);
btScalar btAngularLimit_getLow(btAngularLimit* obj);
btScalar btAngularLimit_getRelaxationFactor(btAngularLimit* obj);
btScalar btAngularLimit_getSign(btAngularLimit* obj);
btScalar btAngularLimit_getSoftness(btAngularLimit* obj);
bool btAngularLimit_isLimit(btAngularLimit* obj);
void btAngularLimit_set(btAngularLimit* obj, btScalar low, btScalar high);
void btAngularLimit_set2(btAngularLimit* obj, btScalar low, btScalar high, btScalar _softness);
void btAngularLimit_set3(btAngularLimit* obj, btScalar low, btScalar high, btScalar _softness, btScalar _biasFactor);
void btAngularLimit_set4(btAngularLimit* obj, btScalar low, btScalar high, btScalar _softness, btScalar _biasFactor, btScalar _relaxationFactor);
void btAngularLimit_test(btAngularLimit* obj, btScalar angle);
void btAngularLimit_delete(btAngularLimit* obj);
btUniformScalingShape* btUniformScalingShape_new(btConvexShape* convexChildShape, btScalar uniformScalingFactor);
btConvexShape* btUniformScalingShape_getChildShape(btUniformScalingShape* obj);
btScalar btUniformScalingShape_getUniformScalingFactor(btUniformScalingShape* obj);
btElement* btElement_new();
int btElement_getId(btElement* obj);
int btElement_getSz(btElement* obj);
void btElement_setId(btElement* obj, int value);
void btElement_setSz(btElement* obj, int value);
void btElement_delete(btElement* obj);
btUnionFind* btUnionFind_new();
void btUnionFind_allocate(btUnionFind* obj, int N);
int btUnionFind_find(btUnionFind* obj, int p, int q);
int btUnionFind_find2(btUnionFind* obj, int x);
void btUnionFind_Free(btUnionFind* obj);
btElement* btUnionFind_getElement(btUnionFind* obj, int index);
int btUnionFind_getNumElements(btUnionFind* obj);
bool btUnionFind_isRoot(btUnionFind* obj, int x);
void btUnionFind_reset(btUnionFind* obj, int N);
void btUnionFind_sortIslands(btUnionFind* obj);
void btUnionFind_unite(btUnionFind* obj, int p, int q);
void btUnionFind_delete(btUnionFind* obj);
btUniversalConstraint* btUniversalConstraint_new(btRigidBody* rbA, btRigidBody* rbB, const btScalar* anchor, const btScalar* axis1, const btScalar* axis2);
void btUniversalConstraint_getAnchor(btUniversalConstraint* obj, btScalar* value);
void btUniversalConstraint_getAnchor2(btUniversalConstraint* obj, btScalar* value);
btScalar btUniversalConstraint_getAngle1(btUniversalConstraint* obj);
btScalar btUniversalConstraint_getAngle2(btUniversalConstraint* obj);
void btUniversalConstraint_getAxis1(btUniversalConstraint* obj, btScalar* value);
void btUniversalConstraint_getAxis2(btUniversalConstraint* obj, btScalar* value);
void btUniversalConstraint_setLowerLimit(btUniversalConstraint* obj, btScalar ang1min, btScalar ang2min);
void btUniversalConstraint_setUpperLimit(btUniversalConstraint* obj, btScalar ang1max, btScalar ang2max);
btVehicleRaycaster_btVehicleRaycasterResult* btVehicleRaycaster_btVehicleRaycasterResult_new();
btScalar btVehicleRaycaster_btVehicleRaycasterResult_getDistFraction(btVehicleRaycaster_btVehicleRaycasterResult* obj);
void btVehicleRaycaster_btVehicleRaycasterResult_getHitNormalInWorld(btVehicleRaycaster_btVehicleRaycasterResult* obj, btScalar* value);
void btVehicleRaycaster_btVehicleRaycasterResult_getHitPointInWorld(btVehicleRaycaster_btVehicleRaycasterResult* obj, btScalar* value);
void btVehicleRaycaster_btVehicleRaycasterResult_setDistFraction(btVehicleRaycaster_btVehicleRaycasterResult* obj, btScalar value);
void btVehicleRaycaster_btVehicleRaycasterResult_setHitNormalInWorld(btVehicleRaycaster_btVehicleRaycasterResult* obj, const btScalar* value);
void btVehicleRaycaster_btVehicleRaycasterResult_setHitPointInWorld(btVehicleRaycaster_btVehicleRaycasterResult* obj, const btScalar* value);
void btVehicleRaycaster_btVehicleRaycasterResult_delete(btVehicleRaycaster_btVehicleRaycasterResult* obj);
void* btVehicleRaycaster_castRay(btVehicleRaycaster* obj, const btScalar* from, const btScalar* to, btVehicleRaycaster_btVehicleRaycasterResult* result);
void btVehicleRaycaster_delete(btVehicleRaycaster* obj);
btUsageBitfield* btUsageBitfield_new();
bool btUsageBitfield_getUnused1(btUsageBitfield* obj);
bool btUsageBitfield_getUnused2(btUsageBitfield* obj);
bool btUsageBitfield_getUnused3(btUsageBitfield* obj);
bool btUsageBitfield_getUnused4(btUsageBitfield* obj);
bool btUsageBitfield_getUsedVertexA(btUsageBitfield* obj);
bool btUsageBitfield_getUsedVertexB(btUsageBitfield* obj);
bool btUsageBitfield_getUsedVertexC(btUsageBitfield* obj);
bool btUsageBitfield_getUsedVertexD(btUsageBitfield* obj);
void btUsageBitfield_reset(btUsageBitfield* obj);
void btUsageBitfield_setUnused1(btUsageBitfield* obj, bool value);
void btUsageBitfield_setUnused2(btUsageBitfield* obj, bool value);
void btUsageBitfield_setUnused3(btUsageBitfield* obj, bool value);
void btUsageBitfield_setUnused4(btUsageBitfield* obj, bool value);
void btUsageBitfield_setUsedVertexA(btUsageBitfield* obj, bool value);
void btUsageBitfield_setUsedVertexB(btUsageBitfield* obj, bool value);
void btUsageBitfield_setUsedVertexC(btUsageBitfield* obj, bool value);
void btUsageBitfield_setUsedVertexD(btUsageBitfield* obj, bool value);
void btUsageBitfield_delete(btUsageBitfield* obj);
btSubSimplexClosestResult* btSubSimplexClosestResult_new();
btScalar* btSubSimplexClosestResult_getBarycentricCoords(btSubSimplexClosestResult* obj);
void btSubSimplexClosestResult_getClosestPointOnSimplex(btSubSimplexClosestResult* obj, btScalar* value);
bool btSubSimplexClosestResult_getDegenerate(btSubSimplexClosestResult* obj);
btUsageBitfield* btSubSimplexClosestResult_getUsedVertices(btSubSimplexClosestResult* obj);
bool btSubSimplexClosestResult_isValid(btSubSimplexClosestResult* obj);
void btSubSimplexClosestResult_reset(btSubSimplexClosestResult* obj);
void btSubSimplexClosestResult_setBarycentricCoordinates(btSubSimplexClosestResult* obj);
void btSubSimplexClosestResult_setBarycentricCoordinates2(btSubSimplexClosestResult* obj, btScalar a);
void btSubSimplexClosestResult_setBarycentricCoordinates3(btSubSimplexClosestResult* obj, btScalar a, btScalar b);
void btSubSimplexClosestResult_setBarycentricCoordinates4(btSubSimplexClosestResult* obj, btScalar a, btScalar b, btScalar c);
void btSubSimplexClosestResult_setBarycentricCoordinates5(btSubSimplexClosestResult* obj, btScalar a, btScalar b, btScalar c, btScalar d);
void btSubSimplexClosestResult_setClosestPointOnSimplex(btSubSimplexClosestResult* obj, const btScalar* value);
void btSubSimplexClosestResult_setDegenerate(btSubSimplexClosestResult* obj, bool value);
void btSubSimplexClosestResult_setUsedVertices(btSubSimplexClosestResult* obj, btUsageBitfield* value);
void btSubSimplexClosestResult_delete(btSubSimplexClosestResult* obj);
btVoronoiSimplexSolver* btVoronoiSimplexSolver_new();
void btVoronoiSimplexSolver_addVertex(btVoronoiSimplexSolver* obj, const btScalar* w, const btScalar* p, const btScalar* q);
void btVoronoiSimplexSolver_backup_closest(btVoronoiSimplexSolver* obj, btScalar* v);
bool btVoronoiSimplexSolver_closest(btVoronoiSimplexSolver* obj, btScalar* v);
bool btVoronoiSimplexSolver_closestPtPointTetrahedron(btVoronoiSimplexSolver* obj, const btScalar* p, const btScalar* a, const btScalar* b, const btScalar* c, const btScalar* d, btSubSimplexClosestResult* finalResult);
bool btVoronoiSimplexSolver_closestPtPointTriangle(btVoronoiSimplexSolver* obj, const btScalar* p, const btScalar* a, const btScalar* b, const btScalar* c, btSubSimplexClosestResult* result);
void btVoronoiSimplexSolver_compute_points(btVoronoiSimplexSolver* obj, btScalar* p1, btScalar* p2);
bool btVoronoiSimplexSolver_emptySimplex(btVoronoiSimplexSolver* obj);
bool btVoronoiSimplexSolver_fullSimplex(btVoronoiSimplexSolver* obj);
btSubSimplexClosestResult* btVoronoiSimplexSolver_getCachedBC(btVoronoiSimplexSolver* obj);
void btVoronoiSimplexSolver_getCachedP1(btVoronoiSimplexSolver* obj, btScalar* value);
void btVoronoiSimplexSolver_getCachedP2(btVoronoiSimplexSolver* obj, btScalar* value);
void btVoronoiSimplexSolver_getCachedV(btVoronoiSimplexSolver* obj, btScalar* value);
bool btVoronoiSimplexSolver_getCachedValidClosest(btVoronoiSimplexSolver* obj);
btScalar btVoronoiSimplexSolver_getEqualVertexThreshold(btVoronoiSimplexSolver* obj);
void btVoronoiSimplexSolver_getLastW(btVoronoiSimplexSolver* obj, btScalar* value);
bool btVoronoiSimplexSolver_getNeedsUpdate(btVoronoiSimplexSolver* obj);
int btVoronoiSimplexSolver_getNumVertices(btVoronoiSimplexSolver* obj);
int btVoronoiSimplexSolver_getSimplex(btVoronoiSimplexSolver* obj, btScalar* pBuf, btScalar* qBuf, btScalar* yBuf);
btVector3* btVoronoiSimplexSolver_getSimplexPointsP(btVoronoiSimplexSolver* obj);
btVector3* btVoronoiSimplexSolver_getSimplexPointsQ(btVoronoiSimplexSolver* obj);
btVector3* btVoronoiSimplexSolver_getSimplexVectorW(btVoronoiSimplexSolver* obj);
bool btVoronoiSimplexSolver_inSimplex(btVoronoiSimplexSolver* obj, const btScalar* w);
btScalar btVoronoiSimplexSolver_maxVertex(btVoronoiSimplexSolver* obj);
int btVoronoiSimplexSolver_numVertices(btVoronoiSimplexSolver* obj);
int btVoronoiSimplexSolver_pointOutsideOfPlane(btVoronoiSimplexSolver* obj, const btScalar* p, const btScalar* a, const btScalar* b, const btScalar* c, const btScalar* d);
void btVoronoiSimplexSolver_reduceVertices(btVoronoiSimplexSolver* obj, const btUsageBitfield* usedVerts);
void btVoronoiSimplexSolver_removeVertex(btVoronoiSimplexSolver* obj, int index);
void btVoronoiSimplexSolver_reset(btVoronoiSimplexSolver* obj);
void btVoronoiSimplexSolver_setCachedBC(btVoronoiSimplexSolver* obj, btSubSimplexClosestResult* value);
void btVoronoiSimplexSolver_setCachedP1(btVoronoiSimplexSolver* obj, const btScalar* value);
void btVoronoiSimplexSolver_setCachedP2(btVoronoiSimplexSolver* obj, const btScalar* value);
void btVoronoiSimplexSolver_setCachedV(btVoronoiSimplexSolver* obj, const btScalar* value);
void btVoronoiSimplexSolver_setCachedValidClosest(btVoronoiSimplexSolver* obj, bool value);
void btVoronoiSimplexSolver_setEqualVertexThreshold(btVoronoiSimplexSolver* obj, btScalar threshold);
void btVoronoiSimplexSolver_setLastW(btVoronoiSimplexSolver* obj, const btScalar* value);
void btVoronoiSimplexSolver_setNeedsUpdate(btVoronoiSimplexSolver* obj, bool value);
void btVoronoiSimplexSolver_setNumVertices(btVoronoiSimplexSolver* obj, int value);
bool btVoronoiSimplexSolver_updateClosestVectorAndPoints(btVoronoiSimplexSolver* obj);
void btVoronoiSimplexSolver_delete(btVoronoiSimplexSolver* obj);
btWheelInfoConstructionInfo* btWheelInfoConstructionInfo_new();
bool btWheelInfoConstructionInfo_getBIsFrontWheel(btWheelInfoConstructionInfo* obj);
void btWheelInfoConstructionInfo_getChassisConnectionCS(btWheelInfoConstructionInfo* obj, btScalar* value);
btScalar btWheelInfoConstructionInfo_getFrictionSlip(btWheelInfoConstructionInfo* obj);
btScalar btWheelInfoConstructionInfo_getMaxSuspensionForce(btWheelInfoConstructionInfo* obj);
btScalar btWheelInfoConstructionInfo_getMaxSuspensionTravelCm(btWheelInfoConstructionInfo* obj);
btScalar btWheelInfoConstructionInfo_getSuspensionRestLength(btWheelInfoConstructionInfo* obj);
btScalar btWheelInfoConstructionInfo_getSuspensionStiffness(btWheelInfoConstructionInfo* obj);
void btWheelInfoConstructionInfo_getWheelAxleCS(btWheelInfoConstructionInfo* obj, btScalar* value);
void btWheelInfoConstructionInfo_getWheelDirectionCS(btWheelInfoConstructionInfo* obj, btScalar* value);
btScalar btWheelInfoConstructionInfo_getWheelRadius(btWheelInfoConstructionInfo* obj);
btScalar btWheelInfoConstructionInfo_getWheelsDampingCompression(btWheelInfoConstructionInfo* obj);
btScalar btWheelInfoConstructionInfo_getWheelsDampingRelaxation(btWheelInfoConstructionInfo* obj);
void btWheelInfoConstructionInfo_setBIsFrontWheel(btWheelInfoConstructionInfo* obj, bool value);
void btWheelInfoConstructionInfo_setChassisConnectionCS(btWheelInfoConstructionInfo* obj, const btScalar* value);
void btWheelInfoConstructionInfo_setFrictionSlip(btWheelInfoConstructionInfo* obj, btScalar value);
void btWheelInfoConstructionInfo_setMaxSuspensionForce(btWheelInfoConstructionInfo* obj, btScalar value);
void btWheelInfoConstructionInfo_setMaxSuspensionTravelCm(btWheelInfoConstructionInfo* obj, btScalar value);
void btWheelInfoConstructionInfo_setSuspensionRestLength(btWheelInfoConstructionInfo* obj, btScalar value);
void btWheelInfoConstructionInfo_setSuspensionStiffness(btWheelInfoConstructionInfo* obj, btScalar value);
void btWheelInfoConstructionInfo_setWheelAxleCS(btWheelInfoConstructionInfo* obj, const btScalar* value);
void btWheelInfoConstructionInfo_setWheelDirectionCS(btWheelInfoConstructionInfo* obj, const btScalar* value);
void btWheelInfoConstructionInfo_setWheelRadius(btWheelInfoConstructionInfo* obj, btScalar value);
void btWheelInfoConstructionInfo_setWheelsDampingCompression(btWheelInfoConstructionInfo* obj, btScalar value);
void btWheelInfoConstructionInfo_setWheelsDampingRelaxation(btWheelInfoConstructionInfo* obj, btScalar value);
void btWheelInfoConstructionInfo_delete(btWheelInfoConstructionInfo* obj);
btWheelInfo_RaycastInfo* btWheelInfo_RaycastInfo_new();
void btWheelInfo_RaycastInfo_getContactNormalWS(btWheelInfo_RaycastInfo* obj, btScalar* value);
void btWheelInfo_RaycastInfo_getContactPointWS(btWheelInfo_RaycastInfo* obj, btScalar* value);
void* btWheelInfo_RaycastInfo_getGroundObject(btWheelInfo_RaycastInfo* obj);
void btWheelInfo_RaycastInfo_getHardPointWS(btWheelInfo_RaycastInfo* obj, btScalar* value);
bool btWheelInfo_RaycastInfo_getIsInContact(btWheelInfo_RaycastInfo* obj);
btScalar btWheelInfo_RaycastInfo_getSuspensionLength(btWheelInfo_RaycastInfo* obj);
void btWheelInfo_RaycastInfo_getWheelAxleWS(btWheelInfo_RaycastInfo* obj, btScalar* value);
void btWheelInfo_RaycastInfo_getWheelDirectionWS(btWheelInfo_RaycastInfo* obj, btScalar* value);
void btWheelInfo_RaycastInfo_setContactNormalWS(btWheelInfo_RaycastInfo* obj, const btScalar* value);
void btWheelInfo_RaycastInfo_setContactPointWS(btWheelInfo_RaycastInfo* obj, const btScalar* value);
void btWheelInfo_RaycastInfo_setGroundObject(btWheelInfo_RaycastInfo* obj, void* value);
void btWheelInfo_RaycastInfo_setHardPointWS(btWheelInfo_RaycastInfo* obj, const btScalar* value);
void btWheelInfo_RaycastInfo_setIsInContact(btWheelInfo_RaycastInfo* obj, bool value);
void btWheelInfo_RaycastInfo_setSuspensionLength(btWheelInfo_RaycastInfo* obj, btScalar value);
void btWheelInfo_RaycastInfo_setWheelAxleWS(btWheelInfo_RaycastInfo* obj, const btScalar* value);
void btWheelInfo_RaycastInfo_setWheelDirectionWS(btWheelInfo_RaycastInfo* obj, const btScalar* value);
void btWheelInfo_RaycastInfo_delete(btWheelInfo_RaycastInfo* obj);
btWheelInfo* btWheelInfo_new(btWheelInfoConstructionInfo* ci);
bool btWheelInfo_getBIsFrontWheel(btWheelInfo* obj);
btScalar btWheelInfo_getBrake(btWheelInfo* obj);
void btWheelInfo_getChassisConnectionPointCS(btWheelInfo* obj, btScalar* value);
void* btWheelInfo_getClientInfo(btWheelInfo* obj);
btScalar btWheelInfo_getClippedInvContactDotSuspension(btWheelInfo* obj);
btScalar btWheelInfo_getDeltaRotation(btWheelInfo* obj);
btScalar btWheelInfo_getEngineForce(btWheelInfo* obj);
btScalar btWheelInfo_getFrictionSlip(btWheelInfo* obj);
btScalar btWheelInfo_getMaxSuspensionForce(btWheelInfo* obj);
btScalar btWheelInfo_getMaxSuspensionTravelCm(btWheelInfo* obj);
btWheelInfo_RaycastInfo* btWheelInfo_getRaycastInfo(btWheelInfo* obj);
btScalar btWheelInfo_getRollInfluence(btWheelInfo* obj);
btScalar btWheelInfo_getRotation(btWheelInfo* obj);
btScalar btWheelInfo_getSkidInfo(btWheelInfo* obj);
btScalar btWheelInfo_getSteering(btWheelInfo* obj);
btScalar btWheelInfo_getSuspensionRelativeVelocity(btWheelInfo* obj);
btScalar btWheelInfo_getSuspensionRestLength(btWheelInfo* obj);
btScalar btWheelInfo_getSuspensionRestLength1(btWheelInfo* obj);
btScalar btWheelInfo_getSuspensionStiffness(btWheelInfo* obj);
void btWheelInfo_getWheelAxleCS(btWheelInfo* obj, btScalar* value);
void btWheelInfo_getWheelDirectionCS(btWheelInfo* obj, btScalar* value);
btScalar btWheelInfo_getWheelsDampingCompression(btWheelInfo* obj);
btScalar btWheelInfo_getWheelsDampingRelaxation(btWheelInfo* obj);
btScalar btWheelInfo_getWheelsRadius(btWheelInfo* obj);
btScalar btWheelInfo_getWheelsSuspensionForce(btWheelInfo* obj);
void btWheelInfo_getWorldTransform(btWheelInfo* obj, btScalar* value);
void btWheelInfo_setBIsFrontWheel(btWheelInfo* obj, bool value);
void btWheelInfo_setBrake(btWheelInfo* obj, btScalar value);
void btWheelInfo_setChassisConnectionPointCS(btWheelInfo* obj, const btScalar* value);
void btWheelInfo_setClientInfo(btWheelInfo* obj, void* value);
void btWheelInfo_setClippedInvContactDotSuspension(btWheelInfo* obj, btScalar value);
void btWheelInfo_setDeltaRotation(btWheelInfo* obj, btScalar value);
void btWheelInfo_setEngineForce(btWheelInfo* obj, btScalar value);
void btWheelInfo_setFrictionSlip(btWheelInfo* obj, btScalar value);
void btWheelInfo_setMaxSuspensionForce(btWheelInfo* obj, btScalar value);
void btWheelInfo_setMaxSuspensionTravelCm(btWheelInfo* obj, btScalar value);
void btWheelInfo_setRollInfluence(btWheelInfo* obj, btScalar value);
void btWheelInfo_setRotation(btWheelInfo* obj, btScalar value);
void btWheelInfo_setSkidInfo(btWheelInfo* obj, btScalar value);
void btWheelInfo_setSteering(btWheelInfo* obj, btScalar value);
void btWheelInfo_setSuspensionRelativeVelocity(btWheelInfo* obj, btScalar value);
void btWheelInfo_setSuspensionRestLength1(btWheelInfo* obj, btScalar value);
void btWheelInfo_setSuspensionStiffness(btWheelInfo* obj, btScalar value);
void btWheelInfo_setWheelAxleCS(btWheelInfo* obj, const btScalar* value);
void btWheelInfo_setWheelDirectionCS(btWheelInfo* obj, const btScalar* value);
void btWheelInfo_setWheelsDampingCompression(btWheelInfo* obj, btScalar value);
void btWheelInfo_setWheelsDampingRelaxation(btWheelInfo* obj, btScalar value);
void btWheelInfo_setWheelsRadius(btWheelInfo* obj, btScalar value);
void btWheelInfo_setWheelsSuspensionForce(btWheelInfo* obj, btScalar value);
void btWheelInfo_setWorldTransform(btWheelInfo* obj, const btScalar* value);
void btWheelInfo_updateWheel(btWheelInfo* obj, const btRigidBody* chassis, btWheelInfo_RaycastInfo* raycastInfo);
void btWheelInfo_delete(btWheelInfo* obj);
btWorldImporter* btWorldImporter_new(btDynamicsWorld* world);
btCollisionShape* btWorldImporter_createBoxShape(btWorldImporter* obj, const btScalar* halfExtents);
btBvhTriangleMeshShape* btWorldImporter_createBvhTriangleMeshShape(btWorldImporter* obj, btStridingMeshInterface* trimesh, btOptimizedBvh* bvh);
btCollisionShape* btWorldImporter_createCapsuleShapeZ(btWorldImporter* obj, btScalar radius, btScalar height);
btCollisionShape* btWorldImporter_createCapsuleShapeX(btWorldImporter* obj, btScalar radius, btScalar height);
btCollisionShape* btWorldImporter_createCapsuleShapeY(btWorldImporter* obj, btScalar radius, btScalar height);
btCollisionObject* btWorldImporter_createCollisionObject(btWorldImporter* obj, const btScalar* startTransform, btCollisionShape* shape, const char* bodyName);
btCompoundShape* btWorldImporter_createCompoundShape(btWorldImporter* obj);
btCollisionShape* btWorldImporter_createConeShapeZ(btWorldImporter* obj, btScalar radius, btScalar height);
btCollisionShape* btWorldImporter_createConeShapeX(btWorldImporter* obj, btScalar radius, btScalar height);
btCollisionShape* btWorldImporter_createConeShapeY(btWorldImporter* obj, btScalar radius, btScalar height);
btConeTwistConstraint* btWorldImporter_createConeTwistConstraint(btWorldImporter* obj, btRigidBody* rbA, btRigidBody* rbB, const btScalar* rbAFrame, const btScalar* rbBFrame);
btConeTwistConstraint* btWorldImporter_createConeTwistConstraint2(btWorldImporter* obj, btRigidBody* rbA, const btScalar* rbAFrame);
btConvexHullShape* btWorldImporter_createConvexHullShape(btWorldImporter* obj);
btCollisionShape* btWorldImporter_createConvexTriangleMeshShape(btWorldImporter* obj, btStridingMeshInterface* trimesh);
btCollisionShape* btWorldImporter_createCylinderShapeZ(btWorldImporter* obj, btScalar radius, btScalar height);
btCollisionShape* btWorldImporter_createCylinderShapeX(btWorldImporter* obj, btScalar radius, btScalar height);
btCollisionShape* btWorldImporter_createCylinderShapeY(btWorldImporter* obj, btScalar radius, btScalar height);
btGearConstraint* btWorldImporter_createGearConstraint(btWorldImporter* obj, btRigidBody* rbA, btRigidBody* rbB, const btScalar* axisInA, const btScalar* axisInB, btScalar ratio);
btGeneric6DofConstraint* btWorldImporter_createGeneric6DofConstraint(btWorldImporter* obj, btRigidBody* rbA, btRigidBody* rbB, const btScalar* frameInA, const btScalar* frameInB, bool useLinearReferenceFrameA);
btGeneric6DofConstraint* btWorldImporter_createGeneric6DofConstraint2(btWorldImporter* obj, btRigidBody* rbB, const btScalar* frameInB, bool useLinearReferenceFrameB);
btGeneric6DofSpringConstraint* btWorldImporter_createGeneric6DofSpringConstraint(btWorldImporter* obj, btRigidBody* rbA, btRigidBody* rbB, const btScalar* frameInA, const btScalar* frameInB, bool useLinearReferenceFrameA);
btGeneric6DofSpring2Constraint* btWorldImporter_createGeneric6DofSpring2Constraint(btWorldImporter* obj, btRigidBody* rbA, btRigidBody* rbB, const btScalar* frameInA, const btScalar* frameInB, int rotateOrder);
btGImpactMeshShape* btWorldImporter_createGimpactShape(btWorldImporter* obj, btStridingMeshInterface* trimesh);
btHingeConstraint* btWorldImporter_createHingeConstraint(btWorldImporter* obj, btRigidBody* rbA, btRigidBody* rbB, const btScalar* rbAFrame, const btScalar* rbBFrame);
btHingeConstraint* btWorldImporter_createHingeConstraint2(btWorldImporter* obj, btRigidBody* rbA, btRigidBody* rbB, const btScalar* rbAFrame, const btScalar* rbBFrame, bool useReferenceFrameA);
btHingeConstraint* btWorldImporter_createHingeConstraint3(btWorldImporter* obj, btRigidBody* rbA, const btScalar* rbAFrame);
btHingeConstraint* btWorldImporter_createHingeConstraint4(btWorldImporter* obj, btRigidBody* rbA, const btScalar* rbAFrame, bool useReferenceFrameA);
btTriangleIndexVertexArray* btWorldImporter_createMeshInterface(btWorldImporter* obj, btStridingMeshInterfaceData* meshData);
btMultiSphereShape* btWorldImporter_createMultiSphereShape(btWorldImporter* obj, const btScalar* positions, const btScalar* radi, int numSpheres);
btOptimizedBvh* btWorldImporter_createOptimizedBvh(btWorldImporter* obj);
btCollisionShape* btWorldImporter_createPlaneShape(btWorldImporter* obj, const btScalar* planeNormal, btScalar planeConstant);
btPoint2PointConstraint* btWorldImporter_createPoint2PointConstraint(btWorldImporter* obj, btRigidBody* rbA, const btScalar* pivotInA);
btPoint2PointConstraint* btWorldImporter_createPoint2PointConstraint2(btWorldImporter* obj, btRigidBody* rbA, btRigidBody* rbB, const btScalar* pivotInA, const btScalar* pivotInB);
btRigidBody* btWorldImporter_createRigidBody(btWorldImporter* obj, bool isDynamic, btScalar mass, const btScalar* startTransform, btCollisionShape* shape, const char* bodyName);
btScaledBvhTriangleMeshShape* btWorldImporter_createScaledTrangleMeshShape(btWorldImporter* obj, btBvhTriangleMeshShape* meshShape, const btScalar* localScalingbtBvhTriangleMeshShape);
btSliderConstraint* btWorldImporter_createSliderConstraint(btWorldImporter* obj, btRigidBody* rbA, btRigidBody* rbB, const btScalar* frameInA, const btScalar* frameInB, bool useLinearReferenceFrameA);
btSliderConstraint* btWorldImporter_createSliderConstraint2(btWorldImporter* obj, btRigidBody* rbB, const btScalar* frameInB, bool useLinearReferenceFrameA);
btCollisionShape* btWorldImporter_createSphereShape(btWorldImporter* obj, btScalar radius);
btStridingMeshInterfaceData* btWorldImporter_createStridingMeshInterfaceData(btWorldImporter* obj, btStridingMeshInterfaceData* interfaceData);
btTriangleInfoMap* btWorldImporter_createTriangleInfoMap(btWorldImporter* obj);
btTriangleIndexVertexArray* btWorldImporter_createTriangleMeshContainer(btWorldImporter* obj);
void btWorldImporter_deleteAllData(btWorldImporter* obj);
btOptimizedBvh* btWorldImporter_getBvhByIndex(btWorldImporter* obj, int index);
btCollisionShape* btWorldImporter_getCollisionShapeByIndex(btWorldImporter* obj, int index);
btCollisionShape* btWorldImporter_getCollisionShapeByName(btWorldImporter* obj, const char* name);
btTypedConstraint* btWorldImporter_getConstraintByIndex(btWorldImporter* obj, int index);
btTypedConstraint* btWorldImporter_getConstraintByName(btWorldImporter* obj, const char* name);
const char* btWorldImporter_getNameForPointer(btWorldImporter* obj, const void* ptr);
int btWorldImporter_getNumBvhs(btWorldImporter* obj);
int btWorldImporter_getNumCollisionShapes(btWorldImporter* obj);
int btWorldImporter_getNumConstraints(btWorldImporter* obj);
int btWorldImporter_getNumRigidBodies(btWorldImporter* obj);
int btWorldImporter_getNumTriangleInfoMaps(btWorldImporter* obj);
btCollisionObject* btWorldImporter_getRigidBodyByIndex(btWorldImporter* obj, int index);
btRigidBody* btWorldImporter_getRigidBodyByName(btWorldImporter* obj, const char* name);
btTriangleInfoMap* btWorldImporter_getTriangleInfoMapByIndex(btWorldImporter* obj, int index);
int btWorldImporter_getVerboseMode(btWorldImporter* obj);
void btWorldImporter_setDynamicsWorldInfo(btWorldImporter* obj, const btScalar* gravity, const btContactSolverInfo* solverInfo);
void btWorldImporter_setVerboseMode(btWorldImporter* obj, int verboseMode);
void btWorldImporter_delete(btWorldImporter* obj);
btCompoundShapeChild* btCompoundShapeChild_array_at(btCompoundShapeChild* a, int n);
btSoftBody_Node* btSoftBodyNodePtrArray_at(btSoftBodyNodePtrArray* obj, int n);
void btSoftBodyNodePtrArray_set(btSoftBodyNodePtrArray* obj, btSoftBody_Node* value, int index);
void btVector3_array_at(const btVector3* a, int n, btScalar* value);
void btVector3_array_set(btVector3* obj, int n, const btScalar* value);
btAlignedVector3Array* btAlignedVector3Array_new();
void btAlignedVector3Array_at(btAlignedVector3Array* obj, int n, btScalar* value);
void btAlignedVector3Array_push_back(btAlignedVector3Array* obj, const btScalar* value);
void btAlignedVector3Array_push_back2(btAlignedVector3Array* obj, const btScalar* value);
void btAlignedVector3Array_set(btAlignedVector3Array* obj, int n, const btScalar* value);
int btAlignedVector3Array_size(btAlignedVector3Array* obj);
void btAlignedVector3Array_delete(btAlignedVector3Array* obj);
HACD_HACD* HACD_new();
bool HACD_Compute(HACD_HACD* obj);
bool HACD_Compute2(HACD_HACD* obj, bool fullCH);
bool HACD_Compute3(HACD_HACD* obj, bool fullCH, bool exportDistPoints);
void HACD_DenormalizeData(HACD_HACD* obj);
bool HACD_GetAddExtraDistPoints(HACD_HACD* obj);
bool HACD_GetAddFacesPoints(HACD_HACD* obj);
bool HACD_GetAddNeighboursDistPoints(HACD_HACD* obj);
const HACD_CallBackFunction HACD_GetCallBack(HACD_HACD* obj);
bool HACD_GetCH(HACD_HACD* obj, int numCH, HACD_Vec3_Real* points, HACD_Vec3_long* triangles);
double HACD_GetCompacityWeight(HACD_HACD* obj);
double HACD_GetConcavity(HACD_HACD* obj);
double HACD_GetConnectDist(HACD_HACD* obj);
size_t HACD_GetNClusters(HACD_HACD* obj);
size_t HACD_GetNPoints(HACD_HACD* obj);
size_t HACD_GetNPointsCH(HACD_HACD* obj, int numCH);
size_t HACD_GetNTriangles(HACD_HACD* obj);
size_t HACD_GetNTrianglesCH(HACD_HACD* obj, int numCH);
size_t HACD_GetNVerticesPerCH(HACD_HACD* obj);
const long* HACD_GetPartition(HACD_HACD* obj);
const HACD_Vec3_Real* HACD_GetPoints(HACD_HACD* obj);
double HACD_GetScaleFactor(HACD_HACD* obj);
const HACD_Vec3_long* HACD_GetTriangles(HACD_HACD* obj);
double HACD_GetVolumeWeight(HACD_HACD* obj);
void HACD_NormalizeData(HACD_HACD* obj);
bool HACD_Save(HACD_HACD* obj, const char* fileName, bool uniColor);
bool HACD_Save2(HACD_HACD* obj, const char* fileName, bool uniColor, long numCluster);
void HACD_SetAddExtraDistPoints(HACD_HACD* obj, bool addExtraDistPoints);
void HACD_SetAddFacesPoints(HACD_HACD* obj, bool addFacesPoints);
void HACD_SetAddNeighboursDistPoints(HACD_HACD* obj, bool addNeighboursDistPoints);
void HACD_SetCallBack(HACD_HACD* obj, HACD_CallBackFunction callBack);
void HACD_SetCompacityWeight(HACD_HACD* obj, double alpha);
void HACD_SetConcavity(HACD_HACD* obj, double concavity);
void HACD_SetConnectDist(HACD_HACD* obj, double ccConnectDist);
void HACD_SetNClusters(HACD_HACD* obj, int nClusters);
void HACD_SetNPoints(HACD_HACD* obj, int nPoints);
void HACD_SetNTriangles(HACD_HACD* obj, int nTriangles);
void HACD_SetNVerticesPerCH(HACD_HACD* obj, int nVerticesPerCH);
void HACD_SetPoints(HACD_HACD* obj, HACD_Vec3_Real* points);
void HACD_SetScaleFactor(HACD_HACD* obj, double scale);
void HACD_SetTriangles(HACD_HACD* obj, HACD_Vec3_long* triangles);
void HACD_SetVolumeWeight(HACD_HACD* obj, double beta);
void HACD_delete(HACD_HACD* obj);
]])
local lib = ffi.load('libbulletc')
local bullet = {}
do -- UniformScalingShape
	local META = {}
	META.__index = META
	function META:GetUniformScalingFactor(...)
		return lib.btUniformScalingShape_getUniformScalingFactor(self, ...)
	end
	function META:GetChildShape(...)
		return lib.btUniformScalingShape_getChildShape(self, ...)
	end
	ffi.metatype('btUniformScalingShape', META)
	function bullet.CreateUniformScalingShape(...)
		return lib.btUniformScalingShape_new(...)
	end
end
do -- SoftBody_AJoint_IControlWrapper
	local META = {}
	META.__index = META
	function META:GetWrapperData(...)
		return lib.btSoftBody_AJoint_IControlWrapper_getWrapperData(self, ...)
	end
	function META:SetWrapperData(...)
		return lib.btSoftBody_AJoint_IControlWrapper_setWrapperData(self, ...)
	end
	ffi.metatype('btSoftBody_AJoint_IControl', META)
	function bullet.CreateSoftBody_AJoint_IControlWrapper(...)
		return lib.btSoftBody_AJoint_IControlWrapper_new(...)
	end
end
do -- BulletFile
	local META = {}
	META.__index = META
	function META:GetBvhs(...)
		return lib.btBulletFile_getBvhs(self, ...)
	end
	function META:GetRigidBodies(...)
		return lib.btBulletFile_getRigidBodies(self, ...)
	end
	function META:GetDataBlocks(...)
		return lib.btBulletFile_getDataBlocks(self, ...)
	end
	function META:GetCollisionObjects(...)
		return lib.btBulletFile_getCollisionObjects(self, ...)
	end
	function META:GetConstraints(...)
		return lib.btBulletFile_getConstraints(self, ...)
	end
	function META:GetDynamicsWorldInfo(...)
		return lib.btBulletFile_getDynamicsWorldInfo(self, ...)
	end
	function META:GetCollisionShapes(...)
		return lib.btBulletFile_getCollisionShapes(self, ...)
	end
	function META:GetSoftBodies(...)
		return lib.btBulletFile_getSoftBodies(self, ...)
	end
	function META:GetTriangleInfoMaps(...)
		return lib.btBulletFile_getTriangleInfoMaps(self, ...)
	end
	function META:ParseData(...)
		return lib.btBulletFile_parseData(self, ...)
	end
	function META:AddStruct(...)
		return lib.btBulletFile_addStruct(self, ...)
	end
	ffi.metatype('bParse_btBulletFile', META)
	function bullet.CreateBulletFile(...)
		return lib.btBulletFile_new(...)
	end
	function bullet.CreateBulletFile2(...)
		return lib.btBulletFile_new2(...)
	end
	function bullet.CreateBulletFile3(...)
		return lib.btBulletFile_new3(...)
	end
end
do -- ConeTwistConstraint
	local META = {}
	META.__index = META
	function META:GetInfo2NonVirtual(...)
		return lib.btConeTwistConstraint_getInfo2NonVirtual(self, ...)
	end
	function META:SetLimit2(...)
		return lib.btConeTwistConstraint_setLimit2(self, ...)
	end
	function META:GetFrameOffsetA(...)
		return lib.btConeTwistConstraint_getFrameOffsetA(self, ...)
	end
	function META:GetInfo1NonVirtual(...)
		return lib.btConeTwistConstraint_getInfo1NonVirtual(self, ...)
	end
	function META:SetMaxMotorImpulseNormalized(...)
		return lib.btConeTwistConstraint_setMaxMotorImpulseNormalized(self, ...)
	end
	function META:EnableMotor(...)
		return lib.btConeTwistConstraint_enableMotor(self, ...)
	end
	function META:CalcAngleInfo2(...)
		return lib.btConeTwistConstraint_calcAngleInfo2(self, ...)
	end
	function META:GetSwingSpan1(...)
		return lib.btConeTwistConstraint_getSwingSpan1(self, ...)
	end
	function META:IsPastSwingLimit(...)
		return lib.btConeTwistConstraint_isPastSwingLimit(self, ...)
	end
	function META:GetTwistSpan(...)
		return lib.btConeTwistConstraint_getTwistSpan(self, ...)
	end
	function META:GetBFrame(...)
		return lib.btConeTwistConstraint_getBFrame(self, ...)
	end
	function META:SetFixThresh(...)
		return lib.btConeTwistConstraint_setFixThresh(self, ...)
	end
	function META:GetAFrame(...)
		return lib.btConeTwistConstraint_getAFrame(self, ...)
	end
	function META:SetDamping(...)
		return lib.btConeTwistConstraint_setDamping(self, ...)
	end
	function META:GetSwingSpan2(...)
		return lib.btConeTwistConstraint_getSwingSpan2(self, ...)
	end
	function META:GetPointForAngle(...)
		return lib.btConeTwistConstraint_GetPointForAngle(self, ...)
	end
	function META:SetLimit(...)
		return lib.btConeTwistConstraint_setLimit(self, ...)
	end
	function META:SetLimit3(...)
		return lib.btConeTwistConstraint_setLimit3(self, ...)
	end
	function META:UpdateRHS(...)
		return lib.btConeTwistConstraint_updateRHS(self, ...)
	end
	function META:GetSolveTwistLimit(...)
		return lib.btConeTwistConstraint_getSolveTwistLimit(self, ...)
	end
	function META:GetTwistAngle(...)
		return lib.btConeTwistConstraint_getTwistAngle(self, ...)
	end
	function META:SetMotorTargetInConstraintSpace(...)
		return lib.btConeTwistConstraint_setMotorTargetInConstraintSpace(self, ...)
	end
	function META:GetFrameOffsetB(...)
		return lib.btConeTwistConstraint_getFrameOffsetB(self, ...)
	end
	function META:GetTwistLimitSign(...)
		return lib.btConeTwistConstraint_getTwistLimitSign(self, ...)
	end
	function META:SetMaxMotorImpulse(...)
		return lib.btConeTwistConstraint_setMaxMotorImpulse(self, ...)
	end
	function META:SetAngularOnly(...)
		return lib.btConeTwistConstraint_setAngularOnly(self, ...)
	end
	function META:GetFixThresh(...)
		return lib.btConeTwistConstraint_getFixThresh(self, ...)
	end
	function META:CalcAngleInfo(...)
		return lib.btConeTwistConstraint_calcAngleInfo(self, ...)
	end
	function META:SetFrames(...)
		return lib.btConeTwistConstraint_setFrames(self, ...)
	end
	function META:GetSolveSwingLimit(...)
		return lib.btConeTwistConstraint_getSolveSwingLimit(self, ...)
	end
	function META:SetLimit4(...)
		return lib.btConeTwistConstraint_setLimit4(self, ...)
	end
	function META:SetLimit5(...)
		return lib.btConeTwistConstraint_setLimit5(self, ...)
	end
	function META:SetMotorTarget(...)
		return lib.btConeTwistConstraint_setMotorTarget(self, ...)
	end
	ffi.metatype('btConeTwistConstraint', META)
	function bullet.CreateConeTwistConstraint2(...)
		return lib.btConeTwistConstraint_new2(...)
	end
	function bullet.CreateConeTwistConstraint(...)
		return lib.btConeTwistConstraint_new(...)
	end
end
do -- BvhTriangleMeshShape
	local META = {}
	META.__index = META
	function META:GetTriangleInfoMap(...)
		return lib.btBvhTriangleMeshShape_getTriangleInfoMap(self, ...)
	end
	function META:PerformRaycast(...)
		return lib.btBvhTriangleMeshShape_performRaycast(self, ...)
	end
	function META:UsesQuantizedAabbCompression(...)
		return lib.btBvhTriangleMeshShape_usesQuantizedAabbCompression(self, ...)
	end
	function META:RefitTree(...)
		return lib.btBvhTriangleMeshShape_refitTree(self, ...)
	end
	function META:PerformConvexcast(...)
		return lib.btBvhTriangleMeshShape_performConvexcast(self, ...)
	end
	function META:SerializeSingleTriangleInfoMap(...)
		return lib.btBvhTriangleMeshShape_serializeSingleTriangleInfoMap(self, ...)
	end
	function META:PartialRefitTree(...)
		return lib.btBvhTriangleMeshShape_partialRefitTree(self, ...)
	end
	function META:SetOptimizedBvh(...)
		return lib.btBvhTriangleMeshShape_setOptimizedBvh(self, ...)
	end
	function META:SerializeSingleBvh(...)
		return lib.btBvhTriangleMeshShape_serializeSingleBvh(self, ...)
	end
	function META:GetOptimizedBvh(...)
		return lib.btBvhTriangleMeshShape_getOptimizedBvh(self, ...)
	end
	function META:SetTriangleInfoMap(...)
		return lib.btBvhTriangleMeshShape_setTriangleInfoMap(self, ...)
	end
	function META:SetOptimizedBvh2(...)
		return lib.btBvhTriangleMeshShape_setOptimizedBvh2(self, ...)
	end
	function META:GetOwnsBvh(...)
		return lib.btBvhTriangleMeshShape_getOwnsBvh(self, ...)
	end
	function META:BuildOptimizedBvh(...)
		return lib.btBvhTriangleMeshShape_buildOptimizedBvh(self, ...)
	end
	ffi.metatype('btBvhTriangleMeshShape', META)
	function bullet.CreateBvhTriangleMeshShape3(...)
		return lib.btBvhTriangleMeshShape_new3(...)
	end
	function bullet.CreateBvhTriangleMeshShape(...)
		return lib.btBvhTriangleMeshShape_new(...)
	end
	function bullet.CreateBvhTriangleMeshShape2(...)
		return lib.btBvhTriangleMeshShape_new2(...)
	end
	function bullet.CreateBvhTriangleMeshShape4(...)
		return lib.btBvhTriangleMeshShape_new4(...)
	end
end
do -- MultibodyLink
	local META = {}
	META.__index = META
	function META:SetCollider(...)
		return lib.btMultibodyLink_setCollider(self, ...)
	end
	function META:GetInertiaLocal(...)
		return lib.btMultibodyLink_getInertiaLocal(self, ...)
	end
	function META:GetCachedRotParentToThis(...)
		return lib.btMultibodyLink_getCachedRotParentToThis(self, ...)
	end
	function META:Delete(...)
		return lib.btMultibodyLink_delete(self, ...)
	end
	function META:GetAbsFrameLocVelocity(...)
		return lib.btMultibodyLink_getAbsFrameLocVelocity(self, ...)
	end
	function META:SetDofOffset(...)
		return lib.btMultibodyLink_setDofOffset(self, ...)
	end
	function META:SetAxisTop(...)
		return lib.btMultibodyLink_setAxisTop(self, ...)
	end
	function META:GetCfgOffset(...)
		return lib.btMultibodyLink_getCfgOffset(self, ...)
	end
	function META:GetPosVarCount(...)
		return lib.btMultibodyLink_getPosVarCount(self, ...)
	end
	function META:GetJointType(...)
		return lib.btMultibodyLink_getJointType(self, ...)
	end
	function META:GetDVector(...)
		return lib.btMultibodyLink_getDVector(self, ...)
	end
	function META:SetAppliedTorque(...)
		return lib.btMultibodyLink_setAppliedTorque(self, ...)
	end
	function META:SetAxisBottom2(...)
		return lib.btMultibodyLink_setAxisBottom2(self, ...)
	end
	function META:SetPosVarCount(...)
		return lib.btMultibodyLink_setPosVarCount(self, ...)
	end
	function META:SetFlags(...)
		return lib.btMultibodyLink_setFlags(self, ...)
	end
	function META:UpdateCacheMultiDof(...)
		return lib.btMultibodyLink_updateCacheMultiDof(self, ...)
	end
	function META:SetZeroRotParentToThis(...)
		return lib.btMultibodyLink_setZeroRotParentToThis(self, ...)
	end
	function META:UpdateCache(...)
		return lib.btMultibodyLink_updateCache(self, ...)
	end
	function META:SetJointType(...)
		return lib.btMultibodyLink_setJointType(self, ...)
	end
	function META:GetAbsFrameTotVelocity(...)
		return lib.btMultibodyLink_getAbsFrameTotVelocity(self, ...)
	end
	function META:GetAppliedForce(...)
		return lib.btMultibodyLink_getAppliedForce(self, ...)
	end
	function META:UpdateCacheMultiDof2(...)
		return lib.btMultibodyLink_updateCacheMultiDof2(self, ...)
	end
	function META:SetEVector(...)
		return lib.btMultibodyLink_setEVector(self, ...)
	end
	function META:SetAxisBottom(...)
		return lib.btMultibodyLink_setAxisBottom(self, ...)
	end
	function META:SetMass(...)
		return lib.btMultibodyLink_setMass(self, ...)
	end
	function META:SetInertiaLocal(...)
		return lib.btMultibodyLink_setInertiaLocal(self, ...)
	end
	function META:SetAxisTop2(...)
		return lib.btMultibodyLink_setAxisTop2(self, ...)
	end
	function META:GetMass(...)
		return lib.btMultibodyLink_getMass(self, ...)
	end
	function META:SetParent(...)
		return lib.btMultibodyLink_setParent(self, ...)
	end
	function META:SetDVector(...)
		return lib.btMultibodyLink_setDVector(self, ...)
	end
	function META:GetEVector(...)
		return lib.btMultibodyLink_getEVector(self, ...)
	end
	function META:SetAbsFrameLocVelocity(...)
		return lib.btMultibodyLink_setAbsFrameLocVelocity(self, ...)
	end
	function META:SetCfgOffset(...)
		return lib.btMultibodyLink_setCfgOffset(self, ...)
	end
	function META:SetDofCount(...)
		return lib.btMultibodyLink_setDofCount(self, ...)
	end
	function META:GetAxisBottom(...)
		return lib.btMultibodyLink_getAxisBottom(self, ...)
	end
	function META:SetCachedRotParentToThis(...)
		return lib.btMultibodyLink_setCachedRotParentToThis(self, ...)
	end
	function META:GetZeroRotParentToThis(...)
		return lib.btMultibodyLink_getZeroRotParentToThis(self, ...)
	end
	function META:GetDofCount(...)
		return lib.btMultibodyLink_getDofCount(self, ...)
	end
	function META:GetAppliedTorque(...)
		return lib.btMultibodyLink_getAppliedTorque(self, ...)
	end
	function META:GetJointPos(...)
		return lib.btMultibodyLink_getJointPos(self, ...)
	end
	function META:SetAppliedForce(...)
		return lib.btMultibodyLink_setAppliedForce(self, ...)
	end
	function META:GetCollider(...)
		return lib.btMultibodyLink_getCollider(self, ...)
	end
	function META:GetAxisTop(...)
		return lib.btMultibodyLink_getAxisTop(self, ...)
	end
	function META:SetAbsFrameTotVelocity(...)
		return lib.btMultibodyLink_setAbsFrameTotVelocity(self, ...)
	end
	function META:GetFlags(...)
		return lib.btMultibodyLink_getFlags(self, ...)
	end
	function META:GetJointTorque(...)
		return lib.btMultibodyLink_getJointTorque(self, ...)
	end
	function META:SetCachedRVector(...)
		return lib.btMultibodyLink_setCachedRVector(self, ...)
	end
	function META:GetAxes(...)
		return lib.btMultibodyLink_getAxes(self, ...)
	end
	function META:GetParent(...)
		return lib.btMultibodyLink_getParent(self, ...)
	end
	function META:GetDofOffset(...)
		return lib.btMultibodyLink_getDofOffset(self, ...)
	end
	function META:GetCachedRVector(...)
		return lib.btMultibodyLink_getCachedRVector(self, ...)
	end
	ffi.metatype('btMultibodyLink', META)
	function bullet.CreateMultibodyLink(...)
		return lib.btMultibodyLink_new(...)
	end
end
do -- CollisionWorld_LocalConvexResult
	local META = {}
	META.__index = META
	function META:GetHitCollisionObject(...)
		return lib.btCollisionWorld_LocalConvexResult_getHitCollisionObject(self, ...)
	end
	function META:SetHitNormalLocal(...)
		return lib.btCollisionWorld_LocalConvexResult_setHitNormalLocal(self, ...)
	end
	function META:SetHitFraction(...)
		return lib.btCollisionWorld_LocalConvexResult_setHitFraction(self, ...)
	end
	function META:SetHitCollisionObject(...)
		return lib.btCollisionWorld_LocalConvexResult_setHitCollisionObject(self, ...)
	end
	function META:GetLocalShapeInfo(...)
		return lib.btCollisionWorld_LocalConvexResult_getLocalShapeInfo(self, ...)
	end
	function META:SetHitPointLocal(...)
		return lib.btCollisionWorld_LocalConvexResult_setHitPointLocal(self, ...)
	end
	function META:GetHitFraction(...)
		return lib.btCollisionWorld_LocalConvexResult_getHitFraction(self, ...)
	end
	function META:SetLocalShapeInfo(...)
		return lib.btCollisionWorld_LocalConvexResult_setLocalShapeInfo(self, ...)
	end
	function META:GetHitPointLocal(...)
		return lib.btCollisionWorld_LocalConvexResult_getHitPointLocal(self, ...)
	end
	function META:GetHitNormalLocal(...)
		return lib.btCollisionWorld_LocalConvexResult_getHitNormalLocal(self, ...)
	end
	function META:Delete(...)
		return lib.btCollisionWorld_LocalConvexResult_delete(self, ...)
	end
	ffi.metatype('btCollisionWorld_LocalConvexResult', META)
	function bullet.CreateCollisionWorld_LocalConvexResult(...)
		return lib.btCollisionWorld_LocalConvexResult_new(...)
	end
end
do -- GIM_BVH_TREE_NODE_ARRAY
	local META = {}
	META.__index = META
	ffi.metatype('GIM_BVH_TREE_NODE_ARRAY', META)
	function bullet.CreateGIM_BVH_TREE_NODE_ARRAY(...)
		return lib.GIM_BVH_TREE_NODE_ARRAY_new(...)
	end
end
do -- DbvtBroadphase
	local META = {}
	META.__index = META
	function META:GetNewpairs(...)
		return lib.btDbvtBroadphase_getNewpairs(self, ...)
	end
	function META:SetNeedcleanup(...)
		return lib.btDbvtBroadphase_setNeedcleanup(self, ...)
	end
	function META:Optimize(...)
		return lib.btDbvtBroadphase_optimize(self, ...)
	end
	function META:GetDupdates(...)
		return lib.btDbvtBroadphase_getDupdates(self, ...)
	end
	function META:SetFupdates(...)
		return lib.btDbvtBroadphase_setFupdates(self, ...)
	end
	function META:GetDeferedcollide(...)
		return lib.btDbvtBroadphase_getDeferedcollide(self, ...)
	end
	function META:GetFupdates(...)
		return lib.btDbvtBroadphase_getFupdates(self, ...)
	end
	function META:Collide(...)
		return lib.btDbvtBroadphase_collide(self, ...)
	end
	function META:SetGid(...)
		return lib.btDbvtBroadphase_setGid(self, ...)
	end
	function META:SetStageCurrent(...)
		return lib.btDbvtBroadphase_setStageCurrent(self, ...)
	end
	function META:SetAabbForceUpdate(...)
		return lib.btDbvtBroadphase_setAabbForceUpdate(self, ...)
	end
	function META:GetNeedcleanup(...)
		return lib.btDbvtBroadphase_getNeedcleanup(self, ...)
	end
	function META:SetDupdates(...)
		return lib.btDbvtBroadphase_setDupdates(self, ...)
	end
	function META:GetVelocityPrediction(...)
		return lib.btDbvtBroadphase_getVelocityPrediction(self, ...)
	end
	function META:SetPrediction(...)
		return lib.btDbvtBroadphase_setPrediction(self, ...)
	end
	function META:GetStageRoots(...)
		return lib.btDbvtBroadphase_getStageRoots(self, ...)
	end
	function META:SetDeferedcollide(...)
		return lib.btDbvtBroadphase_setDeferedcollide(self, ...)
	end
	function META:SetVelocityPrediction(...)
		return lib.btDbvtBroadphase_setVelocityPrediction(self, ...)
	end
	function META:GetSets(...)
		return lib.btDbvtBroadphase_getSets(self, ...)
	end
	function META:GetCupdates(...)
		return lib.btDbvtBroadphase_getCupdates(self, ...)
	end
	function META:GetPrediction(...)
		return lib.btDbvtBroadphase_getPrediction(self, ...)
	end
	function META:SetPid(...)
		return lib.btDbvtBroadphase_setPid(self, ...)
	end
	function META:GetGid(...)
		return lib.btDbvtBroadphase_getGid(self, ...)
	end
	function META:GetReleasepaircache(...)
		return lib.btDbvtBroadphase_getReleasepaircache(self, ...)
	end
	function META:SetNewpairs(...)
		return lib.btDbvtBroadphase_setNewpairs(self, ...)
	end
	function META:GetStageCurrent(...)
		return lib.btDbvtBroadphase_getStageCurrent(self, ...)
	end
	function META:PerformDeferredRemoval(...)
		return lib.btDbvtBroadphase_performDeferredRemoval(self, ...)
	end
	function META:Benchmark(...)
		return lib.btDbvtBroadphase_benchmark(self, ...)
	end
	function META:GetPaircache(...)
		return lib.btDbvtBroadphase_getPaircache(self, ...)
	end
	function META:GetPid(...)
		return lib.btDbvtBroadphase_getPid(self, ...)
	end
	function META:SetReleasepaircache(...)
		return lib.btDbvtBroadphase_setReleasepaircache(self, ...)
	end
	function META:GetFixedleft(...)
		return lib.btDbvtBroadphase_getFixedleft(self, ...)
	end
	function META:SetPaircache(...)
		return lib.btDbvtBroadphase_setPaircache(self, ...)
	end
	function META:SetCid(...)
		return lib.btDbvtBroadphase_setCid(self, ...)
	end
	function META:SetCupdates(...)
		return lib.btDbvtBroadphase_setCupdates(self, ...)
	end
	function META:GetCid(...)
		return lib.btDbvtBroadphase_getCid(self, ...)
	end
	function META:SetFixedleft(...)
		return lib.btDbvtBroadphase_setFixedleft(self, ...)
	end
	ffi.metatype('btDbvtBroadphase', META)
	function bullet.CreateDbvtBroadphase(...)
		return lib.btDbvtBroadphase_new(...)
	end
	function bullet.CreateDbvtBroadphase2(...)
		return lib.btDbvtBroadphase_new2(...)
	end
end
do -- Generic6DofSpringConstraint
	local META = {}
	META.__index = META
	function META:SetDamping(...)
		return lib.btGeneric6DofSpringConstraint_setDamping(self, ...)
	end
	function META:SetEquilibriumPoint(...)
		return lib.btGeneric6DofSpringConstraint_setEquilibriumPoint(self, ...)
	end
	function META:SetEquilibriumPoint3(...)
		return lib.btGeneric6DofSpringConstraint_setEquilibriumPoint3(self, ...)
	end
	function META:EnableSpring(...)
		return lib.btGeneric6DofSpringConstraint_enableSpring(self, ...)
	end
	function META:SetStiffness(...)
		return lib.btGeneric6DofSpringConstraint_setStiffness(self, ...)
	end
	function META:SetEquilibriumPoint2(...)
		return lib.btGeneric6DofSpringConstraint_setEquilibriumPoint2(self, ...)
	end
	ffi.metatype('btGeneric6DofSpringConstraint', META)
	function bullet.CreateGeneric6DofSpringConstraint2(...)
		return lib.btGeneric6DofSpringConstraint_new2(...)
	end
	function bullet.CreateGeneric6DofSpringConstraint6(...)
		return lib.btGeneric6DofSpringConstraint_new(...)
	end
end
do -- RotationalLimitMotor2
	local META = {}
	META.__index = META
	function META:SetTargetVelocity(...)
		return lib.btRotationalLimitMotor2_setTargetVelocity(self, ...)
	end
	function META:GetLoLimit(...)
		return lib.btRotationalLimitMotor2_getLoLimit(self, ...)
	end
	function META:GetCurrentLimit(...)
		return lib.btRotationalLimitMotor2_getCurrentLimit(self, ...)
	end
	function META:GetEquilibriumPoint(...)
		return lib.btRotationalLimitMotor2_getEquilibriumPoint(self, ...)
	end
	function META:SetCurrentPosition(...)
		return lib.btRotationalLimitMotor2_setCurrentPosition(self, ...)
	end
	function META:GetEnableSpring(...)
		return lib.btRotationalLimitMotor2_getEnableSpring(self, ...)
	end
	function META:SetEnableMotor(...)
		return lib.btRotationalLimitMotor2_setEnableMotor(self, ...)
	end
	function META:SetCurrentLimitErrorHi(...)
		return lib.btRotationalLimitMotor2_setCurrentLimitErrorHi(self, ...)
	end
	function META:SetEquilibriumPoint(...)
		return lib.btRotationalLimitMotor2_setEquilibriumPoint(self, ...)
	end
	function META:IsLimited(...)
		return lib.btRotationalLimitMotor2_isLimited(self, ...)
	end
	function META:SetCurrentLimit(...)
		return lib.btRotationalLimitMotor2_setCurrentLimit(self, ...)
	end
	function META:SetServoMotor(...)
		return lib.btRotationalLimitMotor2_setServoMotor(self, ...)
	end
	function META:GetSpringDamping(...)
		return lib.btRotationalLimitMotor2_getSpringDamping(self, ...)
	end
	function META:SetMotorERP(...)
		return lib.btRotationalLimitMotor2_setMotorERP(self, ...)
	end
	function META:GetServoMotor(...)
		return lib.btRotationalLimitMotor2_getServoMotor(self, ...)
	end
	function META:GetTargetVelocity(...)
		return lib.btRotationalLimitMotor2_getTargetVelocity(self, ...)
	end
	function META:Delete(...)
		return lib.btRotationalLimitMotor2_delete(self, ...)
	end
	function META:TestLimitValue(...)
		return lib.btRotationalLimitMotor2_testLimitValue(self, ...)
	end
	function META:SetStopERP(...)
		return lib.btRotationalLimitMotor2_setStopERP(self, ...)
	end
	function META:GetMotorCFM(...)
		return lib.btRotationalLimitMotor2_getMotorCFM(self, ...)
	end
	function META:SetStopCFM(...)
		return lib.btRotationalLimitMotor2_setStopCFM(self, ...)
	end
	function META:GetEnableMotor(...)
		return lib.btRotationalLimitMotor2_getEnableMotor(self, ...)
	end
	function META:GetServoTarget(...)
		return lib.btRotationalLimitMotor2_getServoTarget(self, ...)
	end
	function META:SetSpringStiffness(...)
		return lib.btRotationalLimitMotor2_setSpringStiffness(self, ...)
	end
	function META:GetStopERP(...)
		return lib.btRotationalLimitMotor2_getStopERP(self, ...)
	end
	function META:SetSpringDamping(...)
		return lib.btRotationalLimitMotor2_setSpringDamping(self, ...)
	end
	function META:GetCurrentPosition(...)
		return lib.btRotationalLimitMotor2_getCurrentPosition(self, ...)
	end
	function META:SetServoTarget(...)
		return lib.btRotationalLimitMotor2_setServoTarget(self, ...)
	end
	function META:SetLoLimit(...)
		return lib.btRotationalLimitMotor2_setLoLimit(self, ...)
	end
	function META:SetMotorCFM(...)
		return lib.btRotationalLimitMotor2_setMotorCFM(self, ...)
	end
	function META:GetCurrentLimitError(...)
		return lib.btRotationalLimitMotor2_getCurrentLimitError(self, ...)
	end
	function META:GetMotorERP(...)
		return lib.btRotationalLimitMotor2_getMotorERP(self, ...)
	end
	function META:GetBounce(...)
		return lib.btRotationalLimitMotor2_getBounce(self, ...)
	end
	function META:GetStopCFM(...)
		return lib.btRotationalLimitMotor2_getStopCFM(self, ...)
	end
	function META:GetHiLimit(...)
		return lib.btRotationalLimitMotor2_getHiLimit(self, ...)
	end
	function META:SetBounce(...)
		return lib.btRotationalLimitMotor2_setBounce(self, ...)
	end
	function META:GetSpringStiffness(...)
		return lib.btRotationalLimitMotor2_getSpringStiffness(self, ...)
	end
	function META:SetCurrentLimitError(...)
		return lib.btRotationalLimitMotor2_setCurrentLimitError(self, ...)
	end
	function META:SetMaxMotorForce(...)
		return lib.btRotationalLimitMotor2_setMaxMotorForce(self, ...)
	end
	function META:SetHiLimit(...)
		return lib.btRotationalLimitMotor2_setHiLimit(self, ...)
	end
	function META:GetMaxMotorForce(...)
		return lib.btRotationalLimitMotor2_getMaxMotorForce(self, ...)
	end
	function META:SetEnableSpring(...)
		return lib.btRotationalLimitMotor2_setEnableSpring(self, ...)
	end
	function META:GetCurrentLimitErrorHi(...)
		return lib.btRotationalLimitMotor2_getCurrentLimitErrorHi(self, ...)
	end
	ffi.metatype('btRotationalLimitMotor2', META)
	function bullet.CreateRotationalLimitMotor22(...)
		return lib.btRotationalLimitMotor2_new2(...)
	end
end
do -- ConstraintSetting
	local META = {}
	META.__index = META
	function META:GetTau(...)
		return lib.btConstraintSetting_getTau(self, ...)
	end
	function META:SetDamping(...)
		return lib.btConstraintSetting_setDamping(self, ...)
	end
	function META:GetImpulseClamp(...)
		return lib.btConstraintSetting_getImpulseClamp(self, ...)
	end
	function META:Delete(...)
		return lib.btConstraintSetting_delete(self, ...)
	end
	function META:GetDamping(...)
		return lib.btConstraintSetting_getDamping(self, ...)
	end
	function META:SetTau(...)
		return lib.btConstraintSetting_setTau(self, ...)
	end
	function META:SetImpulseClamp(...)
		return lib.btConstraintSetting_setImpulseClamp(self, ...)
	end
	ffi.metatype('btConstraintSetting', META)
	function bullet.CreateConstraintSetting(...)
		return lib.btConstraintSetting_new(...)
	end
end
do -- CollisionAlgorithmConstructionInfo
	local META = {}
	META.__index = META
	function META:GetDispatcher1(...)
		return lib.btCollisionAlgorithmConstructionInfo_getDispatcher1(self, ...)
	end
	function META:SetManifold(...)
		return lib.btCollisionAlgorithmConstructionInfo_setManifold(self, ...)
	end
	function META:SetDispatcher1(...)
		return lib.btCollisionAlgorithmConstructionInfo_setDispatcher1(self, ...)
	end
	function META:GetManifold(...)
		return lib.btCollisionAlgorithmConstructionInfo_getManifold(self, ...)
	end
	function META:Delete(...)
		return lib.btCollisionAlgorithmConstructionInfo_delete(self, ...)
	end
	ffi.metatype('btCollisionAlgorithmConstructionInfo', META)
	function bullet.CreateCollisionAlgorithmConstructionInfo(...)
		return lib.btCollisionAlgorithmConstructionInfo_new(...)
	end
	function bullet.CreateCollisionAlgorithmConstructionInfo2(...)
		return lib.btCollisionAlgorithmConstructionInfo_new2(...)
	end
end
do -- BulletWorldImporter
	local META = {}
	META.__index = META
	function META:LoadFile2(...)
		return lib.btBulletWorldImporter_loadFile2(self, ...)
	end
	function META:LoadFileFromMemory(...)
		return lib.btBulletWorldImporter_loadFileFromMemory(self, ...)
	end
	function META:LoadFileFromMemory2(...)
		return lib.btBulletWorldImporter_loadFileFromMemory2(self, ...)
	end
	function META:ConvertAllObjects(...)
		return lib.btBulletWorldImporter_convertAllObjects(self, ...)
	end
	function META:LoadFile(...)
		return lib.btBulletWorldImporter_loadFile(self, ...)
	end
	ffi.metatype('btBulletWorldImporter', META)
	function bullet.CreateBulletWorldImporter2(...)
		return lib.btBulletWorldImporter_new2(...)
	end
	function bullet.CreateBulletWorldImporter(...)
		return lib.btBulletWorldImporter_new(...)
	end
end
do -- Box2dShape
	local META = {}
	META.__index = META
	function META:GetVertexCount(...)
		return lib.btBox2dShape_getVertexCount(self, ...)
	end
	function META:GetVertices(...)
		return lib.btBox2dShape_getVertices(self, ...)
	end
	function META:GetNormals(...)
		return lib.btBox2dShape_getNormals(self, ...)
	end
	function META:GetPlaneEquation(...)
		return lib.btBox2dShape_getPlaneEquation(self, ...)
	end
	function META:GetCentroid(...)
		return lib.btBox2dShape_getCentroid(self, ...)
	end
	function META:GetHalfExtentsWithMargin(...)
		return lib.btBox2dShape_getHalfExtentsWithMargin(self, ...)
	end
	function META:GetHalfExtentsWithoutMargin(...)
		return lib.btBox2dShape_getHalfExtentsWithoutMargin(self, ...)
	end
	ffi.metatype('btBox2dShape', META)
	function bullet.CreateBox2dShape2(...)
		return lib.btBox2dShape_new2(...)
	end
	function bullet.CreateBox2dShape3(...)
		return lib.btBox2dShape_new3(...)
	end
end
do -- MultiBody
	local META = {}
	META.__index = META
	function META:FillContactJacobianMultiDof(...)
		return lib.btMultiBody_fillContactJacobianMultiDof(self, ...)
	end
	function META:GetBasePos(...)
		return lib.btMultiBody_getBasePos(self, ...)
	end
	function META:GetBaseMass(...)
		return lib.btMultiBody_getBaseMass(self, ...)
	end
	function META:IsUsingGlobalVelocities(...)
		return lib.btMultiBody_isUsingGlobalVelocities(self, ...)
	end
	function META:GetWorldToBaseRot(...)
		return lib.btMultiBody_getWorldToBaseRot(self, ...)
	end
	function META:SetJointVel(...)
		return lib.btMultiBody_setJointVel(self, ...)
	end
	function META:GetKineticEnergy(...)
		return lib.btMultiBody_getKineticEnergy(self, ...)
	end
	function META:SetupSpherical(...)
		return lib.btMultiBody_setupSpherical(self, ...)
	end
	function META:GetJointVelMultiDof(...)
		return lib.btMultiBody_getJointVelMultiDof(self, ...)
	end
	function META:FillContactJacobian(...)
		return lib.btMultiBody_fillContactJacobian(self, ...)
	end
	function META:SetWorldToBaseRot(...)
		return lib.btMultiBody_setWorldToBaseRot(self, ...)
	end
	function META:AddJointTorque(...)
		return lib.btMultiBody_addJointTorque(self, ...)
	end
	function META:AddJointTorqueMultiDof2(...)
		return lib.btMultiBody_addJointTorqueMultiDof2(self, ...)
	end
	function META:GetBaseOmega(...)
		return lib.btMultiBody_getBaseOmega(self, ...)
	end
	function META:ClearForcesAndTorques(...)
		return lib.btMultiBody_clearForcesAndTorques(self, ...)
	end
	function META:StepVelocitiesMultiDof(...)
		return lib.btMultiBody_stepVelocitiesMultiDof(self, ...)
	end
	function META:AddJointTorqueMultiDof(...)
		return lib.btMultiBody_addJointTorqueMultiDof(self, ...)
	end
	function META:GetBaseVel(...)
		return lib.btMultiBody_getBaseVel(self, ...)
	end
	function META:GetParentToLocalRot(...)
		return lib.btMultiBody_getParentToLocalRot(self, ...)
	end
	function META:CheckMotionAndSleepIfRequired(...)
		return lib.btMultiBody_checkMotionAndSleepIfRequired(self, ...)
	end
	function META:SetupPlanar(...)
		return lib.btMultiBody_setupPlanar(self, ...)
	end
	function META:SetJointPosMultiDof(...)
		return lib.btMultiBody_setJointPosMultiDof(self, ...)
	end
	function META:IsPosUpdated(...)
		return lib.btMultiBody_isPosUpdated(self, ...)
	end
	function META:GetNumLinks(...)
		return lib.btMultiBody_getNumLinks(self, ...)
	end
	function META:SetUseGyroTerm(...)
		return lib.btMultiBody_setUseGyroTerm(self, ...)
	end
	function META:GetRVector(...)
		return lib.btMultiBody_getRVector(self, ...)
	end
	function META:StepPositions(...)
		return lib.btMultiBody_stepPositions(self, ...)
	end
	function META:SetBaseCollider(...)
		return lib.btMultiBody_setBaseCollider(self, ...)
	end
	function META:GetJointPosMultiDof(...)
		return lib.btMultiBody_getJointPosMultiDof(self, ...)
	end
	function META:WorldDirToLocal(...)
		return lib.btMultiBody_worldDirToLocal(self, ...)
	end
	function META:StepVelocities(...)
		return lib.btMultiBody_stepVelocities(self, ...)
	end
	function META:GetLink(...)
		return lib.btMultiBody_getLink(self, ...)
	end
	function META:UseRK4Integration(...)
		return lib.btMultiBody_useRK4Integration(self, ...)
	end
	function META:UseGlobalVelocities(...)
		return lib.btMultiBody_useGlobalVelocities(self, ...)
	end
	function META:GetMaxAppliedImpulse(...)
		return lib.btMultiBody_getMaxAppliedImpulse(self, ...)
	end
	function META:AddBaseTorque(...)
		return lib.btMultiBody_addBaseTorque(self, ...)
	end
	function META:GetJointTorque(...)
		return lib.btMultiBody_getJointTorque(self, ...)
	end
	function META:WakeUp(...)
		return lib.btMultiBody_wakeUp(self, ...)
	end
	function META:StepPositionsMultiDof3(...)
		return lib.btMultiBody_stepPositionsMultiDof3(self, ...)
	end
	function META:GetParent(...)
		return lib.btMultiBody_getParent(self, ...)
	end
	function META:GetAngularDamping(...)
		return lib.btMultiBody_getAngularDamping(self, ...)
	end
	function META:ApplyDeltaVee(...)
		return lib.btMultiBody_applyDeltaVee(self, ...)
	end
	function META:StepPositionsMultiDof2(...)
		return lib.btMultiBody_stepPositionsMultiDof2(self, ...)
	end
	function META:StepPositionsMultiDof(...)
		return lib.btMultiBody_stepPositionsMultiDof(self, ...)
	end
	function META:GetJointVel(...)
		return lib.btMultiBody_getJointVel(self, ...)
	end
	function META:CalcAccelerationDeltasMultiDof(...)
		return lib.btMultiBody_calcAccelerationDeltasMultiDof(self, ...)
	end
	function META:SetBaseVel(...)
		return lib.btMultiBody_setBaseVel(self, ...)
	end
	function META:GetCompanionId(...)
		return lib.btMultiBody_getCompanionId(self, ...)
	end
	function META:GetLinkTorque(...)
		return lib.btMultiBody_getLinkTorque(self, ...)
	end
	function META:Delete(...)
		return lib.btMultiBody_delete(self, ...)
	end
	function META:SetupSpherical2(...)
		return lib.btMultiBody_setupSpherical2(self, ...)
	end
	function META:SetupRevolute2(...)
		return lib.btMultiBody_setupRevolute2(self, ...)
	end
	function META:SetBaseOmega(...)
		return lib.btMultiBody_setBaseOmega(self, ...)
	end
	function META:SetupPlanar2(...)
		return lib.btMultiBody_setupPlanar2(self, ...)
	end
	function META:GoToSleep(...)
		return lib.btMultiBody_goToSleep(self, ...)
	end
	function META:SetupPrismatic(...)
		return lib.btMultiBody_setupPrismatic(self, ...)
	end
	function META:SetupRevolute(...)
		return lib.btMultiBody_setupRevolute(self, ...)
	end
	function META:SetupFixed(...)
		return lib.btMultiBody_setupFixed(self, ...)
	end
	function META:SetPosUpdated(...)
		return lib.btMultiBody_setPosUpdated(self, ...)
	end
	function META:SetJointVelMultiDof(...)
		return lib.btMultiBody_setJointVelMultiDof(self, ...)
	end
	function META:SetMaxCoordinateVelocity(...)
		return lib.btMultiBody_setMaxCoordinateVelocity(self, ...)
	end
	function META:LocalPosToWorld(...)
		return lib.btMultiBody_localPosToWorld(self, ...)
	end
	function META:FilConstraintJacobianMultiDof(...)
		return lib.btMultiBody_filConstraintJacobianMultiDof(self, ...)
	end
	function META:SetNumLinks(...)
		return lib.btMultiBody_setNumLinks(self, ...)
	end
	function META:SetJointPos(...)
		return lib.btMultiBody_setJointPos(self, ...)
	end
	function META:GetBaseCollider(...)
		return lib.btMultiBody_getBaseCollider(self, ...)
	end
	function META:SetHasSelfCollision(...)
		return lib.btMultiBody_setHasSelfCollision(self, ...)
	end
	function META:LocalDirToWorld(...)
		return lib.btMultiBody_localDirToWorld(self, ...)
	end
	function META:SetCompanionId(...)
		return lib.btMultiBody_setCompanionId(self, ...)
	end
	function META:ApplyDeltaVeeMultiDof(...)
		return lib.btMultiBody_applyDeltaVeeMultiDof(self, ...)
	end
	function META:HasFixedBase(...)
		return lib.btMultiBody_hasFixedBase(self, ...)
	end
	function META:SetCanSleep(...)
		return lib.btMultiBody_setCanSleep(self, ...)
	end
	function META:SetBasePos(...)
		return lib.btMultiBody_setBasePos(self, ...)
	end
	function META:GetLinkForce(...)
		return lib.btMultiBody_getLinkForce(self, ...)
	end
	function META:SetBaseMass(...)
		return lib.btMultiBody_setBaseMass(self, ...)
	end
	function META:GetAngularMomentum(...)
		return lib.btMultiBody_getAngularMomentum(self, ...)
	end
	function META:WorldPosToLocal(...)
		return lib.btMultiBody_worldPosToLocal(self, ...)
	end
	function META:SetAngularDamping(...)
		return lib.btMultiBody_setAngularDamping(self, ...)
	end
	function META:SetMaxAppliedImpulse(...)
		return lib.btMultiBody_setMaxAppliedImpulse(self, ...)
	end
	function META:HasSelfCollision(...)
		return lib.btMultiBody_hasSelfCollision(self, ...)
	end
	function META:ClearVelocities(...)
		return lib.btMultiBody_clearVelocities(self, ...)
	end
	function META:CalcAccelerationDeltas(...)
		return lib.btMultiBody_calcAccelerationDeltas(self, ...)
	end
	function META:IsMultiDof(...)
		return lib.btMultiBody_isMultiDof(self, ...)
	end
	function META:IsUsingRK4Integration(...)
		return lib.btMultiBody_isUsingRK4Integration(self, ...)
	end
	function META:IsAwake(...)
		return lib.btMultiBody_isAwake(self, ...)
	end
	function META:AddLinkForce(...)
		return lib.btMultiBody_addLinkForce(self, ...)
	end
	function META:FinalizeMultiDof(...)
		return lib.btMultiBody_finalizeMultiDof(self, ...)
	end
	function META:GetBaseForce(...)
		return lib.btMultiBody_getBaseForce(self, ...)
	end
	function META:AddLinkTorque(...)
		return lib.btMultiBody_addLinkTorque(self, ...)
	end
	function META:GetMaxCoordinateVelocity(...)
		return lib.btMultiBody_getMaxCoordinateVelocity(self, ...)
	end
	function META:GetBaseTorque(...)
		return lib.btMultiBody_getBaseTorque(self, ...)
	end
	function META:SetLinearDamping(...)
		return lib.btMultiBody_setLinearDamping(self, ...)
	end
	function META:GetLinkMass(...)
		return lib.btMultiBody_getLinkMass(self, ...)
	end
	function META:ApplyDeltaVee2(...)
		return lib.btMultiBody_applyDeltaVee2(self, ...)
	end
	function META:GetJointPos(...)
		return lib.btMultiBody_getJointPos(self, ...)
	end
	function META:GetLinearDamping(...)
		return lib.btMultiBody_getLinearDamping(self, ...)
	end
	function META:GetBaseInertia(...)
		return lib.btMultiBody_getBaseInertia(self, ...)
	end
	function META:AddBaseForce(...)
		return lib.btMultiBody_addBaseForce(self, ...)
	end
	function META:GetJointTorqueMultiDof(...)
		return lib.btMultiBody_getJointTorqueMultiDof(self, ...)
	end
	function META:GetCanSleep(...)
		return lib.btMultiBody_getCanSleep(self, ...)
	end
	function META:SetBaseInertia(...)
		return lib.btMultiBody_setBaseInertia(self, ...)
	end
	function META:GetNumPosVars(...)
		return lib.btMultiBody_getNumPosVars(self, ...)
	end
	function META:GetNumDofs(...)
		return lib.btMultiBody_getNumDofs(self, ...)
	end
	function META:GetUseGyroTerm(...)
		return lib.btMultiBody_getUseGyroTerm(self, ...)
	end
	function META:GetVelocityVector(...)
		return lib.btMultiBody_getVelocityVector(self, ...)
	end
	function META:GetLinkInertia(...)
		return lib.btMultiBody_getLinkInertia(self, ...)
	end
	ffi.metatype('btMultiBody', META)
	function bullet.CreateMultiBody(...)
		return lib.btMultiBody_new(...)
	end
	function bullet.CreateMultiBody2(...)
		return lib.btMultiBody_new2(...)
	end
end
do -- TetrahedronShapeEx
	local META = {}
	META.__index = META
	function META:SetVertices(...)
		return lib.btTetrahedronShapeEx_setVertices(self, ...)
	end
	ffi.metatype('btTetrahedronShapeEx', META)
	function bullet.CreateTetrahedronShapeEx(...)
		return lib.btTetrahedronShapeEx_new(...)
	end
end
do -- SoftBodyConcaveCollisionAlgorithm_SwappedCreateFunc
	local META = {}
	META.__index = META
	ffi.metatype('btSoftBodyConcaveCollisionAlgorithm_SwappedCreateFunc', META)
	function bullet.CreateSoftBodyConcaveCollisionAlgorithm_SwappedCreateFunc(...)
		return lib.btSoftBodyConcaveCollisionAlgorithm_SwappedCreateFunc_new(...)
	end
end
do -- MotionStateWrapper
	local META = {}
	META.__index = META
	ffi.metatype('btMotionStateWrapper', META)
	function bullet.CreateMotionStateWrapper(...)
		return lib.btMotionStateWrapper_new(...)
	end
end
do -- MultimaterialTriangleMeshShape
	local META = {}
	META.__index = META
	function META:GetMaterialProperties(...)
		return lib.btMultimaterialTriangleMeshShape_getMaterialProperties(self, ...)
	end
	ffi.metatype('btMultimaterialTriangleMeshShape', META)
	function bullet.CreateMultimaterialTriangleMeshShape(...)
		return lib.btMultimaterialTriangleMeshShape_new(...)
	end
	function bullet.CreateMultimaterialTriangleMeshShape3(...)
		return lib.btMultimaterialTriangleMeshShape_new3(...)
	end
	function bullet.CreateMultimaterialTriangleMeshShape4(...)
		return lib.btMultimaterialTriangleMeshShape_new4(...)
	end
	function bullet.CreateMultimaterialTriangleMeshShape2(...)
		return lib.btMultimaterialTriangleMeshShape_new2(...)
	end
end
do -- GIM_QUANTIZED_BVH_NODE_ARRAY
	local META = {}
	META.__index = META
	ffi.metatype('GIM_QUANTIZED_BVH_NODE_ARRAY', META)
	function bullet.CreateGIM_QUANTIZED_BVH_NODE_ARRAY(...)
		return lib.GIM_QUANTIZED_BVH_NODE_ARRAY_new(...)
	end
end
do -- RaycastVehicle
	local META = {}
	META.__index = META
	function META:SetCoordinateSystem(...)
		return lib.btRaycastVehicle_setCoordinateSystem(self, ...)
	end
	function META:GetNumWheels(...)
		return lib.btRaycastVehicle_getNumWheels(self, ...)
	end
	function META:UpdateWheelTransformsWS2(...)
		return lib.btRaycastVehicle_updateWheelTransformsWS2(self, ...)
	end
	function META:UpdateWheelTransform(...)
		return lib.btRaycastVehicle_updateWheelTransform(self, ...)
	end
	function META:GetUserConstraintType(...)
		return lib.btRaycastVehicle_getUserConstraintType(self, ...)
	end
	function META:UpdateWheelTransform2(...)
		return lib.btRaycastVehicle_updateWheelTransform2(self, ...)
	end
	function META:GetWheelInfo(...)
		return lib.btRaycastVehicle_getWheelInfo(self, ...)
	end
	function META:GetWheelInfo2(...)
		return lib.btRaycastVehicle_getWheelInfo2(self, ...)
	end
	function META:UpdateWheelTransformsWS(...)
		return lib.btRaycastVehicle_updateWheelTransformsWS(self, ...)
	end
	function META:UpdateVehicle(...)
		return lib.btRaycastVehicle_updateVehicle(self, ...)
	end
	function META:ApplyEngineForce(...)
		return lib.btRaycastVehicle_applyEngineForce(self, ...)
	end
	function META:ResetSuspension(...)
		return lib.btRaycastVehicle_resetSuspension(self, ...)
	end
	function META:AddWheel(...)
		return lib.btRaycastVehicle_addWheel(self, ...)
	end
	function META:GetWheelTransformWS(...)
		return lib.btRaycastVehicle_getWheelTransformWS(self, ...)
	end
	function META:GetRightAxis(...)
		return lib.btRaycastVehicle_getRightAxis(self, ...)
	end
	function META:SetBrake(...)
		return lib.btRaycastVehicle_setBrake(self, ...)
	end
	function META:SetPitchControl(...)
		return lib.btRaycastVehicle_setPitchControl(self, ...)
	end
	function META:SetUserConstraintType(...)
		return lib.btRaycastVehicle_setUserConstraintType(self, ...)
	end
	function META:GetCurrentSpeedKmHour(...)
		return lib.btRaycastVehicle_getCurrentSpeedKmHour(self, ...)
	end
	function META:GetRigidBody(...)
		return lib.btRaycastVehicle_getRigidBody(self, ...)
	end
	function META:SetUserConstraintId(...)
		return lib.btRaycastVehicle_setUserConstraintId(self, ...)
	end
	function META:SetSteeringValue(...)
		return lib.btRaycastVehicle_setSteeringValue(self, ...)
	end
	function META:UpdateFriction(...)
		return lib.btRaycastVehicle_updateFriction(self, ...)
	end
	function META:GetSteeringValue(...)
		return lib.btRaycastVehicle_getSteeringValue(self, ...)
	end
	function META:RayCast(...)
		return lib.btRaycastVehicle_rayCast(self, ...)
	end
	function META:GetForwardAxis(...)
		return lib.btRaycastVehicle_getForwardAxis(self, ...)
	end
	function META:GetUpAxis(...)
		return lib.btRaycastVehicle_getUpAxis(self, ...)
	end
	function META:UpdateSuspension(...)
		return lib.btRaycastVehicle_updateSuspension(self, ...)
	end
	function META:GetChassisWorldTransform(...)
		return lib.btRaycastVehicle_getChassisWorldTransform(self, ...)
	end
	function META:GetForwardVector(...)
		return lib.btRaycastVehicle_getForwardVector(self, ...)
	end
	function META:GetUserConstraintId(...)
		return lib.btRaycastVehicle_getUserConstraintId(self, ...)
	end
	ffi.metatype('btRaycastVehicle', META)
	function bullet.CreateRaycastVehicle(...)
		return lib.btRaycastVehicle_new(...)
	end
end
do -- RigidBody_btRigidBodyConstructionInfo
	local META = {}
	META.__index = META
	function META:SetAngularDamping(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_setAngularDamping(self, ...)
	end
	function META:GetCollisionShape(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_getCollisionShape(self, ...)
	end
	function META:Delete(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_delete(self, ...)
	end
	function META:SetAdditionalDamping(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_setAdditionalDamping(self, ...)
	end
	function META:SetMotionState(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_setMotionState(self, ...)
	end
	function META:SetAdditionalAngularDampingFactor(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_setAdditionalAngularDampingFactor(self, ...)
	end
	function META:SetRestitution(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_setRestitution(self, ...)
	end
	function META:GetAdditionalDampingFactor(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_getAdditionalDampingFactor(self, ...)
	end
	function META:SetLocalInertia(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_setLocalInertia(self, ...)
	end
	function META:SetAdditionalDampingFactor(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_setAdditionalDampingFactor(self, ...)
	end
	function META:GetAdditionalDamping(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_getAdditionalDamping(self, ...)
	end
	function META:GetFriction(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_getFriction(self, ...)
	end
	function META:GetLocalInertia(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_getLocalInertia(self, ...)
	end
	function META:GetStartWorldTransform(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_getStartWorldTransform(self, ...)
	end
	function META:SetAdditionalLinearDampingThresholdSqr(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_setAdditionalLinearDampingThresholdSqr(self, ...)
	end
	function META:SetLinearSleepingThreshold(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_setLinearSleepingThreshold(self, ...)
	end
	function META:GetAdditionalLinearDampingThresholdSqr(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_getAdditionalLinearDampingThresholdSqr(self, ...)
	end
	function META:SetMass(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_setMass(self, ...)
	end
	function META:SetStartWorldTransform(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_setStartWorldTransform(self, ...)
	end
	function META:SetRollingFriction(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_setRollingFriction(self, ...)
	end
	function META:GetRollingFriction(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_getRollingFriction(self, ...)
	end
	function META:SetLinearDamping(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_setLinearDamping(self, ...)
	end
	function META:SetFriction(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_setFriction(self, ...)
	end
	function META:GetAngularSleepingThreshold(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_getAngularSleepingThreshold(self, ...)
	end
	function META:GetLinearDamping(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_getLinearDamping(self, ...)
	end
	function META:GetAngularDamping(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_getAngularDamping(self, ...)
	end
	function META:SetAngularSleepingThreshold(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_setAngularSleepingThreshold(self, ...)
	end
	function META:GetLinearSleepingThreshold(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_getLinearSleepingThreshold(self, ...)
	end
	function META:GetRestitution(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_getRestitution(self, ...)
	end
	function META:SetCollisionShape(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_setCollisionShape(self, ...)
	end
	function META:SetAdditionalAngularDampingThresholdSqr(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_setAdditionalAngularDampingThresholdSqr(self, ...)
	end
	function META:GetAdditionalAngularDampingThresholdSqr(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_getAdditionalAngularDampingThresholdSqr(self, ...)
	end
	function META:GetMotionState(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_getMotionState(self, ...)
	end
	function META:GetAdditionalAngularDampingFactor(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_getAdditionalAngularDampingFactor(self, ...)
	end
	function META:GetMass(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_getMass(self, ...)
	end
	ffi.metatype('btRigidBody_btRigidBodyConstructionInfo', META)
	function bullet.CreateRigidBody_btRigidBodyConstructionInfo2(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_new2(...)
	end
	function bullet.CreateRigidBody_btRigidBodyConstructionInfo(...)
		return lib.btRigidBody_btRigidBodyConstructionInfo_new(...)
	end
end
do -- GImpactCollisionAlgorithm_CreateFunc
	local META = {}
	META.__index = META
	ffi.metatype('btGImpactCollisionAlgorithm_CreateFunc', META)
	function bullet.CreateGImpactCollisionAlgorithm_CreateFunc(...)
		return lib.btGImpactCollisionAlgorithm_CreateFunc_new(...)
	end
end
do -- HeightfieldTerrainShape
	local META = {}
	META.__index = META
	function META:SetUseZigzagSubdivision(...)
		return lib.btHeightfieldTerrainShape_setUseZigzagSubdivision(self, ...)
	end
	function META:SetUseZigzagSubdivision2(...)
		return lib.btHeightfieldTerrainShape_setUseZigzagSubdivision2(self, ...)
	end
	function META:SetUseDiamondSubdivision(...)
		return lib.btHeightfieldTerrainShape_setUseDiamondSubdivision(self, ...)
	end
	function META:SetUseDiamondSubdivision2(...)
		return lib.btHeightfieldTerrainShape_setUseDiamondSubdivision2(self, ...)
	end
	ffi.metatype('btHeightfieldTerrainShape', META)
	function bullet.CreateHeightfieldTerrainShape2(...)
		return lib.btHeightfieldTerrainShape_new2(...)
	end
	function bullet.CreateHeightfieldTerrainShape(...)
		return lib.btHeightfieldTerrainShape_new(...)
	end
end
do -- SphereBoxCollisionAlgorithm_CreateFunc
	local META = {}
	META.__index = META
	ffi.metatype('btSphereBoxCollisionAlgorithm_CreateFunc', META)
	function bullet.CreateSphereBoxCollisionAlgorithm_CreateFunc(...)
		return lib.btSphereBoxCollisionAlgorithm_CreateFunc_new(...)
	end
end
do -- ConvexCast_CastResult
	local META = {}
	META.__index = META
	function META:GetHitTransformA(...)
		return lib.btConvexCast_CastResult_getHitTransformA(self, ...)
	end
	function META:SetHitPoint(...)
		return lib.btConvexCast_CastResult_setHitPoint(self, ...)
	end
	function META:GetHitTransformB(...)
		return lib.btConvexCast_CastResult_getHitTransformB(self, ...)
	end
	function META:GetFraction(...)
		return lib.btConvexCast_CastResult_getFraction(self, ...)
	end
	function META:ReportFailure(...)
		return lib.btConvexCast_CastResult_reportFailure(self, ...)
	end
	function META:GetAllowedPenetration(...)
		return lib.btConvexCast_CastResult_getAllowedPenetration(self, ...)
	end
	function META:GetHitPoint(...)
		return lib.btConvexCast_CastResult_getHitPoint(self, ...)
	end
	function META:GetDebugDrawer(...)
		return lib.btConvexCast_CastResult_getDebugDrawer(self, ...)
	end
	function META:SetAllowedPenetration(...)
		return lib.btConvexCast_CastResult_setAllowedPenetration(self, ...)
	end
	function META:SetHitTransformA(...)
		return lib.btConvexCast_CastResult_setHitTransformA(self, ...)
	end
	function META:SetHitTransformB(...)
		return lib.btConvexCast_CastResult_setHitTransformB(self, ...)
	end
	function META:Delete(...)
		return lib.btConvexCast_CastResult_delete(self, ...)
	end
	function META:SetNormal(...)
		return lib.btConvexCast_CastResult_setNormal(self, ...)
	end
	function META:GetNormal(...)
		return lib.btConvexCast_CastResult_getNormal(self, ...)
	end
	function META:SetFraction(...)
		return lib.btConvexCast_CastResult_setFraction(self, ...)
	end
	function META:SetDebugDrawer(...)
		return lib.btConvexCast_CastResult_setDebugDrawer(self, ...)
	end
	function META:DrawCoordSystem(...)
		return lib.btConvexCast_CastResult_drawCoordSystem(self, ...)
	end
	function META:DebugDraw(...)
		return lib.btConvexCast_CastResult_DebugDraw(self, ...)
	end
	ffi.metatype('btConvexCast_CastResult', META)
	function bullet.CreateConvexCast_CastResult(...)
		return lib.btConvexCast_CastResult_new(...)
	end
end
do -- ConvexInternalShape
	local META = {}
	META.__index = META
	function META:SetSafeMargin3(...)
		return lib.btConvexInternalShape_setSafeMargin3(self, ...)
	end
	function META:SetImplicitShapeDimensions(...)
		return lib.btConvexInternalShape_setImplicitShapeDimensions(self, ...)
	end
	function META:SetSafeMargin(...)
		return lib.btConvexInternalShape_setSafeMargin(self, ...)
	end
	function META:SetSafeMargin4(...)
		return lib.btConvexInternalShape_setSafeMargin4(self, ...)
	end
	function META:GetLocalScalingNV(...)
		return lib.btConvexInternalShape_getLocalScalingNV(self, ...)
	end
	function META:GetImplicitShapeDimensions(...)
		return lib.btConvexInternalShape_getImplicitShapeDimensions(self, ...)
	end
	function META:SetSafeMargin2(...)
		return lib.btConvexInternalShape_setSafeMargin2(self, ...)
	end
	function META:GetMarginNV(...)
		return lib.btConvexInternalShape_getMarginNV(self, ...)
	end
	ffi.metatype('btConvexInternalShape', META)
	function bullet.CreateConvexInternalShape(...)
		return lib.btConvexInternalShape_new(...)
	end
end
do -- RaycastVehicle_btVehicleTuning
	local META = {}
	META.__index = META
	function META:GetFrictionSlip(...)
		return lib.btRaycastVehicle_btVehicleTuning_getFrictionSlip(self, ...)
	end
	function META:GetMaxSuspensionTravelCm(...)
		return lib.btRaycastVehicle_btVehicleTuning_getMaxSuspensionTravelCm(self, ...)
	end
	function META:SetSuspensionDamping(...)
		return lib.btRaycastVehicle_btVehicleTuning_setSuspensionDamping(self, ...)
	end
	function META:GetSuspensionCompression(...)
		return lib.btRaycastVehicle_btVehicleTuning_getSuspensionCompression(self, ...)
	end
	function META:SetFrictionSlip(...)
		return lib.btRaycastVehicle_btVehicleTuning_setFrictionSlip(self, ...)
	end
	function META:SetMaxSuspensionTravelCm(...)
		return lib.btRaycastVehicle_btVehicleTuning_setMaxSuspensionTravelCm(self, ...)
	end
	function META:GetSuspensionDamping(...)
		return lib.btRaycastVehicle_btVehicleTuning_getSuspensionDamping(self, ...)
	end
	function META:SetSuspensionCompression(...)
		return lib.btRaycastVehicle_btVehicleTuning_setSuspensionCompression(self, ...)
	end
	function META:SetSuspensionStiffness(...)
		return lib.btRaycastVehicle_btVehicleTuning_setSuspensionStiffness(self, ...)
	end
	function META:Delete(...)
		return lib.btRaycastVehicle_btVehicleTuning_delete(self, ...)
	end
	function META:GetMaxSuspensionForce(...)
		return lib.btRaycastVehicle_btVehicleTuning_getMaxSuspensionForce(self, ...)
	end
	function META:GetSuspensionStiffness(...)
		return lib.btRaycastVehicle_btVehicleTuning_getSuspensionStiffness(self, ...)
	end
	function META:SetMaxSuspensionForce(...)
		return lib.btRaycastVehicle_btVehicleTuning_setMaxSuspensionForce(self, ...)
	end
	ffi.metatype('btRaycastVehicle_btVehicleTuning', META)
	function bullet.CreateRaycastVehicle_btVehicleTuning(...)
		return lib.btRaycastVehicle_btVehicleTuning_new(...)
	end
end
do -- SoftBodyWorldInfo
	local META = {}
	META.__index = META
	function META:SetBroadphase(...)
		return lib.btSoftBodyWorldInfo_setBroadphase(self, ...)
	end
	function META:GetMaxDisplacement(...)
		return lib.btSoftBodyWorldInfo_getMaxDisplacement(self, ...)
	end
	function META:GetDispatcher(...)
		return lib.btSoftBodyWorldInfo_getDispatcher(self, ...)
	end
	function META:Delete(...)
		return lib.btSoftBodyWorldInfo_delete(self, ...)
	end
	function META:SetMaxDisplacement(...)
		return lib.btSoftBodyWorldInfo_setMaxDisplacement(self, ...)
	end
	function META:SetDispatcher(...)
		return lib.btSoftBodyWorldInfo_setDispatcher(self, ...)
	end
	function META:GetGravity(...)
		return lib.btSoftBodyWorldInfo_getGravity(self, ...)
	end
	function META:GetBroadphase(...)
		return lib.btSoftBodyWorldInfo_getBroadphase(self, ...)
	end
	function META:GetSparsesdf(...)
		return lib.btSoftBodyWorldInfo_getSparsesdf(self, ...)
	end
	function META:SetGravity(...)
		return lib.btSoftBodyWorldInfo_setGravity(self, ...)
	end
	ffi.metatype('btSoftBodyWorldInfo', META)
	function bullet.CreateSoftBodyWorldInfo(...)
		return lib.btSoftBodyWorldInfo_new(...)
	end
end
do -- CollisionWorld_ClosestConvexResultCallback
	local META = {}
	META.__index = META
	function META:GetHitCollisionObject(...)
		return lib.btCollisionWorld_ClosestConvexResultCallback_getHitCollisionObject(self, ...)
	end
	function META:SetHitPointWorld(...)
		return lib.btCollisionWorld_ClosestConvexResultCallback_setHitPointWorld(self, ...)
	end
	function META:SetHitCollisionObject(...)
		return lib.btCollisionWorld_ClosestConvexResultCallback_setHitCollisionObject(self, ...)
	end
	function META:GetHitNormalWorld(...)
		return lib.btCollisionWorld_ClosestConvexResultCallback_getHitNormalWorld(self, ...)
	end
	function META:GetHitPointWorld(...)
		return lib.btCollisionWorld_ClosestConvexResultCallback_getHitPointWorld(self, ...)
	end
	function META:SetConvexToWorld(...)
		return lib.btCollisionWorld_ClosestConvexResultCallback_setConvexToWorld(self, ...)
	end
	function META:GetConvexFromWorld(...)
		return lib.btCollisionWorld_ClosestConvexResultCallback_getConvexFromWorld(self, ...)
	end
	function META:GetConvexToWorld(...)
		return lib.btCollisionWorld_ClosestConvexResultCallback_getConvexToWorld(self, ...)
	end
	function META:SetHitNormalWorld(...)
		return lib.btCollisionWorld_ClosestConvexResultCallback_setHitNormalWorld(self, ...)
	end
	function META:SetConvexFromWorld(...)
		return lib.btCollisionWorld_ClosestConvexResultCallback_setConvexFromWorld(self, ...)
	end
	ffi.metatype('btCollisionWorld_ClosestConvexResultCallback', META)
	function bullet.CreateCollisionWorld_ClosestConvexResultCallback(...)
		return lib.btCollisionWorld_ClosestConvexResultCallback_new(...)
	end
end
do -- TriangleMesh
	local META = {}
	META.__index = META
	function META:GetUse4componentVertices(...)
		return lib.btTriangleMesh_getUse4componentVertices(self, ...)
	end
	function META:AddTriangle(...)
		return lib.btTriangleMesh_addTriangle(self, ...)
	end
	function META:FindOrAddVertex(...)
		return lib.btTriangleMesh_findOrAddVertex(self, ...)
	end
	function META:GetNumTriangles(...)
		return lib.btTriangleMesh_getNumTriangles(self, ...)
	end
	function META:SetWeldingThreshold(...)
		return lib.btTriangleMesh_setWeldingThreshold(self, ...)
	end
	function META:AddTriangle2(...)
		return lib.btTriangleMesh_addTriangle2(self, ...)
	end
	function META:GetUse32bitIndices(...)
		return lib.btTriangleMesh_getUse32bitIndices(self, ...)
	end
	function META:AddIndex(...)
		return lib.btTriangleMesh_addIndex(self, ...)
	end
	function META:GetWeldingThreshold(...)
		return lib.btTriangleMesh_getWeldingThreshold(self, ...)
	end
	ffi.metatype('btTriangleMesh', META)
	function bullet.CreateTriangleMesh2(...)
		return lib.btTriangleMesh_new2(...)
	end
	function bullet.CreateTriangleMesh3(...)
		return lib.btTriangleMesh_new3(...)
	end
	function bullet.CreateTriangleMesh(...)
		return lib.btTriangleMesh_new(...)
	end
end
do -- GjkPairDetector
	local META = {}
	META.__index = META
	function META:GetLastUsedMethod(...)
		return lib.btGjkPairDetector_getLastUsedMethod(self, ...)
	end
	function META:GetClosestPointsNonVirtual(...)
		return lib.btGjkPairDetector_getClosestPointsNonVirtual(self, ...)
	end
	function META:SetMinkowskiA(...)
		return lib.btGjkPairDetector_setMinkowskiA(self, ...)
	end
	function META:GetCurIter(...)
		return lib.btGjkPairDetector_getCurIter(self, ...)
	end
	function META:SetIgnoreMargin(...)
		return lib.btGjkPairDetector_setIgnoreMargin(self, ...)
	end
	function META:SetCurIter(...)
		return lib.btGjkPairDetector_setCurIter(self, ...)
	end
	function META:SetLastUsedMethod(...)
		return lib.btGjkPairDetector_setLastUsedMethod(self, ...)
	end
	function META:GetCachedSeparatingAxis(...)
		return lib.btGjkPairDetector_getCachedSeparatingAxis(self, ...)
	end
	function META:GetFixContactNormalDirection(...)
		return lib.btGjkPairDetector_getFixContactNormalDirection(self, ...)
	end
	function META:GetCachedSeparatingDistance(...)
		return lib.btGjkPairDetector_getCachedSeparatingDistance(self, ...)
	end
	function META:SetMinkowskiB(...)
		return lib.btGjkPairDetector_setMinkowskiB(self, ...)
	end
	function META:SetFixContactNormalDirection(...)
		return lib.btGjkPairDetector_setFixContactNormalDirection(self, ...)
	end
	function META:SetPenetrationDepthSolver(...)
		return lib.btGjkPairDetector_setPenetrationDepthSolver(self, ...)
	end
	function META:GetCatchDegeneracies(...)
		return lib.btGjkPairDetector_getCatchDegeneracies(self, ...)
	end
	function META:SetCachedSeparatingAxis(...)
		return lib.btGjkPairDetector_setCachedSeparatingAxis(self, ...)
	end
	function META:SetCatchDegeneracies(...)
		return lib.btGjkPairDetector_setCatchDegeneracies(self, ...)
	end
	function META:GetDegenerateSimplex(...)
		return lib.btGjkPairDetector_getDegenerateSimplex(self, ...)
	end
	function META:SetDegenerateSimplex(...)
		return lib.btGjkPairDetector_setDegenerateSimplex(self, ...)
	end
	ffi.metatype('btGjkPairDetector', META)
	function bullet.CreateGjkPairDetector2(...)
		return lib.btGjkPairDetector_new2(...)
	end
	function bullet.CreateGjkPairDetector(...)
		return lib.btGjkPairDetector_new(...)
	end
end
do -- BroadphaseRayCallbackWrapper
	local META = {}
	META.__index = META
	ffi.metatype('btBroadphaseRayCallbackWrapper', META)
	function bullet.CreateBroadphaseRayCallbackWrapper(...)
		return lib.btBroadphaseRayCallbackWrapper_new(...)
	end
end
do -- TriangleIndexVertexArray
	local META = {}
	META.__index = META
	function META:AddIndexedMesh2(...)
		return lib.btTriangleIndexVertexArray_addIndexedMesh2(self, ...)
	end
	function META:GetIndexedMeshArray(...)
		return lib.btTriangleIndexVertexArray_getIndexedMeshArray(self, ...)
	end
	function META:AddIndexedMesh(...)
		return lib.btTriangleIndexVertexArray_addIndexedMesh(self, ...)
	end
	ffi.metatype('btTriangleIndexVertexArray', META)
	function bullet.CreateTriangleIndexVertexArray(...)
		return lib.btTriangleIndexVertexArray_new(...)
	end
	function bullet.CreateTriangleIndexVertexArray2(...)
		return lib.btTriangleIndexVertexArray_new2(...)
	end
end
do -- BroadphasePair
	local META = {}
	META.__index = META
	function META:SetPProxy1(...)
		return lib.btBroadphasePair_setPProxy1(self, ...)
	end
	function META:GetAlgorithm(...)
		return lib.btBroadphasePair_getAlgorithm(self, ...)
	end
	function META:GetPProxy0(...)
		return lib.btBroadphasePair_getPProxy0(self, ...)
	end
	function META:GetPProxy1(...)
		return lib.btBroadphasePair_getPProxy1(self, ...)
	end
	function META:SetPProxy0(...)
		return lib.btBroadphasePair_setPProxy0(self, ...)
	end
	function META:SetAlgorithm(...)
		return lib.btBroadphasePair_setAlgorithm(self, ...)
	end
	function META:Delete(...)
		return lib.btBroadphasePair_delete(self, ...)
	end
	ffi.metatype('btBroadphasePair', META)
	function bullet.CreateBroadphasePair3(...)
		return lib.btBroadphasePair_new3(...)
	end
	function bullet.CreateBroadphasePair(...)
		return lib.btBroadphasePair_new(...)
	end
	function bullet.CreateBroadphasePair2(...)
		return lib.btBroadphasePair_new2(...)
	end
end
do -- MinkowskiSumShape
	local META = {}
	META.__index = META
	function META:GetShapeA(...)
		return lib.btMinkowskiSumShape_getShapeA(self, ...)
	end
	function META:SetTransformB(...)
		return lib.btMinkowskiSumShape_setTransformB(self, ...)
	end
	function META:GetShapeB(...)
		return lib.btMinkowskiSumShape_getShapeB(self, ...)
	end
	function META:SetTransformA(...)
		return lib.btMinkowskiSumShape_setTransformA(self, ...)
	end
	function META:GetTransformB(...)
		return lib.btMinkowskiSumShape_GetTransformB(self, ...)
	end
	function META:GetTransformA(...)
		return lib.btMinkowskiSumShape_getTransformA(self, ...)
	end
	ffi.metatype('btMinkowskiSumShape', META)
	function bullet.CreateMinkowskiSumShape(...)
		return lib.btMinkowskiSumShape_new(...)
	end
end
do -- TriangleCallbackWrapper
	local META = {}
	META.__index = META
	ffi.metatype('btTriangleCallbackWrapper', META)
	function bullet.CreateTriangleCallbackWrapper(...)
		return lib.btTriangleCallbackWrapper_new(...)
	end
end
do -- Triangle
	local META = {}
	META.__index = META
	function META:GetVertex2(...)
		return lib.btTriangle_getVertex2(self, ...)
	end
	function META:SetVertex1(...)
		return lib.btTriangle_setVertex1(self, ...)
	end
	function META:GetVertex0(...)
		return lib.btTriangle_getVertex0(self, ...)
	end
	function META:SetPartId(...)
		return lib.btTriangle_setPartId(self, ...)
	end
	function META:SetVertex0(...)
		return lib.btTriangle_setVertex0(self, ...)
	end
	function META:SetTriangleIndex(...)
		return lib.btTriangle_setTriangleIndex(self, ...)
	end
	function META:GetPartId(...)
		return lib.btTriangle_getPartId(self, ...)
	end
	function META:SetVertex2(...)
		return lib.btTriangle_setVertex2(self, ...)
	end
	function META:Delete(...)
		return lib.btTriangle_delete(self, ...)
	end
	function META:GetVertex1(...)
		return lib.btTriangle_getVertex1(self, ...)
	end
	function META:GetTriangleIndex(...)
		return lib.btTriangle_getTriangleIndex(self, ...)
	end
	ffi.metatype('btTriangle', META)
	function bullet.CreateTriangle(...)
		return lib.btTriangle_new(...)
	end
end
do -- SoftBodyConcaveCollisionAlgorithm_CreateFunc
	local META = {}
	META.__index = META
	ffi.metatype('btSoftBodyConcaveCollisionAlgorithm_CreateFunc', META)
	function bullet.CreateSoftBodyConcaveCollisionAlgorithm_CreateFunc(...)
		return lib.btSoftBodyConcaveCollisionAlgorithm_CreateFunc_new(...)
	end
end
do -- CylinderShapeX
	local META = {}
	META.__index = META
	ffi.metatype('btCylinderShapeX', META)
	function bullet.CreateCylinderShapeX(...)
		return lib.btCylinderShapeX_new(...)
	end
	function bullet.CreateCylinderShapeX2(...)
		return lib.btCylinderShapeX_new2(...)
	end
end
do -- SphereShape
	local META = {}
	META.__index = META
	function META:GetRadius(...)
		return lib.btSphereShape_getRadius(self, ...)
	end
	function META:SetUnscaledRadius(...)
		return lib.btSphereShape_setUnscaledRadius(self, ...)
	end
	ffi.metatype('btSphereShape', META)
	function bullet.CreateSphereShape(...)
		return lib.btSphereShape_new(...)
	end
end
do -- CylinderShape
	local META = {}
	META.__index = META
	function META:GetUpAxis(...)
		return lib.btCylinderShape_getUpAxis(self, ...)
	end
	function META:GetRadius(...)
		return lib.btCylinderShape_getRadius(self, ...)
	end
	function META:GetHalfExtentsWithMargin(...)
		return lib.btCylinderShape_getHalfExtentsWithMargin(self, ...)
	end
	function META:GetHalfExtentsWithoutMargin(...)
		return lib.btCylinderShape_getHalfExtentsWithoutMargin(self, ...)
	end
	ffi.metatype('btCylinderShape', META)
	function bullet.CreateCylinderShape2(...)
		return lib.btCylinderShape_new2(...)
	end
	function bullet.CreateCylinderShape(...)
		return lib.btCylinderShape_new(...)
	end
end
do -- TriIndex
	local META = {}
	META.__index = META
	function META:Delete(...)
		return lib.btTriIndex_delete(self, ...)
	end
	function META:GetPartId(...)
		return lib.btTriIndex_getPartId(self, ...)
	end
	function META:SetPartIdTriangleIndex(...)
		return lib.btTriIndex_setPartIdTriangleIndex(self, ...)
	end
	function META:GetUid(...)
		return lib.btTriIndex_getUid(self, ...)
	end
	function META:SetChildShape(...)
		return lib.btTriIndex_setChildShape(self, ...)
	end
	function META:GetTriangleIndex(...)
		return lib.btTriIndex_getTriangleIndex(self, ...)
	end
	function META:GetChildShape(...)
		return lib.btTriIndex_getChildShape(self, ...)
	end
	function META:GetPartIdTriangleIndex(...)
		return lib.btTriIndex_getPartIdTriangleIndex(self, ...)
	end
	ffi.metatype('btTriIndex', META)
	function bullet.CreateTriIndex(...)
		return lib.btTriIndex_new(...)
	end
end
do -- Element
	local META = {}
	META.__index = META
	function META:GetSz(...)
		return lib.btElement_getSz(self, ...)
	end
	function META:GetId(...)
		return lib.btElement_getId(self, ...)
	end
	function META:SetSz(...)
		return lib.btElement_setSz(self, ...)
	end
	function META:SetId(...)
		return lib.btElement_setId(self, ...)
	end
	function META:Delete(...)
		return lib.btElement_delete(self, ...)
	end
	ffi.metatype('btElement', META)
	function bullet.CreateElement(...)
		return lib.btElement_new(...)
	end
end
do -- WheelInfo_RaycastInfo
	local META = {}
	META.__index = META
	function META:SetContactNormalWS(...)
		return lib.btWheelInfo_RaycastInfo_setContactNormalWS(self, ...)
	end
	function META:GetContactPointWS(...)
		return lib.btWheelInfo_RaycastInfo_getContactPointWS(self, ...)
	end
	function META:SetGroundObject(...)
		return lib.btWheelInfo_RaycastInfo_setGroundObject(self, ...)
	end
	function META:Delete(...)
		return lib.btWheelInfo_RaycastInfo_delete(self, ...)
	end
	function META:SetSuspensionLength(...)
		return lib.btWheelInfo_RaycastInfo_setSuspensionLength(self, ...)
	end
	function META:GetIsInContact(...)
		return lib.btWheelInfo_RaycastInfo_getIsInContact(self, ...)
	end
	function META:SetWheelDirectionWS(...)
		return lib.btWheelInfo_RaycastInfo_setWheelDirectionWS(self, ...)
	end
	function META:SetWheelAxleWS(...)
		return lib.btWheelInfo_RaycastInfo_setWheelAxleWS(self, ...)
	end
	function META:GetWheelAxleWS(...)
		return lib.btWheelInfo_RaycastInfo_getWheelAxleWS(self, ...)
	end
	function META:SetContactPointWS(...)
		return lib.btWheelInfo_RaycastInfo_setContactPointWS(self, ...)
	end
	function META:SetHardPointWS(...)
		return lib.btWheelInfo_RaycastInfo_setHardPointWS(self, ...)
	end
	function META:GetGroundObject(...)
		return lib.btWheelInfo_RaycastInfo_getGroundObject(self, ...)
	end
	function META:GetHardPointWS(...)
		return lib.btWheelInfo_RaycastInfo_getHardPointWS(self, ...)
	end
	function META:GetSuspensionLength(...)
		return lib.btWheelInfo_RaycastInfo_getSuspensionLength(self, ...)
	end
	function META:SetIsInContact(...)
		return lib.btWheelInfo_RaycastInfo_setIsInContact(self, ...)
	end
	function META:GetContactNormalWS(...)
		return lib.btWheelInfo_RaycastInfo_getContactNormalWS(self, ...)
	end
	function META:GetWheelDirectionWS(...)
		return lib.btWheelInfo_RaycastInfo_getWheelDirectionWS(self, ...)
	end
	ffi.metatype('btWheelInfo_RaycastInfo', META)
	function bullet.CreateWheelInfo_RaycastInfo(...)
		return lib.btWheelInfo_RaycastInfo_new(...)
	end
end
do -- IndexedMesh
	local META = {}
	META.__index = META
	function META:SetNumTriangles(...)
		return lib.btIndexedMesh_setNumTriangles(self, ...)
	end
	function META:GetTriangleIndexBase(...)
		return lib.btIndexedMesh_getTriangleIndexBase(self, ...)
	end
	function META:Delete(...)
		return lib.btIndexedMesh_delete(self, ...)
	end
	function META:GetTriangleIndexStride(...)
		return lib.btIndexedMesh_getTriangleIndexStride(self, ...)
	end
	function META:SetVertexType(...)
		return lib.btIndexedMesh_setVertexType(self, ...)
	end
	function META:GetVertexBase(...)
		return lib.btIndexedMesh_getVertexBase(self, ...)
	end
	function META:SetVertexBase(...)
		return lib.btIndexedMesh_setVertexBase(self, ...)
	end
	function META:GetVertexType(...)
		return lib.btIndexedMesh_getVertexType(self, ...)
	end
	function META:GetNumVertices(...)
		return lib.btIndexedMesh_getNumVertices(self, ...)
	end
	function META:GetIndexType(...)
		return lib.btIndexedMesh_getIndexType(self, ...)
	end
	function META:GetNumTriangles(...)
		return lib.btIndexedMesh_getNumTriangles(self, ...)
	end
	function META:GetVertexStride(...)
		return lib.btIndexedMesh_getVertexStride(self, ...)
	end
	function META:SetIndexType(...)
		return lib.btIndexedMesh_setIndexType(self, ...)
	end
	function META:SetVertexStride(...)
		return lib.btIndexedMesh_setVertexStride(self, ...)
	end
	function META:SetNumVertices(...)
		return lib.btIndexedMesh_setNumVertices(self, ...)
	end
	function META:SetTriangleIndexStride(...)
		return lib.btIndexedMesh_setTriangleIndexStride(self, ...)
	end
	function META:SetTriangleIndexBase(...)
		return lib.btIndexedMesh_setTriangleIndexBase(self, ...)
	end
	ffi.metatype('btIndexedMesh', META)
	function bullet.CreateIndexedMesh(...)
		return lib.btIndexedMesh_new(...)
	end
end
do -- CylinderShapeZ
	local META = {}
	META.__index = META
	ffi.metatype('btCylinderShapeZ', META)
	function bullet.CreateCylinderShapeZ(...)
		return lib.btCylinderShapeZ_new(...)
	end
	function bullet.CreateCylinderShapeZ2(...)
		return lib.btCylinderShapeZ_new2(...)
	end
end
do -- ConvexConvexAlgorithm
	local META = {}
	META.__index = META
	function META:GetManifold(...)
		return lib.btConvexConvexAlgorithm_getManifold(self, ...)
	end
	function META:SetLowLevelOfDetail(...)
		return lib.btConvexConvexAlgorithm_setLowLevelOfDetail(self, ...)
	end
	ffi.metatype('btConvexConvexAlgorithm', META)
	function bullet.CreateConvexConvexAlgorithm(...)
		return lib.btConvexConvexAlgorithm_new(...)
	end
end
do -- ConvexTriangleCallback
	local META = {}
	META.__index = META
	function META:GetTriangleCount(...)
		return lib.btConvexTriangleCallback_getTriangleCount(self, ...)
	end
	function META:ClearWrapperData(...)
		return lib.btConvexTriangleCallback_clearWrapperData(self, ...)
	end
	function META:SetTriangleCount(...)
		return lib.btConvexTriangleCallback_setTriangleCount(self, ...)
	end
	function META:GetAabbMax(...)
		return lib.btConvexTriangleCallback_getAabbMax(self, ...)
	end
	function META:SetManifoldPtr(...)
		return lib.btConvexTriangleCallback_setManifoldPtr(self, ...)
	end
	function META:SetTimeStepAndCounters(...)
		return lib.btConvexTriangleCallback_setTimeStepAndCounters(self, ...)
	end
	function META:GetAabbMin(...)
		return lib.btConvexTriangleCallback_getAabbMin(self, ...)
	end
	function META:GetManifoldPtr(...)
		return lib.btConvexTriangleCallback_getManifoldPtr(self, ...)
	end
	function META:ClearCache(...)
		return lib.btConvexTriangleCallback_clearCache(self, ...)
	end
	ffi.metatype('btConvexTriangleCallback', META)
	function bullet.CreateConvexTriangleCallback(...)
		return lib.btConvexTriangleCallback_new(...)
	end
end
do -- SoftBody_Node
	local META = {}
	META.__index = META
	function META:SetBattach(...)
		return lib.btSoftBody_Node_setBattach(self, ...)
	end
	function META:GetX(...)
		return lib.btSoftBody_Node_getX(self, ...)
	end
	function META:GetN(...)
		return lib.btSoftBody_Node_getN(self, ...)
	end
	function META:SetV(...)
		return lib.btSoftBody_Node_setV(self, ...)
	end
	function META:SetX(...)
		return lib.btSoftBody_Node_setX(self, ...)
	end
	function META:SetN(...)
		return lib.btSoftBody_Node_setN(self, ...)
	end
	function META:SetQ(...)
		return lib.btSoftBody_Node_setQ(self, ...)
	end
	function META:GetV(...)
		return lib.btSoftBody_Node_getV(self, ...)
	end
	function META:GetLeaf(...)
		return lib.btSoftBody_Node_getLeaf(self, ...)
	end
	function META:GetArea(...)
		return lib.btSoftBody_Node_getArea(self, ...)
	end
	function META:GetQ(...)
		return lib.btSoftBody_Node_getQ(self, ...)
	end
	function META:GetF(...)
		return lib.btSoftBody_Node_getF(self, ...)
	end
	function META:GetIm(...)
		return lib.btSoftBody_Node_getIm(self, ...)
	end
	function META:SetArea(...)
		return lib.btSoftBody_Node_setArea(self, ...)
	end
	function META:SetF(...)
		return lib.btSoftBody_Node_setF(self, ...)
	end
	function META:GetBattach(...)
		return lib.btSoftBody_Node_getBattach(self, ...)
	end
	function META:SetIm(...)
		return lib.btSoftBody_Node_setIm(self, ...)
	end
	function META:SetLeaf(...)
		return lib.btSoftBody_Node_setLeaf(self, ...)
	end
	ffi.metatype('btSoftBody_Node', META)
	function bullet.CreateSoftBody_Node(...)
		return lib.btSoftBody_Node_new(...)
	end
end
do -- TriangleShape
	local META = {}
	META.__index = META
	function META:GetVertexPtr(...)
		return lib.btTriangleShape_getVertexPtr(self, ...)
	end
	function META:CalcNormal(...)
		return lib.btTriangleShape_calcNormal(self, ...)
	end
	function META:GetPlaneEquation(...)
		return lib.btTriangleShape_getPlaneEquation(self, ...)
	end
	function META:GetVertices1(...)
		return lib.btTriangleShape_getVertices1(self, ...)
	end
	ffi.metatype('btTriangleShape', META)
	function bullet.CreateTriangleShape(...)
		return lib.btTriangleShape_new(...)
	end
	function bullet.CreateTriangleShape2(...)
		return lib.btTriangleShape_new2(...)
	end
end
do -- GjkConvexCast
	local META = {}
	META.__index = META
	ffi.metatype('btGjkConvexCast', META)
	function bullet.CreateGjkConvexCast(...)
		return lib.btGjkConvexCast_new(...)
	end
end
do -- ActionInterfaceWrapper
	local META = {}
	META.__index = META
	ffi.metatype('btActionInterfaceWrapper', META)
	function bullet.CreateActionInterfaceWrapper(...)
		return lib.btActionInterfaceWrapper_new(...)
	end
end
do -- SphereSphereCollisionAlgorithm_CreateFunc
	local META = {}
	META.__index = META
	ffi.metatype('btSphereSphereCollisionAlgorithm_CreateFunc', META)
	function bullet.CreateSphereSphereCollisionAlgorithm_CreateFunc(...)
		return lib.btSphereSphereCollisionAlgorithm_CreateFunc_new(...)
	end
end
do -- TranslationalLimitMotor
	local META = {}
	META.__index = META
	function META:SetTargetVelocity(...)
		return lib.btTranslationalLimitMotor_setTargetVelocity(self, ...)
	end
	function META:GetAccumulatedImpulse(...)
		return lib.btTranslationalLimitMotor_getAccumulatedImpulse(self, ...)
	end
	function META:SetLowerLimit(...)
		return lib.btTranslationalLimitMotor_setLowerLimit(self, ...)
	end
	function META:GetCurrentLimit(...)
		return lib.btTranslationalLimitMotor_getCurrentLimit(self, ...)
	end
	function META:SetLimitSoftness(...)
		return lib.btTranslationalLimitMotor_setLimitSoftness(self, ...)
	end
	function META:SetRestitution(...)
		return lib.btTranslationalLimitMotor_setRestitution(self, ...)
	end
	function META:GetMaxMotorForce(...)
		return lib.btTranslationalLimitMotor_getMaxMotorForce(self, ...)
	end
	function META:GetLimitSoftness(...)
		return lib.btTranslationalLimitMotor_getLimitSoftness(self, ...)
	end
	function META:SetNormalCFM(...)
		return lib.btTranslationalLimitMotor_setNormalCFM(self, ...)
	end
	function META:GetDamping(...)
		return lib.btTranslationalLimitMotor_getDamping(self, ...)
	end
	function META:IsLimited(...)
		return lib.btTranslationalLimitMotor_isLimited(self, ...)
	end
	function META:SetStopCFM(...)
		return lib.btTranslationalLimitMotor_setStopCFM(self, ...)
	end
	function META:SetDamping(...)
		return lib.btTranslationalLimitMotor_setDamping(self, ...)
	end
	function META:GetCurrentLinearDiff(...)
		return lib.btTranslationalLimitMotor_getCurrentLinearDiff(self, ...)
	end
	function META:GetTargetVelocity(...)
		return lib.btTranslationalLimitMotor_getTargetVelocity(self, ...)
	end
	function META:GetUpperLimit(...)
		return lib.btTranslationalLimitMotor_getUpperLimit(self, ...)
	end
	function META:GetEnableMotor(...)
		return lib.btTranslationalLimitMotor_getEnableMotor(self, ...)
	end
	function META:GetStopERP(...)
		return lib.btTranslationalLimitMotor_getStopERP(self, ...)
	end
	function META:NeedApplyForce(...)
		return lib.btTranslationalLimitMotor_needApplyForce(self, ...)
	end
	function META:GetCurrentLimitError(...)
		return lib.btTranslationalLimitMotor_getCurrentLimitError(self, ...)
	end
	function META:GetStopCFM(...)
		return lib.btTranslationalLimitMotor_getStopCFM(self, ...)
	end
	function META:Delete(...)
		return lib.btTranslationalLimitMotor_delete(self, ...)
	end
	function META:GetLowerLimit(...)
		return lib.btTranslationalLimitMotor_getLowerLimit(self, ...)
	end
	function META:GetRestitution(...)
		return lib.btTranslationalLimitMotor_getRestitution(self, ...)
	end
	function META:SetAccumulatedImpulse(...)
		return lib.btTranslationalLimitMotor_setAccumulatedImpulse(self, ...)
	end
	function META:GetNormalCFM(...)
		return lib.btTranslationalLimitMotor_getNormalCFM(self, ...)
	end
	function META:SetUpperLimit(...)
		return lib.btTranslationalLimitMotor_setUpperLimit(self, ...)
	end
	function META:SetMaxMotorForce(...)
		return lib.btTranslationalLimitMotor_setMaxMotorForce(self, ...)
	end
	function META:TestLimitValue(...)
		return lib.btTranslationalLimitMotor_testLimitValue(self, ...)
	end
	function META:SetCurrentLinearDiff(...)
		return lib.btTranslationalLimitMotor_setCurrentLinearDiff(self, ...)
	end
	function META:SolveLinearAxis(...)
		return lib.btTranslationalLimitMotor_solveLinearAxis(self, ...)
	end
	function META:SetCurrentLimitError(...)
		return lib.btTranslationalLimitMotor_setCurrentLimitError(self, ...)
	end
	function META:SetStopERP(...)
		return lib.btTranslationalLimitMotor_setStopERP(self, ...)
	end
	ffi.metatype('btTranslationalLimitMotor', META)
	function bullet.CreateTranslationalLimitMotor(...)
		return lib.btTranslationalLimitMotor_new(...)
	end
	function bullet.CreateTranslationalLimitMotor2(...)
		return lib.btTranslationalLimitMotor_new2(...)
	end
end
do -- SoftBody_sCti
	local META = {}
	META.__index = META
	function META:GetNormal(...)
		return lib.btSoftBody_sCti_getNormal(self, ...)
	end
	function META:GetOffset(...)
		return lib.btSoftBody_sCti_getOffset(self, ...)
	end
	function META:SetNormal(...)
		return lib.btSoftBody_sCti_setNormal(self, ...)
	end
	function META:GetColObj(...)
		return lib.btSoftBody_sCti_getColObj(self, ...)
	end
	function META:SetColObj(...)
		return lib.btSoftBody_sCti_setColObj(self, ...)
	end
	function META:SetOffset(...)
		return lib.btSoftBody_sCti_setOffset(self, ...)
	end
	function META:Delete(...)
		return lib.btSoftBody_sCti_delete(self, ...)
	end
	ffi.metatype('btSoftBody_sCti', META)
	function bullet.CreateSoftBody_sCti(...)
		return lib.btSoftBody_sCti_new(...)
	end
end
do -- MultiBodyJointLimitConstraint
	local META = {}
	META.__index = META
	ffi.metatype('btMultiBodyJointLimitConstraint', META)
	function bullet.CreateMultiBodyJointLimitConstraint(...)
		return lib.btMultiBodyJointLimitConstraint_new(...)
	end
end
do -- TypedConstraint_btConstraintInfo2
	local META = {}
	META.__index = META
	function META:GetJ1angularAxis(...)
		return lib.btTypedConstraint_btConstraintInfo2_getJ1angularAxis(self, ...)
	end
	function META:GetErp(...)
		return lib.btTypedConstraint_btConstraintInfo2_getErp(self, ...)
	end
	function META:GetRowskip(...)
		return lib.btTypedConstraint_btConstraintInfo2_getRowskip(self, ...)
	end
	function META:GetNumIterations(...)
		return lib.btTypedConstraint_btConstraintInfo2_getNumIterations(self, ...)
	end
	function META:GetUpperLimit(...)
		return lib.btTypedConstraint_btConstraintInfo2_getUpperLimit(self, ...)
	end
	function META:SetRowskip(...)
		return lib.btTypedConstraint_btConstraintInfo2_setRowskip(self, ...)
	end
	function META:SetNumIterations(...)
		return lib.btTypedConstraint_btConstraintInfo2_setNumIterations(self, ...)
	end
	function META:GetConstraintError(...)
		return lib.btTypedConstraint_btConstraintInfo2_getConstraintError(self, ...)
	end
	function META:Delete(...)
		return lib.btTypedConstraint_btConstraintInfo2_delete(self, ...)
	end
	function META:SetUpperLimit(...)
		return lib.btTypedConstraint_btConstraintInfo2_setUpperLimit(self, ...)
	end
	function META:GetFindex(...)
		return lib.btTypedConstraint_btConstraintInfo2_getFindex(self, ...)
	end
	function META:SetLowerLimit(...)
		return lib.btTypedConstraint_btConstraintInfo2_setLowerLimit(self, ...)
	end
	function META:SetJ2angularAxis(...)
		return lib.btTypedConstraint_btConstraintInfo2_setJ2angularAxis(self, ...)
	end
	function META:SetJ2linearAxis(...)
		return lib.btTypedConstraint_btConstraintInfo2_setJ2linearAxis(self, ...)
	end
	function META:GetFps(...)
		return lib.btTypedConstraint_btConstraintInfo2_getFps(self, ...)
	end
	function META:GetCfm(...)
		return lib.btTypedConstraint_btConstraintInfo2_getCfm(self, ...)
	end
	function META:SetJ1linearAxis(...)
		return lib.btTypedConstraint_btConstraintInfo2_setJ1linearAxis(self, ...)
	end
	function META:GetJ2linearAxis(...)
		return lib.btTypedConstraint_btConstraintInfo2_getJ2linearAxis(self, ...)
	end
	function META:GetDamping(...)
		return lib.btTypedConstraint_btConstraintInfo2_getDamping(self, ...)
	end
	function META:SetFps(...)
		return lib.btTypedConstraint_btConstraintInfo2_setFps(self, ...)
	end
	function META:GetJ1linearAxis(...)
		return lib.btTypedConstraint_btConstraintInfo2_getJ1linearAxis(self, ...)
	end
	function META:SetFindex(...)
		return lib.btTypedConstraint_btConstraintInfo2_setFindex(self, ...)
	end
	function META:GetLowerLimit(...)
		return lib.btTypedConstraint_btConstraintInfo2_getLowerLimit(self, ...)
	end
	function META:SetErp(...)
		return lib.btTypedConstraint_btConstraintInfo2_setErp(self, ...)
	end
	function META:SetDamping(...)
		return lib.btTypedConstraint_btConstraintInfo2_setDamping(self, ...)
	end
	function META:SetJ1angularAxis(...)
		return lib.btTypedConstraint_btConstraintInfo2_setJ1angularAxis(self, ...)
	end
	function META:SetConstraintError(...)
		return lib.btTypedConstraint_btConstraintInfo2_setConstraintError(self, ...)
	end
	function META:GetJ2angularAxis(...)
		return lib.btTypedConstraint_btConstraintInfo2_getJ2angularAxis(self, ...)
	end
	function META:SetCfm(...)
		return lib.btTypedConstraint_btConstraintInfo2_setCfm(self, ...)
	end
	ffi.metatype('btTypedConstraint_btConstraintInfo2', META)
	function bullet.CreateTypedConstraint_btConstraintInfo22(...)
		return lib.btTypedConstraint_btConstraintInfo2_new(...)
	end
end
do -- NNCGConstraintSolver
	local META = {}
	META.__index = META
	function META:SetOnlyForNoneContact(...)
		return lib.btNNCGConstraintSolver_setOnlyForNoneContact(self, ...)
	end
	function META:GetOnlyForNoneContact(...)
		return lib.btNNCGConstraintSolver_getOnlyForNoneContact(self, ...)
	end
	ffi.metatype('btNNCGConstraintSolver', META)
	function bullet.CreateNNCGConstraintSolver(...)
		return lib.btNNCGConstraintSolver_new(...)
	end
end
do -- MaterialProperties
	local META = {}
	META.__index = META
	function META:SetMaterialType(...)
		return lib.btMaterialProperties_setMaterialType(self, ...)
	end
	function META:SetTriangleMaterialsBase(...)
		return lib.btMaterialProperties_setTriangleMaterialsBase(self, ...)
	end
	function META:SetNumTriangles(...)
		return lib.btMaterialProperties_setNumTriangles(self, ...)
	end
	function META:SetMaterialStride(...)
		return lib.btMaterialProperties_setMaterialStride(self, ...)
	end
	function META:Delete(...)
		return lib.btMaterialProperties_delete(self, ...)
	end
	function META:GetTriangleMaterialStride(...)
		return lib.btMaterialProperties_getTriangleMaterialStride(self, ...)
	end
	function META:GetTriangleMaterialsBase(...)
		return lib.btMaterialProperties_getTriangleMaterialsBase(self, ...)
	end
	function META:GetNumMaterials(...)
		return lib.btMaterialProperties_getNumMaterials(self, ...)
	end
	function META:GetTriangleType(...)
		return lib.btMaterialProperties_getTriangleType(self, ...)
	end
	function META:SetMaterialBase(...)
		return lib.btMaterialProperties_setMaterialBase(self, ...)
	end
	function META:GetMaterialType(...)
		return lib.btMaterialProperties_getMaterialType(self, ...)
	end
	function META:SetTriangleType(...)
		return lib.btMaterialProperties_setTriangleType(self, ...)
	end
	function META:GetNumTriangles(...)
		return lib.btMaterialProperties_getNumTriangles(self, ...)
	end
	function META:GetMaterialStride(...)
		return lib.btMaterialProperties_getMaterialStride(self, ...)
	end
	function META:SetNumMaterials(...)
		return lib.btMaterialProperties_setNumMaterials(self, ...)
	end
	function META:SetTriangleMaterialStride(...)
		return lib.btMaterialProperties_setTriangleMaterialStride(self, ...)
	end
	function META:GetMaterialBase(...)
		return lib.btMaterialProperties_getMaterialBase(self, ...)
	end
	ffi.metatype('btMaterialProperties', META)
	function bullet.CreateMaterialProperties(...)
		return lib.btMaterialProperties_new(...)
	end
end
do -- MultiBodyDynamicsWorld
	local META = {}
	META.__index = META
	function META:DebugDrawMultiBodyConstraint(...)
		return lib.btMultiBodyDynamicsWorld_debugDrawMultiBodyConstraint(self, ...)
	end
	function META:AddMultiBody(...)
		return lib.btMultiBodyDynamicsWorld_addMultiBody(self, ...)
	end
	function META:AddMultiBody2(...)
		return lib.btMultiBodyDynamicsWorld_addMultiBody2(self, ...)
	end
	function META:RemoveMultiBodyConstraint(...)
		return lib.btMultiBodyDynamicsWorld_removeMultiBodyConstraint(self, ...)
	end
	function META:RemoveMultiBody(...)
		return lib.btMultiBodyDynamicsWorld_removeMultiBody(self, ...)
	end
	function META:AddMultiBodyConstraint(...)
		return lib.btMultiBodyDynamicsWorld_addMultiBodyConstraint(self, ...)
	end
	function META:IntegrateTransforms(...)
		return lib.btMultiBodyDynamicsWorld_integrateTransforms(self, ...)
	end
	function META:AddMultiBody3(...)
		return lib.btMultiBodyDynamicsWorld_addMultiBody3(self, ...)
	end
	ffi.metatype('btMultiBodyDynamicsWorld', META)
	function bullet.CreateMultiBodyDynamicsWorld(...)
		return lib.btMultiBodyDynamicsWorld_new(...)
	end
end
do -- ConvexPlaneCollisionAlgorithm
	local META = {}
	META.__index = META
	function META:CollideSingleContact(...)
		return lib.btConvexPlaneCollisionAlgorithm_collideSingleContact(self, ...)
	end
	ffi.metatype('btConvexPlaneCollisionAlgorithm', META)
	function bullet.CreateConvexPlaneCollisionAlgorithm(...)
		return lib.btConvexPlaneCollisionAlgorithm_new(...)
	end
end
do -- ConvexPlaneCollisionAlgorithm_CreateFunc
	local META = {}
	META.__index = META
	function META:SetNumPerturbationIterations(...)
		return lib.btConvexPlaneCollisionAlgorithm_CreateFunc_setNumPerturbationIterations(self, ...)
	end
	function META:GetNumPerturbationIterations(...)
		return lib.btConvexPlaneCollisionAlgorithm_CreateFunc_getNumPerturbationIterations(self, ...)
	end
	function META:GetMinimumPointsPerturbationThreshold(...)
		return lib.btConvexPlaneCollisionAlgorithm_CreateFunc_getMinimumPointsPerturbationThreshold(self, ...)
	end
	function META:SetMinimumPointsPerturbationThreshold(...)
		return lib.btConvexPlaneCollisionAlgorithm_CreateFunc_setMinimumPointsPerturbationThreshold(self, ...)
	end
	ffi.metatype('btConvexPlaneCollisionAlgorithm_CreateFunc', META)
	function bullet.CreateConvexPlaneCollisionAlgorithm_CreateFunc(...)
		return lib.btConvexPlaneCollisionAlgorithm_CreateFunc_new(...)
	end
end
do -- BT_BOX_BOX_TRANSFORM_CACHE
	local META = {}
	META.__index = META
	ffi.metatype('BT_BOX_BOX_TRANSFORM_CACHE', META)
	function bullet.CreateBT_BOX_BOX_TRANSFORM_CACHE(...)
		return lib.BT_BOX_BOX_TRANSFORM_CACHE_new(...)
	end
end
do -- Dbvt_ICollide
	local META = {}
	META.__index = META
	function META:AllLeaves(...)
		return lib.btDbvt_ICollide_AllLeaves(self, ...)
	end
	function META:Descent(...)
		return lib.btDbvt_ICollide_Descent(self, ...)
	end
	function META:Delete(...)
		return lib.btDbvt_ICollide_delete(self, ...)
	end
	function META:Process2(...)
		return lib.btDbvt_ICollide_Process2(self, ...)
	end
	function META:Process(...)
		return lib.btDbvt_ICollide_Process(self, ...)
	end
	function META:Process3(...)
		return lib.btDbvt_ICollide_Process3(self, ...)
	end
	ffi.metatype('btDbvt_ICollide', META)
	function bullet.CreateDbvt_ICollide(...)
		return lib.btDbvt_ICollide_new(...)
	end
end
do -- GjkEpaPenetrationDepthSolver
	local META = {}
	META.__index = META
	ffi.metatype('btGjkEpaPenetrationDepthSolver', META)
	function bullet.CreateGjkEpaPenetrationDepthSolver(...)
		return lib.btGjkEpaPenetrationDepthSolver_new(...)
	end
end
do -- SphereTriangleCollisionAlgorithm
	local META = {}
	META.__index = META
	ffi.metatype('btSphereTriangleCollisionAlgorithm', META)
	function bullet.CreateSphereTriangleCollisionAlgorithm(...)
		return lib.btSphereTriangleCollisionAlgorithm_new(...)
	end
	function bullet.CreateSphereTriangleCollisionAlgorithm2(...)
		return lib.btSphereTriangleCollisionAlgorithm_new2(...)
	end
end
do -- GImpactMeshShape
	local META = {}
	META.__index = META
	function META:GetMeshInterface(...)
		return lib.btGImpactMeshShape_getMeshInterface(self, ...)
	end
	function META:GetMeshPartCount(...)
		return lib.btGImpactMeshShape_getMeshPartCount(self, ...)
	end
	function META:GetMeshPart(...)
		return lib.btGImpactMeshShape_getMeshPart(self, ...)
	end
	ffi.metatype('btGImpactMeshShape', META)
	function bullet.CreateGImpactMeshShape(...)
		return lib.btGImpactMeshShape_new(...)
	end
end
do -- QuantizedBvh
	local META = {}
	META.__index = META
	function META:ReportRayOverlappingNodex(...)
		return lib.btQuantizedBvh_reportRayOverlappingNodex(self, ...)
	end
	function META:CalculateSerializeBufferSizeNew(...)
		return lib.btQuantizedBvh_calculateSerializeBufferSizeNew(self, ...)
	end
	function META:GetAlignmentSerializationPadding(...)
		return lib.btQuantizedBvh_getAlignmentSerializationPadding(self, ...)
	end
	function META:GetLeafNodeArray(...)
		return lib.btQuantizedBvh_getLeafNodeArray(self, ...)
	end
	function META:Serialize2(...)
		return lib.btQuantizedBvh_serialize2(self, ...)
	end
	function META:Delete(...)
		return lib.btQuantizedBvh_delete(self, ...)
	end
	function META:Quantize(...)
		return lib.btQuantizedBvh_quantize(self, ...)
	end
	function META:QuantizeWithClamp(...)
		return lib.btQuantizedBvh_quantizeWithClamp(self, ...)
	end
	function META:ReportBoxCastOverlappingNodex(...)
		return lib.btQuantizedBvh_reportBoxCastOverlappingNodex(self, ...)
	end
	function META:UnQuantize(...)
		return lib.btQuantizedBvh_unQuantize(self, ...)
	end
	function META:ReportAabbOverlappingNodex(...)
		return lib.btQuantizedBvh_reportAabbOverlappingNodex(self, ...)
	end
	function META:CalculateSerializeBufferSize(...)
		return lib.btQuantizedBvh_calculateSerializeBufferSize(self, ...)
	end
	function META:SetTraversalMode(...)
		return lib.btQuantizedBvh_setTraversalMode(self, ...)
	end
	function META:SetQuantizationValues(...)
		return lib.btQuantizedBvh_setQuantizationValues(self, ...)
	end
	function META:GetSubtreeInfoArray(...)
		return lib.btQuantizedBvh_getSubtreeInfoArray(self, ...)
	end
	function META:BuildInternal(...)
		return lib.btQuantizedBvh_buildInternal(self, ...)
	end
	function META:SetQuantizationValues2(...)
		return lib.btQuantizedBvh_setQuantizationValues2(self, ...)
	end
	function META:Serialize(...)
		return lib.btQuantizedBvh_serialize(self, ...)
	end
	function META:DeSerializeFloat(...)
		return lib.btQuantizedBvh_deSerializeFloat(self, ...)
	end
	function META:GetQuantizedNodeArray(...)
		return lib.btQuantizedBvh_getQuantizedNodeArray(self, ...)
	end
	function META:DeSerializeInPlace(...)
		return lib.btQuantizedBvh_deSerializeInPlace(self, ...)
	end
	function META:IsQuantized(...)
		return lib.btQuantizedBvh_isQuantized(self, ...)
	end
	function META:DeSerializeDouble(...)
		return lib.btQuantizedBvh_deSerializeDouble(self, ...)
	end
	ffi.metatype('btQuantizedBvh', META)
	function bullet.CreateQuantizedBvh(...)
		return lib.btQuantizedBvh_new(...)
	end
end
do -- SoftBody_CJoint
	local META = {}
	META.__index = META
	function META:GetLife(...)
		return lib.btSoftBody_CJoint_getLife(self, ...)
	end
	function META:SetFriction(...)
		return lib.btSoftBody_CJoint_setFriction(self, ...)
	end
	function META:SetNormal(...)
		return lib.btSoftBody_CJoint_setNormal(self, ...)
	end
	function META:GetFriction(...)
		return lib.btSoftBody_CJoint_getFriction(self, ...)
	end
	function META:GetNormal(...)
		return lib.btSoftBody_CJoint_getNormal(self, ...)
	end
	function META:GetRpos(...)
		return lib.btSoftBody_CJoint_getRpos(self, ...)
	end
	function META:GetMaxlife(...)
		return lib.btSoftBody_CJoint_getMaxlife(self, ...)
	end
	function META:SetLife(...)
		return lib.btSoftBody_CJoint_setLife(self, ...)
	end
	function META:SetMaxlife(...)
		return lib.btSoftBody_CJoint_setMaxlife(self, ...)
	end
	ffi.metatype('btSoftBody_CJoint', META)
	function bullet.CreateSoftBody_CJoint(...)
		return lib.btSoftBody_CJoint_new(...)
	end
end
do -- BoxBoxCollisionAlgorithm
	local META = {}
	META.__index = META
	ffi.metatype('btBoxBoxCollisionAlgorithm', META)
	function bullet.CreateBoxBoxCollisionAlgorithm(...)
		return lib.btBoxBoxCollisionAlgorithm_new(...)
	end
	function bullet.CreateBoxBoxCollisionAlgorithm2(...)
		return lib.btBoxBoxCollisionAlgorithm_new2(...)
	end
end
do -- VehicleRaycaster_btVehicleRaycasterResult
	local META = {}
	META.__index = META
	function META:SetHitNormalInWorld(...)
		return lib.btVehicleRaycaster_btVehicleRaycasterResult_setHitNormalInWorld(self, ...)
	end
	function META:GetDistFraction(...)
		return lib.btVehicleRaycaster_btVehicleRaycasterResult_getDistFraction(self, ...)
	end
	function META:SetHitPointInWorld(...)
		return lib.btVehicleRaycaster_btVehicleRaycasterResult_setHitPointInWorld(self, ...)
	end
	function META:GetHitNormalInWorld(...)
		return lib.btVehicleRaycaster_btVehicleRaycasterResult_getHitNormalInWorld(self, ...)
	end
	function META:GetHitPointInWorld(...)
		return lib.btVehicleRaycaster_btVehicleRaycasterResult_getHitPointInWorld(self, ...)
	end
	function META:SetDistFraction(...)
		return lib.btVehicleRaycaster_btVehicleRaycasterResult_setDistFraction(self, ...)
	end
	function META:Delete(...)
		return lib.btVehicleRaycaster_btVehicleRaycasterResult_delete(self, ...)
	end
	ffi.metatype('btVehicleRaycaster_btVehicleRaycasterResult', META)
	function bullet.CreateVehicleRaycaster_btVehicleRaycasterResult(...)
		return lib.btVehicleRaycaster_btVehicleRaycasterResult_new(...)
	end
end
do -- SoftBody_Body
	local META = {}
	META.__index = META
	function META:Velocity(...)
		return lib.btSoftBody_Body_velocity(self, ...)
	end
	function META:ApplyDCImpulse(...)
		return lib.btSoftBody_Body_applyDCImpulse(self, ...)
	end
	function META:ApplyDImpulse(...)
		return lib.btSoftBody_Body_applyDImpulse(self, ...)
	end
	function META:GetCollisionObject(...)
		return lib.btSoftBody_Body_getCollisionObject(self, ...)
	end
	function META:ApplyImpulse(...)
		return lib.btSoftBody_Body_applyImpulse(self, ...)
	end
	function META:ApplyVImpulse(...)
		return lib.btSoftBody_Body_applyVImpulse(self, ...)
	end
	function META:SetCollisionObject(...)
		return lib.btSoftBody_Body_setCollisionObject(self, ...)
	end
	function META:Activate(...)
		return lib.btSoftBody_Body_activate(self, ...)
	end
	function META:AngularVelocity2(...)
		return lib.btSoftBody_Body_angularVelocity2(self, ...)
	end
	function META:SetRigid(...)
		return lib.btSoftBody_Body_setRigid(self, ...)
	end
	function META:Xform(...)
		return lib.btSoftBody_Body_xform(self, ...)
	end
	function META:InvWorldInertia(...)
		return lib.btSoftBody_Body_invWorldInertia(self, ...)
	end
	function META:LinearVelocity(...)
		return lib.btSoftBody_Body_linearVelocity(self, ...)
	end
	function META:GetRigid(...)
		return lib.btSoftBody_Body_getRigid(self, ...)
	end
	function META:ApplyVAImpulse(...)
		return lib.btSoftBody_Body_applyVAImpulse(self, ...)
	end
	function META:Delete(...)
		return lib.btSoftBody_Body_delete(self, ...)
	end
	function META:ApplyDAImpulse(...)
		return lib.btSoftBody_Body_applyDAImpulse(self, ...)
	end
	function META:SetSoft(...)
		return lib.btSoftBody_Body_setSoft(self, ...)
	end
	function META:InvMass(...)
		return lib.btSoftBody_Body_invMass(self, ...)
	end
	function META:ApplyAImpulse(...)
		return lib.btSoftBody_Body_applyAImpulse(self, ...)
	end
	function META:AngularVelocity(...)
		return lib.btSoftBody_Body_angularVelocity(self, ...)
	end
	function META:GetSoft(...)
		return lib.btSoftBody_Body_getSoft(self, ...)
	end
	ffi.metatype('btSoftBody_Body', META)
	function bullet.CreateSoftBody_Body(...)
		return lib.btSoftBody_Body_new(...)
	end
	function bullet.CreateSoftBody_Body2(...)
		return lib.btSoftBody_Body_new2(...)
	end
	function bullet.CreateSoftBody_Body3(...)
		return lib.btSoftBody_Body_new3(...)
	end
end
do -- LemkeSolver
	local META = {}
	META.__index = META
	function META:SetUseLoHighBounds(...)
		return lib.btLemkeSolver_setUseLoHighBounds(self, ...)
	end
	function META:GetMaxValue(...)
		return lib.btLemkeSolver_getMaxValue(self, ...)
	end
	function META:SetMaxValue(...)
		return lib.btLemkeSolver_setMaxValue(self, ...)
	end
	function META:SetDebugLevel(...)
		return lib.btLemkeSolver_setDebugLevel(self, ...)
	end
	function META:SetMaxLoops(...)
		return lib.btLemkeSolver_setMaxLoops(self, ...)
	end
	function META:GetMaxLoops(...)
		return lib.btLemkeSolver_getMaxLoops(self, ...)
	end
	function META:GetUseLoHighBounds(...)
		return lib.btLemkeSolver_getUseLoHighBounds(self, ...)
	end
	function META:GetDebugLevel(...)
		return lib.btLemkeSolver_getDebugLevel(self, ...)
	end
	ffi.metatype('btLemkeSolver', META)
	function bullet.CreateLemkeSolver(...)
		return lib.btLemkeSolver_new(...)
	end
end
do -- SoftBody_Link
	local META = {}
	META.__index = META
	function META:GetBbending(...)
		return lib.btSoftBody_Link_getBbending(self, ...)
	end
	function META:GetC0(...)
		return lib.btSoftBody_Link_getC0(self, ...)
	end
	function META:SetBbending(...)
		return lib.btSoftBody_Link_setBbending(self, ...)
	end
	function META:GetN(...)
		return lib.btSoftBody_Link_getN(self, ...)
	end
	function META:GetC2(...)
		return lib.btSoftBody_Link_getC2(self, ...)
	end
	function META:GetRl(...)
		return lib.btSoftBody_Link_getRl(self, ...)
	end
	function META:SetRl(...)
		return lib.btSoftBody_Link_setRl(self, ...)
	end
	function META:SetC1(...)
		return lib.btSoftBody_Link_setC1(self, ...)
	end
	function META:SetC0(...)
		return lib.btSoftBody_Link_setC0(self, ...)
	end
	function META:GetC1(...)
		return lib.btSoftBody_Link_getC1(self, ...)
	end
	function META:SetC2(...)
		return lib.btSoftBody_Link_setC2(self, ...)
	end
	function META:SetC3(...)
		return lib.btSoftBody_Link_setC3(self, ...)
	end
	function META:GetC3(...)
		return lib.btSoftBody_Link_getC3(self, ...)
	end
	ffi.metatype('btSoftBody_Link', META)
	function bullet.CreateSoftBody_Link2(...)
		return lib.btSoftBody_Link_new2(...)
	end
	function bullet.CreateSoftBody_Link(...)
		return lib.btSoftBody_Link_new(...)
	end
end
do -- SoftBodyConcaveCollisionAlgorithm
	local META = {}
	META.__index = META
	function META:ClearCache(...)
		return lib.btSoftBodyConcaveCollisionAlgorithm_clearCache(self, ...)
	end
	ffi.metatype('btSoftBodyConcaveCollisionAlgorithm', META)
	function bullet.CreateSoftBodyConcaveCollisionAlgorithm(...)
		return lib.btSoftBodyConcaveCollisionAlgorithm_new(...)
	end
end
do -- CollisionWorld_LocalRayResult
	local META = {}
	META.__index = META
	function META:SetHitNormalLocal(...)
		return lib.btCollisionWorld_LocalRayResult_setHitNormalLocal(self, ...)
	end
	function META:SetHitFraction(...)
		return lib.btCollisionWorld_LocalRayResult_setHitFraction(self, ...)
	end
	function META:GetCollisionObject(...)
		return lib.btCollisionWorld_LocalRayResult_getCollisionObject(self, ...)
	end
	function META:GetLocalShapeInfo(...)
		return lib.btCollisionWorld_LocalRayResult_getLocalShapeInfo(self, ...)
	end
	function META:GetHitFraction(...)
		return lib.btCollisionWorld_LocalRayResult_getHitFraction(self, ...)
	end
	function META:SetCollisionObject(...)
		return lib.btCollisionWorld_LocalRayResult_setCollisionObject(self, ...)
	end
	function META:SetLocalShapeInfo(...)
		return lib.btCollisionWorld_LocalRayResult_setLocalShapeInfo(self, ...)
	end
	function META:GetHitNormalLocal(...)
		return lib.btCollisionWorld_LocalRayResult_getHitNormalLocal(self, ...)
	end
	function META:Delete(...)
		return lib.btCollisionWorld_LocalRayResult_delete(self, ...)
	end
	ffi.metatype('btCollisionWorld_LocalRayResult', META)
	function bullet.CreateCollisionWorld_LocalRayResult(...)
		return lib.btCollisionWorld_LocalRayResult_new(...)
	end
end
do -- BvhTree
	local META = {}
	META.__index = META
	function META:GetNodeBound(...)
		return lib.btBvhTree_getNodeBound(self, ...)
	end
	function META:GetRightNode(...)
		return lib.btBvhTree_getRightNode(self, ...)
	end
	function META:GetEscapeNodeIndex(...)
		return lib.btBvhTree_getEscapeNodeIndex(self, ...)
	end
	function META:GetLeftNode(...)
		return lib.btBvhTree_getLeftNode(self, ...)
	end
	function META:Delete(...)
		return lib.btBvhTree_delete(self, ...)
	end
	function META:IsLeafNode(...)
		return lib.btBvhTree_isLeafNode(self, ...)
	end
	function META:SetNodeBound(...)
		return lib.btBvhTree_setNodeBound(self, ...)
	end
	function META:GetNodeCount(...)
		return lib.btBvhTree_getNodeCount(self, ...)
	end
	function META:GetNodeData(...)
		return lib.btBvhTree_getNodeData(self, ...)
	end
	function META:ClearNodes(...)
		return lib.btBvhTree_clearNodes(self, ...)
	end
	ffi.metatype('btBvhTree', META)
	function bullet.CreateBvhTree(...)
		return lib.btBvhTree_new(...)
	end
end
do -- OptimizedBvhNode
	local META = {}
	META.__index = META
	function META:GetEscapeIndex(...)
		return lib.btOptimizedBvhNode_getEscapeIndex(self, ...)
	end
	function META:GetPadding(...)
		return lib.btOptimizedBvhNode_getPadding(self, ...)
	end
	function META:GetTriangleIndex(...)
		return lib.btOptimizedBvhNode_getTriangleIndex(self, ...)
	end
	function META:SetSubPart(...)
		return lib.btOptimizedBvhNode_setSubPart(self, ...)
	end
	function META:Delete(...)
		return lib.btOptimizedBvhNode_delete(self, ...)
	end
	function META:SetTriangleIndex(...)
		return lib.btOptimizedBvhNode_setTriangleIndex(self, ...)
	end
	function META:SetAabbMaxOrg(...)
		return lib.btOptimizedBvhNode_setAabbMaxOrg(self, ...)
	end
	function META:GetAabbMinOrg(...)
		return lib.btOptimizedBvhNode_getAabbMinOrg(self, ...)
	end
	function META:GetSubPart(...)
		return lib.btOptimizedBvhNode_getSubPart(self, ...)
	end
	function META:SetEscapeIndex(...)
		return lib.btOptimizedBvhNode_setEscapeIndex(self, ...)
	end
	function META:SetAabbMinOrg(...)
		return lib.btOptimizedBvhNode_setAabbMinOrg(self, ...)
	end
	function META:GetAabbMaxOrg(...)
		return lib.btOptimizedBvhNode_getAabbMaxOrg(self, ...)
	end
	ffi.metatype('btOptimizedBvhNode', META)
	function bullet.CreateOptimizedBvhNode(...)
		return lib.btOptimizedBvhNode_new(...)
	end
end
do -- SphereBoxCollisionAlgorithm
	local META = {}
	META.__index = META
	function META:GetSphereDistance(...)
		return lib.btSphereBoxCollisionAlgorithm_getSphereDistance(self, ...)
	end
	function META:GetSpherePenetration(...)
		return lib.btSphereBoxCollisionAlgorithm_getSpherePenetration(self, ...)
	end
	ffi.metatype('btSphereBoxCollisionAlgorithm', META)
	function bullet.CreateSphereBoxCollisionAlgorithm(...)
		return lib.btSphereBoxCollisionAlgorithm_new(...)
	end
end
do -- AngularLimit
	local META = {}
	META.__index = META
	function META:Set4(...)
		return lib.btAngularLimit_set4(self, ...)
	end
	function META:GetRelaxationFactor(...)
		return lib.btAngularLimit_getRelaxationFactor(self, ...)
	end
	function META:IsLimit(...)
		return lib.btAngularLimit_isLimit(self, ...)
	end
	function META:GetBiasFactor(...)
		return lib.btAngularLimit_getBiasFactor(self, ...)
	end
	function META:GetSign(...)
		return lib.btAngularLimit_getSign(self, ...)
	end
	function META:GetHigh(...)
		return lib.btAngularLimit_getHigh(self, ...)
	end
	function META:Set(...)
		return lib.btAngularLimit_set(self, ...)
	end
	function META:Set2(...)
		return lib.btAngularLimit_set2(self, ...)
	end
	function META:Set3(...)
		return lib.btAngularLimit_set3(self, ...)
	end
	function META:GetLow(...)
		return lib.btAngularLimit_getLow(self, ...)
	end
	function META:Delete(...)
		return lib.btAngularLimit_delete(self, ...)
	end
	function META:GetSoftness(...)
		return lib.btAngularLimit_getSoftness(self, ...)
	end
	function META:Fit(...)
		return lib.btAngularLimit_fit(self, ...)
	end
	function META:GetError(...)
		return lib.btAngularLimit_getError(self, ...)
	end
	function META:Test(...)
		return lib.btAngularLimit_test(self, ...)
	end
	function META:GetCorrection(...)
		return lib.btAngularLimit_getCorrection(self, ...)
	end
	function META:GetHalfRange(...)
		return lib.btAngularLimit_getHalfRange(self, ...)
	end
	ffi.metatype('btAngularLimit', META)
	function bullet.CreateAngularLimit(...)
		return lib.btAngularLimit_new(...)
	end
end
do -- CollisionWorld_AllHitsRayResultCallback
	local META = {}
	META.__index = META
	function META:SetRayToWorld(...)
		return lib.btCollisionWorld_AllHitsRayResultCallback_setRayToWorld(self, ...)
	end
	function META:GetRayFromWorld(...)
		return lib.btCollisionWorld_AllHitsRayResultCallback_getRayFromWorld(self, ...)
	end
	function META:SetRayFromWorld(...)
		return lib.btCollisionWorld_AllHitsRayResultCallback_setRayFromWorld(self, ...)
	end
	function META:GetRayToWorld(...)
		return lib.btCollisionWorld_AllHitsRayResultCallback_getRayToWorld(self, ...)
	end
	function META:GetHitFractions(...)
		return lib.btCollisionWorld_AllHitsRayResultCallback_getHitFractions(self, ...)
	end
	function META:GetHitNormalWorld(...)
		return lib.btCollisionWorld_AllHitsRayResultCallback_getHitNormalWorld(self, ...)
	end
	function META:GetHitPointWorld(...)
		return lib.btCollisionWorld_AllHitsRayResultCallback_getHitPointWorld(self, ...)
	end
	function META:GetCollisionObjects(...)
		return lib.btCollisionWorld_AllHitsRayResultCallback_getCollisionObjects(self, ...)
	end
	ffi.metatype('btCollisionWorld_AllHitsRayResultCallback', META)
	function bullet.CreateCollisionWorld_AllHitsRayResultCallback(...)
		return lib.btCollisionWorld_AllHitsRayResultCallback_new(...)
	end
end
do -- Convex2dShape
	local META = {}
	META.__index = META
	function META:GetChildShape(...)
		return lib.btConvex2dShape_getChildShape(self, ...)
	end
	ffi.metatype('btConvex2dShape', META)
	function bullet.CreateConvex2dShape2(...)
		return lib.btConvex2dShape_new(...)
	end
end
do -- PolarDecomposition
	local META = {}
	META.__index = META
	function META:MaxIterations(...)
		return lib.btPolarDecomposition_maxIterations(self, ...)
	end
	function META:Delete(...)
		return lib.btPolarDecomposition_delete(self, ...)
	end
	function META:Decompose(...)
		return lib.btPolarDecomposition_decompose(self, ...)
	end
	ffi.metatype('btPolarDecomposition', META)
	function bullet.CreatePolarDecomposition3(...)
		return lib.btPolarDecomposition_new3(...)
	end
	function bullet.CreatePolarDecomposition(...)
		return lib.btPolarDecomposition_new(...)
	end
	function bullet.CreatePolarDecomposition2(...)
		return lib.btPolarDecomposition_new2(...)
	end
end
do -- SimulationIslandManager
	local META = {}
	META.__index = META
	function META:FindUnions(...)
		return lib.btSimulationIslandManager_findUnions(self, ...)
	end
	function META:BuildIslands(...)
		return lib.btSimulationIslandManager_buildIslands(self, ...)
	end
	function META:InitUnionFind(...)
		return lib.btSimulationIslandManager_initUnionFind(self, ...)
	end
	function META:Delete(...)
		return lib.btSimulationIslandManager_delete(self, ...)
	end
	function META:SetSplitIslands(...)
		return lib.btSimulationIslandManager_setSplitIslands(self, ...)
	end
	function META:GetUnionFind(...)
		return lib.btSimulationIslandManager_getUnionFind(self, ...)
	end
	function META:GetSplitIslands(...)
		return lib.btSimulationIslandManager_getSplitIslands(self, ...)
	end
	function META:BuildAndProcessIslands(...)
		return lib.btSimulationIslandManager_buildAndProcessIslands(self, ...)
	end
	function META:UpdateActivationState(...)
		return lib.btSimulationIslandManager_updateActivationState(self, ...)
	end
	function META:StoreIslandActivationState(...)
		return lib.btSimulationIslandManager_storeIslandActivationState(self, ...)
	end
	ffi.metatype('btSimulationIslandManager', META)
	function bullet.CreateSimulationIslandManager(...)
		return lib.btSimulationIslandManager_new(...)
	end
end
do -- TriangleInfoMap
	local META = {}
	META.__index = META
	function META:SetEdgeDistanceThreshold(...)
		return lib.btTriangleInfoMap_setEdgeDistanceThreshold(self, ...)
	end
	function META:GetConvexEpsilon(...)
		return lib.btTriangleInfoMap_getConvexEpsilon(self, ...)
	end
	function META:GetEdgeDistanceThreshold(...)
		return lib.btTriangleInfoMap_getEdgeDistanceThreshold(self, ...)
	end
	function META:Serialize(...)
		return lib.btTriangleInfoMap_serialize(self, ...)
	end
	function META:SetPlanarEpsilon(...)
		return lib.btTriangleInfoMap_setPlanarEpsilon(self, ...)
	end
	function META:GetZeroAreaThreshold(...)
		return lib.btTriangleInfoMap_getZeroAreaThreshold(self, ...)
	end
	function META:SetMaxEdgeAngleThreshold(...)
		return lib.btTriangleInfoMap_setMaxEdgeAngleThreshold(self, ...)
	end
	function META:SetEqualVertexThreshold(...)
		return lib.btTriangleInfoMap_setEqualVertexThreshold(self, ...)
	end
	function META:GetPlanarEpsilon(...)
		return lib.btTriangleInfoMap_getPlanarEpsilon(self, ...)
	end
	function META:SetZeroAreaThreshold(...)
		return lib.btTriangleInfoMap_setZeroAreaThreshold(self, ...)
	end
	function META:DeSerialize(...)
		return lib.btTriangleInfoMap_deSerialize(self, ...)
	end
	function META:GetEqualVertexThreshold(...)
		return lib.btTriangleInfoMap_getEqualVertexThreshold(self, ...)
	end
	function META:GetMaxEdgeAngleThreshold(...)
		return lib.btTriangleInfoMap_getMaxEdgeAngleThreshold(self, ...)
	end
	function META:SetConvexEpsilon(...)
		return lib.btTriangleInfoMap_setConvexEpsilon(self, ...)
	end
	function META:CalculateSerializeBufferSize(...)
		return lib.btTriangleInfoMap_calculateSerializeBufferSize(self, ...)
	end
	ffi.metatype('btTriangleInfoMap', META)
	function bullet.CreateTriangleInfoMap(...)
		return lib.btTriangleInfoMap_new(...)
	end
end
do -- CompoundCompoundCollisionAlgorithm_CreateFunc
	local META = {}
	META.__index = META
	ffi.metatype('btCompoundCompoundCollisionAlgorithm_CreateFunc', META)
	function bullet.CreateCompoundCompoundCollisionAlgorithm_CreateFunc(...)
		return lib.btCompoundCompoundCollisionAlgorithm_CreateFunc_new(...)
	end
end
do -- CollisionWorld_ClosestRayResultCallback
	local META = {}
	META.__index = META
	function META:SetRayToWorld(...)
		return lib.btCollisionWorld_ClosestRayResultCallback_setRayToWorld(self, ...)
	end
	function META:GetRayToWorld(...)
		return lib.btCollisionWorld_ClosestRayResultCallback_getRayToWorld(self, ...)
	end
	function META:SetHitPointWorld(...)
		return lib.btCollisionWorld_ClosestRayResultCallback_setHitPointWorld(self, ...)
	end
	function META:SetRayFromWorld(...)
		return lib.btCollisionWorld_ClosestRayResultCallback_setRayFromWorld(self, ...)
	end
	function META:SetHitNormalWorld(...)
		return lib.btCollisionWorld_ClosestRayResultCallback_setHitNormalWorld(self, ...)
	end
	function META:GetHitNormalWorld(...)
		return lib.btCollisionWorld_ClosestRayResultCallback_getHitNormalWorld(self, ...)
	end
	function META:GetHitPointWorld(...)
		return lib.btCollisionWorld_ClosestRayResultCallback_getHitPointWorld(self, ...)
	end
	function META:GetRayFromWorld(...)
		return lib.btCollisionWorld_ClosestRayResultCallback_getRayFromWorld(self, ...)
	end
	ffi.metatype('btCollisionWorld_ClosestRayResultCallback', META)
	function bullet.CreateCollisionWorld_ClosestRayResultCallback(...)
		return lib.btCollisionWorld_ClosestRayResultCallback_new(...)
	end
end
do -- ShapeHull
	local META = {}
	META.__index = META
	function META:NumVertices(...)
		return lib.btShapeHull_numVertices(self, ...)
	end
	function META:NumIndices(...)
		return lib.btShapeHull_numIndices(self, ...)
	end
	function META:BuildHull(...)
		return lib.btShapeHull_buildHull(self, ...)
	end
	function META:GetIndexPointer(...)
		return lib.btShapeHull_getIndexPointer(self, ...)
	end
	function META:GetVertexPointer(...)
		return lib.btShapeHull_getVertexPointer(self, ...)
	end
	function META:NumTriangles(...)
		return lib.btShapeHull_numTriangles(self, ...)
	end
	function META:Delete(...)
		return lib.btShapeHull_delete(self, ...)
	end
	ffi.metatype('btShapeHull', META)
	function bullet.CreateShapeHull(...)
		return lib.btShapeHull_new(...)
	end
end
do -- SoftBody_sMedium
	local META = {}
	META.__index = META
	function META:SetPressure(...)
		return lib.btSoftBody_sMedium_setPressure(self, ...)
	end
	function META:GetDensity(...)
		return lib.btSoftBody_sMedium_getDensity(self, ...)
	end
	function META:SetVelocity(...)
		return lib.btSoftBody_sMedium_setVelocity(self, ...)
	end
	function META:GetPressure(...)
		return lib.btSoftBody_sMedium_getPressure(self, ...)
	end
	function META:Delete(...)
		return lib.btSoftBody_sMedium_delete(self, ...)
	end
	function META:SetDensity(...)
		return lib.btSoftBody_sMedium_setDensity(self, ...)
	end
	function META:GetVelocity(...)
		return lib.btSoftBody_sMedium_getVelocity(self, ...)
	end
	ffi.metatype('btSoftBody_sMedium', META)
	function bullet.CreateSoftBody_sMedium(...)
		return lib.btSoftBody_sMedium_new(...)
	end
end
do -- JointFeedback
	local META = {}
	META.__index = META
	function META:SetAppliedForceBodyB(...)
		return lib.btJointFeedback_setAppliedForceBodyB(self, ...)
	end
	function META:SetAppliedTorqueBodyB(...)
		return lib.btJointFeedback_setAppliedTorqueBodyB(self, ...)
	end
	function META:GetAppliedForceBodyA(...)
		return lib.btJointFeedback_getAppliedForceBodyA(self, ...)
	end
	function META:GetAppliedTorqueBodyA(...)
		return lib.btJointFeedback_getAppliedTorqueBodyA(self, ...)
	end
	function META:SetAppliedForceBodyA(...)
		return lib.btJointFeedback_setAppliedForceBodyA(self, ...)
	end
	function META:SetAppliedTorqueBodyA(...)
		return lib.btJointFeedback_setAppliedTorqueBodyA(self, ...)
	end
	function META:GetAppliedForceBodyB(...)
		return lib.btJointFeedback_getAppliedForceBodyB(self, ...)
	end
	function META:GetAppliedTorqueBodyB(...)
		return lib.btJointFeedback_getAppliedTorqueBodyB(self, ...)
	end
	function META:Delete(...)
		return lib.btJointFeedback_delete(self, ...)
	end
	ffi.metatype('btJointFeedback', META)
	function bullet.CreateJointFeedback(...)
		return lib.btJointFeedback_new(...)
	end
end
do -- GImpactCompoundShape
	local META = {}
	META.__index = META
	function META:AddChildShape(...)
		return lib.btGImpactCompoundShape_addChildShape(self, ...)
	end
	function META:GetCompoundPrimitiveManager(...)
		return lib.btGImpactCompoundShape_getCompoundPrimitiveManager(self, ...)
	end
	function META:AddChildShape2(...)
		return lib.btGImpactCompoundShape_addChildShape2(self, ...)
	end
	ffi.metatype('btGImpactCompoundShape', META)
	function bullet.CreateGImpactCompoundShape(...)
		return lib.btGImpactCompoundShape_new(...)
	end
	function bullet.CreateGImpactCompoundShape2(...)
		return lib.btGImpactCompoundShape_new2(...)
	end
end
do -- TranslationalLimitMotor2
	local META = {}
	META.__index = META
	function META:SetTargetVelocity(...)
		return lib.btTranslationalLimitMotor2_setTargetVelocity(self, ...)
	end
	function META:SetLowerLimit(...)
		return lib.btTranslationalLimitMotor2_setLowerLimit(self, ...)
	end
	function META:GetCurrentLimit(...)
		return lib.btTranslationalLimitMotor2_getCurrentLimit(self, ...)
	end
	function META:GetEquilibriumPoint(...)
		return lib.btTranslationalLimitMotor2_getEquilibriumPoint(self, ...)
	end
	function META:GetEnableSpring(...)
		return lib.btTranslationalLimitMotor2_getEnableSpring(self, ...)
	end
	function META:GetMaxMotorForce(...)
		return lib.btTranslationalLimitMotor2_getMaxMotorForce(self, ...)
	end
	function META:GetBounce(...)
		return lib.btTranslationalLimitMotor2_getBounce(self, ...)
	end
	function META:SetSpringDamping(...)
		return lib.btTranslationalLimitMotor2_setSpringDamping(self, ...)
	end
	function META:IsLimited(...)
		return lib.btTranslationalLimitMotor2_isLimited(self, ...)
	end
	function META:SetStopCFM(...)
		return lib.btTranslationalLimitMotor2_setStopCFM(self, ...)
	end
	function META:GetSpringDamping(...)
		return lib.btTranslationalLimitMotor2_getSpringDamping(self, ...)
	end
	function META:SetMotorERP(...)
		return lib.btTranslationalLimitMotor2_setMotorERP(self, ...)
	end
	function META:GetServoMotor(...)
		return lib.btTranslationalLimitMotor2_getServoMotor(self, ...)
	end
	function META:GetCurrentLinearDiff(...)
		return lib.btTranslationalLimitMotor2_getCurrentLinearDiff(self, ...)
	end
	function META:GetCurrentLimitErrorHi(...)
		return lib.btTranslationalLimitMotor2_getCurrentLimitErrorHi(self, ...)
	end
	function META:GetUpperLimit(...)
		return lib.btTranslationalLimitMotor2_getUpperLimit(self, ...)
	end
	function META:GetMotorCFM(...)
		return lib.btTranslationalLimitMotor2_getMotorCFM(self, ...)
	end
	function META:GetEnableMotor(...)
		return lib.btTranslationalLimitMotor2_getEnableMotor(self, ...)
	end
	function META:GetServoTarget(...)
		return lib.btTranslationalLimitMotor2_getServoTarget(self, ...)
	end
	function META:Delete(...)
		return lib.btTranslationalLimitMotor2_delete(self, ...)
	end
	function META:SetBounce(...)
		return lib.btTranslationalLimitMotor2_setBounce(self, ...)
	end
	function META:SetCurrentLinearDiff(...)
		return lib.btTranslationalLimitMotor2_setCurrentLinearDiff(self, ...)
	end
	function META:SetServoTarget(...)
		return lib.btTranslationalLimitMotor2_setServoTarget(self, ...)
	end
	function META:TestLimitValue(...)
		return lib.btTranslationalLimitMotor2_testLimitValue(self, ...)
	end
	function META:GetStopCFM(...)
		return lib.btTranslationalLimitMotor2_getStopCFM(self, ...)
	end
	function META:SetUpperLimit(...)
		return lib.btTranslationalLimitMotor2_setUpperLimit(self, ...)
	end
	function META:SetStopERP(...)
		return lib.btTranslationalLimitMotor2_setStopERP(self, ...)
	end
	function META:SetMotorCFM(...)
		return lib.btTranslationalLimitMotor2_setMotorCFM(self, ...)
	end
	function META:SetSpringStiffness(...)
		return lib.btTranslationalLimitMotor2_setSpringStiffness(self, ...)
	end
	function META:GetLowerLimit(...)
		return lib.btTranslationalLimitMotor2_getLowerLimit(self, ...)
	end
	function META:GetCurrentLimitError(...)
		return lib.btTranslationalLimitMotor2_getCurrentLimitError(self, ...)
	end
	function META:GetStopERP(...)
		return lib.btTranslationalLimitMotor2_getStopERP(self, ...)
	end
	function META:GetSpringStiffness(...)
		return lib.btTranslationalLimitMotor2_getSpringStiffness(self, ...)
	end
	function META:SetCurrentLimitError(...)
		return lib.btTranslationalLimitMotor2_setCurrentLimitError(self, ...)
	end
	function META:SetMaxMotorForce(...)
		return lib.btTranslationalLimitMotor2_setMaxMotorForce(self, ...)
	end
	function META:SetCurrentLimitErrorHi(...)
		return lib.btTranslationalLimitMotor2_setCurrentLimitErrorHi(self, ...)
	end
	function META:GetMotorERP(...)
		return lib.btTranslationalLimitMotor2_getMotorERP(self, ...)
	end
	function META:SetEquilibriumPoint(...)
		return lib.btTranslationalLimitMotor2_setEquilibriumPoint(self, ...)
	end
	function META:GetTargetVelocity(...)
		return lib.btTranslationalLimitMotor2_getTargetVelocity(self, ...)
	end
	ffi.metatype('btTranslationalLimitMotor2', META)
	function bullet.CreateTranslationalLimitMotor22(...)
		return lib.btTranslationalLimitMotor2_new2(...)
	end
end
do -- ConeShape
	local META = {}
	META.__index = META
	function META:GetConeUpIndex(...)
		return lib.btConeShape_getConeUpIndex(self, ...)
	end
	function META:SetConeUpIndex(...)
		return lib.btConeShape_setConeUpIndex(self, ...)
	end
	function META:GetRadius(...)
		return lib.btConeShape_getRadius(self, ...)
	end
	function META:GetHeight(...)
		return lib.btConeShape_getHeight(self, ...)
	end
	ffi.metatype('btConeShape', META)
	function bullet.CreateConeShape(...)
		return lib.btConeShape_new(...)
	end
end
do -- TriangleBuffer
	local META = {}
	META.__index = META
	function META:GetTriangle(...)
		return lib.btTriangleBuffer_getTriangle(self, ...)
	end
	function META:ClearBuffer(...)
		return lib.btTriangleBuffer_clearBuffer(self, ...)
	end
	function META:GetNumTriangles(...)
		return lib.btTriangleBuffer_getNumTriangles(self, ...)
	end
	ffi.metatype('btTriangleBuffer', META)
	function bullet.CreateTriangleBuffer(...)
		return lib.btTriangleBuffer_new(...)
	end
end
do -- SoftBody_SolverState
	local META = {}
	META.__index = META
	function META:SetUpdmrg(...)
		return lib.btSoftBody_SolverState_setUpdmrg(self, ...)
	end
	function META:GetRadmrg(...)
		return lib.btSoftBody_SolverState_getRadmrg(self, ...)
	end
	function META:SetSdt(...)
		return lib.btSoftBody_SolverState_setSdt(self, ...)
	end
	function META:GetUpdmrg(...)
		return lib.btSoftBody_SolverState_getUpdmrg(self, ...)
	end
	function META:SetVelmrg(...)
		return lib.btSoftBody_SolverState_setVelmrg(self, ...)
	end
	function META:Delete(...)
		return lib.btSoftBody_SolverState_delete(self, ...)
	end
	function META:GetVelmrg(...)
		return lib.btSoftBody_SolverState_getVelmrg(self, ...)
	end
	function META:SetIsdt(...)
		return lib.btSoftBody_SolverState_setIsdt(self, ...)
	end
	function META:GetSdt(...)
		return lib.btSoftBody_SolverState_getSdt(self, ...)
	end
	function META:SetRadmrg(...)
		return lib.btSoftBody_SolverState_setRadmrg(self, ...)
	end
	function META:GetIsdt(...)
		return lib.btSoftBody_SolverState_getIsdt(self, ...)
	end
	ffi.metatype('btSoftBody_SolverState', META)
	function bullet.CreateSoftBody_SolverState(...)
		return lib.btSoftBody_SolverState_new(...)
	end
end
do -- SoftBody_Joint_Specs
	local META = {}
	META.__index = META
	function META:GetErp(...)
		return lib.btSoftBody_Joint_Specs_getErp(self, ...)
	end
	function META:SetCfm(...)
		return lib.btSoftBody_Joint_Specs_setCfm(self, ...)
	end
	function META:GetCfm(...)
		return lib.btSoftBody_Joint_Specs_getCfm(self, ...)
	end
	function META:SetSplit(...)
		return lib.btSoftBody_Joint_Specs_setSplit(self, ...)
	end
	function META:SetErp(...)
		return lib.btSoftBody_Joint_Specs_setErp(self, ...)
	end
	function META:GetSplit(...)
		return lib.btSoftBody_Joint_Specs_getSplit(self, ...)
	end
	function META:Delete(...)
		return lib.btSoftBody_Joint_Specs_delete(self, ...)
	end
	ffi.metatype('btSoftBody_Joint_Specs', META)
	function bullet.CreateSoftBody_Joint_Specs(...)
		return lib.btSoftBody_Joint_Specs_new(...)
	end
end
do -- HingeAccumulatedAngleConstraint
	local META = {}
	META.__index = META
	function META:SetAccumulatedHingeAngle(...)
		return lib.btHingeAccumulatedAngleConstraint_setAccumulatedHingeAngle(self, ...)
	end
	function META:GetAccumulatedHingeAngle(...)
		return lib.btHingeAccumulatedAngleConstraint_getAccumulatedHingeAngle(self, ...)
	end
	ffi.metatype('btHingeAccumulatedAngleConstraint', META)
	function bullet.CreateHingeAccumulatedAngleConstraint8(...)
		return lib.btHingeAccumulatedAngleConstraint_new8(...)
	end
	function bullet.CreateHingeAccumulatedAngleConstraint3(...)
		return lib.btHingeAccumulatedAngleConstraint_new3(...)
	end
	function bullet.CreateHingeAccumulatedAngleConstraint7(...)
		return lib.btHingeAccumulatedAngleConstraint_new7(...)
	end
	function bullet.CreateHingeAccumulatedAngleConstraint4(...)
		return lib.btHingeAccumulatedAngleConstraint_new4(...)
	end
	function bullet.CreateHingeAccumulatedAngleConstraint6(...)
		return lib.btHingeAccumulatedAngleConstraint_new6(...)
	end
	function bullet.CreateHingeAccumulatedAngleConstraint(...)
		return lib.btHingeAccumulatedAngleConstraint_new(...)
	end
	function bullet.CreateHingeAccumulatedAngleConstraint5(...)
		return lib.btHingeAccumulatedAngleConstraint_new5(...)
	end
	function bullet.CreateHingeAccumulatedAngleConstraint2(...)
		return lib.btHingeAccumulatedAngleConstraint_new2(...)
	end
end
do -- GImpactQuantizedBvh
	local META = {}
	META.__index = META
	function META:GetNodeBound(...)
		return lib.btGImpactQuantizedBvh_getNodeBound(self, ...)
	end
	function META:SetPrimitiveManager(...)
		return lib.btGImpactQuantizedBvh_setPrimitiveManager(self, ...)
	end
	function META:BoxQuery(...)
		return lib.btGImpactQuantizedBvh_boxQuery(self, ...)
	end
	function META:RayQuery(...)
		return lib.btGImpactQuantizedBvh_rayQuery(self, ...)
	end
	function META:GetEscapeNodeIndex(...)
		return lib.btGImpactQuantizedBvh_getEscapeNodeIndex(self, ...)
	end
	function META:HasHierarchy(...)
		return lib.btGImpactQuantizedBvh_hasHierarchy(self, ...)
	end
	function META:IsLeafNode(...)
		return lib.btGImpactQuantizedBvh_isLeafNode(self, ...)
	end
	function META:SetNodeBound(...)
		return lib.btGImpactQuantizedBvh_setNodeBound(self, ...)
	end
	function META:GetNodeTriangle(...)
		return lib.btGImpactQuantizedBvh_getNodeTriangle(self, ...)
	end
	function META:Update(...)
		return lib.btGImpactQuantizedBvh_update(self, ...)
	end
	function META:GetNodeCount(...)
		return lib.btGImpactQuantizedBvh_getNodeCount(self, ...)
	end
	function META:BuildSet(...)
		return lib.btGImpactQuantizedBvh_buildSet(self, ...)
	end
	function META:GetPrimitiveManager(...)
		return lib.btGImpactQuantizedBvh_getPrimitiveManager(self, ...)
	end
	function META:GetNodeData(...)
		return lib.btGImpactQuantizedBvh_getNodeData(self, ...)
	end
	function META:GetLeftNode(...)
		return lib.btGImpactQuantizedBvh_getLeftNode(self, ...)
	end
	function META:Delete(...)
		return lib.btGImpactQuantizedBvh_delete(self, ...)
	end
	function META:IsTrimesh(...)
		return lib.btGImpactQuantizedBvh_isTrimesh(self, ...)
	end
	function META:GetRightNode(...)
		return lib.btGImpactQuantizedBvh_getRightNode(self, ...)
	end
	function META:BoxQueryTrans(...)
		return lib.btGImpactQuantizedBvh_boxQueryTrans(self, ...)
	end
	function META:GetGlobalBox(...)
		return lib.btGImpactQuantizedBvh_getGlobalBox(self, ...)
	end
	ffi.metatype('btGImpactQuantizedBvh', META)
	function bullet.CreateGImpactQuantizedBvh(...)
		return lib.btGImpactQuantizedBvh_new(...)
	end
	function bullet.CreateGImpactQuantizedBvh2(...)
		return lib.btGImpactQuantizedBvh_new2(...)
	end
end
do -- AxisSweep3
	local META = {}
	META.__index = META
	function META:AddHandle(...)
		return lib.btAxisSweep3_addHandle(self, ...)
	end
	function META:ProcessAllOverlappingPairs(...)
		return lib.btAxisSweep3_processAllOverlappingPairs(self, ...)
	end
	function META:TestAabbOverlap(...)
		return lib.btAxisSweep3_testAabbOverlap(self, ...)
	end
	function META:GetNumHandles(...)
		return lib.btAxisSweep3_getNumHandles(self, ...)
	end
	function META:UnQuantize(...)
		return lib.btAxisSweep3_unQuantize(self, ...)
	end
	function META:RemoveHandle(...)
		return lib.btAxisSweep3_removeHandle(self, ...)
	end
	function META:SetOverlappingPairUserCallback(...)
		return lib.btAxisSweep3_setOverlappingPairUserCallback(self, ...)
	end
	function META:GetHandle(...)
		return lib.btAxisSweep3_getHandle(self, ...)
	end
	function META:Quantize(...)
		return lib.btAxisSweep3_quantize(self, ...)
	end
	function META:UpdateHandle(...)
		return lib.btAxisSweep3_updateHandle(self, ...)
	end
	function META:GetOverlappingPairUserCallback(...)
		return lib.btAxisSweep3_getOverlappingPairUserCallback(self, ...)
	end
	ffi.metatype('btAxisSweep3', META)
	function bullet.CreateAxisSweep33(...)
		return lib.btAxisSweep3_new3(...)
	end
	function bullet.CreateAxisSweep32(...)
		return lib.btAxisSweep3_new2(...)
	end
	function bullet.CreateAxisSweep34(...)
		return lib.btAxisSweep3_new4(...)
	end
end
do -- KinematicCharacterController
	local META = {}
	META.__index = META
	function META:SetUpAxis(...)
		return lib.btKinematicCharacterController_setUpAxis(self, ...)
	end
	function META:SetUseGhostSweepTest(...)
		return lib.btKinematicCharacterController_setUseGhostSweepTest(self, ...)
	end
	function META:SetFallSpeed(...)
		return lib.btKinematicCharacterController_setFallSpeed(self, ...)
	end
	function META:SetMaxSlope(...)
		return lib.btKinematicCharacterController_setMaxSlope(self, ...)
	end
	function META:GetGhostObject(...)
		return lib.btKinematicCharacterController_getGhostObject(self, ...)
	end
	function META:GetGravity(...)
		return lib.btKinematicCharacterController_getGravity(self, ...)
	end
	function META:GetMaxSlope(...)
		return lib.btKinematicCharacterController_getMaxSlope(self, ...)
	end
	function META:SetMaxJumpHeight(...)
		return lib.btKinematicCharacterController_setMaxJumpHeight(self, ...)
	end
	function META:SetJumpSpeed(...)
		return lib.btKinematicCharacterController_setJumpSpeed(self, ...)
	end
	function META:SetGravity(...)
		return lib.btKinematicCharacterController_setGravity(self, ...)
	end
	ffi.metatype('btKinematicCharacterController', META)
	function bullet.CreateKinematicCharacterController2(...)
		return lib.btKinematicCharacterController_new2(...)
	end
	function bullet.CreateKinematicCharacterController(...)
		return lib.btKinematicCharacterController_new(...)
	end
end
do -- MultiBodyPoint2Point
	local META = {}
	META.__index = META
	function META:SetPivotInB(...)
		return lib.btMultiBodyPoint2Point_setPivotInB(self, ...)
	end
	function META:GetPivotInB(...)
		return lib.btMultiBodyPoint2Point_getPivotInB(self, ...)
	end
	ffi.metatype('btMultiBodyPoint2Point', META)
	function bullet.CreateMultiBodyPoint2Point2(...)
		return lib.btMultiBodyPoint2Point_new2(...)
	end
end
do -- DefaultCollisionConfiguration
	local META = {}
	META.__index = META
	function META:GetSimplexSolver(...)
		return lib.btDefaultCollisionConfiguration_getSimplexSolver(self, ...)
	end
	function META:SetConvexConvexMultipointIterations2(...)
		return lib.btDefaultCollisionConfiguration_setConvexConvexMultipointIterations2(self, ...)
	end
	function META:SetPlaneConvexMultipointIterations3(...)
		return lib.btDefaultCollisionConfiguration_setPlaneConvexMultipointIterations3(self, ...)
	end
	function META:SetPlaneConvexMultipointIterations(...)
		return lib.btDefaultCollisionConfiguration_setPlaneConvexMultipointIterations(self, ...)
	end
	function META:SetPlaneConvexMultipointIterations2(...)
		return lib.btDefaultCollisionConfiguration_setPlaneConvexMultipointIterations2(self, ...)
	end
	function META:SetConvexConvexMultipointIterations(...)
		return lib.btDefaultCollisionConfiguration_setConvexConvexMultipointIterations(self, ...)
	end
	function META:SetConvexConvexMultipointIterations3(...)
		return lib.btDefaultCollisionConfiguration_setConvexConvexMultipointIterations3(self, ...)
	end
	ffi.metatype('btDefaultCollisionConfiguration', META)
	function bullet.CreateDefaultCollisionConfiguration(...)
		return lib.btDefaultCollisionConfiguration_new(...)
	end
	function bullet.CreateDefaultCollisionConfiguration2(...)
		return lib.btDefaultCollisionConfiguration_new2(...)
	end
end
do -- GImpactMeshShapePart
	local META = {}
	META.__index = META
	function META:GetPart(...)
		return lib.btGImpactMeshShapePart_getPart(self, ...)
	end
	function META:GetVertexCount(...)
		return lib.btGImpactMeshShapePart_getVertexCount(self, ...)
	end
	function META:GetVertex(...)
		return lib.btGImpactMeshShapePart_getVertex(self, ...)
	end
	function META:GetTrimeshPrimitiveManager(...)
		return lib.btGImpactMeshShapePart_getTrimeshPrimitiveManager(self, ...)
	end
	ffi.metatype('btGImpactMeshShapePart', META)
	function bullet.CreateGImpactMeshShapePart(...)
		return lib.btGImpactMeshShapePart_new(...)
	end
	function bullet.CreateGImpactMeshShapePart2(...)
		return lib.btGImpactMeshShapePart_new2(...)
	end
end
do -- ScaledBvhTriangleMeshShape
	local META = {}
	META.__index = META
	function META:GetChildShape(...)
		return lib.btScaledBvhTriangleMeshShape_getChildShape(self, ...)
	end
	ffi.metatype('btScaledBvhTriangleMeshShape', META)
	function bullet.CreateScaledBvhTriangleMeshShape(...)
		return lib.btScaledBvhTriangleMeshShape_new(...)
	end
end
do -- Hinge2Constraint
	local META = {}
	META.__index = META
	function META:GetAngle2(...)
		return lib.btHinge2Constraint_getAngle2(self, ...)
	end
	function META:GetAxis2(...)
		return lib.btHinge2Constraint_getAxis2(self, ...)
	end
	function META:SetUpperLimit(...)
		return lib.btHinge2Constraint_setUpperLimit(self, ...)
	end
	function META:GetAnchor2(...)
		return lib.btHinge2Constraint_getAnchor2(self, ...)
	end
	function META:GetAxis1(...)
		return lib.btHinge2Constraint_getAxis1(self, ...)
	end
	function META:SetLowerLimit(...)
		return lib.btHinge2Constraint_setLowerLimit(self, ...)
	end
	function META:GetAngle1(...)
		return lib.btHinge2Constraint_getAngle1(self, ...)
	end
	function META:GetAnchor(...)
		return lib.btHinge2Constraint_getAnchor(self, ...)
	end
	ffi.metatype('btHinge2Constraint', META)
	function bullet.CreateHinge2Constraint2(...)
		return lib.btHinge2Constraint_new(...)
	end
end
do -- InternalTriangleIndexCallbackWrapper
	local META = {}
	META.__index = META
	ffi.metatype('btInternalTriangleIndexCallbackWrapper', META)
	function bullet.CreateInternalTriangleIndexCallbackWrapper(...)
		return lib.btInternalTriangleIndexCallbackWrapper_new(...)
	end
end
do -- DbvtAabbMm
	local META = {}
	META.__index = META
	function META:Extents(...)
		return lib.btDbvtAabbMm_Extents(self, ...)
	end
	function META:Expand(...)
		return lib.btDbvtAabbMm_Expand(self, ...)
	end
	function META:Contain(...)
		return lib.btDbvtAabbMm_Contain(self, ...)
	end
	function META:Lengths(...)
		return lib.btDbvtAabbMm_Lengths(self, ...)
	end
	function META:SignedExpand(...)
		return lib.btDbvtAabbMm_SignedExpand(self, ...)
	end
	function META:Delete(...)
		return lib.btDbvtAabbMm_delete(self, ...)
	end
	function META:FromPoints2(...)
		return lib.btDbvtAabbMm_FromPoints2(self, ...)
	end
	function META:ProjectMinimum(...)
		return lib.btDbvtAabbMm_ProjectMinimum(self, ...)
	end
	function META:Maxs(...)
		return lib.btDbvtAabbMm_Maxs(self, ...)
	end
	function META:Center(...)
		return lib.btDbvtAabbMm_Center(self, ...)
	end
	function META:Mins(...)
		return lib.btDbvtAabbMm_Mins(self, ...)
	end
	function META:FromCR(...)
		return lib.btDbvtAabbMm_FromCR(self, ...)
	end
	function META:Classify(...)
		return lib.btDbvtAabbMm_Classify(self, ...)
	end
	function META:FromCE(...)
		return lib.btDbvtAabbMm_FromCE(self, ...)
	end
	function META:TMins(...)
		return lib.btDbvtAabbMm_tMins(self, ...)
	end
	function META:TMaxs(...)
		return lib.btDbvtAabbMm_tMaxs(self, ...)
	end
	function META:FromPoints(...)
		return lib.btDbvtAabbMm_FromPoints(self, ...)
	end
	function META:FromMM(...)
		return lib.btDbvtAabbMm_FromMM(self, ...)
	end
	ffi.metatype('btDbvtAabbMm', META)
	function bullet.CreateDbvtAabbMm(...)
		return lib.btDbvtAabbMm_new(...)
	end
end
do -- QuantizedBvhNode
	local META = {}
	META.__index = META
	function META:GetEscapeIndex(...)
		return lib.btQuantizedBvhNode_getEscapeIndex(self, ...)
	end
	function META:SetEscapeIndexOrTriangleIndex(...)
		return lib.btQuantizedBvhNode_setEscapeIndexOrTriangleIndex(self, ...)
	end
	function META:GetTriangleIndex(...)
		return lib.btQuantizedBvhNode_getTriangleIndex(self, ...)
	end
	function META:Delete(...)
		return lib.btQuantizedBvhNode_delete(self, ...)
	end
	function META:GetQuantizedAabbMax(...)
		return lib.btQuantizedBvhNode_getQuantizedAabbMax(self, ...)
	end
	function META:GetPartId(...)
		return lib.btQuantizedBvhNode_getPartId(self, ...)
	end
	function META:IsLeafNode(...)
		return lib.btQuantizedBvhNode_isLeafNode(self, ...)
	end
	function META:GetQuantizedAabbMin(...)
		return lib.btQuantizedBvhNode_getQuantizedAabbMin(self, ...)
	end
	function META:GetEscapeIndexOrTriangleIndex(...)
		return lib.btQuantizedBvhNode_getEscapeIndexOrTriangleIndex(self, ...)
	end
	ffi.metatype('btQuantizedBvhNode', META)
	function bullet.CreateQuantizedBvhNode(...)
		return lib.btQuantizedBvhNode_new(...)
	end
end
do -- DbvtNode
	local META = {}
	META.__index = META
	function META:Isinternal(...)
		return lib.btDbvtNode_isinternal(self, ...)
	end
	function META:GetVolume(...)
		return lib.btDbvtNode_getVolume(self, ...)
	end
	function META:SetDataAsInt(...)
		return lib.btDbvtNode_setDataAsInt(self, ...)
	end
	function META:SetData(...)
		return lib.btDbvtNode_setData(self, ...)
	end
	function META:Delete(...)
		return lib.btDbvtNode_delete(self, ...)
	end
	function META:SetParent(...)
		return lib.btDbvtNode_setParent(self, ...)
	end
	function META:GetChilds(...)
		return lib.btDbvtNode_getChilds(self, ...)
	end
	function META:GetData(...)
		return lib.btDbvtNode_getData(self, ...)
	end
	function META:GetParent(...)
		return lib.btDbvtNode_getParent(self, ...)
	end
	function META:GetDataAsInt(...)
		return lib.btDbvtNode_getDataAsInt(self, ...)
	end
	function META:Isleaf(...)
		return lib.btDbvtNode_isleaf(self, ...)
	end
	ffi.metatype('btDbvtNode', META)
	function bullet.CreateDbvtNode(...)
		return lib.btDbvtNode_new(...)
	end
end
do -- WorldImporter
	local META = {}
	META.__index = META
	function META:CreateConeTwistConstraint(...)
		return lib.btWorldImporter_createConeTwistConstraint(self, ...)
	end
	function META:CreateCollisionObject(...)
		return lib.btWorldImporter_createCollisionObject(self, ...)
	end
	function META:CreateGeneric6DofConstraint2(...)
		return lib.btWorldImporter_createGeneric6DofConstraint2(self, ...)
	end
	function META:CreatePoint2PointConstraint(...)
		return lib.btWorldImporter_createPoint2PointConstraint(self, ...)
	end
	function META:CreateSphereShape(...)
		return lib.btWorldImporter_createSphereShape(self, ...)
	end
	function META:Delete(...)
		return lib.btWorldImporter_delete(self, ...)
	end
	function META:CreateCompoundShape(...)
		return lib.btWorldImporter_createCompoundShape(self, ...)
	end
	function META:GetNumTriangleInfoMaps(...)
		return lib.btWorldImporter_getNumTriangleInfoMaps(self, ...)
	end
	function META:SetVerboseMode(...)
		return lib.btWorldImporter_setVerboseMode(self, ...)
	end
	function META:CreatePoint2PointConstraint2(...)
		return lib.btWorldImporter_createPoint2PointConstraint2(self, ...)
	end
	function META:CreateRigidBody(...)
		return lib.btWorldImporter_createRigidBody(self, ...)
	end
	function META:SetDynamicsWorldInfo(...)
		return lib.btWorldImporter_setDynamicsWorldInfo(self, ...)
	end
	function META:CreateConeShapeY(...)
		return lib.btWorldImporter_createConeShapeY(self, ...)
	end
	function META:GetNumRigidBodies(...)
		return lib.btWorldImporter_getNumRigidBodies(self, ...)
	end
	function META:GetNumConstraints(...)
		return lib.btWorldImporter_getNumConstraints(self, ...)
	end
	function META:GetConstraintByIndex(...)
		return lib.btWorldImporter_getConstraintByIndex(self, ...)
	end
	function META:GetTriangleInfoMapByIndex(...)
		return lib.btWorldImporter_getTriangleInfoMapByIndex(self, ...)
	end
	function META:CreateConvexTriangleMeshShape(...)
		return lib.btWorldImporter_createConvexTriangleMeshShape(self, ...)
	end
	function META:GetRigidBodyByName(...)
		return lib.btWorldImporter_getRigidBodyByName(self, ...)
	end
	function META:CreateMultiSphereShape(...)
		return lib.btWorldImporter_createMultiSphereShape(self, ...)
	end
	function META:GetVerboseMode(...)
		return lib.btWorldImporter_getVerboseMode(self, ...)
	end
	function META:CreateGimpactShape(...)
		return lib.btWorldImporter_createGimpactShape(self, ...)
	end
	function META:GetRigidBodyByIndex(...)
		return lib.btWorldImporter_getRigidBodyByIndex(self, ...)
	end
	function META:GetNumCollisionShapes(...)
		return lib.btWorldImporter_getNumCollisionShapes(self, ...)
	end
	function META:CreateMeshInterface(...)
		return lib.btWorldImporter_createMeshInterface(self, ...)
	end
	function META:CreateOptimizedBvh(...)
		return lib.btWorldImporter_createOptimizedBvh(self, ...)
	end
	function META:CreateGeneric6DofConstraint(...)
		return lib.btWorldImporter_createGeneric6DofConstraint(self, ...)
	end
	function META:GetNameForPointer(...)
		return lib.btWorldImporter_getNameForPointer(self, ...)
	end
	function META:CreateTriangleMeshContainer(...)
		return lib.btWorldImporter_createTriangleMeshContainer(self, ...)
	end
	function META:CreateBvhTriangleMeshShape(...)
		return lib.btWorldImporter_createBvhTriangleMeshShape(self, ...)
	end
	function META:CreateCapsuleShapeX(...)
		return lib.btWorldImporter_createCapsuleShapeX(self, ...)
	end
	function META:GetCollisionShapeByName(...)
		return lib.btWorldImporter_getCollisionShapeByName(self, ...)
	end
	function META:CreateCapsuleShapeY(...)
		return lib.btWorldImporter_createCapsuleShapeY(self, ...)
	end
	function META:GetCollisionShapeByIndex(...)
		return lib.btWorldImporter_getCollisionShapeByIndex(self, ...)
	end
	function META:CreateConeShapeX(...)
		return lib.btWorldImporter_createConeShapeX(self, ...)
	end
	function META:GetBvhByIndex(...)
		return lib.btWorldImporter_getBvhByIndex(self, ...)
	end
	function META:CreateCylinderShapeX(...)
		return lib.btWorldImporter_createCylinderShapeX(self, ...)
	end
	function META:DeleteAllData(...)
		return lib.btWorldImporter_deleteAllData(self, ...)
	end
	function META:GetConstraintByName(...)
		return lib.btWorldImporter_getConstraintByName(self, ...)
	end
	function META:CreateGearConstraint(...)
		return lib.btWorldImporter_createGearConstraint(self, ...)
	end
	function META:CreateTriangleInfoMap(...)
		return lib.btWorldImporter_createTriangleInfoMap(self, ...)
	end
	function META:CreateHingeConstraint(...)
		return lib.btWorldImporter_createHingeConstraint(self, ...)
	end
	function META:CreateConeTwistConstraint2(...)
		return lib.btWorldImporter_createConeTwistConstraint2(self, ...)
	end
	function META:CreateCapsuleShapeZ(...)
		return lib.btWorldImporter_createCapsuleShapeZ(self, ...)
	end
	function META:CreateCylinderShapeZ(...)
		return lib.btWorldImporter_createCylinderShapeZ(self, ...)
	end
	function META:CreateConvexHullShape(...)
		return lib.btWorldImporter_createConvexHullShape(self, ...)
	end
	function META:CreateBoxShape(...)
		return lib.btWorldImporter_createBoxShape(self, ...)
	end
	function META:CreateSliderConstraint(...)
		return lib.btWorldImporter_createSliderConstraint(self, ...)
	end
	function META:CreateHingeConstraint3(...)
		return lib.btWorldImporter_createHingeConstraint3(self, ...)
	end
	function META:CreateScaledTrangleMeshShape(...)
		return lib.btWorldImporter_createScaledTrangleMeshShape(self, ...)
	end
	function META:CreateCylinderShapeY(...)
		return lib.btWorldImporter_createCylinderShapeY(self, ...)
	end
	function META:CreateSliderConstraint2(...)
		return lib.btWorldImporter_createSliderConstraint2(self, ...)
	end
	function META:CreateGeneric6DofSpringConstraint(...)
		return lib.btWorldImporter_createGeneric6DofSpringConstraint(self, ...)
	end
	function META:CreateConeShapeZ(...)
		return lib.btWorldImporter_createConeShapeZ(self, ...)
	end
	function META:CreateStridingMeshInterfaceData(...)
		return lib.btWorldImporter_createStridingMeshInterfaceData(self, ...)
	end
	function META:GetNumBvhs(...)
		return lib.btWorldImporter_getNumBvhs(self, ...)
	end
	function META:CreateGeneric6DofSpring2Constraint(...)
		return lib.btWorldImporter_createGeneric6DofSpring2Constraint(self, ...)
	end
	function META:CreatePlaneShape(...)
		return lib.btWorldImporter_createPlaneShape(self, ...)
	end
	function META:CreateHingeConstraint2(...)
		return lib.btWorldImporter_createHingeConstraint2(self, ...)
	end
	function META:CreateHingeConstraint4(...)
		return lib.btWorldImporter_createHingeConstraint4(self, ...)
	end
	ffi.metatype('btWorldImporter', META)
	function bullet.CreateWorldImporter(...)
		return lib.btWorldImporter_new(...)
	end
end
do -- ConvexConcaveCollisionAlgorithm_SwappedCreateFunc
	local META = {}
	META.__index = META
	ffi.metatype('btConvexConcaveCollisionAlgorithm_SwappedCreateFunc', META)
	function bullet.CreateConvexConcaveCollisionAlgorithm_SwappedCreateFunc(...)
		return lib.btConvexConcaveCollisionAlgorithm_SwappedCreateFunc_new(...)
	end
end
do -- ConvexPointCloudShape
	local META = {}
	META.__index = META
	function META:GetNumPoints(...)
		return lib.btConvexPointCloudShape_getNumPoints(self, ...)
	end
	function META:SetPoints2(...)
		return lib.btConvexPointCloudShape_setPoints2(self, ...)
	end
	function META:SetPoints3(...)
		return lib.btConvexPointCloudShape_setPoints3(self, ...)
	end
	function META:GetUnscaledPoints(...)
		return lib.btConvexPointCloudShape_getUnscaledPoints(self, ...)
	end
	function META:SetPoints(...)
		return lib.btConvexPointCloudShape_setPoints(self, ...)
	end
	function META:GetScaledPoint(...)
		return lib.btConvexPointCloudShape_getScaledPoint(self, ...)
	end
	ffi.metatype('btConvexPointCloudShape', META)
	function bullet.CreateConvexPointCloudShape3(...)
		return lib.btConvexPointCloudShape_new3(...)
	end
	function bullet.CreateConvexPointCloudShape(...)
		return lib.btConvexPointCloudShape_new(...)
	end
	function bullet.CreateConvexPointCloudShape2(...)
		return lib.btConvexPointCloudShape_new2(...)
	end
end
do -- CollisionDispatcher
	local META = {}
	META.__index = META
	function META:GetNearCallback(...)
		return lib.btCollisionDispatcher_getNearCallback(self, ...)
	end
	function META:GetCollisionConfiguration(...)
		return lib.btCollisionDispatcher_getCollisionConfiguration(self, ...)
	end
	function META:GetDispatcherFlags(...)
		return lib.btCollisionDispatcher_getDispatcherFlags(self, ...)
	end
	function META:SetCollisionConfiguration(...)
		return lib.btCollisionDispatcher_setCollisionConfiguration(self, ...)
	end
	function META:SetNearCallback(...)
		return lib.btCollisionDispatcher_setNearCallback(self, ...)
	end
	function META:RegisterCollisionCreateFunc(...)
		return lib.btCollisionDispatcher_registerCollisionCreateFunc(self, ...)
	end
	function META:SetDispatcherFlags(...)
		return lib.btCollisionDispatcher_setDispatcherFlags(self, ...)
	end
	function META:DefaultNearCallback(...)
		return lib.btCollisionDispatcher_defaultNearCallback(self, ...)
	end
	ffi.metatype('btCollisionDispatcher', META)
	function bullet.CreateCollisionDispatcher(...)
		return lib.btCollisionDispatcher_new(...)
	end
end
do -- SoftBody_RContact
	local META = {}
	META.__index = META
	function META:GetC3(...)
		return lib.btSoftBody_RContact_getC3(self, ...)
	end
	function META:GetC0(...)
		return lib.btSoftBody_RContact_getC0(self, ...)
	end
	function META:SetC2(...)
		return lib.btSoftBody_RContact_setC2(self, ...)
	end
	function META:SetNode(...)
		return lib.btSoftBody_RContact_setNode(self, ...)
	end
	function META:GetNode(...)
		return lib.btSoftBody_RContact_getNode(self, ...)
	end
	function META:Delete(...)
		return lib.btSoftBody_RContact_delete(self, ...)
	end
	function META:SetC4(...)
		return lib.btSoftBody_RContact_setC4(self, ...)
	end
	function META:GetCti(...)
		return lib.btSoftBody_RContact_getCti(self, ...)
	end
	function META:GetC4(...)
		return lib.btSoftBody_RContact_getC4(self, ...)
	end
	function META:SetC1(...)
		return lib.btSoftBody_RContact_setC1(self, ...)
	end
	function META:GetC1(...)
		return lib.btSoftBody_RContact_getC1(self, ...)
	end
	function META:GetC2(...)
		return lib.btSoftBody_RContact_getC2(self, ...)
	end
	function META:SetC3(...)
		return lib.btSoftBody_RContact_setC3(self, ...)
	end
	function META:SetC0(...)
		return lib.btSoftBody_RContact_setC0(self, ...)
	end
	ffi.metatype('btSoftBody_RContact', META)
	function bullet.CreateSoftBody_RContact(...)
		return lib.btSoftBody_RContact_new(...)
	end
end
do -- MultiBodyConstraintSolver
	local META = {}
	META.__index = META
	function META:SolveMultiBodyGroup(...)
		return lib.btMultiBodyConstraintSolver_solveMultiBodyGroup(self, ...)
	end
	function META:SolveGroupCacheFriendlyFinish(...)
		return lib.btMultiBodyConstraintSolver_solveGroupCacheFriendlyFinish(self, ...)
	end
	ffi.metatype('btMultiBodyConstraintSolver', META)
	function bullet.CreateMultiBodyConstraintSolver(...)
		return lib.btMultiBodyConstraintSolver_new(...)
	end
end
do -- Dbvt_sStkNPS
	local META = {}
	META.__index = META
	function META:SetValue(...)
		return lib.btDbvt_sStkNPS_setValue(self, ...)
	end
	function META:Delete(...)
		return lib.btDbvt_sStkNPS_delete(self, ...)
	end
	function META:SetNode(...)
		return lib.btDbvt_sStkNPS_setNode(self, ...)
	end
	function META:GetValue(...)
		return lib.btDbvt_sStkNPS_getValue(self, ...)
	end
	function META:GetMask(...)
		return lib.btDbvt_sStkNPS_getMask(self, ...)
	end
	function META:GetNode(...)
		return lib.btDbvt_sStkNPS_getNode(self, ...)
	end
	function META:SetMask(...)
		return lib.btDbvt_sStkNPS_setMask(self, ...)
	end
	ffi.metatype('btDbvt_sStkNPS', META)
	function bullet.CreateDbvt_sStkNPS2(...)
		return lib.btDbvt_sStkNPS_new2(...)
	end
	function bullet.CreateDbvt_sStkNPS(...)
		return lib.btDbvt_sStkNPS_new(...)
	end
end
do -- UsageBitfield
	local META = {}
	META.__index = META
	function META:SetUsedVertexC(...)
		return lib.btUsageBitfield_setUsedVertexC(self, ...)
	end
	function META:GetUsedVertexB(...)
		return lib.btUsageBitfield_getUsedVertexB(self, ...)
	end
	function META:GetUsedVertexC(...)
		return lib.btUsageBitfield_getUsedVertexC(self, ...)
	end
	function META:SetUnused1(...)
		return lib.btUsageBitfield_setUnused1(self, ...)
	end
	function META:SetUnused2(...)
		return lib.btUsageBitfield_setUnused2(self, ...)
	end
	function META:GetUnused1(...)
		return lib.btUsageBitfield_getUnused1(self, ...)
	end
	function META:GetUnused2(...)
		return lib.btUsageBitfield_getUnused2(self, ...)
	end
	function META:SetUnused3(...)
		return lib.btUsageBitfield_setUnused3(self, ...)
	end
	function META:SetUnused4(...)
		return lib.btUsageBitfield_setUnused4(self, ...)
	end
	function META:GetUnused3(...)
		return lib.btUsageBitfield_getUnused3(self, ...)
	end
	function META:Delete(...)
		return lib.btUsageBitfield_delete(self, ...)
	end
	function META:GetUnused4(...)
		return lib.btUsageBitfield_getUnused4(self, ...)
	end
	function META:SetUsedVertexD(...)
		return lib.btUsageBitfield_setUsedVertexD(self, ...)
	end
	function META:GetUsedVertexA(...)
		return lib.btUsageBitfield_getUsedVertexA(self, ...)
	end
	function META:Reset(...)
		return lib.btUsageBitfield_reset(self, ...)
	end
	function META:SetUsedVertexA(...)
		return lib.btUsageBitfield_setUsedVertexA(self, ...)
	end
	function META:GetUsedVertexD(...)
		return lib.btUsageBitfield_getUsedVertexD(self, ...)
	end
	function META:SetUsedVertexB(...)
		return lib.btUsageBitfield_setUsedVertexB(self, ...)
	end
	ffi.metatype('btUsageBitfield', META)
	function bullet.CreateUsageBitfield(...)
		return lib.btUsageBitfield_new(...)
	end
end
do -- BoxBoxCollisionAlgorithm_CreateFunc
	local META = {}
	META.__index = META
	ffi.metatype('btBoxBoxCollisionAlgorithm_CreateFunc', META)
	function bullet.CreateBoxBoxCollisionAlgorithm_CreateFunc(...)
		return lib.btBoxBoxCollisionAlgorithm_CreateFunc_new(...)
	end
end
do -- PairCachingGhostObject
	local META = {}
	META.__index = META
	function META:GetOverlappingPairCache(...)
		return lib.btPairCachingGhostObject_getOverlappingPairCache(self, ...)
	end
	ffi.metatype('btPairCachingGhostObject', META)
	function bullet.CreatePairCachingGhostObject(...)
		return lib.btPairCachingGhostObject_new(...)
	end
end
do -- SoftBody_Note
	local META = {}
	META.__index = META
	function META:GetRank(...)
		return lib.btSoftBody_Note_getRank(self, ...)
	end
	function META:GetOffset(...)
		return lib.btSoftBody_Note_getOffset(self, ...)
	end
	function META:SetText(...)
		return lib.btSoftBody_Note_setText(self, ...)
	end
	function META:GetCoords(...)
		return lib.btSoftBody_Note_getCoords(self, ...)
	end
	function META:GetText(...)
		return lib.btSoftBody_Note_getText(self, ...)
	end
	function META:SetOffset(...)
		return lib.btSoftBody_Note_setOffset(self, ...)
	end
	function META:SetRank(...)
		return lib.btSoftBody_Note_setRank(self, ...)
	end
	function META:GetNodes(...)
		return lib.btSoftBody_Note_getNodes(self, ...)
	end
	ffi.metatype('btSoftBody_Note', META)
	function bullet.CreateSoftBody_Note(...)
		return lib.btSoftBody_Note_new(...)
	end
end
do -- ConvexHullShape
	local META = {}
	META.__index = META
	function META:AddPoint(...)
		return lib.btConvexHullShape_addPoint(self, ...)
	end
	function META:GetPoints(...)
		return lib.btConvexHullShape_getPoints(self, ...)
	end
	function META:GetNumPoints(...)
		return lib.btConvexHullShape_getNumPoints(self, ...)
	end
	function META:GetScaledPoint(...)
		return lib.btConvexHullShape_getScaledPoint(self, ...)
	end
	function META:GetUnscaledPoints(...)
		return lib.btConvexHullShape_getUnscaledPoints(self, ...)
	end
	function META:AddPoint2(...)
		return lib.btConvexHullShape_addPoint2(self, ...)
	end
	function META:Project(...)
		return lib.btConvexHullShape_project(self, ...)
	end
	ffi.metatype('btConvexHullShape', META)
	function bullet.CreateConvexHullShape4(...)
		return lib.btConvexHullShape_new4(...)
	end
	function bullet.CreateConvexHullShape2(...)
		return lib.btConvexHullShape_new2(...)
	end
	function bullet.CreateConvexHullShape(...)
		return lib.btConvexHullShape_new(...)
	end
	function bullet.CreateConvexHullShape3(...)
		return lib.btConvexHullShape_new3(...)
	end
end
do -- Dbvt_sStkNN
	local META = {}
	META.__index = META
	function META:GetA(...)
		return lib.btDbvt_sStkNN_getA(self, ...)
	end
	function META:GetB(...)
		return lib.btDbvt_sStkNN_getB(self, ...)
	end
	function META:SetA(...)
		return lib.btDbvt_sStkNN_setA(self, ...)
	end
	function META:SetB(...)
		return lib.btDbvt_sStkNN_setB(self, ...)
	end
	function META:Delete(...)
		return lib.btDbvt_sStkNN_delete(self, ...)
	end
	ffi.metatype('btDbvt_sStkNN', META)
	function bullet.CreateDbvt_sStkNN(...)
		return lib.btDbvt_sStkNN_new(...)
	end
	function bullet.CreateDbvt_sStkNN2(...)
		return lib.btDbvt_sStkNN_new2(...)
	end
end
do -- SoftBody_sRayCast
	local META = {}
	META.__index = META
	function META:SetIndex(...)
		return lib.btSoftBody_sRayCast_setIndex(self, ...)
	end
	function META:SetFraction(...)
		return lib.btSoftBody_sRayCast_setFraction(self, ...)
	end
	function META:GetIndex(...)
		return lib.btSoftBody_sRayCast_getIndex(self, ...)
	end
	function META:GetFraction(...)
		return lib.btSoftBody_sRayCast_getFraction(self, ...)
	end
	function META:Delete(...)
		return lib.btSoftBody_sRayCast_delete(self, ...)
	end
	function META:GetBody(...)
		return lib.btSoftBody_sRayCast_getBody(self, ...)
	end
	function META:GetFeature(...)
		return lib.btSoftBody_sRayCast_getFeature(self, ...)
	end
	function META:SetFeature(...)
		return lib.btSoftBody_sRayCast_setFeature(self, ...)
	end
	function META:SetBody(...)
		return lib.btSoftBody_sRayCast_setBody(self, ...)
	end
	ffi.metatype('btSoftBody_sRayCast', META)
	function bullet.CreateSoftBody_sRayCast(...)
		return lib.btSoftBody_sRayCast_new(...)
	end
end
do -- CompoundCompoundCollisionAlgorithm_SwappedCreateFunc
	local META = {}
	META.__index = META
	ffi.metatype('btCompoundCompoundCollisionAlgorithm_SwappedCreateFunc', META)
	function bullet.CreateCompoundCompoundCollisionAlgorithm_SwappedCreateFunc(...)
		return lib.btCompoundCompoundCollisionAlgorithm_SwappedCreateFunc_new(...)
	end
end
do -- Generic6DofSpring2Constraint
	local META = {}
	META.__index = META
	function META:SetTargetVelocity(...)
		return lib.btGeneric6DofSpring2Constraint_setTargetVelocity(self, ...)
	end
	function META:GetFrameOffsetA(...)
		return lib.btGeneric6DofSpring2Constraint_getFrameOffsetA(self, ...)
	end
	function META:CalculateTransforms(...)
		return lib.btGeneric6DofSpring2Constraint_calculateTransforms(self, ...)
	end
	function META:SetStiffness(...)
		return lib.btGeneric6DofSpring2Constraint_setStiffness(self, ...)
	end
	function META:SetAngularLowerLimitReversed(...)
		return lib.btGeneric6DofSpring2Constraint_setAngularLowerLimitReversed(self, ...)
	end
	function META:SetAngularLowerLimit(...)
		return lib.btGeneric6DofSpring2Constraint_setAngularLowerLimit(self, ...)
	end
	function META:SetFrames(...)
		return lib.btGeneric6DofSpring2Constraint_setFrames(self, ...)
	end
	function META:EnableMotor(...)
		return lib.btGeneric6DofSpring2Constraint_enableMotor(self, ...)
	end
	function META:GetTranslationalLimitMotor(...)
		return lib.btGeneric6DofSpring2Constraint_getTranslationalLimitMotor(self, ...)
	end
	function META:SetRotationOrder(...)
		return lib.btGeneric6DofSpring2Constraint_setRotationOrder(self, ...)
	end
	function META:SetEquilibriumPoint(...)
		return lib.btGeneric6DofSpring2Constraint_setEquilibriumPoint(self, ...)
	end
	function META:IsLimited(...)
		return lib.btGeneric6DofSpring2Constraint_isLimited(self, ...)
	end
	function META:GetCalculatedTransformA(...)
		return lib.btGeneric6DofSpring2Constraint_getCalculatedTransformA(self, ...)
	end
	function META:GetAngularUpperLimitReversed(...)
		return lib.btGeneric6DofSpring2Constraint_getAngularUpperLimitReversed(self, ...)
	end
	function META:SetAngularUpperLimit(...)
		return lib.btGeneric6DofSpring2Constraint_setAngularUpperLimit(self, ...)
	end
	function META:SetAngularUpperLimitReversed(...)
		return lib.btGeneric6DofSpring2Constraint_setAngularUpperLimitReversed(self, ...)
	end
	function META:GetCalculatedTransformB(...)
		return lib.btGeneric6DofSpring2Constraint_getCalculatedTransformB(self, ...)
	end
	function META:SetDamping(...)
		return lib.btGeneric6DofSpring2Constraint_setDamping(self, ...)
	end
	function META:SetLimitReversed(...)
		return lib.btGeneric6DofSpring2Constraint_setLimitReversed(self, ...)
	end
	function META:GetRotationOrder(...)
		return lib.btGeneric6DofSpring2Constraint_getRotationOrder(self, ...)
	end
	function META:SetEquilibriumPoint2(...)
		return lib.btGeneric6DofSpring2Constraint_setEquilibriumPoint2(self, ...)
	end
	function META:GetLinearLowerLimit(...)
		return lib.btGeneric6DofSpring2Constraint_getLinearLowerLimit(self, ...)
	end
	function META:SetEquilibriumPoint3(...)
		return lib.btGeneric6DofSpring2Constraint_setEquilibriumPoint3(self, ...)
	end
	function META:GetRelativePivotPosition(...)
		return lib.btGeneric6DofSpring2Constraint_getRelativePivotPosition(self, ...)
	end
	function META:SetBounce(...)
		return lib.btGeneric6DofSpring2Constraint_setBounce(self, ...)
	end
	function META:GetRotationalLimitMotor(...)
		return lib.btGeneric6DofSpring2Constraint_getRotationalLimitMotor(self, ...)
	end
	function META:SetServoTarget(...)
		return lib.btGeneric6DofSpring2Constraint_setServoTarget(self, ...)
	end
	function META:GetFrameOffsetB(...)
		return lib.btGeneric6DofSpring2Constraint_getFrameOffsetB(self, ...)
	end
	function META:SetServo(...)
		return lib.btGeneric6DofSpring2Constraint_setServo(self, ...)
	end
	function META:GetAngularLowerLimitReversed(...)
		return lib.btGeneric6DofSpring2Constraint_getAngularLowerLimitReversed(self, ...)
	end
	function META:SetLinearUpperLimit(...)
		return lib.btGeneric6DofSpring2Constraint_setLinearUpperLimit(self, ...)
	end
	function META:GetAngularLowerLimit(...)
		return lib.btGeneric6DofSpring2Constraint_getAngularLowerLimit(self, ...)
	end
	function META:GetAngularUpperLimit(...)
		return lib.btGeneric6DofSpring2Constraint_getAngularUpperLimit(self, ...)
	end
	function META:GetAngle(...)
		return lib.btGeneric6DofSpring2Constraint_getAngle(self, ...)
	end
	function META:SetLimit(...)
		return lib.btGeneric6DofSpring2Constraint_setLimit(self, ...)
	end
	function META:CalculateTransforms2(...)
		return lib.btGeneric6DofSpring2Constraint_calculateTransforms2(self, ...)
	end
	function META:GetAxis(...)
		return lib.btGeneric6DofSpring2Constraint_getAxis(self, ...)
	end
	function META:SetMaxMotorForce(...)
		return lib.btGeneric6DofSpring2Constraint_setMaxMotorForce(self, ...)
	end
	function META:SetLinearLowerLimit(...)
		return lib.btGeneric6DofSpring2Constraint_setLinearLowerLimit(self, ...)
	end
	function META:EnableSpring(...)
		return lib.btGeneric6DofSpring2Constraint_enableSpring(self, ...)
	end
	function META:GetLinearUpperLimit(...)
		return lib.btGeneric6DofSpring2Constraint_getLinearUpperLimit(self, ...)
	end
	function META:SetAxis(...)
		return lib.btGeneric6DofSpring2Constraint_setAxis(self, ...)
	end
	ffi.metatype('btGeneric6DofSpring2Constraint', META)
	function bullet.CreateGeneric6DofSpring2Constraint3(...)
		return lib.btGeneric6DofSpring2Constraint_new3(...)
	end
	function bullet.CreateGeneric6DofSpring2Constraint4(...)
		return lib.btGeneric6DofSpring2Constraint_new4(...)
	end
	function bullet.CreateGeneric6DofSpring2Constraint2(...)
		return lib.btGeneric6DofSpring2Constraint_new2(...)
	end
end
do -- CollisionAlgorithmCreateFunc
	local META = {}
	META.__index = META
	function META:Delete(...)
		return lib.btCollisionAlgorithmCreateFunc_delete(self, ...)
	end
	function META:CreateCollisionAlgorithm(...)
		return lib.btCollisionAlgorithmCreateFunc_CreateCollisionAlgorithm(self, ...)
	end
	function META:SetSwapped(...)
		return lib.btCollisionAlgorithmCreateFunc_setSwapped(self, ...)
	end
	function META:GetSwapped(...)
		return lib.btCollisionAlgorithmCreateFunc_getSwapped(self, ...)
	end
	ffi.metatype('btCollisionAlgorithmCreateFunc', META)
	function bullet.CreateCollisionAlgorithmCreateFunc(...)
		return lib.btCollisionAlgorithmCreateFunc_new(...)
	end
end
do -- MultiBodyJointMotor
	local META = {}
	META.__index = META
	function META:SetVelocityTarget(...)
		return lib.btMultiBodyJointMotor_setVelocityTarget(self, ...)
	end
	ffi.metatype('btMultiBodyJointMotor', META)
	function bullet.CreateMultiBodyJointMotor2(...)
		return lib.btMultiBodyJointMotor_new2(...)
	end
	function bullet.CreateMultiBodyJointMotor(...)
		return lib.btMultiBodyJointMotor_new(...)
	end
end
do -- GearConstraint
	local META = {}
	META.__index = META
	function META:SetAxisA(...)
		return lib.btGearConstraint_setAxisA(self, ...)
	end
	function META:GetRatio(...)
		return lib.btGearConstraint_getRatio(self, ...)
	end
	function META:GetAxisA(...)
		return lib.btGearConstraint_getAxisA(self, ...)
	end
	function META:SetRatio(...)
		return lib.btGearConstraint_setRatio(self, ...)
	end
	function META:GetAxisB(...)
		return lib.btGearConstraint_getAxisB(self, ...)
	end
	function META:SetAxisB(...)
		return lib.btGearConstraint_setAxisB(self, ...)
	end
	ffi.metatype('btGearConstraint', META)
	function bullet.CreateGearConstraint2(...)
		return lib.btGearConstraint_new2(...)
	end
	function bullet.CreateGearConstraint(...)
		return lib.btGearConstraint_new(...)
	end
end
do -- DefaultMotionState
	local META = {}
	META.__index = META
	function META:GetUserPointer(...)
		return lib.btDefaultMotionState_getUserPointer(self, ...)
	end
	function META:SetGraphicsWorldTrans(...)
		return lib.btDefaultMotionState_setGraphicsWorldTrans(self, ...)
	end
	function META:SetStartWorldTrans(...)
		return lib.btDefaultMotionState_setStartWorldTrans(self, ...)
	end
	function META:GetCenterOfMassOffset(...)
		return lib.btDefaultMotionState_getCenterOfMassOffset(self, ...)
	end
	function META:SetUserPointer(...)
		return lib.btDefaultMotionState_setUserPointer(self, ...)
	end
	function META:SetCenterOfMassOffset(...)
		return lib.btDefaultMotionState_setCenterOfMassOffset(self, ...)
	end
	function META:GetGraphicsWorldTrans(...)
		return lib.btDefaultMotionState_getGraphicsWorldTrans(self, ...)
	end
	function META:GetStartWorldTrans(...)
		return lib.btDefaultMotionState_getStartWorldTrans(self, ...)
	end
	ffi.metatype('btDefaultMotionState', META)
	function bullet.CreateDefaultMotionState2(...)
		return lib.btDefaultMotionState_new2(...)
	end
	function bullet.CreateDefaultMotionState3(...)
		return lib.btDefaultMotionState_new3(...)
	end
	function bullet.CreateDefaultMotionState(...)
		return lib.btDefaultMotionState_new(...)
	end
end
do -- GImpactCollisionAlgorithm
	local META = {}
	META.__index = META
	function META:GetPart1(...)
		return lib.btGImpactCollisionAlgorithm_getPart1(self, ...)
	end
	function META:SetFace1(...)
		return lib.btGImpactCollisionAlgorithm_setFace1(self, ...)
	end
	function META:GetFace1(...)
		return lib.btGImpactCollisionAlgorithm_getFace1(self, ...)
	end
	function META:GetPart0(...)
		return lib.btGImpactCollisionAlgorithm_getPart0(self, ...)
	end
	function META:RegisterAlgorithm(...)
		return lib.btGImpactCollisionAlgorithm_registerAlgorithm(self, ...)
	end
	function META:SetPart1(...)
		return lib.btGImpactCollisionAlgorithm_setPart1(self, ...)
	end
	function META:SetFace0(...)
		return lib.btGImpactCollisionAlgorithm_setFace0(self, ...)
	end
	function META:SetPart0(...)
		return lib.btGImpactCollisionAlgorithm_setPart0(self, ...)
	end
	function META:GetFace0(...)
		return lib.btGImpactCollisionAlgorithm_getFace0(self, ...)
	end
	function META:InternalGetResultOut(...)
		return lib.btGImpactCollisionAlgorithm_internalGetResultOut(self, ...)
	end
	ffi.metatype('btGImpactCollisionAlgorithm', META)
	function bullet.CreateGImpactCollisionAlgorithm(...)
		return lib.btGImpactCollisionAlgorithm_new(...)
	end
end
do -- DefaultSerializer
	local META = {}
	META.__index = META
	function META:WriteHeader(...)
		return lib.btDefaultSerializer_writeHeader(self, ...)
	end
	function META:InternalAlloc(...)
		return lib.btDefaultSerializer_internalAlloc(self, ...)
	end
	ffi.metatype('btDefaultSerializer', META)
	function bullet.CreateDefaultSerializer2(...)
		return lib.btDefaultSerializer_new2(...)
	end
	function bullet.CreateDefaultSerializer(...)
		return lib.btDefaultSerializer_new(...)
	end
end
do -- CollisionWorld_RayResultCallbackWrapper
	local META = {}
	META.__index = META
	function META:NeedsCollision(...)
		return lib.btCollisionWorld_RayResultCallbackWrapper_needsCollision(self, ...)
	end
	ffi.metatype('btCollisionWorld_RayResultCallbackWrapper', META)
	function bullet.CreateCollisionWorld_RayResultCallbackWrapper(...)
		return lib.btCollisionWorld_RayResultCallbackWrapper_new(...)
	end
end
do -- BroadphaseAabbCallbackWrapper
	local META = {}
	META.__index = META
	ffi.metatype('btBroadphaseAabbCallbackWrapper', META)
	function bullet.CreateBroadphaseAabbCallbackWrapper(...)
		return lib.btBroadphaseAabbCallbackWrapper_new(...)
	end
end
do -- MultiSphereShape
	local META = {}
	META.__index = META
	function META:GetSphereCount(...)
		return lib.btMultiSphereShape_getSphereCount(self, ...)
	end
	function META:GetSphereRadius(...)
		return lib.btMultiSphereShape_getSphereRadius(self, ...)
	end
	function META:GetSpherePosition(...)
		return lib.btMultiSphereShape_getSpherePosition(self, ...)
	end
	ffi.metatype('btMultiSphereShape', META)
	function bullet.CreateMultiSphereShape2(...)
		return lib.btMultiSphereShape_new2(...)
	end
	function bullet.CreateMultiSphereShape(...)
		return lib.btMultiSphereShape_new(...)
	end
end
do -- SoftBody_LJoint_Specs
	local META = {}
	META.__index = META
	function META:SetPosition(...)
		return lib.btSoftBody_LJoint_Specs_setPosition(self, ...)
	end
	function META:GetPosition(...)
		return lib.btSoftBody_LJoint_Specs_getPosition(self, ...)
	end
	ffi.metatype('btSoftBody_LJoint_Specs', META)
	function bullet.CreateSoftBody_LJoint_Specs(...)
		return lib.btSoftBody_LJoint_Specs_new(...)
	end
end
do -- FixedConstraint
	local META = {}
	META.__index = META
	ffi.metatype('btFixedConstraint', META)
	function bullet.CreateFixedConstraint(...)
		return lib.btFixedConstraint_new(...)
	end
end
do -- ConeShapeZ
	local META = {}
	META.__index = META
	ffi.metatype('btConeShapeZ', META)
	function bullet.CreateConeShapeZ(...)
		return lib.btConeShapeZ_new(...)
	end
end
do -- SoftBody_SContact
	local META = {}
	META.__index = META
	function META:SetWeights(...)
		return lib.btSoftBody_SContact_setWeights(self, ...)
	end
	function META:GetCfm(...)
		return lib.btSoftBody_SContact_getCfm(self, ...)
	end
	function META:SetNormal(...)
		return lib.btSoftBody_SContact_setNormal(self, ...)
	end
	function META:SetNode(...)
		return lib.btSoftBody_SContact_setNode(self, ...)
	end
	function META:GetNode(...)
		return lib.btSoftBody_SContact_getNode(self, ...)
	end
	function META:Delete(...)
		return lib.btSoftBody_SContact_delete(self, ...)
	end
	function META:GetNormal(...)
		return lib.btSoftBody_SContact_getNormal(self, ...)
	end
	function META:SetMargin(...)
		return lib.btSoftBody_SContact_setMargin(self, ...)
	end
	function META:SetFriction(...)
		return lib.btSoftBody_SContact_setFriction(self, ...)
	end
	function META:SetFace(...)
		return lib.btSoftBody_SContact_setFace(self, ...)
	end
	function META:GetFriction(...)
		return lib.btSoftBody_SContact_getFriction(self, ...)
	end
	function META:GetWeights(...)
		return lib.btSoftBody_SContact_getWeights(self, ...)
	end
	function META:GetMargin(...)
		return lib.btSoftBody_SContact_getMargin(self, ...)
	end
	function META:GetFace(...)
		return lib.btSoftBody_SContact_getFace(self, ...)
	end
	ffi.metatype('btSoftBody_SContact', META)
	function bullet.CreateSoftBody_SContact(...)
		return lib.btSoftBody_SContact_new(...)
	end
end
do -- HashedOverlappingPairCache
	local META = {}
	META.__index = META
	function META:GetOverlapFilterCallback(...)
		return lib.btHashedOverlappingPairCache_getOverlapFilterCallback(self, ...)
	end
	function META:GetCount(...)
		return lib.btHashedOverlappingPairCache_GetCount(self, ...)
	end
	function META:NeedsBroadphaseCollision(...)
		return lib.btHashedOverlappingPairCache_needsBroadphaseCollision(self, ...)
	end
	ffi.metatype('btHashedOverlappingPairCache', META)
	function bullet.CreateHashedOverlappingPairCache(...)
		return lib.btHashedOverlappingPairCache_new(...)
	end
end
do -- GIM_PAIR
	local META = {}
	META.__index = META
	ffi.metatype('GIM_PAIR', META)
	function bullet.CreateGIM_PAIR3(...)
		return lib.GIM_PAIR_new3(...)
	end
	function bullet.CreateGIM_PAIR(...)
		return lib.GIM_PAIR_new(...)
	end
	function bullet.CreateGIM_PAIR2(...)
		return lib.GIM_PAIR_new2(...)
	end
end
do -- EmptyAlgorithm
	local META = {}
	META.__index = META
	ffi.metatype('btEmptyAlgorithm', META)
	function bullet.CreateEmptyAlgorithm(...)
		return lib.btEmptyAlgorithm_new(...)
	end
end
do -- SoftBody_AJoint_IControl
	local META = {}
	META.__index = META
	function META:Prepare(...)
		return lib.btSoftBody_AJoint_IControl_Prepare(self, ...)
	end
	function META:Delete(...)
		return lib.btSoftBody_AJoint_IControl_delete(self, ...)
	end
	function META:Speed(...)
		return lib.btSoftBody_AJoint_IControl_Speed(self, ...)
	end
	function META:Default(...)
		return lib.btSoftBody_AJoint_IControl_Default(self, ...)
	end
	ffi.metatype('btSoftBody_AJoint_IControl', META)
	function bullet.CreateSoftBody_AJoint_IControl(...)
		return lib.btSoftBody_AJoint_IControl_new(...)
	end
end
do -- SoftRigidCollisionAlgorithm
	local META = {}
	META.__index = META
	ffi.metatype('btSoftRigidCollisionAlgorithm', META)
	function bullet.CreateSoftRigidCollisionAlgorithm(...)
		return lib.btSoftRigidCollisionAlgorithm_new(...)
	end
end
do -- 32BitAxisSweep3
	local META = {}
	META.__index = META
	function META:AddHandle(...)
		return lib.bt32BitAxisSweep3_addHandle(self, ...)
	end
	function META:Quantize(...)
		return lib.bt32BitAxisSweep3_quantize(self, ...)
	end
	function META:TestAabbOverlap(...)
		return lib.bt32BitAxisSweep3_testAabbOverlap(self, ...)
	end
	function META:GetNumHandles(...)
		return lib.bt32BitAxisSweep3_getNumHandles(self, ...)
	end
	function META:UnQuantize(...)
		return lib.bt32BitAxisSweep3_unQuantize(self, ...)
	end
	function META:RemoveHandle(...)
		return lib.bt32BitAxisSweep3_removeHandle(self, ...)
	end
	function META:SetOverlappingPairUserCallback(...)
		return lib.bt32BitAxisSweep3_setOverlappingPairUserCallback(self, ...)
	end
	function META:GetHandle(...)
		return lib.bt32BitAxisSweep3_getHandle(self, ...)
	end
	function META:ProcessAllOverlappingPairs(...)
		return lib.bt32BitAxisSweep3_processAllOverlappingPairs(self, ...)
	end
	function META:UpdateHandle(...)
		return lib.bt32BitAxisSweep3_updateHandle(self, ...)
	end
	function META:GetOverlappingPairCache(...)
		return lib.bt32BitAxisSweep3_getOverlappingPairCache(self, ...)
	end
	ffi.metatype('bt32BitAxisSweep3', META)
	function bullet.Create32BitAxisSweep33(...)
		return lib.bt32BitAxisSweep3_new3(...)
	end
	function bullet.Create32BitAxisSweep34(...)
		return lib.bt32BitAxisSweep3_new4(...)
	end
	function bullet.Create32BitAxisSweep32(...)
		return lib.bt32BitAxisSweep3_new2(...)
	end
end
do -- CompoundCollisionAlgorithm_SwappedCreateFunc
	local META = {}
	META.__index = META
	ffi.metatype('btCompoundCollisionAlgorithm_SwappedCreateFunc', META)
	function bullet.CreateCompoundCollisionAlgorithm_SwappedCreateFunc(...)
		return lib.btCompoundCollisionAlgorithm_SwappedCreateFunc_new(...)
	end
end
do -- DiscreteDynamicsWorld
	local META = {}
	META.__index = META
	function META:GetSimulationIslandManager(...)
		return lib.btDiscreteDynamicsWorld_getSimulationIslandManager(self, ...)
	end
	function META:GetSynchronizeAllMotionStates(...)
		return lib.btDiscreteDynamicsWorld_getSynchronizeAllMotionStates(self, ...)
	end
	function META:ApplyGravity(...)
		return lib.btDiscreteDynamicsWorld_applyGravity(self, ...)
	end
	function META:GetApplySpeculativeContactRestitution(...)
		return lib.btDiscreteDynamicsWorld_getApplySpeculativeContactRestitution(self, ...)
	end
	function META:GetLatencyMotionStateInterpolation(...)
		return lib.btDiscreteDynamicsWorld_getLatencyMotionStateInterpolation(self, ...)
	end
	function META:GetCollisionWorld(...)
		return lib.btDiscreteDynamicsWorld_getCollisionWorld(self, ...)
	end
	function META:SetApplySpeculativeContactRestitution(...)
		return lib.btDiscreteDynamicsWorld_setApplySpeculativeContactRestitution(self, ...)
	end
	function META:SynchronizeSingleMotionState(...)
		return lib.btDiscreteDynamicsWorld_synchronizeSingleMotionState(self, ...)
	end
	function META:SetLatencyMotionStateInterpolation(...)
		return lib.btDiscreteDynamicsWorld_setLatencyMotionStateInterpolation(self, ...)
	end
	function META:UpdateVehicles(...)
		return lib.btDiscreteDynamicsWorld_updateVehicles(self, ...)
	end
	function META:SetSynchronizeAllMotionStates(...)
		return lib.btDiscreteDynamicsWorld_setSynchronizeAllMotionStates(self, ...)
	end
	function META:SetNumTasks(...)
		return lib.btDiscreteDynamicsWorld_setNumTasks(self, ...)
	end
	function META:DebugDrawConstraint(...)
		return lib.btDiscreteDynamicsWorld_debugDrawConstraint(self, ...)
	end
	ffi.metatype('btDiscreteDynamicsWorld', META)
	function bullet.CreateDiscreteDynamicsWorld(...)
		return lib.btDiscreteDynamicsWorld_new(...)
	end
end
do -- Dbvt_sStkCLN
	local META = {}
	META.__index = META
	function META:SetParent(...)
		return lib.btDbvt_sStkCLN_setParent(self, ...)
	end
	function META:SetNode(...)
		return lib.btDbvt_sStkCLN_setNode(self, ...)
	end
	function META:GetParent(...)
		return lib.btDbvt_sStkCLN_getParent(self, ...)
	end
	function META:GetNode(...)
		return lib.btDbvt_sStkCLN_getNode(self, ...)
	end
	function META:Delete(...)
		return lib.btDbvt_sStkCLN_delete(self, ...)
	end
	ffi.metatype('btDbvt_sStkCLN', META)
	function bullet.CreateDbvt_sStkCLN(...)
		return lib.btDbvt_sStkCLN_new(...)
	end
end
do -- CollisionWorld
	local META = {}
	META.__index = META
	function META:RayTestSingle(...)
		return lib.btCollisionWorld_rayTestSingle(self, ...)
	end
	function META:Delete(...)
		return lib.btCollisionWorld_delete(self, ...)
	end
	function META:GetForceUpdateAllAabbs(...)
		return lib.btCollisionWorld_getForceUpdateAllAabbs(self, ...)
	end
	function META:UpdateSingleAabb(...)
		return lib.btCollisionWorld_updateSingleAabb(self, ...)
	end
	function META:SetDebugDrawer(...)
		return lib.btCollisionWorld_setDebugDrawer(self, ...)
	end
	function META:AddCollisionObject2(...)
		return lib.btCollisionWorld_addCollisionObject2(self, ...)
	end
	function META:UpdateAabbs(...)
		return lib.btCollisionWorld_updateAabbs(self, ...)
	end
	function META:ContactTest(...)
		return lib.btCollisionWorld_contactTest(self, ...)
	end
	function META:GetCollisionObjectArray(...)
		return lib.btCollisionWorld_getCollisionObjectArray(self, ...)
	end
	function META:ConvexSweepTest2(...)
		return lib.btCollisionWorld_convexSweepTest2(self, ...)
	end
	function META:SetBroadphase(...)
		return lib.btCollisionWorld_setBroadphase(self, ...)
	end
	function META:Serialize(...)
		return lib.btCollisionWorld_serialize(self, ...)
	end
	function META:GetBroadphase(...)
		return lib.btCollisionWorld_getBroadphase(self, ...)
	end
	function META:RemoveCollisionObject(...)
		return lib.btCollisionWorld_removeCollisionObject(self, ...)
	end
	function META:ConvexSweepTest(...)
		return lib.btCollisionWorld_convexSweepTest(self, ...)
	end
	function META:ComputeOverlappingPairs(...)
		return lib.btCollisionWorld_computeOverlappingPairs(self, ...)
	end
	function META:GetDebugDrawer(...)
		return lib.btCollisionWorld_getDebugDrawer(self, ...)
	end
	function META:GetPairCache(...)
		return lib.btCollisionWorld_getPairCache(self, ...)
	end
	function META:RayTest(...)
		return lib.btCollisionWorld_rayTest(self, ...)
	end
	function META:PerformDiscreteCollisionDetection(...)
		return lib.btCollisionWorld_performDiscreteCollisionDetection(self, ...)
	end
	function META:GetNumCollisionObjects(...)
		return lib.btCollisionWorld_getNumCollisionObjects(self, ...)
	end
	function META:GetDispatcher(...)
		return lib.btCollisionWorld_getDispatcher(self, ...)
	end
	function META:SetForceUpdateAllAabbs(...)
		return lib.btCollisionWorld_setForceUpdateAllAabbs(self, ...)
	end
	function META:GetDispatchInfo(...)
		return lib.btCollisionWorld_getDispatchInfo(self, ...)
	end
	function META:ObjectQuerySingle(...)
		return lib.btCollisionWorld_objectQuerySingle(self, ...)
	end
	function META:RayTestSingleInternal(...)
		return lib.btCollisionWorld_rayTestSingleInternal(self, ...)
	end
	function META:ObjectQuerySingleInternal(...)
		return lib.btCollisionWorld_objectQuerySingleInternal(self, ...)
	end
	function META:AddCollisionObject(...)
		return lib.btCollisionWorld_addCollisionObject(self, ...)
	end
	function META:ContactPairTest(...)
		return lib.btCollisionWorld_contactPairTest(self, ...)
	end
	function META:DebugDrawObject(...)
		return lib.btCollisionWorld_debugDrawObject(self, ...)
	end
	function META:DebugDrawWorld(...)
		return lib.btCollisionWorld_debugDrawWorld(self, ...)
	end
	function META:AddCollisionObject3(...)
		return lib.btCollisionWorld_addCollisionObject3(self, ...)
	end
	ffi.metatype('btCollisionWorld', META)
	function bullet.CreateCollisionWorld(...)
		return lib.btCollisionWorld_new(...)
	end
end
do -- CompoundCollisionAlgorithm
	local META = {}
	META.__index = META
	function META:GetChildAlgorithm(...)
		return lib.btCompoundCollisionAlgorithm_getChildAlgorithm(self, ...)
	end
	ffi.metatype('btCompoundCollisionAlgorithm', META)
	function bullet.CreateCompoundCollisionAlgorithm(...)
		return lib.btCompoundCollisionAlgorithm_new(...)
	end
end
do -- DantzigSolver
	local META = {}
	META.__index = META
	ffi.metatype('btDantzigSolver', META)
	function bullet.CreateDantzigSolver(...)
		return lib.btDantzigSolver_new(...)
	end
end
do -- PointCollector
	local META = {}
	META.__index = META
	function META:GetNormalOnBInWorld(...)
		return lib.btPointCollector_getNormalOnBInWorld(self, ...)
	end
	function META:SetDistance(...)
		return lib.btPointCollector_setDistance(self, ...)
	end
	function META:SetPointInWorld(...)
		return lib.btPointCollector_setPointInWorld(self, ...)
	end
	function META:GetHasResult(...)
		return lib.btPointCollector_getHasResult(self, ...)
	end
	function META:SetNormalOnBInWorld(...)
		return lib.btPointCollector_setNormalOnBInWorld(self, ...)
	end
	function META:GetDistance(...)
		return lib.btPointCollector_getDistance(self, ...)
	end
	function META:SetHasResult(...)
		return lib.btPointCollector_setHasResult(self, ...)
	end
	function META:GetPointInWorld(...)
		return lib.btPointCollector_getPointInWorld(self, ...)
	end
	ffi.metatype('btPointCollector', META)
	function bullet.CreatePointCollector(...)
		return lib.btPointCollector_new(...)
	end
end
do -- PositionAndRadius
	local META = {}
	META.__index = META
	function META:SetRadius(...)
		return lib.btPositionAndRadius_setRadius(self, ...)
	end
	function META:SetPos(...)
		return lib.btPositionAndRadius_setPos(self, ...)
	end
	function META:GetPos(...)
		return lib.btPositionAndRadius_getPos(self, ...)
	end
	function META:GetRadius(...)
		return lib.btPositionAndRadius_getRadius(self, ...)
	end
	function META:Delete(...)
		return lib.btPositionAndRadius_delete(self, ...)
	end
	ffi.metatype('btPositionAndRadius', META)
	function bullet.CreatePositionAndRadius(...)
		return lib.btPositionAndRadius_new(...)
	end
end
do -- BU_Simplex1to4
	local META = {}
	META.__index = META
	function META:GetIndex(...)
		return lib.btBU_Simplex1to4_getIndex(self, ...)
	end
	function META:AddVertex(...)
		return lib.btBU_Simplex1to4_addVertex(self, ...)
	end
	function META:Reset(...)
		return lib.btBU_Simplex1to4_reset(self, ...)
	end
	ffi.metatype('btBU_Simplex1to4', META)
	function bullet.CreateBU_Simplex1to45(...)
		return lib.btBU_Simplex1to4_new5(...)
	end
	function bullet.CreateBU_Simplex1to43(...)
		return lib.btBU_Simplex1to4_new3(...)
	end
	function bullet.CreateBU_Simplex1to44(...)
		return lib.btBU_Simplex1to4_new4(...)
	end
	function bullet.CreateBU_Simplex1to42(...)
		return lib.btBU_Simplex1to4_new2(...)
	end
end
do -- SphereSphereCollisionAlgorithm
	local META = {}
	META.__index = META
	ffi.metatype('btSphereSphereCollisionAlgorithm', META)
	function bullet.CreateSphereSphereCollisionAlgorithm(...)
		return lib.btSphereSphereCollisionAlgorithm_new(...)
	end
	function bullet.CreateSphereSphereCollisionAlgorithm2(...)
		return lib.btSphereSphereCollisionAlgorithm_new2(...)
	end
end
do -- CollisionWorld_ContactResultCallbackWrapper
	local META = {}
	META.__index = META
	function META:NeedsCollision(...)
		return lib.btCollisionWorld_ContactResultCallbackWrapper_needsCollision(self, ...)
	end
	ffi.metatype('btCollisionWorld_ContactResultCallbackWrapper', META)
	function bullet.CreateCollisionWorld_ContactResultCallbackWrapper(...)
		return lib.btCollisionWorld_ContactResultCallbackWrapper_new(...)
	end
end
do -- CapsuleShapeX
	local META = {}
	META.__index = META
	ffi.metatype('btCapsuleShapeX', META)
	function bullet.CreateCapsuleShapeX(...)
		return lib.btCapsuleShapeX_new(...)
	end
end
do -- CompoundShape
	local META = {}
	META.__index = META
	function META:UpdateChildTransform(...)
		return lib.btCompoundShape_updateChildTransform(self, ...)
	end
	function META:CreateAabbTreeFromChildren(...)
		return lib.btCompoundShape_createAabbTreeFromChildren(self, ...)
	end
	function META:RemoveChildShape(...)
		return lib.btCompoundShape_removeChildShape(self, ...)
	end
	function META:GetDynamicAabbTree(...)
		return lib.btCompoundShape_getDynamicAabbTree(self, ...)
	end
	function META:GetChildTransform(...)
		return lib.btCompoundShape_getChildTransform(self, ...)
	end
	function META:UpdateChildTransform2(...)
		return lib.btCompoundShape_updateChildTransform2(self, ...)
	end
	function META:RemoveChildShapeByIndex(...)
		return lib.btCompoundShape_removeChildShapeByIndex(self, ...)
	end
	function META:GetChildList(...)
		return lib.btCompoundShape_getChildList(self, ...)
	end
	function META:RecalculateLocalAabb(...)
		return lib.btCompoundShape_recalculateLocalAabb(self, ...)
	end
	function META:GetUpdateRevision(...)
		return lib.btCompoundShape_getUpdateRevision(self, ...)
	end
	function META:GetNumChildShapes(...)
		return lib.btCompoundShape_getNumChildShapes(self, ...)
	end
	function META:GetChildShape(...)
		return lib.btCompoundShape_getChildShape(self, ...)
	end
	function META:CalculatePrincipalAxisTransform(...)
		return lib.btCompoundShape_calculatePrincipalAxisTransform(self, ...)
	end
	function META:AddChildShape(...)
		return lib.btCompoundShape_addChildShape(self, ...)
	end
	ffi.metatype('btCompoundShape', META)
	function bullet.CreateCompoundShape(...)
		return lib.btCompoundShape_new(...)
	end
	function bullet.CreateCompoundShape2(...)
		return lib.btCompoundShape_new2(...)
	end
end
do -- GImpactBvh
	local META = {}
	META.__index = META
	function META:GetNodeBound(...)
		return lib.btGImpactBvh_getNodeBound(self, ...)
	end
	function META:SetPrimitiveManager(...)
		return lib.btGImpactBvh_setPrimitiveManager(self, ...)
	end
	function META:BoxQuery(...)
		return lib.btGImpactBvh_boxQuery(self, ...)
	end
	function META:RayQuery(...)
		return lib.btGImpactBvh_rayQuery(self, ...)
	end
	function META:GetEscapeNodeIndex(...)
		return lib.btGImpactBvh_getEscapeNodeIndex(self, ...)
	end
	function META:HasHierarchy(...)
		return lib.btGImpactBvh_hasHierarchy(self, ...)
	end
	function META:IsLeafNode(...)
		return lib.btGImpactBvh_isLeafNode(self, ...)
	end
	function META:SetNodeBound(...)
		return lib.btGImpactBvh_setNodeBound(self, ...)
	end
	function META:GetNodeTriangle(...)
		return lib.btGImpactBvh_getNodeTriangle(self, ...)
	end
	function META:Update(...)
		return lib.btGImpactBvh_update(self, ...)
	end
	function META:GetNodeCount(...)
		return lib.btGImpactBvh_getNodeCount(self, ...)
	end
	function META:BuildSet(...)
		return lib.btGImpactBvh_buildSet(self, ...)
	end
	function META:GetPrimitiveManager(...)
		return lib.btGImpactBvh_getPrimitiveManager(self, ...)
	end
	function META:GetNodeData(...)
		return lib.btGImpactBvh_getNodeData(self, ...)
	end
	function META:GetLeftNode(...)
		return lib.btGImpactBvh_getLeftNode(self, ...)
	end
	function META:Delete(...)
		return lib.btGImpactBvh_delete(self, ...)
	end
	function META:IsTrimesh(...)
		return lib.btGImpactBvh_isTrimesh(self, ...)
	end
	function META:GetRightNode(...)
		return lib.btGImpactBvh_getRightNode(self, ...)
	end
	function META:BoxQueryTrans(...)
		return lib.btGImpactBvh_boxQueryTrans(self, ...)
	end
	function META:GetGlobalBox(...)
		return lib.btGImpactBvh_getGlobalBox(self, ...)
	end
	ffi.metatype('btGImpactBvh', META)
	function bullet.CreateGImpactBvh2(...)
		return lib.btGImpactBvh_new2(...)
	end
	function bullet.CreateGImpactBvh(...)
		return lib.btGImpactBvh_new(...)
	end
end
do -- CollisionObject
	local META = {}
	META.__index = META
	function META:SetActivationState(...)
		return lib.btCollisionObject_setActivationState(self, ...)
	end
	function META:SetCompanionId(...)
		return lib.btCollisionObject_setCompanionId(self, ...)
	end
	function META:GetCcdSquareMotionThreshold(...)
		return lib.btCollisionObject_getCcdSquareMotionThreshold(self, ...)
	end
	function META:GetCollisionShape(...)
		return lib.btCollisionObject_getCollisionShape(self, ...)
	end
	function META:CheckCollideWith(...)
		return lib.btCollisionObject_checkCollideWith(self, ...)
	end
	function META:SetRestitution(...)
		return lib.btCollisionObject_setRestitution(self, ...)
	end
	function META:GetAnisotropicFriction(...)
		return lib.btCollisionObject_getAnisotropicFriction(self, ...)
	end
	function META:GetCollisionFlags(...)
		return lib.btCollisionObject_getCollisionFlags(self, ...)
	end
	function META:GetFriction(...)
		return lib.btCollisionObject_getFriction(self, ...)
	end
	function META:GetCcdSweptSphereRadius(...)
		return lib.btCollisionObject_getCcdSweptSphereRadius(self, ...)
	end
	function META:SetInterpolationWorldTransform(...)
		return lib.btCollisionObject_setInterpolationWorldTransform(self, ...)
	end
	function META:GetHitFraction(...)
		return lib.btCollisionObject_getHitFraction(self, ...)
	end
	function META:GetInterpolationLinearVelocity(...)
		return lib.btCollisionObject_getInterpolationLinearVelocity(self, ...)
	end
	function META:SetContactProcessingThreshold(...)
		return lib.btCollisionObject_setContactProcessingThreshold(self, ...)
	end
	function META:SetAnisotropicFriction(...)
		return lib.btCollisionObject_setAnisotropicFriction(self, ...)
	end
	function META:SetInterpolationLinearVelocity(...)
		return lib.btCollisionObject_setInterpolationLinearVelocity(self, ...)
	end
	function META:GetInterpolationWorldTransform(...)
		return lib.btCollisionObject_getInterpolationWorldTransform(self, ...)
	end
	function META:Activate2(...)
		return lib.btCollisionObject_activate2(self, ...)
	end
	function META:SetCollisionFlags(...)
		return lib.btCollisionObject_setCollisionFlags(self, ...)
	end
	function META:HasAnisotropicFriction2(...)
		return lib.btCollisionObject_hasAnisotropicFriction2(self, ...)
	end
	function META:GetDeactivationTime(...)
		return lib.btCollisionObject_getDeactivationTime(self, ...)
	end
	function META:GetActivationState(...)
		return lib.btCollisionObject_getActivationState(self, ...)
	end
	function META:CalculateSerializeBufferSize(...)
		return lib.btCollisionObject_calculateSerializeBufferSize(self, ...)
	end
	function META:IsStaticObject(...)
		return lib.btCollisionObject_isStaticObject(self, ...)
	end
	function META:SetAnisotropicFriction2(...)
		return lib.btCollisionObject_setAnisotropicFriction2(self, ...)
	end
	function META:GetUserPointer(...)
		return lib.btCollisionObject_getUserPointer(self, ...)
	end
	function META:SetCcdSweptSphereRadius(...)
		return lib.btCollisionObject_setCcdSweptSphereRadius(self, ...)
	end
	function META:GetWorldTransform(...)
		return lib.btCollisionObject_getWorldTransform(self, ...)
	end
	function META:GetUserIndex(...)
		return lib.btCollisionObject_getUserIndex(self, ...)
	end
	function META:IsStaticOrKinematicObject(...)
		return lib.btCollisionObject_isStaticOrKinematicObject(self, ...)
	end
	function META:SetUserIndex(...)
		return lib.btCollisionObject_setUserIndex(self, ...)
	end
	function META:HasAnisotropicFriction(...)
		return lib.btCollisionObject_hasAnisotropicFriction(self, ...)
	end
	function META:GetInterpolationAngularVelocity(...)
		return lib.btCollisionObject_getInterpolationAngularVelocity(self, ...)
	end
	function META:Activate(...)
		return lib.btCollisionObject_activate(self, ...)
	end
	function META:GetContactProcessingThreshold(...)
		return lib.btCollisionObject_getContactProcessingThreshold(self, ...)
	end
	function META:SetWorldTransform(...)
		return lib.btCollisionObject_setWorldTransform(self, ...)
	end
	function META:SetDeactivationTime(...)
		return lib.btCollisionObject_setDeactivationTime(self, ...)
	end
	function META:SetUserPointer(...)
		return lib.btCollisionObject_setUserPointer(self, ...)
	end
	function META:InternalGetExtensionPointer(...)
		return lib.btCollisionObject_internalGetExtensionPointer(self, ...)
	end
	function META:SetInterpolationAngularVelocity(...)
		return lib.btCollisionObject_setInterpolationAngularVelocity(self, ...)
	end
	function META:Serialize(...)
		return lib.btCollisionObject_serialize(self, ...)
	end
	function META:GetBroadphaseHandle(...)
		return lib.btCollisionObject_getBroadphaseHandle(self, ...)
	end
	function META:GetCcdMotionThreshold(...)
		return lib.btCollisionObject_getCcdMotionThreshold(self, ...)
	end
	function META:IsKinematicObject(...)
		return lib.btCollisionObject_isKinematicObject(self, ...)
	end
	function META:SetCcdMotionThreshold(...)
		return lib.btCollisionObject_setCcdMotionThreshold(self, ...)
	end
	function META:SetRollingFriction(...)
		return lib.btCollisionObject_setRollingFriction(self, ...)
	end
	function META:Delete(...)
		return lib.btCollisionObject_delete(self, ...)
	end
	function META:ForceActivationState(...)
		return lib.btCollisionObject_forceActivationState(self, ...)
	end
	function META:SerializeSingleObject(...)
		return lib.btCollisionObject_serializeSingleObject(self, ...)
	end
	function META:GetRollingFriction(...)
		return lib.btCollisionObject_getRollingFriction(self, ...)
	end
	function META:GetIslandTag(...)
		return lib.btCollisionObject_getIslandTag(self, ...)
	end
	function META:SetFriction(...)
		return lib.btCollisionObject_setFriction(self, ...)
	end
	function META:SetIgnoreCollisionCheck(...)
		return lib.btCollisionObject_setIgnoreCollisionCheck(self, ...)
	end
	function META:GetCompanionId(...)
		return lib.btCollisionObject_getCompanionId(self, ...)
	end
	function META:IsActive(...)
		return lib.btCollisionObject_isActive(self, ...)
	end
	function META:GetRestitution(...)
		return lib.btCollisionObject_getRestitution(self, ...)
	end
	function META:InternalSetExtensionPointer(...)
		return lib.btCollisionObject_internalSetExtensionPointer(self, ...)
	end
	function META:SetBroadphaseHandle(...)
		return lib.btCollisionObject_setBroadphaseHandle(self, ...)
	end
	function META:SetIslandTag(...)
		return lib.btCollisionObject_setIslandTag(self, ...)
	end
	function META:SetCollisionShape(...)
		return lib.btCollisionObject_setCollisionShape(self, ...)
	end
	function META:CheckCollideWithOverride(...)
		return lib.btCollisionObject_checkCollideWithOverride(self, ...)
	end
	function META:HasContactResponse(...)
		return lib.btCollisionObject_hasContactResponse(self, ...)
	end
	function META:MergesSimulationIslands(...)
		return lib.btCollisionObject_mergesSimulationIslands(self, ...)
	end
	function META:GetInternalType(...)
		return lib.btCollisionObject_getInternalType(self, ...)
	end
	function META:SetHitFraction(...)
		return lib.btCollisionObject_setHitFraction(self, ...)
	end
	ffi.metatype('btCollisionObject', META)
	function bullet.CreateCollisionObject(...)
		return lib.btCollisionObject_new(...)
	end
end
do -- SortedOverlappingPairCache
	local META = {}
	META.__index = META
	function META:GetOverlapFilterCallback(...)
		return lib.btSortedOverlappingPairCache_getOverlapFilterCallback(self, ...)
	end
	function META:NeedsBroadphaseCollision(...)
		return lib.btSortedOverlappingPairCache_needsBroadphaseCollision(self, ...)
	end
	ffi.metatype('btSortedOverlappingPairCache', META)
	function bullet.CreateSortedOverlappingPairCache(...)
		return lib.btSortedOverlappingPairCache_new(...)
	end
end
do -- SoftSoftCollisionAlgorithm
	local META = {}
	META.__index = META
	ffi.metatype('btSoftSoftCollisionAlgorithm', META)
	function bullet.CreateSoftSoftCollisionAlgorithm(...)
		return lib.btSoftSoftCollisionAlgorithm_new(...)
	end
	function bullet.CreateSoftSoftCollisionAlgorithm2(...)
		return lib.btSoftSoftCollisionAlgorithm_new2(...)
	end
end
do -- CapsuleShapeZ
	local META = {}
	META.__index = META
	ffi.metatype('btCapsuleShapeZ', META)
	function bullet.CreateCapsuleShapeZ(...)
		return lib.btCapsuleShapeZ_new(...)
	end
end
do -- ContinuousConvexCollision
	local META = {}
	META.__index = META
	ffi.metatype('btContinuousConvexCollision', META)
	function bullet.CreateContinuousConvexCollision2(...)
		return lib.btContinuousConvexCollision_new2(...)
	end
	function bullet.CreateContinuousConvexCollision(...)
		return lib.btContinuousConvexCollision_new(...)
	end
end
do -- SoftBody_Pose
	local META = {}
	META.__index = META
	function META:GetVolume(...)
		return lib.btSoftBody_Pose_getVolume(self, ...)
	end
	function META:GetPos(...)
		return lib.btSoftBody_Pose_getPos(self, ...)
	end
	function META:Delete(...)
		return lib.btSoftBody_Pose_delete(self, ...)
	end
	function META:GetBvolume(...)
		return lib.btSoftBody_Pose_getBvolume(self, ...)
	end
	function META:SetVolume(...)
		return lib.btSoftBody_Pose_setVolume(self, ...)
	end
	function META:GetCom(...)
		return lib.btSoftBody_Pose_getCom(self, ...)
	end
	function META:GetAqq(...)
		return lib.btSoftBody_Pose_getAqq(self, ...)
	end
	function META:GetWgh(...)
		return lib.btSoftBody_Pose_getWgh(self, ...)
	end
	function META:GetRot(...)
		return lib.btSoftBody_Pose_getRot(self, ...)
	end
	function META:GetScl(...)
		return lib.btSoftBody_Pose_getScl(self, ...)
	end
	function META:SetScl(...)
		return lib.btSoftBody_Pose_setScl(self, ...)
	end
	function META:GetBframe(...)
		return lib.btSoftBody_Pose_getBframe(self, ...)
	end
	function META:SetRot(...)
		return lib.btSoftBody_Pose_setRot(self, ...)
	end
	function META:SetBframe(...)
		return lib.btSoftBody_Pose_setBframe(self, ...)
	end
	function META:SetAqq(...)
		return lib.btSoftBody_Pose_setAqq(self, ...)
	end
	function META:SetCom(...)
		return lib.btSoftBody_Pose_setCom(self, ...)
	end
	function META:SetBvolume(...)
		return lib.btSoftBody_Pose_setBvolume(self, ...)
	end
	ffi.metatype('btSoftBody_Pose', META)
	function bullet.CreateSoftBody_Pose(...)
		return lib.btSoftBody_Pose_new(...)
	end
end
do -- TypedConstraint_btConstraintInfo1
	local META = {}
	META.__index = META
	function META:SetNumConstraintRows(...)
		return lib.btTypedConstraint_btConstraintInfo1_setNumConstraintRows(self, ...)
	end
	function META:SetNub(...)
		return lib.btTypedConstraint_btConstraintInfo1_setNub(self, ...)
	end
	function META:GetNub(...)
		return lib.btTypedConstraint_btConstraintInfo1_getNub(self, ...)
	end
	function META:GetNumConstraintRows(...)
		return lib.btTypedConstraint_btConstraintInfo1_getNumConstraintRows(self, ...)
	end
	function META:Delete(...)
		return lib.btTypedConstraint_btConstraintInfo1_delete(self, ...)
	end
	ffi.metatype('btTypedConstraint_btConstraintInfo1', META)
	function bullet.CreateTypedConstraint_btConstraintInfo11(...)
		return lib.btTypedConstraint_btConstraintInfo1_new(...)
	end
end
do -- ConvexConcaveCollisionAlgorithm
	local META = {}
	META.__index = META
	function META:ClearCache(...)
		return lib.btConvexConcaveCollisionAlgorithm_clearCache(self, ...)
	end
	ffi.metatype('btConvexConcaveCollisionAlgorithm', META)
	function bullet.CreateConvexConcaveCollisionAlgorithm(...)
		return lib.btConvexConcaveCollisionAlgorithm_new(...)
	end
end
do -- SoftBody_Impulse
	local META = {}
	META.__index = META
	function META:SetAsVelocity(...)
		return lib.btSoftBody_Impulse_setAsVelocity(self, ...)
	end
	function META:SetVelocity(...)
		return lib.btSoftBody_Impulse_setVelocity(self, ...)
	end
	function META:GetVelocity(...)
		return lib.btSoftBody_Impulse_getVelocity(self, ...)
	end
	function META:SetDrift(...)
		return lib.btSoftBody_Impulse_setDrift(self, ...)
	end
	function META:Delete(...)
		return lib.btSoftBody_Impulse_delete(self, ...)
	end
	function META:GetAsVelocity(...)
		return lib.btSoftBody_Impulse_getAsVelocity(self, ...)
	end
	function META:GetDrift(...)
		return lib.btSoftBody_Impulse_getDrift(self, ...)
	end
	function META:SetAsDrift(...)
		return lib.btSoftBody_Impulse_setAsDrift(self, ...)
	end
	function META:GetAsDrift(...)
		return lib.btSoftBody_Impulse_getAsDrift(self, ...)
	end
	ffi.metatype('btSoftBody_Impulse', META)
	function bullet.CreateSoftBody_Impulse(...)
		return lib.btSoftBody_Impulse_new(...)
	end
end
do -- CollisionWorld_ConvexResultCallbackWrapper
	local META = {}
	META.__index = META
	function META:NeedsCollision(...)
		return lib.btCollisionWorld_ConvexResultCallbackWrapper_needsCollision(self, ...)
	end
	ffi.metatype('btCollisionWorld_ConvexResultCallbackWrapper', META)
	function bullet.CreateCollisionWorld_ConvexResultCallbackWrapper(...)
		return lib.btCollisionWorld_ConvexResultCallbackWrapper_new(...)
	end
end
do -- SphereTriangleCollisionAlgorithm_CreateFunc
	local META = {}
	META.__index = META
	ffi.metatype('btSphereTriangleCollisionAlgorithm_CreateFunc', META)
	function bullet.CreateSphereTriangleCollisionAlgorithm_CreateFunc(...)
		return lib.btSphereTriangleCollisionAlgorithm_CreateFunc_new(...)
	end
end
do -- SoftBody_ImplicitFnWrapper
	local META = {}
	META.__index = META
	ffi.metatype('btSoftBody_ImplicitFn', META)
	function bullet.CreateSoftBody_ImplicitFnWrapper(...)
		return lib.btSoftBody_ImplicitFnWrapper_new(...)
	end
end
do -- SoftBody_Cluster
	local META = {}
	META.__index = META
	function META:GetClusterIndex(...)
		return lib.btSoftBody_Cluster_getClusterIndex(self, ...)
	end
	function META:SetCollide(...)
		return lib.btSoftBody_Cluster_setCollide(self, ...)
	end
	function META:Delete(...)
		return lib.btSoftBody_Cluster_delete(self, ...)
	end
	function META:SetContainsAnchor(...)
		return lib.btSoftBody_Cluster_setContainsAnchor(self, ...)
	end
	function META:GetNodes(...)
		return lib.btSoftBody_Cluster_getNodes(self, ...)
	end
	function META:SetFramexform(...)
		return lib.btSoftBody_Cluster_setFramexform(self, ...)
	end
	function META:SetClusterIndex(...)
		return lib.btSoftBody_Cluster_setClusterIndex(self, ...)
	end
	function META:GetCom(...)
		return lib.btSoftBody_Cluster_getCom(self, ...)
	end
	function META:SetNdamping(...)
		return lib.btSoftBody_Cluster_setNdamping(self, ...)
	end
	function META:GetImass(...)
		return lib.btSoftBody_Cluster_getImass(self, ...)
	end
	function META:GetDimpulses(...)
		return lib.btSoftBody_Cluster_getDimpulses(self, ...)
	end
	function META:SetMatching(...)
		return lib.btSoftBody_Cluster_setMatching(self, ...)
	end
	function META:GetSelfCollisionImpulseFactor(...)
		return lib.btSoftBody_Cluster_getSelfCollisionImpulseFactor(self, ...)
	end
	function META:SetMaxSelfCollisionImpulse(...)
		return lib.btSoftBody_Cluster_setMaxSelfCollisionImpulse(self, ...)
	end
	function META:SetInvwi(...)
		return lib.btSoftBody_Cluster_setInvwi(self, ...)
	end
	function META:SetSelfCollisionImpulseFactor(...)
		return lib.btSoftBody_Cluster_setSelfCollisionImpulseFactor(self, ...)
	end
	function META:SetAv(...)
		return lib.btSoftBody_Cluster_setAv(self, ...)
	end
	function META:SetNvimpulses(...)
		return lib.btSoftBody_Cluster_setNvimpulses(self, ...)
	end
	function META:GetNvimpulses(...)
		return lib.btSoftBody_Cluster_getNvimpulses(self, ...)
	end
	function META:SetLdamping(...)
		return lib.btSoftBody_Cluster_setLdamping(self, ...)
	end
	function META:GetContainsAnchor(...)
		return lib.btSoftBody_Cluster_getContainsAnchor(self, ...)
	end
	function META:GetNdamping(...)
		return lib.btSoftBody_Cluster_getNdamping(self, ...)
	end
	function META:SetVimpulses(...)
		return lib.btSoftBody_Cluster_setVimpulses(self, ...)
	end
	function META:SetLv(...)
		return lib.btSoftBody_Cluster_setLv(self, ...)
	end
	function META:GetLv(...)
		return lib.btSoftBody_Cluster_getLv(self, ...)
	end
	function META:GetLocii(...)
		return lib.btSoftBody_Cluster_getLocii(self, ...)
	end
	function META:SetLocii(...)
		return lib.btSoftBody_Cluster_setLocii(self, ...)
	end
	function META:GetMasses(...)
		return lib.btSoftBody_Cluster_getMasses(self, ...)
	end
	function META:GetMatching(...)
		return lib.btSoftBody_Cluster_getMatching(self, ...)
	end
	function META:SetLeaf(...)
		return lib.btSoftBody_Cluster_setLeaf(self, ...)
	end
	function META:SetNdimpulses(...)
		return lib.btSoftBody_Cluster_setNdimpulses(self, ...)
	end
	function META:SetCom(...)
		return lib.btSoftBody_Cluster_setCom(self, ...)
	end
	function META:SetAdamping(...)
		return lib.btSoftBody_Cluster_setAdamping(self, ...)
	end
	function META:SetIdmass(...)
		return lib.btSoftBody_Cluster_setIdmass(self, ...)
	end
	function META:GetVimpulses(...)
		return lib.btSoftBody_Cluster_getVimpulses(self, ...)
	end
	function META:GetLeaf(...)
		return lib.btSoftBody_Cluster_getLeaf(self, ...)
	end
	function META:GetCollide(...)
		return lib.btSoftBody_Cluster_getCollide(self, ...)
	end
	function META:GetMaxSelfCollisionImpulse(...)
		return lib.btSoftBody_Cluster_getMaxSelfCollisionImpulse(self, ...)
	end
	function META:GetAdamping(...)
		return lib.btSoftBody_Cluster_getAdamping(self, ...)
	end
	function META:GetFramexform(...)
		return lib.btSoftBody_Cluster_getFramexform(self, ...)
	end
	function META:GetFramerefs(...)
		return lib.btSoftBody_Cluster_getFramerefs(self, ...)
	end
	function META:GetLdamping(...)
		return lib.btSoftBody_Cluster_getLdamping(self, ...)
	end
	function META:GetAv(...)
		return lib.btSoftBody_Cluster_getAv(self, ...)
	end
	function META:GetNdimpulses(...)
		return lib.btSoftBody_Cluster_getNdimpulses(self, ...)
	end
	function META:GetInvwi(...)
		return lib.btSoftBody_Cluster_getInvwi(self, ...)
	end
	function META:GetIdmass(...)
		return lib.btSoftBody_Cluster_getIdmass(self, ...)
	end
	function META:SetImass(...)
		return lib.btSoftBody_Cluster_setImass(self, ...)
	end
	ffi.metatype('btSoftBody_Cluster', META)
	function bullet.CreateSoftBody_Cluster(...)
		return lib.btSoftBody_Cluster_new(...)
	end
end
do -- OptimizedBvh
	local META = {}
	META.__index = META
	function META:Build(...)
		return lib.btOptimizedBvh_build(self, ...)
	end
	function META:SerializeInPlace(...)
		return lib.btOptimizedBvh_serializeInPlace(self, ...)
	end
	function META:UpdateBvhNodes(...)
		return lib.btOptimizedBvh_updateBvhNodes(self, ...)
	end
	function META:DeSerializeInPlace(...)
		return lib.btOptimizedBvh_deSerializeInPlace(self, ...)
	end
	function META:Refit(...)
		return lib.btOptimizedBvh_refit(self, ...)
	end
	function META:RefitPartial(...)
		return lib.btOptimizedBvh_refitPartial(self, ...)
	end
	ffi.metatype('btOptimizedBvh', META)
	function bullet.CreateOptimizedBvh(...)
		return lib.btOptimizedBvh_new(...)
	end
end
do -- GIM_BVH_DATA
	local META = {}
	META.__index = META
	ffi.metatype('GIM_BVH_DATA', META)
	function bullet.CreateGIM_BVH_DATA(...)
		return lib.GIM_BVH_DATA_new(...)
	end
end
do -- TriangleInfo
	local META = {}
	META.__index = META
	function META:GetEdgeV0V1Angle(...)
		return lib.btTriangleInfo_getEdgeV0V1Angle(self, ...)
	end
	function META:SetEdgeV2V0Angle(...)
		return lib.btTriangleInfo_setEdgeV2V0Angle(self, ...)
	end
	function META:Delete(...)
		return lib.btTriangleInfo_delete(self, ...)
	end
	function META:GetEdgeV2V0Angle(...)
		return lib.btTriangleInfo_getEdgeV2V0Angle(self, ...)
	end
	function META:SetFlags(...)
		return lib.btTriangleInfo_setFlags(self, ...)
	end
	function META:SetEdgeV0V1Angle(...)
		return lib.btTriangleInfo_setEdgeV0V1Angle(self, ...)
	end
	function META:GetFlags(...)
		return lib.btTriangleInfo_getFlags(self, ...)
	end
	function META:SetEdgeV1V2Angle(...)
		return lib.btTriangleInfo_setEdgeV1V2Angle(self, ...)
	end
	function META:GetEdgeV1V2Angle(...)
		return lib.btTriangleInfo_getEdgeV1V2Angle(self, ...)
	end
	ffi.metatype('btTriangleInfo', META)
	function bullet.CreateTriangleInfo(...)
		return lib.btTriangleInfo_new(...)
	end
end
do -- Chunk
	local META = {}
	META.__index = META
	function META:SetOldPtr(...)
		return lib.btChunk_setOldPtr(self, ...)
	end
	function META:GetChunkCode(...)
		return lib.btChunk_getChunkCode(self, ...)
	end
	function META:GetLength(...)
		return lib.btChunk_getLength(self, ...)
	end
	function META:GetOldPtr(...)
		return lib.btChunk_getOldPtr(self, ...)
	end
	function META:SetNumber(...)
		return lib.btChunk_setNumber(self, ...)
	end
	function META:SetChunkCode(...)
		return lib.btChunk_setChunkCode(self, ...)
	end
	function META:Delete(...)
		return lib.btChunk_delete(self, ...)
	end
	function META:GetNumber(...)
		return lib.btChunk_getNumber(self, ...)
	end
	function META:SetLength(...)
		return lib.btChunk_setLength(self, ...)
	end
	ffi.metatype('btChunk', META)
	function bullet.CreateChunk(...)
		return lib.btChunk_new(...)
	end
end
do -- HACD
	local META = {}
	META.__index = META
	ffi.metatype('HACD_HACD', META)
	function bullet.CreateHACD(...)
		return lib.HACD_new(...)
	end
end
do -- AlignedVector3Array
	local META = {}
	META.__index = META
	function META:Delete(...)
		return lib.btAlignedVector3Array_delete(self, ...)
	end
	function META:At(...)
		return lib.btAlignedVector3Array_at(self, ...)
	end
	function META:Size(...)
		return lib.btAlignedVector3Array_size(self, ...)
	end
	function META:Set(...)
		return lib.btAlignedVector3Array_set(self, ...)
	end
	ffi.metatype('btAlignedVector3Array', META)
	function bullet.CreateAlignedVector3Array3(...)
		return lib.btAlignedVector3Array_new(...)
	end
end
do -- WheelInfo
	local META = {}
	META.__index = META
	function META:SetClippedInvContactDotSuspension(...)
		return lib.btWheelInfo_setClippedInvContactDotSuspension(self, ...)
	end
	function META:GetRollInfluence(...)
		return lib.btWheelInfo_getRollInfluence(self, ...)
	end
	function META:GetWorldTransform(...)
		return lib.btWheelInfo_getWorldTransform(self, ...)
	end
	function META:GetClientInfo(...)
		return lib.btWheelInfo_getClientInfo(self, ...)
	end
	function META:Delete(...)
		return lib.btWheelInfo_delete(self, ...)
	end
	function META:GetSuspensionRelativeVelocity(...)
		return lib.btWheelInfo_getSuspensionRelativeVelocity(self, ...)
	end
	function META:SetSuspensionStiffness(...)
		return lib.btWheelInfo_setSuspensionStiffness(self, ...)
	end
	function META:SetWheelAxleCS(...)
		return lib.btWheelInfo_setWheelAxleCS(self, ...)
	end
	function META:GetClippedInvContactDotSuspension(...)
		return lib.btWheelInfo_getClippedInvContactDotSuspension(self, ...)
	end
	function META:GetMaxSuspensionForce(...)
		return lib.btWheelInfo_getMaxSuspensionForce(self, ...)
	end
	function META:SetSteering(...)
		return lib.btWheelInfo_setSteering(self, ...)
	end
	function META:SetWorldTransform(...)
		return lib.btWheelInfo_setWorldTransform(self, ...)
	end
	function META:SetClientInfo(...)
		return lib.btWheelInfo_setClientInfo(self, ...)
	end
	function META:GetWheelsSuspensionForce(...)
		return lib.btWheelInfo_getWheelsSuspensionForce(self, ...)
	end
	function META:GetBrake(...)
		return lib.btWheelInfo_getBrake(self, ...)
	end
	function META:SetWheelsDampingCompression(...)
		return lib.btWheelInfo_setWheelsDampingCompression(self, ...)
	end
	function META:GetWheelDirectionCS(...)
		return lib.btWheelInfo_getWheelDirectionCS(self, ...)
	end
	function META:GetWheelsDampingCompression(...)
		return lib.btWheelInfo_getWheelsDampingCompression(self, ...)
	end
	function META:SetBIsFrontWheel(...)
		return lib.btWheelInfo_setBIsFrontWheel(self, ...)
	end
	function META:UpdateWheel(...)
		return lib.btWheelInfo_updateWheel(self, ...)
	end
	function META:SetDeltaRotation(...)
		return lib.btWheelInfo_setDeltaRotation(self, ...)
	end
	function META:SetSkidInfo(...)
		return lib.btWheelInfo_setSkidInfo(self, ...)
	end
	function META:GetDeltaRotation(...)
		return lib.btWheelInfo_getDeltaRotation(self, ...)
	end
	function META:GetEngineForce(...)
		return lib.btWheelInfo_getEngineForce(self, ...)
	end
	function META:GetSteering(...)
		return lib.btWheelInfo_getSteering(self, ...)
	end
	function META:SetMaxSuspensionTravelCm(...)
		return lib.btWheelInfo_setMaxSuspensionTravelCm(self, ...)
	end
	function META:SetWheelsSuspensionForce(...)
		return lib.btWheelInfo_setWheelsSuspensionForce(self, ...)
	end
	function META:SetWheelsRadius(...)
		return lib.btWheelInfo_setWheelsRadius(self, ...)
	end
	function META:GetRaycastInfo(...)
		return lib.btWheelInfo_getRaycastInfo(self, ...)
	end
	function META:SetWheelDirectionCS(...)
		return lib.btWheelInfo_setWheelDirectionCS(self, ...)
	end
	function META:SetChassisConnectionPointCS(...)
		return lib.btWheelInfo_setChassisConnectionPointCS(self, ...)
	end
	function META:SetSuspensionRestLength1(...)
		return lib.btWheelInfo_setSuspensionRestLength1(self, ...)
	end
	function META:SetSuspensionRelativeVelocity(...)
		return lib.btWheelInfo_setSuspensionRelativeVelocity(self, ...)
	end
	function META:GetSuspensionRestLength(...)
		return lib.btWheelInfo_getSuspensionRestLength(self, ...)
	end
	function META:GetWheelAxleCS(...)
		return lib.btWheelInfo_getWheelAxleCS(self, ...)
	end
	function META:SetRotation(...)
		return lib.btWheelInfo_setRotation(self, ...)
	end
	function META:SetBrake(...)
		return lib.btWheelInfo_setBrake(self, ...)
	end
	function META:GetMaxSuspensionTravelCm(...)
		return lib.btWheelInfo_getMaxSuspensionTravelCm(self, ...)
	end
	function META:SetWheelsDampingRelaxation(...)
		return lib.btWheelInfo_setWheelsDampingRelaxation(self, ...)
	end
	function META:SetMaxSuspensionForce(...)
		return lib.btWheelInfo_setMaxSuspensionForce(self, ...)
	end
	function META:SetFrictionSlip(...)
		return lib.btWheelInfo_setFrictionSlip(self, ...)
	end
	function META:GetWheelsRadius(...)
		return lib.btWheelInfo_getWheelsRadius(self, ...)
	end
	function META:GetRotation(...)
		return lib.btWheelInfo_getRotation(self, ...)
	end
	function META:SetRollInfluence(...)
		return lib.btWheelInfo_setRollInfluence(self, ...)
	end
	function META:GetSkidInfo(...)
		return lib.btWheelInfo_getSkidInfo(self, ...)
	end
	function META:GetChassisConnectionPointCS(...)
		return lib.btWheelInfo_getChassisConnectionPointCS(self, ...)
	end
	function META:GetSuspensionRestLength1(...)
		return lib.btWheelInfo_getSuspensionRestLength1(self, ...)
	end
	function META:GetSuspensionStiffness(...)
		return lib.btWheelInfo_getSuspensionStiffness(self, ...)
	end
	function META:GetFrictionSlip(...)
		return lib.btWheelInfo_getFrictionSlip(self, ...)
	end
	function META:GetWheelsDampingRelaxation(...)
		return lib.btWheelInfo_getWheelsDampingRelaxation(self, ...)
	end
	function META:GetBIsFrontWheel(...)
		return lib.btWheelInfo_getBIsFrontWheel(self, ...)
	end
	function META:SetEngineForce(...)
		return lib.btWheelInfo_setEngineForce(self, ...)
	end
	ffi.metatype('btWheelInfo', META)
	function bullet.CreateWheelInfo(...)
		return lib.btWheelInfo_new(...)
	end
end
do -- CompoundShapeChild
	local META = {}
	META.__index = META
	function META:GetChildShapeType(...)
		return lib.btCompoundShapeChild_getChildShapeType(self, ...)
	end
	function META:SetChildShapeType(...)
		return lib.btCompoundShapeChild_setChildShapeType(self, ...)
	end
	function META:GetNode(...)
		return lib.btCompoundShapeChild_getNode(self, ...)
	end
	function META:Delete(...)
		return lib.btCompoundShapeChild_delete(self, ...)
	end
	function META:SetTransform(...)
		return lib.btCompoundShapeChild_setTransform(self, ...)
	end
	function META:GetChildMargin(...)
		return lib.btCompoundShapeChild_getChildMargin(self, ...)
	end
	function META:SetNode(...)
		return lib.btCompoundShapeChild_setNode(self, ...)
	end
	function META:GetTransform(...)
		return lib.btCompoundShapeChild_getTransform(self, ...)
	end
	function META:GetChildShape(...)
		return lib.btCompoundShapeChild_getChildShape(self, ...)
	end
	function META:SetChildMargin(...)
		return lib.btCompoundShapeChild_setChildMargin(self, ...)
	end
	function META:SetChildShape(...)
		return lib.btCompoundShapeChild_setChildShape(self, ...)
	end
	ffi.metatype('btCompoundShapeChild', META)
	function bullet.CreateCompoundShapeChild(...)
		return lib.btCompoundShapeChild_new(...)
	end
end
do -- WheelInfoConstructionInfo
	local META = {}
	META.__index = META
	function META:GetChassisConnectionCS(...)
		return lib.btWheelInfoConstructionInfo_getChassisConnectionCS(self, ...)
	end
	function META:SetMaxSuspensionTravelCm(...)
		return lib.btWheelInfoConstructionInfo_setMaxSuspensionTravelCm(self, ...)
	end
	function META:GetWheelsDampingRelaxation(...)
		return lib.btWheelInfoConstructionInfo_getWheelsDampingRelaxation(self, ...)
	end
	function META:Delete(...)
		return lib.btWheelInfoConstructionInfo_delete(self, ...)
	end
	function META:SetSuspensionStiffness(...)
		return lib.btWheelInfoConstructionInfo_setSuspensionStiffness(self, ...)
	end
	function META:SetWheelAxleCS(...)
		return lib.btWheelInfoConstructionInfo_setWheelAxleCS(self, ...)
	end
	function META:GetMaxSuspensionForce(...)
		return lib.btWheelInfoConstructionInfo_getMaxSuspensionForce(self, ...)
	end
	function META:GetWheelAxleCS(...)
		return lib.btWheelInfoConstructionInfo_getWheelAxleCS(self, ...)
	end
	function META:SetWheelRadius(...)
		return lib.btWheelInfoConstructionInfo_setWheelRadius(self, ...)
	end
	function META:GetFrictionSlip(...)
		return lib.btWheelInfoConstructionInfo_getFrictionSlip(self, ...)
	end
	function META:GetMaxSuspensionTravelCm(...)
		return lib.btWheelInfoConstructionInfo_getMaxSuspensionTravelCm(self, ...)
	end
	function META:SetWheelsDampingRelaxation(...)
		return lib.btWheelInfoConstructionInfo_setWheelsDampingRelaxation(self, ...)
	end
	function META:SetWheelDirectionCS(...)
		return lib.btWheelInfoConstructionInfo_setWheelDirectionCS(self, ...)
	end
	function META:SetFrictionSlip(...)
		return lib.btWheelInfoConstructionInfo_setFrictionSlip(self, ...)
	end
	function META:SetWheelsDampingCompression(...)
		return lib.btWheelInfoConstructionInfo_setWheelsDampingCompression(self, ...)
	end
	function META:SetSuspensionRestLength(...)
		return lib.btWheelInfoConstructionInfo_setSuspensionRestLength(self, ...)
	end
	function META:GetWheelDirectionCS(...)
		return lib.btWheelInfoConstructionInfo_getWheelDirectionCS(self, ...)
	end
	function META:GetSuspensionRestLength(...)
		return lib.btWheelInfoConstructionInfo_getSuspensionRestLength(self, ...)
	end
	function META:GetWheelsDampingCompression(...)
		return lib.btWheelInfoConstructionInfo_getWheelsDampingCompression(self, ...)
	end
	function META:SetBIsFrontWheel(...)
		return lib.btWheelInfoConstructionInfo_setBIsFrontWheel(self, ...)
	end
	function META:GetSuspensionStiffness(...)
		return lib.btWheelInfoConstructionInfo_getSuspensionStiffness(self, ...)
	end
	function META:SetChassisConnectionCS(...)
		return lib.btWheelInfoConstructionInfo_setChassisConnectionCS(self, ...)
	end
	function META:GetWheelRadius(...)
		return lib.btWheelInfoConstructionInfo_getWheelRadius(self, ...)
	end
	function META:GetBIsFrontWheel(...)
		return lib.btWheelInfoConstructionInfo_getBIsFrontWheel(self, ...)
	end
	function META:SetMaxSuspensionForce(...)
		return lib.btWheelInfoConstructionInfo_setMaxSuspensionForce(self, ...)
	end
	ffi.metatype('btWheelInfoConstructionInfo', META)
	function bullet.CreateWheelInfoConstructionInfo(...)
		return lib.btWheelInfoConstructionInfo_new(...)
	end
end
do -- VoronoiSimplexSolver
	local META = {}
	META.__index = META
	function META:SetLastW(...)
		return lib.btVoronoiSimplexSolver_setLastW(self, ...)
	end
	function META:GetSimplex(...)
		return lib.btVoronoiSimplexSolver_getSimplex(self, ...)
	end
	function META:Delete(...)
		return lib.btVoronoiSimplexSolver_delete(self, ...)
	end
	function META:GetNeedsUpdate(...)
		return lib.btVoronoiSimplexSolver_getNeedsUpdate(self, ...)
	end
	function META:SetCachedV(...)
		return lib.btVoronoiSimplexSolver_setCachedV(self, ...)
	end
	function META:RemoveVertex(...)
		return lib.btVoronoiSimplexSolver_removeVertex(self, ...)
	end
	function META:SetCachedP1(...)
		return lib.btVoronoiSimplexSolver_setCachedP1(self, ...)
	end
	function META:FullSimplex(...)
		return lib.btVoronoiSimplexSolver_fullSimplex(self, ...)
	end
	function META:GetCachedP1(...)
		return lib.btVoronoiSimplexSolver_getCachedP1(self, ...)
	end
	function META:SetCachedP2(...)
		return lib.btVoronoiSimplexSolver_setCachedP2(self, ...)
	end
	function META:GetLastW(...)
		return lib.btVoronoiSimplexSolver_getLastW(self, ...)
	end
	function META:SetNumVertices(...)
		return lib.btVoronoiSimplexSolver_setNumVertices(self, ...)
	end
	function META:GetCachedV(...)
		return lib.btVoronoiSimplexSolver_getCachedV(self, ...)
	end
	function META:InSimplex(...)
		return lib.btVoronoiSimplexSolver_inSimplex(self, ...)
	end
	function META:Reset(...)
		return lib.btVoronoiSimplexSolver_reset(self, ...)
	end
	function META:SetCachedValidClosest(...)
		return lib.btVoronoiSimplexSolver_setCachedValidClosest(self, ...)
	end
	function META:UpdateClosestVectorAndPoints(...)
		return lib.btVoronoiSimplexSolver_updateClosestVectorAndPoints(self, ...)
	end
	function META:SetNeedsUpdate(...)
		return lib.btVoronoiSimplexSolver_setNeedsUpdate(self, ...)
	end
	function META:ClosestPtPointTriangle(...)
		return lib.btVoronoiSimplexSolver_closestPtPointTriangle(self, ...)
	end
	function META:GetCachedBC(...)
		return lib.btVoronoiSimplexSolver_getCachedBC(self, ...)
	end
	function META:NumVertices(...)
		return lib.btVoronoiSimplexSolver_numVertices(self, ...)
	end
	function META:SetEqualVertexThreshold(...)
		return lib.btVoronoiSimplexSolver_setEqualVertexThreshold(self, ...)
	end
	function META:GetCachedP2(...)
		return lib.btVoronoiSimplexSolver_getCachedP2(self, ...)
	end
	function META:GetSimplexPointsQ(...)
		return lib.btVoronoiSimplexSolver_getSimplexPointsQ(self, ...)
	end
	function META:AddVertex(...)
		return lib.btVoronoiSimplexSolver_addVertex(self, ...)
	end
	function META:GetSimplexVectorW(...)
		return lib.btVoronoiSimplexSolver_getSimplexVectorW(self, ...)
	end
	function META:GetCachedValidClosest(...)
		return lib.btVoronoiSimplexSolver_getCachedValidClosest(self, ...)
	end
	function META:GetNumVertices(...)
		return lib.btVoronoiSimplexSolver_getNumVertices(self, ...)
	end
	function META:Closest(...)
		return lib.btVoronoiSimplexSolver_closest(self, ...)
	end
	function META:SetCachedBC(...)
		return lib.btVoronoiSimplexSolver_setCachedBC(self, ...)
	end
	function META:EmptySimplex(...)
		return lib.btVoronoiSimplexSolver_emptySimplex(self, ...)
	end
	function META:ReduceVertices(...)
		return lib.btVoronoiSimplexSolver_reduceVertices(self, ...)
	end
	function META:MaxVertex(...)
		return lib.btVoronoiSimplexSolver_maxVertex(self, ...)
	end
	function META:GetSimplexPointsP(...)
		return lib.btVoronoiSimplexSolver_getSimplexPointsP(self, ...)
	end
	function META:PointOutsideOfPlane(...)
		return lib.btVoronoiSimplexSolver_pointOutsideOfPlane(self, ...)
	end
	function META:GetEqualVertexThreshold(...)
		return lib.btVoronoiSimplexSolver_getEqualVertexThreshold(self, ...)
	end
	function META:ClosestPtPointTetrahedron(...)
		return lib.btVoronoiSimplexSolver_closestPtPointTetrahedron(self, ...)
	end
	ffi.metatype('btVoronoiSimplexSolver', META)
	function bullet.CreateVoronoiSimplexSolver(...)
		return lib.btVoronoiSimplexSolver_new(...)
	end
end
do -- SubSimplexClosestResult
	local META = {}
	META.__index = META
	function META:SetClosestPointOnSimplex(...)
		return lib.btSubSimplexClosestResult_setClosestPointOnSimplex(self, ...)
	end
	function META:SetBarycentricCoordinates(...)
		return lib.btSubSimplexClosestResult_setBarycentricCoordinates(self, ...)
	end
	function META:SetDegenerate(...)
		return lib.btSubSimplexClosestResult_setDegenerate(self, ...)
	end
	function META:SetBarycentricCoordinates4(...)
		return lib.btSubSimplexClosestResult_setBarycentricCoordinates4(self, ...)
	end
	function META:Reset(...)
		return lib.btSubSimplexClosestResult_reset(self, ...)
	end
	function META:SetBarycentricCoordinates3(...)
		return lib.btSubSimplexClosestResult_setBarycentricCoordinates3(self, ...)
	end
	function META:Delete(...)
		return lib.btSubSimplexClosestResult_delete(self, ...)
	end
	function META:SetBarycentricCoordinates2(...)
		return lib.btSubSimplexClosestResult_setBarycentricCoordinates2(self, ...)
	end
	function META:SetUsedVertices(...)
		return lib.btSubSimplexClosestResult_setUsedVertices(self, ...)
	end
	function META:SetBarycentricCoordinates5(...)
		return lib.btSubSimplexClosestResult_setBarycentricCoordinates5(self, ...)
	end
	function META:GetClosestPointOnSimplex(...)
		return lib.btSubSimplexClosestResult_getClosestPointOnSimplex(self, ...)
	end
	function META:GetDegenerate(...)
		return lib.btSubSimplexClosestResult_getDegenerate(self, ...)
	end
	function META:GetUsedVertices(...)
		return lib.btSubSimplexClosestResult_getUsedVertices(self, ...)
	end
	function META:GetBarycentricCoords(...)
		return lib.btSubSimplexClosestResult_getBarycentricCoords(self, ...)
	end
	function META:IsValid(...)
		return lib.btSubSimplexClosestResult_isValid(self, ...)
	end
	ffi.metatype('btSubSimplexClosestResult', META)
	function bullet.CreateSubSimplexClosestResult(...)
		return lib.btSubSimplexClosestResult_new(...)
	end
end
do -- ManifoldResult
	local META = {}
	META.__index = META
	function META:GetBody1Internal(...)
		return lib.btManifoldResult_getBody1Internal(self, ...)
	end
	function META:SetBody1Wrap(...)
		return lib.btManifoldResult_setBody1Wrap(self, ...)
	end
	function META:GetBody0Wrap(...)
		return lib.btManifoldResult_getBody0Wrap(self, ...)
	end
	function META:GetBody1Wrap(...)
		return lib.btManifoldResult_getBody1Wrap(self, ...)
	end
	function META:CalculateCombinedRestitution(...)
		return lib.btManifoldResult_calculateCombinedRestitution(self, ...)
	end
	function META:GetBody0Internal(...)
		return lib.btManifoldResult_getBody0Internal(self, ...)
	end
	function META:SetPersistentManifold(...)
		return lib.btManifoldResult_setPersistentManifold(self, ...)
	end
	function META:CalculateCombinedFriction(...)
		return lib.btManifoldResult_calculateCombinedFriction(self, ...)
	end
	function META:RefreshContactPoints(...)
		return lib.btManifoldResult_refreshContactPoints(self, ...)
	end
	function META:SetBody0Wrap(...)
		return lib.btManifoldResult_setBody0Wrap(self, ...)
	end
	function META:GetPersistentManifold(...)
		return lib.btManifoldResult_getPersistentManifold(self, ...)
	end
	ffi.metatype('btManifoldResult', META)
	function bullet.CreateManifoldResult(...)
		return lib.btManifoldResult_new(...)
	end
	function bullet.CreateManifoldResult2(...)
		return lib.btManifoldResult_new2(...)
	end
end
do -- SliderConstraint
	local META = {}
	META.__index = META
	function META:SetLowerLinLimit(...)
		return lib.btSliderConstraint_setLowerLinLimit(self, ...)
	end
	function META:GetUseLinearReferenceFrameA(...)
		return lib.btSliderConstraint_getUseLinearReferenceFrameA(self, ...)
	end
	function META:GetSoftnessDirAng(...)
		return lib.btSliderConstraint_getSoftnessDirAng(self, ...)
	end
	function META:GetFrameOffsetA(...)
		return lib.btSliderConstraint_getFrameOffsetA(self, ...)
	end
	function META:CalculateTransforms(...)
		return lib.btSliderConstraint_calculateTransforms(self, ...)
	end
	function META:GetInfo1NonVirtual(...)
		return lib.btSliderConstraint_getInfo1NonVirtual(self, ...)
	end
	function META:SetDampingDirLin(...)
		return lib.btSliderConstraint_setDampingDirLin(self, ...)
	end
	function META:GetAncorInA(...)
		return lib.btSliderConstraint_getAncorInA(self, ...)
	end
	function META:GetLinearPos(...)
		return lib.btSliderConstraint_getLinearPos(self, ...)
	end
	function META:GetRestitutionDirAng(...)
		return lib.btSliderConstraint_getRestitutionDirAng(self, ...)
	end
	function META:SetDampingDirAng(...)
		return lib.btSliderConstraint_setDampingDirAng(self, ...)
	end
	function META:GetDampingLimLin(...)
		return lib.btSliderConstraint_getDampingLimLin(self, ...)
	end
	function META:GetSoftnessOrthoLin(...)
		return lib.btSliderConstraint_getSoftnessOrthoLin(self, ...)
	end
	function META:GetDampingDirAng(...)
		return lib.btSliderConstraint_getDampingDirAng(self, ...)
	end
	function META:GetSolveAngLimit(...)
		return lib.btSliderConstraint_getSolveAngLimit(self, ...)
	end
	function META:GetDampingDirLin(...)
		return lib.btSliderConstraint_getDampingDirLin(self, ...)
	end
	function META:GetLinDepth(...)
		return lib.btSliderConstraint_getLinDepth(self, ...)
	end
	function META:SetUseFrameOffset(...)
		return lib.btSliderConstraint_setUseFrameOffset(self, ...)
	end
	function META:GetSolveLinLimit(...)
		return lib.btSliderConstraint_getSolveLinLimit(self, ...)
	end
	function META:SetRestitutionOrthoLin(...)
		return lib.btSliderConstraint_setRestitutionOrthoLin(self, ...)
	end
	function META:SetSoftnessOrthoLin(...)
		return lib.btSliderConstraint_setSoftnessOrthoLin(self, ...)
	end
	function META:GetMaxLinMotorForce(...)
		return lib.btSliderConstraint_getMaxLinMotorForce(self, ...)
	end
	function META:SetMaxLinMotorForce(...)
		return lib.btSliderConstraint_setMaxLinMotorForce(self, ...)
	end
	function META:SetUpperAngLimit(...)
		return lib.btSliderConstraint_setUpperAngLimit(self, ...)
	end
	function META:SetRestitutionDirLin(...)
		return lib.btSliderConstraint_setRestitutionDirLin(self, ...)
	end
	function META:GetUpperLinLimit(...)
		return lib.btSliderConstraint_getUpperLinLimit(self, ...)
	end
	function META:GetInfo2NonVirtual(...)
		return lib.btSliderConstraint_getInfo2NonVirtual(self, ...)
	end
	function META:GetRestitutionOrthoLin(...)
		return lib.btSliderConstraint_getRestitutionOrthoLin(self, ...)
	end
	function META:GetTargetAngMotorVelocity(...)
		return lib.btSliderConstraint_getTargetAngMotorVelocity(self, ...)
	end
	function META:SetFrames(...)
		return lib.btSliderConstraint_setFrames(self, ...)
	end
	function META:GetAncorInB(...)
		return lib.btSliderConstraint_getAncorInB(self, ...)
	end
	function META:GetRestitutionLimAng(...)
		return lib.btSliderConstraint_getRestitutionLimAng(self, ...)
	end
	function META:SetTargetAngMotorVelocity(...)
		return lib.btSliderConstraint_setTargetAngMotorVelocity(self, ...)
	end
	function META:GetTargetLinMotorVelocity(...)
		return lib.btSliderConstraint_getTargetLinMotorVelocity(self, ...)
	end
	function META:SetTargetLinMotorVelocity(...)
		return lib.btSliderConstraint_setTargetLinMotorVelocity(self, ...)
	end
	function META:SetPoweredLinMotor(...)
		return lib.btSliderConstraint_setPoweredLinMotor(self, ...)
	end
	function META:GetRestitutionLimLin(...)
		return lib.btSliderConstraint_getRestitutionLimLin(self, ...)
	end
	function META:SetDampingLimLin(...)
		return lib.btSliderConstraint_setDampingLimLin(self, ...)
	end
	function META:GetAngularPos(...)
		return lib.btSliderConstraint_getAngularPos(self, ...)
	end
	function META:GetCalculatedTransformA(...)
		return lib.btSliderConstraint_getCalculatedTransformA(self, ...)
	end
	function META:SetUpperLinLimit(...)
		return lib.btSliderConstraint_setUpperLinLimit(self, ...)
	end
	function META:TestAngLimits(...)
		return lib.btSliderConstraint_testAngLimits(self, ...)
	end
	function META:SetSoftnessOrthoAng(...)
		return lib.btSliderConstraint_setSoftnessOrthoAng(self, ...)
	end
	function META:SetSoftnessLimLin(...)
		return lib.btSliderConstraint_setSoftnessLimLin(self, ...)
	end
	function META:SetLowerAngLimit(...)
		return lib.btSliderConstraint_setLowerAngLimit(self, ...)
	end
	function META:GetCalculatedTransformB(...)
		return lib.btSliderConstraint_getCalculatedTransformB(self, ...)
	end
	function META:SetSoftnessLimAng(...)
		return lib.btSliderConstraint_setSoftnessLimAng(self, ...)
	end
	function META:SetSoftnessDirLin(...)
		return lib.btSliderConstraint_setSoftnessDirLin(self, ...)
	end
	function META:SetPoweredAngMotor(...)
		return lib.btSliderConstraint_setPoweredAngMotor(self, ...)
	end
	function META:SetMaxAngMotorForce(...)
		return lib.btSliderConstraint_setMaxAngMotorForce(self, ...)
	end
	function META:GetSoftnessDirLin(...)
		return lib.btSliderConstraint_getSoftnessDirLin(self, ...)
	end
	function META:GetDampingOrthoAng(...)
		return lib.btSliderConstraint_getDampingOrthoAng(self, ...)
	end
	function META:GetPoweredAngMotor(...)
		return lib.btSliderConstraint_getPoweredAngMotor(self, ...)
	end
	function META:GetMaxAngMotorForce(...)
		return lib.btSliderConstraint_getMaxAngMotorForce(self, ...)
	end
	function META:GetAngDepth(...)
		return lib.btSliderConstraint_getAngDepth(self, ...)
	end
	function META:SetDampingOrthoAng(...)
		return lib.btSliderConstraint_setDampingOrthoAng(self, ...)
	end
	function META:SetSoftnessDirAng(...)
		return lib.btSliderConstraint_setSoftnessDirAng(self, ...)
	end
	function META:GetDampingLimAng(...)
		return lib.btSliderConstraint_getDampingLimAng(self, ...)
	end
	function META:GetLowerLinLimit(...)
		return lib.btSliderConstraint_getLowerLinLimit(self, ...)
	end
	function META:GetDampingOrthoLin(...)
		return lib.btSliderConstraint_getDampingOrthoLin(self, ...)
	end
	function META:GetFrameOffsetB(...)
		return lib.btSliderConstraint_getFrameOffsetB(self, ...)
	end
	function META:GetSoftnessLimLin(...)
		return lib.btSliderConstraint_getSoftnessLimLin(self, ...)
	end
	function META:GetRestitutionDirLin(...)
		return lib.btSliderConstraint_getRestitutionDirLin(self, ...)
	end
	function META:GetSoftnessLimAng(...)
		return lib.btSliderConstraint_getSoftnessLimAng(self, ...)
	end
	function META:SetRestitutionLimLin(...)
		return lib.btSliderConstraint_setRestitutionLimLin(self, ...)
	end
	function META:GetSoftnessOrthoAng(...)
		return lib.btSliderConstraint_getSoftnessOrthoAng(self, ...)
	end
	function META:GetLowerAngLimit(...)
		return lib.btSliderConstraint_getLowerAngLimit(self, ...)
	end
	function META:GetPoweredLinMotor(...)
		return lib.btSliderConstraint_getPoweredLinMotor(self, ...)
	end
	function META:SetDampingLimAng(...)
		return lib.btSliderConstraint_setDampingLimAng(self, ...)
	end
	function META:TestLinLimits(...)
		return lib.btSliderConstraint_testLinLimits(self, ...)
	end
	function META:SetDampingOrthoLin(...)
		return lib.btSliderConstraint_setDampingOrthoLin(self, ...)
	end
	function META:SetRestitutionOrthoAng(...)
		return lib.btSliderConstraint_setRestitutionOrthoAng(self, ...)
	end
	function META:GetUpperAngLimit(...)
		return lib.btSliderConstraint_getUpperAngLimit(self, ...)
	end
	function META:GetUseFrameOffset(...)
		return lib.btSliderConstraint_getUseFrameOffset(self, ...)
	end
	function META:SetRestitutionDirAng(...)
		return lib.btSliderConstraint_setRestitutionDirAng(self, ...)
	end
	function META:GetRestitutionOrthoAng(...)
		return lib.btSliderConstraint_getRestitutionOrthoAng(self, ...)
	end
	function META:SetRestitutionLimAng(...)
		return lib.btSliderConstraint_setRestitutionLimAng(self, ...)
	end
	ffi.metatype('btSliderConstraint', META)
	function bullet.CreateSliderConstraint(...)
		return lib.btSliderConstraint_new(...)
	end
	function bullet.CreateSliderConstraint2(...)
		return lib.btSliderConstraint_new2(...)
	end
end
do -- EmptyShape
	local META = {}
	META.__index = META
	ffi.metatype('btEmptyShape', META)
	function bullet.CreateEmptyShape(...)
		return lib.btEmptyShape_new(...)
	end
end
do -- Dbvt_IClone
	local META = {}
	META.__index = META
	function META:CloneLeaf(...)
		return lib.btDbvt_IClone_CloneLeaf(self, ...)
	end
	function META:Delete(...)
		return lib.btDbvt_IClone_delete(self, ...)
	end
	ffi.metatype('btDbvt_IClone', META)
	function bullet.CreateDbvt_IClone(...)
		return lib.btDbvt_IClone_new(...)
	end
end
do -- DispatcherInfo
	local META = {}
	META.__index = META
	function META:SetUseConvexConservativeDistanceUtil(...)
		return lib.btDispatcherInfo_setUseConvexConservativeDistanceUtil(self, ...)
	end
	function META:GetEnableSPU(...)
		return lib.btDispatcherInfo_getEnableSPU(self, ...)
	end
	function META:GetUseConvexConservativeDistanceUtil(...)
		return lib.btDispatcherInfo_getUseConvexConservativeDistanceUtil(self, ...)
	end
	function META:GetEnableSatConvex(...)
		return lib.btDispatcherInfo_getEnableSatConvex(self, ...)
	end
	function META:SetUseEpa(...)
		return lib.btDispatcherInfo_setUseEpa(self, ...)
	end
	function META:GetConvexConservativeDistanceThreshold(...)
		return lib.btDispatcherInfo_getConvexConservativeDistanceThreshold(self, ...)
	end
	function META:GetUseEpa(...)
		return lib.btDispatcherInfo_getUseEpa(self, ...)
	end
	function META:Delete(...)
		return lib.btDispatcherInfo_delete(self, ...)
	end
	function META:GetDebugDraw(...)
		return lib.btDispatcherInfo_getDebugDraw(self, ...)
	end
	function META:GetTimeStep(...)
		return lib.btDispatcherInfo_getTimeStep(self, ...)
	end
	function META:GetTimeOfImpact(...)
		return lib.btDispatcherInfo_getTimeOfImpact(self, ...)
	end
	function META:SetTimeOfImpact(...)
		return lib.btDispatcherInfo_setTimeOfImpact(self, ...)
	end
	function META:SetEnableSatConvex(...)
		return lib.btDispatcherInfo_setEnableSatConvex(self, ...)
	end
	function META:GetAllowedCcdPenetration(...)
		return lib.btDispatcherInfo_getAllowedCcdPenetration(self, ...)
	end
	function META:GetStepCount(...)
		return lib.btDispatcherInfo_getStepCount(self, ...)
	end
	function META:SetEnableSPU(...)
		return lib.btDispatcherInfo_setEnableSPU(self, ...)
	end
	function META:GetDispatchFunc(...)
		return lib.btDispatcherInfo_getDispatchFunc(self, ...)
	end
	function META:SetDispatchFunc(...)
		return lib.btDispatcherInfo_setDispatchFunc(self, ...)
	end
	function META:SetTimeStep(...)
		return lib.btDispatcherInfo_setTimeStep(self, ...)
	end
	function META:SetStepCount(...)
		return lib.btDispatcherInfo_setStepCount(self, ...)
	end
	function META:SetDebugDraw(...)
		return lib.btDispatcherInfo_setDebugDraw(self, ...)
	end
	function META:GetUseContinuous(...)
		return lib.btDispatcherInfo_getUseContinuous(self, ...)
	end
	function META:SetConvexConservativeDistanceThreshold(...)
		return lib.btDispatcherInfo_setConvexConservativeDistanceThreshold(self, ...)
	end
	function META:SetAllowedCcdPenetration(...)
		return lib.btDispatcherInfo_setAllowedCcdPenetration(self, ...)
	end
	function META:SetUseContinuous(...)
		return lib.btDispatcherInfo_setUseContinuous(self, ...)
	end
	ffi.metatype('btDispatcherInfo', META)
	function bullet.CreateDispatcherInfo(...)
		return lib.btDispatcherInfo_new(...)
	end
end
do -- MultiBodySolverConstraint
	local META = {}
	META.__index = META
	function META:GetRhs(...)
		return lib.btMultiBodySolverConstraint_getRhs(self, ...)
	end
	function META:GetContactNormal2(...)
		return lib.btMultiBodySolverConstraint_getContactNormal2(self, ...)
	end
	function META:SetDeltaVelAindex(...)
		return lib.btMultiBodySolverConstraint_setDeltaVelAindex(self, ...)
	end
	function META:Delete(...)
		return lib.btMultiBodySolverConstraint_delete(self, ...)
	end
	function META:GetFrictionIndex(...)
		return lib.btMultiBodySolverConstraint_getFrictionIndex(self, ...)
	end
	function META:SetUnusedPadding4(...)
		return lib.btMultiBodySolverConstraint_setUnusedPadding4(self, ...)
	end
	function META:SetUpperLimit(...)
		return lib.btMultiBodySolverConstraint_setUpperLimit(self, ...)
	end
	function META:GetJacDiagABInv(...)
		return lib.btMultiBodySolverConstraint_getJacDiagABInv(self, ...)
	end
	function META:SetSolverBodyIdB(...)
		return lib.btMultiBodySolverConstraint_setSolverBodyIdB(self, ...)
	end
	function META:SetRelpos1CrossNormal(...)
		return lib.btMultiBodySolverConstraint_setRelpos1CrossNormal(self, ...)
	end
	function META:SetAppliedImpulse(...)
		return lib.btMultiBodySolverConstraint_setAppliedImpulse(self, ...)
	end
	function META:GetLinkB(...)
		return lib.btMultiBodySolverConstraint_getLinkB(self, ...)
	end
	function META:SetSolverBodyIdA(...)
		return lib.btMultiBodySolverConstraint_setSolverBodyIdA(self, ...)
	end
	function META:SetCfm(...)
		return lib.btMultiBodySolverConstraint_setCfm(self, ...)
	end
	function META:SetJacDiagABInv(...)
		return lib.btMultiBodySolverConstraint_setJacDiagABInv(self, ...)
	end
	function META:SetRhs(...)
		return lib.btMultiBodySolverConstraint_setRhs(self, ...)
	end
	function META:SetFrictionIndex(...)
		return lib.btMultiBodySolverConstraint_setFrictionIndex(self, ...)
	end
	function META:GetAngularComponentA(...)
		return lib.btMultiBodySolverConstraint_getAngularComponentA(self, ...)
	end
	function META:SetRelpos2CrossNormal(...)
		return lib.btMultiBodySolverConstraint_setRelpos2CrossNormal(self, ...)
	end
	function META:GetAppliedPushImpulse(...)
		return lib.btMultiBodySolverConstraint_getAppliedPushImpulse(self, ...)
	end
	function META:GetLowerLimit(...)
		return lib.btMultiBodySolverConstraint_getLowerLimit(self, ...)
	end
	function META:SetContactNormal2(...)
		return lib.btMultiBodySolverConstraint_setContactNormal2(self, ...)
	end
	function META:SetOriginalContactPoint(...)
		return lib.btMultiBodySolverConstraint_setOriginalContactPoint(self, ...)
	end
	function META:SetMultiBodyB(...)
		return lib.btMultiBodySolverConstraint_setMultiBodyB(self, ...)
	end
	function META:SetMultiBodyA(...)
		return lib.btMultiBodySolverConstraint_setMultiBodyA(self, ...)
	end
	function META:SetLowerLimit(...)
		return lib.btMultiBodySolverConstraint_setLowerLimit(self, ...)
	end
	function META:SetLinkB(...)
		return lib.btMultiBodySolverConstraint_setLinkB(self, ...)
	end
	function META:SetJacBindex(...)
		return lib.btMultiBodySolverConstraint_setJacBindex(self, ...)
	end
	function META:SetLinkA(...)
		return lib.btMultiBodySolverConstraint_setLinkA(self, ...)
	end
	function META:GetRelpos1CrossNormal(...)
		return lib.btMultiBodySolverConstraint_getRelpos1CrossNormal(self, ...)
	end
	function META:GetRelpos2CrossNormal(...)
		return lib.btMultiBodySolverConstraint_getRelpos2CrossNormal(self, ...)
	end
	function META:GetMultiBodyB(...)
		return lib.btMultiBodySolverConstraint_getMultiBodyB(self, ...)
	end
	function META:GetUpperLimit(...)
		return lib.btMultiBodySolverConstraint_getUpperLimit(self, ...)
	end
	function META:SetRhsPenetration(...)
		return lib.btMultiBodySolverConstraint_setRhsPenetration(self, ...)
	end
	function META:SetJacAindex(...)
		return lib.btMultiBodySolverConstraint_setJacAindex(self, ...)
	end
	function META:GetOriginalContactPoint(...)
		return lib.btMultiBodySolverConstraint_getOriginalContactPoint(self, ...)
	end
	function META:SetAngularComponentA(...)
		return lib.btMultiBodySolverConstraint_setAngularComponentA(self, ...)
	end
	function META:GetDeltaVelBindex(...)
		return lib.btMultiBodySolverConstraint_getDeltaVelBindex(self, ...)
	end
	function META:SetFriction(...)
		return lib.btMultiBodySolverConstraint_setFriction(self, ...)
	end
	function META:SetDeltaVelBindex(...)
		return lib.btMultiBodySolverConstraint_setDeltaVelBindex(self, ...)
	end
	function META:SetOverrideNumSolverIterations(...)
		return lib.btMultiBodySolverConstraint_setOverrideNumSolverIterations(self, ...)
	end
	function META:GetUnusedPadding4(...)
		return lib.btMultiBodySolverConstraint_getUnusedPadding4(self, ...)
	end
	function META:GetAngularComponentB(...)
		return lib.btMultiBodySolverConstraint_getAngularComponentB(self, ...)
	end
	function META:GetSolverBodyIdB(...)
		return lib.btMultiBodySolverConstraint_getSolverBodyIdB(self, ...)
	end
	function META:SetAppliedPushImpulse(...)
		return lib.btMultiBodySolverConstraint_setAppliedPushImpulse(self, ...)
	end
	function META:GetCfm(...)
		return lib.btMultiBodySolverConstraint_getCfm(self, ...)
	end
	function META:SetContactNormal1(...)
		return lib.btMultiBodySolverConstraint_setContactNormal1(self, ...)
	end
	function META:GetDeltaVelAindex(...)
		return lib.btMultiBodySolverConstraint_getDeltaVelAindex(self, ...)
	end
	function META:GetJacAindex(...)
		return lib.btMultiBodySolverConstraint_getJacAindex(self, ...)
	end
	function META:GetFriction(...)
		return lib.btMultiBodySolverConstraint_getFriction(self, ...)
	end
	function META:GetOverrideNumSolverIterations(...)
		return lib.btMultiBodySolverConstraint_getOverrideNumSolverIterations(self, ...)
	end
	function META:GetContactNormal1(...)
		return lib.btMultiBodySolverConstraint_getContactNormal1(self, ...)
	end
	function META:GetSolverBodyIdA(...)
		return lib.btMultiBodySolverConstraint_getSolverBodyIdA(self, ...)
	end
	function META:GetAppliedImpulse(...)
		return lib.btMultiBodySolverConstraint_getAppliedImpulse(self, ...)
	end
	function META:GetMultiBodyA(...)
		return lib.btMultiBodySolverConstraint_getMultiBodyA(self, ...)
	end
	function META:GetJacBindex(...)
		return lib.btMultiBodySolverConstraint_getJacBindex(self, ...)
	end
	function META:GetRhsPenetration(...)
		return lib.btMultiBodySolverConstraint_getRhsPenetration(self, ...)
	end
	function META:GetLinkA(...)
		return lib.btMultiBodySolverConstraint_getLinkA(self, ...)
	end
	function META:SetAngularComponentB(...)
		return lib.btMultiBodySolverConstraint_setAngularComponentB(self, ...)
	end
	ffi.metatype('btMultiBodySolverConstraint', META)
	function bullet.CreateMultiBodySolverConstraint(...)
		return lib.btMultiBodySolverConstraint_new(...)
	end
end
do -- AlignedManifoldArray
	local META = {}
	META.__index = META
	function META:Delete(...)
		return lib.btAlignedManifoldArray_delete(self, ...)
	end
	function META:Size(...)
		return lib.btAlignedManifoldArray_size(self, ...)
	end
	function META:ResizeNoInitialize(...)
		return lib.btAlignedManifoldArray_resizeNoInitialize(self, ...)
	end
	function META:At(...)
		return lib.btAlignedManifoldArray_at(self, ...)
	end
	ffi.metatype('btAlignedManifoldArray', META)
	function bullet.CreateAlignedManifoldArray(...)
		return lib.btAlignedManifoldArray_new(...)
	end
end
do -- StorageResult
	local META = {}
	META.__index = META
	function META:GetClosestPointInB(...)
		return lib.btStorageResult_getClosestPointInB(self, ...)
	end
	function META:SetDistance(...)
		return lib.btStorageResult_setDistance(self, ...)
	end
	function META:GetNormalOnSurfaceB(...)
		return lib.btStorageResult_getNormalOnSurfaceB(self, ...)
	end
	function META:GetDistance(...)
		return lib.btStorageResult_getDistance(self, ...)
	end
	function META:SetNormalOnSurfaceB(...)
		return lib.btStorageResult_setNormalOnSurfaceB(self, ...)
	end
	function META:SetClosestPointInB(...)
		return lib.btStorageResult_setClosestPointInB(self, ...)
	end
	ffi.metatype('btStorageResult', META)
	function bullet.CreateStorageResult(...)
		return lib.btStorageResult_new(...)
	end
end
do -- SoftBody_Anchor
	local META = {}
	META.__index = META
	function META:SetC0(...)
		return lib.btSoftBody_Anchor_setC0(self, ...)
	end
	function META:GetC0(...)
		return lib.btSoftBody_Anchor_getC0(self, ...)
	end
	function META:GetInfluence(...)
		return lib.btSoftBody_Anchor_getInfluence(self, ...)
	end
	function META:GetLocal(...)
		return lib.btSoftBody_Anchor_getLocal(self, ...)
	end
	function META:SetNode(...)
		return lib.btSoftBody_Anchor_setNode(self, ...)
	end
	function META:GetNode(...)
		return lib.btSoftBody_Anchor_getNode(self, ...)
	end
	function META:Delete(...)
		return lib.btSoftBody_Anchor_delete(self, ...)
	end
	function META:SetLocal(...)
		return lib.btSoftBody_Anchor_setLocal(self, ...)
	end
	function META:GetBody(...)
		return lib.btSoftBody_Anchor_getBody(self, ...)
	end
	function META:SetBody(...)
		return lib.btSoftBody_Anchor_setBody(self, ...)
	end
	function META:SetC2(...)
		return lib.btSoftBody_Anchor_setC2(self, ...)
	end
	function META:GetC1(...)
		return lib.btSoftBody_Anchor_getC1(self, ...)
	end
	function META:SetC1(...)
		return lib.btSoftBody_Anchor_setC1(self, ...)
	end
	function META:GetC2(...)
		return lib.btSoftBody_Anchor_getC2(self, ...)
	end
	function META:SetInfluence(...)
		return lib.btSoftBody_Anchor_setInfluence(self, ...)
	end
	ffi.metatype('btSoftBody_Anchor', META)
	function bullet.CreateSoftBody_Anchor(...)
		return lib.btSoftBody_Anchor_new(...)
	end
end
do -- Generic6DofConstraint
	local META = {}
	META.__index = META
	function META:GetCalculatedTransformB(...)
		return lib.btGeneric6DofConstraint_getCalculatedTransformB(self, ...)
	end
	function META:SetUseFrameOffset(...)
		return lib.btGeneric6DofConstraint_setUseFrameOffset(self, ...)
	end
	function META:TestAngularLimitMotor(...)
		return lib.btGeneric6DofConstraint_testAngularLimitMotor(self, ...)
	end
	function META:GetFrameOffsetA(...)
		return lib.btGeneric6DofConstraint_getFrameOffsetA(self, ...)
	end
	function META:CalculateTransforms(...)
		return lib.btGeneric6DofConstraint_calculateTransforms(self, ...)
	end
	function META:SetAxis(...)
		return lib.btGeneric6DofConstraint_setAxis(self, ...)
	end
	function META:GetInfo1NonVirtual(...)
		return lib.btGeneric6DofConstraint_getInfo1NonVirtual(self, ...)
	end
	function META:SetLimit(...)
		return lib.btGeneric6DofConstraint_setLimit(self, ...)
	end
	function META:GetLinearLowerLimit(...)
		return lib.btGeneric6DofConstraint_getLinearLowerLimit(self, ...)
	end
	function META:SetAngularLowerLimit(...)
		return lib.btGeneric6DofConstraint_setAngularLowerLimit(self, ...)
	end
	function META:UpdateRHS(...)
		return lib.btGeneric6DofConstraint_updateRHS(self, ...)
	end
	function META:IsLimited(...)
		return lib.btGeneric6DofConstraint_isLimited(self, ...)
	end
	function META:GetRelativePivotPosition(...)
		return lib.btGeneric6DofConstraint_getRelativePivotPosition(self, ...)
	end
	function META:SetFrames(...)
		return lib.btGeneric6DofConstraint_setFrames(self, ...)
	end
	function META:SetLinearLowerLimit(...)
		return lib.btGeneric6DofConstraint_setLinearLowerLimit(self, ...)
	end
	function META:CalcAnchorPos(...)
		return lib.btGeneric6DofConstraint_calcAnchorPos(self, ...)
	end
	function META:SetUseSolveConstraintObsolete(...)
		return lib.btGeneric6DofConstraint_setUseSolveConstraintObsolete(self, ...)
	end
	function META:GetFrameOffsetB(...)
		return lib.btGeneric6DofConstraint_getFrameOffsetB(self, ...)
	end
	function META:CalculateTransforms2(...)
		return lib.btGeneric6DofConstraint_calculateTransforms2(self, ...)
	end
	function META:GetAxis(...)
		return lib.btGeneric6DofConstraint_getAxis(self, ...)
	end
	function META:SetLinearUpperLimit(...)
		return lib.btGeneric6DofConstraint_setLinearUpperLimit(self, ...)
	end
	function META:GetAngularLowerLimit(...)
		return lib.btGeneric6DofConstraint_getAngularLowerLimit(self, ...)
	end
	function META:GetUseSolveConstraintObsolete(...)
		return lib.btGeneric6DofConstraint_getUseSolveConstraintObsolete(self, ...)
	end
	function META:GetAngle(...)
		return lib.btGeneric6DofConstraint_getAngle(self, ...)
	end
	function META:GetTranslationalLimitMotor(...)
		return lib.btGeneric6DofConstraint_getTranslationalLimitMotor(self, ...)
	end
	function META:GetAngularUpperLimit(...)
		return lib.btGeneric6DofConstraint_getAngularUpperLimit(self, ...)
	end
	function META:GetCalculatedTransformA(...)
		return lib.btGeneric6DofConstraint_getCalculatedTransformA(self, ...)
	end
	function META:GetRotationalLimitMotor(...)
		return lib.btGeneric6DofConstraint_getRotationalLimitMotor(self, ...)
	end
	function META:GetUseFrameOffset(...)
		return lib.btGeneric6DofConstraint_getUseFrameOffset(self, ...)
	end
	function META:SetAngularUpperLimit(...)
		return lib.btGeneric6DofConstraint_setAngularUpperLimit(self, ...)
	end
	function META:GetInfo2NonVirtual(...)
		return lib.btGeneric6DofConstraint_getInfo2NonVirtual(self, ...)
	end
	function META:GetLinearUpperLimit(...)
		return lib.btGeneric6DofConstraint_getLinearUpperLimit(self, ...)
	end
	ffi.metatype('btGeneric6DofConstraint', META)
	function bullet.CreateGeneric6DofConstraint2(...)
		return lib.btGeneric6DofConstraint_new2(...)
	end
	function bullet.CreateGeneric6DofConstraint6(...)
		return lib.btGeneric6DofConstraint_new(...)
	end
end
do -- Box2dBox2dCollisionAlgorithm_CreateFunc
	local META = {}
	META.__index = META
	ffi.metatype('btBox2dBox2dCollisionAlgorithm_CreateFunc', META)
	function bullet.CreateBox2dBox2dCollisionAlgorithm_CreateFunc2(...)
		return lib.btBox2dBox2dCollisionAlgorithm_CreateFunc_new(...)
	end
end
do -- RotationalLimitMotor
	local META = {}
	META.__index = META
	function META:SetTargetVelocity(...)
		return lib.btRotationalLimitMotor_setTargetVelocity(self, ...)
	end
	function META:GetAccumulatedImpulse(...)
		return lib.btRotationalLimitMotor_getAccumulatedImpulse(self, ...)
	end
	function META:GetLoLimit(...)
		return lib.btRotationalLimitMotor_getLoLimit(self, ...)
	end
	function META:SetCurrentLimitError(...)
		return lib.btRotationalLimitMotor_setCurrentLimitError(self, ...)
	end
	function META:SetLimitSoftness(...)
		return lib.btRotationalLimitMotor_setLimitSoftness(self, ...)
	end
	function META:SetCurrentPosition(...)
		return lib.btRotationalLimitMotor_setCurrentPosition(self, ...)
	end
	function META:SetMaxLimitForce(...)
		return lib.btRotationalLimitMotor_setMaxLimitForce(self, ...)
	end
	function META:GetMaxMotorForce(...)
		return lib.btRotationalLimitMotor_getMaxMotorForce(self, ...)
	end
	function META:GetBounce(...)
		return lib.btRotationalLimitMotor_getBounce(self, ...)
	end
	function META:GetLimitSoftness(...)
		return lib.btRotationalLimitMotor_getLimitSoftness(self, ...)
	end
	function META:SetNormalCFM(...)
		return lib.btRotationalLimitMotor_setNormalCFM(self, ...)
	end
	function META:GetDamping(...)
		return lib.btRotationalLimitMotor_getDamping(self, ...)
	end
	function META:IsLimited(...)
		return lib.btRotationalLimitMotor_isLimited(self, ...)
	end
	function META:SetCurrentLimit(...)
		return lib.btRotationalLimitMotor_setCurrentLimit(self, ...)
	end
	function META:SetStopCFM(...)
		return lib.btRotationalLimitMotor_setStopCFM(self, ...)
	end
	function META:SetDamping(...)
		return lib.btRotationalLimitMotor_setDamping(self, ...)
	end
	function META:GetTargetVelocity(...)
		return lib.btRotationalLimitMotor_getTargetVelocity(self, ...)
	end
	function META:SetAccumulatedImpulse(...)
		return lib.btRotationalLimitMotor_setAccumulatedImpulse(self, ...)
	end
	function META:GetStopERP(...)
		return lib.btRotationalLimitMotor_getStopERP(self, ...)
	end
	function META:Delete(...)
		return lib.btRotationalLimitMotor_delete(self, ...)
	end
	function META:GetCurrentPosition(...)
		return lib.btRotationalLimitMotor_getCurrentPosition(self, ...)
	end
	function META:GetMaxLimitForce(...)
		return lib.btRotationalLimitMotor_getMaxLimitForce(self, ...)
	end
	function META:SetLoLimit(...)
		return lib.btRotationalLimitMotor_setLoLimit(self, ...)
	end
	function META:TestLimitValue(...)
		return lib.btRotationalLimitMotor_testLimitValue(self, ...)
	end
	function META:SolveAngularLimits(...)
		return lib.btRotationalLimitMotor_solveAngularLimits(self, ...)
	end
	function META:SetEnableMotor(...)
		return lib.btRotationalLimitMotor_setEnableMotor(self, ...)
	end
	function META:GetCurrentLimitError(...)
		return lib.btRotationalLimitMotor_getCurrentLimitError(self, ...)
	end
	function META:GetStopCFM(...)
		return lib.btRotationalLimitMotor_getStopCFM(self, ...)
	end
	function META:GetHiLimit(...)
		return lib.btRotationalLimitMotor_getHiLimit(self, ...)
	end
	function META:GetNormalCFM(...)
		return lib.btRotationalLimitMotor_getNormalCFM(self, ...)
	end
	function META:SetStopERP(...)
		return lib.btRotationalLimitMotor_setStopERP(self, ...)
	end
	function META:SetBounce(...)
		return lib.btRotationalLimitMotor_setBounce(self, ...)
	end
	function META:SetMaxMotorForce(...)
		return lib.btRotationalLimitMotor_setMaxMotorForce(self, ...)
	end
	function META:SetHiLimit(...)
		return lib.btRotationalLimitMotor_setHiLimit(self, ...)
	end
	function META:NeedApplyTorques(...)
		return lib.btRotationalLimitMotor_needApplyTorques(self, ...)
	end
	function META:GetEnableMotor(...)
		return lib.btRotationalLimitMotor_getEnableMotor(self, ...)
	end
	function META:GetCurrentLimit(...)
		return lib.btRotationalLimitMotor_getCurrentLimit(self, ...)
	end
	ffi.metatype('btRotationalLimitMotor', META)
	function bullet.CreateRotationalLimitMotor2(...)
		return lib.btRotationalLimitMotor_new2(...)
	end
	function bullet.CreateRotationalLimitMotor(...)
		return lib.btRotationalLimitMotor_new(...)
	end
end
do -- MultiBodyLinkCollider
	local META = {}
	META.__index = META
	function META:GetMultiBody(...)
		return lib.btMultiBodyLinkCollider_getMultiBody(self, ...)
	end
	function META:GetLink(...)
		return lib.btMultiBodyLinkCollider_getLink(self, ...)
	end
	function META:SetMultiBody(...)
		return lib.btMultiBodyLinkCollider_setMultiBody(self, ...)
	end
	function META:Upcast(...)
		return lib.btMultiBodyLinkCollider_upcast(self, ...)
	end
	function META:SetLink(...)
		return lib.btMultiBodyLinkCollider_setLink(self, ...)
	end
	ffi.metatype('btMultiBodyLinkCollider', META)
	function bullet.CreateMultiBodyLinkCollider(...)
		return lib.btMultiBodyLinkCollider_new(...)
	end
end
do -- SoftRigidDynamicsWorld
	local META = {}
	META.__index = META
	function META:AddSoftBody2(...)
		return lib.btSoftRigidDynamicsWorld_addSoftBody2(self, ...)
	end
	function META:SetDrawFlags(...)
		return lib.btSoftRigidDynamicsWorld_setDrawFlags(self, ...)
	end
	function META:AddSoftBody(...)
		return lib.btSoftRigidDynamicsWorld_addSoftBody(self, ...)
	end
	function META:AddSoftBody3(...)
		return lib.btSoftRigidDynamicsWorld_addSoftBody3(self, ...)
	end
	function META:GetSoftBodyArray(...)
		return lib.btSoftRigidDynamicsWorld_getSoftBodyArray(self, ...)
	end
	function META:GetWorldInfo(...)
		return lib.btSoftRigidDynamicsWorld_getWorldInfo(self, ...)
	end
	function META:GetDrawFlags(...)
		return lib.btSoftRigidDynamicsWorld_getDrawFlags(self, ...)
	end
	function META:RemoveSoftBody(...)
		return lib.btSoftRigidDynamicsWorld_removeSoftBody(self, ...)
	end
	ffi.metatype('btSoftRigidDynamicsWorld', META)
	function bullet.CreateSoftRigidDynamicsWorld2(...)
		return lib.btSoftRigidDynamicsWorld_new2(...)
	end
	function bullet.CreateSoftRigidDynamicsWorld(...)
		return lib.btSoftRigidDynamicsWorld_new(...)
	end
end
do -- SoftBody_LJoint
	local META = {}
	META.__index = META
	function META:GetRpos(...)
		return lib.btSoftBody_LJoint_getRpos(self, ...)
	end
	ffi.metatype('btSoftBody_LJoint', META)
	function bullet.CreateSoftBody_LJoint(...)
		return lib.btSoftBody_LJoint_new(...)
	end
end
do -- Convex2dConvex2dAlgorithm_CreateFunc
	local META = {}
	META.__index = META
	function META:GetSimplexSolver(...)
		return lib.btConvex2dConvex2dAlgorithm_CreateFunc_getSimplexSolver(self, ...)
	end
	function META:GetNumPerturbationIterations(...)
		return lib.btConvex2dConvex2dAlgorithm_CreateFunc_getNumPerturbationIterations(self, ...)
	end
	function META:SetMinimumPointsPerturbationThreshold(...)
		return lib.btConvex2dConvex2dAlgorithm_CreateFunc_setMinimumPointsPerturbationThreshold(self, ...)
	end
	function META:SetPdSolver(...)
		return lib.btConvex2dConvex2dAlgorithm_CreateFunc_setPdSolver(self, ...)
	end
	function META:SetSimplexSolver(...)
		return lib.btConvex2dConvex2dAlgorithm_CreateFunc_setSimplexSolver(self, ...)
	end
	function META:SetNumPerturbationIterations(...)
		return lib.btConvex2dConvex2dAlgorithm_CreateFunc_setNumPerturbationIterations(self, ...)
	end
	function META:GetMinimumPointsPerturbationThreshold(...)
		return lib.btConvex2dConvex2dAlgorithm_CreateFunc_getMinimumPointsPerturbationThreshold(self, ...)
	end
	function META:GetPdSolver(...)
		return lib.btConvex2dConvex2dAlgorithm_CreateFunc_getPdSolver(self, ...)
	end
	ffi.metatype('btConvex2dConvex2dAlgorithm_CreateFunc', META)
	function bullet.CreateConvex2dConvex2dAlgorithm_CreateFunc2(...)
		return lib.btConvex2dConvex2dAlgorithm_CreateFunc_new(...)
	end
end
do -- SoftBodyRigidBodyCollisionConfiguration
	local META = {}
	META.__index = META
	ffi.metatype('btSoftBodyRigidBodyCollisionConfiguration', META)
	function bullet.CreateSoftBodyRigidBodyCollisionConfiguration(...)
		return lib.btSoftBodyRigidBodyCollisionConfiguration_new(...)
	end
	function bullet.CreateSoftBodyRigidBodyCollisionConfiguration2(...)
		return lib.btSoftBodyRigidBodyCollisionConfiguration_new2(...)
	end
end
do -- ConvexSeparatingDistanceUtil
	local META = {}
	META.__index = META
	function META:InitSeparatingDistance(...)
		return lib.btConvexSeparatingDistanceUtil_initSeparatingDistance(self, ...)
	end
	function META:GetConservativeSeparatingDistance(...)
		return lib.btConvexSeparatingDistanceUtil_getConservativeSeparatingDistance(self, ...)
	end
	function META:Delete(...)
		return lib.btConvexSeparatingDistanceUtil_delete(self, ...)
	end
	function META:UpdateSeparatingDistance(...)
		return lib.btConvexSeparatingDistanceUtil_updateSeparatingDistance(self, ...)
	end
	ffi.metatype('btConvexSeparatingDistanceUtil', META)
	function bullet.CreateConvexSeparatingDistanceUtil(...)
		return lib.btConvexSeparatingDistanceUtil_new(...)
	end
end
do -- DbvtProxy
	local META = {}
	META.__index = META
	function META:GetStage(...)
		return lib.btDbvtProxy_getStage(self, ...)
	end
	function META:SetLeaf(...)
		return lib.btDbvtProxy_setLeaf(self, ...)
	end
	function META:SetStage(...)
		return lib.btDbvtProxy_setStage(self, ...)
	end
	function META:GetLinks(...)
		return lib.btDbvtProxy_getLinks(self, ...)
	end
	function META:GetLeaf(...)
		return lib.btDbvtProxy_getLeaf(self, ...)
	end
	ffi.metatype('btDbvtProxy', META)
	function bullet.CreateDbvtProxy(...)
		return lib.btDbvtProxy_new(...)
	end
end
do -- UniversalConstraint
	local META = {}
	META.__index = META
	function META:GetAngle2(...)
		return lib.btUniversalConstraint_getAngle2(self, ...)
	end
	function META:GetAxis2(...)
		return lib.btUniversalConstraint_getAxis2(self, ...)
	end
	function META:SetUpperLimit(...)
		return lib.btUniversalConstraint_setUpperLimit(self, ...)
	end
	function META:GetAnchor2(...)
		return lib.btUniversalConstraint_getAnchor2(self, ...)
	end
	function META:GetAxis1(...)
		return lib.btUniversalConstraint_getAxis1(self, ...)
	end
	function META:SetLowerLimit(...)
		return lib.btUniversalConstraint_setLowerLimit(self, ...)
	end
	function META:GetAngle1(...)
		return lib.btUniversalConstraint_getAngle1(self, ...)
	end
	function META:GetAnchor(...)
		return lib.btUniversalConstraint_getAnchor(self, ...)
	end
	ffi.metatype('btUniversalConstraint', META)
	function bullet.CreateUniversalConstraint(...)
		return lib.btUniversalConstraint_new(...)
	end
end
do -- ConvexInternalAabbCachingShape
	local META = {}
	META.__index = META
	function META:RecalcLocalAabb(...)
		return lib.btConvexInternalAabbCachingShape_recalcLocalAabb(self, ...)
	end
	ffi.metatype('btConvexInternalAabbCachingShape', META)
	function bullet.CreateConvexInternalAabbCachingShape(...)
		return lib.btConvexInternalAabbCachingShape_new(...)
	end
end
do -- ConvexPolyhedron
	local META = {}
	META.__index = META
	function META:GetLocalCenter(...)
		return lib.btConvexPolyhedron_getLocalCenter(self, ...)
	end
	function META:TestContainment(...)
		return lib.btConvexPolyhedron_testContainment(self, ...)
	end
	function META:Initialize(...)
		return lib.btConvexPolyhedron_initialize(self, ...)
	end
	function META:SetMC(...)
		return lib.btConvexPolyhedron_setMC(self, ...)
	end
	function META:SetME(...)
		return lib.btConvexPolyhedron_setME(self, ...)
	end
	function META:GetFaces(...)
		return lib.btConvexPolyhedron_getFaces(self, ...)
	end
	function META:GetExtents(...)
		return lib.btConvexPolyhedron_getExtents(self, ...)
	end
	function META:SetLocalCenter(...)
		return lib.btConvexPolyhedron_setLocalCenter(self, ...)
	end
	function META:Project(...)
		return lib.btConvexPolyhedron_project(self, ...)
	end
	function META:Delete(...)
		return lib.btConvexPolyhedron_delete(self, ...)
	end
	function META:SetRadius(...)
		return lib.btConvexPolyhedron_setRadius(self, ...)
	end
	function META:GetRadius(...)
		return lib.btConvexPolyhedron_getRadius(self, ...)
	end
	function META:SetExtents(...)
		return lib.btConvexPolyhedron_setExtents(self, ...)
	end
	function META:GetME(...)
		return lib.btConvexPolyhedron_getME(self, ...)
	end
	function META:GetUniqueEdges(...)
		return lib.btConvexPolyhedron_getUniqueEdges(self, ...)
	end
	function META:GetVertices(...)
		return lib.btConvexPolyhedron_getVertices(self, ...)
	end
	function META:GetMC(...)
		return lib.btConvexPolyhedron_getMC(self, ...)
	end
	ffi.metatype('btConvexPolyhedron', META)
	function bullet.CreateConvexPolyhedron(...)
		return lib.btConvexPolyhedron_new(...)
	end
end
do -- GhostObject
	local META = {}
	META.__index = META
	function META:GetOverlappingPairs(...)
		return lib.btGhostObject_getOverlappingPairs(self, ...)
	end
	function META:ConvexSweepTest2(...)
		return lib.btGhostObject_convexSweepTest2(self, ...)
	end
	function META:RemoveOverlappingObjectInternal(...)
		return lib.btGhostObject_removeOverlappingObjectInternal(self, ...)
	end
	function META:AddOverlappingObjectInternal(...)
		return lib.btGhostObject_addOverlappingObjectInternal(self, ...)
	end
	function META:Upcast(...)
		return lib.btGhostObject_upcast(self, ...)
	end
	function META:GetNumOverlappingObjects(...)
		return lib.btGhostObject_getNumOverlappingObjects(self, ...)
	end
	function META:GetOverlappingObject(...)
		return lib.btGhostObject_getOverlappingObject(self, ...)
	end
	function META:RemoveOverlappingObjectInternal2(...)
		return lib.btGhostObject_removeOverlappingObjectInternal2(self, ...)
	end
	function META:AddOverlappingObjectInternal2(...)
		return lib.btGhostObject_addOverlappingObjectInternal2(self, ...)
	end
	function META:ConvexSweepTest(...)
		return lib.btGhostObject_convexSweepTest(self, ...)
	end
	function META:RayTest(...)
		return lib.btGhostObject_rayTest(self, ...)
	end
	ffi.metatype('btGhostObject', META)
	function bullet.CreateGhostObject(...)
		return lib.btGhostObject_new(...)
	end
end
do -- ConvexTriangleMeshShape
	local META = {}
	META.__index = META
	function META:GetMeshInterface(...)
		return lib.btConvexTriangleMeshShape_getMeshInterface(self, ...)
	end
	function META:CalculatePrincipalAxisTransform(...)
		return lib.btConvexTriangleMeshShape_calculatePrincipalAxisTransform(self, ...)
	end
	ffi.metatype('btConvexTriangleMeshShape', META)
	function bullet.CreateConvexTriangleMeshShape2(...)
		return lib.btConvexTriangleMeshShape_new2(...)
	end
	function bullet.CreateConvexTriangleMeshShape(...)
		return lib.btConvexTriangleMeshShape_new(...)
	end
end
do -- GhostPairCallback
	local META = {}
	META.__index = META
	ffi.metatype('btGhostPairCallback', META)
	function bullet.CreateGhostPairCallback(...)
		return lib.btGhostPairCallback_new(...)
	end
end
do -- ConvexConcaveCollisionAlgorithm_CreateFunc
	local META = {}
	META.__index = META
	ffi.metatype('btConvexConcaveCollisionAlgorithm_CreateFunc', META)
	function bullet.CreateConvexConcaveCollisionAlgorithm_CreateFunc(...)
		return lib.btConvexConcaveCollisionAlgorithm_CreateFunc_new(...)
	end
end
do -- SoftRigidCollisionAlgorithm_CreateFunc
	local META = {}
	META.__index = META
	ffi.metatype('btSoftRigidCollisionAlgorithm_CreateFunc', META)
	function bullet.CreateSoftRigidCollisionAlgorithm_CreateFunc(...)
		return lib.btSoftRigidCollisionAlgorithm_CreateFunc_new(...)
	end
end
do -- CapsuleShape
	local META = {}
	META.__index = META
	function META:GetHalfHeight(...)
		return lib.btCapsuleShape_getHalfHeight(self, ...)
	end
	function META:GetRadius(...)
		return lib.btCapsuleShape_getRadius(self, ...)
	end
	function META:GetUpAxis(...)
		return lib.btCapsuleShape_getUpAxis(self, ...)
	end
	ffi.metatype('btCapsuleShape', META)
	function bullet.CreateCapsuleShape(...)
		return lib.btCapsuleShape_new(...)
	end
end
do -- AABB
	local META = {}
	META.__index = META
	function META:GetMax(...)
		return lib.btAABB_getMax(self, ...)
	end
	function META:Invalidate(...)
		return lib.btAABB_invalidate(self, ...)
	end
	function META:Delete(...)
		return lib.btAABB_delete(self, ...)
	end
	function META:SetMin(...)
		return lib.btAABB_setMin(self, ...)
	end
	function META:SetMax(...)
		return lib.btAABB_setMax(self, ...)
	end
	function META:Merge(...)
		return lib.btAABB_merge(self, ...)
	end
	function META:GetMin(...)
		return lib.btAABB_getMin(self, ...)
	end
	ffi.metatype('btAABB', META)
	function bullet.CreateAABB4(...)
		return lib.btAABB_new4(...)
	end
	function bullet.CreateAABB5(...)
		return lib.btAABB_new5(...)
	end
	function bullet.CreateAABB(...)
		return lib.btAABB_new(...)
	end
	function bullet.CreateAABB2(...)
		return lib.btAABB_new2(...)
	end
	function bullet.CreateAABB3(...)
		return lib.btAABB_new3(...)
	end
end
do -- CompoundCollisionAlgorithm_CreateFunc
	local META = {}
	META.__index = META
	ffi.metatype('btCompoundCollisionAlgorithm_CreateFunc', META)
	function bullet.CreateCompoundCollisionAlgorithm_CreateFunc(...)
		return lib.btCompoundCollisionAlgorithm_CreateFunc_new(...)
	end
end
do -- GImpactMeshShapePart_TrimeshPrimitiveManager
	local META = {}
	META.__index = META
	function META:GetPart(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_getPart(self, ...)
	end
	function META:GetIndicestype(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_getIndicestype(self, ...)
	end
	function META:SetScale(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_setScale(self, ...)
	end
	function META:GetMargin(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_getMargin(self, ...)
	end
	function META:GetType(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_getType(self, ...)
	end
	function META:GetScale(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_getScale(self, ...)
	end
	function META:GetIndexbase(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_getIndexbase(self, ...)
	end
	function META:SetNumfaces(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_setNumfaces(self, ...)
	end
	function META:SetMargin(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_setMargin(self, ...)
	end
	function META:GetVertexbase(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_getVertexbase(self, ...)
	end
	function META:SetVertexbase(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_setVertexbase(self, ...)
	end
	function META:SetMeshInterface(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_setMeshInterface(self, ...)
	end
	function META:SetType(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_setType(self, ...)
	end
	function META:GetIndexstride(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_getIndexstride(self, ...)
	end
	function META:GetStride(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_getStride(self, ...)
	end
	function META:SetIndexbase(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_setIndexbase(self, ...)
	end
	function META:SetStride(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_setStride(self, ...)
	end
	function META:SetPart(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_setPart(self, ...)
	end
	function META:SetNumverts(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_setNumverts(self, ...)
	end
	function META:Unlock(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_unlock(self, ...)
	end
	function META:GetNumfaces(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_getNumfaces(self, ...)
	end
	function META:GetNumverts(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_getNumverts(self, ...)
	end
	function META:Lock(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_lock(self, ...)
	end
	function META:GetMeshInterface(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_getMeshInterface(self, ...)
	end
	function META:SetIndicestype(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_setIndicestype(self, ...)
	end
	function META:SetIndexstride(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_setIndexstride(self, ...)
	end
	ffi.metatype('btGImpactMeshShapePart_TrimeshPrimitiveManager', META)
	function bullet.CreateGImpactMeshShapePart_TrimeshPrimitiveManager3(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_new3(...)
	end
	function bullet.CreateGImpactMeshShapePart_TrimeshPrimitiveManager2(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_new2(...)
	end
	function bullet.CreateGImpactMeshShapePart_TrimeshPrimitiveManager(...)
		return lib.btGImpactMeshShapePart_TrimeshPrimitiveManager_new(...)
	end
end
do -- DefaultCollisionConstructionInfo
	local META = {}
	META.__index = META
	function META:GetDefaultMaxPersistentManifoldPoolSize(...)
		return lib.btDefaultCollisionConstructionInfo_getDefaultMaxPersistentManifoldPoolSize(self, ...)
	end
	function META:Delete(...)
		return lib.btDefaultCollisionConstructionInfo_delete(self, ...)
	end
	function META:SetDefaultMaxPersistentManifoldPoolSize(...)
		return lib.btDefaultCollisionConstructionInfo_setDefaultMaxPersistentManifoldPoolSize(self, ...)
	end
	function META:GetCustomCollisionAlgorithmMaxElementSize(...)
		return lib.btDefaultCollisionConstructionInfo_getCustomCollisionAlgorithmMaxElementSize(self, ...)
	end
	function META:SetCollisionAlgorithmPool(...)
		return lib.btDefaultCollisionConstructionInfo_setCollisionAlgorithmPool(self, ...)
	end
	function META:SetPersistentManifoldPool(...)
		return lib.btDefaultCollisionConstructionInfo_setPersistentManifoldPool(self, ...)
	end
	function META:SetUseEpaPenetrationAlgorithm(...)
		return lib.btDefaultCollisionConstructionInfo_setUseEpaPenetrationAlgorithm(self, ...)
	end
	function META:SetCustomCollisionAlgorithmMaxElementSize(...)
		return lib.btDefaultCollisionConstructionInfo_setCustomCollisionAlgorithmMaxElementSize(self, ...)
	end
	function META:GetCollisionAlgorithmPool(...)
		return lib.btDefaultCollisionConstructionInfo_getCollisionAlgorithmPool(self, ...)
	end
	function META:GetDefaultMaxCollisionAlgorithmPoolSize(...)
		return lib.btDefaultCollisionConstructionInfo_getDefaultMaxCollisionAlgorithmPoolSize(self, ...)
	end
	function META:GetUseEpaPenetrationAlgorithm(...)
		return lib.btDefaultCollisionConstructionInfo_getUseEpaPenetrationAlgorithm(self, ...)
	end
	function META:GetPersistentManifoldPool(...)
		return lib.btDefaultCollisionConstructionInfo_getPersistentManifoldPool(self, ...)
	end
	function META:SetDefaultMaxCollisionAlgorithmPoolSize(...)
		return lib.btDefaultCollisionConstructionInfo_setDefaultMaxCollisionAlgorithmPoolSize(self, ...)
	end
	ffi.metatype('btDefaultCollisionConstructionInfo', META)
	function bullet.CreateDefaultCollisionConstructionInfo(...)
		return lib.btDefaultCollisionConstructionInfo_new(...)
	end
end
do -- DefaultSoftBodySolver
	local META = {}
	META.__index = META
	function META:CopySoftBodyToVertexBuffer(...)
		return lib.btDefaultSoftBodySolver_copySoftBodyToVertexBuffer(self, ...)
	end
	ffi.metatype('btDefaultSoftBodySolver', META)
	function bullet.CreateDefaultSoftBodySolver(...)
		return lib.btDefaultSoftBodySolver_new(...)
	end
end
do -- RigidBody
	local META = {}
	META.__index = META
	function META:SaveKinematicState(...)
		return lib.btRigidBody_saveKinematicState(self, ...)
	end
	function META:GetLinearVelocity(...)
		return lib.btRigidBody_getLinearVelocity(self, ...)
	end
	function META:SetContactSolverType(...)
		return lib.btRigidBody_setContactSolverType(self, ...)
	end
	function META:GetVelocityInLocalPoint(...)
		return lib.btRigidBody_getVelocityInLocalPoint(self, ...)
	end
	function META:ComputeGyroscopicForceExplicit(...)
		return lib.btRigidBody_computeGyroscopicForceExplicit(self, ...)
	end
	function META:GetCenterOfMassTransform(...)
		return lib.btRigidBody_getCenterOfMassTransform(self, ...)
	end
	function META:SetCenterOfMassTransform(...)
		return lib.btRigidBody_setCenterOfMassTransform(self, ...)
	end
	function META:GetLinearFactor(...)
		return lib.btRigidBody_getLinearFactor(self, ...)
	end
	function META:RemoveConstraintRef(...)
		return lib.btRigidBody_removeConstraintRef(self, ...)
	end
	function META:GetAabb(...)
		return lib.btRigidBody_getAabb(self, ...)
	end
	function META:GetAngularVelocity(...)
		return lib.btRigidBody_getAngularVelocity(self, ...)
	end
	function META:IsInWorld(...)
		return lib.btRigidBody_isInWorld(self, ...)
	end
	function META:SetFlags(...)
		return lib.btRigidBody_setFlags(self, ...)
	end
	function META:ProceedToTransform(...)
		return lib.btRigidBody_proceedToTransform(self, ...)
	end
	function META:GetBroadphaseProxy(...)
		return lib.btRigidBody_getBroadphaseProxy(self, ...)
	end
	function META:ApplyCentralForce(...)
		return lib.btRigidBody_applyCentralForce(self, ...)
	end
	function META:ApplyImpulse(...)
		return lib.btRigidBody_applyImpulse(self, ...)
	end
	function META:UpdateInertiaTensor(...)
		return lib.btRigidBody_updateInertiaTensor(self, ...)
	end
	function META:GetConstraintRef(...)
		return lib.btRigidBody_getConstraintRef(self, ...)
	end
	function META:SetAngularFactor2(...)
		return lib.btRigidBody_setAngularFactor2(self, ...)
	end
	function META:GetFlags(...)
		return lib.btRigidBody_getFlags(self, ...)
	end
	function META:ApplyTorque(...)
		return lib.btRigidBody_applyTorque(self, ...)
	end
	function META:Upcast(...)
		return lib.btRigidBody_upcast(self, ...)
	end
	function META:GetFrictionSolverType(...)
		return lib.btRigidBody_getFrictionSolverType(self, ...)
	end
	function META:GetGravity(...)
		return lib.btRigidBody_getGravity(self, ...)
	end
	function META:ApplyDamping(...)
		return lib.btRigidBody_applyDamping(self, ...)
	end
	function META:GetAngularDamping(...)
		return lib.btRigidBody_getAngularDamping(self, ...)
	end
	function META:ApplyGravity(...)
		return lib.btRigidBody_applyGravity(self, ...)
	end
	function META:SetMassProps(...)
		return lib.btRigidBody_setMassProps(self, ...)
	end
	function META:SetMotionState(...)
		return lib.btRigidBody_setMotionState(self, ...)
	end
	function META:SetLinearFactor(...)
		return lib.btRigidBody_setLinearFactor(self, ...)
	end
	function META:GetTotalForce(...)
		return lib.btRigidBody_getTotalForce(self, ...)
	end
	function META:SetNewBroadphaseProxy(...)
		return lib.btRigidBody_setNewBroadphaseProxy(self, ...)
	end
	function META:GetInvInertiaTensorWorld(...)
		return lib.btRigidBody_getInvInertiaTensorWorld(self, ...)
	end
	function META:IntegrateVelocities(...)
		return lib.btRigidBody_integrateVelocities(self, ...)
	end
	function META:ApplyCentralImpulse(...)
		return lib.btRigidBody_applyCentralImpulse(self, ...)
	end
	function META:SetDamping(...)
		return lib.btRigidBody_setDamping(self, ...)
	end
	function META:WantsSleeping(...)
		return lib.btRigidBody_wantsSleeping(self, ...)
	end
	function META:UpdateDeactivation(...)
		return lib.btRigidBody_updateDeactivation(self, ...)
	end
	function META:SetFrictionSolverType(...)
		return lib.btRigidBody_setFrictionSolverType(self, ...)
	end
	function META:GetInvMass(...)
		return lib.btRigidBody_getInvMass(self, ...)
	end
	function META:ClearForces(...)
		return lib.btRigidBody_clearForces(self, ...)
	end
	function META:ComputeAngularImpulseDenominator(...)
		return lib.btRigidBody_computeAngularImpulseDenominator(self, ...)
	end
	function META:GetLinearSleepingThreshold(...)
		return lib.btRigidBody_getLinearSleepingThreshold(self, ...)
	end
	function META:ComputeImpulseDenominator(...)
		return lib.btRigidBody_computeImpulseDenominator(self, ...)
	end
	function META:GetAngularFactor(...)
		return lib.btRigidBody_getAngularFactor(self, ...)
	end
	function META:GetCenterOfMassPosition(...)
		return lib.btRigidBody_getCenterOfMassPosition(self, ...)
	end
	function META:GetOrientation(...)
		return lib.btRigidBody_getOrientation(self, ...)
	end
	function META:GetAngularSleepingThreshold(...)
		return lib.btRigidBody_getAngularSleepingThreshold(self, ...)
	end
	function META:AddConstraintRef(...)
		return lib.btRigidBody_addConstraintRef(self, ...)
	end
	function META:SetGravity(...)
		return lib.btRigidBody_setGravity(self, ...)
	end
	function META:ApplyTorqueImpulse(...)
		return lib.btRigidBody_applyTorqueImpulse(self, ...)
	end
	function META:GetNumConstraintRefs(...)
		return lib.btRigidBody_getNumConstraintRefs(self, ...)
	end
	function META:GetInvInertiaDiagLocal(...)
		return lib.btRigidBody_getInvInertiaDiagLocal(self, ...)
	end
	function META:ApplyForce(...)
		return lib.btRigidBody_applyForce(self, ...)
	end
	function META:Translate(...)
		return lib.btRigidBody_translate(self, ...)
	end
	function META:GetLinearDamping(...)
		return lib.btRigidBody_getLinearDamping(self, ...)
	end
	function META:GetTotalTorque(...)
		return lib.btRigidBody_getTotalTorque(self, ...)
	end
	function META:PredictIntegratedTransform(...)
		return lib.btRigidBody_predictIntegratedTransform(self, ...)
	end
	function META:GetContactSolverType(...)
		return lib.btRigidBody_getContactSolverType(self, ...)
	end
	function META:GetLocalInertia(...)
		return lib.btRigidBody_getLocalInertia(self, ...)
	end
	function META:SetAngularVelocity(...)
		return lib.btRigidBody_setAngularVelocity(self, ...)
	end
	function META:SetInvInertiaDiagLocal(...)
		return lib.btRigidBody_setInvInertiaDiagLocal(self, ...)
	end
	function META:SetLinearVelocity(...)
		return lib.btRigidBody_setLinearVelocity(self, ...)
	end
	function META:GetMotionState(...)
		return lib.btRigidBody_getMotionState(self, ...)
	end
	function META:SetAngularFactor(...)
		return lib.btRigidBody_setAngularFactor(self, ...)
	end
	function META:SetSleepingThresholds(...)
		return lib.btRigidBody_setSleepingThresholds(self, ...)
	end
	ffi.metatype('btRigidBody', META)
	function bullet.CreateRigidBody2(...)
		return lib.btRigidBody_new2(...)
	end
	function bullet.CreateRigidBody(...)
		return lib.btRigidBody_new(...)
	end
	function bullet.CreateRigidBody3(...)
		return lib.btRigidBody_new3(...)
	end
end
do -- Box2dBox2dCollisionAlgorithm
	local META = {}
	META.__index = META
	ffi.metatype('btBox2dBox2dCollisionAlgorithm', META)
	function bullet.CreateBox2dBox2dCollisionAlgorithm2(...)
		return lib.btBox2dBox2dCollisionAlgorithm_new2(...)
	end
end
do -- GIM_BVH_TREE_NODE
	local META = {}
	META.__index = META
	ffi.metatype('GIM_BVH_TREE_NODE', META)
	function bullet.CreateGIM_BVH_TREE_NODE(...)
		return lib.GIM_BVH_TREE_NODE_new(...)
	end
end
do -- EmptyAlgorithm_CreateFunc
	local META = {}
	META.__index = META
	ffi.metatype('btEmptyAlgorithm_CreateFunc', META)
	function bullet.CreateEmptyAlgorithm_CreateFunc(...)
		return lib.btEmptyAlgorithm_CreateFunc_new(...)
	end
end
do -- BulletXmlWorldImporter
	local META = {}
	META.__index = META
	function META:LoadFile(...)
		return lib.btBulletXmlWorldImporter_loadFile(self, ...)
	end
	ffi.metatype('btBulletXmlWorldImporter', META)
	function bullet.CreateBulletXmlWorldImporter(...)
		return lib.btBulletXmlWorldImporter_new(...)
	end
end
do -- CompoundCompoundCollisionAlgorithm
	local META = {}
	META.__index = META
	ffi.metatype('btCompoundCompoundCollisionAlgorithm', META)
	function bullet.CreateCompoundCompoundCollisionAlgorithm(...)
		return lib.btCompoundCompoundCollisionAlgorithm_new(...)
	end
end
do -- SoftBodyTriangleCallback
	local META = {}
	META.__index = META
	function META:GetTriangleCount(...)
		return lib.btSoftBodyTriangleCallback_getTriangleCount(self, ...)
	end
	function META:ClearCache(...)
		return lib.btSoftBodyTriangleCallback_clearCache(self, ...)
	end
	function META:SetTimeStepAndCounters(...)
		return lib.btSoftBodyTriangleCallback_setTimeStepAndCounters(self, ...)
	end
	function META:SetTriangleCount(...)
		return lib.btSoftBodyTriangleCallback_setTriangleCount(self, ...)
	end
	function META:GetAabbMax(...)
		return lib.btSoftBodyTriangleCallback_getAabbMax(self, ...)
	end
	function META:GetAabbMin(...)
		return lib.btSoftBodyTriangleCallback_getAabbMin(self, ...)
	end
	ffi.metatype('btSoftBodyTriangleCallback', META)
	function bullet.CreateSoftBodyTriangleCallback(...)
		return lib.btSoftBodyTriangleCallback_new(...)
	end
end
do -- GImpactCompoundShape_CompoundPrimitiveManager
	local META = {}
	META.__index = META
	function META:GetCompoundShape(...)
		return lib.btGImpactCompoundShape_CompoundPrimitiveManager_getCompoundShape(self, ...)
	end
	function META:SetCompoundShape(...)
		return lib.btGImpactCompoundShape_CompoundPrimitiveManager_setCompoundShape(self, ...)
	end
	ffi.metatype('btGImpactCompoundShape_CompoundPrimitiveManager', META)
	function bullet.CreateGImpactCompoundShape_CompoundPrimitiveManager3(...)
		return lib.btGImpactCompoundShape_CompoundPrimitiveManager_new3(...)
	end
	function bullet.CreateGImpactCompoundShape_CompoundPrimitiveManager2(...)
		return lib.btGImpactCompoundShape_CompoundPrimitiveManager_new2(...)
	end
	function bullet.CreateGImpactCompoundShape_CompoundPrimitiveManager(...)
		return lib.btGImpactCompoundShape_CompoundPrimitiveManager_new(...)
	end
end
do -- GIM_BVH_DATA_ARRAY
	local META = {}
	META.__index = META
	ffi.metatype('GIM_BVH_DATA_ARRAY', META)
	function bullet.CreateGIM_BVH_DATA_ARRAY(...)
		return lib.GIM_BVH_DATA_ARRAY_new(...)
	end
end
do -- ConeShapeX
	local META = {}
	META.__index = META
	ffi.metatype('btConeShapeX', META)
	function bullet.CreateConeShapeX(...)
		return lib.btConeShapeX_new(...)
	end
end
do -- HingeConstraint
	local META = {}
	META.__index = META
	function META:GetInfo2NonVirtual(...)
		return lib.btHingeConstraint_getInfo2NonVirtual(self, ...)
	end
	function META:SetMotorTarget2(...)
		return lib.btHingeConstraint_setMotorTarget2(self, ...)
	end
	function META:SetLimit2(...)
		return lib.btHingeConstraint_setLimit2(self, ...)
	end
	function META:GetFrameOffsetA(...)
		return lib.btHingeConstraint_getFrameOffsetA(self, ...)
	end
	function META:GetInfo1NonVirtual(...)
		return lib.btHingeConstraint_getInfo1NonVirtual(self, ...)
	end
	function META:GetMotorTargetVelosity(...)
		return lib.btHingeConstraint_getMotorTargetVelosity(self, ...)
	end
	function META:GetAngularOnly(...)
		return lib.btHingeConstraint_getAngularOnly(self, ...)
	end
	function META:SetFrames(...)
		return lib.btHingeConstraint_setFrames(self, ...)
	end
	function META:EnableMotor(...)
		return lib.btHingeConstraint_enableMotor(self, ...)
	end
	function META:GetSolveLimit(...)
		return lib.btHingeConstraint_getSolveLimit(self, ...)
	end
	function META:SetAxis(...)
		return lib.btHingeConstraint_setAxis(self, ...)
	end
	function META:GetLowerLimit(...)
		return lib.btHingeConstraint_getLowerLimit(self, ...)
	end
	function META:GetBFrame(...)
		return lib.btHingeConstraint_getBFrame(self, ...)
	end
	function META:GetAFrame(...)
		return lib.btHingeConstraint_getAFrame(self, ...)
	end
	function META:GetUpperLimit(...)
		return lib.btHingeConstraint_getUpperLimit(self, ...)
	end
	function META:HasLimit(...)
		return lib.btHingeConstraint_hasLimit(self, ...)
	end
	function META:SetLimit3(...)
		return lib.btHingeConstraint_setLimit3(self, ...)
	end
	function META:UpdateRHS(...)
		return lib.btHingeConstraint_updateRHS(self, ...)
	end
	function META:EnableAngularMotor(...)
		return lib.btHingeConstraint_enableAngularMotor(self, ...)
	end
	function META:GetLimitSign(...)
		return lib.btHingeConstraint_getLimitSign(self, ...)
	end
	function META:GetHingeAngle(...)
		return lib.btHingeConstraint_getHingeAngle(self, ...)
	end
	function META:GetHingeAngle2(...)
		return lib.btHingeConstraint_getHingeAngle2(self, ...)
	end
	function META:TestLimit(...)
		return lib.btHingeConstraint_testLimit(self, ...)
	end
	function META:SetMaxMotorImpulse(...)
		return lib.btHingeConstraint_setMaxMotorImpulse(self, ...)
	end
	function META:SetAngularOnly(...)
		return lib.btHingeConstraint_setAngularOnly(self, ...)
	end
	function META:SetUseFrameOffset(...)
		return lib.btHingeConstraint_setUseFrameOffset(self, ...)
	end
	function META:SetLimit4(...)
		return lib.btHingeConstraint_setLimit4(self, ...)
	end
	function META:SetLimit(...)
		return lib.btHingeConstraint_setLimit(self, ...)
	end
	function META:GetMaxMotorImpulse(...)
		return lib.btHingeConstraint_getMaxMotorImpulse(self, ...)
	end
	function META:GetInfo2Internal(...)
		return lib.btHingeConstraint_getInfo2Internal(self, ...)
	end
	function META:GetEnableAngularMotor(...)
		return lib.btHingeConstraint_getEnableAngularMotor(self, ...)
	end
	function META:GetUseFrameOffset(...)
		return lib.btHingeConstraint_getUseFrameOffset(self, ...)
	end
	function META:GetFrameOffsetB(...)
		return lib.btHingeConstraint_getFrameOffsetB(self, ...)
	end
	function META:GetInfo2InternalUsingFrameOffset(...)
		return lib.btHingeConstraint_getInfo2InternalUsingFrameOffset(self, ...)
	end
	function META:SetMotorTarget(...)
		return lib.btHingeConstraint_setMotorTarget(self, ...)
	end
	ffi.metatype('btHingeConstraint', META)
	function bullet.CreateHingeConstraint8(...)
		return lib.btHingeConstraint_new8(...)
	end
	function bullet.CreateHingeConstraint6(...)
		return lib.btHingeConstraint_new6(...)
	end
	function bullet.CreateHingeConstraint2(...)
		return lib.btHingeConstraint_new2(...)
	end
	function bullet.CreateHingeConstraint7(...)
		return lib.btHingeConstraint_new7(...)
	end
	function bullet.CreateHingeConstraint3(...)
		return lib.btHingeConstraint_new3(...)
	end
	function bullet.CreateHingeConstraint(...)
		return lib.btHingeConstraint_new(...)
	end
	function bullet.CreateHingeConstraint4(...)
		return lib.btHingeConstraint_new4(...)
	end
	function bullet.CreateHingeConstraint5(...)
		return lib.btHingeConstraint_new5(...)
	end
end
do -- MLCPSolver
	local META = {}
	META.__index = META
	function META:SetMLCPSolver(...)
		return lib.btMLCPSolver_setMLCPSolver(self, ...)
	end
	function META:SetCfm(...)
		return lib.btMLCPSolver_setCfm(self, ...)
	end
	function META:GetNumFallbacks(...)
		return lib.btMLCPSolver_getNumFallbacks(self, ...)
	end
	function META:GetCfm(...)
		return lib.btMLCPSolver_getCfm(self, ...)
	end
	function META:SetNumFallbacks(...)
		return lib.btMLCPSolver_setNumFallbacks(self, ...)
	end
	ffi.metatype('btMLCPSolver', META)
	function bullet.CreateMLCPSolver(...)
		return lib.btMLCPSolver_new(...)
	end
end
do -- QuantizedBvhTree
	local META = {}
	META.__index = META
	function META:GetNodeBound(...)
		return lib.btQuantizedBvhTree_getNodeBound(self, ...)
	end
	function META:Delete(...)
		return lib.btQuantizedBvhTree_delete(self, ...)
	end
	function META:GetRightNode(...)
		return lib.btQuantizedBvhTree_getRightNode(self, ...)
	end
	function META:GetEscapeNodeIndex(...)
		return lib.btQuantizedBvhTree_getEscapeNodeIndex(self, ...)
	end
	function META:GetLeftNode(...)
		return lib.btQuantizedBvhTree_getLeftNode(self, ...)
	end
	function META:TestQuantizedBoxOverlapp(...)
		return lib.btQuantizedBvhTree_testQuantizedBoxOverlapp(self, ...)
	end
	function META:GetNodeData(...)
		return lib.btQuantizedBvhTree_getNodeData(self, ...)
	end
	function META:IsLeafNode(...)
		return lib.btQuantizedBvhTree_isLeafNode(self, ...)
	end
	function META:SetNodeBound(...)
		return lib.btQuantizedBvhTree_setNodeBound(self, ...)
	end
	function META:GetNodeCount(...)
		return lib.btQuantizedBvhTree_getNodeCount(self, ...)
	end
	function META:QuantizePoint(...)
		return lib.btQuantizedBvhTree_quantizePoint(self, ...)
	end
	function META:ClearNodes(...)
		return lib.btQuantizedBvhTree_clearNodes(self, ...)
	end
	ffi.metatype('btQuantizedBvhTree', META)
	function bullet.CreateQuantizedBvhTree(...)
		return lib.btQuantizedBvhTree_new(...)
	end
end
do -- ContactSolverInfoData
	local META = {}
	META.__index = META
	function META:GetSolverMode(...)
		return lib.btContactSolverInfoData_getSolverMode(self, ...)
	end
	function META:SetGlobalCfm(...)
		return lib.btContactSolverInfoData_setGlobalCfm(self, ...)
	end
	function META:SetLinearSlop(...)
		return lib.btContactSolverInfoData_setLinearSlop(self, ...)
	end
	function META:GetNumIterations(...)
		return lib.btContactSolverInfoData_getNumIterations(self, ...)
	end
	function META:GetGlobalCfm(...)
		return lib.btContactSolverInfoData_getGlobalCfm(self, ...)
	end
	function META:SetSplitImpulseTurnErp(...)
		return lib.btContactSolverInfoData_setSplitImpulseTurnErp(self, ...)
	end
	function META:SetMaxGyroscopicForce(...)
		return lib.btContactSolverInfoData_setMaxGyroscopicForce(self, ...)
	end
	function META:SetSolverMode(...)
		return lib.btContactSolverInfoData_setSolverMode(self, ...)
	end
	function META:SetRestitution(...)
		return lib.btContactSolverInfoData_setRestitution(self, ...)
	end
	function META:GetLinearSlop(...)
		return lib.btContactSolverInfoData_getLinearSlop(self, ...)
	end
	function META:GetSplitImpulseTurnErp(...)
		return lib.btContactSolverInfoData_getSplitImpulseTurnErp(self, ...)
	end
	function META:GetDamping(...)
		return lib.btContactSolverInfoData_getDamping(self, ...)
	end
	function META:GetFriction(...)
		return lib.btContactSolverInfoData_getFriction(self, ...)
	end
	function META:SetWarmstartingFactor(...)
		return lib.btContactSolverInfoData_setWarmstartingFactor(self, ...)
	end
	function META:GetTimeStep(...)
		return lib.btContactSolverInfoData_getTimeStep(self, ...)
	end
	function META:GetMaxGyroscopicForce(...)
		return lib.btContactSolverInfoData_getMaxGyroscopicForce(self, ...)
	end
	function META:GetTau(...)
		return lib.btContactSolverInfoData_getTau(self, ...)
	end
	function META:GetErp(...)
		return lib.btContactSolverInfoData_getErp(self, ...)
	end
	function META:GetSplitImpulse(...)
		return lib.btContactSolverInfoData_getSplitImpulse(self, ...)
	end
	function META:SetNumIterations(...)
		return lib.btContactSolverInfoData_setNumIterations(self, ...)
	end
	function META:GetWarmstartingFactor(...)
		return lib.btContactSolverInfoData_getWarmstartingFactor(self, ...)
	end
	function META:Delete(...)
		return lib.btContactSolverInfoData_delete(self, ...)
	end
	function META:SetTimeStep(...)
		return lib.btContactSolverInfoData_setTimeStep(self, ...)
	end
	function META:SetTau(...)
		return lib.btContactSolverInfoData_setTau(self, ...)
	end
	function META:GetSplitImpulsePenetrationThreshold(...)
		return lib.btContactSolverInfoData_getSplitImpulsePenetrationThreshold(self, ...)
	end
	function META:SetSor(...)
		return lib.btContactSolverInfoData_setSor(self, ...)
	end
	function META:SetSplitImpulse(...)
		return lib.btContactSolverInfoData_setSplitImpulse(self, ...)
	end
	function META:SetMinimumSolverBatchSize(...)
		return lib.btContactSolverInfoData_setMinimumSolverBatchSize(self, ...)
	end
	function META:SetSplitImpulsePenetrationThreshold(...)
		return lib.btContactSolverInfoData_setSplitImpulsePenetrationThreshold(self, ...)
	end
	function META:SetFriction(...)
		return lib.btContactSolverInfoData_setFriction(self, ...)
	end
	function META:SetSingleAxisRollingFrictionThreshold(...)
		return lib.btContactSolverInfoData_setSingleAxisRollingFrictionThreshold(self, ...)
	end
	function META:SetErp2(...)
		return lib.btContactSolverInfoData_setErp2(self, ...)
	end
	function META:GetErp2(...)
		return lib.btContactSolverInfoData_getErp2(self, ...)
	end
	function META:GetSingleAxisRollingFrictionThreshold(...)
		return lib.btContactSolverInfoData_getSingleAxisRollingFrictionThreshold(self, ...)
	end
	function META:GetMinimumSolverBatchSize(...)
		return lib.btContactSolverInfoData_getMinimumSolverBatchSize(self, ...)
	end
	function META:SetMaxErrorReduction(...)
		return lib.btContactSolverInfoData_setMaxErrorReduction(self, ...)
	end
	function META:GetRestitution(...)
		return lib.btContactSolverInfoData_getRestitution(self, ...)
	end
	function META:GetSor(...)
		return lib.btContactSolverInfoData_getSor(self, ...)
	end
	function META:GetRestingContactRestitutionThreshold(...)
		return lib.btContactSolverInfoData_getRestingContactRestitutionThreshold(self, ...)
	end
	function META:GetMaxErrorReduction(...)
		return lib.btContactSolverInfoData_getMaxErrorReduction(self, ...)
	end
	function META:SetErp(...)
		return lib.btContactSolverInfoData_setErp(self, ...)
	end
	function META:SetDamping(...)
		return lib.btContactSolverInfoData_setDamping(self, ...)
	end
	function META:SetRestingContactRestitutionThreshold(...)
		return lib.btContactSolverInfoData_setRestingContactRestitutionThreshold(self, ...)
	end
	ffi.metatype('btContactSolverInfoData', META)
	function bullet.CreateContactSolverInfoData(...)
		return lib.btContactSolverInfoData_new(...)
	end
end
do -- Point2PointConstraint
	local META = {}
	META.__index = META
	function META:GetInfo2NonVirtual(...)
		return lib.btPoint2PointConstraint_getInfo2NonVirtual(self, ...)
	end
	function META:GetUseSolveConstraintObsolete(...)
		return lib.btPoint2PointConstraint_getUseSolveConstraintObsolete(self, ...)
	end
	function META:GetPivotInA(...)
		return lib.btPoint2PointConstraint_getPivotInA(self, ...)
	end
	function META:GetInfo1NonVirtual(...)
		return lib.btPoint2PointConstraint_getInfo1NonVirtual(self, ...)
	end
	function META:UpdateRHS(...)
		return lib.btPoint2PointConstraint_updateRHS(self, ...)
	end
	function META:GetPivotInB(...)
		return lib.btPoint2PointConstraint_getPivotInB(self, ...)
	end
	function META:SetPivotA(...)
		return lib.btPoint2PointConstraint_setPivotA(self, ...)
	end
	function META:SetUseSolveConstraintObsolete(...)
		return lib.btPoint2PointConstraint_setUseSolveConstraintObsolete(self, ...)
	end
	function META:SetPivotB(...)
		return lib.btPoint2PointConstraint_setPivotB(self, ...)
	end
	function META:GetSetting(...)
		return lib.btPoint2PointConstraint_getSetting(self, ...)
	end
	ffi.metatype('btPoint2PointConstraint', META)
	function bullet.CreatePoint2PointConstraint2(...)
		return lib.btPoint2PointConstraint_new2(...)
	end
end
do -- Face
	local META = {}
	META.__index = META
	function META:GetIndices(...)
		return lib.btFace_getIndices(self, ...)
	end
	function META:GetPlane(...)
		return lib.btFace_getPlane(self, ...)
	end
	function META:Delete(...)
		return lib.btFace_delete(self, ...)
	end
	ffi.metatype('btFace', META)
	function bullet.CreateFace(...)
		return lib.btFace_new(...)
	end
end
do -- ConstraintRow
	local META = {}
	META.__index = META
	function META:SetJacDiagInv(...)
		return lib.btConstraintRow_setJacDiagInv(self, ...)
	end
	function META:SetNormal(...)
		return lib.btConstraintRow_setNormal(self, ...)
	end
	function META:GetUpperLimit(...)
		return lib.btConstraintRow_getUpperLimit(self, ...)
	end
	function META:Delete(...)
		return lib.btConstraintRow_delete(self, ...)
	end
	function META:GetAccumImpulse(...)
		return lib.btConstraintRow_getAccumImpulse(self, ...)
	end
	function META:GetNormal(...)
		return lib.btConstraintRow_getNormal(self, ...)
	end
	function META:GetLowerLimit(...)
		return lib.btConstraintRow_getLowerLimit(self, ...)
	end
	function META:SetUpperLimit(...)
		return lib.btConstraintRow_setUpperLimit(self, ...)
	end
	function META:SetRhs(...)
		return lib.btConstraintRow_setRhs(self, ...)
	end
	function META:GetJacDiagInv(...)
		return lib.btConstraintRow_getJacDiagInv(self, ...)
	end
	function META:SetLowerLimit(...)
		return lib.btConstraintRow_setLowerLimit(self, ...)
	end
	function META:GetRhs(...)
		return lib.btConstraintRow_getRhs(self, ...)
	end
	function META:SetAccumImpulse(...)
		return lib.btConstraintRow_setAccumImpulse(self, ...)
	end
	ffi.metatype('btConstraintRow', META)
	function bullet.CreateConstraintRow(...)
		return lib.btConstraintRow_new(...)
	end
end
do -- SoftBody
	local META = {}
	META.__index = META
	function META:SetBUpdateRtCst(...)
		return lib.btSoftBody_setBUpdateRtCst(self, ...)
	end
	function META:GetVolume(...)
		return lib.btSoftBody_getVolume(self, ...)
	end
	function META:AppendFace5(...)
		return lib.btSoftBody_appendFace5(self, ...)
	end
	function META:AppendTetra(...)
		return lib.btSoftBody_appendTetra(self, ...)
	end
	function META:GetTetraVertexNormalData2(...)
		return lib.btSoftBody_getTetraVertexNormalData2(self, ...)
	end
	function META:AppendFace3(...)
		return lib.btSoftBody_appendFace3(self, ...)
	end
	function META:GenerateBendingConstraints2(...)
		return lib.btSoftBody_generateBendingConstraints2(self, ...)
	end
	function META:GetAnchors(...)
		return lib.btSoftBody_getAnchors(self, ...)
	end
	function META:GetNodes(...)
		return lib.btSoftBody_getNodes(self, ...)
	end
	function META:CheckLink(...)
		return lib.btSoftBody_checkLink(self, ...)
	end
	function META:SetInitialWorldTransform(...)
		return lib.btSoftBody_setInitialWorldTransform(self, ...)
	end
	function META:AppendFace2(...)
		return lib.btSoftBody_appendFace2(self, ...)
	end
	function META:GetNotes(...)
		return lib.btSoftBody_getNotes(self, ...)
	end
	function META:ClusterDCImpulse(...)
		return lib.btSoftBody_clusterDCImpulse(self, ...)
	end
	function META:Rotate(...)
		return lib.btSoftBody_rotate(self, ...)
	end
	function META:AppendLink7(...)
		return lib.btSoftBody_appendLink7(self, ...)
	end
	function META:GetLinks(...)
		return lib.btSoftBody_getLinks(self, ...)
	end
	function META:AppendAnchor2(...)
		return lib.btSoftBody_appendAnchor2(self, ...)
	end
	function META:ReleaseClusters(...)
		return lib.btSoftBody_releaseClusters(self, ...)
	end
	function META:SetNdbvt(...)
		return lib.btSoftBody_setNdbvt(self, ...)
	end
	function META:AppendLinearJoint(...)
		return lib.btSoftBody_appendLinearJoint(self, ...)
	end
	function META:AppendAnchor5(...)
		return lib.btSoftBody_appendAnchor5(self, ...)
	end
	function META:RayTest(...)
		return lib.btSoftBody_rayTest(self, ...)
	end
	function META:InitDefaults(...)
		return lib.btSoftBody_initDefaults(self, ...)
	end
	function META:AppendNote7(...)
		return lib.btSoftBody_appendNote7(self, ...)
	end
	function META:Upcast(...)
		return lib.btSoftBody_upcast(self, ...)
	end
	function META:AppendLinearJoint4(...)
		return lib.btSoftBody_appendLinearJoint4(self, ...)
	end
	function META:PointersToIndices(...)
		return lib.btSoftBody_pointersToIndices(self, ...)
	end
	function META:GetTetras(...)
		return lib.btSoftBody_getTetras(self, ...)
	end
	function META:AppendLink6(...)
		return lib.btSoftBody_appendLink6(self, ...)
	end
	function META:ClusterImpulse(...)
		return lib.btSoftBody_clusterImpulse(self, ...)
	end
	function META:ClusterCom(...)
		return lib.btSoftBody_clusterCom(self, ...)
	end
	function META:GetFaceVertexNormalData2(...)
		return lib.btSoftBody_getFaceVertexNormalData2(self, ...)
	end
	function META:GetBounds(...)
		return lib.btSoftBody_getBounds(self, ...)
	end
	function META:GetSolver2(...)
		return lib.btSoftBody_getSolver2(self, ...)
	end
	function META:AppendFace4(...)
		return lib.btSoftBody_appendFace4(self, ...)
	end
	function META:AddVelocity(...)
		return lib.btSoftBody_addVelocity(self, ...)
	end
	function META:GetSst(...)
		return lib.btSoftBody_getSst(self, ...)
	end
	function META:ResetLinkRestLengths(...)
		return lib.btSoftBody_resetLinkRestLengths(self, ...)
	end
	function META:AppendAngularJoint4(...)
		return lib.btSoftBody_appendAngularJoint4(self, ...)
	end
	function META:SolveClusters(...)
		return lib.btSoftBody_solveClusters(self, ...)
	end
	function META:AppendAnchor3(...)
		return lib.btSoftBody_appendAnchor3(self, ...)
	end
	function META:DefaultCollisionHandler2(...)
		return lib.btSoftBody_defaultCollisionHandler2(self, ...)
	end
	function META:AppendTetra3(...)
		return lib.btSoftBody_appendTetra3(self, ...)
	end
	function META:Refine(...)
		return lib.btSoftBody_refine(self, ...)
	end
	function META:AppendLink(...)
		return lib.btSoftBody_appendLink(self, ...)
	end
	function META:SolveCommonConstraints(...)
		return lib.btSoftBody_solveCommonConstraints(self, ...)
	end
	function META:SolveClusters2(...)
		return lib.btSoftBody_solveClusters2(self, ...)
	end
	function META:GetClusters(...)
		return lib.btSoftBody_getClusters(self, ...)
	end
	function META:GetSolver(...)
		return lib.btSoftBody_getSolver(self, ...)
	end
	function META:AppendTetra2(...)
		return lib.btSoftBody_appendTetra2(self, ...)
	end
	function META:AddForce2(...)
		return lib.btSoftBody_addForce2(self, ...)
	end
	function META:AddVelocity2(...)
		return lib.btSoftBody_addVelocity2(self, ...)
	end
	function META:AppendMaterial(...)
		return lib.btSoftBody_appendMaterial(self, ...)
	end
	function META:ClusterAImpulse(...)
		return lib.btSoftBody_clusterAImpulse(self, ...)
	end
	function META:UpdateClusters(...)
		return lib.btSoftBody_updateClusters(self, ...)
	end
	function META:GetFaceVertexData(...)
		return lib.btSoftBody_getFaceVertexData(self, ...)
	end
	function META:GetTetraVertexNormalData(...)
		return lib.btSoftBody_getTetraVertexNormalData(self, ...)
	end
	function META:Translate(...)
		return lib.btSoftBody_translate(self, ...)
	end
	function META:GetCdbvt(...)
		return lib.btSoftBody_getCdbvt(self, ...)
	end
	function META:AppendLink9(...)
		return lib.btSoftBody_appendLink9(self, ...)
	end
	function META:GetCfg(...)
		return lib.btSoftBody_getCfg(self, ...)
	end
	function META:InitializeClusters(...)
		return lib.btSoftBody_initializeClusters(self, ...)
	end
	function META:SetVolumeMass(...)
		return lib.btSoftBody_setVolumeMass(self, ...)
	end
	function META:AppendLinearJoint3(...)
		return lib.btSoftBody_appendLinearJoint3(self, ...)
	end
	function META:GetMaterials(...)
		return lib.btSoftBody_getMaterials(self, ...)
	end
	function META:GetTag(...)
		return lib.btSoftBody_getTag(self, ...)
	end
	function META:SetSolver(...)
		return lib.btSoftBody_setSolver(self, ...)
	end
	function META:UpdateConstants(...)
		return lib.btSoftBody_updateConstants(self, ...)
	end
	function META:ClusterCount(...)
		return lib.btSoftBody_clusterCount(self, ...)
	end
	function META:AppendLink5(...)
		return lib.btSoftBody_appendLink5(self, ...)
	end
	function META:CheckFace(...)
		return lib.btSoftBody_checkFace(self, ...)
	end
	function META:AppendAngularJoint3(...)
		return lib.btSoftBody_appendAngularJoint3(self, ...)
	end
	function META:GetAabb(...)
		return lib.btSoftBody_getAabb(self, ...)
	end
	function META:GenerateClusters(...)
		return lib.btSoftBody_generateClusters(self, ...)
	end
	function META:SetSoftBodySolver(...)
		return lib.btSoftBody_setSoftBodySolver(self, ...)
	end
	function META:GetWorldInfo(...)
		return lib.btSoftBody_getWorldInfo(self, ...)
	end
	function META:SetVolumeDensity(...)
		return lib.btSoftBody_setVolumeDensity(self, ...)
	end
	function META:GetPose(...)
		return lib.btSoftBody_getPose(self, ...)
	end
	function META:DefaultCollisionHandler(...)
		return lib.btSoftBody_defaultCollisionHandler(self, ...)
	end
	function META:SetVelocity(...)
		return lib.btSoftBody_setVelocity(self, ...)
	end
	function META:GetClusterConnectivity(...)
		return lib.btSoftBody_getClusterConnectivity(self, ...)
	end
	function META:GetTetraVertexData(...)
		return lib.btSoftBody_getTetraVertexData(self, ...)
	end
	function META:GetMass(...)
		return lib.btSoftBody_getMass(self, ...)
	end
	function META:AddForce(...)
		return lib.btSoftBody_addForce(self, ...)
	end
	function META:GetFaceVertexNormalData(...)
		return lib.btSoftBody_getFaceVertexNormalData(self, ...)
	end
	function META:RandomizeConstraints(...)
		return lib.btSoftBody_randomizeConstraints(self, ...)
	end
	function META:ApplyClusters(...)
		return lib.btSoftBody_applyClusters(self, ...)
	end
	function META:GetLinkVertexNormalData(...)
		return lib.btSoftBody_getLinkVertexNormalData(self, ...)
	end
	function META:GetLinkVertexData(...)
		return lib.btSoftBody_getLinkVertexData(self, ...)
	end
	function META:GetInitialWorldTransform(...)
		return lib.btSoftBody_getInitialWorldTransform(self, ...)
	end
	function META:AppendNote9(...)
		return lib.btSoftBody_appendNote9(self, ...)
	end
	function META:UpdateNormals(...)
		return lib.btSoftBody_updateNormals(self, ...)
	end
	function META:AppendNote5(...)
		return lib.btSoftBody_appendNote5(self, ...)
	end
	function META:UpdateBounds(...)
		return lib.btSoftBody_updateBounds(self, ...)
	end
	function META:UpdateArea2(...)
		return lib.btSoftBody_updateArea2(self, ...)
	end
	function META:UpdateArea(...)
		return lib.btSoftBody_updateArea(self, ...)
	end
	function META:IndicesToPointers(...)
		return lib.btSoftBody_indicesToPointers(self, ...)
	end
	function META:GenerateBendingConstraints(...)
		return lib.btSoftBody_generateBendingConstraints(self, ...)
	end
	function META:Transform(...)
		return lib.btSoftBody_transform(self, ...)
	end
	function META:StaticSolve(...)
		return lib.btSoftBody_staticSolve(self, ...)
	end
	function META:GetSoftBodySolver(...)
		return lib.btSoftBody_getSoftBodySolver(self, ...)
	end
	function META:SetWorldInfo(...)
		return lib.btSoftBody_setWorldInfo(self, ...)
	end
	function META:AppendAngularJoint2(...)
		return lib.btSoftBody_appendAngularJoint2(self, ...)
	end
	function META:AppendLink8(...)
		return lib.btSoftBody_appendLink8(self, ...)
	end
	function META:UpdateLinkConstants(...)
		return lib.btSoftBody_updateLinkConstants(self, ...)
	end
	function META:AppendAnchor4(...)
		return lib.btSoftBody_appendAnchor4(self, ...)
	end
	function META:GetTotalMass(...)
		return lib.btSoftBody_getTotalMass(self, ...)
	end
	function META:ReleaseCluster(...)
		return lib.btSoftBody_releaseCluster(self, ...)
	end
	function META:AddAeroForceToNode(...)
		return lib.btSoftBody_addAeroForceToNode(self, ...)
	end
	function META:GetFdbvt(...)
		return lib.btSoftBody_getFdbvt(self, ...)
	end
	function META:SetTotalDensity(...)
		return lib.btSoftBody_setTotalDensity(self, ...)
	end
	function META:CheckLink2(...)
		return lib.btSoftBody_checkLink2(self, ...)
	end
	function META:AppendNote2(...)
		return lib.btSoftBody_appendNote2(self, ...)
	end
	function META:SetTimeacc(...)
		return lib.btSoftBody_setTimeacc(self, ...)
	end
	function META:ClusterVAImpulse(...)
		return lib.btSoftBody_clusterVAImpulse(self, ...)
	end
	function META:ClusterVelocity(...)
		return lib.btSoftBody_clusterVelocity(self, ...)
	end
	function META:AppendNote8(...)
		return lib.btSoftBody_appendNote8(self, ...)
	end
	function META:SetRestLengthScale(...)
		return lib.btSoftBody_setRestLengthScale(self, ...)
	end
	function META:SetPose(...)
		return lib.btSoftBody_setPose(self, ...)
	end
	function META:EvaluateCom(...)
		return lib.btSoftBody_evaluateCom(self, ...)
	end
	function META:ClusterVImpulse(...)
		return lib.btSoftBody_clusterVImpulse(self, ...)
	end
	function META:SetMass(...)
		return lib.btSoftBody_setMass(self, ...)
	end
	function META:GetScontacts(...)
		return lib.btSoftBody_getScontacts(self, ...)
	end
	function META:Scale(...)
		return lib.btSoftBody_scale(self, ...)
	end
	function META:GetRcontacts(...)
		return lib.btSoftBody_getRcontacts(self, ...)
	end
	function META:AppendFace(...)
		return lib.btSoftBody_appendFace(self, ...)
	end
	function META:ClusterDImpulse(...)
		return lib.btSoftBody_clusterDImpulse(self, ...)
	end
	function META:AppendNote6(...)
		return lib.btSoftBody_appendNote6(self, ...)
	end
	function META:RayTest2(...)
		return lib.btSoftBody_rayTest2(self, ...)
	end
	function META:AppendLink4(...)
		return lib.btSoftBody_appendLink4(self, ...)
	end
	function META:PredictMotion(...)
		return lib.btSoftBody_predictMotion(self, ...)
	end
	function META:SetWindVelocity(...)
		return lib.btSoftBody_setWindVelocity(self, ...)
	end
	function META:AppendLink3(...)
		return lib.btSoftBody_appendLink3(self, ...)
	end
	function META:AppendAngularJoint(...)
		return lib.btSoftBody_appendAngularJoint(self, ...)
	end
	function META:CheckContact(...)
		return lib.btSoftBody_checkContact(self, ...)
	end
	function META:AddAeroForceToFace(...)
		return lib.btSoftBody_addAeroForceToFace(self, ...)
	end
	function META:IndicesToPointers2(...)
		return lib.btSoftBody_indicesToPointers2(self, ...)
	end
	function META:SetTag(...)
		return lib.btSoftBody_setTag(self, ...)
	end
	function META:ApplyForces(...)
		return lib.btSoftBody_applyForces(self, ...)
	end
	function META:GetFaces(...)
		return lib.btSoftBody_getFaces(self, ...)
	end
	function META:IntegrateMotion(...)
		return lib.btSoftBody_integrateMotion(self, ...)
	end
	function META:SetTotalMass2(...)
		return lib.btSoftBody_setTotalMass2(self, ...)
	end
	function META:GetTimeacc(...)
		return lib.btSoftBody_getTimeacc(self, ...)
	end
	function META:PrepareClusters(...)
		return lib.btSoftBody_prepareClusters(self, ...)
	end
	function META:AppendLinearJoint2(...)
		return lib.btSoftBody_appendLinearJoint2(self, ...)
	end
	function META:AppendAnchor(...)
		return lib.btSoftBody_appendAnchor(self, ...)
	end
	function META:AppendNode(...)
		return lib.btSoftBody_appendNode(self, ...)
	end
	function META:GetUserIndexMapping(...)
		return lib.btSoftBody_getUserIndexMapping(self, ...)
	end
	function META:DampClusters(...)
		return lib.btSoftBody_dampClusters(self, ...)
	end
	function META:CutLink(...)
		return lib.btSoftBody_cutLink(self, ...)
	end
	function META:GetBUpdateRtCst(...)
		return lib.btSoftBody_getBUpdateRtCst(self, ...)
	end
	function META:CutLink2(...)
		return lib.btSoftBody_cutLink2(self, ...)
	end
	function META:AppendNote3(...)
		return lib.btSoftBody_appendNote3(self, ...)
	end
	function META:GetNdbvt(...)
		return lib.btSoftBody_getNdbvt(self, ...)
	end
	function META:InitializeFaceTree(...)
		return lib.btSoftBody_initializeFaceTree(self, ...)
	end
	function META:AppendNote4(...)
		return lib.btSoftBody_appendNote4(self, ...)
	end
	function META:AppendAnchor6(...)
		return lib.btSoftBody_appendAnchor6(self, ...)
	end
	function META:GetCollisionDisabledObjects(...)
		return lib.btSoftBody_getCollisionDisabledObjects(self, ...)
	end
	function META:AppendLink2(...)
		return lib.btSoftBody_appendLink2(self, ...)
	end
	function META:UpdatePose(...)
		return lib.btSoftBody_updatePose(self, ...)
	end
	function META:GetJoints(...)
		return lib.btSoftBody_getJoints(self, ...)
	end
	function META:ClusterDAImpulse(...)
		return lib.btSoftBody_clusterDAImpulse(self, ...)
	end
	function META:SolveConstraints(...)
		return lib.btSoftBody_solveConstraints(self, ...)
	end
	function META:GetRestLengthScale(...)
		return lib.btSoftBody_getRestLengthScale(self, ...)
	end
	function META:ClusterCom2(...)
		return lib.btSoftBody_clusterCom2(self, ...)
	end
	function META:CleanupClusters(...)
		return lib.btSoftBody_cleanupClusters(self, ...)
	end
	function META:SetTotalMass(...)
		return lib.btSoftBody_setTotalMass(self, ...)
	end
	function META:GenerateClusters2(...)
		return lib.btSoftBody_generateClusters2(self, ...)
	end
	function META:GetWindVelocity(...)
		return lib.btSoftBody_getWindVelocity(self, ...)
	end
	function META:AppendNote(...)
		return lib.btSoftBody_appendNote(self, ...)
	end
	ffi.metatype('btSoftBody', META)
	function bullet.CreateSoftBody2(...)
		return lib.btSoftBody_new2(...)
	end
	function bullet.CreateSoftBody(...)
		return lib.btSoftBody_new(...)
	end
end
do -- ManifoldPoint
	local META = {}
	META.__index = META
	function META:GetContactMotion1(...)
		return lib.btManifoldPoint_getContactMotion1(self, ...)
	end
	function META:SetLateralFrictionInitialized(...)
		return lib.btManifoldPoint_setLateralFrictionInitialized(self, ...)
	end
	function META:SetContactMotion1(...)
		return lib.btManifoldPoint_setContactMotion1(self, ...)
	end
	function META:GetDistance(...)
		return lib.btManifoldPoint_getDistance(self, ...)
	end
	function META:GetLocalPointB(...)
		return lib.btManifoldPoint_getLocalPointB(self, ...)
	end
	function META:GetCombinedFriction(...)
		return lib.btManifoldPoint_getCombinedFriction(self, ...)
	end
	function META:GetIndex0(...)
		return lib.btManifoldPoint_getIndex0(self, ...)
	end
	function META:SetAppliedImpulse(...)
		return lib.btManifoldPoint_setAppliedImpulse(self, ...)
	end
	function META:GetLifeTime(...)
		return lib.btManifoldPoint_getLifeTime(self, ...)
	end
	function META:SetLateralFrictionDir2(...)
		return lib.btManifoldPoint_setLateralFrictionDir2(self, ...)
	end
	function META:SetNormalWorldOnB(...)
		return lib.btManifoldPoint_setNormalWorldOnB(self, ...)
	end
	function META:GetContactMotion2(...)
		return lib.btManifoldPoint_getContactMotion2(self, ...)
	end
	function META:Delete(...)
		return lib.btManifoldPoint_delete(self, ...)
	end
	function META:SetUserPersistentData(...)
		return lib.btManifoldPoint_setUserPersistentData(self, ...)
	end
	function META:GetNormalWorldOnB(...)
		return lib.btManifoldPoint_getNormalWorldOnB(self, ...)
	end
	function META:SetPartId0(...)
		return lib.btManifoldPoint_setPartId0(self, ...)
	end
	function META:SetPositionWorldOnA(...)
		return lib.btManifoldPoint_setPositionWorldOnA(self, ...)
	end
	function META:SetContactMotion2(...)
		return lib.btManifoldPoint_setContactMotion2(self, ...)
	end
	function META:SetPositionWorldOnB(...)
		return lib.btManifoldPoint_setPositionWorldOnB(self, ...)
	end
	function META:SetLocalPointB(...)
		return lib.btManifoldPoint_setLocalPointB(self, ...)
	end
	function META:SetAppliedImpulseLateral1(...)
		return lib.btManifoldPoint_setAppliedImpulseLateral1(self, ...)
	end
	function META:GetAppliedImpulseLateral2(...)
		return lib.btManifoldPoint_getAppliedImpulseLateral2(self, ...)
	end
	function META:SetDistance(...)
		return lib.btManifoldPoint_setDistance(self, ...)
	end
	function META:GetContactCFM1(...)
		return lib.btManifoldPoint_getContactCFM1(self, ...)
	end
	function META:GetAppliedImpulseLateral1(...)
		return lib.btManifoldPoint_getAppliedImpulseLateral1(self, ...)
	end
	function META:SetLateralFrictionDir1(...)
		return lib.btManifoldPoint_setLateralFrictionDir1(self, ...)
	end
	function META:SetIndex1(...)
		return lib.btManifoldPoint_setIndex1(self, ...)
	end
	function META:GetUserPersistentData(...)
		return lib.btManifoldPoint_getUserPersistentData(self, ...)
	end
	function META:SetIndex0(...)
		return lib.btManifoldPoint_setIndex0(self, ...)
	end
	function META:SetDistance1(...)
		return lib.btManifoldPoint_setDistance1(self, ...)
	end
	function META:SetPartId1(...)
		return lib.btManifoldPoint_setPartId1(self, ...)
	end
	function META:SetContactCFM2(...)
		return lib.btManifoldPoint_setContactCFM2(self, ...)
	end
	function META:SetContactCFM1(...)
		return lib.btManifoldPoint_setContactCFM1(self, ...)
	end
	function META:SetLifeTime(...)
		return lib.btManifoldPoint_setLifeTime(self, ...)
	end
	function META:GetLateralFrictionInitialized(...)
		return lib.btManifoldPoint_getLateralFrictionInitialized(self, ...)
	end
	function META:GetPositionWorldOnB(...)
		return lib.btManifoldPoint_getPositionWorldOnB(self, ...)
	end
	function META:SetCombinedRestitution(...)
		return lib.btManifoldPoint_setCombinedRestitution(self, ...)
	end
	function META:SetCombinedRollingFriction(...)
		return lib.btManifoldPoint_setCombinedRollingFriction(self, ...)
	end
	function META:SetLocalPointA(...)
		return lib.btManifoldPoint_setLocalPointA(self, ...)
	end
	function META:GetLateralFrictionDir1(...)
		return lib.btManifoldPoint_getLateralFrictionDir1(self, ...)
	end
	function META:GetCombinedRestitution(...)
		return lib.btManifoldPoint_getCombinedRestitution(self, ...)
	end
	function META:GetLocalPointA(...)
		return lib.btManifoldPoint_getLocalPointA(self, ...)
	end
	function META:GetPartId1(...)
		return lib.btManifoldPoint_getPartId1(self, ...)
	end
	function META:GetContactCFM2(...)
		return lib.btManifoldPoint_getContactCFM2(self, ...)
	end
	function META:GetDistance1(...)
		return lib.btManifoldPoint_getDistance1(self, ...)
	end
	function META:GetIndex1(...)
		return lib.btManifoldPoint_getIndex1(self, ...)
	end
	function META:SetAppliedImpulseLateral2(...)
		return lib.btManifoldPoint_setAppliedImpulseLateral2(self, ...)
	end
	function META:GetAppliedImpulse(...)
		return lib.btManifoldPoint_getAppliedImpulse(self, ...)
	end
	function META:GetPartId0(...)
		return lib.btManifoldPoint_getPartId0(self, ...)
	end
	function META:GetCombinedRollingFriction(...)
		return lib.btManifoldPoint_getCombinedRollingFriction(self, ...)
	end
	function META:SetCombinedFriction(...)
		return lib.btManifoldPoint_setCombinedFriction(self, ...)
	end
	function META:GetLateralFrictionDir2(...)
		return lib.btManifoldPoint_getLateralFrictionDir2(self, ...)
	end
	function META:GetPositionWorldOnA(...)
		return lib.btManifoldPoint_getPositionWorldOnA(self, ...)
	end
	ffi.metatype('btManifoldPoint', META)
	function bullet.CreateManifoldPoint2(...)
		return lib.btManifoldPoint_new2(...)
	end
	function bullet.CreateManifoldPoint(...)
		return lib.btManifoldPoint_new(...)
	end
end
do -- MinkowskiPenetrationDepthSolver
	local META = {}
	META.__index = META
	ffi.metatype('btMinkowskiPenetrationDepthSolver', META)
	function bullet.CreateMinkowskiPenetrationDepthSolver(...)
		return lib.btMinkowskiPenetrationDepthSolver_new(...)
	end
end
do -- SoftBody_Element
	local META = {}
	META.__index = META
	function META:Delete(...)
		return lib.btSoftBody_Element_delete(self, ...)
	end
	function META:GetTag(...)
		return lib.btSoftBody_Element_getTag(self, ...)
	end
	function META:SetTag(...)
		return lib.btSoftBody_Element_setTag(self, ...)
	end
	ffi.metatype('btSoftBody_Element', META)
	function bullet.CreateSoftBody_Element(...)
		return lib.btSoftBody_Element_new(...)
	end
end
do -- BoxShape
	local META = {}
	META.__index = META
	function META:GetPlaneEquation(...)
		return lib.btBoxShape_getPlaneEquation(self, ...)
	end
	function META:GetHalfExtentsWithMargin(...)
		return lib.btBoxShape_getHalfExtentsWithMargin(self, ...)
	end
	function META:GetHalfExtentsWithoutMargin(...)
		return lib.btBoxShape_getHalfExtentsWithoutMargin(self, ...)
	end
	ffi.metatype('btBoxShape', META)
	function bullet.CreateBoxShape2(...)
		return lib.btBoxShape_new2(...)
	end
	function bullet.CreateBoxShape(...)
		return lib.btBoxShape_new(...)
	end
	function bullet.CreateBoxShape3(...)
		return lib.btBoxShape_new3(...)
	end
end
do -- SequentialImpulseConstraintSolver
	local META = {}
	META.__index = META
	function META:BtRand2(...)
		return lib.btSequentialImpulseConstraintSolver_btRand2(self, ...)
	end
	function META:BtRandInt2(...)
		return lib.btSequentialImpulseConstraintSolver_btRandInt2(self, ...)
	end
	function META:GetRandSeed(...)
		return lib.btSequentialImpulseConstraintSolver_getRandSeed(self, ...)
	end
	function META:SetRandSeed(...)
		return lib.btSequentialImpulseConstraintSolver_setRandSeed(self, ...)
	end
	ffi.metatype('btSequentialImpulseConstraintSolver', META)
	function bullet.CreateSequentialImpulseConstraintSolver(...)
		return lib.btSequentialImpulseConstraintSolver_new(...)
	end
end
do -- BroadphaseProxy
	local META = {}
	META.__index = META
	function META:SetMultiSapParentProxy(...)
		return lib.btBroadphaseProxy_setMultiSapParentProxy(self, ...)
	end
	function META:GetUid(...)
		return lib.btBroadphaseProxy_getUid(self, ...)
	end
	function META:IsConvex2d(...)
		return lib.btBroadphaseProxy_isConvex2d(self, ...)
	end
	function META:IsConvex(...)
		return lib.btBroadphaseProxy_isConvex(self, ...)
	end
	function META:IsSoftBody(...)
		return lib.btBroadphaseProxy_isSoftBody(self, ...)
	end
	function META:SetCollisionFilterGroup(...)
		return lib.btBroadphaseProxy_setCollisionFilterGroup(self, ...)
	end
	function META:GetMultiSapParentProxy(...)
		return lib.btBroadphaseProxy_getMultiSapParentProxy(self, ...)
	end
	function META:IsCompound(...)
		return lib.btBroadphaseProxy_isCompound(self, ...)
	end
	function META:Delete(...)
		return lib.btBroadphaseProxy_delete(self, ...)
	end
	function META:IsConcave(...)
		return lib.btBroadphaseProxy_isConcave(self, ...)
	end
	function META:SetCollisionFilterMask(...)
		return lib.btBroadphaseProxy_setCollisionFilterMask(self, ...)
	end
	function META:SetAabbMin(...)
		return lib.btBroadphaseProxy_setAabbMin(self, ...)
	end
	function META:IsInfinite(...)
		return lib.btBroadphaseProxy_isInfinite(self, ...)
	end
	function META:SetClientObject(...)
		return lib.btBroadphaseProxy_setClientObject(self, ...)
	end
	function META:GetAabbMax(...)
		return lib.btBroadphaseProxy_getAabbMax(self, ...)
	end
	function META:SetAabbMax(...)
		return lib.btBroadphaseProxy_setAabbMax(self, ...)
	end
	function META:IsNonMoving(...)
		return lib.btBroadphaseProxy_isNonMoving(self, ...)
	end
	function META:SetUniqueId(...)
		return lib.btBroadphaseProxy_setUniqueId(self, ...)
	end
	function META:IsPolyhedral(...)
		return lib.btBroadphaseProxy_isPolyhedral(self, ...)
	end
	function META:GetUniqueId(...)
		return lib.btBroadphaseProxy_getUniqueId(self, ...)
	end
	function META:GetCollisionFilterMask(...)
		return lib.btBroadphaseProxy_getCollisionFilterMask(self, ...)
	end
	function META:GetCollisionFilterGroup(...)
		return lib.btBroadphaseProxy_getCollisionFilterGroup(self, ...)
	end
	function META:GetClientObject(...)
		return lib.btBroadphaseProxy_getClientObject(self, ...)
	end
	function META:GetAabbMin(...)
		return lib.btBroadphaseProxy_getAabbMin(self, ...)
	end
	ffi.metatype('btBroadphaseProxy', META)
	function bullet.CreateBroadphaseProxy(...)
		return lib.btBroadphaseProxy_new(...)
	end
	function bullet.CreateBroadphaseProxy2(...)
		return lib.btBroadphaseProxy_new2(...)
	end
	function bullet.CreateBroadphaseProxy3(...)
		return lib.btBroadphaseProxy_new3(...)
	end
end
do -- NullPairCache
	local META = {}
	META.__index = META
	ffi.metatype('btNullPairCache', META)
	function bullet.CreateNullPairCache(...)
		return lib.btNullPairCache_new(...)
	end
end
do -- SoftBody_AJoint
	local META = {}
	META.__index = META
	function META:GetAxis(...)
		return lib.btSoftBody_AJoint_getAxis(self, ...)
	end
	function META:SetIcontrol(...)
		return lib.btSoftBody_AJoint_setIcontrol(self, ...)
	end
	function META:GetIcontrol(...)
		return lib.btSoftBody_AJoint_getIcontrol(self, ...)
	end
	ffi.metatype('btSoftBody_AJoint', META)
	function bullet.CreateSoftBody_AJoint(...)
		return lib.btSoftBody_AJoint_new(...)
	end
end
do -- DefaultVehicleRaycaster
	local META = {}
	META.__index = META
	ffi.metatype('btDefaultVehicleRaycaster', META)
	function bullet.CreateDefaultVehicleRaycaster(...)
		return lib.btDefaultVehicleRaycaster_new(...)
	end
end
do -- PairSet
	local META = {}
	META.__index = META
	ffi.metatype('btPairSet', META)
	function bullet.CreatePairSet(...)
		return lib.btPairSet_new(...)
	end
end
do -- ContactSolverInfo
	local META = {}
	META.__index = META
	ffi.metatype('btContactSolverInfo', META)
	function bullet.CreateContactSolverInfo(...)
		return lib.btContactSolverInfo_new(...)
	end
end
do -- ConvexConvexAlgorithm_CreateFunc
	local META = {}
	META.__index = META
	function META:GetSimplexSolver(...)
		return lib.btConvexConvexAlgorithm_CreateFunc_getSimplexSolver(self, ...)
	end
	function META:GetNumPerturbationIterations(...)
		return lib.btConvexConvexAlgorithm_CreateFunc_getNumPerturbationIterations(self, ...)
	end
	function META:SetMinimumPointsPerturbationThreshold(...)
		return lib.btConvexConvexAlgorithm_CreateFunc_setMinimumPointsPerturbationThreshold(self, ...)
	end
	function META:SetPdSolver(...)
		return lib.btConvexConvexAlgorithm_CreateFunc_setPdSolver(self, ...)
	end
	function META:SetSimplexSolver(...)
		return lib.btConvexConvexAlgorithm_CreateFunc_setSimplexSolver(self, ...)
	end
	function META:SetNumPerturbationIterations(...)
		return lib.btConvexConvexAlgorithm_CreateFunc_setNumPerturbationIterations(self, ...)
	end
	function META:GetMinimumPointsPerturbationThreshold(...)
		return lib.btConvexConvexAlgorithm_CreateFunc_getMinimumPointsPerturbationThreshold(self, ...)
	end
	function META:GetPdSolver(...)
		return lib.btConvexConvexAlgorithm_CreateFunc_getPdSolver(self, ...)
	end
	ffi.metatype('btConvexConvexAlgorithm_CreateFunc', META)
	function bullet.CreateConvexConvexAlgorithm_CreateFunc(...)
		return lib.btConvexConvexAlgorithm_CreateFunc_new(...)
	end
end
do -- Convex2dConvex2dAlgorithm
	local META = {}
	META.__index = META
	function META:GetManifold(...)
		return lib.btConvex2dConvex2dAlgorithm_getManifold(self, ...)
	end
	function META:SetLowLevelOfDetail(...)
		return lib.btConvex2dConvex2dAlgorithm_setLowLevelOfDetail(self, ...)
	end
	ffi.metatype('btConvex2dConvex2dAlgorithm', META)
	function bullet.CreateConvex2dConvex2dAlgorithm2(...)
		return lib.btConvex2dConvex2dAlgorithm_new(...)
	end
end
do -- SoftBody_AJoint_Specs
	local META = {}
	META.__index = META
	function META:GetAxis(...)
		return lib.btSoftBody_AJoint_Specs_getAxis(self, ...)
	end
	function META:SetAxis(...)
		return lib.btSoftBody_AJoint_Specs_setAxis(self, ...)
	end
	function META:SetIcontrol(...)
		return lib.btSoftBody_AJoint_Specs_setIcontrol(self, ...)
	end
	function META:GetIcontrol(...)
		return lib.btSoftBody_AJoint_Specs_getIcontrol(self, ...)
	end
	ffi.metatype('btSoftBody_AJoint_Specs', META)
	function bullet.CreateSoftBody_AJoint_Specs(...)
		return lib.btSoftBody_AJoint_Specs_new(...)
	end
end
do -- SoftBody_Config
	local META = {}
	META.__index = META
	function META:GetKVC(...)
		return lib.btSoftBody_Config_getKVC(self, ...)
	end
	function META:GetKPR(...)
		return lib.btSoftBody_Config_getKPR(self, ...)
	end
	function META:GetPsequence(...)
		return lib.btSoftBody_Config_getPsequence(self, ...)
	end
	function META:SetKLF(...)
		return lib.btSoftBody_Config_setKLF(self, ...)
	end
	function META:GetCiterations(...)
		return lib.btSoftBody_Config_getCiterations(self, ...)
	end
	function META:GetDiterations(...)
		return lib.btSoftBody_Config_getDiterations(self, ...)
	end
	function META:GetKDG(...)
		return lib.btSoftBody_Config_getKDG(self, ...)
	end
	function META:SetKDP(...)
		return lib.btSoftBody_Config_setKDP(self, ...)
	end
	function META:GetKMT(...)
		return lib.btSoftBody_Config_getKMT(self, ...)
	end
	function META:SetCiterations(...)
		return lib.btSoftBody_Config_setCiterations(self, ...)
	end
	function META:SetDiterations(...)
		return lib.btSoftBody_Config_setDiterations(self, ...)
	end
	function META:SetAeromodel(...)
		return lib.btSoftBody_Config_setAeromodel(self, ...)
	end
	function META:SetKCHR(...)
		return lib.btSoftBody_Config_setKCHR(self, ...)
	end
	function META:GetDsequence(...)
		return lib.btSoftBody_Config_getDsequence(self, ...)
	end
	function META:SetKAHR(...)
		return lib.btSoftBody_Config_setKAHR(self, ...)
	end
	function META:GetPiterations(...)
		return lib.btSoftBody_Config_getPiterations(self, ...)
	end
	function META:Delete(...)
		return lib.btSoftBody_Config_delete(self, ...)
	end
	function META:SetKPR(...)
		return lib.btSoftBody_Config_setKPR(self, ...)
	end
	function META:GetKKHR(...)
		return lib.btSoftBody_Config_getKKHR(self, ...)
	end
	function META:GetKLF(...)
		return lib.btSoftBody_Config_getKLF(self, ...)
	end
	function META:SetKDF(...)
		return lib.btSoftBody_Config_setKDF(self, ...)
	end
	function META:GetCollisions(...)
		return lib.btSoftBody_Config_getCollisions(self, ...)
	end
	function META:SetViterations(...)
		return lib.btSoftBody_Config_setViterations(self, ...)
	end
	function META:SetTimescale(...)
		return lib.btSoftBody_Config_setTimescale(self, ...)
	end
	function META:GetAeromodel(...)
		return lib.btSoftBody_Config_getAeromodel(self, ...)
	end
	function META:SetPiterations(...)
		return lib.btSoftBody_Config_setPiterations(self, ...)
	end
	function META:SetKDG(...)
		return lib.btSoftBody_Config_setKDG(self, ...)
	end
	function META:SetMaxvolume(...)
		return lib.btSoftBody_Config_setMaxvolume(self, ...)
	end
	function META:SetKVCF(...)
		return lib.btSoftBody_Config_setKVCF(self, ...)
	end
	function META:SetKVC(...)
		return lib.btSoftBody_Config_setKVC(self, ...)
	end
	function META:SetKSHR(...)
		return lib.btSoftBody_Config_setKSHR(self, ...)
	end
	function META:SetKMT(...)
		return lib.btSoftBody_Config_setKMT(self, ...)
	end
	function META:GetKSHR(...)
		return lib.btSoftBody_Config_getKSHR(self, ...)
	end
	function META:SetKKHR(...)
		return lib.btSoftBody_Config_setKKHR(self, ...)
	end
	function META:SetCollisions(...)
		return lib.btSoftBody_Config_setCollisions(self, ...)
	end
	function META:GetKDP(...)
		return lib.btSoftBody_Config_getKDP(self, ...)
	end
	function META:GetKDF(...)
		return lib.btSoftBody_Config_getKDF(self, ...)
	end
	function META:GetKVCF(...)
		return lib.btSoftBody_Config_getKVCF(self, ...)
	end
	function META:GetVsequence(...)
		return lib.btSoftBody_Config_getVsequence(self, ...)
	end
	function META:GetMaxvolume(...)
		return lib.btSoftBody_Config_getMaxvolume(self, ...)
	end
	function META:GetKCHR(...)
		return lib.btSoftBody_Config_getKCHR(self, ...)
	end
	function META:GetViterations(...)
		return lib.btSoftBody_Config_getViterations(self, ...)
	end
	function META:GetTimescale(...)
		return lib.btSoftBody_Config_getTimescale(self, ...)
	end
	function META:GetKAHR(...)
		return lib.btSoftBody_Config_getKAHR(self, ...)
	end
	ffi.metatype('btSoftBody_Config', META)
	function bullet.CreateSoftBody_Config(...)
		return lib.btSoftBody_Config_new(...)
	end
end
do -- CollisionWorld_LocalShapeInfo
	local META = {}
	META.__index = META
	function META:SetTriangleIndex(...)
		return lib.btCollisionWorld_LocalShapeInfo_setTriangleIndex(self, ...)
	end
	function META:SetShapePart(...)
		return lib.btCollisionWorld_LocalShapeInfo_setShapePart(self, ...)
	end
	function META:GetTriangleIndex(...)
		return lib.btCollisionWorld_LocalShapeInfo_getTriangleIndex(self, ...)
	end
	function META:GetShapePart(...)
		return lib.btCollisionWorld_LocalShapeInfo_getShapePart(self, ...)
	end
	function META:Delete(...)
		return lib.btCollisionWorld_LocalShapeInfo_delete(self, ...)
	end
	ffi.metatype('btCollisionWorld_LocalShapeInfo', META)
	function bullet.CreateCollisionWorld_LocalShapeInfo(...)
		return lib.btCollisionWorld_LocalShapeInfo_new(...)
	end
end
do -- SoftBody_Feature
	local META = {}
	META.__index = META
	function META:SetMaterial(...)
		return lib.btSoftBody_Feature_setMaterial(self, ...)
	end
	function META:GetMaterial(...)
		return lib.btSoftBody_Feature_getMaterial(self, ...)
	end
	ffi.metatype('btSoftBody_Feature', META)
	function bullet.CreateSoftBody_Feature(...)
		return lib.btSoftBody_Feature_new(...)
	end
end
do -- BT_QUANTIZED_BVH_NODE
	local META = {}
	META.__index = META
	ffi.metatype('BT_QUANTIZED_BVH_NODE', META)
	function bullet.CreateBT_QUANTIZED_BVH_NODE(...)
		return lib.BT_QUANTIZED_BVH_NODE_new(...)
	end
end
do -- PersistentManifold
	local META = {}
	META.__index = META
	function META:ClearUserCache(...)
		return lib.btPersistentManifold_clearUserCache(self, ...)
	end
	function META:ReplaceContactPoint(...)
		return lib.btPersistentManifold_replaceContactPoint(self, ...)
	end
	function META:RemoveContactPoint(...)
		return lib.btPersistentManifold_removeContactPoint(self, ...)
	end
	function META:GetContactPoint(...)
		return lib.btPersistentManifold_getContactPoint(self, ...)
	end
	function META:GetBody0(...)
		return lib.btPersistentManifold_getBody0(self, ...)
	end
	function META:AddManifoldPoint(...)
		return lib.btPersistentManifold_addManifoldPoint(self, ...)
	end
	function META:GetBody1(...)
		return lib.btPersistentManifold_getBody1(self, ...)
	end
	function META:GetCacheEntry(...)
		return lib.btPersistentManifold_getCacheEntry(self, ...)
	end
	function META:GetContactProcessingThreshold(...)
		return lib.btPersistentManifold_getContactProcessingThreshold(self, ...)
	end
	function META:ValidContactDistance(...)
		return lib.btPersistentManifold_validContactDistance(self, ...)
	end
	function META:GetCompanionIdA(...)
		return lib.btPersistentManifold_getCompanionIdA(self, ...)
	end
	function META:GetNumContacts(...)
		return lib.btPersistentManifold_getNumContacts(self, ...)
	end
	function META:AddManifoldPoint2(...)
		return lib.btPersistentManifold_addManifoldPoint2(self, ...)
	end
	function META:GetContactBreakingThreshold(...)
		return lib.btPersistentManifold_getContactBreakingThreshold(self, ...)
	end
	function META:SetIndex1a(...)
		return lib.btPersistentManifold_setIndex1a(self, ...)
	end
	function META:ClearManifold(...)
		return lib.btPersistentManifold_clearManifold(self, ...)
	end
	function META:SetBodies(...)
		return lib.btPersistentManifold_setBodies(self, ...)
	end
	function META:GetIndex1a(...)
		return lib.btPersistentManifold_getIndex1a(self, ...)
	end
	function META:SetCompanionIdB(...)
		return lib.btPersistentManifold_setCompanionIdB(self, ...)
	end
	function META:SetCompanionIdA(...)
		return lib.btPersistentManifold_setCompanionIdA(self, ...)
	end
	function META:SetContactProcessingThreshold(...)
		return lib.btPersistentManifold_setContactProcessingThreshold(self, ...)
	end
	function META:SetContactBreakingThreshold(...)
		return lib.btPersistentManifold_setContactBreakingThreshold(self, ...)
	end
	function META:RefreshContactPoints(...)
		return lib.btPersistentManifold_refreshContactPoints(self, ...)
	end
	function META:SetNumContacts(...)
		return lib.btPersistentManifold_setNumContacts(self, ...)
	end
	function META:GetCompanionIdB(...)
		return lib.btPersistentManifold_getCompanionIdB(self, ...)
	end
	ffi.metatype('btPersistentManifold', META)
	function bullet.CreatePersistentManifold2(...)
		return lib.btPersistentManifold_new2(...)
	end
	function bullet.CreatePersistentManifold(...)
		return lib.btPersistentManifold_new(...)
	end
end
do -- DiscreteCollisionDetectorInterface_ClosestPointInput
	local META = {}
	META.__index = META
	function META:SetMaximumDistanceSquared(...)
		return lib.btDiscreteCollisionDetectorInterface_ClosestPointInput_setMaximumDistanceSquared(self, ...)
	end
	function META:Delete(...)
		return lib.btDiscreteCollisionDetectorInterface_ClosestPointInput_delete(self, ...)
	end
	function META:SetTransformA(...)
		return lib.btDiscreteCollisionDetectorInterface_ClosestPointInput_setTransformA(self, ...)
	end
	function META:SetTransformB(...)
		return lib.btDiscreteCollisionDetectorInterface_ClosestPointInput_setTransformB(self, ...)
	end
	function META:GetMaximumDistanceSquared(...)
		return lib.btDiscreteCollisionDetectorInterface_ClosestPointInput_getMaximumDistanceSquared(self, ...)
	end
	function META:GetTransformB(...)
		return lib.btDiscreteCollisionDetectorInterface_ClosestPointInput_getTransformB(self, ...)
	end
	function META:GetTransformA(...)
		return lib.btDiscreteCollisionDetectorInterface_ClosestPointInput_getTransformA(self, ...)
	end
	ffi.metatype('btDiscreteCollisionDetectorInterface_ClosestPointInput', META)
	function bullet.CreateDiscreteCollisionDetectorInterface_ClosestPointInput(...)
		return lib.btDiscreteCollisionDetectorInterface_ClosestPointInput_new(...)
	end
end
do -- SoftBody_RayFromToCaster
	local META = {}
	META.__index = META
	function META:GetMint(...)
		return lib.btSoftBody_RayFromToCaster_getMint(self, ...)
	end
	function META:RayFromToTriangle(...)
		return lib.btSoftBody_RayFromToCaster_rayFromToTriangle(self, ...)
	end
	function META:GetRayFrom(...)
		return lib.btSoftBody_RayFromToCaster_getRayFrom(self, ...)
	end
	function META:GetRayNormalizedDirection(...)
		return lib.btSoftBody_RayFromToCaster_getRayNormalizedDirection(self, ...)
	end
	function META:SetRayFrom(...)
		return lib.btSoftBody_RayFromToCaster_setRayFrom(self, ...)
	end
	function META:SetTests(...)
		return lib.btSoftBody_RayFromToCaster_setTests(self, ...)
	end
	function META:SetRayTo(...)
		return lib.btSoftBody_RayFromToCaster_setRayTo(self, ...)
	end
	function META:SetRayNormalizedDirection(...)
		return lib.btSoftBody_RayFromToCaster_setRayNormalizedDirection(self, ...)
	end
	function META:SetMint(...)
		return lib.btSoftBody_RayFromToCaster_setMint(self, ...)
	end
	function META:GetFace(...)
		return lib.btSoftBody_RayFromToCaster_getFace(self, ...)
	end
	function META:SetFace(...)
		return lib.btSoftBody_RayFromToCaster_setFace(self, ...)
	end
	function META:GetTests(...)
		return lib.btSoftBody_RayFromToCaster_getTests(self, ...)
	end
	function META:RayFromToTriangle2(...)
		return lib.btSoftBody_RayFromToCaster_rayFromToTriangle2(self, ...)
	end
	function META:GetRayTo(...)
		return lib.btSoftBody_RayFromToCaster_getRayTo(self, ...)
	end
	ffi.metatype('btSoftBody_RayFromToCaster', META)
	function bullet.CreateSoftBody_RayFromToCaster(...)
		return lib.btSoftBody_RayFromToCaster_new(...)
	end
end
do -- SoftBody_Tetra
	local META = {}
	META.__index = META
	function META:GetC0(...)
		return lib.btSoftBody_Tetra_getC0(self, ...)
	end
	function META:GetLeaf(...)
		return lib.btSoftBody_Tetra_getLeaf(self, ...)
	end
	function META:SetC2(...)
		return lib.btSoftBody_Tetra_setC2(self, ...)
	end
	function META:GetN(...)
		return lib.btSoftBody_Tetra_getN(self, ...)
	end
	function META:GetC2(...)
		return lib.btSoftBody_Tetra_getC2(self, ...)
	end
	function META:SetRv(...)
		return lib.btSoftBody_Tetra_setRv(self, ...)
	end
	function META:SetC1(...)
		return lib.btSoftBody_Tetra_setC1(self, ...)
	end
	function META:GetC1(...)
		return lib.btSoftBody_Tetra_getC1(self, ...)
	end
	function META:SetLeaf(...)
		return lib.btSoftBody_Tetra_setLeaf(self, ...)
	end
	function META:GetRv(...)
		return lib.btSoftBody_Tetra_getRv(self, ...)
	end
	ffi.metatype('btSoftBody_Tetra', META)
	function bullet.CreateSoftBody_Tetra(...)
		return lib.btSoftBody_Tetra_new(...)
	end
end
do -- SoftSoftCollisionAlgorithm_CreateFunc
	local META = {}
	META.__index = META
	ffi.metatype('btSoftSoftCollisionAlgorithm_CreateFunc', META)
	function bullet.CreateSoftSoftCollisionAlgorithm_CreateFunc(...)
		return lib.btSoftSoftCollisionAlgorithm_CreateFunc_new(...)
	end
end
do -- StaticPlaneShape
	local META = {}
	META.__index = META
	function META:GetPlaneConstant(...)
		return lib.btStaticPlaneShape_getPlaneConstant(self, ...)
	end
	function META:GetPlaneNormal(...)
		return lib.btStaticPlaneShape_getPlaneNormal(self, ...)
	end
	ffi.metatype('btStaticPlaneShape', META)
	function bullet.CreateStaticPlaneShape(...)
		return lib.btStaticPlaneShape_new(...)
	end
end
do -- UnionFind
	local META = {}
	META.__index = META
	function META:Unite(...)
		return lib.btUnionFind_unite(self, ...)
	end
	function META:Find2(...)
		return lib.btUnionFind_find2(self, ...)
	end
	function META:Allocate(...)
		return lib.btUnionFind_allocate(self, ...)
	end
	function META:GetNumElements(...)
		return lib.btUnionFind_getNumElements(self, ...)
	end
	function META:Find(...)
		return lib.btUnionFind_find(self, ...)
	end
	function META:Delete(...)
		return lib.btUnionFind_delete(self, ...)
	end
	function META:IsRoot(...)
		return lib.btUnionFind_isRoot(self, ...)
	end
	function META:GetElement(...)
		return lib.btUnionFind_getElement(self, ...)
	end
	function META:Free(...)
		return lib.btUnionFind_Free(self, ...)
	end
	function META:SortIslands(...)
		return lib.btUnionFind_sortIslands(self, ...)
	end
	function META:Reset(...)
		return lib.btUnionFind_reset(self, ...)
	end
	ffi.metatype('btUnionFind', META)
	function bullet.CreateUnionFind(...)
		return lib.btUnionFind_new(...)
	end
end
do -- SparseSdf
	local META = {}
	META.__index = META
	function META:Delete(...)
		return lib.btSparseSdf_delete(self, ...)
	end
	ffi.metatype('btSparseSdf3', META)
	function bullet.CreateSparseSdf(...)
		return lib.btSparseSdf_new(...)
	end
end
do -- Dbvt_sStkNP
	local META = {}
	META.__index = META
	function META:Delete(...)
		return lib.btDbvt_sStkNP_delete(self, ...)
	end
	function META:GetMask(...)
		return lib.btDbvt_sStkNP_getMask(self, ...)
	end
	function META:GetNode(...)
		return lib.btDbvt_sStkNP_getNode(self, ...)
	end
	function META:SetNode(...)
		return lib.btDbvt_sStkNP_setNode(self, ...)
	end
	function META:SetMask(...)
		return lib.btDbvt_sStkNP_setMask(self, ...)
	end
	ffi.metatype('btDbvt_sStkNP', META)
	function bullet.CreateDbvt_sStkNP(...)
		return lib.btDbvt_sStkNP_new(...)
	end
end
do -- BoxBoxDetector
	local META = {}
	META.__index = META
	function META:SetBox2(...)
		return lib.btBoxBoxDetector_setBox2(self, ...)
	end
	function META:GetBox1(...)
		return lib.btBoxBoxDetector_getBox1(self, ...)
	end
	function META:SetBox1(...)
		return lib.btBoxBoxDetector_setBox1(self, ...)
	end
	function META:GetBox2(...)
		return lib.btBoxBoxDetector_getBox2(self, ...)
	end
	ffi.metatype('btBoxBoxDetector', META)
	function bullet.CreateBoxBoxDetector(...)
		return lib.btBoxBoxDetector_new(...)
	end
end
do -- Dbvt
	local META = {}
	META.__index = META
	function META:Empty(...)
		return lib.btDbvt_empty(self, ...)
	end
	function META:CollideOCL(...)
		return lib.btDbvt_collideOCL(self, ...)
	end
	function META:CollideOCL2(...)
		return lib.btDbvt_collideOCL2(self, ...)
	end
	function META:Update2(...)
		return lib.btDbvt_update2(self, ...)
	end
	function META:ExtractLeaves(...)
		return lib.btDbvt_extractLeaves(self, ...)
	end
	function META:CountLeaves(...)
		return lib.btDbvt_countLeaves(self, ...)
	end
	function META:CollideTV(...)
		return lib.btDbvt_collideTV(self, ...)
	end
	function META:GetRoot(...)
		return lib.btDbvt_getRoot(self, ...)
	end
	function META:SetOpath(...)
		return lib.btDbvt_setOpath(self, ...)
	end
	function META:EnumLeaves(...)
		return lib.btDbvt_enumLeaves(self, ...)
	end
	function META:Update(...)
		return lib.btDbvt_update(self, ...)
	end
	function META:Nearest(...)
		return lib.btDbvt_nearest(self, ...)
	end
	function META:OptimizeTopDown(...)
		return lib.btDbvt_optimizeTopDown(self, ...)
	end
	function META:OptimizeIncremental(...)
		return lib.btDbvt_optimizeIncremental(self, ...)
	end
	function META:SetLkhd(...)
		return lib.btDbvt_setLkhd(self, ...)
	end
	function META:GetOpath(...)
		return lib.btDbvt_getOpath(self, ...)
	end
	function META:Delete(...)
		return lib.btDbvt_delete(self, ...)
	end
	function META:Write(...)
		return lib.btDbvt_write(self, ...)
	end
	function META:Update6(...)
		return lib.btDbvt_update6(self, ...)
	end
	function META:Update5(...)
		return lib.btDbvt_update5(self, ...)
	end
	function META:Update4(...)
		return lib.btDbvt_update4(self, ...)
	end
	function META:Update3(...)
		return lib.btDbvt_update3(self, ...)
	end
	function META:SetRoot(...)
		return lib.btDbvt_setRoot(self, ...)
	end
	function META:OptimizeTopDown2(...)
		return lib.btDbvt_optimizeTopDown2(self, ...)
	end
	function META:CollideKDOP(...)
		return lib.btDbvt_collideKDOP(self, ...)
	end
	function META:SetLeaves(...)
		return lib.btDbvt_setLeaves(self, ...)
	end
	function META:EnumNodes(...)
		return lib.btDbvt_enumNodes(self, ...)
	end
	function META:SetFree(...)
		return lib.btDbvt_setFree(self, ...)
	end
	function META:Clone(...)
		return lib.btDbvt_clone(self, ...)
	end
	function META:GetStkStack(...)
		return lib.btDbvt_getStkStack(self, ...)
	end
	function META:Insert(...)
		return lib.btDbvt_insert(self, ...)
	end
	function META:RayTestInternal(...)
		return lib.btDbvt_rayTestInternal(self, ...)
	end
	function META:Clear(...)
		return lib.btDbvt_clear(self, ...)
	end
	function META:RayTest(...)
		return lib.btDbvt_rayTest(self, ...)
	end
	function META:CollideTT(...)
		return lib.btDbvt_collideTT(self, ...)
	end
	function META:Maxdepth(...)
		return lib.btDbvt_maxdepth(self, ...)
	end
	function META:Allocate(...)
		return lib.btDbvt_allocate(self, ...)
	end
	function META:Benchmark(...)
		return lib.btDbvt_benchmark(self, ...)
	end
	function META:GetFree(...)
		return lib.btDbvt_getFree(self, ...)
	end
	function META:Clone2(...)
		return lib.btDbvt_clone2(self, ...)
	end
	function META:GetRayTestStack(...)
		return lib.btDbvt_getRayTestStack(self, ...)
	end
	function META:Remove(...)
		return lib.btDbvt_remove(self, ...)
	end
	function META:CollideTTpersistentStack(...)
		return lib.btDbvt_collideTTpersistentStack(self, ...)
	end
	function META:GetLkhd(...)
		return lib.btDbvt_getLkhd(self, ...)
	end
	function META:CollideTU(...)
		return lib.btDbvt_collideTU(self, ...)
	end
	function META:OptimizeBottomUp(...)
		return lib.btDbvt_optimizeBottomUp(self, ...)
	end
	function META:GetLeaves(...)
		return lib.btDbvt_getLeaves(self, ...)
	end
	ffi.metatype('btDbvt', META)
	function bullet.CreateDbvt(...)
		return lib.btDbvt_new(...)
	end
end
do -- SoftBody_Material
	local META = {}
	META.__index = META
	function META:GetKAST(...)
		return lib.btSoftBody_Material_getKAST(self, ...)
	end
	function META:SetKVST(...)
		return lib.btSoftBody_Material_setKVST(self, ...)
	end
	function META:SetKLST(...)
		return lib.btSoftBody_Material_setKLST(self, ...)
	end
	function META:SetFlags(...)
		return lib.btSoftBody_Material_setFlags(self, ...)
	end
	function META:GetKVST(...)
		return lib.btSoftBody_Material_getKVST(self, ...)
	end
	function META:GetKLST(...)
		return lib.btSoftBody_Material_getKLST(self, ...)
	end
	function META:SetKAST(...)
		return lib.btSoftBody_Material_setKAST(self, ...)
	end
	function META:GetFlags(...)
		return lib.btSoftBody_Material_getFlags(self, ...)
	end
	ffi.metatype('btSoftBody_Material', META)
	function bullet.CreateSoftBody_Material(...)
		return lib.btSoftBody_Material_new(...)
	end
end
do -- TriangleIndexVertexMaterialArray
	local META = {}
	META.__index = META
	function META:GetLockedReadOnlyMaterialBase(...)
		return lib.btTriangleIndexVertexMaterialArray_getLockedReadOnlyMaterialBase(self, ...)
	end
	function META:GetLockedMaterialBase(...)
		return lib.btTriangleIndexVertexMaterialArray_getLockedMaterialBase(self, ...)
	end
	function META:AddMaterialProperties(...)
		return lib.btTriangleIndexVertexMaterialArray_addMaterialProperties(self, ...)
	end
	function META:GetLockedReadOnlyMaterialBase2(...)
		return lib.btTriangleIndexVertexMaterialArray_getLockedReadOnlyMaterialBase2(self, ...)
	end
	function META:GetLockedMaterialBase2(...)
		return lib.btTriangleIndexVertexMaterialArray_getLockedMaterialBase2(self, ...)
	end
	function META:AddMaterialProperties2(...)
		return lib.btTriangleIndexVertexMaterialArray_addMaterialProperties2(self, ...)
	end
	ffi.metatype('btTriangleIndexVertexMaterialArray', META)
	function bullet.CreateTriangleIndexVertexMaterialArray2(...)
		return lib.btTriangleIndexVertexMaterialArray_new2(...)
	end
	function bullet.CreateTriangleIndexVertexMaterialArray(...)
		return lib.btTriangleIndexVertexMaterialArray_new(...)
	end
end
do -- SoftBody_Face
	local META = {}
	META.__index = META
	function META:GetNormal(...)
		return lib.btSoftBody_Face_getNormal(self, ...)
	end
	function META:GetRa(...)
		return lib.btSoftBody_Face_getRa(self, ...)
	end
	function META:SetRa(...)
		return lib.btSoftBody_Face_setRa(self, ...)
	end
	function META:GetLeaf(...)
		return lib.btSoftBody_Face_getLeaf(self, ...)
	end
	function META:SetNormal(...)
		return lib.btSoftBody_Face_setNormal(self, ...)
	end
	function META:GetN(...)
		return lib.btSoftBody_Face_getN(self, ...)
	end
	function META:SetLeaf(...)
		return lib.btSoftBody_Face_setLeaf(self, ...)
	end
	ffi.metatype('btSoftBody_Face', META)
	function bullet.CreateSoftBody_Face(...)
		return lib.btSoftBody_Face_new(...)
	end
end
return bullet