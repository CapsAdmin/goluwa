local ffi = require("ffi")
local asm = ffi.C

ffi.cdef[[
  typedef float float4 __attribute__((__vector_size__(16)));
  typedef float float8 __attribute__((__vector_size__(32)));
  typedef double double2 __attribute__((__vector_size__(16)));
  typedef double double4 __attribute__((__vector_size__(32)));

  typedef uint8_t byte16 __attribute__((__vector_size__(16)));
  typedef uint8_t byte32 __attribute__((__vector_size__(32)));
  typedef uint16_t short8 __attribute__((__vector_size__(16)));
  typedef uint16_t short8 __attribute__((__vector_size__(32)));

  typedef int int4 __attribute__((__vector_size__(16)));
  typedef int int8 __attribute__((__vector_size__(32)));
  typedef int64_t long2 __attribute__((__vector_size__(16)));
  typedef int64_t long4 __attribute__((__vector_size__(32)));
]]
-- byte16
ffi.cdef[[
  byte16 paddb(byte16, byte16) __mcode("660FFCrMv");
  byte16 psubb(byte16, byte16) __mcode("660FF8rMv");
  byte16 paddsb(byte16, byte16) __mcode("660FECrMv");
  byte16 paddusb(byte16, byte16) __mcode("660FDCrMv");
  byte16 psubsb(byte16, byte16) __mcode("660FE8rMv");
  byte16 psubusb(byte16, byte16) __mcode("660FD8rMv");
  byte16 pabsb(byte16, byte16) __mcode("660F381CrM");
  byte16 pavgb(byte16, byte16) __mcode("660FE0rMv");
  byte16 mpsadbw(short8, short8) __mcode("660F3A42rMU", 0);
  byte16 psignb(byte16, byte16) __mcode("660F3808rM");
  byte16 pcmpeqb(byte16, byte16) __mcode("660F74rMv");
  byte16 pcmpgtb(byte16, byte16) __mcode("660F64rMv");
  byte16 pblendvb(byte16, byte16) __mcode("660F3810rM");
  byte16 pextrb(byte16) __mcode("660F3A14RmUv", 0);
  byte16 pinsrb(byte16, int32_t) __mcode("660F3A20rMUv", 0);
  byte16 packsswb(byte16, byte16) __mcode("660F63rMv");
  byte16 packuswb(byte16, byte16) __mcode("660F67rMv");
  byte16 punpckhbw(byte16, byte16) __mcode("660F68rMv");
  byte16 punpcklbw(byte16, byte16) __mcode("660F60rMv");
  short8 pmovsxbw(byte16) __mcode("660F3820rMv");
  short8 pmovzxbw(byte16) __mcode("660F3830rMv");
  byte16 pminsb(byte16, byte16) __mcode("660F3838rMv");
  byte16 pmaxsb(byte16, byte16) __mcode("660F383CrMv");
  byte16 pminub(byte16, byte16) __mcode("660FDArMv");
  byte16 pmaxub(byte16, byte16) __mcode("660FDErMv");
  int32_t pmovmskb(byte16) __mcode("660FD7rM");
]]
-- int4
ffi.cdef[[
  int4 paddd(int4, int4) __mcode("660FFErMv");
  int4 psubd(int4, int4) __mcode("660FFArMv");
  int4 pmulld(int4, int4) __mcode("660F3840rMcv");
  int4 pmaddwd(int4, int4) __mcode("660FF5rMv");
  int4 phaddd(int4, int4) __mcode("660F3802rM");
  int4 phsubd(int4, int4) __mcode("660F3806rM");
  int4 psignd(int4, int4) __mcode("660F380ArM");
  int4 pabsd(int4) __mcode("660F381ErMv");
  int4 pslld(int4, int4) __mcode("660FF2rMv");
  int4 psrad(int4, int4) __mcode("660FE2rMv");
  int4 psrld(int4, int4) __mcode("660FD2rMv");
  int4 pcmpeqd(int4, int4) __mcode("660F76rMcv");
  int4 pcmpgtd(int4, int4) __mcode("660F66rMv");
  int4 pshufd(int4) __mcode("660F70rMU", 0);
  int32_t pextrd_0(int4) __mcode("660F3A16RmU", 0);
  int32_t pextrd_1(int4) __mcode("660F3A16RmU", 1);
  int32_t pextrd_2(int4) __mcode("660F3A16RmU", 2);
  int32_t pextrd_3(int4) __mcode("660F3A16RmU", 3);
  int32_t pextrd(int4) __mcode("660F3A16RmU", 0);
  int4 pinsrd_0(int4, int32_t) __mcode("660F3A22rMU", 0);
  int4 pinsrd_1(int4, int32_t) __mcode("660F3A22rMU", 1);
  int4 pinsrd_2(int4, int32_t) __mcode("660F3A22rMU", 2);
  int4 pinsrd_3(int4, int32_t) __mcode("660F3A22rMU", 3);
  int4 pinsrd(int4, int32_t) __mcode("660F3A22rMU", 0);
  int4 punpckhwd(int4, int4) __mcode("660F69rMv");
  int4 punpcklwd(int4, int4) __mcode("660F61rMv");
  int4 pminsd(int4, int4) __mcode("660F3839rMcv");
  int4 pmaxsd(int4, int4) __mcode("660F383DrMcv");
  int4 pminud(int4, int4) __mcode("660F383BrMcv");
  int4 pmaxud(int4, int4) __mcode("660F383FrMcv");
  long2 pmovsxdq(int4) __mcode("660F3825rMv");
  long2 pmovzxdq(int4) __mcode("660F3835rMv");
  float4 cvtdq2ps(int4) __mcode("0F5BrMv");
  double2 cvtdq2pd(int4) __mcode("F30FE6rRv");
]]
-- float4
ffi.cdef[[
  float4 addps(float4, float4) __mcode("0F58rMv");
  float4 subps(float4, float4) __mcode("0F5CrMv");
  float4 divps(float4, float4) __mcode("0F5ErMv");
  float4 mulps(float4, float4) __mcode("0F59rMcv");
  float4 addsubps(float4, float4) __mcode("F20FD0rM");
  float4 haddps(float4, float4) __mcode("F20F7CrM");
  float4 hsubps(float4, float4) __mcode("F20F7DrM");
  float4 dpps(float4, float4) __mcode("660F3A40rMU", 0);
  float4 andnps(float4, float4) __mcode("0F55rMv");
  float4 andps(float4, float4) __mcode("0F54rMcv");
  float4 orps(float4, float4) __mcode("0F56rMcv");
  float4 xorps(float4, float4) __mcode("0F57rMcv");
  float4 maxps(float4, float4) __mcode("0F5FrMcv");
  float4 minps(float4, float4) __mcode("0F5DrMcv");
  float4 cmpeqps(float4, float4) __mcode("0FC2rMUv", 0);
  float4 cmpltps(float4, float4) __mcode("0FC2rMUv", 1);
  float4 cmpps(float4, float4) __mcode("0FC2rMUv", 0);
  float4 movaps(void*) __mcode("0F28rM");
  float4 movntps(void*) __mcode("0F2BRm");
  float4 movups(void*) __mcode("0F10rMI");
  float4 rcpps(float4) __mcode("0F53rM");
  float4 roundps(float4) __mcode("660F3A08rMU", 0);
  float4 rsqrtps(float4) __mcode("0F52rM");
  float4 sqrtps(float4) __mcode("0F51rM");
  float4 movhlps(float4) __mcode("0F12rM");
  float4 movhps(float4) __mcode("0F16rM");
  float4 movlhps(float4) __mcode("0F16rM");
  float4 movlps(float4) __mcode("0F12rM");
  float4 shufps_0(float4) __mcode("0FC6rMU", 0);
  float4 shufps_4444(float4) __mcode("0FC6rMU", 255);
  float4 shufps_3412(float4) __mcode("0FC6rMU", 177);
  float4 shufps_2122(float4) __mcode("0FC6rMU", 69);
  float4 shufps(float4) __mcode("0FC6rMU", 0);
  float4 blendps(float4, float4) __mcode("660F3A0CrMU", 0);
  float4 blendvps(float4, float4) __mcode("660F3814rM");
  float4 unpckhps(float4, float4) __mcode("0F15rMv");
  float4 unpcklps(float4, float4) __mcode("0F14rMv");
  float extractps_0(float4) __mcode("660F3A17RmU", 0);
  float extractps_1(float4) __mcode("660F3A17RmU", 1);
  float extractps_2(float4) __mcode("660F3A17RmU", 2);
  float extractps_3(float4) __mcode("660F3A17RmU", 3);
  float extractps(float4) __mcode("660F3A17RmU", 0);
  float4 insertps_0(float4, float) __mcode("660F3A41rMU", 0);
  float4 insertps_1(float4, float) __mcode("660F3A41rMU", 1);
  float4 insertps_2(float4, float) __mcode("660F3A41rMU", 2);
  float4 insertps_3(float4, float) __mcode("660F3A41rMU", 3);
  float4 insertps(float4, float) __mcode("660F3A41rMU", 0);
  float4 vpermilps(float4, int4) __mcode("660F380CrMV");
  double2 cvtps2pd(float4) __mcode("0F5ArM");
  int4 cvtps2dq(float4) __mcode("660F5BrMv");
  int4 cvttps2dq(float4) __mcode("F30F5BrMv");
]]
-- double4
ffi.cdef[[
  double4 vblendpd(double4, double4) __mcode("660F3A0DrMUV", 0);
  double4 vblendvpd(double4 ymm, double4 ymm, double4 ymm0) __mcode("660F3A4BrMEVU", 0);
  double4 vmaskmovpd(double4 ymm, void* ymm) __mcode("660F382DrMVIE");
]]
-- long2
ffi.cdef[[
  long2 paddq(long2, long2) __mcode("660FD4rMv");
  long2 psubq(long2, long2) __mcode("660FFBrMv");
  long2 pmuldq(long2, long2) __mcode("660F3828rMcv");
  long2 pmuludq(long2, long2) __mcode("660FF4rMcv");
  long2 pclmulqdq(long2, long2) __mcode("660F3A44rMUv", 0);
  long2 movq(long2, long2) __mcode("F30F7ErM");
  long2 pcmpeqq(long2, long2) __mcode("660F3829rMcv");
  long2 pcmpgtq(long2, long2) __mcode("660F3837rM");
  long2 pextrq_0(long2) __mcode("660F3A16RmU", 0);
  long2 pextrq_1(long2) __mcode("660F3A16RmU", 1);
  long2 pextrq(long2) __mcode("660F3A16RmU", 0);
  long2 pinsrq_0(long2, long2) __mcode("660F3A22rXMU", 0);
  long2 pinsrq_1(long2, long2) __mcode("660F3A22rXMU", 1);
  long2 pinsrq(long2, long2) __mcode("660F3A22rXMU", 0);
  long2 punpckhqdq(long2) __mcode("660F6DrMv");
  long2 punpcklqdq(long2) __mcode("660F6CrMv");
  long2 psllq(long2, long2) __mcode("660FF3rMv");
  long2 psrlq(long2, long2) __mcode("660FD3rMv");
]]
ffi.cdef[[
  int4 movd(int32_t) __mcode("660F6ErMv");
  int32_t movdto(int4) __mcode("660F7ErRv");
  long2 movq(int64_t) __mcode("660F6ErMXv");
  int64_t movqto(long2) __mcode("660F7ErRXv");
  int4 pand(int4, int4) __mcode("660FDBrMcv");
  int4 pandn(int4, int4) __mcode("660FDFrMv");
  int4 por(int4, int4) __mcode("660FEBrMcv");
  int4 pxor(int4, int4) __mcode("660FEFrMcv");
  int32_t movmskps(void* xmm) __mcode("0F50rMEv");
  int32_t vmovmskps(void* ymm) __mcode("0F50rMEXV");
  int32_t movmskpd(void* xmm) __mcode("660F50rMEv");
  int32_t vmovmskpd(void* ymm) __mcode("660F50rMEXV");
  byte16 pshufb(void* xmm, void* xmm) __mcode("660F3800rMEv");
  int4 pslldq_1(void* xmm) __mcode("660F737mUEv", 1);
  int4 pslldq_4(void* xmm) __mcode("660F737mUEv", 4);
  int4 pslldq_8(void* xmm) __mcode("660F737mUEv", 8);
  int4 pslldq_12(void* xmm) __mcode("660F737mUEv", 12);
  int4 pslldq(void* xmm) __mcode("660F737mUEv", 0);
  int4 psrldq(void* xmm) __mcode("660F733mUEv", 0);
  int4 palignr(void* xmm, void* xmm) __mcode("660F3A0FrMEU", 0);
  int32_t bsr(int32_t) __mcode("0FBDrM");
  int32_t bsf(int32_t) __mcode("0FBCrM");
  int32_t popcnt(int32_t) __mcode("f30fb8rM");
  int4 pmovsxbd(int4) __mcode("660F3821rM");
  int4 pmovzxbd(int4) __mcode("660F3831rM");
  long2 pmovsxbq(int4) __mcode("660F3822rM");
  long2 pmovzxbq(int4) __mcode("660F3832rM");
  float4 vextractf128_0(void* ymm) __mcode("660F3A19RmUV", 0);
  float4 vextractf128_1(void* ymm) __mcode("660F3A19RmUV", 1);
  float4 vextractf128(void* ymm) __mcode("660F3A19RmUV", 0);
  float8 vinsertf128_0(void* ymm, void* xmm) __mcode("660F3A18rMUV", 0);
  float8 vinsertf128_1(void* ymm, void* xmm) __mcode("660F3A18rMUV", 1);
  float8 vinsertf128(void* ymm, void* xmm) __mcode("660F3A18rMUV", 0);
  float8 vperm2f128(void* ymm, void* ymm) __mcode("660F3A06rMUV", 0);
  int8 vperm2i128(void* ymm, void* ymm) __mcode("660F3A46rMUV", 0);
]]
local format = string.format
local vtostring = {
  float4 = function(v)
    return format("float4(%d, %d, %d, %d)", v[0], v[1], v[2], v[3])
  end,
  float8 = function(v)
    return format("float8(%d, %d, %d, %d, %d, %d, %d, %d)", v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7])
  end,
  byte16 = function(v)
    return format("byte16(%d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d)",
                  v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7], v[8], v[9], v[10], v[11], v[12], v[13], v[14], v[15])
  end,

  int4 = function(v) return format("int4(%d, %d, %d, %d)", v[0], v[1], v[2], v[3]) end,
  int8 = function(v) return format("int8(%d, %d, %d, %d, %d, %d, %d, %d)", v[0], v[1], v[2], v[3], v[4], v[5], v[6], v[7]) end,

  long2 = function(v) return format("long2(%s, %s)", tostring(v[0]), tostring(v[1])) end,
  long4 = function(v) return format("long4(%s, %s, %s, %s)", tostring(v[0]), tostring(v[1]), tostring(v[2]), tostring(v[3])) end,

  double2 = function(v) return format("double2(%d, %d)", v[0], v[1]) end,
  double4 = function(v) return format("double4(%d, %d, %d, %d)", v[0], v[1], v[2], v[3]) end,
}
local byte16 = _G.byte16 or {}
local byte16mt = _G.byte16mt or {__index = byte16}
byte16mt.__tostring = vtostring.byte16

