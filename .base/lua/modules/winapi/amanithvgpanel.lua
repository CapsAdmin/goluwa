
--oo/amanithvgpanel: opengl + openvg-enabled panel using AmanithVG GLE implementation.
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.wglpanel'
local C = require'amanithvg'

AmanithVGPanel = class(WGLPanel)

function AmanithVGPanel:__after_gl_context()
	self.context = C.vgPrivContextCreateAM(nil)
	assert(self.context ~= nil)
	self.surface = C.vgPrivSurfaceCreateAM(self.client_w, self.client_h, C.VG_FALSE, C.VG_FALSE)
	assert(self.surface ~= nil)
	assert(C.vgPrivMakeCurrentAM(self.context, self.surface) ~= C.VG_FALSE)
end

function AmanithVGPanel:on_destroy(...)
	C.vgPrivMakeCurrentAM(nil, nil)
	if self.surface then C.vgPrivSurfaceDestroyAM(self.surface) end
	if self.context then C.vgPrivContextDestroyAM(self.context) end
	AmanithVGPanel.__index.on_destroy(self,...)
end

function AmanithVGPanel:on_resized(...)
	C.vgPrivSurfaceResizeAM(self.surface, self.client_w, self.client_h)
	AmanithVGPanel.__index.on_resized(self,...)
end

if not ... then require'winapi.amanithvgpanel_demo' end
