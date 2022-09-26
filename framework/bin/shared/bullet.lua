local ffi = require("ffi");local CLIB = assert(ffi.load("bullet"));ffi.cdef([[struct b3JointInfo {char m_linkName[1024];char m_jointName[1024];int m_jointType;int m_qIndex;int m_uIndex;int m_jointIndex;int m_flags;double m_jointDamping;double m_jointFriction;double m_jointLowerLimit;double m_jointUpperLimit;double m_jointMaxForce;double m_jointMaxVelocity;double m_parentFrame[7];double m_childFrame[7];double m_jointAxis[3];int m_parentIndex;int m_qSize;int m_uSize;};
struct b3UserDataValue {int m_type;int m_length;const char*m_data1;};
struct b3UserConstraint {int m_parentBodyIndex;int m_parentJointIndex;int m_childBodyIndex;int m_childJointIndex;double m_parentFrame[7];double m_childFrame[7];double m_jointAxis[3];int m_jointType;double m_maxAppliedForce;int m_userConstraintUniqueId;double m_gearRatio;int m_gearAuxLink;double m_relativePositionTarget;double m_erp;};
struct b3BodyInfo {char m_baseName[1024];char m_bodyName[1024];};
struct b3DynamicsInfo {double m_mass;double m_localInertialDiagonal[3];double m_localInertialFrame[7];double m_lateralFrictionCoeff;double m_rollingFrictionCoeff;double m_spinningFrictionCoeff;double m_restitution;double m_contactStiffness;double m_contactDamping;int m_activationState;int m_bodyType;double m_angularDamping;double m_linearDamping;double m_ccdSweptSphereRadius;double m_contactProcessingThreshold;int m_frictionAnchor;double m_collisionMargin;int m_dynamicType;};
struct b3JointSensorState {double m_jointPosition;double m_jointVelocity;double m_jointForceTorque[6];double m_jointMotorTorque;};
struct b3JointSensorState2 {double m_jointPosition[4];double m_jointVelocity[3];double m_jointReactionForceTorque[6];double m_jointMotorTorqueMultiDof[3];int m_qDofSize;int m_uDofSize;};
struct b3DebugLines {int m_numDebugLines;const float*m_linesFrom;const float*m_linesTo;const float*m_linesColor;};
struct b3OverlappingObject {int m_objectUniqueId;int m_linkIndex;};
struct b3AABBOverlapData {int m_numOverlappingObjects;struct b3OverlappingObject*m_overlappingObjects;};
struct b3CameraImageData {int m_pixelWidth;int m_pixelHeight;const unsigned char*m_rgbColorData;const float*m_depthValues;const int*m_segmentationMaskValues;};
struct b3MeshVertex {double x;double y;double z;double w;};
struct b3MeshData {int m_numVertices;struct b3MeshVertex*m_vertices;};
struct b3OpenGLVisualizerCameraInfo {int m_width;int m_height;float m_viewMatrix[16];float m_projectionMatrix[16];float m_camUp[3];float m_camForward[3];float m_horizontal[3];float m_vertical[3];float m_yaw;float m_pitch;float m_dist;float m_target[3];};
struct b3UserConstraintState {double m_appliedConstraintForces[6];int m_numDofs;};
struct b3VRControllerEvent {int m_controllerId;int m_deviceType;int m_numMoveEvents;int m_numButtonEvents;float m_pos[4];float m_orn[4];float m_analogAxis;float m_auxAnalogAxis[5*2];int m_buttons[64];};
struct b3VREventsData {int m_numControllerEvents;struct b3VRControllerEvent*m_controllerEvents;};
struct b3KeyboardEvent {int m_keyCode;int m_keyState;};
struct b3KeyboardEventsData {int m_numKeyboardEvents;struct b3KeyboardEvent*m_keyboardEvents;};
struct b3MouseEvent {int m_eventType;float m_mousePosX;float m_mousePosY;int m_buttonIndex;int m_buttonState;};
struct b3MouseEventsData {int m_numMouseEvents;struct b3MouseEvent*m_mouseEvents;};
struct b3ContactPointData {int m_contactFlags;int m_bodyUniqueIdA;int m_bodyUniqueIdB;int m_linkIndexA;int m_linkIndexB;double m_positionOnAInWS[3];double m_positionOnBInWS[3];double m_contactNormalOnBInWS[3];double m_contactDistance;double m_normalForce;double m_linearFrictionForce1;double m_linearFrictionForce2;double m_linearFrictionDirection1[3];double m_linearFrictionDirection2[3];};
struct b3ContactInformation {int m_numContactPoints;struct b3ContactPointData*m_contactPointData;};
struct b3RayHitInfo {double m_hitFraction;int m_hitObjectUniqueId;int m_hitObjectLinkIndex;double m_hitPositionWorld[3];double m_hitNormalWorld[3];};
struct b3RaycastInformation {int m_numRayHits;struct b3RayHitInfo*m_rayHits;};
struct b3VisualShapeData {int m_objectUniqueId;int m_linkIndex;int m_visualGeometryType;double m_dimensions[3];char m_meshAssetFileName[1024];double m_localVisualFrame[7];double m_rgbaColor[4];int m_tinyRendererTextureId;int m_textureUniqueId;int m_openglTextureId;};
struct b3VisualShapeInformation {int m_numVisualShapes;struct b3VisualShapeData*m_visualShapeData;};
struct b3CollisionShapeData {int m_objectUniqueId;int m_linkIndex;int m_collisionGeometryType;double m_dimensions[3];double m_localCollisionFrame[7];char m_meshAssetFileName[1024];};
struct b3CollisionShapeInformation {int m_numCollisionShapes;struct b3CollisionShapeData*m_collisionShapeData;};
struct b3LinkState {double m_worldPosition[3];double m_worldOrientation[4];double m_localInertialPosition[3];double m_localInertialOrientation[4];double m_worldLinkFramePosition[3];double m_worldLinkFrameOrientation[4];double m_worldLinearVelocity[3];double m_worldAngularVelocity[3];double m_worldAABBMin[3];double m_worldAABBMax[3];};
struct b3PhysicsSimulationParameters {double m_deltaTime;double m_simulationTimestamp;double m_gravityAcceleration[3];int m_numSimulationSubSteps;int m_numSolverIterations;double m_warmStartingFactor;double m_articulatedWarmStartingFactor;int m_useRealTimeSimulation;int m_useSplitImpulse;double m_splitImpulsePenetrationThreshold;double m_contactBreakingThreshold;int m_internalSimFlags;double m_defaultContactERP;int m_collisionFilterMode;int m_enableFileCaching;double m_restitutionVelocityThreshold;double m_defaultNonContactERP;double m_frictionERP;double m_defaultGlobalCFM;double m_frictionCFM;int m_enableConeFriction;int m_deterministicOverlappingPairs;double m_allowedCcdPenetration;int m_jointFeedbackMode;double m_solverResidualThreshold;double m_contactSlop;int m_enableSAT;int m_constraintSolverType;int m_minimumSolverIslandSize;int m_reportSolverAnalytics;double m_sparseSdfVoxelSize;int m_numNonContactInnerIterations;};
struct b3ForwardDynamicsAnalyticsIslandData {int m_islandId;int m_numBodies;int m_numContactManifolds;int m_numIterationsUsed;double m_remainingLeastSquaresResidual;};
struct b3ForwardDynamicsAnalyticsArgs {int m_numSteps;int m_numIslands;int m_numSolverCalls;struct b3ForwardDynamicsAnalyticsIslandData m_islandData[64];};
struct b3PhysicsClientHandle__ {int unused;};
struct b3SharedMemoryCommandHandle__ {int unused;};
struct b3SharedMemoryStatusHandle__ {int unused;};
int(b3PhysicsParamSetSolverResidualThreshold)(struct b3SharedMemoryCommandHandle__*,double);
int(b3CreateCollisionShapeAddHeightfield)(struct b3SharedMemoryCommandHandle__*,const char*,const double,double);
int(b3PhysicsParamSetContactSlop)(struct b3SharedMemoryCommandHandle__*,double);
int(b3CreateCollisionShapeAddHeightfield2)(struct b3PhysicsClientHandle__*,struct b3SharedMemoryCommandHandle__*,const double,double,float*,int,int,int);
int(b3PhysicsParameterSetEnableSAT)(struct b3SharedMemoryCommandHandle__*,int);
int(b3CreateCollisionShapeAddPlane)(struct b3SharedMemoryCommandHandle__*,const double,double);
int(b3PhysicsParameterSetConstraintSolverType)(struct b3SharedMemoryCommandHandle__*,int);
int(b3CreateCollisionShapeAddMesh)(struct b3SharedMemoryCommandHandle__*,const char*,const double);
int(b3PhysicsParameterSetMinimumSolverIslandSize)(struct b3SharedMemoryCommandHandle__*,int);
int(b3CreateCollisionShapeAddConvexMesh)(struct b3PhysicsClientHandle__*,struct b3SharedMemoryCommandHandle__*,const double,const double*,int);
int(b3PhysicsParamSetSolverAnalytics)(struct b3SharedMemoryCommandHandle__*,int);
int(b3GetBodyUniqueId)(struct b3PhysicsClientHandle__*,int);
int(b3CreateCollisionShapeAddConcaveMesh)(struct b3PhysicsClientHandle__*,struct b3SharedMemoryCommandHandle__*,const double,const double*,int,const int*,int);
int(b3PhysicsParameterSetSparseSdfVoxelSize)(struct b3SharedMemoryCommandHandle__*,double);
int(b3GetBodyInfo)(struct b3PhysicsClientHandle__*,int,struct b3BodyInfo*);
void(b3CreateCollisionSetFlag)(struct b3SharedMemoryCommandHandle__*,int,int);
struct b3SharedMemoryCommandHandle__*(b3InitRequestPhysicsParamCommand)(struct b3PhysicsClientHandle__*);
int(b3GetNumJoints)(struct b3PhysicsClientHandle__*,int);
int(b3GetStatusPhysicsSimulationParameters)(struct b3SharedMemoryStatusHandle__*,struct b3PhysicsSimulationParameters*);
int(b3GetNumDofs)(struct b3PhysicsClientHandle__*,int);
int(b3ComputeDofCount)(struct b3PhysicsClientHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3InitStepSimulationCommand)(struct b3PhysicsClientHandle__*);
struct b3SharedMemoryCommandHandle__*(b3InitStepSimulationCommand2)(struct b3SharedMemoryCommandHandle__*);
struct b3SharedMemoryCommandHandle__*(b3InitSyncUserDataCommand)(struct b3PhysicsClientHandle__*);
struct b3SharedMemoryCommandHandle__*(b3InitPerformCollisionDetectionCommand)(struct b3PhysicsClientHandle__*);
void(b3AddBodyToSyncUserDataRequest)(struct b3SharedMemoryCommandHandle__*,int);
void(b3MeshDataSimulationMeshVelocity)(struct b3SharedMemoryCommandHandle__*);
struct b3SharedMemoryCommandHandle__*(b3InitAddUserDataCommand)(struct b3PhysicsClientHandle__*,int,int,int,const char*,enum UserDataValueType,int,const void*);
void(b3GetMeshDataSetCollisionShapeIndex)(struct b3SharedMemoryCommandHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3InitResetSimulationCommand)(struct b3PhysicsClientHandle__*);
void(b3GetMeshDataSetFlags)(struct b3SharedMemoryCommandHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3InitResetSimulationCommand2)(struct b3SharedMemoryCommandHandle__*);
int(b3GetUserData)(struct b3PhysicsClientHandle__*,int,struct b3UserDataValue*);
int(b3InitResetSimulationSetFlags)(struct b3SharedMemoryCommandHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3LoadUrdfCommandInit)(struct b3PhysicsClientHandle__*,const char*);
struct b3SharedMemoryCommandHandle__*(b3LoadUrdfCommandInit2)(struct b3SharedMemoryCommandHandle__*,const char*);
int(b3GetNumUserData)(struct b3PhysicsClientHandle__*,int);
int(b3LoadUrdfCommandSetStartPosition)(struct b3SharedMemoryCommandHandle__*,double,double,double);
void(b3GetUserDataInfo)(struct b3PhysicsClientHandle__*,int,int,const char**,int*,int*,int*);
int(b3LoadUrdfCommandSetStartOrientation)(struct b3SharedMemoryCommandHandle__*,double,double,double,double);
struct b3SharedMemoryCommandHandle__*(b3GetDynamicsInfoCommandInit)(struct b3PhysicsClientHandle__*,int,int);
int(b3CreateVisualShapeAddCylinder)(struct b3SharedMemoryCommandHandle__*,double,double);
int(b3LoadUrdfCommandSetUseMultiBody)(struct b3SharedMemoryCommandHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3GetDynamicsInfoCommandInit2)(struct b3SharedMemoryCommandHandle__*,int,int);
int(b3LoadUrdfCommandSetUseFixedBase)(struct b3SharedMemoryCommandHandle__*,int);
int(b3GetDynamicsInfo)(struct b3SharedMemoryStatusHandle__*,struct b3DynamicsInfo*);
int(b3CreateVisualShapeAddMesh2)(struct b3PhysicsClientHandle__*,struct b3SharedMemoryCommandHandle__*,const double,const double*,int,const int*,int,const double*,int,const double*,int);
int(b3LoadUrdfCommandSetFlags)(struct b3SharedMemoryCommandHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3InitChangeDynamicsInfo)(struct b3PhysicsClientHandle__*);
int(b3LoadUrdfCommandSetGlobalScaling)(struct b3SharedMemoryCommandHandle__*,double);
struct b3SharedMemoryCommandHandle__*(b3InitChangeDynamicsInfo2)(struct b3SharedMemoryCommandHandle__*);
void(b3CreateVisualShapeSetChildTransform)(struct b3SharedMemoryCommandHandle__*,int,const double,const double);
struct b3SharedMemoryCommandHandle__*(b3SaveStateCommandInit)(struct b3PhysicsClientHandle__*);
int(b3ChangeDynamicsInfoSetMass)(struct b3SharedMemoryCommandHandle__*,int,int,double);
struct b3SharedMemoryCommandHandle__*(b3InitRemoveStateCommand)(struct b3PhysicsClientHandle__*,int);
int(b3ChangeDynamicsInfoSetLocalInertiaDiagonal)(struct b3SharedMemoryCommandHandle__*,int,int,const double);
int(b3GetStatusGetStateId)(struct b3SharedMemoryStatusHandle__*);
int(b3ChangeDynamicsInfoSetAnisotropicFriction)(struct b3SharedMemoryCommandHandle__*,int,int,const double);
int(b3LoadStateSetStateId)(struct b3SharedMemoryCommandHandle__*,int);
int(b3ChangeDynamicsInfoSetJointLimit)(struct b3SharedMemoryCommandHandle__*,int,int,double,double);
int(b3CreateMultiBodyBase)(struct b3SharedMemoryCommandHandle__*,double,int,int,const double,const double,const double,const double);
int(b3LoadStateSetFileName)(struct b3SharedMemoryCommandHandle__*,const char*);
int(b3ChangeDynamicsInfoSetJointLimitForce)(struct b3SharedMemoryCommandHandle__*,int,int,double);
int(b3CreateMultiBodyLink)(struct b3SharedMemoryCommandHandle__*,double,double,double,const double,const double,const double,const double,int,int,const double);
struct b3SharedMemoryCommandHandle__*(b3LoadBulletCommandInit)(struct b3PhysicsClientHandle__*,const char*);
int(b3ChangeDynamicsInfoSetDynamicType)(struct b3SharedMemoryCommandHandle__*,int,int,int);
int(b3CreateMultiBodySetBatchPositions)(struct b3PhysicsClientHandle__*,struct b3SharedMemoryCommandHandle__*,double*,int);
struct b3SharedMemoryCommandHandle__*(b3SaveBulletCommandInit)(struct b3PhysicsClientHandle__*,const char*);
int(b3ChangeDynamicsInfoSetSleepThreshold)(struct b3SharedMemoryCommandHandle__*,int,double);
struct b3SharedMemoryCommandHandle__*(b3LoadMJCFCommandInit)(struct b3PhysicsClientHandle__*,const char*);
struct b3SharedMemoryCommandHandle__*(b3LoadMJCFCommandInit2)(struct b3SharedMemoryCommandHandle__*,const char*);
void(b3LoadMJCFCommandSetFlags)(struct b3SharedMemoryCommandHandle__*,int);
int(b3ChangeDynamicsInfoSetSpinningFriction)(struct b3SharedMemoryCommandHandle__*,int,int,double);
void(b3LoadMJCFCommandSetUseMultiBody)(struct b3SharedMemoryCommandHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3CalculateInverseDynamicsCommandInit)(struct b3PhysicsClientHandle__*,int,const double*,const double*,const double*);
int(b3ChangeDynamicsInfoSetRestitution)(struct b3SharedMemoryCommandHandle__*,int,int,double);
struct b3SharedMemoryCommandHandle__*(b3CalculateInverseDynamicsCommandInit2)(struct b3PhysicsClientHandle__*,int,const double*,int,const double*,const double*,int);
int(b3ChangeDynamicsInfoSetLinearDamping)(struct b3SharedMemoryCommandHandle__*,int,double);
void(b3CalculateInverseDynamicsSetFlags)(struct b3SharedMemoryCommandHandle__*,int);
int(b3GetStatusInverseDynamicsJointForces)(struct b3SharedMemoryStatusHandle__*,int*,int*,double*);
int(b3CreateBoxCommandSetCollisionShapeType)(struct b3SharedMemoryCommandHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3CalculateJacobianCommandInit)(struct b3PhysicsClientHandle__*,int,int,const double*,const double*,const double*,const double*);
int(b3CreateBoxCommandSetColorRGBA)(struct b3SharedMemoryCommandHandle__*,double,double,double,double);
int(b3GetStatusJacobian)(struct b3SharedMemoryStatusHandle__*,int*,double*,double*);
struct b3SharedMemoryCommandHandle__*(b3CreatePoseCommandInit)(struct b3PhysicsClientHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3CalculateMassMatrixCommandInit)(struct b3PhysicsClientHandle__*,int,const double*,int);
int(b3CreatePoseCommandSetBasePosition)(struct b3SharedMemoryCommandHandle__*,double,double,double);
void(b3CalculateMassMatrixSetFlags)(struct b3SharedMemoryCommandHandle__*,int);
int(b3CreatePoseCommandSetBaseOrientation)(struct b3SharedMemoryCommandHandle__*,double,double,double,double);
int(b3GetStatusMassMatrix)(struct b3PhysicsClientHandle__*,struct b3SharedMemoryStatusHandle__*,int*,double*);
int(b3ChangeDynamicsInfoSetContactProcessingThreshold)(struct b3SharedMemoryCommandHandle__*,int,int,double);
struct b3SharedMemoryCommandHandle__*(b3CalculateInverseKinematicsCommandInit)(struct b3PhysicsClientHandle__*,int);
int(b3ChangeDynamicsInfoSetActivationState)(struct b3SharedMemoryCommandHandle__*,int,int);
void(b3CalculateInverseKinematicsAddTargetPurePosition)(struct b3SharedMemoryCommandHandle__*,int,const double);
int(b3ChangeDynamicsInfoSetMaxJointVelocity)(struct b3SharedMemoryCommandHandle__*,int,double);
void(b3CalculateInverseKinematicsAddTargetsPurePosition)(struct b3SharedMemoryCommandHandle__*,int,const int*,const double*);
int(b3ChangeDynamicsInfoSetCollisionMargin)(struct b3SharedMemoryCommandHandle__*,int,double);
void(b3CalculateInverseKinematicsAddTargetPositionWithOrientation)(struct b3SharedMemoryCommandHandle__*,int,const double,const double);
struct b3SharedMemoryCommandHandle__*(b3InitCreateUserConstraintCommand)(struct b3PhysicsClientHandle__*,int,int,int,int,struct b3JointInfo*);
void(b3CalculateInverseKinematicsPosWithNullSpaceVel)(struct b3SharedMemoryCommandHandle__*,int,int,const double,const double*,const double*,const double*,const double*);
struct b3SharedMemoryCommandHandle__*(b3InitCreateUserConstraintCommand2)(struct b3SharedMemoryCommandHandle__*,int,int,int,int,struct b3JointInfo*);
void(b3CalculateInverseKinematicsPosOrnWithNullSpaceVel)(struct b3SharedMemoryCommandHandle__*,int,int,const double,const double,const double*,const double*,const double*,const double*);
int(b3GetStatusUserConstraintUniqueId)(struct b3SharedMemoryStatusHandle__*);
void(b3CalculateInverseKinematicsSetJointDamping)(struct b3SharedMemoryCommandHandle__*,int,const double*);
struct b3SharedMemoryCommandHandle__*(b3InitChangeUserConstraintCommand)(struct b3PhysicsClientHandle__*,int);
int(b3CreatePoseCommandSetQdots)(struct b3SharedMemoryCommandHandle__*,int,const double*,const int*);
void(b3CalculateInverseKinematicsSelectSolver)(struct b3SharedMemoryCommandHandle__*,int);
int(b3InitChangeUserConstraintSetPivotInB)(struct b3SharedMemoryCommandHandle__*,const double);
int(b3CreatePoseCommandSetJointVelocities)(struct b3PhysicsClientHandle__*,struct b3SharedMemoryCommandHandle__*,int,const double*);
int(b3GetStatusInverseKinematicsJointPositions)(struct b3SharedMemoryStatusHandle__*,int*,int*,double*);
int(b3InitChangeUserConstraintSetFrameInB)(struct b3SharedMemoryCommandHandle__*,const double);
int(b3CreatePoseCommandSetJointVelocity)(struct b3PhysicsClientHandle__*,struct b3SharedMemoryCommandHandle__*,int,double);
int(b3InitChangeUserConstraintSetMaxForce)(struct b3SharedMemoryCommandHandle__*,double);
int(b3CreatePoseCommandSetJointVelocityMultiDof)(struct b3PhysicsClientHandle__*,struct b3SharedMemoryCommandHandle__*,int,const double*,int);
int(b3InitChangeUserConstraintSetGearRatio)(struct b3SharedMemoryCommandHandle__*,double);
struct b3SharedMemoryCommandHandle__*(b3CreateSensorCommandInit)(struct b3PhysicsClientHandle__*,int);
int(b3InitChangeUserConstraintSetGearAuxLink)(struct b3SharedMemoryCommandHandle__*,int);
int(b3InitChangeUserConstraintSetRelativePositionTarget)(struct b3SharedMemoryCommandHandle__*,double);
int(b3InitChangeUserConstraintSetERP)(struct b3SharedMemoryCommandHandle__*,double);
struct b3SharedMemoryCommandHandle__*(b3InitRemoveUserConstraintCommand)(struct b3PhysicsClientHandle__*,int);
int(b3GetNumUserConstraints)(struct b3PhysicsClientHandle__*);
struct b3SharedMemoryCommandHandle__*(b3InitGetUserConstraintStateCommand)(struct b3PhysicsClientHandle__*,int);
int(b3GetStatusUserConstraintState)(struct b3SharedMemoryStatusHandle__*,struct b3UserConstraintState*);
int(b3GetUserConstraintInfo)(struct b3PhysicsClientHandle__*,int,struct b3UserConstraint*);
void(b3RotateVector)(const double,const double,double);
void(b3CalculateVelocityQuaternion)(const double,const double,double,double);
void(b3GetAxisDifferenceQuaternion)(const double,const double,double);
void(b3GetQuaternionDifference)(const double,const double,double);
void(b3GetAxisAngleFromQuaternion)(const double,double,double*);
void(b3GetQuaternionFromAxisAngle)(const double,double,double);
void(b3QuaternionSlerp)(const double,const double,double,double);
void(b3InvertTransform)(const double,const double,double,double);
void(b3MultiplyTransforms)(const double,const double,const double,const double,double,double);
struct b3SharedMemoryCommandHandle__*(b3SetAdditionalSearchPath)(struct b3PhysicsClientHandle__*,const char*);
double(b3GetTimeOut)(struct b3PhysicsClientHandle__*);
void(b3SetCollisionFilterGroupMask)(struct b3SharedMemoryCommandHandle__*,int,int,int,int);
void(b3PopProfileTiming)(struct b3PhysicsClientHandle__*);
int(b3GetUserConstraintId)(struct b3PhysicsClientHandle__*,int);
void(b3PushProfileTiming)(struct b3PhysicsClientHandle__*,const char*);
struct b3SharedMemoryCommandHandle__*(b3InitRequestDebugLinesCommand)(struct b3PhysicsClientHandle__*,int);
void(b3SetProfileTimingType)(struct b3SharedMemoryCommandHandle__*,int);
void(b3SetProfileTimingDuractionInMicroSeconds)(struct b3SharedMemoryCommandHandle__*,int);
void(b3GetDebugLines)(struct b3PhysicsClientHandle__*,struct b3DebugLines*);
struct b3SharedMemoryCommandHandle__*(b3ProfileTimingCommandInit)(struct b3PhysicsClientHandle__*,const char*);
int(b3StateLoggingStop)(struct b3SharedMemoryCommandHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3InitConfigureOpenGLVisualizer)(struct b3PhysicsClientHandle__*);
int(b3GetStatusLoggingUniqueId)(struct b3SharedMemoryStatusHandle__*);
struct b3SharedMemoryCommandHandle__*(b3InitConfigureOpenGLVisualizer2)(struct b3SharedMemoryCommandHandle__*);
struct b3SharedMemoryCommandHandle__*(b3InitPhysicsParamCommand2)(struct b3SharedMemoryCommandHandle__*);
void(b3ConfigureOpenGLVisualizerSetVisualizationFlags)(struct b3SharedMemoryCommandHandle__*,int,int);
int(b3StateLoggingSetDeviceTypeFilter)(struct b3SharedMemoryCommandHandle__*,int);
int(b3StateLoggingSetBodyBUniqueId)(struct b3SharedMemoryCommandHandle__*,int);
void(b3ConfigureOpenGLVisualizerSetLightPosition)(struct b3SharedMemoryCommandHandle__*,const float);
int(b3StateLoggingSetBodyAUniqueId)(struct b3SharedMemoryCommandHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3RemovePickingConstraint)(struct b3PhysicsClientHandle__*);
void(b3ConfigureOpenGLVisualizerSetShadowMapResolution)(struct b3SharedMemoryCommandHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3CreateRaycastCommandInit)(struct b3PhysicsClientHandle__*,double,double,double,double,double,double);
int(b3StateLoggingSetLinkIndexB)(struct b3SharedMemoryCommandHandle__*,int);
void(b3ConfigureOpenGLVisualizerSetShadowMapIntensity)(struct b3SharedMemoryCommandHandle__*,double);
int(b3StateLoggingSetLinkIndexA)(struct b3SharedMemoryCommandHandle__*,int);
void(b3RaycastBatchSetNumThreads)(struct b3SharedMemoryCommandHandle__*,int);
void(b3ConfigureOpenGLVisualizerSetLightRgbBackground)(struct b3SharedMemoryCommandHandle__*,const float);
int(b3CreateCollisionShapeAddSphere)(struct b3SharedMemoryCommandHandle__*,double);
void(b3RaycastBatchAddRay)(struct b3SharedMemoryCommandHandle__*,const double,const double);
void(b3ConfigureOpenGLVisualizerSetShadowMapWorldSize)(struct b3SharedMemoryCommandHandle__*,int);
int(b3StateLoggingAddLoggingObjectUniqueId)(struct b3SharedMemoryCommandHandle__*,int);
void(b3RaycastBatchAddRays)(struct b3PhysicsClientHandle__*,struct b3SharedMemoryCommandHandle__*,const double*,const double*,int);
void(b3ConfigureOpenGLVisualizerSetRemoteSyncTransformInterval)(struct b3SharedMemoryCommandHandle__*,double);
int(b3CreateCollisionShapeAddCylinder)(struct b3SharedMemoryCommandHandle__*,double,double);
void(b3RaycastBatchSetParentObject)(struct b3SharedMemoryCommandHandle__*,int,int);
void(b3ConfigureOpenGLVisualizerSetViewMatrix)(struct b3SharedMemoryCommandHandle__*,float,float,float,const float);
void(b3CreateCollisionShapeSetChildTransform)(struct b3SharedMemoryCommandHandle__*,int,const double,const double);
struct b3SharedMemoryCommandHandle__*(b3RequestActualStateCommandInit2)(struct b3SharedMemoryCommandHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3InitRequestOpenGLVisualizerCameraCommand)(struct b3PhysicsClientHandle__*);
int(b3RequestActualStateCommandComputeLinkVelocity)(struct b3SharedMemoryCommandHandle__*,int);
int(b3GetStatusOpenGLVisualizerCamera)(struct b3SharedMemoryStatusHandle__*,struct b3OpenGLVisualizerCameraInfo*);
struct b3SharedMemoryCommandHandle__*(b3InitRemoveCollisionShapeCommand)(struct b3PhysicsClientHandle__*,int);
int(b3RequestActualStateCommandComputeForwardKinematics)(struct b3SharedMemoryCommandHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3InitUserDebugDrawAddLine3D)(struct b3PhysicsClientHandle__*,const double,const double,const double,double,double);
struct b3SharedMemoryCommandHandle__*(b3RequestMouseEventsCommandInit)(struct b3PhysicsClientHandle__*);
int(b3GetJointState)(struct b3PhysicsClientHandle__*,struct b3SharedMemoryStatusHandle__*,int,struct b3JointSensorState*);
struct b3SharedMemoryCommandHandle__*(b3InitUserDebugDrawAddPoints3D)(struct b3PhysicsClientHandle__*,const double,const double,double,double,int);
void(b3GetKeyboardEventsData)(struct b3PhysicsClientHandle__*,struct b3KeyboardEventsData*);
int(b3GetJointStateMultiDof)(struct b3PhysicsClientHandle__*,struct b3SharedMemoryStatusHandle__*,int,struct b3JointSensorState2*);
struct b3SharedMemoryCommandHandle__*(b3InitUserDebugDrawAddText3D)(struct b3PhysicsClientHandle__*,const char*,const double,const double,double,double);
struct b3SharedMemoryCommandHandle__*(b3RequestKeyboardEventsCommandInit2)(struct b3SharedMemoryCommandHandle__*);
int(b3GetLinkState)(struct b3PhysicsClientHandle__*,struct b3SharedMemoryStatusHandle__*,int,struct b3LinkState*);
void(b3UserDebugTextSetOptionFlags)(struct b3SharedMemoryCommandHandle__*,int);
int(b3CreateVisualShapeAddSphere)(struct b3SharedMemoryCommandHandle__*,double);
int(b3CreateVisualShapeAddCapsule)(struct b3SharedMemoryCommandHandle__*,double,double);
void(b3UserDebugTextSetOrientation)(struct b3SharedMemoryCommandHandle__*,const double);
int(b3CreateVisualShapeAddMesh)(struct b3SharedMemoryCommandHandle__*,const char*,const double);
void(b3CreateVisualShapeSetSpecularColor)(struct b3SharedMemoryCommandHandle__*,int,const double);
void(b3UserDebugItemSetReplaceItemUniqueId)(struct b3SharedMemoryCommandHandle__*,int);
int(b3GetStatusVisualShapeUniqueId)(struct b3SharedMemoryStatusHandle__*);
struct b3SharedMemoryCommandHandle__*(b3CreateMultiBodyCommandInit)(struct b3PhysicsClientHandle__*);
void(b3UserDebugItemSetParentObject)(struct b3SharedMemoryCommandHandle__*,int,int);
void(b3CreateMultiBodySetFlags)(struct b3SharedMemoryCommandHandle__*,int);
int(b3CreateBoxCommandSetStartPosition)(struct b3SharedMemoryCommandHandle__*,double,double,double);
struct b3SharedMemoryCommandHandle__*(b3InitUserDebugAddParameter)(struct b3PhysicsClientHandle__*,const char*,double,double,double);
struct b3SharedMemoryCommandHandle__*(b3RequestVREventsCommandInit)(struct b3PhysicsClientHandle__*);
struct b3SharedMemoryCommandHandle__*(b3InitCreateSoftBodyAnchorConstraintCommand)(struct b3PhysicsClientHandle__*,int,int,int,int,const double);
struct b3SharedMemoryCommandHandle__*(b3InitUserDebugReadParameter)(struct b3PhysicsClientHandle__*,int);
int(b3CreatePoseCommandSetBaseLinearVelocity)(struct b3SharedMemoryCommandHandle__*,const double);
int(b3CreatePoseCommandSetBaseScaling)(struct b3SharedMemoryCommandHandle__*,double);
int(b3GetStatusDebugParameterValue)(struct b3SharedMemoryStatusHandle__*,double*);
int(b3CreatePoseCommandSetJointPosition)(struct b3PhysicsClientHandle__*,struct b3SharedMemoryCommandHandle__*,int,double);
int(b3CreatePoseCommandSetQ)(struct b3SharedMemoryCommandHandle__*,int,const double*,const int*);
struct b3SharedMemoryCommandHandle__*(b3InitUserDebugDrawRemove)(struct b3PhysicsClientHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3RequestActualStateCommandInit)(struct b3PhysicsClientHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3InitUserDebugDrawRemoveAll)(struct b3PhysicsClientHandle__*);
void(b3ApplyExternalTorque)(struct b3SharedMemoryCommandHandle__*,int,int,const double,int);
struct b3SharedMemoryCommandHandle__*(b3InitUserRemoveAllParameters)(struct b3PhysicsClientHandle__*);
struct b3SharedMemoryCommandHandle__*(b3MovePickedBody)(struct b3PhysicsClientHandle__*,double,double,double,double,double,double);
struct b3SharedMemoryCommandHandle__*(b3InitDebugDrawingCommand)(struct b3PhysicsClientHandle__*);
void(b3RaycastBatchSetReportHitNumber)(struct b3SharedMemoryCommandHandle__*,int);
void(b3SetDebugObjectColor)(struct b3SharedMemoryCommandHandle__*,int,int,const double);
void(b3RaycastBatchSetFractionEpsilon)(struct b3SharedMemoryCommandHandle__*,double);
struct b3SharedMemoryCommandHandle__*(b3ApplyExternalForceCommandInit)(struct b3PhysicsClientHandle__*);
void(b3RemoveDebugObjectColor)(struct b3SharedMemoryCommandHandle__*,int,int);
struct b3SharedMemoryCommandHandle__*(b3LoadSoftBodyCommandInit)(struct b3PhysicsClientHandle__*,const char*);
int(b3GetDebugItemUniqueId)(struct b3SharedMemoryStatusHandle__*);
int(b3LoadSoftBodySetMass)(struct b3SharedMemoryCommandHandle__*,double);
struct b3SharedMemoryCommandHandle__*(b3InitRequestCameraImage)(struct b3PhysicsClientHandle__*);
int(b3LoadSoftBodySetStartPosition)(struct b3SharedMemoryCommandHandle__*,double,double,double);
struct b3SharedMemoryCommandHandle__*(b3InitRequestCameraImage2)(struct b3SharedMemoryCommandHandle__*);
int(b3LoadSoftBodySetStartOrientation)(struct b3SharedMemoryCommandHandle__*,double,double,double,double);
void(b3RequestCameraImageSetCameraMatrices)(struct b3SharedMemoryCommandHandle__*,float,float);
int(b3LoadSoftBodyUpdateSimMesh)(struct b3SharedMemoryCommandHandle__*,const char*);
int(b3LoadSoftBodySetCollisionMargin)(struct b3SharedMemoryCommandHandle__*,double);
void(b3RequestCameraImageSetPixelResolution)(struct b3SharedMemoryCommandHandle__*,int,int);
int(b3LoadSoftBodyAddCorotatedForce)(struct b3SharedMemoryCommandHandle__*,double,double);
int(b3LoadSoftBodySetScale)(struct b3SharedMemoryCommandHandle__*,double);
void(b3RequestCameraImageSetLightDirection)(struct b3SharedMemoryCommandHandle__*,const float);
int(b3LoadSoftBodyAddNeoHookeanForce)(struct b3SharedMemoryCommandHandle__*,double,double,double);
void(b3ApplyExternalForce)(struct b3SharedMemoryCommandHandle__*,int,int,const double,const double,int);
void(b3RequestCameraImageSetLightColor)(struct b3SharedMemoryCommandHandle__*,const float);
int(b3LoadSoftBodyAddMassSpringForce)(struct b3SharedMemoryCommandHandle__*,double,double);
void(b3GetRaycastInformation)(struct b3PhysicsClientHandle__*,struct b3RaycastInformation*);
void(b3RequestCameraImageSetLightDistance)(struct b3SharedMemoryCommandHandle__*,float);
int(b3LoadSoftBodyAddGravityForce)(struct b3SharedMemoryCommandHandle__*,double,double,double);
void(b3RaycastBatchSetCollisionFilterMask)(struct b3SharedMemoryCommandHandle__*,int);
void(b3RequestCameraImageSetLightAmbientCoeff)(struct b3SharedMemoryCommandHandle__*,float);
int(b3LoadSoftBodySetCollisionHardness)(struct b3SharedMemoryCommandHandle__*,double);
struct b3SharedMemoryCommandHandle__*(b3CreateRaycastBatchCommandInit)(struct b3PhysicsClientHandle__*);
void(b3RequestCameraImageSetLightDiffuseCoeff)(struct b3SharedMemoryCommandHandle__*,float);
int(b3LoadSoftBodySetSelfCollision)(struct b3SharedMemoryCommandHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3PickBody)(struct b3PhysicsClientHandle__*,double,double,double,double,double,double);
void(b3RequestCameraImageSetLightSpecularCoeff)(struct b3SharedMemoryCommandHandle__*,float);
int(b3LoadSoftBodySetRepulsionStiffness)(struct b3SharedMemoryCommandHandle__*,double);
int(b3CreateSensorEnableIMUForLink)(struct b3SharedMemoryCommandHandle__*,int,int);
void(b3RequestCameraImageSetShadow)(struct b3SharedMemoryCommandHandle__*,int);
int(b3CreateSensorEnable6DofJointForceTorqueSensor)(struct b3SharedMemoryCommandHandle__*,int,int);
int(b3LoadSoftBodyUseFaceContact)(struct b3SharedMemoryCommandHandle__*,int);
void(b3RequestCameraImageSelectRenderer)(struct b3SharedMemoryCommandHandle__*,int);
int(b3CreatePoseCommandSetJointPositionMultiDof)(struct b3PhysicsClientHandle__*,struct b3SharedMemoryCommandHandle__*,int,const double*,int);
int(b3LoadSoftBodySetFrictionCoefficient)(struct b3SharedMemoryCommandHandle__*,double);
void(b3RequestCameraImageSetFlags)(struct b3SharedMemoryCommandHandle__*,int);
int(b3CreatePoseCommandSetJointPositions)(struct b3SharedMemoryCommandHandle__*,int,const double*);
int(b3LoadSoftBodyUseBendingSprings)(struct b3SharedMemoryCommandHandle__*,int,double);
void(b3GetCameraImageData)(struct b3PhysicsClientHandle__*,struct b3CameraImageData*);
int(b3CreatePoseCommandSetBaseAngularVelocity)(struct b3SharedMemoryCommandHandle__*,const double);
int(b3LoadSoftBodyUseAllDirectionDampingSprings)(struct b3SharedMemoryCommandHandle__*,int);
void(b3RequestCameraImageSetProjectiveTextureMatrices)(struct b3SharedMemoryCommandHandle__*,float,float);
struct b3SharedMemoryCommandHandle__*(b3CreatePoseCommandInit2)(struct b3SharedMemoryCommandHandle__*,int);
void(b3ComputeViewMatrixFromPositions)(const float,const float,const float,float);
int(b3CreateBoxCommandSetMass)(struct b3SharedMemoryCommandHandle__*,double);
int(b3CreateBoxCommandSetHalfExtents)(struct b3SharedMemoryCommandHandle__*,double,double,double);
void(b3ComputeViewMatrixFromYawPitchRoll)(const float,float,float,float,float,int,float);
int(b3CreateBoxCommandSetStartOrientation)(struct b3SharedMemoryCommandHandle__*,double,double,double,double);
void(b3VREventsSetDeviceTypeFilter)(struct b3SharedMemoryCommandHandle__*,int);
void(b3ComputePositionFromViewMatrix)(const float,float,float,float);
struct b3SharedMemoryCommandHandle__*(b3CreateBoxShapeCommandInit)(struct b3PhysicsClientHandle__*);
void(b3GetVREventsData)(struct b3PhysicsClientHandle__*,struct b3VREventsData*);
void(b3ComputeProjectionMatrix)(float,float,float,float,float,float,float);
void(b3CreateMultiBodyUseMaximalCoordinates)(struct b3SharedMemoryCommandHandle__*);
struct b3SharedMemoryCommandHandle__*(b3SetVRCameraStateCommandInit)(struct b3PhysicsClientHandle__*);
void(b3ComputeProjectionMatrixFOV)(float,float,float,float,float);
int(b3SetVRCameraRootPosition)(struct b3SharedMemoryCommandHandle__*,const double);
void(b3CreateVisualShapeSetRGBAColor)(struct b3SharedMemoryCommandHandle__*,int,const double);
void(b3RequestCameraImageSetViewMatrix)(struct b3SharedMemoryCommandHandle__*,const float,const float,const float);
int(b3SetVRCameraRootOrientation)(struct b3SharedMemoryCommandHandle__*,const double);
void(b3CreateVisualSetFlag)(struct b3SharedMemoryCommandHandle__*,int,int);
void(b3RequestCameraImageSetViewMatrix2)(struct b3SharedMemoryCommandHandle__*,const float,float,float,float,float,int);
int(b3SetVRCameraTrackingObject)(struct b3SharedMemoryCommandHandle__*,int);
int(b3CreateVisualShapeAddPlane)(struct b3SharedMemoryCommandHandle__*,const double,double);
void(b3RequestCameraImageSetProjectionMatrix)(struct b3SharedMemoryCommandHandle__*,float,float,float,float,float,float);
int(b3SetVRCameraTrackingObjectFlag)(struct b3SharedMemoryCommandHandle__*,int);
int(b3CreateVisualShapeAddBox)(struct b3SharedMemoryCommandHandle__*,const double);
void(b3RequestCameraImageSetFOVProjectionMatrix)(struct b3SharedMemoryCommandHandle__*,float,float,float,float);
struct b3SharedMemoryCommandHandle__*(b3RequestKeyboardEventsCommandInit)(struct b3PhysicsClientHandle__*);
struct b3SharedMemoryCommandHandle__*(b3CreateVisualShapeCommandInit)(struct b3PhysicsClientHandle__*);
struct b3SharedMemoryCommandHandle__*(b3InitRequestContactPointInformation)(struct b3PhysicsClientHandle__*);
struct b3SharedMemoryCommandHandle__*(b3ResetMeshDataCommandInit)(struct b3PhysicsClientHandle__*,int,int,const double*);
void(b3SetContactFilterBodyA)(struct b3SharedMemoryCommandHandle__*,int);
void(b3GetMeshData)(struct b3PhysicsClientHandle__*,struct b3MeshData*);
void(b3GetMeshDataSimulationMesh)(struct b3SharedMemoryCommandHandle__*);
void(b3SetContactFilterBodyB)(struct b3SharedMemoryCommandHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3GetMeshDataCommandInit)(struct b3PhysicsClientHandle__*,int,int);
void(b3GetMouseEventsData)(struct b3PhysicsClientHandle__*,struct b3MouseEventsData*);
void(b3SetContactFilterLinkA)(struct b3SharedMemoryCommandHandle__*,int);
int(b3GetStatusCollisionShapeUniqueId)(struct b3SharedMemoryStatusHandle__*);
struct b3SharedMemoryCommandHandle__*(b3StateLoggingCommandInit)(struct b3PhysicsClientHandle__*);
void(b3SetContactFilterLinkB)(struct b3SharedMemoryCommandHandle__*,int);
int(b3StateLoggingStart)(struct b3SharedMemoryCommandHandle__*,int,const char*);
int(b3CreateCollisionShapeAddCapsule)(struct b3SharedMemoryCommandHandle__*,double,double);
void(b3GetContactPointInformation)(struct b3PhysicsClientHandle__*,struct b3ContactInformation*);
struct b3PhysicsClientHandle__*(b3ConnectSharedMemory)(int);
int(b3CreateCollisionShapeAddBox)(struct b3SharedMemoryCommandHandle__*,const double);
int(b3StateLoggingSetMaxLogDof)(struct b3SharedMemoryCommandHandle__*,int);
struct b3PhysicsClientHandle__*(b3ConnectSharedMemory2)(int);
int(b3ChangeDynamicsInfoSetFrictionAnchor)(struct b3SharedMemoryCommandHandle__*,int,int,int);
struct b3PhysicsClientHandle__*(b3ConnectPhysicsDirect)();
struct b3SharedMemoryCommandHandle__*(b3InitRemoveUserDataCommand)(struct b3PhysicsClientHandle__*,int);
void(b3SetClosestDistanceFilterLinkA)(struct b3SharedMemoryCommandHandle__*,int);
int(b3PhysicsParamSetInternalSimFlags)(struct b3SharedMemoryCommandHandle__*,int);
void(b3DisconnectSharedMemory)(struct b3PhysicsClientHandle__*);
int(b3JointControlSetDamping)(struct b3SharedMemoryCommandHandle__*,int,double);
void(b3SetClosestDistanceFilterLinkB)(struct b3SharedMemoryCommandHandle__*,int);
int(b3CanSubmitCommand)(struct b3PhysicsClientHandle__*);
void(b3SetClosestDistanceThreshold)(struct b3SharedMemoryCommandHandle__*,double);
int(b3JointControlSetDesiredForceTorqueMultiDof)(struct b3SharedMemoryCommandHandle__*,int,double*,int);
struct b3SharedMemoryStatusHandle__*(b3SubmitClientCommandAndWaitStatus)(struct b3PhysicsClientHandle__*,struct b3SharedMemoryCommandHandle__*);
void(b3SetClosestDistanceFilterCollisionShapeA)(struct b3SharedMemoryCommandHandle__*,int);
int(b3StateLoggingSetLogFlags)(struct b3SharedMemoryCommandHandle__*,int);
int(b3SubmitClientCommand)(struct b3PhysicsClientHandle__*,struct b3SharedMemoryCommandHandle__*);
void(b3SetClosestDistanceFilterCollisionShapeB)(struct b3SharedMemoryCommandHandle__*,int);
struct b3SharedMemoryStatusHandle__*(b3ProcessServerStatus)(struct b3PhysicsClientHandle__*);
struct b3SharedMemoryCommandHandle__*(b3InitPhysicsParamCommand)(struct b3PhysicsClientHandle__*);
int(b3GetStatusType)(struct b3SharedMemoryStatusHandle__*);
void(b3UpdateVisualShapeSpecularColor)(struct b3SharedMemoryCommandHandle__*,const double);
int(b3JointControlSetDesiredVelocity)(struct b3SharedMemoryCommandHandle__*,int,double);
void(b3SetClosestDistanceFilterCollisionShapePositionB)(struct b3SharedMemoryCommandHandle__*,const double);
struct b3SharedMemoryCommandHandle__*(b3CreateCustomCommand)(struct b3PhysicsClientHandle__*);
int(b3JointControlSetMaximumVelocity)(struct b3SharedMemoryCommandHandle__*,int,double);
void(b3CustomCommandLoadPlugin)(struct b3SharedMemoryCommandHandle__*,const char*);
struct b3SharedMemoryCommandHandle__*(b3InitClosestDistanceQuery)(struct b3PhysicsClientHandle__*);
int(b3JointControlSetKd)(struct b3SharedMemoryCommandHandle__*,int,double);
void(b3CustomCommandLoadPluginSetPostFix)(struct b3SharedMemoryCommandHandle__*,const char*);
int(b3JointControlSetKpMultiDof)(struct b3SharedMemoryCommandHandle__*,int,double*,int);
int(b3JointControlSetKp)(struct b3SharedMemoryCommandHandle__*,int,double);
int(b3GetStatusPluginUniqueId)(struct b3SharedMemoryStatusHandle__*);
struct b3SharedMemoryCommandHandle__*(b3CollisionFilterCommandInit)(struct b3PhysicsClientHandle__*);
int(b3GetStatusPluginCommandResult)(struct b3SharedMemoryStatusHandle__*);
struct b3SharedMemoryCommandHandle__*(b3InitAABBOverlapQuery)(struct b3PhysicsClientHandle__*,const double,const double);
int(b3GetStatusPluginCommandReturnData)(struct b3PhysicsClientHandle__*,struct b3UserDataValue*);
void(b3SetTimeOut)(struct b3PhysicsClientHandle__*,double);
void(b3GetAABBOverlapResults)(struct b3PhysicsClientHandle__*,struct b3AABBOverlapData*);
void(b3CustomCommandUnloadPlugin)(struct b3SharedMemoryCommandHandle__*,int);
void(b3CalculateInverseKinematicsSetCurrentPositions)(struct b3SharedMemoryCommandHandle__*,int,const double*);
struct b3SharedMemoryCommandHandle__*(b3InitRequestVisualShapeInformation)(struct b3PhysicsClientHandle__*,int);
void(b3CustomCommandExecutePluginCommand)(struct b3SharedMemoryCommandHandle__*,int,const char*);
void(b3UpdateVisualShapeTexture)(struct b3SharedMemoryCommandHandle__*,int);
void(b3GetVisualShapeInformation)(struct b3PhysicsClientHandle__*,struct b3VisualShapeInformation*);
void(b3CustomCommandExecuteAddIntArgument)(struct b3SharedMemoryCommandHandle__*,int);
void(b3UpdateVisualShapeRGBAColor)(struct b3SharedMemoryCommandHandle__*,const double);
struct b3SharedMemoryCommandHandle__*(b3InitRequestCollisionShapeInformation)(struct b3PhysicsClientHandle__*,int,int);
void(b3CustomCommandExecuteAddFloatArgument)(struct b3SharedMemoryCommandHandle__*,float);
void(b3GetCollisionShapeInformation)(struct b3PhysicsClientHandle__*,struct b3CollisionShapeInformation*);
struct b3SharedMemoryCommandHandle__*(b3JointControlCommandInit2Internal)(struct b3SharedMemoryCommandHandle__*,int,int);
int(b3GetStatusBodyIndices)(struct b3SharedMemoryStatusHandle__*,int*,int);
struct b3SharedMemoryCommandHandle__*(b3InitLoadTexture)(struct b3PhysicsClientHandle__*,const char*);
int(b3LoadSdfCommandSetUseMultiBody)(struct b3SharedMemoryCommandHandle__*,int);
int(b3GetStatusBodyIndex)(struct b3SharedMemoryStatusHandle__*);
int(b3GetStatusTextureUniqueId)(struct b3SharedMemoryStatusHandle__*);
int(b3GetStatusActualState)(struct b3SharedMemoryStatusHandle__*,int*,int*,int*,const double*rootLocalInertialFrame,const double*actualStateQ,const double*actualStateQdot,const double*jointReactionForces);
struct b3SharedMemoryCommandHandle__*(b3CreateChangeTextureCommandInit)(struct b3PhysicsClientHandle__*,int,int,int,const char*);
int(b3PhysicsParamSetGravity)(struct b3SharedMemoryCommandHandle__*,double,double,double);
int(b3GetStatusActualState2)(struct b3SharedMemoryStatusHandle__*,int*,int*,int*,int*,const double*rootLocalInertialFrame,const double*actualStateQ,const double*actualStateQdot,const double*jointReactionForces,const double*linkLocalInertialFrames,const double*jointMotorForces,const double*linkStates,const double*linkWorldVelocities);
struct b3SharedMemoryCommandHandle__*(b3InitUpdateVisualShape)(struct b3PhysicsClientHandle__*,int,int,int,int);
int(b3PhysicsParamSetTimeStep)(struct b3SharedMemoryCommandHandle__*,double);
struct b3SharedMemoryCommandHandle__*(b3JointControlCommandInit)(struct b3PhysicsClientHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3RequestCollisionInfoCommandInit)(struct b3PhysicsClientHandle__*,int);
int(b3PhysicsParamSetDefaultContactERP)(struct b3SharedMemoryCommandHandle__*,double);
int(b3LoadSdfCommandSetUseGlobalScaling)(struct b3SharedMemoryCommandHandle__*,double);
int(b3GetStatusAABB)(struct b3SharedMemoryStatusHandle__*,int,double,double);
int(b3PhysicsParamSetDefaultNonContactERP)(struct b3SharedMemoryCommandHandle__*,double);
struct b3SharedMemoryCommandHandle__*(b3SaveWorldCommandInit)(struct b3PhysicsClientHandle__*,const char*);
struct b3SharedMemoryCommandHandle__*(b3InitSyncBodyInfoCommand)(struct b3PhysicsClientHandle__*);
int(b3PhysicsParamSetDefaultFrictionERP)(struct b3SharedMemoryCommandHandle__*,double);
struct b3SharedMemoryCommandHandle__*(b3InitRequestBodyInfoCommand)(struct b3PhysicsClientHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3JointControlCommandInit2)(struct b3PhysicsClientHandle__*,int,int);
int(b3PhysicsParamSetDefaultGlobalCFM)(struct b3SharedMemoryCommandHandle__*,double);
struct b3SharedMemoryCommandHandle__*(b3LoadSdfCommandInit2)(struct b3SharedMemoryCommandHandle__*,const char*);
int(b3GetNumBodies)(struct b3PhysicsClientHandle__*);
int(b3PhysicsParamSetDefaultFrictionCFM)(struct b3SharedMemoryCommandHandle__*,double);
struct b3SharedMemoryCommandHandle__*(b3LoadSdfCommandInit)(struct b3PhysicsClientHandle__*,const char*);
int(b3JointControlSetDesiredPosition)(struct b3SharedMemoryCommandHandle__*,int,double);
int(b3PhysicsParamSetNumSubSteps)(struct b3SharedMemoryCommandHandle__*,int);
void(b3SetCollisionFilterPair)(struct b3SharedMemoryCommandHandle__*,int,int,int,int,int);
int(b3JointControlSetDesiredPositionMultiDof)(struct b3SharedMemoryCommandHandle__*,int,const double*,int);
int(b3PhysicsParamSetRealTimeSimulation)(struct b3SharedMemoryCommandHandle__*,int);
void(b3CalculateInverseKinematicsSetResidualThreshold)(struct b3SharedMemoryCommandHandle__*,double);
void(b3CalculateInverseKinematicsSetMaxNumIterations)(struct b3SharedMemoryCommandHandle__*,int);
int(b3PhysicsParamSetNumSolverIterations)(struct b3SharedMemoryCommandHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3LoadStateCommandInit)(struct b3PhysicsClientHandle__*);
int(b3GetUserDataIdFromStatus)(struct b3SharedMemoryStatusHandle__*);
int(b3PhysicsParamSetNumNonContactInnerIterations)(struct b3SharedMemoryCommandHandle__*,int);
int(b3GetStatusForwardDynamicsAnalyticsData)(struct b3SharedMemoryStatusHandle__*,struct b3ForwardDynamicsAnalyticsArgs*);
int(b3GetJointInfo)(struct b3PhysicsClientHandle__*,int,int,struct b3JointInfo*);
int(b3PhysicsParamSetWarmStartingFactor)(struct b3SharedMemoryCommandHandle__*,double);
int(b3GetUserDataId)(struct b3PhysicsClientHandle__*,int,int,int,const char*);
int(b3JointControlSetKdMultiDof)(struct b3SharedMemoryCommandHandle__*,int,double*,int);
int(b3PhysicsParamSetArticulatedWarmStartingFactor)(struct b3SharedMemoryCommandHandle__*,double);
void(b3SetClosestDistanceFilterBodyB)(struct b3SharedMemoryCommandHandle__*,int);
int(b3PhysicsParamSetCollisionFilterMode)(struct b3SharedMemoryCommandHandle__*,int);
void(b3SetClosestDistanceFilterCollisionShapeOrientationA)(struct b3SharedMemoryCommandHandle__*,const double);
void(b3GetClosestPointInformation)(struct b3PhysicsClientHandle__*,struct b3ContactInformation*);
int(b3PhysicsParamSetUseSplitImpulse)(struct b3SharedMemoryCommandHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3InitUpdateVisualShape2)(struct b3PhysicsClientHandle__*,int,int,int);
int(b3JointControlSetDesiredVelocityMultiDof)(struct b3SharedMemoryCommandHandle__*,int,const double*,int);
int(b3PhysicsParamSetSplitImpulsePenetrationThreshold)(struct b3SharedMemoryCommandHandle__*,double);
struct b3SharedMemoryCommandHandle__*(b3InitRemoveBodyCommand)(struct b3PhysicsClientHandle__*,int);
int(b3JointControlSetDesiredVelocityMultiDof2)(struct b3SharedMemoryCommandHandle__*,int,const double*,int);
int(b3PhysicsParamSetContactBreakingThreshold)(struct b3SharedMemoryCommandHandle__*,double);
int(b3JointControlSetMaximumForce)(struct b3SharedMemoryCommandHandle__*,int,double);
void(b3UpdateVisualShapeFlags)(struct b3SharedMemoryCommandHandle__*,int);
int(b3PhysicsParamSetMaxNumCommandsPer1ms)(struct b3SharedMemoryCommandHandle__*,int);
void(b3SetClosestDistanceFilterCollisionShapeOrientationB)(struct b3SharedMemoryCommandHandle__*,const double);
void(b3SetClosestDistanceFilterCollisionShapePositionA)(struct b3SharedMemoryCommandHandle__*,const double);
int(b3PhysicsParamSetEnableFileCaching)(struct b3SharedMemoryCommandHandle__*,int);
void(b3SetClosestDistanceFilterBodyA)(struct b3SharedMemoryCommandHandle__*,int);
int(b3JointControlSetDampingMultiDof)(struct b3SharedMemoryCommandHandle__*,int,double*,int);
int(b3PhysicsParamSetRestitutionVelocityThreshold)(struct b3SharedMemoryCommandHandle__*,double);
int(b3ChangeDynamicsInfoSetCcdSweptSphereRadius)(struct b3SharedMemoryCommandHandle__*,int,int,double);
int(b3JointControlSetDesiredForceTorque)(struct b3SharedMemoryCommandHandle__*,int,double);
int(b3PhysicsParamSetEnableConeFriction)(struct b3SharedMemoryCommandHandle__*,int);
struct b3SharedMemoryCommandHandle__*(b3CreateCollisionShapeCommandInit)(struct b3PhysicsClientHandle__*);
int(b3ChangeDynamicsInfoSetContactStiffnessAndDamping)(struct b3SharedMemoryCommandHandle__*,int,int,double,double);
int(b3PhysicsParameterSetDeterministicOverlappingPairs)(struct b3SharedMemoryCommandHandle__*,int);
int(b3ChangeDynamicsInfoSetJointDamping)(struct b3SharedMemoryCommandHandle__*,int,int,double);
int(b3ChangeDynamicsInfoSetAngularDamping)(struct b3SharedMemoryCommandHandle__*,int,double);
int(b3PhysicsParameterSetAllowedCcdPenetration)(struct b3SharedMemoryCommandHandle__*,double);
int(b3ChangeDynamicsInfoSetRollingFriction)(struct b3SharedMemoryCommandHandle__*,int,int,double);
int(b3ChangeDynamicsInfoSetLateralFriction)(struct b3SharedMemoryCommandHandle__*,int,int,double);
int(b3PhysicsParameterSetJointFeedbackMode)(struct b3SharedMemoryCommandHandle__*,int);
]])
local library = {}


