local header = [[
typedef struct GLFWmonitor GLFWmonitor;
typedef struct GLFWwindow GLFWwindow;

typedef void (* GLFWglproc)(void);
typedef void (* GLFWerrorfun)(int,const char*);
typedef void (* GLFWwindowposfun)(GLFWwindow*,int,int);
typedef void (* GLFWwindowsizefun)(GLFWwindow*,int,int);
typedef void (* GLFWwindowclosefun)(GLFWwindow*);
typedef void (* GLFWwindowrefreshfun)(GLFWwindow*);
typedef void (* GLFWwindowfocusfun)(GLFWwindow*,bool);
typedef void (* GLFWwindowiconifyfun)(GLFWwindow*,int);
typedef void (* GLFWframebuffersizefun)(GLFWwindow*,int,int);
typedef void (* GLFWmousebuttonfun)(GLFWwindow*,int,int,int);
typedef void (* GLFWcursorposfun)(GLFWwindow*,double,double);
typedef void (* GLFWcursorenterfun)(GLFWwindow*,int);
typedef void (* GLFWscrollfun)(GLFWwindow*,double,double);
typedef void (* GLFWkeyfun)(GLFWwindow*,int,int,int,int);
typedef void (* GLFWcharfun)(GLFWwindow*,unsigned int);
typedef void (* GLFWmonitorfun)(GLFWmonitor*,int);

GLFWkeyfun glfwSetKeyCallback(GLFWwindow* window, GLFWkeyfun cbfun);
GLFWcharfun glfwSetCharCallback(GLFWwindow* window, GLFWcharfun cbfun);
GLFWmousebuttonfun glfwSetMouseButtonCallback(GLFWwindow* window, GLFWmousebuttonfun cbfun);
GLFWcursorposfun glfwSetCursorPosCallback(GLFWwindow* window, GLFWcursorposfun cbfun);
GLFWcursorenterfun glfwSetCursorEnterCallback(GLFWwindow* window, GLFWcursorenterfun cbfun);
GLFWerrorfun glfwSetErrorCallback(GLFWerrorfun cbfun);
GLFWwindowposfun glfwSetWindowPosCallback(GLFWwindow* window, GLFWwindowposfun cbfun);
GLFWwindowsizefun glfwSetWindowSizeCallback(GLFWwindow* window, GLFWwindowsizefun cbfun);
GLFWwindowclosefun glfwSetWindowCloseCallback(GLFWwindow* window, GLFWwindowclosefun cbfun);
GLFWwindowrefreshfun glfwSetWindowRefreshCallback(GLFWwindow* window, GLFWwindowrefreshfun cbfun);
GLFWwindowfocusfun glfwSetWindowFocusCallback(GLFWwindow* window, GLFWwindowfocusfun cbfun);
GLFWwindowiconifyfun glfwSetWindowIconifyCallback(GLFWwindow* window, GLFWwindowiconifyfun cbfun);
GLFWframebuffersizefun glfwSetFramebufferSizeCallback(GLFWwindow* window, GLFWframebuffersizefun cbfun);
GLFWscrollfun glfwSetScrollCallback(GLFWwindow* window, GLFWscrollfun cbfun);

typedef struct { int width; int height;
	int redBits;
	int greenBits;
	int blueBits;
	int refreshRate;
} GLFWvidmode;

typedef struct {
	unsigned short* red;
	unsigned short* green;
	unsigned short* blue;
	unsigned int size;
} GLFWgammaramp;

int glfwInit(void);
void glfwTerminate(void);
void glfwGetVersion(int* major, int* minor, int* rev);
const char* glfwGetVersionString(void);
GLFWmonitor** glfwGetMonitors(int* count);
GLFWmonitor* glfwGetPrimaryMonitor(void);
void glfwGetMonitorPos(GLFWmonitor* monitor, int* xpos, int* ypos);
void glfwGetMonitorPhysicalSize(GLFWmonitor* monitor, int* width, int* height);
const char* glfwGetMonitorName(GLFWmonitor* monitor);
GLFWmonitorfun glfwSetMonitorCallback(GLFWmonitorfun cbfun);
const GLFWvidmode* glfwGetVideoModes(GLFWmonitor* monitor, int* count);
const GLFWvidmode* glfwGetVideoMode(GLFWmonitor* monitor);
void glfwSetGamma(GLFWmonitor* monitor, float gamma);
const GLFWgammaramp* glfwGetGammaRamp(GLFWmonitor* monitor);
void glfwSetGammaRamp(GLFWmonitor* monitor, const GLFWgammaramp* ramp);
void glfwDefaultWindowHints(void);
void glfwWindowHint(int target, int hint);
GLFWwindow* glfwCreateWindow(int width, int height, const char* title, GLFWmonitor* monitor, GLFWwindow* share);
void glfwDestroyWindow(GLFWwindow* window);
int glfwWindowShouldClose(GLFWwindow* window);
void glfwSetWindowShouldClose(GLFWwindow* window, int value);
void glfwSetWindowTitle(GLFWwindow* window, const char* title);
void glfwGetWindowPos(GLFWwindow* window, int* xpos, int* ypos);
void glfwSetWindowPos(GLFWwindow* window, int xpos, int ypos);
void glfwGetWindowSize(GLFWwindow* window, int* width, int* height);
void glfwSetWindowSize(GLFWwindow* window, int width, int height);
void glfwGetFramebufferSize(GLFWwindow* window, int* width, int* height);
void glfwIconifyWindow(GLFWwindow* window);
void glfwRestoreWindow(GLFWwindow* window);
void glfwShowWindow(GLFWwindow* window);
void glfwHideWindow(GLFWwindow* window);
GLFWmonitor* glfwGetWindowMonitor(GLFWwindow* window);
int glfwGetWindowAttrib(GLFWwindow* window, int attrib);
void glfwSetWindowUserPointer(GLFWwindow* window, void* pointer);
void* glfwGetWindowUserPointer(GLFWwindow* window);
void glfwPollEvents(void);
void glfwWaitEvents(void);
int glfwGetInputMode(GLFWwindow* window, int mode);
void glfwSetInputMode(GLFWwindow* window, int mode, int value);
int glfwGetKey(GLFWwindow* window, int key);
int glfwGetMouseButton(GLFWwindow* window, int button);
void glfwGetCursorPos(GLFWwindow* window, double* xpos, double* ypos);
void glfwSetCursorPos(GLFWwindow* window, double xpos, double ypos);
int glfwJoystickPresent(int joy);
const float* glfwGetJoystickAxes(int joy, int* count);
const unsigned char* glfwGetJoystickButtons(int joy, int* count);
const char* glfwGetJoystickName(int joy);
void glfwSetClipboardString(GLFWwindow* window, const char* string);
const char* glfwGetClipboardString(GLFWwindow* window);
double glfwGetTime(void);
void glfwSetTime(double time);
void glfwMakeContextCurrent(GLFWwindow* window);
GLFWwindow* glfwGetCurrentContext(void);
void glfwSwapBuffers(GLFWwindow* window);
void glfwSwapInterval(int interval);
int glfwExtensionSupported(const char* extension);
GLFWglproc glfwGetProcAddress(const char* procname);
]]

