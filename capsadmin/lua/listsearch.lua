local list = {
	"there was a time they cared nothing for miss vance",
	"60 percent of the time it works everytime",
	"attention stabilization team leaders report d service unit to sterilized body count ratios fully enforcement reward or removal processing",
	"a",
	"b",
	"do you",
	"persuade him",
}

local tree = {}

for sentence_id, sentence in ipairs(list) do
	local node = tree

	for word in sentence:gmatch("[^ ]+") do
		node[word] = node[word] or {}
		node = node[word]
	end

	node._ = sentence_id
end

local function parse_text(str)
	local out = {}

	local words = {}

	for word in str:gmatch("[^ ]+") do
		words[#words + 1] = word
	end

	out[1] = list[math.random(#list)] -- close enough

	return out
end

table.print(parse_text("do you a a a a a persuade him 60 percent of the time it works everytime do b you"))