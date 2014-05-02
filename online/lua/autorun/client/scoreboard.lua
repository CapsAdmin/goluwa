function goluwa.scoreboard.OnDraw2D()
	surface.Color(1,1,1,1)
	surface.SetFont("default")
	local i = 0
	for _, ply in pairs(players.GetAll()) do
		if not ply:IsBot() then
			surface.SetTextPos(10, i * 20 + 5)
			surface.DrawText(ply.score_str)
		end
		i = i + 1
	end
end

function goluwa.scoreboard.OnChatAboveHead(ply, str)
	ply.score_str = ply:GetNick() .. ": " .. str
end