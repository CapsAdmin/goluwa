local freeimage = desire("graphics.ffi.freeimage") -- image decoder

if not freeimage then return end

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
	return self.frames[math.ceil(math.clamp(num%self.frame_count, 1, self.frame_count))]
end

function META:GetTextures()
	return self.frames
end

function META:Draw(x, y)
	local tex = self:GetTexture()
	surface.SetTexture(tex)

	surface.DrawRect(x, y, tex.w, tex.h)
end

prototype.Register(META)

local video = {}

function video.CreateGif(path)
	local self = prototype.CreateObject(META)

	self.frames = {}
	self.frame_count = 1
	self.frame_speed = 15

	self.loading = true

	resource.Download(path, function(path)
		local data = vfs.Read(path)

		local frames = freeimage.LoadMultiPageImage(data)

		local w, h = 0, 0
		for i, frame in pairs(frames) do
			if frame.w > w then w = frame.w end
			if frame.h > h then h = frame.h end

			local tex = Texture(frame.w, frame.h)
			tex:Upload({buffer = frame.data})

			frames[i] = tex
			frames[i].x = frame.x
			frames[i].y = frame.y
			frames[i].ms = frame.ms
		end

		self.frames = frames
		self.frame_count = #frames
		self.loading = false

		if self.frame_count == 0 then
			self.error = true
		end
	end)

	return self
end

_G.Gif = video.CreateGif

return video