local e = {}

e.GLFW_VERSION_MAJOR = 3
e.GLFW_VERSION_MINOR = 0
e.GLFW_VERSION_REVISION = 0
e.GLFW_RELEASE = 0
e.GLFW_PRESS = 1
e.GLFW_REPEAT = 2
e.GLFW_KEY_UNKNOWN = -1
e.GLFW_KEY_SPACE = 32
e.GLFW_KEY_APOSTROPHE = 39
e.GLFW_KEY_COMMA = 44
e.GLFW_KEY_MINUS = 45
e.GLFW_KEY_PERIOD = 46
e.GLFW_KEY_SLASH = 47
e.GLFW_KEY_0 = 48
e.GLFW_KEY_1 = 49
e.GLFW_KEY_2 = 50
e.GLFW_KEY_3 = 51
e.GLFW_KEY_4 = 52
e.GLFW_KEY_5 = 53
e.GLFW_KEY_6 = 54
e.GLFW_KEY_7 = 55
e.GLFW_KEY_8 = 56
e.GLFW_KEY_9 = 57
e.GLFW_KEY_SEMICOLON = 59
e.GLFW_KEY_EQUAL = 61
e.GLFW_KEY_A = 65
e.GLFW_KEY_B = 66
e.GLFW_KEY_C = 67
e.GLFW_KEY_D = 68
e.GLFW_KEY_E = 69
e.GLFW_KEY_F = 70
e.GLFW_KEY_G = 71
e.GLFW_KEY_H = 72
e.GLFW_KEY_I = 73
e.GLFW_KEY_J = 74
e.GLFW_KEY_K = 75
e.GLFW_KEY_L = 76
e.GLFW_KEY_M = 77
e.GLFW_KEY_N = 78
e.GLFW_KEY_O = 79
e.GLFW_KEY_P = 80
e.GLFW_KEY_Q = 81
e.GLFW_KEY_R = 82
e.GLFW_KEY_S = 83
e.GLFW_KEY_T = 84
e.GLFW_KEY_U = 85
e.GLFW_KEY_V = 86
e.GLFW_KEY_W = 87
e.GLFW_KEY_X = 88
e.GLFW_KEY_Y = 89
e.GLFW_KEY_Z = 90
e.GLFW_KEY_LEFT_BRACKET = 91
e.GLFW_KEY_BACKSLASH = 92
e.GLFW_KEY_RIGHT_BRACKET = 93
e.GLFW_KEY_GRAVE_ACCENT = 96
e.GLFW_KEY_WORLD_1 = 161
e.GLFW_KEY_WORLD_2 = 162
e.GLFW_KEY_ESCAPE = 256
e.GLFW_KEY_ENTER = 257
e.GLFW_KEY_TAB = 258
e.GLFW_KEY_BACKSPACE = 259
e.GLFW_KEY_INSERT = 260
e.GLFW_KEY_DELETE = 261
e.GLFW_KEY_RIGHT = 262
e.GLFW_KEY_LEFT = 263
e.GLFW_KEY_DOWN = 264
e.GLFW_KEY_UP = 265
e.GLFW_KEY_PAGE_UP = 266
e.GLFW_KEY_PAGE_DOWN = 267
e.GLFW_KEY_HOME = 268
e.GLFW_KEY_END = 269
e.GLFW_KEY_CAPS_LOCK = 280
e.GLFW_KEY_SCROLL_LOCK = 281
e.GLFW_KEY_NUM_LOCK = 282
e.GLFW_KEY_PRINT_SCREEN = 283
e.GLFW_KEY_PAUSE = 284
e.GLFW_KEY_F1 = 290
e.GLFW_KEY_F2 = 291
e.GLFW_KEY_F3 = 292
e.GLFW_KEY_F4 = 293
e.GLFW_KEY_F5 = 294
e.GLFW_KEY_F6 = 295
e.GLFW_KEY_F7 = 296
e.GLFW_KEY_F8 = 297
e.GLFW_KEY_F9 = 298
e.GLFW_KEY_F10 = 299
e.GLFW_KEY_F11 = 300
e.GLFW_KEY_F12 = 301
e.GLFW_KEY_F13 = 302
e.GLFW_KEY_F14 = 303
e.GLFW_KEY_F15 = 304
e.GLFW_KEY_F16 = 305
e.GLFW_KEY_F17 = 306
e.GLFW_KEY_F18 = 307
e.GLFW_KEY_F19 = 308
e.GLFW_KEY_F20 = 309
e.GLFW_KEY_F21 = 310
e.GLFW_KEY_F22 = 311
e.GLFW_KEY_F23 = 312
e.GLFW_KEY_F24 = 313
e.GLFW_KEY_F25 = 314
e.GLFW_KEY_KP_0 = 320
e.GLFW_KEY_KP_1 = 321
e.GLFW_KEY_KP_2 = 322
e.GLFW_KEY_KP_3 = 323
e.GLFW_KEY_KP_4 = 324
e.GLFW_KEY_KP_5 = 325
e.GLFW_KEY_KP_6 = 326
e.GLFW_KEY_KP_7 = 327
e.GLFW_KEY_KP_8 = 328
e.GLFW_KEY_KP_9 = 329
e.GLFW_KEY_KP_DECIMAL = 330
e.GLFW_KEY_KP_DIVIDE = 331
e.GLFW_KEY_KP_MULTIPLY = 332
e.GLFW_KEY_KP_SUBTRACT = 333
e.GLFW_KEY_KP_ADD = 334
e.GLFW_KEY_KP_ENTER = 335
e.GLFW_KEY_KP_EQUAL = 336
e.GLFW_KEY_LEFT_SHIFT = 340
e.GLFW_KEY_LEFT_CONTROL = 341
e.GLFW_KEY_LEFT_ALT = 342
e.GLFW_KEY_LEFT_SUPER = 343
e.GLFW_KEY_RIGHT_SHIFT = 344
e.GLFW_KEY_RIGHT_CONTROL = 345
e.GLFW_KEY_RIGHT_ALT = 346
e.GLFW_KEY_RIGHT_SUPER = 347
e.GLFW_KEY_MENU = 348
e.GLFW_MOD_SHIFT = 1
e.GLFW_MOD_CONTROL = 2
e.GLFW_MOD_ALT = 4
e.GLFW_MOD_SUPER = 8
e.GLFW_MOUSE_BUTTON_1 = 0
e.GLFW_MOUSE_BUTTON_2 = 1
e.GLFW_MOUSE_BUTTON_3 = 2
e.GLFW_MOUSE_BUTTON_4 = 3
e.GLFW_MOUSE_BUTTON_5 = 4
e.GLFW_MOUSE_BUTTON_6 = 5
e.GLFW_MOUSE_BUTTON_7 = 6
e.GLFW_MOUSE_BUTTON_8 = 7
e.GLFW_JOYSTICK_1 = 0
e.GLFW_JOYSTICK_2 = 1
e.GLFW_JOYSTICK_3 = 2
e.GLFW_JOYSTICK_4 = 3
e.GLFW_JOYSTICK_5 = 4
e.GLFW_JOYSTICK_6 = 5
e.GLFW_JOYSTICK_7 = 6
e.GLFW_JOYSTICK_8 = 7
e.GLFW_JOYSTICK_9 = 8
e.GLFW_JOYSTICK_10 = 9
e.GLFW_JOYSTICK_11 = 10
e.GLFW_JOYSTICK_12 = 11
e.GLFW_JOYSTICK_13 = 12
e.GLFW_JOYSTICK_14 = 13
e.GLFW_JOYSTICK_15 = 14
e.GLFW_JOYSTICK_16 = 15
e.GLFW_NOT_INITIALIZED = 65537
e.GLFW_NO_CURRENT_CONTEXT = 65538
e.GLFW_INVALID_ENUM = 65539
e.GLFW_INVALID_VALUE = 65540
e.GLFW_OUT_OF_MEMORY = 65541
e.GLFW_API_UNAVAILABLE = 65542
e.GLFW_VERSION_UNAVAILABLE = 65543
e.GLFW_PLATFORM_ERROR = 65544
e.GLFW_FORMAT_UNAVAILABLE = 65545
e.GLFW_FOCUSED = 131073
e.GLFW_ICONIFIED = 131074
e.GLFW_RESIZABLE = 131075
e.GLFW_VISIBLE = 131076
e.GLFW_DECORATED = 131077
e.GLFW_RED_BITS = 135169
e.GLFW_GREEN_BITS = 135170
e.GLFW_BLUE_BITS = 135171
e.GLFW_ALPHA_BITS = 135172
e.GLFW_DEPTH_BITS = 135173
e.GLFW_STENCIL_BITS = 135174
e.GLFW_ACCUM_RED_BITS = 135175
e.GLFW_ACCUM_GREEN_BITS = 135176
e.GLFW_ACCUM_BLUE_BITS = 135177
e.GLFW_ACCUM_ALPHA_BITS = 135178
e.GLFW_AUX_BUFFERS = 135179
e.GLFW_STEREO = 135180
e.GLFW_SAMPLES = 135181
e.GLFW_SRGB_CAPABLE = 135182
e.GLFW_REFRESH_RATE = 135183
e.GLFW_CLIENT_API = 139265
e.GLFW_CONTEXT_VERSION_MAJOR = 139266
e.GLFW_CONTEXT_VERSION_MINOR = 139267
e.GLFW_CONTEXT_REVISION = 139268
e.GLFW_CONTEXT_ROBUSTNESS = 139269
e.GLFW_OPENGL_FORWARD_COMPAT = 139270
e.GLFW_OPENGL_DEBUG_CONTEXT = 139271
e.GLFW_OPENGL_PROFILE = 139272
e.GLFW_OPENGL_API = 196609
e.GLFW_OPENGL_ES_API = 196610
e.GLFW_NO_ROBUSTNESS = 0
e.GLFW_NO_RESET_NOTIFICATION = 200705
e.GLFW_LOSE_CONTEXT_ON_RESET = 200706
e.GLFW_OPENGL_ANY_PROFILE = 0
e.GLFW_OPENGL_CORE_PROFILE = 204801
e.GLFW_OPENGL_COMPAT_PROFILE = 204802
e.GLFW_CURSOR = 208897
e.GLFW_STICKY_KEYS = 208898
e.GLFW_STICKY_MOUSE_BUTTONS = 208899
e.GLFW_CURSOR_NORMAL = 212993
e.GLFW_CURSOR_HIDDEN = 212994
e.GLFW_CURSOR_DISABLED = 212995
e.GLFW_CONNECTED = 262145
e.GLFW_DISCONNECTED = 262146

local glfw = {}

for key, val in pairs(e) do
	_E[key] = val
end

local reverse_enums = {}

for k,v in pairs(e) do
	local nice = k:lower():sub(6)
	reverse_enums[v] = nice
end

function glfw.EnumToString(num)
	return reverse_enums[num]
end

local keys = {}

for k,v in pairs(reverse_enums) do
	
	if v:sub(0, 3) == "key" then
		keys[k] = v:sub(5)
	end
end

function glfw.KeyToString(num)
	return keys[num]
end

local mousebuttons = {}

for k,v in pairs(reverse_enums) do
	
	if v:sub(0, 5) == "mouse" then
		mousebuttons[k] = v:sub(7)
	end
end

function glfw.MouseToString(num)
	return mousebuttons[num]
end

ffi.cdef(header)

local lib = ffi.load(jit.os == "Linux" and "glfw" or "glfw3")

glfw.header = header
glfw.lib = lib

for line in header:gmatch("(.-)\n") do
	local name = line:match("glfw(.-)%(")
	
	if name then
		glfw[name] = lib["glfw" .. name]
	end
end

glfw.Init()

return glfw
