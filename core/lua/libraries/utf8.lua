local utf8 = _G.utf8 or {}

function utf8.midsplit(str)
	local half = math.round(str:ulength() / 2 + 1)
	return str:usub(1, half - 1), str:usub(half)
end

local math_floor = math.floor

function utf8.byte(char, offset)
	if char == "" then return -1 end

	offset = offset or 1
	local byte = char:byte(offset)

	if byte and byte >= 128 then
		if byte >= 240 then
			if #char < 4 then return -1 end

			byte = (byte % 8) * 262144
			byte = byte + (char:byte(offset + 1) % 64) * 4096
			byte = byte + (char:byte(offset + 2) % 64) * 64
			byte = byte + (char:byte(offset + 3) % 64)
		elseif byte >= 224 then
			if #char < 3 then return -1 end

			byte = (byte % 16) * 4096
			byte = byte + (char:byte(offset + 1) % 64) * 64
			byte = byte + (char:byte(offset + 2) % 64)
		elseif byte >= 192 then
			if #char < 2 then return -1 end

			byte = (byte % 32) * 64
			byte = byte + (char:byte(offset + 1) % 64)
		else
			byte = -1
		end
	end

	return byte
end

function utf8.bytelength(char, offset)
	local byte = char:byte(offset or 1)
	local length = 1

	if byte and byte >= 128 then
		if byte >= 240 then
			length = 4
		elseif byte >= 224 then
			length = 3
		elseif byte >= 192 then
			length = 2
		end
	end

	return length
end

function utf8.char(byte)
	local utf8 = ""

	if byte <= 127 then
		utf8 = string.char(byte)
	elseif byte < 2048 then
		utf8 = ("%c%c"):format(192 + math_floor(byte / 64), 128 + (byte % 64))
	elseif byte < 65536 then
		utf8 = (
			"%c%c%c"
		):format(
			224 + math_floor(byte / 4096),
			128 + (math_floor(byte / 64) % 64),
			128 + (byte % 64)
		)
	elseif byte < 2097152 then
		utf8 = (
			"%c%c%c%c"
		):format(
			240 + math_floor(byte / 262144),
			128 + (math_floor(byte / 4096) % 64),
			128 + (math_floor(byte / 64) % 64),
			128 + (byte % 64)
		)
	end

	return utf8
end

function utf8.sub(str, i, j)
	j = j or -1
	local length = 0
	local total_length = utf8.length(str)
	-- only set l if i or j is negative
	local l = (i >= 0 and j >= 0) or total_length
	local start_char = (i >= 0) and i or l + i + 1
	local end_char = (j >= 0) and j or l + j + 1

	-- can't have start before end!
	if start_char == 0 and end_char == 0 then return "" end

	if start_char > total_length or end_char > total_length then return "" end

	if start_char > end_char then return "" end

	local pos = 1
	local bytes = #str
	local start_byte = 1
	local end_byte = bytes

	for _ = 1, bytes do
		length = length + 1

		if length == start_char then start_byte = pos end

		pos = pos + utf8.bytelength(str, pos)

		if length == end_char then
			end_byte = pos - 1

			break
		end
	end

	return str:sub(start_byte, end_byte)
end

local function utf8replace(str, mapping)
	local out = {}

	for i, char in ipairs(utf8.totable(str)) do
		list.insert(out, mapping[char] or char)
	end

	return list.concat(out)
end

