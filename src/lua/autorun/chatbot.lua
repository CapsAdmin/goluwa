local gender = "male"
local name = "Alan"

local question = "what's up?"

sockets.Request({
	url = "http://www.a-i.com/alan1/webface1_ctrl.asp?gender="..gender.."&name="..name.."&question="..question.."",
	callback = function(data)
		local answer =  data.content:match("<option>answer = (.-)<option>")
		ALAN_COOKIE = ALAN_COOKIE or data.header["set-cookie"]
		print(answer)
	end,
	method = "GET",
	header = {
		Cookie = ALAN_COOKIE,
	},
})