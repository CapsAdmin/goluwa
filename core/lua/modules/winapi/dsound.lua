
--proc/multimedia/dsound: DirectSound API
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.ole'

dsound = ffi.load'dsound'

WAVE_FORMAT_PCM = 1

_FACDS  = 0x878   --DirectSound's facility code
--MAKE_DSHRESULT(code)  = MAKE_HRESULT(1, _FACDS, code)

DSFX_LOCHARDWARE    = 0x00000001
DSFX_LOCSOFTWARE    = 0x00000002


DSCFX_LOCHARDWARE   = 0x00000001
DSCFX_LOCSOFTWARE   = 0x00000002

DSCFXR_LOCHARDWARE  = 0x00000010
DSCFXR_LOCSOFTWARE  = 0x00000020

KSPROPERTY_SUPPORT_GET  = 0x00000001
KSPROPERTY_SUPPORT_SET  = 0x00000002

DSFXGARGLE_WAVE_TRIANGLE        = 0
DSFXGARGLE_WAVE_SQUARE          = 1

DSFXGARGLE_RATEHZ_MIN           = 1
DSFXGARGLE_RATEHZ_MAX           = 1000

DSFXCHORUS_WAVE_TRIANGLE        = 0
DSFXCHORUS_WAVE_SIN             = 1

DSFXCHORUS_WETDRYMIX_MIN        = 0
DSFXCHORUS_WETDRYMIX_MAX        = 100
DSFXCHORUS_DEPTH_MIN            = 0
DSFXCHORUS_DEPTH_MAX            = 100
DSFXCHORUS_FEEDBACK_MIN         = -99
DSFXCHORUS_FEEDBACK_MAX         = 99
DSFXCHORUS_FREQUENCY_MIN        = 0
DSFXCHORUS_FREQUENCY_MAX        = 10
DSFXCHORUS_DELAY_MIN            = 0
DSFXCHORUS_DELAY_MAX            = 20
DSFXCHORUS_PHASE_MIN            = 0
DSFXCHORUS_PHASE_MAX            = 4

DSFXCHORUS_PHASE_NEG_180        = 0
DSFXCHORUS_PHASE_NEG_90         = 1
DSFXCHORUS_PHASE_ZERO           = 2
DSFXCHORUS_PHASE_90             = 3
DSFXCHORUS_PHASE_180            = 4

DSFXFLANGER_WAVE_TRIANGLE       = 0
DSFXFLANGER_WAVE_SIN            = 1

DSFXFLANGER_WETDRYMIX_MIN       = 0
DSFXFLANGER_WETDRYMIX_MAX       = 100
DSFXFLANGER_FREQUENCY_MIN       = 0
DSFXFLANGER_FREQUENCY_MAX       = 10
DSFXFLANGER_DEPTH_MIN           = 0
DSFXFLANGER_DEPTH_MAX           = 100
DSFXFLANGER_PHASE_MIN           = 0
DSFXFLANGER_PHASE_MAX           = 4
DSFXFLANGER_FEEDBACK_MIN        = -99
DSFXFLANGER_FEEDBACK_MAX        = 99
DSFXFLANGER_DELAY_MIN           = 0
DSFXFLANGER_DELAY_MAX           = 4

DSFXFLANGER_PHASE_NEG_180       = 0
DSFXFLANGER_PHASE_NEG_90        = 1
DSFXFLANGER_PHASE_ZERO          = 2
DSFXFLANGER_PHASE_90            = 3
DSFXFLANGER_PHASE_180           = 4

DSFXECHO_WETDRYMIX_MIN      = 0
DSFXECHO_WETDRYMIX_MAX      = 100
DSFXECHO_FEEDBACK_MIN       = 0
DSFXECHO_FEEDBACK_MAX       = 100
DSFXECHO_LEFTDELAY_MIN      = 1
DSFXECHO_LEFTDELAY_MAX      = 2000
DSFXECHO_RIGHTDELAY_MIN     = 1
DSFXECHO_RIGHTDELAY_MAX     = 2000
DSFXECHO_PANDELAY_MIN       = 0
DSFXECHO_PANDELAY_MAX       = 1

DSFXDISTORTION_GAIN_MIN                     = -60
DSFXDISTORTION_GAIN_MAX                     = 0
DSFXDISTORTION_EDGE_MIN                     = 0
DSFXDISTORTION_EDGE_MAX                     = 100
DSFXDISTORTION_POSTEQCENTERFREQUENCY_MIN    = 100
DSFXDISTORTION_POSTEQCENTERFREQUENCY_MAX    = 8000
DSFXDISTORTION_POSTEQBANDWIDTH_MIN          = 100
DSFXDISTORTION_POSTEQBANDWIDTH_MAX          = 8000
DSFXDISTORTION_PRELOWPASSCUTOFF_MIN         = 100
DSFXDISTORTION_PRELOWPASSCUTOFF_MAX         = 8000

DSFXCOMPRESSOR_GAIN_MIN             = -60
DSFXCOMPRESSOR_GAIN_MAX             = 60
DSFXCOMPRESSOR_ATTACK_MIN           = 0.01
DSFXCOMPRESSOR_ATTACK_MAX           = 500
DSFXCOMPRESSOR_RELEASE_MIN          = 50
DSFXCOMPRESSOR_RELEASE_MAX          = 3000
DSFXCOMPRESSOR_THRESHOLD_MIN        = -60
DSFXCOMPRESSOR_THRESHOLD_MAX        = 0
DSFXCOMPRESSOR_RATIO_MIN            = 1
DSFXCOMPRESSOR_RATIO_MAX            = 100
DSFXCOMPRESSOR_PREDELAY_MIN         = 0
DSFXCOMPRESSOR_PREDELAY_MAX         = 4

DSFXPARAMEQ_CENTER_MIN      = 80
DSFXPARAMEQ_CENTER_MAX      = 16000
DSFXPARAMEQ_BANDWIDTH_MIN   = 1
DSFXPARAMEQ_BANDWIDTH_MAX   = 36
DSFXPARAMEQ_GAIN_MIN        = -15
DSFXPARAMEQ_GAIN_MAX        = 15

DSFX_I3DL2REVERB_ROOM_MIN                   = (-10000)
DSFX_I3DL2REVERB_ROOM_MAX                   = 0
DSFX_I3DL2REVERB_ROOM_DEFAULT               = (-1000)

DSFX_I3DL2REVERB_ROOMHF_MIN                 = (-10000)
DSFX_I3DL2REVERB_ROOMHF_MAX                 = 0
DSFX_I3DL2REVERB_ROOMHF_DEFAULT             = (-100)

DSFX_I3DL2REVERB_ROOMROLLOFFFACTOR_MIN      = 0
DSFX_I3DL2REVERB_ROOMROLLOFFFACTOR_MAX      = 10
DSFX_I3DL2REVERB_ROOMROLLOFFFACTOR_DEFAULT  = 0

DSFX_I3DL2REVERB_DECAYTIME_MIN              = 0.1
DSFX_I3DL2REVERB_DECAYTIME_MAX              = 20
DSFX_I3DL2REVERB_DECAYTIME_DEFAULT          = 1.49

DSFX_I3DL2REVERB_DECAYHFRATIO_MIN           = 0.1
DSFX_I3DL2REVERB_DECAYHFRATIO_MAX           = 2
DSFX_I3DL2REVERB_DECAYHFRATIO_DEFAULT       = 0.83

DSFX_I3DL2REVERB_REFLECTIONS_MIN            = (-10000)
DSFX_I3DL2REVERB_REFLECTIONS_MAX            = 1000
DSFX_I3DL2REVERB_REFLECTIONS_DEFAULT        = (-2602)

DSFX_I3DL2REVERB_REFLECTIONSDELAY_MIN       = 0
DSFX_I3DL2REVERB_REFLECTIONSDELAY_MAX       = 0.3
DSFX_I3DL2REVERB_REFLECTIONSDELAY_DEFAULT   = 0.007

DSFX_I3DL2REVERB_REVERB_MIN                 = (-10000)
DSFX_I3DL2REVERB_REVERB_MAX                 = 2000
DSFX_I3DL2REVERB_REVERB_DEFAULT             = (200)

DSFX_I3DL2REVERB_REVERBDELAY_MIN            = 0
DSFX_I3DL2REVERB_REVERBDELAY_MAX            = 0.1
DSFX_I3DL2REVERB_REVERBDELAY_DEFAULT        = 0.011

DSFX_I3DL2REVERB_DIFFUSION_MIN              = 0
DSFX_I3DL2REVERB_DIFFUSION_MAX              = 100
DSFX_I3DL2REVERB_DIFFUSION_DEFAULT          = 100

DSFX_I3DL2REVERB_DENSITY_MIN                = 0
DSFX_I3DL2REVERB_DENSITY_MAX                = 100
DSFX_I3DL2REVERB_DENSITY_DEFAULT            = 100

DSFX_I3DL2REVERB_HFREFERENCE_MIN            = 20
DSFX_I3DL2REVERB_HFREFERENCE_MAX            = 20000
DSFX_I3DL2REVERB_HFREFERENCE_DEFAULT        = 5000

DSFX_I3DL2REVERB_QUALITY_MIN                = 0
DSFX_I3DL2REVERB_QUALITY_MAX                = 3
DSFX_I3DL2REVERB_QUALITY_DEFAULT            = 2

DSFX_WAVESREVERB_INGAIN_MIN                 = -96
DSFX_WAVESREVERB_INGAIN_MAX                 = 0
DSFX_WAVESREVERB_INGAIN_DEFAULT             = 0
DSFX_WAVESREVERB_REVERBMIX_MIN              = -96
DSFX_WAVESREVERB_REVERBMIX_MAX              = 0
DSFX_WAVESREVERB_REVERBMIX_DEFAULT          = 0
DSFX_WAVESREVERB_REVERBTIME_MIN             = 0.001
DSFX_WAVESREVERB_REVERBTIME_MAX             = 3000
DSFX_WAVESREVERB_REVERBTIME_DEFAULT         = 1000
DSFX_WAVESREVERB_HIGHFREQRTRATIO_MIN        = 0.001
DSFX_WAVESREVERB_HIGHFREQRTRATIO_MAX        = 0.999
DSFX_WAVESREVERB_HIGHFREQRTRATIO_DEFAULT    = 0.001

-- These match the AEC_MODE_* constants in the DDK's ksmedia.h file
DSCFX_AEC_MODE_PASS_THROUGH                     = 0x0
DSCFX_AEC_MODE_HALF_DUPLEX                      = 0x1
DSCFX_AEC_MODE_FULL_DUPLEX                      = 0x2

-- These match the AEC_STATUS_* constants in ksmedia.h
DSCFX_AEC_STATUS_HISTORY_UNINITIALIZED          = 0x0
DSCFX_AEC_STATUS_HISTORY_CONTINUOUSLY_CONVERGED = 0x1
DSCFX_AEC_STATUS_HISTORY_PREVIOUSLY_DIVERGED    = 0x2
DSCFX_AEC_STATUS_CURRENTLY_CONVERGED            = 0x8