--====helper safe_clib_index====
		function SAFE_INDEX(clib)
			return setmetatable({}, {__index = function(_, k)
				local ok, val = pcall(function() return clib[k] end)
				if ok then
					return val
				elseif clib_index then
					return clib_index(k)
				end
			end})
		end
	
--====helper safe_clib_index====

CLIB = SAFE_INDEX(CLIB)library = {
	PhysicsParamSetSolverResidualThreshold = CLIB.b3PhysicsParamSetSolverResidualThreshold,
	CreateCollisionShapeAddHeightfield = CLIB.b3CreateCollisionShapeAddHeightfield,
	PhysicsParamSetContactSlop = CLIB.b3PhysicsParamSetContactSlop,
	CreateCollisionShapeAddHeightfield2 = CLIB.b3CreateCollisionShapeAddHeightfield2,
	PhysicsParameterSetEnableSAT = CLIB.b3PhysicsParameterSetEnableSAT,
	CreateCollisionShapeAddPlane = CLIB.b3CreateCollisionShapeAddPlane,
	PhysicsParameterSetConstraintSolverType = CLIB.b3PhysicsParameterSetConstraintSolverType,
	CreateCollisionShapeAddMesh = CLIB.b3CreateCollisionShapeAddMesh,
	PhysicsParameterSetMinimumSolverIslandSize = CLIB.b3PhysicsParameterSetMinimumSolverIslandSize,
	CreateCollisionShapeAddConvexMesh = CLIB.b3CreateCollisionShapeAddConvexMesh,
	PhysicsParamSetSolverAnalytics = CLIB.b3PhysicsParamSetSolverAnalytics,
	GetBodyUniqueId = CLIB.b3GetBodyUniqueId,
	CreateCollisionShapeAddConcaveMesh = CLIB.b3CreateCollisionShapeAddConcaveMesh,
	PhysicsParameterSetSparseSdfVoxelSize = CLIB.b3PhysicsParameterSetSparseSdfVoxelSize,
	GetBodyInfo = CLIB.b3GetBodyInfo,
	CreateCollisionSetFlag = CLIB.b3CreateCollisionSetFlag,
	InitRequestPhysicsParamCommand = CLIB.b3InitRequestPhysicsParamCommand,
	GetNumJoints = CLIB.b3GetNumJoints,
	GetStatusPhysicsSimulationParameters = CLIB.b3GetStatusPhysicsSimulationParameters,
	GetNumDofs = CLIB.b3GetNumDofs,
	ComputeDofCount = CLIB.b3ComputeDofCount,
	InitStepSimulationCommand = CLIB.b3InitStepSimulationCommand,
	InitStepSimulationCommand2 = CLIB.b3InitStepSimulationCommand2,
	InitSyncUserDataCommand = CLIB.b3InitSyncUserDataCommand,
	InitPerformCollisionDetectionCommand = CLIB.b3InitPerformCollisionDetectionCommand,
	AddBodyToSyncUserDataRequest = CLIB.b3AddBodyToSyncUserDataRequest,
	MeshDataSimulationMeshVelocity = CLIB.b3MeshDataSimulationMeshVelocity,
	InitAddUserDataCommand = CLIB.b3InitAddUserDataCommand,
	GetMeshDataSetCollisionShapeIndex = CLIB.b3GetMeshDataSetCollisionShapeIndex,
	InitResetSimulationCommand = CLIB.b3InitResetSimulationCommand,
	GetMeshDataSetFlags = CLIB.b3GetMeshDataSetFlags,
	InitResetSimulationCommand2 = CLIB.b3InitResetSimulationCommand2,
	GetUserData = CLIB.b3GetUserData,
	InitResetSimulationSetFlags = CLIB.b3InitResetSimulationSetFlags,
	LoadUrdfCommandInit = CLIB.b3LoadUrdfCommandInit,
	LoadUrdfCommandInit2 = CLIB.b3LoadUrdfCommandInit2,
	GetNumUserData = CLIB.b3GetNumUserData,
	LoadUrdfCommandSetStartPosition = CLIB.b3LoadUrdfCommandSetStartPosition,
	GetUserDataInfo = CLIB.b3GetUserDataInfo,
	LoadUrdfCommandSetStartOrientation = CLIB.b3LoadUrdfCommandSetStartOrientation,
	GetDynamicsInfoCommandInit = CLIB.b3GetDynamicsInfoCommandInit,
	CreateVisualShapeAddCylinder = CLIB.b3CreateVisualShapeAddCylinder,
	LoadUrdfCommandSetUseMultiBody = CLIB.b3LoadUrdfCommandSetUseMultiBody,
	GetDynamicsInfoCommandInit2 = CLIB.b3GetDynamicsInfoCommandInit2,
	LoadUrdfCommandSetUseFixedBase = CLIB.b3LoadUrdfCommandSetUseFixedBase,
	GetDynamicsInfo = CLIB.b3GetDynamicsInfo,
	CreateVisualShapeAddMesh2 = CLIB.b3CreateVisualShapeAddMesh2,
	LoadUrdfCommandSetFlags = CLIB.b3LoadUrdfCommandSetFlags,
	InitChangeDynamicsInfo = CLIB.b3InitChangeDynamicsInfo,
	LoadUrdfCommandSetGlobalScaling = CLIB.b3LoadUrdfCommandSetGlobalScaling,
	InitChangeDynamicsInfo2 = CLIB.b3InitChangeDynamicsInfo2,
	CreateVisualShapeSetChildTransform = CLIB.b3CreateVisualShapeSetChildTransform,
	SaveStateCommandInit = CLIB.b3SaveStateCommandInit,
	ChangeDynamicsInfoSetMass = CLIB.b3ChangeDynamicsInfoSetMass,
	InitRemoveStateCommand = CLIB.b3InitRemoveStateCommand,
	ChangeDynamicsInfoSetLocalInertiaDiagonal = CLIB.b3ChangeDynamicsInfoSetLocalInertiaDiagonal,
	GetStatusGetStateId = CLIB.b3GetStatusGetStateId,
	ChangeDynamicsInfoSetAnisotropicFriction = CLIB.b3ChangeDynamicsInfoSetAnisotropicFriction,
	LoadStateSetStateId = CLIB.b3LoadStateSetStateId,
	ChangeDynamicsInfoSetJointLimit = CLIB.b3ChangeDynamicsInfoSetJointLimit,
	CreateMultiBodyBase = CLIB.b3CreateMultiBodyBase,
	LoadStateSetFileName = CLIB.b3LoadStateSetFileName,
	ChangeDynamicsInfoSetJointLimitForce = CLIB.b3ChangeDynamicsInfoSetJointLimitForce,
	CreateMultiBodyLink = CLIB.b3CreateMultiBodyLink,
	LoadBulletCommandInit = CLIB.b3LoadBulletCommandInit,
	ChangeDynamicsInfoSetDynamicType = CLIB.b3ChangeDynamicsInfoSetDynamicType,
	CreateMultiBodySetBatchPositions = CLIB.b3CreateMultiBodySetBatchPositions,
	SaveBulletCommandInit = CLIB.b3SaveBulletCommandInit,
	ChangeDynamicsInfoSetSleepThreshold = CLIB.b3ChangeDynamicsInfoSetSleepThreshold,
	LoadMJCFCommandInit = CLIB.b3LoadMJCFCommandInit,
	LoadMJCFCommandInit2 = CLIB.b3LoadMJCFCommandInit2,
	LoadMJCFCommandSetFlags = CLIB.b3LoadMJCFCommandSetFlags,
	ChangeDynamicsInfoSetSpinningFriction = CLIB.b3ChangeDynamicsInfoSetSpinningFriction,
	LoadMJCFCommandSetUseMultiBody = CLIB.b3LoadMJCFCommandSetUseMultiBody,
	CalculateInverseDynamicsCommandInit = CLIB.b3CalculateInverseDynamicsCommandInit,
	ChangeDynamicsInfoSetRestitution = CLIB.b3ChangeDynamicsInfoSetRestitution,
	CalculateInverseDynamicsCommandInit2 = CLIB.b3CalculateInverseDynamicsCommandInit2,
	ChangeDynamicsInfoSetLinearDamping = CLIB.b3ChangeDynamicsInfoSetLinearDamping,
	CalculateInverseDynamicsSetFlags = CLIB.b3CalculateInverseDynamicsSetFlags,
	GetStatusInverseDynamicsJointForces = CLIB.b3GetStatusInverseDynamicsJointForces,
	CreateBoxCommandSetCollisionShapeType = CLIB.b3CreateBoxCommandSetCollisionShapeType,
	CalculateJacobianCommandInit = CLIB.b3CalculateJacobianCommandInit,
	CreateBoxCommandSetColorRGBA = CLIB.b3CreateBoxCommandSetColorRGBA,
	GetStatusJacobian = CLIB.b3GetStatusJacobian,
	CreatePoseCommandInit = CLIB.b3CreatePoseCommandInit,
	CalculateMassMatrixCommandInit = CLIB.b3CalculateMassMatrixCommandInit,
	CreatePoseCommandSetBasePosition = CLIB.b3CreatePoseCommandSetBasePosition,
	CalculateMassMatrixSetFlags = CLIB.b3CalculateMassMatrixSetFlags,
	CreatePoseCommandSetBaseOrientation = CLIB.b3CreatePoseCommandSetBaseOrientation,
	GetStatusMassMatrix = CLIB.b3GetStatusMassMatrix,
	ChangeDynamicsInfoSetContactProcessingThreshold = CLIB.b3ChangeDynamicsInfoSetContactProcessingThreshold,
	CalculateInverseKinematicsCommandInit = CLIB.b3CalculateInverseKinematicsCommandInit,
	ChangeDynamicsInfoSetActivationState = CLIB.b3ChangeDynamicsInfoSetActivationState,
	CalculateInverseKinematicsAddTargetPurePosition = CLIB.b3CalculateInverseKinematicsAddTargetPurePosition,
	ChangeDynamicsInfoSetMaxJointVelocity = CLIB.b3ChangeDynamicsInfoSetMaxJointVelocity,
	CalculateInverseKinematicsAddTargetsPurePosition = CLIB.b3CalculateInverseKinematicsAddTargetsPurePosition,
	ChangeDynamicsInfoSetCollisionMargin = CLIB.b3ChangeDynamicsInfoSetCollisionMargin,
	CalculateInverseKinematicsAddTargetPositionWithOrientation = CLIB.b3CalculateInverseKinematicsAddTargetPositionWithOrientation,
	InitCreateUserConstraintCommand = CLIB.b3InitCreateUserConstraintCommand,
	CalculateInverseKinematicsPosWithNullSpaceVel = CLIB.b3CalculateInverseKinematicsPosWithNullSpaceVel,
	InitCreateUserConstraintCommand2 = CLIB.b3InitCreateUserConstraintCommand2,
	CalculateInverseKinematicsPosOrnWithNullSpaceVel = CLIB.b3CalculateInverseKinematicsPosOrnWithNullSpaceVel,
	GetStatusUserConstraintUniqueId = CLIB.b3GetStatusUserConstraintUniqueId,
	CalculateInverseKinematicsSetJointDamping = CLIB.b3CalculateInverseKinematicsSetJointDamping,
	InitChangeUserConstraintCommand = CLIB.b3InitChangeUserConstraintCommand,
	CreatePoseCommandSetQdots = CLIB.b3CreatePoseCommandSetQdots,
	CalculateInverseKinematicsSelectSolver = CLIB.b3CalculateInverseKinematicsSelectSolver,
	InitChangeUserConstraintSetPivotInB = CLIB.b3InitChangeUserConstraintSetPivotInB,
	CreatePoseCommandSetJointVelocities = CLIB.b3CreatePoseCommandSetJointVelocities,
	GetStatusInverseKinematicsJointPositions = CLIB.b3GetStatusInverseKinematicsJointPositions,
	InitChangeUserConstraintSetFrameInB = CLIB.b3InitChangeUserConstraintSetFrameInB,
	CreatePoseCommandSetJointVelocity = CLIB.b3CreatePoseCommandSetJointVelocity,
	InitChangeUserConstraintSetMaxForce = CLIB.b3InitChangeUserConstraintSetMaxForce,
	CreatePoseCommandSetJointVelocityMultiDof = CLIB.b3CreatePoseCommandSetJointVelocityMultiDof,
	InitChangeUserConstraintSetGearRatio = CLIB.b3InitChangeUserConstraintSetGearRatio,
	CreateSensorCommandInit = CLIB.b3CreateSensorCommandInit,
	InitChangeUserConstraintSetGearAuxLink = CLIB.b3InitChangeUserConstraintSetGearAuxLink,
	InitChangeUserConstraintSetRelativePositionTarget = CLIB.b3InitChangeUserConstraintSetRelativePositionTarget,
	InitChangeUserConstraintSetERP = CLIB.b3InitChangeUserConstraintSetERP,
	InitRemoveUserConstraintCommand = CLIB.b3InitRemoveUserConstraintCommand,
	GetNumUserConstraints = CLIB.b3GetNumUserConstraints,
	InitGetUserConstraintStateCommand = CLIB.b3InitGetUserConstraintStateCommand,
	GetStatusUserConstraintState = CLIB.b3GetStatusUserConstraintState,
	GetUserConstraintInfo = CLIB.b3GetUserConstraintInfo,
	RotateVector = CLIB.b3RotateVector,
	CalculateVelocityQuaternion = CLIB.b3CalculateVelocityQuaternion,
	GetAxisDifferenceQuaternion = CLIB.b3GetAxisDifferenceQuaternion,
	GetQuaternionDifference = CLIB.b3GetQuaternionDifference,
	GetAxisAngleFromQuaternion = CLIB.b3GetAxisAngleFromQuaternion,
	GetQuaternionFromAxisAngle = CLIB.b3GetQuaternionFromAxisAngle,
	QuaternionSlerp = CLIB.b3QuaternionSlerp,
	InvertTransform = CLIB.b3InvertTransform,
	MultiplyTransforms = CLIB.b3MultiplyTransforms,
	SetAdditionalSearchPath = CLIB.b3SetAdditionalSearchPath,
	GetTimeOut = CLIB.b3GetTimeOut,
	SetCollisionFilterGroupMask = CLIB.b3SetCollisionFilterGroupMask,
	PopProfileTiming = CLIB.b3PopProfileTiming,
	GetUserConstraintId = CLIB.b3GetUserConstraintId,
	PushProfileTiming = CLIB.b3PushProfileTiming,
	InitRequestDebugLinesCommand = CLIB.b3InitRequestDebugLinesCommand,
	SetProfileTimingType = CLIB.b3SetProfileTimingType,
	SetProfileTimingDuractionInMicroSeconds = CLIB.b3SetProfileTimingDuractionInMicroSeconds,
	GetDebugLines = CLIB.b3GetDebugLines,
	ProfileTimingCommandInit = CLIB.b3ProfileTimingCommandInit,
	StateLoggingStop = CLIB.b3StateLoggingStop,
	InitConfigureOpenGLVisualizer = CLIB.b3InitConfigureOpenGLVisualizer,
	GetStatusLoggingUniqueId = CLIB.b3GetStatusLoggingUniqueId,
	InitConfigureOpenGLVisualizer2 = CLIB.b3InitConfigureOpenGLVisualizer2,
	InitPhysicsParamCommand2 = CLIB.b3InitPhysicsParamCommand2,
	ConfigureOpenGLVisualizerSetVisualizationFlags = CLIB.b3ConfigureOpenGLVisualizerSetVisualizationFlags,
	StateLoggingSetDeviceTypeFilter = CLIB.b3StateLoggingSetDeviceTypeFilter,
	StateLoggingSetBodyBUniqueId = CLIB.b3StateLoggingSetBodyBUniqueId,
	ConfigureOpenGLVisualizerSetLightPosition = CLIB.b3ConfigureOpenGLVisualizerSetLightPosition,
	StateLoggingSetBodyAUniqueId = CLIB.b3StateLoggingSetBodyAUniqueId,
	RemovePickingConstraint = CLIB.b3RemovePickingConstraint,
	ConfigureOpenGLVisualizerSetShadowMapResolution = CLIB.b3ConfigureOpenGLVisualizerSetShadowMapResolution,
	CreateRaycastCommandInit = CLIB.b3CreateRaycastCommandInit,
	StateLoggingSetLinkIndexB = CLIB.b3StateLoggingSetLinkIndexB,
	ConfigureOpenGLVisualizerSetShadowMapIntensity = CLIB.b3ConfigureOpenGLVisualizerSetShadowMapIntensity,
	StateLoggingSetLinkIndexA = CLIB.b3StateLoggingSetLinkIndexA,
	RaycastBatchSetNumThreads = CLIB.b3RaycastBatchSetNumThreads,
	ConfigureOpenGLVisualizerSetLightRgbBackground = CLIB.b3ConfigureOpenGLVisualizerSetLightRgbBackground,
	CreateCollisionShapeAddSphere = CLIB.b3CreateCollisionShapeAddSphere,
	RaycastBatchAddRay = CLIB.b3RaycastBatchAddRay,
	ConfigureOpenGLVisualizerSetShadowMapWorldSize = CLIB.b3ConfigureOpenGLVisualizerSetShadowMapWorldSize,
	StateLoggingAddLoggingObjectUniqueId = CLIB.b3StateLoggingAddLoggingObjectUniqueId,
	RaycastBatchAddRays = CLIB.b3RaycastBatchAddRays,
	ConfigureOpenGLVisualizerSetRemoteSyncTransformInterval = CLIB.b3ConfigureOpenGLVisualizerSetRemoteSyncTransformInterval,
	CreateCollisionShapeAddCylinder = CLIB.b3CreateCollisionShapeAddCylinder,
	RaycastBatchSetParentObject = CLIB.b3RaycastBatchSetParentObject,
	ConfigureOpenGLVisualizerSetViewMatrix = CLIB.b3ConfigureOpenGLVisualizerSetViewMatrix,
	CreateCollisionShapeSetChildTransform = CLIB.b3CreateCollisionShapeSetChildTransform,
	RequestActualStateCommandInit2 = CLIB.b3RequestActualStateCommandInit2,
	InitRequestOpenGLVisualizerCameraCommand = CLIB.b3InitRequestOpenGLVisualizerCameraCommand,
	RequestActualStateCommandComputeLinkVelocity = CLIB.b3RequestActualStateCommandComputeLinkVelocity,
	GetStatusOpenGLVisualizerCamera = CLIB.b3GetStatusOpenGLVisualizerCamera,
	InitRemoveCollisionShapeCommand = CLIB.b3InitRemoveCollisionShapeCommand,
	RequestActualStateCommandComputeForwardKinematics = CLIB.b3RequestActualStateCommandComputeForwardKinematics,
	InitUserDebugDrawAddLine3D = CLIB.b3InitUserDebugDrawAddLine3D,
	RequestMouseEventsCommandInit = CLIB.b3RequestMouseEventsCommandInit,
	GetJointState = CLIB.b3GetJointState,
	InitUserDebugDrawAddPoints3D = CLIB.b3InitUserDebugDrawAddPoints3D,
	GetKeyboardEventsData = CLIB.b3GetKeyboardEventsData,
	GetJointStateMultiDof = CLIB.b3GetJointStateMultiDof,
	InitUserDebugDrawAddText3D = CLIB.b3InitUserDebugDrawAddText3D,
	RequestKeyboardEventsCommandInit2 = CLIB.b3RequestKeyboardEventsCommandInit2,
	GetLinkState = CLIB.b3GetLinkState,
	UserDebugTextSetOptionFlags = CLIB.b3UserDebugTextSetOptionFlags,
	CreateVisualShapeAddSphere = CLIB.b3CreateVisualShapeAddSphere,
	CreateVisualShapeAddCapsule = CLIB.b3CreateVisualShapeAddCapsule,
	UserDebugTextSetOrientation = CLIB.b3UserDebugTextSetOrientation,
	CreateVisualShapeAddMesh = CLIB.b3CreateVisualShapeAddMesh,
	CreateVisualShapeSetSpecularColor = CLIB.b3CreateVisualShapeSetSpecularColor,
	UserDebugItemSetReplaceItemUniqueId = CLIB.b3UserDebugItemSetReplaceItemUniqueId,
	GetStatusVisualShapeUniqueId = CLIB.b3GetStatusVisualShapeUniqueId,
	CreateMultiBodyCommandInit = CLIB.b3CreateMultiBodyCommandInit,
	UserDebugItemSetParentObject = CLIB.b3UserDebugItemSetParentObject,
	CreateMultiBodySetFlags = CLIB.b3CreateMultiBodySetFlags,
	CreateBoxCommandSetStartPosition = CLIB.b3CreateBoxCommandSetStartPosition,
	InitUserDebugAddParameter = CLIB.b3InitUserDebugAddParameter,
	RequestVREventsCommandInit = CLIB.b3RequestVREventsCommandInit,
	InitCreateSoftBodyAnchorConstraintCommand = CLIB.b3InitCreateSoftBodyAnchorConstraintCommand,
	InitUserDebugReadParameter = CLIB.b3InitUserDebugReadParameter,
	CreatePoseCommandSetBaseLinearVelocity = CLIB.b3CreatePoseCommandSetBaseLinearVelocity,
	CreatePoseCommandSetBaseScaling = CLIB.b3CreatePoseCommandSetBaseScaling,
	GetStatusDebugParameterValue = CLIB.b3GetStatusDebugParameterValue,
	CreatePoseCommandSetJointPosition = CLIB.b3CreatePoseCommandSetJointPosition,
	CreatePoseCommandSetQ = CLIB.b3CreatePoseCommandSetQ,
	InitUserDebugDrawRemove = CLIB.b3InitUserDebugDrawRemove,
	RequestActualStateCommandInit = CLIB.b3RequestActualStateCommandInit,
	InitUserDebugDrawRemoveAll = CLIB.b3InitUserDebugDrawRemoveAll,
	ApplyExternalTorque = CLIB.b3ApplyExternalTorque,
	InitUserRemoveAllParameters = CLIB.b3InitUserRemoveAllParameters,
	MovePickedBody = CLIB.b3MovePickedBody,
	InitDebugDrawingCommand = CLIB.b3InitDebugDrawingCommand,
	RaycastBatchSetReportHitNumber = CLIB.b3RaycastBatchSetReportHitNumber,
	SetDebugObjectColor = CLIB.b3SetDebugObjectColor,
	RaycastBatchSetFractionEpsilon = CLIB.b3RaycastBatchSetFractionEpsilon,
	ApplyExternalForceCommandInit = CLIB.b3ApplyExternalForceCommandInit,
	RemoveDebugObjectColor = CLIB.b3RemoveDebugObjectColor,
	LoadSoftBodyCommandInit = CLIB.b3LoadSoftBodyCommandInit,
	GetDebugItemUniqueId = CLIB.b3GetDebugItemUniqueId,
	LoadSoftBodySetMass = CLIB.b3LoadSoftBodySetMass,
	InitRequestCameraImage = CLIB.b3InitRequestCameraImage,
	LoadSoftBodySetStartPosition = CLIB.b3LoadSoftBodySetStartPosition,
	InitRequestCameraImage2 = CLIB.b3InitRequestCameraImage2,
	LoadSoftBodySetStartOrientation = CLIB.b3LoadSoftBodySetStartOrientation,
	RequestCameraImageSetCameraMatrices = CLIB.b3RequestCameraImageSetCameraMatrices,
	LoadSoftBodyUpdateSimMesh = CLIB.b3LoadSoftBodyUpdateSimMesh,
	LoadSoftBodySetCollisionMargin = CLIB.b3LoadSoftBodySetCollisionMargin,
	RequestCameraImageSetPixelResolution = CLIB.b3RequestCameraImageSetPixelResolution,
	LoadSoftBodyAddCorotatedForce = CLIB.b3LoadSoftBodyAddCorotatedForce,
	LoadSoftBodySetScale = CLIB.b3LoadSoftBodySetScale,
	RequestCameraImageSetLightDirection = CLIB.b3RequestCameraImageSetLightDirection,
	LoadSoftBodyAddNeoHookeanForce = CLIB.b3LoadSoftBodyAddNeoHookeanForce,
	ApplyExternalForce = CLIB.b3ApplyExternalForce,
	RequestCameraImageSetLightColor = CLIB.b3RequestCameraImageSetLightColor,
	LoadSoftBodyAddMassSpringForce = CLIB.b3LoadSoftBodyAddMassSpringForce,
	GetRaycastInformation = CLIB.b3GetRaycastInformation,
	RequestCameraImageSetLightDistance = CLIB.b3RequestCameraImageSetLightDistance,
	LoadSoftBodyAddGravityForce = CLIB.b3LoadSoftBodyAddGravityForce,
	RaycastBatchSetCollisionFilterMask = CLIB.b3RaycastBatchSetCollisionFilterMask,
	RequestCameraImageSetLightAmbientCoeff = CLIB.b3RequestCameraImageSetLightAmbientCoeff,
	LoadSoftBodySetCollisionHardness = CLIB.b3LoadSoftBodySetCollisionHardness,
	CreateRaycastBatchCommandInit = CLIB.b3CreateRaycastBatchCommandInit,
	RequestCameraImageSetLightDiffuseCoeff = CLIB.b3RequestCameraImageSetLightDiffuseCoeff,
	LoadSoftBodySetSelfCollision = CLIB.b3LoadSoftBodySetSelfCollision,
	PickBody = CLIB.b3PickBody,
	RequestCameraImageSetLightSpecularCoeff = CLIB.b3RequestCameraImageSetLightSpecularCoeff,
	LoadSoftBodySetRepulsionStiffness = CLIB.b3LoadSoftBodySetRepulsionStiffness,
	CreateSensorEnableIMUForLink = CLIB.b3CreateSensorEnableIMUForLink,
	RequestCameraImageSetShadow = CLIB.b3RequestCameraImageSetShadow,
	CreateSensorEnable6DofJointForceTorqueSensor = CLIB.b3CreateSensorEnable6DofJointForceTorqueSensor,
	LoadSoftBodyUseFaceContact = CLIB.b3LoadSoftBodyUseFaceContact,
	RequestCameraImageSelectRenderer = CLIB.b3RequestCameraImageSelectRenderer,
	CreatePoseCommandSetJointPositionMultiDof = CLIB.b3CreatePoseCommandSetJointPositionMultiDof,
	LoadSoftBodySetFrictionCoefficient = CLIB.b3LoadSoftBodySetFrictionCoefficient,
	RequestCameraImageSetFlags = CLIB.b3RequestCameraImageSetFlags,
	CreatePoseCommandSetJointPositions = CLIB.b3CreatePoseCommandSetJointPositions,
	LoadSoftBodyUseBendingSprings = CLIB.b3LoadSoftBodyUseBendingSprings,
	GetCameraImageData = CLIB.b3GetCameraImageData,
	CreatePoseCommandSetBaseAngularVelocity = CLIB.b3CreatePoseCommandSetBaseAngularVelocity,
	LoadSoftBodyUseAllDirectionDampingSprings = CLIB.b3LoadSoftBodyUseAllDirectionDampingSprings,
	RequestCameraImageSetProjectiveTextureMatrices = CLIB.b3RequestCameraImageSetProjectiveTextureMatrices,
	CreatePoseCommandInit2 = CLIB.b3CreatePoseCommandInit2,
	ComputeViewMatrixFromPositions = CLIB.b3ComputeViewMatrixFromPositions,
	CreateBoxCommandSetMass = CLIB.b3CreateBoxCommandSetMass,
	CreateBoxCommandSetHalfExtents = CLIB.b3CreateBoxCommandSetHalfExtents,
	ComputeViewMatrixFromYawPitchRoll = CLIB.b3ComputeViewMatrixFromYawPitchRoll,
	CreateBoxCommandSetStartOrientation = CLIB.b3CreateBoxCommandSetStartOrientation,
	VREventsSetDeviceTypeFilter = CLIB.b3VREventsSetDeviceTypeFilter,
	ComputePositionFromViewMatrix = CLIB.b3ComputePositionFromViewMatrix,
	CreateBoxShapeCommandInit = CLIB.b3CreateBoxShapeCommandInit,
	GetVREventsData = CLIB.b3GetVREventsData,
	ComputeProjectionMatrix = CLIB.b3ComputeProjectionMatrix,
	CreateMultiBodyUseMaximalCoordinates = CLIB.b3CreateMultiBodyUseMaximalCoordinates,
	SetVRCameraStateCommandInit = CLIB.b3SetVRCameraStateCommandInit,
	ComputeProjectionMatrixFOV = CLIB.b3ComputeProjectionMatrixFOV,
	SetVRCameraRootPosition = CLIB.b3SetVRCameraRootPosition,
	CreateVisualShapeSetRGBAColor = CLIB.b3CreateVisualShapeSetRGBAColor,
	RequestCameraImageSetViewMatrix = CLIB.b3RequestCameraImageSetViewMatrix,
	SetVRCameraRootOrientation = CLIB.b3SetVRCameraRootOrientation,
	CreateVisualSetFlag = CLIB.b3CreateVisualSetFlag,
	RequestCameraImageSetViewMatrix2 = CLIB.b3RequestCameraImageSetViewMatrix2,
	SetVRCameraTrackingObject = CLIB.b3SetVRCameraTrackingObject,
	CreateVisualShapeAddPlane = CLIB.b3CreateVisualShapeAddPlane,
	RequestCameraImageSetProjectionMatrix = CLIB.b3RequestCameraImageSetProjectionMatrix,
	SetVRCameraTrackingObjectFlag = CLIB.b3SetVRCameraTrackingObjectFlag,
	CreateVisualShapeAddBox = CLIB.b3CreateVisualShapeAddBox,
	RequestCameraImageSetFOVProjectionMatrix = CLIB.b3RequestCameraImageSetFOVProjectionMatrix,
	RequestKeyboardEventsCommandInit = CLIB.b3RequestKeyboardEventsCommandInit,
	CreateVisualShapeCommandInit = CLIB.b3CreateVisualShapeCommandInit,
	InitRequestContactPointInformation = CLIB.b3InitRequestContactPointInformation,
	ResetMeshDataCommandInit = CLIB.b3ResetMeshDataCommandInit,
	SetContactFilterBodyA = CLIB.b3SetContactFilterBodyA,
	GetMeshData = CLIB.b3GetMeshData,
	GetMeshDataSimulationMesh = CLIB.b3GetMeshDataSimulationMesh,
	SetContactFilterBodyB = CLIB.b3SetContactFilterBodyB,
	GetMeshDataCommandInit = CLIB.b3GetMeshDataCommandInit,
	GetMouseEventsData = CLIB.b3GetMouseEventsData,
	SetContactFilterLinkA = CLIB.b3SetContactFilterLinkA,
	GetStatusCollisionShapeUniqueId = CLIB.b3GetStatusCollisionShapeUniqueId,
	StateLoggingCommandInit = CLIB.b3StateLoggingCommandInit,
	SetContactFilterLinkB = CLIB.b3SetContactFilterLinkB,
	StateLoggingStart = CLIB.b3StateLoggingStart,
	CreateCollisionShapeAddCapsule = CLIB.b3CreateCollisionShapeAddCapsule,
	GetContactPointInformation = CLIB.b3GetContactPointInformation,
	ConnectSharedMemory = CLIB.b3ConnectSharedMemory,
	CreateCollisionShapeAddBox = CLIB.b3CreateCollisionShapeAddBox,
	StateLoggingSetMaxLogDof = CLIB.b3StateLoggingSetMaxLogDof,
	ConnectSharedMemory2 = CLIB.b3ConnectSharedMemory2,
	ChangeDynamicsInfoSetFrictionAnchor = CLIB.b3ChangeDynamicsInfoSetFrictionAnchor,
	ConnectPhysicsDirect = CLIB.b3ConnectPhysicsDirect,
	InitRemoveUserDataCommand = CLIB.b3InitRemoveUserDataCommand,
	SetClosestDistanceFilterLinkA = CLIB.b3SetClosestDistanceFilterLinkA,
	PhysicsParamSetInternalSimFlags = CLIB.b3PhysicsParamSetInternalSimFlags,
	DisconnectSharedMemory = CLIB.b3DisconnectSharedMemory,
	JointControlSetDamping = CLIB.b3JointControlSetDamping,
	SetClosestDistanceFilterLinkB = CLIB.b3SetClosestDistanceFilterLinkB,
	CanSubmitCommand = CLIB.b3CanSubmitCommand,
	SetClosestDistanceThreshold = CLIB.b3SetClosestDistanceThreshold,
	JointControlSetDesiredForceTorqueMultiDof = CLIB.b3JointControlSetDesiredForceTorqueMultiDof,
	SubmitClientCommandAndWaitStatus = CLIB.b3SubmitClientCommandAndWaitStatus,
	SetClosestDistanceFilterCollisionShapeA = CLIB.b3SetClosestDistanceFilterCollisionShapeA,
	StateLoggingSetLogFlags = CLIB.b3StateLoggingSetLogFlags,
	SubmitClientCommand = CLIB.b3SubmitClientCommand,
	SetClosestDistanceFilterCollisionShapeB = CLIB.b3SetClosestDistanceFilterCollisionShapeB,
	ProcessServerStatus = CLIB.b3ProcessServerStatus,
	InitPhysicsParamCommand = CLIB.b3InitPhysicsParamCommand,
	GetStatusType = CLIB.b3GetStatusType,
	UpdateVisualShapeSpecularColor = CLIB.b3UpdateVisualShapeSpecularColor,
	JointControlSetDesiredVelocity = CLIB.b3JointControlSetDesiredVelocity,
	SetClosestDistanceFilterCollisionShapePositionB = CLIB.b3SetClosestDistanceFilterCollisionShapePositionB,
	CreateCustomCommand = CLIB.b3CreateCustomCommand,
	JointControlSetMaximumVelocity = CLIB.b3JointControlSetMaximumVelocity,
	CustomCommandLoadPlugin = CLIB.b3CustomCommandLoadPlugin,
	InitClosestDistanceQuery = CLIB.b3InitClosestDistanceQuery,
	JointControlSetKd = CLIB.b3JointControlSetKd,
	CustomCommandLoadPluginSetPostFix = CLIB.b3CustomCommandLoadPluginSetPostFix,
	JointControlSetKpMultiDof = CLIB.b3JointControlSetKpMultiDof,
	JointControlSetKp = CLIB.b3JointControlSetKp,
	GetStatusPluginUniqueId = CLIB.b3GetStatusPluginUniqueId,
	CollisionFilterCommandInit = CLIB.b3CollisionFilterCommandInit,
	GetStatusPluginCommandResult = CLIB.b3GetStatusPluginCommandResult,
	InitAABBOverlapQuery = CLIB.b3InitAABBOverlapQuery,
	GetStatusPluginCommandReturnData = CLIB.b3GetStatusPluginCommandReturnData,
	SetTimeOut = CLIB.b3SetTimeOut,
	GetAABBOverlapResults = CLIB.b3GetAABBOverlapResults,
	CustomCommandUnloadPlugin = CLIB.b3CustomCommandUnloadPlugin,
	CalculateInverseKinematicsSetCurrentPositions = CLIB.b3CalculateInverseKinematicsSetCurrentPositions,
	InitRequestVisualShapeInformation = CLIB.b3InitRequestVisualShapeInformation,
	CustomCommandExecutePluginCommand = CLIB.b3CustomCommandExecutePluginCommand,
	UpdateVisualShapeTexture = CLIB.b3UpdateVisualShapeTexture,
	GetVisualShapeInformation = CLIB.b3GetVisualShapeInformation,
	CustomCommandExecuteAddIntArgument = CLIB.b3CustomCommandExecuteAddIntArgument,
	UpdateVisualShapeRGBAColor = CLIB.b3UpdateVisualShapeRGBAColor,
	InitRequestCollisionShapeInformation = CLIB.b3InitRequestCollisionShapeInformation,
	CustomCommandExecuteAddFloatArgument = CLIB.b3CustomCommandExecuteAddFloatArgument,
	GetCollisionShapeInformation = CLIB.b3GetCollisionShapeInformation,
	JointControlCommandInit2Internal = CLIB.b3JointControlCommandInit2Internal,
	GetStatusBodyIndices = CLIB.b3GetStatusBodyIndices,
	InitLoadTexture = CLIB.b3InitLoadTexture,
	LoadSdfCommandSetUseMultiBody = CLIB.b3LoadSdfCommandSetUseMultiBody,
	GetStatusBodyIndex = CLIB.b3GetStatusBodyIndex,
	GetStatusTextureUniqueId = CLIB.b3GetStatusTextureUniqueId,
	GetStatusActualState = CLIB.b3GetStatusActualState,
	CreateChangeTextureCommandInit = CLIB.b3CreateChangeTextureCommandInit,
	PhysicsParamSetGravity = CLIB.b3PhysicsParamSetGravity,
	GetStatusActualState2 = CLIB.b3GetStatusActualState2,
	InitUpdateVisualShape = CLIB.b3InitUpdateVisualShape,
	PhysicsParamSetTimeStep = CLIB.b3PhysicsParamSetTimeStep,
	JointControlCommandInit = CLIB.b3JointControlCommandInit,
	RequestCollisionInfoCommandInit = CLIB.b3RequestCollisionInfoCommandInit,
	PhysicsParamSetDefaultContactERP = CLIB.b3PhysicsParamSetDefaultContactERP,
	LoadSdfCommandSetUseGlobalScaling = CLIB.b3LoadSdfCommandSetUseGlobalScaling,
	GetStatusAABB = CLIB.b3GetStatusAABB,
	PhysicsParamSetDefaultNonContactERP = CLIB.b3PhysicsParamSetDefaultNonContactERP,
	SaveWorldCommandInit = CLIB.b3SaveWorldCommandInit,
	InitSyncBodyInfoCommand = CLIB.b3InitSyncBodyInfoCommand,
	PhysicsParamSetDefaultFrictionERP = CLIB.b3PhysicsParamSetDefaultFrictionERP,
	InitRequestBodyInfoCommand = CLIB.b3InitRequestBodyInfoCommand,
	JointControlCommandInit2 = CLIB.b3JointControlCommandInit2,
	PhysicsParamSetDefaultGlobalCFM = CLIB.b3PhysicsParamSetDefaultGlobalCFM,
	LoadSdfCommandInit2 = CLIB.b3LoadSdfCommandInit2,
	GetNumBodies = CLIB.b3GetNumBodies,
	PhysicsParamSetDefaultFrictionCFM = CLIB.b3PhysicsParamSetDefaultFrictionCFM,
	LoadSdfCommandInit = CLIB.b3LoadSdfCommandInit,
	JointControlSetDesiredPosition = CLIB.b3JointControlSetDesiredPosition,
	PhysicsParamSetNumSubSteps = CLIB.b3PhysicsParamSetNumSubSteps,
	SetCollisionFilterPair = CLIB.b3SetCollisionFilterPair,
	JointControlSetDesiredPositionMultiDof = CLIB.b3JointControlSetDesiredPositionMultiDof,
	PhysicsParamSetRealTimeSimulation = CLIB.b3PhysicsParamSetRealTimeSimulation,
	CalculateInverseKinematicsSetResidualThreshold = CLIB.b3CalculateInverseKinematicsSetResidualThreshold,
	CalculateInverseKinematicsSetMaxNumIterations = CLIB.b3CalculateInverseKinematicsSetMaxNumIterations,
	PhysicsParamSetNumSolverIterations = CLIB.b3PhysicsParamSetNumSolverIterations,
	LoadStateCommandInit = CLIB.b3LoadStateCommandInit,
	GetUserDataIdFromStatus = CLIB.b3GetUserDataIdFromStatus,
	PhysicsParamSetNumNonContactInnerIterations = CLIB.b3PhysicsParamSetNumNonContactInnerIterations,
	GetStatusForwardDynamicsAnalyticsData = CLIB.b3GetStatusForwardDynamicsAnalyticsData,
	GetJointInfo = CLIB.b3GetJointInfo,
	PhysicsParamSetWarmStartingFactor = CLIB.b3PhysicsParamSetWarmStartingFactor,
	GetUserDataId = CLIB.b3GetUserDataId,
	JointControlSetKdMultiDof = CLIB.b3JointControlSetKdMultiDof,
	PhysicsParamSetArticulatedWarmStartingFactor = CLIB.b3PhysicsParamSetArticulatedWarmStartingFactor,
	SetClosestDistanceFilterBodyB = CLIB.b3SetClosestDistanceFilterBodyB,
	PhysicsParamSetCollisionFilterMode = CLIB.b3PhysicsParamSetCollisionFilterMode,
	SetClosestDistanceFilterCollisionShapeOrientationA = CLIB.b3SetClosestDistanceFilterCollisionShapeOrientationA,
	GetClosestPointInformation = CLIB.b3GetClosestPointInformation,
	PhysicsParamSetUseSplitImpulse = CLIB.b3PhysicsParamSetUseSplitImpulse,
	InitUpdateVisualShape2 = CLIB.b3InitUpdateVisualShape2,
	JointControlSetDesiredVelocityMultiDof = CLIB.b3JointControlSetDesiredVelocityMultiDof,
	PhysicsParamSetSplitImpulsePenetrationThreshold = CLIB.b3PhysicsParamSetSplitImpulsePenetrationThreshold,
	InitRemoveBodyCommand = CLIB.b3InitRemoveBodyCommand,
	JointControlSetDesiredVelocityMultiDof2 = CLIB.b3JointControlSetDesiredVelocityMultiDof2,
	PhysicsParamSetContactBreakingThreshold = CLIB.b3PhysicsParamSetContactBreakingThreshold,
	JointControlSetMaximumForce = CLIB.b3JointControlSetMaximumForce,
	UpdateVisualShapeFlags = CLIB.b3UpdateVisualShapeFlags,
	PhysicsParamSetMaxNumCommandsPer1ms = CLIB.b3PhysicsParamSetMaxNumCommandsPer1ms,
	SetClosestDistanceFilterCollisionShapeOrientationB = CLIB.b3SetClosestDistanceFilterCollisionShapeOrientationB,
	SetClosestDistanceFilterCollisionShapePositionA = CLIB.b3SetClosestDistanceFilterCollisionShapePositionA,
	PhysicsParamSetEnableFileCaching = CLIB.b3PhysicsParamSetEnableFileCaching,
	SetClosestDistanceFilterBodyA = CLIB.b3SetClosestDistanceFilterBodyA,
	JointControlSetDampingMultiDof = CLIB.b3JointControlSetDampingMultiDof,
	PhysicsParamSetRestitutionVelocityThreshold = CLIB.b3PhysicsParamSetRestitutionVelocityThreshold,
	ChangeDynamicsInfoSetCcdSweptSphereRadius = CLIB.b3ChangeDynamicsInfoSetCcdSweptSphereRadius,
	JointControlSetDesiredForceTorque = CLIB.b3JointControlSetDesiredForceTorque,
	PhysicsParamSetEnableConeFriction = CLIB.b3PhysicsParamSetEnableConeFriction,
	CreateCollisionShapeCommandInit = CLIB.b3CreateCollisionShapeCommandInit,
	ChangeDynamicsInfoSetContactStiffnessAndDamping = CLIB.b3ChangeDynamicsInfoSetContactStiffnessAndDamping,
	PhysicsParameterSetDeterministicOverlappingPairs = CLIB.b3PhysicsParameterSetDeterministicOverlappingPairs,
	ChangeDynamicsInfoSetJointDamping = CLIB.b3ChangeDynamicsInfoSetJointDamping,
	ChangeDynamicsInfoSetAngularDamping = CLIB.b3ChangeDynamicsInfoSetAngularDamping,
	PhysicsParameterSetAllowedCcdPenetration = CLIB.b3PhysicsParameterSetAllowedCcdPenetration,
	ChangeDynamicsInfoSetRollingFriction = CLIB.b3ChangeDynamicsInfoSetRollingFriction,
	ChangeDynamicsInfoSetLateralFriction = CLIB.b3ChangeDynamicsInfoSetLateralFriction,
	PhysicsParameterSetJointFeedbackMode = CLIB.b3PhysicsParameterSetJointFeedbackMode,
}
library.e = {
}
library.clib = CLIB
return library
