local utilities = ... or _G.utilities

local META = metatable.CreateTemplate("packed_rectangle")

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

function utilities.CreatePackedRectangle(w, h) 
	return META:New({root = {x = 0, y = 0, w = w, h = h}}) 
end