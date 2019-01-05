--  lib_socket.lua
local ffi = require("ffi")

if jit.os == "Linux" then

	ffi.cdef[[
		uint32_t htonl(uint32_t hostlong);
		uint16_t htons(uint16_t hostshort);
		uint32_t ntohl(uint32_t netlong);
		uint16_t ntohs(uint16_t netshort);

		int close (int __fd);



		struct in6_addr
		{
			union
			{
				uint8_t	__u6_addr8[16];
				uint16_t __u6_addr16[8];
				uint32_t __u6_addr32[4];
			} __in6_u;
		};

		static const int F_GETFL = 3;
		static const int F_SETFL = 4;
		static const int O_NONBLOCK = 04000;


		static const int  SO_KEEPALIVE	= 9;		/* keep connections alive */
		static const int  SO_DONTROUTE	= 5;		/* just use interface addresses */

		static const int SO_RCVTIMEO = 20;
		static const int SO_SNDTIMEO = 21;
		struct timeval {
			long tv_sec;
			long tv_usec;
		};

		typedef uint32_t in_addr_t;
		typedef unsigned short int sa_family_t;
		typedef unsigned long int nfds_t;
		typedef uint16_t in_port_t;

		typedef int __ssize_t;
		struct sockaddr
		{
			sa_family_t sa_family;
			char sa_data[14];
		};

		typedef __ssize_t ssize_t;
		struct in_addr
		{
			in_addr_t s_addr;
		};

		typedef unsigned int __socklen_t;
		typedef __socklen_t socklen_t;
		struct sockaddr_in
		{
			sa_family_t sin_family;
			in_port_t sin_port;
			struct in_addr sin_addr;
			unsigned char sin_zero[sizeof (struct sockaddr) -
			(sizeof (unsigned short int)) -
			sizeof (in_port_t) -
			sizeof (struct in_addr)];
		};

		struct addrinfo
		{
		int ai_flags;
		int ai_family;
		int ai_socktype;
		int ai_protocol;
		socklen_t ai_addrlen;
		struct sockaddr *ai_addr;
		char *ai_canonname;
		struct addrinfo *ai_next;
		};


		int accept (int __fd, struct sockaddr *__addr,
		socklen_t *__addr_len);
		int bind (int __fd, const struct sockaddr * __addr, socklen_t __len)
		;
		int connect (int __fd, const struct sockaddr * __addr, socklen_t __len);
		int fcntl (int __fd, int __cmd, ...);
		const char *gai_strerror (int __ecode);
		int getaddrinfo (const char *__name,
	const char *__service,
	const struct addrinfo *__req,
	struct addrinfo **__pai);
		int getnameinfo (const struct sockaddr *__sa,
	socklen_t __salen, char *__host,
	socklen_t __hostlen, char *__serv,
	socklen_t __servlen, int __flags);
		int getpeername (int __fd, struct sockaddr *__addr,
	socklen_t *__len);
		int getsockopt (int __fd, int __level, int __optname,
			void *__optval,
			socklen_t *__optlen);
		uint16_t htons (uint16_t __hostshort)
		;
		const char *inet_ntop (int __af, const void *__cp,
		char *__buf, socklen_t __len)
		;
		int listen (int __fd, int __n);
		uint16_t ntohs (uint16_t __netshort)
		;
		int poll (struct pollfd *__fds, nfds_t __nfds, int __timeout);
		ssize_t recv (int __fd, void *__buf, size_t __n, int __flags);
		ssize_t send (int __fd, const char *__buf, size_t __n, int __flags);
		int setsockopt (int __fd, int __level, int __optname,
			const void *__optval, socklen_t __optlen);
		int shutdown (int __fd, int __how);
		int socket (int __domain, int __type, int __protocol);
	]]
