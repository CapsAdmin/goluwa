				local ffi = require("ffi")
				local lib = assert(ffi.load("SDL2"))
				ffi.cdef([[typedef enum SDL_ArrayOrder{SDL_ARRAYORDER_NONE=0,SDL_ARRAYORDER_RGB=1,SDL_ARRAYORDER_RGBA=2,SDL_ARRAYORDER_ARGB=3,SDL_ARRAYORDER_BGR=4,SDL_ARRAYORDER_BGRA=5,SDL_ARRAYORDER_ABGR=6};
typedef enum SDL_AssertState{SDL_ASSERTION_RETRY=0,SDL_ASSERTION_BREAK=1,SDL_ASSERTION_ABORT=2,SDL_ASSERTION_IGNORE=3,SDL_ASSERTION_ALWAYS_IGNORE=4};
typedef enum SDL_AudioStatus{SDL_AUDIO_STOPPED=0,SDL_AUDIO_PLAYING=1,SDL_AUDIO_PAUSED=2};
typedef enum SDL_BitmapOrder{SDL_BITMAPORDER_NONE=0,SDL_BITMAPORDER_4321=1,SDL_BITMAPORDER_1234=2};
typedef enum SDL_BlendFactor{SDL_BLENDFACTOR_ZERO=1,SDL_BLENDFACTOR_ONE=2,SDL_BLENDFACTOR_SRC_COLOR=3,SDL_BLENDFACTOR_ONE_MINUS_SRC_COLOR=4,SDL_BLENDFACTOR_SRC_ALPHA=5,SDL_BLENDFACTOR_ONE_MINUS_SRC_ALPHA=6,SDL_BLENDFACTOR_DST_COLOR=7,SDL_BLENDFACTOR_ONE_MINUS_DST_COLOR=8,SDL_BLENDFACTOR_DST_ALPHA=9,SDL_BLENDFACTOR_ONE_MINUS_DST_ALPHA=10};
typedef enum SDL_BlendMode{SDL_BLENDMODE_NONE=0,SDL_BLENDMODE_BLEND=1,SDL_BLENDMODE_ADD=2,SDL_BLENDMODE_MOD=4,SDL_BLENDMODE_MUL=8,SDL_BLENDMODE_INVALID=2147483647};
typedef enum SDL_BlendOperation{SDL_BLENDOPERATION_ADD=1,SDL_BLENDOPERATION_SUBTRACT=2,SDL_BLENDOPERATION_REV_SUBTRACT=3,SDL_BLENDOPERATION_MINIMUM=4,SDL_BLENDOPERATION_MAXIMUM=5};
typedef enum SDL_DisplayEventID{SDL_DISPLAYEVENT_NONE=0,SDL_DISPLAYEVENT_ORIENTATION=1,SDL_DISPLAYEVENT_CONNECTED=2,SDL_DISPLAYEVENT_DISCONNECTED=3};
typedef enum SDL_DisplayOrientation{SDL_ORIENTATION_UNKNOWN=0,SDL_ORIENTATION_LANDSCAPE=1,SDL_ORIENTATION_LANDSCAPE_FLIPPED=2,SDL_ORIENTATION_PORTRAIT=3,SDL_ORIENTATION_PORTRAIT_FLIPPED=4};
typedef enum SDL_EventType{SDL_FIRSTEVENT=0,SDL_QUIT=256,SDL_APP_TERMINATING=257,SDL_APP_LOWMEMORY=258,SDL_APP_WILLENTERBACKGROUND=259,SDL_APP_DIDENTERBACKGROUND=260,SDL_APP_WILLENTERFOREGROUND=261,SDL_APP_DIDENTERFOREGROUND=262,SDL_LOCALECHANGED=263,SDL_DISPLAYEVENT=336,SDL_WINDOWEVENT=512,SDL_SYSWMEVENT=513,SDL_KEYDOWN=768,SDL_KEYUP=769,SDL_TEXTEDITING=770,SDL_TEXTINPUT=771,SDL_KEYMAPCHANGED=772,SDL_TEXTEDITING_EXT=773,SDL_MOUSEMOTION=1024,SDL_MOUSEBUTTONDOWN=1025,SDL_MOUSEBUTTONUP=1026,SDL_MOUSEWHEEL=1027,SDL_JOYAXISMOTION=1536,SDL_JOYBALLMOTION=1537,SDL_JOYHATMOTION=1538,SDL_JOYBUTTONDOWN=1539,SDL_JOYBUTTONUP=1540,SDL_JOYDEVICEADDED=1541,SDL_JOYDEVICEREMOVED=1542,SDL_JOYBATTERYUPDATED=1543,SDL_CONTROLLERAXISMOTION=1616,SDL_CONTROLLERBUTTONDOWN=1617,SDL_CONTROLLERBUTTONUP=1618,SDL_CONTROLLERDEVICEADDED=1619,SDL_CONTROLLERDEVICEREMOVED=1620,SDL_CONTROLLERDEVICEREMAPPED=1621,SDL_CONTROLLERTOUCHPADDOWN=1622,SDL_CONTROLLERTOUCHPADMOTION=1623,SDL_CONTROLLERTOUCHPADUP=1624,SDL_CONTROLLERSENSORUPDATE=1625,SDL_FINGERDOWN=1792,SDL_FINGERUP=1793,SDL_FINGERMOTION=1794,SDL_DOLLARGESTURE=2048,SDL_DOLLARRECORD=2049,SDL_MULTIGESTURE=2050,SDL_CLIPBOARDUPDATE=2304,SDL_DROPFILE=4096,SDL_DROPTEXT=4097,SDL_DROPBEGIN=4098,SDL_DROPCOMPLETE=4099,SDL_AUDIODEVICEADDED=4352,SDL_AUDIODEVICEREMOVED=4353,SDL_SENSORUPDATE=4608,SDL_RENDER_TARGETS_RESET=8192,SDL_RENDER_DEVICE_RESET=8193,SDL_POLLSENTINEL=32512,SDL_USEREVENT=32768,SDL_LASTEVENT=65535};
typedef enum SDL_FlashOperation{SDL_FLASH_CANCEL=0,SDL_FLASH_BRIEFLY=1,SDL_FLASH_UNTIL_FOCUSED=2};
typedef enum SDL_GLContextResetNotification{SDL_GL_CONTEXT_RESET_NO_NOTIFICATION=0,SDL_GL_CONTEXT_RESET_LOSE_CONTEXT=1};
typedef enum SDL_GLattr{SDL_GL_RED_SIZE=0,SDL_GL_GREEN_SIZE=1,SDL_GL_BLUE_SIZE=2,SDL_GL_ALPHA_SIZE=3,SDL_GL_BUFFER_SIZE=4,SDL_GL_DOUBLEBUFFER=5,SDL_GL_DEPTH_SIZE=6,SDL_GL_STENCIL_SIZE=7,SDL_GL_ACCUM_RED_SIZE=8,SDL_GL_ACCUM_GREEN_SIZE=9,SDL_GL_ACCUM_BLUE_SIZE=10,SDL_GL_ACCUM_ALPHA_SIZE=11,SDL_GL_STEREO=12,SDL_GL_MULTISAMPLEBUFFERS=13,SDL_GL_MULTISAMPLESAMPLES=14,SDL_GL_ACCELERATED_VISUAL=15,SDL_GL_RETAINED_BACKING=16,SDL_GL_CONTEXT_MAJOR_VERSION=17,SDL_GL_CONTEXT_MINOR_VERSION=18,SDL_GL_CONTEXT_EGL=19,SDL_GL_CONTEXT_FLAGS=20,SDL_GL_CONTEXT_PROFILE_MASK=21,SDL_GL_SHARE_WITH_CURRENT_CONTEXT=22,SDL_GL_FRAMEBUFFER_SRGB_CAPABLE=23,SDL_GL_CONTEXT_RELEASE_BEHAVIOR=24,SDL_GL_CONTEXT_RESET_NOTIFICATION=25,SDL_GL_CONTEXT_NO_ERROR=26,SDL_GL_FLOATBUFFERS=27};
typedef enum SDL_GLcontextFlag{SDL_GL_CONTEXT_DEBUG_FLAG=1,SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG=2,SDL_GL_CONTEXT_ROBUST_ACCESS_FLAG=4,SDL_GL_CONTEXT_RESET_ISOLATION_FLAG=8};
typedef enum SDL_GLcontextReleaseFlag{SDL_GL_CONTEXT_RELEASE_BEHAVIOR_NONE=0,SDL_GL_CONTEXT_RELEASE_BEHAVIOR_FLUSH=1};
typedef enum SDL_GLprofile{SDL_GL_CONTEXT_PROFILE_CORE=1,SDL_GL_CONTEXT_PROFILE_COMPATIBILITY=2,SDL_GL_CONTEXT_PROFILE_ES=4};
typedef enum SDL_GameControllerAxis{SDL_CONTROLLER_AXIS_INVALID=-1,SDL_CONTROLLER_AXIS_LEFTX=0,SDL_CONTROLLER_AXIS_LEFTY=1,SDL_CONTROLLER_AXIS_RIGHTX=2,SDL_CONTROLLER_AXIS_RIGHTY=3,SDL_CONTROLLER_AXIS_TRIGGERLEFT=4,SDL_CONTROLLER_AXIS_TRIGGERRIGHT=5,SDL_CONTROLLER_AXIS_MAX=6};
typedef enum SDL_GameControllerBindType{SDL_CONTROLLER_BINDTYPE_NONE=0,SDL_CONTROLLER_BINDTYPE_BUTTON=1,SDL_CONTROLLER_BINDTYPE_AXIS=2,SDL_CONTROLLER_BINDTYPE_HAT=3};
typedef enum SDL_GameControllerButton{SDL_CONTROLLER_BUTTON_INVALID=-1,SDL_CONTROLLER_BUTTON_A=0,SDL_CONTROLLER_BUTTON_B=1,SDL_CONTROLLER_BUTTON_X=2,SDL_CONTROLLER_BUTTON_Y=3,SDL_CONTROLLER_BUTTON_BACK=4,SDL_CONTROLLER_BUTTON_GUIDE=5,SDL_CONTROLLER_BUTTON_START=6,SDL_CONTROLLER_BUTTON_LEFTSTICK=7,SDL_CONTROLLER_BUTTON_RIGHTSTICK=8,SDL_CONTROLLER_BUTTON_LEFTSHOULDER=9,SDL_CONTROLLER_BUTTON_RIGHTSHOULDER=10,SDL_CONTROLLER_BUTTON_DPAD_UP=11,SDL_CONTROLLER_BUTTON_DPAD_DOWN=12,SDL_CONTROLLER_BUTTON_DPAD_LEFT=13,SDL_CONTROLLER_BUTTON_DPAD_RIGHT=14,SDL_CONTROLLER_BUTTON_MISC1=15,SDL_CONTROLLER_BUTTON_PADDLE1=16,SDL_CONTROLLER_BUTTON_PADDLE2=17,SDL_CONTROLLER_BUTTON_PADDLE3=18,SDL_CONTROLLER_BUTTON_PADDLE4=19,SDL_CONTROLLER_BUTTON_TOUCHPAD=20,SDL_CONTROLLER_BUTTON_MAX=21};
typedef enum SDL_GameControllerType{SDL_CONTROLLER_TYPE_UNKNOWN=0,SDL_CONTROLLER_TYPE_XBOX360=1,SDL_CONTROLLER_TYPE_XBOXONE=2,SDL_CONTROLLER_TYPE_PS3=3,SDL_CONTROLLER_TYPE_PS4=4,SDL_CONTROLLER_TYPE_NINTENDO_SWITCH_PRO=5,SDL_CONTROLLER_TYPE_VIRTUAL=6,SDL_CONTROLLER_TYPE_PS5=7,SDL_CONTROLLER_TYPE_AMAZON_LUNA=8,SDL_CONTROLLER_TYPE_GOOGLE_STADIA=9,SDL_CONTROLLER_TYPE_NVIDIA_SHIELD=10,SDL_CONTROLLER_TYPE_NINTENDO_SWITCH_JOYCON_LEFT=11,SDL_CONTROLLER_TYPE_NINTENDO_SWITCH_JOYCON_RIGHT=12,SDL_CONTROLLER_TYPE_NINTENDO_SWITCH_JOYCON_PAIR=13};
typedef enum SDL_HintPriority{SDL_HINT_DEFAULT=0,SDL_HINT_NORMAL=1,SDL_HINT_OVERRIDE=2};
typedef enum SDL_HitTestResult{SDL_HITTEST_NORMAL=0,SDL_HITTEST_DRAGGABLE=1,SDL_HITTEST_RESIZE_TOPLEFT=2,SDL_HITTEST_RESIZE_TOP=3,SDL_HITTEST_RESIZE_TOPRIGHT=4,SDL_HITTEST_RESIZE_RIGHT=5,SDL_HITTEST_RESIZE_BOTTOMRIGHT=6,SDL_HITTEST_RESIZE_BOTTOM=7,SDL_HITTEST_RESIZE_BOTTOMLEFT=8,SDL_HITTEST_RESIZE_LEFT=9};
typedef enum SDL_JoystickPowerLevel{SDL_JOYSTICK_POWER_UNKNOWN=-1,SDL_JOYSTICK_POWER_EMPTY=0,SDL_JOYSTICK_POWER_LOW=1,SDL_JOYSTICK_POWER_MEDIUM=2,SDL_JOYSTICK_POWER_FULL=3,SDL_JOYSTICK_POWER_WIRED=4,SDL_JOYSTICK_POWER_MAX=5};
typedef enum SDL_JoystickType{SDL_JOYSTICK_TYPE_UNKNOWN=0,SDL_JOYSTICK_TYPE_GAMECONTROLLER=1,SDL_JOYSTICK_TYPE_WHEEL=2,SDL_JOYSTICK_TYPE_ARCADE_STICK=3,SDL_JOYSTICK_TYPE_FLIGHT_STICK=4,SDL_JOYSTICK_TYPE_DANCE_PAD=5,SDL_JOYSTICK_TYPE_GUITAR=6,SDL_JOYSTICK_TYPE_DRUM_KIT=7,SDL_JOYSTICK_TYPE_ARCADE_PAD=8,SDL_JOYSTICK_TYPE_THROTTLE=9};
typedef enum SDL_Keymod{KMOD_NONE=0,KMOD_LSHIFT=1,KMOD_RSHIFT=2,KMOD_LCTRL=64,KMOD_RCTRL=128,KMOD_LALT=256,KMOD_RALT=512,KMOD_LGUI=1024,KMOD_RGUI=2048,KMOD_NUM=4096,KMOD_CAPS=8192,KMOD_MODE=16384,KMOD_SCROLL=32768,KMOD_CTRL=192,KMOD_SHIFT=3,KMOD_ALT=768,KMOD_GUI=3072,KMOD_RESERVED=32768};
typedef enum SDL_LogCategory{SDL_LOG_CATEGORY_APPLICATION=0,SDL_LOG_CATEGORY_ERROR=1,SDL_LOG_CATEGORY_ASSERT=2,SDL_LOG_CATEGORY_SYSTEM=3,SDL_LOG_CATEGORY_AUDIO=4,SDL_LOG_CATEGORY_VIDEO=5,SDL_LOG_CATEGORY_RENDER=6,SDL_LOG_CATEGORY_INPUT=7,SDL_LOG_CATEGORY_TEST=8,SDL_LOG_CATEGORY_RESERVED1=9,SDL_LOG_CATEGORY_RESERVED2=10,SDL_LOG_CATEGORY_RESERVED3=11,SDL_LOG_CATEGORY_RESERVED4=12,SDL_LOG_CATEGORY_RESERVED5=13,SDL_LOG_CATEGORY_RESERVED6=14,SDL_LOG_CATEGORY_RESERVED7=15,SDL_LOG_CATEGORY_RESERVED8=16,SDL_LOG_CATEGORY_RESERVED9=17,SDL_LOG_CATEGORY_RESERVED10=18,SDL_LOG_CATEGORY_CUSTOM=19};
typedef enum SDL_LogPriority{SDL_LOG_PRIORITY_VERBOSE=1,SDL_LOG_PRIORITY_DEBUG=2,SDL_LOG_PRIORITY_INFO=3,SDL_LOG_PRIORITY_WARN=4,SDL_LOG_PRIORITY_ERROR=5,SDL_LOG_PRIORITY_CRITICAL=6,SDL_NUM_LOG_PRIORITIES=7};
typedef enum SDL_MessageBoxButtonFlags{SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT=1,SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT=2};
typedef enum SDL_MessageBoxColorType{SDL_MESSAGEBOX_COLOR_BACKGROUND=0,SDL_MESSAGEBOX_COLOR_TEXT=1,SDL_MESSAGEBOX_COLOR_BUTTON_BORDER=2,SDL_MESSAGEBOX_COLOR_BUTTON_BACKGROUND=3,SDL_MESSAGEBOX_COLOR_BUTTON_SELECTED=4,SDL_MESSAGEBOX_COLOR_MAX=5};
typedef enum SDL_MessageBoxFlags{SDL_MESSAGEBOX_ERROR=16,SDL_MESSAGEBOX_WARNING=32,SDL_MESSAGEBOX_INFORMATION=64,SDL_MESSAGEBOX_BUTTONS_LEFT_TO_RIGHT=128,SDL_MESSAGEBOX_BUTTONS_RIGHT_TO_LEFT=256};
typedef enum SDL_MouseWheelDirection{SDL_MOUSEWHEEL_NORMAL=0,SDL_MOUSEWHEEL_FLIPPED=1};
typedef enum SDL_PackedLayout{SDL_PACKEDLAYOUT_NONE=0,SDL_PACKEDLAYOUT_332=1,SDL_PACKEDLAYOUT_4444=2,SDL_PACKEDLAYOUT_1555=3,SDL_PACKEDLAYOUT_5551=4,SDL_PACKEDLAYOUT_565=5,SDL_PACKEDLAYOUT_8888=6,SDL_PACKEDLAYOUT_2101010=7,SDL_PACKEDLAYOUT_1010102=8};
typedef enum SDL_PackedOrder{SDL_PACKEDORDER_NONE=0,SDL_PACKEDORDER_XRGB=1,SDL_PACKEDORDER_RGBX=2,SDL_PACKEDORDER_ARGB=3,SDL_PACKEDORDER_RGBA=4,SDL_PACKEDORDER_XBGR=5,SDL_PACKEDORDER_BGRX=6,SDL_PACKEDORDER_ABGR=7,SDL_PACKEDORDER_BGRA=8};
typedef enum SDL_PixelFormatEnum{SDL_PIXELFORMAT_UNKNOWN=0,SDL_PIXELFORMAT_INDEX1LSB=286261504,SDL_PIXELFORMAT_INDEX1MSB=287310080,SDL_PIXELFORMAT_INDEX4LSB=303039488,SDL_PIXELFORMAT_INDEX4MSB=304088064,SDL_PIXELFORMAT_INDEX8=318769153,SDL_PIXELFORMAT_RGB332=336660481,SDL_PIXELFORMAT_XRGB4444=353504258,SDL_PIXELFORMAT_RGB444=353504258,SDL_PIXELFORMAT_XBGR4444=357698562,SDL_PIXELFORMAT_BGR444=357698562,SDL_PIXELFORMAT_XRGB1555=353570562,SDL_PIXELFORMAT_RGB555=353570562,SDL_PIXELFORMAT_XBGR1555=357764866,SDL_PIXELFORMAT_BGR555=357764866,SDL_PIXELFORMAT_ARGB4444=355602434,SDL_PIXELFORMAT_RGBA4444=356651010,SDL_PIXELFORMAT_ABGR4444=359796738,SDL_PIXELFORMAT_BGRA4444=360845314,SDL_PIXELFORMAT_ARGB1555=355667970,SDL_PIXELFORMAT_RGBA5551=356782082,SDL_PIXELFORMAT_ABGR1555=359862274,SDL_PIXELFORMAT_BGRA5551=360976386,SDL_PIXELFORMAT_RGB565=353701890,SDL_PIXELFORMAT_BGR565=357896194,SDL_PIXELFORMAT_RGB24=386930691,SDL_PIXELFORMAT_BGR24=390076419,SDL_PIXELFORMAT_XRGB8888=370546692,SDL_PIXELFORMAT_RGB888=370546692,SDL_PIXELFORMAT_RGBX8888=371595268,SDL_PIXELFORMAT_XBGR8888=374740996,SDL_PIXELFORMAT_BGR888=374740996,SDL_PIXELFORMAT_BGRX8888=375789572,SDL_PIXELFORMAT_ARGB8888=372645892,SDL_PIXELFORMAT_RGBA8888=373694468,SDL_PIXELFORMAT_ABGR8888=376840196,SDL_PIXELFORMAT_BGRA8888=377888772,SDL_PIXELFORMAT_ARGB2101010=372711428,SDL_PIXELFORMAT_RGBA32=376840196,SDL_PIXELFORMAT_ARGB32=377888772,SDL_PIXELFORMAT_BGRA32=372645892,SDL_PIXELFORMAT_ABGR32=373694468,SDL_PIXELFORMAT_YV12=842094169,SDL_PIXELFORMAT_IYUV=1448433993,SDL_PIXELFORMAT_YUY2=844715353,SDL_PIXELFORMAT_UYVY=1498831189,SDL_PIXELFORMAT_YVYU=1431918169,SDL_PIXELFORMAT_NV12=842094158,SDL_PIXELFORMAT_NV21=825382478,SDL_PIXELFORMAT_EXTERNAL_OES=542328143};
typedef enum SDL_PixelType{SDL_PIXELTYPE_UNKNOWN=0,SDL_PIXELTYPE_INDEX1=1,SDL_PIXELTYPE_INDEX4=2,SDL_PIXELTYPE_INDEX8=3,SDL_PIXELTYPE_PACKED8=4,SDL_PIXELTYPE_PACKED16=5,SDL_PIXELTYPE_PACKED32=6,SDL_PIXELTYPE_ARRAYU8=7,SDL_PIXELTYPE_ARRAYU16=8,SDL_PIXELTYPE_ARRAYU32=9,SDL_PIXELTYPE_ARRAYF16=10,SDL_PIXELTYPE_ARRAYF32=11};
typedef enum SDL_PowerState{SDL_POWERSTATE_UNKNOWN=0,SDL_POWERSTATE_ON_BATTERY=1,SDL_POWERSTATE_NO_BATTERY=2,SDL_POWERSTATE_CHARGING=3,SDL_POWERSTATE_CHARGED=4};
typedef enum SDL_RendererFlags{SDL_RENDERER_SOFTWARE=1,SDL_RENDERER_ACCELERATED=2,SDL_RENDERER_PRESENTVSYNC=4,SDL_RENDERER_TARGETTEXTURE=8};
typedef enum SDL_RendererFlip{SDL_FLIP_NONE=0,SDL_FLIP_HORIZONTAL=1,SDL_FLIP_VERTICAL=2};
typedef enum SDL_SYSWM_TYPE{SDL_SYSWM_UNKNOWN=0,SDL_SYSWM_WINDOWS=1,SDL_SYSWM_X11=2,SDL_SYSWM_DIRECTFB=3,SDL_SYSWM_COCOA=4,SDL_SYSWM_UIKIT=5,SDL_SYSWM_WAYLAND=6,SDL_SYSWM_MIR=7,SDL_SYSWM_WINRT=8,SDL_SYSWM_ANDROID=9,SDL_SYSWM_VIVANTE=10,SDL_SYSWM_OS2=11,SDL_SYSWM_HAIKU=12,SDL_SYSWM_KMSDRM=13,SDL_SYSWM_RISCOS=14};
typedef enum SDL_ScaleMode{SDL_ScaleModeNearest=0,SDL_ScaleModeLinear=1,SDL_ScaleModeBest=2};
typedef enum SDL_Scancode{SDL_SCANCODE_UNKNOWN=0,SDL_SCANCODE_A=4,SDL_SCANCODE_B=5,SDL_SCANCODE_C=6,SDL_SCANCODE_D=7,SDL_SCANCODE_E=8,SDL_SCANCODE_F=9,SDL_SCANCODE_G=10,SDL_SCANCODE_H=11,SDL_SCANCODE_I=12,SDL_SCANCODE_J=13,SDL_SCANCODE_K=14,SDL_SCANCODE_L=15,SDL_SCANCODE_M=16,SDL_SCANCODE_N=17,SDL_SCANCODE_O=18,SDL_SCANCODE_P=19,SDL_SCANCODE_Q=20,SDL_SCANCODE_R=21,SDL_SCANCODE_S=22,SDL_SCANCODE_T=23,SDL_SCANCODE_U=24,SDL_SCANCODE_V=25,SDL_SCANCODE_W=26,SDL_SCANCODE_X=27,SDL_SCANCODE_Y=28,SDL_SCANCODE_Z=29,SDL_SCANCODE_1=30,SDL_SCANCODE_2=31,SDL_SCANCODE_3=32,SDL_SCANCODE_4=33,SDL_SCANCODE_5=34,SDL_SCANCODE_6=35,SDL_SCANCODE_7=36,SDL_SCANCODE_8=37,SDL_SCANCODE_9=38,SDL_SCANCODE_0=39,SDL_SCANCODE_RETURN=40,SDL_SCANCODE_ESCAPE=41,SDL_SCANCODE_BACKSPACE=42,SDL_SCANCODE_TAB=43,SDL_SCANCODE_SPACE=44,SDL_SCANCODE_MINUS=45,SDL_SCANCODE_EQUALS=46,SDL_SCANCODE_LEFTBRACKET=47,SDL_SCANCODE_RIGHTBRACKET=48,SDL_SCANCODE_BACKSLASH=49,SDL_SCANCODE_NONUSHASH=50,SDL_SCANCODE_SEMICOLON=51,SDL_SCANCODE_APOSTROPHE=52,SDL_SCANCODE_GRAVE=53,SDL_SCANCODE_COMMA=54,SDL_SCANCODE_PERIOD=55,SDL_SCANCODE_SLASH=56,SDL_SCANCODE_CAPSLOCK=57,SDL_SCANCODE_F1=58,SDL_SCANCODE_F2=59,SDL_SCANCODE_F3=60,SDL_SCANCODE_F4=61,SDL_SCANCODE_F5=62,SDL_SCANCODE_F6=63,SDL_SCANCODE_F7=64,SDL_SCANCODE_F8=65,SDL_SCANCODE_F9=66,SDL_SCANCODE_F10=67,SDL_SCANCODE_F11=68,SDL_SCANCODE_F12=69,SDL_SCANCODE_PRINTSCREEN=70,SDL_SCANCODE_SCROLLLOCK=71,SDL_SCANCODE_PAUSE=72,SDL_SCANCODE_INSERT=73,SDL_SCANCODE_HOME=74,SDL_SCANCODE_PAGEUP=75,SDL_SCANCODE_DELETE=76,SDL_SCANCODE_END=77,SDL_SCANCODE_PAGEDOWN=78,SDL_SCANCODE_RIGHT=79,SDL_SCANCODE_LEFT=80,SDL_SCANCODE_DOWN=81,SDL_SCANCODE_UP=82,SDL_SCANCODE_NUMLOCKCLEAR=83,SDL_SCANCODE_KP_DIVIDE=84,SDL_SCANCODE_KP_MULTIPLY=85,SDL_SCANCODE_KP_MINUS=86,SDL_SCANCODE_KP_PLUS=87,SDL_SCANCODE_KP_ENTER=88,SDL_SCANCODE_KP_1=89,SDL_SCANCODE_KP_2=90,SDL_SCANCODE_KP_3=91,SDL_SCANCODE_KP_4=92,SDL_SCANCODE_KP_5=93,SDL_SCANCODE_KP_6=94,SDL_SCANCODE_KP_7=95,SDL_SCANCODE_KP_8=96,SDL_SCANCODE_KP_9=97,SDL_SCANCODE_KP_0=98,SDL_SCANCODE_KP_PERIOD=99,SDL_SCANCODE_NONUSBACKSLASH=100,SDL_SCANCODE_APPLICATION=101,SDL_SCANCODE_POWER=102,SDL_SCANCODE_KP_EQUALS=103,SDL_SCANCODE_F13=104,SDL_SCANCODE_F14=105,SDL_SCANCODE_F15=106,SDL_SCANCODE_F16=107,SDL_SCANCODE_F17=108,SDL_SCANCODE_F18=109,SDL_SCANCODE_F19=110,SDL_SCANCODE_F20=111,SDL_SCANCODE_F21=112,SDL_SCANCODE_F22=113,SDL_SCANCODE_F23=114,SDL_SCANCODE_F24=115,SDL_SCANCODE_EXECUTE=116,SDL_SCANCODE_HELP=117,SDL_SCANCODE_MENU=118,SDL_SCANCODE_SELECT=119,SDL_SCANCODE_STOP=120,SDL_SCANCODE_AGAIN=121,SDL_SCANCODE_UNDO=122,SDL_SCANCODE_CUT=123,SDL_SCANCODE_COPY=124,SDL_SCANCODE_PASTE=125,SDL_SCANCODE_FIND=126,SDL_SCANCODE_MUTE=127,SDL_SCANCODE_VOLUMEUP=128,SDL_SCANCODE_VOLUMEDOWN=129,SDL_SCANCODE_KP_COMMA=133,SDL_SCANCODE_KP_EQUALSAS400=134,SDL_SCANCODE_INTERNATIONAL1=135,SDL_SCANCODE_INTERNATIONAL2=136,SDL_SCANCODE_INTERNATIONAL3=137,SDL_SCANCODE_INTERNATIONAL4=138,SDL_SCANCODE_INTERNATIONAL5=139,SDL_SCANCODE_INTERNATIONAL6=140,SDL_SCANCODE_INTERNATIONAL7=141,SDL_SCANCODE_INTERNATIONAL8=142,SDL_SCANCODE_INTERNATIONAL9=143,SDL_SCANCODE_LANG1=144,SDL_SCANCODE_LANG2=145,SDL_SCANCODE_LANG3=146,SDL_SCANCODE_LANG4=147,SDL_SCANCODE_LANG5=148,SDL_SCANCODE_LANG6=149,SDL_SCANCODE_LANG7=150,SDL_SCANCODE_LANG8=151,SDL_SCANCODE_LANG9=152,SDL_SCANCODE_ALTERASE=153,SDL_SCANCODE_SYSREQ=154,SDL_SCANCODE_CANCEL=155,SDL_SCANCODE_CLEAR=156,SDL_SCANCODE_PRIOR=157,SDL_SCANCODE_RETURN2=158,SDL_SCANCODE_SEPARATOR=159,SDL_SCANCODE_OUT=160,SDL_SCANCODE_OPER=161,SDL_SCANCODE_CLEARAGAIN=162,SDL_SCANCODE_CRSEL=163,SDL_SCANCODE_EXSEL=164,SDL_SCANCODE_KP_00=176,SDL_SCANCODE_KP_000=177,SDL_SCANCODE_THOUSANDSSEPARATOR=178,SDL_SCANCODE_DECIMALSEPARATOR=179,SDL_SCANCODE_CURRENCYUNIT=180,SDL_SCANCODE_CURRENCYSUBUNIT=181,SDL_SCANCODE_KP_LEFTPAREN=182,SDL_SCANCODE_KP_RIGHTPAREN=183,SDL_SCANCODE_KP_LEFTBRACE=184,SDL_SCANCODE_KP_RIGHTBRACE=185,SDL_SCANCODE_KP_TAB=186,SDL_SCANCODE_KP_BACKSPACE=187,SDL_SCANCODE_KP_A=188,SDL_SCANCODE_KP_B=189,SDL_SCANCODE_KP_C=190,SDL_SCANCODE_KP_D=191,SDL_SCANCODE_KP_E=192,SDL_SCANCODE_KP_F=193,SDL_SCANCODE_KP_XOR=194,SDL_SCANCODE_KP_POWER=195,SDL_SCANCODE_KP_PERCENT=196,SDL_SCANCODE_KP_LESS=197,SDL_SCANCODE_KP_GREATER=198,SDL_SCANCODE_KP_AMPERSAND=199,SDL_SCANCODE_KP_DBLAMPERSAND=200,SDL_SCANCODE_KP_VERTICALBAR=201,SDL_SCANCODE_KP_DBLVERTICALBAR=202,SDL_SCANCODE_KP_COLON=203,SDL_SCANCODE_KP_HASH=204,SDL_SCANCODE_KP_SPACE=205,SDL_SCANCODE_KP_AT=206,SDL_SCANCODE_KP_EXCLAM=207,SDL_SCANCODE_KP_MEMSTORE=208,SDL_SCANCODE_KP_MEMRECALL=209,SDL_SCANCODE_KP_MEMCLEAR=210,SDL_SCANCODE_KP_MEMADD=211,SDL_SCANCODE_KP_MEMSUBTRACT=212,SDL_SCANCODE_KP_MEMMULTIPLY=213,SDL_SCANCODE_KP_MEMDIVIDE=214,SDL_SCANCODE_KP_PLUSMINUS=215,SDL_SCANCODE_KP_CLEAR=216,SDL_SCANCODE_KP_CLEARENTRY=217,SDL_SCANCODE_KP_BINARY=218,SDL_SCANCODE_KP_OCTAL=219,SDL_SCANCODE_KP_DECIMAL=220,SDL_SCANCODE_KP_HEXADECIMAL=221,SDL_SCANCODE_LCTRL=224,SDL_SCANCODE_LSHIFT=225,SDL_SCANCODE_LALT=226,SDL_SCANCODE_LGUI=227,SDL_SCANCODE_RCTRL=228,SDL_SCANCODE_RSHIFT=229,SDL_SCANCODE_RALT=230,SDL_SCANCODE_RGUI=231,SDL_SCANCODE_MODE=257,SDL_SCANCODE_AUDIONEXT=258,SDL_SCANCODE_AUDIOPREV=259,SDL_SCANCODE_AUDIOSTOP=260,SDL_SCANCODE_AUDIOPLAY=261,SDL_SCANCODE_AUDIOMUTE=262,SDL_SCANCODE_MEDIASELECT=263,SDL_SCANCODE_WWW=264,SDL_SCANCODE_MAIL=265,SDL_SCANCODE_CALCULATOR=266,SDL_SCANCODE_COMPUTER=267,SDL_SCANCODE_AC_SEARCH=268,SDL_SCANCODE_AC_HOME=269,SDL_SCANCODE_AC_BACK=270,SDL_SCANCODE_AC_FORWARD=271,SDL_SCANCODE_AC_STOP=272,SDL_SCANCODE_AC_REFRESH=273,SDL_SCANCODE_AC_BOOKMARKS=274,SDL_SCANCODE_BRIGHTNESSDOWN=275,SDL_SCANCODE_BRIGHTNESSUP=276,SDL_SCANCODE_DISPLAYSWITCH=277,SDL_SCANCODE_KBDILLUMTOGGLE=278,SDL_SCANCODE_KBDILLUMDOWN=279,SDL_SCANCODE_KBDILLUMUP=280,SDL_SCANCODE_EJECT=281,SDL_SCANCODE_SLEEP=282,SDL_SCANCODE_APP1=283,SDL_SCANCODE_APP2=284,SDL_SCANCODE_AUDIOREWIND=285,SDL_SCANCODE_AUDIOFASTFORWARD=286,SDL_SCANCODE_SOFTLEFT=287,SDL_SCANCODE_SOFTRIGHT=288,SDL_SCANCODE_CALL=289,SDL_SCANCODE_ENDCALL=290,SDL_NUM_SCANCODES=512};
typedef enum SDL_SensorType{SDL_SENSOR_INVALID=-1,SDL_SENSOR_UNKNOWN=0,SDL_SENSOR_ACCEL=1,SDL_SENSOR_GYRO=2,SDL_SENSOR_ACCEL_L=3,SDL_SENSOR_GYRO_L=4,SDL_SENSOR_ACCEL_R=5,SDL_SENSOR_GYRO_R=6};
typedef enum SDL_SystemCursor{SDL_SYSTEM_CURSOR_ARROW=0,SDL_SYSTEM_CURSOR_IBEAM=1,SDL_SYSTEM_CURSOR_WAIT=2,SDL_SYSTEM_CURSOR_CROSSHAIR=3,SDL_SYSTEM_CURSOR_WAITARROW=4,SDL_SYSTEM_CURSOR_SIZENWSE=5,SDL_SYSTEM_CURSOR_SIZENESW=6,SDL_SYSTEM_CURSOR_SIZEWE=7,SDL_SYSTEM_CURSOR_SIZENS=8,SDL_SYSTEM_CURSOR_SIZEALL=9,SDL_SYSTEM_CURSOR_NO=10,SDL_SYSTEM_CURSOR_HAND=11,SDL_NUM_SYSTEM_CURSORS=12};
typedef enum SDL_TextureAccess{SDL_TEXTUREACCESS_STATIC=0,SDL_TEXTUREACCESS_STREAMING=1,SDL_TEXTUREACCESS_TARGET=2};
typedef enum SDL_TextureModulate{SDL_TEXTUREMODULATE_NONE=0,SDL_TEXTUREMODULATE_COLOR=1,SDL_TEXTUREMODULATE_ALPHA=2};
typedef enum SDL_ThreadPriority{SDL_THREAD_PRIORITY_LOW=0,SDL_THREAD_PRIORITY_NORMAL=1,SDL_THREAD_PRIORITY_HIGH=2,SDL_THREAD_PRIORITY_TIME_CRITICAL=3};
typedef enum SDL_TouchDeviceType{SDL_TOUCH_DEVICE_INVALID=-1,SDL_TOUCH_DEVICE_DIRECT=0,SDL_TOUCH_DEVICE_INDIRECT_ABSOLUTE=1,SDL_TOUCH_DEVICE_INDIRECT_RELATIVE=2};
typedef enum SDL_WindowEventID{SDL_WINDOWEVENT_NONE=0,SDL_WINDOWEVENT_SHOWN=1,SDL_WINDOWEVENT_HIDDEN=2,SDL_WINDOWEVENT_EXPOSED=3,SDL_WINDOWEVENT_MOVED=4,SDL_WINDOWEVENT_RESIZED=5,SDL_WINDOWEVENT_SIZE_CHANGED=6,SDL_WINDOWEVENT_MINIMIZED=7,SDL_WINDOWEVENT_MAXIMIZED=8,SDL_WINDOWEVENT_RESTORED=9,SDL_WINDOWEVENT_ENTER=10,SDL_WINDOWEVENT_LEAVE=11,SDL_WINDOWEVENT_FOCUS_GAINED=12,SDL_WINDOWEVENT_FOCUS_LOST=13,SDL_WINDOWEVENT_CLOSE=14,SDL_WINDOWEVENT_TAKE_FOCUS=15,SDL_WINDOWEVENT_HIT_TEST=16,SDL_WINDOWEVENT_ICCPROF_CHANGED=17,SDL_WINDOWEVENT_DISPLAY_CHANGED=18};
typedef enum SDL_WindowFlags{SDL_WINDOW_FULLSCREEN=1,SDL_WINDOW_OPENGL=2,SDL_WINDOW_SHOWN=4,SDL_WINDOW_HIDDEN=8,SDL_WINDOW_BORDERLESS=16,SDL_WINDOW_RESIZABLE=32,SDL_WINDOW_MINIMIZED=64,SDL_WINDOW_MAXIMIZED=128,SDL_WINDOW_MOUSE_GRABBED=256,SDL_WINDOW_INPUT_FOCUS=512,SDL_WINDOW_MOUSE_FOCUS=1024,SDL_WINDOW_FULLSCREEN_DESKTOP=4097,SDL_WINDOW_FOREIGN=2048,SDL_WINDOW_ALLOW_HIGHDPI=8192,SDL_WINDOW_MOUSE_CAPTURE=16384,SDL_WINDOW_ALWAYS_ON_TOP=32768,SDL_WINDOW_SKIP_TASKBAR=65536,SDL_WINDOW_UTILITY=131072,SDL_WINDOW_TOOLTIP=262144,SDL_WINDOW_POPUP_MENU=524288,SDL_WINDOW_KEYBOARD_GRABBED=1048576,SDL_WINDOW_VULKAN=268435456,SDL_WINDOW_METAL=536870912,SDL_WINDOW_INPUT_GRABBED=256};
typedef enum SDL_YUV_CONVERSION_MODE{SDL_YUV_CONVERSION_JPEG=0,SDL_YUV_CONVERSION_BT601=1,SDL_YUV_CONVERSION_BT709=2,SDL_YUV_CONVERSION_AUTOMATIC=3};
typedef enum SDL_bool{SDL_FALSE=0,SDL_TRUE=1};
typedef enum SDL_errorcode{SDL_ENOMEM=0,SDL_EFREAD=1,SDL_EFWRITE=2,SDL_EFSEEK=3,SDL_UNSUPPORTED=4,SDL_LASTERROR=5};
typedef enum SDL_eventaction{SDL_ADDEVENT=0,SDL_PEEKEVENT=1,SDL_GETEVENT=2};
typedef enum SDL_grrrrrr{SDL_INIT_TIMER=1,SDL_INIT_AUDIO=16,SDL_INIT_VIDEO=32,SDL_INIT_JOYSTICK=512,SDL_INIT_HAPTIC=4096,SDL_INIT_GAMECONTROLLER=8192,SDL_INIT_EVENTS=16384,SDL_INIT_NOPARACHUTE=1048576,SDL_INIT_EVERYTHING=29233,SDL_WINDOWPOS_UNDEFINED_MASK=536805376,SDL_WINDOWPOS_UNDEFINED_DISPLAY=536805376,SDL_WINDOWPOS_UNDEFINED=536805376,SDL_WINDOWPOS_CENTERED_MASK=805240832,SDL_WINDOWPOS_CENTERED=805240832};
struct _SDL_iconv_t {};
struct SDL_AssertData {int always_ignore;unsigned int trigger_count;const char*condition;const char*filename;int linenum;const char*function;const struct SDL_AssertData*next;};
struct SDL_atomic_t {int value;};
struct SDL_mutex {};
struct SDL_semaphore {};
struct SDL_cond {};
struct SDL_Thread {};
struct SDL_RWops {signed long(*size)(struct SDL_RWops*);signed long(*seek)(struct SDL_RWops*,signed long,int);unsigned long(*read)(struct SDL_RWops*,void*,unsigned long,unsigned long);unsigned long(*write)(struct SDL_RWops*,const void*,unsigned long,unsigned long);int(*close)(struct SDL_RWops*);unsigned int type;union {struct {unsigned char*base;unsigned char*here;unsigned char*stop;}mem;struct {void*data1;void*data2;}unknown;}hidden;};
struct SDL_AudioSpec {int freq;unsigned short format;unsigned char channels;unsigned char silence;unsigned short samples;unsigned short padding;unsigned int size;void(*callback)(void*,unsigned char*,int);void*userdata;};
struct SDL_AudioCVT {int needed;unsigned short src_format;unsigned short dst_format;double rate_incr;unsigned char*buf;int len;int len_cvt;int len_mult;double len_ratio;void(*filters)(struct SDL_AudioCVT*,unsigned short);int filter_index;};
struct _SDL_AudioStream {};
struct SDL_Color {unsigned char r;unsigned char g;unsigned char b;unsigned char a;};
struct SDL_Palette {int ncolors;struct SDL_Color*colors;unsigned int version;int refcount;};
struct SDL_PixelFormat {unsigned int format;struct SDL_Palette*palette;unsigned char BitsPerPixel;unsigned char BytesPerPixel;unsigned char padding[2];unsigned int Rmask;unsigned int Gmask;unsigned int Bmask;unsigned int Amask;unsigned char Rloss;unsigned char Gloss;unsigned char Bloss;unsigned char Aloss;unsigned char Rshift;unsigned char Gshift;unsigned char Bshift;unsigned char Ashift;int refcount;struct SDL_PixelFormat*next;};
struct SDL_Point {int x;int y;};
struct SDL_FPoint {float x;float y;};
struct SDL_Rect {int x;int y;int w;int h;};
struct SDL_FRect {float x;float y;float w;float h;};
struct SDL_BlitMap {};
struct SDL_Surface {unsigned int flags;struct SDL_PixelFormat*format;int w;int h;int pitch;void*pixels;void*userdata;int locked;void*list_blitmap;struct SDL_Rect clip_rect;struct SDL_BlitMap*map;int refcount;};
struct SDL_DisplayMode {unsigned int format;int w;int h;int refresh_rate;void*driverdata;};
struct SDL_Window {};
struct SDL_Keysym {enum SDL_Scancode scancode;signed int sym;unsigned short mod;unsigned int unused;};
struct SDL_Cursor {};
struct SDL_GUID {unsigned char data[16];};
struct _SDL_Joystick {};
struct SDL_VirtualJoystickDesc {unsigned short version;unsigned short type;unsigned short naxes;unsigned short nbuttons;unsigned short nhats;unsigned short vendor_id;unsigned short product_id;unsigned short padding;unsigned int button_mask;unsigned int axis_mask;const char*name;void*userdata;void(*Update)(void*);void(*SetPlayerIndex)(void*,int);int(*Rumble)(void*,unsigned short,unsigned short);int(*RumbleTriggers)(void*,unsigned short,unsigned short);int(*SetLED)(void*,unsigned char,unsigned char,unsigned char);int(*SendEffect)(void*,const void*,int);};
struct _SDL_Sensor {};
struct _SDL_GameController {};
struct SDL_GameControllerButtonBind {enum SDL_GameControllerBindType bindType;union {int button;int axis;struct {int hat;int hat_mask;}hat;}value;};
struct SDL_Finger {signed long id;float x;float y;float pressure;};
struct SDL_CommonEvent {unsigned int type;unsigned int timestamp;};
struct SDL_DisplayEvent {unsigned int type;unsigned int timestamp;unsigned int display;unsigned char event;unsigned char padding1;unsigned char padding2;unsigned char padding3;signed int data1;};
struct SDL_WindowEvent {unsigned int type;unsigned int timestamp;unsigned int windowID;unsigned char event;unsigned char padding1;unsigned char padding2;unsigned char padding3;signed int data1;signed int data2;};
struct SDL_KeyboardEvent {unsigned int type;unsigned int timestamp;unsigned int windowID;unsigned char state;unsigned char repeat;unsigned char padding2;unsigned char padding3;struct SDL_Keysym keysym;};
struct SDL_TextEditingEvent {unsigned int type;unsigned int timestamp;unsigned int windowID;char text[(32)];signed int start;signed int length;};
struct SDL_TextEditingExtEvent {unsigned int type;unsigned int timestamp;unsigned int windowID;char*text;signed int start;signed int length;};
struct SDL_TextInputEvent {unsigned int type;unsigned int timestamp;unsigned int windowID;char text[(32)];};
struct SDL_MouseMotionEvent {unsigned int type;unsigned int timestamp;unsigned int windowID;unsigned int which;unsigned int state;signed int x;signed int y;signed int xrel;signed int yrel;};
struct SDL_MouseButtonEvent {unsigned int type;unsigned int timestamp;unsigned int windowID;unsigned int which;unsigned char button;unsigned char state;unsigned char clicks;unsigned char padding1;signed int x;signed int y;};
struct SDL_MouseWheelEvent {unsigned int type;unsigned int timestamp;unsigned int windowID;unsigned int which;signed int x;signed int y;unsigned int direction;float preciseX;float preciseY;};
struct SDL_JoyAxisEvent {unsigned int type;unsigned int timestamp;signed int which;unsigned char axis;unsigned char padding1;unsigned char padding2;unsigned char padding3;signed short value;unsigned short padding4;};
struct SDL_JoyBallEvent {unsigned int type;unsigned int timestamp;signed int which;unsigned char ball;unsigned char padding1;unsigned char padding2;unsigned char padding3;signed short xrel;signed short yrel;};
struct SDL_JoyHatEvent {unsigned int type;unsigned int timestamp;signed int which;unsigned char hat;unsigned char value;unsigned char padding1;unsigned char padding2;};
struct SDL_JoyButtonEvent {unsigned int type;unsigned int timestamp;signed int which;unsigned char button;unsigned char state;unsigned char padding1;unsigned char padding2;};
struct SDL_JoyDeviceEvent {unsigned int type;unsigned int timestamp;signed int which;};
struct SDL_JoyBatteryEvent {unsigned int type;unsigned int timestamp;signed int which;enum SDL_JoystickPowerLevel level;};
struct SDL_ControllerAxisEvent {unsigned int type;unsigned int timestamp;signed int which;unsigned char axis;unsigned char padding1;unsigned char padding2;unsigned char padding3;signed short value;unsigned short padding4;};
struct SDL_ControllerButtonEvent {unsigned int type;unsigned int timestamp;signed int which;unsigned char button;unsigned char state;unsigned char padding1;unsigned char padding2;};
struct SDL_ControllerDeviceEvent {unsigned int type;unsigned int timestamp;signed int which;};
struct SDL_ControllerTouchpadEvent {unsigned int type;unsigned int timestamp;signed int which;signed int touchpad;signed int finger;float x;float y;float pressure;};
struct SDL_ControllerSensorEvent {unsigned int type;unsigned int timestamp;signed int which;signed int sensor;float data[3];};
struct SDL_AudioDeviceEvent {unsigned int type;unsigned int timestamp;unsigned int which;unsigned char iscapture;unsigned char padding1;unsigned char padding2;unsigned char padding3;};
struct SDL_TouchFingerEvent {unsigned int type;unsigned int timestamp;signed long touchId;signed long fingerId;float x;float y;float dx;float dy;float pressure;unsigned int windowID;};
struct SDL_MultiGestureEvent {unsigned int type;unsigned int timestamp;signed long touchId;float dTheta;float dDist;float x;float y;unsigned short numFingers;unsigned short padding;};
struct SDL_DollarGestureEvent {unsigned int type;unsigned int timestamp;signed long touchId;signed long gestureId;unsigned int numFingers;float error;float x;float y;};
struct SDL_DropEvent {unsigned int type;unsigned int timestamp;char*file;unsigned int windowID;};
struct SDL_SensorEvent {unsigned int type;unsigned int timestamp;signed int which;float data[6];};
struct SDL_QuitEvent {unsigned int type;unsigned int timestamp;};
struct SDL_UserEvent {unsigned int type;unsigned int timestamp;unsigned int windowID;signed int code;void*data1;void*data2;};
struct SDL_SysWMEvent {unsigned int type;unsigned int timestamp;struct SDL_SysWMmsg*msg;};
union SDL_Event {unsigned int type;struct SDL_CommonEvent common;struct SDL_DisplayEvent display;struct SDL_WindowEvent window;struct SDL_KeyboardEvent key;struct SDL_TextEditingEvent edit;struct SDL_TextEditingExtEvent editExt;struct SDL_TextInputEvent text;struct SDL_MouseMotionEvent motion;struct SDL_MouseButtonEvent button;struct SDL_MouseWheelEvent wheel;struct SDL_JoyAxisEvent jaxis;struct SDL_JoyBallEvent jball;struct SDL_JoyHatEvent jhat;struct SDL_JoyButtonEvent jbutton;struct SDL_JoyDeviceEvent jdevice;struct SDL_JoyBatteryEvent jbattery;struct SDL_ControllerAxisEvent caxis;struct SDL_ControllerButtonEvent cbutton;struct SDL_ControllerDeviceEvent cdevice;struct SDL_ControllerTouchpadEvent ctouchpad;struct SDL_ControllerSensorEvent csensor;struct SDL_AudioDeviceEvent adevice;struct SDL_SensorEvent sensor;struct SDL_QuitEvent quit;struct SDL_UserEvent user;struct SDL_SysWMEvent syswm;struct SDL_TouchFingerEvent tfinger;struct SDL_MultiGestureEvent mgesture;struct SDL_DollarGestureEvent dgesture;struct SDL_DropEvent drop;};
struct _SDL_Haptic {};
struct SDL_HapticDirection {unsigned char type;signed int dir[3];};
struct SDL_HapticConstant {unsigned short type;struct SDL_HapticDirection direction;unsigned int length;unsigned short delay;unsigned short button;unsigned short interval;signed short level;unsigned short attack_length;unsigned short attack_level;unsigned short fade_length;unsigned short fade_level;};
struct SDL_HapticPeriodic {unsigned short type;struct SDL_HapticDirection direction;unsigned int length;unsigned short delay;unsigned short button;unsigned short interval;unsigned short period;signed short magnitude;signed short offset;unsigned short phase;unsigned short attack_length;unsigned short attack_level;unsigned short fade_length;unsigned short fade_level;};
struct SDL_HapticCondition {unsigned short type;struct SDL_HapticDirection direction;unsigned int length;unsigned short delay;unsigned short button;unsigned short interval;unsigned short right_sat[3];unsigned short left_sat[3];signed short right_coeff[3];signed short left_coeff[3];unsigned short deadband[3];signed short center[3];};
struct SDL_HapticRamp {unsigned short type;struct SDL_HapticDirection direction;unsigned int length;unsigned short delay;unsigned short button;unsigned short interval;signed short start;signed short end;unsigned short attack_length;unsigned short attack_level;unsigned short fade_length;unsigned short fade_level;};
struct SDL_HapticLeftRight {unsigned short type;unsigned int length;unsigned short large_magnitude;unsigned short small_magnitude;};
struct SDL_HapticCustom {unsigned short type;struct SDL_HapticDirection direction;unsigned int length;unsigned short delay;unsigned short button;unsigned short interval;unsigned char channels;unsigned short period;unsigned short samples;unsigned short*data;unsigned short attack_length;unsigned short attack_level;unsigned short fade_length;unsigned short fade_level;};
union SDL_HapticEffect {unsigned short type;struct SDL_HapticConstant constant;struct SDL_HapticPeriodic periodic;struct SDL_HapticCondition condition;struct SDL_HapticRamp ramp;struct SDL_HapticLeftRight leftright;struct SDL_HapticCustom custom;};
struct SDL_hid_device_ {};
struct SDL_hid_device_info {char*path;unsigned short vendor_id;unsigned short product_id;int*serial_number;unsigned short release_number;int*manufacturer_string;int*product_string;unsigned short usage_page;unsigned short usage;int interface_number;int interface_class;int interface_subclass;int interface_protocol;struct SDL_hid_device_info*next;};
struct SDL_MessageBoxButtonData {unsigned int flags;int buttonid;const char*text;};
struct SDL_MessageBoxColor {unsigned char r;unsigned char g;unsigned char b;};
struct SDL_MessageBoxColorScheme {struct SDL_MessageBoxColor colors[SDL_MESSAGEBOX_COLOR_MAX];};
struct SDL_MessageBoxData {unsigned int flags;struct SDL_Window*window;const char*title;const char*message;int numbuttons;const struct SDL_MessageBoxButtonData*buttons;const struct SDL_MessageBoxColorScheme*colorScheme;};
struct SDL_RendererInfo {const char*name;unsigned int flags;unsigned int num_texture_formats;unsigned int texture_formats[16];int max_texture_width;int max_texture_height;};
struct SDL_Vertex {struct SDL_FPoint position;struct SDL_Color color;struct SDL_FPoint tex_coord;};
struct SDL_Renderer {};
struct SDL_Texture {};
struct SDL_version {unsigned char major;unsigned char minor;unsigned char patch;};
struct SDL_Locale {const char*language;const char*country;};
struct SDL_SysWMmsg {struct SDL_version version;enum SDL_SYSWM_TYPE subsystem;union {int dummy;}msg;};
struct SDL_SysWMinfo {struct SDL_version version;enum SDL_SYSWM_TYPE subsystem;union {unsigned char dummy[64];}info;};
char*(SDL_GameControllerMapping)(struct _SDL_GameController*);
char*(SDL_GameControllerMappingForDeviceIndex)(int);
char*(SDL_GameControllerMappingForGUID)(struct SDL_GUID);
char*(SDL_GameControllerMappingForIndex)(int);
char*(SDL_GetBasePath)();
char*(SDL_GetClipboardText)();
char*(SDL_GetErrorMsg)(char*,int);
char*(SDL_GetPrefPath)(const char*,const char*);
char*(SDL_GetPrimarySelectionText)();
char*(SDL_getenv)(const char*);
char*(SDL_iconv_string)(const char*,const char*,const char*,unsigned long);
char*(SDL_itoa)(int,char*,int);
char*(SDL_lltoa)(signed long,char*,int);
char*(SDL_ltoa)(long,char*,int);
char*(SDL_strchr)(const char*,int);
char*(SDL_strdup)(const char*);
char*(SDL_strlwr)(char*);
char*(SDL_strrchr)(const char*,int);
char*(SDL_strrev)(char*);
char*(SDL_strstr)(const char*,const char*);
char*(SDL_strtokr)(char*,const char*,char**);
char*(SDL_strupr)(char*);
char*(SDL_uitoa)(unsigned int,char*,int);
char*(SDL_ulltoa)(unsigned long,char*,int);
char*(SDL_ultoa)(unsigned long,char*,int);
const char*(SDL_GameControllerGetAppleSFSymbolsNameForAxis)(struct _SDL_GameController*,enum SDL_GameControllerAxis);
const char*(SDL_GameControllerGetAppleSFSymbolsNameForButton)(struct _SDL_GameController*,enum SDL_GameControllerButton);
const char*(SDL_GameControllerGetSerial)(struct _SDL_GameController*);
const char*(SDL_GameControllerGetStringForAxis)(enum SDL_GameControllerAxis);
const char*(SDL_GameControllerGetStringForButton)(enum SDL_GameControllerButton);
const char*(SDL_GameControllerName)(struct _SDL_GameController*);
const char*(SDL_GameControllerNameForIndex)(int);
const char*(SDL_GameControllerPath)(struct _SDL_GameController*);
const char*(SDL_GameControllerPathForIndex)(int);
const char*(SDL_GetAudioDeviceName)(int,int);
const char*(SDL_GetAudioDriver)(int);
const char*(SDL_GetCurrentAudioDriver)();
const char*(SDL_GetCurrentVideoDriver)();
const char*(SDL_GetDisplayName)(int);
const char*(SDL_GetError)();
const char*(SDL_GetHint)(const char*);
const char*(SDL_GetKeyName)(signed int);
const char*(SDL_GetPixelFormatName)(unsigned int);
const char*(SDL_GetPlatform)();
const char*(SDL_GetRevision)();
const char*(SDL_GetScancodeName)(enum SDL_Scancode);
const char*(SDL_GetThreadName)(struct SDL_Thread*);
const char*(SDL_GetTouchName)(int);
const char*(SDL_GetVideoDriver)(int);
const char*(SDL_GetWindowTitle)(struct SDL_Window*);
const char*(SDL_HapticName)(int);
const char*(SDL_JoystickGetSerial)(struct _SDL_Joystick*);
const char*(SDL_JoystickName)(struct _SDL_Joystick*);
const char*(SDL_JoystickNameForIndex)(int);
const char*(SDL_JoystickPath)(struct _SDL_Joystick*);
const char*(SDL_JoystickPathForIndex)(int);
const char*(SDL_SensorGetDeviceName)(int);
const char*(SDL_SensorGetName)(struct _SDL_Sensor*);
const struct SDL_AssertData*(SDL_GetAssertionReport)();
const struct SDL_Rect*(SDL_GetWindowMouseRect)(struct SDL_Window*);
const unsigned char*(SDL_GetKeyboardState)(int*);
double(SDL_acos)(double);
double(SDL_asin)(double);
double(SDL_atan)(double);
double(SDL_atan2)(double,double);
double(SDL_atof)(const char*);
double(SDL_ceil)(double);
double(SDL_copysign)(double,double);
double(SDL_cos)(double);
double(SDL_exp)(double);
double(SDL_fabs)(double);
double(SDL_floor)(double);
double(SDL_fmod)(double,double);
double(SDL_log)(double);
double(SDL_log10)(double);
double(SDL_pow)(double,double);
double(SDL_round)(double);
double(SDL_scalbn)(double,int);
double(SDL_sin)(double);
double(SDL_sqrt)(double);
double(SDL_strtod)(const char*,char**);
double(SDL_tan)(double);
double(SDL_trunc)(double);
enum SDL_AssertState(SDL_ReportAssertion)(struct SDL_AssertData*,const char*,const char*,int);
enum SDL_AssertState(*SDL_GetAssertionHandler(void**))(const struct SDL_AssertData*,void*);
enum SDL_AssertState(*SDL_GetDefaultAssertionHandler())(const struct SDL_AssertData*,void*);
enum SDL_AudioStatus(SDL_GetAudioDeviceStatus)(unsigned int);
enum SDL_AudioStatus(SDL_GetAudioStatus)();
enum SDL_BlendMode(SDL_ComposeCustomBlendMode)(enum SDL_BlendFactor,enum SDL_BlendFactor,enum SDL_BlendOperation,enum SDL_BlendFactor,enum SDL_BlendFactor,enum SDL_BlendOperation);
enum SDL_DisplayOrientation(SDL_GetDisplayOrientation)(int);
enum SDL_GameControllerAxis(SDL_GameControllerGetAxisFromString)(const char*);
enum SDL_GameControllerButton(SDL_GameControllerGetButtonFromString)(const char*);
enum SDL_GameControllerType(SDL_GameControllerGetType)(struct _SDL_GameController*);
enum SDL_GameControllerType(SDL_GameControllerTypeForIndex)(int);
enum SDL_JoystickPowerLevel(SDL_JoystickCurrentPowerLevel)(struct _SDL_Joystick*);
enum SDL_JoystickType(SDL_JoystickGetDeviceType)(int);
enum SDL_JoystickType(SDL_JoystickGetType)(struct _SDL_Joystick*);
enum SDL_Keymod(SDL_GetModState)();
enum SDL_LogPriority(SDL_LogGetPriority)(int);
enum SDL_PowerState(SDL_GetPowerInfo)(int*,int*);
enum SDL_Scancode(SDL_GetScancodeFromKey)(signed int);
enum SDL_Scancode(SDL_GetScancodeFromName)(const char*);
enum SDL_SensorType(SDL_SensorGetDeviceType)(int);
enum SDL_SensorType(SDL_SensorGetType)(struct _SDL_Sensor*);
enum SDL_TouchDeviceType(SDL_GetTouchDeviceType)(signed long);
enum SDL_YUV_CONVERSION_MODE(SDL_GetYUVConversionMode)();
enum SDL_YUV_CONVERSION_MODE(SDL_GetYUVConversionModeForResolution)(int,int);
enum SDL_bool(SDL_AtomicCAS)(struct SDL_atomic_t*,int,int);
enum SDL_bool(SDL_AtomicCASPtr)(void**,void*,void*);
enum SDL_bool(SDL_AtomicTryLock)(int*);
enum SDL_bool(SDL_EncloseFPoints)(const struct SDL_FPoint*,int,const struct SDL_FRect*,struct SDL_FRect*);
enum SDL_bool(SDL_EnclosePoints)(const struct SDL_Point*,int,const struct SDL_Rect*,struct SDL_Rect*);
enum SDL_bool(SDL_GL_ExtensionSupported)(const char*);
enum SDL_bool(SDL_GameControllerGetAttached)(struct _SDL_GameController*);
enum SDL_bool(SDL_GameControllerHasAxis)(struct _SDL_GameController*,enum SDL_GameControllerAxis);
enum SDL_bool(SDL_GameControllerHasButton)(struct _SDL_GameController*,enum SDL_GameControllerButton);
enum SDL_bool(SDL_GameControllerHasLED)(struct _SDL_GameController*);
enum SDL_bool(SDL_GameControllerHasRumble)(struct _SDL_GameController*);
enum SDL_bool(SDL_GameControllerHasRumbleTriggers)(struct _SDL_GameController*);
enum SDL_bool(SDL_GameControllerHasSensor)(struct _SDL_GameController*,enum SDL_SensorType);
enum SDL_bool(SDL_GameControllerIsSensorEnabled)(struct _SDL_GameController*,enum SDL_SensorType);
enum SDL_bool(SDL_GetEventFilter)(int(*filter)(void*,union SDL_Event*),void**);
enum SDL_bool(SDL_GetHintBoolean)(const char*,enum SDL_bool);
enum SDL_bool(SDL_GetRelativeMouseMode)();
enum SDL_bool(SDL_GetWindowGrab)(struct SDL_Window*);
enum SDL_bool(SDL_GetWindowKeyboardGrab)(struct SDL_Window*);
enum SDL_bool(SDL_GetWindowMouseGrab)(struct SDL_Window*);
enum SDL_bool(SDL_GetWindowWMInfo)(struct SDL_Window*,struct SDL_SysWMinfo*);
enum SDL_bool(SDL_Has3DNow)();
enum SDL_bool(SDL_HasARMSIMD)();
enum SDL_bool(SDL_HasAVX)();
enum SDL_bool(SDL_HasAVX2)();
enum SDL_bool(SDL_HasAVX512F)();
enum SDL_bool(SDL_HasAltiVec)();
enum SDL_bool(SDL_HasClipboardText)();
enum SDL_bool(SDL_HasColorKey)(struct SDL_Surface*);
enum SDL_bool(SDL_HasEvent)(unsigned int);
enum SDL_bool(SDL_HasEvents)(unsigned int,unsigned int);
enum SDL_bool(SDL_HasIntersection)(const struct SDL_Rect*,const struct SDL_Rect*);
enum SDL_bool(SDL_HasIntersectionF)(const struct SDL_FRect*,const struct SDL_FRect*);
enum SDL_bool(SDL_HasLASX)();
enum SDL_bool(SDL_HasLSX)();
enum SDL_bool(SDL_HasMMX)();
enum SDL_bool(SDL_HasNEON)();
enum SDL_bool(SDL_HasPrimarySelectionText)();
enum SDL_bool(SDL_HasRDTSC)();
enum SDL_bool(SDL_HasSSE)();
enum SDL_bool(SDL_HasSSE2)();
enum SDL_bool(SDL_HasSSE3)();
enum SDL_bool(SDL_HasSSE41)();
enum SDL_bool(SDL_HasSSE42)();
enum SDL_bool(SDL_HasScreenKeyboardSupport)();
enum SDL_bool(SDL_HasSurfaceRLE)(struct SDL_Surface*);
enum SDL_bool(SDL_IntersectFRect)(const struct SDL_FRect*,const struct SDL_FRect*,struct SDL_FRect*);
enum SDL_bool(SDL_IntersectFRectAndLine)(const struct SDL_FRect*,float*,float*,float*,float*);
enum SDL_bool(SDL_IntersectRect)(const struct SDL_Rect*,const struct SDL_Rect*,struct SDL_Rect*);
enum SDL_bool(SDL_IntersectRectAndLine)(const struct SDL_Rect*,int*,int*,int*,int*);
enum SDL_bool(SDL_IsGameController)(int);
enum SDL_bool(SDL_IsScreenKeyboardShown)(struct SDL_Window*);
enum SDL_bool(SDL_IsScreenSaverEnabled)();
enum SDL_bool(SDL_IsShapedWindow)(const struct SDL_Window*);
enum SDL_bool(SDL_IsTablet)();
enum SDL_bool(SDL_IsTextInputActive)();
enum SDL_bool(SDL_IsTextInputShown)();
enum SDL_bool(SDL_JoystickGetAttached)(struct _SDL_Joystick*);
enum SDL_bool(SDL_JoystickGetAxisInitialState)(struct _SDL_Joystick*,int,signed short*);
enum SDL_bool(SDL_JoystickHasLED)(struct _SDL_Joystick*);
enum SDL_bool(SDL_JoystickHasRumble)(struct _SDL_Joystick*);
enum SDL_bool(SDL_JoystickHasRumbleTriggers)(struct _SDL_Joystick*);
enum SDL_bool(SDL_JoystickIsVirtual)(int);
enum SDL_bool(SDL_PixelFormatEnumToMasks)(unsigned int,int*,unsigned int*,unsigned int*,unsigned int*,unsigned int*);
enum SDL_bool(SDL_RemoveTimer)(int);
enum SDL_bool(SDL_RenderGetIntegerScale)(struct SDL_Renderer*);
enum SDL_bool(SDL_RenderIsClipEnabled)(struct SDL_Renderer*);
enum SDL_bool(SDL_RenderTargetSupported)(struct SDL_Renderer*);
enum SDL_bool(SDL_ResetHint)(const char*);
enum SDL_bool(SDL_SetClipRect)(struct SDL_Surface*,const struct SDL_Rect*);
enum SDL_bool(SDL_SetHint)(const char*,const char*);
enum SDL_bool(SDL_SetHintWithPriority)(const char*,const char*,enum SDL_HintPriority);
enum SDL_bool(SDL_Vulkan_CreateSurface)(struct SDL_Window*,void*,void**);
enum SDL_bool(SDL_Vulkan_GetInstanceExtensions)(struct SDL_Window*,unsigned int*,const char**);
float(SDL_GameControllerGetSensorDataRate)(struct _SDL_GameController*,enum SDL_SensorType);
float(SDL_GetWindowBrightness)(struct SDL_Window*);
float(SDL_acosf)(float);
float(SDL_asinf)(float);
float(SDL_atan2f)(float,float);
float(SDL_atanf)(float);
float(SDL_ceilf)(float);
float(SDL_copysignf)(float,float);
float(SDL_cosf)(float);
float(SDL_expf)(float);
float(SDL_fabsf)(float);
float(SDL_floorf)(float);
float(SDL_fmodf)(float,float);
float(SDL_log10f)(float);
float(SDL_logf)(float);
float(SDL_powf)(float,float);
float(SDL_roundf)(float);
float(SDL_scalbnf)(float,int);
float(SDL_sinf)(float);
float(SDL_sqrtf)(float);
float(SDL_tanf)(float);
float(SDL_truncf)(float);
int*(SDL_wcsdup)(const int*);
int*(SDL_wcsstr)(const int*,const int*);
int(SDL_AddTimer)(unsigned int,unsigned int(*callback)(unsigned int,void*),void*);
int(SDL_AtomicAdd)(struct SDL_atomic_t*,int);
int(SDL_AtomicGet)(struct SDL_atomic_t*);
int(SDL_AtomicSet)(struct SDL_atomic_t*,int);
int(SDL_AudioInit)(const char*);
int(SDL_AudioStreamAvailable)(struct _SDL_AudioStream*);
int(SDL_AudioStreamFlush)(struct _SDL_AudioStream*);
int(SDL_AudioStreamGet)(struct _SDL_AudioStream*,void*,int);
int(SDL_AudioStreamPut)(struct _SDL_AudioStream*,const void*,int);
int(SDL_BuildAudioCVT)(struct SDL_AudioCVT*,unsigned short,unsigned char,int,unsigned short,unsigned char,int);
int(SDL_CaptureMouse)(enum SDL_bool);
int(SDL_CondBroadcast)(struct SDL_cond*);
int(SDL_CondSignal)(struct SDL_cond*);
int(SDL_CondWait)(struct SDL_cond*,struct SDL_mutex*);
int(SDL_CondWaitTimeout)(struct SDL_cond*,struct SDL_mutex*,unsigned int);
int(SDL_ConvertAudio)(struct SDL_AudioCVT*);
int(SDL_ConvertPixels)(int,int,unsigned int,const void*,int,unsigned int,void*,int);
int(SDL_CreateWindowAndRenderer)(int,int,unsigned int,struct SDL_Window**,struct SDL_Renderer**);
int(SDL_Error)(enum SDL_errorcode);
int(SDL_FillRect)(struct SDL_Surface*,const struct SDL_Rect*,unsigned int);
int(SDL_FillRects)(struct SDL_Surface*,const struct SDL_Rect*,int,unsigned int);
int(SDL_FlashWindow)(struct SDL_Window*,enum SDL_FlashOperation);
int(SDL_GL_BindTexture)(struct SDL_Texture*,float*,float*);
int(SDL_GL_GetAttribute)(enum SDL_GLattr,int*);
int(SDL_GL_GetSwapInterval)();
int(SDL_GL_LoadLibrary)(const char*);
int(SDL_GL_MakeCurrent)(struct SDL_Window*,void*);
int(SDL_GL_SetAttribute)(enum SDL_GLattr,int);
int(SDL_GL_SetSwapInterval)(int);
int(SDL_GL_UnbindTexture)(struct SDL_Texture*);
int(SDL_GameControllerAddMapping)(const char*);
int(SDL_GameControllerAddMappingsFromRW)(struct SDL_RWops*,int);
int(SDL_GameControllerEventState)(int);
int(SDL_GameControllerGetNumTouchpadFingers)(struct _SDL_GameController*,int);
int(SDL_GameControllerGetNumTouchpads)(struct _SDL_GameController*);
int(SDL_GameControllerGetPlayerIndex)(struct _SDL_GameController*);
int(SDL_GameControllerGetSensorData)(struct _SDL_GameController*,enum SDL_SensorType,float*,int);
int(SDL_GameControllerGetTouchpadFinger)(struct _SDL_GameController*,int,int,unsigned char*,float*,float*,float*);
int(SDL_GameControllerNumMappings)();
int(SDL_GameControllerRumble)(struct _SDL_GameController*,unsigned short,unsigned short,unsigned int);
int(SDL_GameControllerRumbleTriggers)(struct _SDL_GameController*,unsigned short,unsigned short,unsigned int);
int(SDL_GameControllerSendEffect)(struct _SDL_GameController*,const void*,int);
int(SDL_GameControllerSetLED)(struct _SDL_GameController*,unsigned char,unsigned char,unsigned char);
int(SDL_GameControllerSetSensorEnabled)(struct _SDL_GameController*,enum SDL_SensorType,enum SDL_bool);
int(SDL_GetAudioDeviceSpec)(int,int,struct SDL_AudioSpec*);
int(SDL_GetCPUCacheLineSize)();
int(SDL_GetCPUCount)();
int(SDL_GetColorKey)(struct SDL_Surface*,unsigned int*);
int(SDL_GetCurrentDisplayMode)(int,struct SDL_DisplayMode*);
int(SDL_GetDefaultAudioInfo)(char**,struct SDL_AudioSpec*,int);
int(SDL_GetDesktopDisplayMode)(int,struct SDL_DisplayMode*);
int(SDL_GetDisplayBounds)(int,struct SDL_Rect*);
int(SDL_GetDisplayDPI)(int,float*,float*,float*);
int(SDL_GetDisplayMode)(int,int,struct SDL_DisplayMode*);
int(SDL_GetDisplayUsableBounds)(int,struct SDL_Rect*);
int(SDL_GetNumAllocations)();
int(SDL_GetNumAudioDevices)(int);
int(SDL_GetNumAudioDrivers)();
int(SDL_GetNumDisplayModes)(int);
int(SDL_GetNumRenderDrivers)();
int(SDL_GetNumTouchDevices)();
int(SDL_GetNumTouchFingers)(signed long);
int(SDL_GetNumVideoDisplays)();
int(SDL_GetNumVideoDrivers)();
int(SDL_GetPointDisplayIndex)(const struct SDL_Point*);
int(SDL_GetRectDisplayIndex)(const struct SDL_Rect*);
int(SDL_GetRenderDrawBlendMode)(struct SDL_Renderer*,enum SDL_BlendMode*);
int(SDL_GetRenderDrawColor)(struct SDL_Renderer*,unsigned char*,unsigned char*,unsigned char*,unsigned char*);
int(SDL_GetRenderDriverInfo)(int,struct SDL_RendererInfo*);
int(SDL_GetRendererInfo)(struct SDL_Renderer*,struct SDL_RendererInfo*);
int(SDL_GetRendererOutputSize)(struct SDL_Renderer*,int*,int*);
int(SDL_GetRevisionNumber)();
int(SDL_GetShapedWindowMode)(struct SDL_Window*,struct SDL_WindowShapeMode*);
int(SDL_GetSurfaceAlphaMod)(struct SDL_Surface*,unsigned char*);
int(SDL_GetSurfaceBlendMode)(struct SDL_Surface*,enum SDL_BlendMode*);
int(SDL_GetSurfaceColorMod)(struct SDL_Surface*,unsigned char*,unsigned char*,unsigned char*);
int(SDL_GetSystemRAM)();
int(SDL_GetTextureAlphaMod)(struct SDL_Texture*,unsigned char*);
int(SDL_GetTextureBlendMode)(struct SDL_Texture*,enum SDL_BlendMode*);
int(SDL_GetTextureColorMod)(struct SDL_Texture*,unsigned char*,unsigned char*,unsigned char*);
int(SDL_GetTextureScaleMode)(struct SDL_Texture*,enum SDL_ScaleMode*);
int(SDL_GetWindowBordersSize)(struct SDL_Window*,int*,int*,int*,int*);
int(SDL_GetWindowDisplayIndex)(struct SDL_Window*);
int(SDL_GetWindowDisplayMode)(struct SDL_Window*,struct SDL_DisplayMode*);
int(SDL_GetWindowGammaRamp)(struct SDL_Window*,unsigned short*,unsigned short*,unsigned short*);
int(SDL_GetWindowOpacity)(struct SDL_Window*,float*);
int(SDL_HapticEffectSupported)(struct _SDL_Haptic*,union SDL_HapticEffect*);
int(SDL_HapticGetEffectStatus)(struct _SDL_Haptic*,int);
int(SDL_HapticIndex)(struct _SDL_Haptic*);
int(SDL_HapticNewEffect)(struct _SDL_Haptic*,union SDL_HapticEffect*);
int(SDL_HapticNumAxes)(struct _SDL_Haptic*);
int(SDL_HapticNumEffects)(struct _SDL_Haptic*);
int(SDL_HapticNumEffectsPlaying)(struct _SDL_Haptic*);
int(SDL_HapticOpened)(int);
int(SDL_HapticPause)(struct _SDL_Haptic*);
int(SDL_HapticRumbleInit)(struct _SDL_Haptic*);
int(SDL_HapticRumblePlay)(struct _SDL_Haptic*,float,unsigned int);
int(SDL_HapticRumbleStop)(struct _SDL_Haptic*);
int(SDL_HapticRumbleSupported)(struct _SDL_Haptic*);
int(SDL_HapticRunEffect)(struct _SDL_Haptic*,int,unsigned int);
int(SDL_HapticSetAutocenter)(struct _SDL_Haptic*,int);
int(SDL_HapticSetGain)(struct _SDL_Haptic*,int);
int(SDL_HapticStopAll)(struct _SDL_Haptic*);
int(SDL_HapticStopEffect)(struct _SDL_Haptic*,int);
int(SDL_HapticUnpause)(struct _SDL_Haptic*);
int(SDL_HapticUpdateEffect)(struct _SDL_Haptic*,int,union SDL_HapticEffect*);
int(SDL_Init)(unsigned int);
int(SDL_InitSubSystem)(unsigned int);
int(SDL_JoystickAttachVirtual)(enum SDL_JoystickType,int,int,int);
int(SDL_JoystickAttachVirtualEx)(const struct SDL_VirtualJoystickDesc*);
int(SDL_JoystickDetachVirtual)(int);
int(SDL_JoystickEventState)(int);
int(SDL_JoystickGetBall)(struct _SDL_Joystick*,int,int*,int*);
int(SDL_JoystickGetDevicePlayerIndex)(int);
int(SDL_JoystickGetPlayerIndex)(struct _SDL_Joystick*);
int(SDL_JoystickIsHaptic)(struct _SDL_Joystick*);
int(SDL_JoystickNumAxes)(struct _SDL_Joystick*);
int(SDL_JoystickNumBalls)(struct _SDL_Joystick*);
int(SDL_JoystickNumButtons)(struct _SDL_Joystick*);
int(SDL_JoystickNumHats)(struct _SDL_Joystick*);
int(SDL_JoystickRumble)(struct _SDL_Joystick*,unsigned short,unsigned short,unsigned int);
int(SDL_JoystickRumbleTriggers)(struct _SDL_Joystick*,unsigned short,unsigned short,unsigned int);
int(SDL_JoystickSendEffect)(struct _SDL_Joystick*,const void*,int);
int(SDL_JoystickSetLED)(struct _SDL_Joystick*,unsigned char,unsigned char,unsigned char);
int(SDL_JoystickSetVirtualAxis)(struct _SDL_Joystick*,int,signed short);
int(SDL_JoystickSetVirtualButton)(struct _SDL_Joystick*,int,unsigned char);
int(SDL_JoystickSetVirtualHat)(struct _SDL_Joystick*,int,unsigned char);
int(SDL_LinuxSetThreadPriority)(signed long,int);
int(SDL_LinuxSetThreadPriorityAndPolicy)(signed long,int,int);
int(SDL_LoadDollarTemplates)(signed long,struct SDL_RWops*);
int(SDL_LockMutex)(struct SDL_mutex*);
int(SDL_LockSurface)(struct SDL_Surface*);
int(SDL_LockTexture)(struct SDL_Texture*,const struct SDL_Rect*,void**,int*);
int(SDL_LockTextureToSurface)(struct SDL_Texture*,const struct SDL_Rect*,struct SDL_Surface**);
int(SDL_LowerBlit)(struct SDL_Surface*,struct SDL_Rect*,struct SDL_Surface*,struct SDL_Rect*);
int(SDL_LowerBlitScaled)(struct SDL_Surface*,struct SDL_Rect*,struct SDL_Surface*,struct SDL_Rect*);
int(SDL_MouseIsHaptic)();
int(SDL_NumHaptics)();
int(SDL_NumJoysticks)();
int(SDL_NumSensors)();
int(SDL_OpenAudio)(struct SDL_AudioSpec*,struct SDL_AudioSpec*);
int(SDL_OpenURL)(const char*);
int(SDL_PeepEvents)(union SDL_Event*,int,enum SDL_eventaction,unsigned int,unsigned int);
int(SDL_PollEvent)(union SDL_Event*);
int(SDL_PremultiplyAlpha)(int,int,unsigned int,const void*,int,unsigned int,void*,int);
int(SDL_PushEvent)(union SDL_Event*);
int(SDL_QueryTexture)(struct SDL_Texture*,unsigned int*,int*,int*,int*);
int(SDL_QueueAudio)(unsigned int,const void*,unsigned int);
int(SDL_RWclose)(struct SDL_RWops*);
int(SDL_RecordGesture)(signed long);
int(SDL_RenderClear)(struct SDL_Renderer*);
int(SDL_RenderCopy)(struct SDL_Renderer*,struct SDL_Texture*,const struct SDL_Rect*,const struct SDL_Rect*);
int(SDL_RenderCopyEx)(struct SDL_Renderer*,struct SDL_Texture*,const struct SDL_Rect*,const struct SDL_Rect*,const double,const struct SDL_Point*,const enum SDL_RendererFlip);
int(SDL_RenderCopyExF)(struct SDL_Renderer*,struct SDL_Texture*,const struct SDL_Rect*,const struct SDL_FRect*,const double,const struct SDL_FPoint*,const enum SDL_RendererFlip);
int(SDL_RenderCopyF)(struct SDL_Renderer*,struct SDL_Texture*,const struct SDL_Rect*,const struct SDL_FRect*);
int(SDL_RenderDrawLine)(struct SDL_Renderer*,int,int,int,int);
int(SDL_RenderDrawLineF)(struct SDL_Renderer*,float,float,float,float);
int(SDL_RenderDrawLines)(struct SDL_Renderer*,const struct SDL_Point*,int);
int(SDL_RenderDrawLinesF)(struct SDL_Renderer*,const struct SDL_FPoint*,int);
int(SDL_RenderDrawPoint)(struct SDL_Renderer*,int,int);
int(SDL_RenderDrawPointF)(struct SDL_Renderer*,float,float);
int(SDL_RenderDrawPoints)(struct SDL_Renderer*,const struct SDL_Point*,int);
int(SDL_RenderDrawPointsF)(struct SDL_Renderer*,const struct SDL_FPoint*,int);
int(SDL_RenderDrawRect)(struct SDL_Renderer*,const struct SDL_Rect*);
int(SDL_RenderDrawRectF)(struct SDL_Renderer*,const struct SDL_FRect*);
int(SDL_RenderDrawRects)(struct SDL_Renderer*,const struct SDL_Rect*,int);
int(SDL_RenderDrawRectsF)(struct SDL_Renderer*,const struct SDL_FRect*,int);
int(SDL_RenderFillRect)(struct SDL_Renderer*,const struct SDL_Rect*);
int(SDL_RenderFillRectF)(struct SDL_Renderer*,const struct SDL_FRect*);
int(SDL_RenderFillRects)(struct SDL_Renderer*,const struct SDL_Rect*,int);
int(SDL_RenderFillRectsF)(struct SDL_Renderer*,const struct SDL_FRect*,int);
int(SDL_RenderFlush)(struct SDL_Renderer*);
int(SDL_RenderGeometry)(struct SDL_Renderer*,struct SDL_Texture*,const struct SDL_Vertex*,int,const int*,int);
int(SDL_RenderGeometryRaw)(struct SDL_Renderer*,struct SDL_Texture*,const float*,int,const struct SDL_Color*,int,const float*,int,int,const void*,int,int);
int(SDL_RenderReadPixels)(struct SDL_Renderer*,const struct SDL_Rect*,unsigned int,void*,int);
int(SDL_RenderSetClipRect)(struct SDL_Renderer*,const struct SDL_Rect*);
int(SDL_RenderSetIntegerScale)(struct SDL_Renderer*,enum SDL_bool);
int(SDL_RenderSetLogicalSize)(struct SDL_Renderer*,int,int);
int(SDL_RenderSetScale)(struct SDL_Renderer*,float,float);
int(SDL_RenderSetVSync)(struct SDL_Renderer*,int);
int(SDL_RenderSetViewport)(struct SDL_Renderer*,const struct SDL_Rect*);
int(SDL_SaveAllDollarTemplates)(struct SDL_RWops*);
int(SDL_SaveBMP_RW)(struct SDL_Surface*,struct SDL_RWops*,int);
int(SDL_SaveDollarTemplate)(signed long,struct SDL_RWops*);
int(SDL_SemPost)(struct SDL_semaphore*);
int(SDL_SemTryWait)(struct SDL_semaphore*);
int(SDL_SemWait)(struct SDL_semaphore*);
int(SDL_SemWaitTimeout)(struct SDL_semaphore*,unsigned int);
int(SDL_SensorGetData)(struct _SDL_Sensor*,float*,int);
int(SDL_SensorGetDeviceNonPortableType)(int);
int(SDL_SensorGetNonPortableType)(struct _SDL_Sensor*);
int(SDL_SetClipboardText)(const char*);
int(SDL_SetColorKey)(struct SDL_Surface*,int,unsigned int);
int(SDL_SetError)(const char*,...);
int(SDL_SetMemoryFunctions)(void*(*malloc_func)(unsigned long),void*(*calloc_func)(unsigned long,unsigned long),void*(*realloc_func)(void*,unsigned long),void(*free_func)(void*));
int(SDL_SetPaletteColors)(struct SDL_Palette*,const struct SDL_Color*,int,int);
int(SDL_SetPixelFormatPalette)(struct SDL_PixelFormat*,struct SDL_Palette*);
int(SDL_SetPrimarySelectionText)(const char*);
int(SDL_SetRelativeMouseMode)(enum SDL_bool);
int(SDL_SetRenderDrawBlendMode)(struct SDL_Renderer*,enum SDL_BlendMode);
int(SDL_SetRenderDrawColor)(struct SDL_Renderer*,unsigned char,unsigned char,unsigned char,unsigned char);
int(SDL_SetRenderTarget)(struct SDL_Renderer*,struct SDL_Texture*);
int(SDL_SetSurfaceAlphaMod)(struct SDL_Surface*,unsigned char);
int(SDL_SetSurfaceBlendMode)(struct SDL_Surface*,enum SDL_BlendMode);
int(SDL_SetSurfaceColorMod)(struct SDL_Surface*,unsigned char,unsigned char,unsigned char);
int(SDL_SetSurfacePalette)(struct SDL_Surface*,struct SDL_Palette*);
int(SDL_SetSurfaceRLE)(struct SDL_Surface*,int);
int(SDL_SetTextureAlphaMod)(struct SDL_Texture*,unsigned char);
int(SDL_SetTextureBlendMode)(struct SDL_Texture*,enum SDL_BlendMode);
int(SDL_SetTextureColorMod)(struct SDL_Texture*,unsigned char,unsigned char,unsigned char);
int(SDL_SetTextureScaleMode)(struct SDL_Texture*,enum SDL_ScaleMode);
int(SDL_SetTextureUserData)(struct SDL_Texture*,void*);
int(SDL_SetThreadPriority)(enum SDL_ThreadPriority);
int(SDL_SetWindowBrightness)(struct SDL_Window*,float);
int(SDL_SetWindowDisplayMode)(struct SDL_Window*,const struct SDL_DisplayMode*);
int(SDL_SetWindowFullscreen)(struct SDL_Window*,unsigned int);
int(SDL_SetWindowGammaRamp)(struct SDL_Window*,const unsigned short*,const unsigned short*,const unsigned short*);
int(SDL_SetWindowHitTest)(struct SDL_Window*,enum SDL_HitTestResult(*callback)(struct SDL_Window*,const struct SDL_Point*,void*),void*);
int(SDL_SetWindowInputFocus)(struct SDL_Window*);
int(SDL_SetWindowModalFor)(struct SDL_Window*,struct SDL_Window*);
int(SDL_SetWindowMouseRect)(struct SDL_Window*,const struct SDL_Rect*);
int(SDL_SetWindowOpacity)(struct SDL_Window*,float);
int(SDL_SetWindowShape)(struct SDL_Window*,struct SDL_Surface*,struct SDL_WindowShapeMode*);
int(SDL_ShowCursor)(int);
int(SDL_ShowMessageBox)(const struct SDL_MessageBoxData*,int*);
int(SDL_ShowSimpleMessageBox)(unsigned int,const char*,const char*,struct SDL_Window*);
int(SDL_SoftStretch)(struct SDL_Surface*,const struct SDL_Rect*,struct SDL_Surface*,const struct SDL_Rect*);
int(SDL_SoftStretchLinear)(struct SDL_Surface*,const struct SDL_Rect*,struct SDL_Surface*,const struct SDL_Rect*);
int(SDL_TryLockMutex)(struct SDL_mutex*);
int(SDL_UnlockMutex)(struct SDL_mutex*);
int(SDL_UpdateNVTexture)(struct SDL_Texture*,const struct SDL_Rect*,const unsigned char*,int,const unsigned char*,int);
int(SDL_UpdateTexture)(struct SDL_Texture*,const struct SDL_Rect*,const void*,int);
int(SDL_UpdateWindowSurface)(struct SDL_Window*);
int(SDL_UpdateWindowSurfaceRects)(struct SDL_Window*,const struct SDL_Rect*,int);
int(SDL_UpdateYUVTexture)(struct SDL_Texture*,const struct SDL_Rect*,const unsigned char*,int,const unsigned char*,int,const unsigned char*,int);
int(SDL_UpperBlit)(struct SDL_Surface*,const struct SDL_Rect*,struct SDL_Surface*,struct SDL_Rect*);
int(SDL_UpperBlitScaled)(struct SDL_Surface*,const struct SDL_Rect*,struct SDL_Surface*,struct SDL_Rect*);
int(SDL_VideoInit)(const char*);
int(SDL_Vulkan_LoadLibrary)(const char*);
int(SDL_WaitEvent)(union SDL_Event*);
int(SDL_WaitEventTimeout)(union SDL_Event*,int);
int(SDL_WarpMouseGlobal)(int,int);
int(SDL_abs)(int);
int(SDL_asprintf)(char**,const char*,...);
int(SDL_atoi)(const char*);
int(SDL_hid_exit)();
int(SDL_hid_get_feature_report)(struct SDL_hid_device_*,unsigned char*,unsigned long);
int(SDL_hid_get_indexed_string)(struct SDL_hid_device_*,int,int*,unsigned long);
int(SDL_hid_get_manufacturer_string)(struct SDL_hid_device_*,int*,unsigned long);
int(SDL_hid_get_product_string)(struct SDL_hid_device_*,int*,unsigned long);
int(SDL_hid_get_serial_number_string)(struct SDL_hid_device_*,int*,unsigned long);
int(SDL_hid_init)();
int(SDL_hid_read)(struct SDL_hid_device_*,unsigned char*,unsigned long);
int(SDL_hid_read_timeout)(struct SDL_hid_device_*,unsigned char*,unsigned long,int);
int(SDL_hid_send_feature_report)(struct SDL_hid_device_*,const unsigned char*,unsigned long);
int(SDL_hid_set_nonblocking)(struct SDL_hid_device_*,int);
int(SDL_hid_write)(struct SDL_hid_device_*,const unsigned char*,unsigned long);
int(SDL_iconv_close)(struct _SDL_iconv_t*);
int(SDL_isalnum)(int);
int(SDL_isalpha)(int);
int(SDL_isblank)(int);
int(SDL_iscntrl)(int);
int(SDL_isdigit)(int);
int(SDL_isgraph)(int);
int(SDL_islower)(int);
int(SDL_isprint)(int);
int(SDL_ispunct)(int);
int(SDL_isspace)(int);
int(SDL_isupper)(int);
int(SDL_isxdigit)(int);
int(SDL_memcmp)(const void*,const void*,unsigned long);
int(SDL_setenv)(const char*,const char*,int);
int(SDL_snprintf)(char*,unsigned long,const char*,...);
int(SDL_sscanf)(const char*,const char*,...);
int(SDL_strcasecmp)(const char*,const char*);
int(SDL_strcmp)(const char*,const char*);
int(SDL_strncasecmp)(const char*,const char*,unsigned long);
int(SDL_strncmp)(const char*,const char*,unsigned long);
int(SDL_tolower)(int);
int(SDL_toupper)(int);
int(SDL_vasprintf)(char**,const char*,__builtin_va_list);
int(SDL_vsnprintf)(char*,unsigned long,const char*,__builtin_va_list);
int(SDL_vsscanf)(const char*,const char*,__builtin_va_list);
int(SDL_wcscasecmp)(const int*,const int*);
int(SDL_wcscmp)(const int*,const int*);
int(SDL_wcsncasecmp)(const int*,const int*,unsigned long);
int(SDL_wcsncmp)(const int*,const int*,unsigned long);
long(SDL_lround)(double);
long(SDL_lroundf)(float);
long(SDL_strtol)(const char*,char**,int);
signed int(SDL_GetKeyFromName)(const char*);
signed int(SDL_GetKeyFromScancode)(enum SDL_Scancode);
signed int(SDL_JoystickGetDeviceInstanceID)(int);
signed int(SDL_JoystickInstanceID)(struct _SDL_Joystick*);
signed int(SDL_SensorGetDeviceInstanceID)(int);
signed int(SDL_SensorGetInstanceID)(struct _SDL_Sensor*);
signed long(SDL_GetTouchDevice)(int);
signed long(SDL_RWseek)(struct SDL_RWops*,signed long,int);
signed long(SDL_RWsize)(struct SDL_RWops*);
signed long(SDL_RWtell)(struct SDL_RWops*);
signed long(SDL_strtoll)(const char*,char**,int);
signed short(SDL_GameControllerGetAxis)(struct _SDL_GameController*,enum SDL_GameControllerAxis);
signed short(SDL_JoystickGetAxis)(struct _SDL_Joystick*,int);
struct SDL_AudioSpec*(SDL_LoadWAV_RW)(struct SDL_RWops*,int,struct SDL_AudioSpec*,unsigned char**,unsigned int*);
struct SDL_Cursor*(SDL_CreateColorCursor)(struct SDL_Surface*,int,int);
struct SDL_Cursor*(SDL_CreateCursor)(const unsigned char*,const unsigned char*,int,int,int,int);
struct SDL_Cursor*(SDL_CreateSystemCursor)(enum SDL_SystemCursor);
struct SDL_Cursor*(SDL_GetCursor)();
struct SDL_Cursor*(SDL_GetDefaultCursor)();
struct SDL_DisplayMode*(SDL_GetClosestDisplayMode)(int,const struct SDL_DisplayMode*,struct SDL_DisplayMode*);
struct SDL_Finger*(SDL_GetTouchFinger)(signed long,int);
struct SDL_GUID(SDL_GUIDFromString)(const char*);
struct SDL_GUID(SDL_JoystickGetDeviceGUID)(int);
struct SDL_GUID(SDL_JoystickGetGUID)(struct _SDL_Joystick*);
struct SDL_GUID(SDL_JoystickGetGUIDFromString)(const char*);
struct SDL_GameControllerButtonBind(SDL_GameControllerGetBindForAxis)(struct _SDL_GameController*,enum SDL_GameControllerAxis);
struct SDL_GameControllerButtonBind(SDL_GameControllerGetBindForButton)(struct _SDL_GameController*,enum SDL_GameControllerButton);
struct SDL_Locale*(SDL_GetPreferredLocales)();
struct SDL_Palette*(SDL_AllocPalette)(int);
struct SDL_PixelFormat*(SDL_AllocFormat)(unsigned int);
struct SDL_RWops*(SDL_AllocRW)();
struct SDL_RWops*(SDL_RWFromConstMem)(const void*,int);
struct SDL_RWops*(SDL_RWFromFP)(void*,enum SDL_bool);
struct SDL_RWops*(SDL_RWFromFile)(const char*,const char*);
struct SDL_RWops*(SDL_RWFromMem)(void*,int);
struct SDL_Renderer*(SDL_CreateRenderer)(struct SDL_Window*,int,unsigned int);
struct SDL_Renderer*(SDL_CreateSoftwareRenderer)(struct SDL_Surface*);
struct SDL_Renderer*(SDL_GetRenderer)(struct SDL_Window*);
struct SDL_Surface*(SDL_ConvertSurface)(struct SDL_Surface*,const struct SDL_PixelFormat*,unsigned int);
struct SDL_Surface*(SDL_ConvertSurfaceFormat)(struct SDL_Surface*,unsigned int,unsigned int);
struct SDL_Surface*(SDL_CreateRGBSurface)(unsigned int,int,int,int,unsigned int,unsigned int,unsigned int,unsigned int);
struct SDL_Surface*(SDL_CreateRGBSurfaceFrom)(void*,int,int,int,int,unsigned int,unsigned int,unsigned int,unsigned int);
struct SDL_Surface*(SDL_CreateRGBSurfaceWithFormat)(unsigned int,int,int,int,unsigned int);
struct SDL_Surface*(SDL_CreateRGBSurfaceWithFormatFrom)(void*,int,int,int,int,unsigned int);
struct SDL_Surface*(SDL_DuplicateSurface)(struct SDL_Surface*);
struct SDL_Surface*(SDL_GetWindowSurface)(struct SDL_Window*);
struct SDL_Surface*(SDL_LoadBMP_RW)(struct SDL_RWops*,int);
struct SDL_Texture*(SDL_CreateTexture)(struct SDL_Renderer*,unsigned int,int,int,int);
struct SDL_Texture*(SDL_CreateTextureFromSurface)(struct SDL_Renderer*,struct SDL_Surface*);
struct SDL_Texture*(SDL_GetRenderTarget)(struct SDL_Renderer*);
struct SDL_Thread*(SDL_CreateThread)(int(*fn)(void*),const char*,void*);
struct SDL_Thread*(SDL_CreateThreadWithStackSize)(int(*fn)(void*),const char*,const unsigned long,void*);
struct SDL_Window*(SDL_CreateShapedWindow)(const char*,unsigned int,unsigned int,unsigned int,unsigned int,unsigned int);
struct SDL_Window*(SDL_CreateWindow)(const char*,int,int,int,int,unsigned int);
struct SDL_Window*(SDL_CreateWindowFrom)(const void*);
struct SDL_Window*(SDL_GL_GetCurrentWindow)();
struct SDL_Window*(SDL_GetGrabbedWindow)();
struct SDL_Window*(SDL_GetKeyboardFocus)();
struct SDL_Window*(SDL_GetMouseFocus)();
struct SDL_Window*(SDL_GetWindowFromID)(unsigned int);
struct SDL_Window*(SDL_RenderGetWindow)(struct SDL_Renderer*);
struct SDL_cond*(SDL_CreateCond)();
struct SDL_hid_device_*(SDL_hid_open)(unsigned short,unsigned short,const int*);
struct SDL_hid_device_*(SDL_hid_open_path)(const char*,int);
struct SDL_hid_device_info*(SDL_hid_enumerate)(unsigned short,unsigned short);
struct SDL_mutex*(SDL_CreateMutex)();
struct SDL_semaphore*(SDL_CreateSemaphore)(unsigned int);
struct _SDL_AudioStream*(SDL_NewAudioStream)(const unsigned short,const unsigned char,const int,const unsigned short,const unsigned char,const int);
struct _SDL_GameController*(SDL_GameControllerFromInstanceID)(signed int);
struct _SDL_GameController*(SDL_GameControllerFromPlayerIndex)(int);
struct _SDL_GameController*(SDL_GameControllerOpen)(int);
struct _SDL_Haptic*(SDL_HapticOpen)(int);
struct _SDL_Haptic*(SDL_HapticOpenFromJoystick)(struct _SDL_Joystick*);
struct _SDL_Haptic*(SDL_HapticOpenFromMouse)();
struct _SDL_Joystick*(SDL_GameControllerGetJoystick)(struct _SDL_GameController*);
struct _SDL_Joystick*(SDL_JoystickFromInstanceID)(signed int);
struct _SDL_Joystick*(SDL_JoystickFromPlayerIndex)(int);
struct _SDL_Joystick*(SDL_JoystickOpen)(int);
struct _SDL_Sensor*(SDL_SensorFromInstanceID)(signed int);
struct _SDL_Sensor*(SDL_SensorOpen)(int);
struct _SDL_iconv_t*(SDL_iconv_open)(const char*,const char*);
unsigned char(SDL_EventState)(unsigned int,int);
unsigned char(SDL_GameControllerGetButton)(struct _SDL_GameController*,enum SDL_GameControllerButton);
unsigned char(SDL_JoystickGetButton)(struct _SDL_Joystick*,int);
unsigned char(SDL_JoystickGetHat)(struct _SDL_Joystick*,int);
unsigned char(SDL_ReadU8)(struct SDL_RWops*);
unsigned int(SDL_DequeueAudio)(unsigned int,void*,unsigned int);
unsigned int(SDL_GetGlobalMouseState)(int*,int*);
unsigned int(SDL_GetMouseState)(int*,int*);
unsigned int(SDL_GetQueuedAudioSize)(unsigned int);
unsigned int(SDL_GetRelativeMouseState)(int*,int*);
unsigned int(SDL_GetTicks)();
unsigned int(SDL_GetWindowFlags)(struct SDL_Window*);
unsigned int(SDL_GetWindowID)(struct SDL_Window*);
unsigned int(SDL_GetWindowPixelFormat)(struct SDL_Window*);
unsigned int(SDL_HapticQuery)(struct _SDL_Haptic*);
unsigned int(SDL_MapRGB)(const struct SDL_PixelFormat*,unsigned char,unsigned char,unsigned char);
unsigned int(SDL_MapRGBA)(const struct SDL_PixelFormat*,unsigned char,unsigned char,unsigned char,unsigned char);
unsigned int(SDL_MasksToPixelFormatEnum)(int,unsigned int,unsigned int,unsigned int,unsigned int);
unsigned int(SDL_OpenAudioDevice)(const char*,int,const struct SDL_AudioSpec*,struct SDL_AudioSpec*,int);
unsigned int(SDL_ReadBE32)(struct SDL_RWops*);
unsigned int(SDL_ReadLE32)(struct SDL_RWops*);
unsigned int(SDL_RegisterEvents)(int);
unsigned int(SDL_SemValue)(struct SDL_semaphore*);
unsigned int(SDL_TLSCreate)();
unsigned int(SDL_WasInit)(unsigned int);
unsigned int(SDL_crc32)(unsigned int,const void*,unsigned long);
unsigned int(SDL_hid_device_change_count)();
unsigned long(SDL_GetPerformanceCounter)();
unsigned long(SDL_GetPerformanceFrequency)();
unsigned long(SDL_GetThreadID)(struct SDL_Thread*);
unsigned long(SDL_GetTicks64)();
unsigned long(SDL_RWread)(struct SDL_RWops*,void*,unsigned long,unsigned long);
unsigned long(SDL_RWwrite)(struct SDL_RWops*,const void*,unsigned long,unsigned long);
unsigned long(SDL_ReadBE64)(struct SDL_RWops*);
unsigned long(SDL_ReadLE64)(struct SDL_RWops*);
unsigned long(SDL_SIMDGetAlignment)();
unsigned long(SDL_ThreadID)();
unsigned long(SDL_WriteBE16)(struct SDL_RWops*,unsigned short);
unsigned long(SDL_WriteBE32)(struct SDL_RWops*,unsigned int);
unsigned long(SDL_WriteBE64)(struct SDL_RWops*,unsigned long);
unsigned long(SDL_WriteLE16)(struct SDL_RWops*,unsigned short);
unsigned long(SDL_WriteLE32)(struct SDL_RWops*,unsigned int);
unsigned long(SDL_WriteLE64)(struct SDL_RWops*,unsigned long);
unsigned long(SDL_WriteU8)(struct SDL_RWops*,unsigned char);
unsigned long(SDL_iconv)(struct _SDL_iconv_t*,const char**,unsigned long*,char**,unsigned long*);
unsigned long(SDL_strlcat)(char*,const char*,unsigned long);
unsigned long(SDL_strlcpy)(char*,const char*,unsigned long);
unsigned long(SDL_strlen)(const char*);
unsigned long(SDL_strtoul)(const char*,char**,int);
unsigned long(SDL_strtoull)(const char*,char**,int);
unsigned long(SDL_utf8strlcpy)(char*,const char*,unsigned long);
unsigned long(SDL_utf8strlen)(const char*);
unsigned long(SDL_utf8strnlen)(const char*,unsigned long);
unsigned long(SDL_wcslcat)(int*,const int*,unsigned long);
unsigned long(SDL_wcslcpy)(int*,const int*,unsigned long);
unsigned long(SDL_wcslen)(const int*);
unsigned short(SDL_GameControllerGetFirmwareVersion)(struct _SDL_GameController*);
unsigned short(SDL_GameControllerGetProduct)(struct _SDL_GameController*);
unsigned short(SDL_GameControllerGetProductVersion)(struct _SDL_GameController*);
unsigned short(SDL_GameControllerGetVendor)(struct _SDL_GameController*);
unsigned short(SDL_JoystickGetDeviceProduct)(int);
unsigned short(SDL_JoystickGetDeviceProductVersion)(int);
unsigned short(SDL_JoystickGetDeviceVendor)(int);
unsigned short(SDL_JoystickGetFirmwareVersion)(struct _SDL_Joystick*);
unsigned short(SDL_JoystickGetProduct)(struct _SDL_Joystick*);
unsigned short(SDL_JoystickGetProductVersion)(struct _SDL_Joystick*);
unsigned short(SDL_JoystickGetVendor)(struct _SDL_Joystick*);
unsigned short(SDL_ReadBE16)(struct SDL_RWops*);
unsigned short(SDL_ReadLE16)(struct SDL_RWops*);
unsigned short(SDL_crc16)(unsigned short,const void*,unsigned long);
void*(SDL_AtomicGetPtr)(void**);
void*(SDL_AtomicSetPtr)(void**,void*);
void*(SDL_GL_CreateContext)(struct SDL_Window*);
void*(SDL_GL_GetCurrentContext)();
void*(SDL_GL_GetProcAddress)(const char*);
void*(SDL_GetTextureUserData)(struct SDL_Texture*);
void*(SDL_GetWindowData)(struct SDL_Window*,const char*);
void*(SDL_GetWindowICCProfile)(struct SDL_Window*,unsigned long*);
void*(SDL_LoadFile)(const char*,unsigned long*);
void*(SDL_LoadFile_RW)(struct SDL_RWops*,unsigned long*,int);
void*(SDL_LoadFunction)(void*,const char*);
void*(SDL_LoadObject)(const char*);
void*(SDL_Metal_CreateView)(struct SDL_Window*);
void*(SDL_Metal_GetLayer)(void*);
void*(SDL_RenderGetMetalCommandEncoder)(struct SDL_Renderer*);
void*(SDL_RenderGetMetalLayer)(struct SDL_Renderer*);
void*(SDL_SIMDAlloc)(const unsigned long);
void*(SDL_SIMDRealloc)(void*,const unsigned long);
void*(SDL_SetWindowData)(struct SDL_Window*,const char*,void*);
void*(SDL_TLSGet)(unsigned int);
void*(SDL_Vulkan_GetVkGetInstanceProcAddr)();
void*(SDL_calloc)(unsigned long,unsigned long);
void*(SDL_malloc)(unsigned long);
void*(SDL_memcpy)(void*,const void*,unsigned long);
void*(SDL_memmove)(void*,const void*,unsigned long);
void*(SDL_memset)(void*,int,unsigned long);
void*(SDL_realloc)(void*,unsigned long);
void(SDL_AddEventWatch)(int(*filter)(void*,union SDL_Event*),void*);
void(SDL_AddHintCallback)(const char*,void(*callback)(void*,const char*,const char*,const char*),void*);
void(SDL_AtomicLock)(int*);
void(SDL_AtomicUnlock)(int*);
void(SDL_AudioQuit)();
void(SDL_AudioStreamClear)(struct _SDL_AudioStream*);
void(SDL_CalculateGammaRamp)(float,unsigned short*);
void(SDL_ClearComposition)();
void(SDL_ClearError)();
void(SDL_ClearHints)();
void(SDL_ClearQueuedAudio)(unsigned int);
void(SDL_CloseAudio)();
void(SDL_CloseAudioDevice)(unsigned int);
void(SDL_DelEventWatch)(int(*filter)(void*,union SDL_Event*),void*);
void(SDL_DelHintCallback)(const char*,void(*callback)(void*,const char*,const char*,const char*),void*);
void(SDL_Delay)(unsigned int);
void(SDL_DestroyCond)(struct SDL_cond*);
void(SDL_DestroyMutex)(struct SDL_mutex*);
void(SDL_DestroyRenderer)(struct SDL_Renderer*);
void(SDL_DestroySemaphore)(struct SDL_semaphore*);
void(SDL_DestroyTexture)(struct SDL_Texture*);
void(SDL_DestroyWindow)(struct SDL_Window*);
void(SDL_DetachThread)(struct SDL_Thread*);
void(SDL_DisableScreenSaver)();
void(SDL_EnableScreenSaver)();
void(SDL_FilterEvents)(int(*filter)(void*,union SDL_Event*),void*);
void(SDL_FlushEvent)(unsigned int);
void(SDL_FlushEvents)(unsigned int,unsigned int);
void(SDL_FreeAudioStream)(struct _SDL_AudioStream*);
void(SDL_FreeCursor)(struct SDL_Cursor*);
void(SDL_FreeFormat)(struct SDL_PixelFormat*);
void(SDL_FreePalette)(struct SDL_Palette*);
void(SDL_FreeRW)(struct SDL_RWops*);
void(SDL_FreeSurface)(struct SDL_Surface*);
void(SDL_FreeWAV)(unsigned char*);
void(SDL_GL_DeleteContext)(void*);
void(SDL_GL_GetDrawableSize)(struct SDL_Window*,int*,int*);
void(SDL_GL_ResetAttributes)();
void(SDL_GL_SwapWindow)(struct SDL_Window*);
void(SDL_GL_UnloadLibrary)();
void(SDL_GUIDToString)(struct SDL_GUID,char*,int);
void(SDL_GameControllerClose)(struct _SDL_GameController*);
void(SDL_GameControllerSetPlayerIndex)(struct _SDL_GameController*,int);
void(SDL_GameControllerUpdate)();
void(SDL_GetClipRect)(struct SDL_Surface*,struct SDL_Rect*);
void(SDL_GetJoystickGUIDInfo)(struct SDL_GUID,unsigned short*,unsigned short*,unsigned short*,unsigned short*);
void(SDL_GetMemoryFunctions)(void*(*malloc_func)(unsigned long),void*(*calloc_func)(unsigned long,unsigned long),void*(*realloc_func)(void*,unsigned long),void(*free_func)(void*));
void(SDL_GetOriginalMemoryFunctions)(void*(*malloc_func)(unsigned long),void*(*calloc_func)(unsigned long,unsigned long),void*(*realloc_func)(void*,unsigned long),void(*free_func)(void*));
void(SDL_GetRGB)(unsigned int,const struct SDL_PixelFormat*,unsigned char*,unsigned char*,unsigned char*);
void(SDL_GetRGBA)(unsigned int,const struct SDL_PixelFormat*,unsigned char*,unsigned char*,unsigned char*,unsigned char*);
void(SDL_GetVersion)(struct SDL_version*);
void(SDL_GetWindowMaximumSize)(struct SDL_Window*,int*,int*);
void(SDL_GetWindowMinimumSize)(struct SDL_Window*,int*,int*);
void(SDL_GetWindowPosition)(struct SDL_Window*,int*,int*);
void(SDL_GetWindowSize)(struct SDL_Window*,int*,int*);
void(SDL_GetWindowSizeInPixels)(struct SDL_Window*,int*,int*);
void(SDL_HapticClose)(struct _SDL_Haptic*);
void(SDL_HapticDestroyEffect)(struct _SDL_Haptic*,int);
void(SDL_HideWindow)(struct SDL_Window*);
void(SDL_JoystickClose)(struct _SDL_Joystick*);
void(SDL_JoystickGetGUIDString)(struct SDL_GUID,char*,int);
void(SDL_JoystickSetPlayerIndex)(struct _SDL_Joystick*,int);
void(SDL_JoystickUpdate)();
void(SDL_LockAudio)();
void(SDL_LockAudioDevice)(unsigned int);
void(SDL_LockJoysticks)();
void(SDL_LockSensors)();
void(SDL_Log)(const char*,...);
void(SDL_LogCritical)(int,const char*,...);
void(SDL_LogDebug)(int,const char*,...);
void(SDL_LogError)(int,const char*,...);
void(SDL_LogGetOutputFunction)(void(*callback)(void*,int,enum SDL_LogPriority,const char*),void**);
void(SDL_LogInfo)(int,const char*,...);
void(SDL_LogMessage)(int,enum SDL_LogPriority,const char*,...);
void(SDL_LogMessageV)(int,enum SDL_LogPriority,const char*,__builtin_va_list);
void(SDL_LogResetPriorities)();
void(SDL_LogSetAllPriority)(enum SDL_LogPriority);
void(SDL_LogSetOutputFunction)(void(*callback)(void*,int,enum SDL_LogPriority,const char*),void*);
void(SDL_LogSetPriority)(int,enum SDL_LogPriority);
void(SDL_LogVerbose)(int,const char*,...);
void(SDL_LogWarn)(int,const char*,...);
void(SDL_MaximizeWindow)(struct SDL_Window*);
void(SDL_MemoryBarrierAcquireFunction)();
void(SDL_MemoryBarrierReleaseFunction)();
void(SDL_Metal_DestroyView)(void*);
void(SDL_Metal_GetDrawableSize)(struct SDL_Window*,int*,int*);
void(SDL_MinimizeWindow)(struct SDL_Window*);
void(SDL_MixAudio)(unsigned char*,const unsigned char*,unsigned int,int);
void(SDL_MixAudioFormat)(unsigned char*,const unsigned char*,unsigned short,unsigned int,int);
void(SDL_OnApplicationDidBecomeActive)();
void(SDL_OnApplicationDidEnterBackground)();
void(SDL_OnApplicationDidReceiveMemoryWarning)();
void(SDL_OnApplicationWillEnterForeground)();
void(SDL_OnApplicationWillResignActive)();
void(SDL_OnApplicationWillTerminate)();
void(SDL_PauseAudio)(int);
void(SDL_PauseAudioDevice)(unsigned int,int);
void(SDL_PumpEvents)();
void(SDL_Quit)();
void(SDL_QuitSubSystem)(unsigned int);
void(SDL_RaiseWindow)(struct SDL_Window*);
void(SDL_RenderGetClipRect)(struct SDL_Renderer*,struct SDL_Rect*);
void(SDL_RenderGetLogicalSize)(struct SDL_Renderer*,int*,int*);
void(SDL_RenderGetScale)(struct SDL_Renderer*,float*,float*);
void(SDL_RenderGetViewport)(struct SDL_Renderer*,struct SDL_Rect*);
void(SDL_RenderLogicalToWindow)(struct SDL_Renderer*,float,float,int*,int*);
void(SDL_RenderPresent)(struct SDL_Renderer*);
void(SDL_RenderWindowToLogical)(struct SDL_Renderer*,int,int,float*,float*);
void(SDL_ResetAssertionReport)();
void(SDL_ResetKeyboard)();
void(SDL_RestoreWindow)(struct SDL_Window*);
void(SDL_SIMDFree)(void*);
void(SDL_SensorClose)(struct _SDL_Sensor*);
void(SDL_SensorUpdate)();
void(SDL_SetAssertionHandler)(enum SDL_AssertState(*handler)(const struct SDL_AssertData*,void*),void*);
void(SDL_SetCursor)(struct SDL_Cursor*);
void(SDL_SetEventFilter)(int(*filter)(void*,union SDL_Event*),void*);
void(SDL_SetMainReady)();
void(SDL_SetModState)(enum SDL_Keymod);
void(SDL_SetTextInputRect)(const struct SDL_Rect*);
void(SDL_SetWindowAlwaysOnTop)(struct SDL_Window*,enum SDL_bool);
void(SDL_SetWindowBordered)(struct SDL_Window*,enum SDL_bool);
void(SDL_SetWindowGrab)(struct SDL_Window*,enum SDL_bool);
void(SDL_SetWindowIcon)(struct SDL_Window*,struct SDL_Surface*);
void(SDL_SetWindowKeyboardGrab)(struct SDL_Window*,enum SDL_bool);
void(SDL_SetWindowMaximumSize)(struct SDL_Window*,int,int);
void(SDL_SetWindowMinimumSize)(struct SDL_Window*,int,int);
void(SDL_SetWindowMouseGrab)(struct SDL_Window*,enum SDL_bool);
void(SDL_SetWindowPosition)(struct SDL_Window*,int,int);
void(SDL_SetWindowResizable)(struct SDL_Window*,enum SDL_bool);
void(SDL_SetWindowSize)(struct SDL_Window*,int,int);
void(SDL_SetWindowTitle)(struct SDL_Window*,const char*);
void(SDL_SetYUVConversionMode)(enum SDL_YUV_CONVERSION_MODE);
void(SDL_ShowWindow)(struct SDL_Window*);
void(SDL_StartTextInput)();
void(SDL_StopTextInput)();
void(SDL_TLSCleanup)();
void(SDL_UnionFRect)(const struct SDL_FRect*,const struct SDL_FRect*,struct SDL_FRect*);
void(SDL_UnionRect)(const struct SDL_Rect*,const struct SDL_Rect*,struct SDL_Rect*);
void(SDL_UnloadObject)(void*);
void(SDL_UnlockAudio)();
void(SDL_UnlockAudioDevice)(unsigned int);
void(SDL_UnlockJoysticks)();
void(SDL_UnlockSensors)();
void(SDL_UnlockSurface)(struct SDL_Surface*);
void(SDL_UnlockTexture)(struct SDL_Texture*);
void(SDL_VideoQuit)();
void(SDL_Vulkan_GetDrawableSize)(struct SDL_Window*,int*,int*);
void(SDL_Vulkan_UnloadLibrary)();
void(SDL_WaitThread)(struct SDL_Thread*,int*);
void(SDL_WarpMouseInWindow)(struct SDL_Window*,int,int);
void(SDL_free)(void*);
void(SDL_hid_ble_scan)(enum SDL_bool);
void(SDL_hid_close)(struct SDL_hid_device_*);
void(SDL_hid_free_enumeration)(struct SDL_hid_device_info*);
]])
				local CLIB = setmetatable({}, {__index = function(_, k)
					local ok, val = pcall(function() return lib[k] end)
					if ok then
						return val
					end
				end})
			library = {
	AddEventWatch = CLIB.SDL_AddEventWatch,
	AddHintCallback = CLIB.SDL_AddHintCallback,
	AddTimer = CLIB.SDL_AddTimer,
	AllocFormat = CLIB.SDL_AllocFormat,
	AllocPalette = CLIB.SDL_AllocPalette,
	AllocRW = CLIB.SDL_AllocRW,
	AtomicAdd = CLIB.SDL_AtomicAdd,
	AtomicCAS = CLIB.SDL_AtomicCAS,
	AtomicCASPtr = CLIB.SDL_AtomicCASPtr,
	AtomicGet = CLIB.SDL_AtomicGet,
	AtomicGetPtr = CLIB.SDL_AtomicGetPtr,
	AtomicLock = CLIB.SDL_AtomicLock,
	AtomicSet = CLIB.SDL_AtomicSet,
	AtomicSetPtr = CLIB.SDL_AtomicSetPtr,
	AtomicTryLock = CLIB.SDL_AtomicTryLock,
	AtomicUnlock = CLIB.SDL_AtomicUnlock,
	AudioInit = CLIB.SDL_AudioInit,
	AudioQuit = CLIB.SDL_AudioQuit,
	AudioStreamAvailable = CLIB.SDL_AudioStreamAvailable,
	AudioStreamClear = CLIB.SDL_AudioStreamClear,
	AudioStreamFlush = CLIB.SDL_AudioStreamFlush,
	AudioStreamGet = CLIB.SDL_AudioStreamGet,
	AudioStreamPut = CLIB.SDL_AudioStreamPut,
	BuildAudioCVT = CLIB.SDL_BuildAudioCVT,
	CalculateGammaRamp = CLIB.SDL_CalculateGammaRamp,
	CaptureMouse = CLIB.SDL_CaptureMouse,
	ClearComposition = CLIB.SDL_ClearComposition,
	ClearError = CLIB.SDL_ClearError,
	ClearHints = CLIB.SDL_ClearHints,
	ClearQueuedAudio = CLIB.SDL_ClearQueuedAudio,
	CloseAudio = CLIB.SDL_CloseAudio,
	CloseAudioDevice = CLIB.SDL_CloseAudioDevice,
	ComposeCustomBlendMode = CLIB.SDL_ComposeCustomBlendMode,
	CondBroadcast = CLIB.SDL_CondBroadcast,
	CondSignal = CLIB.SDL_CondSignal,
	CondWait = CLIB.SDL_CondWait,
	CondWaitTimeout = CLIB.SDL_CondWaitTimeout,
	ConvertAudio = CLIB.SDL_ConvertAudio,
	ConvertPixels = CLIB.SDL_ConvertPixels,
	ConvertSurface = CLIB.SDL_ConvertSurface,
	ConvertSurfaceFormat = CLIB.SDL_ConvertSurfaceFormat,
	CreateColorCursor = CLIB.SDL_CreateColorCursor,
	CreateCond = CLIB.SDL_CreateCond,
	CreateCursor = CLIB.SDL_CreateCursor,
	CreateMutex = CLIB.SDL_CreateMutex,
	CreateRGBSurface = CLIB.SDL_CreateRGBSurface,
	CreateRGBSurfaceFrom = CLIB.SDL_CreateRGBSurfaceFrom,
	CreateRGBSurfaceWithFormat = CLIB.SDL_CreateRGBSurfaceWithFormat,
	CreateRGBSurfaceWithFormatFrom = CLIB.SDL_CreateRGBSurfaceWithFormatFrom,
	CreateRenderer = CLIB.SDL_CreateRenderer,
	CreateSemaphore = CLIB.SDL_CreateSemaphore,
	CreateShapedWindow = CLIB.SDL_CreateShapedWindow,
	CreateSoftwareRenderer = CLIB.SDL_CreateSoftwareRenderer,
	CreateSystemCursor = CLIB.SDL_CreateSystemCursor,
	CreateTexture = CLIB.SDL_CreateTexture,
	CreateTextureFromSurface = CLIB.SDL_CreateTextureFromSurface,
	CreateThread = CLIB.SDL_CreateThread,
	CreateThreadWithStackSize = CLIB.SDL_CreateThreadWithStackSize,
	CreateWindow = CLIB.SDL_CreateWindow,
	CreateWindowAndRenderer = CLIB.SDL_CreateWindowAndRenderer,
	CreateWindowFrom = CLIB.SDL_CreateWindowFrom,
	DelEventWatch = CLIB.SDL_DelEventWatch,
	DelHintCallback = CLIB.SDL_DelHintCallback,
	Delay = CLIB.SDL_Delay,
	DequeueAudio = CLIB.SDL_DequeueAudio,
	DestroyCond = CLIB.SDL_DestroyCond,
	DestroyMutex = CLIB.SDL_DestroyMutex,
	DestroyRenderer = CLIB.SDL_DestroyRenderer,
	DestroySemaphore = CLIB.SDL_DestroySemaphore,
	DestroyTexture = CLIB.SDL_DestroyTexture,
	DestroyWindow = CLIB.SDL_DestroyWindow,
	DetachThread = CLIB.SDL_DetachThread,
	DisableScreenSaver = CLIB.SDL_DisableScreenSaver,
	DuplicateSurface = CLIB.SDL_DuplicateSurface,
	EnableScreenSaver = CLIB.SDL_EnableScreenSaver,
	EncloseFPoints = CLIB.SDL_EncloseFPoints,
	EnclosePoints = CLIB.SDL_EnclosePoints,
	Error = CLIB.SDL_Error,
	EventState = CLIB.SDL_EventState,
	FillRect = CLIB.SDL_FillRect,
	FillRects = CLIB.SDL_FillRects,
	FilterEvents = CLIB.SDL_FilterEvents,
	FlashWindow = CLIB.SDL_FlashWindow,
	FlushEvent = CLIB.SDL_FlushEvent,
	FlushEvents = CLIB.SDL_FlushEvents,
	FreeAudioStream = CLIB.SDL_FreeAudioStream,
	FreeCursor = CLIB.SDL_FreeCursor,
	FreeFormat = CLIB.SDL_FreeFormat,
	FreePalette = CLIB.SDL_FreePalette,
	FreeRW = CLIB.SDL_FreeRW,
	FreeSurface = CLIB.SDL_FreeSurface,
	FreeWAV = CLIB.SDL_FreeWAV,
	GL_BindTexture = CLIB.SDL_GL_BindTexture,
	GL_CreateContext = CLIB.SDL_GL_CreateContext,
	GL_DeleteContext = CLIB.SDL_GL_DeleteContext,
	GL_ExtensionSupported = CLIB.SDL_GL_ExtensionSupported,
	GL_GetAttribute = CLIB.SDL_GL_GetAttribute,
	GL_GetCurrentContext = CLIB.SDL_GL_GetCurrentContext,
	GL_GetCurrentWindow = CLIB.SDL_GL_GetCurrentWindow,
	GL_GetDrawableSize = CLIB.SDL_GL_GetDrawableSize,
	GL_GetProcAddress = CLIB.SDL_GL_GetProcAddress,
	GL_GetSwapInterval = CLIB.SDL_GL_GetSwapInterval,
	GL_LoadLibrary = CLIB.SDL_GL_LoadLibrary,
	GL_MakeCurrent = CLIB.SDL_GL_MakeCurrent,
	GL_ResetAttributes = CLIB.SDL_GL_ResetAttributes,
	GL_SetAttribute = CLIB.SDL_GL_SetAttribute,
	GL_SetSwapInterval = CLIB.SDL_GL_SetSwapInterval,
	GL_SwapWindow = CLIB.SDL_GL_SwapWindow,
	GL_UnbindTexture = CLIB.SDL_GL_UnbindTexture,
	GL_UnloadLibrary = CLIB.SDL_GL_UnloadLibrary,
	GUIDFromString = CLIB.SDL_GUIDFromString,
	GUIDToString = CLIB.SDL_GUIDToString,
	GameControllerAddMapping = CLIB.SDL_GameControllerAddMapping,
	GameControllerAddMappingsFromRW = CLIB.SDL_GameControllerAddMappingsFromRW,
	GameControllerClose = CLIB.SDL_GameControllerClose,
	GameControllerEventState = CLIB.SDL_GameControllerEventState,
	GameControllerFromInstanceID = CLIB.SDL_GameControllerFromInstanceID,
	GameControllerFromPlayerIndex = CLIB.SDL_GameControllerFromPlayerIndex,
	GameControllerGetAppleSFSymbolsNameForAxis = CLIB.SDL_GameControllerGetAppleSFSymbolsNameForAxis,
	GameControllerGetAppleSFSymbolsNameForButton = CLIB.SDL_GameControllerGetAppleSFSymbolsNameForButton,
	GameControllerGetAttached = CLIB.SDL_GameControllerGetAttached,
	GameControllerGetAxis = CLIB.SDL_GameControllerGetAxis,
	GameControllerGetAxisFromString = CLIB.SDL_GameControllerGetAxisFromString,
	GameControllerGetBindForAxis = CLIB.SDL_GameControllerGetBindForAxis,
	GameControllerGetBindForButton = CLIB.SDL_GameControllerGetBindForButton,
	GameControllerGetButton = CLIB.SDL_GameControllerGetButton,
	GameControllerGetButtonFromString = CLIB.SDL_GameControllerGetButtonFromString,
	GameControllerGetFirmwareVersion = CLIB.SDL_GameControllerGetFirmwareVersion,
	GameControllerGetJoystick = CLIB.SDL_GameControllerGetJoystick,
	GameControllerGetNumTouchpadFingers = CLIB.SDL_GameControllerGetNumTouchpadFingers,
	GameControllerGetNumTouchpads = CLIB.SDL_GameControllerGetNumTouchpads,
	GameControllerGetPlayerIndex = CLIB.SDL_GameControllerGetPlayerIndex,
	GameControllerGetProduct = CLIB.SDL_GameControllerGetProduct,
	GameControllerGetProductVersion = CLIB.SDL_GameControllerGetProductVersion,
	GameControllerGetSensorData = CLIB.SDL_GameControllerGetSensorData,
	GameControllerGetSensorDataRate = CLIB.SDL_GameControllerGetSensorDataRate,
	GameControllerGetSerial = CLIB.SDL_GameControllerGetSerial,
	GameControllerGetStringForAxis = CLIB.SDL_GameControllerGetStringForAxis,
	GameControllerGetStringForButton = CLIB.SDL_GameControllerGetStringForButton,
	GameControllerGetTouchpadFinger = CLIB.SDL_GameControllerGetTouchpadFinger,
	GameControllerGetType = CLIB.SDL_GameControllerGetType,
	GameControllerGetVendor = CLIB.SDL_GameControllerGetVendor,
	GameControllerHasAxis = CLIB.SDL_GameControllerHasAxis,
	GameControllerHasButton = CLIB.SDL_GameControllerHasButton,
	GameControllerHasLED = CLIB.SDL_GameControllerHasLED,
	GameControllerHasRumble = CLIB.SDL_GameControllerHasRumble,
	GameControllerHasRumbleTriggers = CLIB.SDL_GameControllerHasRumbleTriggers,
	GameControllerHasSensor = CLIB.SDL_GameControllerHasSensor,
	GameControllerIsSensorEnabled = CLIB.SDL_GameControllerIsSensorEnabled,
	GameControllerMapping = CLIB.SDL_GameControllerMapping,
	GameControllerMappingForDeviceIndex = CLIB.SDL_GameControllerMappingForDeviceIndex,
	GameControllerMappingForGUID = CLIB.SDL_GameControllerMappingForGUID,
	GameControllerMappingForIndex = CLIB.SDL_GameControllerMappingForIndex,
	GameControllerName = CLIB.SDL_GameControllerName,
	GameControllerNameForIndex = CLIB.SDL_GameControllerNameForIndex,
	GameControllerNumMappings = CLIB.SDL_GameControllerNumMappings,
	GameControllerOpen = CLIB.SDL_GameControllerOpen,
	GameControllerPath = CLIB.SDL_GameControllerPath,
	GameControllerPathForIndex = CLIB.SDL_GameControllerPathForIndex,
	GameControllerRumble = CLIB.SDL_GameControllerRumble,
	GameControllerRumbleTriggers = CLIB.SDL_GameControllerRumbleTriggers,
	GameControllerSendEffect = CLIB.SDL_GameControllerSendEffect,
	GameControllerSetLED = CLIB.SDL_GameControllerSetLED,
	GameControllerSetPlayerIndex = CLIB.SDL_GameControllerSetPlayerIndex,
	GameControllerSetSensorEnabled = CLIB.SDL_GameControllerSetSensorEnabled,
	GameControllerTypeForIndex = CLIB.SDL_GameControllerTypeForIndex,
	GameControllerUpdate = CLIB.SDL_GameControllerUpdate,
	GetAssertionHandler = CLIB.SDL_GetAssertionHandler,
	GetAssertionReport = CLIB.SDL_GetAssertionReport,
	GetAudioDeviceName = CLIB.SDL_GetAudioDeviceName,
	GetAudioDeviceSpec = CLIB.SDL_GetAudioDeviceSpec,
	GetAudioDeviceStatus = CLIB.SDL_GetAudioDeviceStatus,
	GetAudioDriver = CLIB.SDL_GetAudioDriver,
	GetAudioStatus = CLIB.SDL_GetAudioStatus,
	GetBasePath = CLIB.SDL_GetBasePath,
	GetCPUCacheLineSize = CLIB.SDL_GetCPUCacheLineSize,
	GetCPUCount = CLIB.SDL_GetCPUCount,
	GetClipRect = CLIB.SDL_GetClipRect,
	GetClipboardText = CLIB.SDL_GetClipboardText,
	GetClosestDisplayMode = CLIB.SDL_GetClosestDisplayMode,
	GetColorKey = CLIB.SDL_GetColorKey,
	GetCurrentAudioDriver = CLIB.SDL_GetCurrentAudioDriver,
	GetCurrentDisplayMode = CLIB.SDL_GetCurrentDisplayMode,
	GetCurrentVideoDriver = CLIB.SDL_GetCurrentVideoDriver,
	GetCursor = CLIB.SDL_GetCursor,
	GetDefaultAssertionHandler = CLIB.SDL_GetDefaultAssertionHandler,
	GetDefaultAudioInfo = CLIB.SDL_GetDefaultAudioInfo,
	GetDefaultCursor = CLIB.SDL_GetDefaultCursor,
	GetDesktopDisplayMode = CLIB.SDL_GetDesktopDisplayMode,
	GetDisplayBounds = CLIB.SDL_GetDisplayBounds,
	GetDisplayDPI = CLIB.SDL_GetDisplayDPI,
	GetDisplayMode = CLIB.SDL_GetDisplayMode,
	GetDisplayName = CLIB.SDL_GetDisplayName,
	GetDisplayOrientation = CLIB.SDL_GetDisplayOrientation,
	GetDisplayUsableBounds = CLIB.SDL_GetDisplayUsableBounds,
	GetError = CLIB.SDL_GetError,
	GetErrorMsg = CLIB.SDL_GetErrorMsg,
	GetEventFilter = CLIB.SDL_GetEventFilter,
	GetGlobalMouseState = CLIB.SDL_GetGlobalMouseState,
	GetGrabbedWindow = CLIB.SDL_GetGrabbedWindow,
	GetHint = CLIB.SDL_GetHint,
	GetHintBoolean = CLIB.SDL_GetHintBoolean,
	GetJoystickGUIDInfo = CLIB.SDL_GetJoystickGUIDInfo,
	GetKeyFromName = CLIB.SDL_GetKeyFromName,
	GetKeyFromScancode = CLIB.SDL_GetKeyFromScancode,
	GetKeyName = CLIB.SDL_GetKeyName,
	GetKeyboardFocus = CLIB.SDL_GetKeyboardFocus,
	GetKeyboardState = CLIB.SDL_GetKeyboardState,
	GetMemoryFunctions = CLIB.SDL_GetMemoryFunctions,
	GetModState = CLIB.SDL_GetModState,
	GetMouseFocus = CLIB.SDL_GetMouseFocus,
	GetMouseState = CLIB.SDL_GetMouseState,
	GetNumAllocations = CLIB.SDL_GetNumAllocations,
	GetNumAudioDevices = CLIB.SDL_GetNumAudioDevices,
	GetNumAudioDrivers = CLIB.SDL_GetNumAudioDrivers,
	GetNumDisplayModes = CLIB.SDL_GetNumDisplayModes,
	GetNumRenderDrivers = CLIB.SDL_GetNumRenderDrivers,
	GetNumTouchDevices = CLIB.SDL_GetNumTouchDevices,
	GetNumTouchFingers = CLIB.SDL_GetNumTouchFingers,
	GetNumVideoDisplays = CLIB.SDL_GetNumVideoDisplays,
	GetNumVideoDrivers = CLIB.SDL_GetNumVideoDrivers,
	GetOriginalMemoryFunctions = CLIB.SDL_GetOriginalMemoryFunctions,
	GetPerformanceCounter = CLIB.SDL_GetPerformanceCounter,
	GetPerformanceFrequency = CLIB.SDL_GetPerformanceFrequency,
	GetPixelFormatName = CLIB.SDL_GetPixelFormatName,
	GetPlatform = CLIB.SDL_GetPlatform,
	GetPointDisplayIndex = CLIB.SDL_GetPointDisplayIndex,
	GetPowerInfo = CLIB.SDL_GetPowerInfo,
	GetPrefPath = CLIB.SDL_GetPrefPath,
	GetPreferredLocales = CLIB.SDL_GetPreferredLocales,
	GetPrimarySelectionText = CLIB.SDL_GetPrimarySelectionText,
	GetQueuedAudioSize = CLIB.SDL_GetQueuedAudioSize,
	GetRGB = CLIB.SDL_GetRGB,
	GetRGBA = CLIB.SDL_GetRGBA,
	GetRectDisplayIndex = CLIB.SDL_GetRectDisplayIndex,
	GetRelativeMouseMode = CLIB.SDL_GetRelativeMouseMode,
	GetRelativeMouseState = CLIB.SDL_GetRelativeMouseState,
	GetRenderDrawBlendMode = CLIB.SDL_GetRenderDrawBlendMode,
	GetRenderDrawColor = CLIB.SDL_GetRenderDrawColor,
	GetRenderDriverInfo = CLIB.SDL_GetRenderDriverInfo,
	GetRenderTarget = CLIB.SDL_GetRenderTarget,
	GetRenderer = CLIB.SDL_GetRenderer,
	GetRendererInfo = CLIB.SDL_GetRendererInfo,
	GetRendererOutputSize = CLIB.SDL_GetRendererOutputSize,
	GetRevision = CLIB.SDL_GetRevision,
	GetRevisionNumber = CLIB.SDL_GetRevisionNumber,
	GetScancodeFromKey = CLIB.SDL_GetScancodeFromKey,
	GetScancodeFromName = CLIB.SDL_GetScancodeFromName,
	GetScancodeName = CLIB.SDL_GetScancodeName,
	GetShapedWindowMode = CLIB.SDL_GetShapedWindowMode,
	GetSurfaceAlphaMod = CLIB.SDL_GetSurfaceAlphaMod,
	GetSurfaceBlendMode = CLIB.SDL_GetSurfaceBlendMode,
	GetSurfaceColorMod = CLIB.SDL_GetSurfaceColorMod,
	GetSystemRAM = CLIB.SDL_GetSystemRAM,
	GetTextureAlphaMod = CLIB.SDL_GetTextureAlphaMod,
	GetTextureBlendMode = CLIB.SDL_GetTextureBlendMode,
	GetTextureColorMod = CLIB.SDL_GetTextureColorMod,
	GetTextureScaleMode = CLIB.SDL_GetTextureScaleMode,
	GetTextureUserData = CLIB.SDL_GetTextureUserData,
	GetThreadID = CLIB.SDL_GetThreadID,
	GetThreadName = CLIB.SDL_GetThreadName,
	GetTicks = CLIB.SDL_GetTicks,
	GetTicks64 = CLIB.SDL_GetTicks64,
	GetTouchDevice = CLIB.SDL_GetTouchDevice,
	GetTouchDeviceType = CLIB.SDL_GetTouchDeviceType,
	GetTouchFinger = CLIB.SDL_GetTouchFinger,
	GetTouchName = CLIB.SDL_GetTouchName,
	GetVersion = CLIB.SDL_GetVersion,
	GetVideoDriver = CLIB.SDL_GetVideoDriver,
	GetWindowBordersSize = CLIB.SDL_GetWindowBordersSize,
	GetWindowBrightness = CLIB.SDL_GetWindowBrightness,
	GetWindowData = CLIB.SDL_GetWindowData,
	GetWindowDisplayIndex = CLIB.SDL_GetWindowDisplayIndex,
	GetWindowDisplayMode = CLIB.SDL_GetWindowDisplayMode,
	GetWindowFlags = CLIB.SDL_GetWindowFlags,
	GetWindowFromID = CLIB.SDL_GetWindowFromID,
	GetWindowGammaRamp = CLIB.SDL_GetWindowGammaRamp,
	GetWindowGrab = CLIB.SDL_GetWindowGrab,
	GetWindowICCProfile = CLIB.SDL_GetWindowICCProfile,
	GetWindowID = CLIB.SDL_GetWindowID,
	GetWindowKeyboardGrab = CLIB.SDL_GetWindowKeyboardGrab,
	GetWindowMaximumSize = CLIB.SDL_GetWindowMaximumSize,
	GetWindowMinimumSize = CLIB.SDL_GetWindowMinimumSize,
	GetWindowMouseGrab = CLIB.SDL_GetWindowMouseGrab,
	GetWindowMouseRect = CLIB.SDL_GetWindowMouseRect,
	GetWindowOpacity = CLIB.SDL_GetWindowOpacity,
	GetWindowPixelFormat = CLIB.SDL_GetWindowPixelFormat,
	GetWindowPosition = CLIB.SDL_GetWindowPosition,
	GetWindowSize = CLIB.SDL_GetWindowSize,
	GetWindowSizeInPixels = CLIB.SDL_GetWindowSizeInPixels,
	GetWindowSurface = CLIB.SDL_GetWindowSurface,
	GetWindowTitle = CLIB.SDL_GetWindowTitle,
	GetWindowWMInfo = CLIB.SDL_GetWindowWMInfo,
	GetYUVConversionMode = CLIB.SDL_GetYUVConversionMode,
	GetYUVConversionModeForResolution = CLIB.SDL_GetYUVConversionModeForResolution,
	HapticClose = CLIB.SDL_HapticClose,
	HapticDestroyEffect = CLIB.SDL_HapticDestroyEffect,
	HapticEffectSupported = CLIB.SDL_HapticEffectSupported,
	HapticGetEffectStatus = CLIB.SDL_HapticGetEffectStatus,
	HapticIndex = CLIB.SDL_HapticIndex,
	HapticName = CLIB.SDL_HapticName,
	HapticNewEffect = CLIB.SDL_HapticNewEffect,
	HapticNumAxes = CLIB.SDL_HapticNumAxes,
	HapticNumEffects = CLIB.SDL_HapticNumEffects,
	HapticNumEffectsPlaying = CLIB.SDL_HapticNumEffectsPlaying,
	HapticOpen = CLIB.SDL_HapticOpen,
	HapticOpenFromJoystick = CLIB.SDL_HapticOpenFromJoystick,
	HapticOpenFromMouse = CLIB.SDL_HapticOpenFromMouse,
	HapticOpened = CLIB.SDL_HapticOpened,
	HapticPause = CLIB.SDL_HapticPause,
	HapticQuery = CLIB.SDL_HapticQuery,
	HapticRumbleInit = CLIB.SDL_HapticRumbleInit,
	HapticRumblePlay = CLIB.SDL_HapticRumblePlay,
	HapticRumbleStop = CLIB.SDL_HapticRumbleStop,
	HapticRumbleSupported = CLIB.SDL_HapticRumbleSupported,
	HapticRunEffect = CLIB.SDL_HapticRunEffect,
	HapticSetAutocenter = CLIB.SDL_HapticSetAutocenter,
	HapticSetGain = CLIB.SDL_HapticSetGain,
	HapticStopAll = CLIB.SDL_HapticStopAll,
	HapticStopEffect = CLIB.SDL_HapticStopEffect,
	HapticUnpause = CLIB.SDL_HapticUnpause,
	HapticUpdateEffect = CLIB.SDL_HapticUpdateEffect,
	Has3DNow = CLIB.SDL_Has3DNow,
	HasARMSIMD = CLIB.SDL_HasARMSIMD,
	HasAVX = CLIB.SDL_HasAVX,
	HasAVX2 = CLIB.SDL_HasAVX2,
	HasAVX512F = CLIB.SDL_HasAVX512F,
	HasAltiVec = CLIB.SDL_HasAltiVec,
	HasClipboardText = CLIB.SDL_HasClipboardText,
	HasColorKey = CLIB.SDL_HasColorKey,
	HasEvent = CLIB.SDL_HasEvent,
	HasEvents = CLIB.SDL_HasEvents,
	HasIntersection = CLIB.SDL_HasIntersection,
	HasIntersectionF = CLIB.SDL_HasIntersectionF,
	HasLASX = CLIB.SDL_HasLASX,
	HasLSX = CLIB.SDL_HasLSX,
	HasMMX = CLIB.SDL_HasMMX,
	HasNEON = CLIB.SDL_HasNEON,
	HasPrimarySelectionText = CLIB.SDL_HasPrimarySelectionText,
	HasRDTSC = CLIB.SDL_HasRDTSC,
	HasSSE = CLIB.SDL_HasSSE,
	HasSSE2 = CLIB.SDL_HasSSE2,
	HasSSE3 = CLIB.SDL_HasSSE3,
	HasSSE41 = CLIB.SDL_HasSSE41,
	HasSSE42 = CLIB.SDL_HasSSE42,
	HasScreenKeyboardSupport = CLIB.SDL_HasScreenKeyboardSupport,
	HasSurfaceRLE = CLIB.SDL_HasSurfaceRLE,
	HideWindow = CLIB.SDL_HideWindow,
	Init = CLIB.SDL_Init,
	InitSubSystem = CLIB.SDL_InitSubSystem,
	IntersectFRect = CLIB.SDL_IntersectFRect,
	IntersectFRectAndLine = CLIB.SDL_IntersectFRectAndLine,
	IntersectRect = CLIB.SDL_IntersectRect,
	IntersectRectAndLine = CLIB.SDL_IntersectRectAndLine,
	IsGameController = CLIB.SDL_IsGameController,
	IsScreenKeyboardShown = CLIB.SDL_IsScreenKeyboardShown,
	IsScreenSaverEnabled = CLIB.SDL_IsScreenSaverEnabled,
	IsShapedWindow = CLIB.SDL_IsShapedWindow,
	IsTablet = CLIB.SDL_IsTablet,
	IsTextInputActive = CLIB.SDL_IsTextInputActive,
	IsTextInputShown = CLIB.SDL_IsTextInputShown,
	JoystickAttachVirtual = CLIB.SDL_JoystickAttachVirtual,
	JoystickAttachVirtualEx = CLIB.SDL_JoystickAttachVirtualEx,
	JoystickClose = CLIB.SDL_JoystickClose,
	JoystickCurrentPowerLevel = CLIB.SDL_JoystickCurrentPowerLevel,
	JoystickDetachVirtual = CLIB.SDL_JoystickDetachVirtual,
	JoystickEventState = CLIB.SDL_JoystickEventState,
	JoystickFromInstanceID = CLIB.SDL_JoystickFromInstanceID,
	JoystickFromPlayerIndex = CLIB.SDL_JoystickFromPlayerIndex,
	JoystickGetAttached = CLIB.SDL_JoystickGetAttached,
	JoystickGetAxis = CLIB.SDL_JoystickGetAxis,
	JoystickGetAxisInitialState = CLIB.SDL_JoystickGetAxisInitialState,
	JoystickGetBall = CLIB.SDL_JoystickGetBall,
	JoystickGetButton = CLIB.SDL_JoystickGetButton,
	JoystickGetDeviceGUID = CLIB.SDL_JoystickGetDeviceGUID,
	JoystickGetDeviceInstanceID = CLIB.SDL_JoystickGetDeviceInstanceID,
	JoystickGetDevicePlayerIndex = CLIB.SDL_JoystickGetDevicePlayerIndex,
	JoystickGetDeviceProduct = CLIB.SDL_JoystickGetDeviceProduct,
	JoystickGetDeviceProductVersion = CLIB.SDL_JoystickGetDeviceProductVersion,
	JoystickGetDeviceType = CLIB.SDL_JoystickGetDeviceType,
	JoystickGetDeviceVendor = CLIB.SDL_JoystickGetDeviceVendor,
	JoystickGetFirmwareVersion = CLIB.SDL_JoystickGetFirmwareVersion,
	JoystickGetGUID = CLIB.SDL_JoystickGetGUID,
	JoystickGetGUIDFromString = CLIB.SDL_JoystickGetGUIDFromString,
	JoystickGetGUIDString = CLIB.SDL_JoystickGetGUIDString,
	JoystickGetHat = CLIB.SDL_JoystickGetHat,
	JoystickGetPlayerIndex = CLIB.SDL_JoystickGetPlayerIndex,
	JoystickGetProduct = CLIB.SDL_JoystickGetProduct,
	JoystickGetProductVersion = CLIB.SDL_JoystickGetProductVersion,
	JoystickGetSerial = CLIB.SDL_JoystickGetSerial,
	JoystickGetType = CLIB.SDL_JoystickGetType,
	JoystickGetVendor = CLIB.SDL_JoystickGetVendor,
	JoystickHasLED = CLIB.SDL_JoystickHasLED,
	JoystickHasRumble = CLIB.SDL_JoystickHasRumble,
	JoystickHasRumbleTriggers = CLIB.SDL_JoystickHasRumbleTriggers,
	JoystickInstanceID = CLIB.SDL_JoystickInstanceID,
	JoystickIsHaptic = CLIB.SDL_JoystickIsHaptic,
	JoystickIsVirtual = CLIB.SDL_JoystickIsVirtual,
	JoystickName = CLIB.SDL_JoystickName,
	JoystickNameForIndex = CLIB.SDL_JoystickNameForIndex,
	JoystickNumAxes = CLIB.SDL_JoystickNumAxes,
	JoystickNumBalls = CLIB.SDL_JoystickNumBalls,
	JoystickNumButtons = CLIB.SDL_JoystickNumButtons,
	JoystickNumHats = CLIB.SDL_JoystickNumHats,
	JoystickOpen = CLIB.SDL_JoystickOpen,
	JoystickPath = CLIB.SDL_JoystickPath,
	JoystickPathForIndex = CLIB.SDL_JoystickPathForIndex,
	JoystickRumble = CLIB.SDL_JoystickRumble,
	JoystickRumbleTriggers = CLIB.SDL_JoystickRumbleTriggers,
	JoystickSendEffect = CLIB.SDL_JoystickSendEffect,
	JoystickSetLED = CLIB.SDL_JoystickSetLED,
	JoystickSetPlayerIndex = CLIB.SDL_JoystickSetPlayerIndex,
	JoystickSetVirtualAxis = CLIB.SDL_JoystickSetVirtualAxis,
	JoystickSetVirtualButton = CLIB.SDL_JoystickSetVirtualButton,
	JoystickSetVirtualHat = CLIB.SDL_JoystickSetVirtualHat,
	JoystickUpdate = CLIB.SDL_JoystickUpdate,
	LinuxSetThreadPriority = CLIB.SDL_LinuxSetThreadPriority,
	LinuxSetThreadPriorityAndPolicy = CLIB.SDL_LinuxSetThreadPriorityAndPolicy,
	LoadBMP_RW = CLIB.SDL_LoadBMP_RW,
	LoadDollarTemplates = CLIB.SDL_LoadDollarTemplates,
	LoadFile = CLIB.SDL_LoadFile,
	LoadFile_RW = CLIB.SDL_LoadFile_RW,
	LoadFunction = CLIB.SDL_LoadFunction,
	LoadObject = CLIB.SDL_LoadObject,
	LoadWAV_RW = CLIB.SDL_LoadWAV_RW,
	LockAudio = CLIB.SDL_LockAudio,
	LockAudioDevice = CLIB.SDL_LockAudioDevice,
	LockJoysticks = CLIB.SDL_LockJoysticks,
	LockMutex = CLIB.SDL_LockMutex,
	LockSensors = CLIB.SDL_LockSensors,
	LockSurface = CLIB.SDL_LockSurface,
	LockTexture = CLIB.SDL_LockTexture,
	LockTextureToSurface = CLIB.SDL_LockTextureToSurface,
	Log = CLIB.SDL_Log,
	LogCritical = CLIB.SDL_LogCritical,
	LogDebug = CLIB.SDL_LogDebug,
	LogError = CLIB.SDL_LogError,
	LogGetOutputFunction = CLIB.SDL_LogGetOutputFunction,
	LogGetPriority = CLIB.SDL_LogGetPriority,
	LogInfo = CLIB.SDL_LogInfo,
	LogMessage = CLIB.SDL_LogMessage,
	LogMessageV = CLIB.SDL_LogMessageV,
	LogResetPriorities = CLIB.SDL_LogResetPriorities,
	LogSetAllPriority = CLIB.SDL_LogSetAllPriority,
	LogSetOutputFunction = CLIB.SDL_LogSetOutputFunction,
	LogSetPriority = CLIB.SDL_LogSetPriority,
	LogVerbose = CLIB.SDL_LogVerbose,
	LogWarn = CLIB.SDL_LogWarn,
	LowerBlit = CLIB.SDL_LowerBlit,
	LowerBlitScaled = CLIB.SDL_LowerBlitScaled,
	MapRGB = CLIB.SDL_MapRGB,
	MapRGBA = CLIB.SDL_MapRGBA,
	MasksToPixelFormatEnum = CLIB.SDL_MasksToPixelFormatEnum,
	MaximizeWindow = CLIB.SDL_MaximizeWindow,
	MemoryBarrierAcquireFunction = CLIB.SDL_MemoryBarrierAcquireFunction,
	MemoryBarrierReleaseFunction = CLIB.SDL_MemoryBarrierReleaseFunction,
	Metal_CreateView = CLIB.SDL_Metal_CreateView,
	Metal_DestroyView = CLIB.SDL_Metal_DestroyView,
	Metal_GetDrawableSize = CLIB.SDL_Metal_GetDrawableSize,
	Metal_GetLayer = CLIB.SDL_Metal_GetLayer,
	MinimizeWindow = CLIB.SDL_MinimizeWindow,
	MixAudio = CLIB.SDL_MixAudio,
	MixAudioFormat = CLIB.SDL_MixAudioFormat,
	MouseIsHaptic = CLIB.SDL_MouseIsHaptic,
	NewAudioStream = CLIB.SDL_NewAudioStream,
	NumHaptics = CLIB.SDL_NumHaptics,
	NumJoysticks = CLIB.SDL_NumJoysticks,
	NumSensors = CLIB.SDL_NumSensors,
	OnApplicationDidBecomeActive = CLIB.SDL_OnApplicationDidBecomeActive,
	OnApplicationDidEnterBackground = CLIB.SDL_OnApplicationDidEnterBackground,
	OnApplicationDidReceiveMemoryWarning = CLIB.SDL_OnApplicationDidReceiveMemoryWarning,
	OnApplicationWillEnterForeground = CLIB.SDL_OnApplicationWillEnterForeground,
	OnApplicationWillResignActive = CLIB.SDL_OnApplicationWillResignActive,
	OnApplicationWillTerminate = CLIB.SDL_OnApplicationWillTerminate,
	OpenAudio = CLIB.SDL_OpenAudio,
	OpenAudioDevice = CLIB.SDL_OpenAudioDevice,
	OpenURL = CLIB.SDL_OpenURL,
	PauseAudio = CLIB.SDL_PauseAudio,
	PauseAudioDevice = CLIB.SDL_PauseAudioDevice,
	PeepEvents = CLIB.SDL_PeepEvents,
	PixelFormatEnumToMasks = CLIB.SDL_PixelFormatEnumToMasks,
	PollEvent = CLIB.SDL_PollEvent,
	PremultiplyAlpha = CLIB.SDL_PremultiplyAlpha,
	PumpEvents = CLIB.SDL_PumpEvents,
	PushEvent = CLIB.SDL_PushEvent,
	QueryTexture = CLIB.SDL_QueryTexture,
	QueueAudio = CLIB.SDL_QueueAudio,
	Quit = CLIB.SDL_Quit,
	QuitSubSystem = CLIB.SDL_QuitSubSystem,
	RWFromConstMem = CLIB.SDL_RWFromConstMem,
	RWFromFP = CLIB.SDL_RWFromFP,
	RWFromFile = CLIB.SDL_RWFromFile,
	RWFromMem = CLIB.SDL_RWFromMem,
	RWclose = CLIB.SDL_RWclose,
	RWread = CLIB.SDL_RWread,
	RWseek = CLIB.SDL_RWseek,
	RWsize = CLIB.SDL_RWsize,
	RWtell = CLIB.SDL_RWtell,
	RWwrite = CLIB.SDL_RWwrite,
	RaiseWindow = CLIB.SDL_RaiseWindow,
	ReadBE16 = CLIB.SDL_ReadBE16,
	ReadBE32 = CLIB.SDL_ReadBE32,
	ReadBE64 = CLIB.SDL_ReadBE64,
	ReadLE16 = CLIB.SDL_ReadLE16,
	ReadLE32 = CLIB.SDL_ReadLE32,
	ReadLE64 = CLIB.SDL_ReadLE64,
	ReadU8 = CLIB.SDL_ReadU8,
	RecordGesture = CLIB.SDL_RecordGesture,
	RegisterEvents = CLIB.SDL_RegisterEvents,
	RemoveTimer = CLIB.SDL_RemoveTimer,
	RenderClear = CLIB.SDL_RenderClear,
	RenderCopy = CLIB.SDL_RenderCopy,
	RenderCopyEx = CLIB.SDL_RenderCopyEx,
	RenderCopyExF = CLIB.SDL_RenderCopyExF,
	RenderCopyF = CLIB.SDL_RenderCopyF,
	RenderDrawLine = CLIB.SDL_RenderDrawLine,
	RenderDrawLineF = CLIB.SDL_RenderDrawLineF,
	RenderDrawLines = CLIB.SDL_RenderDrawLines,
	RenderDrawLinesF = CLIB.SDL_RenderDrawLinesF,
	RenderDrawPoint = CLIB.SDL_RenderDrawPoint,
	RenderDrawPointF = CLIB.SDL_RenderDrawPointF,
	RenderDrawPoints = CLIB.SDL_RenderDrawPoints,
	RenderDrawPointsF = CLIB.SDL_RenderDrawPointsF,
	RenderDrawRect = CLIB.SDL_RenderDrawRect,
	RenderDrawRectF = CLIB.SDL_RenderDrawRectF,
	RenderDrawRects = CLIB.SDL_RenderDrawRects,
	RenderDrawRectsF = CLIB.SDL_RenderDrawRectsF,
	RenderFillRect = CLIB.SDL_RenderFillRect,
	RenderFillRectF = CLIB.SDL_RenderFillRectF,
	RenderFillRects = CLIB.SDL_RenderFillRects,
	RenderFillRectsF = CLIB.SDL_RenderFillRectsF,
	RenderFlush = CLIB.SDL_RenderFlush,
	RenderGeometry = CLIB.SDL_RenderGeometry,
	RenderGeometryRaw = CLIB.SDL_RenderGeometryRaw,
	RenderGetClipRect = CLIB.SDL_RenderGetClipRect,
	RenderGetIntegerScale = CLIB.SDL_RenderGetIntegerScale,
	RenderGetLogicalSize = CLIB.SDL_RenderGetLogicalSize,
	RenderGetMetalCommandEncoder = CLIB.SDL_RenderGetMetalCommandEncoder,
	RenderGetMetalLayer = CLIB.SDL_RenderGetMetalLayer,
	RenderGetScale = CLIB.SDL_RenderGetScale,
	RenderGetViewport = CLIB.SDL_RenderGetViewport,
	RenderGetWindow = CLIB.SDL_RenderGetWindow,
	RenderIsClipEnabled = CLIB.SDL_RenderIsClipEnabled,
	RenderLogicalToWindow = CLIB.SDL_RenderLogicalToWindow,
	RenderPresent = CLIB.SDL_RenderPresent,
	RenderReadPixels = CLIB.SDL_RenderReadPixels,
	RenderSetClipRect = CLIB.SDL_RenderSetClipRect,
	RenderSetIntegerScale = CLIB.SDL_RenderSetIntegerScale,
	RenderSetLogicalSize = CLIB.SDL_RenderSetLogicalSize,
	RenderSetScale = CLIB.SDL_RenderSetScale,
	RenderSetVSync = CLIB.SDL_RenderSetVSync,
	RenderSetViewport = CLIB.SDL_RenderSetViewport,
	RenderTargetSupported = CLIB.SDL_RenderTargetSupported,
	RenderWindowToLogical = CLIB.SDL_RenderWindowToLogical,
	ReportAssertion = CLIB.SDL_ReportAssertion,
	ResetAssertionReport = CLIB.SDL_ResetAssertionReport,
	ResetHint = CLIB.SDL_ResetHint,
	ResetKeyboard = CLIB.SDL_ResetKeyboard,
	RestoreWindow = CLIB.SDL_RestoreWindow,
	SIMDAlloc = CLIB.SDL_SIMDAlloc,
	SIMDFree = CLIB.SDL_SIMDFree,
	SIMDGetAlignment = CLIB.SDL_SIMDGetAlignment,
	SIMDRealloc = CLIB.SDL_SIMDRealloc,
	SaveAllDollarTemplates = CLIB.SDL_SaveAllDollarTemplates,
	SaveBMP_RW = CLIB.SDL_SaveBMP_RW,
	SaveDollarTemplate = CLIB.SDL_SaveDollarTemplate,
	SemPost = CLIB.SDL_SemPost,
	SemTryWait = CLIB.SDL_SemTryWait,
	SemValue = CLIB.SDL_SemValue,
	SemWait = CLIB.SDL_SemWait,
	SemWaitTimeout = CLIB.SDL_SemWaitTimeout,
	SensorClose = CLIB.SDL_SensorClose,
	SensorFromInstanceID = CLIB.SDL_SensorFromInstanceID,
	SensorGetData = CLIB.SDL_SensorGetData,
	SensorGetDeviceInstanceID = CLIB.SDL_SensorGetDeviceInstanceID,
	SensorGetDeviceName = CLIB.SDL_SensorGetDeviceName,
	SensorGetDeviceNonPortableType = CLIB.SDL_SensorGetDeviceNonPortableType,
	SensorGetDeviceType = CLIB.SDL_SensorGetDeviceType,
	SensorGetInstanceID = CLIB.SDL_SensorGetInstanceID,
	SensorGetName = CLIB.SDL_SensorGetName,
	SensorGetNonPortableType = CLIB.SDL_SensorGetNonPortableType,
	SensorGetType = CLIB.SDL_SensorGetType,
	SensorOpen = CLIB.SDL_SensorOpen,
	SensorUpdate = CLIB.SDL_SensorUpdate,
	SetAssertionHandler = CLIB.SDL_SetAssertionHandler,
	SetClipRect = CLIB.SDL_SetClipRect,
	SetClipboardText = CLIB.SDL_SetClipboardText,
	SetColorKey = CLIB.SDL_SetColorKey,
	SetCursor = CLIB.SDL_SetCursor,
	SetError = CLIB.SDL_SetError,
	SetEventFilter = CLIB.SDL_SetEventFilter,
	SetHint = CLIB.SDL_SetHint,
	SetHintWithPriority = CLIB.SDL_SetHintWithPriority,
	SetMainReady = CLIB.SDL_SetMainReady,
	SetMemoryFunctions = CLIB.SDL_SetMemoryFunctions,
	SetModState = CLIB.SDL_SetModState,
	SetPaletteColors = CLIB.SDL_SetPaletteColors,
	SetPixelFormatPalette = CLIB.SDL_SetPixelFormatPalette,
	SetPrimarySelectionText = CLIB.SDL_SetPrimarySelectionText,
	SetRelativeMouseMode = CLIB.SDL_SetRelativeMouseMode,
	SetRenderDrawBlendMode = CLIB.SDL_SetRenderDrawBlendMode,
	SetRenderDrawColor = CLIB.SDL_SetRenderDrawColor,
	SetRenderTarget = CLIB.SDL_SetRenderTarget,
	SetSurfaceAlphaMod = CLIB.SDL_SetSurfaceAlphaMod,
	SetSurfaceBlendMode = CLIB.SDL_SetSurfaceBlendMode,
	SetSurfaceColorMod = CLIB.SDL_SetSurfaceColorMod,
	SetSurfacePalette = CLIB.SDL_SetSurfacePalette,
	SetSurfaceRLE = CLIB.SDL_SetSurfaceRLE,
	SetTextInputRect = CLIB.SDL_SetTextInputRect,
	SetTextureAlphaMod = CLIB.SDL_SetTextureAlphaMod,
	SetTextureBlendMode = CLIB.SDL_SetTextureBlendMode,
	SetTextureColorMod = CLIB.SDL_SetTextureColorMod,
	SetTextureScaleMode = CLIB.SDL_SetTextureScaleMode,
	SetTextureUserData = CLIB.SDL_SetTextureUserData,
	SetThreadPriority = CLIB.SDL_SetThreadPriority,
	SetWindowAlwaysOnTop = CLIB.SDL_SetWindowAlwaysOnTop,
	SetWindowBordered = CLIB.SDL_SetWindowBordered,
	SetWindowBrightness = CLIB.SDL_SetWindowBrightness,
	SetWindowData = CLIB.SDL_SetWindowData,
	SetWindowDisplayMode = CLIB.SDL_SetWindowDisplayMode,
	SetWindowFullscreen = CLIB.SDL_SetWindowFullscreen,
	SetWindowGammaRamp = CLIB.SDL_SetWindowGammaRamp,
	SetWindowGrab = CLIB.SDL_SetWindowGrab,
	SetWindowHitTest = CLIB.SDL_SetWindowHitTest,
	SetWindowIcon = CLIB.SDL_SetWindowIcon,
	SetWindowInputFocus = CLIB.SDL_SetWindowInputFocus,
	SetWindowKeyboardGrab = CLIB.SDL_SetWindowKeyboardGrab,
	SetWindowMaximumSize = CLIB.SDL_SetWindowMaximumSize,
	SetWindowMinimumSize = CLIB.SDL_SetWindowMinimumSize,
	SetWindowModalFor = CLIB.SDL_SetWindowModalFor,
	SetWindowMouseGrab = CLIB.SDL_SetWindowMouseGrab,
	SetWindowMouseRect = CLIB.SDL_SetWindowMouseRect,
	SetWindowOpacity = CLIB.SDL_SetWindowOpacity,
	SetWindowPosition = CLIB.SDL_SetWindowPosition,
	SetWindowResizable = CLIB.SDL_SetWindowResizable,
	SetWindowShape = CLIB.SDL_SetWindowShape,
	SetWindowSize = CLIB.SDL_SetWindowSize,
	SetWindowTitle = CLIB.SDL_SetWindowTitle,
	SetYUVConversionMode = CLIB.SDL_SetYUVConversionMode,
	ShowCursor = CLIB.SDL_ShowCursor,
	ShowMessageBox = CLIB.SDL_ShowMessageBox,
	ShowSimpleMessageBox = CLIB.SDL_ShowSimpleMessageBox,
	ShowWindow = CLIB.SDL_ShowWindow,
	SoftStretch = CLIB.SDL_SoftStretch,
	SoftStretchLinear = CLIB.SDL_SoftStretchLinear,
	StartTextInput = CLIB.SDL_StartTextInput,
	StopTextInput = CLIB.SDL_StopTextInput,
	TLSCleanup = CLIB.SDL_TLSCleanup,
	TLSCreate = CLIB.SDL_TLSCreate,
	TLSGet = CLIB.SDL_TLSGet,
	ThreadID = CLIB.SDL_ThreadID,
	TryLockMutex = CLIB.SDL_TryLockMutex,
	UnionFRect = CLIB.SDL_UnionFRect,
	UnionRect = CLIB.SDL_UnionRect,
	UnloadObject = CLIB.SDL_UnloadObject,
	UnlockAudio = CLIB.SDL_UnlockAudio,
	UnlockAudioDevice = CLIB.SDL_UnlockAudioDevice,
	UnlockJoysticks = CLIB.SDL_UnlockJoysticks,
	UnlockMutex = CLIB.SDL_UnlockMutex,
	UnlockSensors = CLIB.SDL_UnlockSensors,
	UnlockSurface = CLIB.SDL_UnlockSurface,
	UnlockTexture = CLIB.SDL_UnlockTexture,
	UpdateNVTexture = CLIB.SDL_UpdateNVTexture,
	UpdateTexture = CLIB.SDL_UpdateTexture,
	UpdateWindowSurface = CLIB.SDL_UpdateWindowSurface,
	UpdateWindowSurfaceRects = CLIB.SDL_UpdateWindowSurfaceRects,
	UpdateYUVTexture = CLIB.SDL_UpdateYUVTexture,
	UpperBlit = CLIB.SDL_UpperBlit,
	UpperBlitScaled = CLIB.SDL_UpperBlitScaled,
	VideoInit = CLIB.SDL_VideoInit,
	VideoQuit = CLIB.SDL_VideoQuit,
	Vulkan_CreateSurface = CLIB.SDL_Vulkan_CreateSurface,
	Vulkan_GetDrawableSize = CLIB.SDL_Vulkan_GetDrawableSize,
	Vulkan_GetInstanceExtensions = CLIB.SDL_Vulkan_GetInstanceExtensions,
	Vulkan_GetVkGetInstanceProcAddr = CLIB.SDL_Vulkan_GetVkGetInstanceProcAddr,
	Vulkan_LoadLibrary = CLIB.SDL_Vulkan_LoadLibrary,
	Vulkan_UnloadLibrary = CLIB.SDL_Vulkan_UnloadLibrary,
	WaitEvent = CLIB.SDL_WaitEvent,
	WaitEventTimeout = CLIB.SDL_WaitEventTimeout,
	WaitThread = CLIB.SDL_WaitThread,
	WarpMouseGlobal = CLIB.SDL_WarpMouseGlobal,
	WarpMouseInWindow = CLIB.SDL_WarpMouseInWindow,
	WasInit = CLIB.SDL_WasInit,
	WriteBE16 = CLIB.SDL_WriteBE16,
	WriteBE32 = CLIB.SDL_WriteBE32,
	WriteBE64 = CLIB.SDL_WriteBE64,
	WriteLE16 = CLIB.SDL_WriteLE16,
	WriteLE32 = CLIB.SDL_WriteLE32,
	WriteLE64 = CLIB.SDL_WriteLE64,
	WriteU8 = CLIB.SDL_WriteU8,
	abs = CLIB.SDL_abs,
	acos = CLIB.SDL_acos,
	acosf = CLIB.SDL_acosf,
	asin = CLIB.SDL_asin,
	asinf = CLIB.SDL_asinf,
	asprintf = CLIB.SDL_asprintf,
	atan = CLIB.SDL_atan,
	atan2 = CLIB.SDL_atan2,
	atan2f = CLIB.SDL_atan2f,
	atanf = CLIB.SDL_atanf,
	atof = CLIB.SDL_atof,
	atoi = CLIB.SDL_atoi,
	calloc = CLIB.SDL_calloc,
	ceil = CLIB.SDL_ceil,
	ceilf = CLIB.SDL_ceilf,
	copysign = CLIB.SDL_copysign,
	copysignf = CLIB.SDL_copysignf,
	cos = CLIB.SDL_cos,
	cosf = CLIB.SDL_cosf,
	crc16 = CLIB.SDL_crc16,
	crc32 = CLIB.SDL_crc32,
	exp = CLIB.SDL_exp,
	expf = CLIB.SDL_expf,
	fabs = CLIB.SDL_fabs,
	fabsf = CLIB.SDL_fabsf,
	floor = CLIB.SDL_floor,
	floorf = CLIB.SDL_floorf,
	fmod = CLIB.SDL_fmod,
	fmodf = CLIB.SDL_fmodf,
	free = CLIB.SDL_free,
	getenv = CLIB.SDL_getenv,
	hid_ble_scan = CLIB.SDL_hid_ble_scan,
	hid_close = CLIB.SDL_hid_close,
	hid_device_change_count = CLIB.SDL_hid_device_change_count,
	hid_enumerate = CLIB.SDL_hid_enumerate,
	hid_exit = CLIB.SDL_hid_exit,
	hid_free_enumeration = CLIB.SDL_hid_free_enumeration,
	hid_get_feature_report = CLIB.SDL_hid_get_feature_report,
	hid_get_indexed_string = CLIB.SDL_hid_get_indexed_string,
	hid_get_manufacturer_string = CLIB.SDL_hid_get_manufacturer_string,
	hid_get_product_string = CLIB.SDL_hid_get_product_string,
	hid_get_serial_number_string = CLIB.SDL_hid_get_serial_number_string,
	hid_init = CLIB.SDL_hid_init,
	hid_open = CLIB.SDL_hid_open,
	hid_open_path = CLIB.SDL_hid_open_path,
	hid_read = CLIB.SDL_hid_read,
	hid_read_timeout = CLIB.SDL_hid_read_timeout,
	hid_send_feature_report = CLIB.SDL_hid_send_feature_report,
	hid_set_nonblocking = CLIB.SDL_hid_set_nonblocking,
	hid_write = CLIB.SDL_hid_write,
	iconv = CLIB.SDL_iconv,
	iconv_close = CLIB.SDL_iconv_close,
	iconv_open = CLIB.SDL_iconv_open,
	iconv_string = CLIB.SDL_iconv_string,
	isalnum = CLIB.SDL_isalnum,
	isalpha = CLIB.SDL_isalpha,
	isblank = CLIB.SDL_isblank,
	iscntrl = CLIB.SDL_iscntrl,
	isdigit = CLIB.SDL_isdigit,
	isgraph = CLIB.SDL_isgraph,
	islower = CLIB.SDL_islower,
	isprint = CLIB.SDL_isprint,
	ispunct = CLIB.SDL_ispunct,
	isspace = CLIB.SDL_isspace,
	isupper = CLIB.SDL_isupper,
	isxdigit = CLIB.SDL_isxdigit,
	itoa = CLIB.SDL_itoa,
	lltoa = CLIB.SDL_lltoa,
	log = CLIB.SDL_log,
	log10 = CLIB.SDL_log10,
	log10f = CLIB.SDL_log10f,
	logf = CLIB.SDL_logf,
	lround = CLIB.SDL_lround,
	lroundf = CLIB.SDL_lroundf,
	ltoa = CLIB.SDL_ltoa,
	malloc = CLIB.SDL_malloc,
	memcmp = CLIB.SDL_memcmp,
	memcpy = CLIB.SDL_memcpy,
	memmove = CLIB.SDL_memmove,
	memset = CLIB.SDL_memset,
	pow = CLIB.SDL_pow,
	powf = CLIB.SDL_powf,
	realloc = CLIB.SDL_realloc,
	round = CLIB.SDL_round,
	roundf = CLIB.SDL_roundf,
	scalbn = CLIB.SDL_scalbn,
	scalbnf = CLIB.SDL_scalbnf,
	setenv = CLIB.SDL_setenv,
	sin = CLIB.SDL_sin,
	sinf = CLIB.SDL_sinf,
	snprintf = CLIB.SDL_snprintf,
	sqrt = CLIB.SDL_sqrt,
	sqrtf = CLIB.SDL_sqrtf,
	sscanf = CLIB.SDL_sscanf,
	strcasecmp = CLIB.SDL_strcasecmp,
	strchr = CLIB.SDL_strchr,
	strcmp = CLIB.SDL_strcmp,
	strdup = CLIB.SDL_strdup,
	strlcat = CLIB.SDL_strlcat,
	strlcpy = CLIB.SDL_strlcpy,
	strlen = CLIB.SDL_strlen,
	strlwr = CLIB.SDL_strlwr,
	strncasecmp = CLIB.SDL_strncasecmp,
	strncmp = CLIB.SDL_strncmp,
	strrchr = CLIB.SDL_strrchr,
	strrev = CLIB.SDL_strrev,
	strstr = CLIB.SDL_strstr,
	strtod = CLIB.SDL_strtod,
	strtokr = CLIB.SDL_strtokr,
	strtol = CLIB.SDL_strtol,
	strtoll = CLIB.SDL_strtoll,
	strtoul = CLIB.SDL_strtoul,
	strtoull = CLIB.SDL_strtoull,
	strupr = CLIB.SDL_strupr,
	tan = CLIB.SDL_tan,
	tanf = CLIB.SDL_tanf,
	tolower = CLIB.SDL_tolower,
	toupper = CLIB.SDL_toupper,
	trunc = CLIB.SDL_trunc,
	truncf = CLIB.SDL_truncf,
	uitoa = CLIB.SDL_uitoa,
	ulltoa = CLIB.SDL_ulltoa,
	ultoa = CLIB.SDL_ultoa,
	utf8strlcpy = CLIB.SDL_utf8strlcpy,
	utf8strlen = CLIB.SDL_utf8strlen,
	utf8strnlen = CLIB.SDL_utf8strnlen,
	vasprintf = CLIB.SDL_vasprintf,
	vsnprintf = CLIB.SDL_vsnprintf,
	vsscanf = CLIB.SDL_vsscanf,
	wcscasecmp = CLIB.SDL_wcscasecmp,
	wcscmp = CLIB.SDL_wcscmp,
	wcsdup = CLIB.SDL_wcsdup,
	wcslcat = CLIB.SDL_wcslcat,
	wcslcpy = CLIB.SDL_wcslcpy,
	wcslen = CLIB.SDL_wcslen,
	wcsncasecmp = CLIB.SDL_wcsncasecmp,
	wcsncmp = CLIB.SDL_wcsncmp,
	wcsstr = CLIB.SDL_wcsstr,
}
library.e = {
	ARRAYORDER_NONE = ffi.cast("enum SDL_ArrayOrder", "SDL_ARRAYORDER_NONE"),
	ARRAYORDER_RGB = ffi.cast("enum SDL_ArrayOrder", "SDL_ARRAYORDER_RGB"),
	ARRAYORDER_RGBA = ffi.cast("enum SDL_ArrayOrder", "SDL_ARRAYORDER_RGBA"),
	ARRAYORDER_ARGB = ffi.cast("enum SDL_ArrayOrder", "SDL_ARRAYORDER_ARGB"),
	ARRAYORDER_BGR = ffi.cast("enum SDL_ArrayOrder", "SDL_ARRAYORDER_BGR"),
	ARRAYORDER_BGRA = ffi.cast("enum SDL_ArrayOrder", "SDL_ARRAYORDER_BGRA"),
	ARRAYORDER_ABGR = ffi.cast("enum SDL_ArrayOrder", "SDL_ARRAYORDER_ABGR"),
	ASSERTION_RETRY = ffi.cast("enum SDL_AssertState", "SDL_ASSERTION_RETRY"),
	ASSERTION_BREAK = ffi.cast("enum SDL_AssertState", "SDL_ASSERTION_BREAK"),
	ASSERTION_ABORT = ffi.cast("enum SDL_AssertState", "SDL_ASSERTION_ABORT"),
	ASSERTION_IGNORE = ffi.cast("enum SDL_AssertState", "SDL_ASSERTION_IGNORE"),
	ASSERTION_ALWAYS_IGNORE = ffi.cast("enum SDL_AssertState", "SDL_ASSERTION_ALWAYS_IGNORE"),
	AUDIO_STOPPED = ffi.cast("enum SDL_AudioStatus", "SDL_AUDIO_STOPPED"),
	AUDIO_PLAYING = ffi.cast("enum SDL_AudioStatus", "SDL_AUDIO_PLAYING"),
	AUDIO_PAUSED = ffi.cast("enum SDL_AudioStatus", "SDL_AUDIO_PAUSED"),
	BITMAPORDER_NONE = ffi.cast("enum SDL_BitmapOrder", "SDL_BITMAPORDER_NONE"),
	BITMAPORDER_4321 = ffi.cast("enum SDL_BitmapOrder", "SDL_BITMAPORDER_4321"),
	BITMAPORDER_1234 = ffi.cast("enum SDL_BitmapOrder", "SDL_BITMAPORDER_1234"),
	BLENDFACTOR_ZERO = ffi.cast("enum SDL_BlendFactor", "SDL_BLENDFACTOR_ZERO"),
	BLENDFACTOR_ONE = ffi.cast("enum SDL_BlendFactor", "SDL_BLENDFACTOR_ONE"),
	BLENDFACTOR_SRC_COLOR = ffi.cast("enum SDL_BlendFactor", "SDL_BLENDFACTOR_SRC_COLOR"),
	BLENDFACTOR_ONE_MINUS_SRC_COLOR = ffi.cast("enum SDL_BlendFactor", "SDL_BLENDFACTOR_ONE_MINUS_SRC_COLOR"),
	BLENDFACTOR_SRC_ALPHA = ffi.cast("enum SDL_BlendFactor", "SDL_BLENDFACTOR_SRC_ALPHA"),
	BLENDFACTOR_ONE_MINUS_SRC_ALPHA = ffi.cast("enum SDL_BlendFactor", "SDL_BLENDFACTOR_ONE_MINUS_SRC_ALPHA"),
	BLENDFACTOR_DST_COLOR = ffi.cast("enum SDL_BlendFactor", "SDL_BLENDFACTOR_DST_COLOR"),
	BLENDFACTOR_ONE_MINUS_DST_COLOR = ffi.cast("enum SDL_BlendFactor", "SDL_BLENDFACTOR_ONE_MINUS_DST_COLOR"),
	BLENDFACTOR_DST_ALPHA = ffi.cast("enum SDL_BlendFactor", "SDL_BLENDFACTOR_DST_ALPHA"),
	BLENDFACTOR_ONE_MINUS_DST_ALPHA = ffi.cast("enum SDL_BlendFactor", "SDL_BLENDFACTOR_ONE_MINUS_DST_ALPHA"),
	BLENDMODE_NONE = ffi.cast("enum SDL_BlendMode", "SDL_BLENDMODE_NONE"),
	BLENDMODE_BLEND = ffi.cast("enum SDL_BlendMode", "SDL_BLENDMODE_BLEND"),
	BLENDMODE_ADD = ffi.cast("enum SDL_BlendMode", "SDL_BLENDMODE_ADD"),
	BLENDMODE_MOD = ffi.cast("enum SDL_BlendMode", "SDL_BLENDMODE_MOD"),
	BLENDMODE_MUL = ffi.cast("enum SDL_BlendMode", "SDL_BLENDMODE_MUL"),
	BLENDMODE_INVALID = ffi.cast("enum SDL_BlendMode", "SDL_BLENDMODE_INVALID"),
	BLENDOPERATION_ADD = ffi.cast("enum SDL_BlendOperation", "SDL_BLENDOPERATION_ADD"),
	BLENDOPERATION_SUBTRACT = ffi.cast("enum SDL_BlendOperation", "SDL_BLENDOPERATION_SUBTRACT"),
	BLENDOPERATION_REV_SUBTRACT = ffi.cast("enum SDL_BlendOperation", "SDL_BLENDOPERATION_REV_SUBTRACT"),
	BLENDOPERATION_MINIMUM = ffi.cast("enum SDL_BlendOperation", "SDL_BLENDOPERATION_MINIMUM"),
	BLENDOPERATION_MAXIMUM = ffi.cast("enum SDL_BlendOperation", "SDL_BLENDOPERATION_MAXIMUM"),
	DISPLAYEVENT_NONE = ffi.cast("enum SDL_DisplayEventID", "SDL_DISPLAYEVENT_NONE"),
	DISPLAYEVENT_ORIENTATION = ffi.cast("enum SDL_DisplayEventID", "SDL_DISPLAYEVENT_ORIENTATION"),
	DISPLAYEVENT_CONNECTED = ffi.cast("enum SDL_DisplayEventID", "SDL_DISPLAYEVENT_CONNECTED"),
	DISPLAYEVENT_DISCONNECTED = ffi.cast("enum SDL_DisplayEventID", "SDL_DISPLAYEVENT_DISCONNECTED"),
	ORIENTATION_UNKNOWN = ffi.cast("enum SDL_DisplayOrientation", "SDL_ORIENTATION_UNKNOWN"),
	ORIENTATION_LANDSCAPE = ffi.cast("enum SDL_DisplayOrientation", "SDL_ORIENTATION_LANDSCAPE"),
	ORIENTATION_LANDSCAPE_FLIPPED = ffi.cast("enum SDL_DisplayOrientation", "SDL_ORIENTATION_LANDSCAPE_FLIPPED"),
	ORIENTATION_PORTRAIT = ffi.cast("enum SDL_DisplayOrientation", "SDL_ORIENTATION_PORTRAIT"),
	ORIENTATION_PORTRAIT_FLIPPED = ffi.cast("enum SDL_DisplayOrientation", "SDL_ORIENTATION_PORTRAIT_FLIPPED"),
	FIRSTEVENT = ffi.cast("enum SDL_EventType", "SDL_FIRSTEVENT"),
	QUIT = ffi.cast("enum SDL_EventType", "SDL_QUIT"),
	APP_TERMINATING = ffi.cast("enum SDL_EventType", "SDL_APP_TERMINATING"),
	APP_LOWMEMORY = ffi.cast("enum SDL_EventType", "SDL_APP_LOWMEMORY"),
	APP_WILLENTERBACKGROUND = ffi.cast("enum SDL_EventType", "SDL_APP_WILLENTERBACKGROUND"),
	APP_DIDENTERBACKGROUND = ffi.cast("enum SDL_EventType", "SDL_APP_DIDENTERBACKGROUND"),
	APP_WILLENTERFOREGROUND = ffi.cast("enum SDL_EventType", "SDL_APP_WILLENTERFOREGROUND"),
	APP_DIDENTERFOREGROUND = ffi.cast("enum SDL_EventType", "SDL_APP_DIDENTERFOREGROUND"),
	LOCALECHANGED = ffi.cast("enum SDL_EventType", "SDL_LOCALECHANGED"),
	DISPLAYEVENT = ffi.cast("enum SDL_EventType", "SDL_DISPLAYEVENT"),
	WINDOWEVENT = ffi.cast("enum SDL_EventType", "SDL_WINDOWEVENT"),
	SYSWMEVENT = ffi.cast("enum SDL_EventType", "SDL_SYSWMEVENT"),
	KEYDOWN = ffi.cast("enum SDL_EventType", "SDL_KEYDOWN"),
	KEYUP = ffi.cast("enum SDL_EventType", "SDL_KEYUP"),
	TEXTEDITING = ffi.cast("enum SDL_EventType", "SDL_TEXTEDITING"),
	TEXTINPUT = ffi.cast("enum SDL_EventType", "SDL_TEXTINPUT"),
	KEYMAPCHANGED = ffi.cast("enum SDL_EventType", "SDL_KEYMAPCHANGED"),
	TEXTEDITING_EXT = ffi.cast("enum SDL_EventType", "SDL_TEXTEDITING_EXT"),
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
	JOYBATTERYUPDATED = ffi.cast("enum SDL_EventType", "SDL_JOYBATTERYUPDATED"),
	CONTROLLERAXISMOTION = ffi.cast("enum SDL_EventType", "SDL_CONTROLLERAXISMOTION"),
	CONTROLLERBUTTONDOWN = ffi.cast("enum SDL_EventType", "SDL_CONTROLLERBUTTONDOWN"),
	CONTROLLERBUTTONUP = ffi.cast("enum SDL_EventType", "SDL_CONTROLLERBUTTONUP"),
	CONTROLLERDEVICEADDED = ffi.cast("enum SDL_EventType", "SDL_CONTROLLERDEVICEADDED"),
	CONTROLLERDEVICEREMOVED = ffi.cast("enum SDL_EventType", "SDL_CONTROLLERDEVICEREMOVED"),
	CONTROLLERDEVICEREMAPPED = ffi.cast("enum SDL_EventType", "SDL_CONTROLLERDEVICEREMAPPED"),
	CONTROLLERTOUCHPADDOWN = ffi.cast("enum SDL_EventType", "SDL_CONTROLLERTOUCHPADDOWN"),
	CONTROLLERTOUCHPADMOTION = ffi.cast("enum SDL_EventType", "SDL_CONTROLLERTOUCHPADMOTION"),
	CONTROLLERTOUCHPADUP = ffi.cast("enum SDL_EventType", "SDL_CONTROLLERTOUCHPADUP"),
	CONTROLLERSENSORUPDATE = ffi.cast("enum SDL_EventType", "SDL_CONTROLLERSENSORUPDATE"),
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
	SENSORUPDATE = ffi.cast("enum SDL_EventType", "SDL_SENSORUPDATE"),
	RENDER_TARGETS_RESET = ffi.cast("enum SDL_EventType", "SDL_RENDER_TARGETS_RESET"),
	RENDER_DEVICE_RESET = ffi.cast("enum SDL_EventType", "SDL_RENDER_DEVICE_RESET"),
	POLLSENTINEL = ffi.cast("enum SDL_EventType", "SDL_POLLSENTINEL"),
	USEREVENT = ffi.cast("enum SDL_EventType", "SDL_USEREVENT"),
	LASTEVENT = ffi.cast("enum SDL_EventType", "SDL_LASTEVENT"),
	FLASH_CANCEL = ffi.cast("enum SDL_FlashOperation", "SDL_FLASH_CANCEL"),
	FLASH_BRIEFLY = ffi.cast("enum SDL_FlashOperation", "SDL_FLASH_BRIEFLY"),
	FLASH_UNTIL_FOCUSED = ffi.cast("enum SDL_FlashOperation", "SDL_FLASH_UNTIL_FOCUSED"),
	GL_CONTEXT_RESET_NO_NOTIFICATION = ffi.cast("enum SDL_GLContextResetNotification", "SDL_GL_CONTEXT_RESET_NO_NOTIFICATION"),
	GL_CONTEXT_RESET_LOSE_CONTEXT = ffi.cast("enum SDL_GLContextResetNotification", "SDL_GL_CONTEXT_RESET_LOSE_CONTEXT"),
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
	GL_CONTEXT_RESET_NOTIFICATION = ffi.cast("enum SDL_GLattr", "SDL_GL_CONTEXT_RESET_NOTIFICATION"),
	GL_CONTEXT_NO_ERROR = ffi.cast("enum SDL_GLattr", "SDL_GL_CONTEXT_NO_ERROR"),
	GL_FLOATBUFFERS = ffi.cast("enum SDL_GLattr", "SDL_GL_FLOATBUFFERS"),
	GL_CONTEXT_DEBUG_FLAG = ffi.cast("enum SDL_GLcontextFlag", "SDL_GL_CONTEXT_DEBUG_FLAG"),
	GL_CONTEXT_FORWARD_COMPATIBLE_FLAG = ffi.cast("enum SDL_GLcontextFlag", "SDL_GL_CONTEXT_FORWARD_COMPATIBLE_FLAG"),
	GL_CONTEXT_ROBUST_ACCESS_FLAG = ffi.cast("enum SDL_GLcontextFlag", "SDL_GL_CONTEXT_ROBUST_ACCESS_FLAG"),
	GL_CONTEXT_RESET_ISOLATION_FLAG = ffi.cast("enum SDL_GLcontextFlag", "SDL_GL_CONTEXT_RESET_ISOLATION_FLAG"),
	GL_CONTEXT_RELEASE_BEHAVIOR_NONE = ffi.cast("enum SDL_GLcontextReleaseFlag", "SDL_GL_CONTEXT_RELEASE_BEHAVIOR_NONE"),
	GL_CONTEXT_RELEASE_BEHAVIOR_FLUSH = ffi.cast("enum SDL_GLcontextReleaseFlag", "SDL_GL_CONTEXT_RELEASE_BEHAVIOR_FLUSH"),
	GL_CONTEXT_PROFILE_CORE = ffi.cast("enum SDL_GLprofile", "SDL_GL_CONTEXT_PROFILE_CORE"),
	GL_CONTEXT_PROFILE_COMPATIBILITY = ffi.cast("enum SDL_GLprofile", "SDL_GL_CONTEXT_PROFILE_COMPATIBILITY"),
	GL_CONTEXT_PROFILE_ES = ffi.cast("enum SDL_GLprofile", "SDL_GL_CONTEXT_PROFILE_ES"),
	CONTROLLER_AXIS_INVALID = ffi.cast("enum SDL_GameControllerAxis", "SDL_CONTROLLER_AXIS_INVALID"),
	CONTROLLER_AXIS_LEFTX = ffi.cast("enum SDL_GameControllerAxis", "SDL_CONTROLLER_AXIS_LEFTX"),
	CONTROLLER_AXIS_LEFTY = ffi.cast("enum SDL_GameControllerAxis", "SDL_CONTROLLER_AXIS_LEFTY"),
	CONTROLLER_AXIS_RIGHTX = ffi.cast("enum SDL_GameControllerAxis", "SDL_CONTROLLER_AXIS_RIGHTX"),
	CONTROLLER_AXIS_RIGHTY = ffi.cast("enum SDL_GameControllerAxis", "SDL_CONTROLLER_AXIS_RIGHTY"),
	CONTROLLER_AXIS_TRIGGERLEFT = ffi.cast("enum SDL_GameControllerAxis", "SDL_CONTROLLER_AXIS_TRIGGERLEFT"),
	CONTROLLER_AXIS_TRIGGERRIGHT = ffi.cast("enum SDL_GameControllerAxis", "SDL_CONTROLLER_AXIS_TRIGGERRIGHT"),
	CONTROLLER_AXIS_MAX = ffi.cast("enum SDL_GameControllerAxis", "SDL_CONTROLLER_AXIS_MAX"),
	CONTROLLER_BINDTYPE_NONE = ffi.cast("enum SDL_GameControllerBindType", "SDL_CONTROLLER_BINDTYPE_NONE"),
	CONTROLLER_BINDTYPE_BUTTON = ffi.cast("enum SDL_GameControllerBindType", "SDL_CONTROLLER_BINDTYPE_BUTTON"),
	CONTROLLER_BINDTYPE_AXIS = ffi.cast("enum SDL_GameControllerBindType", "SDL_CONTROLLER_BINDTYPE_AXIS"),
	CONTROLLER_BINDTYPE_HAT = ffi.cast("enum SDL_GameControllerBindType", "SDL_CONTROLLER_BINDTYPE_HAT"),
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
	CONTROLLER_BUTTON_MISC1 = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_MISC1"),
	CONTROLLER_BUTTON_PADDLE1 = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_PADDLE1"),
	CONTROLLER_BUTTON_PADDLE2 = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_PADDLE2"),
	CONTROLLER_BUTTON_PADDLE3 = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_PADDLE3"),
	CONTROLLER_BUTTON_PADDLE4 = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_PADDLE4"),
	CONTROLLER_BUTTON_TOUCHPAD = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_TOUCHPAD"),
	CONTROLLER_BUTTON_MAX = ffi.cast("enum SDL_GameControllerButton", "SDL_CONTROLLER_BUTTON_MAX"),
	CONTROLLER_TYPE_UNKNOWN = ffi.cast("enum SDL_GameControllerType", "SDL_CONTROLLER_TYPE_UNKNOWN"),
	CONTROLLER_TYPE_XBOX360 = ffi.cast("enum SDL_GameControllerType", "SDL_CONTROLLER_TYPE_XBOX360"),
	CONTROLLER_TYPE_XBOXONE = ffi.cast("enum SDL_GameControllerType", "SDL_CONTROLLER_TYPE_XBOXONE"),
	CONTROLLER_TYPE_PS3 = ffi.cast("enum SDL_GameControllerType", "SDL_CONTROLLER_TYPE_PS3"),
	CONTROLLER_TYPE_PS4 = ffi.cast("enum SDL_GameControllerType", "SDL_CONTROLLER_TYPE_PS4"),
	CONTROLLER_TYPE_NINTENDO_SWITCH_PRO = ffi.cast("enum SDL_GameControllerType", "SDL_CONTROLLER_TYPE_NINTENDO_SWITCH_PRO"),
	CONTROLLER_TYPE_VIRTUAL = ffi.cast("enum SDL_GameControllerType", "SDL_CONTROLLER_TYPE_VIRTUAL"),
	CONTROLLER_TYPE_PS5 = ffi.cast("enum SDL_GameControllerType", "SDL_CONTROLLER_TYPE_PS5"),
	CONTROLLER_TYPE_AMAZON_LUNA = ffi.cast("enum SDL_GameControllerType", "SDL_CONTROLLER_TYPE_AMAZON_LUNA"),
	CONTROLLER_TYPE_GOOGLE_STADIA = ffi.cast("enum SDL_GameControllerType", "SDL_CONTROLLER_TYPE_GOOGLE_STADIA"),
	CONTROLLER_TYPE_NVIDIA_SHIELD = ffi.cast("enum SDL_GameControllerType", "SDL_CONTROLLER_TYPE_NVIDIA_SHIELD"),
	CONTROLLER_TYPE_NINTENDO_SWITCH_JOYCON_LEFT = ffi.cast("enum SDL_GameControllerType", "SDL_CONTROLLER_TYPE_NINTENDO_SWITCH_JOYCON_LEFT"),
	CONTROLLER_TYPE_NINTENDO_SWITCH_JOYCON_RIGHT = ffi.cast("enum SDL_GameControllerType", "SDL_CONTROLLER_TYPE_NINTENDO_SWITCH_JOYCON_RIGHT"),
	CONTROLLER_TYPE_NINTENDO_SWITCH_JOYCON_PAIR = ffi.cast("enum SDL_GameControllerType", "SDL_CONTROLLER_TYPE_NINTENDO_SWITCH_JOYCON_PAIR"),
	HINT_DEFAULT = ffi.cast("enum SDL_HintPriority", "SDL_HINT_DEFAULT"),
	HINT_NORMAL = ffi.cast("enum SDL_HintPriority", "SDL_HINT_NORMAL"),
	HINT_OVERRIDE = ffi.cast("enum SDL_HintPriority", "SDL_HINT_OVERRIDE"),
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
	JOYSTICK_POWER_UNKNOWN = ffi.cast("enum SDL_JoystickPowerLevel", "SDL_JOYSTICK_POWER_UNKNOWN"),
	JOYSTICK_POWER_EMPTY = ffi.cast("enum SDL_JoystickPowerLevel", "SDL_JOYSTICK_POWER_EMPTY"),
	JOYSTICK_POWER_LOW = ffi.cast("enum SDL_JoystickPowerLevel", "SDL_JOYSTICK_POWER_LOW"),
	JOYSTICK_POWER_MEDIUM = ffi.cast("enum SDL_JoystickPowerLevel", "SDL_JOYSTICK_POWER_MEDIUM"),
	JOYSTICK_POWER_FULL = ffi.cast("enum SDL_JoystickPowerLevel", "SDL_JOYSTICK_POWER_FULL"),
	JOYSTICK_POWER_WIRED = ffi.cast("enum SDL_JoystickPowerLevel", "SDL_JOYSTICK_POWER_WIRED"),
	JOYSTICK_POWER_MAX = ffi.cast("enum SDL_JoystickPowerLevel", "SDL_JOYSTICK_POWER_MAX"),
	JOYSTICK_TYPE_UNKNOWN = ffi.cast("enum SDL_JoystickType", "SDL_JOYSTICK_TYPE_UNKNOWN"),
	JOYSTICK_TYPE_GAMECONTROLLER = ffi.cast("enum SDL_JoystickType", "SDL_JOYSTICK_TYPE_GAMECONTROLLER"),
	JOYSTICK_TYPE_WHEEL = ffi.cast("enum SDL_JoystickType", "SDL_JOYSTICK_TYPE_WHEEL"),
	JOYSTICK_TYPE_ARCADE_STICK = ffi.cast("enum SDL_JoystickType", "SDL_JOYSTICK_TYPE_ARCADE_STICK"),
	JOYSTICK_TYPE_FLIGHT_STICK = ffi.cast("enum SDL_JoystickType", "SDL_JOYSTICK_TYPE_FLIGHT_STICK"),
	JOYSTICK_TYPE_DANCE_PAD = ffi.cast("enum SDL_JoystickType", "SDL_JOYSTICK_TYPE_DANCE_PAD"),
	JOYSTICK_TYPE_GUITAR = ffi.cast("enum SDL_JoystickType", "SDL_JOYSTICK_TYPE_GUITAR"),
	JOYSTICK_TYPE_DRUM_KIT = ffi.cast("enum SDL_JoystickType", "SDL_JOYSTICK_TYPE_DRUM_KIT"),
	JOYSTICK_TYPE_ARCADE_PAD = ffi.cast("enum SDL_JoystickType", "SDL_JOYSTICK_TYPE_ARCADE_PAD"),
	JOYSTICK_TYPE_THROTTLE = ffi.cast("enum SDL_JoystickType", "SDL_JOYSTICK_TYPE_THROTTLE"),
	LOG_CATEGORY_APPLICATION = ffi.cast("enum SDL_LogCategory", "SDL_LOG_CATEGORY_APPLICATION"),
	LOG_CATEGORY_ERROR = ffi.cast("enum SDL_LogCategory", "SDL_LOG_CATEGORY_ERROR"),
	LOG_CATEGORY_ASSERT = ffi.cast("enum SDL_LogCategory", "SDL_LOG_CATEGORY_ASSERT"),
	LOG_CATEGORY_SYSTEM = ffi.cast("enum SDL_LogCategory", "SDL_LOG_CATEGORY_SYSTEM"),
	LOG_CATEGORY_AUDIO = ffi.cast("enum SDL_LogCategory", "SDL_LOG_CATEGORY_AUDIO"),
	LOG_CATEGORY_VIDEO = ffi.cast("enum SDL_LogCategory", "SDL_LOG_CATEGORY_VIDEO"),
	LOG_CATEGORY_RENDER = ffi.cast("enum SDL_LogCategory", "SDL_LOG_CATEGORY_RENDER"),
	LOG_CATEGORY_INPUT = ffi.cast("enum SDL_LogCategory", "SDL_LOG_CATEGORY_INPUT"),
	LOG_CATEGORY_TEST = ffi.cast("enum SDL_LogCategory", "SDL_LOG_CATEGORY_TEST"),
	LOG_CATEGORY_RESERVED1 = ffi.cast("enum SDL_LogCategory", "SDL_LOG_CATEGORY_RESERVED1"),
	LOG_CATEGORY_RESERVED2 = ffi.cast("enum SDL_LogCategory", "SDL_LOG_CATEGORY_RESERVED2"),
	LOG_CATEGORY_RESERVED3 = ffi.cast("enum SDL_LogCategory", "SDL_LOG_CATEGORY_RESERVED3"),
	LOG_CATEGORY_RESERVED4 = ffi.cast("enum SDL_LogCategory", "SDL_LOG_CATEGORY_RESERVED4"),
	LOG_CATEGORY_RESERVED5 = ffi.cast("enum SDL_LogCategory", "SDL_LOG_CATEGORY_RESERVED5"),
	LOG_CATEGORY_RESERVED6 = ffi.cast("enum SDL_LogCategory", "SDL_LOG_CATEGORY_RESERVED6"),
	LOG_CATEGORY_RESERVED7 = ffi.cast("enum SDL_LogCategory", "SDL_LOG_CATEGORY_RESERVED7"),
	LOG_CATEGORY_RESERVED8 = ffi.cast("enum SDL_LogCategory", "SDL_LOG_CATEGORY_RESERVED8"),
	LOG_CATEGORY_RESERVED9 = ffi.cast("enum SDL_LogCategory", "SDL_LOG_CATEGORY_RESERVED9"),
	LOG_CATEGORY_RESERVED10 = ffi.cast("enum SDL_LogCategory", "SDL_LOG_CATEGORY_RESERVED10"),
	LOG_CATEGORY_CUSTOM = ffi.cast("enum SDL_LogCategory", "SDL_LOG_CATEGORY_CUSTOM"),
	LOG_PRIORITY_VERBOSE = ffi.cast("enum SDL_LogPriority", "SDL_LOG_PRIORITY_VERBOSE"),
	LOG_PRIORITY_DEBUG = ffi.cast("enum SDL_LogPriority", "SDL_LOG_PRIORITY_DEBUG"),
	LOG_PRIORITY_INFO = ffi.cast("enum SDL_LogPriority", "SDL_LOG_PRIORITY_INFO"),
	LOG_PRIORITY_WARN = ffi.cast("enum SDL_LogPriority", "SDL_LOG_PRIORITY_WARN"),
	LOG_PRIORITY_ERROR = ffi.cast("enum SDL_LogPriority", "SDL_LOG_PRIORITY_ERROR"),
	LOG_PRIORITY_CRITICAL = ffi.cast("enum SDL_LogPriority", "SDL_LOG_PRIORITY_CRITICAL"),
	NUM_LOG_PRIORITIES = ffi.cast("enum SDL_LogPriority", "SDL_NUM_LOG_PRIORITIES"),
	MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT = ffi.cast("enum SDL_MessageBoxButtonFlags", "SDL_MESSAGEBOX_BUTTON_RETURNKEY_DEFAULT"),
	MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT = ffi.cast("enum SDL_MessageBoxButtonFlags", "SDL_MESSAGEBOX_BUTTON_ESCAPEKEY_DEFAULT"),
	MESSAGEBOX_COLOR_BACKGROUND = ffi.cast("enum SDL_MessageBoxColorType", "SDL_MESSAGEBOX_COLOR_BACKGROUND"),
	MESSAGEBOX_COLOR_TEXT = ffi.cast("enum SDL_MessageBoxColorType", "SDL_MESSAGEBOX_COLOR_TEXT"),
	MESSAGEBOX_COLOR_BUTTON_BORDER = ffi.cast("enum SDL_MessageBoxColorType", "SDL_MESSAGEBOX_COLOR_BUTTON_BORDER"),
	MESSAGEBOX_COLOR_BUTTON_BACKGROUND = ffi.cast("enum SDL_MessageBoxColorType", "SDL_MESSAGEBOX_COLOR_BUTTON_BACKGROUND"),
	MESSAGEBOX_COLOR_BUTTON_SELECTED = ffi.cast("enum SDL_MessageBoxColorType", "SDL_MESSAGEBOX_COLOR_BUTTON_SELECTED"),
	MESSAGEBOX_COLOR_MAX = ffi.cast("enum SDL_MessageBoxColorType", "SDL_MESSAGEBOX_COLOR_MAX"),
	MESSAGEBOX_ERROR = ffi.cast("enum SDL_MessageBoxFlags", "SDL_MESSAGEBOX_ERROR"),
	MESSAGEBOX_WARNING = ffi.cast("enum SDL_MessageBoxFlags", "SDL_MESSAGEBOX_WARNING"),
	MESSAGEBOX_INFORMATION = ffi.cast("enum SDL_MessageBoxFlags", "SDL_MESSAGEBOX_INFORMATION"),
	MESSAGEBOX_BUTTONS_LEFT_TO_RIGHT = ffi.cast("enum SDL_MessageBoxFlags", "SDL_MESSAGEBOX_BUTTONS_LEFT_TO_RIGHT"),
	MESSAGEBOX_BUTTONS_RIGHT_TO_LEFT = ffi.cast("enum SDL_MessageBoxFlags", "SDL_MESSAGEBOX_BUTTONS_RIGHT_TO_LEFT"),
	MOUSEWHEEL_NORMAL = ffi.cast("enum SDL_MouseWheelDirection", "SDL_MOUSEWHEEL_NORMAL"),
	MOUSEWHEEL_FLIPPED = ffi.cast("enum SDL_MouseWheelDirection", "SDL_MOUSEWHEEL_FLIPPED"),
	PACKEDLAYOUT_NONE = ffi.cast("enum SDL_PackedLayout", "SDL_PACKEDLAYOUT_NONE"),
	PACKEDLAYOUT_332 = ffi.cast("enum SDL_PackedLayout", "SDL_PACKEDLAYOUT_332"),
	PACKEDLAYOUT_4444 = ffi.cast("enum SDL_PackedLayout", "SDL_PACKEDLAYOUT_4444"),
	PACKEDLAYOUT_1555 = ffi.cast("enum SDL_PackedLayout", "SDL_PACKEDLAYOUT_1555"),
	PACKEDLAYOUT_5551 = ffi.cast("enum SDL_PackedLayout", "SDL_PACKEDLAYOUT_5551"),
	PACKEDLAYOUT_565 = ffi.cast("enum SDL_PackedLayout", "SDL_PACKEDLAYOUT_565"),
	PACKEDLAYOUT_8888 = ffi.cast("enum SDL_PackedLayout", "SDL_PACKEDLAYOUT_8888"),
	PACKEDLAYOUT_2101010 = ffi.cast("enum SDL_PackedLayout", "SDL_PACKEDLAYOUT_2101010"),
	PACKEDLAYOUT_1010102 = ffi.cast("enum SDL_PackedLayout", "SDL_PACKEDLAYOUT_1010102"),
	PACKEDORDER_NONE = ffi.cast("enum SDL_PackedOrder", "SDL_PACKEDORDER_NONE"),
	PACKEDORDER_XRGB = ffi.cast("enum SDL_PackedOrder", "SDL_PACKEDORDER_XRGB"),
	PACKEDORDER_RGBX = ffi.cast("enum SDL_PackedOrder", "SDL_PACKEDORDER_RGBX"),
	PACKEDORDER_ARGB = ffi.cast("enum SDL_PackedOrder", "SDL_PACKEDORDER_ARGB"),
	PACKEDORDER_RGBA = ffi.cast("enum SDL_PackedOrder", "SDL_PACKEDORDER_RGBA"),
	PACKEDORDER_XBGR = ffi.cast("enum SDL_PackedOrder", "SDL_PACKEDORDER_XBGR"),
	PACKEDORDER_BGRX = ffi.cast("enum SDL_PackedOrder", "SDL_PACKEDORDER_BGRX"),
	PACKEDORDER_ABGR = ffi.cast("enum SDL_PackedOrder", "SDL_PACKEDORDER_ABGR"),
	PACKEDORDER_BGRA = ffi.cast("enum SDL_PackedOrder", "SDL_PACKEDORDER_BGRA"),
	PIXELFORMAT_UNKNOWN = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_UNKNOWN"),
	PIXELFORMAT_INDEX1LSB = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_INDEX1LSB"),
	PIXELFORMAT_INDEX1MSB = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_INDEX1MSB"),
	PIXELFORMAT_INDEX4LSB = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_INDEX4LSB"),
	PIXELFORMAT_INDEX4MSB = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_INDEX4MSB"),
	PIXELFORMAT_INDEX8 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_INDEX8"),
	PIXELFORMAT_RGB332 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_RGB332"),
	PIXELFORMAT_XRGB4444 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_XRGB4444"),
	PIXELFORMAT_RGB444 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_RGB444"),
	PIXELFORMAT_XBGR4444 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_XBGR4444"),
	PIXELFORMAT_BGR444 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_BGR444"),
	PIXELFORMAT_XRGB1555 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_XRGB1555"),
	PIXELFORMAT_RGB555 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_RGB555"),
	PIXELFORMAT_XBGR1555 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_XBGR1555"),
	PIXELFORMAT_BGR555 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_BGR555"),
	PIXELFORMAT_ARGB4444 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_ARGB4444"),
	PIXELFORMAT_RGBA4444 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_RGBA4444"),
	PIXELFORMAT_ABGR4444 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_ABGR4444"),
	PIXELFORMAT_BGRA4444 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_BGRA4444"),
	PIXELFORMAT_ARGB1555 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_ARGB1555"),
	PIXELFORMAT_RGBA5551 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_RGBA5551"),
	PIXELFORMAT_ABGR1555 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_ABGR1555"),
	PIXELFORMAT_BGRA5551 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_BGRA5551"),
	PIXELFORMAT_RGB565 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_RGB565"),
	PIXELFORMAT_BGR565 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_BGR565"),
	PIXELFORMAT_RGB24 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_RGB24"),
	PIXELFORMAT_BGR24 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_BGR24"),
	PIXELFORMAT_XRGB8888 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_XRGB8888"),
	PIXELFORMAT_RGB888 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_RGB888"),
	PIXELFORMAT_RGBX8888 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_RGBX8888"),
	PIXELFORMAT_XBGR8888 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_XBGR8888"),
	PIXELFORMAT_BGR888 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_BGR888"),
	PIXELFORMAT_BGRX8888 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_BGRX8888"),
	PIXELFORMAT_ARGB8888 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_ARGB8888"),
	PIXELFORMAT_RGBA8888 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_RGBA8888"),
	PIXELFORMAT_ABGR8888 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_ABGR8888"),
	PIXELFORMAT_BGRA8888 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_BGRA8888"),
	PIXELFORMAT_ARGB2101010 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_ARGB2101010"),
	PIXELFORMAT_RGBA32 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_RGBA32"),
	PIXELFORMAT_ARGB32 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_ARGB32"),
	PIXELFORMAT_BGRA32 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_BGRA32"),
	PIXELFORMAT_ABGR32 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_ABGR32"),
	PIXELFORMAT_YV12 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_YV12"),
	PIXELFORMAT_IYUV = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_IYUV"),
	PIXELFORMAT_YUY2 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_YUY2"),
	PIXELFORMAT_UYVY = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_UYVY"),
	PIXELFORMAT_YVYU = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_YVYU"),
	PIXELFORMAT_NV12 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_NV12"),
	PIXELFORMAT_NV21 = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_NV21"),
	PIXELFORMAT_EXTERNAL_OES = ffi.cast("enum SDL_PixelFormatEnum", "SDL_PIXELFORMAT_EXTERNAL_OES"),
	PIXELTYPE_UNKNOWN = ffi.cast("enum SDL_PixelType", "SDL_PIXELTYPE_UNKNOWN"),
	PIXELTYPE_INDEX1 = ffi.cast("enum SDL_PixelType", "SDL_PIXELTYPE_INDEX1"),
	PIXELTYPE_INDEX4 = ffi.cast("enum SDL_PixelType", "SDL_PIXELTYPE_INDEX4"),
	PIXELTYPE_INDEX8 = ffi.cast("enum SDL_PixelType", "SDL_PIXELTYPE_INDEX8"),
	PIXELTYPE_PACKED8 = ffi.cast("enum SDL_PixelType", "SDL_PIXELTYPE_PACKED8"),
	PIXELTYPE_PACKED16 = ffi.cast("enum SDL_PixelType", "SDL_PIXELTYPE_PACKED16"),
	PIXELTYPE_PACKED32 = ffi.cast("enum SDL_PixelType", "SDL_PIXELTYPE_PACKED32"),
	PIXELTYPE_ARRAYU8 = ffi.cast("enum SDL_PixelType", "SDL_PIXELTYPE_ARRAYU8"),
	PIXELTYPE_ARRAYU16 = ffi.cast("enum SDL_PixelType", "SDL_PIXELTYPE_ARRAYU16"),
	PIXELTYPE_ARRAYU32 = ffi.cast("enum SDL_PixelType", "SDL_PIXELTYPE_ARRAYU32"),
	PIXELTYPE_ARRAYF16 = ffi.cast("enum SDL_PixelType", "SDL_PIXELTYPE_ARRAYF16"),
	PIXELTYPE_ARRAYF32 = ffi.cast("enum SDL_PixelType", "SDL_PIXELTYPE_ARRAYF32"),
	POWERSTATE_UNKNOWN = ffi.cast("enum SDL_PowerState", "SDL_POWERSTATE_UNKNOWN"),
	POWERSTATE_ON_BATTERY = ffi.cast("enum SDL_PowerState", "SDL_POWERSTATE_ON_BATTERY"),
	POWERSTATE_NO_BATTERY = ffi.cast("enum SDL_PowerState", "SDL_POWERSTATE_NO_BATTERY"),
	POWERSTATE_CHARGING = ffi.cast("enum SDL_PowerState", "SDL_POWERSTATE_CHARGING"),
	POWERSTATE_CHARGED = ffi.cast("enum SDL_PowerState", "SDL_POWERSTATE_CHARGED"),
	RENDERER_SOFTWARE = ffi.cast("enum SDL_RendererFlags", "SDL_RENDERER_SOFTWARE"),
	RENDERER_ACCELERATED = ffi.cast("enum SDL_RendererFlags", "SDL_RENDERER_ACCELERATED"),
	RENDERER_PRESENTVSYNC = ffi.cast("enum SDL_RendererFlags", "SDL_RENDERER_PRESENTVSYNC"),
	RENDERER_TARGETTEXTURE = ffi.cast("enum SDL_RendererFlags", "SDL_RENDERER_TARGETTEXTURE"),
	FLIP_NONE = ffi.cast("enum SDL_RendererFlip", "SDL_FLIP_NONE"),
	FLIP_HORIZONTAL = ffi.cast("enum SDL_RendererFlip", "SDL_FLIP_HORIZONTAL"),
	FLIP_VERTICAL = ffi.cast("enum SDL_RendererFlip", "SDL_FLIP_VERTICAL"),
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
	SYSWM_OS2 = ffi.cast("enum SDL_SYSWM_TYPE", "SDL_SYSWM_OS2"),
	SYSWM_HAIKU = ffi.cast("enum SDL_SYSWM_TYPE", "SDL_SYSWM_HAIKU"),
	SYSWM_KMSDRM = ffi.cast("enum SDL_SYSWM_TYPE", "SDL_SYSWM_KMSDRM"),
	SYSWM_RISCOS = ffi.cast("enum SDL_SYSWM_TYPE", "SDL_SYSWM_RISCOS"),
	ScaleModeNearest = ffi.cast("enum SDL_ScaleMode", "SDL_ScaleModeNearest"),
	ScaleModeLinear = ffi.cast("enum SDL_ScaleMode", "SDL_ScaleModeLinear"),
	ScaleModeBest = ffi.cast("enum SDL_ScaleMode", "SDL_ScaleModeBest"),
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
	SCANCODE_AUDIOREWIND = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_AUDIOREWIND"),
	SCANCODE_AUDIOFASTFORWARD = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_AUDIOFASTFORWARD"),
	SCANCODE_SOFTLEFT = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_SOFTLEFT"),
	SCANCODE_SOFTRIGHT = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_SOFTRIGHT"),
	SCANCODE_CALL = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_CALL"),
	SCANCODE_ENDCALL = ffi.cast("enum SDL_Scancode", "SDL_SCANCODE_ENDCALL"),
	NUM_SCANCODES = ffi.cast("enum SDL_Scancode", "SDL_NUM_SCANCODES"),
	SENSOR_INVALID = ffi.cast("enum SDL_SensorType", "SDL_SENSOR_INVALID"),
	SENSOR_UNKNOWN = ffi.cast("enum SDL_SensorType", "SDL_SENSOR_UNKNOWN"),
	SENSOR_ACCEL = ffi.cast("enum SDL_SensorType", "SDL_SENSOR_ACCEL"),
	SENSOR_GYRO = ffi.cast("enum SDL_SensorType", "SDL_SENSOR_GYRO"),
	SENSOR_ACCEL_L = ffi.cast("enum SDL_SensorType", "SDL_SENSOR_ACCEL_L"),
	SENSOR_GYRO_L = ffi.cast("enum SDL_SensorType", "SDL_SENSOR_GYRO_L"),
	SENSOR_ACCEL_R = ffi.cast("enum SDL_SensorType", "SDL_SENSOR_ACCEL_R"),
	SENSOR_GYRO_R = ffi.cast("enum SDL_SensorType", "SDL_SENSOR_GYRO_R"),
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
	TEXTUREACCESS_STATIC = ffi.cast("enum SDL_TextureAccess", "SDL_TEXTUREACCESS_STATIC"),
	TEXTUREACCESS_STREAMING = ffi.cast("enum SDL_TextureAccess", "SDL_TEXTUREACCESS_STREAMING"),
	TEXTUREACCESS_TARGET = ffi.cast("enum SDL_TextureAccess", "SDL_TEXTUREACCESS_TARGET"),
	TEXTUREMODULATE_NONE = ffi.cast("enum SDL_TextureModulate", "SDL_TEXTUREMODULATE_NONE"),
	TEXTUREMODULATE_COLOR = ffi.cast("enum SDL_TextureModulate", "SDL_TEXTUREMODULATE_COLOR"),
	TEXTUREMODULATE_ALPHA = ffi.cast("enum SDL_TextureModulate", "SDL_TEXTUREMODULATE_ALPHA"),
	THREAD_PRIORITY_LOW = ffi.cast("enum SDL_ThreadPriority", "SDL_THREAD_PRIORITY_LOW"),
	THREAD_PRIORITY_NORMAL = ffi.cast("enum SDL_ThreadPriority", "SDL_THREAD_PRIORITY_NORMAL"),
	THREAD_PRIORITY_HIGH = ffi.cast("enum SDL_ThreadPriority", "SDL_THREAD_PRIORITY_HIGH"),
	THREAD_PRIORITY_TIME_CRITICAL = ffi.cast("enum SDL_ThreadPriority", "SDL_THREAD_PRIORITY_TIME_CRITICAL"),
	TOUCH_DEVICE_INVALID = ffi.cast("enum SDL_TouchDeviceType", "SDL_TOUCH_DEVICE_INVALID"),
	TOUCH_DEVICE_DIRECT = ffi.cast("enum SDL_TouchDeviceType", "SDL_TOUCH_DEVICE_DIRECT"),
	TOUCH_DEVICE_INDIRECT_ABSOLUTE = ffi.cast("enum SDL_TouchDeviceType", "SDL_TOUCH_DEVICE_INDIRECT_ABSOLUTE"),
	TOUCH_DEVICE_INDIRECT_RELATIVE = ffi.cast("enum SDL_TouchDeviceType", "SDL_TOUCH_DEVICE_INDIRECT_RELATIVE"),
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
	WINDOWEVENT_ICCPROF_CHANGED = ffi.cast("enum SDL_WindowEventID", "SDL_WINDOWEVENT_ICCPROF_CHANGED"),
	WINDOWEVENT_DISPLAY_CHANGED = ffi.cast("enum SDL_WindowEventID", "SDL_WINDOWEVENT_DISPLAY_CHANGED"),
	WINDOW_FULLSCREEN = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_FULLSCREEN"),
	WINDOW_OPENGL = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_OPENGL"),
	WINDOW_SHOWN = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_SHOWN"),
	WINDOW_HIDDEN = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_HIDDEN"),
	WINDOW_BORDERLESS = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_BORDERLESS"),
	WINDOW_RESIZABLE = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_RESIZABLE"),
	WINDOW_MINIMIZED = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_MINIMIZED"),
	WINDOW_MAXIMIZED = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_MAXIMIZED"),
	WINDOW_MOUSE_GRABBED = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_MOUSE_GRABBED"),
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
	WINDOW_KEYBOARD_GRABBED = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_KEYBOARD_GRABBED"),
	WINDOW_VULKAN = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_VULKAN"),
	WINDOW_METAL = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_METAL"),
	WINDOW_INPUT_GRABBED = ffi.cast("enum SDL_WindowFlags", "SDL_WINDOW_INPUT_GRABBED"),
	YUV_CONVERSION_JPEG = ffi.cast("enum SDL_YUV_CONVERSION_MODE", "SDL_YUV_CONVERSION_JPEG"),
	YUV_CONVERSION_BT601 = ffi.cast("enum SDL_YUV_CONVERSION_MODE", "SDL_YUV_CONVERSION_BT601"),
	YUV_CONVERSION_BT709 = ffi.cast("enum SDL_YUV_CONVERSION_MODE", "SDL_YUV_CONVERSION_BT709"),
	YUV_CONVERSION_AUTOMATIC = ffi.cast("enum SDL_YUV_CONVERSION_MODE", "SDL_YUV_CONVERSION_AUTOMATIC"),
	FALSE = ffi.cast("enum SDL_bool", "SDL_FALSE"),
	TRUE = ffi.cast("enum SDL_bool", "SDL_TRUE"),
	ENOMEM = ffi.cast("enum SDL_errorcode", "SDL_ENOMEM"),
	EFREAD = ffi.cast("enum SDL_errorcode", "SDL_EFREAD"),
	EFWRITE = ffi.cast("enum SDL_errorcode", "SDL_EFWRITE"),
	EFSEEK = ffi.cast("enum SDL_errorcode", "SDL_EFSEEK"),
	UNSUPPORTED = ffi.cast("enum SDL_errorcode", "SDL_UNSUPPORTED"),
	LASTERROR = ffi.cast("enum SDL_errorcode", "SDL_LASTERROR"),
	ADDEVENT = ffi.cast("enum SDL_eventaction", "SDL_ADDEVENT"),
	PEEKEVENT = ffi.cast("enum SDL_eventaction", "SDL_PEEKEVENT"),
	GETEVENT = ffi.cast("enum SDL_eventaction", "SDL_GETEVENT"),
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
	hints_h_ = 1,
	HINT_ACCELEROMETER_AS_JOYSTICK = "SDL_ACCELEROMETER_AS_JOYSTICK",
	HINT_ALLOW_ALT_TAB_WHILE_GRABBED = "SDL_ALLOW_ALT_TAB_WHILE_GRABBED",
	HINT_ALLOW_TOPMOST = "SDL_ALLOW_TOPMOST",
	HINT_ANDROID_APK_EXPANSION_MAIN_FILE_VERSION = "SDL_ANDROID_APK_EXPANSION_MAIN_FILE_VERSION",
	HINT_ANDROID_APK_EXPANSION_PATCH_FILE_VERSION = "SDL_ANDROID_APK_EXPANSION_PATCH_FILE_VERSION",
	HINT_ANDROID_BLOCK_ON_PAUSE = "SDL_ANDROID_BLOCK_ON_PAUSE",
	HINT_ANDROID_BLOCK_ON_PAUSE_PAUSEAUDIO = "SDL_ANDROID_BLOCK_ON_PAUSE_PAUSEAUDIO",
	HINT_ANDROID_TRAP_BACK_BUTTON = "SDL_ANDROID_TRAP_BACK_BUTTON",
	HINT_APP_NAME = "SDL_APP_NAME",
	HINT_APPLE_TV_CONTROLLER_UI_EVENTS = "SDL_APPLE_TV_CONTROLLER_UI_EVENTS",
	HINT_APPLE_TV_REMOTE_ALLOW_ROTATION = "SDL_APPLE_TV_REMOTE_ALLOW_ROTATION",
	HINT_AUDIO_CATEGORY = "SDL_AUDIO_CATEGORY",
	HINT_AUDIO_DEVICE_APP_NAME = "SDL_AUDIO_DEVICE_APP_NAME",
	HINT_AUDIO_DEVICE_STREAM_NAME = "SDL_AUDIO_DEVICE_STREAM_NAME",
	HINT_AUDIO_DEVICE_STREAM_ROLE = "SDL_AUDIO_DEVICE_STREAM_ROLE",
	HINT_AUDIO_RESAMPLING_MODE = "SDL_AUDIO_RESAMPLING_MODE",
	HINT_AUTO_UPDATE_JOYSTICKS = "SDL_AUTO_UPDATE_JOYSTICKS",
	HINT_AUTO_UPDATE_SENSORS = "SDL_AUTO_UPDATE_SENSORS",
	HINT_BMP_SAVE_LEGACY_FORMAT = "SDL_BMP_SAVE_LEGACY_FORMAT",
	HINT_DISPLAY_USABLE_BOUNDS = "SDL_DISPLAY_USABLE_BOUNDS",
	HINT_EMSCRIPTEN_ASYNCIFY = "SDL_EMSCRIPTEN_ASYNCIFY",
	HINT_EMSCRIPTEN_KEYBOARD_ELEMENT = "SDL_EMSCRIPTEN_KEYBOARD_ELEMENT",
	HINT_ENABLE_STEAM_CONTROLLERS = "SDL_ENABLE_STEAM_CONTROLLERS",
	HINT_EVENT_LOGGING = "SDL_EVENT_LOGGING",
	HINT_FRAMEBUFFER_ACCELERATION = "SDL_FRAMEBUFFER_ACCELERATION",
	HINT_GAMECONTROLLERCONFIG = "SDL_GAMECONTROLLERCONFIG",
	HINT_GAMECONTROLLERCONFIG_FILE = "SDL_GAMECONTROLLERCONFIG_FILE",
	HINT_GAMECONTROLLERTYPE = "SDL_GAMECONTROLLERTYPE",
	HINT_GAMECONTROLLER_IGNORE_DEVICES = "SDL_GAMECONTROLLER_IGNORE_DEVICES",
	HINT_GAMECONTROLLER_IGNORE_DEVICES_EXCEPT = "SDL_GAMECONTROLLER_IGNORE_DEVICES_EXCEPT",
	HINT_GAMECONTROLLER_USE_BUTTON_LABELS = "SDL_GAMECONTROLLER_USE_BUTTON_LABELS",
	HINT_GRAB_KEYBOARD = "SDL_GRAB_KEYBOARD",
	HINT_IDLE_TIMER_DISABLED = "SDL_IOS_IDLE_TIMER_DISABLED",
	HINT_IME_INTERNAL_EDITING = "SDL_IME_INTERNAL_EDITING",
	HINT_IME_SHOW_UI = "SDL_IME_SHOW_UI",
	HINT_IME_SUPPORT_EXTENDED_TEXT = "SDL_IME_SUPPORT_EXTENDED_TEXT",
	HINT_IOS_HIDE_HOME_INDICATOR = "SDL_IOS_HIDE_HOME_INDICATOR",
	HINT_JOYSTICK_ALLOW_BACKGROUND_EVENTS = "SDL_JOYSTICK_ALLOW_BACKGROUND_EVENTS",
	HINT_JOYSTICK_HIDAPI = "SDL_JOYSTICK_HIDAPI",
	HINT_JOYSTICK_HIDAPI_GAMECUBE = "SDL_JOYSTICK_HIDAPI_GAMECUBE",
	HINT_JOYSTICK_GAMECUBE_RUMBLE_BRAKE = "SDL_JOYSTICK_GAMECUBE_RUMBLE_BRAKE",
	HINT_JOYSTICK_HIDAPI_JOY_CONS = "SDL_JOYSTICK_HIDAPI_JOY_CONS",
	HINT_JOYSTICK_HIDAPI_COMBINE_JOY_CONS = "SDL_JOYSTICK_HIDAPI_COMBINE_JOY_CONS",
	HINT_JOYSTICK_HIDAPI_LUNA = "SDL_JOYSTICK_HIDAPI_LUNA",
	HINT_JOYSTICK_HIDAPI_NINTENDO_CLASSIC = "SDL_JOYSTICK_HIDAPI_NINTENDO_CLASSIC",
	HINT_JOYSTICK_HIDAPI_SHIELD = "SDL_JOYSTICK_HIDAPI_SHIELD",
	HINT_JOYSTICK_HIDAPI_PS3 = "SDL_JOYSTICK_HIDAPI_PS3",
	HINT_JOYSTICK_HIDAPI_PS4 = "SDL_JOYSTICK_HIDAPI_PS4",
	HINT_JOYSTICK_HIDAPI_PS4_RUMBLE = "SDL_JOYSTICK_HIDAPI_PS4_RUMBLE",
	HINT_JOYSTICK_HIDAPI_PS5 = "SDL_JOYSTICK_HIDAPI_PS5",
	HINT_JOYSTICK_HIDAPI_PS5_PLAYER_LED = "SDL_JOYSTICK_HIDAPI_PS5_PLAYER_LED",
	HINT_JOYSTICK_HIDAPI_PS5_RUMBLE = "SDL_JOYSTICK_HIDAPI_PS5_RUMBLE",
	HINT_JOYSTICK_HIDAPI_STADIA = "SDL_JOYSTICK_HIDAPI_STADIA",
	HINT_JOYSTICK_HIDAPI_STEAM = "SDL_JOYSTICK_HIDAPI_STEAM",
	HINT_JOYSTICK_HIDAPI_SWITCH = "SDL_JOYSTICK_HIDAPI_SWITCH",
	HINT_JOYSTICK_HIDAPI_SWITCH_HOME_LED = "SDL_JOYSTICK_HIDAPI_SWITCH_HOME_LED",
	HINT_JOYSTICK_HIDAPI_JOYCON_HOME_LED = "SDL_JOYSTICK_HIDAPI_JOYCON_HOME_LED",
	HINT_JOYSTICK_HIDAPI_SWITCH_PLAYER_LED = "SDL_JOYSTICK_HIDAPI_SWITCH_PLAYER_LED",
	HINT_JOYSTICK_HIDAPI_WII = "SDL_JOYSTICK_HIDAPI_WII",
	HINT_JOYSTICK_HIDAPI_WII_PLAYER_LED = "SDL_JOYSTICK_HIDAPI_WII_PLAYER_LED",
	HINT_JOYSTICK_HIDAPI_XBOX = "SDL_JOYSTICK_HIDAPI_XBOX",
	HINT_JOYSTICK_HIDAPI_XBOX_360 = "SDL_JOYSTICK_HIDAPI_XBOX_360",
	HINT_JOYSTICK_HIDAPI_XBOX_360_PLAYER_LED = "SDL_JOYSTICK_HIDAPI_XBOX_360_PLAYER_LED",
	HINT_JOYSTICK_HIDAPI_XBOX_360_WIRELESS = "SDL_JOYSTICK_HIDAPI_XBOX_360_WIRELESS",
	HINT_JOYSTICK_HIDAPI_XBOX_ONE = "SDL_JOYSTICK_HIDAPI_XBOX_ONE",
	HINT_JOYSTICK_RAWINPUT = "SDL_JOYSTICK_RAWINPUT",
	HINT_JOYSTICK_RAWINPUT_CORRELATE_XINPUT = "SDL_JOYSTICK_RAWINPUT_CORRELATE_XINPUT",
	HINT_JOYSTICK_ROG_CHAKRAM = "SDL_JOYSTICK_ROG_CHAKRAM",
	HINT_JOYSTICK_THREAD = "SDL_JOYSTICK_THREAD",
	HINT_KMSDRM_REQUIRE_DRM_MASTER = "SDL_KMSDRM_REQUIRE_DRM_MASTER",
	HINT_JOYSTICK_DEVICE = "SDL_JOYSTICK_DEVICE",
	HINT_LINUX_DIGITAL_HATS = "SDL_LINUX_DIGITAL_HATS",
	HINT_LINUX_HAT_DEADZONES = "SDL_LINUX_HAT_DEADZONES",
	HINT_LINUX_JOYSTICK_CLASSIC = "SDL_LINUX_JOYSTICK_CLASSIC",
	HINT_LINUX_JOYSTICK_DEADZONES = "SDL_LINUX_JOYSTICK_DEADZONES",
	HINT_MAC_BACKGROUND_APP = "SDL_MAC_BACKGROUND_APP",
	HINT_MAC_CTRL_CLICK_EMULATE_RIGHT_CLICK = "SDL_MAC_CTRL_CLICK_EMULATE_RIGHT_CLICK",
	HINT_MAC_OPENGL_ASYNC_DISPATCH = "SDL_MAC_OPENGL_ASYNC_DISPATCH",
	HINT_MOUSE_DOUBLE_CLICK_RADIUS = "SDL_MOUSE_DOUBLE_CLICK_RADIUS",
	HINT_MOUSE_DOUBLE_CLICK_TIME = "SDL_MOUSE_DOUBLE_CLICK_TIME",
	HINT_MOUSE_FOCUS_CLICKTHROUGH = "SDL_MOUSE_FOCUS_CLICKTHROUGH",
	HINT_MOUSE_NORMAL_SPEED_SCALE = "SDL_MOUSE_NORMAL_SPEED_SCALE",
	HINT_MOUSE_RELATIVE_MODE_CENTER = "SDL_MOUSE_RELATIVE_MODE_CENTER",
	HINT_MOUSE_RELATIVE_MODE_WARP = "SDL_MOUSE_RELATIVE_MODE_WARP",
	HINT_MOUSE_RELATIVE_SCALING = "SDL_MOUSE_RELATIVE_SCALING",
	HINT_MOUSE_RELATIVE_SPEED_SCALE = "SDL_MOUSE_RELATIVE_SPEED_SCALE",
	HINT_MOUSE_RELATIVE_SYSTEM_SCALE = "SDL_MOUSE_RELATIVE_SYSTEM_SCALE",
	HINT_MOUSE_RELATIVE_WARP_MOTION = "SDL_MOUSE_RELATIVE_WARP_MOTION",
	HINT_MOUSE_TOUCH_EVENTS = "SDL_MOUSE_TOUCH_EVENTS",
	HINT_MOUSE_AUTO_CAPTURE = "SDL_MOUSE_AUTO_CAPTURE",
	HINT_NO_SIGNAL_HANDLERS = "SDL_NO_SIGNAL_HANDLERS",
	HINT_OPENGL_ES_DRIVER = "SDL_OPENGL_ES_DRIVER",
	HINT_ORIENTATIONS = "SDL_IOS_ORIENTATIONS",
	HINT_POLL_SENTINEL = "SDL_POLL_SENTINEL",
	HINT_PREFERRED_LOCALES = "SDL_PREFERRED_LOCALES",
	HINT_QTWAYLAND_CONTENT_ORIENTATION = "SDL_QTWAYLAND_CONTENT_ORIENTATION",
	HINT_QTWAYLAND_WINDOW_FLAGS = "SDL_QTWAYLAND_WINDOW_FLAGS",
	HINT_RENDER_BATCHING = "SDL_RENDER_BATCHING",
	HINT_RENDER_LINE_METHOD = "SDL_RENDER_LINE_METHOD",
	HINT_RENDER_DIRECT3D11_DEBUG = "SDL_RENDER_DIRECT3D11_DEBUG",
	HINT_RENDER_DIRECT3D_THREADSAFE = "SDL_RENDER_DIRECT3D_THREADSAFE",
	HINT_RENDER_DRIVER = "SDL_RENDER_DRIVER",
	HINT_RENDER_LOGICAL_SIZE_MODE = "SDL_RENDER_LOGICAL_SIZE_MODE",
	HINT_RENDER_OPENGL_SHADERS = "SDL_RENDER_OPENGL_SHADERS",
	HINT_RENDER_SCALE_QUALITY = "SDL_RENDER_SCALE_QUALITY",
	HINT_RENDER_VSYNC = "SDL_RENDER_VSYNC",
	HINT_PS2_DYNAMIC_VSYNC = "SDL_PS2_DYNAMIC_VSYNC",
	HINT_RETURN_KEY_HIDES_IME = "SDL_RETURN_KEY_HIDES_IME",
	HINT_RPI_VIDEO_LAYER = "SDL_RPI_VIDEO_LAYER",
	HINT_SCREENSAVER_INHIBIT_ACTIVITY_NAME = "SDL_SCREENSAVER_INHIBIT_ACTIVITY_NAME",
	HINT_THREAD_FORCE_REALTIME_TIME_CRITICAL = "SDL_THREAD_FORCE_REALTIME_TIME_CRITICAL",
	HINT_THREAD_PRIORITY_POLICY = "SDL_THREAD_PRIORITY_POLICY",
	HINT_THREAD_STACK_SIZE = "SDL_THREAD_STACK_SIZE",
	HINT_TIMER_RESOLUTION = "SDL_TIMER_RESOLUTION",
	HINT_TOUCH_MOUSE_EVENTS = "SDL_TOUCH_MOUSE_EVENTS",
	HINT_TV_REMOTE_AS_JOYSTICK = "SDL_TV_REMOTE_AS_JOYSTICK",
	HINT_VIDEO_ALLOW_SCREENSAVER = "SDL_VIDEO_ALLOW_SCREENSAVER",
	HINT_VIDEO_DOUBLE_BUFFER = "SDL_VIDEO_DOUBLE_BUFFER",
	HINT_VIDEO_EGL_ALLOW_TRANSPARENCY = "SDL_VIDEO_EGL_ALLOW_TRANSPARENCY",
	HINT_VIDEO_EXTERNAL_CONTEXT = "SDL_VIDEO_EXTERNAL_CONTEXT",
	HINT_VIDEO_HIGHDPI_DISABLED = "SDL_VIDEO_HIGHDPI_DISABLED",
	HINT_VIDEO_MAC_FULLSCREEN_SPACES = "SDL_VIDEO_MAC_FULLSCREEN_SPACES",
	HINT_VIDEO_MINIMIZE_ON_FOCUS_LOSS = "SDL_VIDEO_MINIMIZE_ON_FOCUS_LOSS",
	HINT_VIDEO_WAYLAND_ALLOW_LIBDECOR = "SDL_VIDEO_WAYLAND_ALLOW_LIBDECOR",
	HINT_VIDEO_WAYLAND_PREFER_LIBDECOR = "SDL_VIDEO_WAYLAND_PREFER_LIBDECOR",
	HINT_VIDEO_WAYLAND_MODE_EMULATION = "SDL_VIDEO_WAYLAND_MODE_EMULATION",
	HINT_VIDEO_WINDOW_SHARE_PIXEL_FORMAT = "SDL_VIDEO_WINDOW_SHARE_PIXEL_FORMAT",
	HINT_VIDEO_FOREIGN_WINDOW_OPENGL = "SDL_VIDEO_FOREIGN_WINDOW_OPENGL",
	HINT_VIDEO_FOREIGN_WINDOW_VULKAN = "SDL_VIDEO_FOREIGN_WINDOW_VULKAN",
	HINT_VIDEO_WIN_D3DCOMPILER = "SDL_VIDEO_WIN_D3DCOMPILER",
	HINT_VIDEO_X11_FORCE_EGL = "SDL_VIDEO_X11_FORCE_EGL",
	HINT_VIDEO_X11_NET_WM_BYPASS_COMPOSITOR = "SDL_VIDEO_X11_NET_WM_BYPASS_COMPOSITOR",
	HINT_VIDEO_X11_NET_WM_PING = "SDL_VIDEO_X11_NET_WM_PING",
	HINT_VIDEO_X11_WINDOW_VISUALID = "SDL_VIDEO_X11_WINDOW_VISUALID",
	HINT_VIDEO_X11_XINERAMA = "SDL_VIDEO_X11_XINERAMA",
	HINT_VIDEO_X11_XRANDR = "SDL_VIDEO_X11_XRANDR",
	HINT_VIDEO_X11_XVIDMODE = "SDL_VIDEO_X11_XVIDMODE",
	HINT_WAVE_FACT_CHUNK = "SDL_WAVE_FACT_CHUNK",
	HINT_WAVE_RIFF_CHUNK_SIZE = "SDL_WAVE_RIFF_CHUNK_SIZE",
	HINT_WAVE_TRUNCATION = "SDL_WAVE_TRUNCATION",
	HINT_WINDOWS_DISABLE_THREAD_NAMING = "SDL_WINDOWS_DISABLE_THREAD_NAMING",
	HINT_WINDOWS_ENABLE_MESSAGELOOP = "SDL_WINDOWS_ENABLE_MESSAGELOOP",
	HINT_WINDOWS_FORCE_MUTEX_CRITICAL_SECTIONS = "SDL_WINDOWS_FORCE_MUTEX_CRITICAL_SECTIONS",
	HINT_WINDOWS_FORCE_SEMAPHORE_KERNEL = "SDL_WINDOWS_FORCE_SEMAPHORE_KERNEL",
	HINT_WINDOWS_INTRESOURCE_ICON = "SDL_WINDOWS_INTRESOURCE_ICON",
	HINT_WINDOWS_INTRESOURCE_ICON_SMALL = "SDL_WINDOWS_INTRESOURCE_ICON_SMALL",
	HINT_WINDOWS_NO_CLOSE_ON_ALT_F4 = "SDL_WINDOWS_NO_CLOSE_ON_ALT_F4",
	HINT_WINDOWS_USE_D3D9EX = "SDL_WINDOWS_USE_D3D9EX",
	HINT_WINDOWS_DPI_AWARENESS = "SDL_WINDOWS_DPI_AWARENESS",
	HINT_WINDOWS_DPI_SCALING = "SDL_WINDOWS_DPI_SCALING",
	HINT_WINDOW_FRAME_USABLE_WHILE_CURSOR_HIDDEN = "SDL_WINDOW_FRAME_USABLE_WHILE_CURSOR_HIDDEN",
	HINT_WINDOW_NO_ACTIVATION_WHEN_SHOWN = "SDL_WINDOW_NO_ACTIVATION_WHEN_SHOWN",
	HINT_WINRT_HANDLE_BACK_BUTTON = "SDL_WINRT_HANDLE_BACK_BUTTON",
	HINT_WINRT_PRIVACY_POLICY_LABEL = "SDL_WINRT_PRIVACY_POLICY_LABEL",
	HINT_WINRT_PRIVACY_POLICY_URL = "SDL_WINRT_PRIVACY_POLICY_URL",
	HINT_X11_FORCE_OVERRIDE_REDIRECT = "SDL_X11_FORCE_OVERRIDE_REDIRECT",
	HINT_XINPUT_ENABLED = "SDL_XINPUT_ENABLED",
	HINT_DIRECTINPUT_ENABLED = "SDL_DIRECTINPUT_ENABLED",
	HINT_XINPUT_USE_OLD_JOYSTICK_MAPPING = "SDL_XINPUT_USE_OLD_JOYSTICK_MAPPING",
	HINT_AUDIO_INCLUDE_MONITORS = "SDL_AUDIO_INCLUDE_MONITORS",
	HINT_X11_WINDOW_TYPE = "SDL_X11_WINDOW_TYPE",
	HINT_QUIT_ON_LAST_WINDOW_CLOSE = "SDL_QUIT_ON_LAST_WINDOW_CLOSE",
	HINT_VIDEODRIVER = "SDL_VIDEODRIVER",
	HINT_AUDIODRIVER = "SDL_AUDIODRIVER",
	HINT_KMSDRM_DEVICE_INDEX = "SDL_KMSDRM_DEVICE_INDEX",
	HINT_TRACKPAD_IS_TOUCH_ONLY = "SDL_TRACKPAD_IS_TOUCH_ONLY",
}
		function library.CreateVulkanSurface(window, instance)
			local box = ffi.new("struct VkSurfaceKHR_T * [1]")

			if library.Vulkan_CreateSurface(window, instance, ffi.cast("void**", box)) == nil then
				return nil, ffi.string(library.GetError())
			end

			return box[0]
		end

		function library.GetRequiredInstanceExtensions(wnd, extra)
			local count = ffi.new("uint32_t[1]")

			if library.Vulkan_GetInstanceExtensions(wnd, count, nil) == 0 then
				return nil, ffi.string(library.GetError())
			end

			local array = ffi.new("const char *[?]", count[0])

			if library.Vulkan_GetInstanceExtensions(wnd, count, array) == 0 then
				return nil, ffi.string(library.GetError())
			end

			local out = {}
			for i = 0, count[0] - 1 do
				list.insert(out, ffi.string(array[i]))
			end

			if extra then
				for i,v in ipairs(extra) do
					list.insert(out, v)
				end
			end

			return out
		end
		library.clib = CLIB
return library
