--  lib_util.lua
module(..., package.seeall)

local ffi = require "ffi"
local C = ffi.C
local bit = require "bit"

-- global utility
isWin = (ffi.os == "Windows")
isMac = (ffi.os == "OSX")
isLinux = (ffi.os == "Linux")
is64bit = ffi.abi("64bit")
is32bit = ffi.abi("32bit")

local floor = math.floor

function openFile(file)
	if isWin then
		os.execute("start "..file)
	else
		os.execute("open "..file)
	end
end

function currentPath()
	local currentPath = ""
	local pwd_file
	if isWin then
		pwd_file = io.popen("cd", "r")
	else
		pwd_file = io.popen("pwd", "r")
	end
	if pwd_file then
		currentPath = pwd_file:read("*all")
		pwd_file:close()
	end
	currentPath = currentPath:gsub("\r", "")
	currentPath = currentPath:gsub("\n", "")
	currentPath = currentPath:gsub("\\", "/") -- windows
	currentPath = currentPath.."/"
	return currentPath
end

local function homeDirectoy()
	local homeDir
	if isWin then
		pwd_file = nil -- todo
	else
		pwd_file = io.popen("echo ~", "r")
	end
	if pwd_file then
		homeDir = pwd_file:read("*all")
		pwd_file:close()
	end
	homeDir = homeDir:gsub("\r", "")
	homeDir = homeDir:gsub("\n", "")
	return homeDir
end

function filePathFix(file)
	if file:find("~") then
		if isWin then
			return file:gsub("~", "C:")
		else
			return file:gsub("~", homeDirectoy())
		end
	end
	return file
end

function readFile(file)
	file = filePathFix(file)
	local f = io.open(file, "r")
	local fileData = f:read("*all")
	f:close()
	return fileData,file
end

function writeFile(file, data)
	file = filePathFix(file)
	local f = io.open(file, "wb")
	f:write(data)
	f:close()
	return file
end

function appendFile(file, data)
	file = filePathFix(file)
	local f = io.open(file, "a+b")
	f:write(data)
	f:close()
	return file
end

function fileSize(bytes, decimals)
		local decimals = decimals or 2
		local ret = ""
		if( bytes == 0 ) then
			ret = "0 Bytes"
		else
    	local filesizename = {" Bytes", " KB", " MB", " GB", " TB", " PB", " EB", " ZB", " YB"}
    	local factor = floor((string.len(tostring(bytes)) - 1) / 3)
    	ret = format_num(bytes / math.pow(1024, factor), decimals, "")
    	       -- no space or comma between int numbers
    	       -- wo don't want "1 024" - we want "1024" because int part is never more than 4 numbers
    	ret = ret .. filesizename[factor + 1]
    end
    return ret
end

-- common win + osx + linux: C-functions
ffi.cdef([[
	char * strerror ( int errnum );
]])

if isWin then
	--require "win_socket"
	function win_errortext(err)
		if not err then
			return("ERR: win_errortext() called with nil value")
		end
		-- sock.WSAGetLastError() --err --ffi.string(ffi.C.gai_strerror(err))
		local buffer = ffi.new("char[512]")
		if not kernel32 then
			kernel32 = ffi.load("kernel32")
		end
		local flags = bit.bor(C.FORMAT_MESSAGE_IGNORE_INSERTS, C.FORMAT_MESSAGE_FROM_SYSTEM)
		local err_c = ffi.cast("int", err)
		kernel32.FormatMessageA(flags, nil, err_c, 0, buffer, ffi.sizeof(buffer), nil)
		return string.sub(ffi.string(buffer), 1, -3).." ("..err..")" -- remove last crlf
	end
end

function cstr(str)
	local len = str:len()+1
  local typeStr = "uint8_t[" .. len .. "]"
  return ffi.new( typeStr, str )
end

function cerr()
	error( ffi.string(C.strerror(ffi.errno())) )
end