local byte161vec = ffi.new("byte16", 1)
byte16.vec1 = byte161vec

function byte16mt:__add(v2)
  return (asm.paddb(self, v2))
end

function byte16mt:__sub(v2)
  return (asm.psubb(self, v2))
end

function byte16:cmpeq(v2)
  return (asm.pcmpeqb(self, v2))
end

function byte16:cmpgt(v2)
  return (asm.pcmpgtb(self, v2))
end

function byte16:cmplt(v2)
  return (asm.pcmpgtb(v2, self))
end

function byte16:min(v2)
  return (asm.pminsb(self, v2))
end

function byte16:max(v2)
  return (asm.pmaxsb(self, v2))
end

function byte16:minu(v2)
  return (asm.pminub(self, v2))
end

function byte16:maxu(v2)
  return (asm.pmaxub(self, v2))
end

local int4 = _G.int4 or {}
local int4mt = _G.int4mt or {__index = int4}
int4mt.__tostring = vtostring.int4

local int41vec = ffi.new("int4", 1)
int4.vec1 = int41vec

function int4mt:__add(v2)
  return (asm.paddd(self, v2))
end

function int4mt:__sub(v2)
  return (asm.psubd(self, v2))
end

function int4mt:__mul(v2)
  return (asm.pmulld(self, v2))
