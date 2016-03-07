local gl = require("libopengl") -- OpenGL

window.Open()

gl.PopMatrix()
local m = Matrix44()
gl.MatrixMode(gl.e.GL_MODELVIEW)
gl.PushMatrix()
gl.LoadIdentity()

local function test(lua_func, gl_func, ...)
	gl.LoadIdentity()
	m:LoadIdentity()
	m[lua_func](m, ...)

	local copy = m:Copy()

	local args = {}
	for k,v in pairs({...}) do
		if typex(v) == "matrix44" then
			v = v.ptr
		end
		args[k] = v
	end

	gl_func(unpack(args))
	gl.GetFloatv(gl.e.GL_MODELVIEW_MATRIX, m.ptr)

	local equal = true

	for i = 0, 15 do
		if math.round(copy.ptr[i], 3) ~= math.round(m.ptr[i], 3) then

			logf("%s member %i is not equal\n", lua_func, i)
			logn("lua: ", copy.ptr[i])
			logn("ogl: ", m.ptr[i])

			equal = false
		end
	end

	if equal then
	--	logf("%s results are equal\n", lua_func)

		return true
	end

	logf("%s results are not equal!\n", lua_func)

	logn("\nLua result:")
	logn(copy, "\n")

	logn("\nOpenGL result:")
	logn(m, "\n")

	return false
end

local function random_matrix()
	local m = Matrix44()

	for i = 0, 15 do
		m.ptr[i] = math.randomf(-100,100)
	end

	return m
end

for i = 1, 20 do
	if not test("Translate", gl.Translatef, math.randomf(-100, 100), math.randomf(-100, 100), math.randomf(-100, 100)) then break end
	if not test("Multiply", gl.MultMatrixf, random_matrix()) then break end
	if not test("Rotate", gl.Rotatef, math.randomf(-360, 360), math.randomf(-1, 1), math.randomf(-1, 1), math.randomf(-1, 1)) then break end
	if not test("Multiply", gl.MultMatrixf, random_matrix()) then break end
	if not test("Scale", gl.Scalef, math.randomf(-100, 100), math.randomf(-100, 100), math.randomf(-100, 100)) then break end
	if not test("Multiply", gl.MultMatrixf, random_matrix()) then break end
end

--test("Ortho", gl.Ortho, 0, 512, 0, 512, -1, 1)