function createBuffer(datalen)
	if datalen < 1 then
		error("datalen < 1 [createBuffer(datalen)]")
	end
	local var = ffi.new("int8_t[?]", datalen)
	local ptr = ffi.cast("void *", var)
	return var,ptr
end

local is64bit_l = is64bit  -- do we need a local var for performance ?
function getOffsetPointer(cdata, offset)
	local address_as_number
	if is64bit_l then
		address_as_number = ffi.cast("int64_t", cdata)
		-- return ffi.cast("int64_t *", address_as_number + offset)
	else --if is32bit then
		address_as_number = ffi.cast("int32_t", cdata)
		-- return ffi.cast("int32_t *", address_as_number + offset)
	end -- is there 16 bit luajit systems?
	return ffi.cast("int8_t *", tonumber(address_as_number) + offset)
end


--[[

function createAddressVariable(cdata)
	local addr_var = ffi.new("uintptr_t[1]")
	addr_var[0] = getPointer(cdata)
	return addr_var
end

function getAddressAsNumber(cdata)
	if is64bit then
		return ffi.cast("int64_t", cdata)
	elseif is32bit then
		return ffi.cast("int32_t", cdata)
	end
	return nil
end

function getOffsetPointer(var, offset)
	if offset < 0 then
		error("*** ERROR: offset < 0 [getOffsetPointer(var, offset)]")
	end
	return ffi.cast("int8_t *", var[offset])
end
function getPointer(cdata)
	local addr_var = ffi.new("uintptr_t[1]")
	if is64bit then
		addr_var[0] = ffi.cast("int64_t", cdata)
	elseif is32bit then
		addr_var[0] = ffi.cast("int32_t", cdata)
	end
	print(cdata, addr_var, addr_var[0])
	return ffi.cast("int8_t *", addr_var)
end

	local tmpvar = ffi.new("int8_t[1]")
	local varptr ffi.cast("int8_t *", var)
	tmpvar[0] = varptr

function createAddressVariable(cdata)
	local addr_var = ffi.new("uintptr_t[1]")
	addr_var[0] = getPointer(cdata)
	return addr_var
end

function createBufferVariable(datalen)
	return ffi.new("int8_t *[?]", datalen)
end

]]

function file_exists(name)
   local f=io.open(name,"r")
   if f~=nil then io.close(f) return true else return false end
end

function string_starts(String, Start)
   return string.sub(String,1,string.len(Start))==Start
end

function string_ends(String, End)
   return End=="" or string.sub(String,-string.len(End))==End
end

function last_part(txt, search_string)
	local lastPos -- nil
	local pos = string.find(txt, search_string)
	while pos do
		lastPos = pos
		pos = string.find(txt, search_string, pos + 1)
	end
  if lastPos then
    return string.sub(txt,lastPos+1,string.len(txt))
  else
    return ""
  end
end

function toHexString(num)
	if type(num) ~= "number" then
		num = tonumber(num) -- try to cast for ex. cdata[0]
	end
	if is64bit then
		return string.format("0x%016x", num)
	elseif is32bit then
		return string.format("0x%08x", num)
	end
	return nil
end

