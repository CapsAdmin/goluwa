local serializer = ... or _G.serializer
local ffi = require("ffi")

serializer.AddLibrary(
	"lzma",
	nil,
	function(archive, str)
		local a = archive.ReadNew()
		archive.ReadSupportCompressionLzma(a)
		archive.ReadSupportFilterLzma(a)
		archive.ReadSupportFormatRaw(a)

		if archive.ReadOpenMemory(a, str, #str) ~= archive.e.OK then
			local err = archive.ErrorString(a)

			if err ~= nil then err = ffi.string(err) end

			archive.ReadFree(a)
			return nil, err
		end

		local entry = archive.EntryNew()

		if archive.ReadNextHeader2(a, entry) ~= archive.e.OK then
			local err = archive.ErrorString(a)

			if err ~= nil then err = ffi.string(err) end

			archive.EntryFree(entry)
			archive.ReadFree(a)
			return nil, err
		end

		local path = ffi.string(archive.EntryPathname(entry))

		if path ~= "data" then
			archive.EntryFree(entry)
			archive.ReadFree(a)
			return nil, "not an archive"
		end

		if archive.EntrySizeIsSet(entry) == 0 then
			local size = 4194304
			local chunks = {}

			for i = 1, math.huge do
				local data = ffi.new("uint8_t[?]", size)
				local bytes_read = archive.ReadData(a, data, size)
				list.insert(chunks, ffi.string(data, bytes_read))

				if bytes_read ~= size then break end
			end

			return list.concat(chunks, "")
		else
			local size = archive.EntrySize(entry)
			local data = ffi.new("uint8_t[?]", size)
			size = archive.ReadData(a, data, size)
			return ffi.string(data, size)
		end
	end,
	desire("libarchive")
)