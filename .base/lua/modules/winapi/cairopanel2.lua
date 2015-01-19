
--oo/cairopanel2: provides on_render(surface) event to draw on a cairo pixman surface.
--Written by Cosmin Apreutesei. Public Domain.

--this implementation doesn't rely on cairo's win32 extensions.
local ffi = require'ffi'
local bit = require'bit'
local cairo = require'cairo'
local winapi = require'winapi'
require'winapi.panelclass'

CairoPanel = winapi.class(winapi.Panel)

function CairoPanel:invalidate()
	if self.layered then
		self:_repaint_surface()
		self:_update_layered()
	else
		self.__index.invalidate(self)
	end
end

function CairoPanel:on_paint(hdc)
	self:_repaint_surface()
	if not self.bmp then return end
	winapi.BitBlt(hdc, 0, 0, self.bmp_size.w, self.bmp_size.h, self.bmp_hdc, 0, 0, winapi.SRCCOPY)
end

function CairoPanel:WM_ERASEBKGND()
	return false --we draw our own background (prevent flicker)
end

function CairoPanel:_create_surface()
	if self.bmp then return end
	self.win_pos = winapi.POINT{x = self.x, y = self.y}
	local w, h = self.client_w, self.client_h
	if w <= 0 or h <= 0 then return end
	self.bmp_pos = winapi.POINT{x = 0, y = 0}
	self.bmp_size = winapi.SIZE{w = w, h = h}

	local info = winapi.types.BITMAPINFO()
	info.bmiHeader.biSize = ffi.sizeof'BITMAPINFO'
	info.bmiHeader.biWidth = w
	info.bmiHeader.biHeight = -h
	info.bmiHeader.biPlanes = 1
	info.bmiHeader.biBitCount = 32
	info.bmiHeader.biCompression = winapi.BI_RGB
	self.bmp_hdc = winapi.CreateCompatibleDC()
	self.bmp, self.bmp_bits = winapi.CreateDIBSection(self.bmp_hdc, info, winapi.DIB_RGB_COLORS)
	self.old_bmp = winapi.SelectObject(self.bmp_hdc, self.bmp)

	self.pixman_surface = cairo.cairo_image_surface_create_for_data(self.bmp_bits,
									cairo.CAIRO_FORMAT_ARGB32, w, h, w * 4)
	self.pixman_cr = self.pixman_surface:create_context()
end

function CairoPanel:_free_surface()
	if not self.bmp then return end
	local w, h = self.client_w, self.client_h
	if self.bmp_size.w == w and self.bmp_size.h == h then return end
	self.pixman_cr:free()
	self.pixman_surface:free()
	winapi.SelectObject(self.bmp_hdc, self.old_bmp)
	winapi.DeleteObject(self.bmp)
	winapi.DeleteDC(self.bmp_hdc)
	self.bmp = nil
end

function CairoPanel:_repaint_surface()
	self:_create_surface()
	if not self.bmp then return end
	winapi.GdiFlush()
	self:on_render(self.pixman_cr)
end

function CairoPanel:on_render(cr) end --stub

function CairoPanel:on_resized()
	self:_free_surface()
	self:invalidate()
end

