setfenv(1, require'winapi')
require'winapi.mmdevice'

local CO_E_FIRST       = 0x800401F0
local CO_E_LAST        = 0x800401FF

-- Create an instance of the enumeration interface
local pEnumerator = ffi.new("IMMDeviceEnumerator *[1]")

CoCreateInstance(CLSID_MMDeviceEnumerator,
	nil,
	CLSCTX_INPROC_SERVER,
	IID_IMMDeviceEnumerator,
	ffi.cast("void**",pEnumerator));

--pEnumerator = pEnumerator[0];
--print("pEnumerator: ", pEnumerator[0])
local ppDevices = ffi.new("IMMDeviceCollection *[1]")

--[[
print("About To EnumAudioEndpoints")
print("        pEnumerator: ", pEnumerator[0])
print("               eAll: ", ffi.C.eAll)
print("DEVICE_STATE_ACTIVE: ", ffi.C.DEVICE_STATE_ACTIVE)
print("          ppDevices: ", ppDevices)
--]]

hr = pEnumerator[0].EnumAudioEndpoints(pEnumerator[0], ffi.C.eAll, ffi.C.DEVICE_STATE_ACTIVE, ppDevices)

--print("EnumAudioEndpoints: ", HRESULT_PARTS(hr))

if hr ~= 0 then
	return false, hr
end
ppDevices = ppDevices[0]

-- get the count of devices
local pcDevices = ffi.new("UINT[1]")
hr = ppDevices:GetCount(pcDevices)

--print("GetCount: ", HRESULT_PARTS(hr))
--print("Count of devices: ", pcDevices[0])

local deviceCount = pcDevices[0];
local ppDevice = ffi.new("IMMDevice * [1]")
for i=0,deviceCount-1 do
	local hr = ppDevices:Item(i, ppDevice)
	--print("Item: ", ppDevice[0], HRESULT_PARTS(hr))

	if hr == 0 then
		pEndPoint = ppDevice[0]
		local ppstrId = ffi.new("PWSTR [1]")
		hr = pEndPoint:GetId(ppstrId)
		local deviceID = mbs(ppstrId[0])
		--print("Device ID: ", deviceID)

		-- open property store
		local pProps = ffi.new("IPropertyStore * [1]");
		hr = pEndPoint:OpenPropertyStore(ffi.C.STGM_READ, pProps);
		--print("Open Property Store: ", HRESULT_PARTS(hr))

		if hr ~= 0 then
			break
		end

		local pStore = pProps[0];
		-- How many properties
		local cProps = ffi.new("DWORD[1]")
		hr = pStore.lpVtbl.GetCount(pStore,cProps);
		--print("PropertyStore:GetCount: ", cProps[0])

		-- for each of the properties, get the key
		-- then the value
		local propVar = ffi.new("PROPVARIANT");
		hr = pStore.lpVtbl.GetValue(pStore, PKEY_Device_FriendlyName, propVar);
		local value = mbs(propVar.pwszVal)
		print("Value: ", value)

	end
end
