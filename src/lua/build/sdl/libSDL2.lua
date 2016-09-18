local ffi = require("ffi")
ffi.cdef([[enum{SDL_PIXELTYPE_UNKNOWN=0,SDL_PIXELTYPE_INDEX1=1,SDL_PIXELTYPE_INDEX4=2,SDL_PIXELTYPE_INDEX8=3,SDL_PIXELTYPE_PACKED8=4,SDL_PIXELTYPE_PACKED16=5,SDL_PIXELTYPE_PACKED32=6,SDL_PIXELTYPE_ARRAYU8=7,SDL_PIXELTYPE_ARRAYU16=8,SDL_PIXELTYPE_ARRAYU32=9,SDL_PIXELTYPE_ARRAYF16=10,SDL_PIXELTYPE_ARRAYF32=11,
SDL_BITMAPORDER_NONE=0,SDL_BITMAPORDER_4321=1,SDL_BITMAPORDER_1234=2,
SDL_PACKEDORDER_NONE=0,SDL_PACKEDORDER_XRGB=1,SDL_PACKEDORDER_RGBX=2,SDL_PACKEDORDER_ARGB=3,SDL_PACKEDORDER_RGBA=4,SDL_PACKEDORDER_XBGR=5,SDL_PACKEDORDER_BGRX=6,SDL_PACKEDORDER_ABGR=7,SDL_PACKEDORDER_BGRA=8,
SDL_ARRAYORDER_NONE=0,SDL_ARRAYORDER_RGB=1,SDL_ARRAYORDER_RGBA=2,SDL_ARRAYORDER_ARGB=3,SDL_ARRAYORDER_BGR=4,SDL_ARRAYORDER_BGRA=5,SDL_ARRAYORDER_ABGR=6,
SDL_PACKEDLAYOUT_NONE=0,SDL_PACKEDLAYOUT_332=1,SDL_PACKEDLAYOUT_4444=2,SDL_PACKEDLAYOUT_1555=3,SDL_PACKEDLAYOUT_5551=4,SDL_PACKEDLAYOUT_565=5,SDL_PACKEDLAYOUT_8888=6,SDL_PACKEDLAYOUT_2101010=7,SDL_PACKEDLAYOUT_1010102=8,
SDL_PIXELFORMAT_UNKNOWN=0,SDL_PIXELFORMAT_INDEX1LSB=286261504,SDL_PIXELFORMAT_INDEX1MSB=287310080,SDL_PIXELFORMAT_INDEX4LSB=303039488,SDL_PIXELFORMAT_INDEX4MSB=304088064,SDL_PIXELFORMAT_INDEX8=318769153,SDL_PIXELFORMAT_RGB332=336660481,SDL_PIXELFORMAT_RGB444=353504258,SDL_PIXELFORMAT_RGB555=353570562,SDL_PIXELFORMAT_BGR555=357764866,SDL_PIXELFORMAT_ARGB4444=355602434,SDL_PIXELFORMAT_RGBA4444=356651010,SDL_PIXELFORMAT_ABGR4444=359796738,SDL_PIXELFORMAT_BGRA4444=360845314,SDL_PIXELFORMAT_ARGB1555=355667970,SDL_PIXELFORMAT_RGBA5551=356782082,SDL_PIXELFORMAT_ABGR1555=359862274,SDL_PIXELFORMAT_BGRA5551=360976386,SDL_PIXELFORMAT_RGB565=353701890,SDL_PIXELFORMAT_BGR565=357896194,SDL_PIXELFORMAT_RGB24=386930691,SDL_PIXELFORMAT_BGR24=390076419,SDL_PIXELFORMAT_RGB888=370546692,SDL_PIXELFORMAT_RGBX8888=371595268,SDL_PIXELFORMAT_BGR888=374740996,SDL_PIXELFORMAT_BGRX8888=375789572,SDL_PIXELFORMAT_ARGB8888=372645892,SDL_PIXELFORMAT_RGBA8888=373694468,SDL_PIXELFORMAT_ABGR8888=376840196,SDL_PIXELFORMAT_BGRA8888=377888772,SDL_PIXELFORMAT_ARGB2101010=372711428,SDL_PIXELFORMAT_YV12=842094169,SDL_PIXELFORMAT_IYUV=1448433993,SDL_PIXELFORMAT_YUY2=844715353,SDL_PIXELFORMAT_UYVY=1498831189,SDL_PIXELFORMAT_YVYU=1431918169,SDL_PIXELFORMAT_NV12=842094158,SDL_PIXELFORMAT_NV21=825382478,
SDL_LOG_CATEGORY_APPLICATION=0,SDL_LOG_CATEGORY_ERROR=1,SDL_LOG_CATEGORY_ASSERT=2,SDL_LOG_CATEGORY_SYSTEM=3,SDL_LOG_CATEGORY_AUDIO=4,SDL_LOG_CATEGORY_VIDEO=5,SDL_LOG_CATEGORY_RENDER=6,SDL_LOG_CATEGORY_INPUT=7,SDL_LOG_CATEGORY_TEST=8,SDL_LOG_CATEGORY_RESERVED1=9,SDL_LOG_CATEGORY_RESERVED2=10,SDL_LOG_CATEGORY_RESERVED3=11,SDL_LOG_CATEGORY_RESERVED4=12,SDL_LOG_CATEGORY_RESERVED5=13,SDL_LOG_CATEGORY_RESERVED6=14,SDL_LOG_CATEGORY_RESERVED7=15,SDL_LOG_CATEGORY_RESERVED8=16,SDL_LOG_CATEGORY_RESERVED9=17,SDL_LOG_CATEGORY_RESERVED10=18,SDL_LOG_CATEGORY_CUSTOM=19,};typedef enum SDL_TextureAccess{SDL_TEXTUREACCESS_STATIC=0,SDL_TEXTUREACCESS_STREAMING=1,SDL_TEXTUREACCESS_TARGET=2};
typedef enum SDL_BlendMode{SDL_BLENDMODE_NONE=0,SDL_BLENDMODE_BLEND=1,SDL_BLENDMODE_ADD=2,SDL_BLENDMODE_MOD=4};
typedef enum SDL_WindowEventID{SDL_WINDOWEVENT_NONE=0,SDL_WINDOWEVENT_SHOWN=1,SDL_WINDOWEVENT_HIDDEN=2,SDL_WINDOWEVENT_EXPOSED=3,SDL_WINDOWEVENT_MOVED=4,SDL_WINDOWEVENT_RESIZED=5,SDL_WINDOWEVENT_SIZE_CHANGED=6,SDL_WINDOWEVENT_MINIMIZED=7,SDL_WINDOWEVENT_MAXIMIZED=8,SDL_WINDOWEVENT_RESTORED=9,SDL_WINDOWEVENT_ENTER=10,SDL_WINDOWEVENT_LEAVE=11,SDL_WINDOWEVENT_FOCUS_GAINED=12,SDL_WINDOWEVENT_FOCUS_LOST=13,SDL_WINDOWEVENT_CLOSE=14,SDL_WINDOWEVENT_TAKE_FOCUS=15,SDL_WINDOWEVENT_HIT_TEST=16};
typedef enum SDL_bool{SDL_FALSE=0,SDL_TRUE=1};
typedef enum SDL_PowerState{SDL_POWERSTATE_UNKNOWN=0,SDL_POWERSTATE_ON_BATTERY=1,SDL_POWERSTATE_NO_BATTERY=2,SDL_POWERSTATE_CHARGING=3,SDL_POWERSTATE_CHARGED=4};
typedef enum SDL_Keymod{KMOD_NONE=0,KMOD_LSHIFT=1,KMOD_RSHIFT=2,KMOD_LCTRL=64,KMOD_RCTRL=128,KMOD_LALT=256,KMOD_RALT=512,KMOD_LGUI=1024,KMOD_RGUI=2048,KMOD_NUM=4096,KMOD_CAPS=8192,KMOD_MODE=16384,KMOD_RESERVED=32768};
typedef enum SDL_eventaction{SDL_ADDEVENT=0,SDL_PEEKEVENT=1,SDL_GETEVENT=2};
typedef enum SDL_GLcontextReleaseFlag{SDL_GL_CONTEXT_RELEASE_BEHAVIOR_NONE=0,SDL_GL_CONTEXT_RELEASE_BEHAVIOR_FLUSH=1};
typedef enum SDL_GameControllerAxis{SDL_CONTROLLER_AXIS_INVALID=-1,SDL_CONTROLLER_AXIS_LEFTX=0,SDL_CONTROLLER_AXIS_LEFTY=1,SDL_CONTROLLER_AXIS_RIGHTX=2,SDL_CONTROLLER_AXIS_RIGHTY=3,SDL_CONTROLLER_AXIS_TRIGGERLEFT=4,SDL_CONTROLLER_AXIS_TRIGGERRIGHT=5,SDL_CONTROLLER_AXIS_MAX=6};
typedef enum SDL_LogPriority{SDL_LOG_PRIORITY_VERBOSE=1,SDL_LOG_PRIORITY_DEBUG=2,SDL_LOG_PRIORITY_INFO=3,SDL_LOG_PRIORITY_WARN=4,SDL_LOG_PRIORITY_ERROR=5,SDL_LOG_PRIORITY_CRITICAL=6,SDL_NUM_LOG_PRIORITIES=7};
typedef enum SDL_MouseWheelDirection{SDL_MOUSEWHEEL_NORMAL=0,SDL_MOUSEWHEEL_FLIPPED=1};
typedef enum SDL_GLprofile{SDL_GL_CONTEXT_PROFILE_CORE=1,SDL_GL_CONTEXT_PROFILE_COMPATIBILITY=2,SDL_GL_CONTEXT_PROFILE_ES=4};
typedef enum SDL_errorcode{SDL_ENOMEM=0,SDL_EFREAD=1,SDL_EFWRITE=2,SDL_EFSEEK=3,SDL_UNSUPPORTED=4,SDL_LASTERROR=5};
typedef enum SDL_MessageBoxButtonFlags{SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT=1,SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT=2};
typedef enum SDL_RendererFlip{SDL_FLIP_NONE=0,SDL_FLIP_HORIZONTAL=1,SDL_FLIP_VERTICAL=2};
typedef enum SDL_ThreadPriority{SDL_THREAD_PRIORITY_LOW=0,SDL_THREAD_PRIORITY_NORMAL=1,SDL_THREAD_PRIORITY_HIGH=2};
typedef enum SDL_grrrrrr{SDL_INIT_TIMER=1,SDL_INIT_AUDIO=16,SDL_INIT_VIDEO=32,SDL_INIT_JOYSTICK=512,SDL_INIT_HAPTIC=4096,SDL_INIT_GAMECONTROLLER=8192,SDL_INIT_EVENTS=16384,SDL_INIT_NOPARACHUTE=1048576,SDL_INIT_EVERYTHING=29233,SDL_WINDOWPOS_UNDEFINED_MASK=536805376,SDL_WINDOWPOS_UNDEFINED_DISPLAY=536805376,SDL_WINDOWPOS_UNDEFINED=536805376,SDL_WINDOWPOS_CENTERED_MASK=805240832,SDL_WINDOWPOS_CENTERED=805240832};
typedef enum SDL_HintPriority{SDL_HINT_DEFAULT=0,SDL_HINT_NORMAL=1,SDL_HINT_OVERRIDE=2};
typedef enum SDL_SYSWM_TYPE{SDL_SYSWM_UNKNOWN=0,SDL_SYSWM_WINDOWS=1,SDL_SYSWM_X11=2,SDL_SYSWM_DIRECTFB=3,SDL_SYSWM_COCOA=4,SDL_SYSWM_UIKIT=5,SDL_SYSWM_WAYLAND=6,SDL_SYSWM_MIR=7,SDL_SYSWM_WINRT=8,SDL_SYSWM_ANDROID=9,SDL_SYSWM_VIVANTE=10};
typedef enum SDL_TextureModulate{SDL_TEXTUREMODULATE_NONE=0,SDL_TEXTUREMODULATE_COLOR=1,SDL_TEXTUREMODULATE_ALPHA=2};
typedef enum SDL_RendererFlags{SDL_RENDERER_SOFTWARE=1,SDL_RENDERER_ACCELERATED=2,SDL_RENDERER_PRESENTVSYNC=4,SDL_RENDERER_TARGETTEXTURE=8};
typedef enum SDL_MessageBoxColorType{SDL_MESSAGEBOX_COLOR_BACKGROUND=0,SDL_MESSAGEBOX_COLOR_TEXT=1,SDL_MESSAGEBOX_COLOR_BUTTON_BORDER=2,SDL_MESSAGEBOX_COLOR_BUTTON_BACKGROUND=3,SDL_MESSAGEBOX_COLOR_BUTTON_SELECTED=4,SDL_MESSAGEBOX_COLOR_MAX=5};
typedef enum SDL_GLcontextFlag{SDL_GL_CONTEXT_DEBUG_FLAG=1,SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG=2,SDL_GL_CONTEXT_ROBUST_ACCESS_FLAG=4,SDL_GL_CONTEXT_RESET_ISOLATION_FLAG=8};
typedef enum SDL_Scancode{SDL_SCANCODE_UNKNOWN=0,SDL_SCANCODE_A=4,SDL_SCANCODE_B=5,SDL_SCANCODE_C=6,SDL_SCANCODE_D=7,SDL_SCANCODE_E=8,SDL_SCANCODE_F=9,SDL_SCANCODE_G=10,SDL_SCANCODE_H=11,SDL_SCANCODE_I=12,SDL_SCANCODE_J=13,SDL_SCANCODE_K=14,SDL_SCANCODE_L=15,SDL_SCANCODE_M=16,SDL_SCANCODE_N=17,SDL_SCANCODE_O=18,SDL_SCANCODE_P=19,SDL_SCANCODE_Q=20,SDL_SCANCODE_R=21,SDL_SCANCODE_S=22,SDL_SCANCODE_T=23,SDL_SCANCODE_U=24,SDL_SCANCODE_V=25,SDL_SCANCODE_W=26,SDL_SCANCODE_X=27,SDL_SCANCODE_Y=28,SDL_SCANCODE_Z=29,SDL_SCANCODE_1=30,SDL_SCANCODE_2=31,SDL_SCANCODE_3=32,SDL_SCANCODE_4=33,SDL_SCANCODE_5=34,SDL_SCANCODE_6=35,SDL_SCANCODE_7=36,SDL_SCANCODE_8=37,SDL_SCANCODE_9=38,SDL_SCANCODE_0=39,SDL_SCANCODE_RETURN=40,SDL_SCANCODE_ESCAPE=41,SDL_SCANCODE_BACKSPACE=42,SDL_SCANCODE_TAB=43,SDL_SCANCODE_SPACE=44,SDL_SCANCODE_MINUS=45,SDL_SCANCODE_EQUALS=46,SDL_SCANCODE_LEFTBRACKET=47,SDL_SCANCODE_RIGHTBRACKET=48,SDL_SCANCODE_BACKSLASH=49,SDL_SCANCODE_NONUSHASH=50,SDL_SCANCODE_SEMICOLON=51,SDL_SCANCODE_APOSTROPHE=52,SDL_SCANCODE_GRAVE=53,SDL_SCANCODE_COMMA=54,SDL_SCANCODE_PERIOD=55,SDL_SCANCODE_SLASH=56,SDL_SCANCODE_CAPSLOCK=57,SDL_SCANCODE_F1=58,SDL_SCANCODE_F2=59,SDL_SCANCODE_F3=60,SDL_SCANCODE_F4=61,SDL_SCANCODE_F5=62,SDL_SCANCODE_F6=63,SDL_SCANCODE_F7=64,SDL_SCANCODE_F8=65,SDL_SCANCODE_F9=66,SDL_SCANCODE_F10=67,SDL_SCANCODE_F11=68,SDL_SCANCODE_F12=69,SDL_SCANCODE_PRINTSCREEN=70,SDL_SCANCODE_SCROLLLOCK=71,SDL_SCANCODE_PAUSE=72,SDL_SCANCODE_INSERT=73,SDL_SCANCODE_HOME=74,SDL_SCANCODE_PAGEUP=75,SDL_SCANCODE_DELETE=76,SDL_SCANCODE_END=77,SDL_SCANCODE_PAGEDOWN=78,SDL_SCANCODE_RIGHT=79,SDL_SCANCODE_LEFT=80,SDL_SCANCODE_DOWN=81,SDL_SCANCODE_UP=82,SDL_SCANCODE_NUMLOCKCLEAR=83,SDL_SCANCODE_KP_DIVIDE=84,SDL_SCANCODE_KP_MULTIPLY=85,SDL_SCANCODE_KP_MINUS=86,SDL_SCANCODE_KP_PLUS=87,SDL_SCANCODE_KP_ENTER=88,SDL_SCANCODE_KP_1=89,SDL_SCANCODE_KP_2=90,SDL_SCANCODE_KP_3=91,SDL_SCANCODE_KP_4=92,SDL_SCANCODE_KP_5=93,SDL_SCANCODE_KP_6=94,SDL_SCANCODE_KP_7=95,SDL_SCANCODE_KP_8=96,SDL_SCANCODE_KP_9=97,SDL_SCANCODE_KP_0=98,SDL_SCANCODE_KP_PERIOD=99,SDL_SCANCODE_NONUSBACKSLASH=100,SDL_SCANCODE_APPLICATION=101,SDL_SCANCODE_POWER=102,SDL_SCANCODE_KP_EQUALS=103,SDL_SCANCODE_F13=104,SDL_SCANCODE_F14=105,SDL_SCANCODE_F15=106,SDL_SCANCODE_F16=107,SDL_SCANCODE_F17=108,SDL_SCANCODE_F18=109,SDL_SCANCODE_F19=110,SDL_SCANCODE_F20=111,SDL_SCANCODE_F21=112,SDL_SCANCODE_F22=113,SDL_SCANCODE_F23=114,SDL_SCANCODE_F24=115,SDL_SCANCODE_EXECUTE=116,SDL_SCANCODE_HELP=117,SDL_SCANCODE_MENU=118,SDL_SCANCODE_SELECT=119,SDL_SCANCODE_STOP=120,SDL_SCANCODE_AGAIN=121,SDL_SCANCODE_UNDO=122,SDL_SCANCODE_CUT=123,SDL_SCANCODE_COPY=124,SDL_SCANCODE_PASTE=125,SDL_SCANCODE_FIND=126,SDL_SCANCODE_MUTE=127,SDL_SCANCODE_VOLUMEUP=128,SDL_SCANCODE_VOLUMEDOWN=129,SDL_SCANCODE_KP_COMMA=133,SDL_SCANCODE_KP_EQUALSAS400=134,SDL_SCANCODE_INTERNATIONAL1=135,SDL_SCANCODE_INTERNATIONAL2=136,SDL_SCANCODE_INTERNATIONAL3=137,SDL_SCANCODE_INTERNATIONAL4=138,SDL_SCANCODE_INTERNATIONAL5=139,SDL_SCANCODE_INTERNATIONAL6=140,SDL_SCANCODE_INTERNATIONAL7=141,SDL_SCANCODE_INTERNATIONAL8=142,SDL_SCANCODE_INTERNATIONAL9=143,SDL_SCANCODE_LANG1=144,SDL_SCANCODE_LANG2=145,SDL_SCANCODE_LANG3=146,SDL_SCANCODE_LANG4=147,SDL_SCANCODE_LANG5=148,SDL_SCANCODE_LANG6=149,SDL_SCANCODE_LANG7=150,SDL_SCANCODE_LANG8=151,SDL_SCANCODE_LANG9=152,SDL_SCANCODE_ALTERASE=153,SDL_SCANCODE_SYSREQ=154,SDL_SCANCODE_CANCEL=155,SDL_SCANCODE_CLEAR=156,SDL_SCANCODE_PRIOR=157,SDL_SCANCODE_RETURN2=158,SDL_SCANCODE_SEPARATOR=159,SDL_SCANCODE_OUT=160,SDL_SCANCODE_OPER=161,SDL_SCANCODE_CLEARAGAIN=162,SDL_SCANCODE_CRSEL=163,SDL_SCANCODE_EXSEL=164,SDL_SCANCODE_KP_00=176,SDL_SCANCODE_KP_000=177,SDL_SCANCODE_THOUSANDSSEPARATOR=178,SDL_SCANCODE_DECIMALSEPARATOR=179,SDL_SCANCODE_CURRENCYUNIT=180,SDL_SCANCODE_CURRENCYSUBUNIT=181,SDL_SCANCODE_KP_LEFTPAREN=182,SDL_SCANCODE_KP_RIGHTPAREN=183,SDL_SCANCODE_KP_LEFTBRACE=184,SDL_SCANCODE_KP_RIGHTBRACE=185,SDL_SCANCODE_KP_TAB=186,SDL_SCANCODE_KP_BACKSPACE=187,SDL_SCANCODE_KP_A=188,SDL_SCANCODE_KP_B=189,SDL_SCANCODE_KP_C=190,SDL_SCANCODE_KP_D=191,SDL_SCANCODE_KP_E=192,SDL_SCANCODE_KP_F=193,SDL_SCANCODE_KP_XOR=194,SDL_SCANCODE_KP_POWER=195,SDL_SCANCODE_KP_PERCENT=196,SDL_SCANCODE_KP_LESS=197,SDL_SCANCODE_KP_GREATER=198,SDL_SCANCODE_KP_AMPERSAND=199,SDL_SCANCODE_KP_DBLAMPERSAND=200,SDL_SCANCODE_KP_VERTICALBAR=201,SDL_SCANCODE_KP_DBLVERTICALBAR=202,SDL_SCANCODE_KP_COLON=203,SDL_SCANCODE_KP_HASH=204,SDL_SCANCODE_KP_SPACE=205,SDL_SCANCODE_KP_AT=206,SDL_SCANCODE_KP_EXCLAM=207,SDL_SCANCODE_KP_MEMSTORE=208,SDL_SCANCODE_KP_MEMRECALL=209,SDL_SCANCODE_KP_MEMCLEAR=210,SDL_SCANCODE_KP_MEMADD=211,SDL_SCANCODE_KP_MEMSUBTRACT=212,SDL_SCANCODE_KP_MEMMULTIPLY=213,SDL_SCANCODE_KP_MEMDIVIDE=214,SDL_SCANCODE_KP_PLUSMINUS=215,SDL_SCANCODE_KP_CLEAR=216,SDL_SCANCODE_KP_CLEARENTRY=217,SDL_SCANCODE_KP_BINARY=218,SDL_SCANCODE_KP_OCTAL=219,SDL_SCANCODE_KP_DECIMAL=220,SDL_SCANCODE_KP_HEXADECIMAL=221,SDL_SCANCODE_LCTRL=224,SDL_SCANCODE_LSHIFT=225,SDL_SCANCODE_LALT=226,SDL_SCANCODE_LGUI=227,SDL_SCANCODE_RCTRL=228,SDL_SCANCODE_RSHIFT=229,SDL_SCANCODE_RALT=230,SDL_SCANCODE_RGUI=231,SDL_SCANCODE_MODE=257,SDL_SCANCODE_AUDIONEXT=258,SDL_SCANCODE_AUDIOPREV=259,SDL_SCANCODE_AUDIOSTOP=260,SDL_SCANCODE_AUDIOPLAY=261,SDL_SCANCODE_AUDIOMUTE=262,SDL_SCANCODE_MEDIASELECT=263,SDL_SCANCODE_WWW=264,SDL_SCANCODE_MAIL=265,SDL_SCANCODE_CALCULATOR=266,SDL_SCANCODE_COMPUTER=267,SDL_SCANCODE_AC_SEARCH=268,SDL_SCANCODE_AC_HOME=269,SDL_SCANCODE_AC_BACK=270,SDL_SCANCODE_AC_FORWARD=271,SDL_SCANCODE_AC_STOP=272,SDL_SCANCODE_AC_REFRESH=273,SDL_SCANCODE_AC_BOOKMARKS=274,SDL_SCANCODE_BRIGHTNESSDOWN=275,SDL_SCANCODE_BRIGHTNESSUP=276,SDL_SCANCODE_DISPLAYSWITCH=277,SDL_SCANCODE_KBDILLUMTOGGLE=278,SDL_SCANCODE_KBDILLUMDOWN=279,SDL_SCANCODE_KBDILLUMUP=280,SDL_SCANCODE_EJECT=281,SDL_SCANCODE_SLEEP=282,SDL_SCANCODE_APP1=283,SDL_SCANCODE_APP2=284,SDL_NUM_SCANCODES=512};
typedef enum SDL_GameControllerBindType{SDL_CONTROLLER_BINDTYPE_NONE=0,SDL_CONTROLLER_BINDTYPE_BUTTON=1,SDL_CONTROLLER_BINDTYPE_AXIS=2,SDL_CONTROLLER_BINDTYPE_HAT=3};
typedef enum SDL_EventType{SDL_FIRSTEVENT=0,SDL_QUIT=256,SDL_APP_TERMINATING=257,SDL_APP_LOWMEMORY=258,SDL_APP_WILLENTERBACKGROUND=259,SDL_APP_DIDENTERBACKGROUND=260,SDL_APP_WILLENTERFOREGROUND=261,SDL_APP_DIDENTERFOREGROUND=262,SDL_WINDOWEVENT=512,SDL_SYSWMEVENT=513,SDL_KEYDOWN=768,SDL_KEYUP=769,SDL_TEXTEDITING=770,SDL_TEXTINPUT=771,SDL_KEYMAPCHANGED=772,SDL_MOUSEMOTION=1024,SDL_MOUSEBUTTONDOWN=1025,SDL_MOUSEBUTTONUP=1026,SDL_MOUSEWHEEL=1027,SDL_JOYAXISMOTION=1536,SDL_JOYBALLMOTION=1537,SDL_JOYHATMOTION=1538,SDL_JOYBUTTONDOWN=1539,SDL_JOYBUTTONUP=1540,SDL_JOYDEVICEADDED=1541,SDL_JOYDEVICEREMOVED=1542,SDL_CONTROLLERAXISMOTION=1616,SDL_CONTROLLERBUTTONDOWN=1617,SDL_CONTROLLERBUTTONUP=1618,SDL_CONTROLLERDEVICEADDED=1619,SDL_CONTROLLERDEVICEREMOVED=1620,SDL_CONTROLLERDEVICEREMAPPED=1621,SDL_FINGERDOWN=1792,SDL_FINGERUP=1793,SDL_FINGERMOTION=1794,SDL_DOLLARGESTURE=2048,SDL_DOLLARRECORD=2049,SDL_MULTIGESTURE=2050,SDL_CLIPBOARDUPDATE=2304,SDL_DROPFILE=4096,SDL_DROPTEXT=4097,SDL_DROPBEGIN=4098,SDL_DROPCOMPLETE=4099,SDL_AUDIODEVICEADDED=4352,SDL_AUDIODEVICEREMOVED=4353,SDL_RENDER_TARGETS_RESET=8192,SDL_RENDER_DEVICE_RESET=8193,SDL_USEREVENT=32768,SDL_LASTEVENT=65535};
typedef enum SDL_AssertState{SDL_ASSERTION_RETRY=0,SDL_ASSERTION_BREAK=1,SDL_ASSERTION_ABORT=2,SDL_ASSERTION_IGNORE=3,SDL_ASSERTION_ALWAYS_IGNORE=4};
typedef enum SDL_AudioStatus{SDL_AUDIO_STOPPED=0,SDL_AUDIO_PLAYING=1,SDL_AUDIO_PAUSED=2};
typedef enum SDL_SystemCursor{SDL_SYSTEM_CURSOR_ARROW=0,SDL_SYSTEM_CURSOR_IBEAM=1,SDL_SYSTEM_CURSOR_WAIT=2,SDL_SYSTEM_CURSOR_CROSSHAIR=3,SDL_SYSTEM_CURSOR_WAITARROW=4,SDL_SYSTEM_CURSOR_SIZENWSE=5,SDL_SYSTEM_CURSOR_SIZENESW=6,SDL_SYSTEM_CURSOR_SIZEWE=7,SDL_SYSTEM_CURSOR_SIZENS=8,SDL_SYSTEM_CURSOR_SIZEALL=9,SDL_SYSTEM_CURSOR_NO=10,SDL_SYSTEM_CURSOR_HAND=11,SDL_NUM_SYSTEM_CURSORS=12};
typedef enum SDL_WindowFlags{SDL_WINDOW_FULLSCREEN=1,SDL_WINDOW_OPENGL=2,SDL_WINDOW_SHOWN=4,SDL_WINDOW_HIDDEN=8,SDL_WINDOW_BORDERLESS=16,SDL_WINDOW_RESIZABLE=32,SDL_WINDOW_MINIMIZED=64,SDL_WINDOW_MAXIMIZED=128,SDL_WINDOW_INPUT_GRABBED=256,SDL_WINDOW_INPUT_FOCUS=512,SDL_WINDOW_MOUSE_FOCUS=1024,SDL_WINDOW_FULLSCREEN_DESKTOP=4097,SDL_WINDOW_FOREIGN=2048,SDL_WINDOW_ALLOW_HIGHDPI=8192,SDL_WINDOW_MOUSE_CAPTURE=16384,SDL_WINDOW_ALWAYS_ON_TOP=32768,SDL_WINDOW_SKIP_TASKBAR=65536,SDL_WINDOW_UTILITY=131072,SDL_WINDOW_TOOLTIP=262144,SDL_WINDOW_POPUP_MENU=524288};
typedef enum SDL_JoystickPowerLevel{SDL_JOYSTICK_POWER_UNKNOWN=-1,SDL_JOYSTICK_POWER_EMPTY=0,SDL_JOYSTICK_POWER_LOW=1,SDL_JOYSTICK_POWER_MEDIUM=2,SDL_JOYSTICK_POWER_FULL=3,SDL_JOYSTICK_POWER_WIRED=4,SDL_JOYSTICK_POWER_MAX=5};
typedef enum SDL_HitTestResult{SDL_HITTEST_NORMAL=0,SDL_HITTEST_DRAGGABLE=1,SDL_HITTEST_RESIZE_TOPLEFT=2,SDL_HITTEST_RESIZE_TOP=3,SDL_HITTEST_RESIZE_TOPRIGHT=4,SDL_HITTEST_RESIZE_RIGHT=5,SDL_HITTEST_RESIZE_BOTTOMRIGHT=6,SDL_HITTEST_RESIZE_BOTTOM=7,SDL_HITTEST_RESIZE_BOTTOMLEFT=8,SDL_HITTEST_RESIZE_LEFT=9};
typedef enum SDL_GameControllerButton{SDL_CONTROLLER_BUTTON_INVALID=-1,SDL_CONTROLLER_BUTTON_A=0,SDL_CONTROLLER_BUTTON_B=1,SDL_CONTROLLER_BUTTON_X=2,SDL_CONTROLLER_BUTTON_Y=3,SDL_CONTROLLER_BUTTON_BACK=4,SDL_CONTROLLER_BUTTON_GUIDE=5,SDL_CONTROLLER_BUTTON_START=6,SDL_CONTROLLER_BUTTON_LEFTSTICK=7,SDL_CONTROLLER_BUTTON_RIGHTSTICK=8,SDL_CONTROLLER_BUTTON_LEFTSHOULDER=9,SDL_CONTROLLER_BUTTON_RIGHTSHOULDER=10,SDL_CONTROLLER_BUTTON_DPAD_UP=11,SDL_CONTROLLER_BUTTON_DPAD_DOWN=12,SDL_CONTROLLER_BUTTON_DPAD_LEFT=13,SDL_CONTROLLER_BUTTON_DPAD_RIGHT=14,SDL_CONTROLLER_BUTTON_MAX=15};
typedef enum SDL_MessageBoxFlags{SDL_MESSAGEBOX_ERROR=16,SDL_MESSAGEBOX_WARNING=32,SDL_MESSAGEBOX_INFORMATION=64};
typedef enum SDL_GLattr{SDL_GL_RED_SIZE=0,SDL_GL_GREEN_SIZE=1,SDL_GL_BLUE_SIZE=2,SDL_GL_ALPHA_SIZE=3,SDL_GL_BUFFER_SIZE=4,SDL_GL_DOUBLEBUFFER=5,SDL_GL_DEPTH_SIZE=6,SDL_GL_STENCIL_SIZE=7,SDL_GL_ACCUM_RED_SIZE=8,SDL_GL_ACCUM_GREEN_SIZE=9,SDL_GL_ACCUM_BLUE_SIZE=10,SDL_GL_ACCUM_ALPHA_SIZE=11,SDL_GL_STEREO=12,SDL_GL_MULTISAMPLEBUFFERS=13,SDL_GL_MULTISAMPLESAMPLES=14,SDL_GL_ACCELERATED_VISUAL=15,SDL_GL_RETAINED_BACKING=16,SDL_GL_CONTEXT_MAJOR_VERSION=17,SDL_GL_CONTEXT_MINOR_VERSION=18,SDL_GL_CONTEXT_EGL=19,SDL_GL_CONTEXT_FLAGS=20,SDL_GL_CONTEXT_PROFILE_MASK=21,SDL_GL_SHARE_WITH_CURRENT_CONTEXT=22,SDL_GL_FRAMEBUFFER_SRGB_CAPABLE=23,SDL_GL_CONTEXT_RELEASE_BEHAVIOR=24};
struct SDL_BlitMap {};
struct _SDL_iconv_t {};
struct SDL_AssertData {int always_ignore;unsigned int trigger_count;const char*condition;const char*filename;int linenum;const char*function;const struct SDL_AssertData*next;};
struct SDL_atomic_t {int value;};
struct SDL_mutex {};
struct SDL_semaphore {};
struct SDL_cond {};
struct SDL_Thread {};
struct SDL_RWops {long(*size)(struct SDL_RWops*);long(*seek)(struct SDL_RWops*,long,int);unsigned long(*read)(struct SDL_RWops*,void*,unsigned long,unsigned long);unsigned long(*write)(struct SDL_RWops*,const void*,unsigned long,unsigned long);int(*close)(struct SDL_RWops*);unsigned int type;union {struct {unsigned char*base;unsigned char*here;unsigned char*stop;}mem;struct {void*data1;void*data2;}unknown;}hidden;};
struct SDL_AudioSpec {int freq;unsigned short format;unsigned char channels;unsigned char silence;unsigned short samples;unsigned short padding;unsigned int size;void(*callback)(void*,unsigned char*,int);void*userdata;};
struct SDL_AudioCVT {int needed;unsigned short src_format;unsigned short dst_format;double rate_incr;unsigned char*buf;int len;int len_cvt;int len_mult;double len_ratio;void(*filters)(struct SDL_AudioCVT*,unsigned short);int filter_index;};
struct SDL_Color {unsigned char r;unsigned char g;unsigned char b;unsigned char a;};
struct SDL_Palette {int ncolors;struct SDL_Color*colors;unsigned int version;int refcount;};
struct SDL_PixelFormat {unsigned int format;struct SDL_Palette*palette;unsigned char BitsPerPixel;unsigned char BytesPerPixel;unsigned char padding[2];unsigned int Rmask;unsigned int Gmask;unsigned int Bmask;unsigned int Amask;unsigned char Rloss;unsigned char Gloss;unsigned char Bloss;unsigned char Aloss;unsigned char Rshift;unsigned char Gshift;unsigned char Bshift;unsigned char Ashift;int refcount;struct SDL_PixelFormat*next;};
struct SDL_Point {int x;int y;};
struct SDL_Rect {int x;int y;int w;int h;};
struct SDL_Surface {unsigned int flags;struct SDL_PixelFormat*format;int w;int h;int pitch;void*pixels;void*userdata;int locked;void*lock_data;struct SDL_Rect clip_rect;struct SDL_BlitMap*map;int refcount;};
struct SDL_DisplayMode {unsigned int format;int w;int h;int refresh_rate;void*driverdata;};
struct SDL_Window {};
struct SDL_Keysym {enum SDL_Scancode scancode;int sym;unsigned short mod;unsigned int unused;};
struct SDL_Cursor {};
struct _SDL_Joystick {};
struct SDL_JoystickGUID {unsigned char data[16];};
struct _SDL_GameController {};
struct SDL_GameControllerButtonBind {enum SDL_GameControllerBindType bindType;union {int button;int axis;struct {int hat;int hat_mask;}hat;}value;};
struct SDL_Finger {long id;float x;float y;float pressure;};
struct SDL_CommonEvent {unsigned int type;unsigned int timestamp;};
struct SDL_WindowEvent {unsigned int type;unsigned int timestamp;unsigned int windowID;unsigned char event;unsigned char padding1;unsigned char padding2;unsigned char padding3;int data1;int data2;};
struct SDL_KeyboardEvent {unsigned int type;unsigned int timestamp;unsigned int windowID;unsigned char state;unsigned char repeat;unsigned char padding2;unsigned char padding3;struct SDL_Keysym keysym;};
struct SDL_TextEditingEvent {unsigned int type;unsigned int timestamp;unsigned int windowID;char text[(32)];int start;int length;};
struct SDL_TextInputEvent {unsigned int type;unsigned int timestamp;unsigned int windowID;char text[(32)];};
struct SDL_MouseMotionEvent {unsigned int type;unsigned int timestamp;unsigned int windowID;unsigned int which;unsigned int state;int x;int y;int xrel;int yrel;};
struct SDL_MouseButtonEvent {unsigned int type;unsigned int timestamp;unsigned int windowID;unsigned int which;unsigned char button;unsigned char state;unsigned char clicks;unsigned char padding1;int x;int y;};
struct SDL_MouseWheelEvent {unsigned int type;unsigned int timestamp;unsigned int windowID;unsigned int which;int x;int y;unsigned int direction;};
struct SDL_JoyAxisEvent {unsigned int type;unsigned int timestamp;int which;unsigned char axis;unsigned char padding1;unsigned char padding2;unsigned char padding3;short value;unsigned short padding4;};
struct SDL_JoyBallEvent {unsigned int type;unsigned int timestamp;int which;unsigned char ball;unsigned char padding1;unsigned char padding2;unsigned char padding3;short xrel;short yrel;};
struct SDL_JoyHatEvent {unsigned int type;unsigned int timestamp;int which;unsigned char hat;unsigned char value;unsigned char padding1;unsigned char padding2;};
struct SDL_JoyButtonEvent {unsigned int type;unsigned int timestamp;int which;unsigned char button;unsigned char state;unsigned char padding1;unsigned char padding2;};
struct SDL_JoyDeviceEvent {unsigned int type;unsigned int timestamp;int which;};
struct SDL_ControllerAxisEvent {unsigned int type;unsigned int timestamp;int which;unsigned char axis;unsigned char padding1;unsigned char padding2;unsigned char padding3;short value;unsigned short padding4;};
struct SDL_ControllerButtonEvent {unsigned int type;unsigned int timestamp;int which;unsigned char button;unsigned char state;unsigned char padding1;unsigned char padding2;};
struct SDL_ControllerDeviceEvent {unsigned int type;unsigned int timestamp;int which;};
struct SDL_AudioDeviceEvent {unsigned int type;unsigned int timestamp;unsigned int which;unsigned char iscapture;unsigned char padding1;unsigned char padding2;unsigned char padding3;};
struct SDL_TouchFingerEvent {unsigned int type;unsigned int timestamp;long touchId;long fingerId;float x;float y;float dx;float dy;float pressure;};
struct SDL_MultiGestureEvent {unsigned int type;unsigned int timestamp;long touchId;float dTheta;float dDist;float x;float y;unsigned short numFingers;unsigned short padding;};
struct SDL_DollarGestureEvent {unsigned int type;unsigned int timestamp;long touchId;long gestureId;unsigned int numFingers;float error;float x;float y;};
struct SDL_DropEvent {unsigned int type;unsigned int timestamp;char*file;unsigned int windowID;};
struct SDL_QuitEvent {unsigned int type;unsigned int timestamp;};
struct SDL_UserEvent {unsigned int type;unsigned int timestamp;unsigned int windowID;int code;void*data1;void*data2;};
struct SDL_SysWMEvent {unsigned int type;unsigned int timestamp;struct SDL_SysWMmsg*msg;};
union SDL_Event {unsigned int type;struct SDL_CommonEvent common;struct SDL_WindowEvent window;struct SDL_KeyboardEvent key;struct SDL_TextEditingEvent edit;struct SDL_TextInputEvent text;struct SDL_MouseMotionEvent motion;struct SDL_MouseButtonEvent button;struct SDL_MouseWheelEvent wheel;struct SDL_JoyAxisEvent jaxis;struct SDL_JoyBallEvent jball;struct SDL_JoyHatEvent jhat;struct SDL_JoyButtonEvent jbutton;struct SDL_JoyDeviceEvent jdevice;struct SDL_ControllerAxisEvent caxis;struct SDL_ControllerButtonEvent cbutton;struct SDL_ControllerDeviceEvent cdevice;struct SDL_AudioDeviceEvent adevice;struct SDL_QuitEvent quit;struct SDL_UserEvent user;struct SDL_SysWMEvent syswm;struct SDL_TouchFingerEvent tfinger;struct SDL_MultiGestureEvent mgesture;struct SDL_DollarGestureEvent dgesture;struct SDL_DropEvent drop;unsigned char padding[56];};
struct _SDL_Haptic {};
struct SDL_HapticDirection {unsigned char type;int dir[3];};
struct SDL_HapticConstant {unsigned short type;struct SDL_HapticDirection direction;unsigned int length;unsigned short delay;unsigned short button;unsigned short interval;short level;unsigned short attack_length;unsigned short attack_level;unsigned short fade_length;unsigned short fade_level;};
struct SDL_HapticPeriodic {unsigned short type;struct SDL_HapticDirection direction;unsigned int length;unsigned short delay;unsigned short button;unsigned short interval;unsigned short period;short magnitude;short offset;unsigned short phase;unsigned short attack_length;unsigned short attack_level;unsigned short fade_length;unsigned short fade_level;};
struct SDL_HapticCondition {unsigned short type;struct SDL_HapticDirection direction;unsigned int length;unsigned short delay;unsigned short button;unsigned short interval;unsigned short right_sat[3];unsigned short left_sat[3];short right_coeff[3];short left_coeff[3];unsigned short deadband[3];short center[3];};
struct SDL_HapticRamp {unsigned short type;struct SDL_HapticDirection direction;unsigned int length;unsigned short delay;unsigned short button;unsigned short interval;short start;short end;unsigned short attack_length;unsigned short attack_level;unsigned short fade_length;unsigned short fade_level;};
struct SDL_HapticLeftRight {unsigned short type;unsigned int length;unsigned short large_magnitude;unsigned short small_magnitude;};
struct SDL_HapticCustom {unsigned short type;struct SDL_HapticDirection direction;unsigned int length;unsigned short delay;unsigned short button;unsigned short interval;unsigned char channels;unsigned short period;unsigned short samples;unsigned short*data;unsigned short attack_length;unsigned short attack_level;unsigned short fade_length;unsigned short fade_level;};
union SDL_HapticEffect {unsigned short type;struct SDL_HapticConstant constant;struct SDL_HapticPeriodic periodic;struct SDL_HapticCondition condition;struct SDL_HapticRamp ramp;struct SDL_HapticLeftRight leftright;struct SDL_HapticCustom custom;};
struct SDL_MessageBoxButtonData {unsigned int flags;int buttonid;const char*text;};
struct SDL_MessageBoxColor {unsigned char r;unsigned char g;unsigned char b;};
struct SDL_MessageBoxColorScheme {struct SDL_MessageBoxColor colors[SDL_MESSAGEBOX_COLOR_MAX];};
struct SDL_MessageBoxData {unsigned int flags;struct SDL_Window*window;const char*title;const char*message;int numbuttons;const struct SDL_MessageBoxButtonData*buttons;const struct SDL_MessageBoxColorScheme*colorScheme;};
struct SDL_RendererInfo {const char*name;unsigned int flags;unsigned int num_texture_formats;unsigned int texture_formats[16];int max_texture_width;int max_texture_height;};
struct SDL_Renderer {};
struct SDL_Texture {};
struct SDL_version {unsigned char major;unsigned char minor;unsigned char patch;};
struct SDL_SysWMmsg {struct SDL_version version;enum SDL_SYSWM_TYPE subsystem;union {int dummy;}msg;};
struct SDL_SysWMinfo {struct SDL_version version;enum SDL_SYSWM_TYPE subsystem;union {int dummy;}info;};
double(SDL_atan2)(double,double);
enum SDL_bool(SDL_HasEvent)(unsigned int);
void(SDL_FreePalette)(struct SDL_Palette*);
enum SDL_PowerState(SDL_GetPowerInfo)(int*,int*);
int(SDL_MouseIsHaptic)();
void(SDL_MaximizeWindow)(struct SDL_Window*);
int(SDL_HapticStopAll)(struct _SDL_Haptic*);
void(SDL_FlushEvent)(unsigned int);
double(SDL_ceil)(double);
void(SDL_RestoreWindow)(struct SDL_Window*);
void(SDL_DestroySemaphore)(struct SDL_semaphore*);
struct SDL_Palette*(SDL_AllocPalette)(int);
int(SDL_AddTimer)(unsigned int,unsigned int(*callback)(unsigned int,void*),void*);
int(SDL_SetPaletteColors)(struct SDL_Palette*,const struct SDL_Color*,int,int);
int(SDL_GetNumDisplayModes)(int);
int(SDL_ShowCursor)(int);
int(SDL_UpdateWindowSurface)(struct SDL_Window*);
struct SDL_Texture*(SDL_CreateTextureFromSurface)(struct SDL_Renderer*,struct SDL_Surface*);
unsigned long(SDL_WriteBE16)(struct SDL_RWops*,unsigned short);
void(SDL_UnionRect)(const struct SDL_Rect*,const struct SDL_Rect*,struct SDL_Rect*);
enum SDL_bool(SDL_HasAVX)();
int(SDL_HapticEffectSupported)(struct _SDL_Haptic*,union SDL_HapticEffect*);
void*(SDL_TLSGet)(unsigned int);
unsigned int(SDL_SemValue)(struct SDL_semaphore*);
unsigned long(SDL_ReadBE64)(struct SDL_RWops*);
int(SDL_RecordGesture)(long);
unsigned int(SDL_GetMouseState)(int*,int*);
unsigned long(SDL_WriteLE32)(struct SDL_RWops*,unsigned int);
int(SDL_SaveDollarTemplate)(long,struct SDL_RWops*);
void(SDL_ClearError)();
int(SDL_SetError)(const char*,...);
const char*(SDL_JoystickName)(struct _SDL_Joystick*);
struct SDL_Surface*(SDL_GetWindowSurface)(struct SDL_Window*);
struct SDL_RWops*(SDL_AllocRW)();
void*(SDL_realloc)(void*,unsigned long);
int(SDL_SetTextureColorMod)(struct SDL_Texture*,unsigned char,unsigned char,unsigned char);
void(SDL_DestroyWindow)(struct SDL_Window*);
int(SDL_AtomicGet)(struct SDL_atomic_t*);
const char*(SDL_GameControllerGetStringForAxis)(enum SDL_GameControllerAxis);
struct SDL_Cursor*(SDL_CreateSystemCursor)(enum SDL_SystemCursor);
unsigned long(SDL_GetPerformanceCounter)();
struct SDL_GameControllerButtonBind(SDL_GameControllerGetBindForAxis)(struct _SDL_GameController*,enum SDL_GameControllerAxis);
int(SDL_Error)(enum SDL_errorcode);
unsigned long(SDL_iconv)(struct _SDL_iconv_t*,const char**,unsigned long*,char**,unsigned long*);
int(SDL_JoystickNumAxes)(struct _SDL_Joystick*);
int(SDL_UpperBlit)(struct SDL_Surface*,const struct SDL_Rect*,struct SDL_Surface*,struct SDL_Rect*);
enum SDL_bool(SDL_IsScreenSaverEnabled)();
void(SDL_Delay)(unsigned int);
int(SDL_GL_GetAttribute)(enum SDL_GLattr,int*);
int(SDL_UpdateTexture)(struct SDL_Texture*,const struct SDL_Rect*,const void*,int);
unsigned long(SDL_wcslcpy)(int*,const int*,unsigned long);
void(SDL_FreeFormat)(struct SDL_PixelFormat*);
short(SDL_GameControllerGetAxis)(struct _SDL_GameController*,enum SDL_GameControllerAxis);
void(SDL_DisableScreenSaver)();
int(SDL_PollEvent)(union SDL_Event*);
void(SDL_JoystickUpdate)();
float(SDL_sinf)(float);
unsigned long(SDL_WriteU8)(struct SDL_RWops*,unsigned char);
char*(SDL_strchr)(const char*,int);
int(SDL_RenderSetLogicalSize)(struct SDL_Renderer*,int,int);
int(SDL_SetRenderDrawBlendMode)(struct SDL_Renderer*,enum SDL_BlendMode);
int(SDL_RenderSetIntegerScale)(struct SDL_Renderer*,enum SDL_bool);
enum SDL_JoystickPowerLevel(SDL_JoystickCurrentPowerLevel)(struct _SDL_Joystick*);
unsigned int(SDL_GetRelativeMouseState)(int*,int*);
void(SDL_GetClipRect)(struct SDL_Surface*,struct SDL_Rect*);
int(SDL_AtomicSet)(struct SDL_atomic_t*,int);
enum SDL_bool(SDL_IsTextInputActive)();
struct SDL_Cursor*(SDL_GetCursor)();
int(SDL_JoystickGetBall)(struct _SDL_Joystick*,int,int*,int*);
void(SDL_DetachThread)(struct SDL_Thread*);
void(SDL_UnloadObject)(void*);
int(SDL_WaitEvent)(union SDL_Event*);
enum SDL_GameControllerAxis(SDL_GameControllerGetAxisFromString)(const char*);
unsigned long(SDL_ThreadID)();
void(SDL_PumpEvents)();
void(SDL_GL_UnloadLibrary)();
struct SDL_Window*(SDL_GetKeyboardFocus)();
int(SDL_strcmp)(const char*,const char*);
int(SDL_HapticNumAxes)(struct _SDL_Haptic*);
int(SDL_sscanf)(const char*,const char*,...);
struct SDL_Finger*(SDL_GetTouchFinger)(long,int);
struct SDL_RWops*(SDL_RWFromConstMem)(const void*,int);
int(SDL_isspace)(int);
struct _SDL_GameController*(SDL_GameControllerOpen)(int);
int(SDL_SemTryWait)(struct SDL_semaphore*);
struct SDL_Surface*(SDL_CreateRGBSurface)(unsigned int,int,int,int,unsigned int,unsigned int,unsigned int,unsigned int);
void*(SDL_calloc)(unsigned long,unsigned long);
void(SDL_LockAudio)();
int(SDL_GetWindowOpacity)(struct SDL_Window*,float*);
double(SDL_copysign)(double,double);
int(SDL_SetWindowModalFor)(struct SDL_Window*,struct SDL_Window*);
int(SDL_AudioInit)(const char*);
const unsigned char*(SDL_GetKeyboardState)(int*);
int(SDL_JoystickInstanceID)(struct _SDL_Joystick*);
void(SDL_JoystickGetGUIDString)(struct SDL_JoystickGUID,char*,int);
void(SDL_FilterEvents)(int(*filter)(void*,union SDL_Event*),void*);
struct SDL_Renderer*(SDL_GetRenderer)(struct SDL_Window*);
int(SDL_GetWindowDisplayIndex)(struct SDL_Window*);
int(SDL_SetWindowDisplayMode)(struct SDL_Window*,const struct SDL_DisplayMode*);
int(SDL_SetSurfaceRLE)(struct SDL_Surface*,int);
void(SDL_StartTextInput)();
int(SDL_ConvertAudio)(struct SDL_AudioCVT*);
void(SDL_LogDebug)(int,const char*,...);
int(SDL_JoystickNumHats)(struct _SDL_Joystick*);
const char*(SDL_GetPlatform)();
struct SDL_Window*(SDL_GetGrabbedWindow)();
int(SDL_UnlockMutex)(struct SDL_mutex*);
enum SDL_bool(SDL_HasSSE)();
void(SDL_UnlockAudioDevice)(unsigned int);
int(SDL_LoadDollarTemplates)(long,struct SDL_RWops*);
void(SDL_LogSetOutputFunction)(void(*callback)(void*,int,enum SDL_LogPriority,const char*),void*);
const char*(SDL_GetVideoDriver)(int);
int(SDL_GetKeyFromName)(const char*);
int(SDL_GameControllerAddMappingsFromRW)(struct SDL_RWops*,int);
void(SDL_PauseAudio)(int);
short(SDL_JoystickGetAxis)(struct _SDL_Joystick*,int);
int(SDL_vsscanf)(const char*,const char*,__builtin_va_list);
int(SDL_HapticRunEffect)(struct _SDL_Haptic*,int,unsigned int);
int(SDL_RenderCopyEx)(struct SDL_Renderer*,struct SDL_Texture*,const struct SDL_Rect*,const struct SDL_Rect*,const double,const struct SDL_Point*,const enum SDL_RendererFlip);
int(SDL_GL_SetSwapInterval)(int);
void(SDL_ClearHints)();
int(SDL_GL_MakeCurrent)(struct SDL_Window*,void*);
int(SDL_ShowMessageBox)(const struct SDL_MessageBoxData*,int*);
int(SDL_LockTexture)(struct SDL_Texture*,const struct SDL_Rect*,void**,int*);
void(SDL_RenderGetScale)(struct SDL_Renderer*,float*,float*);
void(SDL_LogGetOutputFunction)(void(*callback)(void*,int,enum SDL_LogPriority,const char*),void**);
void(SDL_SetAssertionHandler)(enum SDL_AssertState(*handler)(const struct SDL_AssertData*,void*),void*);
void*(SDL_AtomicGetPtr)(void**);
void(SDL_WarpMouseInWindow)(struct SDL_Window*,int,int);
int(SDL_JoystickEventState)(int);
int(SDL_setenv)(const char*,const char*,int);
void(SDL_PauseAudioDevice)(unsigned int,int);
unsigned int(SDL_GetWindowID)(struct SDL_Window*);
double(SDL_asin)(double);
struct _SDL_iconv_t*(SDL_iconv_open)(const char*,const char*);
unsigned long(SDL_strtoull)(const char*,char**,int);
int(SDL_SaveBMP_RW)(struct SDL_Surface*,struct SDL_RWops*,int);
unsigned int(SDL_MasksToPixelFormatEnum)(int,unsigned int,unsigned int,unsigned int,unsigned int);
double(SDL_fabs)(double);
void(SDL_ResetAssertionReport)();
struct SDL_GameControllerButtonBind(SDL_GameControllerGetBindForButton)(struct _SDL_GameController*,enum SDL_GameControllerButton);
int(SDL_SetColorKey)(struct SDL_Surface*,int,unsigned int);
void(SDL_ClearQueuedAudio)(unsigned int);
void(SDL_SetTextInputRect)(struct SDL_Rect*);
int(SDL_GetColorKey)(struct SDL_Surface*,unsigned int*);
void(SDL_GL_ResetAttributes)();
void*(SDL_GL_GetCurrentContext)();
int(SDL_SetWindowOpacity)(struct SDL_Window*,float);
unsigned int(SDL_GetWindowFlags)(struct SDL_Window*);
enum SDL_bool(SDL_PixelFormatEnumToMasks)(unsigned int,int*,unsigned int*,unsigned int*,unsigned int*,unsigned int*);
void(SDL_GL_GetDrawableSize)(struct SDL_Window*,int*,int*);
int(SDL_GetWindowBordersSize)(struct SDL_Window*,int*,int*,int*,int*);
unsigned char(SDL_JoystickGetButton)(struct _SDL_Joystick*,int);
const char*(SDL_GameControllerGetStringForButton)(enum SDL_GameControllerButton);
struct _SDL_Joystick*(SDL_JoystickFromInstanceID)(int);
int(SDL_WarpMouseGlobal)(int,int);
int(SDL_PeepEvents)(union SDL_Event*,int,enum SDL_eventaction,unsigned int,unsigned int);
int(SDL_FillRect)(struct SDL_Surface*,const struct SDL_Rect*,unsigned int);
enum SDL_AudioStatus(SDL_GetAudioDeviceStatus)(unsigned int);
int(SDL_ShowSimpleMessageBox)(unsigned int,const char*,const char*,struct SDL_Window*);
int(SDL_TryLockMutex)(struct SDL_mutex*);
struct SDL_Texture*(SDL_CreateTexture)(struct SDL_Renderer*,unsigned int,int,int,int);
int(SDL_CaptureMouse)(enum SDL_bool);
int(SDL_GetSurfaceBlendMode)(struct SDL_Surface*,enum SDL_BlendMode*);
enum SDL_bool(SDL_AtomicCASPtr)(void**,void*,void*);
void*(SDL_GL_CreateContext)(struct SDL_Window*);
int(SDL_SemWaitTimeout)(struct SDL_semaphore*,unsigned int);
void(SDL_FreeCursor)(struct SDL_Cursor*);
struct SDL_Cursor*(SDL_CreateColorCursor)(struct SDL_Surface*,int,int);
int(SDL_SemPost)(struct SDL_semaphore*);
int(SDL_vsnprintf)(char*,unsigned long,const char*,__builtin_va_list);
int(SDL_NumJoysticks)();
char*(SDL_GameControllerMapping)(struct _SDL_GameController*);
int(SDL_VideoInit)(const char*);
int(SDL_HapticNumEffects)(struct _SDL_Haptic*);
void*(SDL_memcpy)(void*,const void*,unsigned long);
enum SDL_bool(SDL_AtomicCAS)(struct SDL_atomic_t*,int,int);
const char*(SDL_GetAudioDriver)(int);
int(SDL_GameControllerEventState)(int);
void(SDL_VideoQuit)();
char*(SDL_strrchr)(const char*,int);
int(SDL_GetSurfaceColorMod)(struct SDL_Surface*,unsigned char*,unsigned char*,unsigned char*);
int(SDL_LowerBlitScaled)(struct SDL_Surface*,struct SDL_Rect*,struct SDL_Surface*,struct SDL_Rect*);
void(SDL_FreeWAV)(unsigned char*);
double(SDL_scalbn)(double,int);
const char*(SDL_GetKeyName)(int);
int(SDL_FillRects)(struct SDL_Surface*,const struct SDL_Rect*,int,unsigned int);
int(SDL_SetRelativeMouseMode)(enum SDL_bool);
void(SDL_MinimizeWindow)(struct SDL_Window*);
int(SDL_LowerBlit)(struct SDL_Surface*,struct SDL_Rect*,struct SDL_Surface*,struct SDL_Rect*);
int(SDL_strncmp)(const char*,const char*,unsigned long);
enum SDL_bool(SDL_HasRDTSC)();
char*(SDL_GetBasePath)();
int(SDL_RenderSetClipRect)(struct SDL_Renderer*,const struct SDL_Rect*);
int(SDL_isdigit)(int);
double(SDL_log)(double);
double(SDL_floor)(double);
struct SDL_AudioSpec*(SDL_LoadWAV_RW)(struct SDL_RWops*,int,struct SDL_AudioSpec*,unsigned char**,unsigned int*);
enum SDL_AssertState(*SDL_GetDefaultAssertionHandler())(const struct SDL_AssertData*,void*);
int(SDL_GL_LoadLibrary)(const char*);
int(SDL_SetSurfaceBlendMode)(struct SDL_Surface*,enum SDL_BlendMode);
int(SDL_tolower)(int);
int(SDL_HapticNewEffect)(struct _SDL_Haptic*,union SDL_HapticEffect*);
char*(SDL_ultoa)(unsigned long,char*,int);
void(SDL_GetRGBA)(unsigned int,const struct SDL_PixelFormat*,unsigned char*,unsigned char*,unsigned char*,unsigned char*);
double(SDL_sqrt)(double);
const char*(SDL_GetThreadName)(struct SDL_Thread*);
int(SDL_GetNumTouchDevices)();
void(SDL_StopTextInput)();
struct SDL_Thread*(SDL_CreateThread)(int(*fn)(void*),const char*,void*);
unsigned int(SDL_ReadBE32)(struct SDL_RWops*);
unsigned int(SDL_DequeueAudio)(unsigned int,void*,unsigned int);
int(SDL_abs)(int);
int(SDL_SetTextureAlphaMod)(struct SDL_Texture*,unsigned char);
void(SDL_CalculateGammaRamp)(float,unsigned short*);
int(SDL_GetCurrentDisplayMode)(int,struct SDL_DisplayMode*);
void(SDL_SetWindowBordered)(struct SDL_Window*,enum SDL_bool);
void(SDL_AudioQuit)();
void(SDL_ShowWindow)(struct SDL_Window*);
int(SDL_GetDisplayDPI)(int,float*,float*,float*);
unsigned int(SDL_HapticQuery)(struct _SDL_Haptic*);
const char*(SDL_GameControllerName)(struct _SDL_GameController*);
void(SDL_GameControllerClose)(struct _SDL_GameController*);
int(SDL_RenderDrawPoint)(struct SDL_Renderer*,int,int);
enum SDL_bool(SDL_IsScreenKeyboardShown)(struct SDL_Window*);
void(SDL_DestroyCond)(struct SDL_cond*);
char*(SDL_lltoa)(long,char*,int);
int(SDL_GetNumAudioDevices)(int);
unsigned long(SDL_strtoul)(const char*,char**,int);
int(SDL_SetWindowInputFocus)(struct SDL_Window*);
enum SDL_bool(SDL_GetWindowWMInfo)(struct SDL_Window*,struct SDL_SysWMinfo*);
enum SDL_bool(SDL_RenderIsClipEnabled)(struct SDL_Renderer*);
void(SDL_GetVersion)(struct SDL_version*);
void(SDL_QuitSubSystem)(unsigned int);
void(SDL_SetCursor)(struct SDL_Cursor*);
int(SDL_SemWait)(struct SDL_semaphore*);
double(SDL_pow)(double,double);
int(SDL_InitSubSystem)(unsigned int);
int(SDL_Init)(unsigned int);
int(SDL_UpdateWindowSurfaceRects)(struct SDL_Window*,const struct SDL_Rect*,int);
const char*(SDL_GetRevision)();
unsigned int(SDL_WasInit)(unsigned int);
double(SDL_atof)(const char*);
void*(SDL_AtomicSetPtr)(void**,void*);
unsigned int(SDL_GetTicks)();
void(SDL_SetWindowMaximumSize)(struct SDL_Window*,int,int);
void(SDL_LogMessage)(int,enum SDL_LogPriority,const char*,...);
int(SDL_GL_BindTexture)(struct SDL_Texture*,float*,float*);
int(SDL_PushEvent)(union SDL_Event*);
struct SDL_Surface*(SDL_CreateRGBSurfaceFrom)(void*,int,int,int,int,unsigned int,unsigned int,unsigned int,unsigned int);
enum SDL_bool(SDL_JoystickGetAttached)(struct _SDL_Joystick*);
void(SDL_DestroyRenderer)(struct SDL_Renderer*);
double(SDL_strtod)(const char*,char**);
struct _SDL_GameController*(SDL_GameControllerFromInstanceID)(int);
enum SDL_AssertState(*SDL_GetAssertionHandler(void**))(const struct SDL_AssertData*,void*);
int(SDL_RenderDrawPoints)(struct SDL_Renderer*,const struct SDL_Point*,int);
int(SDL_GL_GetSwapInterval)();
char*(SDL_strupr)(char*);
struct SDL_Surface*(SDL_ConvertSurface)(struct SDL_Surface*,const struct SDL_PixelFormat*,unsigned int);
enum SDL_bool(SDL_HasSSE2)();
unsigned char(SDL_ReadU8)(struct SDL_RWops*);
enum SDL_bool(SDL_IntersectRectAndLine)(const struct SDL_Rect*,int*,int*,int*,int*);
int(SDL_HapticRumbleSupported)(struct _SDL_Haptic*);
struct SDL_RWops*(SDL_RWFromMem)(void*,int);
char*(SDL_ulltoa)(unsigned long,char*,int);
int(SDL_QueryTexture)(struct SDL_Texture*,unsigned int*,int*,int*,int*);
int(SDL_RenderCopy)(struct SDL_Renderer*,struct SDL_Texture*,const struct SDL_Rect*,const struct SDL_Rect*);
int(SDL_RenderFillRects)(struct SDL_Renderer*,const struct SDL_Rect*,int);
int(SDL_RenderFillRect)(struct SDL_Renderer*,const struct SDL_Rect*);
int(SDL_RenderDrawRects)(struct SDL_Renderer*,const struct SDL_Rect*,int);
int(SDL_RenderDrawRect)(struct SDL_Renderer*,const struct SDL_Rect*);
int(SDL_RenderDrawLines)(struct SDL_Renderer*,const struct SDL_Point*,int);
void(SDL_LockAudioDevice)(unsigned int);
int(SDL_RenderDrawLine)(struct SDL_Renderer*,int,int,int,int);
int(SDL_RenderClear)(struct SDL_Renderer*);
struct SDL_Window*(SDL_CreateWindow)(const char*,int,int,int,int,unsigned int);
int(SDL_HapticRumblePlay)(struct _SDL_Haptic*,float,unsigned int);
int(SDL_GetCPUCacheLineSize)();
int(SDL_GetRenderDrawBlendMode)(struct SDL_Renderer*,enum SDL_BlendMode*);
int(SDL_GetRenderDrawColor)(struct SDL_Renderer*,unsigned char*,unsigned char*,unsigned char*,unsigned char*);
void(SDL_AddEventWatch)(int(*filter)(void*,union SDL_Event*),void*);
const char*(SDL_HapticName)(int);
long(SDL_strtol)(const char*,char**,int);
int(SDL_RenderSetScale)(struct SDL_Renderer*,float,float);
void(SDL_Quit)();
int(SDL_OpenAudio)(struct SDL_AudioSpec*,struct SDL_AudioSpec*);
void(SDL_RenderGetClipRect)(struct SDL_Renderer*,struct SDL_Rect*);
int(SDL_SetWindowHitTest)(struct SDL_Window*,enum SDL_HitTestResult(*callback)(struct SDL_Window*,const struct SDL_Point*,void*),void*);
enum SDL_GameControllerButton(SDL_GameControllerGetButtonFromString)(const char*);
int(SDL_memcmp)(const void*,const void*,unsigned long);
struct SDL_JoystickGUID(SDL_JoystickGetGUID)(struct _SDL_Joystick*);
void(SDL_JoystickClose)(struct _SDL_Joystick*);
struct SDL_Cursor*(SDL_CreateCursor)(const unsigned char*,const unsigned char*,int,int,int,int);
char*(SDL_strlwr)(char*);
int(SDL_CondBroadcast)(struct SDL_cond*);
void(SDL_RenderGetLogicalSize)(struct SDL_Renderer*,int*,int*);
char*(SDL_strrev)(char*);
struct SDL_Texture*(SDL_GetRenderTarget)(struct SDL_Renderer*);
enum SDL_bool(SDL_HasAltiVec)();
int(SDL_SetRenderTarget)(struct SDL_Renderer*,struct SDL_Texture*);
enum SDL_bool(SDL_RenderTargetSupported)(struct SDL_Renderer*);
int(SDL_GetDisplayBounds)(int,struct SDL_Rect*);
void(SDL_UnlockTexture)(struct SDL_Texture*);
void(SDL_GameControllerUpdate)();
int(SDL_UpdateYUVTexture)(struct SDL_Texture*,const struct SDL_Rect*,const unsigned char*,int,const unsigned char*,int,const unsigned char*,int);
int(SDL_GetTextureBlendMode)(struct SDL_Texture*,enum SDL_BlendMode*);
int(SDL_SetTextureBlendMode)(struct SDL_Texture*,enum SDL_BlendMode);
const char*(SDL_GameControllerNameForIndex)(int);
int(SDL_GetTextureAlphaMod)(struct SDL_Texture*,unsigned char*);
int(SDL_GetTextureColorMod)(struct SDL_Texture*,unsigned char*,unsigned char*,unsigned char*);
void*(SDL_SetWindowData)(struct SDL_Window*,const char*,void*);
int(SDL_GetRendererOutputSize)(struct SDL_Renderer*,int*,int*);
int(SDL_GetRendererInfo)(struct SDL_Renderer*,struct SDL_RendererInfo*);
int(SDL_iconv_close)(struct _SDL_iconv_t*);
struct SDL_Renderer*(SDL_CreateRenderer)(struct SDL_Window*,int,unsigned int);
void(SDL_HapticClose)(struct _SDL_Haptic*);
int(SDL_GetRenderDriverInfo)(int,struct SDL_RendererInfo*);
int(SDL_HapticRumbleInit)(struct _SDL_Haptic*);
void(SDL_LogMessageV)(int,enum SDL_LogPriority,const char*,__builtin_va_list);
char*(SDL_strdup)(const char*);
void(SDL_LogCritical)(int,const char*,...);
void(SDL_LogError)(int,const char*,...);
void(SDL_LogWarn)(int,const char*,...);
void(SDL_LogInfo)(int,const char*,...);
void(SDL_HideWindow)(struct SDL_Window*);
void*(SDL_memmove)(void*,const void*,unsigned long);
const char*(SDL_GetCurrentAudioDriver)();
enum SDL_LogPriority(SDL_LogGetPriority)(int);
unsigned int(SDL_GetQueuedAudioSize)(unsigned int);
void(SDL_LogSetPriority)(int,enum SDL_LogPriority);
void(SDL_LogSetAllPriority)(enum SDL_LogPriority);
void*(SDL_LoadFunction)(void*,const char*);
int(SDL_HapticSetAutocenter)(struct _SDL_Haptic*,int);
void*(SDL_LoadObject)(const char*);
void(SDL_DelHintCallback)(const char*,void(*callback)(void*,const char*,const char*,const char*),void*);
void(SDL_AddHintCallback)(const char*,void(*callback)(void*,const char*,const char*,const char*),void*);
void(SDL_WaitThread)(struct SDL_Thread*,int*);
void(SDL_UnlockAudio)();
const char*(SDL_GetHint)(const char*);
enum SDL_bool(SDL_SetHint)(const char*,const char*);
enum SDL_bool(SDL_SetHintWithPriority)(const char*,const char*,enum SDL_HintPriority);
const char*(SDL_GetWindowTitle)(struct SDL_Window*);
struct _SDL_Joystick*(SDL_JoystickOpen)(int);
int(SDL_HapticRumbleStop)(struct _SDL_Haptic*);
char*(SDL_iconv_string)(const char*,const char*,const char*,unsigned long);
int(SDL_GetNumRenderDrivers)();
int(SDL_HapticUnpause)(struct _SDL_Haptic*);
int(SDL_HapticPause)(struct _SDL_Haptic*);
int(SDL_HapticSetGain)(struct _SDL_Haptic*,int);
int(SDL_HapticGetEffectStatus)(struct _SDL_Haptic*,int);
unsigned int(SDL_MapRGB)(const struct SDL_PixelFormat*,unsigned char,unsigned char,unsigned char);
void(SDL_HapticDestroyEffect)(struct _SDL_Haptic*,int);
int(SDL_HapticStopEffect)(struct _SDL_Haptic*,int);
int(SDL_HapticUpdateEffect)(struct _SDL_Haptic*,int,union SDL_HapticEffect*);
int(SDL_HapticNumEffectsPlaying)(struct _SDL_Haptic*);
long(SDL_strtoll)(const char*,char**,int);
int(SDL_CreateWindowAndRenderer)(int,int,unsigned int,struct SDL_Window**,struct SDL_Renderer**);
void(SDL_SetEventFilter)(int(*filter)(void*,union SDL_Event*),void*);
struct SDL_Window*(SDL_GL_GetCurrentWindow)();
unsigned long(SDL_GetThreadID)(struct SDL_Thread*);
double(SDL_acos)(double);
void(SDL_GetWindowMinimumSize)(struct SDL_Window*,int*,int*);
float(SDL_cosf)(float);
int(SDL_GetCPUCount)();
enum SDL_bool(SDL_Has3DNow)();
int(SDL_JoystickIsHaptic)(struct _SDL_Joystick*);
struct _SDL_Haptic*(SDL_HapticOpenFromMouse)();
int(SDL_GameControllerAddMapping)(const char*);
double(SDL_sin)(double);
struct _SDL_Haptic*(SDL_HapticOpen)(int);
unsigned int(SDL_ReadLE32)(struct SDL_RWops*);
int(SDL_LockMutex)(struct SDL_mutex*);
struct SDL_JoystickGUID(SDL_JoystickGetDeviceGUID)(int);
struct SDL_DisplayMode*(SDL_GetClosestDisplayMode)(int,const struct SDL_DisplayMode*,struct SDL_DisplayMode*);
int(SDL_SetRenderDrawColor)(struct SDL_Renderer*,unsigned char,unsigned char,unsigned char,unsigned char);
unsigned short(SDL_ReadLE16)(struct SDL_RWops*);
int(SDL_NumHaptics)();
char*(SDL_GetPrefPath)(const char*,const char*);
enum SDL_bool(SDL_GetEventFilter)(int(*filter)(void*,union SDL_Event*),void**);
void*(SDL_memset)(void*,int,unsigned long);
unsigned char(SDL_EventState)(unsigned int,int);
int(SDL_SaveAllDollarTemplates)(struct SDL_RWops*);
void(SDL_FreeSurface)(struct SDL_Surface*);
char*(SDL_uitoa)(unsigned int,char*,int);
unsigned int(SDL_RegisterEvents)(int);
int(SDL_SoftStretch)(struct SDL_Surface*,const struct SDL_Rect*,struct SDL_Surface*,const struct SDL_Rect*);
void(SDL_GetWindowMaximumSize)(struct SDL_Window*,int*,int*);
int(SDL_WaitEventTimeout)(union SDL_Event*,int);
enum SDL_bool(SDL_HasClipboardText)();
void(SDL_GetWindowSize)(struct SDL_Window*,int*,int*);
int(SDL_GetNumAudioDrivers)();
int(SDL_SetPixelFormatPalette)(struct SDL_PixelFormat*,struct SDL_Palette*);
void(SDL_FlushEvents)(unsigned int,unsigned int);
float(SDL_GetWindowBrightness)(struct SDL_Window*);
enum SDL_bool(SDL_RenderGetIntegerScale)(struct SDL_Renderer*);
unsigned long(SDL_WriteBE32)(struct SDL_RWops*,unsigned int);
char*(SDL_GetClipboardText)();
const char*(SDL_GetAudioDeviceName)(int,int);
unsigned int(SDL_OpenAudioDevice)(const char*,int,const struct SDL_AudioSpec*,struct SDL_AudioSpec*,int);
void(SDL_MixAudioFormat)(unsigned char*,const unsigned char*,unsigned short,unsigned int,int);
int(SDL_SetClipboardText)(const char*);
unsigned char(SDL_JoystickGetHat)(struct _SDL_Joystick*,int);
unsigned long(SDL_wcslen)(const int*);
int(SDL_GetSurfaceAlphaMod)(struct SDL_Surface*,unsigned char*);
enum SDL_bool(SDL_GetRelativeMouseMode)();
void(SDL_SetModState)(enum SDL_Keymod);
struct SDL_Cursor*(SDL_GetDefaultCursor)();
char*(SDL_itoa)(int,char*,int);
void(SDL_CloseAudio)();
int(SDL_strcasecmp)(const char*,const char*);
int(SDL_GetNumVideoDrivers)();
void(SDL_LogResetPriorities)();
enum SDL_bool(SDL_RemoveTimer)(int);
enum SDL_Keymod(SDL_GetModState)();
int(SDL_GL_SetAttribute)(enum SDL_GLattr,int);
int(SDL_GetKeyFromScancode)(enum SDL_Scancode);
void(SDL_RenderPresent)(struct SDL_Renderer*);
enum SDL_Scancode(SDL_GetScancodeFromKey)(int);
double(SDL_cos)(double);
unsigned int(SDL_GetWindowPixelFormat)(struct SDL_Window*);
enum SDL_Scancode(SDL_GetScancodeFromName)(const char*);
int(SDL_AtomicAdd)(struct SDL_atomic_t*,int);
unsigned long(SDL_wcslcat)(int*,const int*,unsigned long);
unsigned long(SDL_WriteBE64)(struct SDL_RWops*,unsigned long);
int(SDL_GetRevisionNumber)();
struct SDL_Surface*(SDL_ConvertSurfaceFormat)(struct SDL_Surface*,unsigned int,unsigned int);
int(SDL_SetWindowFullscreen)(struct SDL_Window*,unsigned int);
unsigned long(SDL_WriteLE64)(struct SDL_RWops*,unsigned long);
unsigned char(SDL_GameControllerGetButton)(struct _SDL_GameController*,enum SDL_GameControllerButton);
unsigned long(SDL_strlen)(const char*);
void(SDL_CloseAudioDevice)(unsigned int);
int(SDL_SetSurfacePalette)(struct SDL_Surface*,struct SDL_Palette*);
int(SDL_GetSystemRAM)();
void(SDL_MixAudio)(unsigned char*,const unsigned char*,unsigned int,int);
void(SDL_DestroyTexture)(struct SDL_Texture*);
enum SDL_AudioStatus(SDL_GetAudioStatus)();
int(SDL_RenderReadPixels)(struct SDL_Renderer*,const struct SDL_Rect*,unsigned int,void*,int);
void(SDL_DelEventWatch)(int(*filter)(void*,union SDL_Event*),void*);
struct SDL_JoystickGUID(SDL_JoystickGetGUIDFromString)(const char*);
void(SDL_SetWindowIcon)(struct SDL_Window*,struct SDL_Surface*);
void(SDL_AtomicUnlock)(int*);
struct SDL_RWops*(SDL_RWFromFP)(void*,enum SDL_bool);
void(SDL_AtomicLock)(int*);
int(SDL_CondWait)(struct SDL_cond*,struct SDL_mutex*);
unsigned long(SDL_WriteLE16)(struct SDL_RWops*,unsigned short);
unsigned short(SDL_ReadBE16)(struct SDL_RWops*);
int(SDL_JoystickNumBalls)(struct _SDL_Joystick*);
int(SDL_SetSurfaceAlphaMod)(struct SDL_Surface*,unsigned char);
unsigned long(SDL_utf8strlcpy)(char*,const char*,unsigned long);
int(SDL_GetDisplayMode)(int,int,struct SDL_DisplayMode*);
enum SDL_bool(SDL_HasIntersection)(const struct SDL_Rect*,const struct SDL_Rect*);
int(SDL_BuildAudioCVT)(struct SDL_AudioCVT*,unsigned short,unsigned char,int,unsigned short,unsigned char,int);
struct SDL_PixelFormat*(SDL_AllocFormat)(unsigned int);
unsigned int(SDL_TLSCreate)();
int(SDL_ConvertPixels)(int,int,unsigned int,const void*,int,unsigned int,void*,int);
struct SDL_mutex*(SDL_CreateMutex)();
int(SDL_SetWindowBrightness)(struct SDL_Window*,float);
void(SDL_RenderGetViewport)(struct SDL_Renderer*,struct SDL_Rect*);
int(SDL_strncasecmp)(const char*,const char*,unsigned long);
enum SDL_bool(SDL_IsGameController)(int);
char*(SDL_ltoa)(long,char*,int);
void(SDL_GL_SwapWindow)(struct SDL_Window*);
struct _SDL_Joystick*(SDL_GameControllerGetJoystick)(struct _SDL_GameController*);
double(SDL_atan)(double);
enum SDL_bool(SDL_SetClipRect)(struct SDL_Surface*,const struct SDL_Rect*);
float(SDL_sqrtf)(float);
unsigned long(SDL_GetPerformanceFrequency)();
void(SDL_FreeRW)(struct SDL_RWops*);
int(SDL_SetThreadPriority)(enum SDL_ThreadPriority);
struct SDL_RWops*(SDL_RWFromFile)(const char*,const char*);
enum SDL_bool(SDL_IntersectRect)(const struct SDL_Rect*,const struct SDL_Rect*,struct SDL_Rect*);
void(SDL_GetRGB)(unsigned int,const struct SDL_PixelFormat*,unsigned char*,unsigned char*,unsigned char*);
const char*(SDL_GetDisplayName)(int);
void(SDL_RaiseWindow)(struct SDL_Window*);
int(SDL_toupper)(int);
int(SDL_atoi)(const char*);
void*(SDL_GL_GetProcAddress)(const char*);
enum SDL_bool(SDL_GameControllerGetAttached)(struct _SDL_GameController*);
int(SDL_snprintf)(char*,unsigned long,const char*,...);
float(SDL_tanf)(float);
void(SDL_UnlockSurface)(struct SDL_Surface*);
enum SDL_bool(SDL_HasSSE3)();
struct SDL_Window*(SDL_GetMouseFocus)();
enum SDL_bool(SDL_HasSSE41)();
enum SDL_bool(SDL_HasSSE42)();
char*(SDL_GameControllerMappingForGUID)(struct SDL_JoystickGUID);
int(SDL_GetNumVideoDisplays)();
struct SDL_semaphore*(SDL_CreateSemaphore)(unsigned int);
char*(SDL_getenv)(const char*);
int(SDL_HapticOpened)(int);
const char*(SDL_GetPixelFormatName)(unsigned int);
long(SDL_GetTouchDevice)(int);
int(SDL_SetSurfaceColorMod)(struct SDL_Surface*,unsigned char,unsigned char,unsigned char);
double(SDL_tan)(double);
int(SDL_UpperBlitScaled)(struct SDL_Surface*,const struct SDL_Rect*,struct SDL_Surface*,struct SDL_Rect*);
void*(SDL_malloc)(unsigned long);
const char*(SDL_GetCurrentVideoDriver)();
enum SDL_bool(SDL_HasAVX2)();
int(SDL_GetDisplayUsableBounds)(int,struct SDL_Rect*);
const struct SDL_AssertData*(SDL_GetAssertionReport)();
int(SDL_QueueAudio)(unsigned int,const void*,unsigned int);
int(SDL_SetWindowGammaRamp)(struct SDL_Window*,const unsigned short*,const unsigned short*,const unsigned short*);
int(SDL_GetWindowDisplayMode)(struct SDL_Window*,struct SDL_DisplayMode*);
enum SDL_bool(SDL_HasMMX)();
enum SDL_AssertState(SDL_ReportAssertion)(struct SDL_AssertData*,const char*,const char*,int);
const char*(SDL_JoystickNameForIndex)(int);
struct SDL_Window*(SDL_CreateWindowFrom)(const void*);
unsigned long(SDL_strlcat)(char*,const char*,unsigned long);
const char*(SDL_GetError)();
int(SDL_GetWindowGammaRamp)(struct SDL_Window*,unsigned short*,unsigned short*,unsigned short*);
void(SDL_SetWindowTitle)(struct SDL_Window*,const char*);
struct SDL_Renderer*(SDL_CreateSoftwareRenderer)(struct SDL_Surface*);
char*(SDL_strstr)(const char*,const char*);
struct SDL_Surface*(SDL_LoadBMP_RW)(struct SDL_RWops*,int);
void*(SDL_GetWindowData)(struct SDL_Window*,const char*);
void(SDL_SetWindowPosition)(struct SDL_Window*,int,int);
void(SDL_SetMainReady)();
void(SDL_GetWindowPosition)(struct SDL_Window*,int*,int*);
int(SDL_GetNumTouchFingers)(long);
void(SDL_SetWindowSize)(struct SDL_Window*,int,int);
enum SDL_bool(SDL_HasScreenKeyboardSupport)();
enum SDL_bool(SDL_HasEvents)(unsigned int,unsigned int);
void(SDL_SetWindowMinimumSize)(struct SDL_Window*,int,int);
struct _SDL_Haptic*(SDL_HapticOpenFromJoystick)(struct _SDL_Joystick*);
int(SDL_GL_UnbindTexture)(struct SDL_Texture*);
void(SDL_Log)(const char*,...);
enum SDL_bool(SDL_EnclosePoints)(const struct SDL_Point*,int,const struct SDL_Rect*,struct SDL_Rect*);
void(SDL_LogVerbose)(int,const char*,...);
int(SDL_CondWaitTimeout)(struct SDL_cond*,struct SDL_mutex*,unsigned int);
unsigned long(SDL_ReadLE64)(struct SDL_RWops*);
unsigned int(SDL_MapRGBA)(const struct SDL_PixelFormat*,unsigned char,unsigned char,unsigned char,unsigned char);
void(SDL_SetWindowGrab)(struct SDL_Window*,enum SDL_bool);
enum SDL_bool(SDL_GetWindowGrab)(struct SDL_Window*);
struct SDL_Window*(SDL_GetWindowFromID)(unsigned int);
int(SDL_CondSignal)(struct SDL_cond*);
void(SDL_free)(void*);
void(SDL_GL_DeleteContext)(void*);
int(SDL_GetDesktopDisplayMode)(int,struct SDL_DisplayMode*);
unsigned long(SDL_strlcpy)(char*,const char*,unsigned long);
const char*(SDL_GetScancodeName)(enum SDL_Scancode);
void(SDL_EnableScreenSaver)();
unsigned int(SDL_GetGlobalMouseState)(int*,int*);
struct SDL_cond*(SDL_CreateCond)();
void(SDL_DestroyMutex)(struct SDL_mutex*);
int(SDL_RenderSetViewport)(struct SDL_Renderer*,const struct SDL_Rect*);
int(SDL_JoystickNumButtons)(struct _SDL_Joystick*);
int(SDL_LockSurface)(struct SDL_Surface*);
int(SDL_HapticIndex)(struct _SDL_Haptic*);
enum SDL_bool(SDL_AtomicTryLock)(int*);
enum SDL_bool(SDL_GL_ExtensionSupported)(const char*);
]])
local CLIB = ffi.load(_G.FFI_LIB or "SDL2")
local library = {}
library = {
	atan2 = CLIB.SDL_atan2,
	HasEvent = CLIB.SDL_HasEvent,
	FreePalette = CLIB.SDL_FreePalette,
	GetPowerInfo = CLIB.SDL_GetPowerInfo,
	MouseIsHaptic = CLIB.SDL_MouseIsHaptic,
	MaximizeWindow = CLIB.SDL_MaximizeWindow,
	HapticStopAll = CLIB.SDL_HapticStopAll,
	FlushEvent = CLIB.SDL_FlushEvent,
	ceil = CLIB.SDL_ceil,
	RestoreWindow = CLIB.SDL_RestoreWindow,
	DestroySemaphore = CLIB.SDL_DestroySemaphore,
	AllocPalette = CLIB.SDL_AllocPalette,
	AddTimer = CLIB.SDL_AddTimer,
	SetPaletteColors = CLIB.SDL_SetPaletteColors,
	GetNumDisplayModes = CLIB.SDL_GetNumDisplayModes,
	ShowCursor = CLIB.SDL_ShowCursor,
	UpdateWindowSurface = CLIB.SDL_UpdateWindowSurface,
	CreateTextureFromSurface = CLIB.SDL_CreateTextureFromSurface,
	WriteBE16 = CLIB.SDL_WriteBE16,
	UnionRect = CLIB.SDL_UnionRect,
	HasAVX = CLIB.SDL_HasAVX,
	HapticEffectSupported = CLIB.SDL_HapticEffectSupported,
	TLSGet = CLIB.SDL_TLSGet,
	SemValue = CLIB.SDL_SemValue,
	ReadBE64 = CLIB.SDL_ReadBE64,
	RecordGesture = CLIB.SDL_RecordGesture,
	GetMouseState = CLIB.SDL_GetMouseState,
	WriteLE32 = CLIB.SDL_WriteLE32,
	SaveDollarTemplate = CLIB.SDL_SaveDollarTemplate,
	ClearError = CLIB.SDL_ClearError,
	SetError = CLIB.SDL_SetError,
	JoystickName = CLIB.SDL_JoystickName,
	GetWindowSurface = CLIB.SDL_GetWindowSurface,
	AllocRW = CLIB.SDL_AllocRW,
	realloc = CLIB.SDL_realloc,
	SetTextureColorMod = CLIB.SDL_SetTextureColorMod,
	DestroyWindow = CLIB.SDL_DestroyWindow,
	AtomicGet = CLIB.SDL_AtomicGet,
	GameControllerGetStringForAxis = CLIB.SDL_GameControllerGetStringForAxis,
	CreateSystemCursor = CLIB.SDL_CreateSystemCursor,
	GetPerformanceCounter = CLIB.SDL_GetPerformanceCounter,
	GameControllerGetBindForAxis = CLIB.SDL_GameControllerGetBindForAxis,
	Error = CLIB.SDL_Error,
	iconv = CLIB.SDL_iconv,
	JoystickNumAxes = CLIB.SDL_JoystickNumAxes,
	UpperBlit = CLIB.SDL_UpperBlit,
	IsScreenSaverEnabled = CLIB.SDL_IsScreenSaverEnabled,
	Delay = CLIB.SDL_Delay,
	GL_GetAttribute = CLIB.SDL_GL_GetAttribute,
	UpdateTexture = CLIB.SDL_UpdateTexture,
	wcslcpy = CLIB.SDL_wcslcpy,
	FreeFormat = CLIB.SDL_FreeFormat,
	GameControllerGetAxis = CLIB.SDL_GameControllerGetAxis,
	DisableScreenSaver = CLIB.SDL_DisableScreenSaver,
	PollEvent = CLIB.SDL_PollEvent,
	JoystickUpdate = CLIB.SDL_JoystickUpdate,
	sinf = CLIB.SDL_sinf,
	WriteU8 = CLIB.SDL_WriteU8,
	strchr = CLIB.SDL_strchr,
	RenderSetLogicalSize = CLIB.SDL_RenderSetLogicalSize,
	SetRenderDrawBlendMode = CLIB.SDL_SetRenderDrawBlendMode,
	RenderSetIntegerScale = CLIB.SDL_RenderSetIntegerScale,
	JoystickCurrentPowerLevel = CLIB.SDL_JoystickCurrentPowerLevel,
	GetRelativeMouseState = CLIB.SDL_GetRelativeMouseState,
	GetClipRect = CLIB.SDL_GetClipRect,
	AtomicSet = CLIB.SDL_AtomicSet,
	IsTextInputActive = CLIB.SDL_IsTextInputActive,
	GetCursor = CLIB.SDL_GetCursor,
	JoystickGetBall = CLIB.SDL_JoystickGetBall,
	DetachThread = CLIB.SDL_DetachThread,
	UnloadObject = CLIB.SDL_UnloadObject,
	WaitEvent = CLIB.SDL_WaitEvent,
	GameControllerGetAxisFromString = CLIB.SDL_GameControllerGetAxisFromString,
	ThreadID = CLIB.SDL_ThreadID,
	PumpEvents = CLIB.SDL_PumpEvents,
	GL_UnloadLibrary = CLIB.SDL_GL_UnloadLibrary,
	GetKeyboardFocus = CLIB.SDL_GetKeyboardFocus,
	strcmp = CLIB.SDL_strcmp,
	HapticNumAxes = CLIB.SDL_HapticNumAxes,
	sscanf = CLIB.SDL_sscanf,
	GetTouchFinger = CLIB.SDL_GetTouchFinger,
	RWFromConstMem = CLIB.SDL_RWFromConstMem,
	isspace = CLIB.SDL_isspace,
	GameControllerOpen = CLIB.SDL_GameControllerOpen,
	SemTryWait = CLIB.SDL_SemTryWait,
	CreateRGBSurface = CLIB.SDL_CreateRGBSurface,
	calloc = CLIB.SDL_calloc,
	LockAudio = CLIB.SDL_LockAudio,
	GetWindowOpacity = CLIB.SDL_GetWindowOpacity,
	copysign = CLIB.SDL_copysign,
	SetWindowModalFor = CLIB.SDL_SetWindowModalFor,
	AudioInit = CLIB.SDL_AudioInit,
	GetKeyboardState = CLIB.SDL_GetKeyboardState,
	JoystickInstanceID = CLIB.SDL_JoystickInstanceID,
	JoystickGetGUIDString = CLIB.SDL_JoystickGetGUIDString,
	FilterEvents = CLIB.SDL_FilterEvents,
	GetRenderer = CLIB.SDL_GetRenderer,
	GetWindowDisplayIndex = CLIB.SDL_GetWindowDisplayIndex,
	SetWindowDisplayMode = CLIB.SDL_SetWindowDisplayMode,
	SetSurfaceRLE = CLIB.SDL_SetSurfaceRLE,
	StartTextInput = CLIB.SDL_StartTextInput,
	ConvertAudio = CLIB.SDL_ConvertAudio,
	LogDebug = CLIB.SDL_LogDebug,
	JoystickNumHats = CLIB.SDL_JoystickNumHats,
	GetPlatform = CLIB.SDL_GetPlatform,
	GetGrabbedWindow = CLIB.SDL_GetGrabbedWindow,
	UnlockMutex = CLIB.SDL_UnlockMutex,
	HasSSE = CLIB.SDL_HasSSE,
	UnlockAudioDevice = CLIB.SDL_UnlockAudioDevice,
	LoadDollarTemplates = CLIB.SDL_LoadDollarTemplates,
	LogSetOutputFunction = CLIB.SDL_LogSetOutputFunction,
	GetVideoDriver = CLIB.SDL_GetVideoDriver,
	GetKeyFromName = CLIB.SDL_GetKeyFromName,
	GameControllerAddMappingsFromRW = CLIB.SDL_GameControllerAddMappingsFromRW,
	PauseAudio = CLIB.SDL_PauseAudio,
	JoystickGetAxis = CLIB.SDL_JoystickGetAxis,
	vsscanf = CLIB.SDL_vsscanf,
	HapticRunEffect = CLIB.SDL_HapticRunEffect,
	RenderCopyEx = CLIB.SDL_RenderCopyEx,
	GL_SetSwapInterval = CLIB.SDL_GL_SetSwapInterval,
	ClearHints = CLIB.SDL_ClearHints,
	GL_MakeCurrent = CLIB.SDL_GL_MakeCurrent,
	ShowMessageBox = CLIB.SDL_ShowMessageBox,
	LockTexture = CLIB.SDL_LockTexture,
	RenderGetScale = CLIB.SDL_RenderGetScale,
	LogGetOutputFunction = CLIB.SDL_LogGetOutputFunction,
	SetAssertionHandler = CLIB.SDL_SetAssertionHandler,
	AtomicGetPtr = CLIB.SDL_AtomicGetPtr,
	WarpMouseInWindow = CLIB.SDL_WarpMouseInWindow,
	JoystickEventState = CLIB.SDL_JoystickEventState,
	setenv = CLIB.SDL_setenv,
	PauseAudioDevice = CLIB.SDL_PauseAudioDevice,
	GetWindowID = CLIB.SDL_GetWindowID,
	asin = CLIB.SDL_asin,
	iconv_open = CLIB.SDL_iconv_open,
	strtoull = CLIB.SDL_strtoull,
	SaveBMP_RW = CLIB.SDL_SaveBMP_RW,
	MasksToPixelFormatEnum = CLIB.SDL_MasksToPixelFormatEnum,
	fabs = CLIB.SDL_fabs,
	ResetAssertionReport = CLIB.SDL_ResetAssertionReport,
	GameControllerGetBindForButton = CLIB.SDL_GameControllerGetBindForButton,
	SetColorKey = CLIB.SDL_SetColorKey,
	ClearQueuedAudio = CLIB.SDL_ClearQueuedAudio,
	SetTextInputRect = CLIB.SDL_SetTextInputRect,
	GetColorKey = CLIB.SDL_GetColorKey,
	GL_ResetAttributes = CLIB.SDL_GL_ResetAttributes,
	GL_GetCurrentContext = CLIB.SDL_GL_GetCurrentContext,
	SetWindowOpacity = CLIB.SDL_SetWindowOpacity,
	GetWindowFlags = CLIB.SDL_GetWindowFlags,
	PixelFormatEnumToMasks = CLIB.SDL_PixelFormatEnumToMasks,
	GL_GetDrawableSize = CLIB.SDL_GL_GetDrawableSize,
	GetWindowBordersSize = CLIB.SDL_GetWindowBordersSize,
	JoystickGetButton = CLIB.SDL_JoystickGetButton,
	GameControllerGetStringForButton = CLIB.SDL_GameControllerGetStringForButton,
	JoystickFromInstanceID = CLIB.SDL_JoystickFromInstanceID,
	WarpMouseGlobal = CLIB.SDL_WarpMouseGlobal,
	PeepEvents = CLIB.SDL_PeepEvents,
	FillRect = CLIB.SDL_FillRect,
	GetAudioDeviceStatus = CLIB.SDL_GetAudioDeviceStatus,
	ShowSimpleMessageBox = CLIB.SDL_ShowSimpleMessageBox,
	TryLockMutex = CLIB.SDL_TryLockMutex,
	CreateTexture = CLIB.SDL_CreateTexture,
	CaptureMouse = CLIB.SDL_CaptureMouse,
	GetSurfaceBlendMode = CLIB.SDL_GetSurfaceBlendMode,
	AtomicCASPtr = CLIB.SDL_AtomicCASPtr,
	GL_CreateContext = CLIB.SDL_GL_CreateContext,
	SemWaitTimeout = CLIB.SDL_SemWaitTimeout,
	FreeCursor = CLIB.SDL_FreeCursor,
	CreateColorCursor = CLIB.SDL_CreateColorCursor,
	SemPost = CLIB.SDL_SemPost,
	vsnprintf = CLIB.SDL_vsnprintf,
	NumJoysticks = CLIB.SDL_NumJoysticks,
	GameControllerMapping = CLIB.SDL_GameControllerMapping,
	VideoInit = CLIB.SDL_VideoInit,
	HapticNumEffects = CLIB.SDL_HapticNumEffects,
	memcpy = CLIB.SDL_memcpy,
	AtomicCAS = CLIB.SDL_AtomicCAS,
	GetAudioDriver = CLIB.SDL_GetAudioDriver,
	GameControllerEventState = CLIB.SDL_GameControllerEventState,
	VideoQuit = CLIB.SDL_VideoQuit,
	strrchr = CLIB.SDL_strrchr,
	GetSurfaceColorMod = CLIB.SDL_GetSurfaceColorMod,
	LowerBlitScaled = CLIB.SDL_LowerBlitScaled,
	FreeWAV = CLIB.SDL_FreeWAV,
	scalbn = CLIB.SDL_scalbn,
	GetKeyName = CLIB.SDL_GetKeyName,
	FillRects = CLIB.SDL_FillRects,
	SetRelativeMouseMode = CLIB.SDL_SetRelativeMouseMode,
	MinimizeWindow = CLIB.SDL_MinimizeWindow,
	LowerBlit = CLIB.SDL_LowerBlit,
	strncmp = CLIB.SDL_strncmp,
	HasRDTSC = CLIB.SDL_HasRDTSC,
	GetBasePath = CLIB.SDL_GetBasePath,
	RenderSetClipRect = CLIB.SDL_RenderSetClipRect,
	isdigit = CLIB.SDL_isdigit,
	log = CLIB.SDL_log,
	floor = CLIB.SDL_floor,
	LoadWAV_RW = CLIB.SDL_LoadWAV_RW,
	GetDefaultAssertionHandler = CLIB.SDL_GetDefaultAssertionHandler,
	GL_LoadLibrary = CLIB.SDL_GL_LoadLibrary,
	SetSurfaceBlendMode = CLIB.SDL_SetSurfaceBlendMode,
	tolower = CLIB.SDL_tolower,
	HapticNewEffect = CLIB.SDL_HapticNewEffect,
	ultoa = CLIB.SDL_ultoa,
	GetRGBA = CLIB.SDL_GetRGBA,
	sqrt = CLIB.SDL_sqrt,
	GetThreadName = CLIB.SDL_GetThreadName,
	GetNumTouchDevices = CLIB.SDL_GetNumTouchDevices,
	StopTextInput = CLIB.SDL_StopTextInput,
	CreateThread = CLIB.SDL_CreateThread,
	ReadBE32 = CLIB.SDL_ReadBE32,
	DequeueAudio = CLIB.SDL_DequeueAudio,
	abs = CLIB.SDL_abs,
	SetTextureAlphaMod = CLIB.SDL_SetTextureAlphaMod,
	CalculateGammaRamp = CLIB.SDL_CalculateGammaRamp,
	GetCurrentDisplayMode = CLIB.SDL_GetCurrentDisplayMode,
	SetWindowBordered = CLIB.SDL_SetWindowBordered,
	AudioQuit = CLIB.SDL_AudioQuit,
	ShowWindow = CLIB.SDL_ShowWindow,
	GetDisplayDPI = CLIB.SDL_GetDisplayDPI,
	HapticQuery = CLIB.SDL_HapticQuery,
	GameControllerName = CLIB.SDL_GameControllerName,
	GameControllerClose = CLIB.SDL_GameControllerClose,
	RenderDrawPoint = CLIB.SDL_RenderDrawPoint,
	IsScreenKeyboardShown = CLIB.SDL_IsScreenKeyboardShown,
	DestroyCond = CLIB.SDL_DestroyCond,
	lltoa = CLIB.SDL_lltoa,
	GetNumAudioDevices = CLIB.SDL_GetNumAudioDevices,
	strtoul = CLIB.SDL_strtoul,
	SetWindowInputFocus = CLIB.SDL_SetWindowInputFocus,
	GetWindowWMInfo = CLIB.SDL_GetWindowWMInfo,
	RenderIsClipEnabled = CLIB.SDL_RenderIsClipEnabled,
	GetVersion = CLIB.SDL_GetVersion,
	QuitSubSystem = CLIB.SDL_QuitSubSystem,
	SetCursor = CLIB.SDL_SetCursor,
	SemWait = CLIB.SDL_SemWait,
	pow = CLIB.SDL_pow,
	InitSubSystem = CLIB.SDL_InitSubSystem,
	Init = CLIB.SDL_Init,
	UpdateWindowSurfaceRects = CLIB.SDL_UpdateWindowSurfaceRects,
	GetRevision = CLIB.SDL_GetRevision,
	WasInit = CLIB.SDL_WasInit,
	atof = CLIB.SDL_atof,
	AtomicSetPtr = CLIB.SDL_AtomicSetPtr,
	GetTicks = CLIB.SDL_GetTicks,
	SetWindowMaximumSize = CLIB.SDL_SetWindowMaximumSize,
	LogMessage = CLIB.SDL_LogMessage,
	GL_BindTexture = CLIB.SDL_GL_BindTexture,
	PushEvent = CLIB.SDL_PushEvent,
	CreateRGBSurfaceFrom = CLIB.SDL_CreateRGBSurfaceFrom,
	JoystickGetAttached = CLIB.SDL_JoystickGetAttached,
	DestroyRenderer = CLIB.SDL_DestroyRenderer,
	strtod = CLIB.SDL_strtod,
	GameControllerFromInstanceID = CLIB.SDL_GameControllerFromInstanceID,
	GetAssertionHandler = CLIB.SDL_GetAssertionHandler,
	RenderDrawPoints = CLIB.SDL_RenderDrawPoints,
	GL_GetSwapInterval = CLIB.SDL_GL_GetSwapInterval,
	strupr = CLIB.SDL_strupr,
	ConvertSurface = CLIB.SDL_ConvertSurface,
	HasSSE2 = CLIB.SDL_HasSSE2,
	ReadU8 = CLIB.SDL_ReadU8,
	IntersectRectAndLine = CLIB.SDL_IntersectRectAndLine,
	HapticRumbleSupported = CLIB.SDL_HapticRumbleSupported,
	RWFromMem = CLIB.SDL_RWFromMem,
	ulltoa = CLIB.SDL_ulltoa,
	QueryTexture = CLIB.SDL_QueryTexture,
	RenderCopy = CLIB.SDL_RenderCopy,
	RenderFillRects = CLIB.SDL_RenderFillRects,
	RenderFillRect = CLIB.SDL_RenderFillRect,
	RenderDrawRects = CLIB.SDL_RenderDrawRects,
	RenderDrawRect = CLIB.SDL_RenderDrawRect,
	RenderDrawLines = CLIB.SDL_RenderDrawLines,
	LockAudioDevice = CLIB.SDL_LockAudioDevice,
	RenderDrawLine = CLIB.SDL_RenderDrawLine,
	RenderClear = CLIB.SDL_RenderClear,
	CreateWindow = CLIB.SDL_CreateWindow,
	HapticRumblePlay = CLIB.SDL_HapticRumblePlay,
	GetCPUCacheLineSize = CLIB.SDL_GetCPUCacheLineSize,
	GetRenderDrawBlendMode = CLIB.SDL_GetRenderDrawBlendMode,
	GetRenderDrawColor = CLIB.SDL_GetRenderDrawColor,
	AddEventWatch = CLIB.SDL_AddEventWatch,
	HapticName = CLIB.SDL_HapticName,
	strtol = CLIB.SDL_strtol,
	RenderSetScale = CLIB.SDL_RenderSetScale,
	Quit = CLIB.SDL_Quit,
	OpenAudio = CLIB.SDL_OpenAudio,
	RenderGetClipRect = CLIB.SDL_RenderGetClipRect,
	SetWindowHitTest = CLIB.SDL_SetWindowHitTest,
	GameControllerGetButtonFromString = CLIB.SDL_GameControllerGetButtonFromString,
	memcmp = CLIB.SDL_memcmp,
	JoystickGetGUID = CLIB.SDL_JoystickGetGUID,
	JoystickClose = CLIB.SDL_JoystickClose,
	CreateCursor = CLIB.SDL_CreateCursor,
	strlwr = CLIB.SDL_strlwr,
	CondBroadcast = CLIB.SDL_CondBroadcast,
	RenderGetLogicalSize = CLIB.SDL_RenderGetLogicalSize,
	strrev = CLIB.SDL_strrev,
	GetRenderTarget = CLIB.SDL_GetRenderTarget,
	HasAltiVec = CLIB.SDL_HasAltiVec,
	SetRenderTarget = CLIB.SDL_SetRenderTarget,
	RenderTargetSupported = CLIB.SDL_RenderTargetSupported,
	GetDisplayBounds = CLIB.SDL_GetDisplayBounds,
	UnlockTexture = CLIB.SDL_UnlockTexture,
	GameControllerUpdate = CLIB.SDL_GameControllerUpdate,
	UpdateYUVTexture = CLIB.SDL_UpdateYUVTexture,
	GetTextureBlendMode = CLIB.SDL_GetTextureBlendMode,
	SetTextureBlendMode = CLIB.SDL_SetTextureBlendMode,
	GameControllerNameForIndex = CLIB.SDL_GameControllerNameForIndex,
	GetTextureAlphaMod = CLIB.SDL_GetTextureAlphaMod,
	GetTextureColorMod = CLIB.SDL_GetTextureColorMod,
	SetWindowData = CLIB.SDL_SetWindowData,
	GetRendererOutputSize = CLIB.SDL_GetRendererOutputSize,
	GetRendererInfo = CLIB.SDL_GetRendererInfo,
	iconv_close = CLIB.SDL_iconv_close,
	CreateRenderer = CLIB.SDL_CreateRenderer,
	HapticClose = CLIB.SDL_HapticClose,
	GetRenderDriverInfo = CLIB.SDL_GetRenderDriverInfo,
	HapticRumbleInit = CLIB.SDL_HapticRumbleInit,
	LogMessageV = CLIB.SDL_LogMessageV,
	strdup = CLIB.SDL_strdup,
	LogCritical = CLIB.SDL_LogCritical,
	LogError = CLIB.SDL_LogError,
	LogWarn = CLIB.SDL_LogWarn,
	LogInfo = CLIB.SDL_LogInfo,
	HideWindow = CLIB.SDL_HideWindow,
	memmove = CLIB.SDL_memmove,
	GetCurrentAudioDriver = CLIB.SDL_GetCurrentAudioDriver,
	LogGetPriority = CLIB.SDL_LogGetPriority,
	GetQueuedAudioSize = CLIB.SDL_GetQueuedAudioSize,
	LogSetPriority = CLIB.SDL_LogSetPriority,
	LogSetAllPriority = CLIB.SDL_LogSetAllPriority,
	LoadFunction = CLIB.SDL_LoadFunction,
	HapticSetAutocenter = CLIB.SDL_HapticSetAutocenter,
	LoadObject = CLIB.SDL_LoadObject,
	DelHintCallback = CLIB.SDL_DelHintCallback,
	AddHintCallback = CLIB.SDL_AddHintCallback,
	WaitThread = CLIB.SDL_WaitThread,
	UnlockAudio = CLIB.SDL_UnlockAudio,
	GetHint = CLIB.SDL_GetHint,
	SetHint = CLIB.SDL_SetHint,
	SetHintWithPriority = CLIB.SDL_SetHintWithPriority,
	GetWindowTitle = CLIB.SDL_GetWindowTitle,
	JoystickOpen = CLIB.SDL_JoystickOpen,
	HapticRumbleStop = CLIB.SDL_HapticRumbleStop,
	iconv_string = CLIB.SDL_iconv_string,
	GetNumRenderDrivers = CLIB.SDL_GetNumRenderDrivers,
	HapticUnpause = CLIB.SDL_HapticUnpause,
	HapticPause = CLIB.SDL_HapticPause,
	HapticSetGain = CLIB.SDL_HapticSetGain,
	HapticGetEffectStatus = CLIB.SDL_HapticGetEffectStatus,
	MapRGB = CLIB.SDL_MapRGB,
	HapticDestroyEffect = CLIB.SDL_HapticDestroyEffect,
	HapticStopEffect = CLIB.SDL_HapticStopEffect,
	HapticUpdateEffect = CLIB.SDL_HapticUpdateEffect,
	HapticNumEffectsPlaying = CLIB.SDL_HapticNumEffectsPlaying,
	strtoll = CLIB.SDL_strtoll,
	CreateWindowAndRenderer = CLIB.SDL_CreateWindowAndRenderer,
	SetEventFilter = CLIB.SDL_SetEventFilter,
	GL_GetCurrentWindow = CLIB.SDL_GL_GetCurrentWindow,
	GetThreadID = CLIB.SDL_GetThreadID,
	acos = CLIB.SDL_acos,
	GetWindowMinimumSize = CLIB.SDL_GetWindowMinimumSize,
	cosf = CLIB.SDL_cosf,
	GetCPUCount = CLIB.SDL_GetCPUCount,
	Has3DNow = CLIB.SDL_Has3DNow,
	JoystickIsHaptic = CLIB.SDL_JoystickIsHaptic,
	HapticOpenFromMouse = CLIB.SDL_HapticOpenFromMouse,
	GameControllerAddMapping = CLIB.SDL_GameControllerAddMapping,
	sin = CLIB.SDL_sin,
	HapticOpen = CLIB.SDL_HapticOpen,
	ReadLE32 = CLIB.SDL_ReadLE32,
	LockMutex = CLIB.SDL_LockMutex,
	JoystickGetDeviceGUID = CLIB.SDL_JoystickGetDeviceGUID,
	GetClosestDisplayMode = CLIB.SDL_GetClosestDisplayMode,
	SetRenderDrawColor = CLIB.SDL_SetRenderDrawColor,
	ReadLE16 = CLIB.SDL_ReadLE16,
	NumHaptics = CLIB.SDL_NumHaptics,
	GetPrefPath = CLIB.SDL_GetPrefPath,
	GetEventFilter = CLIB.SDL_GetEventFilter,
	memset = CLIB.SDL_memset,
	EventState = CLIB.SDL_EventState,
	SaveAllDollarTemplates = CLIB.SDL_SaveAllDollarTemplates,
	FreeSurface = CLIB.SDL_FreeSurface,
	uitoa = CLIB.SDL_uitoa,
	RegisterEvents = CLIB.SDL_RegisterEvents,
	SoftStretch = CLIB.SDL_SoftStretch,
	GetWindowMaximumSize = CLIB.SDL_GetWindowMaximumSize,
	WaitEventTimeout = CLIB.SDL_WaitEventTimeout,
	HasClipboardText = CLIB.SDL_HasClipboardText,
	GetWindowSize = CLIB.SDL_GetWindowSize,
	GetNumAudioDrivers = CLIB.SDL_GetNumAudioDrivers,
	SetPixelFormatPalette = CLIB.SDL_SetPixelFormatPalette,
	FlushEvents = CLIB.SDL_FlushEvents,
	GetWindowBrightness = CLIB.SDL_GetWindowBrightness,
	RenderGetIntegerScale = CLIB.SDL_RenderGetIntegerScale,
	WriteBE32 = CLIB.SDL_WriteBE32,
	GetClipboardText = CLIB.SDL_GetClipboardText,
	GetAudioDeviceName = CLIB.SDL_GetAudioDeviceName,
	OpenAudioDevice = CLIB.SDL_OpenAudioDevice,
	MixAudioFormat = CLIB.SDL_MixAudioFormat,
	SetClipboardText = CLIB.SDL_SetClipboardText,
	JoystickGetHat = CLIB.SDL_JoystickGetHat,
	wcslen = CLIB.SDL_wcslen,
	GetSurfaceAlphaMod = CLIB.SDL_GetSurfaceAlphaMod,
	GetRelativeMouseMode = CLIB.SDL_GetRelativeMouseMode,
	SetModState = CLIB.SDL_SetModState,
	GetDefaultCursor = CLIB.SDL_GetDefaultCursor,
	itoa = CLIB.SDL_itoa,
	CloseAudio = CLIB.SDL_CloseAudio,
	strcasecmp = CLIB.SDL_strcasecmp,
	GetNumVideoDrivers = CLIB.SDL_GetNumVideoDrivers,
	LogResetPriorities = CLIB.SDL_LogResetPriorities,
	RemoveTimer = CLIB.SDL_RemoveTimer,
	GetModState = CLIB.SDL_GetModState,
	GL_SetAttribute = CLIB.SDL_GL_SetAttribute,
	GetKeyFromScancode = CLIB.SDL_GetKeyFromScancode,
	RenderPresent = CLIB.SDL_RenderPresent,
	GetScancodeFromKey = CLIB.SDL_GetScancodeFromKey,
	cos = CLIB.SDL_cos,
	GetWindowPixelFormat = CLIB.SDL_GetWindowPixelFormat,
	GetScancodeFromName = CLIB.SDL_GetScancodeFromName,
	AtomicAdd = CLIB.SDL_AtomicAdd,
	wcslcat = CLIB.SDL_wcslcat,
	WriteBE64 = CLIB.SDL_WriteBE64,
	GetRevisionNumber = CLIB.SDL_GetRevisionNumber,
	ConvertSurfaceFormat = CLIB.SDL_ConvertSurfaceFormat,
	SetWindowFullscreen = CLIB.SDL_SetWindowFullscreen,
	WriteLE64 = CLIB.SDL_WriteLE64,
	GameControllerGetButton = CLIB.SDL_GameControllerGetButton,
	strlen = CLIB.SDL_strlen,
	CloseAudioDevice = CLIB.SDL_CloseAudioDevice,
	SetSurfacePalette = CLIB.SDL_SetSurfacePalette,
	GetSystemRAM = CLIB.SDL_GetSystemRAM,
	MixAudio = CLIB.SDL_MixAudio,
	DestroyTexture = CLIB.SDL_DestroyTexture,
	GetAudioStatus = CLIB.SDL_GetAudioStatus,
	RenderReadPixels = CLIB.SDL_RenderReadPixels,
	DelEventWatch = CLIB.SDL_DelEventWatch,
	JoystickGetGUIDFromString = CLIB.SDL_JoystickGetGUIDFromString,
	SetWindowIcon = CLIB.SDL_SetWindowIcon,
	AtomicUnlock = CLIB.SDL_AtomicUnlock,
	RWFromFP = CLIB.SDL_RWFromFP,
	AtomicLock = CLIB.SDL_AtomicLock,
	CondWait = CLIB.SDL_CondWait,
	WriteLE16 = CLIB.SDL_WriteLE16,
	ReadBE16 = CLIB.SDL_ReadBE16,
	JoystickNumBalls = CLIB.SDL_JoystickNumBalls,
	SetSurfaceAlphaMod = CLIB.SDL_SetSurfaceAlphaMod,
	utf8strlcpy = CLIB.SDL_utf8strlcpy,
	GetDisplayMode = CLIB.SDL_GetDisplayMode,
	HasIntersection = CLIB.SDL_HasIntersection,
	BuildAudioCVT = CLIB.SDL_BuildAudioCVT,
	AllocFormat = CLIB.SDL_AllocFormat,
	TLSCreate = CLIB.SDL_TLSCreate,
	ConvertPixels = CLIB.SDL_ConvertPixels,
	CreateMutex = CLIB.SDL_CreateMutex,
	SetWindowBrightness = CLIB.SDL_SetWindowBrightness,
	RenderGetViewport = CLIB.SDL_RenderGetViewport,
	strncasecmp = CLIB.SDL_strncasecmp,
	IsGameController = CLIB.SDL_IsGameController,
	ltoa = CLIB.SDL_ltoa,
	GL_SwapWindow = CLIB.SDL_GL_SwapWindow,
	GameControllerGetJoystick = CLIB.SDL_GameControllerGetJoystick,
	atan = CLIB.SDL_atan,
	SetClipRect = CLIB.SDL_SetClipRect,
	sqrtf = CLIB.SDL_sqrtf,
	GetPerformanceFrequency = CLIB.SDL_GetPerformanceFrequency,
	FreeRW = CLIB.SDL_FreeRW,
	SetThreadPriority = CLIB.SDL_SetThreadPriority,
	RWFromFile = CLIB.SDL_RWFromFile,
	IntersectRect = CLIB.SDL_IntersectRect,
	GetRGB = CLIB.SDL_GetRGB,
	GetDisplayName = CLIB.SDL_GetDisplayName,
	RaiseWindow = CLIB.SDL_RaiseWindow,
	toupper = CLIB.SDL_toupper,
	atoi = CLIB.SDL_atoi,
	GL_GetProcAddress = CLIB.SDL_GL_GetProcAddress,
	GameControllerGetAttached = CLIB.SDL_GameControllerGetAttached,
	snprintf = CLIB.SDL_snprintf,
	tanf = CLIB.SDL_tanf,
	UnlockSurface = CLIB.SDL_UnlockSurface,
	HasSSE3 = CLIB.SDL_HasSSE3,
	GetMouseFocus = CLIB.SDL_GetMouseFocus,
	HasSSE41 = CLIB.SDL_HasSSE41,
	HasSSE42 = CLIB.SDL_HasSSE42,
	GameControllerMappingForGUID = CLIB.SDL_GameControllerMappingForGUID,
	GetNumVideoDisplays = CLIB.SDL_GetNumVideoDisplays,
	CreateSemaphore = CLIB.SDL_CreateSemaphore,
	getenv = CLIB.SDL_getenv,
	HapticOpened = CLIB.SDL_HapticOpened,
	GetPixelFormatName = CLIB.SDL_GetPixelFormatName,
	GetTouchDevice = CLIB.SDL_GetTouchDevice,
	SetSurfaceColorMod = CLIB.SDL_SetSurfaceColorMod,
	tan = CLIB.SDL_tan,
	UpperBlitScaled = CLIB.SDL_UpperBlitScaled,
	malloc = CLIB.SDL_malloc,
	GetCurrentVideoDriver = CLIB.SDL_GetCurrentVideoDriver,
	HasAVX2 = CLIB.SDL_HasAVX2,
	GetDisplayUsableBounds = CLIB.SDL_GetDisplayUsableBounds,
	GetAssertionReport = CLIB.SDL_GetAssertionReport,
	QueueAudio = CLIB.SDL_QueueAudio,
	SetWindowGammaRamp = CLIB.SDL_SetWindowGammaRamp,
	GetWindowDisplayMode = CLIB.SDL_GetWindowDisplayMode,
	HasMMX = CLIB.SDL_HasMMX,
	ReportAssertion = CLIB.SDL_ReportAssertion,
	JoystickNameForIndex = CLIB.SDL_JoystickNameForIndex,
	CreateWindowFrom = CLIB.SDL_CreateWindowFrom,
	strlcat = CLIB.SDL_strlcat,
	GetError = CLIB.SDL_GetError,
	GetWindowGammaRamp = CLIB.SDL_GetWindowGammaRamp,
	SetWindowTitle = CLIB.SDL_SetWindowTitle,
	CreateSoftwareRenderer = CLIB.SDL_CreateSoftwareRenderer,
	strstr = CLIB.SDL_strstr,
	LoadBMP_RW = CLIB.SDL_LoadBMP_RW,
	GetWindowData = CLIB.SDL_GetWindowData,
	SetWindowPosition = CLIB.SDL_SetWindowPosition,
	SetMainReady = CLIB.SDL_SetMainReady,
	GetWindowPosition = CLIB.SDL_GetWindowPosition,
	GetNumTouchFingers = CLIB.SDL_GetNumTouchFingers,
	SetWindowSize = CLIB.SDL_SetWindowSize,
	HasScreenKeyboardSupport = CLIB.SDL_HasScreenKeyboardSupport,
	HasEvents = CLIB.SDL_HasEvents,
	SetWindowMinimumSize = CLIB.SDL_SetWindowMinimumSize,
	HapticOpenFromJoystick = CLIB.SDL_HapticOpenFromJoystick,
	GL_UnbindTexture = CLIB.SDL_GL_UnbindTexture,
	Log = CLIB.SDL_Log,
	EnclosePoints = CLIB.SDL_EnclosePoints,
	LogVerbose = CLIB.SDL_LogVerbose,
	CondWaitTimeout = CLIB.SDL_CondWaitTimeout,
	ReadLE64 = CLIB.SDL_ReadLE64,
	MapRGBA = CLIB.SDL_MapRGBA,
	SetWindowGrab = CLIB.SDL_SetWindowGrab,
	GetWindowGrab = CLIB.SDL_GetWindowGrab,
	GetWindowFromID = CLIB.SDL_GetWindowFromID,
	CondSignal = CLIB.SDL_CondSignal,
	free = CLIB.SDL_free,
	GL_DeleteContext = CLIB.SDL_GL_DeleteContext,
	GetDesktopDisplayMode = CLIB.SDL_GetDesktopDisplayMode,
	strlcpy = CLIB.SDL_strlcpy,
	GetScancodeName = CLIB.SDL_GetScancodeName,
	EnableScreenSaver = CLIB.SDL_EnableScreenSaver,
	GetGlobalMouseState = CLIB.SDL_GetGlobalMouseState,
	CreateCond = CLIB.SDL_CreateCond,
	DestroyMutex = CLIB.SDL_DestroyMutex,
	RenderSetViewport = CLIB.SDL_RenderSetViewport,
	JoystickNumButtons = CLIB.SDL_JoystickNumButtons,
	LockSurface = CLIB.SDL_LockSurface,
	HapticIndex = CLIB.SDL_HapticIndex,
	AtomicTryLock = CLIB.SDL_AtomicTryLock,
	GL_ExtensionSupported = CLIB.SDL_GL_ExtensionSupported,
}
library.e = {
	TEXTUREACCESS_STATIC = ffi.cast("enum SDL_TextureAccess", "SDL_TEXTUREACCESS_STATIC"),
	TEXTUREACCESS_STREAMING = ffi.cast("enum SDL_TextureAccess", "SDL_TEXTUREACCESS_STREAMING"),
	TEXTUREACCESS_TARGET = ffi.cast("enum SDL_TextureAccess", "SDL_TEXTUREACCESS_TARGET"),
	BLENDMODE_NONE = ffi.cast("enum SDL_BlendMode", "SDL_BLENDMODE_NONE"),
	BLENDMODE_BLEND = ffi.cast("enum SDL_BlendMode", "SDL_BLENDMODE_BLEND"),
	BLENDMODE_ADD = ffi.cast("enum SDL_BlendMode", "SDL_BLENDMODE_ADD"),
	BLENDMODE_MOD = ffi.cast("enum SDL_BlendMode", "SDL_BLENDMODE_MOD"),
	WINDOWEVENT_NONE = ffi.cast("enum SDL_WindowEventID", "SDL_WINDOWEVENT_NONE"),
	WINDOWEVENT_SHOWN = ffi.cast("enum SDL_WindowEventID", "SDL_WINDOWEVENT_SHOWN"),
	WINDOWEVENT_HIDDEN = ffi.cast("enum SDL_WindowEventID", "SDL_WINDOWEVENT_HIDDEN"),
	WINDOWEVENT_EXPOSED = ffi.cast("enum SDL_WindowEventID", "SDL_WINDOWEVENT_EXPOSED"),
	WINDOWEVENT_MOVED = ffi.cast("enum SDL_WindowEventID", "SDL_WINDOWEVENT_MOVED"),
	WINDOWEVENT_RESIZED = ffi.cast("enum SDL_WindowEventID", "SDL_WINDOWEVENT_RESIZED"),
	WINDOWEVENT_SIZE_CHANGED = ffi.cast("enum SDL_WindowEventID", "SDL_WINDOWEVENT_SIZE_CHANGED"),
	WINDOWEVENT_MINIMIZED = ffi.cast("enum SDL_WindowEventID", "SDL_WINDOWEVENT_MINIMIZED"),
	WINDOWEVENT_MAXIMIZED = ffi.cast("enum SDL_WindowEventID", "SDL_WINDOWEVENT_MAXIMIZED"),
	WINDOWEVENT_RESTORED = ffi.cast("enum SDL_WindowEventID", "SDL_WINDOWEVENT_RESTORED"),
	WINDOWEVENT_ENTER = ffi.cast("enum SDL_WindowEventID", "SDL_WINDOWEVENT_ENTER"),
	WINDOWEVENT_LEAVE = ffi.cast("enum SDL_WindowEventID", "SDL_WINDOWEVENT_LEAVE"),
	WINDOWEVENT_FOCUS_GAINED = ffi.cast("enum SDL_WindowEventID", "SDL_WINDOWEVENT_FOCUS_GAINED"),
	WINDOWEVENT_FOCUS_LOST = ffi.cast("enum SDL_WindowEventID", "SDL_WINDOWEVENT_FOCUS_LOST"),
	WINDOWEVENT_CLOSE = ffi.cast("enum SDL_WindowEventID", "SDL_WINDOWEVENT_CLOSE"),
	WINDOWEVENT_TAKE_FOCUS = ffi.cast("enum SDL_WindowEventID", "SDL_WINDOWEVENT_TAKE_FOCUS"),
	WINDOWEVENT_HIT_TEST = ffi.cast("enum SDL_WindowEventID", "SDL_WINDOWEVENT_HIT_TEST"),
	FALSE = ffi.cast("enum SDL_bool", "SDL_FALSE"),
	TRUE = ffi.cast("enum SDL_bool", "SDL_TRUE"),
	POWERSTATE_UNKNOWN = ffi.cast("enum SDL_PowerState", "SDL_POWERSTATE_UNKNOWN"),
	POWERSTATE_ON_BATTERY = ffi.cast("enum SDL_PowerState", "SDL_POWERSTATE_ON_BATTERY"),
	POWERSTATE_NO_BATTERY = ffi.cast("enum SDL_PowerState", "SDL_POWERSTATE_NO_BATTERY"),
	POWERSTATE_CHARGING = ffi.cast("enum SDL_PowerState", "SDL_POWERSTATE_CHARGING"),
	POWERSTATE_CHARGED = ffi.cast("enum SDL_PowerState", "SDL_POWERSTATE_CHARGED"),
	ADDEVENT = ffi.cast("enum SDL_eventaction", "SDL_ADDEVENT"),
	PEEKEVENT = ffi.cast("enum SDL_eventaction", "SDL_PEEKEVENT"),
	GETEVENT = ffi.cast("enum SDL_eventaction", "SDL_GETEVENT"),
	GL_CONTEXT_RELEASE_BEHAVIOR_NONE = ffi.cast("enum SDL_GLcontextReleaseFlag", "SDL_GL_CONTEXT_RELEASE_BEHAVIOR_NONE"),
	GL_CONTEXT_RELEASE_BEHAVIOR_FLUSH = ffi.cast("enum SDL_GLcontextReleaseFlag", "SDL_GL_CONTEXT_RELEASE_BEHAVIOR_FLUSH"),
	CONTROLLER_AXIS_INVALID = ffi.cast("enum SDL_GameControllerAxis", "SDL_CONTROLLER_AXIS_INVALID"),
	CONTROLLER_AXIS_LEFTX = ffi.cast("enum SDL_GameControllerAxis", "SDL_CONTROLLER_AXIS_LEFTX"),
	CONTROLLER_AXIS_LEFTY = ffi.cast("enum SDL_GameControllerAxis", "SDL_CONTROLLER_AXIS_LEFTY"),
	CONTROLLER_AXIS_RIGHTX = ffi.cast("enum SDL_GameControllerAxis", "SDL_CONTROLLER_AXIS_RIGHTX"),
	CONTROLLER_AXIS_RIGHTY = ffi.cast("enum SDL_GameControllerAxis", "SDL_CONTROLLER_AXIS_RIGHTY"),
	CONTROLLER_AXIS_TRIGGERLEFT = ffi.cast("enum SDL_GameControllerAxis", "SDL_CONTROLLER_AXIS_TRIGGERLEFT"),
	CONTROLLER_AXIS_TRIGGERRIGHT = ffi.cast("enum SDL_GameControllerAxis", "SDL_CONTROLLER_AXIS_TRIGGERRIGHT"),
	CONTROLLER_AXIS_MAX = ffi.cast("enum SDL_GameControllerAxis", "SDL_CONTROLLER_AXIS_MAX"),
	LOG_PRIORITY_VERBOSE = ffi.cast("enum SDL_LogPriority", "SDL_LOG_PRIORITY_VERBOSE"),
	LOG_PRIORITY_DEBUG = ffi.cast("enum SDL_LogPriority", "SDL_LOG_PRIORITY_DEBUG"),
	LOG_PRIORITY_INFO = ffi.cast("enum SDL_LogPriority", "SDL_LOG_PRIORITY_INFO"),
	LOG_PRIORITY_WARN = ffi.cast("enum SDL_LogPriority", "SDL_LOG_PRIORITY_WARN"),
	LOG_PRIORITY_ERROR = ffi.cast("enum SDL_LogPriority", "SDL_LOG_PRIORITY_ERROR"),
	LOG_PRIORITY_CRITICAL = ffi.cast("enum SDL_LogPriority", "SDL_LOG_PRIORITY_CRITICAL"),
	NUM_LOG_PRIORITIES = ffi.cast("enum SDL_LogPriority", "SDL_NUM_LOG_PRIORITIES"),
	MOUSEWHEEL_NORMAL = ffi.cast("enum SDL_MouseWheelDirection", "SDL_MOUSEWHEEL_NORMAL"),
	MOUSEWHEEL_FLIPPED = ffi.cast("enum SDL_MouseWheelDirection", "SDL_MOUSEWHEEL_FLIPPED"),
	GL_CONTEXT_PROFILE_CORE = ffi.cast("enum SDL_GLprofile", "SDL_GL_CONTEXT_PROFILE_CORE"),
	GL_CONTEXT_PROFILE_COMPATIBILITY = ffi.cast("enum SDL_GLprofile", "SDL_GL_CONTEXT_PROFILE_COMPATIBILITY"),
	GL_CONTEXT_PROFILE_ES = ffi.cast("enum SDL_GLprofile", "SDL_GL_CONTEXT_PROFILE_ES"),
	ENOMEM = ffi.cast("enum SDL_errorcode", "SDL_ENOMEM"),
	EFREAD = ffi.cast("enum SDL_errorcode", "SDL_EFREAD"),
	EFWRITE = ffi.cast("enum SDL_errorcode", "SDL_EFWRITE"),
	EFSEEK = ffi.cast("enum SDL_errorcode", "SDL_EFSEEK"),
	UNSUPPORTED = ffi.cast("enum SDL_errorcode", "SDL_UNSUPPORTED"),
	LASTERROR = ffi.cast("enum SDL_errorcode", "SDL_LASTERROR"),
	MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT = ffi.cast("enum SDL_MessageBoxButtonFlags", "SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT"),
	MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT = ffi.cast("enum SDL_MessageBoxButtonFlags", "SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT"),
	FLIP_NONE = ffi.cast("enum SDL_RendererFlip", "SDL_FLIP_NONE"),
	FLIP_HORIZONTAL = ffi.cast("enum SDL_RendererFlip", "SDL_FLIP_HORIZONTAL"),
	FLIP_VERTICAL = ffi.cast("enum SDL_RendererFlip", "SDL_FLIP_VERTICAL"),
	THREAD_PRIORITY_LOW = ffi.cast("enum SDL_ThreadPriority", "SDL_THREAD_PRIORITY_LOW"),
	THREAD_PRIORITY_NORMAL = ffi.cast("enum SDL_ThreadPriority", "SDL_THREAD_PRIORITY_NORMAL"),
	THREAD_PRIORITY_HIGH = ffi.cast("enum SDL_ThreadPriority", "SDL_THREAD_PRIORITY_HIGH"),
	INIT_TIMER = ffi.cast("enum SDL_grrrrrr", "SDL_INIT_TIMER"),
	INIT_AUDIO = ffi.cast("enum SDL_grrrrrr", "SDL_INIT_AUDIO"),
	INIT_VIDEO = ffi.cast("enum SDL_grrrrrr", "SDL_INIT_VIDEO"),
	INIT_JOYSTICK = ffi.cast("enum SDL_grrrrrr", "SDL_INIT_JOYSTICK"),
	INIT_HAPTIC = ffi.cast("enum SDL_grrrrrr", "SDL_INIT_HAPTIC"),
	INIT_GAMECONTROLLER = ffi.cast("enum SDL_grrrrrr", "SDL_INIT_GAMECONTROLLER"),
	INIT_EVENTS = ffi.cast("enum SDL_grrrrrr", "SDL_INIT_EVENTS"),
	INIT_NOPARACHUTE = ffi.cast("enum SDL_grrrrrr", "SDL_INIT_NOPARACHUTE"),
	INIT_EVERYTHING = ffi.cast("enum SDL_grrrrrr", "SDL_INIT_EVERYTHING"),
	WINDOWPOS_UNDEFINED_MASK = ffi.cast("enum SDL_grrrrrr", "SDL_WINDOWPOS_UNDEFINED_MASK"),
	WINDOWPOS_UNDEFINED_DISPLAY = ffi.cast("enum SDL_grrrrrr", "SDL_WINDOWPOS_UNDEFINED_DISPLAY"),
	WINDOWPOS_UNDEFINED = ffi.cast("enum SDL_grrrrrr", "SDL_WINDOWPOS_UNDEFINED"),
	WINDOWPOS_CENTERED_MASK = ffi.cast("enum SDL_grrrrrr", "SDL_WINDOWPOS_CENTERED_MASK"),
	WINDOWPOS_CENTERED = ffi.cast("enum SDL_grrrrrr", "SDL_WINDOWPOS_CENTERED"),
	HINT_DEFAULT = ffi.cast("enum SDL_HintPriority", "SDL_HINT_DEFAULT"),
	HINT_NORMAL = ffi.cast("enum SDL_HintPriority", "SDL_HINT_NORMAL"),
	HINT_OVERRIDE = ffi.cast("enum SDL_HintPriority", "SDL_HINT_OVERRIDE"),
	SYSWM_UNKNOWN = ffi.cast("enum SDL_SYSWM_TYPE", "SDL_SYSWM_UNKNOWN"),
	SYSWM_WINDOWS = ffi.cast("enum SDL_SYSWM_TYPE", "SDL_SYSWM_WINDOWS"),
	SYSWM_X11 = ffi.cast("enum SDL_SYSWM_TYPE", "SDL_SYSWM_X11"),
	SYSWM_DIRECTFB = ffi.cast("enum SDL_SYSWM_TYPE", "SDL_SYSWM_DIRECTFB"),
	SYSWM_COCOA = ffi.cast("enum SDL_SYSWM_TYPE", "SDL_SYSWM_COCOA"),
	SYSWM_UIKIT = ffi.cast("enum SDL_SYSWM_TYPE", "SDL_SYSWM_UIKIT"),
	SYSWM_WAYLAND = ffi.cast("enum SDL_SYSWM_TYPE", "SDL_SYSWM_WAYLAND"),
	SYSWM_MIR = ffi.cast("enum SDL_SYSWM_TYPE", "SDL_SYSWM_MIR"),
	SYSWM_WINRT = ffi.cast("enum SDL_SYSWM_TYPE", "SDL_SYSWM_WINRT"),
	SYSWM_ANDROID = ffi.cast("enum SDL_SYSWM_TYPE", "SDL_SYSWM_ANDROID"),
	SYSWM_VIVANTE = ffi.cast("enum SDL_SYSWM_TYPE", "SDL_SYSWM_VIVANTE"),
	TEXTUREMODULATE_NONE = ffi.cast("enum SDL_TextureModulate", "SDL_TEXTUREMODULATE_NONE"),
	TEXTUREMODULATE_COLOR = ffi.cast("enum SDL_TextureModulate", "SDL_TEXTUREMODULATE_COLOR"),
	TEXTUREMODULATE_ALPHA = ffi.cast("enum SDL_TextureModulate", "SDL_TEXTUREMODULATE_ALPHA"),
	RENDERER_SOFTWARE = ffi.cast("enum SDL_RendererFlags", "SDL_RENDERER_SOFTWARE"),
	RENDERER_ACCELERATED = ffi.cast("enum SDL_RendererFlags", "SDL_RENDERER_ACCELERATED"),
	RENDERER_PRESENTVSYNC = ffi.cast("enum SDL_RendererFlags", "SDL_RENDERER_PRESENTVSYNC"),
	RENDERER_TARGETTEXTURE = ffi.cast("enum SDL_RendererFlags", "SDL_RENDERER_TARGETTEXTURE"),
	MESSAGEBOX_COLOR_BACKGROUND = ffi.cast("enum SDL_MessageBoxColorType", "SDL_MESSAGEBOX_COLOR_BACKGROUND"),
	MESSAGEBOX_COLOR_TEXT = ffi.cast("enum SDL_MessageBoxColorType", "SDL_MESSAGEBOX_COLOR_TEXT"),
	MESSAGEBOX_COLOR_BUTTON_BORDER = ffi.cast("enum SDL_MessageBoxColorType", "SDL_MESSAGEBOX_COLOR_BUTTON_BORDER"),
	MESSAGEBOX_COLOR_BUTTON_BACKGROUND = ffi.cast("enum SDL_MessageBoxColorType", "SDL_MESSAGEBOX_COLOR_BUTTON_BACKGROUND"),
	MESSAGEBOX_COLOR_BUTTON_SELECTED = ffi.cast("enum SDL_MessageBoxColorType", "SDL_MESSAGEBOX_COLOR_BUTTON_SELECTED"),
	MESSAGEBOX_COLOR_MAX = ffi.cast("enum SDL_MessageBoxColorType", "SDL_MESSAGEBOX_COLOR_MAX"),
	GL_CONTEXT_DEBUG_FLAG = ffi.cast("enum SDL_GLcontextFlag", "SDL_GL_CONTEXT_DEBUG_FLAG"),
	GL_CONTEXT_FORWARD_COMPATIBLE_FLAG = ffi.cast("enum SDL_GLcontextFlag", "SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG"),
	GL_CONTEXT_ROBUST_ACCESS_FLAG = ffi.cast("enum SDL_GLcontextFlag", "SDL_GL_CONTEXT_ROBUST_ACCESS_FLAG"),
	GL_CONTEXT_RESET_ISOLATION_FLAG = ffi.cast("enum SDL_GLcontextFlag", "SDL_GL_CONTEXT_RESET_ISOLATION_FLAG"),
	SCANCODE_UNKNOWN = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_UNKNOWN"),
	SCANCODE_A = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_A"),
	SCANCODE_B = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_B"),
	SCANCODE_C = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_C"),
	SCANCODE_D = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_D"),
	SCANCODE_E = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_E"),
	SCANCODE_F = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F"),
	SCANCODE_G = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_G"),
	SCANCODE_H = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_H"),
	SCANCODE_I = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_I"),
	SCANCODE_J = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_J"),
	SCANCODE_K = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_K"),
	SCANCODE_L = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_L"),
	SCANCODE_M = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_M"),
	SCANCODE_N = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_N"),
	SCANCODE_O = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_O"),
	SCANCODE_P = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_P"),
	SCANCODE_Q = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_Q"),
	SCANCODE_R = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_R"),
	SCANCODE_S = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_S"),
	SCANCODE_T = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_T"),
	SCANCODE_U = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_U"),
	SCANCODE_V = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_V"),
	SCANCODE_W = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_W"),
	SCANCODE_X = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_X"),
	SCANCODE_Y = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_Y"),
	SCANCODE_Z = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_Z"),
	SCANCODE_1 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_1"),
	SCANCODE_2 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_2"),
	SCANCODE_3 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_3"),
	SCANCODE_4 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_4"),
	SCANCODE_5 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_5"),
	SCANCODE_6 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_6"),
	SCANCODE_7 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_7"),
	SCANCODE_8 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_8"),
	SCANCODE_9 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_9"),
	SCANCODE_0 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_0"),
	SCANCODE_RETURN = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_RETURN"),
	SCANCODE_ESCAPE = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_ESCAPE"),
	SCANCODE_BACKSPACE = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_BACKSPACE"),
	SCANCODE_TAB = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_TAB"),
	SCANCODE_SPACE = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_SPACE"),
	SCANCODE_MINUS = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_MINUS"),
	SCANCODE_EQUALS = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_EQUALS"),
	SCANCODE_LEFTBRACKET = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_LEFTBRACKET"),
	SCANCODE_RIGHTBRACKET = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_RIGHTBRACKET"),
	SCANCODE_BACKSLASH = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_BACKSLASH"),
	SCANCODE_NONUSHASH = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_NONUSHASH"),
	SCANCODE_SEMICOLON = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_SEMICOLON"),
	SCANCODE_APOSTROPHE = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_APOSTROPHE"),
	SCANCODE_GRAVE = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_GRAVE"),
	SCANCODE_COMMA = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_COMMA"),
	SCANCODE_PERIOD = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_PERIOD"),
	SCANCODE_SLASH = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_SLASH"),
	SCANCODE_CAPSLOCK = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_CAPSLOCK"),
	SCANCODE_F1 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F1"),
	SCANCODE_F2 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F2"),
	SCANCODE_F3 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F3"),
	SCANCODE_F4 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F4"),
	SCANCODE_F5 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F5"),
	SCANCODE_F6 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F6"),
	SCANCODE_F7 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F7"),
	SCANCODE_F8 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F8"),
	SCANCODE_F9 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F9"),
	SCANCODE_F10 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F10"),
	SCANCODE_F11 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F11"),
	SCANCODE_F12 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F12"),
	SCANCODE_PRINTSCREEN = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_PRINTSCREEN"),
	SCANCODE_SCROLLLOCK = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_SCROLLLOCK"),
	SCANCODE_PAUSE = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_PAUSE"),
	SCANCODE_INSERT = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_INSERT"),
	SCANCODE_HOME = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_HOME"),
	SCANCODE_PAGEUP = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_PAGEUP"),
	SCANCODE_DELETE = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_DELETE"),
	SCANCODE_END = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_END"),
	SCANCODE_PAGEDOWN = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_PAGEDOWN"),
	SCANCODE_RIGHT = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_RIGHT"),
	SCANCODE_LEFT = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_LEFT"),
	SCANCODE_DOWN = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_DOWN"),
	SCANCODE_UP = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_UP"),
	SCANCODE_NUMLOCKCLEAR = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_NUMLOCKCLEAR"),
	SCANCODE_KP_DIVIDE = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_DIVIDE"),
	SCANCODE_KP_MULTIPLY = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_MULTIPLY"),
	SCANCODE_KP_MINUS = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_MINUS"),
	SCANCODE_KP_PLUS = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_PLUS"),
	SCANCODE_KP_ENTER = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_ENTER"),
	SCANCODE_KP_1 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_1"),
	SCANCODE_KP_2 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_2"),
	SCANCODE_KP_3 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_3"),
	SCANCODE_KP_4 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_4"),
	SCANCODE_KP_5 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_5"),
	SCANCODE_KP_6 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_6"),
	SCANCODE_KP_7 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_7"),
	SCANCODE_KP_8 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_8"),
	SCANCODE_KP_9 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_9"),
	SCANCODE_KP_0 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_0"),
	SCANCODE_KP_PERIOD = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_PERIOD"),
	SCANCODE_NONUSBACKSLASH = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_NONUSBACKSLASH"),
	SCANCODE_APPLICATION = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_APPLICATION"),
	SCANCODE_POWER = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_POWER"),
	SCANCODE_KP_EQUALS = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_EQUALS"),
	SCANCODE_F13 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F13"),
	SCANCODE_F14 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F14"),
	SCANCODE_F15 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F15"),
	SCANCODE_F16 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F16"),
	SCANCODE_F17 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F17"),
	SCANCODE_F18 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F18"),
	SCANCODE_F19 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F19"),
	SCANCODE_F20 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F20"),
	SCANCODE_F21 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F21"),
	SCANCODE_F22 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F22"),
	SCANCODE_F23 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F23"),
	SCANCODE_F24 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_F24"),
	SCANCODE_EXECUTE = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_EXECUTE"),
	SCANCODE_HELP = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_HELP"),
	SCANCODE_MENU = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_MENU"),
	SCANCODE_SELECT = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_SELECT"),
	SCANCODE_STOP = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_STOP"),
	SCANCODE_AGAIN = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_AGAIN"),
	SCANCODE_UNDO = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_UNDO"),
	SCANCODE_CUT = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_CUT"),
	SCANCODE_COPY = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_COPY"),
	SCANCODE_PASTE = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_PASTE"),
	SCANCODE_FIND = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_FIND"),
	SCANCODE_MUTE = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_MUTE"),
	SCANCODE_VOLUMEUP = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_VOLUMEUP"),
	SCANCODE_VOLUMEDOWN = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_VOLUMEDOWN"),
	SCANCODE_KP_COMMA = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_COMMA"),
	SCANCODE_KP_EQUALSAS400 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_EQUALSAS400"),
	SCANCODE_INTERNATIONAL1 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_INTERNATIONAL1"),
	SCANCODE_INTERNATIONAL2 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_INTERNATIONAL2"),
	SCANCODE_INTERNATIONAL3 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_INTERNATIONAL3"),
	SCANCODE_INTERNATIONAL4 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_INTERNATIONAL4"),
	SCANCODE_INTERNATIONAL5 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_INTERNATIONAL5"),
	SCANCODE_INTERNATIONAL6 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_INTERNATIONAL6"),
	SCANCODE_INTERNATIONAL7 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_INTERNATIONAL7"),
	SCANCODE_INTERNATIONAL8 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_INTERNATIONAL8"),
	SCANCODE_INTERNATIONAL9 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_INTERNATIONAL9"),
	SCANCODE_LANG1 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_LANG1"),
	SCANCODE_LANG2 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_LANG2"),
	SCANCODE_LANG3 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_LANG3"),
	SCANCODE_LANG4 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_LANG4"),
	SCANCODE_LANG5 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_LANG5"),
	SCANCODE_LANG6 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_LANG6"),
	SCANCODE_LANG7 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_LANG7"),
	SCANCODE_LANG8 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_LANG8"),
	SCANCODE_LANG9 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_LANG9"),
	SCANCODE_ALTERASE = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_ALTERASE"),
	SCANCODE_SYSREQ = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_SYSREQ"),
	SCANCODE_CANCEL = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_CANCEL"),
	SCANCODE_CLEAR = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_CLEAR"),
	SCANCODE_PRIOR = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_PRIOR"),
	SCANCODE_RETURN2 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_RETURN2"),
	SCANCODE_SEPARATOR = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_SEPARATOR"),
	SCANCODE_OUT = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_OUT"),
	SCANCODE_OPER = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_OPER"),
	SCANCODE_CLEARAGAIN = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_CLEARAGAIN"),
	SCANCODE_CRSEL = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_CRSEL"),
	SCANCODE_EXSEL = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_EXSEL"),
	SCANCODE_KP_00 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_00"),
	SCANCODE_KP_000 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_000"),
	SCANCODE_THOUSANDSSEPARATOR = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_THOUSANDSSEPARATOR"),
	SCANCODE_DECIMALSEPARATOR = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_DECIMALSEPARATOR"),
	SCANCODE_CURRENCYUNIT = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_CURRENCYUNIT"),
	SCANCODE_CURRENCYSUBUNIT = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_CURRENCYSUBUNIT"),
	SCANCODE_KP_LEFTPAREN = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_LEFTPAREN"),
	SCANCODE_KP_RIGHTPAREN = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_RIGHTPAREN"),
	SCANCODE_KP_LEFTBRACE = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_LEFTBRACE"),
	SCANCODE_KP_RIGHTBRACE = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_RIGHTBRACE"),
	SCANCODE_KP_TAB = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_TAB"),
	SCANCODE_KP_BACKSPACE = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_BACKSPACE"),
	SCANCODE_KP_A = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_A"),
	SCANCODE_KP_B = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_B"),
	SCANCODE_KP_C = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_C"),
	SCANCODE_KP_D = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_D"),
	SCANCODE_KP_E = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_E"),
	SCANCODE_KP_F = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_F"),
	SCANCODE_KP_XOR = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_XOR"),
	SCANCODE_KP_POWER = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_POWER"),
	SCANCODE_KP_PERCENT = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_PERCENT"),
	SCANCODE_KP_LESS = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_LESS"),
	SCANCODE_KP_GREATER = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_GREATER"),
	SCANCODE_KP_AMPERSAND = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_AMPERSAND"),
	SCANCODE_KP_DBLAMPERSAND = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_DBLAMPERSAND"),
	SCANCODE_KP_VERTICALBAR = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_VERTICALBAR"),
	SCANCODE_KP_DBLVERTICALBAR = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_DBLVERTICALBAR"),
	SCANCODE_KP_COLON = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_COLON"),
	SCANCODE_KP_HASH = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_HASH"),
	SCANCODE_KP_SPACE = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_SPACE"),
	SCANCODE_KP_AT = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_AT"),
	SCANCODE_KP_EXCLAM = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_EXCLAM"),
	SCANCODE_KP_MEMSTORE = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_MEMSTORE"),
	SCANCODE_KP_MEMRECALL = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_MEMRECALL"),
	SCANCODE_KP_MEMCLEAR = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_MEMCLEAR"),
	SCANCODE_KP_MEMADD = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_MEMADD"),
	SCANCODE_KP_MEMSUBTRACT = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_MEMSUBTRACT"),
	SCANCODE_KP_MEMMULTIPLY = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_MEMMULTIPLY"),
	SCANCODE_KP_MEMDIVIDE = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_MEMDIVIDE"),
	SCANCODE_KP_PLUSMINUS = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_PLUSMINUS"),
	SCANCODE_KP_CLEAR = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_CLEAR"),
	SCANCODE_KP_CLEARENTRY = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_CLEARENTRY"),
	SCANCODE_KP_BINARY = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_BINARY"),
	SCANCODE_KP_OCTAL = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_OCTAL"),
	SCANCODE_KP_DECIMAL = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_DECIMAL"),
	SCANCODE_KP_HEXADECIMAL = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KP_HEXADECIMAL"),
	SCANCODE_LCTRL = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_LCTRL"),
	SCANCODE_LSHIFT = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_LSHIFT"),
	SCANCODE_LALT = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_LALT"),
	SCANCODE_LGUI = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_LGUI"),
	SCANCODE_RCTRL = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_RCTRL"),
	SCANCODE_RSHIFT = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_RSHIFT"),
	SCANCODE_RALT = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_RALT"),
	SCANCODE_RGUI = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_RGUI"),
	SCANCODE_MODE = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_MODE"),
	SCANCODE_AUDIONEXT = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_AUDIONEXT"),
	SCANCODE_AUDIOPREV = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_AUDIOPREV"),
	SCANCODE_AUDIOSTOP = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_AUDIOSTOP"),
	SCANCODE_AUDIOPLAY = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_AUDIOPLAY"),
	SCANCODE_AUDIOMUTE = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_AUDIOMUTE"),
	SCANCODE_MEDIASELECT = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_MEDIASELECT"),
	SCANCODE_WWW = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_WWW"),
	SCANCODE_MAIL = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_MAIL"),
	SCANCODE_CALCULATOR = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_CALCULATOR"),
	SCANCODE_COMPUTER = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_COMPUTER"),
	SCANCODE_AC_SEARCH = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_AC_SEARCH"),
	SCANCODE_AC_HOME = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_AC_HOME"),
	SCANCODE_AC_BACK = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_AC_BACK"),
	SCANCODE_AC_FORWARD = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_AC_FORWARD"),
	SCANCODE_AC_STOP = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_AC_STOP"),
	SCANCODE_AC_REFRESH = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_AC_REFRESH"),
	SCANCODE_AC_BOOKMARKS = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_AC_BOOKMARKS"),
	SCANCODE_BRIGHTNESSDOWN = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_BRIGHTNESSDOWN"),
	SCANCODE_BRIGHTNESSUP = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_BRIGHTNESSUP"),
	SCANCODE_DISPLAYSWITCH = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_DISPLAYSWITCH"),
	SCANCODE_KBDILLUMTOGGLE = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KBDILLUMTOGGLE"),
	SCANCODE_KBDILLUMDOWN = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KBDILLUMDOWN"),
	SCANCODE_KBDILLUMUP = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_KBDILLUMUP"),
	SCANCODE_EJECT = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_EJECT"),
	SCANCODE_SLEEP = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_SLEEP"),
	SCANCODE_APP1 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_APP1"),
	SCANCODE_APP2 = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_APP2"),
	NUM_SCANCODES = ffi.cast("enum SDL_Scancode", "SDL_NUM_SCANCODES"),
	CONTROLLER_BINDTYPE_NONE = ffi.cast("enum SDL_GameControllerBindType", "SDL_CONTROLLER_BINDTYPE_NONE"),
	CONTROLLER_BINDTYPE_BUTTON = ffi.cast("enum SDL_GameControllerBindType", "SDL_CONTROLLER_BINDTYPE_BUTTON"),
	CONTROLLER_BINDTYPE_AXIS = ffi.cast("enum SDL_GameControllerBindType", "SDL_CONTROLLER_BINDTYPE_AXIS"),
	CONTROLLER_BINDTYPE_HAT = ffi.cast("enum SDL_GameControllerBindType", "SDL_CONTROLLER_BINDTYPE_HAT"),
	FIRSTEVENT = ffi.cast("enum SDL_EventType", "SDL_FIRSTEVENT"),
	QUIT = ffi.cast("enum SDL_EventType", "SDL_QUIT"),
	APP_TERMINATING = ffi.cast("enum SDL_EventType", "SDL_APP_TERMINATING"),
	APP_LOWMEMORY = ffi.cast("enum SDL_EventType", "SDL_APP_LOWMEMORY"),
	APP_WILLENTERBACKGROUND = ffi.cast("enum SDL_EventType", "SDL_APP_WILLENTERBACKGROUND"),
	APP_DIDENTERBACKGROUND = ffi.cast("enum SDL_EventType", "SDL_APP_DIDENTERBACKGROUND"),
	APP_WILLENTERFOREGROUND = ffi.cast("enum SDL_EventType", "SDL_APP_WILLENTERFOREGROUND"),
	APP_DIDENTERFOREGROUND = ffi.cast("enum SDL_EventType", "SDL_APP_DIDENTERFOREGROUND"),
	WINDOWEVENT = ffi.cast("enum SDL_EventType", "SDL_WINDOWEVENT"),
	SYSWMEVENT = ffi.cast("enum SDL_EventType", "SDL_SYSWMEVENT"),
	KEYDOWN = ffi.cast("enum SDL_EventType", "SDL_KEYDOWN"),
	KEYUP = ffi.cast("enum SDL_EventType", "SDL_KEYUP"),
	TEXTEDITING = ffi.cast("enum SDL_EventType", "SDL_TEXTEDITING"),
	TEXTINPUT = ffi.cast("enum SDL_EventType", "SDL_TEXTINPUT"),
	KEYMAPCHANGED = ffi.cast("enum SDL_EventType", "SDL_KEYMAPCHANGED"),
	MOUSEMOTION = ffi.cast("enum SDL_EventType", "SDL_MOUSEMOTION"),
	MOUSEBUTTONDOWN = ffi.cast("enum SDL_EventType", "SDL_MOUSEBUTTONDOWN"),
	MOUSEBUTTONUP = ffi.cast("enum SDL_EventType", "SDL_MOUSEBUTTONUP"),
	MOUSEWHEEL = ffi.cast("enum SDL_EventType", "SDL_MOUSEWHEEL"),
	JOYAXISMOTION = ffi.cast("enum SDL_EventType", "SDL_JOYAXISMOTION"),
	JOYBALLMOTION = ffi.cast("enum SDL_EventType", "SDL_JOYBALLMOTION"),
	JOYHATMOTION = ffi.cast("enum SDL_EventType", "SDL_JOYHATMOTION"),
	JOYBUTTONDOWN = ffi.cast("enum SDL_EventType", "SDL_JOYBUTTONDOWN"),
	JOYBUTTONUP = ffi.cast("enum SDL_EventType", "SDL_JOYBUTTONUP"),
	JOYDEVICEADDED = ffi.cast("enum SDL_EventType", "SDL_JOYDEVICEADDED"),
	JOYDEVICEREMOVED = ffi.cast("enum SDL_EventType", "SDL_JOYDEVICEREMOVED"),
	CONTROLLERAXISMOTION = ffi.cast("enum SDL_EventType", "SDL_CONTROLLERAXISMOTION"),
	CONTROLLERBUTTONDOWN = ffi.cast("enum SDL_EventType", "SDL_CONTROLLERBUTTONDOWN"),
	CONTROLLERBUTTONUP = ffi.cast("enum SDL_EventType", "SDL_CONTROLLERBUTTONUP"),
	CONTROLLERDEVICEADDED = ffi.cast("enum SDL_EventType", "SDL_CONTROLLERDEVICEADDED"),
	CONTROLLERDEVICEREMOVED = ffi.cast("enum SDL_EventType", "SDL_CONTROLLERDEVICEREMOVED"),
	CONTROLLERDEVICEREMAPPED = ffi.cast("enum SDL_EventType", "SDL_CONTROLLERDEVICEREMAPPED"),
	FINGERDOWN = ffi.cast("enum SDL_EventType", "SDL_FINGERDOWN"),
	FINGERUP = ffi.cast("enum SDL_EventType", "SDL_FINGERUP"),
	FINGERMOTION = ffi.cast("enum SDL_EventType", "SDL_FINGERMOTION"),
	DOLLARGESTURE = ffi.cast("enum SDL_EventType", "SDL_DOLLARGESTURE"),
	DOLLARRECORD = ffi.cast("enum SDL_EventType", "SDL_DOLLARRECORD"),
	MULTIGESTURE = ffi.cast("enum SDL_EventType", "SDL_MULTIGESTURE"),
	CLIPBOARDUPDATE = ffi.cast("enum SDL_EventType", "SDL_CLIPBOARDUPDATE"),
	DROPFILE = ffi.cast("enum SDL_EventType", "SDL_DROPFILE"),
	DROPTEXT = ffi.cast("enum SDL_EventType", "SDL_DROPTEXT"),
	DROPBEGIN = ffi.cast("enum SDL_EventType", "SDL_DROPBEGIN"),
	DROPCOMPLETE = ffi.cast("enum SDL_EventType", "SDL_DROPCOMPLETE"),
	AUDIODEVICEADDED = ffi.cast("enum SDL_EventType", "SDL_AUDIODEVICEADDED"),
	AUDIODEVICEREMOVED = ffi.cast("enum SDL_EventType", "SDL_AUDIODEVICEREMOVED"),
	RENDER_TARGETS_RESET = ffi.cast("enum SDL_EventType", "SDL_RENDER_TARGETS_RESET"),
	RENDER_DEVICE_RESET = ffi.cast("enum SDL_EventType", "SDL_RENDER_DEVICE_RESET"),
	USEREVENT = ffi.cast("enum SDL_EventType", "SDL_USEREVENT"),
	LASTEVENT = ffi.cast("enum SDL_EventType", "SDL_LASTEVENT"),
	ASSERTION_RETRY = ffi.cast("enum SDL_AssertState", "SDL_ASSERTION_RETRY"),
	ASSERTION_BREAK = ffi.cast("enum SDL_AssertState", "SDL_ASSERTION_BREAK"),
	ASSERTION_ABORT = ffi.cast("enum SDL_AssertState", "SDL_ASSERTION_ABORT"),
	ASSERTION_IGNORE = ffi.cast("enum SDL_AssertState", "SDL_ASSERTION_IGNORE"),
	ASSERTION_ALWAYS_IGNORE = ffi.cast("enum SDL_AssertState", "SDL_ASSERTION_ALWAYS_IGNORE"),
	AUDIO_STOPPED = ffi.cast("enum SDL_AudioStatus", "SDL_AUDIO_STOPPED"),
	AUDIO_PLAYING = ffi.cast("enum SDL_AudioStatus", "SDL_AUDIO_PLAYING"),
	AUDIO_PAUSED = ffi.cast("enum SDL_AudioStatus", "SDL_AUDIO_PAUSED"),
	SYSTEM_CURSOR_ARROW = ffi.cast("enum SDL_SystemCursor", "SDL_SYSTEM_CURSOR_ARROW"),
	SYSTEM_CURSOR_IBEAM = ffi.cast("enum SDL_SystemCursor", "SDL_SYSTEM_CURSOR_IBEAM"),
	SYSTEM_CURSOR_WAIT = ffi.cast("enum SDL_SystemCursor", "SDL_SYSTEM_CURSOR_WAIT"),
	SYSTEM_CURSOR_CROSSHAIR = ffi.cast("enum SDL_SystemCursor", "SDL_SYSTEM_CURSOR_CROSSHAIR"),
	SYSTEM_CURSOR_WAITARROW = ffi.cast("enum SDL_SystemCursor", "SDL_SYSTEM_CURSOR_WAITARROW"),
	SYSTEM_CURSOR_SIZENWSE = ffi.cast("enum SDL_SystemCursor", "SDL_SYSTEM_CURSOR_SIZENWSE"),
	SYSTEM_CURSOR_SIZENESW = ffi.cast("enum SDL_SystemCursor", "SDL_SYSTEM_CURSOR_SIZENESW"),
	SYSTEM_CURSOR_SIZEWE = ffi.cast("enum SDL_SystemCursor", "SDL_SYSTEM_CURSOR_SIZEWE"),
	SYSTEM_CURSOR_SIZENS = ffi.cast("enum SDL_SystemCursor", "SDL_SYSTEM_CURSOR_SIZENS"),
	SYSTEM_CURSOR_SIZEALL = ffi.cast("enum SDL_SystemCursor", "SDL_SYSTEM_CURSOR_SIZEALL"),
	SYSTEM_CURSOR_NO = ffi.cast("enum SDL_SystemCursor", "SDL_SYSTEM_CURSOR_NO"),
	SYSTEM_CURSOR_HAND = ffi.cast("enum SDL_SystemCursor", "SDL_SYSTEM_CURSOR_HAND"),
	NUM_SYSTEM_CURSORS = ffi.cast("enum SDL_SystemCursor", "SDL_NUM_SYSTEM_CURSORS"),
	WINDOW_FULLSCREEN = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_FULLSCREEN"),
	WINDOW_OPENGL = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_OPENGL"),
	WINDOW_SHOWN = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_SHOWN"),
	WINDOW_HIDDEN = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_HIDDEN"),
	WINDOW_BORDERLESS = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_BORDERLESS"),
	WINDOW_RESIZABLE = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_RESIZABLE"),
	WINDOW_MINIMIZED = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_MINIMIZED"),
	WINDOW_MAXIMIZED = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_MAXIMIZED"),
	WINDOW_INPUT_GRABBED = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_INPUT_GRABBED"),
	WINDOW_INPUT_FOCUS = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_INPUT_FOCUS"),
	WINDOW_MOUSE_FOCUS = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_MOUSE_FOCUS"),
	WINDOW_FULLSCREEN_DESKTOP = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_FULLSCREEN_DESKTOP"),
	WINDOW_FOREIGN = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_FOREIGN"),
	WINDOW_ALLOW_HIGHDPI = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_ALLOW_HIGHDPI"),
	WINDOW_MOUSE_CAPTURE = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_MOUSE_CAPTURE"),
	WINDOW_ALWAYS_ON_TOP = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_ALWAYS_ON_TOP"),
	WINDOW_SKIP_TASKBAR = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_SKIP_TASKBAR"),
	WINDOW_UTILITY = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_UTILITY"),
	WINDOW_TOOLTIP = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_TOOLTIP"),
	WINDOW_POPUP_MENU = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_POPUP_MENU"),
	JOYSTICK_POWER_UNKNOWN = ffi.cast("enum SDL_JoystickPowerLevel", "SDL_JOYSTICK_POWER_UNKNOWN"),
	JOYSTICK_POWER_EMPTY = ffi.cast("enum SDL_JoystickPowerLevel", "SDL_JOYSTICK_POWER_EMPTY"),
	JOYSTICK_POWER_LOW = ffi.cast("enum SDL_JoystickPowerLevel", "SDL_JOYSTICK_POWER_LOW"),
	JOYSTICK_POWER_MEDIUM = ffi.cast("enum SDL_JoystickPowerLevel", "SDL_JOYSTICK_POWER_MEDIUM"),
	JOYSTICK_POWER_FULL = ffi.cast("enum SDL_JoystickPowerLevel", "SDL_JOYSTICK_POWER_FULL"),
	JOYSTICK_POWER_WIRED = ffi.cast("enum SDL_JoystickPowerLevel", "SDL_JOYSTICK_POWER_WIRED"),
	JOYSTICK_POWER_MAX = ffi.cast("enum SDL_JoystickPowerLevel", "SDL_JOYSTICK_POWER_MAX"),
	HITTEST_NORMAL = ffi.cast("enum SDL_HitTestResult", "SDL_HITTEST_NORMAL"),
	HITTEST_DRAGGABLE = ffi.cast("enum SDL_HitTestResult", "SDL_HITTEST_DRAGGABLE"),
	HITTEST_RESIZE_TOPLEFT = ffi.cast("enum SDL_HitTestResult", "SDL_HITTEST_RESIZE_TOPLEFT"),
	HITTEST_RESIZE_TOP = ffi.cast("enum SDL_HitTestResult", "SDL_HITTEST_RESIZE_TOP"),
	HITTEST_RESIZE_TOPRIGHT = ffi.cast("enum SDL_HitTestResult", "SDL_HITTEST_RESIZE_TOPRIGHT"),
	HITTEST_RESIZE_RIGHT = ffi.cast("enum SDL_HitTestResult", "SDL_HITTEST_RESIZE_RIGHT"),
	HITTEST_RESIZE_BOTTOMRIGHT = ffi.cast("enum SDL_HitTestResult", "SDL_HITTEST_RESIZE_BOTTOMRIGHT"),
	HITTEST_RESIZE_BOTTOM = ffi.cast("enum SDL_HitTestResult", "SDL_HITTEST_RESIZE_BOTTOM"),
	HITTEST_RESIZE_BOTTOMLEFT = ffi.cast("enum SDL_HitTestResult", "SDL_HITTEST_RESIZE_BOTTOMLEFT"),
	HITTEST_RESIZE_LEFT = ffi.cast("enum SDL_HitTestResult", "SDL_HITTEST_RESIZE_LEFT"),
	CONTROLLER_BUTTON_INVALID = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_INVALID"),
	CONTROLLER_BUTTON_A = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_A"),
	CONTROLLER_BUTTON_B = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_B"),
	CONTROLLER_BUTTON_X = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_X"),
	CONTROLLER_BUTTON_Y = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_Y"),
	CONTROLLER_BUTTON_BACK = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_BACK"),
	CONTROLLER_BUTTON_GUIDE = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_GUIDE"),
	CONTROLLER_BUTTON_START = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_START"),
	CONTROLLER_BUTTON_LEFTSTICK = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_LEFTSTICK"),
	CONTROLLER_BUTTON_RIGHTSTICK = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_RIGHTSTICK"),
	CONTROLLER_BUTTON_LEFTSHOULDER = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_LEFTSHOULDER"),
	CONTROLLER_BUTTON_RIGHTSHOULDER = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_RIGHTSHOULDER"),
	CONTROLLER_BUTTON_DPAD_UP = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_DPAD_UP"),
	CONTROLLER_BUTTON_DPAD_DOWN = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_DPAD_DOWN"),
	CONTROLLER_BUTTON_DPAD_LEFT = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_DPAD_LEFT"),
	CONTROLLER_BUTTON_DPAD_RIGHT = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_DPAD_RIGHT"),
	CONTROLLER_BUTTON_MAX = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_MAX"),
	MESSAGEBOX_ERROR = ffi.cast("enum SDL_MessageBoxFlags", "SDL_MESSAGEBOX_ERROR"),
	MESSAGEBOX_WARNING = ffi.cast("enum SDL_MessageBoxFlags", "SDL_MESSAGEBOX_WARNING"),
	MESSAGEBOX_INFORMATION = ffi.cast("enum SDL_MessageBoxFlags", "SDL_MESSAGEBOX_INFORMATION"),
	GL_RED_SIZE = ffi.cast("enum SDL_GLattr", "SDL_GL_RED_SIZE"),
	GL_GREEN_SIZE = ffi.cast("enum SDL_GLattr", "SDL_GL_GREEN_SIZE"),
	GL_BLUE_SIZE = ffi.cast("enum SDL_GLattr", "SDL_GL_BLUE_SIZE"),
	GL_ALPHA_SIZE = ffi.cast("enum SDL_GLattr", "SDL_GL_ALPHA_SIZE"),
	GL_BUFFER_SIZE = ffi.cast("enum SDL_GLattr", "SDL_GL_BUFFER_SIZE"),
	GL_DOUBLEBUFFER = ffi.cast("enum SDL_GLattr", "SDL_GL_DOUBLEBUFFER"),
	GL_DEPTH_SIZE = ffi.cast("enum SDL_GLattr", "SDL_GL_DEPTH_SIZE"),
	GL_STENCIL_SIZE = ffi.cast("enum SDL_GLattr", "SDL_GL_STENCIL_SIZE"),
	GL_ACCUM_RED_SIZE = ffi.cast("enum SDL_GLattr", "SDL_GL_ACCUM_RED_SIZE"),
	GL_ACCUM_GREEN_SIZE = ffi.cast("enum SDL_GLattr", "SDL_GL_ACCUM_GREEN_SIZE"),
	GL_ACCUM_BLUE_SIZE = ffi.cast("enum SDL_GLattr", "SDL_GL_ACCUM_BLUE_SIZE"),
	GL_ACCUM_ALPHA_SIZE = ffi.cast("enum SDL_GLattr", "SDL_GL_ACCUM_ALPHA_SIZE"),
	GL_STEREO = ffi.cast("enum SDL_GLattr", "SDL_GL_STEREO"),
	GL_MULTISAMPLEBUFFERS = ffi.cast("enum SDL_GLattr", "SDL_GL_MULTISAMPLEBUFFERS"),
	GL_MULTISAMPLESAMPLES = ffi.cast("enum SDL_GLattr", "SDL_GL_MULTISAMPLESAMPLES"),
	GL_ACCELERATED_VISUAL = ffi.cast("enum SDL_GLattr", "SDL_GL_ACCELERATED_VISUAL"),
	GL_RETAINED_BACKING = ffi.cast("enum SDL_GLattr", "SDL_GL_RETAINED_BACKING"),
	GL_CONTEXT_MAJOR_VERSION = ffi.cast("enum SDL_GLattr", "SDL_GL_CONTEXT_MAJOR_VERSION"),
	GL_CONTEXT_MINOR_VERSION = ffi.cast("enum SDL_GLattr", "SDL_GL_CONTEXT_MINOR_VERSION"),
	GL_CONTEXT_EGL = ffi.cast("enum SDL_GLattr", "SDL_GL_CONTEXT_EGL"),
	GL_CONTEXT_FLAGS = ffi.cast("enum SDL_GLattr", "SDL_GL_CONTEXT_FLAGS"),
	GL_CONTEXT_PROFILE_MASK = ffi.cast("enum SDL_GLattr", "SDL_GL_CONTEXT_PROFILE_MASK"),
	GL_SHARE_WITH_CURRENT_CONTEXT = ffi.cast("enum SDL_GLattr", "SDL_GL_SHARE_WITH_CURRENT_CONTEXT"),
	GL_FRAMEBUFFER_SRGB_CAPABLE = ffi.cast("enum SDL_GLattr", "SDL_GL_FRAMEBUFFER_SRGB_CAPABLE"),
	GL_CONTEXT_RELEASE_BEHAVIOR = ffi.cast("enum SDL_GLattr", "SDL_GL_CONTEXT_RELEASE_BEHAVIOR"),
	PIXELTYPE_UNKNOWN = 0,
	PIXELTYPE_INDEX1 = 1,
	PIXELTYPE_INDEX4 = 2,
	PIXELTYPE_INDEX8 = 3,
	PIXELTYPE_PACKED8 = 4,
	PIXELTYPE_PACKED16 = 5,
	PIXELTYPE_PACKED32 = 6,
	PIXELTYPE_ARRAYU8 = 7,
	PIXELTYPE_ARRAYU16 = 8,
	PIXELTYPE_ARRAYU32 = 9,
	PIXELTYPE_ARRAYF16 = 10,
	PIXELTYPE_ARRAYF32 = 11,
	BITMAPORDER_NONE = 0,
	BITMAPORDER_4321 = 1,
	BITMAPORDER_1234 = 2,
	PACKEDORDER_NONE = 0,
	PACKEDORDER_XRGB = 1,
	PACKEDORDER_RGBX = 2,
	PACKEDORDER_ARGB = 3,
	PACKEDORDER_RGBA = 4,
	PACKEDORDER_XBGR = 5,
	PACKEDORDER_BGRX = 6,
	PACKEDORDER_ABGR = 7,
	PACKEDORDER_BGRA = 8,
	ARRAYORDER_NONE = 0,
	ARRAYORDER_RGB = 1,
	ARRAYORDER_RGBA = 2,
	ARRAYORDER_ARGB = 3,
	ARRAYORDER_BGR = 4,
	ARRAYORDER_BGRA = 5,
	ARRAYORDER_ABGR = 6,
	PACKEDLAYOUT_NONE = 0,
	PACKEDLAYOUT_332 = 1,
	PACKEDLAYOUT_4444 = 2,
	PACKEDLAYOUT_1555 = 3,
	PACKEDLAYOUT_5551 = 4,
	PACKEDLAYOUT_565 = 5,
	PACKEDLAYOUT_8888 = 6,
	PACKEDLAYOUT_2101010 = 7,
	PACKEDLAYOUT_1010102 = 8,
	PIXELFORMAT_UNKNOWN = 0,
	PIXELFORMAT_INDEX1LSB = 286261504,
	PIXELFORMAT_INDEX1MSB = 287310080,
	PIXELFORMAT_INDEX4LSB = 303039488,
	PIXELFORMAT_INDEX4MSB = 304088064,
	PIXELFORMAT_INDEX8 = 318769153,
	PIXELFORMAT_RGB332 = 336660481,
	PIXELFORMAT_RGB444 = 353504258,
	PIXELFORMAT_RGB555 = 353570562,
	PIXELFORMAT_BGR555 = 357764866,
	PIXELFORMAT_ARGB4444 = 355602434,
	PIXELFORMAT_RGBA4444 = 356651010,
	PIXELFORMAT_ABGR4444 = 359796738,
	PIXELFORMAT_BGRA4444 = 360845314,
	PIXELFORMAT_ARGB1555 = 355667970,
	PIXELFORMAT_RGBA5551 = 356782082,
	PIXELFORMAT_ABGR1555 = 359862274,
	PIXELFORMAT_BGRA5551 = 360976386,
	PIXELFORMAT_RGB565 = 353701890,
	PIXELFORMAT_BGR565 = 357896194,
	PIXELFORMAT_RGB24 = 386930691,
	PIXELFORMAT_BGR24 = 390076419,
	PIXELFORMAT_RGB888 = 370546692,
	PIXELFORMAT_RGBX8888 = 371595268,
	PIXELFORMAT_BGR888 = 374740996,
	PIXELFORMAT_BGRX8888 = 375789572,
	PIXELFORMAT_ARGB8888 = 372645892,
	PIXELFORMAT_RGBA8888 = 373694468,
	PIXELFORMAT_ABGR8888 = 376840196,
	PIXELFORMAT_BGRA8888 = 377888772,
	PIXELFORMAT_ARGB2101010 = 372711428,
	PIXELFORMAT_YV12 = 842094169,
	PIXELFORMAT_IYUV = 1448433993,
	PIXELFORMAT_YUY2 = 844715353,
	PIXELFORMAT_UYVY = 1498831189,
	PIXELFORMAT_YVYU = 1431918169,
	PIXELFORMAT_NV12 = 842094158,
	PIXELFORMAT_NV21 = 825382478,
	LOG_CATEGORY_APPLICATION = 0,
	LOG_CATEGORY_ERROR = 1,
	LOG_CATEGORY_ASSERT = 2,
	LOG_CATEGORY_SYSTEM = 3,
	LOG_CATEGORY_AUDIO = 4,
	LOG_CATEGORY_VIDEO = 5,
	LOG_CATEGORY_RENDER = 6,
	LOG_CATEGORY_INPUT = 7,
	LOG_CATEGORY_TEST = 8,
	LOG_CATEGORY_RESERVED1 = 9,
	LOG_CATEGORY_RESERVED2 = 10,
	LOG_CATEGORY_RESERVED3 = 11,
	LOG_CATEGORY_RESERVED4 = 12,
	LOG_CATEGORY_RESERVED5 = 13,
	LOG_CATEGORY_RESERVED6 = 14,
	LOG_CATEGORY_RESERVED7 = 15,
	LOG_CATEGORY_RESERVED8 = 16,
	LOG_CATEGORY_RESERVED9 = 17,
	LOG_CATEGORY_RESERVED10 = 18,
	LOG_CATEGORY_CUSTOM = 19,
}
library.clib = CLIB
return library
