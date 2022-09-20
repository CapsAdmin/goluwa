local eeg_power = {}
local esense = {attention = 50, meditation = 50}
local W, H = render2d.GetSize()
local last_x = 0
local last_y = 0
local fb = render.CreateFrameBuffer(Vec2(W, H))
local tex = render.CreateTexture("2d")
tex:SetSize(Vec2(W, H))
tex:SetInternalFormat("rgb32f")
tex:SetupStorage()
fb:SetTexture(1, tex)
-- last argument stores this socket with the specified id and destroys previous socket with that id if called again
local client = sockets.CreateClient("tcp", "localhost", 13854, "neurosky")

local function update_rt(eeg)
	fb:Begin()
	render.Start2D(0, 0, W, H)
	render2d.SetTexture()
	render2d.SetColor(1, 1, 1, 1)
	local x, y = system.GetElapsedTime() * 100 % W, H / 2 + eeg / 10
	gfx.DrawLine(x, y, last_x, last_y)
	last_x = x
	last_y = y

	if x < 5 then fb:Clear() end

	render.End2D()
	fb:End()
end

function goluwa.PreDrawGUI()
	render2d.SetTexture(fb:GetTexture(1))
	render2d.DrawRect(0, 0, W, H)
	gfx.SetFont()
	render2d.SetColor(1, 1, 1, 1)
	local x, y = 5, 5

	for k, v in pairs(eeg_power) do
		gfx.SetTextPosition(x, y)
		gfx.DrawText(k .. " = " .. v)
		y = y + 20
	end
end

client:Send(
	serializer.Encode(
		"json",
		{
			appName = "NodeThinkGear",
			appKey = "0fc4141b4b45c675cc8d3a765b8d71c5bde9390",
			format = "Json",
			enableRawOutput = true,
		}
	)
)

function client:OnReceive(data)
	data = serializer.Decode("json", data)

	if data.rawEeg then
		update_rt(data.rawEeg)
	elseif data.eegPower then
		eeg_power = data.eegPower
	elseif data.eSense then
		esense = data.eSense
	else
		table.print(data)
	end
end