do
	local upper = {}
	local lower = {}

	local function init()
		local case = "Ζ;ζ;Ⓣ;ⓣ;Ḟ;ḟ;Ȗ;ȗ;Ա;ա;U;u;Ė;ė;Ἓ;ἓ;Ś;ś;Ⱋ;ⱋ;Ʊ;ʊ;Ϛ;ϛ;Ⴆ;ⴆ;Ú;ú;О;о;Ṙ;ṙ;Ξ;ξ;Ȟ;ȟ;Թ;թ;Ğ;ğ;" .. "Ḑ;ḑ;Ǉ;ǉ;Ⲉ;ⲉ;Ⴡ;ⴡ;Ç;ç;Ⴌ;ⴌ;Ѓ;ѓ;Ｔ;ｔ;Ⓓ;ⓓ;Ĺ;ĺ;Ả;ả;Ṛ;ṛ;Ň;ň;Ӈ;ӈ;Ⳉ;ⳉ;Ữ;ữ;Ž;ž;Ͻ;ͻ;Ḓ;ḓ;Ţ;ţ;" .. "Ⲏ;ⲏ;𐐞;𐑆;Ƌ;ƌ;Ʀ;ʀ;Ⴊ;ⴊ;Ⴣ;ⴣ;Ӣ;ӣ;Ǐ;ǐ;Ấ;ấ;Φ;φ;Ḕ;ḕ;Ï;ï;Ｒ;ｒ;Ћ;ћ;Ȧ;ȧ;Ħ;ħ;Ⱒ;ⱒ;Ū;ū;Г;г;Ⓩ;ⓩ;" .. "Տ;տ;Ϫ;ϫ;Ῡ;ῡ;Ⲱ;ⲱ;Ⴥ;ⴥ;Ἇ;ἇ;Ǫ;ǫ;Ｐ;ｐ;Ỡ;ỡ;Ȯ;ȯ;Ὑ;ὑ;Ʈ;ʈ;Į;į;Ӫ;ӫ;Ύ;ύ;Γ;γ;Ӳ;ӳ;Ḗ;ḗ;Ѳ;ѳ;N;n;" .. "Ү;ү;Л;л;Ὴ;ὴ;Ā;ā;Ҷ;ҷ;Ȁ;ȁ;Λ;λ;ǲ;ǳ;Ἦ;ἦ;V;v;Ѐ;ѐ;Ǆ;ǆ;Ҁ;ҁ;Ԁ;ԁ;Ä;ä;Ḉ;ḉ;Ⱖ;ⱖ;Ʉ;ʉ;𐐕;𐐽;𐐢;𐑊;" .. "Ĉ;ĉ;Ⴔ;ⴔ;Ӻ;ӻ;Ｌ;ｌ;Ȉ;ȉ;Ἤ;ἤ;Ķ;ķ;Ḥ;ḥ;Έ;έ;Ϻ;ϻ;Ⱔ;ⱔ;Ԉ;ԉ;Ҿ;ҿ;𐐎;𐐶;Ɍ;ɍ;Ḋ;ḋ;Ō;ō;Ⱦ;ⱦ;G;g;Ⴒ;ⴒ;" .. "Ⰵ;ⰵ;Σ;σ;А;а;Ґ;ґ;Ռ;ռ;Ᾰ;ᾰ;Ἢ;ἢ;Ṋ;ṋ;𐐆;𐐮;Ⱚ;ⱚ;𐐧;𐑏;Đ;đ;𐐣;𐑋;Ɛ;ɛ;Ⲹ;ⲹ;Ϋ;ϋ;𐐥;𐑍;𐐤;𐑌;𐐦;𐑎;O;o;" .. "Ｈ;ｈ;Ք;ք;Ἠ;ἠ;𐐡;𐑉;𐐠;𐑈;𐐟;𐑇;Ḍ;ḍ;Ⴘ;ⴘ;Ὰ;ὰ;𐐝;𐑅;𐐜;𐑄;Ṗ;ṗ;Ⱘ;ⱘ;И;и;𐐛;𐑃;Ҙ;ҙ;𐐚;𐑂;Ŕ;ŕ;𐐙;𐑁;𐐘;𐑀;" .. "𐐗;𐐿;Ș;ș;Ḏ;ḏ;Ὤ;ὤ;𐐖;𐐾;𐐔;𐐼;Ⲙ;ⲙ;Θ;θ;𐐒;𐐺;𐐑;𐐹;Ⲍ;ⲍ;Գ;գ;𐐏;𐐷;W;w;𐐍;𐐵;Ƙ;ƙ;Ǥ;ǥ;Ϝ;ϝ;Ⴖ;ⴖ;𐐋;𐐳;" .. "Ł;ł;𐐊;𐐲;𐐉;𐐱;Ŝ;ŝ;Ɂ;ɂ;Ƴ;ƴ;Ⱡ;ⱡ;𐐇;𐐯;𐐅;𐐭;Ü;ü;Ⲽ;ⲽ;𐐄;𐐬;𐐃;𐐫;Ƿ;ƿ;Ḁ;ḁ;𐐂;𐐪;Ձ;ձ;Ի;ի;ᾈ;ᾀ;𐐀;𐐨;" .. "Ｚ;ｚ;Ϸ;ϸ;Ⱐ;ⱐ;Ⴜ;ⴜ;Ｄ;ｄ;Ｘ;ｘ;Ｗ;ｗ;Ⅷ;ⅷ;Ẓ;ẓ;Ｖ;ｖ;Ѕ;ѕ;Ｕ;ｕ;Ｓ;ｓ;Ļ;ļ;Å;å;Ġ;ġ;Ẑ;ẑ;Ơ;ơ;Ὅ;ὅ;Ƞ;ƞ;" .. "É;é;Ộ;ộ;Չ;չ;Ⅳ;ⅳ;Ｏ;ｏ;Π;π;Ḃ;ḃ;Р;р;Մ;մ;Ҡ;ҡ;Ᾱ;ᾱ;Ｋ;ｋ;Ｊ;ｊ;Ὸ;ὸ;Ｉ;ｉ;Ⴚ;ⴚ;Ӊ;ӊ;Ｇ;ｇ;Ｆ;ｆ;H;h;" .. "Ｅ;ｅ;Ť;ť;Ṡ;ṡ;Ａ;ａ;Ｂ;ｂ;Ȩ;ȩ;Ⱓ;ⱓ;Ӥ;ӥ;Ց;ց;Ⓧ;ⓧ;Ⳡ;ⳡ;Ψ;ψ;Ѝ;ѝ;Ở;ở;Ⳟ;ⳟ;Э;э;Ⳛ;ⳛ;Њ;њ;Ⳗ;ⳗ;Ⳕ;ⳕ;" .. "Ⳓ;ⳓ;Ϭ;ϭ;Ñ;ñ;Ц;ц;Ⳏ;ⳏ;Ὼ;ὼ;Ǒ;ǒ;Ŭ;ŭ;Ⳍ;ⳍ;Ǭ;ǭ;Ⓜ;ⓜ;Ҩ;ҩ;Ⳋ;ⳋ;P;p;Ḅ;ḅ;Ⳇ;ⳇ;Ⳅ;ⳅ;Ⳃ;ⳃ;Ҟ;ҟ;Ⲿ;ⲿ;" .. "Ⴃ;ⴃ;Ұ;ұ;Ⲻ;ⲻ;Ⲷ;ⲷ;Ε;ε;Ⲵ;ⲵ;Ⲳ;ⲳ;Ѭ;ѭ;Ḻ;ḻ;Ӭ;ӭ;Ḇ;ḇ;Ⴞ;ⴞ;Ⲯ;ⲯ;Ờ;ờ;Ⲭ;ⲭ;Ṍ;ṍ;Ⲫ;ⲫ;Ѵ;ѵ;Ⰽ;ⰽ;Ӵ;ӵ;" .. "Ᵽ;ᵽ;Ⲥ;ⲥ;Ⲣ;ⲣ;Ȱ;ȱ;Ù;ù;Ⲡ;ⲡ;Z;z;X;x;Ⴁ;ⴁ;Ը;ը;Ν;ν;Ǵ;ǵ;Ω;ω;Ṁ;ṁ;Ⓞ;ⓞ;𐐓;𐐻;ᾬ;ᾤ;Ἵ;ἵ;Ɲ;ɲ;ϴ;θ;" .. "Ḹ;ḹ;Ⲕ;ⲕ;Ȃ;ȃ;Ҹ;ҹ;Ῑ;ῑ;Ŵ;ŵ;Ы;ы;Ὥ;ὥ;𐐐;𐐸;Ⲋ;ⲋ;Ђ;ђ;Ⲇ;ⲇ;Ɇ;ɇ;Ⲅ;ⲅ;Ԃ;ԃ;ᾉ;ᾁ;A;a;Ⲃ;ⲃ;П;п;Ѽ;ѽ;" .. "Ↄ;ↄ;Ӽ;ӽ;Ί;ί;Ƹ;ƹ;Ċ;ċ;Ầ;ầ;Ⱬ;ⱬ;Ӌ;ӌ;Ȋ;ȋ;Ⱨ;ⱨ;Ɗ;ɗ;Ɽ;ɽ;Ⴇ;ⴇ;Ǽ;ǽ;Ⲧ;ⲧ;Ɫ;ɫ;𐐈;𐐰;Ⱞ;ⱞ;Ɏ;ɏ;Ἳ;ἳ;" .. "Ԋ;ԋ;Ⱝ;ⱝ;Ҋ;ҋ;ᾏ;ᾇ;Ⱜ;ⱜ;Ὢ;ὢ;Ἣ;ἣ;Ⅻ;ⅻ;Υ;υ;Î;î;I;i;Ⱕ;ⱕ;Ⴅ;ⴅ;Ⳣ;ⳣ;Ⱑ;ⱑ;Ⅽ;ⅽ;Ẁ;ẁ;Ｙ;ｙ;Վ;վ;Ἱ;ἱ;" .. "Ⱏ;ⱏ;Ỉ;ỉ;В;в;Ⅱ;ⅱ;Ⱍ;ⱍ;Ⓑ;ⓑ;Ԓ;ԓ;Ⱊ;ⱊ;Ⱆ;ⱆ;Ｎ;ｎ;Ⲩ;ⲩ;Ⱇ;ⱇ;Ẏ;ẏ;Ⱅ;ⱅ;Ⱄ;ⱄ;Ⱃ;ⱃ;Ⱂ;ⱂ;Ⱁ;ⱁ;Ӗ;ӗ;Ⱀ;ⱀ;" .. "Β;β;Ῥ;ῥ;Ē;ē;Ⰿ;ⰿ;Ֆ;ֆ;Ṻ;ṻ;Ȓ;ȓ;Ⰾ;ⰾ;Ⴋ;ⴋ;Ⱈ;ⱈ;Ⰼ;ⰼ;Ⰻ;ⰻ;Ⰺ;ⰺ;Ⰹ;ⰹ;Ö;ö;Ọ;ọ;Ḳ;ḳ;Ⰷ;ⰷ;Ự;ự;ᾋ;ᾃ;" .. "Ŗ;ŗ;Ổ;ổ;Ṉ;ṉ;Ṅ;ṅ;К;к;Ⰳ;ⰳ;Κ;κ;Ⰲ;ⰲ;Ě;ě;Ỗ;ỗ;Ⰱ;ⰱ;Ⰰ;ⰰ;Ț;ț;Ǳ;ǳ;Ṽ;ṽ;Ⓦ;ⓦ;Ã;ã;Ṹ;ṹ;Y;y;Ⅹ;ⅹ;" .. "Ӟ;ӟ;Ե;ե;Ⓥ;ⓥ;Ƶ;ƶ;Ϟ;ϟ;Ⓤ;ⓤ;Ş;ş;Ⓢ;ⓢ;Ô;ô;Ḱ;ḱ;Ń;ń;Ⓠ;ⓠ;Ǟ;ǟ;Ȼ;ȼ;Ƀ;ƀ;Є;є;Þ;þ;Ź;ź;Ƈ;ƈ;Ƅ;ƅ;" .. "Ⓚ;ⓚ;Ⓙ;ⓙ;Ⓨ;ⓨ;Ⓗ;ⓗ;Ẃ;ẃ;Ӕ;ӕ;Ճ;ճ;Ϲ;ϲ;Ⓕ;ⓕ;ᾊ;ᾂ;Ṿ;ṿ;Ⓒ;ⓒ;Ї;ї;Ⱌ;ⱌ;B;b;K;k;Ƣ;ƣ;Ⱶ;ⱶ;Ⴢ;ⴢ;Ƚ;ƚ;" .. "Ⅿ;ⅿ;Ḷ;ḷ;ǋ;ǌ;Ľ;ľ;Ⅾ;ⅾ;Ị;ị;Ģ;ģ;Ն;ն;Ң;ң;Ⅺ;ⅺ;Ȣ;ȣ;Ⅸ;ⅸ;Ώ;ώ;Ⅶ;ⅶ;Ǧ;ǧ;Ⅵ;ⅵ;Ծ;ծ;Ḵ;ḵ;Т;т;E;e;" .. "Ə;ə;Ⱎ;ⱎ;Ϧ;ϧ;Ր;ր;Ŧ;ŧ;Ҍ;ҍ;Ｑ;ｑ;Ⓐ;ⓐ;J;j;ῌ;ῃ;Ⴤ;ⴤ;ῼ;ῳ;Ī;ī;Ώ;ώ;Џ;џ;C;c;Ȫ;ȫ;Ὺ;ὺ;Փ;փ;Ῠ;ῠ;" .. "Ó;ó;Ί;ί;Ⱗ;ⱗ;Ῐ;ῐ;Ǔ;ǔ;Ω;ω;Ề;ề;Ή;ή;Ϯ;ϯ;Ὦ;ὦ;Ů;ů;Ὲ;ὲ;Ⴑ;ⴑ;ᾼ;ᾳ;Ṳ;ṳ;Ⓖ;ⓖ;Ǯ;ǯ;Ẇ;ẇ;Ｍ;ｍ;Қ;қ;" .. "Ъ;ъ;ᾮ;ᾦ;R;r;Ӧ;ӧ;Ȥ;ȥ;Ḫ;ḫ;ᾪ;ᾢ;Ⲓ;ⲓ;Ἥ;ἥ;ᾨ;ᾠ;Η;η;Ẹ;ẹ;ᾟ;ᾗ;Ὀ;ὀ;Բ;բ;ᾝ;ᾕ;Ӯ;ӯ;À;à;Ἁ;ἁ;ᾛ;ᾓ;" .. "Ⴏ;ⴏ;Ẅ;ẅ;Û;û;ᾚ;ᾒ;ᾙ;ᾑ;Ẉ;ẉ;Ǜ;ǜ;Ҫ;ҫ;ᾍ;ᾅ;ᾌ;ᾄ;Ĳ;ĳ;Ⓔ;ⓔ;𐐁;𐐩;Ӏ;ӏ;Ȳ;ȳ;Հ;հ;Ο;ο;Ḩ;ḩ;Ƕ;ƕ;Ṣ;ṣ;" .. "Ą;ą;Έ;έ;Һ;һ;Ⲑ;ⲑ;Ɵ;ɵ;K;k;Ⱛ;ⱛ;Ǌ;ǌ;Ŷ;ŷ;Ὠ;ὠ;Ὗ;ὗ;Ẻ;ẻ;Ὕ;ὕ;Ḭ;ḭ;Ɉ;ɉ;Ὓ;ὓ;Ⴕ;ⴕ;Н;н;Ṷ;ṷ;Ὃ;ὃ;" .. "Ⱥ;ⱥ;Ⰴ;ⰴ;Ȍ;ȍ;Ὁ;ὁ;Ἡ;ἡ;ᾞ;ᾖ;Č;č;Ἷ;ἷ;Ό;ό;Ḯ;ḯ;Ἶ;ἶ;Ⲗ;ⲗ;Ͼ;ͼ;Ύ;ύ;Ṵ;ṵ;Ӷ;ӷ;Ո;ո;Ἧ;ἧ;Ⱙ;ⱙ;Ἕ;ἕ;" .. "Ǿ;ǿ;Ἔ;ἔ;Ӑ;ӑ;Ẽ;ẽ;Ἒ;ἒ;Ἑ;ἑ;Ƨ;ƨ;Ἐ;ἐ;Ἄ;ἄ;Ἅ;ἅ;Ṫ;ṫ;Ἆ;ἆ;Ⴓ;ⴓ;Ἃ;ἃ;Χ;χ;Ⓘ;ⓘ;Д;д;ᾜ;ᾔ;Ð;ð;Ớ;ớ;" .. "Ч;ч;Ỹ;ỹ;Ά;ά;Ỵ;ỵ;З;з;Ⰶ;ⰶ;Ҕ;ҕ;Ế;ế;Ő;ő;Ử;ử;Ừ;ừ;Ԑ;ԑ;Ủ;ủ;Ụ;ụ;Ợ;ợ;Ἀ;ἀ;Ồ;ồ;Ố;ố;Ɣ;ɣ;Ỏ;ỏ;" .. "Ȕ;ȕ;Ⴙ;ⴙ;Ṩ;ṩ;Ằ;ằ;Ĕ;ĕ;Ⰸ;ⰸ;Δ;δ;Ệ;ệ;S;s;Ễ;ễ;Ể;ể;Ë;ë;Ẵ;ẵ;Ḣ;ḣ;Ř;ř;Ⲛ;ⲛ;Ϙ;ϙ;Ⅴ;ⅴ;М;м;Ӛ;ӛ;" .. "Ø;ø;Ẫ;ẫ;Я;я;Ϡ;ϡ;Á;á;Ẕ;ẕ;Ȝ;ȝ;Ẍ;ẍ;Ҝ;ҝ;Ẋ;ẋ;Ĝ;ĝ;Ɓ;ɓ;Μ;μ;ᾘ;ᾐ;Ṯ;ṯ;Ἂ;ἂ;Ṱ;ṱ;Ṭ;ṭ;Ⳑ;ⳑ;Ṥ;ṥ;" .. "Ɯ;ɯ;Ὧ;ὧ;Ｃ;ｃ;Ṟ;ṟ;Ⴗ;ⴗ;Ḡ;ḡ;Ṝ;ṝ;ǅ;ǆ;Ṕ;ṕ;Ё;ё;Ʒ;ʒ;Å;å;Ṓ;ṓ;Ņ;ņ;Ṑ;ṑ;Ṏ;ṏ;Ὂ;ὂ;Ṇ;ṇ;Ṃ;ṃ;Ẳ;ẳ;" .. "Ḿ;ḿ;Ḽ;ḽ;Ϊ;ϊ;Ⴎ;ⴎ;Q;q;Ⴝ;ⴝ;Ǡ;ǡ;Ӆ;ӆ;Ż;ż;Յ;յ;Կ;կ;Ǘ;ǘ;Š;š;Ɖ;ɖ;D;d;Ƃ;ƃ;Ջ;ջ;Ḧ;ḧ;Ӡ;ӡ;Ⲟ;ⲟ;" .. "Ὄ;ὄ;Ⅰ;ⅰ;Ƥ;ƥ;ǈ;ǉ;Ѡ;ѡ;Ò;ò;Ŀ;ŀ;Ɨ;ɨ;Ĥ;ĥ;Ǎ;ǎ;Τ;τ;Љ;љ;Ф;ф;Í;í;Æ;æ;Ս;ս;Ɠ;ɠ;Ȑ;ȑ;Ũ;ũ;Ặ;ặ;" .. "Ϩ;ϩ;Ⴛ;ⴛ;Ҥ;ҥ;Ժ;ժ;Զ;զ;Ὣ;ὣ;Ҏ;ҏ;Ⲝ;ⲝ;Ǩ;ǩ;Ӎ;ӎ;Ȭ;ȭ;Ό;ό;Ă;ă;Х;х;Ĭ;ĭ;Ƒ;ƒ;Ư;ư;Ⅲ;ⅲ;Ὶ;ὶ;Ȅ;ȅ;" .. "Ө;ө;Օ;օ;ᾭ;ᾥ;Α;α;Ƭ;ƭ;Ὡ;ὡ;Ѩ;ѩ;L;l;Ď;ď;Ή;ή;Ӱ;ӱ;Ǖ;ǖ;Ⓝ;ⓝ;Ŏ;ŏ;Ь;ь;Õ;õ;Ѱ;ѱ;Ⱪ;ⱪ;Ű;ű;Ќ;ќ;" .. "Ⓛ;ⓛ;Ρ;ρ;T;t;Й;й;Ҭ;ҭ;Ⅼ;ⅼ;Ϥ;ϥ;Ẩ;ẩ;Ϣ;ϣ;Ι;ι;ᾯ;ᾧ;Ѻ;ѻ;Ѷ;ѷ;Ѧ;ѧ;Ҵ;ҵ;Ͽ;ͽ;Դ;դ;Ⴟ;ⴟ;Ⳝ;ⳝ;İ;i;" .. "Ÿ;ÿ;Â;â;Ṧ;ṧ;Ғ;ғ;Ј;ј;Ǚ;ǚ;Ⳙ;ⳙ;Ɔ;ɔ;Ĵ;ĵ;Ų;ų;Ì;ì;Е;е;Ӹ;ӹ;Ḙ;ḙ;Ⴀ;ⴀ;Ǻ;ǻ;Ỳ;ỳ;Ý;ý;Ѹ;ѹ;Ⲁ;ⲁ;" .. "Ĩ;ĩ;Ά;ά;Ⴄ;ⴄ;Ղ;ղ;Ш;ш;Ἴ;ἴ;ᾩ;ᾡ;Ȇ;ȇ;Ю;ю;Ѥ;ѥ;Ѫ;ѫ;Ć;ć;Ǹ;ǹ;Ŋ;ŋ;Ⅎ;ⅎ;І;і;Ҽ;ҽ;Ɋ;ɋ;Ⳁ;ⳁ;Ҧ;ҧ;" .. "Б;б;ᾎ;ᾆ;Ѯ;ѯ;Ê;ê;Ҳ;ҳ;Ḛ;ḛ;ᾫ;ᾣ;Ԇ;ԇ;Ƽ;ƽ;Պ;պ;𐐌;𐐴;Ӄ;ӄ;Ⓟ;ⓟ;Ȏ;ȏ;Ⴂ;ⴂ;Ǝ;ǝ;Ỷ;ỷ;С;с;Ә;ә;Ậ;ậ;" .. "Ӝ;ӝ;Ḝ;ḝ;Ʌ;ʌ;Ӂ;ӂ;Է;է;Ἲ;ἲ;Ӿ;ӿ;Ạ;ạ;Ԅ;ԅ;Ӓ;ӓ;Ԍ;ԍ;Ę;ę;Ứ;ứ;Ԏ;ԏ;F;f;Ւ;ւ;Ⓡ;ⓡ;Ў;ў;Ѣ;ѣ;M;m;" .. "Լ;լ;Ʃ;ʃ;Խ;խ;Ắ;ắ;Ѿ;ѿ;Җ;җ;Ⱉ;ⱉ;Ж;ж;Շ;շ;Ἰ;ἰ;У;у;Œ;œ;È;è;Ⴉ;ⴉ;Ⴈ;ⴈ;Ʋ;ʋ;Ⴍ;ⴍ;Ɩ;ɩ;Ⴐ;ⴐ;Щ;щ;" .. "Ⴠ;ⴠ;Ǣ;ǣ"
		local tbl = case:split(";")

		for i = 1, #tbl, 2 do
			local key, val = tbl[i + 0], tbl[i + 1]
			lower[key] = val
			upper[val] = key
		end
	end

	function utf8.upper(str)
		if not upper[1] then init() end

		return utf8replace(str, upper)
	end

	function utf8.lower(str)
		if not upper[1] then init() end

		return utf8replace(str, lower)
	end
