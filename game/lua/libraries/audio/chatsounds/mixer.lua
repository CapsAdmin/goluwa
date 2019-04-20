local ffi = require("ffi")
local source = audio.CreateSource()

local frame_size = 0.5
local queue_length = 10
local max_volume = 0xFF
local sample_rate = 44100

local buffer_size = math.ceil(frame_size*sample_rate*2)

for i = 0, 4 do
    local int, frac = math.modf((buffer_size + i)/4)
    if frac == 0 then
        buffer_size = buffer_size + i
        break
    end
end

local sounds = {}

do
    local META = prototype.CreateTemplate("sound")

    META:GetSet("Volume", 1)
    META:GetSet("Pitch", 1)

    function META:LoadPath(path)
        resource.Download(path):Then(function(path)
            local file = vfs.Open(path)
            local data, length, info = audio.Decode(file, path)
table.print(info)
print(data, length)
            self.Buffer = data
            self.BufferSize = length
            self.SampleLength = info.frames
        end)
    end

    function META:Initialize()
        self.SamplePosition = 0
    end

    META:Register()

    local function Sound(path)
        local self = META:CreateObject()

        self:Initialize()
        self:LoadPath(path)

        return self
    end

    table.insert(sounds, Sound("https://raw.githubusercontent.com/PAC3-Server/chatsounds-valve-games/master/hl2/robert_guillaume/-now%20lets%20see%20the%20last%20time%20i%20s-206290379.ogg"))
end

local time = 0
local function render(buf, len)
    for i = 0, len-1, 2 do
        local l = buf[i+0]
        local r = buf[i+1]

        for _, sound in ipairs(sounds) do
            if sound.Buffer then
                l = l + sound.Buffer[math.ceil(sound.SamplePosition)]
                r = r + sound.Buffer[math.ceil(sound.SamplePosition)]

                sound.SamplePosition = sound.SamplePosition + 1

                print(sound.SamplePosition)

                if sound.SamplePosition >= sound.SampleLength then
                    break
                end
            end
        end

        --l = math.sin((time/sample_rate)*440)
        --r = math.sin((time/sample_rate)*440)

        buf[i+0] = l--*max_volume
        buf[i+1] = r--*max_volume

        time = time + 1
    end
end

local function process(b)
    local buf, len = b:GetData()

    len = len or buffer_size
    buf = buf or ffi.new("int16_t[?]", len)

    for i = 0, len-1 do
        buf[i] = 0
    end

    render(buf, len)
    b:SetData(buf, len)
    source:PushBuffer(b)
end

for i = 1, queue_length do
    local b = audio.CreateBuffer()
    b:SetFormat(source:GetBufferFormat())

    process(b)
end

source:Play()

event.RemoveTimer("chatsounds_mixer")
do return end
event.Timer("chatsounds_mixer", frame_size/2, 0, function()
    if source:GetBuffersProcessed() > 0 then
        local b = source:PopBuffer()

        process(b)
    end

    if not source:IsPlaying() then
        source:Play()
    end
end)

source:Play()