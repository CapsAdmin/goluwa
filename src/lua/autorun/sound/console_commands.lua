local source = NULL

commands.Add("play=arg_line", function(path)
	if source:IsValid() then source:Remove() end
	source = audio.CreateSource(path)
	source:Play()
end)

commands.Add("stopsounds", function()
	audio.Panic()
end)