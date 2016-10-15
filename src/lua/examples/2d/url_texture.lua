local tex = render.CreateTextureFromPath("http://www.google.com/images/icons/ui/doodle_plus/doodle_plus_google_logo_on_grey.gif")

event.AddListener("PreDrawGUI", "lol", function()
	surface.SetColor(1,1,1,1)
	surface.SetTexture(tex)
	surface.DrawRect(64, 64, tex:GetSize():Unpack())
end)
