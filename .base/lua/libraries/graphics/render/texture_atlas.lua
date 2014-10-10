local META = {}
META.__index = META

function META:FindNode(root, w, h)
	if root.used then
		return self:FindNode(root.right, w, h) or self:FindNode(root.down, w, h)
	elseif w <= root.w and h <= root.h then
		return root
	end
end

function META:SplitNode(node, w, h)
	node.used = true
	node.down = {x = node.x, y = node.y + h, w = node.w, h = node.h - h}
	node.right = {x = node.x + w, y = node.y, w = node.w - w, h = h}
	return node
end

function META:Fit(w, h)
	local node = self:FindNode(self.root, w, h)
	
	if node then		
		return self:SplitNode(node, w, h)
	end
end

local function create_packed_rectangle(w, h) 
	return setmetatable({root = {x = 0, y = 0, w = w, h = h}}, META)
end

local render = ... or _G.render

local META = prototype.CreateTemplate("texture_atlas")

function META:FindFreePage(w, h)	
	for _, page in ipairs(self.pages) do
		local found = page.packer:Fit(w, h)
		if found then
			return page, found.x, found.y, found.w, found.h
		end
	end
	
	local page = { 
		texture = render.CreateTexture(self.width, self.height, nil, {
			min_filter = "linear",
			mag_filter = "linear",
		}), 
		textures = {}, 
		packer = create_packed_rectangle(self.width, self.height) 
	}
					
	table.insert(self.pages, page)
	
	return page, 0, 0, w, h
end


function META:BuildTextures()
	table.sort(self.dirty_textures, function(a, b)
		return (a.w + a.h) > (b.w + b.h)
	end)
	
	for _, tex in ipairs(self.dirty_textures) do
		local page, x, y, w, h = self:FindFreePage(tex.w, tex.h)
		
		tex.page_x = x
		tex.page_y = y
		
		tex.page_uv = {x, -y+h, w, h*2, page.texture.w, page.texture.h}
		
		page.textures[tex] = tex
		
		page.dirty = true
	end
	
	self.dirty_textures = {}

	for _, page in ipairs(self.pages) do
		if page.dirty then		
			page.texture:Clear()
			
			for _, tex in pairs(page.textures) do				
				page.texture:Upload(tex, {x = tex.page_x, y = tex.page_y})
			end
			
			page.dirty = false
		end
	end
end

function META:DebugDraw()
	surface.SetColor(1,1,1,1)
	local x, y = 0,0
	for _, page in ipairs(self.pages) do
		surface.SetTexture(page.texture)
		surface.DrawRect(x,y,page.texture.w, page.texture.h)
		if x + page.texture.w*2 > render.GetWidth() then
			x = 0
			y = y + page.texture.h
		else
			x = x + page.texture.w
		end		
	end
end

function META:Insert(texture, id)
	if id then
		self.textures[id] = texture
	end
	table.insert(self.dirty_textures, texture)
end

function META:Draw(id, x, y, w, h)
	local tex = self.textures[id]
	if id then
		w = w or tex.w
		h = h or tex.h
		surface.SetTexture(tex)
		surface.SetRectUV(unpack(tex.page_uv))
		surface.DrawRect(x,y, w,h)
		surface.SetRectUV(0,0,1,1)
	end
end

function render.CreateTextureAtlas(page_width, page_height)
	page_height = page_height or page_width
	return prototype.CreateObject(META, {dirty_textures = {}, pages = {}, textures = {}, width = page_width, height = page_height})
end

if RELOAD then
	local atlas = render.CreateTextureAtlas(256)

	local icons = vfs.Find("textures/sa/")
	for i, icon in ipairs(icons) do
		atlas:Insert(Texture("textures/sa/" .. icon), icon)
	end
	atlas:BuildTextures()
	local icon = "itwaspoo.001.gif"--table.random(icons)
	event.AddListener("Draw2D", "lol", function()
		atlas:DebugDraw()
		--if wait(1) then icon = table.random(icons) end
		atlas:Draw(icon, 550, 550)
		surface.SetTextPos(550, 520)
		surface.DrawText(icon)
	end)
end