local M = {}

--- Split a Cabal version string into its numeric components.
--- Cabal follows the PVP, so a version is a dot-separated list of non-negative
--- integers with anywhere from 1 to 4 components, e.g. "1", "1.2", "1.2.3.4".
--- @param version string
--- @return integer[]
local function parse(version)
    local parts = {}
    for component in tostring(version):gmatch("%d+") do
        parts[#parts + 1] = tonumber(component)
    end
    return parts
end

--- Compare two Cabal version strings, returning -1, 0, or 1 (a < b, a == b,
--- a > b). The built-in semver.compare assumes the 3-component
--- MAJOR.MINOR.PATCH shape and mis-sorts Cabal's 1-to-4-component versions, so
--- we compare component by component ourselves, treating any missing trailing
--- component as 0 (so "1.2" == "1.2.0").
--- @param a string
--- @param b string
--- @return integer
function M.compare_versions(a, b)
    local pa = parse(a)
    local pb = parse(b)

    local n = math.max(#pa, #pb)
    for i = 1, n do
        local na = pa[i] or 0
        local nb = pb[i] or 0
        if na ~= nb then
            return na < nb and -1 or 1
        end
    end

    return 0
end

--- Sort Cabal version strings ascending (oldest -> newest), as mise expects.
--- Returns a new sorted list and leaves the input untouched.
--- @param versions string[]
--- @return string[]
function M.sort_versions(versions)
    local sorted = {}
    for i, v in ipairs(versions) do
        sorted[i] = v
    end
    table.sort(sorted, function(a, b)
        return M.compare_versions(a, b) < 0
    end)
    return sorted
end

--- Whether `name` is a valid Hackage package name: one or more alphanumeric
--- components joined by single hyphens, each containing at least one letter,
--- e.g. "hlint", "pandoc-cli", "base64". The name ends up in a shell command, so
--- this also guarantees it holds no shell metacharacters.
--- @param name string
--- @return boolean
function M.is_package_name(name)
    if type(name) ~= "string" or name == "" then
        return false
    end
    for component in (name .. "-"):gmatch("(.-)%-") do
        if not component:match("^%w+$") or not component:match("%a") then
            return false
        end
    end
    return true
end

--- Whether `version` is a valid Cabal version: dot-separated non-negative
--- integers, e.g. "1", "3.8", "1.2.3.4". Like the package name, it ends up in a
--- shell command, so this also guarantees it holds no shell metacharacters.
--- @param version string
--- @return boolean
function M.is_version(version)
    if type(version) ~= "string" or version == "" then
        return false
    end
    for component in (version .. "."):gmatch("(.-)%.") do
        if not component:match("^%d+$") then
            return false
        end
    end
    return true
end

--- Raise a mise-cabal error unless `name` is a valid Hackage package name.
--- @param name string
function M.check_package_name(name)
    if not M.is_package_name(name) then
        error("mise-cabal: '" .. tostring(name) .. "' is not a valid Hackage package name")
    end
end

--- Run `cabal <args>` with the tool's own CABAL_DIR so cabal treats `dir` as its
--- entire home: store, package index, config, and bins all live there, keeping
--- each tool's install self-contained. CABAL_DIR is passed through cmd.exec's
--- `env` option, which scopes it to this subprocess and leaves the rest of the
--- environment (PATH, HOME, ...) intact.
--- @param dir string
--- @param args string
--- @return string
function M.call(dir, args)
    local cmd = require("cmd")

    return cmd.exec("cabal " .. args, {
        env = {
            CABAL_DIR = dir,
        },
    })
end

return M
