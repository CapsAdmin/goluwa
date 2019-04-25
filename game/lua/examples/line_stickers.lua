function goluwa.PreDrawGUI()
	local set = utility.GetLineStickers("1073")
print(set)
	if not set then return end

	local X, Y = 0, 0
	local max_height = 0

	for _, sticker in ipairs(set.stickers) do
		local size = sticker.tex:GetSize()/3
		max_height = math.max(max_height, size.y)
		gfx.DrawRect(X, Y, size.x, size.y, sticker.tex)
		X = X + size.x
		if X > 1000 then
			X = 0
			Y = Y + max_height
		end
	end

	gfx.DrawRect(0, Y + max_height, 100, 100, utility.GetLineStickerSetIcon("272"))
end