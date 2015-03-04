local libusb = require("libraries.ffi.libusb")

libusb.init(nil)

local devices = ffi.new("libusb_device**[1]")

for i = 1, libusb.get_device_list(nil, devices) do
	local device = devices[0][i-1]
	local desc = ffi.new("struct libusb_device_descriptor[1]")
	libusb.get_device_descriptor(device, desc)
	desc = desc[0]
	
	logf("%04x:%04x (bus %d, device %d)\n",	desc.idVendor, desc.idProduct, libusb.get_bus_number(device), libusb.get_device_address(device))
end