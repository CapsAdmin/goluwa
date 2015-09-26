--minizip binding. zip standard here: http://www.pkware.com/documents/casestudies/APPNOTE.TXT
local ffi = require'ffi'
local bit = require'bit'

local glue = {}

function glue.update(dt,...)
	for i=1,select('#',...) do
		local t=select(i,...)
		if t ~= nil then
			for k,v in pairs(t) do dt[k]=v end
		end
	end
	return dt
end

function glue.fcall(f,...)
	return assert(fpcall(f,...))
end

require'minizip.header'
local C = ffi.load'libminizip'
local M = {C = C}

local errors = {
	[C.UNZ_ERRNO] = 'errno',
	[C.UNZ_END_OF_LIST_OF_FILE] = 'end of list',
	[C.UNZ_PARAMERROR] = 'invalid argument',
	[C.UNZ_BADZIPFILE] = 'bad zip file',
	[C.UNZ_INTERNALERROR] = 'internal error',
	[C.UNZ_CRCERROR] = 'crc error',
	[-1] = "errno",
	[-2] = "streamerror",
	[-3] = "data error",
	[-4] = "mem error",
	[-5] = "buf error",
	[-6] = "version error",
}

local function checkh(h)
	if h ~= nil then return h end
	error('minizip error')
end

local function check_function(check, ret)
	return function(ret)
		if check(ret) then return ret end
		error(string.format('minizip error %d: %s', ret, errors[ret] or 'unknown error'))
	end
end

local checkz   = check_function(function(ret) return ret == 0 end)
local checkpoz = check_function(function(ret) return ret >= 0 end)
local checkeol = check_function(function(ret) return ret == 0 or ret == C.UNZ_END_OF_LIST_OF_FILE end)

local function zip_close(file, global_comment)
	checkz(C.zipClose(file, global_comment))
	ffi.gc(file, nil)
end

local function zip_open(filename, flag)
	return ffi.gc(checkh(C.zipOpen64(filename, flag or C.APPEND_STATUS_CREATE)), zip_close)
end

--from zlib_h.lua so we don't have to import it (you'd probably not want to change these in most cases)
local Z_DEFLATED            = 8
local Z_DEFAULT_COMPRESSION = -1
local Z_MAX_WBITS           = 15
local Z_DEFAULT_STRATEGY    = 0

local default_add_options = {
	date = nil,                           --table in os.date() format (if missing, dosDate will be used)
	dosDate = 0,                          --date in DOS format
	internal_fa = 0,                      --2 bytes bitfield. format depends on versionMadeBy.
	external_fa = 0,                      --4 bytes bitfield. format depends on versionMadeBy.
	local_extra = nil,                    --cdata or string
	local_extra_size = nil,
	file_extra = nil,                     --cdata or string
	file_extra_size = nil,
	comment = nil,                        --string or char*
	method = Z_DEFLATED,                  --0 = store
	level = Z_DEFAULT_COMPRESSION,        --0..9
	raw = false,                          --write raw data
	windowBits = -Z_MAX_WBITS,            -- -8..-15
	memLevel = 8,                         --1..9 (1 = min. speed, min. memory; 9 = max. speed, max. memory)
	strategy = Z_DEFAULT_STRATEGY,        --see zlib_h.lua
	password = nil,                       --encrypt file with a password
	crc = 0,                              --number; needed if a password is set
	versionMadeBy = 0,                    --version of the zip standard to use. look at section 4.4.2 of the standard.
	flagBase = 0,                         --2 byte "general purpose bit flag" (except the first 3 bits)
	zip64 = false,                        --enable support for files larger than 4G
}

