local gl = require("libraries.ffi.opengl") -- OpenGL

window.Open()

gl.PopMatrix()
local m = Matrix44()
gl.MatrixMode(gl.e.GL_MODELVIEW)
gl.PushMatrix()
gl.LoadIdentity()

local function test(lua_func, gl_func, ...)
	m[lua_func](m, ...)
	
	local copy = ffi.new("float[16]")
	for i = 0, 15 do
		copy[i] = m.m[i]
	end
	
	local args = {}
	for k,v in pairs({...}) do
		if typex(v) == "matrix44" then
			v = v.m
		end
		args[k] = v
	end

	gl_func(unpack(args))
	gl.GetFloatv(gl.e.GL_MODELVIEW_MATRIX, m.m)
	
	local equal = true
	
	for i = 0, 15 do
		if math.round(copy[i], 3) ~= math.round(m.m[i], 3) then
			
			logf("member %i is not equal\n", i)
			logn("lua: ", copy[i])
			logn("ogl: ", m.m[i])
			
			equal = false
		end
	end
		
	if equal then
	--	logf("%s results are equal\n", lua_func)
		
		return true
	end
	
	logf("%s results are not equal!\n", lua_func)
	
	local old = m.m
	m.m = copy
	logn("\nLua result:")
	logn(m, "\n")

	m.m = old
	logn("\nOpenGL result:")
	logn(m, "\n")
	
	return false
end

local function random_matrix()
	local m = Matrix44()
	
	for i = 1, 15 do
		m[i] = math.randomf(-100,100)
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
   
print(m) 

--test("Ortho", gl.Ortho, 0, 512, 0, 512, -1, 1) 