--[[
-- The function completed successfully
DS_OK                           = S_OK

-- The call succeeded, but we had to substitute the 3D algorithm
DS_NO_VIRTUALIZATION            = MAKE_HRESULT(0, _FACDS, 10)

-- The call failed because resources (such as a priority level)
-- were already being used by another caller
DSERR_ALLOCATED                 = MAKE_DSHRESULT(10)

-- The control (vol, pan, etc.) requested by the caller is not available
DSERR_CONTROLUNAVAIL            = MAKE_DSHRESULT(30)

-- An invalid parameter was passed to the returning function
DSERR_INVALIDPARAM              = E_INVALIDARG

-- This call is not valid for the current state of this object
DSERR_INVALIDCALL               = MAKE_DSHRESULT(50)

-- An undetermined error occurred inside the DirectSound subsystem
DSERR_GENERIC                   = E_FAIL

-- The caller does not have the priority level required for the function to
-- succeed
DSERR_PRIOLEVELNEEDED           = MAKE_DSHRESULT(70)

-- Not enough free memory is available to complete the operation
DSERR_OUTOFMEMORY               = E_OUTOFMEMORY

-- The specified WAVE format is not supported
DSERR_BADFORMAT                 = MAKE_DSHRESULT(100)

-- The function called is not supported at this time
DSERR_UNSUPPORTED               = E_NOTIMPL

-- No sound driver is available for use
DSERR_NODRIVER                  = MAKE_DSHRESULT(120)

-- This object is already initialized
DSERR_ALREADYINITIALIZED        = MAKE_DSHRESULT(130)

-- This object does not support aggregation
DSERR_NOAGGREGATION             = CLASS_E_NOAGGREGATION

-- The buffer memory has been lost, and must be restored
DSERR_BUFFERLOST                = MAKE_DSHRESULT(150)

-- Another app has a higher priority level, preventing this call from
-- succeeding
DSERR_OTHERAPPHASPRIO           = MAKE_DSHRESULT(160)

-- This object has not been initialized
DSERR_UNINITIALIZED             = MAKE_DSHRESULT(170)

-- The requested COM interface is not available
DSERR_NOINTERFACE               = E_NOINTERFACE

-- Access is denied
DSERR_ACCESSDENIED              = E_ACCESSDENIED

-- Tried to create a DSBCAPS_CTRLFX buffer shorter than DSBSIZE_FX_MIN milliseconds
DSERR_BUFFERTOOSMALL            = MAKE_DSHRESULT(180)

-- Attempt to use DirectSound 8 functionality on an older DirectSound object
DSERR_DS8_REQUIRED              = MAKE_DSHRESULT(190)

-- A circular loop of send effects was detected
DSERR_SENDLOOP                  = MAKE_DSHRESULT(200)

-- The GUID specified in an audiopath file does not match a valid MIXIN buffer
DSERR_BADSENDBUFFERGUID         = MAKE_DSHRESULT(210)

-- The object requested was not found (numerically equal to DMUS_E_NOT_FOUND)
DSERR_OBJECTNOTFOUND            = MAKE_DSHRESULT(4449)

-- The effects requested could not be found on the system, or they were found
-- but in the wrong order, or in the wrong hardware/software locations.
DSERR_FXUNAVAILABLE             = MAKE_DSHRESULT(220)
]]

DSCAPS_PRIMARYMONO          = 0x00000001
DSCAPS_PRIMARYSTEREO        = 0x00000002
DSCAPS_PRIMARY8BIT          = 0x00000004
DSCAPS_PRIMARY16BIT         = 0x00000008
DSCAPS_CONTINUOUSRATE       = 0x00000010
DSCAPS_EMULDRIVER           = 0x00000020
DSCAPS_CERTIFIED            = 0x00000040
DSCAPS_SECONDARYMONO        = 0x00000100
DSCAPS_SECONDARYSTEREO      = 0x00000200
DSCAPS_SECONDARY8BIT        = 0x00000400
DSCAPS_SECONDARY16BIT       = 0x00000800

DSSCL_NORMAL                = 0x00000001
DSSCL_PRIORITY              = 0x00000002
DSSCL_EXCLUSIVE             = 0x00000003
DSSCL_WRITEPRIMARY          = 0x00000004

DSSPEAKER_DIRECTOUT         = 0x00000000
DSSPEAKER_HEADPHONE         = 0x00000001
DSSPEAKER_MONO              = 0x00000002
DSSPEAKER_QUAD              = 0x00000003
DSSPEAKER_STEREO            = 0x00000004
DSSPEAKER_SURROUND          = 0x00000005
DSSPEAKER_5POINT1           = 0x00000006  -- obsolete 5.1 setting
DSSPEAKER_7POINT1           = 0x00000007  -- obsolete 7.1 setting
DSSPEAKER_7POINT1_SURROUND  = 0x00000008  -- correct 7.1 Home Theater setting
DSSPEAKER_5POINT1_SURROUND  = 0x00000009  -- correct 5.1 setting
DSSPEAKER_7POINT1_WIDE      = DSSPEAKER_7POINT1
DSSPEAKER_5POINT1_BACK      = DSSPEAKER_5POINT1

DSSPEAKER_GEOMETRY_MIN      = 0x00000005  --   5 degrees
DSSPEAKER_GEOMETRY_NARROW   = 0x0000000A  --  10 degrees
DSSPEAKER_GEOMETRY_WIDE     = 0x00000014  --  20 degrees
DSSPEAKER_GEOMETRY_MAX      = 0x000000B4  -- 180 degrees

--DSSPEAKER_COMBINED(c, g)    ((DWORD)(((BYTE)(c)) | ((DWORD)((BYTE)(g))) << 16))
--DSSPEAKER_CONFIG(a)         = ((BYTE)(a))
--DSSPEAKER_GEOMETRY(a)       = ((BYTE)(((DWORD)(a) >> 16) & 0x00FF))

DSBCAPS_PRIMARYBUFFER       = 0x00000001
DSBCAPS_STATIC              = 0x00000002
DSBCAPS_LOCHARDWARE         = 0x00000004
DSBCAPS_LOCSOFTWARE         = 0x00000008
DSBCAPS_CTRL3D              = 0x00000010
DSBCAPS_CTRLFREQUENCY       = 0x00000020
DSBCAPS_CTRLPAN             = 0x00000040
DSBCAPS_CTRLVOLUME          = 0x00000080
DSBCAPS_CTRLPOSITIONNOTIFY  = 0x00000100
DSBCAPS_CTRLFX              = 0x00000200
DSBCAPS_STICKYFOCUS         = 0x00004000
DSBCAPS_GLOBALFOCUS         = 0x00008000
DSBCAPS_GETCURRENTPOSITION2 = 0x00010000
DSBCAPS_MUTE3DATMAXDISTANCE = 0x00020000
DSBCAPS_LOCDEFER            = 0x00040000
DSBCAPS_TRUEPLAYPOSITION    = 0x00080000

DSBPLAY_LOOPING             = 0x00000001
DSBPLAY_LOCHARDWARE         = 0x00000002
DSBPLAY_LOCSOFTWARE         = 0x00000004
DSBPLAY_TERMINATEBY_TIME    = 0x00000008
DSBPLAY_TERMINATEBY_DISTANCE    = 0x000000010
DSBPLAY_TERMINATEBY_PRIORITY    = 0x000000020

DSBSTATUS_PLAYING           = 0x00000001
DSBSTATUS_BUFFERLOST        = 0x00000002
DSBSTATUS_LOOPING           = 0x00000004
DSBSTATUS_LOCHARDWARE       = 0x00000008
DSBSTATUS_LOCSOFTWARE       = 0x00000010
DSBSTATUS_TERMINATED        = 0x00000020

DSBLOCK_FROMWRITECURSOR     = 0x00000001
DSBLOCK_ENTIREBUFFER        = 0x00000002

DSBFREQUENCY_ORIGINAL       = 0
DSBFREQUENCY_MIN            = 100

DSBPAN_LEFT                 = -10000
DSBPAN_CENTER               = 0
DSBPAN_RIGHT                = 10000

DSBVOLUME_MIN               = -10000
DSBVOLUME_MAX               = 0

DSBSIZE_MIN                 = 4
DSBSIZE_MAX                 = 0x0FFFFFFF
DSBSIZE_FX_MIN              = 150  -- NOTE: Milliseconds, not bytes

DSBNOTIFICATIONS_MAX        = 100000

DS3DMODE_NORMAL             = 0x00000000
DS3DMODE_HEADRELATIVE       = 0x00000001
DS3DMODE_DISABLE            = 0x00000002

DS3D_IMMEDIATE              = 0x00000000
DS3D_DEFERRED               = 0x00000001

DS3D_MINDISTANCEFACTOR      = FLT_MIN
DS3D_MAXDISTANCEFACTOR      = FLT_MAX
DS3D_DEFAULTDISTANCEFACTOR  = 1

DS3D_MINROLLOFFFACTOR       = 0
DS3D_MAXROLLOFFFACTOR       = 10
DS3D_DEFAULTROLLOFFFACTOR   = 1

DS3D_MINDOPPLERFACTOR       = 0
DS3D_MAXDOPPLERFACTOR       = 10
DS3D_DEFAULTDOPPLERFACTOR   = 1

DS3D_DEFAULTMINDISTANCE     = 1
DS3D_DEFAULTMAXDISTANCE     = 1000000000

DS3D_MINCONEANGLE           = 0
DS3D_MAXCONEANGLE           = 360
DS3D_DEFAULTCONEANGLE       = 360

DS3D_DEFAULTCONEOUTSIDEVOLUME = DSBVOLUME_MAX

-- IDirectSoundCapture attributes

DSCCAPS_EMULDRIVER          = DSCAPS_EMULDRIVER
DSCCAPS_CERTIFIED           = DSCAPS_CERTIFIED
DSCCAPS_MULTIPLECAPTURE     = 0x00000001

-- IDirectSoundCaptureBuffer attributes

DSCBCAPS_WAVEMAPPED         = 0x80000000
DSCBCAPS_CTRLFX             = 0x00000200

DSCBLOCK_ENTIREBUFFER       = 0x00000001

DSCBSTATUS_CAPTURING        = 0x00000001
DSCBSTATUS_LOOPING          = 0x00000002

DSCBSTART_LOOPING           = 0x00000001

DSBPN_OFFSETSTOP            = 0xFFFFFFFF

DS_CERTIFIED                = 0x00000000
DS_UNCERTIFIED              = 0x00000001

--I3DL2_MATERIAL_PRESET_SINGLEWINDOW    = -2800,0.71
--I3DL2_MATERIAL_PRESET_DOUBLEWINDOW    = -5000,0.40
--I3DL2_MATERIAL_PRESET_THINDOOR        = -1800,0.66
--I3DL2_MATERIAL_PRESET_THICKDOOR       = -4400,0.64
--I3DL2_MATERIAL_PRESET_WOODWALL        = -4000,0.50
--I3DL2_MATERIAL_PRESET_BRICKWALL       = -5000,0.60
--I3DL2_MATERIAL_PRESET_STONEWALL       = -6000,0.68
--I3DL2_MATERIAL_PRESET_CURTAIN         = -1200,0.15

