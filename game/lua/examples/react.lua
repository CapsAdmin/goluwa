local SEARCH = "http://api.github.com/search/repositories"

local function CSS(tbl)
    return {
        type = "css",
        values = tbl,
    }
end

local function Result(result) 
    return {
        [[
            <div style=]], CSS{
                padding = "10px",
                margin = "10px",
                background = 'white',
                ["box-shadow"] = '0 1px 5px rgba(0,0,0,0.5)'
            }, [[>
                <div>
                    <a href=]], result.html_url, [[ target="_blank">
                        ]], result.full_name, [[
                    </a>
                    🌟<strong>]],result.stargazers_count,[[</strong>
                </div>
                <p>]],result.description,[[</p>
            </div>
        ]]
    }
end

local META = {}

function META:OnMount()
    resource.Download(SEARCH .. "?q=preact"):Then(function(results)
        self.results = vfs.Read(results).items or {}
        
        local function render(tbl, flat)
            for i,v in ipairs(tbl) do
                if type(v) == "table" then
                    if v.type and v.type == "css" then
                        local css = {}

                        for k,v in pairs(v.values) do
                            table.insert(css, k .. ":" .. tostring(v) .. ";")
                        end

                        v = '"'..table.concat(css)..'"'
                    else
                        v = render(v, flat)
                    end
                else
                    v = tostring(v)
                end
                table.insert(flat, v)
            end
        end

        local flat = {}
        render(self:Render(), flat)
        vfs.Write("WO.html", table.concat(flat))
        print(R"WO.html")
    end)
end

function META:Render()
    return {[[
        <div>
            <h1 style="text-align:center;">Example</h1>
            <div class="list">
                ]], table.map(self.results, function(result) return Result(result) end) ,[[
            </div>
        </div>
    ]]}
end

META:OnMount()