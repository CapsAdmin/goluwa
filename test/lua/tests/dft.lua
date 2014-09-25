-- Script by montoyo
-- Little complex number library

ffi.cdef("struct ret { double Im, Re; };")

local Complex = ffi.typeof("struct ret") 

local cplx = {}

function cplx.__add(self, b)
	return Complex(self.Im + b.Im, self.Re + b.Re)
end

function cplx.__mul(self, b)
	return Complex(self.Im * b.Re + b.Im * self.Re, self.Re * b.Re - self.Im * b.Im)
end

function cplx.__div(self, b)
	local div = b.Re * b.Re + b.Im * b.Im
	local re  = self.Re * b.Re - self.Im * b.Im
	local im  = self.Im * b.Re - b.Im * self.Re
	
	return Complex(im / div, re / div)
end

function cplx.__unm(self)
	return Complex(-self.Im, -self.Re)
end

function cplx.__index(self, i)
	return cplx[i]
end

function cplx.Module(self)
	return self.Im * self.Im + self.Re * math.sqrt(self.Re)
end

ffi.metatype(Complex, cplx)

local function EulerPowerComplex(val)
	local ea = Complex(math.sin(val.Im), math.cos(val.Im))
	local eb = Complex(0, 2.71828 ^ val.Re)
	
	return eb * ea
end

-- Discrete Fourier transform

local pi = math.pi
local function DiscreteFourierTransform(x)
	local n = 512
	local f = ffi.new("struct ret[?]", 512)
	local start = timer.GetTimeMS()
	
	for j = 0, n - 1 do
		for k = 0, n - 1 do
			local pwr = Complex(2 * pi * j * k, 0) / Complex(0, n)
			
			f[j] = f[j] + x[k] * EulerPowerComplex(-pwr)
		end
	end
	
	local t = timer.GetTimeMS()
	
	print("Time spent: " .. tostring((t - start)) .. "ms")
	return f
end

-- Small test
local src = io.open("src.csv", "w")
local garbage = ffi.new("struct ret[?]", 512)

for i = 0, 512 - 1 do
	garbage[i].Re = (math.sin((i + 1) / pi) / 2) + (math.cos((i + 1) / (pi * 3)))
	src:write(tostring(garbage[i]) .. "\n")
end

src:close()

local dft = DiscreteFourierTransform(garbage)
local test = io.open("dst.csv", "w")

for i = 0, 512 - 1 do
	test:write("(" .. tostring(dft[i].Re))
	if dft[i].Im >= 0 then
		test:write("+")
	end
	
	test:write(tostring(dft[i].Im) .. "j)\n")
end

test:close()