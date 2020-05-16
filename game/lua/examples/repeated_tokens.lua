local found = {}
local str = {}

if true then
    local path = "/home/caps/goluwa2/core/lua/init.lua"
    local str = fs.Read(path)
    local tokenizer = oh.lua.Tokenizer(str)
    local tokens = tokenizer:GetTokens()
    table.add(found, tokens)
else
    for _, path in ipairs(fs.get_files_recursive("core/")) do
        if path:endswith(".lua") then
            if path:find("/home/caps/goluwa2/game/lua/examples/repeated_tokens.lua") then
                local str = fs.Read(path)
                local tokenizer = oh.lua.Tokenizer(str)
                local tokens = tokenizer:GetTokens()
                table.add(found, tokens)
            end
        end
    end
end

for i,v in ipairs(found) do
    str[i] = v.value
end

str = table.concat(str, " ")

local MINLEN = 2
local MINCNT = 3

local function sub_table(tbl, start, stop)
    local out = {}
    for i = start, stop do
        table.insert(out, tbl[i])
    end
    return out
end

local function count(tbl, what)
    local found = 0
    local i = 1
    for _, token in ipairs(tbl) do
        if what[i].value == token.value then
            i = i + 1
            if not what[i] then
                found = found + 1
                i = 1
            end
        else
            i = 1
        end
    end
    return found
end

local function hash(tokens)
    local hash = {}
    for i,v in ipairs(tokens) do
        hash[i] = v.value
    end
    return table.concat(hash, " ")
end

local len = #str
local d={}
for sublen = MINLEN, math.ceil(len/MINCNT)-1 do
    for i = 1, len - sublen do
        local sub = str:sub(i, i+sublen)

        if str:find(sub, i, true) then
            d[sub] = (d[sub] or 0) + 1
        end
    end
end

for i,v in pairs(d) do
    if v >= MINCNT then
        print(i,v)
    end
end

local a = 5 + 2
local a = 5 + 2
local a = 5 + 2
local a = 5 + 2