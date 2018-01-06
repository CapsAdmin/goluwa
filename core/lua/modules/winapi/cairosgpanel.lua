
--oo/controls/cairosgpanel: cairo scene graph panel
--Written by Cosmin Apreutesei. Public Domain.

--call self.scene_graph:render(scene) on on_render() to render a cairo scene graph.
local winapi = require'winapi'
local CairoPanel = require'winapi.cairopanel'
local SG = require'sg_cairo'
local Cache = require'sg_cache'

local CairoSGPanel = winapi.class(CairoPanel)

function CairoSGPanel:__create_surface(surface)
	if not self.cache then self.cache = Cache:new() end
	assert(not self.scenegraph)
	self.scene_graph = SG:new(surface, self.cache)
end

function CairoSGPanel:__destroy_surface(surface)
	self.scene_graph = self.scene_graph:free()
end

function CairoSGPanel:on_destroy(...)
	self.cache = self.cache:free()
	CairoPanel.on_destroy(self,...)
end

return CairoSGPanel

