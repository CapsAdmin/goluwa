local header = require("lj-libsoundfile.header")
local enums = require("lj-libsoundfile.enums")

local lib = assert(ffi.load("libsndfile"))

ffi.cdef(header)  

header = header:gsub("%s+", " ")
header = header:gsub(";", "%1\n")

local libsoundfile = {lib = lib, e = enums}

for line in header:gmatch("(.-)\n") do
	if not line:find("typedef") then
		local func = line:match("(sf_%S-) %(")
		if func then
		
			local temp = func
			temp = temp:gsub("(str)[^ing]", "string")
			temp = temp:gsub("_fd", "_file_descriptor")
			temp = temp:gsub("_readf", "_read_frames")
			local friendly = ("_" .. temp):sub(4):gsub("(_%l)", function(char) return char:sub(2,2):upper() end)
			
			libsoundfile[friendly] = lib[func]
		end
	end
end 

-- eek
libsoundfile.ErrorString = libsoundfile.ErrorStr
libsoundfile.ErrorStr = nil

libsoundfile.StringError = libsoundfile.Stringrror
libsoundfile.Stringrror = nil 

-- ???????????????????????????????????????????????????????????????????????????????????????????????
-- FOR SOME REASON REMOVING THIS OTHER LIB CODE EVEN WITHOUT USING IT WILL MAKE SF CRASH WHEN USED
-- ???????????????????????????????????????????????????????????????????????????????????????????????
do -- ekjrieojkr
local band = bit.band
local libsndfile_lib = lib

local majformats = { -- Major formats
	WAV       = e.SF_FORMAT_WAV ;   -- Microsoft WAV format (little endian).
	AIFF      = e.SF_FORMAT_AIFF ;  -- Apple/SGI AIFF format (big endian).
	AU        = e.SF_FORMAT_AU ;    -- Sun/NeXT AU format (big endian).
	RAW       = e.SF_FORMAT_RAW ;   -- RAW PCM data.
	PAF       = e.SF_FORMAT_PAF ;   -- Ensoniq PARIS file format.
	SVX       = e.SF_FORMAT_SVX ;   -- Amiga IFF / SVX8 / SV16 format.
	NIST      = e.SF_FORMAT_NIST ;  -- Sphere NIST format.
	VOC       = e.SF_FORMAT_VOC ;   -- VOC files.
	IRCAM     = e.SF_FORMAT_IRCAM ; -- Berkeley/IRCAM/CARL
	W64       = e.SF_FORMAT_W64 ;   -- Sonic Foundry's 64 bit RIFF/WAV
	MAT4      = e.SF_FORMAT_MAT4 ;  -- Matlab (tm) V4.2 / GNU Octave 2.0
	MAT5      = e.SF_FORMAT_MAT5 ;  -- Matlab (tm) V5.0 / GNU Octave 2.1
	PVF       = e.SF_FORMAT_PVF ;   -- Portable Voice Format
	XI        = e.SF_FORMAT_XI ;    -- Fasttracker 2 Extended Instrument
	HTK       = e.SF_FORMAT_HTK ;   -- HMM Tool Kit format
	SDS       = e.SF_FORMAT_SDS ;   -- Midi Sample Dump Standard
	AVR       = e.SF_FORMAT_AVR ;   -- Audio Visual Research
	WAVEX     = e.SF_FORMAT_WAVEX ; -- MS WAVE with WAVEFORMATEX
	SD2       = e.SF_FORMAT_SD2 ;   -- Sound Designer 2
	FLAC      = e.SF_FORMAT_FLAC ;  -- FLAC lossless file format
	CAF       = e.SF_FORMAT_CAF ;   -- Core Audio File format
	WVE       = e.SF_FORMAT_WVE ;   -- Psion WVE format
	OGG       = e.SF_FORMAT_OGG ;   -- Xiph OGG container
	MPC2K     = e.SF_FORMAT_MPC2K ; -- Akai MPC 2000 sampler
	RF64      = e.SF_FORMAT_RF64 ;  -- RF64 WAV file
}
local subformats = { -- Subtypes
	PCM_S8    = e.SF_FORMAT_PCM_S8 ;    -- Signed 8 bit data
	PCM_16    = e.SF_FORMAT_PCM_16 ;    -- Signed 16 bit data
	PCM_24    = e.SF_FORMAT_PCM_24 ;    -- Signed 24 bit data
	PCM_32    = e.SF_FORMAT_PCM_32 ;    -- Signed 32 bit data
	PCM_U8    = e.SF_FORMAT_PCM_U8 ;    -- Unsigned 8 bit data (WAV and RAW only)
	FLOAT     = e.SF_FORMAT_FLOAT ;     -- 32 bit float data
	DOUBLE    = e.SF_FORMAT_DOUBLE ;    -- 64 bit float data
	ULAW      = e.SF_FORMAT_ULAW ;      -- U-Law encoded.
	ALAW      = e.SF_FORMAT_ALAW ;      -- A-Law encoded.
	IMA_ADPCM = e.SF_FORMAT_IMA_ADPCM ; -- IMA ADPCM.
	MS_ADPCM  = e.SF_FORMAT_MS_ADPCM ;  -- Microsoft ADPCM.
	GSM610    = e.SF_FORMAT_GSM610 ;    -- GSM 6.10 encoding.
	VOX_ADPCM = e.SF_FORMAT_VOX_ADPCM ; -- Oki Dialogic ADPCM encoding.
	G721_32   = e.SF_FORMAT_G721_32 ;   -- 32kbs G721 ADPCM encoding.
	G723_24   = e.SF_FORMAT_G723_24 ;   -- 24kbs G723 ADPCM encoding.
	G723_40   = e.SF_FORMAT_G723_40 ;   -- 40kbs G723 ADPCM encoding.
	DWVW_12   = e.SF_FORMAT_DWVW_12 ;   -- 12 bit Delta Width Variable Word encoding.
	DWVW_16   = e.SF_FORMAT_DWVW_16 ;   -- 16 bit Delta Width Variable Word encoding.
	DWVW_24   = e.SF_FORMAT_DWVW_24 ;   -- 24 bit Delta Width Variable Word encoding.
	DWVW_N    = e.SF_FORMAT_DWVW_N ;    -- N bit Delta Width Variable Word encoding.
	DPCM_8    = e.SF_FORMAT_DPCM_8 ;    -- 8 bit differential PCM (XI only)
	DPCM_16   = e.SF_FORMAT_DPCM_16 ;   -- 16 bit differential PCM (XI only)
	VORBIS    = e.SF_FORMAT_VORBIS ;    -- Xiph Vorbis encoding.
}
local endianess = {
	FILE      = e.SF_ENDIAN_FILE ;   -- Default file endian-ness.
	LITTLE    = e.SF_ENDIAN_LITTLE ; -- Force little endian-ness.
	BIG       = e.SF_ENDIAN_BIG ;    -- Force big endian-ness.
	CPU       = e.SF_ENDIAN_CPU ;    -- Force CPU endian-ness.
}
local masks = {
	SUB    = e.SF_FORMAT_SUBMASK ;
	TYPE   = e.SF_FORMAT_TYPEMASK ;
    ENDIAN = e.SF_FORMAT_ENDMASK ;
}

