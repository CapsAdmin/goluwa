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

prototype.GetSet(META, "Padding", 1)

function render.CreateTextureAtlas(page_width, page_height, filtering)
	page_height = page_height or page_width
	return prototype.CreateObject(META, {
		dirty_textures = {},
		pages = {},
		textures = {},
		width = page_width,
		height = page_height,
		filtering = filtering,
	})
end

function META:FindFreePage(w, h)
	w = w + self.Padding
	h = h + self.Padding

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
			texture = render.CreateBlankTexture(Vec2(self.width, self.height) + self.Padding),
			textures = {},
			tree = tree,
		}

		--page.texture:SetMinFilter(self.filtering)
		page.texture:SetMagFilter(self.filtering)

		table.insert(self.pages, page)

		return page, node
	end
end

local function sort(a, b) return (a.w + a.h) > (b.w + b.h) end

function META:Build()
	table.sort(self.dirty_textures, sort)

	for _, data in ipairs(self.dirty_textures) do

		local page, node = self:FindFreePage(data.w, data.h)

		if not page then
			error("texture " .. tostring(data) .. " is too big", 2)
		end

		local x, y, w, h = node.x, node.y, node.w, node.h

		data.page_x = x + self.Padding
		data.page_y = y + self.Padding
		data.page_w = w
		data.page_h = h
		data.page = page

		data.page_uv = {x+self.Padding/2, y+self.Padding/2, w, h, page.texture:GetSize().x, page.texture:GetSize().y}

		page.textures[data] = data

		page.dirty = true
	end

	self.dirty_textures = {}

	for _, page in ipairs(self.pages) do
		if page.dirty then
			page.texture:Clear()

			for _, data in pairs(page.textures) do
				if data.buffer then
					page.texture:Upload({
						buffer = data.buffer,
						x = data.page_x,
						y = data.page_y,
						width = data.w,
						height = data.h,
						flip_x = data.flip_x,
						flip_y = data.flip_y,
					})
				else
					local data = data:Download()
					data.x = data.page_x
					data.y = data.page_y
					page.texture:Upload(data)
				end
			end

			page.dirty = false
		end
	end
end

function META:GetTextures()
	local out = {}

	for k,v in ipairs(self.pages) do
		table.insert(out, v.texture)
	end

	return out
end

function META:DebugDraw()
	surface.SetColor(1,1,1,1)
	local x, y = 0,0
	for _, page in ipairs(self.pages) do
		surface.SetTexture(page.texture)
		surface.DrawRect(x,y,page.texture:GetSize().x, page.texture:GetSize().y)
		if x + page.texture:GetSize().x*2 > render.GetWidth() then
			x = 0
			y = y + page.texture:GetSize().y
		else
			x = x + page.texture:GetSize().x
		end
	end
end

function META:Insert(id, data)
	if id then
		self.textures[id] = data
	end
	table.insert(self.dirty_textures, data)
end

function META:Draw(id, x, y, w, h)
	local data = self.textures[id]
	if data then
		w = w or data.page_w
		h = h or data.page_h

		surface.SetTexture(data.page.texture)

		surface.SetRectUV(unpack(data.page_uv))
		surface.DrawRect(x,y, w,h)
		surface.SetRectUV()
	end
end

function META:GetUV(id)
	local data = self.textures[id]
	if data then
		return unpack(data.page_uv)
	end
end

function META:GetPageTexture(id)
	local data = self.textures[id]
	if data then
		return data.page.texture
	end
end

prototype.Register(META)