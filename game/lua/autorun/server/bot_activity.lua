commands.Add("bot_activity", function()
	timer.Repeat(
		"bot_activity",
		0.25,
		0,
		function()
			if math.random() > 0.99 then
				local bot = table.random(clients.GetAll())

				if bot and bot:IsBot() then
					bot:Kick(string.randomwords(2, math.random()))
				end
			end

			if math.random() > 0.9 and #clients.GetAll() < 32 then
				clients.CreateBot()
			end

			if math.random() > 0.999 then
				for k, v in pairs(clients.GetAll()) do
					if v:IsBot() then v:Kick("LOL") end
				end
			end

			for _, bot in ipairs(clients.GetAll()) do
				if bot:IsBot() then
					if not bot.do_soemthing or bot.do_soemthing < os.clock() then
						if math.random() > 0.5 then
							local sentence = string.randomwords(math.random(20), math.random())
							chat.ClientSay(bot, sentence)
						end

						bot.do_soemthing = (os.clock() + math.random() * 30)
					end
				end
			end
		end
	)
end)

BEEF = clients.CreateBot("DEADBEEF", "robots", "0xDEADBEEF")
BEEF:AddEvent("ClientEntered")

function BEEF:OnClientEntered(client)
	chat.ClientSay(self, "hi " .. client:GetNick())
end

BABE = clients.CreateBot("CAFEBABE", "robots", "0xCAFEBABE")
BABE:AddEvent("ClientChat")

function BABE:OnClientChat(client, str)
	if client ~= self and math.random() > 0.75 or str:lower():find("cafebabe") then
		timer.Delay(math.random() * 3, function()
			chat.ClientSay(
				self,
				client:GetNick() .. ", " .. string.randomwords(math.random(20), math.random())
			)
		end)
	end
end