end

do
	local translate = {}

	local function init()
		local translate_data = [=[0,O;ᔡ,s;く,<;ᖱ,d;⋓,u;б,b,6;ฝ,w,u;Ա,u,U;ݒ,u;ᘬ,s;ꇘ,S;≻,>;‵,';ᘉ,n;ฑ,n;Ҟ,K;ı,i;Ξ,E;₩,W;ᑙ,n;ʞ,k;]=] .. [=[ڹ,U;ƃ,b;☊,n;ƞ,n;ʃ,s,f;ҹ,u,h;Ꮽ,9;˵,";ʹ,';ս,u;ι,i,l,L;ڃ,c,z;ѽ,w,o;ɇ,e;ͽ,c,E;━,-;ƹ,E,z,3;╤,T;ɽ,r,l;ч,ch,u,y,h;]=] .. [=[‘,';Ᏺ,h;⓱,17;┮,T;ه,o,a;ᑢ,c;Շ,o;ԋ,H;ˏ,COMMA;‹,<;Ѣ,b;ᑝ,c;բ,f,p;Ｒ,R;Ꮜ,a,u;٢,2,r;Ħ,H;≿,>;ғ,F;˪,L,i;]=] .. [=[ᵾ,Au;Ϫ,Y,a,v;ⅴ,V;ᒶ,L;ê,E;Ꮹ,G,c;╙,L;⓬,12;ᴦ,G,L,R;☣,o;〡,i,l;ʮ,h,u;⊂,<;Ɠ,G;Ʈ,T;ʓ,E,z,3;®,R;₱,D;ת,n;ᶈ,A,p,o;]=] .. [=[ԛ,q;ᐏ,A,n,v;Ѳ,f,th,o;ᑦ,c;Ү,U,Y;⓵,1;Л,L,N;∪,u;ٲ,i;≳,>;♈,v;‽,!?,?!,?,!;ㄘ,c,s;ж,x,k;｛,{;ɲ,n;丨,i,l;ᙄ,e,c;☂,j;˟,x;]=] .. [=[ᄇ,A;τ,t,T;Ｊ,J;ᶕ,e;๑,a;ß,ss,B;ศ,a;╅,t,+;Ӻ,F;ᴢ,Z;ᗷ,E,B;ʈ,t;⊆,<;˺,';ᴩ,R,P;ઠ,s;ۄ,a,g;⏋,L;ƈ,c;†,+,t;]=] .. [=[Ɍ,R;⓹,5;£,L,E;১,1;ʾ,';ᑪ,c;ƾ,s;ʣ,dz;Σ,S,E;А,A;ң,H;ㄤ,ang;Ռ,n;ь,b;ɧ,h;ｗ,W;☺,o;ŧ,t;ฬ,n,w,m;Đ,D;]=] .. [=[ᶑ,d;╁,t,+;٧,7,v;ｏ,/,O;է,t;⊚,o;ژ,j;ث,u;ᒎ,j,i;⓽,9;Ҙ,E;☧,t;⏇,T;ʘ,O;ᑮ,p;Θ,TH,O;ᕫ,w,u;ڳ,S;ᐐ,A,n,v;Ƙ,K;]=] .. [=[ㄠ,au;ɜ,e,3;Ł,L;☾,c;Ɂ,?;Ƴ,Y;≨,<;ᴍ,M;ᒢ,i;с,s,c,C;γ,g,y,b,Y;ᄏ,F;շ,2;Ձ,2;Ի,r,R;!,i;ᖆ,A;ᴪ,W;ᗿ,B;ɷ,w,o;]=] .. [=[л,l,n;ᇫ,A,n,v;ᒇ,d;ˉ,';ᔓ,s;⋧,>;ω,aw,w;Ȼ,C;义,X;Ƞ,n;É,E;ӿ,x;ㄍ,g;ᵮ,f;৯,9;Р,R,P;ۉ,g;ᶅ,l,I;ʍ,w,m;ä,A;]=] .. [=[ƍ,o;Ϥ,h,b,p,q;Ӊ,H;♄,h;ᅅ,ON,OA;Ｂ,B;ʨ,tc,ts,t;Ց,s,/;▍,|;Ψ,PS,U,W;ҍ,b;✚,t;ƨ,s;ᶙ,u;Е,E;ɬ,l,I;╉,t,+;₠,C;ɑ,a,A;¡,!,i;]=] .. [=[ڙ,j;⋁,u;⊒,c;ᖂ,d;ᴉ,i,!;Ꮾ,6,G;＿,_;Ƀ,B;а,a,A;ᴙ,R;2,z;ᕲ,D;լ,L;₵,C;ᑷ,p;Γ,G,L,r,T;ذ,s;ݑ,u;χ,x,X;ĕ,E;]=] .. [=[ฅ,n,a;ᑐ,c;ᶁ,d;╼,-;ᗋ,A;３,/;∞,oo;◎,O;∺,H;ϙ,o;Ｖ,V;—,-;☡,Z,2;Ꮇ,M;❿,10;ҝ,x,k;۴,r;Ƃ,b;➋,2;Ν,N;]=] .. [=[¦,|;ʂ,s;Ʀ,R;ʝ,j,i;ᑱ,d;ᚺ,H,N;⁎,*;Ɲ,N;ᒪ,L;⋜,<;Ꭼ,E;║,ll,||;Ҹ,u,y,h;➇,8;Ɫ,L,t;แ,ii;エ,I;ڂ,c,z;ᚤ,n;ɭ,l;]=] .. [=[✖,X;Ɇ,E;❻,6;♯,#;θ,th,o;੫,5;฿,B;Ʃ,E;Ѽ,w,u;ц,ts,u;ұ,u,y,v;ᔛ,s;Ƹ,E,z,3;Ꮃ,W;­,-;ᕾ,p;ɼ,r,l;ن,u;は,t;ᑔ,c;]=] .. [=[ᗬ,D;ɡ,g,G;ⱳ,w;◌,o;Ꮤ,W;＞,>;ᶍ,x;ݢ,S;ⅼ,L;ѡ,W,v;ђ,dj,h;ϩ,s;ݙ,S;ˎ,COMMA;ઝ,K;ȶ,t;ᴧ,L,A,n,v;١,1;ێ,s;ȥ,z;]=] .. [=[ټ,u;Ғ,F;–,-;ｃ,C;Ⅽ,C;ァ,P;➑,8;Х,H,X;➓,10;ｇ,G;❷,2;å,A;☪,c;ผ,w,u;﹞,);ٽ,u;ᑵ,q;é,E;Ｎ,N;ㄑ,q,k;]=] .. [=[Ǝ,E;і,i,I;Ӕ,AE,E;Ｆ,F;╱,/;➃,4;╌,-;ʭ,n;ʎ,A,Y,l;Β,B;੯,9;ƭ,E;ˮ,";Ֆ,s;ᒐ,l,i;ๅ,r;ᗣ,A;ヨ,E;ꇙ,S;ᕺ,b;]=] .. [=[ѱ,ps,w;Ԛ,Q;ف,g;Ꮠ,i;ձ,do;ɖ,d;Ｚ,Z;卩,P,N;ٱ,i;：,:;Ｗ,W;ᶉ,r;Ъ,b;К,K;ɥ,h,u;Ê,E;ミ,E;Ě,E;е,e,E;ҭ,t;]=] .. [=[ᵵ,t;۞,O;乙,z;ᚽ,I;ɱ,m;Ã,A;р,r,p,P;〈,<;Ⅹ,X;ǃ,!;Ե,t;ᔢ,s;ᑹ,p;ݖ,u;ⱷ,w;ᴻ,N;۹,q;σ,s,o;Ꭴ,u;Ρ,R,P;]=] .. [=[《,<<;ᑜ,n;ȵ,n;І,I;⋟,>;Þ,b,p;ฐ,s;Ƈ,C;╽,|;ۃ,s,o,j;‛,';ղ,n;˹,';〕,);ڽ,o,u;ᶄ,k;Ϲ,C;ઙ,s;～,~;ʇ,t,f;]=] .. [=[▎,|;¢,c;ҽ,e;ｚ,Z;乚,L;Ƣ,a;ν,n,v,V;Ｓ,S;♑,N;ʢ,?,c;ʽ,';ق,g;€,E;м,m,M;ƽ,s;ڇ,c;ᗫ,D;Ң,H;ы,bl;〝,";]=] .. [=[。,.;╕,F;տ,s;ď,D;ᐄ,A,n;凢,N;ด,n,a;ᚱ,R;▐,|;ɦ,h;⋉,K;丫,Y;ᵱ,p;Ŧ,T;⓭,13;丅,T;▁,_;Ѧ,A;ᴎ,N;ԏ,T;]=] .. [=[☢,o;ㄝ,eh;ʁ,R;Џ,U,Y;﹝,(;٦,6;─,-;Ｍ,M;х,h,x,X;զ,q;δ,d,o;り,n;₰,I;Ꭳ,o;ᴚ,R;Ԋ,H;☒,X;Ϯ,I,t,l;੧,1;җ,x,k;]=] .. [=[ᑍ,n,h;ت,u;‚,COMMA;）,);ઈ,d;∑,S,E;Â,A;ڗ,j;＝,=;Ҳ,X;₡,C;Ɨ,I;܄,:;⺇,n;٠,.;Ր,r;Ꮟ,b;ۮ,j;ᒘ,j;Η,H;]=] .. [=[״,";！,;Ꭰ,a,d,D;ʗ,c;ョ,E;ћ,ts,h;〃,";؟,?;ᵽ,p;Ʋ,u;➎,5;ㄈ,f,c;ɀ,z;ɛ,e;２,/;П,P,N;Ꮋ,H;β,b,B;ᘂ,i;˩,l,i;]=] .. [=[ᑡ,c;ն,u,G;モ,E,T;Ｋ,K;Հ,R;ᗶ,R;ϯ,i,t;┈,-;凣,N;Ժ,o,a;＊,*;Ⱥ,A;ҧ,n;غ,E;ㄆ,p,r;ӏ,l;╥,T;ˈ,';ᴆ,D;✗,X;]=] .. [=[ㄉ,d;ψ,ps,u,w;ฤ,n,a;Ꮯ,c,C;∶,:;Ԅ,R;Ⅼ,L;ㄋ,n;ݕ,u;∕,/;ｈ,H;≼,<;Ꮛ,e;ã,A;ᗻ,R;ᴯ,B,D;♉,u;Ӿ,X;三,3,E;サ,H;]=] .. [=[۳,r;ӈ,H,A;ㄐ,j,u;Ⱪ,K;ᵹ,d;ϣ,w;ƒ,f;ｖ,V;ㄛ,o;ݫ,j;‧,.;⓶,2;ᴕ,o;þ,b,p;ᗑ,A;ร,s;Ɯ,w;ڌ,j;ᒀ,b;Ꮴ,v;]=] .. [=[ⅽ,C;Ⴓ,Q;ᘺ,w;Χ,X;ᶒ,e;Ҍ,b;Ᵽ,p;ʧ,ts,a;Ө,th,O;ٻ,u;ᖺ,n,h;⊙,o;ᑥ,c;匸,C;∈,E;Ｇ,G;☦,t;ɫ,l,I;ｓ,S;と,y;]=] .. [=[Ѩ,IA,A;ɐ,a;ᴂ,ae;ᙂ,c;ｌ,L;ㄕ,sh,p,r;⊺,T;ᚩ,F;ꆿ,H;ի,h;ㄙ,s,A;➈,9;ㄡ,ou,A,r;Ĕ,E;ㇶ,t;ｎ,N;Ɉ,J;ט,u;丷,'';Ꮰ,j;]=] .. [=[♍,m;ݐ,u;ᑘ,u;ѕ,s,S;Ė,E;ᐑ,A,n,v;ᴈ,3;ᵰ,n;ᒏ,j,i;Ø,O;ㄨ,u,X;ｒ,R;▄,_;丄,T;Կ,u;》,>>;ᅂ,OC;Ҝ,K;ｆ,F;٥,5,o;]=] .. [=[Ɓ,B;৬,6;�,?,-,/,=,C,I,O,S;Ä,A;ⅹ,X;ᗺ,E,B;➒,9;ҷ,u,y,h;ᑩ,c;ϳ,j,J;Ⱨ,H;Ｃ,C;ҁ,k,c;ᗾ,B;｀,`;Ꮄ,S;ց,g;ᑼ,d;Ʌ,^,N;Ʒ,E,z,3;]=] .. [=[ځ,c,z;ɨ,i;╚,L;·,';╭,r;☹,o;一,-;η,e,n;╒,F,r;ͻ,c;ة,o;م,p;ᑭ,p;ѻ,o;ヒ,t;⓺,6;ʔ,?;ռ,n;Յ,3,d;ｊ,J;]=] .. [=[ㄌ,l;ɻ,r,l;ᅄ,OU,OR,OA;п,p,n;⁃,-;✝,t;ㄩ,iu,U;ᵎ,i,!;੬,6;ム,A;њ,nj,Hb,H,b;ȿ,s;ᆼ,o;Ѡ,w;ˍ,COMMA;ᕷ,d;Ꮓ,Z;․,.;∂,d,a;⓾,10;]=] .. [=[Љ,N;Ф,F,O;Њ,H;ɢ,G;ґ,r;˨,l,i;＆,&;ǂ,|;נ,i,c,j;Ϩ,s;ۍ,s;Ⅰ,I;ڑ,j;┽,t,+;Ⱬ,Z;匚,C;┾,t,+;Ϟ,N,X;Ӎ,M;－,-;]=] .. [=[⊑,c;ᛖ,M;┰,T;∀,A;Ƒ,F;ɍ,r;ʙ,B;Ꮀ,E;ʑ,z;ʬ,w;Օ,O,/;″,";Α,A;Ƭ,T;ค,n,a;ⱥ,a;۔,.;¬,-,!;ۈ,g;？,?;]=] .. [=[ઘ,u;┭,T;ɕ,c;∣,l;╈,t,+;Ѱ,PS,W;╲,\;₴,S;♅,H;հ,h;〞,";Ⴝ,S;┌,r;Ҭ,T;ᑰ,d;ᒈ,b;イ,T;à,A;܁,.;ㄊ,t,g;]=] .. [=[么,G;▌,|;ᅀ,A;⋝,>;ᵭ,d;ᆺ,A,n,v;ם,a,o;۝,O;ᶆ,m;ɰ,w;＂,";Ͼ,C,c,E;＄,";ๆ,r;➊,1;ㄞ,ai;┍,r;ᅡ,t;˂,<;⓼,8;]=] .. [=[◊,o;ᵼ,i;Ⅾ,D;Å,A;Պ,n;ϝ,F;Φ,PH,F,O;┼,t,+;Ď,D;ᕵ,p;┇,|;ｂ,B;＼,\;ϸ,b,p;ʆ,l;〓,=;ס,o;ڼ,i;ֆ,S,$;ป,u;]=] .. [=[ڄ,c,z;ȴ,l;Ŋ,N;ᑗ,u;જ,v;Ҽ,e;Ɋ,q,a;［,[;ɪ,I;μ,m,u,U;چ,c;ᒌ,i;ʡ,?;ʼ,';ᖁ,d;‟,";❼,7;Ƽ,s;ᑴ,q;ᑤ,c;]=] .. [=[੨,2;➆,7;ي,s;ㄖ,r,o;ě,E;‖,||,ll;☩,t;٪,%;Ɔ,C;ท,n;ъ,b;❸,3;Ѕ,S;מ,a;ѥ,ie,E;⋑,c;ۏ,g;〨,E;ᙀ,u;ᘪ,s;]=] .. [=[ᶂ,f;⓮,14;Ԏ,T;ӄ,b,h,k;ᴃ,B,D;ϗ,h,k,x;ե,t,b;ڷ,J;ᗸ,E;⫽,/;ᐁ,v;ɘ,e;ᒑ,l,i;ᄔ,LL;Җ,X,K;˃,>;Ｘ,X;Ю,IO,O;ϭ,d,o;※,X;]=] .. [=[｡,.;６,/;อ,d,o;ฟ,w,m;ᑽ,d;╏,|;Ɩ,I;ᑛ,n;Щ,SH,W;ᵴ,s;≽,>;ㄒ,x,T;〤,X;╎,|;Ζ,Z;；,SEMICOLON;Ᏸ,B;╍,-;ʖ,?;ڱ,S;]=] .. [=[า,r;Λ,L,A,N;ᑸ,p;Ｅ,E;╊,t,+;ѵ,v,V;⏆,l;±,+,-;ᑨ,n;⊌,u;ɚ,e;Ʊ,u;二,2;╆,t,+;ᗐ,V;Д,D,A;Ꭹ,y,v,u;յ,j,i,J;О,O,/;α,a,A;]=] .. [=[ᔣ,s;ᄐ,E;╂,t,+;➂,3;ม,u,w;ฮ,a;マ,R;ᴟ,m,E;┃,|;ɵ,o;В,V,B;ع,E;┱,T;ȣ,d,o;ᑠ,c;২,2;ᒕ,r;Ȥ,Z;ل,j;┗,L;]=] .. [=[ᗽ,B;Ｔ,T;╺,-;⊝,o;｝,};⏌,L;ˇ,';ȹ,qp,cp;ë,E;└,L;る,z;ᑟ,c;܃,:;ㄣ,en;Ӈ,H,A;凡,N;ʋ,u,v;ӽ,x;â,A;┏,r;]=] .. [=[ᴇ,E;Ͻ,C;ۇ,g;ｐ,P;ᑌ,u;♌,n;๛,c;７,/;Ƌ,d;丶,';乛,-;⊛,o;⊥,T;ᅙ,o;ɏ,y;ᴫ,N;˫,l,i;➐,7;ע,v,u;ᗵ,R;]=] .. [=[Ꭵ,v,i,I;ᖅ,b;ʦ,ts,s;┉,-;下,T;ᄜ,OA,OU,OR;ᗪ,D;ᘢ,u;У,U,Y;ᖳ,q;Ҧ,n;Ϻ,M;Г,G,L;ᕹ,b;Տ,s,S;╇,t,+;ԓ,N;ٺ,u;я,y,R;∐,U;]=] .. [=[ᒙ,j;ᚫ,F;ח,n;Є,E;ᘃ,i;ᶊ,s;ժ,d,D;⺆,n;ҫ,s,c;ｙ,Y;♊,o;ӌ,u,y,h;ē,E;⊎,u;Ꮞ,4;ᴋ,K;／,/;┖,L;⏊,T;Ԍ,G;]=] .. [=[⏄,A;ƣ,a;×,x;Գ,q;从,M;ᚾ,I;ⅾ,D;Ƨ,S;上,T;⋂,n;⏀,O;ᗹ,E,B;қ,k;个,T;۲,r;⊕,o;⎿,L;ӷ,L;☥,t;⋩,>;]=] .. [=[ʛ,G;ƀ,b;Ҷ,u,y,h;ᗱ,E;Ꭱ,e,R;ʀ,R;ɾ,r;ك,j;ᅊ,OE;⓳,19;ڶ,J;⏉,T;ƛ,A;Ҁ,k,c;ƶ,z;Ｐ,P;＋,+;ր,n;¶,P;人,N;]=] .. [=[⋎,v;ڀ,u;Ʉ,U;ᛙ,I;;,SEMICOLON;⋗,>;ᗖ,V;ㄦ,er;⋒,n;Ｌ,L;Ꮚ,w;Ｉ,I;∆,D,A;ｕ,U;╀,t,+;ԃ,d;Ꮍ,Y;վ,u;ɺ,r,l;⋀,A,n;]=] .. [=[∋,R;օ,o;Ծ,o;ㄢ,an;ᶔ,3,e;⓸,4;о,o,/,O;ᔙ,s;ᴏ,O;♩,l,I;ˌ,COMMA,.;Ｄ,D;♏,m;厂,R;Ⱦ,T;๓,n,m;ᒁ,b;˶,";ᶓ,e;，,COMMA;]=] .. [=[Ⱡ,L;λ,l,A;ݟ,E;Ꮒ,h;ʄ,s,f;»,>>,>;ی,s;╃,t,+;ฃ,u;ᴠ,V;ϧ,3,c;☸,o;七,t;≪,<<;˧,l,i;ф,f,o;ᴨ,P,N;⁁,l,/;ק,p;⋥,c;]=] .. [=[⊔,u;⓷,3;є,e;⏅,A;ʫ,lz;ｔ,T;ᆷ,o;∨,v;＇,';ẞ,ss,B;ʐ,z;ӡ,3,z;«,<<,<;Ｈ,H;Ք,p;ɗ,d;ƫ,t;ｑ,Q;Ꮵ,h;≲,<;]=] .. [=[ګ,S;ᒚ,j;Ꮖ,C;ヲ,E;ㄧ,i;ɯ,w;И,I,N;⊇,>;凵,U;₫,d;Ę,E;⊍,u;┳,T;♭,b;Ϭ,d,o;₤,E,L;➍,4;ย,u;ˑ,.;⎾,L;]=] .. [=[ᒅ,q;ᛘ,Y;կ,u;ᖄ,b;Ɽ,R;⊜,o;ѯ,E;ᒋ,i;⊦,t;ᒗ,r;Ϝ,F;Á,A;Ꮁ,T,G,F;∩,n;ݔ,u;ǁ,II;ز,j;À,A;ᵲ,r;▏,|;]=] .. [=[ᒫ,L;ㄏ,h;۷,v;ρ,r,p,P;˴,';ƅ,b;Ƿ,P;৭,7;ᖃ,b;ᒰ,r;÷,-;Ѯ,E;ڻ,o,u;⓻,7;ݤ,S;⏁,O,T;ᶚ,3;ʅ,s;@,a;☓,X;]=] .. [=[һ,h,H;ｍ,M;℧,u;ɉ,j;Ꮅ,P;๏,o;ᶗ,c;ᑏ,n;ʻ,';∃,E;ٿ,u;ᖯ,b;➉,10;څ,c,z;ʠ,q;Չ,o;┿,t,+;∇,A;Π,P,N;ى,s;]=] .. [=[ƻ,2;ฦ,n,a;Ҡ,K;ⅿ,M;ᒉ,i;ᚪ,F;ɿ,r;щ,sh,w;ⱨ,h;Ꮳ,c;ɤ,v;〜,~;₯,Dp,D;Ը,c,l;▃,_;ᕴ,q;ᗥ,D;۸,A;Ѥ,IE,E;ᶋ,s;]=] .. [=[ȝ,3,E;ԍ,G;ᔑ,s;⋨,<;ڲ,S;੦,0;٤,4,E;ۑ,s;］,];₥,m;դ,n;ʪ,ls;ᑒ,c;Ҫ,s,C;ب,u;ᛕ,K;∠,<;ҕ,b,a;ᵬ,b;৩,3;]=] .. [=[₣,F;＠,?;Ш,SH,W;⌡,j;и,i,N;ｉ,I;È,E;ᚿ,I;ڸ,U;ƕ,h;Æ,AE;ィ,T;ᅃ,OO;”,";Ұ,U,Y,V;☼,o;“,";Ε,E;ェ,I;љ,lj,nb,n,b;]=] .. [=[Ⅿ,M;ʕ,?;ڰ,S;➏,6;➅,6;ᴔ,oe;‒,-;ə,e;Փ,o;ᒍ,j,i;°,',o;˼,COMMA;ⱬ,z;ԝ,w;ۆ,g;✘,X;∏,P,N;Н,N,H;ᖇ,R;⋞,<;]=] .. [=[╳,X;ᅇ,OO;մ,u;Ꮮ,l,L;ᄘ,2L;╔,r;ظ,b;Ҋ,I,N;ᵯ,m;ᚨ,F;̸,/;Ꮪ,s,S;Ｑ,Q;ᶎ,z;ɴ,N;╘,L;ᶌ,v;ᑖ,c;ĸ,K;≾,<;]=] .. [=[ᛉ,Y;ᶇ,n;ȸ,db,cb;Ђ,h;ㄚ,a,Y;＜,<;◇,o;Ԃ,d;〷,XX;ｅ,E;Ⴍ,Q;ˆ,^;Ԁ,d;Т,T;Ӽ,X;܂,.;ᑻ,d;ɩ,i,I;ϼ,p;á,A;]=] .. [=[凹,U;ㄗ,z,p,n;ᔤ,s;Ɗ,D;›,>;ڒ,j;9,g;▋,|;ᗏ,A;บ,u;ᵺ,th;Ɏ,Y;₢,G;ƥ,b;ᚢ,n;乃,B;ᵷ,g,o,b;¥,Y;⊃,>;⦿,o;]=] .. [=[ז,i;Υ,U,Y;੩,3;ᘭ,s;╿,|;ʥ,dz;❽,8;ø,o;ݞ,E;═,-;Ｙ,Y;Վ,u;ᐂ,A,n;ҥ,H;ᴊ,J;ю,io,o;⺁,r;ѩ,IA,A;ᴡ,W;Ԓ,N;]=] .. [=[8,B;ᑚ,n;ᘨ,u;թ,p;ต,n,a;∟,L;ᶃ,g;٩,9,q;г,g,r,L;８,/;ә,e;┋,|;ᆠ,T;ａ,A;〔,(;Ē,E;ᘻ,m;ƌ,d;┆,|;੭,7;]=] .. [=[ᑿ,b;ᑣ,c;ˋ,';ᖰ,p;พ,w,m;ح,c,z;ⱱ,v;Қ,K;ᒸ,L;⓰,16;ױ,ii;ᴁ,AE;╻,i;Э,E;۱,i,l;ʚ,a,d;₦,N;Κ,K;ʊ,u;乇,T;]=] .. [=[ᛇ,S;Ᏻ,G;―,-;４,/;ҵ,u;Մ,u;ᛒ,B;ᕸ,d;ᗩ,A;❹,4;ᴜ,U;ᛊ,E;ڵ,J;Ｕ,U;չ,Z;ɞ,e,B;Ƶ,Z;ᚼ,I;⓴,20;≺,<;]=] .. [=[ᚹ,P;｜,|;ᶏ,a;⊏,c;ε,e;ᑞ,c;ѹ,oy;7,t;ᛁ,I;⁅,E;⓫,11;ᚗ,G;△,A;ᘯ,n;ɹ,r;у,u,y,Y;Ҏ,p;ƚ,l;ᙁ,n;Ճ,bo;]=] .. [=[ᵳ,r;็,r;ㄓ,zh,z,w;ᚻ,H,N;н,n,H;ᛗ,M;Ꭺ,A,n;ᛞ,M;☨,t;ㄟ,ei;ᘵ,n;Ë,E;Ƚ,L,t;ᗴ,E;十,T;ㄥ,eng,L,C;ζ,z,s,c;⋖,<;ᴘ,P;ۋ,g;]=] .. [=[㉿,K;☋,u;│,|;Ȣ,d,o;৫,5;Ｏ,/,O;’,';Ӌ,u,y,h;ᴛ,T;ʏ,Y;պ,w;æ,ae;ɋ,q,a;Ə,e;⊋,>;Ϧ,h,b;ҡ,k;∓,T;ᴣ,3;˦,l,i;]=] .. [=[ۯ,j;ᘫ,s;⊤,T;➀,1;≦,<;┯,T;⓯,15;ｘ,X;╋,t,+;ઇ,d;ᒖ,r;ƪ,l;ᄕ,LC;ҏ,p;6,b;ᖀ,p;φ,ph,o,w;З,E;‡,t,i;ɮ,B,k,z,3;]=] .. [=[ટ,s;几,N;ө,th,o;ᔍ,c;ᵿ,A,u;ᔜ,s;○,O;œ,oe,ce;ᑧ,u;╄,t,+;ᔕ,s;ɓ,b;ϡ,l;ᶖ,i;Ѵ,V;ٮ,u;れ,n;♆,W;┎,r;ծ,d,o;]=] .. [=[ᒺ,L;ɶ,OE,CE;ถ,n,a;כ,c;₮,T;ė,E;ᒮ,r;Բ,f;ᒛ,j;„,,,,COMMA;ᙅ,c;ϛ,s;⁄,/;Ꮣ,l,c;ǀ,I,|;꞉,:;ᖸ,u;ડ,s;ษ,u;Ӷ,L;]=] .. [=[Ц,TS,U,Li;₧,Pts,P;π,p,n;₭,K;⊐,c;ҟ,k;Ӏ,I;Ƅ,b;♋,69;Ο,O,/;Ы,bl;Ƕ,H;ᑬ,p;ʟ,L;ᴄ,C;Һ,h;Ꮙ,v;Ɵ,O;ᑳ,b;϶,e;]=] .. [=[₳,A;5,S;、,COMMA;ք,p;ᄆ,O;০,0;₸,T;κ,k,x,K;ᵻ,i;Ϸ,b,p;к,k;$,S;ᑫ,q;∫,s;ᘀ,B;Ѿ,w;∊,R;ᕶ,p;ᅌ,O;Ո,n;]=] .. [=[∝,oo;ᗼ,R;в,v,B;و,g;ݓ,u;ก,n,a;ϟ,S;≤,<;≩,>;Ꮷ,J;Ꭲ,I,G,L,T;ш,shw;ݬ,j;☻,o;ɔ,c;ɣ,Y,v;Ћ,h;๐,o;ں,i;א,X,N;]=] .. [=[Ɛ,E;ݣ,S;ᴀ,A;ѣ,b;⊖,o;⊘,o;❍,o;գ,q;Ґ,L,r;ħ,h,n;⋃,u,U;Ð,D;ѿ,W;Ч,CH,u,h;Ͽ,C,c,E;ϫ,a,v;Ј,J,I,l;⋦,<;ᗗ,A;Ҕ,b,h;]=] .. [=[ᐎ,A,n,v;ا,i,l,/,I,L,|;Ǥ,G;پ,u;ᶐ,q;થ,u;（,(;Ꮶ,K;4,A,R;Ѻ,O;⋐,c;Ɣ,Y;ƺ,E,z,3;ӎ,m;Μ,M;∔,i;ᑯ,d;ʯ,h,u;ɟ,j,f;Δ,D,A;]=] .. [=[☤,t;ϲ,C;ㄇ,m,n;ј,j,J;џ,dz,u;⋤,c;Ꮎ,E;Ԝ,W;ᔖ,s;ᑎ,n;Ⅴ,V;М,M;1,I,l;گ,S;┲,T;ѳ,f,th,o,e;➁,2;≫,>>;Ӄ,R,b,h,K;Ȝ,3,E;]=] .. [=[⏃,A;ү,u,Y,v;⏈,T;ٳ,i;ら,s;з,z,e,3;ᴌ,L;┕,L;ᙃ,e,c;˄,^;ŋ,n;இ,I,A,O;⓲,18;ط,b;ᒂ,b;ې,s;♃,u;Է,t;ƴ,y;ɳ,n;]=] .. [=[ҋ,i,N;ᑲ,b;ᅆ,OA;٣,3,r;Ꮑ,N;Ϣ,W;ԁ,d,D;ӻ,f;υ,u,U;ȷ,j,i;ᗟ,D;〉,>;˅,v;৮,8;ʉ,u,A;˻,COMMA;ː,i,¦;≥,>;➌,3;ξ,x,E;]=] .. [=[┬,T;⏂,O,T;Ꮊ,N;Ａ,A;ᔔ,s;ᛂ,I;Ꮢ,R;Ꮲ,p,P;ۅ,g;ᘮ,u;д,d,A;Ӡ,3,z;ᔒ,s;ҿ,e;ข,u;Ƥ,P;ן,i;ο,o,/,O;丂,S;¤,o,x;]=] .. [=[⊓,n;ʿ,';։,:;Τ,T;Ь,b,B;ƿ,D;ᒿ,2;ʤ,dz;Ս,u,U;¿,?;ᗦ,D;Ꮐ,G;э,e,3;✛,t;Б,b;Ҥ,H;ચ,u;ᛔ,B;ԑ,E;❾,9;]=] .. [=[ห,n;ᗤ,D;ճ,d,o;ǝ,e;♇,B;§,S;ᑶ,p;ը,o,n;ו,i;Ꮭ,c;❶,1;٨,8,n;ӕ,ae;ɠ,g;đ,d,D;⁓,~;▂,_;Ᏼ,B;╾,-;ج,c,z;]=] .. [=[ە,o;ᛈ,C;3,E;ⅰ,I;ｋ,K;K,K;ς,s,c;װ,ii;ᶘ,s;Ϙ,O;ҙ,E;ｄ,D;ݘ,c;⺋,e;ʒ,E,z,3;Ꮆ,G;＾,^;５,/;ฆ,u;ð,d,o;]=] .. [=[ʌ,v,n,^;৪,4;Ι,I;ᑓ,c;ᶀ,b;Ɖ,D;☽,c;Ҵ,u;Ҿ,e;〇,o;ƙ,k;น,u;ɝ,e,3,s;て,t;Ә,e;ڴ,S;❺,5;％,%;ᄙ,22;ᑑ,c;]=] .. [=[ł,l;٫,COMMA;．,.;ᒊ,i;ɂ,?;ㄎ,k,s,e;ᒔ,r;੪,4;Я,Y,R;Ԑ,E;ᑺ,d;Ѹ,Oy;т,t;Ꮩ,V,N;ʜ,H;Լ,L;Ղ,n;Ն,i;ᒆ,p;ɸ,o,ph,f;]=] .. [=[Ꭿ,A;ᄖ,LA,LR,LU;ノ,J;ա,w;ᵫ,ue;ㄜ,e;➄,5;ȼ,c;ˊ,';ո,n;丁,T;ʺ,";ה,n;เ,i;‐,-;خ,c,z;ݝ,E;ㄅ,b,s;ᐃ,A,n;ᴑ,O;]=] .. [=[⊗,o;ᔚ,s;ȡ,d;☖,o;ۊ,g;💀,oo;Ꮸ,c;√,v;ǥ,g;ᕿ,p;С,S,C;Ⱳ,W;ӊ,H;Ϛ,S;ڈ,s,j;ㄔ,ch;ϥ,h,b,p,q;ᴅ,D;ﾉ,/;⫻,/;]=] .. [=[˥,l,i;ݗ,c;ʩ,fn;９,/;ץ,Y;≧,>;Ω,aw,O,n;┊,|;Ւ,t,r;ᵶ,z;©,c;ᑕ,c;੮,8;ⱪ,k;ᑾ,b;ⱦ,t,l;Ꭻ,j,J;Ꮥ,s;ک,S;ᘴ,u;]=] .. [=[Ж,X,K;ภ,n,a;ͼ,c,E;ւ,L;Œ,OE,CE;⊊,,<;ᄋ,O;１,/;ɒ,a;✞,t;ҳ,x;ѧ,A;٭,*;◯,O;▕,|;]=]

		for _, chunk in ipairs(translate_data:split(";")) do
			local args = chunk:split(",")
			local key = list.remove(args, 1)

			for i, v in ipairs(args) do
				if v == "COMMA" then v = "," end

				if v == "SEMICOLON" then v = ";" end
			end

			translate[key] = args
		end
	end

	function utf8.getsimilarity(a, b)
		if not translate[1] then init() end

		b = b:upper()
		local score = 0

		for i, char in ipairs(utf8.totable(a)) do
			if translate[char] then
				local test = b:usub(i, i)

				if table.has_value(translate[char], test) then score = score + 1 end
			end
		end

		return score / #b
	end
end

function utf8.length(str)
	local len = 0

	for i = 1, #str do
		local b = str:byte(i)

		if b < 128 or b > 191 then len = len + 1 end
	end

	return len
end

utf8.len = utf8.length

function utf8.totable(str)
	local tbl = {}
	local i = 1

	for tbl_i = 1, #str do
		local byte = str:byte(i)

		if not byte then break end

		local length = 1

		if byte >= 128 then
			if byte >= 240 then
				length = 4
			elseif byte >= 224 then
				length = 3
			elseif byte >= 192 then
				length = 2
			end
		end

		tbl[tbl_i] = str:sub(i, i + length - 1)
		i = i + length
	end

	return tbl
end

for name, func in pairs(utf8) do
	string["u" .. name] = func
end

return utf8