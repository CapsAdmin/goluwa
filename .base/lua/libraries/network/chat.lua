local chat = _G.chat or {}

local function getnick(client)
	return client:IsValid() and client:GetNick() or "server"
end

local enabled = console.CreateVariable("chat_timestamps", true)

function chat.AddTimeStamp(tbl)
	if not enabled:Get() then return {} end
	
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

	local client = NULL
	
	if typex(var) == "client" then
		client = var
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
		
		if client:IsValid() then
			table.insert(tbl, client:GetUniqueColor())
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
	message.AddListener("say", function(client, str, seed)
		if event.Call("ClientChat", client, str, seed) ~= false then
			chat.Append(client, str)
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
	

	local i = 1
	local history = {}
	local visible
	local last_history
	
	-- this depends on "aahh" which is an addon, which may as well be a part of goluwa
 	-- TODO!!
			
	console.AddCommand("showchat", function()
	
		local panel =  chat.panel
		local found_autocomplete = {}
		
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
					 
					local scroll = 0
					 
					if key == "tab" then
						scroll = input.IsKeyDown("left_shift") and -1 or 1
					end
					
					found_autocomplete = autocomplete.Query("chatsounds", str, scroll)
					
					if key == "tab" and found_autocomplete then
						panel:SetText(found_autocomplete[1])
						return false
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
					if found_autocomplete and #found_autocomplete > 0 then
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

local seed = 0

function chat.ClientSay(client, str, skip_log)
	if event.Call("ClientChat", client, str, seed) ~= false then
		if skip_log then chat.Append(client, str) end
		if SERVER then message.Broadcast("say", client, str, seed) seed = seed + 1 end
	end
end

if SERVER then

	message.AddListener("say", function(client, str)
		chat.ClientSay(client, str)
	end)

	function chat.Say(str)
		str = tostring(str)		
		message.Broadcast("say", NULL, str)
		chat.Append(NULL, str)
	end
end

return chat