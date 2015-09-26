local size = 8
local max = 16
local active_probes = {}
local list = {}

event.AddListener("Update", "probe", function()
	local x,y,z = render.camera_3d:GetPosition():Unpack()
	x = math.round(x / size) * size
	y = math.round(y / size) * size
	z = math.round(z / size) * size

	active_probes[x] = active_probes[x] or {}
	active_probes[x][y] = active_probes[x][y] or {}
	active_probes[x][y][z] = active_probes[x][y][z] or {}

	local data = active_probes[x][y][z]

	if not data.probe then
		local probe

		if #list > max then
			local data = table.remove(list)
			active_probes[data.key[1]][data.key[2]][data.key[3]] = nil
			probe = data.probe
		else
			probe = render.CreateEnvironmentProbe()
		end

		probe:SetPosition(Vec3(x,y,z))
		probe:Capture()
		data.probe = probe

		table.insert(list, {probe = probe, key = {x,y,z}})
	end

	data.probe.tex.probe = data.probe
	render.environment_probe_texture = data.probe.tex
end)
--_G.active_probes = active_probes