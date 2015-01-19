local winapi = require'winapi'
require'winapi.windowclass'
require'winapi.amanithvgpanel'
local gl = require'winapi.gl11'
local vg = require'amanithvg'

local main = winapi.Window{
	autoquit = true,
	visible = false,
	title = 'AmanithVGPanel test'
}

local panel = winapi.AmanithVGPanel{
	anchors = {left = true, top = true, right = true, bottom = true},
	visible = false,
}

function main:init()
	panel.w = self.client_w
	panel.h = self.client_h
	panel.parent = self
	panel.visible = true
	self.visible = true
	panel:settimer(1/60, panel.invalidate)
end

function panel:on_render()
	local ffi = require'ffi'
	local bit = require'bit'

	vg.vgSeti(vg.VG_RENDERING_QUALITY, vg.VG_RENDERING_QUALITY_BETTER)
	vg.vgSeti(vg.VG_BLEND_MODE, vg.VG_BLEND_SRC_OVER)
	vg.vgSeti(vg.VG_MASKING, vg.VG_FALSE)
	vg.vgSeti(vg.VG_SCISSORING, vg.VG_FALSE)
	vg.vgSeti(vg.VG_MATRIX_MODE, vg.VG_MATRIX_PATH_USER_TO_SURFACE)
	vg.vgLoadIdentity()

	local col = ffi.new('VGfloat[?]', 4, 1, 1, 1, 1)
	vg.vgSetfv(vg.VG_CLEAR_COLOR, 4, col)
	vg.vgClear(0, 0, self.client_w, self.client_h)

	---------------------------------------------------------------------------
	--TODO: make some demos from here: http://www.amanithvg.com/testsuite/amanithvg_gle/tests/

	local starSegments = ffi.new('VGubyte[?]', 6,
     vg.VG_MOVE_TO_ABS,
     vg.VG_LINE_TO_REL,
     vg.VG_LINE_TO_REL,
     vg.VG_LINE_TO_REL,
     vg.VG_LINE_TO_REL,
     vg.VG_CLOSE_PATH)

	local starCoords = ffi.new('VGfloat[?]', 10,
     110, 35,
     50, 160,
     -130, -100,
     160, 0,
     -130, 100)

	local path = vg.vgCreatePath(vg.VG_PATH_FORMAT_STANDARD,
							  vg.VG_PATH_DATATYPE_F,
							  1.0,  -- scale
							  0.0,  -- bias
							  0,    -- segmentCapacityHint
							  0,    -- coordCapacityHint
							  vg.VG_PATH_CAPABILITY_ALL)
	vg.vgAppendPathData(path, ffi.sizeof(starSegments), starSegments, starCoords)

	vg.vguRect(path, 100, 100, 500, 500)

	local col = ffi.new('VGfloat[?]', 4, 1, 0, 0, 1)
	local strokePaint = vg.vgCreatePaint()
	vg.vgSetParameteri(strokePaint, vg.VG_PAINT_TYPE, vg.VG_PAINT_TYPE_COLOR)
	vg.vgSetParameterfv(strokePaint, vg.VG_PAINT_COLOR, 4, col)

	local col = ffi.new('VGfloat[?]', 4, 0, 0, 1, 1)
	local fillPaint = vg.vgCreatePaint()
	vg.vgSetParameteri(fillPaint, vg.VG_PAINT_TYPE, vg.VG_PAINT_TYPE_COLOR)
	vg.vgSetParameterfv(fillPaint, vg.VG_PAINT_COLOR, 4, col)

	vg.vgSetPaint(strokePaint, vg.VG_STROKE_PATH)
	vg.vgSetPaint(fillPaint, vg.VG_FILL_PATH)
	vg.vgDrawPath(path, bit.bor(vg.VG_FILL_PATH, vg.VG_STROKE_PATH))

	vg.vgDestroyPath(path)
	vg.vgDestroyPaint(strokePaint)
end

main:init()

os.exit(winapi.MessageLoop())