elseif jit.os == "OSX" then
		ffi.cdef[[

			static const int SOL_SOCKET = 0xffff;


			// Option flags per-socket.
			static const int  SO_DEBUG	= 0x0001;		/* turn on debugging info recording */
			static const int  SO_ACCEPTCONN	= 0x0002;		/* socket has had listen() */
			static const int  SO_REUSEADDR	= 0x0004;		/* allow local address reuse */
			static const int  SO_KEEPALIVE	= 0x0008;		/* keep connections alive */
			static const int  SO_DONTROUTE	= 0x0010;		/* just use interface addresses */
			static const int  SO_BROADCAST	= 0x0020;		/* permit sending of broadcast msgs */
			// #if !defined(_POSIX_C_SOURCE) || defined(_DARWIN_C_SOURCE)
			static const int  SO_USELOOPBACK	= 0x0040;		/* bypass hardware when possible */
			static const int  SO_LINGER	= 0x0080;          /* linger on close if data present (in ticks) */
			// #else
			// static const int  SO_LINGER	= 0x1080;          /* linger on close if data present (in seconds) */
			// #endif	/* (!_POSIX_C_SOURCE || _DARWIN_C_SOURCE) */
			static const int  SO_OOBINLINE	= 0x0100;		/* leave received OOB data in line */
			// #if !defined(_POSIX_C_SOURCE) || defined(_DARWIN_C_SOURCE)
			static const int  SO_REUSEPORT	= 0x0200;		/* allow local address & port reuse */
			static const int  SO_TIMESTAMP	= 0x0400;		/* timestamp received dgram traffic */
			static const int  SO_TIMESTAMP_MONOTONIC	= 0x0800;	/* Monotonically increasing timestamp on rcvd dgram */
			// #ifndef __APPLE__
			// static const int  SO_ACCEPTFILTER	= 0x1000;		/* there is an accept filter */
			// #else
			static const int  SO_DONTTRUNC	= 0x2000;		/* APPLE: Retain unread data */
							/*  (ATOMIC proto) */
			static const int  SO_WANTMORE	= 0x4000;		/* APPLE: Give hint when more data ready */
			static const int  SO_WANTOOBFLAG	= 0x8000;		/* APPLE: Want OOB in MSG_FLAG on receive */
			// #endif  /* (!__APPLE__) */
			// #endif	/* (!_POSIX_C_SOURCE || _DARWIN_C_SOURCE) */

			/* Structure describing a generic socket address.  */
			struct sockaddr {
				uint8_t	sa_len;		/* total length */
				sa_family_t	sa_family;	/* [XSI] address family */
				char		sa_data[14];	/* [XSI] addr value (actually larger) */
			};
			struct addrinfo {
				int ai_flags;           /* input flags. AI_PASSIVE, AI_CANONNAME, AI_NUMERICHOST */
				int ai_family;          /* protocol family for socket. PF_xxx */
				int ai_socktype;        /* socket type. SOCK_xxx */
				int ai_protocol;        /* protocol for socket, 0 or IPPROTO_xxx for IPv4 and IPv6 */
				socklen_t ai_addrlen;   /* length of socket-address, length of ai_addr */
				char *ai_canonname;     /* canonical name for service location, canonical name for hostname */
				struct sockaddr *ai_addr; /* socket-address for socket, binary address */
				struct addrinfo *ai_next; /* pointer to next in list, next structure in linked list */
			 };
		]]
		ffi.cdef[[
			uint32_t htonl(uint32_t hostlong);
			uint16_t htons(uint16_t hostshort);
			uint32_t ntohl(uint32_t netlong);
			uint16_t ntohs(uint16_t netshort);

			static const int F_GETFL = 3;
			static const int F_SETFL = 4;
			static const int O_NONBLOCK = 0x0004;

			typedef long __darwin_ssize_t;
			typedef uint8_t sa_family_t;
			typedef unsigned int nfds_t;
			typedef uint32_t __darwin_socklen_t;
			typedef uint16_t in_port_t;

			typedef __darwin_ssize_t ssize_t;

			struct sockaddr {
			 uint8_t sa_len;
			 sa_family_t sa_family;
			 char sa_data[14];
			};
			struct in_addr sin_addr;
			typedef __darwin_socklen_t socklen_t;

			struct sockaddr_in {
			 uint8_t sin_len;
			 sa_family_t sin_family;
			 in_port_t sin_port;
			 struct in_addr sin_addr;
			 char sin_zero[8];
			};

			struct addrinfo {
			 int ai_flags;
			 int ai_family;
			 int ai_socktype;
			 int ai_protocol;
			 socklen_t ai_addrlen;
			 char *ai_canonname;
			 struct sockaddr *ai_addr;
			 struct addrinfo *ai_next;
			};

			int accept(int, struct sockaddr * , socklen_t * );
			int bind(int, const struct sockaddr *, socklen_t);
			int connect(int, const struct sockaddr *, socklen_t);
			int fcntl(int, int, ...);
			const char *gai_strerror(int);

			int getaddrinfo(const char * , const char * ,
				   const struct addrinfo * ,
				   struct addrinfo ** );

			int getnameinfo(const struct sockaddr * , socklen_t,
					 char * , socklen_t, char * ,
					 socklen_t, int);
			int getpeername(int, struct sockaddr * , socklen_t * );
			int getsockopt(int, int, int, void * , socklen_t * );
			const char *inet_ntop(int, const void *, char *, socklen_t);
			int listen(int, int);
			int poll (struct pollfd *, nfds_t, int);
			ssize_t recv(int, void *, size_t, int);
			ssize_t send(int, const char *, size_t, int);
			int setsockopt(int, int, int, const void *, socklen_t);
			int shutdown(int, int);
			int socket(int, int, int);
			]]
