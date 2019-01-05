-- lib_poll.lua
local ffi = require "ffi"

if jit.os == "Linux" then

	ffi.cdef[[
		static const int POLLERR = 0x008;
		static const int POLLHUP = 0x010;
		static const int POLLIN = 0x001;
		static const int POLLNVAL = 0x020;
		static const int POLLOUT = 0x004;

		struct pollfd
			{
				int fd;
				short int events;
				short int revents;
			};


		void free (void *__ptr);
		void *realloc (void *__ptr, size_t __size)
			;
	]]
		elseif jit.os == "OSX" then
			ffi.cdef[[
				static const int POLLERR = 0x0008;
				static const int POLLHUP = 0x0010;
				static const int POLLIN = 0x0001;
				static const int POLLNVAL = 0x0020;
				static const int POLLOUT = 0x0004;


				struct pollfd
				{
				 int fd;
				 short events;
				 short revents;
				};

				void free(void *);
				void *realloc(void *, size_t);
				]]
		elseif jit.os == "Windows" then

		end
module(..., package.seeall)

-- partly copied from: https://github.com/chatid/fend/blob/master/poll.lua

local C = ffi.C
local socket = require "ljsocket.lib_socket"
local bit = require "bit"
local band = bit.band
local bor = bit.bor
ffi.cdef[[
	void* calloc (size_t num, size_t size);
	void* realloc (void* ptr, size_t size);
	void free (void* ptr);
]]

local poll_event, in_callback, out_callback, close_callback, error_callback
local fds, nfds, pollCount
local fdsListSize, timeout, fdsListAddCount, debug_level
local fdAddCount, fdRemoveCount

local function clear_all()
  poll_event = nil
	in_callback = nil 		-- runs this function when data has come in
	out_callback = nil 		-- runs this function when you can write out
	close_callback = nil	-- runs this function when you need to close socket
	error_callback = nil	-- runs this function when error has happened
	fds = nil 			-- ffi.C memory area containing all (max. fdsListSize) "struct pollfd":s
	nfds = 0 				-- number of active fds
	pollCount = 0
	fdsListSize = 0 -- how many fd's can fit in to fds memory size
	timeout = 0
	fdsListAddCount = 10
	debug_level = 0
	fdAddCount = 0
	fdRemoveCount = 0
end
clear_all()

local function expand_fds(oldFds, countFds)
	print("poll.expand_fds: ", oldFds, countFds)
	local newFds
	if oldFds then
		ffi.gc(oldFds , nil)
		-- oldFds will be used in realloc, mut not garbage collect it, remove it's gc function
	end
	newFds = C.realloc(oldFds, ffi.sizeof("struct pollfd") * countFds)
	if newFds == nil then
		error("Cannot re-allocate memory (poll.expand_fds)")
	end
	local ret = ffi.cast("struct pollfd*", newFds)
	return ffi.gc(ret, ffi.C.free) -- assign ffi.C.free for garbage collect
end

local function fd_arr_index(fd)
	local idx = nfds - 1 -- better to loop from en, more likely to find correct
	while idx >= 0 do
		if fds[idx].fd == fd then return idx end
		idx = idx - 1
	end
	return -1
end

local function fd_arr_show()
	local idx = 0
	local txt = "fds["
	while idx < nfds do
		txt = txt..fds[idx].fd
		idx = idx + 1
		if idx < nfds then
			txt = txt..", "
		end
	end
	return txt.."], nfds="..nfds
end

function add_fd(fd, events)
	fdAddCount = fdAddCount + 1
	local idx = fd_arr_index(fd)
	if idx >= 0 then
		-- is old fd number, is ok when we reuse addresses ???
		print("ERR: Fd was already added to array (poll.add_fd): idx="..idx..", fd="..fd..", nfds="..nfds)
		print(fd_arr_show())
	else
		if nfds >= fdsListSize then -- expand nfds C memory area
			fdsListSize = fdsListSize + fdsListAddCount
			fds = expand_fds(fds, fdsListSize)
		end
	end
	fds[nfds].fd 			= fd -- set C struct pollfd field fd, same as fds[nfds].fd = fd
	fds[nfds].events 	= events -- bor(C.POLLIN, C.POLLOUT, C.POLLRDHUP)
	-- fds[nfds].revents 	= 0 -- no need to set
	nfds = nfds + 1 -- fds is C-mem area and 0-based, so add it only in the end
	if debug_level > 0 then print("  poll.add_fd: fd="..fd..", nfds="..nfds) end
end

function remove_fd(fd)
	fdRemoveCount = fdRemoveCount + 1
	local idx = fd_arr_index(fd)
	if idx < 0 then
		error("ERR: Fd was not found from array (poll.remove_fd): fd="..fd..", nfds="..nfds)
		print(fd_arr_show())
		return
	end
	if idx ~= nfds-1 then -- if not last item, move an item from end of list to fill the empty spot
		if debug_level > 0 then
			print("  poll.remove_fd from middle: idx=".. idx+1 ..", fd="..fd..", nfds="..nfds)
			print("  "..fd_arr_show())
		end
		nfds = nfds - 1 -- decrease nfds count so that fds[nfds] is zero-based
		local lastfd = fds[nfds].fd
		local lastevent = fds[nfds].events
		fds[idx].fd = lastfd
		fds[idx].events = lastevent
		if debug_level > 0 then
			print("  "..fd_arr_show())
		end
	else
		nfds = nfds - 1 -- decrease nfds count so that fds[nfds] is zero-based
		fds[idx].fd = -1
		if debug_level > 0 then
			print("  poll.remove_fd from end   : idx=".. idx+1 ..", fd="..fd..", nfds="..nfds)
			print("  "..fd_arr_show())
		end
	end
