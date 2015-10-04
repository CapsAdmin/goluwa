
--proc/gdi/devcaps: device capabilities API
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')

-- Device Parameters for GetDeviceCaps()
DRIVERVERSION  = 0      -- Device driver version
TECHNOLOGY     = 2      -- Device classification
HORZSIZE       = 4      -- Horizontal size in millimeters
VERTSIZE       = 6      -- Vertical size in millimeters
HORZRES        = 8      -- Horizontal width in pixels
VERTRES        = 10     -- Vertical height in pixels
BITSPIXEL      = 12     -- Number of bits per pixel
PLANES         = 14     -- Number of planes
NUMBRUSHES     = 16     -- Number of brushes the device has
NUMPENS        = 18     -- Number of pens the device has
NUMMARKERS     = 20     -- Number of markers the device has
NUMFONTS       = 22     -- Number of fonts the device has
NUMCOLORS      = 24     -- Number of colors the device supports
PDEVICESIZE    = 26     -- Size required for device descriptor
CURVECAPS      = 28     -- Curve capabilities
LINECAPS       = 30     -- Line capabilities
POLYGONALCAPS  = 32     -- Polygonal capabilities
TEXTCAPS       = 34     -- Text capabilities
CLIPCAPS       = 36     -- Clipping capabilities
RASTERCAPS     = 38     -- Bitblt capabilities
ASPECTX        = 40     -- Length of the X leg
ASPECTY        = 42     -- Length of the Y leg
ASPECTXY       = 44     -- Length of the hypotenuse

LOGPIXELSX     = 88     -- Logical pixels/inch in X
LOGPIXELSY     = 90     -- Logical pixels/inch in Y

SIZEPALETTE   = 104     -- Number of entries in physical palette
NUMRESERVED   = 106     -- Number of reserved entries in palette
COLORRES      = 108     -- Actual color resolution

-- Printing related DeviceCaps. These replace the appropriate Escapes

PHYSICALWIDTH    = 110  -- Physical Width in device units
PHYSICALHEIGHT   = 111  -- Physical Height in device units
PHYSICALOFFSETX  = 112  -- Physical Printable Area x margin
PHYSICALOFFSETY  = 113  -- Physical Printable Area y margin
SCALINGFACTORX   = 114  -- Scaling factor x
SCALINGFACTORY   = 115  -- Scaling factor y

-- Display driver specific

VREFRESH         = 116   -- Current vertical refresh rate of the display device (for displays only) in Hz
DESKTOPVERTRES   = 117   -- Horizontal width of entire desktop in pixels
DESKTOPHORZRES   = 118   -- Vertical height of entire desktop in pixels
BLTALIGNMENT     = 119   -- Preferred blt alignment

SHADEBLENDCAPS   = 120   -- Shading and blending caps
COLORMGMTCAPS    = 121   -- Color Management caps

-- Device Capability Masks:

-- Device Technologies
DT_PLOTTER           = 0    -- Vector plotter
DT_RASDISPLAY        = 1    -- Raster display
DT_RASPRINTER        = 2    -- Raster printer
DT_RASCAMERA         = 3    -- Raster camera
DT_CHARSTREAM        = 4    -- Character-stream, PLP
DT_METAFILE          = 5    -- Metafile, VDM
DT_DISPFILE          = 6    -- Display-file

-- Curve Capabilities
CC_NONE              = 0    -- Curves not supported
CC_CIRCLES           = 1    -- Can do circles
CC_PIE               = 2    -- Can do pie wedges
CC_CHORD             = 4    -- Can do chord arcs
CC_ELLIPSES          = 8    -- Can do ellipese
CC_WIDE              = 16   -- Can do wide lines
CC_STYLED            = 32   -- Can do styled lines
CC_WIDESTYLED        = 64   -- Can do wide styled lines
CC_INTERIORS         = 128  -- Can do interiors
CC_ROUNDRECT         = 256  --

-- Line Capabilities
LC_NONE              = 0    -- Lines not supported
LC_POLYLINE          = 2    -- Can do polylines
LC_MARKER            = 4    -- Can do markers
LC_POLYMARKER        = 8    -- Can do polymarkers
LC_WIDE              = 16   -- Can do wide lines
LC_STYLED            = 32   -- Can do styled lines
LC_WIDESTYLED        = 64   -- Can do wide styled lines
LC_INTERIORS         = 128  -- Can do interiors

