--- Hackage HTTP API, used when the local package index is unavailable (see
--- `index.lua`). It has no per-package endpoint with upload times, so versions
--- found here are undated.
local M = {}

--- Lists the versions of a package, unsorted.
--- @param tool string
--- @return string[]
function M.versions(tool)
    local http = require("http")
    local json = require("json")

    -- The Hackage "preferred" endpoint returns JSON with two arrays:
    --   "normal-version"     : usable versions
    --   "deprecated-version" : versions the maintainer discourages (still installable)
    -- NOTE: http yields internally, so it must NOT be wrapped in pcall. Use the
    -- try_ variant, which returns (response, err) instead of raising on transport
    -- failures (timeout, DNS, connection refused).
    local url = "https://hackage.haskell.org/package/" .. tool .. "/preferred"
    local resp, err = http.try_get({ url = url, headers = { ["Accept"] = "application/json" } })
    if err ~= nil then
        error("mise-cabal: failed to reach Hackage for '" .. tool .. "': " .. tostring(err))
    end
    if resp.status_code == 404 then
        return {}
    end
    if resp.status_code ~= 200 then
        error("mise-cabal: Hackage returned HTTP " .. tostring(resp.status_code) .. " for '" .. tool .. "'")
    end

    local data = json.decode(resp.body)
    if type(data) ~= "table" then
        error("mise-cabal: could not parse Hackage response for '" .. tool .. "'")
    end

    -- Include deprecated versions too, so a previously pinned version stays resolvable.
    local versions = {}
    local function append(list)
        if type(list) == "table" then
            for _, v in ipairs(list) do
                versions[#versions + 1] = v
            end
        end
    end
    append(data["normal-version"])
    append(data["deprecated-version"])

    return versions
end

--- Searches package names and synopses.
--- @param query string
--- @return BackendTool[]
function M.search(query)
    local http = require("http")
    local json = require("json")

    -- Percent-encode the query so spaces and symbols survive the URL.
    local terms = query:gsub("[^%w%-%._~]", function(c)
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

    return tools
end

return M
