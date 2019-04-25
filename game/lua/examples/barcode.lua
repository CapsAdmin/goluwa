local tex = render.CreateTextureFromPath("http://lempickarecords.com/wp-content/uploads/2013/01/oz-barcodes.png")

event.AddListener("PostDrawGUI", "test", function()
	gfx.DrawRect(0,0, tex:GetSize().x, tex:GetSize().y, tex)

	local mpos = window.GetMousePosition()

	local i = 0
	local avg = 0

	local w = 100
	local h = 20

	local bars = {}

	for x = -w, w do
		for y = -h, h do
			local c = tex:GetPixelColor(mpos.x + x, mpos.y + y)

			if y == 0 then
				local len = Vec3(c.r, c.g, c.b):GetLength()
				table.insert(bars, len)
				avg = avg + len
				i = i  + 1
			end

		end
	end

	avg = avg / i

	for i,v in ipairs(bars) do
		bars[i] = v / avg
	end

	local i = 1
	local threshold = 0.8

	while true do if not bars[i] then break end
		if bars[i] < threshold then
			local len = 0
			while true do if not bars[i] then break end
				if bars[i] < threshold then
					len = len + 1
				else
					break
				end
				i = i + 1
			end

			log((" "):rep(len))
		else
			local len = 0
			while true do if not bars[i] then break end
				if bars[i] > threshold then
					len = len + 1
				else
					break
				end
				i = i + 1
			end

			log(("|"):rep(len))
		end
		i = i + 1
	end

	logn()


	avg = avg / ((1+w*2) * (1+h*2))

	gfx.DrawRect(mpos.x - w, mpos.y - h, w*2, h*2, nil, 1,0,0,0.5)
end)