elseif jit.os == "Windows" then
	require "ljsocket.win_socket"

		ffi.cdef[[
			typedef struct _GUID {
				unsigned long Data1;
				unsigned short Data2;
				unsigned short Data3;
				unsigned char Data4[ 8 ];
			} GUID;

			typedef void *PVOID;
			typedef int socklen_t;



			SOCKET
			accept(
				SOCKET s,
				struct sockaddr * addr,
				int * addrlen
				);

			int
			bind(
				SOCKET s,
				const struct sockaddr * name,
				int namelen
				);

			int
			closesocket(
				SOCKET s
				);

			int
			connect(
				SOCKET s,
				const struct sockaddr * name,
				int namelen
				);

			INT
			getaddrinfo(
				PCSTR pNodeName,
				PCSTR pServiceName,
				const ADDRINFOA * pHints,
				PADDRINFOA * ppResult
				);

			INT
			getnameinfo(
				const SOCKADDR * pSockaddr,
				socklen_t SockaddrLength,
				PCHAR pNodeBuffer,
				DWORD NodeBufferSize,
				PCHAR pServiceBuffer,
				DWORD ServiceBufferSize,
				INT Flags
				);

			int
			getpeername(
				SOCKET s,
				struct sockaddr * name,
				int * namelen
				);

			int
			getsockopt(
				SOCKET s,
				int level,
				int optname,
				char * optval,
				int * optlen
				);

			u_short
			htons(
				u_short hostshort
				);

			PCSTR
			inet_ntop(
				INT Family,
				PVOID pAddr,
				PSTR pStringBuf,
				size_t StringBufSize
				);

			int
			ioctlsocket(
				SOCKET s,
				long cmd,
				u_long * argp
				);

			int
			listen(
				SOCKET s,
				int backlog
				);

			u_short
			ntohs(
				u_short netshort
				);

			int
			recv(
				SOCKET s,
				char * buf,
				int len,
				int flags
				);

			int
			send(
				SOCKET s,
				const char * buf,
				int len,
				int flags
				);

			int
			setsockopt(
				SOCKET s,
				int level,
				int optname,
				const char * optval,
				int optlen
				);

			int
			shutdown(
				SOCKET s,
				int how
				);

			SOCKET
			socket(
				int af,
				int type,
				int protocol
				);

			INT
			WSAAddressToStringA(
				LPSOCKADDR lpsaAddress,
				DWORD dwAddressLength,
				LPWSAPROTOCOL_INFOA lpProtocolInfo,
				LPSTR lpszAddressString,
				LPDWORD lpdwAddressStringLength
				);

			int
			WSACleanup(
				void
				);

			int
			WSAGetLastError(
				void
				);

			int
			WSAPoll(
				LPWSAPOLLFD fdArray,
				ULONG fds,
				INT timeout
				);

			int
			WSAStartup(
				WORD wVersionRequested,
				LPWSADATA lpWSAData
				);
			]]
	end

