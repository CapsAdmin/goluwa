local tex = render.CreateTextureFromPath("http://www.google.com/images/icons/ui/doodle_plus/doodle_plus_google_logo_on_grey.gif")

function goluwa.PreDrawGUI()
	render2d.SetColor(1,1,1,1)
	render2d.SetTexture(tex)
	render2d.DrawRect(64, 64, tex:GetSize():Unpack())
end
