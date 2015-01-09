local language = _G.language or {}

language.known_strings = language.known_strings or {}
language.current_translation = {}

local cvar = console.CreateVariable("language", "english", true)

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
	
	for key, val in pairs(file.Find("data/translations/*", "LUA")) do
		val = val:gsub("%.lua", "")
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
			local menu = gui.CreatePanel("menu")
			menu:SetPosition(window.GetMousePosition())
			menu:AddEntry(L"edit", function()
				local window = Derma_StringRequest(
					L"translate",
					english,
					other,

					function(new)
						language.current_translation[english] = new
						line:SetValue(2, new)
						language.SaveCurrentTranslation()
					end
				)
				for _, pnl in pairs(window:GetChildren()) do
					if pnl.ClassName == "DPanel" then
						for key, pnl in pairs(pnl:GetChildren()) do
							if pnl.ClassName == "DTextEntry" then
								pnl:SetAllowNonAsciiCharacters(true)
							end
						end
					end
				end
			end):SetImage(language.MiscIcons.edit)
			menu:AddOption(L"revert", function()
				local new = CompileFile("pac3/editor/client/translations/"..lang..".lua")()[english]
				language.current_translation[english] = new
				line:SetValue(2, new or english)
				language.SaveCurrentTranslation()
			end):SetImage(language.MiscIcons.revert)
			
			menu:MakePopup()
		end
	end
	
--	list:SizeToContents()
end

function language.SaveCurrentTranslation()
	serializer.WriteFile("luadata", "%ROOT%/.base/languages/" .. cvar:Get(), language.current_translation)
end

function language.GetOutputForTranslation()
	local str = ""
	 
	for key, val in pairs(language.known_strings) do
		str = str .. ("%s = %s\n"):format(key:gsub("(.)","_%1_"), val)
	end
	
	return str
end

function language.SetLanguage(lang)
	lang = lang or cvar:GetString()
	
	cvar:Set(lang)
	
	if lang == "english" then
		language.current_translation = {}
	else
		language.current_translation = serializer.ReadFile("luadata", "%ROOT%/.base/languages/" .. cvar:Get())
	end
end

return language