local function zip_add_file(file, t)
	if type(t) == 'string' then
		t = glue.update({filename = t}, default_add_options)
	else
		t = glue.update({}, default_add_options, t)
	end
	assert(t.filename, 'filename missing')

	local info = ffi.new'zip_fileinfo'
	if t.date then
		info.dosDate = 0
		info.tmz_date.tm_sec   = t.date.sec
		info.tmz_date.tm_min   = t.date.min
		info.tmz_date.tm_hour  = t.date.hour
		info.tmz_date.tm_mday  = t.date.day
		info.tmz_date.tm_mon   = t.date.month - 1
		info.tmz_date.tm_year  = t.date.year
	else
		info.dosDate = t.dosDate
	end
	info.internal_fa = t.internal_fa
	info.external_fa = t.external_fa

	t.local_extra_size = t.local_extra and (t.local_extra_size or #t.local_extra) or 0
	t.file_extra_size  = t.file_extra  and (t.file_extra_size  or #t.file_extra)  or 0

	checkz(C.zipOpenNewFileInZip4_64(file, t.filename, info,
			t.local_extra, t.local_extra_size, t.file_extra, t.file_extra_size,
			t.comment, t.method, t.level, t.raw,
			t.windowBits, t.memLevel, t.strategy,
			t.password, t.crc, t.versionMadeBy, t.flagBase, t.zip64))
end

local function zip_write(file, data, sz)
	checkz(C.zipWriteInFileInZip(file, data, sz or #data))
end

local function zip_close_file(file)
	checkz(C.zipCloseFileInZip(file))
end

local function zip_close_file_raw(file, uncompressed_size, crc32)
	checkz(C.zipCloseFileInZipRaw64(file, uncompressed_size, crc32))
end

--zip hi-level API

local function zip_archive(file, t, s, sz)
	zip_add_file(file, t)
	zip_write(file, s, sz)
	zip_close_file(file)
end

--unzip interface

local function unzip_close(file)
	checkz(C.unzClose(file))
	ffi.gc(file, nil)
end

local function unzip_open(filename)
	return ffi.gc(checkh(C.unzOpen64(filename)), unzip_close)
end

--return the number of entries in the zip file and the global comment
local function unzip_get_global_info(file)
	local info = ffi.new'unz_global_info64'
	checkz(C.unzGetGlobalInfo64(file, info))
	local sz = info.size_comment
	local buf = ffi.new('uint8_t[?]', sz)
	sz = checkpoz(C.unzGetGlobalComment(file, buf, sz))
	local comment = sz > 0 and ffi.string(buf, sz) or nil
	local entries = info.number_entry
	return {
		entries = tonumber(entries),
		comment = comment,
	}
end

local function unzip_first_file(file)
	checkz(C.unzGoToFirstFile(file))
	return true
end

local function unzip_next_file(file)
	return checkeol(C.unzGoToNextFile(file)) == 0 or nil
end

local function unzip_locate_file(file, filename, case_insensitive)
	return checkeol(C.unzLocateFile(file, filename, case_insensitive and 2 or 1)) == 0
end

local function unzip_get_file_pos(file)
	local pos = ffi.new'unz64_file_pos'
	checkz(C.unzGetFilePos64(file, pos))
	return pos
end

local function unzip_goto_file_pos(file, pos)
	checkz(C.unzGoToFilePos64(file, pos))
end

local levels = {
	[6] = 1,
	[4] = 2,
	[2] = 9,
}

local function unzip_get_file_info(file)
	local info = ffi.new'unz_file_info64'

	checkz(C.unzGetCurrentFileInfo64(file, info, nil, 0, nil, 0, nil, 0))

	local filename     = info.size_filename > 0 and ffi.new('uint8_t[?]', info.size_filename) or nil
	local file_extra   = info.size_file_extra > 0 and ffi.new('uint8_t[?]', info.size_file_extra) or nil
	local file_comment = info.size_file_comment > 0 and ffi.new('uint8_t[?]', info.size_file_comment) or nil

	checkz(C.unzGetCurrentFileInfo64(file, info,
												filename,     info.size_filename,
												file_extra,   info.size_file_extra,
												file_comment, info.size_file_comment))

	return {
		version        = info.version,
		version_needed = info.version_needed,
		flagBase  = bit.band(info.flag, 0xfff8),
		method    = info.compression_method,
		level     = levels[bit.band(info.flag, 0x06)] or 6,
		encrypted = bit.band(info.flag, 1) == 1,
		dosDate   = info.dosDate,
		crc       = info.crc,
		compressed_size   = tonumber(info.compressed_size),
		uncompressed_size = tonumber(info.uncompressed_size),
		internal_fa = info.internal_fa,
		external_fa = info.external_fa,
		date = {
			sec   = info.tmu_date.tm_sec,
			min   = info.tmu_date.tm_min,
			hour  = info.tmu_date.tm_hour,
			day   = info.tmu_date.tm_mday,
			month = info.tmu_date.tm_mon + 1,
			year  = info.tmu_date.tm_year,
		},
		filename         = filename and ffi.string(filename, info.size_filename),
		file_extra       = file_extra,
		file_extra_size  = file_extra and info.size_file_extra,
		comment          = file_comment and ffi.string(file_comment, info.size_file_comment),
	}
end

local function unzip_get_zstream_pos(file)
	return tonumber(C.unzGetCurrentFileZStreamPos64(file))
end

local function unzip_open_file(file, password, raw)
	local method = ffi.new'int[1]'
	local level = ffi.new'int[1]'
	checkz(C.unzOpenCurrentFile3(file, nil, nil, raw or 0, password))
end

local function unzip_get_local_extra(file)
	local sz = checkpoz(C.unzGetLocalExtrafield(file, nil, 0))
	if sz == 0 then return end
	local buf = ffi.new('char[?]', sz)
	assert(checkpoz(C.unzGetLocalExtrafield(file, buf, sz)) == sz)
	return buf, sz
end

local function unzip_close_file(file)
	checkz(C.unzCloseCurrentFile(file))
end

local function unzip_read_cdata(file, buf, sz)
	return checkpoz(C.unzReadCurrentFile(file, buf, sz))
end

local function unzip_read(file, sz)
	if sz == math.huge then
		sz = unzip_get_file_info(file).uncompressed_size
	end
	local buf = ffi.new('uint8_t[?]', sz)
	local len = unzip_read_cdata(file, buf, sz)
	return len > 0 and ffi.string(buf, len) or nil
end

local function unzip_tell(file)
	return tonumber(C.unztell64(file))
end

local function unzip_eof(file)
	return C.unzeof(file) == 1
end

local function unzip_get_offset(file)
	return tonumber(C.unzGetOffset64(file))
end

local function unzip_set_offset(file, pos)
	C.unzSetOffset64(file, pos)
end

--unzip hi-level API

local function unzip_files(file)
	unzip_first_file(file)
	local first = true
	return function()
		if first then
			first = false
		elseif not unzip_next_file(file) then
			return
		end
		return unzip_get_file_info(file)
	end
end

local function unzip_extract(file, filename, password)
	assert(unzip_locate_file(file, assert(filename, 'filename missing')), 'file not found')
	local sz = unzip_get_file_info(file).uncompressed_size
	unzip_open_file(file, password)
	local s = unzip_read(file, sz)
	unzip_close_file(file)
	assert(#s == sz, 'short read')
	return s
end

--zip+unzip interface

local function copy_from_zip(file, src_file, bufsize)
	glue.fcall(function(finally)

		unzip_open_file(src_file, nil, true)
		finally(function() unzip_close_file(src_file) end)

		local info = unzip_get_file_info(src_file)

		--get local extra header and remove the ZIP64 block as needed for RAW mode copying
		local local_extra, local_extra_size = unzip_get_local_extra(src_file)
		if local_extra then
			local sz = ffi.new'int[1]'
			C.zipRemoveExtraInfoBlock(local_extra, sz, 1)
			local_extra_size = sz[0]
		end

		--add the file to the dest. zip with exactly the same header fields as the source file
		zip_add_file(file, {
			filename = info.filename,
			versionMadeBy = info.version,
			dosDate = info.dosDate,
			internal_fa = info.internal_fa,
			external_fa = info.external_fa,
			comment = info.comment,
			method = info.method,
			level = info.level,
			raw = true,
			crc = info.crc,
			flagBase = info.flagBase,
			local_extra = local_extra,
			local_extra_size = local_extra_size,
			file_extra = info.file_extra,
			file_extra_size = info.file_extra_size,
		})

		--copy the file contents in fixed sized chunks
		local left = info.compressed_size
		if left > 0 then
			local bufsize = math.min(left, bufsize or 4096)
			local buf = ffi.new('char[?]', bufsize)
			while left > 0 do
				local sz = math.min(left, bufsize)
				assert(unzip_read_cdata(src_file, buf, sz) == sz)
				zip_write(file, buf, sz)
				left = left - sz
			end
		end

		--close the dest. file. the source file is closed on the finally clause.
		zip_close_file_raw(file, info.uncompressed_size, info.crc)
	end)
end

--user interface

ffi.metatype('zipFile_s', {__index = {
	close = zip_close,
	add_file = zip_add_file,
	write = zip_write,
	close_file = zip_close_file,
	close_file_raw = zip_close_file_raw,
	archive = zip_archive,
	copy_from_zip = copy_from_zip,
}})

ffi.metatype('unzFile_s', {__index = {
	close = unzip_close,
	get_global_info = unzip_get_global_info,
	--file catalog
	first_file = unzip_first_file,
	next_file = unzip_next_file,
	locate_file = unzip_locate_file,
	get_file_pos = unzip_get_file_pos,
	goto_file_pos = unzip_goto_file_pos,
	get_file_info = unzip_get_file_info,
	get_zstream_pos = unzip_get_zstream_pos,
	--file i/o
	open_file = unzip_open_file,
	close_file = unzip_close_file,
	read_cdata = unzip_read_cdata,
	read = unzip_read,
	tell = unzip_tell,
	eof = unzip_eof,
	get_offset = unzip_get_offset,
	set_offset = unzip_set_offset,
	--hi-level API
	files = unzip_files,
	extract = unzip_extract,
}})

local function open(filename, mode)
	if not mode or mode == 'r' then
		return unzip_open(filename)
	elseif mode == 'w' then
		return zip_open(filename)
	elseif mode == 'a' then
		return zip_open(filename, C.APPEND_STATUS_ADDINZIP)
	else
		error("invalid mode. nil, 'r', 'w', 'a', expected.")
	end
end

return {
	open = open,
}

