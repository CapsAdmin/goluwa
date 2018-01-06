
--proc/opengl/gl: opengl dynamic namespace
--Written by Cosmin Apreutesei. Public Domain.

--NOTE: don't load this module, load gl11, gl21, wglext etc. instead.

setfenv(1, require'winapi')
require'winapi.wgl'

local function accesssym(lib, symbol) return lib[symbol] end
local function checksym(lib, symbol)
	local ok,v = pcall(accesssym, lib, symbol)
	if ok then return v else return nil,v end
end

gl = setmetatable({}, {
	__index = function(t,k)
		t[k] = checksym(opengl32, k) or
			ptr(ffi.cast(string.format('PFN%sPROC', k:upper()), wglGetProcAddress(k)))
		return rawget(t,k)
	end
})

local errors = {
	[0x0500] = 'GL_INVALID_ENUM',
	[0x0501] = 'GL_INVALID_VALUE',
	[0x0502] = 'GL_INVALID_OPERATION',
	[0x0503] = 'GL_OUT_OF_MEMORY',
	[0x0506] = 'GL_INVALID_FRAMEBUFFER_OPERATION',
	[0x0503] = 'GL_STACK_OVERFLOW',
	[0x0504] = 'GL_STACK_UNDERFLOW',
	[0x8031] = 'GL_TABLE_TOO_LARGE',
}

function gl.glCheckError()
	local err = gl.glGetError()
	glue.assert(err == 0, '%s Error 0x%x: %s', k, err, errors[err] or 'Unknown error.')
end

