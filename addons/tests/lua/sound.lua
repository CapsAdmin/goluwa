local SAMPLE_RATE = 44100
local DURATION = 60
local INCREMENT = 1 / SAMPLE_RATE
local SAMPLES = DURATION * SAMPLE_RATE

local t = 0

do
	waveform = {}

	function waveform.GetPitch(offset)
		return 440 * 2 ^ ((offset - 52) / 12)
	end

	function waveform.Saw(offset)
		return (t * waveform.GetPitch(offset))%1
	end

	function waveform.PWM(offset, w)
		w = w or 0.5

		return (t * waveform.GetPitch(offset))%1 > w and 1 or 0
	end

	waveform.Square = waveform.PWM

	function waveform.Sin(offset)
		return math.sin(t * math.pi * 2 * waveform.GetPitch(offset))
	end

	local v
	function waveform.Tri(offset)
		v = (t * waveform.GetPitch(offset))%1

		return v > 0.5 and (-v + 1) or v
	end

	function waveform.Super(func, offset, detune, amount)
		local v = 0
		for i = -amount, amount do
			v = v + func(offset + (i / detune))
		end
		
		return v / amount
	end
end

local function beat(time)
    local t = time * 8
    local w = 0

    if t%1 > 0.9 and t%1 < 0.95 then
        w = w + (math.random() * math.sin(t))
    end

    if t%8 < 0.5 then
        w = w + math.random()
    end

    if (t%4 > 2 and t%4 < 2.6) then
        w = w + waveform.Square(22)
    end

    if (t%4 > 2.6 and t%4 < 3) then
        w = w + waveform.Square(0)
    end
	
    return w
end

local raw = Array("sfInt16", SAMPLES)

for i = 0, SAMPLES do
	raw[i] = beat(t) * 32767
	t = t + INCREMENT
end

local buffer = SoundBuffer("samples", raw.data, SAMPLES, 1, SAMPLE_RATE)

if snd then snd:Stop() end

snd = Sound()
snd:SetBuffer(buffer)
snd:Play()