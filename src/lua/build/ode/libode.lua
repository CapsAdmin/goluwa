local ffi = require("ffi")
ffi.cdef([[enum{dParamLoStop=0,dParamHiStop=1,dParamVel=2,dParamLoVel=3,dParamHiVel=4,dParamFMax=5,dParamFudgeFactor=6,dParamBounce=7,dParamCFM=8,dParamStopERP=9,dParamStopCFM=10,dParamSuspensionERP=11,dParamSuspensionCFM=12,dParamERP=13,dParamsInGroup=14,dParamGroup1=0,dParamLoStop1=0,dParamHiStop1=1,dParamVel1=2,dParamLoVel1=3,dParamHiVel1=4,dParamFMax1=5,dParamFudgeFactor1=6,dParamBounce1=7,dParamCFM1=8,dParamStopERP1=9,dParamStopCFM1=10,dParamSuspensionERP1=11,dParamSuspensionCFM1=12,dParamERP1=13,dParamGroup2=256,dParamLoStop2=256,dParamHiStop2=257,dParamVel2=258,dParamLoVel2=259,dParamHiVel2=260,dParamFMax2=261,dParamFudgeFactor2=262,dParamBounce2=263,dParamCFM2=264,dParamStopERP2=265,dParamStopCFM2=266,dParamSuspensionERP2=267,dParamSuspensionCFM2=268,dParamERP2=269,dParamGroup3=512,dParamLoStop3=512,dParamHiStop3=513,dParamVel3=514,dParamLoVel3=515,dParamHiVel3=516,dParamFMax3=517,dParamFudgeFactor3=518,dParamBounce3=519,dParamCFM3=520,dParamStopERP3=521,dParamStopCFM3=522,dParamSuspensionERP3=523,dParamSuspensionCFM3=524,dParamERP3=525,dParamGroup=256,
dAMotorUser=0,dAMotorEuler=1,
dTransmissionParallelAxes=0,dTransmissionIntersectingAxes=1,dTransmissionChainDrive=2,
dContactMu2=1,dContactAxisDep=1,dContactFDir1=2,dContactBounce=4,dContactSoftERP=8,dContactSoftCFM=16,dContactMotion1=32,dContactMotion2=64,dContactMotionN=128,dContactSlip1=256,dContactSlip2=512,dContactRolling=1024,dContactApprox0=0,dContactApprox1_1=4096,dContactApprox1_2=8192,dContactApprox1_N=16384,dContactApprox1=28672,
dGeomCommonControlClass=0,dGeomColliderControlClass=1,
dGeomCommonAnyControlCode=0,dGeomColliderSetMergeSphereContactsControlCode=1,dGeomColliderGetMergeSphereContactsControlCode=2,
dGeomColliderMergeContactsValue__Default=0,dGeomColliderMergeContactsValue_None=1,dGeomColliderMergeContactsValue_Normals=2,dGeomColliderMergeContactsValue_Full=3,
dMaxUserClasses=4,
dSphereClass=0,dBoxClass=1,dCapsuleClass=2,dCylinderClass=3,dPlaneClass=4,dRayClass=5,dConvexClass=6,dGeomTransformClass=7,dTriMeshClass=8,dHeightfieldClass=9,dFirstSpaceClass=10,dSimpleSpaceClass=10,dHashSpaceClass=11,dSweepAndPruneSpaceClass=12,dQuadTreeSpaceClass=13,dLastSpaceClass=13,dFirstUserClass=14,dLastUserClass=17,dGeomNumClasses=18,};typedef enum dSpaceAxis{dSA__MIN=0,dSA_X=0,dSA_Y=1,dSA_Z=2,dSA__MAX=3};
typedef enum dVec4Element{dV4E__MIN=0,dV4E_X=0,dV4E_Y=1,dV4E_Z=2,dV4E_O=3,dV4E__MAX=4};
typedef enum dMat4Element{dM4E__MIN=0,dM4E__X_MIN=0,dM4E_XX=0,dM4E_XY=1,dM4E_XZ=2,dM4E_XO=3,dM4E__X_MAX=4,dM4E__Y_MIN=4,dM4E_YX=4,dM4E_YY=5,dM4E_YZ=6,dM4E_YO=7,dM4E__Y_MAX=8,dM4E__Z_MIN=8,dM4E_ZX=8,dM4E_ZY=9,dM4E_ZZ=10,dM4E_ZO=11,dM4E__Z_MAX=12,dM4E__O_MIN=12,dM4E_OX=12,dM4E_OY=13,dM4E_OZ=14,dM4E_OO=15,dM4E__O_MAX=16,dM4E__MAX=16};
typedef enum dDynamicsAxis{dDA__MIN=0,dDA__L_MIN=0,dDA_LX=0,dDA_LY=1,dDA_LZ=2,dDA__L_MAX=3,dDA__A_MIN=3,dDA_AX=3,dDA_AY=4,dDA_AZ=5,dDA__A_MAX=6,dDA__MAX=6};
typedef enum dMotionDynamics{dMD__MIN=0,dMD_LINEAR=0,dMD_ANGULAR=1,dMD__MAX=2};
typedef enum dAllocateODEDataFlags{dAllocateFlagBasicData=0,dAllocateFlagCollisionData=1,dAllocateMaskAll=-1};
typedef enum dQuatElement{dQUE__MIN=0,dQUE_R=0,dQUE__AXIS_MIN=1,dQUE_I=1,dQUE_J=2,dQUE_K=3,dQUE__AXIS_MAX=4,dQUE__MAX=4};
typedef enum dJointType{dJointTypeNone=0,dJointTypeBall=1,dJointTypeHinge=2,dJointTypeSlider=3,dJointTypeContact=4,dJointTypeUniversal=5,dJointTypeHinge2=6,dJointTypeFixed=7,dJointTypeNull=8,dJointTypeAMotor=9,dJointTypeLMotor=10,dJointTypePlane2D=11,dJointTypePR=12,dJointTypePU=13,dJointTypePiston=14,dJointTypeDBall=15,dJointTypeDHinge=16,dJointTypeTransmission=17};
typedef enum dMat3Element{dM3E__MIN=0,dM3E__X_MIN=0,dM3E__X_AXES_MIN=0,dM3E_XX=0,dM3E_XY=1,dM3E_XZ=2,dM3E__X_AXES_MAX=3,dM3E_XPAD=3,dM3E__X_MAX=4,dM3E__Y_MIN=4,dM3E__Y_AXES_MIN=4,dM3E_YX=4,dM3E_YY=5,dM3E_YZ=6,dM3E__Y_AXES_MAX=7,dM3E_YPAD=7,dM3E__Y_MAX=8,dM3E__Z_MIN=8,dM3E__Z_AXES_MIN=8,dM3E_ZX=8,dM3E_ZY=9,dM3E_ZZ=10,dM3E__Z_AXES_MAX=11,dM3E_ZPAD=11,dM3E__Z_MAX=12,dM3E__MAX=12};
typedef enum dInitODEFlags{dInitFlagManualThreadCleanup=1};
typedef enum dVec3Element{dV3E__MIN=0,dV3E__AXES_MIN=0,dV3E_X=0,dV3E_Y=1,dV3E_Z=2,dV3E__AXES_MAX=3,dV3E_PAD=3,dV3E__MAX=4};
struct _IO_marker {struct _IO_marker*_next;struct _IO_FILE*_sbuf;int _pos;};
struct _IO_FILE {int _flags;char*_IO_read_ptr;char*_IO_read_end;char*_IO_read_base;char*_IO_write_base;char*_IO_write_ptr;char*_IO_write_end;char*_IO_buf_base;char*_IO_buf_end;char*_IO_save_base;char*_IO_backup_base;char*_IO_save_end;struct _IO_marker*_markers;struct _IO_FILE*_chain;int _fileno;int _flags2;long _old_offset;unsigned short _cur_column;signed char _vtable_offset;char _shortbuf[1];void*_lock;long _offset;void*__pad1;void*__pad2;void*__pad3;void*__pad4;unsigned long __pad5;int _mode;char _unused2[15*sizeof(int)-4*sizeof(void*)-sizeof(size_t)];};
struct dxWorld {};
struct dxSpace {};
struct dxBody {};
struct dxGeom {};
struct dxJoint {};
struct dxJointGroup {};
struct dJointFeedback {double f1[dV3E__MAX];double t1[dV3E__MAX];double f2[dV3E__MAX];double t2[dV3E__MAX];};
struct dSurfaceParameters {int mode;double mu;double mu2;double rho;double rho2;double rhoN;double bounce;double bounce_vel;double soft_erp;double soft_cfm;double motion1;double motion2;double motionN;double slip1;double slip2;};
struct dContactGeom {double pos[dV3E__MAX];double normal[dV3E__MAX];double depth;struct dxGeom*g1;struct dxGeom*g2;int side1;int side2;};
struct dContact {struct dSurfaceParameters surface;struct dContactGeom geom;double fdir1[dV3E__MAX];};
struct dStopwatch {double time;unsigned long cc[2];};
struct dMass {double mass;double c[dV3E__MAX];double I[dM3E__MAX];};
struct dxThreadingImplementation {};
struct dWorldStepReserveInfo {unsigned int struct_size;float reserve_factor;unsigned int reserve_minimum;};
struct dWorldStepMemoryFunctionsInfo {unsigned int struct_size;void*(*alloc_block)(unsigned long);void*(*shrink_block)(void*,unsigned long,unsigned long);void(*free_block)(void*,unsigned long);};
struct dxTriMeshData {};
struct dxHeightfieldData {};
struct dxThreadingThreadPool {};
void(dJointSetSliderAxisDelta)(struct dxJoint*,double,double,double,double,double,double);
double(dJointGetPistonAngleRate)(struct dxJoint*);
int(dConnectingJointList)(struct dxBody*,struct dxBody*,struct dxJoint**);
int(dGeomTriMeshIsTCEnabled)(struct dxGeom*,int);
void(dJointGetHinge2Anchor)(struct dxJoint*,double[dV3E__MAX]);
void(dPlaneSpace)(const double[dV3E__MAX],double[dV3E__MAX],double[dV3E__MAX]);
void*(dWorldGetData)(struct dxWorld*);
void(dJointSetTransmissionAnchor2)(struct dxJoint*,double,double,double);
int(dBodyGetAutoDisableAverageSamplesCount)(struct dxBody*);
void(dBodySetAutoDisableAngularThreshold)(struct dxBody*,double);
void(dGeomTriMeshDataBuildDouble1)(struct dxTriMeshData*,const void*,int,int,const void*,int,int,const void*);
void(dJointGroupDestroy)(struct dxJointGroup*);
void(dSetErrorHandler)(void(fn)(int,const char*,__builtin_va_list));
void(dGeomTransformSetGeom)(struct dxGeom*,struct dxGeom*);
void(dJointGetPRAnchor)(struct dxJoint*,double[dV3E__MAX]);
double(dGeomPlanePointDepth)(struct dxGeom*,double,double,double);
double(dGeomRayGetLength)(struct dxGeom*);
double(dJointGetUniversalAngle2)(struct dxJoint*);
int(dBoxBox)(const double[dV3E__MAX],const double[dM3E__MAX],const double[dV3E__MAX],const double[dV3E__MAX],const double[dM3E__MAX],const double[dV3E__MAX],double[dV3E__MAX],double*,int*,int,struct dContactGeom*,int);
void(dGeomTriMeshSetRayCallback)(struct dxGeom*,int(Callback)(struct dxGeom*,struct dxGeom*,int,double,double));
void(dBodySetAutoDisableTime)(struct dxBody*,double);
void(dGeomSetCategoryBits)(struct dxGeom*,unsigned long);
void(dJointSetPUParam)(struct dxJoint*,int,double);
int(dOrthogonalizeR)(double[dM3E__MAX]);
void(dGeomRaySetBackfaceCull)(struct dxGeom*,int);
struct dxHeightfieldData*(dGeomHeightfieldGetHeightfieldData)(struct dxGeom*);
void(dGeomTriMeshGetPoint)(struct dxGeom*,int,double,double,double[dV3E__MAX]);
void(dWorldSetContactSurfaceLayer)(struct dxWorld*,double);
const double*(dBodyGetPosition)(struct dxBody*);
void(dGeomDisable)(struct dxGeom*);
void(dJointSetLMotorAxis)(struct dxJoint*,int,int,double,double,double);
void(dJointGetTransmissionAnchor2)(struct dxJoint*,double[dV3E__MAX]);
int(dBodyGetGyroscopicMode)(struct dxBody*);
void(dJointSetDBallDistance)(struct dxJoint*,double);
void(dBodyGetFiniteRotationAxis)(struct dxBody*,double[dV3E__MAX]);
void(dBodyDestroy)(struct dxBody*);
void(dHashSpaceGetLevels)(struct dxSpace*,int*,int*);
struct dxJoint*(dBodyGetJoint)(struct dxBody*,int);
void(dGeomMoved)(struct dxGeom*);
void*(dAlloc)(unsigned long);
struct dJointFeedback*(dJointGetFeedback)(struct dxJoint*);
struct dxGeom*(dCreateConvex)(struct dxSpace*,const double*,unsigned int,const double*,unsigned int,const unsigned int*);
void(dWorldSetMaxAngularSpeed)(struct dxWorld*,double);
struct dxJoint*(dJointCreateFixed)(struct dxWorld*,struct dxJointGroup*);
double(dStopwatchTime)(struct dStopwatch*);
void(dJointSetPUAxis3)(struct dxJoint*,double,double,double);
struct dxJoint*(dJointCreateBall)(struct dxWorld*,struct dxJointGroup*);
double(dWorldGetContactSurfaceLayer)(struct dxWorld*);
struct dxGeom*(dBodyGetNextGeom)(struct dxGeom*);
struct dxJoint*(dJointCreateSlider)(struct dxWorld*,struct dxJointGroup*);
struct dxWorld*(dWorldCreate)();
double(dJointGetHingeParam)(struct dxJoint*,int);
double(dJointGetAMotorParam)(struct dxJoint*,int);
int(dJointIsEnabled)(struct dxJoint*);
void(dBodySetKinematic)(struct dxBody*);
void(dMassSetBox)(struct dMass*,double,double,double,double);
int(dAllocateODEDataForThread)(unsigned int);
void(dBodySetAngularDampingThreshold)(struct dxBody*,double);
void(dGeomSetPosition)(struct dxGeom*,double,double,double);
void(dJointSetHinge2Axis1)(struct dxJoint*,double,double,double);
void(dJointSetLMotorParam)(struct dxJoint*,int,double);
void(dJointGroupEmpty)(struct dxJointGroup*);
void(dJointSetAMotorParam)(struct dxJoint*,int,double);
void(dJointSetTransmissionMode)(struct dxJoint*,int);
struct dxGeom*(dCreateRay)(struct dxSpace*,double);
void(dJointGetTransmissionAxis)(struct dxJoint*,double[dV3E__MAX]);
void(dGeomPlaneSetParams)(struct dxGeom*,double,double,double,double);
double(dJointGetLMotorParam)(struct dxJoint*,int);
double(dJointGetPUPosition)(struct dxJoint*);
void(dMultiply1)(double*,const double*,const double*,int,int,int);
double(dJointGetHinge2Angle1)(struct dxJoint*);
int(dSafeNormalize4)(double[dV4E__MAX]);
const double*(dBodyGetAngularVel)(struct dxBody*);
unsigned long(dGeomGetCollideBits)(struct dxGeom*);
void(dBodyGetMass)(struct dxBody*,struct dMass*);
void(dGeomGetAABB)(struct dxGeom*,double);
void(dJointSetSliderAxis)(struct dxJoint*,double,double,double);
void*(dGeomGetData)(struct dxGeom*);
void(dDebug)(int,const char*,...);
void(dBodyAddForceAtRelPos)(struct dxBody*,double,double,double,double,double,double);
void(dJointSetUniversalAxis2Offset)(struct dxJoint*,double,double,double,double,double);
void(dMassSetBoxTotal)(struct dMass*,double,double,double,double);
void(dBodySetRotation)(struct dxBody*,const double[dM3E__MAX]);
void(dGeomSetCollideBits)(struct dxGeom*,unsigned long);
struct dxJoint*(dJointCreatePR)(struct dxWorld*,struct dxJointGroup*);
void(dBodyAddTorque)(struct dxBody*,double,double,double);
const double*(dBodyGetRotation)(struct dxBody*);
void(dBodyEnable)(struct dxBody*);
void(dJointSetHingeAxisOffset)(struct dxJoint*,double,double,double,double);
void(dBodySetAngularVel)(struct dxBody*,double,double,double);
double(dJointGetSliderParam)(struct dxJoint*,int);
void(dJointSetSliderParam)(struct dxJoint*,int,double);
void(dJointSetPistonAxisDelta)(struct dxJoint*,double,double,double,double,double,double);
int(dMassCheck)(const struct dMass*);
int(dBodyGetAutoDisableSteps)(struct dxBody*);
int(dWorldSetStepMemoryManager)(struct dxWorld*,const struct dWorldStepMemoryFunctionsInfo*);
void(dRemoveRowCol)(double*,int,int,int);
void(dJointSetPUAxis2)(struct dxJoint*,double,double,double);
void(dJointGetPUAxis3)(struct dxJoint*,double[dV3E__MAX]);
void(dCloseODE)();
double(dJointGetPRAngleRate)(struct dxJoint*);
double(dGeomBoxPointDepth)(struct dxGeom*,double,double,double);
void(dGeomSetData)(struct dxGeom*,void*);
unsigned int(dWorldGetStepIslandsProcessingMaxThreadCount)(struct dxWorld*);
void(dJointSetBallParam)(struct dxJoint*,int,double);
void(dQMultiply1)(double[dQUE__MAX],const double[dQUE__MAX],const double[dQUE__MAX]);
void(dBodyAddRelForce)(struct dxBody*,double,double,double);
struct dxBody*(dGeomGetBody)(struct dxGeom*);
void(dGeomGetRelPointPos)(struct dxGeom*,double,double,double,double[dV3E__MAX]);
void(dGeomEnable)(struct dxGeom*);
int(dSpaceGetCleanup)(struct dxSpace*);
void(dTimerNow)(const char*);
void(dWorldSetGravity)(struct dxWorld*,double,double,double);
void(*dGetMessageHandler())(int,const char*,__builtin_va_list);
void(dVectorScale)(double*,const double*,int);
void(dLDLTRemove)(double**,const int*,double*,double*,int,int,int,int);
void(dRFromAxisAndAngle)(double[dM3E__MAX],double,double,double,double);
void(dJointSetHingeAnchor)(struct dxJoint*,double,double,double);
int(dCheckConfiguration)(const char*);
void(dBodySetAutoDisableLinearThreshold)(struct dxBody*,double);
unsigned long(dRand)();
int(dBoxTouchesBox)(const double[dV3E__MAX],const double[dM3E__MAX],const double[dV3E__MAX],const double[dV3E__MAX],const double[dM3E__MAX],const double[dV3E__MAX]);
void(dQfromR)(double[dQUE__MAX],const double[dM3E__MAX]);
void(dMassSetParameters)(struct dMass*,double,double,double,double,double,double,double,double,double,double);
void(dDQfromW)(double,const double[dV3E__MAX],const double[dQUE__MAX]);
double(dGeomSphereGetRadius)(struct dxGeom*);
void(dGeomSetRotation)(struct dxGeom*,const double[dM3E__MAX]);
double(dRandReal)();
void(dBodyGetRelPointPos)(struct dxBody*,double,double,double,double[dV3E__MAX]);
int(dWorldGetAutoDisableFlag)(struct dxWorld*);
void(dSolveLDLT)(const double*,const double*,double*,int,int);
void(dJointGetTransmissionAxis1)(struct dxJoint*,double[dV3E__MAX]);
void(dGeomHeightfieldDataBuildDouble)(struct dxHeightfieldData*,const double*,int,double,double,int,int,double,double,double,int);
void(dJointAddHingeTorque)(struct dxJoint*,double);
void(dMessage)(int,const char*,...);
const double*(dBodyGetForce)(struct dxBody*);
int(dBodyIsKinematic)(struct dxBody*);
struct dxBody*(dJointGetBody)(struct dxJoint*,int);
int(dJointGetAMotorMode)(struct dxJoint*);
struct dxSpace*(dGeomGetSpace)(struct dxGeom*);
double(dJointGetPUAngle2)(struct dxJoint*);
void(dSpaceCollide)(struct dxSpace*,void*,void(callback)(void*,struct dxGeom*,struct dxGeom*));
void(dJointSetTransmissionAxis2)(struct dxJoint*,double,double,double);
void(dSpaceSetManualCleanup)(struct dxSpace*,int);
struct dxJoint*(dJointCreatePlane2D)(struct dxWorld*,struct dxJointGroup*);
void(dQMultiply2)(double[dQUE__MAX],const double[dQUE__MAX],const double[dQUE__MAX]);
void(dJointSetHingeAxis)(struct dxJoint*,double,double,double);
void(dWorldSetQuickStepNumIterations)(struct dxWorld*,int);
void(dQSetIdentity)(double[dQUE__MAX]);
void(dSetColliderOverride)(int,int,int(fn)(struct dxGeom*,struct dxGeom*,int,struct dContactGeom*,int));
void(dJointDisable)(struct dxJoint*);
int(dWorldGetQuickStepNumIterations)(struct dxWorld*);
void(dGeomDestroy)(struct dxGeom*);
void(dRandSetSeed)(unsigned long);
struct dxJoint*(dJointCreateNull)(struct dxWorld*,struct dxJointGroup*);
struct dxBody*(dBodyCreate)(struct dxWorld*);
int(dBodyGetFiniteRotationMode)(struct dxBody*);
void(dJointGetUniversalAxis2)(struct dxJoint*,double[dV3E__MAX]);
void(dMultiply0)(double*,const double*,const double*,int,int,int);
void(dWorldSetAutoDisableLinearThreshold)(struct dxWorld*,double);
void(dJointSetUniversalAxis2)(struct dxJoint*,double,double,double);
struct dxJoint*(dJointCreatePiston)(struct dxWorld*,struct dxJointGroup*);
void(dGeomRaySetLength)(struct dxGeom*,double);
void(dWorldSetCFM)(struct dxWorld*,double);
int(dSpaceGetManualCleanup)(struct dxSpace*);
void(dSolveCholesky)(const double*,double*,int);
void(dJointAddAMotorTorques)(struct dxJoint*,double,double,double);
void(dSetDebugHandler)(void(fn)(int,const char*,__builtin_va_list));
void(dJointGetPRAxis2)(struct dxJoint*,double[dV3E__MAX]);
void(dBodySetAutoDisableFlag)(struct dxBody*,int);
struct dxJoint*(dConnectingJoint)(struct dxBody*,struct dxBody*);
void(dGeomCopyRotation)(struct dxGeom*,double[dM3E__MAX]);
void(dMassRotate)(struct dMass*,const double[dM3E__MAX]);
void(dBodyAddForceAtPos)(struct dxBody*,double,double,double,double,double,double);
void(dBodyCopyRotation)(struct dxBody*,double[dM3E__MAX]);
void(dJointSetPlane2DXParam)(struct dxJoint*,int,double);
void(dJointAttach)(struct dxJoint*,struct dxBody*,struct dxBody*);
int(dWorldSetStepMemoryReservationPolicy)(struct dxWorld*,const struct dWorldStepReserveInfo*);
void(dJointGetUniversalAnchor)(struct dxJoint*,double[dV3E__MAX]);
void(dJointSetPUAnchorDelta)(struct dxJoint*,double,double,double,double,double,double);
void(dMassSetCylinder)(struct dMass*,double,int,double,double);
void(dBodyGetRelPointVel)(struct dxBody*,double,double,double,double[dV3E__MAX]);
void(dGeomTriMeshDataBuildSimple1)(struct dxTriMeshData*,const double*,int,const unsigned int*,int,const int*);
double(dBodyGetAngularDamping)(struct dxBody*);
void(dJointSetHinge2Axis2)(struct dxJoint*,double,double,double);
void(dWorldSetData)(struct dxWorld*,void*);
void(dJointSetTransmissionRatio)(struct dxJoint*,double);
double(dWorldGetERP)(struct dxWorld*);
void(dGeomSphereSetRadius)(struct dxGeom*,double);
void(dMassTranslate)(struct dMass*,double,double,double);
void(dGeomHeightfieldSetHeightfieldData)(struct dxGeom*,struct dxHeightfieldData*);
double(dWorldGetAutoDisableTime)(struct dxWorld*);
void(dMassSetTrimesh)(struct dMass*,double,struct dxGeom*);
void(dBodySetDynamic)(struct dxBody*);
struct dxSpace*(dSimpleSpaceCreate)(struct dxSpace*);
void(dBodySetLinearDamping)(struct dxBody*,double);
void(dThreadingImplementationCleanupForRestart)(struct dxThreadingImplementation*);
void*(dJointGetData)(struct dxJoint*);
void(dJointSetPlane2DAngleParam)(struct dxJoint*,int,double);
void(dInfiniteAABB)(struct dxGeom*,double);
void(dWorldSetAngularDamping)(struct dxWorld*,double);
void(dGeomRaySetParams)(struct dxGeom*,int,int);
double(dWorldGetAngularDamping)(struct dxWorld*);
void(dPrintMatrix)(const double*,int,int,const char*,struct _IO_FILE*);
void(dGeomTriMeshDataBuildSingle1)(struct dxTriMeshData*,const void*,int,int,const void*,int,int,const void*);
void(dBodyAddRelForceAtPos)(struct dxBody*,double,double,double,double,double,double);
double(dWorldGetQuickStepW)(struct dxWorld*);
void(dJointEnable)(struct dxJoint*);
int(dBodyGetNumJoints)(struct dxBody*);
void(dJointGetUniversalAngles)(struct dxJoint*,double*,double*);
int(dJointGetAMotorAxisRel)(struct dxJoint*,int);
double*(dGeomTriMeshGetLastTransform)(struct dxGeom*);
double(dJointGetTransmissionParam)(struct dxJoint*,int);
void(dJointSetDHingeParam)(struct dxJoint*,int,double);
void(dJointGetDHingeAxis)(struct dxJoint*,double[dV3E__MAX]);
void(dGeomTriMeshDataGetBuffer)(struct dxTriMeshData*,unsigned char**,int*);
void(dJointGetUniversalAxis1)(struct dxJoint*,double[dV3E__MAX]);
void(dJointSetHinge2Param)(struct dxJoint*,int,double);
void(dWorldCleanupWorkingMemory)(struct dxWorld*);
void(dJointSetUniversalAxis1)(struct dxJoint*,double,double,double);
int(dBodyGetGravityMode)(struct dxBody*);
double(dJointGetHinge2Param)(struct dxJoint*,int);
void(dJointSetPUAnchorOffset)(struct dxJoint*,double,double,double,double,double,double);
void(dJointAddHinge2Torques)(struct dxJoint*,double,double);
void(dGeomHeightfieldDataBuildSingle)(struct dxHeightfieldData*,const float*,int,double,double,int,int,double,double,double,int);
int(dBodyIsEnabled)(struct dxBody*);
int(dFactorCholesky)(double*,int);
double(dJointGetFixedParam)(struct dxJoint*,int);
void(dStopwatchReset)(struct dStopwatch*);
void(dWorldSetDamping)(struct dxWorld*,double,double);
void(dJointSetFixed)(struct dxJoint*);
void(dJointGetHinge2Anchor2)(struct dxJoint*,double[dV3E__MAX]);
void(dThreadingFreeImplementation)(struct dxThreadingImplementation*);
double(dBodyGetAutoDisableTime)(struct dxBody*);
void(dJointSetLMotorNumAxes)(struct dxJoint*,int);
void(dJointDestroy)(struct dxJoint*);
unsigned long(dGeomGetCategoryBits)(struct dxGeom*);
void(dBodySetGravityMode)(struct dxBody*,int);
void(dStopwatchStart)(struct dStopwatch*);
void(dSolveL1)(const double*,double*,int,int);
double(dDot)(const double*,const double*,int);
void(dJointGetLMotorAxis)(struct dxJoint*,int,double[dV3E__MAX]);
int(dJointGetLMotorNumAxes)(struct dxJoint*);
void(dMassSetCappedCylinderTotal)(struct dMass*,double,int,double,double);
struct dxThreadingThreadPool*(dThreadingAllocateThreadPool)(unsigned int,unsigned long,unsigned int,void*);
void(dBodySetGyroscopicMode)(struct dxBody*,int);
struct dxJoint*(dJointCreateHinge)(struct dxWorld*,struct dxJointGroup*);
void(dMassSetCapsule)(struct dMass*,double,int,double,double);
void(dSpaceSetCleanup)(struct dxSpace*,int);
int(*dGeomTriMeshGetCallback(struct dxGeom*))(struct dxGeom*,struct dxGeom*,int);
void(dBodyVectorFromWorld)(struct dxBody*,double,double,double,double[dV3E__MAX]);
double(dTimerResolution)();
void(dJointAddPistonForce)(struct dxJoint*,double);
double(dWorldGetMaxAngularSpeed)(struct dxWorld*);
void(dMassSetCappedCylinder)(struct dMass*,double,int,double,double);
void(dGeomRayGet)(struct dxGeom*,double[dV3E__MAX],double[dV3E__MAX]);
void(dBodySetTorque)(struct dxBody*,double,double,double);
void(dBodySetLinearDampingThreshold)(struct dxBody*,double);
const double*(dBodyGetTorque)(struct dxBody*);
int(dSpaceGetNumGeoms)(struct dxSpace*);
struct dxJoint*(dJointCreateContact)(struct dxWorld*,struct dxJointGroup*,const struct dContact*);
int(dGeomRayGetClosestHit)(struct dxGeom*);
void(dGeomRayGetParams)(struct dxGeom*,int*,int*);
void(dThreadingImplementationShutdownProcessing)(struct dxThreadingImplementation*);
void(dGeomSetOffsetWorldPosition)(struct dxGeom*,double,double,double);
struct dxJoint*(dJointCreatePU)(struct dxWorld*,struct dxJointGroup*);
void(dJointSetHingeParam)(struct dxJoint*,int,double);
void(dBodyGetPosRelPoint)(struct dxBody*,double,double,double,double[dV3E__MAX]);
void(dJointSetAMotorAngle)(struct dxJoint*,int,double);
void(dGeomGetQuaternion)(struct dxGeom*,double[dQUE__MAX]);
void(dMassSetZero)(struct dMass*);
void(dBodySetAutoDisableDefaults)(struct dxBody*);
void(dJointSetBallAnchor2)(struct dxJoint*,double,double,double);
struct dxThreadingImplementation*(dThreadingAllocateSelfThreadedImplementation)();
struct dxJointGroup*(dJointGroupCreate)(int);
double(dWorldGetLinearDampingThreshold)(struct dxWorld*);
void(dJointSetTransmissionAxis)(struct dxJoint*,double,double,double);
double(dJointGetDHingeDistance)(struct dxJoint*);
void(dJointGetBallAnchor2)(struct dxJoint*,double[dV3E__MAX]);
void(dWorldExportDIF)(struct dxWorld*,struct _IO_FILE*,const char*);
void(dThreadingFreeThreadPool)(struct dxThreadingThreadPool*);
void(dThreadingThreadPoolServeMultiThreadedImplementation)(struct dxThreadingThreadPool*,struct dxThreadingImplementation*);
void(dExternalThreadingServeMultiThreadedImplementation)(struct dxThreadingImplementation*,void(readiness_callback)(void*),void*);
struct dxThreadingImplementation*(dThreadingAllocateMultiThreadedImplementation)();
double(dJointGetAMotorAngle)(struct dxJoint*,int);
void(dJointSetDBallAnchor1)(struct dxJoint*,double,double,double);
void(dSetValue)(double*,int,double);
void(dGeomSetQuaternion)(struct dxGeom*,const double[dQUE__MAX]);
void(dJointGetDBallAnchor1)(struct dxJoint*,double[dV3E__MAX]);
void(dJointGetDBallAnchor2)(struct dxJoint*,double[dV3E__MAX]);
void*(dGeomGetClassData)(struct dxGeom*);
void(dNormalize3)(double[dV3E__MAX]);
void(dClosestLineSegmentPoints)(const double[dV3E__MAX],const double[dV3E__MAX],const double[dV3E__MAX],const double[dV3E__MAX],double[dV3E__MAX],double[dV3E__MAX]);
void(dJointGetSliderAxis)(struct dxJoint*,double[dV3E__MAX]);
void(dGeomTriMeshDataBuildSingle)(struct dxTriMeshData*,const void*,int,int,const void*,int,int);
void(dGeomHeightfieldDataBuildShort)(struct dxHeightfieldData*,const short*,int,double,double,int,int,double,double,double,int);
void(dJointSetTransmissionAxis1)(struct dxJoint*,double,double,double);
void(dJointSetAMotorAxis)(struct dxJoint*,int,int,double,double,double);
void(dGeomHeightfieldDataDestroy)(struct dxHeightfieldData*);
double(dJointGetPUAngle1Rate)(struct dxJoint*);
struct dxHeightfieldData*(dGeomHeightfieldDataCreate)();
struct dxGeom*(dCreateHeightfield)(struct dxSpace*,struct dxHeightfieldData*,int);
int(dGeomTransformGetInfo)(struct dxGeom*);
int(dGeomTransformGetCleanup)(struct dxGeom*);
void(dGeomTransformSetCleanup)(struct dxGeom*,int);
struct dxGeom*(dGeomTransformGetGeom)(struct dxGeom*);
struct dxGeom*(dCreateGeomTransform)(struct dxSpace*);
void(dGeomTriMeshDataUpdate)(struct dxTriMeshData*);
int(dGeomTriMeshGetTriangleCount)(struct dxGeom*);
void(dMakeRandomVector)(double*,int,double);
void(dGeomTriMeshGetTriangle)(struct dxGeom*,int,double*[dV3E__MAX],double*[dV3E__MAX],double*[dV3E__MAX]);
struct dxTriMeshData*(dGeomTriMeshGetTriMeshDataID)(struct dxGeom*);
void(dGeomTriMeshEnableTC)(struct dxGeom*,int,int);
struct dxTriMeshData*(dGeomTriMeshGetData)(struct dxGeom*);
void(dGeomTriMeshSetData)(struct dxGeom*,struct dxTriMeshData*);
struct dxGeom*(dCreateTriMesh)(struct dxSpace*,struct dxTriMeshData*,int(Callback)(struct dxGeom*,struct dxGeom*,int),void(ArrayCallback)(struct dxGeom*,struct dxGeom*,const int*,int),int(RayCallback)(struct dxGeom*,struct dxGeom*,int,double,double));
int(*dGeomTriMeshGetTriMergeCallback(struct dxGeom*))(struct dxGeom*,int,int);
void(dJointSetTransmissionAnchor1)(struct dxJoint*,double,double,double);
void(dGeomTriMeshSetTriMergeCallback)(struct dxGeom*,int(Callback)(struct dxGeom*,int,int));
double(dJointGetPUParam)(struct dxJoint*,int);
void(*dGeomTriMeshGetArrayCallback(struct dxGeom*))(struct dxGeom*,struct dxGeom*,const int*,int);
void(dGeomTriMeshSetArrayCallback)(struct dxGeom*,void(ArrayCallback)(struct dxGeom*,struct dxGeom*,const int*,int));
struct dxJoint*(dJointCreateUniversal)(struct dxWorld*,struct dxJointGroup*);
void(dJointGetPRAxis1)(struct dxJoint*,double[dV3E__MAX]);
void(dJointGetTransmissionAnchor1)(struct dxJoint*,double[dV3E__MAX]);
double(dBodyGetMaxAngularSpeed)(struct dxBody*);
void(dGeomTriMeshDataSetBuffer)(struct dxTriMeshData*,unsigned char*);
void(dGeomTriMeshDataPreprocess)(struct dxTriMeshData*);
void(dHashSpaceSetLevels)(struct dxSpace*,int,int);
void(dGeomTriMeshDataBuildSimple)(struct dxTriMeshData*,const double*,int,const unsigned int*,int);
void(dJointSetFeedback)(struct dxJoint*,struct dJointFeedback*);
void(dGeomTriMeshDataBuildDouble)(struct dxTriMeshData*,const void*,int,int,const void*,int,int);
void(dGeomHeightfieldDataSetBounds)(struct dxHeightfieldData*,double,double);
void(dRFromZAxis)(double[dM3E__MAX],double,double,double);
void(dBodySetData)(struct dxBody*,void*);
void(dGeomTriMeshSetLastTransform)(struct dxGeom*,double[dM4E__MAX]);
double(dJointGetHinge2Angle2Rate)(struct dxJoint*);
void(dGeomTriMeshDataSet)(struct dxTriMeshData*,int,void*);
void(dGeomTriMeshDataDestroy)(struct dxTriMeshData*);
struct dxTriMeshData*(dGeomTriMeshDataCreate)();
void(dGeomRaySetClosestHit)(struct dxGeom*,int);
int(dGeomRayGetBackfaceCull)(struct dxGeom*);
int(dGeomRayGetFirstContact)(struct dxGeom*);
void(dMakeRandomMatrix)(double*,int,int,double);
void(dGeomRaySet)(struct dxGeom*,double,double,double,double,double,double);
void(dGeomCylinderGetParams)(struct dxGeom*,double*,double*);
void(dGeomCylinderSetParams)(struct dxGeom*,double,double);
struct dxGeom*(dCreateCylinder)(struct dxSpace*,double,double);
double(dGeomCapsulePointDepth)(struct dxGeom*,double,double,double);
void(dGeomCapsuleGetParams)(struct dxGeom*,double*,double*);
void(dGeomCapsuleSetParams)(struct dxGeom*,double,double);
void(dGeomPlaneGetParams)(struct dxGeom*,double[dV4E__MAX]);
struct dxGeom*(dCreatePlane)(struct dxSpace*,double,double,double,double);
void(dMassSetCapsuleTotal)(struct dMass*,double,int,double,double);
void(dGeomBoxGetLengths)(struct dxGeom*,double[dV3E__MAX]);
void(dGeomBoxSetLengths)(struct dxGeom*,double,double,double);
struct dxGeom*(dCreateBox)(struct dxSpace*,double,double,double);
void(dGeomSetConvex)(struct dxGeom*,const double*,unsigned int,const double*,unsigned int,const unsigned int*);
double(dGeomSpherePointDepth)(struct dxGeom*,double,double,double);
void(dSpaceCollide2)(struct dxGeom*,struct dxGeom*,void*,void(callback)(void*,struct dxGeom*,struct dxGeom*));
int(dCollide)(struct dxGeom*,struct dxGeom*,int,struct dContactGeom*,int);
void(dSpaceClean)(struct dxSpace*);
enum dJointType(dJointGetType)(struct dxJoint*);
void(dGeomCopyOffsetRotation)(struct dxGeom*,double[dM3E__MAX]);
const double*(dGeomGetOffsetRotation)(struct dxGeom*);
void(dGeomCopyOffsetPosition)(struct dxGeom*,double[dV3E__MAX]);
void(dJointSetHinge2Axes)(struct dxJoint*,const double*,const double*);
const double*(dGeomGetOffsetPosition)(struct dxGeom*);
struct dxJoint*(dJointCreateDHinge)(struct dxWorld*,struct dxJointGroup*);
double(dJointGetAMotorAngleRate)(struct dxJoint*,int);
void(dGeomClearOffset)(struct dxGeom*);
void(dGeomSetOffsetWorldQuaternion)(struct dxGeom*,const double[dQUE__MAX]);
void(dGeomSetOffsetWorldRotation)(struct dxGeom*,const double[dM3E__MAX]);
void(dGeomSetOffsetQuaternion)(struct dxGeom*,const double[dQUE__MAX]);
void(dGeomSetOffsetRotation)(struct dxGeom*,const double[dM3E__MAX]);
void(dGeomSetOffsetPosition)(struct dxGeom*,double,double,double);
void(dJointSetPistonParam)(struct dxJoint*,int,double);
void(dJointSetHingeAnchorDelta)(struct dxJoint*,double,double,double,double,double,double);
void(dGeomVectorToWorld)(struct dxGeom*,double,double,double,double[dV3E__MAX]);
void(dGeomGetPosRelPoint)(struct dxGeom*,double,double,double,double[dV3E__MAX]);
int(dGeomLowLevelControl)(struct dxGeom*,int,int,void*,int*);
int(dGeomGetClass)(struct dxGeom*);
const double*(dGeomGetRotation)(struct dxGeom*);
void(dJointGetPistonAnchor)(struct dxJoint*,double[dV3E__MAX]);
const double*(dGeomGetPosition)(struct dxGeom*);
double(dJointGetBallParam)(struct dxJoint*,int);
void(dGeomSetBody)(struct dxGeom*,struct dxBody*);
int(dSpaceGetClass)(struct dxSpace*);
void(dStopwatchStop)(struct dStopwatch*);
struct dxGeom*(dSpaceGetGeom)(struct dxSpace*,int);
void(dGeomGetOffsetQuaternion)(struct dxGeom*,double[dQUE__MAX]);
double(dTimerTicksPerSecond)();
int(dRandInt)(int);
void(dSpaceAdd)(struct dxSpace*,struct dxGeom*);
void(dBodySetMaxAngularSpeed)(struct dxBody*,double);
void(dSpaceSetSublevel)(struct dxSpace*,int);
void(dSetMessageHandler)(void(fn)(int,const char*,__builtin_va_list));
struct dxSpace*(dSweepAndPruneSpaceCreate)(struct dxSpace*,int);
double(dJointGetPistonPosition)(struct dxJoint*);
struct dxSpace*(dHashSpaceCreate)(struct dxSpace*);
int(dAreConnectedExcluding)(struct dxBody*,struct dxBody*,int);
int(dAreConnected)(struct dxBody*,struct dxBody*);
double(dJointGetDHingeParam)(struct dxJoint*,int);
double(dJointGetUniversalAngle1Rate)(struct dxJoint*);
void(dJointGetDHingeAnchor1)(struct dxJoint*,double[dV3E__MAX]);
void(dJointSetDHingeAnchor2)(struct dxJoint*,double,double,double);
void(dMassAdd)(struct dMass*,const struct dMass*);
double(dBodyGetAutoDisableLinearThreshold)(struct dxBody*);
double(dJointGetDBallParam)(struct dxJoint*,int);
void(dInitODE)();
void(dBodyCopyQuaternion)(struct dxBody*,double[dQUE__MAX]);
void(dJointSetDBallParam)(struct dxJoint*,int,double);
double(dJointGetDBallDistance)(struct dxJoint*);
void(dJointSetDBallAnchor2)(struct dxJoint*,double,double,double);
void(dJointGetPistonAnchor2)(struct dxJoint*,double[dV3E__MAX]);
void(dWorldDestroy)(struct dxWorld*);
void(dJointSetTransmissionRadius2)(struct dxJoint*,double);
void(dJointSetTransmissionRadius1)(struct dxJoint*,double);
void(dBodyCopyPosition)(struct dxBody*,double[dV3E__MAX]);
void(dBodySetFiniteRotationMode)(struct dxBody*,int);
double(dJointGetTransmissionRadius1)(struct dxJoint*);
void(dBodySetDamping)(struct dxBody*,double,double);
double(dJointGetTransmissionAngle1)(struct dxJoint*);
int(dWorldUseSharedWorkingMemory)(struct dxWorld*,struct dxWorld*);
struct dxJoint*(dJointCreateHinge2)(struct dxWorld*,struct dxJointGroup*);
int(dJointGetTransmissionMode)(struct dxJoint*);
void(dJointGetTransmissionAxis2)(struct dxJoint*,double[dV3E__MAX]);
void(dGeomHeightfieldDataBuildByte)(struct dxHeightfieldData*,const unsigned char*,int,double,double,int,int,double,double,double,int);
void(dJointGetTransmissionContactPoint2)(struct dxJoint*,double[dV3E__MAX]);
void(dJointSetPUAxisP)(struct dxJoint*,double,double,double);
void(dJointGetTransmissionContactPoint1)(struct dxJoint*,double[dV3E__MAX]);
int(dGeomIsOffset)(struct dxGeom*);
struct dxGeom*(dCreateGeom)(int);
void(dJointGetAMotorAxis)(struct dxJoint*,int,double[dV3E__MAX]);
double(dJointGetPistonParam)(struct dxJoint*,int);
int(dWorldQuickStep)(struct dxWorld*,double);
void(dJointGetPistonAxis)(struct dxJoint*,double[dV3E__MAX]);
void(dJointSetTransmissionBacklash)(struct dxJoint*,double);
void(dGeomCopyPosition)(struct dxGeom*,double[dV3E__MAX]);
double(dJointGetPistonAngle)(struct dxJoint*);
double(dJointGetPistonPositionRate)(struct dxJoint*);
int(*dGeomTriMeshGetRayCallback(struct dxGeom*))(struct dxGeom*,struct dxGeom*,int,double,double);
double(dJointGetPUAngle2Rate)(struct dxJoint*);
void(dWorldGetGravity)(struct dxWorld*,double[dV3E__MAX]);
void(dJointGetPUAxis2)(struct dxJoint*,double[dV3E__MAX]);
void(dJointGetPUAxis1)(struct dxJoint*,double[dV3E__MAX]);
void(dWorldSetAutoDisableFlag)(struct dxWorld*,int);
void(dWorldSetERP)(struct dxWorld*,double);
void(dJointSetData)(struct dxJoint*,void*);
double(dJointGetTransmissionBacklash)(struct dxJoint*);
void(dJointGetPUAnchor)(struct dxJoint*,double[dV3E__MAX]);
double(dJointGetPRParam)(struct dxJoint*,int);
void(dGeomTriMeshSetCallback)(struct dxGeom*,int(Callback)(struct dxGeom*,struct dxGeom*,int));
struct dxJoint*(dJointCreateAMotor)(struct dxWorld*,struct dxJointGroup*);
double(dJointGetPRPositionRate)(struct dxJoint*);
double(dJointGetUniversalAngle2Rate)(struct dxJoint*);
void(dJointGetDHingeAnchor2)(struct dxJoint*,double[dV3E__MAX]);
double(dJointGetUniversalAngle1)(struct dxJoint*);
double(dJointGetTransmissionAngle2)(struct dxJoint*);
void(dJointGetUniversalAnchor2)(struct dxJoint*,double[dV3E__MAX]);
void*(dGeomTriMeshDataGet)(struct dxTriMeshData*,int);
void(dJointSetBallAnchor)(struct dxJoint*,double,double,double);
double(dJointGetHinge2Angle1Rate)(struct dxJoint*);
double(dJointGetHinge2Angle2)(struct dxJoint*);
void(dJointGetHinge2Axis2)(struct dxJoint*,double[dV3E__MAX]);
void(dJointGetHinge2Axis1)(struct dxJoint*,double[dV3E__MAX]);
double(dJointGetSliderPositionRate)(struct dxJoint*);
double(dJointGetSliderPosition)(struct dxJoint*);
double(dJointGetHingeAngle)(struct dxJoint*);
void(dClearUpperTriangle)(double*,int);
void(dJointGetHingeAnchor2)(struct dxJoint*,double[dV3E__MAX]);
void(dJointGetHingeAnchor)(struct dxJoint*,double[dV3E__MAX]);
void(dJointGetBallAnchor)(struct dxJoint*,double[dV3E__MAX]);
void(dJointSetPlane2DYParam)(struct dxJoint*,int,double);
void(dJointSetAMotorMode)(struct dxJoint*,int);
void(dGeomHeightfieldDataBuildCallback)(struct dxHeightfieldData*,void*,double(pCallback)(void*,int,int),double,double,int,int,double,double,double,int);
void(dJointAddSliderForce)(struct dxJoint*,double);
void(dJointSetAMotorNumAxes)(struct dxJoint*,int);
void(dJointSetFixedParam)(struct dxJoint*,int,double);
void(dGeomVectorFromWorld)(struct dxGeom*,double,double,double,double[dV3E__MAX]);
void(dJointSetPistonAxis)(struct dxJoint*,double,double,double);
void(dJointSetPistonAnchorOffset)(struct dxJoint*,double,double,double,double,double,double);
void(dBodyAddForce)(struct dxBody*,double,double,double);
int(dWorldGetAutoDisableAverageSamplesCount)(struct dxWorld*);
void(*dGetFreeHandler())(void*,unsigned long);
void(dWorldImpulseToForce)(struct dxWorld*,double,double,double,double,double[dV3E__MAX]);
unsigned long(dRandGetSeed)();
void(dRFrom2Axes)(double[dM3E__MAX],double,double,double,double,double,double);
void(dBodySetDampingDefaults)(struct dxBody*);
double(dBodyGetAngularDampingThreshold)(struct dxBody*);
void(dFactorLDLT)(double*,double*,int,int);
double(dBodyGetLinearDampingThreshold)(struct dxBody*);
void(dJointAddPRTorque)(struct dxJoint*,double);
void(dJointGetHingeAxis)(struct dxJoint*,double[dV3E__MAX]);
void(dRFromEulerAngles)(double[dM3E__MAX],double,double,double);
double(dJointGetPRPosition)(struct dxJoint*);
void(dWorldSetLinearDamping)(struct dxWorld*,double);
void(*dGetDebugHandler())(int,const char*,__builtin_va_list);
void(dJointSetPRParam)(struct dxJoint*,int,double);
double(dWorldGetAutoDisableAngularThreshold)(struct dxWorld*);
void(dCleanupODEAllDataForThread)();
struct dxJoint*(dJointCreateDBall)(struct dxWorld*,struct dxJointGroup*);
void(dGeomRaySetFirstContact)(struct dxGeom*,int);
void(dWorldSetStepIslandsProcessingMaxThreadCount)(struct dxWorld*,unsigned int);
void(dJointSetPistonAnchor)(struct dxJoint*,double,double,double);
void*(*dGetAllocHandler())(unsigned long);
void(dLDLTAddTL)(double*,double*,const double*,int,int);
void(dSpaceDestroy)(struct dxSpace*);
void(dNormalize4)(double[dV4E__MAX]);
void*(*dGetReallocHandler())(void*,unsigned long,unsigned long);
int(dBodyGetAutoDisableFlag)(struct dxBody*);
double(dJointGetHingeAngleRate)(struct dxJoint*);
int(dWorldStep)(struct dxWorld*,double);
void(dJointSetPUAxis1)(struct dxJoint*,double,double,double);
void(dMassSetSphere)(struct dMass*,double,double);
void(dRfromQ)(double[dM3E__MAX],const double[dQUE__MAX]);
int(dSpaceQuery)(struct dxSpace*,struct dxGeom*);
void(dTimerReport)(struct _IO_FILE*,int);
double(dJointGetPRAngle)(struct dxJoint*);
int(dInvertPDMatrix)(const double*,double*,int);
void(dMultiply2)(double*,const double*,const double*,int,int,int);
int(dJointGetNumBodies)(struct dxJoint*);
int(dSafeNormalize3)(double[dV3E__MAX]);
void(dBodyGetPointVel)(struct dxBody*,double,double,double,double[dV3E__MAX]);
void(dJointSetUniversalAnchor)(struct dxJoint*,double,double,double);
void(dError)(int,const char*,...);
void(dJointGetPUAxisP)(struct dxJoint*,double[dV3E__MAX]);
int(dTestRand)();
double(dMaxDifference)(const double*,const double*,int,int);
const double*(dBodyGetQuaternion)(struct dxBody*);
int(dGeomIsSpace)(struct dxGeom*);
void*(dRealloc)(void*,unsigned long,unsigned long);
void(dBodySetAngularDamping)(struct dxBody*,double);
int(dWorldGetAutoDisableSteps)(struct dxWorld*);
void(dMassAdjust)(struct dMass*,double);
void(dJointSetPRAnchor)(struct dxJoint*,double,double,double);
struct dxJoint*(dJointCreateTransmission)(struct dxWorld*,struct dxJointGroup*);
const char*(dGetConfiguration)();
void(dGeomTransformSetInfo)(struct dxGeom*,int);
double(dJointGetTransmissionRatio)(struct dxJoint*);
int(dIsPositiveDefinite)(const double*,int);
void(dJointSetDHingeAnchor1)(struct dxJoint*,double,double,double);
struct dxWorld*(dBodyGetWorld)(struct dxBody*);
void(dJointAddUniversalTorques)(struct dxJoint*,double,double);
void(dWorldSetAutoDisableTime)(struct dxWorld*,double);
void(dBodyAddRelForceAtRelPos)(struct dxBody*,double,double,double,double,double,double);
void(dThreadingThreadPoolWaitIdleState)(struct dxThreadingThreadPool*);
double(dJointGetPUPositionRate)(struct dxJoint*);
struct dxGeom*(dCreateSphere)(struct dxSpace*,double);
double(dJointGetUniversalParam)(struct dxJoint*,int);
void(dSolveL1T)(const double*,double*,int,int);
int(dJointGetAMotorNumAxes)(struct dxJoint*);
void(dBodySetQuaternion)(struct dxBody*,const double[dQUE__MAX]);
void(dJointSetUniversalParam)(struct dxJoint*,int,double);
void(dJointSetPUAnchor)(struct dxJoint*,double,double,double);
void(dSetAllocHandler)(void*(fn)(unsigned long));
double(dBodyGetLinearDamping)(struct dxBody*);
void(dJointSetPRAxis1)(struct dxJoint*,double,double,double);
void*(dBodyGetData)(struct dxBody*);
struct dxGeom*(dCreateCapsule)(struct dxSpace*,double,double);
double(dWorldGetAutoDisableLinearThreshold)(struct dxWorld*);
double(dJointGetPUAngle1)(struct dxJoint*);
void(dSetFreeHandler)(void(fn)(void*,unsigned long));
void(dBodySetLinearVel)(struct dxBody*,double,double,double);
int(dInitODE2)(unsigned int);
void(dSetReallocHandler)(void*(fn)(void*,unsigned long,unsigned long));
void(dFree)(void*,unsigned long);
struct dxSpace*(dQuadTreeSpaceCreate)(struct dxSpace*,const double[dV3E__MAX],const double[dV3E__MAX],int);
const double*(dBodyGetLinearVel)(struct dxBody*);
void(dBodySetMass)(struct dxBody*,const struct dMass*);
struct dxJoint*(dJointCreateLMotor)(struct dxWorld*,struct dxJointGroup*);
void(dTimerStart)(const char*);
void(dTimerEnd)();
void(dQMultiply0)(double[dQUE__MAX],const double[dQUE__MAX],const double[dQUE__MAX]);
void(dGeomTriMeshClearTCCache)(struct dxGeom*);
void(dMassSetSphereTotal)(struct dMass*,double,double);
void(dMassSetTrimeshTotal)(struct dMass*,double,struct dxGeom*);
void(dSpaceRemove)(struct dxSpace*,struct dxGeom*);
void(dRSetIdentity)(double[dM3E__MAX]);
double(dMaxDifferenceLowerTriangle)(const double*,const double*,int);
void(dWorldSetQuickStepW)(struct dxWorld*,double);
void(dBodyAddRelTorque)(struct dxBody*,double,double,double);
void(dQFromAxisAndAngle)(double[dQUE__MAX],double,double,double,double);
void(dJointGetPUAngles)(struct dxJoint*,double*,double*);
void(*dGetErrorHandler())(int,const char*,__builtin_va_list);
void(dJointSetTransmissionParam)(struct dxJoint*,int,double);
double(dWorldGetContactMaxCorrectingVel)(struct dxWorld*);
void(dBodySetForce)(struct dxBody*,double,double,double);
void(dMassSetCylinderTotal)(struct dMass*,double,int,double,double);
void(dWorldSetAutoDisableAngularThreshold)(struct dxWorld*,double);
void(dWorldSetAutoDisableSteps)(struct dxWorld*,int);
double(dWorldGetAngularDampingThreshold)(struct dxWorld*);
void(dWorldSetAngularDampingThreshold)(struct dxWorld*,double);
double(dWorldGetLinearDamping)(struct dxWorld*);
void(dJointSetDHingeAxis)(struct dxJoint*,double,double,double);
double(dBodyGetAutoDisableAngularThreshold)(struct dxBody*);
void(dBodyVectorToWorld)(struct dxBody*,double,double,double,double[dV3E__MAX]);
void(dBodySetAutoDisableAverageSamplesCount)(struct dxBody*,unsigned int);
double(dWorldGetCFM)(struct dxWorld*);
void(dBodySetAutoDisableSteps)(struct dxBody*,int);
void(dBodySetPosition)(struct dxBody*,double,double,double);
void(dWorldSetContactMaxCorrectingVel)(struct dxWorld*,double);
void(dWorldSetLinearDampingThreshold)(struct dxWorld*,double);
struct dxGeom*(dGeomGetBodyNext)(struct dxGeom*);
int(dGeomIsEnabled)(struct dxGeom*);
double(dJointGetTransmissionRadius2)(struct dxJoint*);
void(dBodyDisable)(struct dxBody*);
struct dxGeom*(dBodyGetFirstGeom)(struct dxBody*);
void(dQMultiply3)(double[dQUE__MAX],const double[dQUE__MAX],const double[dQUE__MAX]);
int(dSpaceGetSublevel)(struct dxSpace*);
void(dSetZero)(double*,int);
void(dBodySetFiniteRotationAxis)(struct dxBody*,double,double,double);
void(dJointSetHinge2Anchor)(struct dxJoint*,double,double,double);
void(dJointSetUniversalAxis1Offset)(struct dxJoint*,double,double,double,double,double);
void(dJointSetPRAxis2)(struct dxJoint*,double,double,double);
void(dWorldSetAutoDisableAverageSamplesCount)(struct dxWorld*,unsigned int);
]])
local CLIB = ffi.load(_G.FFI_LIB or "ode")
local library = {}
library = {
	JointSetSliderAxisDelta = CLIB.dJointSetSliderAxisDelta,
	JointGetPistonAngleRate = CLIB.dJointGetPistonAngleRate,
	ConnectingJointList = CLIB.dConnectingJointList,
	GeomTriMeshIsTCEnabled = CLIB.dGeomTriMeshIsTCEnabled,
	JointGetHinge2Anchor = CLIB.dJointGetHinge2Anchor,
	PlaneSpace = CLIB.dPlaneSpace,
	WorldGetData = CLIB.dWorldGetData,
	JointSetTransmissionAnchor2 = CLIB.dJointSetTransmissionAnchor2,
	BodyGetAutoDisableAverageSamplesCount = CLIB.dBodyGetAutoDisableAverageSamplesCount,
	BodySetAutoDisableAngularThreshold = CLIB.dBodySetAutoDisableAngularThreshold,
	GeomTriMeshDataBuildDouble1 = CLIB.dGeomTriMeshDataBuildDouble1,
	JointGroupDestroy = CLIB.dJointGroupDestroy,
	SetErrorHandler = CLIB.dSetErrorHandler,
	GeomTransformSetGeom = CLIB.dGeomTransformSetGeom,
	JointGetPRAnchor = CLIB.dJointGetPRAnchor,
	GeomPlanePointDepth = CLIB.dGeomPlanePointDepth,
	GeomRayGetLength = CLIB.dGeomRayGetLength,
	JointGetUniversalAngle2 = CLIB.dJointGetUniversalAngle2,
	BoxBox = CLIB.dBoxBox,
	GeomTriMeshSetRayCallback = CLIB.dGeomTriMeshSetRayCallback,
	BodySetAutoDisableTime = CLIB.dBodySetAutoDisableTime,
	GeomSetCategoryBits = CLIB.dGeomSetCategoryBits,
	JointSetPUParam = CLIB.dJointSetPUParam,
	OrthogonalizeR = CLIB.dOrthogonalizeR,
	GeomRaySetBackfaceCull = CLIB.dGeomRaySetBackfaceCull,
	GeomHeightfieldGetHeightfieldData = CLIB.dGeomHeightfieldGetHeightfieldData,
	GeomTriMeshGetPoint = CLIB.dGeomTriMeshGetPoint,
	WorldSetContactSurfaceLayer = CLIB.dWorldSetContactSurfaceLayer,
	BodyGetPosition = CLIB.dBodyGetPosition,
	GeomDisable = CLIB.dGeomDisable,
	JointSetLMotorAxis = CLIB.dJointSetLMotorAxis,
	JointGetTransmissionAnchor2 = CLIB.dJointGetTransmissionAnchor2,
	BodyGetGyroscopicMode = CLIB.dBodyGetGyroscopicMode,
	JointSetDBallDistance = CLIB.dJointSetDBallDistance,
	BodyGetFiniteRotationAxis = CLIB.dBodyGetFiniteRotationAxis,
	BodyDestroy = CLIB.dBodyDestroy,
	HashSpaceGetLevels = CLIB.dHashSpaceGetLevels,
	BodyGetJoint = CLIB.dBodyGetJoint,
	GeomMoved = CLIB.dGeomMoved,
	Alloc = CLIB.dAlloc,
	JointGetFeedback = CLIB.dJointGetFeedback,
	CreateConvex = CLIB.dCreateConvex,
	WorldSetMaxAngularSpeed = CLIB.dWorldSetMaxAngularSpeed,
	JointCreateFixed = CLIB.dJointCreateFixed,
	StopwatchTime = CLIB.dStopwatchTime,
	JointSetPUAxis3 = CLIB.dJointSetPUAxis3,
	JointCreateBall = CLIB.dJointCreateBall,
	WorldGetContactSurfaceLayer = CLIB.dWorldGetContactSurfaceLayer,
	BodyGetNextGeom = CLIB.dBodyGetNextGeom,
	JointCreateSlider = CLIB.dJointCreateSlider,
	WorldCreate = CLIB.dWorldCreate,
	JointGetHingeParam = CLIB.dJointGetHingeParam,
	JointGetAMotorParam = CLIB.dJointGetAMotorParam,
	JointIsEnabled = CLIB.dJointIsEnabled,
	BodySetKinematic = CLIB.dBodySetKinematic,
	MassSetBox = CLIB.dMassSetBox,
	AllocateODEDataForThread = CLIB.dAllocateODEDataForThread,
	BodySetAngularDampingThreshold = CLIB.dBodySetAngularDampingThreshold,
	GeomSetPosition = CLIB.dGeomSetPosition,
	JointSetHinge2Axis1 = CLIB.dJointSetHinge2Axis1,
	JointSetLMotorParam = CLIB.dJointSetLMotorParam,
	JointGroupEmpty = CLIB.dJointGroupEmpty,
	JointSetAMotorParam = CLIB.dJointSetAMotorParam,
	JointSetTransmissionMode = CLIB.dJointSetTransmissionMode,
	CreateRay = CLIB.dCreateRay,
	JointGetTransmissionAxis = CLIB.dJointGetTransmissionAxis,
	GeomPlaneSetParams = CLIB.dGeomPlaneSetParams,
	JointGetLMotorParam = CLIB.dJointGetLMotorParam,
	JointGetPUPosition = CLIB.dJointGetPUPosition,
	Multiply1 = CLIB.dMultiply1,
	JointGetHinge2Angle1 = CLIB.dJointGetHinge2Angle1,
	SafeNormalize4 = CLIB.dSafeNormalize4,
	BodyGetAngularVel = CLIB.dBodyGetAngularVel,
	GeomGetCollideBits = CLIB.dGeomGetCollideBits,
	BodyGetMass = CLIB.dBodyGetMass,
	GeomGetAABB = CLIB.dGeomGetAABB,
	JointSetSliderAxis = CLIB.dJointSetSliderAxis,
	GeomGetData = CLIB.dGeomGetData,
	Debug = CLIB.dDebug,
	BodyAddForceAtRelPos = CLIB.dBodyAddForceAtRelPos,
	JointSetUniversalAxis2Offset = CLIB.dJointSetUniversalAxis2Offset,
	MassSetBoxTotal = CLIB.dMassSetBoxTotal,
	BodySetRotation = CLIB.dBodySetRotation,
	GeomSetCollideBits = CLIB.dGeomSetCollideBits,
	JointCreatePR = CLIB.dJointCreatePR,
	BodyAddTorque = CLIB.dBodyAddTorque,
	BodyGetRotation = CLIB.dBodyGetRotation,
	BodyEnable = CLIB.dBodyEnable,
	JointSetHingeAxisOffset = CLIB.dJointSetHingeAxisOffset,
	BodySetAngularVel = CLIB.dBodySetAngularVel,
	JointGetSliderParam = CLIB.dJointGetSliderParam,
	JointSetSliderParam = CLIB.dJointSetSliderParam,
	JointSetPistonAxisDelta = CLIB.dJointSetPistonAxisDelta,
	MassCheck = CLIB.dMassCheck,
	BodyGetAutoDisableSteps = CLIB.dBodyGetAutoDisableSteps,
	WorldSetStepMemoryManager = CLIB.dWorldSetStepMemoryManager,
	RemoveRowCol = CLIB.dRemoveRowCol,
	JointSetPUAxis2 = CLIB.dJointSetPUAxis2,
	JointGetPUAxis3 = CLIB.dJointGetPUAxis3,
	CloseODE = CLIB.dCloseODE,
	JointGetPRAngleRate = CLIB.dJointGetPRAngleRate,
	GeomBoxPointDepth = CLIB.dGeomBoxPointDepth,
	GeomSetData = CLIB.dGeomSetData,
	WorldGetStepIslandsProcessingMaxThreadCount = CLIB.dWorldGetStepIslandsProcessingMaxThreadCount,
	JointSetBallParam = CLIB.dJointSetBallParam,
	QMultiply1 = CLIB.dQMultiply1,
	BodyAddRelForce = CLIB.dBodyAddRelForce,
	GeomGetBody = CLIB.dGeomGetBody,
	GeomGetRelPointPos = CLIB.dGeomGetRelPointPos,
	GeomEnable = CLIB.dGeomEnable,
	SpaceGetCleanup = CLIB.dSpaceGetCleanup,
	TimerNow = CLIB.dTimerNow,
	WorldSetGravity = CLIB.dWorldSetGravity,
	GetMessageHandler = CLIB.dGetMessageHandler,
	VectorScale = CLIB.dVectorScale,
	LDLTRemove = CLIB.dLDLTRemove,
	RFromAxisAndAngle = CLIB.dRFromAxisAndAngle,
	JointSetHingeAnchor = CLIB.dJointSetHingeAnchor,
	CheckConfiguration = CLIB.dCheckConfiguration,
	BodySetAutoDisableLinearThreshold = CLIB.dBodySetAutoDisableLinearThreshold,
	Rand = CLIB.dRand,
	BoxTouchesBox = CLIB.dBoxTouchesBox,
	QfromR = CLIB.dQfromR,
	MassSetParameters = CLIB.dMassSetParameters,
	DQfromW = CLIB.dDQfromW,
	GeomSphereGetRadius = CLIB.dGeomSphereGetRadius,
	GeomSetRotation = CLIB.dGeomSetRotation,
	RandReal = CLIB.dRandReal,
	BodyGetRelPointPos = CLIB.dBodyGetRelPointPos,
	WorldGetAutoDisableFlag = CLIB.dWorldGetAutoDisableFlag,
	SolveLDLT = CLIB.dSolveLDLT,
	JointGetTransmissionAxis1 = CLIB.dJointGetTransmissionAxis1,
	GeomHeightfieldDataBuildDouble = CLIB.dGeomHeightfieldDataBuildDouble,
	JointAddHingeTorque = CLIB.dJointAddHingeTorque,
	Message = CLIB.dMessage,
	BodyGetForce = CLIB.dBodyGetForce,
	BodyIsKinematic = CLIB.dBodyIsKinematic,
	JointGetBody = CLIB.dJointGetBody,
	JointGetAMotorMode = CLIB.dJointGetAMotorMode,
	GeomGetSpace = CLIB.dGeomGetSpace,
	JointGetPUAngle2 = CLIB.dJointGetPUAngle2,
	SpaceCollide = CLIB.dSpaceCollide,
	JointSetTransmissionAxis2 = CLIB.dJointSetTransmissionAxis2,
	SpaceSetManualCleanup = CLIB.dSpaceSetManualCleanup,
	JointCreatePlane2D = CLIB.dJointCreatePlane2D,
	QMultiply2 = CLIB.dQMultiply2,
	JointSetHingeAxis = CLIB.dJointSetHingeAxis,
	WorldSetQuickStepNumIterations = CLIB.dWorldSetQuickStepNumIterations,
	QSetIdentity = CLIB.dQSetIdentity,
	SetColliderOverride = CLIB.dSetColliderOverride,
	JointDisable = CLIB.dJointDisable,
	WorldGetQuickStepNumIterations = CLIB.dWorldGetQuickStepNumIterations,
	GeomDestroy = CLIB.dGeomDestroy,
	RandSetSeed = CLIB.dRandSetSeed,
	JointCreateNull = CLIB.dJointCreateNull,
	BodyCreate = CLIB.dBodyCreate,
	BodyGetFiniteRotationMode = CLIB.dBodyGetFiniteRotationMode,
	JointGetUniversalAxis2 = CLIB.dJointGetUniversalAxis2,
	Multiply0 = CLIB.dMultiply0,
	WorldSetAutoDisableLinearThreshold = CLIB.dWorldSetAutoDisableLinearThreshold,
	JointSetUniversalAxis2 = CLIB.dJointSetUniversalAxis2,
	JointCreatePiston = CLIB.dJointCreatePiston,
	GeomRaySetLength = CLIB.dGeomRaySetLength,
	WorldSetCFM = CLIB.dWorldSetCFM,
	SpaceGetManualCleanup = CLIB.dSpaceGetManualCleanup,
	SolveCholesky = CLIB.dSolveCholesky,
	JointAddAMotorTorques = CLIB.dJointAddAMotorTorques,
	SetDebugHandler = CLIB.dSetDebugHandler,
	JointGetPRAxis2 = CLIB.dJointGetPRAxis2,
	BodySetAutoDisableFlag = CLIB.dBodySetAutoDisableFlag,
	ConnectingJoint = CLIB.dConnectingJoint,
	GeomCopyRotation = CLIB.dGeomCopyRotation,
	MassRotate = CLIB.dMassRotate,
	BodyAddForceAtPos = CLIB.dBodyAddForceAtPos,
	BodyCopyRotation = CLIB.dBodyCopyRotation,
	JointSetPlane2DXParam = CLIB.dJointSetPlane2DXParam,
	JointAttach = CLIB.dJointAttach,
	WorldSetStepMemoryReservationPolicy = CLIB.dWorldSetStepMemoryReservationPolicy,
	JointGetUniversalAnchor = CLIB.dJointGetUniversalAnchor,
	JointSetPUAnchorDelta = CLIB.dJointSetPUAnchorDelta,
	MassSetCylinder = CLIB.dMassSetCylinder,
	BodyGetRelPointVel = CLIB.dBodyGetRelPointVel,
	GeomTriMeshDataBuildSimple1 = CLIB.dGeomTriMeshDataBuildSimple1,
	BodyGetAngularDamping = CLIB.dBodyGetAngularDamping,
	JointSetHinge2Axis2 = CLIB.dJointSetHinge2Axis2,
	WorldSetData = CLIB.dWorldSetData,
	JointSetTransmissionRatio = CLIB.dJointSetTransmissionRatio,
	WorldGetERP = CLIB.dWorldGetERP,
	GeomSphereSetRadius = CLIB.dGeomSphereSetRadius,
	MassTranslate = CLIB.dMassTranslate,
	GeomHeightfieldSetHeightfieldData = CLIB.dGeomHeightfieldSetHeightfieldData,
	WorldGetAutoDisableTime = CLIB.dWorldGetAutoDisableTime,
	MassSetTrimesh = CLIB.dMassSetTrimesh,
	BodySetDynamic = CLIB.dBodySetDynamic,
	SimpleSpaceCreate = CLIB.dSimpleSpaceCreate,
	BodySetLinearDamping = CLIB.dBodySetLinearDamping,
	ThreadingImplementationCleanupForRestart = CLIB.dThreadingImplementationCleanupForRestart,
	JointGetData = CLIB.dJointGetData,
	JointSetPlane2DAngleParam = CLIB.dJointSetPlane2DAngleParam,
	InfiniteAABB = CLIB.dInfiniteAABB,
	WorldSetAngularDamping = CLIB.dWorldSetAngularDamping,
	GeomRaySetParams = CLIB.dGeomRaySetParams,
	WorldGetAngularDamping = CLIB.dWorldGetAngularDamping,
	PrintMatrix = CLIB.dPrintMatrix,
	GeomTriMeshDataBuildSingle1 = CLIB.dGeomTriMeshDataBuildSingle1,
	BodyAddRelForceAtPos = CLIB.dBodyAddRelForceAtPos,
	WorldGetQuickStepW = CLIB.dWorldGetQuickStepW,
	JointEnable = CLIB.dJointEnable,
	BodyGetNumJoints = CLIB.dBodyGetNumJoints,
	JointGetUniversalAngles = CLIB.dJointGetUniversalAngles,
	JointGetAMotorAxisRel = CLIB.dJointGetAMotorAxisRel,
	GeomTriMeshGetLastTransform = CLIB.dGeomTriMeshGetLastTransform,
	JointGetTransmissionParam = CLIB.dJointGetTransmissionParam,
	JointSetDHingeParam = CLIB.dJointSetDHingeParam,
	JointGetDHingeAxis = CLIB.dJointGetDHingeAxis,
	GeomTriMeshDataGetBuffer = CLIB.dGeomTriMeshDataGetBuffer,
	JointGetUniversalAxis1 = CLIB.dJointGetUniversalAxis1,
	JointSetHinge2Param = CLIB.dJointSetHinge2Param,
	WorldCleanupWorkingMemory = CLIB.dWorldCleanupWorkingMemory,
	JointSetUniversalAxis1 = CLIB.dJointSetUniversalAxis1,
	BodyGetGravityMode = CLIB.dBodyGetGravityMode,
	JointGetHinge2Param = CLIB.dJointGetHinge2Param,
	JointSetPUAnchorOffset = CLIB.dJointSetPUAnchorOffset,
	JointAddHinge2Torques = CLIB.dJointAddHinge2Torques,
	GeomHeightfieldDataBuildSingle = CLIB.dGeomHeightfieldDataBuildSingle,
	BodyIsEnabled = CLIB.dBodyIsEnabled,
	FactorCholesky = CLIB.dFactorCholesky,
	JointGetFixedParam = CLIB.dJointGetFixedParam,
	StopwatchReset = CLIB.dStopwatchReset,
	WorldSetDamping = CLIB.dWorldSetDamping,
	JointSetFixed = CLIB.dJointSetFixed,
	JointGetHinge2Anchor2 = CLIB.dJointGetHinge2Anchor2,
	ThreadingFreeImplementation = CLIB.dThreadingFreeImplementation,
	BodyGetAutoDisableTime = CLIB.dBodyGetAutoDisableTime,
	JointSetLMotorNumAxes = CLIB.dJointSetLMotorNumAxes,
	JointDestroy = CLIB.dJointDestroy,
	GeomGetCategoryBits = CLIB.dGeomGetCategoryBits,
	BodySetGravityMode = CLIB.dBodySetGravityMode,
	StopwatchStart = CLIB.dStopwatchStart,
	SolveL1 = CLIB.dSolveL1,
	Dot = CLIB.dDot,
	JointGetLMotorAxis = CLIB.dJointGetLMotorAxis,
	JointGetLMotorNumAxes = CLIB.dJointGetLMotorNumAxes,
	MassSetCappedCylinderTotal = CLIB.dMassSetCappedCylinderTotal,
	ThreadingAllocateThreadPool = CLIB.dThreadingAllocateThreadPool,
	BodySetGyroscopicMode = CLIB.dBodySetGyroscopicMode,
	JointCreateHinge = CLIB.dJointCreateHinge,
	MassSetCapsule = CLIB.dMassSetCapsule,
	SpaceSetCleanup = CLIB.dSpaceSetCleanup,
	GeomTriMeshGetCallback = CLIB.dGeomTriMeshGetCallback,
	BodyVectorFromWorld = CLIB.dBodyVectorFromWorld,
	TimerResolution = CLIB.dTimerResolution,
	JointAddPistonForce = CLIB.dJointAddPistonForce,
	WorldGetMaxAngularSpeed = CLIB.dWorldGetMaxAngularSpeed,
	MassSetCappedCylinder = CLIB.dMassSetCappedCylinder,
	GeomRayGet = CLIB.dGeomRayGet,
	BodySetTorque = CLIB.dBodySetTorque,
	BodySetLinearDampingThreshold = CLIB.dBodySetLinearDampingThreshold,
	BodyGetTorque = CLIB.dBodyGetTorque,
	SpaceGetNumGeoms = CLIB.dSpaceGetNumGeoms,
	JointCreateContact = CLIB.dJointCreateContact,
	GeomRayGetClosestHit = CLIB.dGeomRayGetClosestHit,
	GeomRayGetParams = CLIB.dGeomRayGetParams,
	ThreadingImplementationShutdownProcessing = CLIB.dThreadingImplementationShutdownProcessing,
	GeomSetOffsetWorldPosition = CLIB.dGeomSetOffsetWorldPosition,
	JointCreatePU = CLIB.dJointCreatePU,
	JointSetHingeParam = CLIB.dJointSetHingeParam,
	BodyGetPosRelPoint = CLIB.dBodyGetPosRelPoint,
	JointSetAMotorAngle = CLIB.dJointSetAMotorAngle,
	GeomGetQuaternion = CLIB.dGeomGetQuaternion,
	MassSetZero = CLIB.dMassSetZero,
	BodySetAutoDisableDefaults = CLIB.dBodySetAutoDisableDefaults,
	JointSetBallAnchor2 = CLIB.dJointSetBallAnchor2,
	ThreadingAllocateSelfThreadedImplementation = CLIB.dThreadingAllocateSelfThreadedImplementation,
	JointGroupCreate = CLIB.dJointGroupCreate,
	WorldGetLinearDampingThreshold = CLIB.dWorldGetLinearDampingThreshold,
	JointSetTransmissionAxis = CLIB.dJointSetTransmissionAxis,
	JointGetDHingeDistance = CLIB.dJointGetDHingeDistance,
	JointGetBallAnchor2 = CLIB.dJointGetBallAnchor2,
	WorldExportDIF = CLIB.dWorldExportDIF,
	ThreadingFreeThreadPool = CLIB.dThreadingFreeThreadPool,
	ThreadingThreadPoolServeMultiThreadedImplementation = CLIB.dThreadingThreadPoolServeMultiThreadedImplementation,
	ExternalThreadingServeMultiThreadedImplementation = CLIB.dExternalThreadingServeMultiThreadedImplementation,
	ThreadingAllocateMultiThreadedImplementation = CLIB.dThreadingAllocateMultiThreadedImplementation,
	JointGetAMotorAngle = CLIB.dJointGetAMotorAngle,
	JointSetDBallAnchor1 = CLIB.dJointSetDBallAnchor1,
	SetValue = CLIB.dSetValue,
	GeomSetQuaternion = CLIB.dGeomSetQuaternion,
	JointGetDBallAnchor1 = CLIB.dJointGetDBallAnchor1,
	JointGetDBallAnchor2 = CLIB.dJointGetDBallAnchor2,
	GeomGetClassData = CLIB.dGeomGetClassData,
	Normalize3 = CLIB.dNormalize3,
	ClosestLineSegmentPoints = CLIB.dClosestLineSegmentPoints,
	JointGetSliderAxis = CLIB.dJointGetSliderAxis,
	GeomTriMeshDataBuildSingle = CLIB.dGeomTriMeshDataBuildSingle,
	GeomHeightfieldDataBuildShort = CLIB.dGeomHeightfieldDataBuildShort,
	JointSetTransmissionAxis1 = CLIB.dJointSetTransmissionAxis1,
	JointSetAMotorAxis = CLIB.dJointSetAMotorAxis,
	GeomHeightfieldDataDestroy = CLIB.dGeomHeightfieldDataDestroy,
	JointGetPUAngle1Rate = CLIB.dJointGetPUAngle1Rate,
	GeomHeightfieldDataCreate = CLIB.dGeomHeightfieldDataCreate,
	CreateHeightfield = CLIB.dCreateHeightfield,
	GeomTransformGetInfo = CLIB.dGeomTransformGetInfo,
	GeomTransformGetCleanup = CLIB.dGeomTransformGetCleanup,
	GeomTransformSetCleanup = CLIB.dGeomTransformSetCleanup,
	GeomTransformGetGeom = CLIB.dGeomTransformGetGeom,
	CreateGeomTransform = CLIB.dCreateGeomTransform,
	GeomTriMeshDataUpdate = CLIB.dGeomTriMeshDataUpdate,
	GeomTriMeshGetTriangleCount = CLIB.dGeomTriMeshGetTriangleCount,
	MakeRandomVector = CLIB.dMakeRandomVector,
	GeomTriMeshGetTriangle = CLIB.dGeomTriMeshGetTriangle,
	GeomTriMeshGetTriMeshDataID = CLIB.dGeomTriMeshGetTriMeshDataID,
	GeomTriMeshEnableTC = CLIB.dGeomTriMeshEnableTC,
	GeomTriMeshGetData = CLIB.dGeomTriMeshGetData,
	GeomTriMeshSetData = CLIB.dGeomTriMeshSetData,
	CreateTriMesh = CLIB.dCreateTriMesh,
	GeomTriMeshGetTriMergeCallback = CLIB.dGeomTriMeshGetTriMergeCallback,
	JointSetTransmissionAnchor1 = CLIB.dJointSetTransmissionAnchor1,
	GeomTriMeshSetTriMergeCallback = CLIB.dGeomTriMeshSetTriMergeCallback,
	JointGetPUParam = CLIB.dJointGetPUParam,
	GeomTriMeshGetArrayCallback = CLIB.dGeomTriMeshGetArrayCallback,
	GeomTriMeshSetArrayCallback = CLIB.dGeomTriMeshSetArrayCallback,
	JointCreateUniversal = CLIB.dJointCreateUniversal,
	JointGetPRAxis1 = CLIB.dJointGetPRAxis1,
	JointGetTransmissionAnchor1 = CLIB.dJointGetTransmissionAnchor1,
	BodyGetMaxAngularSpeed = CLIB.dBodyGetMaxAngularSpeed,
	GeomTriMeshDataSetBuffer = CLIB.dGeomTriMeshDataSetBuffer,
	GeomTriMeshDataPreprocess = CLIB.dGeomTriMeshDataPreprocess,
	HashSpaceSetLevels = CLIB.dHashSpaceSetLevels,
	GeomTriMeshDataBuildSimple = CLIB.dGeomTriMeshDataBuildSimple,
	JointSetFeedback = CLIB.dJointSetFeedback,
	GeomTriMeshDataBuildDouble = CLIB.dGeomTriMeshDataBuildDouble,
	GeomHeightfieldDataSetBounds = CLIB.dGeomHeightfieldDataSetBounds,
	RFromZAxis = CLIB.dRFromZAxis,
	BodySetData = CLIB.dBodySetData,
	GeomTriMeshSetLastTransform = CLIB.dGeomTriMeshSetLastTransform,
	JointGetHinge2Angle2Rate = CLIB.dJointGetHinge2Angle2Rate,
	GeomTriMeshDataSet = CLIB.dGeomTriMeshDataSet,
	GeomTriMeshDataDestroy = CLIB.dGeomTriMeshDataDestroy,
	GeomTriMeshDataCreate = CLIB.dGeomTriMeshDataCreate,
	GeomRaySetClosestHit = CLIB.dGeomRaySetClosestHit,
	GeomRayGetBackfaceCull = CLIB.dGeomRayGetBackfaceCull,
	GeomRayGetFirstContact = CLIB.dGeomRayGetFirstContact,
	MakeRandomMatrix = CLIB.dMakeRandomMatrix,
	GeomRaySet = CLIB.dGeomRaySet,
	GeomCylinderGetParams = CLIB.dGeomCylinderGetParams,
	GeomCylinderSetParams = CLIB.dGeomCylinderSetParams,
	CreateCylinder = CLIB.dCreateCylinder,
	GeomCapsulePointDepth = CLIB.dGeomCapsulePointDepth,
	GeomCapsuleGetParams = CLIB.dGeomCapsuleGetParams,
	GeomCapsuleSetParams = CLIB.dGeomCapsuleSetParams,
	GeomPlaneGetParams = CLIB.dGeomPlaneGetParams,
	CreatePlane = CLIB.dCreatePlane,
	MassSetCapsuleTotal = CLIB.dMassSetCapsuleTotal,
	GeomBoxGetLengths = CLIB.dGeomBoxGetLengths,
	GeomBoxSetLengths = CLIB.dGeomBoxSetLengths,
	CreateBox = CLIB.dCreateBox,
	GeomSetConvex = CLIB.dGeomSetConvex,
	GeomSpherePointDepth = CLIB.dGeomSpherePointDepth,
	SpaceCollide2 = CLIB.dSpaceCollide2,
	Collide = CLIB.dCollide,
	SpaceClean = CLIB.dSpaceClean,
	JointGetType = CLIB.dJointGetType,
	GeomCopyOffsetRotation = CLIB.dGeomCopyOffsetRotation,
	GeomGetOffsetRotation = CLIB.dGeomGetOffsetRotation,
	GeomCopyOffsetPosition = CLIB.dGeomCopyOffsetPosition,
	JointSetHinge2Axes = CLIB.dJointSetHinge2Axes,
	GeomGetOffsetPosition = CLIB.dGeomGetOffsetPosition,
	JointCreateDHinge = CLIB.dJointCreateDHinge,
	JointGetAMotorAngleRate = CLIB.dJointGetAMotorAngleRate,
	GeomClearOffset = CLIB.dGeomClearOffset,
	GeomSetOffsetWorldQuaternion = CLIB.dGeomSetOffsetWorldQuaternion,
	GeomSetOffsetWorldRotation = CLIB.dGeomSetOffsetWorldRotation,
	GeomSetOffsetQuaternion = CLIB.dGeomSetOffsetQuaternion,
	GeomSetOffsetRotation = CLIB.dGeomSetOffsetRotation,
	GeomSetOffsetPosition = CLIB.dGeomSetOffsetPosition,
	JointSetPistonParam = CLIB.dJointSetPistonParam,
	JointSetHingeAnchorDelta = CLIB.dJointSetHingeAnchorDelta,
	GeomVectorToWorld = CLIB.dGeomVectorToWorld,
	GeomGetPosRelPoint = CLIB.dGeomGetPosRelPoint,
	GeomLowLevelControl = CLIB.dGeomLowLevelControl,
	GeomGetClass = CLIB.dGeomGetClass,
	GeomGetRotation = CLIB.dGeomGetRotation,
	JointGetPistonAnchor = CLIB.dJointGetPistonAnchor,
	GeomGetPosition = CLIB.dGeomGetPosition,
	JointGetBallParam = CLIB.dJointGetBallParam,
	GeomSetBody = CLIB.dGeomSetBody,
	SpaceGetClass = CLIB.dSpaceGetClass,
	StopwatchStop = CLIB.dStopwatchStop,
	SpaceGetGeom = CLIB.dSpaceGetGeom,
	GeomGetOffsetQuaternion = CLIB.dGeomGetOffsetQuaternion,
	TimerTicksPerSecond = CLIB.dTimerTicksPerSecond,
	RandInt = CLIB.dRandInt,
	SpaceAdd = CLIB.dSpaceAdd,
	BodySetMaxAngularSpeed = CLIB.dBodySetMaxAngularSpeed,
	SpaceSetSublevel = CLIB.dSpaceSetSublevel,
	SetMessageHandler = CLIB.dSetMessageHandler,
	SweepAndPruneSpaceCreate = CLIB.dSweepAndPruneSpaceCreate,
	JointGetPistonPosition = CLIB.dJointGetPistonPosition,
	HashSpaceCreate = CLIB.dHashSpaceCreate,
	AreConnectedExcluding = CLIB.dAreConnectedExcluding,
	AreConnected = CLIB.dAreConnected,
	JointGetDHingeParam = CLIB.dJointGetDHingeParam,
	JointGetUniversalAngle1Rate = CLIB.dJointGetUniversalAngle1Rate,
	JointGetDHingeAnchor1 = CLIB.dJointGetDHingeAnchor1,
	JointSetDHingeAnchor2 = CLIB.dJointSetDHingeAnchor2,
	MassAdd = CLIB.dMassAdd,
	BodyGetAutoDisableLinearThreshold = CLIB.dBodyGetAutoDisableLinearThreshold,
	JointGetDBallParam = CLIB.dJointGetDBallParam,
	InitODE = CLIB.dInitODE,
	BodyCopyQuaternion = CLIB.dBodyCopyQuaternion,
	JointSetDBallParam = CLIB.dJointSetDBallParam,
	JointGetDBallDistance = CLIB.dJointGetDBallDistance,
	JointSetDBallAnchor2 = CLIB.dJointSetDBallAnchor2,
	JointGetPistonAnchor2 = CLIB.dJointGetPistonAnchor2,
	WorldDestroy = CLIB.dWorldDestroy,
	JointSetTransmissionRadius2 = CLIB.dJointSetTransmissionRadius2,
	JointSetTransmissionRadius1 = CLIB.dJointSetTransmissionRadius1,
	BodyCopyPosition = CLIB.dBodyCopyPosition,
	BodySetFiniteRotationMode = CLIB.dBodySetFiniteRotationMode,
	JointGetTransmissionRadius1 = CLIB.dJointGetTransmissionRadius1,
	BodySetDamping = CLIB.dBodySetDamping,
	JointGetTransmissionAngle1 = CLIB.dJointGetTransmissionAngle1,
	WorldUseSharedWorkingMemory = CLIB.dWorldUseSharedWorkingMemory,
	JointCreateHinge2 = CLIB.dJointCreateHinge2,
	JointGetTransmissionMode = CLIB.dJointGetTransmissionMode,
	JointGetTransmissionAxis2 = CLIB.dJointGetTransmissionAxis2,
	GeomHeightfieldDataBuildByte = CLIB.dGeomHeightfieldDataBuildByte,
	JointGetTransmissionContactPoint2 = CLIB.dJointGetTransmissionContactPoint2,
	JointSetPUAxisP = CLIB.dJointSetPUAxisP,
	JointGetTransmissionContactPoint1 = CLIB.dJointGetTransmissionContactPoint1,
	GeomIsOffset = CLIB.dGeomIsOffset,
	CreateGeom = CLIB.dCreateGeom,
	JointGetAMotorAxis = CLIB.dJointGetAMotorAxis,
	JointGetPistonParam = CLIB.dJointGetPistonParam,
	WorldQuickStep = CLIB.dWorldQuickStep,
	JointGetPistonAxis = CLIB.dJointGetPistonAxis,
	JointSetTransmissionBacklash = CLIB.dJointSetTransmissionBacklash,
	GeomCopyPosition = CLIB.dGeomCopyPosition,
	JointGetPistonAngle = CLIB.dJointGetPistonAngle,
	JointGetPistonPositionRate = CLIB.dJointGetPistonPositionRate,
	GeomTriMeshGetRayCallback = CLIB.dGeomTriMeshGetRayCallback,
	JointGetPUAngle2Rate = CLIB.dJointGetPUAngle2Rate,
	WorldGetGravity = CLIB.dWorldGetGravity,
	JointGetPUAxis2 = CLIB.dJointGetPUAxis2,
	JointGetPUAxis1 = CLIB.dJointGetPUAxis1,
	WorldSetAutoDisableFlag = CLIB.dWorldSetAutoDisableFlag,
	WorldSetERP = CLIB.dWorldSetERP,
	JointSetData = CLIB.dJointSetData,
	JointGetTransmissionBacklash = CLIB.dJointGetTransmissionBacklash,
	JointGetPUAnchor = CLIB.dJointGetPUAnchor,
	JointGetPRParam = CLIB.dJointGetPRParam,
	GeomTriMeshSetCallback = CLIB.dGeomTriMeshSetCallback,
	JointCreateAMotor = CLIB.dJointCreateAMotor,
	JointGetPRPositionRate = CLIB.dJointGetPRPositionRate,
	JointGetUniversalAngle2Rate = CLIB.dJointGetUniversalAngle2Rate,
	JointGetDHingeAnchor2 = CLIB.dJointGetDHingeAnchor2,
	JointGetUniversalAngle1 = CLIB.dJointGetUniversalAngle1,
	JointGetTransmissionAngle2 = CLIB.dJointGetTransmissionAngle2,
	JointGetUniversalAnchor2 = CLIB.dJointGetUniversalAnchor2,
	GeomTriMeshDataGet = CLIB.dGeomTriMeshDataGet,
	JointSetBallAnchor = CLIB.dJointSetBallAnchor,
	JointGetHinge2Angle1Rate = CLIB.dJointGetHinge2Angle1Rate,
	JointGetHinge2Angle2 = CLIB.dJointGetHinge2Angle2,
	JointGetHinge2Axis2 = CLIB.dJointGetHinge2Axis2,
	JointGetHinge2Axis1 = CLIB.dJointGetHinge2Axis1,
	JointGetSliderPositionRate = CLIB.dJointGetSliderPositionRate,
	JointGetSliderPosition = CLIB.dJointGetSliderPosition,
	JointGetHingeAngle = CLIB.dJointGetHingeAngle,
	ClearUpperTriangle = CLIB.dClearUpperTriangle,
	JointGetHingeAnchor2 = CLIB.dJointGetHingeAnchor2,
	JointGetHingeAnchor = CLIB.dJointGetHingeAnchor,
	JointGetBallAnchor = CLIB.dJointGetBallAnchor,
	JointSetPlane2DYParam = CLIB.dJointSetPlane2DYParam,
	JointSetAMotorMode = CLIB.dJointSetAMotorMode,
	GeomHeightfieldDataBuildCallback = CLIB.dGeomHeightfieldDataBuildCallback,
	JointAddSliderForce = CLIB.dJointAddSliderForce,
	JointSetAMotorNumAxes = CLIB.dJointSetAMotorNumAxes,
	JointSetFixedParam = CLIB.dJointSetFixedParam,
	GeomVectorFromWorld = CLIB.dGeomVectorFromWorld,
	JointSetPistonAxis = CLIB.dJointSetPistonAxis,
	JointSetPistonAnchorOffset = CLIB.dJointSetPistonAnchorOffset,
	BodyAddForce = CLIB.dBodyAddForce,
	WorldGetAutoDisableAverageSamplesCount = CLIB.dWorldGetAutoDisableAverageSamplesCount,
	GetFreeHandler = CLIB.dGetFreeHandler,
	WorldImpulseToForce = CLIB.dWorldImpulseToForce,
	RandGetSeed = CLIB.dRandGetSeed,
	RFrom2Axes = CLIB.dRFrom2Axes,
	BodySetDampingDefaults = CLIB.dBodySetDampingDefaults,
	BodyGetAngularDampingThreshold = CLIB.dBodyGetAngularDampingThreshold,
	FactorLDLT = CLIB.dFactorLDLT,
	BodyGetLinearDampingThreshold = CLIB.dBodyGetLinearDampingThreshold,
	JointAddPRTorque = CLIB.dJointAddPRTorque,
	JointGetHingeAxis = CLIB.dJointGetHingeAxis,
	RFromEulerAngles = CLIB.dRFromEulerAngles,
	JointGetPRPosition = CLIB.dJointGetPRPosition,
	WorldSetLinearDamping = CLIB.dWorldSetLinearDamping,
	GetDebugHandler = CLIB.dGetDebugHandler,
	JointSetPRParam = CLIB.dJointSetPRParam,
	WorldGetAutoDisableAngularThreshold = CLIB.dWorldGetAutoDisableAngularThreshold,
	CleanupODEAllDataForThread = CLIB.dCleanupODEAllDataForThread,
	JointCreateDBall = CLIB.dJointCreateDBall,
	GeomRaySetFirstContact = CLIB.dGeomRaySetFirstContact,
	WorldSetStepIslandsProcessingMaxThreadCount = CLIB.dWorldSetStepIslandsProcessingMaxThreadCount,
	JointSetPistonAnchor = CLIB.dJointSetPistonAnchor,
	GetAllocHandler = CLIB.dGetAllocHandler,
	LDLTAddTL = CLIB.dLDLTAddTL,
	SpaceDestroy = CLIB.dSpaceDestroy,
	Normalize4 = CLIB.dNormalize4,
	GetReallocHandler = CLIB.dGetReallocHandler,
	BodyGetAutoDisableFlag = CLIB.dBodyGetAutoDisableFlag,
	JointGetHingeAngleRate = CLIB.dJointGetHingeAngleRate,
	WorldStep = CLIB.dWorldStep,
	JointSetPUAxis1 = CLIB.dJointSetPUAxis1,
	MassSetSphere = CLIB.dMassSetSphere,
	RfromQ = CLIB.dRfromQ,
	SpaceQuery = CLIB.dSpaceQuery,
	TimerReport = CLIB.dTimerReport,
	JointGetPRAngle = CLIB.dJointGetPRAngle,
	InvertPDMatrix = CLIB.dInvertPDMatrix,
	Multiply2 = CLIB.dMultiply2,
	JointGetNumBodies = CLIB.dJointGetNumBodies,
	SafeNormalize3 = CLIB.dSafeNormalize3,
	BodyGetPointVel = CLIB.dBodyGetPointVel,
	JointSetUniversalAnchor = CLIB.dJointSetUniversalAnchor,
	Error = CLIB.dError,
	JointGetPUAxisP = CLIB.dJointGetPUAxisP,
	TestRand = CLIB.dTestRand,
	MaxDifference = CLIB.dMaxDifference,
	BodyGetQuaternion = CLIB.dBodyGetQuaternion,
	GeomIsSpace = CLIB.dGeomIsSpace,
	Realloc = CLIB.dRealloc,
	BodySetAngularDamping = CLIB.dBodySetAngularDamping,
	WorldGetAutoDisableSteps = CLIB.dWorldGetAutoDisableSteps,
	MassAdjust = CLIB.dMassAdjust,
	JointSetPRAnchor = CLIB.dJointSetPRAnchor,
	JointCreateTransmission = CLIB.dJointCreateTransmission,
	GetConfiguration = CLIB.dGetConfiguration,
	GeomTransformSetInfo = CLIB.dGeomTransformSetInfo,
	JointGetTransmissionRatio = CLIB.dJointGetTransmissionRatio,
	IsPositiveDefinite = CLIB.dIsPositiveDefinite,
	JointSetDHingeAnchor1 = CLIB.dJointSetDHingeAnchor1,
	BodyGetWorld = CLIB.dBodyGetWorld,
	JointAddUniversalTorques = CLIB.dJointAddUniversalTorques,
	WorldSetAutoDisableTime = CLIB.dWorldSetAutoDisableTime,
	BodyAddRelForceAtRelPos = CLIB.dBodyAddRelForceAtRelPos,
	ThreadingThreadPoolWaitIdleState = CLIB.dThreadingThreadPoolWaitIdleState,
	JointGetPUPositionRate = CLIB.dJointGetPUPositionRate,
	CreateSphere = CLIB.dCreateSphere,
	JointGetUniversalParam = CLIB.dJointGetUniversalParam,
	SolveL1T = CLIB.dSolveL1T,
	JointGetAMotorNumAxes = CLIB.dJointGetAMotorNumAxes,
	BodySetQuaternion = CLIB.dBodySetQuaternion,
	JointSetUniversalParam = CLIB.dJointSetUniversalParam,
	JointSetPUAnchor = CLIB.dJointSetPUAnchor,
	SetAllocHandler = CLIB.dSetAllocHandler,
	BodyGetLinearDamping = CLIB.dBodyGetLinearDamping,
	JointSetPRAxis1 = CLIB.dJointSetPRAxis1,
	BodyGetData = CLIB.dBodyGetData,
	CreateCapsule = CLIB.dCreateCapsule,
	WorldGetAutoDisableLinearThreshold = CLIB.dWorldGetAutoDisableLinearThreshold,
	JointGetPUAngle1 = CLIB.dJointGetPUAngle1,
	SetFreeHandler = CLIB.dSetFreeHandler,
	BodySetLinearVel = CLIB.dBodySetLinearVel,
	InitODE2 = CLIB.dInitODE2,
	SetReallocHandler = CLIB.dSetReallocHandler,
	Free = CLIB.dFree,
	QuadTreeSpaceCreate = CLIB.dQuadTreeSpaceCreate,
	BodyGetLinearVel = CLIB.dBodyGetLinearVel,
	BodySetMass = CLIB.dBodySetMass,
	JointCreateLMotor = CLIB.dJointCreateLMotor,
	TimerStart = CLIB.dTimerStart,
	TimerEnd = CLIB.dTimerEnd,
	QMultiply0 = CLIB.dQMultiply0,
	GeomTriMeshClearTCCache = CLIB.dGeomTriMeshClearTCCache,
	MassSetSphereTotal = CLIB.dMassSetSphereTotal,
	MassSetTrimeshTotal = CLIB.dMassSetTrimeshTotal,
	SpaceRemove = CLIB.dSpaceRemove,
	RSetIdentity = CLIB.dRSetIdentity,
	MaxDifferenceLowerTriangle = CLIB.dMaxDifferenceLowerTriangle,
	WorldSetQuickStepW = CLIB.dWorldSetQuickStepW,
	BodyAddRelTorque = CLIB.dBodyAddRelTorque,
	QFromAxisAndAngle = CLIB.dQFromAxisAndAngle,
	JointGetPUAngles = CLIB.dJointGetPUAngles,
	GetErrorHandler = CLIB.dGetErrorHandler,
	JointSetTransmissionParam = CLIB.dJointSetTransmissionParam,
	WorldGetContactMaxCorrectingVel = CLIB.dWorldGetContactMaxCorrectingVel,
	BodySetForce = CLIB.dBodySetForce,
	MassSetCylinderTotal = CLIB.dMassSetCylinderTotal,
	WorldSetAutoDisableAngularThreshold = CLIB.dWorldSetAutoDisableAngularThreshold,
	WorldSetAutoDisableSteps = CLIB.dWorldSetAutoDisableSteps,
	WorldGetAngularDampingThreshold = CLIB.dWorldGetAngularDampingThreshold,
	WorldSetAngularDampingThreshold = CLIB.dWorldSetAngularDampingThreshold,
	WorldGetLinearDamping = CLIB.dWorldGetLinearDamping,
	JointSetDHingeAxis = CLIB.dJointSetDHingeAxis,
	BodyGetAutoDisableAngularThreshold = CLIB.dBodyGetAutoDisableAngularThreshold,
	BodyVectorToWorld = CLIB.dBodyVectorToWorld,
	BodySetAutoDisableAverageSamplesCount = CLIB.dBodySetAutoDisableAverageSamplesCount,
	WorldGetCFM = CLIB.dWorldGetCFM,
	BodySetAutoDisableSteps = CLIB.dBodySetAutoDisableSteps,
	BodySetPosition = CLIB.dBodySetPosition,
	WorldSetContactMaxCorrectingVel = CLIB.dWorldSetContactMaxCorrectingVel,
	WorldSetLinearDampingThreshold = CLIB.dWorldSetLinearDampingThreshold,
	GeomGetBodyNext = CLIB.dGeomGetBodyNext,
	GeomIsEnabled = CLIB.dGeomIsEnabled,
	JointGetTransmissionRadius2 = CLIB.dJointGetTransmissionRadius2,
	BodyDisable = CLIB.dBodyDisable,
	BodyGetFirstGeom = CLIB.dBodyGetFirstGeom,
	QMultiply3 = CLIB.dQMultiply3,
	SpaceGetSublevel = CLIB.dSpaceGetSublevel,
	SetZero = CLIB.dSetZero,
	BodySetFiniteRotationAxis = CLIB.dBodySetFiniteRotationAxis,
	JointSetHinge2Anchor = CLIB.dJointSetHinge2Anchor,
	JointSetUniversalAxis1Offset = CLIB.dJointSetUniversalAxis1Offset,
	JointSetPRAxis2 = CLIB.dJointSetPRAxis2,
	WorldSetAutoDisableAverageSamplesCount = CLIB.dWorldSetAutoDisableAverageSamplesCount,
}
library.e = {
	SA__MIN = ffi.cast("enum dSpaceAxis", "dSA__MIN"),
	SA_X = ffi.cast("enum dSpaceAxis", "dSA_X"),
	SA_Y = ffi.cast("enum dSpaceAxis", "dSA_Y"),
	SA_Z = ffi.cast("enum dSpaceAxis", "dSA_Z"),
	SA__MAX = ffi.cast("enum dSpaceAxis", "dSA__MAX"),
	V4E__MIN = ffi.cast("enum dVec4Element", "dV4E__MIN"),
	V4E_X = ffi.cast("enum dVec4Element", "dV4E_X"),
	V4E_Y = ffi.cast("enum dVec4Element", "dV4E_Y"),
	V4E_Z = ffi.cast("enum dVec4Element", "dV4E_Z"),
	V4E_O = ffi.cast("enum dVec4Element", "dV4E_O"),
	V4E__MAX = ffi.cast("enum dVec4Element", "dV4E__MAX"),
	M4E__MIN = ffi.cast("enum dMat4Element", "dM4E__MIN"),
	M4E__X_MIN = ffi.cast("enum dMat4Element", "dM4E__X_MIN"),
	M4E_XX = ffi.cast("enum dMat4Element", "dM4E_XX"),
	M4E_XY = ffi.cast("enum dMat4Element", "dM4E_XY"),
	M4E_XZ = ffi.cast("enum dMat4Element", "dM4E_XZ"),
	M4E_XO = ffi.cast("enum dMat4Element", "dM4E_XO"),
	M4E__X_MAX = ffi.cast("enum dMat4Element", "dM4E__X_MAX"),
	M4E__Y_MIN = ffi.cast("enum dMat4Element", "dM4E__Y_MIN"),
	M4E_YX = ffi.cast("enum dMat4Element", "dM4E_YX"),
	M4E_YY = ffi.cast("enum dMat4Element", "dM4E_YY"),
	M4E_YZ = ffi.cast("enum dMat4Element", "dM4E_YZ"),
	M4E_YO = ffi.cast("enum dMat4Element", "dM4E_YO"),
	M4E__Y_MAX = ffi.cast("enum dMat4Element", "dM4E__Y_MAX"),
	M4E__Z_MIN = ffi.cast("enum dMat4Element", "dM4E__Z_MIN"),
	M4E_ZX = ffi.cast("enum dMat4Element", "dM4E_ZX"),
	M4E_ZY = ffi.cast("enum dMat4Element", "dM4E_ZY"),
	M4E_ZZ = ffi.cast("enum dMat4Element", "dM4E_ZZ"),
	M4E_ZO = ffi.cast("enum dMat4Element", "dM4E_ZO"),
	M4E__Z_MAX = ffi.cast("enum dMat4Element", "dM4E__Z_MAX"),
	M4E__O_MIN = ffi.cast("enum dMat4Element", "dM4E__O_MIN"),
	M4E_OX = ffi.cast("enum dMat4Element", "dM4E_OX"),
	M4E_OY = ffi.cast("enum dMat4Element", "dM4E_OY"),
	M4E_OZ = ffi.cast("enum dMat4Element", "dM4E_OZ"),
	M4E_OO = ffi.cast("enum dMat4Element", "dM4E_OO"),
	M4E__O_MAX = ffi.cast("enum dMat4Element", "dM4E__O_MAX"),
	M4E__MAX = ffi.cast("enum dMat4Element", "dM4E__MAX"),
	DA__MIN = ffi.cast("enum dDynamicsAxis", "dDA__MIN"),
	DA__L_MIN = ffi.cast("enum dDynamicsAxis", "dDA__L_MIN"),
	DA_LX = ffi.cast("enum dDynamicsAxis", "dDA_LX"),
	DA_LY = ffi.cast("enum dDynamicsAxis", "dDA_LY"),
	DA_LZ = ffi.cast("enum dDynamicsAxis", "dDA_LZ"),
	DA__L_MAX = ffi.cast("enum dDynamicsAxis", "dDA__L_MAX"),
	DA__A_MIN = ffi.cast("enum dDynamicsAxis", "dDA__A_MIN"),
	DA_AX = ffi.cast("enum dDynamicsAxis", "dDA_AX"),
	DA_AY = ffi.cast("enum dDynamicsAxis", "dDA_AY"),
	DA_AZ = ffi.cast("enum dDynamicsAxis", "dDA_AZ"),
	DA__A_MAX = ffi.cast("enum dDynamicsAxis", "dDA__A_MAX"),
	DA__MAX = ffi.cast("enum dDynamicsAxis", "dDA__MAX"),
	MD__MIN = ffi.cast("enum dMotionDynamics", "dMD__MIN"),
	MD_LINEAR = ffi.cast("enum dMotionDynamics", "dMD_LINEAR"),
	MD_ANGULAR = ffi.cast("enum dMotionDynamics", "dMD_ANGULAR"),
	MD__MAX = ffi.cast("enum dMotionDynamics", "dMD__MAX"),
	AllocateFlagBasicData = ffi.cast("enum dAllocateODEDataFlags", "dAllocateFlagBasicData"),
	AllocateFlagCollisionData = ffi.cast("enum dAllocateODEDataFlags", "dAllocateFlagCollisionData"),
	AllocateMaskAll = ffi.cast("enum dAllocateODEDataFlags", "dAllocateMaskAll"),
	QUE__MIN = ffi.cast("enum dQuatElement", "dQUE__MIN"),
	QUE_R = ffi.cast("enum dQuatElement", "dQUE_R"),
	QUE__AXIS_MIN = ffi.cast("enum dQuatElement", "dQUE__AXIS_MIN"),
	QUE_I = ffi.cast("enum dQuatElement", "dQUE_I"),
	QUE_J = ffi.cast("enum dQuatElement", "dQUE_J"),
	QUE_K = ffi.cast("enum dQuatElement", "dQUE_K"),
	QUE__AXIS_MAX = ffi.cast("enum dQuatElement", "dQUE__AXIS_MAX"),
	QUE__MAX = ffi.cast("enum dQuatElement", "dQUE__MAX"),
	JointTypeNone = ffi.cast("enum dJointType", "dJointTypeNone"),
	JointTypeBall = ffi.cast("enum dJointType", "dJointTypeBall"),
	JointTypeHinge = ffi.cast("enum dJointType", "dJointTypeHinge"),
	JointTypeSlider = ffi.cast("enum dJointType", "dJointTypeSlider"),
	JointTypeContact = ffi.cast("enum dJointType", "dJointTypeContact"),
	JointTypeUniversal = ffi.cast("enum dJointType", "dJointTypeUniversal"),
	JointTypeHinge2 = ffi.cast("enum dJointType", "dJointTypeHinge2"),
	JointTypeFixed = ffi.cast("enum dJointType", "dJointTypeFixed"),
	JointTypeNull = ffi.cast("enum dJointType", "dJointTypeNull"),
	JointTypeAMotor = ffi.cast("enum dJointType", "dJointTypeAMotor"),
	JointTypeLMotor = ffi.cast("enum dJointType", "dJointTypeLMotor"),
	JointTypePlane2D = ffi.cast("enum dJointType", "dJointTypePlane2D"),
	JointTypePR = ffi.cast("enum dJointType", "dJointTypePR"),
	JointTypePU = ffi.cast("enum dJointType", "dJointTypePU"),
	JointTypePiston = ffi.cast("enum dJointType", "dJointTypePiston"),
	JointTypeDBall = ffi.cast("enum dJointType", "dJointTypeDBall"),
	JointTypeDHinge = ffi.cast("enum dJointType", "dJointTypeDHinge"),
	JointTypeTransmission = ffi.cast("enum dJointType", "dJointTypeTransmission"),
	M3E__MIN = ffi.cast("enum dMat3Element", "dM3E__MIN"),
	M3E__X_MIN = ffi.cast("enum dMat3Element", "dM3E__X_MIN"),
	M3E__X_AXES_MIN = ffi.cast("enum dMat3Element", "dM3E__X_AXES_MIN"),
	M3E_XX = ffi.cast("enum dMat3Element", "dM3E_XX"),
	M3E_XY = ffi.cast("enum dMat3Element", "dM3E_XY"),
	M3E_XZ = ffi.cast("enum dMat3Element", "dM3E_XZ"),
	M3E__X_AXES_MAX = ffi.cast("enum dMat3Element", "dM3E__X_AXES_MAX"),
	M3E_XPAD = ffi.cast("enum dMat3Element", "dM3E_XPAD"),
	M3E__X_MAX = ffi.cast("enum dMat3Element", "dM3E__X_MAX"),
	M3E__Y_MIN = ffi.cast("enum dMat3Element", "dM3E__Y_MIN"),
	M3E__Y_AXES_MIN = ffi.cast("enum dMat3Element", "dM3E__Y_AXES_MIN"),
	M3E_YX = ffi.cast("enum dMat3Element", "dM3E_YX"),
	M3E_YY = ffi.cast("enum dMat3Element", "dM3E_YY"),
	M3E_YZ = ffi.cast("enum dMat3Element", "dM3E_YZ"),
	M3E__Y_AXES_MAX = ffi.cast("enum dMat3Element", "dM3E__Y_AXES_MAX"),
	M3E_YPAD = ffi.cast("enum dMat3Element", "dM3E_YPAD"),
	M3E__Y_MAX = ffi.cast("enum dMat3Element", "dM3E__Y_MAX"),
	M3E__Z_MIN = ffi.cast("enum dMat3Element", "dM3E__Z_MIN"),
	M3E__Z_AXES_MIN = ffi.cast("enum dMat3Element", "dM3E__Z_AXES_MIN"),
	M3E_ZX = ffi.cast("enum dMat3Element", "dM3E_ZX"),
	M3E_ZY = ffi.cast("enum dMat3Element", "dM3E_ZY"),
	M3E_ZZ = ffi.cast("enum dMat3Element", "dM3E_ZZ"),
	M3E__Z_AXES_MAX = ffi.cast("enum dMat3Element", "dM3E__Z_AXES_MAX"),
	M3E_ZPAD = ffi.cast("enum dMat3Element", "dM3E_ZPAD"),
	M3E__Z_MAX = ffi.cast("enum dMat3Element", "dM3E__Z_MAX"),
	M3E__MAX = ffi.cast("enum dMat3Element", "dM3E__MAX"),
	InitFlagManualThreadCleanup = ffi.cast("enum dInitODEFlags", "dInitFlagManualThreadCleanup"),
	V3E__MIN = ffi.cast("enum dVec3Element", "dV3E__MIN"),
	V3E__AXES_MIN = ffi.cast("enum dVec3Element", "dV3E__AXES_MIN"),
	V3E_X = ffi.cast("enum dVec3Element", "dV3E_X"),
	V3E_Y = ffi.cast("enum dVec3Element", "dV3E_Y"),
	V3E_Z = ffi.cast("enum dVec3Element", "dV3E_Z"),
	V3E__AXES_MAX = ffi.cast("enum dVec3Element", "dV3E__AXES_MAX"),
	V3E_PAD = ffi.cast("enum dVec3Element", "dV3E_PAD"),
	V3E__MAX = ffi.cast("enum dVec3Element", "dV3E__MAX"),
	ParamLoStop = 0,
	ParamHiStop = 1,
	ParamVel = 2,
	ParamLoVel = 3,
	ParamHiVel = 4,
	ParamFMax = 5,
	ParamFudgeFactor = 6,
	ParamBounce = 7,
	ParamCFM = 8,
	ParamStopERP = 9,
	ParamStopCFM = 10,
	ParamSuspensionERP = 11,
	ParamSuspensionCFM = 12,
	ParamERP = 13,
	ParamsInGroup = 14,
	ParamGroup1 = 0,
	ParamLoStop1 = 0,
	ParamHiStop1 = 1,
	ParamVel1 = 2,
	ParamLoVel1 = 3,
	ParamHiVel1 = 4,
	ParamFMax1 = 5,
	ParamFudgeFactor1 = 6,
	ParamBounce1 = 7,
	ParamCFM1 = 8,
	ParamStopERP1 = 9,
	ParamStopCFM1 = 10,
	ParamSuspensionERP1 = 11,
	ParamSuspensionCFM1 = 12,
	ParamERP1 = 13,
	ParamGroup2 = 256,
	ParamLoStop2 = 256,
	ParamHiStop2 = 257,
	ParamVel2 = 258,
	ParamLoVel2 = 259,
	ParamHiVel2 = 260,
	ParamFMax2 = 261,
	ParamFudgeFactor2 = 262,
	ParamBounce2 = 263,
	ParamCFM2 = 264,
	ParamStopERP2 = 265,
	ParamStopCFM2 = 266,
	ParamSuspensionERP2 = 267,
	ParamSuspensionCFM2 = 268,
	ParamERP2 = 269,
	ParamGroup3 = 512,
	ParamLoStop3 = 512,
	ParamHiStop3 = 513,
	ParamVel3 = 514,
	ParamLoVel3 = 515,
	ParamHiVel3 = 516,
	ParamFMax3 = 517,
	ParamFudgeFactor3 = 518,
	ParamBounce3 = 519,
	ParamCFM3 = 520,
	ParamStopERP3 = 521,
	ParamStopCFM3 = 522,
	ParamSuspensionERP3 = 523,
	ParamSuspensionCFM3 = 524,
	ParamERP3 = 525,
	ParamGroup = 256,
	AMotorUser = 0,
	AMotorEuler = 1,
	TransmissionParallelAxes = 0,
	TransmissionIntersectingAxes = 1,
	TransmissionChainDrive = 2,
	ContactMu2 = 1,
	ContactAxisDep = 1,
	ContactFDir1 = 2,
	ContactBounce = 4,
	ContactSoftERP = 8,
	ContactSoftCFM = 16,
	ContactMotion1 = 32,
	ContactMotion2 = 64,
	ContactMotionN = 128,
	ContactSlip1 = 256,
	ContactSlip2 = 512,
	ContactRolling = 1024,
	ContactApprox0 = 0,
	ContactApprox1_1 = 4096,
	ContactApprox1_2 = 8192,
	ContactApprox1_N = 16384,
	ContactApprox1 = 28672,
	GeomCommonControlClass = 0,
	GeomColliderControlClass = 1,
	GeomCommonAnyControlCode = 0,
	GeomColliderSetMergeSphereContactsControlCode = 1,
	GeomColliderGetMergeSphereContactsControlCode = 2,
	GeomColliderMergeContactsValue__Default = 0,
	GeomColliderMergeContactsValue_None = 1,
	GeomColliderMergeContactsValue_Normals = 2,
	GeomColliderMergeContactsValue_Full = 3,
	MaxUserClasses = 4,
	SphereClass = 0,
	BoxClass = 1,
	CapsuleClass = 2,
	CylinderClass = 3,
	PlaneClass = 4,
	RayClass = 5,
	ConvexClass = 6,
	GeomTransformClass = 7,
	TriMeshClass = 8,
	HeightfieldClass = 9,
	FirstSpaceClass = 10,
	SimpleSpaceClass = 10,
	HashSpaceClass = 11,
	SweepAndPruneSpaceClass = 12,
	QuadTreeSpaceClass = 13,
	LastSpaceClass = 13,
	FirstUserClass = 14,
	LastUserClass = 17,
	GeomNumClasses = 18,
}
library.clib = CLIB
return library