--I3DL2_ENVIRONMENT_PRESET_DEFAULT         = -1000, -100, 0, 1.49f, 0.83f, -2602, 0.007f,   200, 0.011f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_GENERIC         = -1000, -100, 0, 1.49f, 0.83f, -2602, 0.007f,   200, 0.011f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_PADDEDCELL      = -1000,-6000, 0, 0.17f, 0.10f, -1204, 0.001f,   207, 0.002f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_ROOM            = -1000, -454, 0, 0.40f, 0.83f, -1646, 0.002f,    53, 0.003f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_BATHROOM        = -1000,-1200, 0, 1.49f, 0.54f,  -370, 0.007f,  1030, 0.011f, 100,  60, 5000
--I3DL2_ENVIRONMENT_PRESET_LIVINGROOM      = -1000,-6000, 0, 0.50f, 0.10f, -1376, 0.003f, -1104, 0.004f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_STONEROOM       = -1000, -300, 0, 2.31f, 0.64f,  -711, 0.012f,    83, 0.017f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_AUDITORIUM      = -1000, -476, 0, 4.32f, 0.59f,  -789, 0.020f,  -289, 0.030f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_CONCERTHALL     = -1000, -500, 0, 3.92f, 0.70f, -1230, 0.020f,    -2, 0.029f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_CAVE            = -1000,    0, 0, 2.91f, 1.30f,  -602, 0.015f,  -302, 0.022f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_ARENA           = -1000, -698, 0, 7.24f, 0.33f, -1166, 0.020f,    16, 0.030f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_HANGAR          = -1000,-1000, 0,10.05f, 0.23f,  -602, 0.020f,   198, 0.030f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_CARPETEDHALLWAY = -1000,-4000, 0, 0.30f, 0.10f, -1831, 0.002f, -1630, 0.030f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_HALLWAY         = -1000, -300, 0, 1.49f, 0.59f, -1219, 0.007f,   441, 0.011f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_STONECORRIDOR   = -1000, -237, 0, 2.70f, 0.79f, -1214, 0.013f,   395, 0.020f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_ALLEY           = -1000, -270, 0, 1.49f, 0.86f, -1204, 0.007f,    -4, 0.011f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_FOREST          = -1000,-3300, 0, 1.49f, 0.54f, -2560, 0.162f,  -613, 0.088f,  79, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_CITY            = -1000, -800, 0, 1.49f, 0.67f, -2273, 0.007f, -2217, 0.011f,  50, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_MOUNTAINS       = -1000,-2500, 0, 1.49f, 0.21f, -2780, 0.300f, -2014, 0.100f,  27, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_QUARRY          = -1000,-1000, 0, 1.49f, 0.83f,-10000, 0.061f,   500, 0.025f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_PLAIN           = -1000,-2000, 0, 1.49f, 0.50f, -2466, 0.179f, -2514, 0.100f,  21, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_PARKINGLOT      = -1000,    0, 0, 1.65f, 1.50f, -1363, 0.008f, -1153, 0.012f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_SEWERPIPE       = -1000,-1000, 0, 2.81f, 0.14f,   429, 0.014f,   648, 0.021f,  80,  60, 5000
--I3DL2_ENVIRONMENT_PRESET_UNDERWATER      = -1000,-4000, 0, 1.49f, 0.10f,  -449, 0.007f,  1700, 0.011f, 100, 100, 5000

--
-- Examples simulating 'musical' reverb presets
--
-- Name       Decay time   Description
-- Small Room    1.1s      A small size room with a length of 5m or so.
-- Medium Room   1.3s      A medium size room with a length of 10m or so.
-- Large Room    1.5s      A large size room suitable for live performances.
-- Medium Hall   1.8s      A medium size concert hall.
-- Large Hall    1.8s      A large size concert hall suitable for a full orchestra.
-- Plate         1.3s      A plate reverb simulation.
--

--I3DL2_ENVIRONMENT_PRESET_SMALLROOM       = -1000, -600, 0, 1.10f, 0.83f,  -400, 0.005f,   500, 0.010f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_MEDIUMROOM      = -1000, -600, 0, 1.30f, 0.83f, -1000, 0.010f,  -200, 0.020f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_LARGEROOM       = -1000, -600, 0, 1.50f, 0.83f, -1600, 0.020f, -1000, 0.040f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_MEDIUMHALL      = -1000, -600, 0, 1.80f, 0.70f, -1300, 0.015f,  -800, 0.030f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_LARGEHALL       = -1000, -600, 0, 1.80f, 0.70f, -2000, 0.030f, -1400, 0.060f, 100, 100, 5000
--I3DL2_ENVIRONMENT_PRESET_PLATE           = -1000, -200, 0, 1.30f, 0.90f,     0, 0.002f,     0, 0.010f, 100,  75, 5000

