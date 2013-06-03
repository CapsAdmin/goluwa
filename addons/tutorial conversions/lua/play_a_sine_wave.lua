local SAMPLES = 44100
local SAMPLE_RATE = 44100
local AMPLITUDE = 30000

local raw = Array("Int16", SAMPLES)

local TWO_PI = math.pi * 2
local increment = 440/44100

local x = 0

for i = 0, SAMPLES do
	raw[i] = AMPLITUDE * math.sin(x * TWO_PI)
	x = x - increment
end

local buffer = SoundBuffer("samples", raw.data, SAMPLES, 1, SAMPLE_RATE)

local snd = Sound()
snd:SetBuffer(buffer)
snd:SetLoop(true)
snd:Play()