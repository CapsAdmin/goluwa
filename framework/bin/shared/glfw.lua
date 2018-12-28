local ffi = require("ffi")
ffi.cdef([[struct GLFWmonitor {};
struct GLFWwindow {};
struct GLFWcursor {};
struct GLFWvidmode {int width;int height;int redBits;int greenBits;int blueBits;int refreshRate;};
struct GLFWgammaramp {unsigned short*red;unsigned short*green;unsigned short*blue;unsigned int size;};
struct GLFWimage {int width;int height;unsigned char*pixels;};
struct GLFWgamepadstate {unsigned char buttons[15];float axes[6];};
void(glfwMaximizeWindow)(struct GLFWwindow*);
void(glfwRestoreWindow)(struct GLFWwindow*);
unsigned long(glfwGetTimerValue)();
void(glfwDestroyCursor)(struct GLFWcursor*);
const char*(glfwGetVersionString)();
void(glfwGetWindowPos)(struct GLFWwindow*,int*,int*);
void(*glfwSetWindowMaximizeCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,int)))(struct GLFWwindow*,int);
void(*glfwSetWindowRefreshCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*)))(struct GLFWwindow*);
void(glfwSetWindowShouldClose)(struct GLFWwindow*,int);
const unsigned char*(glfwGetJoystickHats)(int,int*);
void(glfwDestroyWindow)(struct GLFWwindow*);
void(glfwSetCursorPos)(struct GLFWwindow*,double,double);
void(*glfwSetCharCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,unsigned int)))(struct GLFWwindow*,unsigned int);
int(glfwGetPhysicalDevicePresentationSupport)(void*,void*,unsigned int);
void(*glfwSetErrorCallback(void(*cbfun)(int,const char*)))(int,const char*);
int(glfwWindowShouldClose)(struct GLFWwindow*);
void(glfwInitHint)(int,int);
int(glfwCreateWindowSurface)(void*,struct GLFWwindow*,void*,void**);
void(*glfwGetInstanceProcAddress(void*,const char*))();
const char**(glfwGetRequiredInstanceExtensions)(unsigned int*);
int(glfwVulkanSupported)();
void(glfwSwapInterval)(int);
void(glfwSwapBuffers)(struct GLFWwindow*);
struct GLFWwindow*(glfwGetCurrentContext)();
void(glfwMakeContextCurrent)(struct GLFWwindow*);
void(*glfwSetWindowIconifyCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,int)))(struct GLFWwindow*,int);
double(glfwGetTime)();
const char*(glfwGetClipboardString)(struct GLFWwindow*);
void(glfwGetVersion)(int*,int*,int*);
int(glfwGetGamepadState)(int,struct GLFWgamepadstate*);
const struct GLFWvidmode*(glfwGetVideoModes)(struct GLFWmonitor*,int*);
int(glfwUpdateGamepadMappings)(const char*);
void(*glfwSetJoystickCallback(void(*cbfun)(int,int)))(int,int);
void*(glfwGetJoystickUserPointer)(int);
void(glfwSetJoystickUserPointer)(int,void*);
const char*(glfwGetJoystickGUID)(int);
const unsigned char*(glfwGetJoystickButtons)(int,int*);
int(glfwJoystickPresent)(int);
int(glfwGetWindowAttrib)(struct GLFWwindow*,int);
void(*glfwSetMouseButtonCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,int,int,int)))(struct GLFWwindow*,int,int,int);
void(*glfwSetCharModsCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,unsigned int,int)))(struct GLFWwindow*,unsigned int,int);
void(*glfwSetKeyCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,int,int,int,int)))(struct GLFWwindow*,int,int,int,int);
void(glfwSetCursor)(struct GLFWwindow*,struct GLFWcursor*);
struct GLFWcursor*(glfwCreateStandardCursor)(int);
struct GLFWcursor*(glfwCreateCursor)(const struct GLFWimage*,int,int);
void(glfwGetCursorPos)(struct GLFWwindow*,double*,double*);
int(glfwGetMouseButton)(struct GLFWwindow*,int);
int(glfwGetKey)(struct GLFWwindow*,int);
const char*(glfwGetKeyName)(int,int);
void(glfwSetInputMode)(struct GLFWwindow*,int,int);
int(glfwGetInputMode)(struct GLFWwindow*,int);
void(glfwPostEmptyEvent)();
const float*(glfwGetJoystickAxes)(int,int*);
void(glfwPollEvents)();
void(*glfwSetWindowContentScaleCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,float,float)))(struct GLFWwindow*,float,float);
void(*glfwSetWindowFocusCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,int)))(struct GLFWwindow*,int);
void(*glfwSetWindowCloseCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*)))(struct GLFWwindow*);
void(*glfwSetWindowPosCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,int,int)))(struct GLFWwindow*,int,int);
void*(glfwGetWindowUserPointer)(struct GLFWwindow*);
void(glfwSetWindowUserPointer)(struct GLFWwindow*,void*);
void(glfwSetWindowAttrib)(struct GLFWwindow*,int,int);
struct GLFWwindow*(glfwCreateWindow)(int,int,const char*,struct GLFWmonitor*,struct GLFWwindow*);
void(*glfwSetCursorEnterCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,int)))(struct GLFWwindow*,int);
void(glfwFocusWindow)(struct GLFWwindow*);
void(glfwHideWindow)(struct GLFWwindow*);
void(glfwSetWindowIcon)(struct GLFWwindow*,int,const struct GLFWimage*);
void(glfwShowWindow)(struct GLFWwindow*);
void(glfwIconifyWindow)(struct GLFWwindow*);
void(glfwSetWindowOpacity)(struct GLFWwindow*,float);
float(glfwGetWindowOpacity)(struct GLFWwindow*);
void(glfwGetWindowContentScale)(struct GLFWwindow*,float*,float*);
void(glfwGetFramebufferSize)(struct GLFWwindow*,int*,int*);
void(glfwSetWindowSize)(struct GLFWwindow*,int,int);
void(glfwSetWindowAspectRatio)(struct GLFWwindow*,int,int);
void(glfwSetWindowSizeLimits)(struct GLFWwindow*,int,int,int,int);
void(glfwGetWindowSize)(struct GLFWwindow*,int*,int*);
void(glfwSetWindowPos)(struct GLFWwindow*,int,int);
void(glfwWindowHint)(int,int);
void(glfwDefaultWindowHints)();
void(glfwSetGammaRamp)(struct GLFWmonitor*,const struct GLFWgammaramp*);
const struct GLFWgammaramp*(glfwGetGammaRamp)(struct GLFWmonitor*);
void(glfwSetGamma)(struct GLFWmonitor*,float);
const struct GLFWvidmode*(glfwGetVideoMode)(struct GLFWmonitor*);
const char*(glfwGetGamepadName)(int);
void(*glfwSetMonitorCallback(void(*cbfun)(struct GLFWmonitor*,int)))(struct GLFWmonitor*,int);
void*(glfwGetMonitorUserPointer)(struct GLFWmonitor*);
void(*glfwSetFramebufferSizeCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,int,int)))(struct GLFWwindow*,int,int);
const char*(glfwGetMonitorName)(struct GLFWmonitor*);
void(glfwGetMonitorContentScale)(struct GLFWmonitor*,float*,float*);
struct GLFWmonitor**(glfwGetMonitors)(int*);
int(glfwGetError)(const char**);
void(glfwTerminate)();
int(glfwInit)();
void(glfwSetWindowTitle)(struct GLFWwindow*,const char*);
void(glfwGetMonitorPos)(struct GLFWmonitor*,int*,int*);
struct GLFWmonitor*(glfwGetPrimaryMonitor)();
unsigned long(glfwGetTimerFrequency)();
void(glfwRequestWindowAttention)(struct GLFWwindow*);
void(*glfwGetProcAddress(const char*))();
void(glfwSetWindowMonitor)(struct GLFWwindow*,struct GLFWmonitor*,int,int,int,int,int);
void(*glfwSetDropCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,int,const char**)))(struct GLFWwindow*,int,const char**);
struct GLFWmonitor*(glfwGetWindowMonitor)(struct GLFWwindow*);
int(glfwJoystickIsGamepad)(int);
void(glfwGetWindowFrameSize)(struct GLFWwindow*,int*,int*,int*,int*);
const char*(glfwGetJoystickName)(int);
void(glfwSetMonitorUserPointer)(struct GLFWmonitor*,void*);
void(*glfwSetWindowSizeCallback(struct GLFWwindow*,void(*cbfun)(struct GLFWwindow*,int,int)))(struct GLFWwindow*,int,int);
void(glfwSetTime)(double);
void(glfwWaitEvents)();
int(glfwExtensionSupported)(const char*);
int(glfwGetKeyScancode)(int);
void(glfwGetMonitorPhysicalSize)(struct GLFWmonitor*,int*,int*);
void(glfwWindowHintString)(int,const char*);
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
	SetWindowMaximizeCallback = CLIB.glfwSetWindowMaximizeCallback,
	SetWindowRefreshCallback = CLIB.glfwSetWindowRefreshCallback,
	SetWindowShouldClose = CLIB.glfwSetWindowShouldClose,
	GetJoystickHats = CLIB.glfwGetJoystickHats,
	DestroyWindow = CLIB.glfwDestroyWindow,
	SetCursorPos = CLIB.glfwSetCursorPos,
	SetCharCallback = CLIB.glfwSetCharCallback,
	GetPhysicalDevicePresentationSupport = CLIB.glfwGetPhysicalDevicePresentationSupport,
	SetErrorCallback = CLIB.glfwSetErrorCallback,
	WindowShouldClose = CLIB.glfwWindowShouldClose,
	InitHint = CLIB.glfwInitHint,
	CreateWindowSurface = CLIB.glfwCreateWindowSurface,
	GetInstanceProcAddress = CLIB.glfwGetInstanceProcAddress,
	GetRequiredInstanceExtensions = CLIB.glfwGetRequiredInstanceExtensions,
	VulkanSupported = CLIB.glfwVulkanSupported,
	SwapInterval = CLIB.glfwSwapInterval,
	SwapBuffers = CLIB.glfwSwapBuffers,
	GetCurrentContext = CLIB.glfwGetCurrentContext,
	MakeContextCurrent = CLIB.glfwMakeContextCurrent,
	SetWindowIconifyCallback = CLIB.glfwSetWindowIconifyCallback,
	GetTime = CLIB.glfwGetTime,
	GetClipboardString = CLIB.glfwGetClipboardString,
	GetVersion = CLIB.glfwGetVersion,
	GetGamepadState = CLIB.glfwGetGamepadState,
	GetVideoModes = CLIB.glfwGetVideoModes,
	UpdateGamepadMappings = CLIB.glfwUpdateGamepadMappings,
	SetJoystickCallback = CLIB.glfwSetJoystickCallback,
	GetJoystickUserPointer = CLIB.glfwGetJoystickUserPointer,
	SetJoystickUserPointer = CLIB.glfwSetJoystickUserPointer,
	GetJoystickGUID = CLIB.glfwGetJoystickGUID,
	GetJoystickButtons = CLIB.glfwGetJoystickButtons,
	JoystickPresent = CLIB.glfwJoystickPresent,
	GetWindowAttrib = CLIB.glfwGetWindowAttrib,
	SetMouseButtonCallback = CLIB.glfwSetMouseButtonCallback,
	SetCharModsCallback = CLIB.glfwSetCharModsCallback,
	SetKeyCallback = CLIB.glfwSetKeyCallback,
	SetCursor = CLIB.glfwSetCursor,
	CreateStandardCursor = CLIB.glfwCreateStandardCursor,
	CreateCursor = CLIB.glfwCreateCursor,
	GetCursorPos = CLIB.glfwGetCursorPos,
	GetMouseButton = CLIB.glfwGetMouseButton,
	GetKey = CLIB.glfwGetKey,
	GetKeyName = CLIB.glfwGetKeyName,
	SetInputMode = CLIB.glfwSetInputMode,
	GetInputMode = CLIB.glfwGetInputMode,
	PostEmptyEvent = CLIB.glfwPostEmptyEvent,
	GetJoystickAxes = CLIB.glfwGetJoystickAxes,
	PollEvents = CLIB.glfwPollEvents,
	SetWindowContentScaleCallback = CLIB.glfwSetWindowContentScaleCallback,
	SetWindowFocusCallback = CLIB.glfwSetWindowFocusCallback,
	SetWindowCloseCallback = CLIB.glfwSetWindowCloseCallback,
	SetWindowPosCallback = CLIB.glfwSetWindowPosCallback,
	GetWindowUserPointer = CLIB.glfwGetWindowUserPointer,
	SetWindowUserPointer = CLIB.glfwSetWindowUserPointer,
	SetWindowAttrib = CLIB.glfwSetWindowAttrib,
	CreateWindow = CLIB.glfwCreateWindow,
	SetCursorEnterCallback = CLIB.glfwSetCursorEnterCallback,
	FocusWindow = CLIB.glfwFocusWindow,
	HideWindow = CLIB.glfwHideWindow,
	SetWindowIcon = CLIB.glfwSetWindowIcon,
	ShowWindow = CLIB.glfwShowWindow,
	IconifyWindow = CLIB.glfwIconifyWindow,
	SetWindowOpacity = CLIB.glfwSetWindowOpacity,
	GetWindowOpacity = CLIB.glfwGetWindowOpacity,
	GetWindowContentScale = CLIB.glfwGetWindowContentScale,
	GetFramebufferSize = CLIB.glfwGetFramebufferSize,
	SetWindowSize = CLIB.glfwSetWindowSize,
	SetWindowAspectRatio = CLIB.glfwSetWindowAspectRatio,
	SetWindowSizeLimits = CLIB.glfwSetWindowSizeLimits,
	GetWindowSize = CLIB.glfwGetWindowSize,
	SetWindowPos = CLIB.glfwSetWindowPos,
	WindowHint = CLIB.glfwWindowHint,
	DefaultWindowHints = CLIB.glfwDefaultWindowHints,
	SetGammaRamp = CLIB.glfwSetGammaRamp,
	GetGammaRamp = CLIB.glfwGetGammaRamp,
	SetGamma = CLIB.glfwSetGamma,
	GetVideoMode = CLIB.glfwGetVideoMode,
	GetGamepadName = CLIB.glfwGetGamepadName,
	SetMonitorCallback = CLIB.glfwSetMonitorCallback,
	GetMonitorUserPointer = CLIB.glfwGetMonitorUserPointer,
	SetFramebufferSizeCallback = CLIB.glfwSetFramebufferSizeCallback,
	GetMonitorName = CLIB.glfwGetMonitorName,
	GetMonitorContentScale = CLIB.glfwGetMonitorContentScale,
	GetMonitors = CLIB.glfwGetMonitors,
	GetError = CLIB.glfwGetError,
	Terminate = CLIB.glfwTerminate,
	Init = CLIB.glfwInit,
	SetWindowTitle = CLIB.glfwSetWindowTitle,
	GetMonitorPos = CLIB.glfwGetMonitorPos,
	GetPrimaryMonitor = CLIB.glfwGetPrimaryMonitor,
	GetTimerFrequency = CLIB.glfwGetTimerFrequency,
	RequestWindowAttention = CLIB.glfwRequestWindowAttention,
	GetProcAddress = CLIB.glfwGetProcAddress,
	SetWindowMonitor = CLIB.glfwSetWindowMonitor,
	SetDropCallback = CLIB.glfwSetDropCallback,
	GetWindowMonitor = CLIB.glfwGetWindowMonitor,
	JoystickIsGamepad = CLIB.glfwJoystickIsGamepad,
	GetWindowFrameSize = CLIB.glfwGetWindowFrameSize,
	GetJoystickName = CLIB.glfwGetJoystickName,
	SetMonitorUserPointer = CLIB.glfwSetMonitorUserPointer,
	SetWindowSizeCallback = CLIB.glfwSetWindowSizeCallback,
	SetTime = CLIB.glfwSetTime,
	WaitEvents = CLIB.glfwWaitEvents,
	ExtensionSupported = CLIB.glfwExtensionSupported,
	GetKeyScancode = CLIB.glfwGetKeyScancode,
	GetMonitorPhysicalSize = CLIB.glfwGetMonitorPhysicalSize,
	WindowHintString = CLIB.glfwWindowHintString,
	SetClipboardString = CLIB.glfwSetClipboardString,
	SetCursorPosCallback = CLIB.glfwSetCursorPosCallback,
	SetScrollCallback = CLIB.glfwSetScrollCallback,
	WaitEventsTimeout = CLIB.glfwWaitEventsTimeout,
}
library.e = {
	APIENTRY_DEFINED = 1,
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
	HAT_CENTERED = 0,
	HAT_UP = 1,
	HAT_RIGHT = 2,
	HAT_DOWN = 4,
	HAT_LEFT = 8,
	HAT_RIGHT_UP = 3,
	HAT_RIGHT_DOWN = 6,
	HAT_LEFT_UP = 9,
	HAT_LEFT_DOWN = 12,
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
	MOD_CAPS_LOCK = 16,
	MOD_NUM_LOCK = 32,
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
	GAMEPAD_BUTTON_A = 0,
	GAMEPAD_BUTTON_B = 1,
	GAMEPAD_BUTTON_X = 2,
	GAMEPAD_BUTTON_Y = 3,
	GAMEPAD_BUTTON_LEFT_BUMPER = 4,
	GAMEPAD_BUTTON_RIGHT_BUMPER = 5,
	GAMEPAD_BUTTON_BACK = 6,
	GAMEPAD_BUTTON_START = 7,
	GAMEPAD_BUTTON_GUIDE = 8,
	GAMEPAD_BUTTON_LEFT_THUMB = 9,
	GAMEPAD_BUTTON_RIGHT_THUMB = 10,
	GAMEPAD_BUTTON_DPAD_UP = 11,
	GAMEPAD_BUTTON_DPAD_RIGHT = 12,
	GAMEPAD_BUTTON_DPAD_DOWN = 13,
	GAMEPAD_BUTTON_DPAD_LEFT = 14,
	GAMEPAD_BUTTON_LAST = 14,
	GAMEPAD_BUTTON_CROSS = 0,
	GAMEPAD_BUTTON_CIRCLE = 1,
	GAMEPAD_BUTTON_SQUARE = 2,
	GAMEPAD_BUTTON_TRIANGLE = 3,
	GAMEPAD_AXIS_LEFT_X = 0,
	GAMEPAD_AXIS_LEFT_Y = 1,
	GAMEPAD_AXIS_RIGHT_X = 2,
	GAMEPAD_AXIS_RIGHT_Y = 3,
	GAMEPAD_AXIS_LEFT_TRIGGER = 4,
	GAMEPAD_AXIS_RIGHT_TRIGGER = 5,
	GAMEPAD_AXIS_LAST = 5,
	NO_ERROR = 0,
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
	CENTER_CURSOR = 131081,
	TRANSPARENT_FRAMEBUFFER = 131082,
	HOVERED = 131083,
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
	COCOA_RETINA_FRAMEBUFFER = 143361,
	COCOA_FRAME_NAME = 143362,
	COCOA_GRAPHICS_SWITCHING = 143363,
	X11_CLASS_NAME = 147457,
	X11_INSTANCE_NAME = 147458,
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
	LOCK_KEY_MODS = 208900,
	CURSOR_NORMAL = 212993,
	CURSOR_HIDDEN = 212994,
	CURSOR_DISABLED = 212995,
	ANY_RELEASE_BEHAVIOR = 0,
	RELEASE_BEHAVIOR_FLUSH = 217089,
	RELEASE_BEHAVIOR_NONE = 217090,
	NATIVE_CONTEXT_API = 221185,
	EGL_CONTEXT_API = 221186,
	OSMESA_CONTEXT_API = 221187,
	ARROW_CURSOR = 221185,
	IBEAM_CURSOR = 221186,
	CROSSHAIR_CURSOR = 221187,
	HAND_CURSOR = 221188,
	HRESIZE_CURSOR = 221189,
	VRESIZE_CURSOR = 221190,
	CONNECTED = 262145,
	DISCONNECTED = 262146,
	JOYSTICK_HAT_BUTTONS = 327681,
	COCOA_CHDIR_RESOURCES = 331777,
	COCOA_MENUBAR = 331778,
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
