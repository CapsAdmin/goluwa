--Based off 'Webserver'

--TODO: Test in multiplayer - Create a menu to set your name - Create a data saving system, I'll finish this later on my PC - neither windows with OpenGL or AAHH related stuff can run on my laptop.. I dont know why
--Note: This test is just so I can learn more about this engine.

local remove_player = true
luasocket.debug = true

server = utilities.RemoveOldObject(luasocket.Server())

local function FindPlayer(id)
	for k,v in pairs(players.GetAll()) do
		if v:GetUniqueID() and type(id) == "number" and v:GetUniqueID() == id then
			return v
		end
		if v:GetNick() and type(id) == "string" and v:GetNick() == id then
			return v
		end
	end
	return nil
end

function server:NotFound(dir)
	print("Server not found!")
	return "Server not found!"
end

function server:OnClientConnected(client)
	if not client then return end
	local plstr = "-"
	--local pl = Entity("player")
	local uid = #players.GetAll()+1
	local pl = players.Create(uid)
	client:Send("Your UniqueID is "..pl:GetUniqueID().."\nRetrieving player entity from 'FindPlayer'\n")
	local me = FindPlayer(pl:GetNick())
	client:Send("Found you by name  "..pl:GetNick().."("..tostring(pl:GetUniqueID())..")\n")
	local ume = FindPlayer(pl:GetUniqueID())
	client:Send("Found you by UID  "..pl:GetNick().."("..tostring(pl:GetUniqueID())..")\n")
	client:Send("Changing position of player")
	pl:SetPos(Vec3(0,0,0))
	client:Send("Player Position changed to "..tostring(pl:GetPos()).."\nChecking player nvar object.\n")
	if pl.nv then
		client:Send("NVar object found for player!")
	else
		client:Send("NVar object not found :(")
	end
	for k,v in pairs(players.GetAll()) do 
		plstr = plstr.." -"..v:GetNick().."("..v:GetUniqueID()..")"
	end
	client:Send("Active Players: "..plstr.." Player Count: "..tostring(#players.GetAll()))
	if remove_player then
		if pl:IsValid() then
			client:Send("Player valid... removing...")
			pl:Remove(true)
			if pl:IsValid() then
				client:Send("Player still valid...")
			else
				client:Send("Player removed properly...")
			end
			pl = nil
		else
			client:Send("Player not valid ")
		end
	end
	
	
--	function client:OnReceive(data, client)
--	end
	client:CloseWhenDoneSending(true)

end   

server:Host("*", 1234)

os.execute("explorer http://localhost:1234")