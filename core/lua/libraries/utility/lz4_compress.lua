local ffi = desire("ffi")
local ok, lib

if ffi then
	ok, lib = pcall(ffi.load, "lz4")

	if ok then
		ffi.cdef[[
            int LZ4_compress        (const char* source, char* dest, int inputSize);
            int LZ4_decompress_safe (const char* source, char* dest, int inputSize, int maxOutputSize);
        ]]

		function utility.Compress(data)
			local size = #data
			local buf = ffi.new("uint8_t[?]", ((size) + ((size) / 255) + 16))
			local res = lib.LZ4_compress(data, buf, size)

			if res ~= 0 then return ffi.string(buf, res) end
		end

		function utility.Decompress(source, orig_size)
			local dest = ffi.new("uint8_t[?]", orig_size)
			local res = lib.LZ4_decompress_safe(source, dest, #source, orig_size)

			if res > 0 then return ffi.string(dest, res) end
		end
	end
end

if not ok then
	utility.Compress = function()
		error("lz4 is not avaible: " .. lib, 2)
	end
	utility.Decompress = utility.Compress
end