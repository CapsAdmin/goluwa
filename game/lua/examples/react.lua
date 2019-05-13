--oh!

local function LSX(class, props, children)
    do
        local s = "<" .. class
        if props then
            s = s .. " "
            for k,v in pairs(props) do
                s = s .. k .. "='" .. tostring(v) .. "'"
            end
        end
        s = s .. ">"

        if children then
            for _, v in ipairs(children) do
                if type(v) == "table" then
                    print(v)
                    for _, v in ipairs(v) do
                        s = s .. tostring(v)
                    end
                else
                    s = s .. tostring(v)
                end
            end
        end

        s = s .. "</" .. class .. ">"

        return s
    end

    return {
        class = class,
        props = props,
        children = children,
    }
end

local function CSS(tbl)
    local s = ""
    for k,v in pairs(tbl) do
        s = s .. k .. ":" .. tostring(v) .. ";"
    end
    return s
end

local function Result(result)
    return <div style={CSS{
        padding = "10px",
        margin = "10px",
        background = 'white',
        ["box-shadow"] = '0 1px 5px rgba(0,0,0,0.5)'
    }}>
        <div>
            <a href={result.html_url} target="_blank">
                {result.full_name}
            </a>
            🌟<strong>{result.stargazers_count}</strong>
        </div>
        <p>{result.description}</p>
    </div>
end

resource.Download("http://api.github.com/search/repositories?q=preact"):Then(function(results)
    local results = vfs.Read(results).items or {}

    local html = <div>
        <h1 style="text-align:center;">Example</h1>
        <div class="list">
            {table.map(results, function(result) return Result(result) end)}
        </div>
    </div>

    vfs.Write("index.html", html)
    print(R"index.html")
end)