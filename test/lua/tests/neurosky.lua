local eeg_power = {}
local esense = {attention = 50, meditation = 50}

local W, H = surface.GetSize()

local last_x = 0
local last_y = 0

local fb = render.CreateFrameBuffer(W, H, {
	attach = "color1",
	texture_format = {
		internal_format = "RGB32F",
	}
})

-- last argument stores this socket with the specified id and destroys previous socket with that id if called again
local client = sockets.CreateClient("tcp", "localhost", 13854, "neurosky") 

local function update_rt(eeg)
	fb:Begin()
		surface.Start(0, 0, W, H)
			surface.SetWhiteTexture()
			surface.SetColor(1, 1, 1, 1)
			
			local x, y = system.GetTime() * 100 % W, H / 2 + eeg / 10
			
			surface.DrawLine(x, y, last_x, last_y)
			
			last_x = x
			last_y = y
			
			if x < 5 then 
				fb:Clear() 
			end
			
		surface.End()
	fb:End()
end

event.AddListener("DrawHUD", "mindwave", function()
	surface.SetTexture(fb:GetTexture())
	surface.DrawRect(0,0, W,H)
	
	surface.SetFont("default")
	surface.SetColor(1,1,1,1)
		
	local x, y = 5, 5
	
	for k,v in pairs(eeg_power) do
		surface.SetTextPosition(x, y)
		surface.DrawText(k .. " = " .. v)
		y = y + 20
	end
end)

client:Send(serializer.Encode("json", {
	appName = "NodeThinkGear", 
	appKey = "0fc4141b4b45c675cc8d3a765b8d71c5bde9390", 
	format = "Json", 
	enableRawOutput = true
}))

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