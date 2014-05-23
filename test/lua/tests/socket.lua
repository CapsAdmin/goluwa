local AF_UNSPEC = 0
local AF_INET = 2
local AF_IPX = 6
local AF_APPLETALK = 16
local AF_NETBIOS = 17
local AF_INET6 = 23
local AF_IRDA = 26
local AF_BTH = 32

local SOCK_STREAM = 1
local SOCK_DGRAM = 2
local SOCK_RAW = 3
local SOCK_RDM = 4
local SOCK_SEQPACKET = 5

local IPPROTO_ICMP = 1
local IPPROTO_IGMP = 2
local BTHPROTO_RFCOMM = 3
local IPPROTO_TCP = 6
local IPPROTO_UDP = 17
local IPPROTO_ICMPV6 = 58
local IPPROTO_RM = 113

local MSG_DONTWAIT = 0x40
local O_NONBLOCK  = 0x0004
local F_SETFL = 4
local F_GETFL = 3

local FIONBIO = 2147772030	

ffi.cdef([[
	typedef struct 
	{
		unsigned short family;
		char data[14];
	} sockaddr;
	
	struct in_addr {
		size_t s_addr;
	};
	
	typedef struct {
		short family;
		unsigned short port;
		struct in_addr addr;
		char zero[8];
	} sockaddr_in;

	int socket(int domain, int type, int protocol);
	int connect(int socket, const sockaddr *name, int name_length);
	
	int bind(int socket, const sockaddr_in *addr, size_t addrlen);
	int listen(int socket, int backlog);
	int accept(int socket, sockaddr *addr, size_t *addrlen);
	
	int16_t recv(int socket, char *buffer, size_t length, int flags);
	int16_t recvfrom(int socket, char *buffer, size_t length, int flags, sockaddr_in *src_addr, size_t *addrlen);
	
	int send(int socket, const char *buf, int len, int flags);
	int sendto(int socket, const char *buf, int len, int flags, sockaddr *to, int tolen);
	
	int getsockopt(int socket, int level, int optname, void *optval, size_t *optlen);
	int setsockopt(int socket, int level, int optname, const void *optval, size_t optlen);
	
	struct in_addr inet_addr(const char *cp);
	char *inet_ntoa(struct in_addr);
	unsigned short htons(uint16_t cp);
	uint16_t ntohs(unsigned short cp);
	
	int closesocket(int socket);
	int close(int socket);
]])

local lib

if WINDOWS then
	ffi.cdef([[
		int WSAGetLastError();
		int ioctlsocket(int socket, unsigned long cmd, unsigned long *argp);
	]])
	lib = ffi.load("Ws2_32.dll")
else
	ffi.cdef[[
		int fcntl(int fildes, int cmd, ...);
	]]
	lib = ffi.C
end

local check = function(v) if v < 0 then print(lib.WSAGetLastError()) error("fail: " .. v, 2) end return v end

local socket = check(lib.socket(AF_INET, SOCK_DGRAM, IPPROTO_UDP))

local info = ffi.new("const sockaddr_in[1]", ffi.new("sockaddr_in", {
	family = AF_INET, 
	addr = lib.inet_addr("192.168.0.10"),
	port = lib.htons(5552),
}))

lib.bind(socket, info, ffi.sizeof(info))

if LINUX then
	local flags = check(lib.fcntl(socket, F_GETFL, 0))
	check(lib.fcntl(socket, F_SETFL, bit.bor(flags, O_NONBLOCK)))
end

if WINDOWS then
	check(lib.ioctlsocket(socket, FIONBIO, ffi.new("unsigned long[1]", 1)))
	print(lib.WSAGetLastError())
end

local info = ffi.new("sockaddr_in[1]")

local buffer = ffi.new("char[512]")
local length = check(lib.recvfrom(socket, buffer, 512, MSG_DONTWAIT, info, ffi.new("size_t[1]", ffi.sizeof(info))))

if LINUX then
	lib.close(socket)
end

if WINDOWS then
	lib.closesocket(socket)
end

print(ffi.string(buffer, length), ffi.string(lib.inet_ntoa(info[0].addr)), lib.ntohs(info[0].port)) 
