local ok = true

-- check if git exists
if os.execute("git help") ~= 0 then
	print("git was not found! (git help)")
	print("http://git-scm.com/download/win\n")	
	ok = false
end

if os.execute("mingw32-make -help") ~= 0 then
	print("mingw was not found! (mingw32-make)")
	print("http://www.mingw.org/\n")
	ok = false
end

if not ok then 
	print("remember to install these to system path")
	print("")
return end

-- R will convert this path into a full path
local dir = R"%DATA%/temp/" 

-- create the dir if it doesn't exist
vfs.CreateFoldersFromPath(dir)

-- ugh
dir = dir:gsub("NUL", "")

local old_dir = lfs.currentdir()
lfs.chdir(dir)

os.execute("git clean -d -x -f")
os.execute("git rebase")
os.execute("git clone https://github.com/erikd/libsndfile.git")

local src_dir = dir .. "libsndfile"
lfs.chdir(src_dir)

os.execute("mingw32-make")

do 
	local old_dir = old_dir:gsub("/", "\\")
	local launcher = old_dir:gsub("%.base\\bin\\windows\\x86", "launch.bat")
		
	local batch = 
	"ping -n 1 127.0.0.1 >nu\n" ..
	"xcopy \"libsnd.dll\" \""..old_dir.."\" /Y /C /R\n" ..
	"start \"\" \"".. launcher .."\"\n"

	vfs.Write(src_dir .. "/" .. "temp.cmd", batch)
	
	os.execute("start \"\" temp.cmd")
end

lfs.chdir(old_dir)

os.exit() 