module(..., package.seeall)

local C = ffi.C
local bit = require("bit")

local lshift = bit.lshift
local rshift = bit.rshift
local band = bit.band
local bor = bit.bor
local bnot = bit.bnot
local bswap = bit.bswap

local s
if jit.os == "Windows" then
	ffi.cdef[[
		int WSAPoll(LPWSAPOLLFD fdArray, ULONG fds, INT timeout);
	]]
	s = ffi.load("ws2_32")
else
	-- unix
	s = C
end
local err_prefix = "  SOCKET ERROR: "
function error_prefix_text_set(errTxt)
	err_prefix = errTxt
end

if jit.os == "Windows" then
	INVALID_SOCKET = ffi.new("SOCKET", -1)
else
	INVALID_SOCKET = -1
end

SOCKET_ERROR	= -1	-- 0xffffffff

local function MAKEWORD(low,high)
	return bor(low , lshift(high , 8))
end

local function LOWBYTE(word)
	return band(word, 0xff)
end

local function HIGHBYTE(word)
	return band(rshift(word,8), 0xff)
end

if jit.os == "Windows" then
	function errortext(err)
		return require("lib_util").win_errortext(err)
	end
	function initialize()
		local wsadata
		if jit.arch == "x64" then
			wsadata = ffi.new("WSADATA64[1]")
		else
			wsadata = ffi.new("WSADATA[1]")
		end
		local wVersionRequested = ffi.cast("WORD", MAKEWORD(2, 2))
		local err = s.WSAStartup(wVersionRequested, wsadata)
		if err ~= 0 then
			print(err_prefix.."WSAStartup failed with error code: "..err)
		elseif s.WSAGetLastError() ~= 0 then
			print(err_prefix.."WSAStartup failed with error code: "..s.WSAGetLastError())
		end
    --print(err_prefix.."WSAStartup: ".. err)
		return err -- err,wsadata[0]
	end
	function poll(fdArray, fds, timeout)
		return s.WSAPoll(fdArray, fds, timeout)
	end
	function close(socket)
		local socket_c = ffi.cast("int", socket)
		return s.closesocket(socket_c)
	end
	function cleanup(socket, errnum, errtext)
		-- get WSAGetLastError() before close and WSACleanup
		local wsa_err_num = s.WSAGetLastError()
		local	wsa_err_text = errortext(wsa_err_num)
		if errnum and errnum ~= -1 and errnum ~= wsa_err_num then
			wsa_err_text = errortext(wsa_err_num)..", WSAGetLastError: "..tonumber(wsa_err_num)..". "..wsa_err_text
		end
		if socket then
			close(socket)
		end
		s.WSACleanup()
		if errtext and #errtext > 0 then
			error(err_prefix..errtext.."("..tonumber(errnum)..") "..wsa_err_text)
		end
	end
	function inet_ntop(family, pAddr, strptr)
		-- win XP: http://memset.wordpress.com/2010/10/09/inet_ntop-for-win32/
		local srcaddr = ffi.new("struct sockaddr_in") --ffi.cast("struct sockaddr_in *", pAddr)
		ffi.copy(srcaddr.sin_addr, pAddr, ffi.sizeof(srcaddr.sin_addr))
		srcaddr.sin_family = family
		local len = ffi.new("unsigned long[1]", ffi.sizeof(strptr))
    local ret = s.WSAAddressToStringA(ffi.cast("struct sockaddr *", srcaddr), ffi.sizeof("struct sockaddr"), nil, strptr, len)
    if ret ~= 0 then
   		print(err_prefix.."WSAAddressToString failed with error: "..tonumber(ret))
      return nil
    end
    return strptr
  end
	function set_nonblock(socket, arg)
		local arg_c = ffi.new("int[1]")
		arg_c[0] = arg
		return s.ioctlsocket(socket, FIONBIO, arg_c) -- FIONBIO in win_socket.lua
	end


