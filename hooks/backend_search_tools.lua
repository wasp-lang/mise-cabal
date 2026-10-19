--- Searches Hackage for packages, for `mise search` and shell completion.
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendsearchtools
--- @param ctx BackendSearchToolsCtx
--- @return BackendToolsResult
function PLUGIN:BackendSearchTools(ctx)
    local http = require("http")
    local json = require("json")

    -- Percent-encode the query so spaces and symbols survive the URL.
    local terms = ctx.query:gsub("[^%w%-%._~]", function(c)
        return string.format("%%%02X", c:byte())
    end)

    -- Hackage's search endpoint returns `[{"name": "hlint"}, ...]` as JSON. It
    -- matches package names and synopses, so it also finds tools by topic.
    local url = "https://hackage.haskell.org/packages/search?terms=" .. terms
    local resp, err = http.try_get({ url = url, headers = { ["Accept"] = "application/json" } })
    if err ~= nil then
        error("mise-cabal: failed to search Hackage: " .. tostring(err))
    end
    if resp.status_code ~= 200 then
        error("mise-cabal: Hackage search returned HTTP " .. tostring(resp.status_code))
    end

    local data = json.decode(resp.body)
    if type(data) ~= "table" then
        error("mise-cabal: could not parse Hackage search response")
    end

    local tools = {}
    for _, entry in ipairs(data) do
        if type(entry) == "table" and type(entry.name) == "string" then
            tools[#tools + 1] = { name = entry.name }
        end
    end

    return { tools = tools }
end
