
if WINDOWS then
	ffi.cdef[[int _putenv_s(const char *var_name, const char *new_value)]]
	
	function os.setenv(key, val)
		ffi.C._putenv_s(key, val)
	end
else
	ffi.cdef[[int setenv(const char *var_name, const char *new_value, int change_flag)]]
	
	function os.setenv(key, val, flag)
		ffi.C.setenv(key, val, flag or 0)
	end
end

do
	if WINDOWS then
		local winapi = require("winapi")
		require("winapi.process")
		local temp = ffi.new("PROCESS_INFORMATION[1]")
		
		ffi.cdef([[
			int _open_osfhandle(intptr_t osfhandle, int flags);
			FILE *_fdopen(int fd, const char *mode);
			
			BOOL CreatePipe(
				PHANDLE hReadPipe,
				PHANDLE hWritePipe,
				LPSECURITY_ATTRIBUTES lpPipeAttributes,
				DWORD nSize
			);
			
			BOOL CloseHandle(PHANDLE handle);
			
			BOOL SetHandleInformation(
				HANDLE hObject,
				DWORD dwMask,
				DWORD dwFlags
			);

			BOOL PeekNamedPipe(
				HANDLE hNamedPipe,
				LPVOID lpBuffer,
				DWORD nBufferSize,
				LPDWORD lpBytesRead,
				LPDWORD lpTotalBytesAvail,
				LPDWORD lpBytesLeftThisMessage
			);
			
			BOOL ReadFile(
				HANDLE hFile,
				LPVOID lpBuffer,
				DWORD nNumberOfBytesToRead,
				LPDWORD lpNumberOfBytesRead,
				void *lpOverlapped
			);

		]])
		
		function os.execute2(cmd, cd)
			local info = ffi.new("STARTUPINFOW", 0)
			info.cb = ffi.sizeof(info)
						
			local security = ffi.new("SECURITY_ATTRIBUTES[1]")
			security[0].nLength = ffi.sizeof(security[0])
			security[0].bInheritHandle = true
			
						
			--local input = ffi.new("HANDLE[1]")
			--local output = ffi.new("HANDLE[1]")
			
			--ffi.C.CreatePipe(input, output, security, 0)
			
			--ffi.C.SetHandleInformation(input[0], 1, 0)
			--ffi.C.SetHandleInformation(output[0], 1, 0)
			
			info.dwFlags = winapi.STARTF_USESTDHANDLES
			--info.hStdInput = input[0]
			--info.hStdOutput = output[0]
									
			local flags = 0x08000000
			winapi.CreateProcess(nil, winapi.wcs_sz(cmd), nil, nil, true, flags, nil, cd, info, temp)
			--[[
			print("pipe out: ", info.hStdOutput)
			print("pipe in: ", info.hStdInput)
			local buffer = ffi.new("uint8_t[128]", 0)
			
			
			local read = ffi.new("DWORD[1]", 1)
			
			ffi.C.PeekNamedPipe(info.hStdInput, buffer, 1, read, nil, nil)
				if read[0] ~= 0 then
					ffi.C.ReadFile(info.hStdInput, buffer, 127, nil, nil)
					print(ffi.string(buffer))
				end
				
			local handle = ffi.C._open_osfhandle(ffi.cast("intptr_t", input[0]), 0)

			local str = "wwwjIWD iawjd iwd"
			local lol = ffi.cast("uint8_t *", str)
			print(ffi.C.fwrite(lol, #str, 0, ffi.C._fdopen(handle, "w")))
			
			local handle = ffi.C._open_osfhandle(ffi.cast("intptr_t", output[0]), 0)						
			local buffer = ffi.new("uint8_t[128]", 0)
			print(ffi.C.fread(buffer, 128, 1, ffi.C._fdopen(handle, "r")))
			
			print(ffi.string(buffer))]]	
		end
		
		if RELOAD then
			os.execute2([[C:\Windows\System32\help.exe]])
		end
	end
end

do
	os.setcd = fs.setcd
	os.getcd = fs.getcd

	local stack = {}
	
	function os.pushcd(dir)
		table.insert(stack, os.getcd())
		os.setcd(dir)
	end
	
	function os.popcd()
		local old = table.remove(stack)
		if old then
			os.setcd(old)
		end
	end
end

do -- by Python1320
	local dd=60*60*24
	local hh=60*60
	local mm=60

	function os.datetable(a)
		check(a, "number")
		
		local negative=false
		if a<0 then negative=true a=a*-1 end
		local f,s,m,h,d
		f=a - math.floor(a)
		f=math.Round(f*10)*0.1
		a=math.floor(a)
		d=math.floor(a/dd)
		a=a-d*dd
		h=math.floor(a/hh)
		a=a-h*hh
		m=math.floor(a/mm)
		a=a-m*mm
		s=a
		return {
			f=f,
			s=s,
			m=m,
			h=h,
			d=d,
			n=negative
		}
	end
end

do -- by Python1320
	local conjunction=  " and"
	local conjunction2= ","
	
	function os.prettydate(t)
		check(t, "number", "table")

		if type(t)=="number" then
			t=datetable(t)
		end

		local tbl={}
		if t.d~=0 then
			table.insert(tbl,t.d .." day"..(t.d==1 and "" or "s"))
		end

		local lastand
		if t.h~=0 then
			if #tbl>0 then lastand=table.insert(tbl,conjunction)table.insert(tbl," ")end
			table.insert(tbl,t.h .." hour"..(t.h==1 and "" or "s"))
		end
		if t.m~=0 then
			if #tbl>0 then lastand=table.insert(tbl,conjunction)table.insert(tbl," ")end
			table.insert(tbl,t.m .." minute"..(t.m==1 and "" or "s"))
		end
		if t.s~=0 or #tbl==0 then
			if #tbl>0 then lastand=table.insert(tbl,conjunction)table.insert(tbl," ")end
			table.insert(tbl,t.s .."."..math.Round(t.f*10).." seconds")
		end
		if t.n then
			table.insert(tbl," in the past")
		end
		for k,v in pairs(tbl) do 
			if v==conjunction and k~=lastand then
				tbl[k]=conjunction2
			end
		end

		return table.concat ( tbl , "" ) 
	end
end