commands.RunString("mount hl2")

local speaker = {}

local queue = {}

local function calc_job(id, job, play_next_now)
	if job.sound_queue and #job.sound_queue > 0 then
		job.next_sound = job.next_sound or 0

		if play_next_now or job.next_sound < system.GetTime() then

			-- stop any previous sounds
			if job.current_sound then
				job.current_sound:Stop()
			end

			-- remove and get the first sound from the queue
			local data = table.remove(job.sound_queue, 1)

			if data.snd and data.pitch then

				data.snd:SetGain(data.volume)
				data.snd:SetPitch(data.pitch / 255)
				data.snd:Play()

				-- make it so we can hook onto when a sound is played for effects
				event.Call("SpeakerSoundPlayed", job, data.path, data.pitch, data.duration, data.snd)

				-- store the sound so we can stop it before we play the next sound
				job.current_sound = data.snd
			end

			-- store when to play the next sound
			job.next_sound = system.GetTime() + data.duration
		end
	else
		job.sound_queue = nil
		job.next_sound = nil
		if job.current_sound then
			job.current_sound:Stop()
		end
		job.current_sound = nil

		queue[id] = nil
	end
end

event.AddListener("Update", "queue", function()
	for id, job in pairs(queue) do
		calc_job(id, job)
	end
end)

local pause_symbols =
{
	["."] = true,
	["!"] = true,
	["?"] = true,
}


local function add_sound_to_job(id, job, path, pitch, volume, soundlevel, cutoff)
	local sound_queue = job.sound_queue or {}

	if pause_symbols[path] then
		table.insert(
			sound_queue,
			{
				duration = 0.5,
			}
		)
	else
		local snd = audio.CreateSource(path)

		table.insert(
			sound_queue,
			{
				snd = snd,
				pitch = pitch,
				path = path,
				soundlevel = soundlevel,
				volume = volume,

				-- get the sound length of the sound and scale it with the pitch above
				-- the sounds have a little empty space at the end so subtract 0.05 seconds from their time
				duration = (cutoff < 0 and -cutoff) or (snd:GetDuration() * (pitch / 100) - 0.05 - cutoff),
			}
		)
	end

	job.sound_queue = sound_queue
end

