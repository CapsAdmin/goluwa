
--oo/cairopanel: provides on_render(surface) event to draw on a cairo pixman surface.
--Written by Cosmin Apreutesei. Public Domain.

local ffi = require'ffi'
local bit = require'bit'
local winapi = require'winapi'
require'winapi.panelclass'
local cairo = require'cairo'
require'cairo_win32'

CairoPanel = winapi.class(winapi.Panel)

function CairoPanel:__before_create(info, args)
	info.own_dc = true --very important, because we reuse the hdc between WM_PAINTs
	CairoPanel.__index.__before_create(self, info, args)
end

function CairoPanel:__init(...)
	CairoPanel.__index.__init(self,...)
	self:invalidate()
end

function CairoPanel:__create_surface(surface) end --stub
function CairoPanel:__destroy_surface(surface) end --stub
function CairoPanel:on_render(surface) end --stub

function CairoPanel:__free_buffers()
	if not self.__pixman_surface then return end
	self.__window_cr = self.__window_cr:free()
	self.__window_surface = self.__window_surface:free()
	self:__destroy_surface(self.__pixman_surface)
	self.__pixman_surface = self.__pixman_surface:free()
end

function CairoPanel:on_destroy()
	self:__free_buffers()
end

function CairoPanel:WM_ERASEBKGND()
	return false --we draw our own background
end

function CairoPanel:on_resized()
	self:__free_buffers()
	self:invalidate()
end

function CairoPanel:on_paint(window_hdc)
	local w, h = self.client_w, self.client_h
	if not self.__pixman_surface then
		self.__window_surface = cairo.cairo_win32_surface_create(window_hdc)
		self.__window_cr = self.__window_surface:create_context()
		self.__pixman_surface = cairo.cairo_image_surface_create(cairo.CAIRO_FORMAT_RGB24, w, h)
		self:__create_surface(self.__pixman_surface)
		--this way, we avoid a copy from the pixman surface to the window surface
		self.__window_cr:set_source_surface(self.__pixman_surface, 0, 0)
	end
	self:on_render(self.__pixman_surface)
	if self.__pixman_surface then
		self.__window_cr:paint()
	end
end

return CairoPanel

--[[
--from cairo-win32-display-surface.c
local function get_bits(hdc, width, height)
	local bitmap_info = ffi.new'BITMAPINFO'
	bitmap_info.bmiHeader.biSize = ffi.sizeof'BITMAPINFOHEADER'
	bitmap_info.bmiHeader.biWidth = width
	bitmap_info.bmiHeader.biHeight = -height --top-down
	bitmap_info.bmiHeader.biPlanes = 1
	bitmap_info.bmiHeader.biBitCount = 32
	bitmap_info.bmiHeader.biCompression = BI_RGB
	local dc = CreateCompatibleDC(hdc)
	local bmp, bits = CreateDIBSection(dc, bitmap_info, DIB_RGB_COLORS)
   GdiFlush()
	local last_bmp = SelectObject(dc, bmp)
	--TODO: now use cairo_image_surface_create_for_data(bits)

	--TODO: save and free these on __free_buffers()
	SelectObject(dc, last_bmp)
	DeleteObject(bmp)
	DeleteDC(dc)
end
]]
