local SAMPLE_RATE = 44100
local DURATION = 5
local FREQUENCY = 440
local INCREMENT = FREQUENCY / SAMPLE_RATE
local SAMPLES = DURATION * SAMPLE_RATE

local raw = Array("sfInt16", SAMPLES)
local t = 0

for i = 0, SAMPLES do
	raw[i] = math.sin(math.pow(2, t % 1) % 1 * math.pi * 2) * 32767
	t = t + INCREMENT
end

local buffer = SoundBuffer("samples", raw.data, SAMPLES, 1, SAMPLE_RATE)

if snd then snd:Stop() end

snd = Sound()
snd:SetBuffer(buffer)
snd:Play()

utilities.MonitorFileInclude()
