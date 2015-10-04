---
tagline: OpenGL panels
---

## `require'winapi.wglpanel'`

This module implements the `WGLPanel` class which allows drawing
on a panel using [OpenGL][opengl].

## WGLPanel

### Hierarchy

* [Object][winapi.object]
	* [VObject][winapi.vobject]
		* [BaseWindow][winapi.basewindowclass]
			* [Control][winapi.controlclass]
				* [Panel][winapi.panelclass]
					* WGLPanel

### Events

<div class=small>
-------------------------------------------- -------------------------------------- -------------------------
__painting__											__description__								__reference__
on_render()												panel needs repainting						WM_PAINT
on_set_viewport()										window was resized
-------------------------------------------- -------------------------------------- -------------------------
</div>

### Usage

~~~{.lua}
local winapi = require'winapi'
require'winapi.wglpanel'

local main = winapi.Window{
  autoquit = true,
}

local panel = winapi.WGLPanel{
  anchors = {left = true, top = true, right = true, bottom = true},
  w = main.client_w,
  h = main.client_h,
  parent = main,
}

local gl = require'winapi.gl21'

function panel:on_render()
  gl.glMatrixMode(gl.GL_MODELVIEW)
  gl.glLoadIdentity()
  --render model...
end
~~~
