
--oo/controls/bitmappanel: RGBA bitmap control
--Written by Cosmin Apreutesei. Public Domain.

local ffi = require'ffi'
local bit = require'bit'
setfenv(1, require'winapi')
require'winapi.bitmap'
require'winapi.panelclass'
require'winapi.dibitmap'

BitmapPanel = class(Panel)

function BitmapPanel:on_paint(hdc)
	local bmp = self.__bmp

	if not bmp then
		local w, h = self.client_w, self.client_h
		if w <= 0 or h <= 0 then return end
		bmp = DIBitmap(w, h, self.hwnd)
		self.__bmp = bmp
		self:on_bitmap_create(bmp)
	end

	GdiFlush()
	self:on_bitmap_paint(bmp)

	bmp:paint(hdc)
end

function BitmapPanel:WM_ERASEBKGND()
	return not self.__bmp --we draw our own background (prevent flicker)
end

function BitmapPanel:on_resized()
	local bmp = self.__bmp
	if not bmp then return end

	local w, h = self.client_w, self.client_h
	if bmp.w == w and bmp.h == h then return end

	self:on_bitmap_free(bmp)
	bmp:free()
	self.__bmp = nil

	self:invalidate()
end

function BitmapPanel:on_bitmap_create(bitmap) end
function BitmapPanel:on_bitmap_free(bitmap) end
function BitmapPanel:on_bitmap_paint(bitmap) end

--showcase

if not ... then
	require'winapi.showcase'
	local win = ShowcaseWindow()
	local bp = BitmapPanel{
		x = 20,
		y = 20,
		w = win.client_w - 40,
		h = win.client_h - 40,
		parent = win,
		anchors = {left = true, top = true, right = true, bottom = true},
	}
	function bp:on_bitmap_paint(bmp)
		local pixels = ffi.cast('int32_t*', bmp.data)
		for y = 0, bmp.h - 1 do
			for x = 0, bmp.w - 1 do
				pixels[y * bmp.w + x] = y * 2^8 + x * 2^16
			end
		end
	end
	win:invalidate()
	MessageLoop()
end

return BitmapPanel
