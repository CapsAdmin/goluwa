-- networked input

local META = (...) or prototype.GetRegistered("client")

local function add_event(name, check)
	input.SetupAccessorFunctions(META, name)

	if CLIENT then
		event.AddListener(name .. "Input", "client_" .. name .. "_event", function(key, press)
			local client = clients.GetLocalClient()

			if client:IsValid() then
				if check and not check[key] then return end

				input.CallOnTable(client, name, key, press, nil, nil, true)
				message.Send("Client" .. name .. "Input", key, press)

				return event.Call("Client" .. name .. "Input", client, key, press)
			end
		end, {on_error = system.OnError})
	end

	if SERVER then
		message.AddListener("Client" .. name .. "Input", function(client, key, press)
			if client:IsValid() then
				if check and not check[key] then return end

				input.CallOnTable(client, name, key, press, nil, nil, true)

				event.Call("Client" .. name .. "Input", client, key, press)
			end
		end, {on_error = system.OnError})
	end
end

add_event("Key")
add_event("Char")
add_event("Mouse")

prototype.UpdateObjects(META)