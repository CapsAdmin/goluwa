local frame = gui.CreatePanel("frame", nil, "lol")
frame:SetSize(Vec2()+512)
frame:CenterSimple()

local area = gui.CreatePanel("base", frame)
area:SetNoDraw(true)
area:SetupLayout("bottom", "fill_x", "fill_y")

local search = gui.CreatePanel("text_edit", area)
search:SetHeight(20)
search:SetupLayout("top", "fill_x")

local bottom = gui.CreatePanel("divider", area)
bottom:SetStyle("frame")
bottom:SetupLayout("bottom", "fill_x", "fill_y")

local right = bottom:SetRight(gui.CreatePanel("scroll"))
local icons = right:SetPanel(gui.CreatePanel("base"))
icons:SetNoDraw(true)
icons:SetStack(true)
icons:SetupLayout("fill_x")

local left = bottom:SetLeft(gui.CreatePanel("scroll"))
local tree = left:SetPanel(gui.CreatePanel("tree"))
tree:SetSize(Vec2() + 20000)

bottom:SetDividerPosition(200)

--[[
render.InitializeGBuffer()
local ent = entities.CreateEntity("visual")
ent:SetModel("models/cube.obj")
local light = entities.CreateEntity("light")
light:SetSize(100)
local function draw_scene(mat)
	light:SetPosition(Vec3() + 2)
	ent:SetMaterialOverride(mat)
	ent:Draw()
end
]]

local function add_icon(full_path)
	local dir, name = full_path:match("(.+)/(.+)")
	name = name or full_path

	local area = icons:CreatePanel("base")
	area:SetSize(Vec2() + 128)
	area:SetNoDraw(true)
	area:SetPadding(Rect()+4)

	local label = area:CreatePanel("text")
	label:SetText(name)
	label:SetupLayout("bottom", "center_x_simple")

	local icon = area:CreatePanel("base")
	icon:SetSize(Vec2() + 128)
	icon.OnMouseEnter = function()
		if full_path:endswith(".vmt") then
			--local mat = render.CreateMaterial("model")
			--steam.LoadMaterial(full_path, mat)
			--draw_scene(mat)
		else
			local tex = Texture(full_path)
			icon:SetTexture(tex)
			icon:SetSize((Vec2() + 100) * tex:GetSize().x/tex:GetSize().y)
			icon:SetupLayout("center_simple")
		end
	end
end

local function populate_icons(full_path)
	icons:RemoveChildren()

	for _, full_path in pairs(vfs.Find(full_path .. "/", nil, true)) do
		add_icon(full_path)
	end

	icons:SizeToChildrenHeight()
end

local function populate(dir, node)
	local folders = false

	for _, full_path in pairs(vfs.Find(dir, nil, true)) do
		local dir, name = full_path:match("(.+)/(.+)")
		name = name or full_path
		dir = dir or full_path

		if vfs.IsFolder(full_path) then
			local node = node:AddNode(name, gui.skin.icons.folder)
			node:SetExpandCallback(function(b)
				if not populate(full_path .. "/", node) then
					node.expand:SetVisible(false)
				end
			end)
			node.OnSelect = function()
				populate_icons(full_path)
			end
			folders = true
		else

		end
	end
	tree:SizeToChildrenHeight()

	tree:Layout()

	return folders
end

local where = "textures/"

populate(where, tree)

function search:OnTextChanged(str)
	if str == "" then
		tree:RemoveChildren()
		populate(where, tree)
		return
	end

	prototype.SafeRemove(self.task)
	local task = tasks.CreateTask()

	tree:RemoveChildren()

	function task:OnStart()
		icons:RemoveChildren()
		vfs.Search(where, nil, function(full_path)
			if full_path:find(str) and vfs.IsFile(full_path) then
				add_icon(full_path)
			end
			self:Wait()
		end)
		icons:SizeToChildrenHeight()
	end

	task:Start()
	self.task = task
end