if isWin then

	function processorCoreCount()
		local sysinfo = ffi.new("SYSTEM_INFO")
		C.GetSystemInfo(sysinfo)
		return sysinfo.dwNumberOfProcessors,sysinfo.dwNumberOfProcessors -- conf and online? = hyperthreding
	end

	function waitKeyPressed()
		--[[
		DWORD mode, count;
		HANDLE h = GetStdHandle( STD_INPUT_HANDLE );
		if (h == NULL) return 0;  // not a console
		GetConsoleMode( h, &mode );
		SetConsoleMode( h, mode & ~(ENABLE_LINE_INPUT | ENABLE_ECHO_INPUT) );
		TCHAR c = 0;
		ReadConsole( h, &c, 1, &count, NULL );
		SetConsoleMode( h, mode );
		]]
		local h = C.GetStdHandle( C.STD_INPUT_HANDLE )
		if not h then return 0 end-- not a console
		local mode = ffi.new("DWORD[1]")
		C.GetConsoleMode( h, mode )
		local modeSet = bit.band(mode[0], bit.bnot(bit.bor(C.ENABLE_LINE_INPUT, C.ENABLE_ECHO_INPUT))) --, C.ENABLE_PROCESSED_INPUT)))
		C.SetConsoleMode( h, modeSet )
		local ch = ffi.new("DWORD[1]")
		local count = ffi.new("DWORD[1]")
		-- to read also arrows and other special chars from input:
		-- http://msdn.microsoft.com/en-us/library/windows/desktop/ms684958(v=vs.85).aspx
		-- last param: A pointer to a CONSOLE_READCONSOLE_CONTROL structure that specifies a control character to signal the end of the read operation. This parameter can be NULL.
		C.ReadConsoleA( h, ch, 1, count, nil )
		C.SetConsoleMode( h, mode[0] )
		return string.char(tonumber(ch[0]))
	end

  function yield()
    C.SwitchToThrea()
  end

  function sleep(millisec)
    C.Sleep(millisec)
  end

  function microsleep(microseconds)
		millisec = floor(microseconds/1000)
  	C.usleep (millisec)
  end

	function nanosleep(sec, nanosec)
		local millisec = sec * 1000
		millisec = floor(millisec + (nanosec/1000000))
		--if millisec < 1 then
		--	millisec = 0 -- Sleep(0), best we can do
		--end
		C.Sleep(millisec) -- better solution for windows?
	end

else -- OSX, Posix, Linux?

	function processorCoreCount()
		-- http://www.gnu.org/software/libc/manual/html_node/Processor-Resources.html
		local countConfigured = C.sysconf(C._SC_NPROCESSORS_CONF)
		local countOnline = C.sysconf(C._SC_NPROCESSORS_ONLN) -- returns int64_t
		return tonumber(countConfigured),tonumber(countOnline)
	end

	function waitKeyPressed()
    --http://lua.2524044.n2.nabble.com/How-to-get-one-keystroke-without-hitting-Enter-td5858614.html
    os.execute("stty cbreak </dev/tty >/dev/tty 2>&1")
    local key = io.read(1)
    os.execute("stty -cbreak </dev/tty >/dev/tty 2>&1");
    return(key);
  end

  function yield()
    C.sched_yield()
  end

  function sleep(millisec)
    --C.poll(nil, 0, millisec)
  	local microseconds = millisec * 1000
  	C.usleep (microseconds)
  end

  function microsleep(microseconds)
  	C.usleep (microseconds)
  end

	function nanosleep(sec, nanosec)
		if nanosec > 999999999 then
			print(" *** ERR: max nanosec to sleep is 999999999")
			nanosec = 999999999
		end
		local t = ffi.new("struct timespec", {tv_sec = sec, tv_nsec = nanosec})
		-- The value of the nanoseconds field must be in the range 0 to 999999999.
		return C.nanosleep(t, nil) -- assert(C.nanosleep(t, nil) == 0)
	end

end

