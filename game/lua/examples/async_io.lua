local ffi = require("ffi")
ffi.cdef("int ioctl(int fd, unsigned long request, ...);")
ffi.cdef([[
    typedef struct
    {
        long fds_bits[1024 / 64];
    } fd_set;
    FD_SET(int fd, fd_set *fdset);

    FD_CLR(int fd, fd_set *fdset);

    FD_ISSET(int fd, fd_set *fdset);

    void FD_ZERO(fd_set *fdset);
int select(int nfds, fd_set *readfds, fd_set *writefds, fd_set *exceptfds, struct timeval *timeout);]])
local p = assert(io.popen("sleep 1; echo 'aaa'"))
local fd = ffi.C.fileno(p)
local int = ffi.new("size_t[1]")

event.AddListener("Update", "", function()
	if ffi.C.ioctl(fd, 21531, int) == 0 and int[0] > 0 then
		print(p:read(tonumber(int[0])))
	end
end)

LOL = p