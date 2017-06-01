local bot = clients.Create("alan_chatbot", true)
bot:SetNick("Alan")
bot.gender = "male"

function bot:Ask(question, cb, noprint)
	self.cookie = self.cookie or vfs.Read("data/alan_cookie")

	sockets.Request({
		url = "http://www.a-i.com/alan1/webface1_ctrl.asp?gender="..self.gender.."&name="..self:GetNick().."&question="..question.."",
		callback = function(data)
			local answer =  data.content:match("<option>answer = (.-)<option>")

			answer = answer:gsub("notreallyanemailaddress", clients.GetLocalClient():GetNick())
			answer = answer:gsub("notreallyalastname ", "")

			if answer then
				if not self.cookie then
					self.cookie = data.header["set-cookie"]
					vfs.Write("data/alan_cookie", self.cookie)
				end
				if not noprint then
					chat.ClientSay(bot, answer)
				end
				if cb then cb(answer) end
			end
		end,
		method = "GET",
		timeout = 5,
		header = {
			Cookie = self.cookie,
		},
	})
end

function bot:OnClientChat(client, str)
	if network.IsConnected() then self:Remove() return end
	if client == clients.GetLocalClient() then
		self:Ask(str)
	end
end

bot:AddEvent("ClientChat")

do -- not so elegant login
	local username = "notreallyanemailaddress@goluwa.com"
	local password = "password"


	bot:Ask("hi", function()
		bot:Ask("my username is " .. username, function()
			bot:Ask(password, nil, true)
		end, true)
	end, true)
end