function get_seconds( multiplier, prevMs )
	local returnValue64_c -- = ffi.new("int64_t")
	-- local returnValueMsb = 0
	-- local returnValueLsb = 0
	local returnValue = 0 -- lua double

	if isWin then
		--  Get the high resolution counter's accuracy.
		local ticksPerSecond = ffi.new("int64_t[1]")
		C.QueryPerformanceFrequency(ticksPerSecond)

		--  What time is it?
		local tick = ffi.new("int64_t[1]")
		C.QueryPerformanceCounter(tick)
		--  Convert the tick number into the number of seconds since the system was started.
		returnValue64_c = (tick[0] * 100000) / (ticksPerSecond[0] / 1000)
		--(tick.QuadPart * 100000) / (ticksPerSecond.QuadPart / 1000)
		-- time in microseconds
	else
		-- OSX, Posix, Linux?
		-- Use POSIX gettimeofday function to get precise time.
		local tv = ffi.new("struct timeval")
		local rc = C.gettimeofday (tv, nil)
		if rc ~= 0 then
			returnValue64_c = ffi.new("int64_t", -1) -- error here, we need to have returnValue64_c always ctype<int64_t>
		else
			returnValue64_c = (tonumber(tv.tv_sec) * 1000000) + tonumber(tv.tv_usec)
		end
	end

	--[[
	 in Lua 0x001fffffffffffff is the (about) biggest value that does not change when
	 converting to Lua double with 'tonumber(returnValue64_c)'
   returnValue64_c = bit.band(returnValue64_c, 0x00ffffff) -- get rid of highest bits
	 bit.band() does not work before Luajit 2.1 with 64 bit integers

	-- old way to get rid of highest bits, better to have unsigned int in timer:
	returnValue = tonumber(ffi.cast("uint32_t", returnValue64_c))
	]]
	returnValue = tonumber(ffi.cast("double", returnValue64_c))

	if isWin then
		if multiplier == 1 then
			returnValue = returnValue / 100000000  -- seconds -> microseconds
		elseif multiplier == 2 then
			returnValue = returnValue / 100000 -- seconds -> milliseconds
		else
			returnValue = returnValue / 100
		end
	else
  	-- OSX, Posix, Linux?
		if multiplier == 1 then
			returnValue = returnValue / 1000000 -- microseconds -> second
		elseif multiplier == 2 then
			returnValue = returnValue / 1000 -- microseconds -> milliseconds
		end
	end

	if prevMs then
		if prevMs > returnValue then
			returnValue = prevMs - returnValue
		else
			returnValue = returnValue - prevMs
		end
	end
  return returnValue
end

function seconds(prev_sec)
  return get_seconds(1, prev_sec)
end

function milliSeconds(prev_millisec)
  return get_seconds(2, prev_millisec)
end

function microSeconds(prev_microsec)
  return get_seconds(3, prev_microsec)
end