ffi.cdef[[
/*
 *  extended waveform format structure used for all non-PCM formats. this
 *  structure is common to all non-PCM formats.
 */
typedef struct tWAVEFORMATEX
{
	WORD        wFormatTag;         /* format type */
	WORD        nChannels;          /* number of channels (i.e. mono, stereo...) */
	DWORD       nSamplesPerSec;     /* sample rate */
	DWORD       nAvgBytesPerSec;    /* for buffer estimation */
	WORD        nBlockAlign;        /* block size of data */
	WORD        wBitsPerSample;     /* number of bits per sample of mono data */
	WORD        cbSize;             /* the count in bytes of the size of */
											  /* extra information (after cbSize) */
} WAVEFORMATEX, *PWAVEFORMATEX, *NPWAVEFORMATEX, *LPWAVEFORMATEX;
typedef float D3DVALUE, *LPD3DVALUE;
typedef DWORD D3DCOLOR;
typedef DWORD *LPD3DCOLOR;
typedef struct _D3DVECTOR
{
	float x;
	float y;
	float z;
} D3DVECTOR;
typedef D3DVECTOR *LPD3DVECTOR;
const GUID CLSID_DirectSound;
const GUID CLSID_DirectSound8;
const GUID CLSID_DirectSoundCapture;
const GUID CLSID_DirectSoundCapture8;
const GUID CLSID_DirectSoundFullDuplex;
const GUID DSDEVID_DefaultPlayback;
const GUID DSDEVID_DefaultCapture;
const GUID DSDEVID_DefaultVoicePlayback;
const GUID DSDEVID_DefaultVoiceCapture;
typedef struct IDirectSound *LPDIRECTSOUND;
typedef struct IDirectSoundBuffer *LPDIRECTSOUNDBUFFER;
typedef struct IDirectSound3DListener *LPDIRECTSOUND3DLISTENER;
typedef struct IDirectSound3DBuffer *LPDIRECTSOUND3DBUFFER;
typedef struct IDirectSoundCapture *LPDIRECTSOUNDCAPTURE;
typedef struct IDirectSoundCaptureBuffer *LPDIRECTSOUNDCAPTUREBUFFER;
typedef struct IDirectSoundNotify *LPDIRECTSOUNDNOTIFY;
typedef struct IDirectSoundFXGargle *LPDIRECTSOUNDFXGARGLE;
typedef struct IDirectSoundFXChorus *LPDIRECTSOUNDFXCHORUS;
typedef struct IDirectSoundFXFlanger *LPDIRECTSOUNDFXFLANGER;
typedef struct IDirectSoundFXEcho *LPDIRECTSOUNDFXECHO;
typedef struct IDirectSoundFXDistortion *LPDIRECTSOUNDFXDISTORTION;
typedef struct IDirectSoundFXCompressor *LPDIRECTSOUNDFXCOMPRESSOR;
typedef struct IDirectSoundFXParamEq *LPDIRECTSOUNDFXPARAMEQ;
typedef struct IDirectSoundFXWavesReverb *LPDIRECTSOUNDFXWAVESREVERB;
typedef struct IDirectSoundFXI3DL2Reverb *LPDIRECTSOUNDFXI3DL2REVERB;
typedef struct IDirectSoundCaptureFXAec *LPDIRECTSOUNDCAPTUREFXAEC;
typedef struct IDirectSoundCaptureFXNoiseSuppress *LPDIRECTSOUNDCAPTUREFXNOISESUPPRESS;
typedef struct IDirectSoundFullDuplex *LPDIRECTSOUNDFULLDUPLEX;
typedef struct IDirectSound8 *LPDIRECTSOUND8;
typedef struct IDirectSoundBuffer8 *LPDIRECTSOUNDBUFFER8;
typedef struct IDirectSound3DListener *LPDIRECTSOUND3DLISTENER8;
typedef struct IDirectSound3DBuffer *LPDIRECTSOUND3DBUFFER8;
typedef struct IDirectSoundCapture *LPDIRECTSOUNDCAPTURE8;
typedef struct IDirectSoundCaptureBuffer8 *LPDIRECTSOUNDCAPTUREBUFFER8;
typedef struct IDirectSoundNotify *LPDIRECTSOUNDNOTIFY8;
typedef struct IDirectSoundFXGargle *LPDIRECTSOUNDFXGARGLE8;
typedef struct IDirectSoundFXChorus *LPDIRECTSOUNDFXCHORUS8;
typedef struct IDirectSoundFXFlanger *LPDIRECTSOUNDFXFLANGER8;
typedef struct IDirectSoundFXEcho *LPDIRECTSOUNDFXECHO8;
typedef struct IDirectSoundFXDistortion *LPDIRECTSOUNDFXDISTORTION8;
typedef struct IDirectSoundFXCompressor *LPDIRECTSOUNDFXCOMPRESSOR8;
typedef struct IDirectSoundFXParamEq *LPDIRECTSOUNDFXPARAMEQ8;
typedef struct IDirectSoundFXWavesReverb *LPDIRECTSOUNDFXWAVESREVERB8;
typedef struct IDirectSoundFXI3DL2Reverb *LPDIRECTSOUNDFXI3DL2REVERB8;
typedef struct IDirectSoundCaptureFXAec *LPDIRECTSOUNDCAPTUREFXAEC8;
typedef struct IDirectSoundCaptureFXNoiseSuppress *LPDIRECTSOUNDCAPTUREFXNOISESUPPRESS8;
typedef struct IDirectSoundFullDuplex *LPDIRECTSOUNDFULLDUPLEX8;
typedef const WAVEFORMATEX *LPCWAVEFORMATEX;
typedef LPDIRECTSOUND *LPLPDIRECTSOUND;
typedef LPDIRECTSOUNDBUFFER *LPLPDIRECTSOUNDBUFFER;
typedef LPDIRECTSOUND3DLISTENER *LPLPDIRECTSOUND3DLISTENER;
typedef LPDIRECTSOUND3DBUFFER *LPLPDIRECTSOUND3DBUFFER;
typedef LPDIRECTSOUNDCAPTURE *LPLPDIRECTSOUNDCAPTURE;
typedef LPDIRECTSOUNDCAPTUREBUFFER *LPLPDIRECTSOUNDCAPTUREBUFFER;
typedef LPDIRECTSOUNDNOTIFY *LPLPDIRECTSOUNDNOTIFY;
typedef LPDIRECTSOUND8 *LPLPDIRECTSOUND8;
typedef LPDIRECTSOUNDBUFFER8 *LPLPDIRECTSOUNDBUFFER8;
typedef LPDIRECTSOUNDCAPTURE8 *LPLPDIRECTSOUNDCAPTURE8;
typedef LPDIRECTSOUNDCAPTUREBUFFER8 *LPLPDIRECTSOUNDCAPTUREBUFFER8;
typedef struct _DSCAPS
{
	DWORD dwSize;
	DWORD dwFlags;
	DWORD dwMinSecondarySampleRate;
	DWORD dwMaxSecondarySampleRate;
	DWORD dwPrimaryBuffers;
	DWORD dwMaxHwMixingAllBuffers;
	DWORD dwMaxHwMixingStaticBuffers;
	DWORD dwMaxHwMixingStreamingBuffers;
	DWORD dwFreeHwMixingAllBuffers;
	DWORD dwFreeHwMixingStaticBuffers;
	DWORD dwFreeHwMixingStreamingBuffers;
	DWORD dwMaxHw3DAllBuffers;
	DWORD dwMaxHw3DStaticBuffers;
	DWORD dwMaxHw3DStreamingBuffers;
	DWORD dwFreeHw3DAllBuffers;
	DWORD dwFreeHw3DStaticBuffers;
	DWORD dwFreeHw3DStreamingBuffers;
	DWORD dwTotalHwMemBytes;
	DWORD dwFreeHwMemBytes;
	DWORD dwMaxContigFreeHwMemBytes;
	DWORD dwUnlockTransferRateHwBuffers;
	DWORD dwPlayCpuOverheadSwBuffers;
	DWORD dwReserved1;
	DWORD dwReserved2;
} DSCAPS, *LPDSCAPS;
typedef const DSCAPS *LPCDSCAPS;
typedef struct _DSBCAPS
{
	DWORD dwSize;
	DWORD dwFlags;
	DWORD dwBufferBytes;
	DWORD dwUnlockTransferRate;
	DWORD dwPlayCpuOverhead;
} DSBCAPS, *LPDSBCAPS;
typedef const DSBCAPS *LPCDSBCAPS;
	typedef struct _DSEFFECTDESC
	{
	    DWORD dwSize;
	    DWORD dwFlags;
	    GUID guidDSFXClass;
	    DWORD_PTR dwReserved1;
	    DWORD_PTR dwReserved2;
	} DSEFFECTDESC, *LPDSEFFECTDESC;
	typedef const DSEFFECTDESC *LPCDSEFFECTDESC;
	enum
	{
	    DSFXR_PRESENT,
	    DSFXR_LOCHARDWARE,
	    DSFXR_LOCSOFTWARE,
	    DSFXR_UNALLOCATED,
	    DSFXR_FAILED,
	    DSFXR_UNKNOWN,
	    DSFXR_SENDLOOP
	};
	typedef struct _DSCEFFECTDESC
	{
	    DWORD dwSize;
	    DWORD dwFlags;
	    GUID guidDSCFXClass;
	    GUID guidDSCFXInstance;
	    DWORD dwReserved1;
	    DWORD dwReserved2;
	} DSCEFFECTDESC, *LPDSCEFFECTDESC;
	typedef const DSCEFFECTDESC *LPCDSCEFFECTDESC;
typedef struct _DSBUFFERDESC
{
	DWORD dwSize;
	DWORD dwFlags;
	DWORD dwBufferBytes;
	DWORD dwReserved;
	LPWAVEFORMATEX lpwfxFormat;
	GUID guid3DAlgorithm;
} DSBUFFERDESC, *LPDSBUFFERDESC;
typedef const DSBUFFERDESC *LPCDSBUFFERDESC;
typedef struct _DSBUFFERDESC1
{
	DWORD dwSize;
	DWORD dwFlags;
	DWORD dwBufferBytes;
	DWORD dwReserved;
	LPWAVEFORMATEX lpwfxFormat;
} DSBUFFERDESC1, *LPDSBUFFERDESC1;
typedef const DSBUFFERDESC1 *LPCDSBUFFERDESC1;
typedef struct _DS3DBUFFER
{
	DWORD dwSize;
	D3DVECTOR vPosition;
	D3DVECTOR vVelocity;
	DWORD dwInsideConeAngle;
	DWORD dwOutsideConeAngle;
	D3DVECTOR vConeOrientation;
	LONG lConeOutsideVolume;
	D3DVALUE flMinDistance;
	D3DVALUE flMaxDistance;
	DWORD dwMode;
} DS3DBUFFER, *LPDS3DBUFFER;
typedef const DS3DBUFFER *LPCDS3DBUFFER;
typedef struct _DS3DLISTENER
{
	DWORD dwSize;
	D3DVECTOR vPosition;
	D3DVECTOR vVelocity;
	D3DVECTOR vOrientFront;
	D3DVECTOR vOrientTop;
	D3DVALUE flDistanceFactor;
	D3DVALUE flRolloffFactor;
	D3DVALUE flDopplerFactor;
} DS3DLISTENER, *LPDS3DLISTENER;
typedef const DS3DLISTENER *LPCDS3DLISTENER;
typedef struct _DSCCAPS
{
	DWORD dwSize;
	DWORD dwFlags;
	DWORD dwFormats;
	DWORD dwChannels;
} DSCCAPS, *LPDSCCAPS;
typedef const DSCCAPS *LPCDSCCAPS;
typedef struct _DSCBUFFERDESC1
{
	DWORD dwSize;
	DWORD dwFlags;
	DWORD dwBufferBytes;
	DWORD dwReserved;
	LPWAVEFORMATEX lpwfxFormat;
} DSCBUFFERDESC1, *LPDSCBUFFERDESC1;
typedef struct _DSCBUFFERDESC
{
	DWORD dwSize;
	DWORD dwFlags;
	DWORD dwBufferBytes;
	DWORD dwReserved;
	LPWAVEFORMATEX lpwfxFormat;
	DWORD dwFXCount;
	LPDSCEFFECTDESC lpDSCFXDesc;
} DSCBUFFERDESC, *LPDSCBUFFERDESC;
typedef const DSCBUFFERDESC *LPCDSCBUFFERDESC;
typedef struct _DSCBCAPS
{
	DWORD dwSize;
	DWORD dwFlags;
	DWORD dwBufferBytes;
	DWORD dwReserved;
} DSCBCAPS, *LPDSCBCAPS;
typedef const DSCBCAPS *LPCDSCBCAPS;
typedef struct _DSBPOSITIONNOTIFY
{
	DWORD dwOffset;
	HANDLE hEventNotify;
} DSBPOSITIONNOTIFY, *LPDSBPOSITIONNOTIFY;
typedef const DSBPOSITIONNOTIFY *LPCDSBPOSITIONNOTIFY;
typedef BOOL ( *LPDSENUMCALLBACKA)(LPGUID, LPCSTR, LPCSTR, LPVOID);
typedef BOOL ( *LPDSENUMCALLBACKW)(LPGUID, LPCWSTR, LPCWSTR, LPVOID);
HRESULT DirectSoundCreate(LPCGUID pcGuidDevice, LPDIRECTSOUND *ppDS, LPUNKNOWN pUnkOuter);
HRESULT DirectSoundEnumerateW(LPDSENUMCALLBACKW pDSEnumCallback, LPVOID pContext);
HRESULT DirectSoundCaptureCreate(LPCGUID pcGuidDevice, LPDIRECTSOUNDCAPTURE *ppDSC, LPUNKNOWN pUnkOuter);
HRESULT DirectSoundCaptureEnumerateW(LPDSENUMCALLBACKW pDSEnumCallback, LPVOID pContext);
HRESULT DirectSoundCreate8(LPCGUID pcGuidDevice, LPDIRECTSOUND8 *ppDS8, LPUNKNOWN pUnkOuter);
HRESULT DirectSoundCaptureCreate8(LPCGUID pcGuidDevice, LPDIRECTSOUNDCAPTURE8 *ppDSC8, LPUNKNOWN pUnkOuter);
HRESULT DirectSoundFullDuplexCreate
(
	LPCGUID pcGuidCaptureDevice,
	LPCGUID pcGuidRenderDevice,
	LPCDSCBUFFERDESC pcDSCBufferDesc,
	LPCDSBUFFERDESC pcDSBufferDesc,
	HWND hWnd,
	DWORD dwLevel,
	LPDIRECTSOUNDFULLDUPLEX* ppDSFD,
	LPDIRECTSOUNDCAPTUREBUFFER8 *ppDSCBuffer8,
	LPDIRECTSOUNDBUFFER8 *ppDSBuffer8,
	LPUNKNOWN pUnkOuter
);
HRESULT GetDeviceID(LPCGUID pGuidSrc, LPGUID pGuidDest);
typedef LONGLONG REFERENCE_TIME;
typedef REFERENCE_TIME *LPREFERENCE_TIME;
const GUID IID_IReferenceClock;
typedef struct IReferenceClock { struct IReferenceClockVtbl *lpVtbl; } IReferenceClock; typedef struct IReferenceClockVtbl IReferenceClockVtbl; struct IReferenceClockVtbl
{
	HRESULT ( *QueryInterface) (IReferenceClock *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IReferenceClock *This);
	ULONG ( *Release) (IReferenceClock *This);
	HRESULT ( *GetTime) (IReferenceClock *This, REFERENCE_TIME *pTime);
	HRESULT ( *AdviseTime) (IReferenceClock *This, REFERENCE_TIME rtBaseTime, REFERENCE_TIME rtStreamTime, HANDLE hEvent, LPDWORD pdwAdviseCookie);
	HRESULT ( *AdvisePeriodic) (IReferenceClock *This, REFERENCE_TIME rtStartTime, REFERENCE_TIME rtPeriodTime, HANDLE hSemaphore, LPDWORD pdwAdviseCookie);
	HRESULT ( *Unadvise) (IReferenceClock *This, DWORD dwAdviseCookie);
};
const GUID IID_IDirectSound;
typedef struct IDirectSound { struct IDirectSoundVtbl *lpVtbl; } IDirectSound; typedef struct IDirectSoundVtbl IDirectSoundVtbl; struct IDirectSoundVtbl
{
	HRESULT ( *QueryInterface) (IDirectSound *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSound *This);
	ULONG ( *Release) (IDirectSound *This);
	HRESULT ( *CreateSoundBuffer) (IDirectSound *This, LPCDSBUFFERDESC pcDSBufferDesc, LPDIRECTSOUNDBUFFER *ppDSBuffer, LPUNKNOWN pUnkOuter);
	HRESULT ( *GetCaps) (IDirectSound *This, LPDSCAPS pDSCaps);
	HRESULT ( *DuplicateSoundBuffer) (IDirectSound *This, LPDIRECTSOUNDBUFFER pDSBufferOriginal, LPDIRECTSOUNDBUFFER *ppDSBufferDuplicate);
	HRESULT ( *SetCooperativeLevel) (IDirectSound *This, HWND hwnd, DWORD dwLevel);
	HRESULT ( *Compact) (IDirectSound *This);
	HRESULT ( *GetSpeakerConfig) (IDirectSound *This, LPDWORD pdwSpeakerConfig);
	HRESULT ( *SetSpeakerConfig) (IDirectSound *This, DWORD dwSpeakerConfig);
	HRESULT ( *Initialize) (IDirectSound *This, LPCGUID pcGuidDevice);
};
const GUID IID_IDirectSound8;
typedef struct IDirectSound8 { struct IDirectSound8Vtbl *lpVtbl; } IDirectSound8; typedef struct IDirectSound8Vtbl IDirectSound8Vtbl; struct IDirectSound8Vtbl
{
	HRESULT ( *QueryInterface) (IDirectSound8 *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSound8 *This);
	ULONG ( *Release) (IDirectSound8 *This);
	HRESULT ( *CreateSoundBuffer) (IDirectSound8 *This, LPCDSBUFFERDESC pcDSBufferDesc, LPDIRECTSOUNDBUFFER *ppDSBuffer, LPUNKNOWN pUnkOuter);
	HRESULT ( *GetCaps) (IDirectSound8 *This, LPDSCAPS pDSCaps);
	HRESULT ( *DuplicateSoundBuffer) (IDirectSound8 *This, LPDIRECTSOUNDBUFFER pDSBufferOriginal, LPDIRECTSOUNDBUFFER *ppDSBufferDuplicate);
	HRESULT ( *SetCooperativeLevel) (IDirectSound8 *This, HWND hwnd, DWORD dwLevel);
	HRESULT ( *Compact) (IDirectSound8 *This);
	HRESULT ( *GetSpeakerConfig) (IDirectSound8 *This, LPDWORD pdwSpeakerConfig);
	HRESULT ( *SetSpeakerConfig) (IDirectSound8 *This, DWORD dwSpeakerConfig);
	HRESULT ( *Initialize) (IDirectSound8 *This, LPCGUID pcGuidDevice);
	HRESULT ( *VerifyCertification) (IDirectSound8 *This, LPDWORD pdwCertified);
};
const GUID IID_IDirectSoundBuffer;
typedef struct IDirectSoundBuffer { struct IDirectSoundBufferVtbl *lpVtbl; } IDirectSoundBuffer; typedef struct IDirectSoundBufferVtbl IDirectSoundBufferVtbl; struct IDirectSoundBufferVtbl
{
	HRESULT ( *QueryInterface) (IDirectSoundBuffer *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSoundBuffer *This);
	ULONG ( *Release) (IDirectSoundBuffer *This);
	HRESULT ( *GetCaps) (IDirectSoundBuffer *This, LPDSBCAPS pDSBufferCaps);
	HRESULT ( *GetCurrentPosition) (IDirectSoundBuffer *This, LPDWORD pdwCurrentPlayCursor, LPDWORD pdwCurrentWriteCursor);
	HRESULT ( *GetFormat) (IDirectSoundBuffer *This, LPWAVEFORMATEX pwfxFormat, DWORD dwSizeAllocated, LPDWORD pdwSizeWritten);
	HRESULT ( *GetVolume) (IDirectSoundBuffer *This, LPLONG plVolume);
	HRESULT ( *GetPan) (IDirectSoundBuffer *This, LPLONG plPan);
	HRESULT ( *GetFrequency) (IDirectSoundBuffer *This, LPDWORD pdwFrequency);
	HRESULT ( *GetStatus) (IDirectSoundBuffer *This, LPDWORD pdwStatus);
	HRESULT ( *Initialize) (IDirectSoundBuffer *This, LPDIRECTSOUND pDirectSound, LPCDSBUFFERDESC pcDSBufferDesc);
	HRESULT ( *Lock) (IDirectSoundBuffer *This, DWORD dwOffset, DWORD dwBytes,
	                                       LPVOID *ppvAudioPtr1, LPDWORD pdwAudioBytes1,
	                                       LPVOID *ppvAudioPtr2, LPDWORD pdwAudioBytes2, DWORD dwFlags);
	HRESULT ( *Play) (IDirectSoundBuffer *This, DWORD dwReserved1, DWORD dwPriority, DWORD dwFlags);
	HRESULT ( *SetCurrentPosition) (IDirectSoundBuffer *This, DWORD dwNewPosition);
	HRESULT ( *SetFormat) (IDirectSoundBuffer *This, LPCWAVEFORMATEX pcfxFormat);
	HRESULT ( *SetVolume) (IDirectSoundBuffer *This, LONG lVolume);
	HRESULT ( *SetPan) (IDirectSoundBuffer *This, LONG lPan);
	HRESULT ( *SetFrequency) (IDirectSoundBuffer *This, DWORD dwFrequency);
	HRESULT ( *Stop) (IDirectSoundBuffer *This);
	HRESULT ( *Unlock) (IDirectSoundBuffer *This, LPVOID pvAudioPtr1, DWORD dwAudioBytes1,
	                                       LPVOID pvAudioPtr2, DWORD dwAudioBytes2);
	HRESULT ( *Restore) (IDirectSoundBuffer *This);
};
const GUID IID_IDirectSoundBuffer8;
typedef struct IDirectSoundBuffer8 { struct IDirectSoundBuffer8Vtbl *lpVtbl; } IDirectSoundBuffer8; typedef struct IDirectSoundBuffer8Vtbl IDirectSoundBuffer8Vtbl; struct IDirectSoundBuffer8Vtbl
{
	HRESULT ( *QueryInterface) (IDirectSoundBuffer8 *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSoundBuffer8 *This);
	ULONG ( *Release) (IDirectSoundBuffer8 *This);
	HRESULT ( *GetCaps) (IDirectSoundBuffer8 *This, LPDSBCAPS pDSBufferCaps);
	HRESULT ( *GetCurrentPosition) (IDirectSoundBuffer8 *This, LPDWORD pdwCurrentPlayCursor, LPDWORD pdwCurrentWriteCursor);
	HRESULT ( *GetFormat) (IDirectSoundBuffer8 *This, LPWAVEFORMATEX pwfxFormat, DWORD dwSizeAllocated, LPDWORD pdwSizeWritten);
	HRESULT ( *GetVolume) (IDirectSoundBuffer8 *This, LPLONG plVolume);
	HRESULT ( *GetPan) (IDirectSoundBuffer8 *This, LPLONG plPan);
	HRESULT ( *GetFrequency) (IDirectSoundBuffer8 *This, LPDWORD pdwFrequency);
	HRESULT ( *GetStatus) (IDirectSoundBuffer8 *This, LPDWORD pdwStatus);
	HRESULT ( *Initialize) (IDirectSoundBuffer8 *This, LPDIRECTSOUND pDirectSound, LPCDSBUFFERDESC pcDSBufferDesc);
	HRESULT ( *Lock) (IDirectSoundBuffer8 *This, DWORD dwOffset, DWORD dwBytes,
	                                       LPVOID *ppvAudioPtr1, LPDWORD pdwAudioBytes1,
	                                       LPVOID *ppvAudioPtr2, LPDWORD pdwAudioBytes2, DWORD dwFlags);
	HRESULT ( *Play) (IDirectSoundBuffer8 *This, DWORD dwReserved1, DWORD dwPriority, DWORD dwFlags);
	HRESULT ( *SetCurrentPosition) (IDirectSoundBuffer8 *This, DWORD dwNewPosition);
	HRESULT ( *SetFormat) (IDirectSoundBuffer8 *This, LPCWAVEFORMATEX pcfxFormat);
	HRESULT ( *SetVolume) (IDirectSoundBuffer8 *This, LONG lVolume);
	HRESULT ( *SetPan) (IDirectSoundBuffer8 *This, LONG lPan);
	HRESULT ( *SetFrequency) (IDirectSoundBuffer8 *This, DWORD dwFrequency);
	HRESULT ( *Stop) (IDirectSoundBuffer8 *This);
	HRESULT ( *Unlock) (IDirectSoundBuffer8 *This, LPVOID pvAudioPtr1, DWORD dwAudioBytes1,
	                                       LPVOID pvAudioPtr2, DWORD dwAudioBytes2);
	HRESULT ( *Restore) (IDirectSoundBuffer8 *This);
	HRESULT ( *SetFX) (IDirectSoundBuffer8 *This, DWORD dwEffectsCount, LPDSEFFECTDESC pDSFXDesc, LPDWORD pdwResultCodes);
	HRESULT ( *AcquireResources) (IDirectSoundBuffer8 *This, DWORD dwFlags, DWORD dwEffectsCount, LPDWORD pdwResultCodes);
	HRESULT ( *GetObjectInPath) (IDirectSoundBuffer8 *This, const GUID *const rguidObject, DWORD dwIndex, const GUID *const rguidInterface, LPVOID *ppObject);
};
const GUID GUID_All_Objects;
const GUID IID_IDirectSound3DListener;
typedef struct IDirectSound3DListener { struct IDirectSound3DListenerVtbl *lpVtbl; } IDirectSound3DListener; typedef struct IDirectSound3DListenerVtbl IDirectSound3DListenerVtbl; struct IDirectSound3DListenerVtbl
{
	HRESULT ( *QueryInterface) (IDirectSound3DListener *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSound3DListener *This);
	ULONG ( *Release) (IDirectSound3DListener *This);
	HRESULT ( *GetAllParameters) (IDirectSound3DListener *This, LPDS3DLISTENER pListener);
	HRESULT ( *GetDistanceFactor) (IDirectSound3DListener *This, D3DVALUE* pflDistanceFactor);
	HRESULT ( *GetDopplerFactor) (IDirectSound3DListener *This, D3DVALUE* pflDopplerFactor);
	HRESULT ( *GetOrientation) (IDirectSound3DListener *This, D3DVECTOR* pvOrientFront, D3DVECTOR* pvOrientTop);
	HRESULT ( *GetPosition) (IDirectSound3DListener *This, D3DVECTOR* pvPosition);
	HRESULT ( *GetRolloffFactor) (IDirectSound3DListener *This, D3DVALUE* pflRolloffFactor);
	HRESULT ( *GetVelocity) (IDirectSound3DListener *This, D3DVECTOR* pvVelocity);
	HRESULT ( *SetAllParameters) (IDirectSound3DListener *This, LPCDS3DLISTENER pcListener, DWORD dwApply);
	HRESULT ( *SetDistanceFactor) (IDirectSound3DListener *This, D3DVALUE flDistanceFactor, DWORD dwApply);
	HRESULT ( *SetDopplerFactor) (IDirectSound3DListener *This, D3DVALUE flDopplerFactor, DWORD dwApply);
	HRESULT ( *SetOrientation) (IDirectSound3DListener *This, D3DVALUE xFront, D3DVALUE yFront, D3DVALUE zFront,
	                                           D3DVALUE xTop, D3DVALUE yTop, D3DVALUE zTop, DWORD dwApply);
	HRESULT ( *SetPosition) (IDirectSound3DListener *This, D3DVALUE x, D3DVALUE y, D3DVALUE z, DWORD dwApply);
	HRESULT ( *SetRolloffFactor) (IDirectSound3DListener *This, D3DVALUE flRolloffFactor, DWORD dwApply);
	HRESULT ( *SetVelocity) (IDirectSound3DListener *This, D3DVALUE x, D3DVALUE y, D3DVALUE z, DWORD dwApply);
	HRESULT ( *CommitDeferredSettings) (IDirectSound3DListener *This);
};
const GUID IID_IDirectSound3DBuffer;
typedef struct IDirectSound3DBuffer { struct IDirectSound3DBufferVtbl *lpVtbl; } IDirectSound3DBuffer; typedef struct IDirectSound3DBufferVtbl IDirectSound3DBufferVtbl; struct IDirectSound3DBufferVtbl
{
	HRESULT ( *QueryInterface) (IDirectSound3DBuffer *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSound3DBuffer *This);
	ULONG ( *Release) (IDirectSound3DBuffer *This);
	HRESULT ( *GetAllParameters) (IDirectSound3DBuffer *This, LPDS3DBUFFER pDs3dBuffer);
	HRESULT ( *GetConeAngles) (IDirectSound3DBuffer *This, LPDWORD pdwInsideConeAngle, LPDWORD pdwOutsideConeAngle);
	HRESULT ( *GetConeOrientation) (IDirectSound3DBuffer *This, D3DVECTOR* pvOrientation);
	HRESULT ( *GetConeOutsideVolume) (IDirectSound3DBuffer *This, LPLONG plConeOutsideVolume);
	HRESULT ( *GetMaxDistance) (IDirectSound3DBuffer *This, D3DVALUE* pflMaxDistance);
	HRESULT ( *GetMinDistance) (IDirectSound3DBuffer *This, D3DVALUE* pflMinDistance);
	HRESULT ( *GetMode) (IDirectSound3DBuffer *This, LPDWORD pdwMode);
	HRESULT ( *GetPosition) (IDirectSound3DBuffer *This, D3DVECTOR* pvPosition);
	HRESULT ( *GetVelocity) (IDirectSound3DBuffer *This, D3DVECTOR* pvVelocity);
	HRESULT ( *SetAllParameters) (IDirectSound3DBuffer *This, LPCDS3DBUFFER pcDs3dBuffer, DWORD dwApply);
	HRESULT ( *SetConeAngles) (IDirectSound3DBuffer *This, DWORD dwInsideConeAngle, DWORD dwOutsideConeAngle, DWORD dwApply);
	HRESULT ( *SetConeOrientation) (IDirectSound3DBuffer *This, D3DVALUE x, D3DVALUE y, D3DVALUE z, DWORD dwApply);
	HRESULT ( *SetConeOutsideVolume) (IDirectSound3DBuffer *This, LONG lConeOutsideVolume, DWORD dwApply);
	HRESULT ( *SetMaxDistance) (IDirectSound3DBuffer *This, D3DVALUE flMaxDistance, DWORD dwApply);
	HRESULT ( *SetMinDistance) (IDirectSound3DBuffer *This, D3DVALUE flMinDistance, DWORD dwApply);
	HRESULT ( *SetMode) (IDirectSound3DBuffer *This, DWORD dwMode, DWORD dwApply);
	HRESULT ( *SetPosition) (IDirectSound3DBuffer *This, D3DVALUE x, D3DVALUE y, D3DVALUE z, DWORD dwApply);
	HRESULT ( *SetVelocity) (IDirectSound3DBuffer *This, D3DVALUE x, D3DVALUE y, D3DVALUE z, DWORD dwApply);
};
const GUID IID_IDirectSoundCapture;
typedef struct IDirectSoundCapture { struct IDirectSoundCaptureVtbl *lpVtbl; } IDirectSoundCapture; typedef struct IDirectSoundCaptureVtbl IDirectSoundCaptureVtbl; struct IDirectSoundCaptureVtbl
{
	HRESULT ( *QueryInterface) (IDirectSoundCapture *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSoundCapture *This);
	ULONG ( *Release) (IDirectSoundCapture *This);
	HRESULT ( *CreateCaptureBuffer) (IDirectSoundCapture *This, LPCDSCBUFFERDESC pcDSCBufferDesc, LPDIRECTSOUNDCAPTUREBUFFER *ppDSCBuffer, LPUNKNOWN pUnkOuter);
	HRESULT ( *GetCaps) (IDirectSoundCapture *This, LPDSCCAPS pDSCCaps);
	HRESULT ( *Initialize) (IDirectSoundCapture *This, LPCGUID pcGuidDevice);
};
const GUID IID_IDirectSoundCaptureBuffer;
typedef struct IDirectSoundCaptureBuffer { struct IDirectSoundCaptureBufferVtbl *lpVtbl; } IDirectSoundCaptureBuffer; typedef struct IDirectSoundCaptureBufferVtbl IDirectSoundCaptureBufferVtbl; struct IDirectSoundCaptureBufferVtbl
{
	HRESULT ( *QueryInterface) (IDirectSoundCaptureBuffer *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSoundCaptureBuffer *This);
	ULONG ( *Release) (IDirectSoundCaptureBuffer *This);
	HRESULT ( *GetCaps) (IDirectSoundCaptureBuffer *This, LPDSCBCAPS pDSCBCaps);
	HRESULT ( *GetCurrentPosition) (IDirectSoundCaptureBuffer *This, LPDWORD pdwCapturePosition, LPDWORD pdwReadPosition);
	HRESULT ( *GetFormat) (IDirectSoundCaptureBuffer *This, LPWAVEFORMATEX pwfxFormat, DWORD dwSizeAllocated, LPDWORD pdwSizeWritten);
	HRESULT ( *GetStatus) (IDirectSoundCaptureBuffer *This, LPDWORD pdwStatus);
	HRESULT ( *Initialize) (IDirectSoundCaptureBuffer *This, LPDIRECTSOUNDCAPTURE pDirectSoundCapture, LPCDSCBUFFERDESC pcDSCBufferDesc);
	HRESULT ( *Lock) (IDirectSoundCaptureBuffer *This, DWORD dwOffset, DWORD dwBytes,
	                                       LPVOID *ppvAudioPtr1, LPDWORD pdwAudioBytes1,
	                                       LPVOID *ppvAudioPtr2, LPDWORD pdwAudioBytes2, DWORD dwFlags);
	HRESULT ( *Start) (IDirectSoundCaptureBuffer *This, DWORD dwFlags);
	HRESULT ( *Stop) (IDirectSoundCaptureBuffer *This);
	HRESULT ( *Unlock) (IDirectSoundCaptureBuffer *This, LPVOID pvAudioPtr1, DWORD dwAudioBytes1,
	                                       LPVOID pvAudioPtr2, DWORD dwAudioBytes2);
};
const GUID IID_IDirectSoundCaptureBuffer8;
typedef struct IDirectSoundCaptureBuffer8 { struct IDirectSoundCaptureBuffer8Vtbl *lpVtbl; } IDirectSoundCaptureBuffer8; typedef struct IDirectSoundCaptureBuffer8Vtbl IDirectSoundCaptureBuffer8Vtbl; struct IDirectSoundCaptureBuffer8Vtbl
{
	HRESULT ( *QueryInterface) (IDirectSoundCaptureBuffer8 *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSoundCaptureBuffer8 *This);
	ULONG ( *Release) (IDirectSoundCaptureBuffer8 *This);
	HRESULT ( *GetCaps) (IDirectSoundCaptureBuffer8 *This, LPDSCBCAPS pDSCBCaps);
	HRESULT ( *GetCurrentPosition) (IDirectSoundCaptureBuffer8 *This, LPDWORD pdwCapturePosition, LPDWORD pdwReadPosition);
	HRESULT ( *GetFormat) (IDirectSoundCaptureBuffer8 *This, LPWAVEFORMATEX pwfxFormat, DWORD dwSizeAllocated, LPDWORD pdwSizeWritten);
	HRESULT ( *GetStatus) (IDirectSoundCaptureBuffer8 *This, LPDWORD pdwStatus);
	HRESULT ( *Initialize) (IDirectSoundCaptureBuffer8 *This, LPDIRECTSOUNDCAPTURE pDirectSoundCapture, LPCDSCBUFFERDESC pcDSCBufferDesc);
	HRESULT ( *Lock) (IDirectSoundCaptureBuffer8 *This, DWORD dwOffset, DWORD dwBytes,
	                                       LPVOID *ppvAudioPtr1, LPDWORD pdwAudioBytes1,
	                                       LPVOID *ppvAudioPtr2, LPDWORD pdwAudioBytes2, DWORD dwFlags);
	HRESULT ( *Start) (IDirectSoundCaptureBuffer8 *This, DWORD dwFlags);
	HRESULT ( *Stop) (IDirectSoundCaptureBuffer8 *This);
	HRESULT ( *Unlock) (IDirectSoundCaptureBuffer8 *This, LPVOID pvAudioPtr1, DWORD dwAudioBytes1,
	                                       LPVOID pvAudioPtr2, DWORD dwAudioBytes2);
	HRESULT ( *GetObjectInPath) (IDirectSoundCaptureBuffer8 *This, const GUID *const rguidObject, DWORD dwIndex, const GUID *const rguidInterface, LPVOID *ppObject);
	HRESULT ( *GetFXStatus) (DWORD dwEffectsCount, LPDWORD pdwFXStatus);
};
const GUID IID_IDirectSoundNotify;
typedef struct IDirectSoundNotify { struct IDirectSoundNotifyVtbl *lpVtbl; } IDirectSoundNotify; typedef struct IDirectSoundNotifyVtbl IDirectSoundNotifyVtbl; struct IDirectSoundNotifyVtbl
{
	HRESULT ( *QueryInterface) (IDirectSoundNotify *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSoundNotify *This);
	ULONG ( *Release) (IDirectSoundNotify *This);
	HRESULT ( *SetNotificationPositions) (IDirectSoundNotify *This, DWORD dwPositionNotifies, LPCDSBPOSITIONNOTIFY pcPositionNotifies);
};
typedef struct IKsPropertySet *LPKSPROPERTYSET;
const GUID IID_IKsPropertySet;
typedef struct IKsPropertySet { struct IKsPropertySetVtbl *lpVtbl; } IKsPropertySet; typedef struct IKsPropertySetVtbl IKsPropertySetVtbl; struct IKsPropertySetVtbl
{
	HRESULT ( *QueryInterface) (IKsPropertySet *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IKsPropertySet *This);
	ULONG ( *Release) (IKsPropertySet *This);
	HRESULT ( *Get) (IKsPropertySet *This, const GUID *const rguidPropSet, ULONG ulId, LPVOID pInstanceData, ULONG ulInstanceLength, LPVOID pPropertyData, ULONG ulDataLength, PULONG pulBytesReturned);
	HRESULT ( *Set) (IKsPropertySet *This, const GUID *const rguidPropSet, ULONG ulId, LPVOID pInstanceData, ULONG ulInstanceLength, LPVOID pPropertyData, ULONG ulDataLength);
	HRESULT ( *QuerySupport) (IKsPropertySet *This, const GUID *const rguidPropSet, ULONG ulId, PULONG pulTypeSupport);
};
const GUID IID_IDirectSoundFXGargle;
typedef struct _DSFXGargle
{
	DWORD dwRateHz;
	DWORD dwWaveShape;
} DSFXGargle, *LPDSFXGargle;
typedef const DSFXGargle *LPCDSFXGargle;
typedef struct IDirectSoundFXGargle { struct IDirectSoundFXGargleVtbl *lpVtbl; } IDirectSoundFXGargle; typedef struct IDirectSoundFXGargleVtbl IDirectSoundFXGargleVtbl; struct IDirectSoundFXGargleVtbl
{
	HRESULT ( *QueryInterface) (IDirectSoundFXGargle *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSoundFXGargle *This);
	ULONG ( *Release) (IDirectSoundFXGargle *This);
	HRESULT ( *SetAllParameters) (IDirectSoundFXGargle *This, LPCDSFXGargle pcDsFxGargle);
	HRESULT ( *GetAllParameters) (IDirectSoundFXGargle *This, LPDSFXGargle pDsFxGargle);
};
const GUID IID_IDirectSoundFXChorus;
typedef struct _DSFXChorus
{
	FLOAT fWetDryMix;
	FLOAT fDepth;
	FLOAT fFeedback;
	FLOAT fFrequency;
	LONG lWaveform;
	FLOAT fDelay;
	LONG lPhase;
} DSFXChorus, *LPDSFXChorus;
typedef const DSFXChorus *LPCDSFXChorus;
typedef struct IDirectSoundFXChorus { struct IDirectSoundFXChorusVtbl *lpVtbl; } IDirectSoundFXChorus; typedef struct IDirectSoundFXChorusVtbl IDirectSoundFXChorusVtbl; struct IDirectSoundFXChorusVtbl
{
	HRESULT ( *QueryInterface) (IDirectSoundFXChorus *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSoundFXChorus *This);
	ULONG ( *Release) (IDirectSoundFXChorus *This);
	HRESULT ( *SetAllParameters) (IDirectSoundFXChorus *This, LPCDSFXChorus pcDsFxChorus);
	HRESULT ( *GetAllParameters) (IDirectSoundFXChorus *This, LPDSFXChorus pDsFxChorus);
};
const GUID IID_IDirectSoundFXFlanger;
typedef struct _DSFXFlanger
{
	FLOAT fWetDryMix;
	FLOAT fDepth;
	FLOAT fFeedback;
	FLOAT fFrequency;
	LONG lWaveform;
	FLOAT fDelay;
	LONG lPhase;
} DSFXFlanger, *LPDSFXFlanger;
typedef const DSFXFlanger *LPCDSFXFlanger;
typedef struct IDirectSoundFXFlanger { struct IDirectSoundFXFlangerVtbl *lpVtbl; } IDirectSoundFXFlanger; typedef struct IDirectSoundFXFlangerVtbl IDirectSoundFXFlangerVtbl; struct IDirectSoundFXFlangerVtbl
{
	HRESULT ( *QueryInterface) (IDirectSoundFXFlanger *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSoundFXFlanger *This);
	ULONG ( *Release) (IDirectSoundFXFlanger *This);
	HRESULT ( *SetAllParameters) (IDirectSoundFXFlanger *This, LPCDSFXFlanger pcDsFxFlanger);
	HRESULT ( *GetAllParameters) (IDirectSoundFXFlanger *This, LPDSFXFlanger pDsFxFlanger);
};
const GUID IID_IDirectSoundFXEcho;
typedef struct _DSFXEcho
{
	FLOAT fWetDryMix;
	FLOAT fFeedback;
	FLOAT fLeftDelay;
	FLOAT fRightDelay;
	LONG lPanDelay;
} DSFXEcho, *LPDSFXEcho;
typedef const DSFXEcho *LPCDSFXEcho;
typedef struct IDirectSoundFXEcho { struct IDirectSoundFXEchoVtbl *lpVtbl; } IDirectSoundFXEcho; typedef struct IDirectSoundFXEchoVtbl IDirectSoundFXEchoVtbl; struct IDirectSoundFXEchoVtbl
{
	HRESULT ( *QueryInterface) (IDirectSoundFXEcho *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSoundFXEcho *This);
	ULONG ( *Release) (IDirectSoundFXEcho *This);
	HRESULT ( *SetAllParameters) (IDirectSoundFXEcho *This, LPCDSFXEcho pcDsFxEcho);
	HRESULT ( *GetAllParameters) (IDirectSoundFXEcho *This, LPDSFXEcho pDsFxEcho);
};
const GUID IID_IDirectSoundFXDistortion;
typedef struct _DSFXDistortion
{
	FLOAT fGain;
	FLOAT fEdge;
	FLOAT fPostEQCenterFrequency;
	FLOAT fPostEQBandwidth;
	FLOAT fPreLowpassCutoff;
} DSFXDistortion, *LPDSFXDistortion;
typedef const DSFXDistortion *LPCDSFXDistortion;
typedef struct IDirectSoundFXDistortion { struct IDirectSoundFXDistortionVtbl *lpVtbl; } IDirectSoundFXDistortion; typedef struct IDirectSoundFXDistortionVtbl IDirectSoundFXDistortionVtbl; struct IDirectSoundFXDistortionVtbl
{
	HRESULT ( *QueryInterface) (IDirectSoundFXDistortion *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSoundFXDistortion *This);
	ULONG ( *Release) (IDirectSoundFXDistortion *This);
	HRESULT ( *SetAllParameters) (IDirectSoundFXDistortion *This, LPCDSFXDistortion pcDsFxDistortion);
	HRESULT ( *GetAllParameters) (IDirectSoundFXDistortion *This, LPDSFXDistortion pDsFxDistortion);
};
const GUID IID_IDirectSoundFXCompressor;
typedef struct _DSFXCompressor
{
	FLOAT fGain;
	FLOAT fAttack;
	FLOAT fRelease;
	FLOAT fThreshold;
	FLOAT fRatio;
	FLOAT fPredelay;
} DSFXCompressor, *LPDSFXCompressor;
typedef const DSFXCompressor *LPCDSFXCompressor;
typedef struct IDirectSoundFXCompressor { struct IDirectSoundFXCompressorVtbl *lpVtbl; } IDirectSoundFXCompressor; typedef struct IDirectSoundFXCompressorVtbl IDirectSoundFXCompressorVtbl; struct IDirectSoundFXCompressorVtbl
{
	HRESULT ( *QueryInterface) (IDirectSoundFXCompressor *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSoundFXCompressor *This);
	ULONG ( *Release) (IDirectSoundFXCompressor *This);
	HRESULT ( *SetAllParameters) (IDirectSoundFXCompressor *This, LPCDSFXCompressor pcDsFxCompressor);
	HRESULT ( *GetAllParameters) (IDirectSoundFXCompressor *This, LPDSFXCompressor pDsFxCompressor);
};
const GUID IID_IDirectSoundFXParamEq;
typedef struct _DSFXParamEq
{
	FLOAT fCenter;
	FLOAT fBandwidth;
	FLOAT fGain;
} DSFXParamEq, *LPDSFXParamEq;
typedef const DSFXParamEq *LPCDSFXParamEq;
typedef struct IDirectSoundFXParamEq { struct IDirectSoundFXParamEqVtbl *lpVtbl; } IDirectSoundFXParamEq; typedef struct IDirectSoundFXParamEqVtbl IDirectSoundFXParamEqVtbl; struct IDirectSoundFXParamEqVtbl
{
	HRESULT ( *QueryInterface) (IDirectSoundFXParamEq *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSoundFXParamEq *This);
	ULONG ( *Release) (IDirectSoundFXParamEq *This);
	HRESULT ( *SetAllParameters) (IDirectSoundFXParamEq *This, LPCDSFXParamEq pcDsFxParamEq);
	HRESULT ( *GetAllParameters) (IDirectSoundFXParamEq *This, LPDSFXParamEq pDsFxParamEq);
};
const GUID IID_IDirectSoundFXI3DL2Reverb;
typedef struct _DSFXI3DL2Reverb
{
	LONG lRoom;
	LONG lRoomHF;
	FLOAT flRoomRolloffFactor;
	FLOAT flDecayTime;
	FLOAT flDecayHFRatio;
	LONG lReflections;
	FLOAT flReflectionsDelay;
	LONG lReverb;
	FLOAT flReverbDelay;
	FLOAT flDiffusion;
	FLOAT flDensity;
	FLOAT flHFReference;
} DSFXI3DL2Reverb, *LPDSFXI3DL2Reverb;
typedef const DSFXI3DL2Reverb *LPCDSFXI3DL2Reverb;
typedef struct IDirectSoundFXI3DL2Reverb { struct IDirectSoundFXI3DL2ReverbVtbl *lpVtbl; } IDirectSoundFXI3DL2Reverb; typedef struct IDirectSoundFXI3DL2ReverbVtbl IDirectSoundFXI3DL2ReverbVtbl; struct IDirectSoundFXI3DL2ReverbVtbl
{
	HRESULT ( *QueryInterface) (IDirectSoundFXI3DL2Reverb *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSoundFXI3DL2Reverb *This);
	ULONG ( *Release) (IDirectSoundFXI3DL2Reverb *This);
	HRESULT ( *SetAllParameters) (IDirectSoundFXI3DL2Reverb *This, LPCDSFXI3DL2Reverb pcDsFxI3DL2Reverb);
	HRESULT ( *GetAllParameters) (IDirectSoundFXI3DL2Reverb *This, LPDSFXI3DL2Reverb pDsFxI3DL2Reverb);
	HRESULT ( *SetPreset) (IDirectSoundFXI3DL2Reverb *This, DWORD dwPreset);
	HRESULT ( *GetPreset) (IDirectSoundFXI3DL2Reverb *This, LPDWORD pdwPreset);
	HRESULT ( *SetQuality) (IDirectSoundFXI3DL2Reverb *This, LONG lQuality);
	HRESULT ( *GetQuality) (IDirectSoundFXI3DL2Reverb *This, LONG *plQuality);
};
const GUID IID_IDirectSoundFXWavesReverb;
typedef struct _DSFXWavesReverb
{
	FLOAT fInGain;
	FLOAT fReverbMix;
	FLOAT fReverbTime;
	FLOAT fHighFreqRTRatio;
} DSFXWavesReverb, *LPDSFXWavesReverb;
typedef const DSFXWavesReverb *LPCDSFXWavesReverb;
typedef struct IDirectSoundFXWavesReverb { struct IDirectSoundFXWavesReverbVtbl *lpVtbl; } IDirectSoundFXWavesReverb; typedef struct IDirectSoundFXWavesReverbVtbl IDirectSoundFXWavesReverbVtbl; struct IDirectSoundFXWavesReverbVtbl
{
	HRESULT ( *QueryInterface) (IDirectSoundFXWavesReverb *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSoundFXWavesReverb *This);
	ULONG ( *Release) (IDirectSoundFXWavesReverb *This);
	HRESULT ( *SetAllParameters) (IDirectSoundFXWavesReverb *This, LPCDSFXWavesReverb pcDsFxWavesReverb);
	HRESULT ( *GetAllParameters) (IDirectSoundFXWavesReverb *This, LPDSFXWavesReverb pDsFxWavesReverb);
};
const GUID IID_IDirectSoundCaptureFXAec;
typedef struct _DSCFXAec
{
	BOOL fEnable;
	BOOL fNoiseFill;
	DWORD dwMode;
} DSCFXAec, *LPDSCFXAec;
typedef const DSCFXAec *LPCDSCFXAec;
typedef struct IDirectSoundCaptureFXAec { struct IDirectSoundCaptureFXAecVtbl *lpVtbl; } IDirectSoundCaptureFXAec; typedef struct IDirectSoundCaptureFXAecVtbl IDirectSoundCaptureFXAecVtbl; struct IDirectSoundCaptureFXAecVtbl
{
	HRESULT ( *QueryInterface) (IDirectSoundCaptureFXAec *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSoundCaptureFXAec *This);
	ULONG ( *Release) (IDirectSoundCaptureFXAec *This);
	HRESULT ( *SetAllParameters) (IDirectSoundCaptureFXAec *This, LPCDSCFXAec pDscFxAec);
	HRESULT ( *GetAllParameters) (IDirectSoundCaptureFXAec *This, LPDSCFXAec pDscFxAec);
	HRESULT ( *GetStatus) (IDirectSoundCaptureFXAec *This, LPDWORD pdwStatus);
	HRESULT ( *Reset) (IDirectSoundCaptureFXAec *This);
};
const GUID IID_IDirectSoundCaptureFXNoiseSuppress;
typedef struct _DSCFXNoiseSuppress
{
	BOOL fEnable;
} DSCFXNoiseSuppress, *LPDSCFXNoiseSuppress;
typedef const DSCFXNoiseSuppress *LPCDSCFXNoiseSuppress;
typedef struct IDirectSoundCaptureFXNoiseSuppress { struct IDirectSoundCaptureFXNoiseSuppressVtbl *lpVtbl; } IDirectSoundCaptureFXNoiseSuppress; typedef struct IDirectSoundCaptureFXNoiseSuppressVtbl IDirectSoundCaptureFXNoiseSuppressVtbl; struct IDirectSoundCaptureFXNoiseSuppressVtbl
{
	HRESULT ( *QueryInterface) (IDirectSoundCaptureFXNoiseSuppress *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSoundCaptureFXNoiseSuppress *This);
	ULONG ( *Release) (IDirectSoundCaptureFXNoiseSuppress *This);
	HRESULT ( *SetAllParameters) (IDirectSoundCaptureFXNoiseSuppress *This, LPCDSCFXNoiseSuppress pcDscFxNoiseSuppress);
	HRESULT ( *GetAllParameters) (IDirectSoundCaptureFXNoiseSuppress *This, LPDSCFXNoiseSuppress pDscFxNoiseSuppress);
	HRESULT ( *Reset) (IDirectSoundCaptureFXNoiseSuppress *This);
};
typedef struct IDirectSoundFullDuplex *LPDIRECTSOUNDFULLDUPLEX;
const GUID IID_IDirectSoundFullDuplex;
typedef struct IDirectSoundFullDuplex { struct IDirectSoundFullDuplexVtbl *lpVtbl; } IDirectSoundFullDuplex; typedef struct IDirectSoundFullDuplexVtbl IDirectSoundFullDuplexVtbl; struct IDirectSoundFullDuplexVtbl
{
	HRESULT ( *QueryInterface) (IDirectSoundFullDuplex *This, const IID *const, LPVOID*);
	ULONG ( *AddRef) (IDirectSoundFullDuplex *This);
	ULONG ( *Release) (IDirectSoundFullDuplex *This);
	HRESULT ( *Initialize) (IDirectSoundFullDuplex *This, LPCGUID pCaptureGuid, LPCGUID pRenderGuid, LPCDSCBUFFERDESC lpDscBufferDesc, LPCDSBUFFERDESC lpDsBufferDesc, HWND hWnd, DWORD dwLevel, LPLPDIRECTSOUNDCAPTUREBUFFER8 lplpDirectSoundCaptureBuffer8, LPLPDIRECTSOUNDBUFFER8 lplpDirectSoundBuffer8);
};
enum
{
	DSFX_I3DL2_MATERIAL_PRESET_SINGLEWINDOW,
	DSFX_I3DL2_MATERIAL_PRESET_DOUBLEWINDOW,
	DSFX_I3DL2_MATERIAL_PRESET_THINDOOR,
	DSFX_I3DL2_MATERIAL_PRESET_THICKDOOR,
	DSFX_I3DL2_MATERIAL_PRESET_WOODWALL,
	DSFX_I3DL2_MATERIAL_PRESET_BRICKWALL,
	DSFX_I3DL2_MATERIAL_PRESET_STONEWALL,
	DSFX_I3DL2_MATERIAL_PRESET_CURTAIN
};
enum
{
	DSFX_I3DL2_ENVIRONMENT_PRESET_DEFAULT,
	DSFX_I3DL2_ENVIRONMENT_PRESET_GENERIC,
	DSFX_I3DL2_ENVIRONMENT_PRESET_PADDEDCELL,
	DSFX_I3DL2_ENVIRONMENT_PRESET_ROOM,
	DSFX_I3DL2_ENVIRONMENT_PRESET_BATHROOM,
	DSFX_I3DL2_ENVIRONMENT_PRESET_LIVINGROOM,
	DSFX_I3DL2_ENVIRONMENT_PRESET_STONEROOM,
	DSFX_I3DL2_ENVIRONMENT_PRESET_AUDITORIUM,
	DSFX_I3DL2_ENVIRONMENT_PRESET_CONCERTHALL,
	DSFX_I3DL2_ENVIRONMENT_PRESET_CAVE,
	DSFX_I3DL2_ENVIRONMENT_PRESET_ARENA,
	DSFX_I3DL2_ENVIRONMENT_PRESET_HANGAR,
	DSFX_I3DL2_ENVIRONMENT_PRESET_CARPETEDHALLWAY,
	DSFX_I3DL2_ENVIRONMENT_PRESET_HALLWAY,
	DSFX_I3DL2_ENVIRONMENT_PRESET_STONECORRIDOR,
	DSFX_I3DL2_ENVIRONMENT_PRESET_ALLEY,
	DSFX_I3DL2_ENVIRONMENT_PRESET_FOREST,
	DSFX_I3DL2_ENVIRONMENT_PRESET_CITY,
	DSFX_I3DL2_ENVIRONMENT_PRESET_MOUNTAINS,
	DSFX_I3DL2_ENVIRONMENT_PRESET_QUARRY,
	DSFX_I3DL2_ENVIRONMENT_PRESET_PLAIN,
	DSFX_I3DL2_ENVIRONMENT_PRESET_PARKINGLOT,
	DSFX_I3DL2_ENVIRONMENT_PRESET_SEWERPIPE,
	DSFX_I3DL2_ENVIRONMENT_PRESET_UNDERWATER,
	DSFX_I3DL2_ENVIRONMENT_PRESET_SMALLROOM,
	DSFX_I3DL2_ENVIRONMENT_PRESET_MEDIUMROOM,
	DSFX_I3DL2_ENVIRONMENT_PRESET_LARGEROOM,
	DSFX_I3DL2_ENVIRONMENT_PRESET_MEDIUMHALL,
	DSFX_I3DL2_ENVIRONMENT_PRESET_LARGEHALL,
	DSFX_I3DL2_ENVIRONMENT_PRESET_PLATE
};
const GUID DS3DALG_NO_VIRTUALIZATION;
const GUID DS3DALG_HRTF_FULL;
const GUID DS3DALG_HRTF_LIGHT;
const GUID GUID_DSFX_STANDARD_GARGLE;
const GUID GUID_DSFX_STANDARD_CHORUS;
const GUID GUID_DSFX_STANDARD_FLANGER;
const GUID GUID_DSFX_STANDARD_ECHO;
const GUID GUID_DSFX_STANDARD_DISTORTION;
const GUID GUID_DSFX_STANDARD_COMPRESSOR;
const GUID GUID_DSFX_STANDARD_PARAMEQ;
const GUID GUID_DSFX_STANDARD_I3DL2REVERB;
const GUID GUID_DSFX_WAVES_REVERB;
const GUID GUID_DSCFX_CLASS_AEC;
const GUID GUID_DSCFX_MS_AEC;
const GUID GUID_DSCFX_SYSTEM_AEC;
const GUID GUID_DSCFX_CLASS_NS;
const GUID GUID_DSCFX_MS_NS;
const GUID GUID_DSCFX_SYSTEM_NS;
]]

