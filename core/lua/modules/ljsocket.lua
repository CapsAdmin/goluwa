if jit.os == "Windows" then
	require "ljsocket.ffi_def_windows_old"   -- ffi_def_windows --ffi_def_windows_by_hand --  ffi_def_windows_old
end

return {
    socket = require "ljsocket.lib_socket",
    tcp = require "ljsocket.lib_tcp",
    poll = require "ljsocket.lib_poll",
}
