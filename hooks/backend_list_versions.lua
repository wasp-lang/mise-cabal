--- Lists available Hackage versions for a package (ascending order).
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendlistversions
--- @param ctx BackendListVersionsCtx
--- @return BackendListVersionsResult
function PLUGIN:BackendListVersions(ctx)
    local cabal = require("cabal")
    local hackage = require("hackage")
    local index = require("index")

    local tool = ctx.tool
    if not tool or tool == "" then
        error("mise-cabal: package name cannot be empty")
    end

    -- The local index dates each version, for `minimum_release_age` and
    -- `ls-remote --before`. Without it, fall back to the undated Hackage API.
    local versions = index.versions(tool) or hackage.versions(tool)

    if #versions == 0 then
        error("mise-cabal: package '" .. tool .. "' not found on Hackage")
    end

    -- Sort ascending (oldest -> newest), as mise expects. We use our own Cabal
    -- version comparison because the built-in semver.sort assumes 3-component
    -- versions and mis-orders Cabal's 1-to-4-component (PVP) versions.
    return { versions = cabal.sort_versions(versions) }
end
