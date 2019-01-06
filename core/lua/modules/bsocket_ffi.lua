--[[
    berkeley sockets with unix and windows support

    the goal is to provide a minimal abstraction for
    the socket api and hide platform differences

    this file is not intended to be used as an api
    but rather as a building block for a higher level
    api
]]

local module = {}
local ffi = require("ffi")
local lib

local function generic_function(lib_name, cdef, alias, size_error_handling)
    ffi.cdef(cdef)

    alias = alias or lib_name
    local func_name = "socket_" .. alias
    local func = lib[lib_name]

    if size_error_handling == false then
        module[func_name] = func
    elseif size_error_handling then
        module[func_name] = function(...)
            local len = func(...)

            if len < 0 then
                return nil, module.lasterror()
            end

            return len
        end
    else
        module[func_name] = function(...)
            local ret = func(...)

            if ret == 0 then
                return true
            end

            return nil, module.lasterror()
        end
    end
end

ffi.cdef([[
    struct sockaddr {
        unsigned short sa_family;
        char sa_data[14];
    };

    struct in_addr
    {
        uint32_t s_addr;
    };

    int getaddrinfo(char const *node, char const *service, struct addrinfo const *hints, struct addrinfo **res);
    int getnameinfo(const struct sockaddr* sa, uint32_t salen, char* host, size_t hostlen, char* serv, size_t servlen, int flags);
    void freeaddrinfo(struct addrinfo *ai);
    const char *gai_strerror(int errcode);
    char *inet_ntoa(struct in_addr in);
    uint16_t ntohs(uint16_t netshort);
]])

function module.getaddrinfo(node_name, service_name, hints, result)
    local ret = lib.getaddrinfo(node_name, service_name, hints, result)
    if ret == 0 then
        return true
    end

    return nil, ffi.string(lib.gai_strerror(ret))
end

function module.getnameinfo(address, length, host, hostlen, serv, servlen, flags)
    local ret = lib.getnameinfo(address, length, host, hostlen, serv, servlen, flags)
    if ret == 0 then
        return true
    end

    return nil, ffi.string(lib.gai_strerror(ret))
end

do
    ffi.cdef("const char *inet_ntop(int __af, const void *__cp, char *__buf, unsigned int __len);")

    function module.inet_ntop(family, addrinfo, strptr, strlen)
        if lib.inet_ntop(family, addrinfo, strptr, strlen) == nil then
            return nil, module.lasterror()
        end

        return strptr
    end
end


