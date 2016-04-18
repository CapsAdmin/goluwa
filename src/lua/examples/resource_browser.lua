commands.RunString("mount gmod")

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

local ent = entities.CreateEntity("visual", entities.GetWorld())
ent:SetModelPath("models/cube.obj")
ent:SetVisible(false)
local light = entities.CreateEntity("light", entities.GetWorld())
light:SetSize(100)
local function draw_scene(mat, pos, rot, fov, w,h)
	local old_view = render.camera_3d:GetView()
	local old_projection = render.camera_3d:GetProjection()
	local old_viewport = render.camera_3d:GetViewport()



	local projection = Matrix44()
	projection:Perspective(fov, render.camera_3d.FarZ, render.camera_3d.NearZ, w / h)

	local view = Matrix44()
	view:SetRotation(rot)
	view:Translate(pos.y, pos.x, pos.z)
	render.camera_3d:SetProjection(projection)
	render.camera_3d:SetView(view)

	render.camera_3d:SetViewport(Rect(0,0,w,h))

local lol = render.active_framebuffer
	ent:SetMaterialOverride(mat)
	ent:SetVisible(true)
	render.DrawGBuffer()
	ent:SetVisible(false)

print(render.active_framebuffer == lol)

	render.camera_3d:SetViewport(old_viewport)
	render.camera_3d:SetView(old_view)
	render.camera_3d:SetProjection(old_projection)
end


local file_types = {
	material = {"vmt"},
	image = {"png", "jpeg", "dds", "vtf", "bmp", "tga"},
	sound = {"wav", "ogg"},
}

local function get_file_type(path)
	for file_type, extensions in pairs(file_types) do
		for i, extension in ipairs(extensions) do
			if path:endswith("." .. extension) then
				return file_type
			end
		end
	end
end

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

	local file_type = get_file_type(full_path)

	local icon = area:CreatePanel("base")
	icon:SetSize(Vec2() + 128)
	icon:SetColor(Color(1,1,1,0.5))

	if file_type == "material" then
		icon:SetCachedRendering(true)
		local mat = render.CreateMaterial("model")
		steam.LoadMaterial(full_path, mat)
		icon.OnDraw = function() draw_scene(mat, Vec3()+10, QuatDeg3(45,45,0), 90, icon:GetWidth(), icon:GetHeight()) end
	elseif file_type == "image" then
		icon:SetTexture(render.CreateTextureFromPath("loading"))
		icon.OnMouseEnter = function()
			local tex = render.CreateTextureFromPath(full_path)
			icon:SetTexture(tex)
			icon:SetSize((Vec2() + 100) * tex:GetSize().x/tex:GetSize().y)
			icon:SetupLayout("center_simple")
		end
	elseif file_type == "sound" then

	else

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
	for _, full_path in pairs(vfs.Find(dir, nil, true)) do
		local dir, name = full_path:match("(.+)/(.+)")
		name = name or full_path
		dir = dir or full_path

		if vfs.IsDirectory(full_path) then
			local node = node:AddNode(name, gui.skin.icons.folder)
			node:SetExpandCallback(function(b)
				populate(full_path .. "/", node)
			end)
			node.OnSelect = function()
				populate_icons(full_path)
			end

			if #vfs.Find(full_path .. "/") == 0 then
				node.expand:SetVisible(false)
			end
		else

		end
	end
	tree:SizeToChildrenHeight()

	tree:Layout()
end

local where = "materials/"

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