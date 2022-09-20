local gfx = (...) or _G.gfx
local freeimage = desire("freeimage") -- image decoder
local META = prototype.CreateTemplate("gif")

function META:GetFrameCount()
	return self.frame_count
end

function META:SetFPS(fps)
	self.frame_speed = fps
end

function META:GetTexture(num)
	num = num or (os.clock() * self.frame_speed)

	if self.error then return render.GetErrorTexture() end

	if self.loading then return render.GetLoadingTexture() end

	return self.frames[math.ceil(math.clamp(num % self.frame_count, 1, self.frame_count))]
end

function META:GetTextures()
	return self.frames
end

function META:Draw(x, y)
	local tex = self:GetTexture()
	render2d.SetTexture(tex)
	render2d.DrawRect(x, y, tex:GetSize().x, tex:GetSize().y)
end

META:Register()

function gfx.CreateGif(path)
	local self = META:CreateObject()
	self.frames = {}
	self.frame_count = 1
	self.frame_speed = 15
	self.loading = true

	if freeimage then
		resource.Download(path):Then(function(path)
			local data = vfs.Read(path)
			local frames = freeimage.LoadMultiPageImage(data)
			local w, h = 0, 0

			for i, frame in pairs(frames) do
				if frame.w > w then w = frame.w end

				if frame.h > h then h = frame.h end

				local tex = render.CreateBlankTexture(Vec2(frame.w, frame.h))
				tex:Upload({buffer = frame.data})
				frames[i] = tex
				frames[i].x = frame.x
				frames[i].y = frame.y
				frames[i].ms = frame.ms
			end

			self.frames = frames
			self.frame_count = #frames
			self.loading = false

			if self.frame_count == 0 then self.error = true end
		end)
	end

	return self
end