local sf_assert = function ( err )
	if err ~= 0 then
		error ( ffi.string ( libsndfile_lib.sf_error_number ( err ) ) , 2 )
	end
end

-- Returns version string , major , minor , incremental
local function version ( )
	local data = ffi.new ( "char[128]" )
	libsndfile_lib.sf_command ( nil , e.SFC_GET_LIB_VERSION , data , ffi.sizeof ( data ) )
	local str = ffi.string ( data )
	local maj , min , inc = str:match ( "(%d+).(%d+).(%d+)" )
	return str , tonumber ( maj ) , tonumber ( min ) , tonumber ( inc )
end

-- Takes a format
-- returns (as numbers):
 -- the major type
 -- sub-type
 -- endianess
local function mask_format ( f )
	local major = band ( masks.TYPE , f )
	local minor = band ( masks.SUB , f )
	local endianess = band ( masks.ENDIAN , f )
	return major , minor , endianess
end

-- Takes format
-- returns:
 -- the name of the major type
 -- the name of the sub-type
 -- the most common file extension for this type
local function format_info ( f )
	local data = ffi.new ( "SF_FORMAT_INFO[1]" )

	data[0].format = f
	sf_assert ( libsndfile_lib.sf_command ( nil , e.SFC_GET_FORMAT_INFO , data , ffi.sizeof ( "SF_FORMAT_INFO" ) ) )

	local typename = ffi.string ( data[0].name )
	local extension = ffi.string ( data[0].extension )

	data[0].format = band ( f , masks.SUB )
	sf_assert ( libsndfile_lib.sf_command ( nil , e.SFC_GET_FORMAT_INFO , data , ffi.sizeof ( "SF_FORMAT_INFO" ) ) )
	local subname = ffi.string ( data[0].name )

	return typename , subname , extension
end

-- Opens the given path
-- For info, sample_rate , channels , format are required when the input file is a RAW file
-- returns:
 -- A sndfile object
 -- Info
local function openpath ( path , mode , info )
	assert ( path , "No path provided" )

	if mode == nil or mode == "r" then
		mode = e.SFM_READ
	elseif mode == "w" then
		mode = e.SFM_WRITE
	elseif mode == "rw" then
		mode = e.SFM_RDWR
	end

	info = info or { }
	info = ffi.new ( "SF_INFO" , info )

	local sndfile = libsndfile_lib.sf_open ( path , mode , ffi.new ( "SF_INFO*" , info ) )
	if sndfile == nil then
		error ( ffi.string ( libsndfile_lib.sf_strerror ( sndfile ) ) )
	end

	return sndfile , info
end


local sndfile_methods = { }
local sndfile_mt = { __index = sndfile_methods }

-- TOFIX!
-- Platform specific; could be wrong
local seek_constants = {
	["set"] = 0 ;
	["cur"] = 1 ;
	["end"] = 2 ;
}
function sndfile_methods:seek ( frames , whence )
	whence = seek_constants [ whence ] or seek_constants.set

	local res = libsndfile_lib.sf_seek ( self , frames , whence )

	if res == -1 then error ( "Unable to seek" ) end
	return res
end

function sndfile_methods:close ( )
	sf_assert ( libsndfile_lib.sf_close ( self ) )
end
sndfile_mt.__gc = sndfile_methods.close


sndfile_methods.read_short 	= libsndfile_lib.sf_readf_short
sndfile_methods.read_int 	= libsndfile_lib.sf_readf_int
sndfile_methods.read_float 	= libsndfile_lib.sf_readf_float
sndfile_methods.read_double	= libsndfile_lib.sf_readf_double

sndfile_methods.write_short 	= libsndfile_lib.sf_writef_short
sndfile_methods.write_int   	= libsndfile_lib.sf_writef_int
sndfile_methods.write_float 	= libsndfile_lib.sf_writef_float
sndfile_methods.write_double	= libsndfile_lib.sf_writef_double


ffi.metatype ( "SNDFILE" , sndfile_mt )

libsoundfile.uumm = {
	majformats = majformats ;
	subformats = subformats ;
	endianess = endianess ;
	masks = masks ;
	mask_format = mask_format ;
	format_info = format_info ;

	version = version ;
	openpath = openpath ;
}
end

return libsoundfile