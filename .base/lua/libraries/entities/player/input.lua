-- networked input

local META = (...) or utilities.FindMetaTable("player")

local function add_event(name, check)	
	input.SetupAccessorFunctions(META, name)
	
	if CLIENT then
		event.AddListener(name .. "Input", "player_" .. name .. "_event", function(key, press)
			local ply = players.GetLocalPlayer()
			
			if ply:IsValid() then						
				if check and not check[key] then return end
				
				input.CallOnTable(ply, name, key, press, nil, nil, true)
				message.Send("Player" .. name .. "Event", key, press)
				
				return event.Call("Player" .. name .. "Event", ply, key, press)
			end
		end, print)
	end
	
	if SERVER then
		message.AddListener("Player" .. name .. "Event", function(ply, key, press)
			if ply:IsValid() then
				if check and not check[key] then return end

				input.CallOnTable(ply, name, key, press, nil, nil, true)
			
				event.Call("Player" .. name .. "Event", ply, key, press)
			end
		end, print)
	end
end
		
add_event("Key")
add_event("Char")