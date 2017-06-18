local markup = ... or gfx.CreateMarkup()
--markup:SetLineWrap(true)
markup:AddFont(fonts.CreateFont({size = 14, read_speed = 100}))

markup:AddString("Hello markup test!\n有一些中國\nそして、いくつかの日本の\nكيف حول بعض عربية")
markup:AddString[[markup todo:
caret real_x should prioritise pixel width
y axis caret movement when the text is being wrapped
divide this up in cells (new object?)
proper tag stack
the ability to edit (remove and copy) custom tags that have a size (like textures)
alignment tags]]

markup:AddFont(fonts.CreateFont({size = 8, read_speed = 100}))
markup:AddString("\nhere's some text in chinese:\n我寫了這個在谷歌翻譯，所以我可以測試我的標記語言使用Unicode正確。它似乎做工精細！\n")	markup:AddString("some normal string again\n")
markup:AddString("and another one\n")

markup:AddFont(gfx.GetDefaultFont())
markup:AddString("back to normal!\n\n")

markup:AddFont(fonts.CreateFont({size = 14, read_speed = 100, monospace = true}))
markup:AddString("monospace\n")
markup:AddString("░█░█░█▀█░█▀█░█▀█░█░█░\n░█▀█░█▀█░█▀▀░█▀▀░▀█▀░\n░▀░▀░▀░▀░▀░░░▀░░░░▀░░\n")	markup:AddString("it's kinda like fullwidth\n")
markup:AddFont(gfx.GetDefaultFont())

local icons = vfs.Find("textures/silkicons/.")
local tags = ""
for i = 1, 32 do
	local path = table.random(icons)
	tags = tags .. ("<texture=textures/silkicons/%s>%s"):format(path, i%16 == 0 and "\n" or "")
end

markup:AddString(tags, true)

markup:AddString([[<font=default><color=0.5,0.62,0.75,1>if<color=1,1,1,1> CLIENT<color=0.5,0.62,0.75,1> then
if<color=1,1,1,1> window<color=0.5,0.62,0.75,1> and<color=0.75,0.75,0.62,1> #<color=1,1,1,1>window<color=0.75,0.75,0.62,1>.<color=1,1,1,1>GetSize<color=0.75,0.75,0.62,1>() ><color=0.5,0.75,0.5,1> 5<color=0.5,0.62,0.75,1> then<color=1,1,1,1>
timer<color=0.75,0.75,0.62,1>.<color=1,1,1,1>Delay<color=0.75,0.75,0.62,1>(<color=0.5,0.75,0.5,1>0<color=0.75,0.75,0.62,1>,<color=0.5,0.62,0.75,1> function<color=0.75,0.75,0.62,1>()
<color=1,1,1,1>			include<color=0.75,0.75,0.62,1>(<color=0.75,0.5,0.5,1>"examples/markup.lua"<color=0.75,0.75,0.62,1>)
<color=0.5,0.62,0.75,1>		end<color=0.75,0.75,0.62,1>)
<color=0.5,0.62,0.75,1>	end
end
]], true)

markup:AddFont(fonts.CreateFont({path = "Roboto", size = 30, read_speed = 100}))
markup:AddColor(ColorBytes(0,255,0,255))
markup:AddString("This font is huge and green for some reason!\n")
markup:AddString("wwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwwww\n")
markup:AddColor(ColorBytes(255, 255, 255, 255))
markup:AddFont(gfx.GetDefaultFont())

markup:AddFont(fonts.CreateFont({path = "Roboto", size = 20, read_speed = 100}))
markup:AddColor(ColorBytes(255,0,255,255))
markup:AddString("This one is slightly smaller bug with a different font\n")
markup:AddColor(ColorBytes(255, 255, 255, 255))
markup:AddFont(gfx.GetDefaultFont())

--self:AddString("rotated grin<rotate=90>:D</rotate> \n", true)
--self:AddString("that's <wrong>WRONG</wrong>\n", true)
markup:AddString("Hey look it's gordon freeman!\n")
markup:AddString("<click>http://www.google.com</click>\n", true)
markup:AddString("did you forget your <mark>eggs</mark>?\n", true)
markup:AddString("no but that's <wrong>wierd</wrong>\n", true)
markup:AddString("what's so <rotate=-3>wierd</rotate> about that?\n", true)
markup:AddString("<hsv=[t()+input.rand/10],[(t()+input.rand)/100]>", true)
--markup:AddString("<rotate=1>i'm not sure it seems to be</rotate><rotate=-1>some kind of</rotate><physics=0,0>interference</physics>\n", true)
markup:AddString("<scale=[((t()/10)%5^5)+1],1>you don't say</scale>\n", true)

markup:AddString("smileys?")
markup:AddString("\n")
markup:AddString("<rotate=90>:D</rotate>", true)
markup:AddString("<rotate=90>:)</rotate>", true)
markup:AddString("<rotate=90>:(</rotate>", true)
markup:AddString("<rotate=90>:P</rotate>", true)
markup:AddString("<rotate=90>:O</rotate>", true)
markup:AddString("<rotate=90>:]</rotate>", true)
markup:AddString("<rotate=90></rotate>", true)-- FIX ME
markup:AddString("\n")
markup:AddString("maybe..\n")

markup:AddFont(fonts.CreateFont({path = "Aladin", size = 30, read_speed = 100}))
local str = "That's all folks!"

markup:AddFont(gfx.GetDefaultFont())
markup:AddString("\n")
markup:AddString([[
© 2012, Author
Self publishing
(Possibly email address or contact data)]])

if ... then return end

event.AddListener("PostDrawGUI", "lol", function()
	local x = (os.clock()*10)%500
	x = gfx.GetMousePosition()
	render2d.PushMatrix(50,50)
		markup:Update()
		markup:Draw()
		--markup:SetMaxWidth(x)
		render2d.SetColor(1,1,1,1)
		gfx.DrawLine(x, 0, x, 1000)
	render2d.PopMatrix()
end)