end

function int4:cmpeq(v2)
  return (asm.pcmpeqd(self, v2))
end

function int4:cmpgt(v2)
  return (asm.pcmpgtd(self, v2))
end

function int4:cmplt(v2)
  return (asm.pcmpgtd(v2, self))
end

function int4:min(v2)
  return (asm.pminsd(self, v2))
end

function int4:max(v2)
  return (asm.pmaxsd(self, v2))
end

function int4:maxu(v2)
  return (asm.pminud(self, v2))
end

function int4:maxu(v2)
  return (asm.pmaxud(self, v2))
end

local long4 = _G.long4 or {}
local long4mt = _G.long4mt or {__index = long4}
long4mt.__tostring = vtostring.long4

local long41vec = ffi.new("long4", 1)
long4.vec1 = long41vec

local float4 = _G.float4 or {}
local float4mt = _G.float4mt or {__index = float4}
float4mt.__tostring = vtostring.float4

local float41vec = ffi.new("float4", 1)
float4.vec1 = float41vec

function float4mt:__add(v2)
  return (asm.addps(self, v2))
end

function float4mt:__sub(v2)
  return (asm.subps(self, v2))
end

function float4mt:__div(v2)
  return (asm.divps(self, v2))
end

function float4mt:__mul(v2)
  return (asm.mulps(self, v2))