-- Polygonal Capabilities
PC_NONE              = 0    -- Polygonals not supported
PC_POLYGON           = 1    -- Can do polygons
PC_RECTANGLE         = 2    -- Can do rectangles
PC_WINDPOLYGON       = 4    -- Can do winding polygons
PC_TRAPEZOID         = 4    -- Can do trapezoids
PC_SCANLINE          = 8    -- Can do scanlines
PC_WIDE              = 16   -- Can do wide borders
PC_STYLED            = 32   -- Can do styled borders
PC_WIDESTYLED        = 64   -- Can do wide styled borders
PC_INTERIORS         = 128  -- Can do interiors
PC_POLYPOLYGON       = 256  -- Can do polypolygons
PC_PATHS             = 512  -- Can do paths

-- Clipping Capabilities
CP_NONE              = 0    -- No clipping of output
CP_RECTANGLE         = 1    -- Output clipped to rects
CP_REGION            = 2    -- obsolete

-- Text Capabilities
TC_OP_CHARACTER      = 0x00000001   -- Can do OutputPrecision   CHARACTER
TC_OP_STROKE         = 0x00000002   -- Can do OutputPrecision   STROKE
TC_CP_STROKE         = 0x00000004   -- Can do ClipPrecision     STROKE
TC_CR_90             = 0x00000008   -- Can do CharRotAbility    90
TC_CR_ANY            = 0x00000010   -- Can do CharRotAbility    ANY
TC_SF_X_YINDEP       = 0x00000020   -- Can do ScaleFreedom      X_YINDEPENDENT
TC_SA_DOUBLE         = 0x00000040   -- Can do ScaleAbility      DOUBLE
TC_SA_INTEGER        = 0x00000080   -- Can do ScaleAbility      INTEGER
TC_SA_CONTIN         = 0x00000100   -- Can do ScaleAbility      CONTINUOUS
TC_EA_DOUBLE         = 0x00000200   -- Can do EmboldenAbility   DOUBLE
TC_IA_ABLE           = 0x00000400   -- Can do ItalisizeAbility  ABLE
TC_UA_ABLE           = 0x00000800   -- Can do UnderlineAbility  ABLE
TC_SO_ABLE           = 0x00001000   -- Can do StrikeOutAbility  ABLE
TC_RA_ABLE           = 0x00002000   -- Can do RasterFontAble    ABLE
TC_VA_ABLE           = 0x00004000   -- Can do VectorFontAble    ABLE
TC_RESERVED          = 0x00008000
TC_SCROLLBLT         = 0x00010000   -- Don't do text scroll with blt

-- Raster Capabilities
RC_BITBLT            = 1        -- Can do standard BLT.
RC_BANDING           = 2        -- Device requires banding support
RC_SCALING           = 4        -- Device requires scaling support
RC_BITMAP64          = 8        -- Device can support >64K bitmap
RC_GDI20_OUTPUT      = 0x0010       -- has 2.0 output calls
RC_GDI20_STATE       = 0x0020
RC_SAVEBITMAP        = 0x0040
RC_DI_BITMAP         = 0x0080       -- supports DIB to memory
RC_PALETTE           = 0x0100       -- supports a palette
RC_DIBTODEV          = 0x0200       -- supports DIBitsToDevice
RC_BIGFONT           = 0x0400       -- supports >64K fonts
RC_STRETCHBLT        = 0x0800       -- supports StretchBlt
RC_FLOODFILL         = 0x1000       -- supports FloodFill
RC_STRETCHDIB        = 0x2000       -- supports StretchDIBits
RC_OP_DX_OUTPUT      = 0x4000
RC_DEVBITS           = 0x8000

-- Shading and blending caps
SB_NONE              = 0x00000000
SB_CONST_ALPHA       = 0x00000001
SB_PIXEL_ALPHA       = 0x00000002
SB_PREMULT_ALPHA     = 0x00000004

SB_GRAD_RECT         = 0x00000010
SB_GRAD_TRI          = 0x00000020

-- Color Management caps
CM_NONE              = 0x00000000
CM_DEVICE_ICM        = 0x00000001
CM_GAMMA_RAMP        = 0x00000002
CM_CMYK_COLOR        = 0x00000004

ffi.cdef[[
int GetDeviceCaps(HDC hdc, int index);
]]

function GetDeviceCaps(hdc, index)
	return C.GetDeviceCaps(hdc, flags(index))
end
