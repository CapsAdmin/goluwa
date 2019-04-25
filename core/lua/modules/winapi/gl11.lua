
--proc/opengl/gl11: OpenGL 1.1 API
--Written by Cosmin Apreutesei. Public Domain.

setfenv(1, require'winapi')
require'winapi.gl'
require'gl_funcs11'
update(gl, require'gl_consts11')
package.loaded['gl_consts11'] = nil

local glGetString = gl.glGetString
function gl.glGetString(...)
	return ffi.string(glGetString(...))
end

return gl
