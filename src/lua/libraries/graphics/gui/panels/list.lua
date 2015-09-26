local gui = ... or _G.gui

local PANEL = {}

PANEL.ClassName = "list"

function PANEL:Initialize()
	self.columns = {}
	self.last_div = NULL
	self.list = NULL

	local top = self:CreatePanel("base", "top")
	--top:SetLayoutParentOnLayout(true)
	top:SetMargin(Rect())
	--top:SetClipping(true)
	top:SetNoDraw(true)

	local list = self:CreatePanel("base", "list")
	self:SetStyle("property")
	--list:SetClipping(true)
	 list:SetNoDraw(true)
	--list:SetCachedRendering(true)

	local scroll = self:CreatePanel("scroll", "scroll")
	scroll:SetYScrollBar(true)
	scroll:SetPanel(list)

	self:SetupSorted("")
end

function PANEL:OnStyleChanged(skin)
	self.list:SetColor(skin.font_edit_background)

	for i, column in ipairs(self.columns) do
		column.div:SetColor(skin.font_edit_background)
	end

	for _, entry in ipairs(self.entries) do
		for i, label in ipairs(entry.labels) do
			label:SetTextColor(skin.text_color)
		end
	end
end

function PANEL:OnLayout(S)
	self.top:SetWidth(self:GetWidth())
	self.top:SetHeight(S*10)
	self.scroll:SetPosition(Vec2(0, S*10))
	self.scroll:SetWidth(self:GetWidth())
	self.scroll:SetHeight(self:GetHeight() - S*10)

	local y = 0
	for _, entry in ipairs(self.entries) do
		entry:SetPosition(Vec2(0, y))
		entry:SetHeight(S*8)
		entry:SetWidth(self:GetWidth())
		y = y + entry:GetHeight()

		local x = 0
		for i, label in ipairs(entry.labels) do
			local w = self.columns[i].div.left:GetWidth()
			label:SetWidth(w)
			label:SetX(x-S)
			label:SetHeight(entry:GetHeight())

			w = w + self.columns[i].div:GetDividerWidth()

			if self.columns[i].div.left then
				x = x + w
			end
		end
	end

	self.list:SetHeight(y)
	self.list:SetWidth(self:GetWidth())

	--self:SizeColumnsToFit()

	local column = self.columns[1]
	--column:SetMargin(Rect()+2*S)
	--column:SetHeight(S*10)
	column.div:SetWidth(self:GetWidth())

	if #self.columns > 0 then
		self.columns[#self.columns].div:SetDividerPosition(self:GetWidth())
	end
end

function PANEL:SizeColumnsToFit()
	for i, column in ipairs(self.columns) do
		column.div:SetDividerPosition(column:GetTextSize().x + column.icon:GetWidth() * 2)
	end
end

function PANEL:SetupSorted(...)
	self.list:RemoveChildren()
	self.top:RemoveChildren()

	self.last_div = NULL

	self.columns = {}
	self.entries = {}

	for i = 1, select("#", ...) do
		local v = select(i, ...)
		local name, func

		if type(v) == "table" then
			 name, func = next(v)
		elseif type(v) == "string" then
			name = v
			func = table.sort
		end

		local column = gui.CreatePanel("text_button", self)
		column:SetText(name)
		column:SizeToText()
		column.label:SetupLayout("left", "top", "center_y_simple")

		local icon = column:CreatePanel("base", "icon")
		icon:SetStyle("list_down_arrow")
		icon:SetupLayout("left", "right", "top", "center_y_simple")
		icon:SetIgnoreMouse(true)

		local div = self.top:CreatePanel("divider")
		--div:SetupLayout("fill")
		div:SetHideDivider(true)
		div:SetHeight(column:GetHeight())
		div:SetLeft(column)
		div.OnDividerPositionChanged = function() self:Layout() end
		column.div = div

		self.columns[i] = column

		column.OnRelease = function()
			if column.sorted then
				icon:SetStyle("list_down_arrow")
				table.sort(self.entries, function(a, b)
					return a.labels[i].text < b.labels[i].text
				end)
			else
				icon:SetStyle("list_up_arrow")
				table.sort(self.entries, function(a, b)
					return a.labels[i].text > b.labels[i].text
				end)
			end

			self:Layout()

			column.sorted = not column.sorted
		end

		if self.last_div:IsValid() then
			self.last_div:SetRight(div)
		end
		self.last_div = div
	end

	self:Layout()
end

function PANEL:ClearList()
	self.list:RemoveChildren()
end

function PANEL:AddEntry(...)
	local entry = self.list:CreatePanel("button")
	entry.OnSelect = function() end
	entry.labels = {}

	for i = 1, #self.columns do
		local text = select(i, ...) or "nil"

		local label = entry:CreatePanel("text_button")
		label:SetTextWrap(false)
		label.label:SetLightMode(true)
		label.label.markup:SetSuperLightMode(true)
		label:SetTextColor(self:GetSkin().text_list_color)
		label:SetText(self.columns[i].converter and self.columns[i].converter(text) or text)
		label:SizeToText()
		label.text = text
--		label:SetFixedSize(true)
		label:SetWidth(20)
		--label:SetClipping(true)
		label:SetNoDraw(true)
		label:SetIgnoreMouse(true)
		label:SetConcatenateTextToSize(true)

		entry.labels[i] = label
	end

	local last_child = self.list:GetChildren()[#self.list:GetChildren()]

	entry:SetMode("toggle")
	entry:SetActiveStyle("menu_select")
	entry:SetInactiveStyle("nodraw")

	entry.SetIcon = function(_, path)
		local label = entry.labels[1]

		table.remove(label:GetChildren())
		local icon = label:CreatePanel("base")
		table.insert(label:GetChildren(), label.label)

		local image = Texture(path or "textures/silkicons/folder.png")
		icon:SetTexture(image)
		icon:SetSize(image:GetSize())

		icon:SetupLayout("left", "center_y_simple")
		label.label:SetupLayout("left", "center_y_simple")
	end

	entry.OnStateChanged = function(_, b)
		if b then
			entry:OnSelect()
		end
		self:OnEntrySelect(entry, b)
	end

	entry.i = #self.entries + 1

	table.insert(self.entries, entry)

	return entry
end

function PANEL:OnEntrySelect(entry, select)

end

function PANEL:SetupConverters(...)
	for i = 1, #self.columns do
		self.columns[i].converter = select(i, ...)
	end
end

gui.RegisterPanel(PANEL)

if RELOAD then
	local test = {
		{name = "MSK-48 All Weapons Server", players = 18, map = "lib/mp_anzio_lib"},
		{name = "F|A RECRUITING XP SAVE", players = 29, map = "bba0-beta2"},
		{name = "-[HELLO]-Bfv | Allmaps", players = 22, map = "QUANG TRI 1972"},
		{name = "24/7 =(eGO)= AVALANCHE NO BOTS! | GameME", players = 31, map = "dod_avalanche"},
		{name = "-/\\-Villa-/\\- Villekulla - HQ of ((bh)) and Villa", players = 0, map = "maps/refinery.entities"},
		{name = "Universal Br Hosting", players = 200, map = "TeamSpeak"},
		{name = "RBN Tactical Crouch TDM", players = 12, map = "mp_cosmodrome"},
		{name = "=MXT=CTF Server", players = 18, map = "[SEC2] - MXTArchives"},
		{name = "WWW.FALLIN-ANGELS.ORG", players = 27, map = "ut4_kingdom"},
		{name = "29th Infantry Division [Battalion Server]", players = 37, map = "DH-CarpiquetAirfield-B2"},
		{name = "[2.FJg] HOS - Tactical Realism", players =	62, map = "TE-MyshkovaRiver_MCP"},
		{name = "[GFLClan.com]24/7 ZOMBIE ESCAPE |Rank|NoBlock|FastDL|Chicago", players = 64, map = "ze_FFXII_Westersand_v7_2"},
		{name = "-[DISC-FF.com]- |24/7 Freak Fortress #1| [Amp/Crits/RTD]", players = 31, map = "vsh_northkorea_v4new"},
		{name = "zp| * * * -=[SIEGE]=- |uK| The One Night Stand -=[SIEGE]=- Server * * * In Lo", players = 19, map = "CTF-McSwartzly2004]II[x"},
		{name = "! !--Good_Half-Life_Server--! !", players = 9, map = "crossfire"},
		{name = "Drippy's 2fort: Seeing Green (antibhop,no bots)", players = 26, map = "2fort"},
		{name = "Sentry Turrets/Bots|Weapons|Specimens: Default|Lvl 6-30| Int", players = 35, map = "KF-Archives-IGC"},
		{name = "blackhorse-gaming.eu|AVP|TDM|SCORE 500", players = 0, map = "Gateway"},
		{name = "--=[ aX ]=-- (CD and Origin)", players = 40, map = "market garden"},
		{name = "POL-SPEAK.pl ( DARMOWE KANAŁY)", players = 10480, map = "TeamSpeak 3"},
		{name = "bgq4.ru | moscow 2", players = 2/6, map = "mp/q4dm7"},
		{name = "Historians|Bas|NY|New Maps!", players = 27, map = "mp_foy"},
		{name = "[MiA] WARFARE", players = 14, map = "CTF-FaceClassic"},
		{name = "[UA] F.A.B.I.S. #4 / NOCDKEY / DayZ Chernarus, map = Regular", players = 2, map = "DayZ Mod v1.8.0.3"},
		{name = "[AR51] 24/7 Crossfire By WWW.AR51.EU", players = 64, map = "mp_crossfire"},
		{name = "Moto's Funhouse | Dallas, TX", players = 7, map = "ff_basketball"},
		{name = " -[KR]- Serv", players = 18, map = "mp/ffa3"},
		{name = "[GFLClan.com]Surf Timer #1 | Smooth Ramps | No Lag", players = 64, map = "surf_classics2"},
		{name = "-- Unnamed --", players =	20, map = "Kunar Base"},
		{name = "COOP`16 Paradis [l4dZone.ru] 1", players = 1, map = "l4d_hospital02_subway"},
		{name = "ZambiLand 13vs13 [2.1.2.5]", players = 17, map = "c8m2_subway"},
		{name = "Grey Matter LOOT LOOT LOOT 24/7 day 12572", players = 49, map = "DayZ_Auto"},
		{name = "UT3 Server PRO Best Maps (T.L.G.S.E.)", players = 1, map = "VCTF-Necrotic"},
		{name = "UGC | Dust2 #1 24/7 | UGC-Gaming.net", players = 18, map = "de_dust2_cz"},
		{name = "Hostile Takeover - King Of The Hill - US #1", players = 1100, map = "Altis"},
		{name = "Battlefield,M4+ Set|AntiCheat|1|RustTW#1", players = 464, map = "rust_island_2013"},
		{name = "{CROM} FREEZE", players = 27, map = "q3dm15"},
		{name = "SneakyMonkeys.com Limited Archer High Tick TO UK EU", players = 47, map = "aocto-outpost_p"},
		{name = "#aT# Hide&Seek", players = 4, map = "kam5"},
		{name = "[REDORCHESTRA.RU] & VTG.CLAN.SU International Community", players = 1, map = "RO-BaksanValley"},
		{name = "[Санкт-Петербургский] Public [Dust2]", players = 26, map = "de_dust2"},
		{name = "<MLS>STONER SERVER", players = 26, map = "dm/mohdm3"},
		{name = "Valve CTF / SD Server (Washington srcds146 #3)", players =	22, map = "ctf_sawmill"},
		{name = "PDE|#1 REAL FAST XP+ |pdelite.net", players = 30, map = "mp_asylum"},
		{name = "MetroOnly All Wapon OK but,No Glitch No Cheater", players = 52, map = "Operation Metro"},
	}


	local frame = gui.CreatePanel("frame", nil, "test")
	frame:SetCachedRendering(false)
	frame:SetSize(Vec2()+500)
	local list = frame:CreatePanel("list")
	list:SetupLayout("fill")
	list:SetupSorted("name", "modified", "type", "size")
	list:SetupConverters(nil, function(num) return os.date("%c", os.difftime(os.time(), num)) end, nil, utility.FormatFileSize)
	for i, name in ipairs(vfs.Find("lua/")) do
		local file = vfs.Open("lua/" .. name)
		local type = "folder"
		local size = 0
		local last_modified = 0

		if file then
			type = name:match(".+%.(.+)")
			size = file:GetSize()
			last_modified = file:GetLastModified()
		end
		local entry = list:AddEntry(name, last_modified, type, size)
		entry:SetIcon("textures/silkicons/"..(type == "folder" and "folder" or "script")..".png")
		if file then
			file:Close()
		end
	end
end