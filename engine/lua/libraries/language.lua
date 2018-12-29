local language = _G.language or {}

language.known_strings = language.known_strings or {}
language.current_translation = {}


do
	local available = vfs.Find("languages/")
	table.insert(available, "english")

	local tbl = {}

	for i,v in ipairs(available) do
		tbl[v] = {}
	end

	language.available = tbl
end

resource.Download("data/countries.lua"):Then(function(path)
	language.world = serializer.ReadFile("luadata", path)

	for lang_code, info in pairs(language.world.languages) do
		if info.name then
			local found = language.available[info.name:lower()]
			if found then
				found.native = info.native
				if info.native ~= info.name then
					found.friendly = info.name .. " <=> " .. info.native
				else
					found.friendly = info.name
				end
			end
		end
	end
end)

local cvar = pvars.Setup2({
	key = "system_language",
	default = "english",
	table = language.available,
	callback = function(val)
		language.Set(val)
	end
})

function language.LanguageString(val)
	local key = val:trim():lower()

	language.known_strings[key] = val

	return language.current_translation[key] or val
end

local L = language.LanguageString

function language.ShowLanguageEditor()
	local lang = cvar:Get()

	local frame = gui.CreatePanel("frame")
	frame:SetSize(Vec2(512, 512))
	frame:Center()
	frame:SetTitle(L"translation editor")

	local list = gui.CreatePanel("list", frame)
	list:SetupLayout("fill_x", "fill_y")
	list:SetupSorted("english", lang)

	local strings = {}

	for k,v in pairs(language.known_strings) do
		strings[k] = v:trim():lower()
	end

	table.merge(strings, language.current_translation)

	for english, other in pairs(strings) do
		local line = list:AddEntry(english, other)
		line.OnRightClick = function()

			gui.CreateMenu({
				{
					L"edit",
					function()
						local window = gui.StringInput(
							L"translate",
							L"translate",
							english,

							function(new)
								language.current_translation[english] = new
								line:UpdateLine(2, new)
								language.SaveCurrentTranslation()
							end
						)
					end,
					gui.skin.icons.edit
				},
				{
					L"revert",
					function()
						local new = serializer.ReadFile("simple", "translations/"..lang)[english]
						language.current_translation[english] = new
						line:SetValue(2, new or english)
						language.SaveCurrentTranslation()
					end,
					gui.skin.icons.revert,
				}
			})
		end
	end

--	list:SizeToContents()
end

function language.SaveCurrentTranslation()
	serializer.WriteFile("simple", "languages/" .. cvar:Get(), language.current_translation)
end

function language.Translate(to, nice)
	local str = ""

	local lookup = {}
	local i = 1

	for key, val in pairs(language.known_strings) do
		str = str .. val .. "\n"
		lookup[i] = key
		i = i + 1
	end

	google.Translate("en", to, str, function(data)
		local res = ""

		for i, line in ipairs(data.translated:gsub("\\n", "\n"):split("\n")) do
			res = res .. lookup[i] .. "="..line.."\n"
		end

		print(res)

		local tbl = serializer.Decode("simple", res)
		serializer.WriteFile("simple", "data/languages/" .. (nice or to), tbl)
	end)

	return str
end

function language.Set(lang)
	lang = lang or cvar:Get()

	cvar:Set(lang)

	if lang == "english" then
		language.current_translation = {}
	else
		language.current_translation = serializer.ReadFile("simple", "languages/" .. cvar:Get())
	end
end

return language