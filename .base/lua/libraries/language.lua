local language = _G.language or {}

language.known_strings = language.known_strings or {}
language.current_translation = {}

local cvar = console.CreateVariable("language", "english", function(val)
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

function language.GetOutputForTranslation()
	local str = ""
	 
	for key, val in pairs(language.known_strings) do
		str = str .. ("%s = %s\n"):format(key:gsub("(.)","_%1_"), val)
	end
	
	return str
end

function language.TranslationOutputToString(str)
	local out = ""
	for i, line in ipairs(str:explode("\n")) do
		out = out .. line:gsub("_", "")
	end
	
	out = out:gsub(" = ", "=")
	
	return out
end

function language.Set(lang)
	lang = lang or cvar:GetString()
	
	cvar:Set(lang)
	
	if lang == "english" then
		language.current_translation = {}
	else
		language.current_translation = serializer.ReadFile("simple", "languages/" .. cvar:Get())
	end
end

return language