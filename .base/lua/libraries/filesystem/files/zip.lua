local vfs = (...) or _G.vfs

--local zip2 = require("zip") -- GRRRR
local zip = require("minizip.init")

local CONTEXT = {}

CONTEXT.Name = "zip"

local valid_names = {
	"a", -- Hellhog XP (*.A)
	"abz", -- Alpha Black Zero (*.ABZ)
	"arf", -- Packmania 2 (*.ARF)
	"arh", -- El Airplane (*.ARH)
	"bnd", -- Neighbours From Hell (*.BND)|Neighbours From Hell 2 (*.BND)
	"bos", -- Fallout Tactics (*.BOS)
	"bot", -- Team Factor (*.BOT)
	"box", -- Cellblock Squadrons (*.BOX)
	"bin", -- X-Men Legends 2 (*.BIN)|XPand Rally (*.BIN)
	"cab", -- Microsoft Flight Simulator 2004 (*.CAB)
	"crf", -- System Shock 2 (*.CRF)|Thief (*.CRF)|Thief 2 (*.CRF)
	"csc", -- 18 Wheels Of Steel Pedal To The Metal (*.CSC)
	"ctp", -- Call To Power (*.CTP)
	"dat", -- Against Rome (*.DAT)|Defiance (*.DAT)|Ricochet Lost Worlds Recharged (*.DAT)|Ricochet Xtreme (*.DAT)|Star Wolves (*.DAT)|Uplink (*.DAT)
	"dlu", -- Dirty Little Helper 98(*.DLU)
	"fbz", -- Shadowgrounds (*.FBZ)
	"ff", -- Freedom Force (*.FF)|Freedom Force vs The 3rd Reich (*.FF)
	"flmod", -- Freelancer (*.FLMOD)
	"gro", -- Serious Sam (*.GRO)|Serious Sam 2 (*.GRO)
	"iwd", -- Call of Duty 2 (*.IWD)|Call of Duty 3 (*.IWD)|Call of Duty 4: Modern Warfare (*.IWD)|Call of Duty: World at War (*.IWD)
	"lzp", -- Law And Order 3 Justice Is Served (*.LZP)
	"mgz", -- Metal Gear Solid (*.MGZ)
	"mob", -- Master of Orion 3 (*.MOB)
	"nob", -- Vampire: The Masquerade (*.NOB)|Vampire The Masquerade Redemption (*.NOB)
	"pac", -- Desperados: Wanted Dead or Alive (*.PAC)
	"pak", -- Blitzkrieg (*.PAK)|Blitzkrieg Burning Horizon (*.PAK)|Blitzkrieg Rolling Thunder (*.PAK)|Brothers Pilots 4 (*.PAK)|Call of Juarez (*.PAK)|Far Cry (*.PAK)|Heroes of Might & Magi " XV" -- PAK)|Monte Cristo (*.PAK)|Outfront (*.PAK)|Crysis 1-3 (*.PAK)
	"pk1", -- PK2','XS Mark (*.PK1;*.PK2)
	"pk3", -- Call of Duty (*.PK3)|Quake 3 Arena (*.PK3)|Medal of Honor: Allied Assault (*.PK3)|American McGee Alice (*.PK3)|Jedi Knight 2: Jedi Outcast (*.PK3)|Heavy Metal: F.A.K.K.2 (*.PK3)
	"pk4", -- Doom 3 (*.PK4)|Quake 4 (*.PK4)|Doom 3 Resurrection Of Evil (*.PK4)
	"pod", -- Hoyle Games 2005 (*.POD)|Terminator 3 (*.POD)
	"psh", -- Itch (*.PSH)|Pusher (*.PSH)
	"rbz", -- Richard Burns Rally (*.RBZ)
	"res", -- Swat 3 Close Quarters Battle (*.RES)
	"rod", -- Hot Rod American Street Drag (*.ROD)
	"rvi", -- RVM;*.RVR','Revenant (*.RVI;*.RVM;*.RVR)
	"sab", -- Sabotain (*.SAB)
	"scs", -- Hunting Unlimited 3 (*.SCS)
	"sxt", -- Singles Flirt Up Your Life (*.SXT)
	"texturepack", -- DATA','Arena Wars (*.TEXTUREPACK;*.DATA)
	"vl2", -- Tribes 2 (*.VL2)
	"za", -- Elite Warriors (*.ZA)|Line of Sight: Vietnam (*.ZA)|Deadly Dozen (*.ZA)|Deadly Dozen 2 Pacific Theater (*.ZA)
	"zip", -- Dethkarz (*.ZIP)|Battlefield 2 (*.ZIP)|Empire Earth 2 (*.ZIP)|Falcon 4 (*.ZIP)|Fire Starter (*.ZIP)|Freedom Fighters (*.ZIP)|Hitman Contracts (*.ZIP)|Hitman Bloodmoney (*.ZIP)|Hitma Silent "Slave" --  (*.ZIP)
	"zipfs", -- 18 Wheels Of Steel Across America (*.ZIPFS)|Duke Nukem - Manhattan Project (*.ZIPFS)
	"ztd", -- Dinosaur Digs (*.ZTD)|Marine Mania (*.ZTD)
}

