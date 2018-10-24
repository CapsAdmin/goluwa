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

--[[
g("base") SetupLayout("Fill")
	g("base") Height = 56 Color = ColorName("Blue") SetupLayout("MoveUp", "FillX")  g()
	g("base") Height = 56 Color = ColorName("Green") SetupLayout("MoveDown", "FillX") g()
	g("base") Color = ColorName("Yellow") SetupLayout("Fill") g()
g()]]

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
