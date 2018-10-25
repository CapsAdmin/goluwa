local stack = {}

local function set_panel_env(pnl)
	local meta = {}
	function meta:__index(key)
		if key == "self" then
			return pnl
		end

		if key == "Color" then
			return _G.Color
		end

		if key == "Rect" then
			return _G.Rect
		end

		if pnl["Get" .. key] then
			return pnl["Get" .. key](pnl)
		end

		if type(pnl[key]) == "function" then
			return function(...) pnl[key](pnl, ...) end
		end

		if pnl[key] then
			return pnl[key]
		end

		return _G[key]
	end
	function meta:__newindex(key, val)
		if pnl["Set" .. key] then
			pnl["Set" .. key](pnl, val)
		end

		if key:startswith("On") then
			pnl[key] = val
		end
	end
	local env = setmetatable({}, meta)

	setfenv(2, env)

	return env
end

local function g(class_name, ...)
	if not class_name then
		if not stack[1] then
			setfenv(2, _G)
		else
			table.remove(stack, pnl)
			set_panel_env(stack[#stack])
		end
		return
	end

	local pnl = gui.CreatePanel(class_name, ...)

	if stack[#stack] then
		pnl:SetParent(stack[#stack])
		pnl:SetSkin(stack[#stack]:GetSkin())
	end

	table.insert(stack, pnl)

	return set_panel_env(pnl)
end

gui.Panic()

local META = gui.CreateTemplate("rectangle")
	META:GetSet("NoDraw", true)
gui.RegisterPanel(META)

-- [[

g("base")
	Fill()
	Color = ColorName("white")
	local rect = self:GetRect():Copy()

	local function shrink(a, b, how)
		if how == "top" then
			a.y = a.y + b.h
			a.h = a.h - b.h
		elseif how == "bottom" then
			a.h = a.h - b.h
		end

		if how == "left" then
			a.x = a.x + b.w
			a.w = a.w - b.w
		elseif how == "right" then
			a.w = a.w - b.w
		end
		return a
	end

	local function dock(color, size, dir, lol)
		g("base")
			Margin = Rect()+20
			Padding = Rect()+20
			self.debug_mp = true

			if dir == "top" or dir == "bottom" then
				Height = size
				self.laid_out_y = true
			elseif dir == "left" or dir == "right" then
				Width = size
				self.laid_out_x = true
			end
			Position = rect:GetPosition() + self:GetPadding():GetPosition()
			Color = ColorName(color)
			if dir == "top" then
				MoveLeft()
				MoveUp()
				FillX()
			elseif dir == "bottom" then
				MoveDown()
				FillX()
			elseif dir == "left" then
				MoveLeft()
				FillY()
			elseif dir == "right" then
				MoveRight()
				FillY()
			end
			rect = shrink(rect, self:GetRect() + self:GetPadding() + self:GetParent():GetMargin(), dir)
		g()
	end

	Margin = Rect() + 20
	Padding = Rect() + 20

	dock("#bbbbbbb", 500, "top")
 do return end
	dock("green", 50, "bottom")
	dock("yellow", 50, "left")
	dock("purple", 50, "right")
	--dock("orange", 50, "right")
	--dock("black", 50, "left", true)
	-- [[
	g("base") Name = "pink"
		Color = ColorName("Pink")
		Size = Vec2(16, 16)
		--Rect = rect
		Position = rect:GetPosition()
		FillX()
	g()
	--]]
g() do return end--]]

g("frame")
	Size = Vec2(250, 140)
	Title = "Confirm Save As"
	SetupLayout("LayoutChildren", "SizeToChildrenHeight", "SizeToChildrenWidth")
	local frame = self
	g("base")
		Style = "frame"
		SetupLayout("MoveUp", "FillX", "SizeToChildrenHeight")
		g("rectangle")
			SetupLayout("SizeToChildren", "CenterSimple")
			g("image")
				Texture = render.CreateTextureFromPath("https://cdn1.iconfinder.com/data/icons/CrystalClear/32x32/actions/messagebox_warning.png")
				Size = Texture:GetSize()
				SetupLayout("MoveLeft", "CenterYSimple")
			g()
			g("text")
				Padding = Rect() + 4
				Text = "temp.txt already exist.\nDo you want to replace it?"
				SetupLayout("MoveLeft")
			g()
		g()
	g()
	g("rectangle")
		SetupLayout("MoveUp", "FillX", "SizeToChildrenHeight")
		local function button(str)
			g("text_button")
				Padding = Rect() + 4
				Text = str
				Size = Vec2(90, 25)
				label:SetupLayout("CenterSimple")
				SetupLayout("MoveRight")
				function OnRelease()
					--self.Parent.Parent:Remove()
					frame:Remove()
					print(self, frame)
				end
			g()
		end
		button("Yes")
		button("No")
	g()
g()
