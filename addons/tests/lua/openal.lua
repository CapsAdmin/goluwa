
al.debug = true

local device = alc.OpenDevice(nil)

-- needed to provide debugging info for alc
alc.device = device 
alc.debug = true

local context = alc.CreateContext(device, nil)
alc.MakeContextCurrent(context)

al.Listenerfv(e.AL_POSITION, ffi.new("float[3]",0, 0, 0))
al.Listenerfv(e.AL_VELOCITY, ffi.new("float[3]",0, 0, 0))
al.Listenerfv(e.AL_ORIENTATION, ffi.new("float[3]", 0, 0, -1))

local source = al.GenSource()

al.Sourcef(source, e.AL_PITCH, 1)
al.Sourcef(source, e.AL_GAIN, 1)
al.Source3f(source, e.AL_POSITION, 0, 0, 0)
al.Source3f(source, e.AL_VELOCITY, 0, 0, 0)
al.Sourcei(source, e.AL_LOOPING, e.AL_FALSE)

local buffer = al.GenBuffer()

local size = 2 ^ 16
local data = ffi.new("unsigned char[?]", size)

for i = 1, size do
	data[i-1] = math.random(255)
end

al.BufferData(buffer, e.AL_FORMAT_MONO8, data, size, 1024)
al.Sourcei(source, e.AL_BUFFER, buffer)

al.SourcePlay(source)

timer.Create("um", 0,0,function()
	local offset = ffi.new("int[1]")
	al.GetSourcei(source, e.AL_BYTE_OFFSET, offset)	
	offset = offset[0]
end)

LOL_SOURCE = source