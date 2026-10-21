--- A Hackage package index shared by all tools. It lives in the plugin's cache
--- directory, is refreshed with `cabal update`, and answers searches and version
--- listings locally, including each version's upload date.
local M = {}

---@class Index
---@field dir string CABAL_DIR that owns the index
---@field tar string The index tarball

--- Strip surrounding whitespace, including the CRLF that Windows output ends with.
--- @param s string
--- @return string
local function trim(s)
    return (s:gsub("^%s+", ""):gsub("%s+$", ""))
end

--- Bring the shared index up to date. Returns nil when there is no usable index
--- (mise has no cache directory for us, or cabal is not installed yet), so the
--- caller can fall back to the Hackage API.
--- @return Index?
function M.update()
    local cabal = require("cabal")
    local file = require("file")
    local log = require("log")

    if RUNTIME.cacheDirPath == nil then
        return nil
    end
    local dir = file.join_path(RUNTIME.cacheDirPath, "cabal")

    -- Ask cabal where the index goes rather than assuming the layout, which the
    -- user's CABAL_CONFIG can change.
    local ok, repo_cache = pcall(cabal.call, dir, "path -v0 --remote-repo-cache")
    if not ok then
        log.debug("mise-cabal: cannot run cabal, falling back to the Hackage API: " .. tostring(repo_cache))
        return nil
    end
    repo_cache = trim(repo_cache)
    local tar = file.join_path(repo_cache, "hackage.haskell.org", "01-index.tar")

    if not file.exists(tar) then
        log.info("Downloading the Hackage package index, this only happens once")
    end
    local updated, err = pcall(cabal.call, dir, "update")
    if not updated then
        if not file.exists(tar) then
            log.warn("mise-cabal: could not download the Hackage package index: " .. tostring(err))
            return nil
        end
        log.warn("mise-cabal: could not update the Hackage package index, using the existing one: " .. tostring(err))
    end

    return { dir = dir, tar = tar }
end

--- A NUL-terminated string field of a tar header.
--- @param field string
--- @return string
local function cstring(field)
    local nul = field:find("\0", 1, true)
    return nul and field:sub(1, nul - 1) or field
end

--- An octal number field of a tar header.
--- @param field string
--- @return number?
local function octal(field)
    return tonumber(field:match("[0-7]+"), 8)
end

--- Lists the versions of a package with their upload dates, unsorted. Returns
--- nil when the index is unavailable, and an empty list if the package does not
--- exist.
--- @param tool string
--- @return BackendVersion[]?
function M.versions(tool)
    local index = M.update()
    if index == nil then
        return nil
    end

    local f, err = io.open(index.tar, "rb")
    if f == nil then
        error("mise-cabal: could not open the Hackage package index: " .. tostring(err))
    end

    -- The index is an append-only tarball with a `<pkg>/<version>/<pkg>.cabal`
    -- entry per upload, timestamped with the upload time. Later revisions of the
    -- .cabal file are appended as new entries, so the first one for a version
    -- dates its release. Reading just the 512-byte headers and seeking past the
    -- contents scans the whole index in well under a second.
    local prefix = tool .. "/"
    local dates = {}
    local order = {}
    while true do
        local header = f:read(512)
        if header == nil or #header < 512 or header:byte(1) == 0 then
            break
        end

        local name = cstring(header:sub(1, 100))
        if header:byte(346) ~= 0 then -- ustar splits long paths into a prefix and a name
            name = cstring(header:sub(346, 500)) .. "/" .. name
        end
        if name:sub(1, #prefix) == prefix then
            local version = name:match("^[^/]+/([^/]+)/[^/]+%.cabal$")
            if version ~= nil and dates[version] == nil then
                dates[version] = octal(header:sub(137, 148))
                order[#order + 1] = version
            end
        end

        local size = octal(header:sub(125, 136)) or 0
        f:seek("cur", math.ceil(size / 512) * 512)
    end
    f:close()

    local versions = {}
    for i, version in ipairs(order) do
        versions[i] = {
            version = version,
            created_at = dates[version] and os.date("!%Y-%m-%dT%H:%M:%SZ", dates[version]),
        }
    end
    return versions
end

--- Searches package names. Returns nil when the index is unavailable.
--- @param query string
--- @return BackendTool[]?
function M.search(query)
    local cabal = require("cabal")
    local shell = require("shell")

    local index = M.update()
    if index == nil then
        return nil
    end

    -- `cabal list` prints a block per package:
    --   * hlint
    --       Synopsis: Source code suggestions
    --       Default available version: 3.10
    --       ...
    -- with long values wrapped onto further, more indented lines.
    local out = cabal.call(index.dir, "list -v0 " .. shell.var("MISE_CABAL_QUERY"), { MISE_CABAL_QUERY = query })

    local tools = {}
    local current, field
    for line in out:gmatch("[^\r\n]+") do
        local name = line:match("^%* (%S+)")
        if name ~= nil then
            current = { name = name }
            tools[#tools + 1] = current
            field = nil
        elseif current ~= nil then
            local key, value = line:match("^    (%S[^:]*):(.*)$")
            if key ~= nil then
                field = key
                if key == "Synopsis" then
                    current.description = trim(value)
                end
            elseif field == "Synopsis" then
                current.description = trim(current.description .. " " .. line)
            end
        end
    end
    for _, tool in ipairs(tools) do
        if tool.description == "" then
            tool.description = nil
        end
    end

    return tools
end

return M
