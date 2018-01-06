
--oo/controls/wglpanel: opengl-enabled panel
--Written by Cosmin Apreutesei. Public Domain.

if not ... then require'winapi.wglpanel_demo'; return end

setfenv(1, require'winapi')
require'winapi.panelclass'
require'winapi.gl11'
require'winapi.wglext'

WGLPanel = class(Panel)

function WGLPanel:__before_create(info, args)
	info.own_dc = true
	WGLPanel.__index.__before_create(self, info, args)
end

function WGLPanel:__init(...)
	WGLPanel.__index.__init(self,...)
	self:invalidate()
end

function WGLPanel:on_destroy()
	if not self.hrc then return end
	wglDeleteContext(self.hrc)
	if self.window_hdc then
		wglMakeCurrent(self.window_hdc, nil)
	end
	self.hrc = nil
end

function WGLPanel:WM_ERASEBKGND()
	return false --we draw our own background
end

function WGLPanel:on_resized()
	if not self.hrc then return end
	self:on_set_viewport()
	self:invalidate()
end

function WGLPanel:on_render() end
function WGLPanel:on_set_viewport() end

function WGLPanel:on_paint(window_hdc)
	self.window_hdc = window_hdc
	if not self.hrc then
		local pfd = PIXELFORMATDESCRIPTOR{
			flags = 'PFD_DRAW_TO_WINDOW | PFD_SUPPORT_OPENGL | PFD_DOUBLEBUFFER',
			pixel_type = 'PFD_TYPE_RGBA',
			cColorBits = 32,
			cDepthBits = 24,
			cStencilBits = 8,
			layer_type = 'PFD_MAIN_PLANE',
		}
		SetPixelFormat(window_hdc, ChoosePixelFormat(window_hdc, pfd), pfd)
		self.hrc = gl.wglCreateContext(window_hdc)

		--[[
		if wglChoosePixelFormatARB then
			local pixelFormat = ffi.new'int32_t[1]'
			local numFormats = ffi.new'uint32_t[1]'
			local fAttributes = ffi.new('float[?]', 2)
			-- These Attributes Are The Bits We Want To Test For In Our Sample
			-- Everything Is Pretty Standard, The Only One We Want To
			-- Really Focus On Is The SAMPLE BUFFERS ARB And WGL SAMPLES
			-- These Two Are Going To Do The Main Testing For Whether Or Not
			-- We Support Multisampling On This Hardware
			local opts = {
				WGL_DRAW_TO_WINDOW_ARB, gl.GL_TRUE,
				WGL_SUPPORT_OPENGL_ARB, gl.GL_TRUE,
				WGL_ACCELERATION_ARB, WGL_FULL_ACCELERATION_ARB,
				WGL_COLOR_BITS_ARB, 32,
				WGL_DEPTH_BITS_ARB, 24,
				WGL_ALPHA_BITS_ARB, 8,
				WGL_STENCIL_BITS_ARB, 0,
				WGL_DOUBLE_BUFFER_ARB, gl.GL_TRUE,
				WGL_SAMPLE_BUFFERS_ARB, gl.GL_TRUE,
				WGL_SAMPLES_ARB, 4, --Check For 4x Multisampling
				0, 0}
			local iAttributes = ffi.new('int32_t[?]', #opts, opts)

			--First We Check To See If We Can Get A Pixel Format For 4 Samples
			local valid = wglChoosePixelFormatARB(window_hdc, iAttributes, fAttributes, 1, pixelFormat, numFormats)
			print(valid, numFormats[0], pixelFormat[0])

			if valid == 0 or numFormats[0] == 0 then
				-- Our Pixel Format With 4 Samples Failed, Test For 2 Samples
				iAttributes[19] = 2
				local valid = wglChoosePixelFormatARB(window_hdc, iAttributes, fAttributes, 1, pixelFormat, numFormats)
			end
		end
		]]

		if gl.wglSwapIntervalEXT then --enable vsync
			gl.wglSwapIntervalEXT(1)
		end

		wglMakeCurrent(window_hdc, self.hrc)
		--TODO: use wglChoosePixelFormatARB to enable FSAA
		self:on_set_viewport()
	else
		wglMakeCurrent(window_hdc, self.hrc)
	end

	self:on_render()
	SwapBuffers(window_hdc)
end

