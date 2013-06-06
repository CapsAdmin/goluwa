local gserv = {}

function gserv.StartFastDL()
	local meh = lfs.currentdir()
	lfs.chdir(SRCDS .. "..\\nginx")
	os.execute("start nginx.exe")
	lfs.chdir(meh)
end

function gserv.StopFastDL()
	local meh = lfs.currentdir()
	lfs.chdir(SRCDS .. "..\\nginx")
	os.execute("nginx.exe -s quit")
	lfs.chdir(meh)
end

function gserv.ReloadFastDL()
	local addons = {}

	for i in lfs.dir(GARRYSMOD .. "addons") do
		if i:sub(1, 1) ~= "." and lfs.attributes(GARRYSMOD .. "addons\\" .. i, "mode") == "directory" then
			addons[#addons + 1] = "/addons/" .. i .. "$uri"
		end
	end

	local file = io.open(SRCDS .. "..\\nginx\\conf\\nginx.conf", "wb")

	file:write([[
worker_processes 8;

events {
	worker_connections 1024;
}

http {
	include mime.types;
	default_type application/octet-stream;

	autoindex on;

	server {
		server_name .capsadmin.com;
		listen 80 default_server;

		location / {
			root ]] .. "G:\\srcds\\orangebox\\garrysmod" .. [[;
			try_files $uri $uri/ ]] .. table.concat(addons, " ") .. [[ =404;
		}

		location /blah {
			proxy_pass http://127.0.0.1:27000;
		}

		location /websocket {
			proxy_pass http://127.0.0.1:1234;
			proxy_http_version 1.1;
			proxy_set_header Upgrade $http_upgrade;
			proxy_set_header Connection "upgrade";
		}
	}
}
]])

	file:close()

	local meh = lfs.currentdir()
	lfs.chdir(SRCDS .. "..\\nginx")
	os.execute("nginx.exe -s reload")
	lfs.chdir(meh)
end

function gserv.CompressThings()
	local path1 = GARRYSMOD .. "maps"

	for i in lfs.dir(path1) do
		local path2 = path1 .. "\\" .. i

		if lfs.attributes(path2, "mode") == "file" and i:find("%.bsp$") then
			local path3 = path2 .. ".bz2"

			if not lfs.attributes(path3) then
				os.execute(string.format(SRCDS .. "..\\bzip2.exe --keep --best %q", path2))
			end
		end
	end
	
	for i in io.lines(GARRYSMOD .. "data\\gserv\\fastdl_paths.txt") do
		--[[local parts = {}
		
		for j in i:gmatch("[^\\/]+") do 
			parts[#parts + 1] = j 
		end
		
		for j = 1, #parts - 1 do 
			lfs.mkdir(GARRYSMOD .. table.concat(parts, "\\", 1, j))
		end]]

		os.execute(string.format(SRCDS .. "..\\bzip2.exe --best --keep %q", i))
	end
end

function gserv.UpdateRepositories()
	local repos = luadata.ReadFile(GARRYSMODX .. "data/gserv/repositories.txt")

	for url, info in pairs(repos) do
		info.type = info.type or "svn"
		info.name = info.name or url:gsub("%p", "")
		
		if info.type == "svn" then
			if url:find("^https?://") or url:find("^svn://") then
				os.execute(string.format("svn checkout %q %q", url, GARRYSMOD .. "addons\\" .. info.name))
			else
				os.execute(string.format("svn update %q", url))
			end
		elseif info.type == "git" then
			if url:find("^https?://") or url:find("^git://") then
				os.execute(string.format("git clone %q %q", url, GARRYSMOD .. "addons\\" .. info.name))
			else
				local meh = lfs.currentdir()
				lfs.chdir(url)
				os.execute("git pull")
				lfs.chdir(meh)
			end
		end
	end
end

function gserv.UpdateGame()
	os.execute(SRCDS .. "..\\hldsupdatetool -command update -game garrysmod -dir .")
	gserv.InjectFastDLSomething()
end

do -- server monitoring
	ffi.cdef([[
		typedef unsigned int DWORD;
		typedef char* LPTSTR;
		typedef unsigned short WORD;
		typedef int BOOL;
		typedef unsigned char* LPBYTE;
		typedef void* HANDLE;
		typedef unsigned int UINT;

		typedef struct _STARTUPINFO {
		  DWORD  cb;
		  LPTSTR lpReserved;
		  LPTSTR lpDesktop;
		  LPTSTR lpTitle;
		  DWORD  dwX;
		  DWORD  dwY;
		  DWORD  dwXSize;
		  DWORD  dwYSize;
		  DWORD  dwXCountChars;
		  DWORD  dwYCountChars;
		  DWORD  dwFillAttribute;
		  DWORD  dwFlags;
		  WORD   wShowWindow;
		  WORD   cbReserved2;
		  LPBYTE lpReserved2;
		  HANDLE hStdInput;
		  HANDLE hStdOutput;
		  HANDLE hStdError;
		} STARTUPINFO, *LPSTARTUPINFO;

		typedef struct _PROCESS_INFORMATION {
		  HANDLE hProcess;
		  HANDLE hThread;
		  DWORD  dwProcessId;
		  DWORD  dwThreadId;
		} PROCESS_INFORMATION, *LPPROCESS_INFORMATION;

		BOOL CreateProcessA(const char* a, const char* b, void* c, void* d, BOOL e, DWORD f, void* g, const char* h, void* i, void* j);
		BOOL GetExitCodeProcess(HANDLE a, DWORD* code);
		DWORD WaitForSingleObject(HANDLE a, DWORD timeout);
		DWORD SetErrorMode(DWORD mode);
		BOOL TerminateProcess(HANDLE a, UINT code);

	]])

	local servers = {}

	function gserv.GetAllServers()
		return servers
	end

	function gserv.StartServer(id)
		id = tostring(id)
				
		local startupinfo = ffi.new("STARTUPINFO")
		ffi.fill(startupinfo, ffi.sizeof("STARTUPINFO"))
		startupinfo.cb = ffi.sizeof("STARTUPINFO")

		local processinfo = ffi.new("PROCESS_INFORMATION")
		ffi.fill(processinfo, ffi.sizeof("PROCESS_INFORMATION"))

		ffi.C.SetErrorMode(bit.bor(0x0001, 0x0004, 0x0002, 0x8000))
		ffi.C.CreateProcessA(nil, SRCDS .. "srcds.exe -withjit -console -game garrysmod -insecure -dev -nohltv -tickrate 100 -maxplayers 15 -ip 0.0.0.0 -port 27015 -nocrashdialog", nil, nil, 0, 0, nil, nil, startupinfo, processinfo)
		
		logf("created server %s", id)
		
		servers[id] = processinfo
	end

	function gserv.StopServer(id)
		id = tostring(id)

		if servers[id] then
			ffi.C.TerminateProcess(servers[id].hProcess, 0)
			servers[id] = nil
		end
	end

	local status = ffi.new("DWORD[1]")

	event.AddListener("OnUpdate", "server_monitor", function()
		for id, processinfo in pairs(servers) do
			if ffi.C.WaitForSingleObject(processinfo.hProcess, 0) == 0 then
				ffi.C.GetExitCodeProcess(processinfo.hProcess, status) 
				logf("server %s stopped with error code 0x%.8X", id, status[0])
				
				gserv.StartServer(id)
			end
		end
	end)
end

function gserv.InjectFastDLSomething()
	local lua = [[FASTDL_PATHS = {}

old_resource_AddFile = old_resource_AddFile or resource.AddFile

local um = {
	{
		[".mdl"] = true, 
		[".vvd"] = true, 
		[".ani"] = true, 
		[".dx80.vtx"] = true, 
		[".dx90.vtx"] = true, 
		[".sw.vtx"] = true, 
		[".phy"] = true, 
		[".jpg"] = true	,
	},
	{
		[".vmt"] = true,
		[".vtf"] = true,
	}
}

local um2 = {}

for k1, v1 in pairs(um) do
	for k2, v2 in pairs(v1) do
		um2[k2] = v1
	end
end

local function write(path)
	for k, v in pairs(select(2, file.Find("addons/*", "GAME"))) do
		local uh = "addons/" .. v .. "/" .. path
		if file.Exists(uh, "GAME") then
			path = util.RelativePathToFull(uh)
			break
		end
	end
	
	FASTDL_PATHS[path] = 1
	local str = ""
	for k,v in pairs(FASTDL_PATHS) do str = str .. k .. "\n" end
	file.Write("gserv/fastdl_paths.txt", str)
end

function resource.AddFile(path, ...)
	local pathx, extension = path:match("(.-)(%..+)")
	local extensions = um2[extension]
	
	if extensions then
		for ext in pairs(extensions) do
			if ext ~= extension and file.Exists(pathx .. ext, "GAME") then
				write(pathx..ext)
			end
		end
	end
	
	return old_resource_AddFile(path, ...)
end

old_resource_AddSingleFile = old_resource_AddSingleFile or resource.AddSingleFile

function resource.AddSingleFile(path, ...)
	write(path)
	return old_resource_AddSingleFile(path, ...)
end

-- END OF FASTDL INJECT
]]

	local path = GARRYSMOD .. "lua\\includes\\init.lua"
	local fil = io.open(path)
	local str = fil:read("*all")
	fil:close()
	
	if str:explode("\n")[67] ~= "-- END OF FASTDL INJECT" then
		local new = lua .. str
		local fil = io.open(path, "w")
		fil:write(new)
		fil:close()
	end

end

return gserv