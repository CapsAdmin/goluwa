#define STEAMWORKS_CLIENT_INTERFACES

#include "Steamworks.h"


class CSigScanner
{
public:
	CSigScanner(const void* hModule);

	void* FindSignature(const char* pubSignature, const char* cszMask, bool bSearchUp = false, const void* pPreviousMatch = NULL) const;
	void* FindSignature(const unsigned char* pubSignature, const char* cszMask, bool bSearchUp = false, const void* pPreviousMatch = NULL) const;

private:
	const void* m_pAllocationBase;
	unsigned int m_uSize;
};

inline void* CSigScanner::FindSignature(const char* pubSignature, const char* cszMask, bool bSearchUp/* = false*/, const void* pPreviousMatch/* = NULL*/) const
{
	return FindSignature((const unsigned char*)pubSignature, cszMask, bSearchUp, pPreviousMatch);
}

CSigScanner::CSigScanner(const void* hModule) : m_pAllocationBase(NULL), m_uSize(0)
{
	if (!hModule)
		return;

	MEMORY_BASIC_INFORMATION basicInformation;

	if (!VirtualQuery(hModule, &basicInformation, sizeof(basicInformation)))
		return;

	const IMAGE_DOS_HEADER *pDOSHeader = (IMAGE_DOS_HEADER*)basicInformation.AllocationBase;
	const IMAGE_NT_HEADERS *pNTHeader = (IMAGE_NT_HEADERS*)(((unsigned char*)basicInformation.AllocationBase) + pDOSHeader->e_lfanew);

	if (pNTHeader->Signature != IMAGE_NT_SIGNATURE)
		return;

	m_pAllocationBase = basicInformation.AllocationBase;
	m_uSize = pNTHeader->OptionalHeader.SizeOfImage;
}

void* CSigScanner::FindSignature(const unsigned char* pubSignature, const char* cszMask, bool bSearchUp/* = false*/, const void* pPreviousMatch/* = NULL*/) const
{
	if (!m_pAllocationBase || !cszMask || !*cszMask)
		return NULL;

	unsigned char *pCurrent = NULL;

	unsigned int uSignatureLength = (unsigned int)strlen(cszMask);

	if (!bSearchUp)
	{
		if (pPreviousMatch)
		{
			if (pPreviousMatch < m_pAllocationBase || (unsigned char*)pPreviousMatch + uSignatureLength >(unsigned char*)m_pAllocationBase + m_uSize)
				return NULL;

			pCurrent = (unsigned char*)pPreviousMatch + 1;
		}
		else
			pCurrent = (unsigned char *)m_pAllocationBase;

		unsigned char *pEnd = (unsigned char*)m_pAllocationBase + m_uSize;

		unsigned int i;

		for (; pCurrent < pEnd && (unsigned long)(pEnd - pCurrent) >= uSignatureLength; pCurrent++)
		{
			for (i = 0; cszMask[i] != '\0'; i++)
			{
				if ((cszMask[i] != '?') && (pubSignature[i] != pCurrent[i]))
					break;
			}
			if (cszMask[i] == '\0')
				return pCurrent;
		}
		return NULL;
	}
	else
	{
		if (pPreviousMatch)
		{
			if ((unsigned char*)pPreviousMatch - uSignatureLength < m_pAllocationBase || pPreviousMatch >(unsigned char*)m_pAllocationBase + m_uSize)
				return NULL;

			pCurrent = (unsigned char*)pPreviousMatch - 1;
		}
		else
			pCurrent = (unsigned char*)m_pAllocationBase + m_uSize - uSignatureLength;

		unsigned char *pEnd = (unsigned char*)m_pAllocationBase;

		unsigned int i;

		for (; pCurrent > pEnd && (unsigned long)(pCurrent - pEnd) >= uSignatureLength; pCurrent--)
		{
			for (i = 0; cszMask[i] != '\0'; i++)
			{
				if ((cszMask[i] != '?') && (pubSignature[i] != pCurrent[i]))
					break;
			}
			if (cszMask[i] == '\0')
				return pCurrent;
		}
		return NULL;
	}
}


#include <time.h>

#pragma comment( lib, "../Resources/Libs/Win32/steamclient.lib" )

