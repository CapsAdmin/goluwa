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

local list = bottom:SetRight(gui.CreatePanel("list"))
list:SetupSorted("name", "type")
list:SizeColumnsToFit()

local scroll = bottom:SetLeft(gui.CreatePanel("scroll"))
scroll:SetWidth(200)

bottom:SetDividerPosition(200)

local tree = scroll:SetPanel(gui.CreatePanel("tree"))
tree:SetSize(Vec2() + 20000)

local function populate(dir, node)
	for _, full_path in pairs(vfs.Find(dir, nil, true)) do
		local is_dir = vfs.IsFolder(full_path)
		local dir, name = full_path:match("(.+)/(.+)")
		name = name or full_path
		dir = dir or full_path

		if is_dir then
			dir = full_path
			local node = node:AddNode(name, gui.skin.icons.folder)
			node:SetExpandCallback(function(b)
				populate(dir .. "/", node)
			end)
		else
			node:AddNode(name, gui.skin.icons.page)
		end

		--local name, ext = name:match("(.+)%.(.+)")
		--list:AddEntry(name, ext)
	end
	tree:SizeToChildrenHeight()
	tree:Layout()
end

populate(".", tree)

function search:OnTextChanged(str)
	if str == "" then
		tree:RemoveChildren()
		populate("models/", tree)
		return
	end

	prototype.SafeRemove(self.task)
	local task = tasks.CreateTask()

	tree:RemoveChildren()

	function task:OnStart()
		vfs.Search("models/", nil, function(full_path)
			if full_path:find(str) and vfs.IsFile(full_path) then
				local name = full_path:match(".+/(.+)")
				tree:AddNode(name, gui.skin.icons.page)
			end
			self:Wait()
		end)
	end

	task:Start()
	self.task = task
end