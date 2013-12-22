window.Open()

vfs.ReadAsync("lol.ttf", function(data)
	print(utilities.FormatFileSize(#data))
end, 5)

local tex = Image("http://www.google.com/images/icons/ui/doodle_plus/doodle_plus_google_logo_on_grey.gif")

event.AddListener("OnDraw2D", 1, function()
	surface.SetTexture(tex)
	surface.DrawRect(64, 64, tex.w, tex.h)
end)