if jit.os == "Windows" then
    ffi.cdef([[
        typedef uint64_t SOCKET;

        struct addrinfo
        {
            int ai_flags;
            int ai_family;
            int ai_socktype;
            int ai_protocol;
            size_t ai_addrlen;
            char *ai_canonname;
            struct sockaddr *ai_addr;
            struct addrinfo *ai_next;
        };

        struct sockaddr_in {
            int16_t sin_family;
            uint16_t sin_port;
            struct in_addr sin_addr;
            uint8_t sin_zero[8];
        };
    ]])

    module.INVALID_SOCKET = ffi.new("SOCKET", -1)

    lib = ffi.load("ws2_32")

    local function WORD(low, high)
        return bit.bor(low , bit.lshift(high , 8))
    end

    do
        ffi.cdef("int GetLastError();")

        local FORMAT_MESSAGE_FROM_SYSTEM = 0x00001000
        local FORMAT_MESSAGE_IGNORE_INSERTS = 0x00000200
        local flags = bit.bor(FORMAT_MESSAGE_IGNORE_INSERTS, FORMAT_MESSAGE_FROM_SYSTEM)

        local cache = {}

        function module.lasterror(num)
            num = num or ffi.C.GetLastError()

            if not cache[num] then
                local buffer = ffi.new("char[512]")
                ffi.C.FormatMessageA(flags, nil, num, 0, buffer, ffi.sizeof(buffer), nil)
                cache[num] = string.sub(ffi.string(buffer), 1, -3).." ("..num..")" -- remove last crlf
            end

            return cache[num]
        end
    end

    do
        ffi.cdef("int WSAStartup(uint16_t version, void *wsa_data);")

        local wsa_data

        if jit.arch == "x64" then
            wsa_data = ffi.typeof([[struct {
                uint16_t wVersion;
                uint16_t wHighVersion;
                unsigned short iMaxmodule;
                unsigned short iMaxUdpDg;
                char * lpVendorInfo;
                char szDescription[257];
                char szSystemStatus[129];
            }]])
        else
            wsa_data = ffi.typeof([[struct {
                uint16_t wVersion;
                uint16_t wHighVersion;
                char szDescription[257];
                char szSystemStatus[129];
                unsigned short iMaxmodule;
                unsigned short iMaxUdpDg;
                char * lpVendorInfo;
            }]])
        end

        function module.initialize()
            local data = wsa_data()

            if lib.WSAStartup(WORD(2, 2), data) == 0 then
                return data
            end

            return nil, module.lasterror()
        end
    end

    do
        ffi.cdef("int WSACleanup();")

        function module.shutdown()
            if lib.WSACleanup() == 0 then
                return true
            end

            return nil, module.lasterror()
        end
    end

    if jit.arch ~= "x64" then -- xp or something
        ffi.cdef("int WSAAddressToStringA(struct sockaddr *, unsigned long, void *, char *, unsigned long *);")

        function module.inet_ntop(family, pAddr, strptr, strlen)
            -- win XP: http://memset.wordpress.com/2010/10/09/inet_ntop-for-win32/
            local srcaddr = ffi.new("struct sockaddr_in")
            ffi.copy(srcaddr.sin_addr, pAddr, ffi.sizeof(srcaddr.sin_addr))
            srcaddr.sin_family = family
            local len = ffi.new("unsigned long[1]", strlen)
            return lib.WSAAddressToStringA(ffi.cast("struct sockaddr *", srcaddr), ffi.sizeof(srcaddr), nil, strptr, len)
        end
    end

    function module.wouldblock()
        return ffi.C.GetLastError() == 10035
    end

    generic_function("closesocket", "int closesocket(SOCKET s);", "close")

    do
        ffi.cdef("int ioctlsocket(SOCKET s, long cmd, unsigned long* argp);")

        local IOCPARM_MASK    = 0x7
        local IOC_IN          = 0x80000000
        local function _IOW(x,y,t)
            return bit.bor(IOC_IN, bit.lshift(bit.band(ffi.sizeof(t),IOCPARM_MASK),16), bit.lshift(x,8), y)
        end

        local FIONBIO = _IOW(string.byte'f', 126, "uint32_t") -- -2147195266 -- 2147772030ULL

        function module.socket_blocking(fd, b)
            local ret = lib.ioctlsocket(fd, FIONBIO, ffi.new("int[1]", b and 0 or 1))
            if ret == 0 then
                return true
            end

            return nil, module.lasterror()
        end
    end
else
    ffi.cdef([[
        typedef int SOCKET;

        struct addrinfo {
			int ai_flags;
			int ai_family;
			int ai_socktype;
			int ai_protocol;
			unsigned int ai_addrlen;
			struct sockaddr *ai_addr;
			char *ai_canonname;
			struct addrinfo *ai_next;
        };


        struct sockaddr_in {
            uint8_t sin_len;
            unsigned short sin_family;
            uint16_t sin_port;
            struct in_addr sin_addr;
            char sin_zero[8];
        };

    ]])
    lib = ffi.C

    module.INVALID_SOCKET = -1

    do
        local cache = {}

        function module.lasterror(num)
            num = num or ffi.errno()

            if not cache[num] then
                local err = ffi.string(ffi.C.strerror(num))
                cache[num] = err == "" and tostring(num) or err
            end

            return cache[num]
        end
    end

    generic_function("close", "int close(SOCKET s);")

    do
        ffi.cdef("int fcntl(int, int, ...);")

        local F_GETFL = 3
        local F_SETFL = 4
        local O_NONBLOCK = 04000

        function module.socket_blocking(fd, b)
            local flags = ffi.C.fcntl(fd, F_GETFL, 0)

            if flags < 0 then
                -- error
                return nil, module.lasterror()
            end

            if b then
                flags = bit.band(flags, bit.bnot(O_NONBLOCK))
            else
                flags = bit.bor(flags, O_NONBLOCK)
            end

            local ret = ffi.C.fcntl(fd, F_SETFL, ffi.new("int", flags))

            if ret < 0 then
                return nil, module.lasterror()
            end

            return true
        end
    end

    function module.wouldblock()
        local err = ffi.errno()
        return err == 11 or err == 115 or err == 114
    end
end

do
    ffi.cdef("SOCKET socket(int af, int type, int protocol);")

    function module.socket(af, type, protocol)
        local fd = lib.socket(af, type, protocol)

        if fd <= 0 then
            return nil, module.lasterror()
        end

        return fd
    end
end

