				local ffi = require("ffi")
				local CLIB = assert(ffi.load("enet"))
				ffi.cdef([[enum{ENET_PROTOCOL_MINIMUM_MTU=576,ENET_PROTOCOL_MAXIMUM_MTU=4096,ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS=32,ENET_PROTOCOL_MINIMUM_WINDOW_SIZE=4096,ENET_PROTOCOL_MAXIMUM_WINDOW_SIZE=65536,ENET_PROTOCOL_MINIMUM_CHANNEL_COUNT=1,ENET_PROTOCOL_MAXIMUM_CHANNEL_COUNT=255,ENET_PROTOCOL_MAXIMUM_PEER_ID=4095,ENET_PROTOCOL_MAXIMUM_FRAGMENT_COUNT=1048576,
ENET_HOST_RECEIVE_BUFFER_SIZE=262144,ENET_HOST_SEND_BUFFER_SIZE=262144,ENET_HOST_BANDWIDTH_THROTTLE_INTERVAL=1000,ENET_HOST_DEFAULT_MTU=1400,ENET_HOST_DEFAULT_MAXIMUM_PACKET_SIZE=33554432,ENET_HOST_DEFAULT_MAXIMUM_WAITING_DATA=33554432,ENET_PEER_DEFAULT_ROUND_TRIP_TIME=500,ENET_PEER_DEFAULT_PACKET_THROTTLE=32,ENET_PEER_PACKET_THROTTLE_SCALE=32,ENET_PEER_PACKET_THROTTLE_COUNTER=7,ENET_PEER_PACKET_THROTTLE_ACCELERATION=2,ENET_PEER_PACKET_THROTTLE_DECELERATION=2,ENET_PEER_PACKET_THROTTLE_INTERVAL=5000,ENET_PEER_PACKET_LOSS_SCALE=65536,ENET_PEER_PACKET_LOSS_INTERVAL=10000,ENET_PEER_WINDOW_SIZE_SCALE=65536,ENET_PEER_TIMEOUT_LIMIT=32,ENET_PEER_TIMEOUT_MINIMUM=5000,ENET_PEER_TIMEOUT_MAXIMUM=30000,ENET_PEER_PING_INTERVAL=500,ENET_PEER_UNSEQUENCED_WINDOWS=64,ENET_PEER_UNSEQUENCED_WINDOW_SIZE=1024,ENET_PEER_FREE_UNSEQUENCED_WINDOWS=32,ENET_PEER_RELIABLE_WINDOWS=16,ENET_PEER_RELIABLE_WINDOW_SIZE=4096,ENET_PEER_FREE_RELIABLE_WINDOWS=8,};typedef enum _ENetEventType{ENET_EVENT_TYPE_NONE=0,ENET_EVENT_TYPE_CONNECT=1,ENET_EVENT_TYPE_DISCONNECT=2,ENET_EVENT_TYPE_RECEIVE=3};
typedef enum _ENetPacketFlag{ENET_PACKET_FLAG_RELIABLE=1,ENET_PACKET_FLAG_UNSEQUENCED=2,ENET_PACKET_FLAG_NO_ALLOCATE=4,ENET_PACKET_FLAG_UNRELIABLE_FRAGMENT=8,ENET_PACKET_FLAG_SENT=256};
typedef enum _ENetPeerFlag{ENET_PEER_FLAG_NEEDS_DISPATCH=1};
typedef enum _ENetPeerState{ENET_PEER_STATE_DISCONNECTED=0,ENET_PEER_STATE_CONNECTING=1,ENET_PEER_STATE_ACKNOWLEDGING_CONNECT=2,ENET_PEER_STATE_CONNECTION_PENDING=3,ENET_PEER_STATE_CONNECTION_SUCCEEDED=4,ENET_PEER_STATE_CONNECTED=5,ENET_PEER_STATE_DISCONNECT_LATER=6,ENET_PEER_STATE_DISCONNECTING=7,ENET_PEER_STATE_ACKNOWLEDGING_DISCONNECT=8,ENET_PEER_STATE_ZOMBIE=9};
typedef enum _ENetProtocolCommand{ENET_PROTOCOL_COMMAND_NONE=0,ENET_PROTOCOL_COMMAND_ACKNOWLEDGE=1,ENET_PROTOCOL_COMMAND_CONNECT=2,ENET_PROTOCOL_COMMAND_VERIFY_CONNECT=3,ENET_PROTOCOL_COMMAND_DISCONNECT=4,ENET_PROTOCOL_COMMAND_PING=5,ENET_PROTOCOL_COMMAND_SEND_RELIABLE=6,ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE=7,ENET_PROTOCOL_COMMAND_SEND_FRAGMENT=8,ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED=9,ENET_PROTOCOL_COMMAND_BANDWIDTH_LIMIT=10,ENET_PROTOCOL_COMMAND_THROTTLE_CONFIGURE=11,ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT=12,ENET_PROTOCOL_COMMAND_COUNT=13,ENET_PROTOCOL_COMMAND_MASK=15};
typedef enum _ENetProtocolFlag{ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE=128,ENET_PROTOCOL_COMMAND_FLAG_UNSEQUENCED=64,ENET_PROTOCOL_HEADER_FLAG_COMPRESSED=16384,ENET_PROTOCOL_HEADER_FLAG_SENT_TIME=32768,ENET_PROTOCOL_HEADER_FLAG_MASK=49152,ENET_PROTOCOL_HEADER_SESSION_MASK=12288,ENET_PROTOCOL_HEADER_SESSION_SHIFT=12};
typedef enum _ENetSocketOption{ENET_SOCKOPT_NONBLOCK=1,ENET_SOCKOPT_BROADCAST=2,ENET_SOCKOPT_RCVBUF=3,ENET_SOCKOPT_SNDBUF=4,ENET_SOCKOPT_REUSEADDR=5,ENET_SOCKOPT_RCVTIMEO=6,ENET_SOCKOPT_SNDTIMEO=7,ENET_SOCKOPT_ERROR=8,ENET_SOCKOPT_NODELAY=9};
typedef enum _ENetSocketShutdown{ENET_SOCKET_SHUTDOWN_READ=0,ENET_SOCKET_SHUTDOWN_WRITE=1,ENET_SOCKET_SHUTDOWN_READ_WRITE=2};
typedef enum _ENetSocketType{ENET_SOCKET_TYPE_STREAM=1,ENET_SOCKET_TYPE_DATAGRAM=2};
typedef enum _ENetSocketWait{ENET_SOCKET_WAIT_NONE=0,ENET_SOCKET_WAIT_SEND=1,ENET_SOCKET_WAIT_RECEIVE=2,ENET_SOCKET_WAIT_INTERRUPT=4};
struct ENetBuffer {void*data;unsigned long dataLength;};
struct _ENetProtocolCommandHeader {unsigned char command;unsigned char channelID;unsigned short reliableSequenceNumber;};
struct _ENetProtocolAcknowledge {struct _ENetProtocolCommandHeader header;unsigned short receivedReliableSequenceNumber;unsigned short receivedSentTime;};
struct _ENetProtocolConnect {struct _ENetProtocolCommandHeader header;unsigned short outgoingPeerID;unsigned char incomingSessionID;unsigned char outgoingSessionID;unsigned int mtu;unsigned int windowSize;unsigned int channelCount;unsigned int incomingBandwidth;unsigned int outgoingBandwidth;unsigned int packetThrottleInterval;unsigned int packetThrottleAcceleration;unsigned int packetThrottleDeceleration;unsigned int connectID;unsigned int data;};
struct _ENetProtocolVerifyConnect {struct _ENetProtocolCommandHeader header;unsigned short outgoingPeerID;unsigned char incomingSessionID;unsigned char outgoingSessionID;unsigned int mtu;unsigned int windowSize;unsigned int channelCount;unsigned int incomingBandwidth;unsigned int outgoingBandwidth;unsigned int packetThrottleInterval;unsigned int packetThrottleAcceleration;unsigned int packetThrottleDeceleration;unsigned int connectID;};
struct _ENetProtocolBandwidthLimit {struct _ENetProtocolCommandHeader header;unsigned int incomingBandwidth;unsigned int outgoingBandwidth;};
struct _ENetProtocolThrottleConfigure {struct _ENetProtocolCommandHeader header;unsigned int packetThrottleInterval;unsigned int packetThrottleAcceleration;unsigned int packetThrottleDeceleration;};
struct _ENetProtocolDisconnect {struct _ENetProtocolCommandHeader header;unsigned int data;};
struct _ENetProtocolPing {struct _ENetProtocolCommandHeader header;};
struct _ENetProtocolSendReliable {struct _ENetProtocolCommandHeader header;unsigned short dataLength;};
struct _ENetProtocolSendUnreliable {struct _ENetProtocolCommandHeader header;unsigned short unreliableSequenceNumber;unsigned short dataLength;};
struct _ENetProtocolSendUnsequenced {struct _ENetProtocolCommandHeader header;unsigned short unsequencedGroup;unsigned short dataLength;};
struct _ENetProtocolSendFragment {struct _ENetProtocolCommandHeader header;unsigned short startSequenceNumber;unsigned short dataLength;unsigned int fragmentCount;unsigned int fragmentNumber;unsigned int totalLength;unsigned int fragmentOffset;};
union _ENetProtocol {struct _ENetProtocolCommandHeader header;struct _ENetProtocolAcknowledge acknowledge;struct _ENetProtocolConnect connect;struct _ENetProtocolVerifyConnect verifyConnect;struct _ENetProtocolDisconnect disconnect;struct _ENetProtocolPing ping;struct _ENetProtocolSendReliable sendReliable;struct _ENetProtocolSendUnreliable sendUnreliable;struct _ENetProtocolSendUnsequenced sendUnsequenced;struct _ENetProtocolSendFragment sendFragment;struct _ENetProtocolBandwidthLimit bandwidthLimit;struct _ENetProtocolThrottleConfigure throttleConfigure;};
struct _ENetListNode {struct _ENetListNode*next;struct _ENetListNode*previous;};
struct _ENetList {struct _ENetListNode sentinel;};
struct _ENetCallbacks {void*(*malloc)(unsigned long);void(*free)(void*);void(*no_memory)();};
struct _ENetAddress {unsigned int host;unsigned short port;};
struct _ENetPacket {unsigned long referenceCount;unsigned int flags;unsigned char*data;unsigned long dataLength;void(*freeCallback)(struct _ENetPacket*);void*userData;};
struct _ENetAcknowledgement {struct _ENetListNode acknowledgementList;unsigned int sentTime;union _ENetProtocol command;};
struct _ENetOutgoingCommand {struct _ENetListNode outgoingCommandList;unsigned short reliableSequenceNumber;unsigned short unreliableSequenceNumber;unsigned int sentTime;unsigned int roundTripTimeout;unsigned int roundTripTimeoutLimit;unsigned int fragmentOffset;unsigned short fragmentLength;unsigned short sendAttempts;union _ENetProtocol command;struct _ENetPacket*packet;};
struct _ENetIncomingCommand {struct _ENetListNode incomingCommandList;unsigned short reliableSequenceNumber;unsigned short unreliableSequenceNumber;union _ENetProtocol command;unsigned int fragmentCount;unsigned int fragmentsRemaining;unsigned int*fragments;struct _ENetPacket*packet;};
struct _ENetChannel {unsigned short outgoingReliableSequenceNumber;unsigned short outgoingUnreliableSequenceNumber;unsigned short usedReliableWindows;unsigned short reliableWindows[ENET_PEER_RELIABLE_WINDOWS];unsigned short incomingReliableSequenceNumber;unsigned short incomingUnreliableSequenceNumber;struct _ENetList incomingReliableCommands;struct _ENetList incomingUnreliableCommands;};
struct _ENetPeer {struct _ENetListNode dispatchList;struct _ENetHost*host;unsigned short outgoingPeerID;unsigned short incomingPeerID;unsigned int connectID;unsigned char outgoingSessionID;unsigned char incomingSessionID;struct _ENetAddress address;void*data;enum _ENetPeerState state;struct _ENetChannel*channels;unsigned long channelCount;unsigned int incomingBandwidth;unsigned int outgoingBandwidth;unsigned int incomingBandwidthThrottleEpoch;unsigned int outgoingBandwidthThrottleEpoch;unsigned int incomingDataTotal;unsigned int outgoingDataTotal;unsigned int lastSendTime;unsigned int lastReceiveTime;unsigned int nextTimeout;unsigned int earliestTimeout;unsigned int packetLossEpoch;unsigned int packetsSent;unsigned int packetsLost;unsigned int packetLoss;unsigned int packetLossVariance;unsigned int packetThrottle;unsigned int packetThrottleLimit;unsigned int packetThrottleCounter;unsigned int packetThrottleEpoch;unsigned int packetThrottleAcceleration;unsigned int packetThrottleDeceleration;unsigned int packetThrottleInterval;unsigned int pingInterval;unsigned int timeoutLimit;unsigned int timeoutMinimum;unsigned int timeoutMaximum;unsigned int lastRoundTripTime;unsigned int lowestRoundTripTime;unsigned int lastRoundTripTimeVariance;unsigned int highestRoundTripTimeVariance;unsigned int roundTripTime;unsigned int roundTripTimeVariance;unsigned int mtu;unsigned int windowSize;unsigned int reliableDataInTransit;unsigned short outgoingReliableSequenceNumber;struct _ENetList acknowledgements;struct _ENetList sentReliableCommands;struct _ENetList sentUnreliableCommands;struct _ENetList outgoingCommands;struct _ENetList dispatchedCommands;unsigned short flags;unsigned short reserved;unsigned short incomingUnsequencedGroup;unsigned short outgoingUnsequencedGroup;unsigned int unsequencedWindow[ENET_PEER_UNSEQUENCED_WINDOW_SIZE/32];unsigned int eventData;unsigned long totalWaitingData;};
struct _ENetCompressor {void*context;unsigned long(*compress)(void*,const struct ENetBuffer*,unsigned long,unsigned long,unsigned char*,unsigned long);unsigned long(*decompress)(void*,const unsigned char*,unsigned long,unsigned char*,unsigned long);void(*destroy)(void*);};
struct _ENetHost {int socket;struct _ENetAddress address;unsigned int incomingBandwidth;unsigned int outgoingBandwidth;unsigned int bandwidthThrottleEpoch;unsigned int mtu;unsigned int randomSeed;int recalculateBandwidthLimits;struct _ENetPeer*peers;unsigned long peerCount;unsigned long channelLimit;unsigned int serviceTime;struct _ENetList dispatchQueue;int continueSending;unsigned long packetSize;unsigned short headerFlags;union _ENetProtocol commands[ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS];unsigned long commandCount;struct ENetBuffer buffers[(1+2*ENET_PROTOCOL_MAXIMUM_PACKET_COMMANDS)];unsigned long bufferCount;unsigned int(*checksum)(const struct ENetBuffer*,unsigned long);struct _ENetCompressor compressor;unsigned char packetData[2][ENET_PROTOCOL_MAXIMUM_MTU];struct _ENetAddress receivedAddress;unsigned char*receivedData;unsigned long receivedDataLength;unsigned int totalSentData;unsigned int totalSentPackets;unsigned int totalReceivedData;unsigned int totalReceivedPackets;int(*intercept)(struct _ENetHost*,struct _ENetEvent*);unsigned long connectedPeers;unsigned long bandwidthLimitedPeers;unsigned long duplicatePeers;unsigned long maximumPacketSize;unsigned long maximumWaitingData;};
struct _ENetEvent {enum _ENetEventType type;struct _ENetPeer*peer;unsigned char channelID;unsigned int data;struct _ENetPacket*packet;};
int(enet_address_get_host)(const struct _ENetAddress*,char*,unsigned long);
int(enet_address_get_host_ip)(const struct _ENetAddress*,char*,unsigned long);
int(enet_address_set_host)(struct _ENetAddress*,const char*);
int(enet_address_set_host_ip)(struct _ENetAddress*,const char*);
int(enet_host_check_events)(struct _ENetHost*,struct _ENetEvent*);
int(enet_host_compress_with_range_coder)(struct _ENetHost*);
int(enet_host_service)(struct _ENetHost*,struct _ENetEvent*,unsigned int);
int(enet_initialize)();
int(enet_initialize_with_callbacks)(unsigned int,const struct _ENetCallbacks*);
int(enet_packet_resize)(struct _ENetPacket*,unsigned long);
int(enet_peer_send)(struct _ENetPeer*,unsigned char,struct _ENetPacket*);
int(enet_peer_throttle)(struct _ENetPeer*,unsigned int);
int(enet_socket_accept)(int,struct _ENetAddress*);
int(enet_socket_bind)(int,const struct _ENetAddress*);
int(enet_socket_connect)(int,const struct _ENetAddress*);
int(enet_socket_create)(enum _ENetSocketType);
int(enet_socket_get_address)(int,struct _ENetAddress*);
int(enet_socket_get_option)(int,enum _ENetSocketOption,int*);
int(enet_socket_listen)(int,int);
int(enet_socket_receive)(int,struct _ENetAddress*,struct ENetBuffer*,unsigned long);
int(enet_socket_send)(int,const struct _ENetAddress*,const struct ENetBuffer*,unsigned long);
int(enet_socket_set_option)(int,enum _ENetSocketOption,int);
int(enet_socket_shutdown)(int,enum _ENetSocketShutdown);
int(enet_socket_wait)(int,unsigned int*,unsigned int);
int(enet_socketset_select)(int,void*,void*,unsigned int);
struct _ENetAcknowledgement*(enet_peer_queue_acknowledgement)(struct _ENetPeer*,const union _ENetProtocol*,unsigned short);
struct _ENetHost*(enet_host_create)(const struct _ENetAddress*,unsigned long,unsigned long,unsigned int,unsigned int);
struct _ENetIncomingCommand*(enet_peer_queue_incoming_command)(struct _ENetPeer*,const union _ENetProtocol*,const void*,unsigned long,unsigned int,unsigned int);
struct _ENetListNode*(enet_list_insert)(struct _ENetListNode*,void*);
struct _ENetListNode*(enet_list_move)(struct _ENetListNode*,void*,void*);
struct _ENetOutgoingCommand*(enet_peer_queue_outgoing_command)(struct _ENetPeer*,const union _ENetProtocol*,struct _ENetPacket*,unsigned int,unsigned short);
struct _ENetPacket*(enet_packet_create)(const void*,unsigned long,unsigned int);
struct _ENetPacket*(enet_peer_receive)(struct _ENetPeer*,unsigned char*);
struct _ENetPeer*(enet_host_connect)(struct _ENetHost*,const struct _ENetAddress*,unsigned long,unsigned int);
unsigned int(enet_crc32)(const struct ENetBuffer*,unsigned long);
unsigned int(enet_host_random)(struct _ENetHost*);
unsigned int(enet_host_random_seed)();
unsigned int(enet_linked_version)();
unsigned int(enet_time_get)();
unsigned long(enet_list_size)(struct _ENetList*);
unsigned long(enet_protocol_command_size)(unsigned char);
unsigned long(enet_range_coder_compress)(void*,const struct ENetBuffer*,unsigned long,unsigned long,unsigned char*,unsigned long);
unsigned long(enet_range_coder_decompress)(void*,const unsigned char*,unsigned long,unsigned char*,unsigned long);
void*(enet_list_remove)(struct _ENetListNode*);
void*(enet_malloc)(unsigned long);
void*(enet_range_coder_create)();
void(enet_deinitialize)();
void(enet_free)(void*);
void(enet_host_bandwidth_limit)(struct _ENetHost*,unsigned int,unsigned int);
void(enet_host_bandwidth_throttle)(struct _ENetHost*);
void(enet_host_broadcast)(struct _ENetHost*,unsigned char,struct _ENetPacket*);
void(enet_host_channel_limit)(struct _ENetHost*,unsigned long);
void(enet_host_compress)(struct _ENetHost*,const struct _ENetCompressor*);
void(enet_host_destroy)(struct _ENetHost*);
void(enet_host_flush)(struct _ENetHost*);
void(enet_list_clear)(struct _ENetList*);
void(enet_packet_destroy)(struct _ENetPacket*);
void(enet_peer_disconnect)(struct _ENetPeer*,unsigned int);
void(enet_peer_disconnect_later)(struct _ENetPeer*,unsigned int);
void(enet_peer_disconnect_now)(struct _ENetPeer*,unsigned int);
void(enet_peer_dispatch_incoming_reliable_commands)(struct _ENetPeer*,struct _ENetChannel*,struct _ENetIncomingCommand*);
void(enet_peer_dispatch_incoming_unreliable_commands)(struct _ENetPeer*,struct _ENetChannel*,struct _ENetIncomingCommand*);
void(enet_peer_on_connect)(struct _ENetPeer*);
void(enet_peer_on_disconnect)(struct _ENetPeer*);
void(enet_peer_ping)(struct _ENetPeer*);
void(enet_peer_ping_interval)(struct _ENetPeer*,unsigned int);
void(enet_peer_reset)(struct _ENetPeer*);
void(enet_peer_reset_queues)(struct _ENetPeer*);
void(enet_peer_setup_outgoing_command)(struct _ENetPeer*,struct _ENetOutgoingCommand*);
void(enet_peer_throttle_configure)(struct _ENetPeer*,unsigned int,unsigned int,unsigned int);
void(enet_peer_timeout)(struct _ENetPeer*,unsigned int,unsigned int,unsigned int);
void(enet_range_coder_destroy)(void*);
void(enet_socket_destroy)(int);
void(enet_time_set)(unsigned int);
]])
			local library = {
	AddressGetHost = CLIB.enet_address_get_host,
	AddressGetHostIp = CLIB.enet_address_get_host_ip,
	AddressSetHost = CLIB.enet_address_set_host,
	AddressSetHostIp = CLIB.enet_address_set_host_ip,
	Crc32 = CLIB.enet_crc32,
	Deinitialize = CLIB.enet_deinitialize,
	Free = CLIB.enet_free,
	HostBandwidthLimit = CLIB.enet_host_bandwidth_limit,
	HostBandwidthThrottle = CLIB.enet_host_bandwidth_throttle,
	HostBroadcast = CLIB.enet_host_broadcast,
	HostChannelLimit = CLIB.enet_host_channel_limit,
	HostCheckEvents = CLIB.enet_host_check_events,
	HostCompress = CLIB.enet_host_compress,
	HostCompressWithRangeCoder = CLIB.enet_host_compress_with_range_coder,
	HostConnect = CLIB.enet_host_connect,
	HostCreate = CLIB.enet_host_create,
	HostDestroy = CLIB.enet_host_destroy,
	HostFlush = CLIB.enet_host_flush,
	HostRandom = CLIB.enet_host_random,
	HostRandomSeed = CLIB.enet_host_random_seed,
	HostService = CLIB.enet_host_service,
	Initialize = CLIB.enet_initialize,
	InitializeWithCallbacks = CLIB.enet_initialize_with_callbacks,
	LinkedVersion = CLIB.enet_linked_version,
	ListClear = CLIB.enet_list_clear,
	ListInsert = CLIB.enet_list_insert,
	ListMove = CLIB.enet_list_move,
	ListRemove = CLIB.enet_list_remove,
	ListSize = CLIB.enet_list_size,
	Malloc = CLIB.enet_malloc,
	PacketCreate = CLIB.enet_packet_create,
	PacketDestroy = CLIB.enet_packet_destroy,
	PacketResize = CLIB.enet_packet_resize,
	PeerDisconnect = CLIB.enet_peer_disconnect,
	PeerDisconnectLater = CLIB.enet_peer_disconnect_later,
	PeerDisconnectNow = CLIB.enet_peer_disconnect_now,
	PeerDispatchIncomingReliableCommands = CLIB.enet_peer_dispatch_incoming_reliable_commands,
	PeerDispatchIncomingUnreliableCommands = CLIB.enet_peer_dispatch_incoming_unreliable_commands,
	PeerOnConnect = CLIB.enet_peer_on_connect,
	PeerOnDisconnect = CLIB.enet_peer_on_disconnect,
	PeerPing = CLIB.enet_peer_ping,
	PeerPingInterval = CLIB.enet_peer_ping_interval,
	PeerQueueAcknowledgement = CLIB.enet_peer_queue_acknowledgement,
	PeerQueueIncomingCommand = CLIB.enet_peer_queue_incoming_command,
	PeerQueueOutgoingCommand = CLIB.enet_peer_queue_outgoing_command,
	PeerReceive = CLIB.enet_peer_receive,
	PeerReset = CLIB.enet_peer_reset,
	PeerResetQueues = CLIB.enet_peer_reset_queues,
	PeerSend = CLIB.enet_peer_send,
	PeerSetupOutgoingCommand = CLIB.enet_peer_setup_outgoing_command,
	PeerThrottle = CLIB.enet_peer_throttle,
	PeerThrottleConfigure = CLIB.enet_peer_throttle_configure,
	PeerTimeout = CLIB.enet_peer_timeout,
	ProtocolCommandSize = CLIB.enet_protocol_command_size,
	RangeCoderCompress = CLIB.enet_range_coder_compress,
	RangeCoderCreate = CLIB.enet_range_coder_create,
	RangeCoderDecompress = CLIB.enet_range_coder_decompress,
	RangeCoderDestroy = CLIB.enet_range_coder_destroy,
	SocketAccept = CLIB.enet_socket_accept,
	SocketBind = CLIB.enet_socket_bind,
	SocketConnect = CLIB.enet_socket_connect,
	SocketCreate = CLIB.enet_socket_create,
	SocketDestroy = CLIB.enet_socket_destroy,
	SocketGetAddress = CLIB.enet_socket_get_address,
	SocketGetOption = CLIB.enet_socket_get_option,
	SocketListen = CLIB.enet_socket_listen,
	SocketReceive = CLIB.enet_socket_receive,
	SocketSend = CLIB.enet_socket_send,
	SocketSetOption = CLIB.enet_socket_set_option,
	SocketShutdown = CLIB.enet_socket_shutdown,
	SocketWait = CLIB.enet_socket_wait,
	SocketsetSelect = CLIB.enet_socketset_select,
	TimeGet = CLIB.enet_time_get,
	TimeSet = CLIB.enet_time_set,
}
library.e = {
	EVENT_TYPE_NONE = ffi.cast("enum _ENetEventType", "ENET_EVENT_TYPE_NONE"),
	EVENT_TYPE_CONNECT = ffi.cast("enum _ENetEventType", "ENET_EVENT_TYPE_CONNECT"),
	EVENT_TYPE_DISCONNECT = ffi.cast("enum _ENetEventType", "ENET_EVENT_TYPE_DISCONNECT"),
	EVENT_TYPE_RECEIVE = ffi.cast("enum _ENetEventType", "ENET_EVENT_TYPE_RECEIVE"),
	PACKET_FLAG_RELIABLE = ffi.cast("enum _ENetPacketFlag", "ENET_PACKET_FLAG_RELIABLE"),
	PACKET_FLAG_UNSEQUENCED = ffi.cast("enum _ENetPacketFlag", "ENET_PACKET_FLAG_UNSEQUENCED"),
	PACKET_FLAG_NO_ALLOCATE = ffi.cast("enum _ENetPacketFlag", "ENET_PACKET_FLAG_NO_ALLOCATE"),
	PACKET_FLAG_UNRELIABLE_FRAGMENT = ffi.cast("enum _ENetPacketFlag", "ENET_PACKET_FLAG_UNRELIABLE_FRAGMENT"),
	PACKET_FLAG_SENT = ffi.cast("enum _ENetPacketFlag", "ENET_PACKET_FLAG_SENT"),
	PEER_FLAG_NEEDS_DISPATCH = ffi.cast("enum _ENetPeerFlag", "ENET_PEER_FLAG_NEEDS_DISPATCH"),
	PEER_STATE_DISCONNECTED = ffi.cast("enum _ENetPeerState", "ENET_PEER_STATE_DISCONNECTED"),
	PEER_STATE_CONNECTING = ffi.cast("enum _ENetPeerState", "ENET_PEER_STATE_CONNECTING"),
	PEER_STATE_ACKNOWLEDGING_CONNECT = ffi.cast("enum _ENetPeerState", "ENET_PEER_STATE_ACKNOWLEDGING_CONNECT"),
	PEER_STATE_CONNECTION_PENDING = ffi.cast("enum _ENetPeerState", "ENET_PEER_STATE_CONNECTION_PENDING"),
	PEER_STATE_CONNECTION_SUCCEEDED = ffi.cast("enum _ENetPeerState", "ENET_PEER_STATE_CONNECTION_SUCCEEDED"),
	PEER_STATE_CONNECTED = ffi.cast("enum _ENetPeerState", "ENET_PEER_STATE_CONNECTED"),
	PEER_STATE_DISCONNECT_LATER = ffi.cast("enum _ENetPeerState", "ENET_PEER_STATE_DISCONNECT_LATER"),
	PEER_STATE_DISCONNECTING = ffi.cast("enum _ENetPeerState", "ENET_PEER_STATE_DISCONNECTING"),
	PEER_STATE_ACKNOWLEDGING_DISCONNECT = ffi.cast("enum _ENetPeerState", "ENET_PEER_STATE_ACKNOWLEDGING_DISCONNECT"),
	PEER_STATE_ZOMBIE = ffi.cast("enum _ENetPeerState", "ENET_PEER_STATE_ZOMBIE"),
	PROTOCOL_COMMAND_NONE = ffi.cast("enum _ENetProtocolCommand", "ENET_PROTOCOL_COMMAND_NONE"),
	PROTOCOL_COMMAND_ACKNOWLEDGE = ffi.cast("enum _ENetProtocolCommand", "ENET_PROTOCOL_COMMAND_ACKNOWLEDGE"),
	PROTOCOL_COMMAND_CONNECT = ffi.cast("enum _ENetProtocolCommand", "ENET_PROTOCOL_COMMAND_CONNECT"),
	PROTOCOL_COMMAND_VERIFY_CONNECT = ffi.cast("enum _ENetProtocolCommand", "ENET_PROTOCOL_COMMAND_VERIFY_CONNECT"),
	PROTOCOL_COMMAND_DISCONNECT = ffi.cast("enum _ENetProtocolCommand", "ENET_PROTOCOL_COMMAND_DISCONNECT"),
	PROTOCOL_COMMAND_PING = ffi.cast("enum _ENetProtocolCommand", "ENET_PROTOCOL_COMMAND_PING"),
	PROTOCOL_COMMAND_SEND_RELIABLE = ffi.cast("enum _ENetProtocolCommand", "ENET_PROTOCOL_COMMAND_SEND_RELIABLE"),
	PROTOCOL_COMMAND_SEND_UNRELIABLE = ffi.cast("enum _ENetProtocolCommand", "ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE"),
	PROTOCOL_COMMAND_SEND_FRAGMENT = ffi.cast("enum _ENetProtocolCommand", "ENET_PROTOCOL_COMMAND_SEND_FRAGMENT"),
	PROTOCOL_COMMAND_SEND_UNSEQUENCED = ffi.cast("enum _ENetProtocolCommand", "ENET_PROTOCOL_COMMAND_SEND_UNSEQUENCED"),
	PROTOCOL_COMMAND_BANDWIDTH_LIMIT = ffi.cast("enum _ENetProtocolCommand", "ENET_PROTOCOL_COMMAND_BANDWIDTH_LIMIT"),
	PROTOCOL_COMMAND_THROTTLE_CONFIGURE = ffi.cast("enum _ENetProtocolCommand", "ENET_PROTOCOL_COMMAND_THROTTLE_CONFIGURE"),
	PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT = ffi.cast("enum _ENetProtocolCommand", "ENET_PROTOCOL_COMMAND_SEND_UNRELIABLE_FRAGMENT"),
	PROTOCOL_COMMAND_COUNT = ffi.cast("enum _ENetProtocolCommand", "ENET_PROTOCOL_COMMAND_COUNT"),
	PROTOCOL_COMMAND_MASK = ffi.cast("enum _ENetProtocolCommand", "ENET_PROTOCOL_COMMAND_MASK"),
	PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE = ffi.cast("enum _ENetProtocolFlag", "ENET_PROTOCOL_COMMAND_FLAG_ACKNOWLEDGE"),
	PROTOCOL_COMMAND_FLAG_UNSEQUENCED = ffi.cast("enum _ENetProtocolFlag", "ENET_PROTOCOL_COMMAND_FLAG_UNSEQUENCED"),
	PROTOCOL_HEADER_FLAG_COMPRESSED = ffi.cast("enum _ENetProtocolFlag", "ENET_PROTOCOL_HEADER_FLAG_COMPRESSED"),
	PROTOCOL_HEADER_FLAG_SENT_TIME = ffi.cast("enum _ENetProtocolFlag", "ENET_PROTOCOL_HEADER_FLAG_SENT_TIME"),
	PROTOCOL_HEADER_FLAG_MASK = ffi.cast("enum _ENetProtocolFlag", "ENET_PROTOCOL_HEADER_FLAG_MASK"),
	PROTOCOL_HEADER_SESSION_MASK = ffi.cast("enum _ENetProtocolFlag", "ENET_PROTOCOL_HEADER_SESSION_MASK"),
	PROTOCOL_HEADER_SESSION_SHIFT = ffi.cast("enum _ENetProtocolFlag", "ENET_PROTOCOL_HEADER_SESSION_SHIFT"),
	SOCKOPT_NONBLOCK = ffi.cast("enum _ENetSocketOption", "ENET_SOCKOPT_NONBLOCK"),
	SOCKOPT_BROADCAST = ffi.cast("enum _ENetSocketOption", "ENET_SOCKOPT_BROADCAST"),
	SOCKOPT_RCVBUF = ffi.cast("enum _ENetSocketOption", "ENET_SOCKOPT_RCVBUF"),
	SOCKOPT_SNDBUF = ffi.cast("enum _ENetSocketOption", "ENET_SOCKOPT_SNDBUF"),
	SOCKOPT_REUSEADDR = ffi.cast("enum _ENetSocketOption", "ENET_SOCKOPT_REUSEADDR"),
	SOCKOPT_RCVTIMEO = ffi.cast("enum _ENetSocketOption", "ENET_SOCKOPT_RCVTIMEO"),
	SOCKOPT_SNDTIMEO = ffi.cast("enum _ENetSocketOption", "ENET_SOCKOPT_SNDTIMEO"),
	SOCKOPT_ERROR = ffi.cast("enum _ENetSocketOption", "ENET_SOCKOPT_ERROR"),
	SOCKOPT_NODELAY = ffi.cast("enum _ENetSocketOption", "ENET_SOCKOPT_NODELAY"),
	SOCKET_SHUTDOWN_READ = ffi.cast("enum _ENetSocketShutdown", "ENET_SOCKET_SHUTDOWN_READ"),
	SOCKET_SHUTDOWN_WRITE = ffi.cast("enum _ENetSocketShutdown", "ENET_SOCKET_SHUTDOWN_WRITE"),
	SOCKET_SHUTDOWN_READ_WRITE = ffi.cast("enum _ENetSocketShutdown", "ENET_SOCKET_SHUTDOWN_READ_WRITE"),
	SOCKET_TYPE_STREAM = ffi.cast("enum _ENetSocketType", "ENET_SOCKET_TYPE_STREAM"),
	SOCKET_TYPE_DATAGRAM = ffi.cast("enum _ENetSocketType", "ENET_SOCKET_TYPE_DATAGRAM"),
	SOCKET_WAIT_NONE = ffi.cast("enum _ENetSocketWait", "ENET_SOCKET_WAIT_NONE"),
	SOCKET_WAIT_SEND = ffi.cast("enum _ENetSocketWait", "ENET_SOCKET_WAIT_SEND"),
	SOCKET_WAIT_RECEIVE = ffi.cast("enum _ENetSocketWait", "ENET_SOCKET_WAIT_RECEIVE"),
	SOCKET_WAIT_INTERRUPT = ffi.cast("enum _ENetSocketWait", "ENET_SOCKET_WAIT_INTERRUPT"),
	HOST_BANDWIDTH_THROTTLE_INTERVAL = 1000,
	HOST_DEFAULT_MAXIMUM_PACKET_SIZE = 33554432,
	HOST_DEFAULT_MAXIMUM_WAITING_DATA = 33554432,
	HOST_DEFAULT_MTU = 1400,
	HOST_RECEIVE_BUFFER_SIZE = 262144,
	HOST_SEND_BUFFER_SIZE = 262144,
	PEER_DEFAULT_PACKET_THROTTLE = 32,
	PEER_DEFAULT_ROUND_TRIP_TIME = 500,
	PEER_FREE_RELIABLE_WINDOWS = 8,
	PEER_FREE_UNSEQUENCED_WINDOWS = 32,
	PEER_PACKET_LOSS_INTERVAL = 10000,
	PEER_PACKET_LOSS_SCALE = 65536,
	PEER_PACKET_THROTTLE_ACCELERATION = 2,
	PEER_PACKET_THROTTLE_COUNTER = 7,
	PEER_PACKET_THROTTLE_DECELERATION = 2,
	PEER_PACKET_THROTTLE_INTERVAL = 5000,
	PEER_PACKET_THROTTLE_SCALE = 32,
	PEER_PING_INTERVAL = 500,
	PEER_RELIABLE_WINDOWS = 16,
	PEER_RELIABLE_WINDOW_SIZE = 4096,
	PEER_TIMEOUT_LIMIT = 32,
	PEER_TIMEOUT_MAXIMUM = 30000,
	PEER_TIMEOUT_MINIMUM = 5000,
	PEER_UNSEQUENCED_WINDOWS = 64,
	PEER_UNSEQUENCED_WINDOW_SIZE = 1024,
	PEER_WINDOW_SIZE_SCALE = 65536,
	PROTOCOL_MAXIMUM_CHANNEL_COUNT = 255,
	PROTOCOL_MAXIMUM_FRAGMENT_COUNT = 1048576,
	PROTOCOL_MAXIMUM_MTU = 4096,
	PROTOCOL_MAXIMUM_PACKET_COMMANDS = 32,
	PROTOCOL_MAXIMUM_PEER_ID = 4095,
	PROTOCOL_MAXIMUM_WINDOW_SIZE = 65536,
	PROTOCOL_MINIMUM_CHANNEL_COUNT = 1,
	PROTOCOL_MINIMUM_MTU = 576,
	PROTOCOL_MINIMUM_WINDOW_SIZE = 4096,
}
library.clib = CLIB
return library
