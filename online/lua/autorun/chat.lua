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
		var = "disconnected"
	elseif not network.IsConnected() then
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
	
	logf("%s%s: %s\n", chat.GetTimeStamp(), var, str)
end

if CLIENT then	
	message.AddListener("say", function(ply, str, seed)
		if event.Call("PlayerChat", ply, str, seed) ~= false then
			chat.Append(ply, str)
		end
	end)
	
	function chat.Say(str)
		str = tostring(str)		
		message.Send("say", str)
	end	
	
	chat.panel = NULL
	
	function chat.IsVisible()
		return chat.panel:IsValid()
	end
		
	function chat.SetInputText(str)
		if not chat.IsVisible() then return end
		chat.panel:SetText(str)
	end
	
	function chat.GetInputText()
		if not chat.IsVisible() then return "" end
		return chat.panel:GetText()
	end	
	
	function chat.GetInputPos()
		if not chat.IsVisible() then return 0, 0 end
		return chat.panel:GetPos()
	end
		
	--[[event.AddListener("ConsoleLineEntered", "chat", function(line)
		if not network.IsStarted() then return end
	
		if not console.RunString(line, true) then
			chat.Say(line)
		end
		
		return false
	end)]]
	
	if aahh then

		local i = 1
		local history = {}
		local visible
		local last_history
				
		console.AddCommand("showchat", function()
		
			local panel =  chat.panel
			
			local tab_str
			local tab_autocomplete
			
			local last_str
			local found_autocomplete = {}
			
			local pause_autocomplete
			
			if not visible then				
				panel = aahh.Create("text_input")
					panel:SetPos(Vec2(50, Vec2(render.GetScreenSize()).h - 100))
					panel:SetSize(Vec2(512, 16))
					panel:MakeActivePanel()
					panel:SetMultiline(true)
					
					panel.OnPreKeyInput = function(self, key)									
						local str = self:GetText()
						
						local ctrl = input.IsKeyDown("left_control") or input.IsKeyDown("right_control")
						
						if ctrl or str == "" or str == last_history then
							local browse = false
							
							if key == "up" then
								i = math.clamp(i + 1, 1, #history)
								browse = true
							elseif key == "down" then
								i = math.clamp(i - 1, 1, #history)
								browse = true
							end
							
							local found = history[i]
							if browse and found then
								panel:SetText(found)
								panel:SetCaretPos(Vec2(#found, 0))
								last_history = found
							end
						end
						 
						if last_str and #last_str > #str and key ~= "tab" then
							tab_str = nil
							tab_autocomplete = nil
							pause_autocomplete = false
						end

						if not pause_autocomplete then 
							found_autocomplete = autocomplete.Search(tab_str or str, tab_autocomplete)
							
							if #found_autocomplete == 0 then 
								pause_autocomplete = str 
							end
						else
							if #pause_autocomplete > #str then
								pause_autocomplete = false
							end
						end
						
						if key == "tab" then
							autocomplete.ScrollFound(tab_autocomplete or found_autocomplete, input.IsKeyDown("left_shift") and -1 or 1)
							
							if #found_autocomplete > 0 then 
								panel:SetText(found_autocomplete[1])
								if not tab_str then
									tab_str = str
									tab_autocomplete = found_autocomplete
								end
								last_str = str
								return false 
							end
							
							local str = event.Call("ChatTab", str)
								
							if str then 
								panel:SetText(str)
								
								return false	
							end
						end
						
						if key == "enter" and not ctrl or key == "escape" then
						
							if key ~= "escape" then
								i = 0
								if #str > 0 then
									chat.Say(str)
									if history[1] ~= str then
										table.insert(history, 1, str)
									end
								end
							end
							
							window.ShowCursor(false)
							visible = false
							
							panel:Remove()
							
							event.Call("ChatTextChanged", "")
							
							return
						end	
						
						event.Call("ChatTextChanged", str)
						last_str = str
					end
					
					local suppress = true -- stupid
					event.Delay(0.1, function() suppress = false end) -- stupid
					
					panel.OnTextChanged = function(self, str)
						if suppress then -- stupid
							suppress = false -- stupid
							self:SetText("") -- stupid
							suppress = true -- stupid
						end
						event.Call("ChatTextChanged", str)
						
						self:SetPos(Vec2(50, Vec2(render.GetScreenSize()).h - 100))
						self:SizeToContents()
					end
					
					panel.OnPostDraw = function()
						if #found_autocomplete > 0 then
							autocomplete.DrawFound(0, panel:GetHeight(), found_autocomplete, nil, 2) 
						end
					end
					
				window.ShowCursor(true)
				visible = true
			end
			
			chat.panel = panel
		end)
		
		input.Bind("y", "showchat")
	end
end

local seed = 0

function chat.PlayerSay(ply, str, skip_log)
	if event.Call("PlayerChat", ply, str, seed) ~= false then
		if skip_log then chat.Append(ply, str) end
		if SERVER then message.Broadcast("say", ply, str, seed) seed = seed + 1 end
	end
end

if SERVER then

	message.AddListener("say", function(ply, str)
		chat.PlayerSay(ply, str)
	end)

	function chat.Say(str)
		str = tostring(str)		
		message.Broadcast("say", NULL, str)
		chat.Append(NULL, str)
	end
end