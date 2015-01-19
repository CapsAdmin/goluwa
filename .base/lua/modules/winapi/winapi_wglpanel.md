---
project: winapi
title:   winapi.wglpanel
tagline: Windows OpenGL surface widget
---

## `require'winapi.wglpanel'`

## `winapi.WGLPanel(properties) -> WGLPanel`

Example:

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
