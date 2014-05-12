translation = {}

local base_url = "http://translate.google.com/translate_a/t?client=t&sl=%s&tl=%s&ie=UTF-8&oe=UTF-8&q=%s"

function translation.GoogleTranslate(from, to, str, callback)
	from = from or "auto"
	to = to or "en"
	str = str or ""

	local url = base_url:format(from, to, luasocket.EscapeURL(str))

	luasocket.Get(url, function(data)
		local out = {translated = "", transliteration = "", from = ""}
		local content = data.content:match(".-%[(%b[])"):sub(2, -2)
		
		for part in content:gmatch("(%b[])") do
			local to, from, trl = part:match("%[(%b\"\"),(%b\"\"),(%b\"\")")
			out.translated = out.translated .. to:sub(2,-2)
			out.from = out.from .. from:sub(2,-2)
			out.transliteration = out.transliteration .. trl:sub(2,-2)
		end
		
		callback(out)
	end)
end