end


function remove_all(close_func)
	for i=0,nfds-1 do
		--print("poll.remove_all: ", fds[i].fd)
		close_func(fds[i].fd)
	end
	clear_all()
end

function poll_count()
	return pollCount
end

function fd_count()
	return nfds
end

function fd_add_count()
	return fdAddCount
end

function fd_remove_count()
	return fdRemoveCount
end

function timeout_set(timeOut)
	timeout = timeOut
end
function in_callback_set(func)
	in_callback = func
end
function out_callback_set(func)
	out_callback = func
end
function close_callback_set(func)
	close_callback = func
end
function error_callback_set(func)
	error_callback = func
end

	-- http://www.greenend.org.uk/rjk/tech/poll.html
	-- *** we use elseif here because id some event is really needed it will come on next poll *** --

local function poll_event_nodebug(evt, fd)

  if band(evt, C.POLLHUP) ~= 0 then

    close_callback(fd)

  elseif band(evt, C.POLLIN) ~= 0 then

    in_callback(fd)

  elseif band(evt, C.POLLOUT) ~= 0 then

    out_callback(fd)

  elseif band(evt, C.POLLNVAL) ~= 0 then

    error_callback(fd, "POLLNVAL")

  elseif band(evt, C.POLLERR) ~= 0 then

    error_callback(fd, "POLLERR")

  end

end



local function poll_event_debug(evt, fd, i)

  -- debug_level version, must be same ifs as above

  if band(evt, C.POLLHUP) ~= 0 then -- usually C.POLLIN | C.POLLHUP, but we don't want C.POLLIN

    -- POLLHUP, output only

    print("\n"..pollCount..". POLLHUP : idx="..i..", evt="..evt..", fd="..fd..", nfds="..nfds)

    close_callback(fd)

  elseif band(evt, C.POLLIN) ~= 0 then

    -- POLLIN

    print("\n"..pollCount..". POLLIN  : idx="..i..", evt="..evt..", fd="..fd..", nfds="..nfds)

    in_callback(fd)

  --[[elseif band(evt, C.POLLPRI) ~= 0 then

    --[ [POLLPRI	Priority data may be read without blocking. This flag is not supported by the Microsoft Winsock provider.] ]

    if debug_level > 0 then print(pollCount..". POLLPRI : idx="..i..", evt="..evt..", fd="..fd..", nfds="..nfds) end

    in_callback(fd)]]

  elseif band(evt, C.POLLOUT) ~= 0 then

    -- POLLOUT

    -- because we exclude POLLHUP and POLLIN we cand exclude POLLOUT

    print("\n"..pollCount..". POLLOUT : idx="..i..", evt="..evt..", fd="..fd..", nfds="..nfds)

    out_callback(fd)

  elseif band(evt, C.POLLNVAL) ~= 0 then

    -- POLLNVAL, output only

    print("\n"..pollCount..". POLLNVAL: idx="..i..", evt="..evt..", fd="..fd..", nfds="..nfds)

    error_callback(fd, "POLLNVAL")

  elseif band(evt, C.POLLERR) ~= 0 then

    -- POLLERR, output only

    print("\n"..pollCount..". POLLERR : idx="..i..", evt="..evt..", fd="..fd..", nfds="..nfds)

    error_callback(fd, "POLLERR")

  end

  --[[elseif band(evt, C.POLLRDHUP) ~= 0 then

    -- POLLRDHUP

    if debug_level > 0 then print(pollCount..". POLLRDHUP: idx="..i..", evt="..evt..", fd="..fd..", nfds="..nfds) end

    close_callback(fd)

  end]]

end


function debug_level_set(level)

	debug_level = level

  if debug_level > 0 then

    poll_event = poll_event_debug -- change to debug function

  else

    poll_event = poll_event_nodebug -- change to debug function

  end

	print("poll debug level:  "..debug_level, poll_event)

end


function poll()
	pollCount = pollCount + 1
	local ret = socket.poll(fds, nfds, timeout)
	if ret == -1 then
		print(pollCount..". poll, nfds="..nfds)
		socket.cleanup(fds[0].fd, ret, "socket.poll failed with error: ")
	elseif ret == 0 then
		return 0
	end

	-- loop all events, break loop as soon as possible
	local served = 0
	for i=1,nfds do
		local evt = fds[i-1].revents
		if evt~= 0 then
			local fd = fds[i-1].fd
			poll_event(evt, fd, i)
		end
		if served == ret then break end -- break loop as soon as possible
	end

	return ret
end
