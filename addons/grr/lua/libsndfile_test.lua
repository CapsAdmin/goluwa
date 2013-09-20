-- A test for ffi based libsndfile bindings 
 
local FILE = R"sounds/what a shame.ogg" 

print ( "libsndfile version:" , sndfile.version ( ) )

print "\nOPENING FILE"

local sf , info = sndfile.openpath ( FILE )

print ( )
print ( "Frames      " , tonumber ( info.frames ) )
print ( "Sample Rate " , info.samplerate )
print ( "Channels    " , info.channels )
print ( "Format      " , sndfile.format_info ( info.format ) )
print ( "Sections    " , info.sections )
print ( "Seekable?   " , info.seekable ~= 0 )

local outfilename = "samples.raw"
print ( "\nDECODING TO FILE: " .. outfilename )

local out_fd = assert ( io.open ( outfilename , "wb" ) )

local frames = 2^19
local buff = ffi.new ( "int16_t[?]" , frames * info.channels)
local i = 0
repeat
	io.stderr:write ( ("\r%3.0f%%"):format ( i / tonumber ( info.frames ) * 100 ) )
	local n = tonumber ( sf:read_short ( buff , frames ) )
	i = i + n
	out_fd:write ( ffi.string ( buff , n * ffi.sizeof ( "int16_t" ) * info.channels ) )
until n == 0

io.stderr:write ( ("\r%3.0f%%\n"):format ( i / tonumber ( info.frames ) * 100 ) )

print ( "\nDONE" )