generic_function("shutdown", "int shutdown(SOCKET s, int how);")

generic_function("setsockopt", "int setsockopt(SOCKET s, int level, int optname, const void* optval, uint32_t optlen);")
generic_function("getsockopt", "int getsockopt(SOCKET s, int level, int optname, void *optval, uint32_t *optlen);")

generic_function("accept", "SOCKET accept(SOCKET s, struct sockaddr *, int *);", nil, false)
generic_function("bind", "int bind(SOCKET s, const struct sockaddr* name, int namelen);")
generic_function("connect", "int connect(SOCKET s, const struct sockaddr * name, int namelen);")

generic_function("listen", "int listen(SOCKET s, int backlog);")
generic_function("recv", "int recv(SOCKET s, char* buf, int len, int flags);", nil, true)

generic_function("send", "int send(SOCKET s, const char* buf, int len, int flags);", nil, true)
generic_function("sendto", "int sendto(SOCKET s, const char* buf, int len, int flags, const struct sockaddr* to, int tolen);", nil, true)

generic_function("getpeername", "int getpeername(SOCKET s, struct sockaddr *, unsigned int *);")
generic_function("getsockname", "int getsockname(SOCKET s, struct sockaddr *, unsigned int *);")

module.inet_ntoa = lib.inet_ntoa
module.ntohs = lib.ntohs

local e = {}

if jit.os == "Windows" then
    module.e = {
        SOL_SOCKET = 0xffff,
        SO_DEBUG = 0x0001,
        SOMAXCONN =  0x7fffffff,
        SO_ACCEPTCONN = 0x0002,
        SO_REUSEADDR = 0x0004,
        SO_KEEPALIVE = 0x0008,
        SO_DONTROUTE = 0x0010,
        SO_BROADCAST = 0x0020,
        SO_USELOOPBACK = 0x0040,
        SO_LINGER = 0x0080,
        SO_OOBINLINE = 0x0100,
        SO_DONTLINGER = bit,
        SO_EXCLUSIVEADDRUSE = bit,
        SO_SNDBUF =  0x1001,
        SO_RCVBUF =  0x1002,
        SO_SNDLOWAT =  0x1003,
        SO_RCVLOWAT =  0x1004,
        SO_SNDTIMEO =  0x1005,
        SO_RCVTIMEO =  0x1006,
        SO_ERROR =  0x1007,
        SO_TYPE =  0x1008,
        SO_CONNECT_TIME = 0x700C,
        SOCKET_ERROR = -1,
        INADDR_ANY = 0x00000000,
        INADDR_LOOPBACK = 0x7f000001,
        INADDR_BROADCAST = 0xffffffff,
        INADDR_NONE = 0xffffffff,
        INET_ADDRSTRLEN = 16,
        INET6_ADDRSTRLEN = 46,
        SOCK_STREAM = 1,
        SOCK_DGRAM = 2,
        SOCK_RAW = 3,
        SOCK_RDM = 4,
        SOCK_SEQPACKET = 5,
        AF_UNSPEC = 0,
        AF_UNIX = 1,
        AF_INET = 2,
        AF_IMPLINK = 3,
        AF_PUP = 4,
        AF_CHAOS = 5,
        AF_IPX = 6,
        AF_NS = 6,
        AF_ISO = 7,
        AF_OSI = AF_ISO,
        AF_ECMA = 8,
        AF_DATAKIT = 9,
        AF_CCITT = 10,
        AF_SNA = 11,
        AF_DECnet = 12,
        AF_DLI = 13,
        AF_LAT = 14,
        AF_HYLINK = 15,
        AF_APPLETALK = 16,
        AF_NETBIOS = 17,
        AF_VOICEVIEW = 18,
        AF_FIREFOX = 19,
        AF_UNKNOWN1 = 20,
        AF_BAN = 21,
        AF_INET6 = 23,
        AF_IRDA = 26,
        AF_NETDES = 28,
        AF_TCNPROCESS = 29,
        AF_TCNMESSAGE = 30,
        AF_ICLFXBM = 31,
        AF_BTH = 32,
        AF_LINK = 33,
        AF_MAX = 34,
        IPPROTO_IP = 0,
        IPPROTO_ICMP = 1,
        IPPROTO_IGMP = 2,
        IPPROTO_GGP = 3,
        IPPROTO_TCP = 6,
        IPPROTO_PUP = 12,
        IPPROTO_UDP = 17,
        IPPROTO_IDP = 22,
        IPPROTO_RDP = 27,
        IPPROTO_IPV6 = 41,
        IPPROTO_ROUTING = 43,
        IPPROTO_FRAGMENT = 44,
        IPPROTO_ESP = 50,
        IPPROTO_AH = 51,
        IPPROTO_ICMPV6 = 58,
        IPPROTO_NONE = 59,
        IPPROTO_DSTOPTS = 60,
        IPPROTO_ND = 77,
        IPPROTO_ICLFXBM = 78,
        IPPROTO_PIM = 103,
        IPPROTO_PGM = 113,
        IPPROTO_RM = 113,
        IPPROTO_L2TP = 115,
        IPPROTO_SCTP = 132,
        IPPROTO_RAW = 255,
        IP_OPTIONS = 1,
        IP_MULTICAST_IF = 2,
        IP_MULTICAST_TTL = 3,
        IP_MULTICAST_LOOP = 4,
        IP_ADD_MEMBERSHIP = 5,
        IP_DROP_MEMBERSHIP = 6,
        IP_TTL = 7,
        IP_TOS = 8,
        IP_DONTFRAGMENT = 9,
        AI_PASSIVE = 0x00000001,
        AI_CANONNAME = 0x00000002,
        AI_NUMERICHOST = 0x00000004,
        AI_NUMERICSERV = 0x00000008,
        AI_ALL = 0x00000100,
        AI_ADDRCONFIG = 0x00000400,
        AI_V4MAPPED = 0x00000800,
        AI_NON_AUTHORITATIVE = 0x00004000,
        AI_SECURE = 0x00008000,
        AI_RETURN_PREFERRED_NAMES = 0x00010000,
        AI_FQDN = 0x00020000,
        AI_FILESERVER = 0x00040000,
    }
