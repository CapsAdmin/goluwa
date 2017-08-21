
--oo/controls/cairopanel: cairo pixman surface control
--Written by Cosmin Apreutesei. Public Domain.

--NOTE: this implementation doesn't rely on cairo's win32 extensions,
--so it works with a cairo binary that wasn't compiled with them.

local ffi = require'ffi'
local bit = require'bit'
local cairo = require'cairo'
setfenv(1, require'winapi')
require'winapi.bitmappanel'

CairoPanel = class(BitmapPanel)

function CairoPanel:on_bitmap_create(bitmap)
	self.__cairo_surface = cairo.cairo_image_surface_create_for_data(
		bitmap.data, cairo.CAIRO_FORMAT_ARGB32, bitmap.w, bitmap.h, bitmap.stride)
	self:on_cairo_create_surface(self.__cairo_surface)
	self.__cairo_context = self.__cairo_surface:create_context()
end

function CairoPanel:on_bitmap_free(bitmap)
	self.__cairo_context:free()
	self.__cairo_context = nil
	self:on_cairo_free_surface(self.__cairo_surface)
	self.__cairo_surface:free()
	self.__cairo_surface = nil
end

function CairoPanel:on_bitmap_paint(bitmap)
	self:on_cairo_paint(self.__cairo_context)
end

function CairoPanel:on_cairo_create_surface(surface) end
function CairoPanel:on_cairo_free_surface(surface) end
function CairoPanel:on_cairo_paint(context) end

--showcase

if not ... then
	require'winapi.showcase'
	local win = ShowcaseWindow()
	local bp = CairoPanel{
		x = 20,
		y = 20,
		w = win.client_w - 40,
		h = win.client_h - 40,
		parent = win,
		anchors = {left = true, top = true, right = true, bottom = true},
	}
	function bp:on_cairo_paint(cr)
		cr:set_source_rgba(0,0,0,1)
		cr:paint()

		cr:identity_matrix()
		cr:translate((bp.w - 250) / 2, (bp.h - 250) / 2)
		cr:set_source_rgba(0,0.7,0,1)

		cr:set_line_width (40.96)
		cr:move_to(76.8, 84.48)
		cr:rel_line_to(51.2, -51.2)
		cr:rel_line_to(51.2, 51.2)
		cr:set_line_join(cairo.CAIRO_LINE_JOIN_MITER)
		cr:stroke()

		cr:move_to(76.8, 161.28)
		cr:rel_line_to(51.2, -51.2)
		cr:rel_line_to(51.2, 51.2)
		cr:set_line_join(cairo.CAIRO_LINE_JOIN_BEVEL)
		cr:stroke()

		cr:move_to(76.8, 238.08)
		cr:rel_line_to(51.2, -51.2)
		cr:rel_line_to(51.2, 51.2)
		cr:set_line_join(cairo.CAIRO_LINE_JOIN_ROUND)
		cr:stroke()
	end
	win:invalidate()
	MessageLoop()
end

return CairoPanel