end

function float4:max(v2)
  return (asm.maxps(self, v2))
end

function float4:min(v2)
  return (asm.minps(self, v2))
end

local double2 = _G.double2 or {}
local double2mt = _G.double2mt or {__index = double2}
double2mt.__tostring = vtostring.double2

local double21vec = ffi.new("double2", 1)
double2.vec1 = double21vec

local float8 = _G.float8 or {}
local float8mt = _G.float8mt or {__index = float8}
float8mt.__tostring = vtostring.float8

local float81vec = ffi.new("float8", 1)
float8.vec1 = float81vec

local double4 = _G.double4 or {}
local double4mt = _G.double4mt or {__index = double4}
double4mt.__tostring = vtostring.double4

local double41vec = ffi.new("double4", 1)
double4.vec1 = double41vec

local long2 = _G.long2 or {}
local long2mt = _G.long2mt or {__index = long2}
long2mt.__tostring = vtostring.long2

local long21vec = ffi.new("long2", 1)
long2.vec1 = long21vec

function long2mt:__add(v2)
  return (asm.paddq(self, v2))
end

function long2mt:__sub(v2)
  return (asm.psubq(self, v2))
end

function long2mt:__mul(v2)
  return (asm.pmuldq(self, v2))
end

function long2:cmpeq(v2)
  return (asm.pcmpeqq(self, v2))