local function split_path(path_info)
	
	local archive_path, relative
	
	for i, ext in ipairs(valid_names) do
		archive_path, relative = path_info.full_path:match("(.-%."..ext..")/(.*)")
		if archive_path and relative then
			break
		end
	end
		
	if not archive_path and not relative then
		error("not a valid archive path", 2)
	end

	local temp = io.open(archive_path, "rb")
	local signature = temp:read(4)
	if signature ~= "\x50\x4b\x03\x04" then 
		logn(signature:dumphex())
		error("not a valid zip file: expected signature '\x50\x4b\x03\x04' got " .. signature)
	end
	
	return archive_path, relative
end

function CONTEXT:IsFile(path_info)
	local archive_path, relative = split_path(path_info)
	
	local archive = zip.open(archive_path, "r")

	if archive:locate_file(relative) then
		archive:close()
		return true
	end
	
	archive:close()
end

function CONTEXT:IsFolder(path_info)
	
	-- [zipak] files are folders
	if path_info.full_path:find("^.+%.[zipak]$") then
		return true
	end

	local archive = zip.open(archive_path, "r")

	if archive:locate_file(relative) and archive:get_file_info().crc == 0 then
		archive:close()
		return true
	end
	
	archive:close()
end

function CONTEXT:GetFiles(path_info)
	local archive_path, relative = split_path(path_info)
	
	local out = {}
	
	local archive = zip.open(archive_path, "r")
		
	local dir = relative:match("(.*/)")
	local done = {}
	
	for info in archive:files() do
		local path = info.filename
		
		if path:endswith("/") then
			path = path:sub(0, -2)
		end
		
		if path:find(relative, nil, true) and (not dir or path:match("(.*/)") == dir) then
			-- path is just . so it needs to be handled a bit different
			--print(path)
			if not dir then
				if not done[path] then
					path = path:match("(.-)/") or path
					table.insert(out, path)
					done[path] = true
				end
			else
				table.insert(out, path:match(".+/(.+)") or path)
			end
		end 
	end
	
	archive:close()
	
	return out
end

function CONTEXT:Open(path_info, mode, ...)	
	local archive_path, relative = split_path(path_info)
	local file
	
	if self:GetMode() == "read" then		
		if zip2 then
			local archive = zip2.open(archive_path, "r")
			local file = assert(archive:open(relative))
			
			self.file = file
		else		
			local archive = zip.open(archive_path, "r")
			
			if not archive:locate_file(relative) then
				archive:close()
				error("file not found in archive")
			end
			
			
			self.info = archive:get_file_info()
			archive:open_file()
			
			self.archive = archive
		end
		
	elseif self:GetMode() == "write" then
		error("not implemented")
	end
end

if zip2 then
	function CONTEXT:ReadBytes(bytes)
		return self.file:read(bytes)
	end

	function CONTEXT:SetPos(pos)
		self.file:seek("set", pos)
	end

	function CONTEXT:GetPos()
		return self.file:seek()
	end

	function CONTEXT:Close()
		self.file:close()
	end
	
	function CONTEXT:GetSize()
		local old = self:GetPos()
		local size = self.file:seek("end")
		self:SetPos(old)
		return size
	end
else
	function CONTEXT:ReadBytes(bytes)
		return self.archive:read(bytes)
	end

	function CONTEXT:SetPos(pos)
		self.archive:set_offset(math.clamp(pos, 0, self:GetSize()))
	end

	function CONTEXT:GetPos()
		return self.archive:tell()
	end

	function CONTEXT:Close()
		self.archive:close()
	end
	
	function CONTEXT:GetSize()
		return self.info.uncompressed_size
	end

	function CONTEXT:GetLastModified()
		return self.info.dosDate
	end
end

vfs.RegisterFileSystem(CONTEXT) 