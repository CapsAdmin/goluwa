local META = (...) or prototype.GetRegistered("client")

-- send lua
if CLIENT then
	message.AddListener("sendlua", function(code, env)
		commands.RunLua(code, true, "sendlua")
	end)
end

if SERVER then
	function META:SendLua(code)
		message.Send("sendlua", self, code, env)
	end

	function META:Cexec(str)
		self:SendLua("commands.RunString('"..str.."')")
	end
end

prototype.UpdateObjects(META)