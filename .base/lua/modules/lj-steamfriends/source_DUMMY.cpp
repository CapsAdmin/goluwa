#if defined(_MSC_VER)
//  Microsoft 
#define EXPORT __declspec(dllexport)
#elif defined(_GCC)
//  GCC
#define EXPORT __attribute__((visibility("default")))
#else
//  do nothing and hope for the best?
#pragma warning Unknown dynamic link import/export semantics.
#define EXPORT 
#endif

extern "C"
{

	EXPORT const char *steamGetLastError()
	{
		return "";
	}

	EXPORT int steamInitialize()
	{
		return 0;
	}

	struct message
	{
		const char *text;
		const char *sender_steam_id;
		const char *receiver_steam_id;
	};

	EXPORT message *steamGetLastChatMessage()
	{
		return 0;
	};

	EXPORT int steamSendChatMessage(const char *steam_id, const char *text)
	{
		return 0;
	}

	EXPORT const char *steamGetNickFromSteamID(const char *steam_id)
	{
		return "";
	}

	EXPORT const char *steamGetClientSteamID()
	{
		return "";
	}

	EXPORT unsigned steamGetFriendCount()
	{
		return 0;
	}

	EXPORT const char *steamGetFriendByIndex(unsigned i)
	{
		return "";
	}

	struct steam_auth_token
	{
		int auth_size;
		unsigned char *auth_buffer;		
		//int key_size;
		//unsigned char *key_buffer;
	};

	typedef unsigned int uint32;
	typedef unsigned long long uint64;

	EXPORT uint32 steamGetAuthSessionTicket(void *ticket_buffer, int ticket_size, uint32 *ticket_buffer_size)
	{
		return 0;
	}

	EXPORT void steamCancelAuthSessionTicket(uint32 auth_session_ticket)
	{
	}

	EXPORT const char* steamBeginAuthSession(const void *auth_ticket, int auth_ticket_size)
	{	
		return "unknown";
	}

	EXPORT void steamEndAuthSession()
	{
	}

	EXPORT uint64 steamRequestEncryptedAppTicket(void *pDataToInclude, int cbDataToInclude)
	{
		return 0;
	}

	EXPORT int steamGetEncryptedAppTicket(void *ticket_buffer, int ticket_size, uint32 *ticket_buffer_size)
	{
		return 0;
	}

	EXPORT steam_auth_token *steamGetAuthTokenFromServer(uint64 server_id, uint32 app_id, const char *ip, short port, int secure)
	{ 
		return 0;
	}
}