else
	-- unix
	function errortext(err)
		return ffi.string(C.gai_strerror(err))
	end
	function initialize()
		return 0 -- for win compatibilty
	end
	function poll(fds, nfds, timeout)
		return s.poll(fds, nfds, timeout)
	end
	function close(socket)
		return s.close(socket)
	end
	function cleanup(socket, errnum, errtext)
		if socket then
			close(socket)
		end
		--s.WSACleanup()
		if errtext and #errtext > 0 then
			error(err_prefix..errtext.."("..tonumber(errnum)..") "..errortext(errnum))
		end
	end
	function inet_ntop(family, pAddr, strptr)
		return s.inet_ntop(family, pAddr, strptr, ffi.sizeof(strptr))
	end
	function set_nonblock(socket, arg)
		local flags = s.fcntl(socket, s.F_GETFL, 0);
		if flags < 0 then return flags end
		if arg ~= 0 then
			flags = bit.bor(flags, s.O_NONBLOCK)
		else
			flags = bit.band(flags, bit.bnot(s.O_NONBLOCK))
		end
		return s.fcntl(socket, s.F_SETFL, ffi.new("int", flags))
	end
end

function shutdown(socket, how)
	return s.shutdown(socket, how)
end
function htons(num)
	return s.htons(num)
end
function socket(domain, type_, protocol)
	return s.socket(domain, type_, protocol)
end
function bind(socket, sockaddr ,addrlen)
	return s.bind(socket, sockaddr ,addrlen)
end
function listen(socket, backlog)
	return s.listen(socket, backlog)
end
function connect(socket, sockaddr ,address_len)
	return s.connect(socket, sockaddr ,address_len)
end
function accept(socket, sockaddr ,addrlen)
	return s.accept(socket, sockaddr ,addrlen)
end
function recv(socket, buffer, length, flags)
	return tonumber(s.recv(socket, buffer, length, flags))
end
function send(socket, buffer, length, flags)
	return tonumber(s.send(socket, buffer, length, flags))
end
function getsockopt(socket, level, option_name, option_value, option_len)
	return s.getsockopt(socket, level, option_name, option_value, option_len)
end
function setsockopt(socket, level, option_name, option_value)
	--local arg_c = ffi.new("uint32_t[1]", option_value)
	local arg_c = type(option_value) == "number" and ffi.new("int[1]", option_value) or option_value
	local option_len = ffi.sizeof(arg_c)
	return s.setsockopt(socket, level, option_name, ffi.cast("void *", arg_c), option_len)
	--return s.setsockopt(socket, level, option_name, arg_c, option_len)
end
function getnameinfo(sa, salen, host, hostlen, serv, servlen, flags)
	return s.getnameinfo(sa, salen, host, hostlen, serv, servlen, flags)
end

function getaddrinfo(hostname, servname, hints, res)
  return s.getaddrinfo(hostname, servname, hints, res)
end
function getpeername(socket, name, namelen)
	return s.getpeername(socket, name, namelen)
end
function ntohs(netshort)
	return s.ntohs(netshort)
end

if jit.os == "Windows" then
	ffi.cdef("int GetLastError();")
	function wouldblock()
		return ffi.C.GetLastError() == 10035
	end
else
	function wouldblock()
		return ffi.errno() == 11
	end
end