function directory_files(dirpath)
	local f
	if ffi.os == "Windows" then
		f = io.popen("dir /B "..dirpath)
	else
		f = io.popen("ls "..dirpath)
	end
	local txt = f:read("*a")
	local dir = {}
	for file in string.gmatch(txt, "[^\r\n]+") do
		dir[#dir+1] = file
	end
	return dir
end

-- === external (borrowed) utilities === --

function numStringLength( i )
  if (i < 10) then return 1 end
  if (i < 100) then return 2 end
  if (i < 1000) then return 3 end
  if (i < 10000) then return 4 end
  if (i < 100000) then return 5 end
  if (i < 1000000) then return 6 end
  if (i < 10000000) then return 7 end
  if (i < 100000000) then return 8 end
  if (i < 1000000000) then return 9 end
  return 100
end

-- add comma to separate thousands
function comma_value(amount, comma)
	comma = comma or ' ' -- in us comma = ','
	if comma == '' then comma = ' ' end -- must be something or will not work
  local formatted = amount

  local k
  while true do
    formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1' .. comma .. '%2')
    if (k==0) then
      break
    end
  end
  return formatted
end

function round(val, decimal)
  if decimal then
    return floor( (val * 10^decimal) + 0.5) / (10^decimal)
  else
    return floor(val+0.5)
  end
end

-- given a numeric value formats output with comma to separate thousands
-- and rounded to given decimal places
function format_num(amount, decimal, comma, prefix, neg_prefix)
  local formatted, famount, remain
  decimal = decimal or 2  -- default 2 decimal places
  comma = comma or ' '
  neg_prefix = neg_prefix or "-" -- default negative sign
  famount = math.abs(round(amount,decimal))
  famount = floor(famount)
  remain = round(math.abs(amount) - famount, decimal)
        -- comma to separate the thousands
  if( comma~='' ) then
  	formatted = comma_value(famount, comma)
  else
  	formatted = tostring(famount)
  end
        -- attach the decimal portion
  if (decimal > 0) then
    remain = string.sub(tostring(remain),3)
    formatted = formatted .. "." .. remain ..
                string.rep("0", decimal - string.len(remain))
  end
        -- attach prefix string e.g '$'
  formatted = (prefix or "") .. formatted
        -- if value is negative then format accordingly
  if (amount<0) then
    if (neg_prefix=="()") then
      formatted = "("..formatted ..")"
    else
      formatted = neg_prefix .. formatted
    end
  end
  return formatted
end

-- http://stackoverflow.com/questions/9754285/in-lua-how-do-you-find-out-the-key-an-object-is-stored-in
function table_invert(t)
  local u = { }
  for k,v in pairs(t) do u[v] = k end
  return u
end

-- http://lua-users.org/wiki/TableSerialization
--[[
   Author: Julio Manuel Fernandez-Diaz
   Date:   January 12, 2007
   (For Lua 5.1)

   Modified slightly by RiciLake to avoid the unnecessary table traversal in tablecount()

   Formats tables with cycles recursively to any depth.
   The output is returned as a string.
   References to other tables are shown as values.
   Self references are indicated.

   The string returned is "Lua code", which can be procesed
   (in the case in which indent is composed by spaces or "--").
   Userdata and function keys and values are shown as strings,
   which logically are exactly not equivalent to the original code.

   This routine can serve for pretty formating tables with
   proper indentations, apart from printing them:

      print(table_show(t, "t"))   -- a typical use

   Heavily based on "Saving tables with cycles", PIL2, p. 113.

   Arguments:
      t is the table.
      name is the name of the table (optional)
      indent is a first indentation (optional).
--]]
function table_show(t, name, indent)
   local cart     -- a container
   local autoref  -- for self references

   --[[ counts the number of elements in a table
   local function tablecount(t)
      local n = 0
      for _, _ in pairs(t) do n = n+1 end
      return n
   end
   ]]
   -- (RiciLake) returns true if the table is empty
   local function isemptytable(t) return next(t) == nil end

   local function basicSerialize (o)
      local so = tostring(o)
      if type(o) == "function" then
         local info = debug.getinfo(o, "S")
         -- info.name is nil because o is not a calling level
         if info.what == "C" then
            return string.format("%q", so .. ", C function")
         else
            -- the information is defined through lines
            return string.format("%q", so .. ", defined in (" ..
                info.linedefined .. "-" .. info.lastlinedefined ..
                ")" .. info.source)
         end
      elseif type(o) == "number" or type(o) == "boolean" then
         return so
      else
         return string.format("%q", so)
      end
   end

   local function addtocart (value, name, indent, saved, field)
      indent = indent or ""
      saved = saved or {}
      field = field or name

      cart = cart .. indent .. field

      if type(value) ~= "table" then
         cart = cart .. " = " .. basicSerialize(value) .. ";\n"
      else
         if saved[value] then
            cart = cart .. " = {}; -- " .. saved[value]
                        .. " (self reference)\n"
            autoref = autoref ..  name .. " = " .. saved[value] .. ";\n"
         else
            saved[value] = name
            --if tablecount(value) == 0 then
            if isemptytable(value) then
               cart = cart .. " = {};\n"
            else
               cart = cart .. " = {\n"
               for k, v in pairs(value) do
                  k = basicSerialize(k)
                  local fname = string.format("%s[%s]", name, k)
                  field = string.format("[%s]", k)
                  -- three spaces between levels
                  addtocart(v, fname, indent .. "   ", saved, field)
               end
               cart = cart .. indent .. "};\n"
            end
         end
      end
   end

   name = name or "__unnamed__"
   if type(t) ~= "table" then
      return name .. " = " .. basicSerialize(t)
   end
   cart, autoref = "", ""
   addtocart(t, name, indent)
   return cart .. autoref
end
