commands.Add("bot_activity", function()
	event.Timer("bot_activity", 0.25, 0, function()
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
			for k,v in pairs(clients.GetAll()) do
				if v:IsBot() then
					v:Kick("LOL")
				end
			end
		end

		for _, bot in ipairs(clients.GetAll()) do
			if bot:IsBot() then
				if not bot.do_soemthing or bot.do_soemthing < os.clock() then

					if math.random() > 0.5 then
						local sentence = string.randomwords(math.random(20), math.random())
						chat.ClientSay(bot, sentence)
					end

					bot.do_soemthing = (os.clock() + math.random()*30)
				end
			end
		end
	end)
end)