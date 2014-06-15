local META = (...) or metatable.Get("client")

-- send lua
if CLIENT then
	message.AddListener("sendlua", function(code, env)
		local data = easylua.RunLua(me, code, env or "server")
		if data.error then
			print(data.error)
		end
	end)
end

if SERVER then
	function META:SendLua(code)
		message.Send("sendlua", self, code, env)
	end
	
	function META:Cexec(str)
		self:SendLua("console.RunString('"..str.."')")
	end
end