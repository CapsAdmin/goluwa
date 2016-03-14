local META = (...) or prototype.GetRegistered("markup")

function META:Test()
	self:AddString("Hello markup test!\n\n有一些中國\nそして、いくつかの日本の\nكيف حول بعض عربية")

	self:AddString[[


markup todo:
caret real_x should prioritise pixel width
y axis caret movement when the text is being wrapped
divide this up in cells (new object?)
proper tag stack
the ability to edit (remove and copy) custom tags that have a size (like textures)
alignment tags
	]]

	local small_font = "markup_small"
	surface.CreateFont(small_font, {size = 8, read_speed = 100})

	self:AddFont(small_font)
	self:AddString("\nhere's some text in chinese:\n我寫了這個在谷歌翻譯，所以我可以測試我的標記語言使用Unicode正確。它似乎做工精細！\n")	self:AddString("some normal string again\n")
	self:AddString("and another one\n")

	self:AddFont("default")
	self:AddString("back to normal!\n\n")

	local small_font = "markup_small4"
	surface.CreateFont(small_font, {size = 14, read_speed = 100, monospace = true})

	self:AddFont(small_font)
	self:AddString("monospace\n")
	self:AddString("░█░█░█▀█░█▀█░█▀█░█░█░\n░█▀█░█▀█░█▀▀░█▀▀░▀█▀░\n░▀░▀░▀░▀░▀░░░▀░░░░▀░░\n")	self:AddString("it's kinda like fullwidth\n")
	self:AddFont("default")

	local icons = vfs.Find("textures/silkicons/.")
	local tags = ""
	for i = 1, 32 do
		local path = table.random(icons)
		tags = tags .. ("<texture=textures/silkicons/%s>%s"):format(path, i%16 == 0 and "\n" or "")
	end

	self:AddString(tags, true)

	self:AddString([[<font=default><color=0.5,0.62,0.75,1>if<color=1,1,1,1> CLIENT<color=0.5,0.62,0.75,1> then
if<color=1,1,1,1> window<color=0.5,0.62,0.75,1> and<color=0.75,0.75,0.62,1> #<color=1,1,1,1>window<color=0.75,0.75,0.62,1>.<color=1,1,1,1>GetSize<color=0.75,0.75,0.62,1>() ><color=0.5,0.75,0.5,1> 5<color=0.5,0.62,0.75,1> then<color=1,1,1,1>
	timer<color=0.75,0.75,0.62,1>.<color=1,1,1,1>Delay<color=0.75,0.75,0.62,1>(<color=0.5,0.75,0.5,1>0<color=0.75,0.75,0.62,1>,<color=0.5,0.62,0.75,1> function<color=0.75,0.75,0.62,1>()
<color=1,1,1,1>			include<color=0.75,0.75,0.62,1>(<color=0.75,0.5,0.5,1>"examples/markup.lua"<color=0.75,0.75,0.62,1>)
<color=0.5,0.62,0.75,1>		end<color=0.75,0.75,0.62,1>)
<color=0.5,0.62,0.75,1>	end
end
]], true)

	local big_font = "markup_test_big"
	surface.CreateFont(big_font, {path = "Arial Black", size = 30, read_speed = 100})

	self:AddFont(big_font)
	self:AddColor(ColorBytes(0,255,0,255))
	self:AddString("This font is huge and green for some reason!\n")
	self:AddString("wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww\n")
	self:AddColor(ColorBytes(255, 255, 255, 255))
	self:AddFont("default")

	local big_font = "markup_big2"
	surface.CreateFont(big_font, {path = "Roboto", size = 20, read_speed = 100})

	self:AddFont(big_font)
	self:AddColor(ColorBytes(255,0,255,255))
	self:AddString("This one is slightly smaller bug with a different font\n")
	self:AddColor(ColorBytes(255, 255, 255, 255))
	self:AddFont("default")

	--self:AddString("rotated grin<rotate=90>:D</rotate> \n", true)
	--self:AddString("that's <wrong>WRONG</wrong>\n", true)
	self:AddString("Hey look it's gordon freeman!\n")
	self:AddString("<click>http://www.google.com</click>\n", true)
	self:AddString("did you forget your <mark>eggs</mark>?\n", true)
	self:AddString("no but that's <wrong>wierd</wrong>\n", true)
	self:AddString("what's so <rotate=-3>wierd</rotate> about that?\n", true)
	self:AddString("<hsv=[t()+input.rand/10],[(t()+input.rand)/100]>", true)
	self:AddString("<rotate=1>i'm not sure it seems to be</rotate><rotate=-1>some kind of</rotate><physics=0,0>interference</physics>\n", true)
	self:AddString("<scale=[((t()/10)%5^5)+1],1>you don't say</scale>\n", true)

	self:AddString("smileys?")
	self:AddString("\n")
	self:AddString("<rotate=90>:D</rotate>", true)
	self:AddString("<rotate=90>:)</rotate>", true)
	self:AddString("<rotate=90>:(</rotate>", true)
	self:AddString("<rotate=90>:P</rotate>", true)
	self:AddString("<rotate=90>:O</rotate>", true)
	self:AddString("<rotate=90>:]</rotate>", true)
	self:AddString("<rotate=90></rotate>", true)-- FIX ME
	self:AddString("\n")
	self:AddString("maybe..\n\n")

	local big_font = "markup_big3"
	surface.CreateFont(big_font, {path = "Pinyon Script", size = 50, read_speed = 100})
	self:AddFont(big_font)
	local str = "That's all folks!"

	self:AddFont("default")
	self:AddString("\n")
	self:AddString([[
© 2012, Author
Self publishing
(Possibly email address or contact data)]])
end

prototype.UpdateObjects(META)