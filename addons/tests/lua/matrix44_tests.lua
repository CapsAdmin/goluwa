window.Open()

gl.PopMatrix()
local m = Matrix44()
gl.MatrixMode(e.GL_MODELVIEW)
gl.PushMatrix()
gl.LoadIdentity()

local function test(lua_func, gl_func, ...)
	m = m[lua_func](m, ...)
	
	local copy = ffi.new("float[16]")
	for i = 0, 15 do
		copy[i] = m.m[i]
	end

	gl_func(...)
	gl.GetFloatv(e.GL_MODELVIEW_MATRIX, m.m)
	
	local equal = true
	
	for i = 0, 15 do
		if math.round(copy[i], 3) ~= math.round(m.m[i], 3) then
			
			logf("member %i is not equal", i)
			logn("lua: ", copy[i])
			logn("ogl: ", m.m[i])
			
			equal = false
		end
	end
		
	if equal then
		logf("%s results are equal", lua_func)
		
		return true
	end
	
	logf("%s results are not equal!", lua_func)
	
	local old = m.m
	m.m = copy
	logn("\nLua result:")
	logn(m, "\n")

	m.m = old
	logn("\nOpenGL result:")
	logn(m, "\n")
	
	return false
end


for i = 1, 20 do 
	if not test("Translate", gl.Translatef, math.randomf(-100, 100), math.randomf(-100, 100), math.randomf(-100, 100)) then break end
	if not test("Rotate", gl.Rotatef, math.randomf(-100, 100), math.randomf(-1, 1), math.randomf(-1, 1), math.randomf(-1, 1)) then break end
	if not test("Scale", gl.Scalef, math.randomf(-100, 100), math.randomf(-100, 100), math.randomf(-100, 100)) then break end
	if not test("Ortho", gl.Ortho, math.randomf(-100, 100), math.randomf(-100, 100), math.randomf(-100, 100), math.randomf(-100, 100), math.randomf(-100, 100), math.randomf(-100, 100)) then break end
end
     
--test("Ortho", gl.Ortho, 0, 512, 0, 512, -1, 1) 
--test("Perspective", glu.Perspective, 70, 0.35, 200, 1.23)  