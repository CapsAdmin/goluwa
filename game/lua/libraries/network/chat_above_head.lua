local META = (...) or prototype.GetRegistered("client")

function META:GetChatAboveHead()
	return self.coh_str or ""
end

if CLIENT then
	function META:SetChatAboveHead(str, send)
		self.coh_str = str

		if not network.IsConnected() then return end

		if send and clients.GetLocalClient() == self then
			message.Send("coh", str)
		end

		event.Call("ChatAboveHead", self, str)
	end

	event.AddListener("ChatTextChanged", "coh", function(str)
		if not network.IsConnected() then return end

		message.Send("coh", str)
		clients.GetLocalClient():SetChatAboveHead(str)
	end)

	message.AddListener("coh", function(client, str)
		client:SetChatAboveHead(str)
	end)
end

if SERVER then
	function META:SetChatAboveHead(str)
		self.coh_str = str
		message.Send("coh", nil, self, str)
	end

	message.AddListener("coh", function(client, str)
		local filter = clients.CreateFilter()
		filter:AddAllExcept(client)
		message.Send("coh", filter, client, str)
	end)
end

prototype.UpdateObjects(META)