-- makes the fairy talk without using a real language
-- it's using sounds from a zelda game which does the same thing
local function play_phrase(id, text, list, pitch, volume, soundlevel, cutoff)
	list = list or METROCOP_VOICE
	pitch = pitch or 100
	volume = volume or 1
	soundlevel = soundlevel or 90


	text = text:lower()
	text = text .. " "

	local job = {}
	local total_duration = 0

	id = id or job

	-- split the sentence up in chunks
	for chunk in (" " .. text .. " ."):gsub("%p", " %1 "):gmatch("(.-)[%s]") do
		if chunk:trim() ~= "" then
			if pause_symbols[chunk] then
				add_sound_to_job(id, job, chunk)
			else
				-- this will use each chunk as random seed to make sure it picks the same sound for each chunk every time
				local crc = crypto.CRC32(chunk)
				local path = "sound/" .. list[1 + crc%#list]

				-- randomize pitch a little, makes it sound less static

				local pitch = pitch

				if type(pitch) == "number" then
					pitch = pitch + math.randomf(-4, 4)
				elseif type(pitch) == "table" then
					pitch = math.randomf(pitch.min or pitch[1], pitch.max or pitch[2])
				else
					pitch = 100 + math.randomf(-4, 4)
				end

				pitch = pitch + (crc%1 == 0 and crc%10 or -crc%10)

				local cutoff = cutoff

				if not cutoff then
					cutoff = (-0.25 * (1 + (#chunk / 10))) / 1.25
				end

				add_sound_to_job(id, job, path, pitch, volume, soundlevel, cutoff)
			end
		end
	end

	queue[id] = job
end

local function stop_speaking(job)
	if ent.current_sound then
		ent.current_sound:Stop()
	end
	ent.sound_queue = {}
	ent.next_sound = 0
end

-- add some voices
local voices = {}

local function add_voices(path, name)
	local tbl = {}

	for k,v in pairs(vfs.Find("sound/" .. path .. "*.wav")) do
		if
			not v:lower():find("pain") and
			not v:lower():find("hurt") and
			not v:lower():find("die") and
			not v:lower():find("death")
		then
			table.insert(tbl, path .. v)
		end
	end

	voices[name] = tbl
end

add_voices("npc/metropolice/vo/", "metrocop")
add_voices("npc/overwatch/radiovoice/", "overwatch")
add_voices("vo/npc/female01/", "female")
add_voices("vo/npc/male01/", "male")
add_voices("vo/npc/alyx/", "alyx")
add_voices("vo/npc/barney/", "barney")
add_voices("vo/npc/vortigaunt/", "vortigaunt")

voices.radio_noise = {}
for i = 1, 15 do
	voices.radio_noise[i] = "ambient/levels/prison/radio_random"..i..".wav"
end

voices.seagull =
{
	"ambient/creatures/seagull_idle1.wav",
	"ambient/creatures/seagull_idle2.wav",
	"ambient/creatures/seagull_idle3.wav",
	"ambient/creatures/seagull_pain1.wav",
	"ambient/creatures/seagull_pain2.wav",
	"ambient/creatures/seagull_pain3.wav",
}

voices.rat =
{
	"ambient/creatures/rats1.wav",
	"ambient/creatures/rats2.wav",
	"ambient/creatures/rats3.wav",
	"ambient/creatures/rats4.wav",

}

voices.pigeon =
{
	"ambient/creatures/pigeon_idle1.wav",
	"ambient/creatures/pigeon_idle2.wav",
	"ambient/creatures/pigeon_idle3.wav",
	"ambient/creatures/pigeon_idle4.wav",

}

voices.flies =
{
	"ambient/creatures/flies1.wav",
	"ambient/creatures/flies2.wav",
	"ambient/creatures/flies3.wav",
	"ambient/creatures/flies4.wav",
	"ambient/creatures/flies5.wav",
}

voices.fast_zombie =
{
	"npc/fast_zombie/gurgle_loop1.wav",
	"npc/fast_zombie/idle1.wav",
	"npc/fast_zombie/idle2.wav",
	"npc/fast_zombie/idle3.wav",
	"npc/fast_zombie/leap1.wav",
	"npc/fast_zombie/wake1.wav",
}

voices.crow =
{
	"npc/crow/alert2.wav",
	"npc/crow/alert3.wav",
	"npc/crow/pain1.wav",
	"npc/crow/pain2.wav",
}

voices.big_robot =
{
	"npc/dog/dog_alarmed1.wav",
	"npc/dog/dog_alarmed3.wav",
	"npc/dog/dog_angry1.wav",
	"npc/dog/dog_angry2.wav",
	"npc/dog/dog_angry3.wav",
	"npc/dog/dog_playfull1.wav",
	"npc/dog/dog_playfull2.wav",
	"npc/dog/dog_playfull3.wav",
	"npc/dog/dog_playfull4.wav",
	"npc/dog/dog_playfull5.wav",
}

voices.bird = {}
for i = 1, 7 do voices.bird[i] = "ambient/levels/coast/coastbird"..i..".wav" end

voices.robot = {}
for i = 1, 6 do voices.robot[i] = "ambient/levels/canals/headcrab_canister_ambient"..i..".wav" end

voices.terminal = {}
for i = 1, 4 do voices.terminal[i] = "ambient/machines/combine_terminal_idle"..i..".wav" end

voices.bird_swamp = {}
for i = 1, 6 do voices.bird_swamp[i] = "ambient/levels/canals/swamp_bird"..i..".wav" end


voices.bird_coast = {}
for i = 1, 7 do voices.bird_coast[i] = "ambient/levels/coast/coastbird"..i..".wav" end

voices.servo = {}
for i = 1, 12 do
	if
		i ~= 4 and
		i ~= 9 and
		i ~= 11
	then
		table.insert(voices.servo,  "npc/dog/dog_servo"..i..".wav" )
	end
end

voices.zombie = {}
for i = 1, 14 do voices.zombie[i] = "npc/zombie/zombie_voice_idle"..i..".wav" end

voices.cat = {}
for i = 1, 3 do voices.cat[i] = "items/halloween/cat0"..i..".wav" end

_G.speaker = {
	PlayPhrase = function(ent, text, list, ...)
		if type(list) == "string" then
			list = voices[list]
		end
		return play_phrase(ent, text, list, ...)
	end,
	StopSpeaking = stop_speaking,
	GetVoices = function() return voices end,
}

_G.speaker.PlayPhrase({}, "twsetes tsejtijs etijset wok w koww ow owo wo", "metrocop")