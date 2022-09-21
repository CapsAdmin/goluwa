local ffi = require("ffi")
local CLIB = assert(ffi.load("tls"))
ffi.cdef([[struct tls {};
struct tls_config {};
int(tls_config_set_key_mem)(struct tls_config*,const unsigned char*,unsigned long);
const unsigned char*(tls_peer_cert_chain_pem)(struct tls*,unsigned long*);
int(tls_connect_socket)(struct tls*,int,const char*);
const char*(tls_peer_cert_issuer)(struct tls*);
int(tls_config_set_protocols)(struct tls_config*,unsigned int);
int(tls_config_set_ca_file)(struct tls_config*,const char*);
void(tls_config_clear_keys)(struct tls_config*);
int(tls_config_set_ciphers)(struct tls_config*,const char*);
int(tls_config_set_keypair_ocsp_file)(struct tls_config*,const char*,const char*,const char*);
int(tls_config_set_key_file)(struct tls_config*,const char*);
void(tls_free)(struct tls*);
int(tls_config_set_ocsp_staple_mem)(struct tls_config*,const unsigned char*,unsigned long);
int(tls_peer_ocsp_cert_status)(struct tls*);
int(tls_init)();
long(tls_peer_ocsp_revocation_time)(struct tls*);
int(tls_peer_ocsp_response_status)(struct tls*);
int(tls_peer_ocsp_crl_reason)(struct tls*);
void(tls_config_insecure_noverifytime)(struct tls_config*);
void(tls_reset)(struct tls*);
int(tls_config_set_dheparams)(struct tls_config*,const char*);
const char*(tls_config_error)(struct tls_config*);
int(tls_config_set_ocsp_staple_file)(struct tls_config*,const char*);
const char*(tls_peer_cert_subject)(struct tls*);
void(tls_config_verify_client)(struct tls_config*);
int(tls_config_add_keypair_ocsp_mem)(struct tls_config*,const unsigned char*,unsigned long,const unsigned char*,unsigned long,const unsigned char*,unsigned long);
int(tls_connect_cbs)(struct tls*,long(*_read_cb)(struct tls*,void*,unsigned long,void*),long(*_write_cb)(struct tls*,const void*,unsigned long,void*),void*,const char*);
struct tls_config*(tls_config_new)();
void(tls_config_insecure_noverifycert)(struct tls_config*);
int(tls_config_set_ecdhecurves)(struct tls_config*,const char*);
int(tls_config_set_crl_file)(struct tls_config*,const char*);
int(tls_conn_cipher_strength)(struct tls*);
long(tls_peer_ocsp_next_update)(struct tls*);
int(tls_accept_fds)(struct tls*,struct tls**,int,int);
int(tls_config_set_cert_file)(struct tls_config*,const char*);
int(tls_handshake)(struct tls*);
struct tls*(tls_server)();
struct tls*(tls_client)();
int(tls_config_set_crl_mem)(struct tls_config*,const unsigned char*,unsigned long);
int(tls_peer_cert_provided)(struct tls*);
void(tls_config_ocsp_require_stapling)(struct tls_config*);
int(tls_accept_cbs)(struct tls*,struct tls**,long(*_read_cb)(struct tls*,void*,unsigned long,void*),long(*_write_cb)(struct tls*,const void*,unsigned long,void*),void*);
int(tls_config_parse_protocols)(unsigned int*,const char*);
long(tls_peer_cert_notafter)(struct tls*);
void(tls_config_verify_client_optional)(struct tls_config*);
int(tls_config_add_keypair_ocsp_file)(struct tls_config*,const char*,const char*,const char*);
void(tls_config_verify)(struct tls_config*);
int(tls_accept_socket)(struct tls*,struct tls**,int);
int(tls_config_set_alpn)(struct tls_config*,const char*);
long(tls_peer_cert_notbefore)(struct tls*);
int(tls_connect_fds)(struct tls*,int,int,const char*);
void(tls_config_free)(struct tls_config*);
const char*(tls_peer_ocsp_url)(struct tls*);
int(tls_connect_servername)(struct tls*,const char*,const char*,const char*);
const char*(tls_error)(struct tls*);
long(tls_peer_ocsp_this_update)(struct tls*);
int(tls_config_set_verify_depth)(struct tls_config*,int);
const char*(tls_peer_ocsp_result)(struct tls*);
int(tls_config_set_ecdhecurve)(struct tls_config*,const char*);
int(tls_ocsp_process_response)(struct tls*,const unsigned char*,unsigned long);
void(tls_config_prefer_ciphers_server)(struct tls_config*);
long(tls_write)(struct tls*,const void*,unsigned long);
long(tls_read)(struct tls*,void*,unsigned long);
int(tls_configure)(struct tls*,struct tls_config*);
const char*(tls_conn_alpn_selected)(struct tls*);
void(tls_unload_file)(unsigned char*,unsigned long);
int(tls_connect)(struct tls*,const char*,const char*);
const char*(tls_conn_version)(struct tls*);
int(tls_config_set_keypair_mem)(struct tls_config*,const unsigned char*,unsigned long,const unsigned char*,unsigned long);
int(tls_conn_session_resumed)(struct tls*);
int(tls_config_set_cert_mem)(struct tls_config*,const unsigned char*,unsigned long);
int(tls_peer_cert_contains_name)(struct tls*,const char*);
int(tls_config_set_session_lifetime)(struct tls_config*,int);
void(tls_config_insecure_noverifyname)(struct tls_config*);
const char*(tls_conn_cipher)(struct tls*);
unsigned char*(tls_load_file)(const char*,unsigned long*,char*);
int(tls_config_set_keypair_file)(struct tls_config*,const char*,const char*);
const char*(tls_conn_servername)(struct tls*);
int(tls_close)(struct tls*);
const char*(tls_default_ca_cert_file)();
int(tls_config_set_ca_path)(struct tls_config*,const char*);
int(tls_config_set_keypair_ocsp_mem)(struct tls_config*,const unsigned char*,unsigned long,const unsigned char*,unsigned long,const unsigned char*,unsigned long);
int(tls_config_set_session_fd)(struct tls_config*,int);
const char*(tls_peer_cert_hash)(struct tls*);
int(tls_config_add_keypair_mem)(struct tls_config*,const unsigned char*,unsigned long,const unsigned char*,unsigned long);
int(tls_config_add_keypair_file)(struct tls_config*,const char*,const char*);
void(tls_config_prefer_ciphers_client)(struct tls_config*);
int(tls_config_add_ticket_key)(struct tls_config*,unsigned int,unsigned char*,unsigned long);
int(tls_config_set_session_id)(struct tls_config*,const unsigned char*,unsigned long);
int(tls_config_set_ca_mem)(struct tls_config*,const unsigned char*,unsigned long);
]])
local library = {}

