local render = ... or _G.render

local function insert_rect(node, w, h)
	if node.left and node.right then
		return insert_rect(node.left, w, h) or insert_rect(node.right, w, h)
	elseif not node.used and (node.w >= w and node.h >= h) then		
		if w == node.w and h == node.h then
			node.used = true
			return node
		end
			
		if node.w - w > node.h - h then
			node.left = {
				x = node.x, 
				y = node.y, 
				w = w, 
				h = node.h
			}
			node.right = {
				x = node.x + w, 
				y = node.y, 
				w = node.w - w, 
				h = node.h,
			}
		else
			node.left = {
				x = node.x, 
				y = node.y, 
				w = node.w, 
				h = h
			}
			node.right = {
				x = node.x, 
				y = node.y + h, 
				w = node.w, 
				h = node.h - h
			}
		end
		
		return insert_rect(node.left, w, h)
	end
end

local META = prototype.CreateTemplate("texture_atlas")

function META:FindFreePage(w, h)
	for _, page in ipairs(self.pages) do
		local found = insert_rect(page.tree, w, h)
		if found then
			return page, found
		end
	end
	
	local tree = {x = 0, y = 0, w = self.width, h = self.height}
	local node = insert_rect(tree, w, h)
	
	if node then
		local page = { 
			texture = render.CreateTexture(self.width, self.height, nil, {
				min_filter = "linear",
				mag_filter = "linear",
			}), 
			textures = {}, 
			tree = tree,
		}

		table.insert(self.pages, page)
		
		return page, node
	end
end

function META:BuildTextures()
	table.sort(self.dirty_textures, function(a, b) return (a.w + a.h) > (b.w + b.h) end)
	
	for _, tex in ipairs(self.dirty_textures) do
		local page, node = self:FindFreePage(tex.w, tex.h)
		
		if not page then
			error("texture " .. tostring(tex) .. " is too big", 2)
		end
		
		local x, y, w, h = node.x, node.y, node.w, node.h
		
		tex.page_x = x
		tex.page_y = y 
		tex.page_w = w
		tex.page_h = h
		tex.page = page 
		
		tex.page_uv = {x, y, w, h, page.texture.w, page.texture.h}
		
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
		surface.SetTexture(tex.page.texture)

		surface.SetRectUV(unpack(tex.page_uv))
		surface.DrawRect(x,y, w,h)
		surface.SetRectUV()
	end
end

function render.CreateTextureAtlas(page_width, page_height)
	page_height = page_height or page_width
	return prototype.CreateObject(META, {
		dirty_textures = {}, 
		pages = {}, 
		textures = {}, 
		width = page_width, 
		height = page_height
	})
end