void* FindSteamFunction(const char* cszName)
{
	static CSigScanner sigScanner(GetModuleHandleA("steamclient.dll"));

	for (unsigned char* pMatch = NULL; pMatch = (unsigned char*)sigScanner.FindSignature("\x68\x00\x00\x00\x00\x51\x8d\x55\xd0\x52\x50\xe8\x00\x00\x00\x00\x8d\x48\x04\xe8\x00\x00\x00\x00\x8b\xf0\x8b\xce\xe8\x00\x00\x00\x00\x00\x00\x00\x00", "x????xxx?xxx????xxxx????xxxxx????????", false, pMatch);)
	{
		const char* cszFunctionName = *(const char**)(pMatch + 1);
		if (strcmp(cszFunctionName, cszName) == 0)
		{
			return sigScanner.FindSignature("\x55\x8B\xEC\x83\xEC", "xxxxx", true, pMatch);
		}
	}

	return NULL;
}

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


CSteamAPILoader loader;
HSteamPipe steam_pipe;
ISteamFriends013 *steam_friends;
IClientFriends *client_friends;
ISteamUser016 *steam_user;

extern "C"
{
	char *last_error = "";

	EXPORT const char *steamGetLastError()
	{	
		auto temp = last_error;
		last_error = "";
		return temp;
	}

	EXPORT int steamInitialize()
	{
		auto factory = loader.GetSteam3Factory();
		if (!factory)
		{
			last_error = "could not get the steam3 factory";
			return 1;
		}

		auto steam_client = (ISteamClient012*)factory(STEAMCLIENT_INTERFACE_VERSION_012, NULL);
		if (!steam_client)
		{
			last_error = "could not get steam client";
			return 1;
		}

		{
			steam_pipe = steam_client->CreateSteamPipe();
			if (!steam_pipe || steam_pipe == -1)
			{
				last_error = "could not get steam pipe";
				return 1;
			}

			// Steamworks likes to deadlock if we create the pipe while Steam is starting
			// Which leads us to use this ugly hack.
			steam_client->BReleaseSteamPipe(steam_pipe);

			steam_pipe = steam_client->CreateSteamPipe();
			if (!steam_pipe || steam_pipe == -1)
			{
				last_error = "could not get steam pipe";
				return 1;
			}
		}

		auto steam_user_handle = steam_client->ConnectToGlobalUser(steam_pipe);
		if (!steam_user_handle)
		{
			last_error = "could not connect to global user";
			return 1;
		}

		steam_friends = (ISteamFriends013*)steam_client->GetISteamFriends(steam_user_handle, steam_pipe, STEAMFRIENDS_INTERFACE_VERSION_013);
		if (!steam_friends)
		{
			last_error = "could not get steam friends";
			return 1;
		}

		steam_user = (ISteamUser016*)steam_client->GetISteamUser(steam_user_handle, steam_pipe, STEAMUSER_INTERFACE_VERSION_016);
		if (!steam_user)
		{
			last_error = "could not get steam user";
			return 1;
		}
	
		auto client_engine = (IClientEngine*)factory(CLIENTENGINE_INTERFACE_VERSION, NULL);
		if (!client_engine)
		{
			last_error = "unable to get IClientEngine interface,\nGroup chat logging and Nickname support are disabled.";
			return 1;
		}

		client_friends = client_engine->GetIClientFriends(steam_user_handle, steam_pipe, CLIENTFRIENDS_INTERFACE_VERSION);
		if (!client_friends)
		{
			last_error = "Unable to get IClientFriends interface,\nGroup chat logging and Nickname support are disabled.";
			return true;
		}

		return 0;
	}

	struct message
	{
		const char *text;
		const char *sender_steam_id;
		const char *receiver_steam_id;
	};

	CallbackMsg_t callback;

	EXPORT message *steamGetLastChatMessage()
	{
		callback.m_iCallback = 0;

		Steam_BGetCallback(steam_pipe, &callback);

		switch (callback.m_iCallback)
		{
			case FriendChatMsg_t::k_iCallback:
			{
				auto chat_msg = (FriendChatMsg_t*)callback.m_pubParam;
			
				char text[k_cchFriendChatMsgMax + 1];
				EChatEntryType entry_type;
				auto size = steam_friends->GetFriendMessage(chat_msg->m_ulFriendID, chat_msg->m_iChatID, text, sizeof(text)-1, &entry_type);
				text[size] = '\0';

				if (size)
				{
					auto msg = new message;

					msg->sender_steam_id = chat_msg->m_ulSenderID.Render();
					msg->receiver_steam_id = chat_msg->m_ulFriendID.Render();

					msg->text = text;
					

					Steam_FreeLastCallback(steam_pipe);

					return msg;
				}
			}
		}

		Steam_FreeLastCallback(steam_pipe);

		return 0;
	};

	EXPORT int steamSendChatMessage(const char *steam_id, const char *text)
	{
		CSteamID friendID;
		for (int i = 0; i < client_friends->GetFriendCount(k_EFriendFlagImmediate); i++)
		{
			friendID = client_friends->GetFriendByIndex(i, k_EFriendFlagImmediate);

			if (strcmp(friendID.Render(), steam_id) == 0)
			{
				client_friends->SendMsgToFriend(friendID, k_EChatEntryTypeChatMsg, text, strlen(text));
				return 0;
			}
		}

		last_error = "could not find steamid";

		return 1;
	}

	EXPORT const char *steamGetNickFromSteamID(const char *steam_id)
	{
		if (strcmp(steam_user->GetSteamID().Render(), steam_id) == 0)
		{
			return client_friends->GetPersonaName();
		}

		CSteamID friendID;
		for (int i = 0; i < client_friends->GetFriendCount(k_EFriendFlagImmediate); i++)
		{
			friendID = client_friends->GetFriendByIndex(i, k_EFriendFlagImmediate);

			if (strcmp(friendID.Render(), steam_id) == 0)
			{
				return steam_friends->GetFriendPersonaName(friendID);
			}
		}

		last_error = "could not find steamid";

		return "";
	}

	EXPORT const char *steamGetClientSteamID()
	{
		return steam_user->GetSteamID().Render();
	}

	EXPORT unsigned steamGetFriendCount()
	{
		return client_friends->GetFriendCount(k_EFriendFlagImmediate);
	}

	EXPORT const char *steamGetFriendByIndex(unsigned i)
	{
		return client_friends->GetFriendByIndex(i, k_EFriendFlagImmediate).Render();
	}

	struct steam_auth_token
	{
		int auth_size;
		unsigned char *auth_buffer;		
		//int key_size;
		//unsigned char *key_buffer;
	};

#ifdef _WIN32
#pragma comment(lib, "Ws2_32.lib")
#endif

	EXPORT uint32 steamGetAuthSessionTicket(void *ticket_buffer, int ticket_size, uint32 *ticket_buffer_size)
	{
		return steam_user->GetAuthSessionTicket(ticket_buffer, ticket_size, ticket_buffer_size);
	}

	EXPORT void steamCancelAuthSessionTicket(uint32 auth_session_ticket)
	{
		steam_user->CancelAuthTicket(auth_session_ticket);
	}

	EXPORT const char* steamBeginAuthSession(const void *auth_ticket, int auth_ticket_size)
	{	
		switch (steam_user->BeginAuthSession(auth_ticket, auth_ticket_size, steam_user->GetSteamID()))
		{
			case k_EBeginAuthSessionResultOK: return "ok";
			case k_EBeginAuthSessionResultInvalidTicket: return "invalid";
			case k_EBeginAuthSessionResultDuplicateRequest: return "duplicate";
			case k_EBeginAuthSessionResultInvalidVersion: return "invalid_version";
			case k_EBeginAuthSessionResultGameMismatch: return "missmatch";
			case k_EBeginAuthSessionResultExpiredTicket: return "expired";
		}

		return "unknown";
	}

	EXPORT void steamEndAuthSession()
	{
		steam_user->EndAuthSession(steam_user->GetSteamID());
	}

	EXPORT uint64 steamRequestEncryptedAppTicket(void *pDataToInclude, int cbDataToInclude)
	{
		return steam_user->RequestEncryptedAppTicket(pDataToInclude, cbDataToInclude);
	}
	EXPORT int steamGetEncryptedAppTicket(void *ticket_buffer, int ticket_size, uint32 *ticket_buffer_size)
	{
		return steam_user->GetEncryptedAppTicket(ticket_buffer, ticket_size, ticket_buffer_size) == 1;
	}

	EXPORT steam_auth_token *steamGetAuthTokenFromServer(uint64 server_id, uint32 app_id, const char *ip, short port, int secure)
	{ 
		unsigned char buffer[2048] = {0};

		int size = steam_user->InitiateGameConnection(buffer, 2048, CSteamID(server_id), inet_addr(ip), port, secure == 1);//, key_buffer, sizeof(key_buffer));

		auto key = new steam_auth_token;

		key->auth_size = size;
		key->auth_buffer = buffer;
		
		return key;
	}

	int main(char, char **)
	{
		steamInitialize();

		char ticket[1024] = {0};
		uint32 size = 1024;

		auto huh = steam_user->GetAuthSessionTicket(ticket, sizeof(ticket), &size);
				
		while (true)
		{
			steamGetLastChatMessage();
		}
	};
}
