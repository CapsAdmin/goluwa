chat = {}

local function getnick(ply)
	return ply:IsValid() and ply:GetNick() or "server"
end

local enabled = console.CreateVariable("chat_timestamps", true)

function chat.AddTimeStamp(tbl)
	if not enabled:Get() then return end
	
	tbl = tbl or {}
	
	local time = os.date("*t")
	
	table.insert(tbl, 1, " - ")
	table.insert(tbl, 1, Color(255, 255, 255))
	table.insert(tbl, 1, ("%.2d:%.2d"):format(time.hour, time.min))
	table.insert(tbl, 1, Color(118, 170, 217))

	return tbl
end

function chat.GetTimeStamp()
	local time = os.date("*t")

	return ("%.2d:%.2d - "):format(time.hour, time.min)
end

function chat.Append(var, str)

	if not str then
		str = var
		var = NULL
	end

	local ply = NULL
	
	if typex(var) == "player" then
		ply = var
		var = getnick(var)
	elseif typex(var) == "null" then
		var = "server"
	else
		var = tostring(var)
	end	

	if CLIENT then
		local tbl = chat.AddTimeStamp()
		
		if ply:IsValid() then
			table.insert(tbl, ply:GetUniqueColor())
		end
		
		table.insert(tbl, var)
		table.insert(tbl, Color(255, 255, 255, 255))
		table.insert(tbl, ": ")
		table.insert(tbl, str)
		chathud.AddText(unpack(tbl))
	end
	
	logf("%s%s: %s", chat.GetTimeStamp(), var, str)
end

if CLIENT then	
	message.AddListener("say", function(ply, str)
		if event.Call("OnPlayerChat", ply, str) ~= false then
			chat.Append(ply, str)
		end
	end)
	
	function chat.Say(str)
		str = tostring(str)		
		message.Send("say", str)
		if event.Call("OnPlayerChat", players.GetLocalPlayer(), str) ~= false then
			chat.Append(players.GetLocalPlayer(), str)
		end
	end	
		
	event.AddListener("OnLineEntered", "chat", function(line)
		if not network.IsStarted() then return end
	
		if not console.RunString(line, true) then
			chat.Say(line)
		end
		
		return false
	end)
	
	if aahh then

		local showing = false
		local i = 1
		local history = {}
		local panel = NULL
		
		console.AddCommand("showchat", function()
			
			if not showing then				
				panel = aahh.Create("text_input")
					panel:SetPos(Vec2(50, Vec2(render.GetScreenSize()).h - 100))
					panel:SetSize(Vec2(512, 16))
					panel:MakeActivePanel()
					panel:SetMultiline(false)
					
					panel.OnUnhandledKey = function(_, key)	
						local browse = false
						
						if key == "up" then
							i = math.clamp(i + 1, 1, #history)
							browse = true
						elseif key == "down" then
							i = math.clamp(i - 1, 1, #history)
							browse = true
						end
						
						if browse and history[i] then
							panel:SetText(history[i])
							panel:SetCaretPos(Vec2(#history[i], 0))
						end

						if key == "escape" then
							panel:OnEnter("")
						end
					end
					
					local suppress = true -- stupid
					timer.Delay(0.1, function() suppress = false end) -- stupid
					
					panel.OnTextChanged = function(self, str)
						if suppress then -- stupid
							suppress = false -- stupid
							self:SetText("") -- stupid
							suppress = true -- stupid
						end
						event.Call("OnChatTextChanged", str)
					end
					
					panel.OnEnter = function(_, str)
						i = 0
						if #str > 0 then
							chat.Say(str)
							if history[1] ~= str then
								table.insert(history, 1, str)
							end
						end
						
						window.ShowCursor(false)
						showing = false
						
						panel:Remove()
						
						event.Call("OnChatTextChanged", "")
					end
				
				window.ShowCursor(true)
				showing = true
			end
		end)
		
		input.Bind("y", "showchat")
	end
end

if SERVER then
	message.AddListener("say", function(ply, str)
		if event.Call("OnPlayerChat", ply, str) ~= false then
			chat.Append(ply, str)
			message.Send("say", message.PlayerFilter():AddAllExcept(ply), ply, str)
		end
	end)

	function chat.Say(str)
		str = tostring(str)		
		message.Broadcast("say", NULL, str)
		chat.Append(NULL, str)
	end
end