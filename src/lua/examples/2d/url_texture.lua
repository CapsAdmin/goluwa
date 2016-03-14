local tex = Texture("http://www.google.com/images/icons/ui/doodle_plus/doodle_plus_google_logo_on_grey.gif")

event.AddListener("Draw2D", 1, function()
	surface.SetColor(1,1,1,1)
	surface.SetTexture(tex)
	surface.DrawRect(64, 64, tex.w, tex.h)
end)
