--wolffs 1.0 by Somepotato
fs={
	mounted={}
}
local FS={}
function FS:FileExists(dir)
	return false
end
function FS:FileOpen(dir)
	return false
end
function FS:FileRead(dir)
	return ""
end
function FS:FileWrite(dir, stringcontent)
	return false
end
function FS:IsFile(path)
	return false
end
function FS:IsDir(path)
	return false
end
function FS:MakeFile(path)
	return false
end
function FS:MakeDir(path)
	return false
end
function FS:TraverseDir(path)
	return {}
end
function fs.Init()
	
	local FS=fs.NewFS()
	function FS:FileExists(dir)
		return file.Exists(self.basedir.."/"..dir,true)
	end
	function FS:FileOpen(dir)
		return false
	end
	function FS:FileRead(dir)
		return file.Read(self.basedir.."/"..dir,true)
	end
	function FS:FileWrite(dir, stringcontent)
		if(self.basedir:sub(1,4)~="data") then
			error("Can't write outside of the Garry's Mod data directory!")
		end
		local suc=pcall(file.Write,self.basedir:gsub("data/","").."/"..dir,stringcontent)
		return suc
	end
	function FS:IsFile(path)
		return false
	end
	function FS:IsDir(path)
		return file.FolderExists(self.basedir.."/"..path,true)
	end
	function FS:MakeFile(path)
		return self:FileWrite(path,"")
	end
	function FS:MakeDir(path)
		return file.MkDir(self.basedir.."/"..path,true)
	end
	function FS:TraverseDir(path)
		return file.Find(self.basedir.."/"..path.."/*",true)
	end
	fs.Base=FS
	fs.Main=fs.MountDir("")
end
function fs.MountDir(dir,root)
	local mt=setmetatable({basedir=dir,root=root},{__index=fs.Base})
	table.insert(fs.mounted,mt)
	return mt
end
function fs.Mount(fs,root)
	table.insert(fs.mounted,setmetatable({root=root},{__index=fs}))
end
function fs.NewFS()
	return table.copy(FS)
end
local function foreachmounted(callback)
	for k,v in pairs(fs.mounted) do
		local ret=callback(v,v.root~=nil and v.root or "")
		if ret then return ret end
	end
	return false
end
local function isInDir(path1, path2)
	if(path2=="") then return true end--its at the root
	local subdirs1=path1:explode("/")
	local subdirs2=path2:explode("/")
	--get rid of last one as its a filename
	table.remove(subdirs1,#subdirs1)
	--2nd one is a root dir, not a filename
	for k,v in pairs(subdirs1) do
		if(subdirs2[k]:lower()~=v:lower()) then return false end
	end
	return true
end
--print(isInDir("data/test/aids.txt","data/test"))
-------------
function fs.Exists(dir)
	return foreachmounted(function(fs,root)
		if(not isInDir(dir, root)) then return end
		
		if(fs:FileExists(dir:sub(#root+1))) then
			return true
		end
	end)
end
function fs.Read(dir)
	return foreachmounted(function(fs,root)
		if(not isInDir(dir, root)) then return end
		
		if(fs:FileExists(dir:sub(#root+1))) then
			return fs:FileRead(dir:sub(#root+1))
		end
	end)
end
function fs.Write(dir,data)
	return fs.Main:FileWrite(dir,data)
end
function fs.TraverseDir(dir)
	local total={}
	foreachmounted(function(fs,root)
		if(not isInDir(dir, root)) then return end
		
		if(fs:IsDir(dir:sub(#root+1))) then
			local traversed=fs:TraverseDir(dir:sub(#root+1))
			for k,v in pairs(traversed) do
				local exit
				for k2,v2 in pairs(total) do if(v2==v) then exit=true break end end
				if not exit then 
					table.insert(total,v)
				end
			end
		end
	end)
	return total
	--return fs.Main:FileWrite(dir,data)
end


-------------
fs.Init()