--allow obj:method(...) instead of obj.lpVtbl.method(obj, ...)
local iface_meta = {__index = function(self, k) return self.lpVtbl[k] end}
for i, iface in ipairs{
	'IReferenceClock',
	'IDirectSound', 'IDirectSound8',
	'IDirectSoundBuffer', 'IDirectSoundBuffer8',
	'IDirectSound3DListener',
	'IDirectSound3DBuffer',
	'IDirectSoundCapture',
	'IDirectSoundCaptureBuffer',
	'IDirectSoundNotify',
	'IDirectSoundFXGargle',
	'IDirectSoundFXChorus',
	'IDirectSoundFXFlanger',
	'IDirectSoundFXEcho',
	'IDirectSoundFXDistortion',
	'IDirectSoundFXCompressor',
	'IDirectSoundFXParamEq',
	'IDirectSoundFXWavesReverb',
	'IDirectSoundFXI3DL2Reverb',
	'IDirectSoundCaptureFXAec',
	'IDirectSoundCaptureFXNoiseSuppress',
	'IDirectSoundFullDuplex',
} do
	ffi.metatype(iface, iface_meta)
end

function DirectSoundCreate(device_guid, other)
	local ds = ffi.new'LPDIRECTSOUND[1]'
	checkz(dsound.DirectSoundCreate(device_guid, ds, other))
	return ds[0]
