local header = [[
typedef void (*GLFWglproc)(void);
typedef struct GLFWmonitor GLFWmonitor;
typedef struct GLFWwindow GLFWwindow;
typedef void (* GLFWerrorfun)(int,const char*);
typedef void (* GLFWwindowposfun)(GLFWwindow*,int,int);
typedef void (* GLFWwindowsizefun)(GLFWwindow*,int,int);
typedef void (* GLFWwindowclosefun)(GLFWwindow*);
typedef void (* GLFWwindowrefreshfun)(GLFWwindow*);
typedef void (* GLFWwindowfocusfun)(GLFWwindow*,int);
typedef void (* GLFWwindowiconifyfun)(GLFWwindow*,int);
typedef void (* GLFWframebuffersizefun)(GLFWwindow*,int,int);
typedef void (* GLFWmousebuttonfun)(GLFWwindow*,int,int,int);
typedef void (* GLFWcursorposfun)(GLFWwindow*,double,double);
typedef void (* GLFWcursorenterfun)(GLFWwindow*,int);
typedef void (* GLFWscrollfun)(GLFWwindow*,double,double);
typedef void (* GLFWkeyfun)(GLFWwindow*,int,int,int,int);
typedef void (* GLFWcharfun)(GLFWwindow*,unsigned int);
typedef void (* GLFWdropfun)(GLFWwindow*,int,const char**);
typedef void (* GLFWmonitorfun)(GLFWmonitor*,int);
typedef struct GLFWcursor GLFWcursor;
typedef struct GLFWvidmode
{
    int width;
    int height;
    int redBits;
    int greenBits;
    int blueBits;
    int refreshRate;
} GLFWvidmode;
typedef struct GLFWgammaramp
{
    unsigned short* red;
    unsigned short* green;
    unsigned short* blue;
    unsigned int size;
} GLFWgammaramp;
typedef struct GLFWimage
{
    int width;
    int height;
    unsigned char* pixels;
} GLFWimage;
GLFWcursor* glfwCreateCursor(const GLFWimage* image, int xhot, int yhot);
void glfwDestroyCursor(GLFWcursor* cursor);
void glfwSetCursor(GLFWwindow* window, GLFWcursor* cursor);

int glfwInit(void);
void glfwTerminate(void);
void glfwGetVersion(int* major, int* minor, int* rev);
const char* glfwGetVersionString(void);
GLFWerrorfun glfwSetErrorCallback(GLFWerrorfun cbfun);
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
GLFWwindowposfun glfwSetWindowPosCallback(GLFWwindow* window, GLFWwindowposfun cbfun);
GLFWwindowsizefun glfwSetWindowSizeCallback(GLFWwindow* window, GLFWwindowsizefun cbfun);
GLFWwindowclosefun glfwSetWindowCloseCallback(GLFWwindow* window, GLFWwindowclosefun cbfun);
GLFWwindowrefreshfun glfwSetWindowRefreshCallback(GLFWwindow* window, GLFWwindowrefreshfun cbfun);
GLFWwindowfocusfun glfwSetWindowFocusCallback(GLFWwindow* window, GLFWwindowfocusfun cbfun);
GLFWwindowiconifyfun glfwSetWindowIconifyCallback(GLFWwindow* window, GLFWwindowiconifyfun cbfun);
GLFWframebuffersizefun glfwSetFramebufferSizeCallback(GLFWwindow* window, GLFWframebuffersizefun cbfun);
void glfwPollEvents(void);
void glfwWaitEvents(void);
void glfwPostEmptyEvent(void);
int glfwGetInputMode(GLFWwindow* window, int mode);
void glfwSetInputMode(GLFWwindow* window, int mode, int value);
int glfwGetKey(GLFWwindow* window, int key);
int glfwGetMouseButton(GLFWwindow* window, int button);
void glfwGetCursorPos(GLFWwindow* window, double* xpos, double* ypos);
void glfwSetCursorPos(GLFWwindow* window, double xpos, double ypos);
GLFWkeyfun glfwSetKeyCallback(GLFWwindow* window, GLFWkeyfun cbfun);
GLFWcharfun glfwSetCharCallback(GLFWwindow* window, GLFWcharfun cbfun);
GLFWmousebuttonfun glfwSetMouseButtonCallback(GLFWwindow* window, GLFWmousebuttonfun cbfun);
GLFWcursorposfun glfwSetCursorPosCallback(GLFWwindow* window, GLFWcursorposfun cbfun);
GLFWcursorenterfun glfwSetCursorEnterCallback(GLFWwindow* window, GLFWcursorenterfun cbfun);
GLFWscrollfun glfwSetScrollCallback(GLFWwindow* window, GLFWscrollfun cbfun);
GLFWdropfun glfwSetDropCallback(GLFWwindow* window, GLFWdropfun cbfun);
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
void *glfwGetWin32Window(GLFWwindow *window);
]]
local enums = {
	GLFW_VERSION_MAJOR = 3,
	GLFW_VERSION_MINOR = 0,
	GLFW_VERSION_REVISION = 0,
	GLFW_RELEASE = 0,
	GLFW_PRESS = 1,
	GLFW_REPEAT = 2,
	GLFW_KEY_UNKNOWN = -1,
	GLFW_KEY_SPACE = 32,
	GLFW_KEY_APOSTROPHE = 39,
	GLFW_KEY_COMMA = 44,
	GLFW_KEY_MINUS = 45,
	GLFW_KEY_PERIOD = 46,
	GLFW_KEY_SLASH = 47,
	GLFW_KEY_0 = 48,
	GLFW_KEY_1 = 49,
	GLFW_KEY_2 = 50,
	GLFW_KEY_3 = 51,
	GLFW_KEY_4 = 52,
	GLFW_KEY_5 = 53,
	GLFW_KEY_6 = 54,
	GLFW_KEY_7 = 55,
	GLFW_KEY_8 = 56,
	GLFW_KEY_9 = 57,
	GLFW_KEY_SEMICOLON = 59,
	GLFW_KEY_EQUAL = 61,
	GLFW_KEY_A = 65,
	GLFW_KEY_B = 66,
	GLFW_KEY_C = 67,
	GLFW_KEY_D = 68,
	GLFW_KEY_E = 69,
	GLFW_KEY_F = 70,
	GLFW_KEY_G = 71,
	GLFW_KEY_H = 72,
	GLFW_KEY_I = 73,
	GLFW_KEY_J = 74,
	GLFW_KEY_K = 75,
	GLFW_KEY_L = 76,
	GLFW_KEY_M = 77,
	GLFW_KEY_N = 78,
	GLFW_KEY_O = 79,
	GLFW_KEY_P = 80,
	GLFW_KEY_Q = 81,
	GLFW_KEY_R = 82,
	GLFW_KEY_S = 83,
	GLFW_KEY_T = 84,
	GLFW_KEY_U = 85,
	GLFW_KEY_V = 86,
	GLFW_KEY_W = 87,
	GLFW_KEY_X = 88,
	GLFW_KEY_Y = 89,
	GLFW_KEY_Z = 90,
	GLFW_KEY_LEFT_BRACKET = 91,
	GLFW_KEY_BACKSLASH = 92,
	GLFW_KEY_RIGHT_BRACKET = 93,
	GLFW_KEY_GRAVE_ACCENT = 96,
	GLFW_KEY_WORLD_1 = 161,
	GLFW_KEY_WORLD_2 = 162,
	GLFW_KEY_ESCAPE = 256,
	GLFW_KEY_ENTER = 257,
	GLFW_KEY_TAB = 258,
	GLFW_KEY_BACKSPACE = 259,
	GLFW_KEY_INSERT = 260,
	GLFW_KEY_DELETE = 261,
	GLFW_KEY_RIGHT = 262,
	GLFW_KEY_LEFT = 263,
	GLFW_KEY_DOWN = 264,
	GLFW_KEY_UP = 265,
	GLFW_KEY_PAGE_UP = 266,
	GLFW_KEY_PAGE_DOWN = 267,
	GLFW_KEY_HOME = 268,
	GLFW_KEY_END = 269,
	GLFW_KEY_CAPS_LOCK = 280,
	GLFW_KEY_SCROLL_LOCK = 281,
	GLFW_KEY_NUM_LOCK = 282,
	GLFW_KEY_PRINT_SCREEN = 283,
	GLFW_KEY_PAUSE = 284,
	GLFW_KEY_F1 = 290,
	GLFW_KEY_F2 = 291,
	GLFW_KEY_F3 = 292,
	GLFW_KEY_F4 = 293,
	GLFW_KEY_F5 = 294,
	GLFW_KEY_F6 = 295,
	GLFW_KEY_F7 = 296,
	GLFW_KEY_F8 = 297,
	GLFW_KEY_F9 = 298,
	GLFW_KEY_F10 = 299,
	GLFW_KEY_F11 = 300,
	GLFW_KEY_F12 = 301,
	GLFW_KEY_F13 = 302,
	GLFW_KEY_F14 = 303,
	GLFW_KEY_F15 = 304,
	GLFW_KEY_F16 = 305,
	GLFW_KEY_F17 = 306,
	GLFW_KEY_F18 = 307,
	GLFW_KEY_F19 = 308,
	GLFW_KEY_F20 = 309,
	GLFW_KEY_F21 = 310,
	GLFW_KEY_F22 = 311,
	GLFW_KEY_F23 = 312,
	GLFW_KEY_F24 = 313,
	GLFW_KEY_F25 = 314,
	GLFW_KEY_KP_0 = 320,
	GLFW_KEY_KP_1 = 321,
	GLFW_KEY_KP_2 = 322,
	GLFW_KEY_KP_3 = 323,
	GLFW_KEY_KP_4 = 324,
	GLFW_KEY_KP_5 = 325,
	GLFW_KEY_KP_6 = 326,
	GLFW_KEY_KP_7 = 327,
	GLFW_KEY_KP_8 = 328,
	GLFW_KEY_KP_9 = 329,
	GLFW_KEY_KP_DECIMAL = 330,
	GLFW_KEY_KP_DIVIDE = 331,
	GLFW_KEY_KP_MULTIPLY = 332,
	GLFW_KEY_KP_SUBTRACT = 333,
	GLFW_KEY_KP_ADD = 334,
	GLFW_KEY_KP_ENTER = 335,
	GLFW_KEY_KP_EQUAL = 336,
	GLFW_KEY_LEFT_SHIFT = 340,
	GLFW_KEY_LEFT_CONTROL = 341,
	GLFW_KEY_LEFT_ALT = 342,
	GLFW_KEY_LEFT_SUPER = 343,
	GLFW_KEY_RIGHT_SHIFT = 344,
	GLFW_KEY_RIGHT_CONTROL = 345,
	GLFW_KEY_RIGHT_ALT = 346,
	GLFW_KEY_RIGHT_SUPER = 347,
	GLFW_KEY_MENU = 348,
	GLFW_MOD_SHIFT = 1,
	GLFW_MOD_CONTROL = 2,
	GLFW_MOD_ALT = 4,
	GLFW_MOD_SUPER = 8,
	GLFW_MOUSE_BUTTON_1 = 0,
	GLFW_MOUSE_BUTTON_2 = 1,
	GLFW_MOUSE_BUTTON_3 = 2,
	GLFW_MOUSE_BUTTON_4 = 3,
	GLFW_MOUSE_BUTTON_5 = 4,
	GLFW_MOUSE_BUTTON_6 = 5,
	GLFW_MOUSE_BUTTON_7 = 6,
	GLFW_MOUSE_BUTTON_8 = 7,
	GLFW_JOYSTICK_1 = 0,
	GLFW_JOYSTICK_2 = 1,
	GLFW_JOYSTICK_3 = 2,
	GLFW_JOYSTICK_4 = 3,
	GLFW_JOYSTICK_5 = 4,
	GLFW_JOYSTICK_6 = 5,
	GLFW_JOYSTICK_7 = 6,
	GLFW_JOYSTICK_8 = 7,
	GLFW_JOYSTICK_9 = 8,
	GLFW_JOYSTICK_10 = 9,
	GLFW_JOYSTICK_11 = 10,
	GLFW_JOYSTICK_12 = 11,
	GLFW_JOYSTICK_13 = 12,
	GLFW_JOYSTICK_14 = 13,
	GLFW_JOYSTICK_15 = 14,
	GLFW_JOYSTICK_16 = 15,
	GLFW_NOT_INITIALIZED = 65537,
	GLFW_NO_CURRENT_CONTEXT = 65538,
	GLFW_INVALID_ENUM = 65539,
	GLFW_INVALID_VALUE = 65540,
	GLFW_OUT_OF_MEMORY = 65541,
	GLFW_API_UNAVAILABLE = 65542,
	GLFW_VERSION_UNAVAILABLE = 65543,
	GLFW_PLATFORM_ERROR = 65544,
	GLFW_FORMAT_UNAVAILABLE = 65545,
	GLFW_FOCUSED = 131073,
	GLFW_ICONIFIED = 131074,
	GLFW_RESIZABLE = 131075,
	GLFW_VISIBLE = 131076,
	GLFW_DECORATED = 131077,
	GLFW_RED_BITS = 135169,
	GLFW_GREEN_BITS = 135170,
	GLFW_BLUE_BITS = 135171,
	GLFW_ALPHA_BITS = 135172,
	GLFW_DEPTH_BITS = 135173,
	GLFW_STENCIL_BITS = 135174,
	GLFW_ACCUM_RED_BITS = 135175,
	GLFW_ACCUM_GREEN_BITS = 135176,
	GLFW_ACCUM_BLUE_BITS = 135177,
	GLFW_ACCUM_ALPHA_BITS = 135178,
	GLFW_AUX_BUFFERS = 135179,
	GLFW_STEREO = 135180,
	GLFW_SAMPLES = 135181,
	GLFW_SRGB_CAPABLE = 135182,
	GLFW_REFRESH_RATE = 135183,
	GLFW_CLIENT_API = 139265,
	GLFW_CONTEXT_VERSION_MAJOR = 139266,
	GLFW_CONTEXT_VERSION_MINOR = 139267,
	GLFW_CONTEXT_REVISION = 139268,
	GLFW_CONTEXT_ROBUSTNESS = 139269,
	GLFW_OPENGL_FORWARD_COMPAT = 139270,
	GLFW_OPENGL_DEBUG_CONTEXT = 139271,
	GLFW_OPENGL_PROFILE = 139272,
	GLFW_OPENGL_API = 196609,
	GLFW_OPENGL_ES_API = 196610,
	GLFW_NO_ROBUSTNESS = 0,
	GLFW_NO_RESET_NOTIFICATION = 200705,
	GLFW_LOSE_CONTEXT_ON_RESET = 200706,
	GLFW_OPENGL_ANY_PROFILE = 0,
	GLFW_OPENGL_CORE_PROFILE = 204801,
	GLFW_OPENGL_COMPAT_PROFILE = 204802,
	GLFW_CURSOR = 208897,
	GLFW_STICKY_KEYS = 208898,
	GLFW_STICKY_MOUSE_BUTTONS = 208899,
	GLFW_CURSOR_NORMAL = 212993,
	GLFW_CURSOR_HIDDEN = 212994,
	GLFW_CURSOR_DISABLED = 212995,
	GLFW_CONNECTED = 262145,
	GLFW_DISCONNECTED = 262146,
}

