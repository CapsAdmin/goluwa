local ffi = require("ffi")
ffi.cdef([[struct GLFWmonitor {};
struct GLFWwindow {};
struct GLFWcursor {};
struct GLFWvidmode {int width;int height;int redBits;int greenBits;int blueBits;int refreshRate;};
struct GLFWgammaramp {unsigned short*red;unsigned short*green;unsigned short*blue;unsigned int size;};
struct GLFWimage {int width;int height;unsigned char*pixels;};
void(glfwMaximizeWindow)(struct GLFWwindow*);
void(glfwRestoreWindow)(struct GLFWwindow*);
unsigned long(glfwGetTimerValue)();
void(glfwDestroyCursor)(struct GLFWcursor*);
const char*(glfwGetVersionString)();
void(glfwGetWindowPos)(struct GLFWwindow*,int*,int*);
void(*glfwSetWindowRefreshCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*)))(struct GLFWwindow*);
void(glfwSetWindowShouldClose)(struct GLFWwindow*,int);
void(glfwDestroyWindow)(struct GLFWwindow*);
void(glfwSetCursorPos)(struct GLFWwindow*,double,double);
void(*glfwSetCharCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,unsigned int)))(struct GLFWwindow*,unsigned int);
int(glfwGetPhysicalDevicePresentationSupport)(void*,void*,unsigned int);
void(*glfwSetErrorCallback(void(*cbfun)(int,const char*)))(int,const char*);
int(glfwWindowShouldClose)(struct GLFWwindow*);
void(*glfwSetWindowIconifyCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,int)))(struct GLFWwindow*,int);
void(glfwGetVersion)(int*,int*,int*);
const float*(glfwGetJoystickAxes)(int,int*);
struct GLFWwindow*(glfwCreateWindow)(int,int,const char*,struct GLFWmonitor*,struct GLFWwindow*);
void(*glfwSetCursorEnterCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,int)))(struct GLFWwindow*,int);
void(glfwSetWindowIcon)(struct GLFWwindow*,int,const struct GLFWimage*);
void(*glfwSetFramebufferSizeCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,int,int)))(struct GLFWwindow*,int,int);
const char*(glfwGetMonitorName)(struct GLFWmonitor*);
void(glfwSetWindowTitle)(struct GLFWwindow*,const char*);
int(glfwCreateWindowSurface)(void*,struct GLFWwindow*,void*,void**);
void(*glfwGetInstanceProcAddress(void*,const char*))();
const char**(glfwGetRequiredInstanceExtensions)(unsigned int*);
int(glfwVulkanSupported)();
int(glfwJoystickPresent)(int);
void(glfwGetMonitorPos)(struct GLFWmonitor*,int*,int*);
void(glfwFocusWindow)(struct GLFWwindow*);
void(glfwSwapInterval)(int);
void(glfwSwapBuffers)(struct GLFWwindow*);
struct GLFWwindow*(glfwGetCurrentContext)();
struct GLFWmonitor*(glfwGetPrimaryMonitor)();
void(glfwMakeContextCurrent)(struct GLFWwindow*);
int(glfwGetKey)(struct GLFWwindow*,int);
double(glfwGetTime)();
const char*(glfwGetClipboardString)(struct GLFWwindow*);
void(glfwGetCursorPos)(struct GLFWwindow*,double*,double*);
const unsigned char*(glfwGetJoystickButtons)(int,int*);
void(glfwIconifyWindow)(struct GLFWwindow*);
void(*glfwSetMouseButtonCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,int,int,int)))(struct GLFWwindow*,int,int,int);
void(*glfwSetKeyCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,int,int,int,int)))(struct GLFWwindow*,int,int,int,int);
void(glfwSetCursor)(struct GLFWwindow*,struct GLFWcursor*);
struct GLFWcursor*(glfwCreateStandardCursor)(int);
struct GLFWcursor*(glfwCreateCursor)(const struct GLFWimage*,int,int);
void(*glfwSetJoystickCallback(void(*cbfun)(int,int)))(int,int);
int(glfwGetMouseButton)(struct GLFWwindow*,int);
unsigned long(glfwGetTimerFrequency)();
const char*(glfwGetKeyName)(int,int);
void(glfwSetInputMode)(struct GLFWwindow*,int,int);
int(glfwGetInputMode)(struct GLFWwindow*,int);
void(glfwPostEmptyEvent)();
void(glfwPollEvents)();
void(*glfwSetWindowFocusCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,int)))(struct GLFWwindow*,int);
void(*glfwSetWindowCloseCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*)))(struct GLFWwindow*);
void(*glfwSetWindowPosCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,int,int)))(struct GLFWwindow*,int,int);
void*(glfwGetWindowUserPointer)(struct GLFWwindow*);
void(glfwSetWindowUserPointer)(struct GLFWwindow*,void*);
int(glfwGetWindowAttrib)(struct GLFWwindow*,int);
void(*glfwGetProcAddress(const char*))();
void(glfwSetWindowPos)(struct GLFWwindow*,int,int);
void(glfwSetWindowMonitor)(struct GLFWwindow*,struct GLFWmonitor*,int,int,int,int,int);
void(glfwHideWindow)(struct GLFWwindow*);
void(glfwShowWindow)(struct GLFWwindow*);
void(*glfwSetDropCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,int,const char**)))(struct GLFWwindow*,int,const char**);
void(glfwGetFramebufferSize)(struct GLFWwindow*,int*,int*);
void(glfwSetWindowSize)(struct GLFWwindow*,int,int);
void(glfwSetWindowAspectRatio)(struct GLFWwindow*,int,int);
void(glfwSetWindowSizeLimits)(struct GLFWwindow*,int,int,int,int);
void(glfwGetWindowSize)(struct GLFWwindow*,int*,int*);
struct GLFWmonitor*(glfwGetWindowMonitor)(struct GLFWwindow*);
void(glfwWindowHint)(int,int);
void(glfwDefaultWindowHints)();
void(glfwSetGammaRamp)(struct GLFWmonitor*,const struct GLFWgammaramp*);
const struct GLFWgammaramp*(glfwGetGammaRamp)(struct GLFWmonitor*);
void(glfwSetGamma)(struct GLFWmonitor*,float);
const struct GLFWvidmode*(glfwGetVideoMode)(struct GLFWmonitor*);
const struct GLFWvidmode*(glfwGetVideoModes)(struct GLFWmonitor*,int*);
void(*glfwSetMonitorCallback(void(*cbfun)(struct GLFWmonitor*,int)))(struct GLFWmonitor*,int);
void(glfwTerminate)();
int(glfwInit)();
void(glfwGetWindowFrameSize)(struct GLFWwindow*,int*,int*,int*,int*);
const char*(glfwGetJoystickName)(int);
void(*glfwSetWindowSizeCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,int,int)))(struct GLFWwindow*,int,int);
void(glfwSetTime)(double);
void(glfwWaitEvents)();
int(glfwExtensionSupported)(const char*);
struct GLFWmonitor**(glfwGetMonitors)(int*);
int(glfwGetKeyScancode)(int);
void(glfwGetMonitorPhysicalSize)(struct GLFWmonitor*,int*,int*);
void(*glfwSetCharModsCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,unsigned int,int)))(struct GLFWwindow*,unsigned int,int);
void(glfwSetClipboardString)(struct GLFWwindow*,const char*);
void(*glfwSetCursorPosCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,double,double)))(struct GLFWwindow*,double,double);
void(*glfwSetScrollCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,double,double)))(struct GLFWwindow*,double,double);
void(glfwWaitEventsTimeout)(double);
]])
local CLIB = ffi.load(_G.FFI_LIB or "glfw")
local library = {}
library = {
	MaximizeWindow = CLIB.glfwMaximizeWindow,
	RestoreWindow = CLIB.glfwRestoreWindow,
	GetTimerValue = CLIB.glfwGetTimerValue,
	DestroyCursor = CLIB.glfwDestroyCursor,
	GetVersionString = CLIB.glfwGetVersionString,
	GetWindowPos = CLIB.glfwGetWindowPos,
	SetWindowRefreshCallback = CLIB.glfwSetWindowRefreshCallback,
	SetWindowShouldClose = CLIB.glfwSetWindowShouldClose,
	DestroyWindow = CLIB.glfwDestroyWindow,
	SetCursorPos = CLIB.glfwSetCursorPos,
	SetCharCallback = CLIB.glfwSetCharCallback,
	GetPhysicalDevicePresentationSupport = CLIB.glfwGetPhysicalDevicePresentationSupport,
	SetErrorCallback = CLIB.glfwSetErrorCallback,
	WindowShouldClose = CLIB.glfwWindowShouldClose,
	SetWindowIconifyCallback = CLIB.glfwSetWindowIconifyCallback,
	GetVersion = CLIB.glfwGetVersion,
	GetJoystickAxes = CLIB.glfwGetJoystickAxes,
	CreateWindow = CLIB.glfwCreateWindow,
	SetCursorEnterCallback = CLIB.glfwSetCursorEnterCallback,
	SetWindowIcon = CLIB.glfwSetWindowIcon,
	SetFramebufferSizeCallback = CLIB.glfwSetFramebufferSizeCallback,
	GetMonitorName = CLIB.glfwGetMonitorName,
	SetWindowTitle = CLIB.glfwSetWindowTitle,
	CreateWindowSurface = CLIB.glfwCreateWindowSurface,
	GetInstanceProcAddress = CLIB.glfwGetInstanceProcAddress,
	GetRequiredInstanceExtensions = CLIB.glfwGetRequiredInstanceExtensions,
	VulkanSupported = CLIB.glfwVulkanSupported,
	JoystickPresent = CLIB.glfwJoystickPresent,
	GetMonitorPos = CLIB.glfwGetMonitorPos,
	FocusWindow = CLIB.glfwFocusWindow,
	SwapInterval = CLIB.glfwSwapInterval,
	SwapBuffers = CLIB.glfwSwapBuffers,
	GetCurrentContext = CLIB.glfwGetCurrentContext,
	GetPrimaryMonitor = CLIB.glfwGetPrimaryMonitor,
	MakeContextCurrent = CLIB.glfwMakeContextCurrent,
	GetKey = CLIB.glfwGetKey,
	GetTime = CLIB.glfwGetTime,
	GetClipboardString = CLIB.glfwGetClipboardString,
	GetCursorPos = CLIB.glfwGetCursorPos,
	GetJoystickButtons = CLIB.glfwGetJoystickButtons,
	IconifyWindow = CLIB.glfwIconifyWindow,
	SetMouseButtonCallback = CLIB.glfwSetMouseButtonCallback,
	SetKeyCallback = CLIB.glfwSetKeyCallback,
	SetCursor = CLIB.glfwSetCursor,
	CreateStandardCursor = CLIB.glfwCreateStandardCursor,
	CreateCursor = CLIB.glfwCreateCursor,
	SetJoystickCallback = CLIB.glfwSetJoystickCallback,
	GetMouseButton = CLIB.glfwGetMouseButton,
	GetTimerFrequency = CLIB.glfwGetTimerFrequency,
	GetKeyName = CLIB.glfwGetKeyName,
	SetInputMode = CLIB.glfwSetInputMode,
	GetInputMode = CLIB.glfwGetInputMode,
	PostEmptyEvent = CLIB.glfwPostEmptyEvent,
	PollEvents = CLIB.glfwPollEvents,
	SetWindowFocusCallback = CLIB.glfwSetWindowFocusCallback,
	SetWindowCloseCallback = CLIB.glfwSetWindowCloseCallback,
	SetWindowPosCallback = CLIB.glfwSetWindowPosCallback,
	GetWindowUserPointer = CLIB.glfwGetWindowUserPointer,
	SetWindowUserPointer = CLIB.glfwSetWindowUserPointer,
	GetWindowAttrib = CLIB.glfwGetWindowAttrib,
	GetProcAddress = CLIB.glfwGetProcAddress,
	SetWindowPos = CLIB.glfwSetWindowPos,
	SetWindowMonitor = CLIB.glfwSetWindowMonitor,
	HideWindow = CLIB.glfwHideWindow,
	ShowWindow = CLIB.glfwShowWindow,
	SetDropCallback = CLIB.glfwSetDropCallback,
	GetFramebufferSize = CLIB.glfwGetFramebufferSize,
	SetWindowSize = CLIB.glfwSetWindowSize,
	SetWindowAspectRatio = CLIB.glfwSetWindowAspectRatio,
	SetWindowSizeLimits = CLIB.glfwSetWindowSizeLimits,
	GetWindowSize = CLIB.glfwGetWindowSize,
	GetWindowMonitor = CLIB.glfwGetWindowMonitor,
	WindowHint = CLIB.glfwWindowHint,
	DefaultWindowHints = CLIB.glfwDefaultWindowHints,
	SetGammaRamp = CLIB.glfwSetGammaRamp,
	GetGammaRamp = CLIB.glfwGetGammaRamp,
	SetGamma = CLIB.glfwSetGamma,
	GetVideoMode = CLIB.glfwGetVideoMode,
	GetVideoModes = CLIB.glfwGetVideoModes,
	SetMonitorCallback = CLIB.glfwSetMonitorCallback,
	Terminate = CLIB.glfwTerminate,
	Init = CLIB.glfwInit,
	GetWindowFrameSize = CLIB.glfwGetWindowFrameSize,
	GetJoystickName = CLIB.glfwGetJoystickName,
	SetWindowSizeCallback = CLIB.glfwSetWindowSizeCallback,
	SetTime = CLIB.glfwSetTime,
	WaitEvents = CLIB.glfwWaitEvents,
	ExtensionSupported = CLIB.glfwExtensionSupported,
	GetMonitors = CLIB.glfwGetMonitors,
	GetKeyScancode = CLIB.glfwGetKeyScancode,
	GetMonitorPhysicalSize = CLIB.glfwGetMonitorPhysicalSize,
	SetCharModsCallback = CLIB.glfwSetCharModsCallback,
	SetClipboardString = CLIB.glfwSetClipboardString,
	SetCursorPosCallback = CLIB.glfwSetCursorPosCallback,
	SetScrollCallback = CLIB.glfwSetScrollCallback,
	WaitEventsTimeout = CLIB.glfwWaitEventsTimeout,
}
library.e = {
	WINGDIAPI_DEFINED = 1,
	CALLBACK_DEFINED = 1,
	VERSION_MAJOR = 3,
	VERSION_MINOR = 3,
	VERSION_REVISION = 0,
	TRUE = 1,
	FALSE = 0,
	RELEASE = 0,
	PRESS = 1,
	REPEAT = 2,
	KEY_UNKNOWN = -1,
	KEY_SPACE = 32,
	KEY_APOSTROPHE = 39,
	KEY_COMMA = 44,
	KEY_MINUS = 45,
	KEY_PERIOD = 46,
	KEY_SLASH = 47,
	KEY_0 = 48,
	KEY_1 = 49,
	KEY_2 = 50,
	KEY_3 = 51,
	KEY_4 = 52,
	KEY_5 = 53,
	KEY_6 = 54,
	KEY_7 = 55,
	KEY_8 = 56,
	KEY_9 = 57,
	KEY_SEMICOLON = 59,
	KEY_EQUAL = 61,
	KEY_A = 65,
	KEY_B = 66,
	KEY_C = 67,
	KEY_D = 68,
	KEY_E = 69,
	KEY_F = 70,
	KEY_G = 71,
	KEY_H = 72,
	KEY_I = 73,
	KEY_J = 74,
	KEY_K = 75,
	KEY_L = 76,
	KEY_M = 77,
	KEY_N = 78,
	KEY_O = 79,
	KEY_P = 80,
	KEY_Q = 81,
	KEY_R = 82,
	KEY_S = 83,
	KEY_T = 84,
	KEY_U = 85,
	KEY_V = 86,
	KEY_W = 87,
	KEY_X = 88,
	KEY_Y = 89,
	KEY_Z = 90,
	KEY_LEFT_BRACKET = 91,
	KEY_BACKSLASH = 92,
	KEY_RIGHT_BRACKET = 93,
	KEY_GRAVE_ACCENT = 96,
	KEY_WORLD_1 = 161,
	KEY_WORLD_2 = 162,
	KEY_ESCAPE = 256,
	KEY_ENTER = 257,
	KEY_TAB = 258,
	KEY_BACKSPACE = 259,
	KEY_INSERT = 260,
	KEY_DELETE = 261,
	KEY_RIGHT = 262,
	KEY_LEFT = 263,
	KEY_DOWN = 264,
	KEY_UP = 265,
	KEY_PAGE_UP = 266,
	KEY_PAGE_DOWN = 267,
	KEY_HOME = 268,
	KEY_END = 269,
	KEY_CAPS_LOCK = 280,
	KEY_SCROLL_LOCK = 281,
	KEY_NUM_LOCK = 282,
	KEY_PRINT_SCREEN = 283,
	KEY_PAUSE = 284,
	KEY_F1 = 290,
	KEY_F2 = 291,
	KEY_F3 = 292,
	KEY_F4 = 293,
	KEY_F5 = 294,
	KEY_F6 = 295,
	KEY_F7 = 296,
	KEY_F8 = 297,
	KEY_F9 = 298,
	KEY_F10 = 299,
	KEY_F11 = 300,
	KEY_F12 = 301,
	KEY_F13 = 302,
	KEY_F14 = 303,
	KEY_F15 = 304,
	KEY_F16 = 305,
	KEY_F17 = 306,
	KEY_F18 = 307,
	KEY_F19 = 308,
	KEY_F20 = 309,
	KEY_F21 = 310,
	KEY_F22 = 311,
	KEY_F23 = 312,
	KEY_F24 = 313,
	KEY_F25 = 314,
	KEY_KP_0 = 320,
	KEY_KP_1 = 321,
	KEY_KP_2 = 322,
	KEY_KP_3 = 323,
	KEY_KP_4 = 324,
	KEY_KP_5 = 325,
	KEY_KP_6 = 326,
	KEY_KP_7 = 327,
	KEY_KP_8 = 328,
	KEY_KP_9 = 329,
	KEY_KP_DECIMAL = 330,
	KEY_KP_DIVIDE = 331,
	KEY_KP_MULTIPLY = 332,
	KEY_KP_SUBTRACT = 333,
	KEY_KP_ADD = 334,
	KEY_KP_ENTER = 335,
	KEY_KP_EQUAL = 336,
	KEY_LEFT_SHIFT = 340,
	KEY_LEFT_CONTROL = 341,
	KEY_LEFT_ALT = 342,
	KEY_LEFT_SUPER = 343,
	KEY_RIGHT_SHIFT = 344,
	KEY_RIGHT_CONTROL = 345,
	KEY_RIGHT_ALT = 346,
	KEY_RIGHT_SUPER = 347,
	KEY_MENU = 348,
	KEY_LAST = 348,
	MOD_SHIFT = 1,
	MOD_CONTROL = 2,
	MOD_ALT = 4,
	MOD_SUPER = 8,
	MOUSE_BUTTON_1 = 0,
	MOUSE_BUTTON_2 = 1,
	MOUSE_BUTTON_3 = 2,
	MOUSE_BUTTON_4 = 3,
	MOUSE_BUTTON_5 = 4,
	MOUSE_BUTTON_6 = 5,
	MOUSE_BUTTON_7 = 6,
	MOUSE_BUTTON_8 = 7,
	MOUSE_BUTTON_LAST = 7,
	MOUSE_BUTTON_LEFT = 0,
	MOUSE_BUTTON_RIGHT = 1,
	MOUSE_BUTTON_MIDDLE = 2,
	JOYSTICK_1 = 0,
	JOYSTICK_2 = 1,
	JOYSTICK_3 = 2,
	JOYSTICK_4 = 3,
	JOYSTICK_5 = 4,
	JOYSTICK_6 = 5,
	JOYSTICK_7 = 6,
	JOYSTICK_8 = 7,
	JOYSTICK_9 = 8,
	JOYSTICK_10 = 9,
	JOYSTICK_11 = 10,
	JOYSTICK_12 = 11,
	JOYSTICK_13 = 12,
	JOYSTICK_14 = 13,
	JOYSTICK_15 = 14,
	JOYSTICK_16 = 15,
	JOYSTICK_LAST = 15,
	NOT_INITIALIZED = 65537,
	NO_CURRENT_CONTEXT = 65538,
	INVALID_ENUM = 65539,
	INVALID_VALUE = 65540,
	OUT_OF_MEMORY = 65541,
	API_UNAVAILABLE = 65542,
	VERSION_UNAVAILABLE = 65543,
	PLATFORM_ERROR = 65544,
	FORMAT_UNAVAILABLE = 65545,
	NO_WINDOW_CONTEXT = 65546,
	FOCUSED = 131073,
	ICONIFIED = 131074,
	RESIZABLE = 131075,
	VISIBLE = 131076,
	DECORATED = 131077,
	AUTO_ICONIFY = 131078,
	FLOATING = 131079,
	MAXIMIZED = 131080,
	RED_BITS = 135169,
	GREEN_BITS = 135170,
	BLUE_BITS = 135171,
	ALPHA_BITS = 135172,
	DEPTH_BITS = 135173,
	STENCIL_BITS = 135174,
	ACCUM_RED_BITS = 135175,
	ACCUM_GREEN_BITS = 135176,
	ACCUM_BLUE_BITS = 135177,
	ACCUM_ALPHA_BITS = 135178,
	AUX_BUFFERS = 135179,
	STEREO = 135180,
	SAMPLES = 135181,
	SRGB_CAPABLE = 135182,
	REFRESH_RATE = 135183,
	DOUBLEBUFFER = 135184,
	CLIENT_API = 139265,
	CONTEXT_VERSION_MAJOR = 139266,
	CONTEXT_VERSION_MINOR = 139267,
	CONTEXT_REVISION = 139268,
	CONTEXT_ROBUSTNESS = 139269,
	OPENGL_FORWARD_COMPAT = 139270,
	OPENGL_DEBUG_CONTEXT = 139271,
	OPENGL_PROFILE = 139272,
	CONTEXT_RELEASE_BEHAVIOR = 139273,
	CONTEXT_NO_ERROR = 139274,
	CONTEXT_CREATION_API = 139275,
	NO_API = 0,
	OPENGL_API = 196609,
	OPENGL_ES_API = 196610,
	NO_ROBUSTNESS = 0,
	NO_RESET_NOTIFICATION = 200705,
	LOSE_CONTEXT_ON_RESET = 200706,
	OPENGL_ANY_PROFILE = 0,
	OPENGL_CORE_PROFILE = 204801,
	OPENGL_COMPAT_PROFILE = 204802,
	CURSOR = 208897,
	STICKY_KEYS = 208898,
	STICKY_MOUSE_BUTTONS = 208899,
	CURSOR_NORMAL = 212993,
	CURSOR_HIDDEN = 212994,
	CURSOR_DISABLED = 212995,
	ANY_RELEASE_BEHAVIOR = 0,
	RELEASE_BEHAVIOR_FLUSH = 217089,
	RELEASE_BEHAVIOR_NONE = 217090,
	NATIVE_CONTEXT_API = 221185,
	EGL_CONTEXT_API = 221186,
	ARROW_CURSOR = 221185,
	IBEAM_CURSOR = 221186,
	CROSSHAIR_CURSOR = 221187,
	HAND_CURSOR = 221188,
	HRESIZE_CURSOR = 221189,
	VRESIZE_CURSOR = 221190,
	CONNECTED = 262145,
	DISCONNECTED = 262146,
	DONT_CARE = -1,
}
function library.GetRequiredInstanceExtensions(extra)
	local count = ffi.new("uint32_t[1]")
	local array = CLIB.glfwGetRequiredInstanceExtensions(count)
	local out = {}
	for i = 0, count[0] - 1 do
		table.insert(out, ffi.string(array[i]))
	end
	if extra then
		for i,v in ipairs(extra) do
			table.insert(out, v)
		end
	end
	return out
end

function library.CreateWindowSurface(instance, window, huh)
	local box = ffi.new("struct VkSurfaceKHR_T * [1]")
	local status = CLIB.glfwCreateWindowSurface(instance, window, huh, ffi.cast("void **", box))
	if status == 0 then
		return box[0]
	end
	return nil, status
end
library.clib = CLIB
return library
