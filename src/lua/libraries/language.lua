local language = _G.language or {}

language.known_strings = language.known_strings or {}
language.current_translation = {}

local cvar = pvars.Setup("language", "english", function(val)
	language.Set(val)
end)

function language.LanguageString(val)
	local key = val:trim():lower()

	language.known_strings[key] = val

	return language.current_translation[key] or val
end

local L = language.LanguageString

function language.AddLanguagesToMenu(menu)
	local menu = menu:AddSubMenu(L"language")

	menu:AddOption("english", function()
		language.SetLanguage("english")
	end)

	for key, val in pairs(vfs.Find("translations/")) do
		val = val:match("(.+)%.")
		menu:AddOption(val, function()
			language.SetLanguage(val)
		end)
	end

	menu:AddSpacer()

	menu:AddOption("edit", function() language.ShowLanguageEditor() end)
end

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
							english,
							other,

							function(new)
								language.current_translation[english] = new
								line:SetValue(2, new)
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
		serializer.WriteFile("simple", "%SRC%/languages/" .. (nice or to), tbl)
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