ffi.cdef(header)

local lib = assert(ffi.load(jit.os == "Linux" and "glfw" or "glfw3"))

local glfw = {
	e = enums,
	header = header,
	lib = lib,
}

-- put all the functions in the glfw table
for line in header:gmatch("(.-)\n") do
	local name = line:match("glfw(.-)%(")

	if name then
		pcall(function()
			glfw[name] = lib["glfw" .. name]
		end)
	end
end

do
	local reverse_enums = {}

	for k,v in pairs(enums) do
		local nice = k:lower():sub(6)
		reverse_enums[v] = nice
	end

	function glfw.EnumToString(num)
		return reverse_enums[num]
	end
end

do
	local keys = {}

	for k,v in pairs(enums) do
		if k:sub(0, 8) == "GLFW_KEY" then
			keys[v] = k:lower():sub(10)
		end
	end

	function glfw.KeyToString(num)
		return keys[num]
	end
end

do
	local mousebuttons = {}

	for k,v in pairs(enums) do
		if k:sub(0, 10) == "GLFW_MOUSE" then
			mousebuttons[v] = k:lower():sub(12)
		end
	end

	function glfw.MouseToString(num)
		return mousebuttons[num]
	end
end

function glfw.GetVersion()
	local major = ffi.new("int[1]")
	local minor = ffi.new("int[1]")
	local rev = ffi.new("int[1]")

	lib.glfwGetVersion(major, minor, rev)

	return major[0] + (minor[0] / 100), rev[0]
end

glfw.SetErrorCallback(function(code, msg) logf("[glfw error] %s\n", ffi.string(msg)) end)

glfw.Init()

return glfw
