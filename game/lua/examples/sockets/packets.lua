if CLIENT then
	packet.AddListener("foEobar", function(buffer)
		print(buffer:ReadString())
		print(("%x"):format(buffer:ReadLong()))
	end)
end

if SERVER then
	local buffer = Buffer()
	buffer:WriteString("LOL")
	buffer:WriteLong(0xDEADBEEF)

	packet.Broadcast("foEobar", buffer)
end