end

function long2:cmpgt(v2)
  return (asm.pcmpgtq(self, v2))
end

function long2:cmplt(v2)
  return (asm.pcmpgtq(v2, self))
end


--use an alignment equal to a cacheline so we don't load across a cache line
local shufbshift = ffi.new([[
  union __attribute__((packed, aligned(64))){
    struct{
      byte16 start;
      byte16 center;
      byte16 end;
    };
    const int8_t bytes[48];
  }]],

  ffi.new("byte16", -1),
  ffi.new("byte16", 0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15),
  ffi.new("byte16", -1)
)

local function varshift(v, shift)
  local shuf = ffi.cast("byte16*", shufbshift.byte+shift)
  return asm.pshufb(shuf, shuf[0])
end

function int4:getmask()
  return asm.movmskps(self)
end

function int4:band(v2)
  return asm.pand(self, v2)
end

function int4:bandnot(v2)
  return asm.pandn(self, v2)
end

function int4:bor(v2)
  return asm.por(self, v2)
end

function int4:bxor(v2)
  return asm.pxor(self, v2)
end

function byte16:band(v2)
  return asm.pand(self, v2)
end

function byte16:bandnot(v2)
  return asm.pandn(self, v2)
end

function byte16:bor(v2)
  return asm.por(self, v2)
end

function byte16:bxor(v2)
  return asm.pxor(self, v2)
end

function float4:getmask()
  return asm.movmskps(self)
end

function float8:getmask()
  return asm.vmovmskps(self)
end

function double2:getmask()
  return asm.movmskpd(self)
end

function long2:getmask()
  return asm.movmskpd(self)
end

function double4:getmask()
  return asm.vmovmskpd(self)
end

function long4:getmask()
  return asm.vmovmskpd(self)
end

ffi.metatype("byte16", byte16mt)
byte16 = ffi.typeof("byte16")
ffi.metatype("int4", int4mt)
int4 = ffi.typeof("int4")
ffi.metatype("long4", long4mt)
long4 = ffi.typeof("long4")
ffi.metatype("float4", float4mt)
float4 = ffi.typeof("float4")
ffi.metatype("double2", double2mt)
double2 = ffi.typeof("double2")
ffi.metatype("float8", float8mt)
float8 = ffi.typeof("float8")
ffi.metatype("double4", double4mt)
double4 = ffi.typeof("double4")
ffi.metatype("long2", long2mt)
long2 = ffi.typeof("long2")

profiler.StartTimer("intrinsic")

local o = float4(0,0,0,0)
for i = 1, 1000000 do
	o = o + (float4(4,3,2,0) * float4(1,2,3,0))
end
print(o)

profiler.StopTimer()

profiler.StartTimer("vec3")

local o = Vec3(0,0,0)
for i = 1, 1000000 do
	o = o + (Vec3(4,3,2) * Vec3(1,2,3))
end
print(o)

profiler.StopTimer()