elseif jit.os == "Linux" then
    module.e = {
        PF_INET = 2,
	    PF_INET6 = 10,
	    AF_INET = 2,
	    AF_INET6 = 10,
	    AI_PASSIVE = 0x0001,
	    INET6_ADDRSTRLEN = 46,
	    INET_ADDRSTRLEN = 16,
	    SO_RCVBUF = 8,
	    SO_REUSEADDR = 2,
	    SO_SNDBUF = 7,
	    SOL_SOCKET = 1,
	    SOMAXCONN = 128,
        TCP_NODELAY = 1,
        IPPROTO_IP = 0,
        IPPROTO_HOPOPTS = 0,
        IPPROTO_ICMP = 1,
        IPPROTO_IGMP = 2,
        IPPROTO_IPIP = 4,
        IPPROTO_TCP = 6,
        IPPROTO_EGP = 8,
        IPPROTO_PUP = 12,
        IPPROTO_UDP = 17,
        IPPROTO_IDP = 22,
        IPPROTO_TP = 29,
        IPPROTO_DCCP = 33,
        IPPROTO_IPV6 = 41,
        IPPROTO_ROUTING = 43,
        IPPROTO_FRAGMENT = 44,
        IPPROTO_RSVP = 46,
        IPPROTO_GRE = 47,
        IPPROTO_ESP = 50,
        IPPROTO_AH = 51,
        IPPROTO_ICMPV6 = 58,
        IPPROTO_NONE = 59,
        IPPROTO_DSTOPTS = 60,
        IPPROTO_MTP = 92,
        IPPROTO_ENCAP = 98,
        IPPROTO_PIM = 103,
        IPPROTO_COMP = 108,
        IPPROTO_SCTP = 132,
        IPPROTO_UDPLITE = 136,
        IPPROTO_RAW = 255,
        SOCK_STREAM = 1,
        SOCK_DGRAM = 2,
        SOCK_RAW = 3,
        SOCK_RDM = 4,
        SOCK_SEQPACKET = 5,
        SOCK_DCCP = 6,
        SOCK_PACKET = 10,
        SOCK_CLOEXEC = 02000000,
        SOCK_NONBLOCK = 04000,
        AI_PASSIVE = 0x00000001,
        AI_CANONNAME = 0x00000002,
        AI_NUMERICHOST = 0x00000004,
        AI_NUMERICSERV = 0x00000008,
        AI_ALL = 0x00000100,
        AI_ADDRCONFIG = 0x00000400,
        AI_V4MAPPED = 0x00000800,
        AI_NON_AUTHORITATIVE = 0x00004000,
        AI_SECURE = 0x00008000,
        AI_RETURN_PREFERRED_NAMES = 0x00010000,
        AI_FQDN = 0x00020000,
        AI_FILESERVER = 0x00040000,
    }
end

return module