--====helper safe_clib_index====
function SAFE_INDEX(clib)
	return setmetatable(
		{},
		{
			__index = function(_, k)
				local ok, val = pcall(function()
					return clib[k]
				end)

				if ok then
					return val
				elseif clib_index then
					return clib_index(k)
				end
			end,
		}
	)
end

--====helper safe_clib_index====
CLIB = SAFE_INDEX(CLIB)
library = {
	config_set_key_mem = CLIB.tls_config_set_key_mem,
	peer_cert_chain_pem = CLIB.tls_peer_cert_chain_pem,
	connect_socket = CLIB.tls_connect_socket,
	peer_cert_issuer = CLIB.tls_peer_cert_issuer,
	config_set_protocols = CLIB.tls_config_set_protocols,
	config_set_ca_file = CLIB.tls_config_set_ca_file,
	config_clear_keys = CLIB.tls_config_clear_keys,
	config_set_ciphers = CLIB.tls_config_set_ciphers,
	config_set_keypair_ocsp_file = CLIB.tls_config_set_keypair_ocsp_file,
	config_set_key_file = CLIB.tls_config_set_key_file,
	free = CLIB.tls_free,
	config_set_ocsp_staple_mem = CLIB.tls_config_set_ocsp_staple_mem,
	peer_ocsp_cert_status = CLIB.tls_peer_ocsp_cert_status,
	init = CLIB.tls_init,
	peer_ocsp_revocation_time = CLIB.tls_peer_ocsp_revocation_time,
	peer_ocsp_response_status = CLIB.tls_peer_ocsp_response_status,
	peer_ocsp_crl_reason = CLIB.tls_peer_ocsp_crl_reason,
	config_insecure_noverifytime = CLIB.tls_config_insecure_noverifytime,
	reset = CLIB.tls_reset,
	config_set_dheparams = CLIB.tls_config_set_dheparams,
	config_error = CLIB.tls_config_error,
	config_set_ocsp_staple_file = CLIB.tls_config_set_ocsp_staple_file,
	peer_cert_subject = CLIB.tls_peer_cert_subject,
	config_verify_client = CLIB.tls_config_verify_client,
	config_add_keypair_ocsp_mem = CLIB.tls_config_add_keypair_ocsp_mem,
	connect_cbs = CLIB.tls_connect_cbs,
	config_new = CLIB.tls_config_new,
	config_insecure_noverifycert = CLIB.tls_config_insecure_noverifycert,
	config_set_ecdhecurves = CLIB.tls_config_set_ecdhecurves,
	config_set_crl_file = CLIB.tls_config_set_crl_file,
	conn_cipher_strength = CLIB.tls_conn_cipher_strength,
	peer_ocsp_next_update = CLIB.tls_peer_ocsp_next_update,
	accept_fds = CLIB.tls_accept_fds,
	config_set_cert_file = CLIB.tls_config_set_cert_file,
	handshake = CLIB.tls_handshake,
	server = CLIB.tls_server,
	client = CLIB.tls_client,
	config_set_crl_mem = CLIB.tls_config_set_crl_mem,
	peer_cert_provided = CLIB.tls_peer_cert_provided,
	config_ocsp_require_stapling = CLIB.tls_config_ocsp_require_stapling,
	accept_cbs = CLIB.tls_accept_cbs,
	config_parse_protocols = CLIB.tls_config_parse_protocols,
	peer_cert_notafter = CLIB.tls_peer_cert_notafter,
	config_verify_client_optional = CLIB.tls_config_verify_client_optional,
	config_add_keypair_ocsp_file = CLIB.tls_config_add_keypair_ocsp_file,
	config_verify = CLIB.tls_config_verify,
	accept_socket = CLIB.tls_accept_socket,
	config_set_alpn = CLIB.tls_config_set_alpn,
	peer_cert_notbefore = CLIB.tls_peer_cert_notbefore,
	connect_fds = CLIB.tls_connect_fds,
	config_free = CLIB.tls_config_free,
	peer_ocsp_url = CLIB.tls_peer_ocsp_url,
	connect_servername = CLIB.tls_connect_servername,
	error = CLIB.tls_error,
	peer_ocsp_this_update = CLIB.tls_peer_ocsp_this_update,
	config_set_verify_depth = CLIB.tls_config_set_verify_depth,
	peer_ocsp_result = CLIB.tls_peer_ocsp_result,
	config_set_ecdhecurve = CLIB.tls_config_set_ecdhecurve,
	ocsp_process_response = CLIB.tls_ocsp_process_response,
	config_prefer_ciphers_server = CLIB.tls_config_prefer_ciphers_server,
	write = CLIB.tls_write,
	read = CLIB.tls_read,
	configure = CLIB.tls_configure,
	conn_alpn_selected = CLIB.tls_conn_alpn_selected,
	unload_file = CLIB.tls_unload_file,
	connect = CLIB.tls_connect,
	conn_version = CLIB.tls_conn_version,
	config_set_keypair_mem = CLIB.tls_config_set_keypair_mem,
	conn_session_resumed = CLIB.tls_conn_session_resumed,
	config_set_cert_mem = CLIB.tls_config_set_cert_mem,
	peer_cert_contains_name = CLIB.tls_peer_cert_contains_name,
	config_set_session_lifetime = CLIB.tls_config_set_session_lifetime,
	config_insecure_noverifyname = CLIB.tls_config_insecure_noverifyname,
	conn_cipher = CLIB.tls_conn_cipher,
	load_file = CLIB.tls_load_file,
	config_set_keypair_file = CLIB.tls_config_set_keypair_file,
	conn_servername = CLIB.tls_conn_servername,
	close = CLIB.tls_close,
	default_ca_cert_file = CLIB.tls_default_ca_cert_file,
	config_set_ca_path = CLIB.tls_config_set_ca_path,
	config_set_keypair_ocsp_mem = CLIB.tls_config_set_keypair_ocsp_mem,
	config_set_session_fd = CLIB.tls_config_set_session_fd,
	peer_cert_hash = CLIB.tls_peer_cert_hash,
	config_add_keypair_mem = CLIB.tls_config_add_keypair_mem,
	config_add_keypair_file = CLIB.tls_config_add_keypair_file,
	config_prefer_ciphers_client = CLIB.tls_config_prefer_ciphers_client,
	config_add_ticket_key = CLIB.tls_config_add_ticket_key,
	config_set_session_id = CLIB.tls_config_set_session_id,
	config_set_ca_mem = CLIB.tls_config_set_ca_mem,
}
library.e = {
	API = 20200120,
	PROTOCOL_TLSv1_0 = 2,
	PROTOCOL_TLSv1_1 = 4,
	PROTOCOL_TLSv1_2 = 8,
	PROTOCOL_TLSv1_3 = 16,
	WANT_POLLIN = -2,
	WANT_POLLOUT = -3,
	OCSP_RESPONSE_SUCCESSFUL = 0,
	OCSP_RESPONSE_MALFORMED = 1,
	OCSP_RESPONSE_INTERNALERROR = 2,
	OCSP_RESPONSE_TRYLATER = 3,
	OCSP_RESPONSE_SIGREQUIRED = 4,
	OCSP_RESPONSE_UNAUTHORIZED = 5,
	OCSP_CERT_GOOD = 0,
	OCSP_CERT_REVOKED = 1,
	OCSP_CERT_UNKNOWN = 2,
	CRL_REASON_UNSPECIFIED = 0,
	CRL_REASON_KEY_COMPROMISE = 1,
	CRL_REASON_CA_COMPROMISE = 2,
	CRL_REASON_AFFILIATION_CHANGED = 3,
	CRL_REASON_SUPERSEDED = 4,
	CRL_REASON_CESSATION_OF_OPERATION = 5,
	CRL_REASON_CERTIFICATE_HOLD = 6,
	CRL_REASON_REMOVE_FROM_CRL = 8,
	CRL_REASON_PRIVILEGE_WITHDRAWN = 9,
	CRL_REASON_AA_COMPROMISE = 10,
	MAX_SESSION_ID_LENGTH = 32,
	TICKET_KEY_SIZE = 48,
}
library.clib = CLIB
return library