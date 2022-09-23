local function insert_rect(node, w, h)
	if node.left and node.right then
		return insert_rect(node.left, w, h) or insert_rect(node.right, w, h)
	elseif not node.used and (node.w >= w and node.h >= h) then
		if w == node.w and h == node.h then
			node.used = true
			return node
		end

		if node.w - w > node.h - h then
			node.left = {x = node.x, y = node.y, w = w, h = node.h}
			node.right = {
				x = node.x + w,
				y = node.y,
				w = node.w - w,
				h = node.h,
			}
		else
			node.left = {x = node.x, y = node.y, w = node.w, h = h}
			node.right = {x = node.x, y = node.y + h, w = node.w, h = node.h - h}
		end

		return insert_rect(node.left, w, h)
	end
end

local lst = {}
local tree = {x = 0, y = 0, w = render.GetWidth(), h = render.GetHeight()}

for _, v in pairs(prototype.GetCreated()) do
	if v.Type == "texture" then
		local w, h = v:GetSize().x, v:GetSize().y

		if w > 64 or h > 64 then
			w = 64
			h = 64 * (v:GetSize().y / v:GetSize().x)
		end

		list.insert(lst, {tex = v, node = insert_rect(tree, w + 4, h + 4)})
	end
end

function goluwa.PreDrawGUI()
	render2d.SetColor(1, 1, 1, 1)

	for _, v in ipairs(list) do
		if v.node then
			render2d.SetTexture(v.tex)

			if v.tex.StorageType == "cube_map" then
				render2d.DrawRect(v.node.x, v.node.y, v.node.w - 4, v.node.h - 4)
			else
				render2d.DrawRect(v.node.x, v.node.y, v.node.w - 4, v.node.h - 4)
			end
		end
	end
end