end


--showcase

if not ... then
	require'winapi.showcase'
	local ringbuffer = require'ringbuffer'
	local win = ShowcaseWindow{title = 'Human Music', w = 500, h = 200}

	--create a direct sound object
	local ds = DirectSoundCreate()

	--we need this so we can call setFormat() to set 16bit sample size...
	checkz(ds:SetCooperativeLevel(win.hwnd, DSSCL_PRIORITY))

	--create the primary sound buffer (zero-sized, just to set the format)
	local bd = ffi.new'DSBUFFERDESC'
	bd.dwSize = ffi.sizeof(bd)
	bd.dwFlags = DSBCAPS_PRIMARYBUFFER
	local psb = ffi.new'LPDIRECTSOUNDBUFFER[1]'
	checkz(ds:CreateSoundBuffer(bd, psb, nil))
	psb = psb[0]

	local SAMPLE_RATE = 48000
	local BUFFER_SECONDS = 0.2
	local CHANNELS = 2
	local SAMPLE_TYPE = ffi.typeof'int16_t'
	local SAMPLE_PTR_TYPE = ffi.typeof('$*', SAMPLE_TYPE)
	local SAMPLE_SIZE = ffi.sizeof(SAMPLE_TYPE)
	local BLOCK_SIZE = SAMPLE_SIZE * CHANNELS
	local SECOND_SIZE = SAMPLE_RATE * SAMPLE_SIZE * CHANNELS
	local BUFFER_SIZE = SECOND_SIZE * BUFFER_SECONDS

	--set the format of the primary buffer
	local wf = ffi.new'WAVEFORMATEX'
	wf.wFormatTag = WAVE_FORMAT_PCM
	wf.nChannels = CHANNELS
	wf.nSamplesPerSec = SAMPLE_RATE
	wf.nAvgBytesPerSec = SECOND_SIZE
	wf.nBlockAlign = BLOCK_SIZE
	wf.wBitsPerSample = SAMPLE_SIZE * 8
	wf.cbSize = ffi.sizeof(wf)
	checkz(psb:SetFormat(wf))

	--create the secondary sound buffer into which we're going to write to
	local bd = ffi.new'DSBUFFERDESC'
	bd.dwSize = ffi.sizeof(bd)
	bd.dwBufferBytes = BUFFER_SIZE
	bd.lpwfxFormat = wf
	bd.dwFlags = DSBCAPS_GLOBALFOCUS --don't stop playing while the window is inactive!
	local ssb = ffi.new'LPDIRECTSOUNDBUFFER[1]'
	checkz(ds:CreateSoundBuffer(bd, ssb, nil))
	ssb = ssb[0]

	--create a ring buffer to manage the sound buffer state
	local rb = ringbuffer{size = BUFFER_SIZE, data = false}

	local playcursor  = ffi.new'int[1]'
	local writecursor = ffi.new'int[1]'
	function rb:update()
		--get the current start position of the ringbuffer
		checkz(ssb:GetCurrentPosition(playcursor, writecursor))
		--find out how much was consumed
		local len0 = playcursor[0] - rb.start
		local len = len0
		if len <= 0 then --a zero len is empty (the buffer can never be completely full)
			len = rb.size + len
		end
		print(string.format('pull %6d bytes.   start: %6d, filled: %3d%%',
			len, rb.start, rb.length / rb.size * 100))
		rb:pull(len)
	end

	math.randomseed(os.time())

	local tone = 440 --A4
	local function music_tone()
		local note = math.random(tone > 120 and -12 or 0, tone < 2000 and 12 or 0) / 12
		local change_it = math.random() > 0.5 and 1 or 0
		tone = tone * 2^(note * change_it)
		return tone
	end

	local PERIOD, VOLUME

	local function set_tone(tone) --tone is in Hertz
		PERIOD = math.floor(SAMPLE_RATE / tone)
	end

	local function set_volume(vol) --vol is in 0..1 range
		local max_vol = 2^15-1
		VOLUME = math.floor(vol^4 * max_vol)
	end

	set_tone(music_tone())
	set_volume(.5)

	local function square_wave(sample_index, channel)
		return (sample_index % PERIOD > PERIOD/2 and 1 or -1) * VOLUME -- _|-
	end

	local function sine_wave(sample_index, channel)
		return math.sin(sample_index * 2 * math.pi / PERIOD) * VOLUME
	end

	local wave_sample = sine_wave
	--local wave_sample = square_wave --go ahead, try the 1bit feel!

	local p1 = ffi.new'void*[1]'
	local p2 = ffi.new'void*[1]'
	local z1 = ffi.new'int[1]'
	local z2 = ffi.new'int[1]'
	function rb:write(src, di, si, n)
		checkz(ssb:Lock(di, n, p1, z1, p2, z2, 0))
		assert(z2[0] == 0) --our ringbuffer takes care of segmenting...
		local blocks = z1[0] / BLOCK_SIZE
		local si = (src + si) / BLOCK_SIZE
		assert(blocks == math.floor(blocks)) --check alignment
		assert(si == math.floor(si))
		local p = ffi.cast(SAMPLE_PTR_TYPE, p1[0])
		for i = 0, blocks-1 do
			for j = 0, CHANNELS-1 do
				p[i * CHANNELS + j] = wave_sample(si + i, j)
			end
		end
		checkz(ssb:Unlock(p1[0], z1[0], p2[0], z2[0]))
	end

	wave_offset = 0
	function rb:fill()
		rb:update()
		--find out how much space is available, but keep 1 block free
		--so that we can distinguish full from empty.
		local len = rb.size - rb.length - BLOCK_SIZE
		if len <= 0 then return end
		print(string.format('push %6d bytes.   start: %6d, filled: %3d%%',
			len, rb.start, rb.length / rb.size * 100))
		rb:push(len, wave_offset)
		wave_offset = wave_offset + len
	end

	--fill up the sound buffer (minus 1 block).
	rb:push(rb.size - BLOCK_SIZE, wave_offset)
	wave_offset = wave_offset + rb.size

	--re-fill the sound buffer on a timer when it's approx. half empty.
	win:settimer(BUFFER_SECONDS/2, function()
		set_tone(music_tone())
		rb:fill()
	end)

	--set the volume by hovering the mouse horizontally across the window.
	function win:on_mouse_move(x, y)
		set_volume(x / win.rect.w * 0.75)
	end

	--start playing
	ssb:Play(0, 0, DSBPLAY_LOOPING)

	MessageLoop()
end
