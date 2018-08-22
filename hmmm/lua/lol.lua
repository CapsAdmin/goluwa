local big_font = fonts.CreateFont({
	path = "Roboto",
	size = 50,
})

gui.Panic()

local page = gui.CreatePanel("frame")
page:SetSize(Vec2(500, 700))
--page:SetColor(Color(0.1, 0.1, 0.1, 1))

	local scroll = page:CreatePanel("scroll")
	scroll:SetupLayout("fill")
	scroll:SetPadding(Rect() + 8)

		local stack = scroll:CreatePanel("base")
		stack:SetStack(true)
		stack:SetStackRight(false)
		stack:SetStackDown(true)
		stack:SetupLayout("fill")

			local text = stack:CreatePanel("text")
			text:SetFont(big_font)
			text:SetTextColor(Color(1, 0.75, 0.5, 1))
			text:SetText("Find wines")
			text:SetPadding(Rect() + 5)

			local text = stack:CreatePanel("text")
			text:SetText("Search and browse wines")
			text:SetPadding(Rect() + 5)

			local search = stack:CreatePanel("text_input")
			search:SetMultiline(false)
			search:SetPadding(Rect() + 5)
			search:SetHeight(30)
			search:SetText("test")
			search:SetupLayout("fill_x")

			local grid = stack:CreatePanel("base")
			grid:SetColor(Color(1,0,0,0.5))
			grid:SetStack(true)
			grid:SetPadding(Rect() + 5)
			grid:SetHeight(400)
			--grid:SetupLayout("fill_x", "layout_children", "size_to_children_height")
			grid:SetupLayout("fill_x")
			for i = 1, 4 do
				local img = grid:CreatePanel("image")
				img:SetPath("https://upload.wikimedia.org/wikipedia/commons/thumb/3/3c/Red_and_white_wine_12-2015.jpg/1200px-Red_and_white_wine_12-2015.jpg")
				img:SetSize(Vec2() + 140)
				img:SetPadding(Rect() + 5)
			end


