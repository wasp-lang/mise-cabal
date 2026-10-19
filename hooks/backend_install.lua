--- Installs a Hackage executable package via `cabal install`.
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendinstall
--- @param ctx BackendInstallCtx
--- @return BackendInstallResult
function PLUGIN:BackendInstall(ctx)
    local cabal = require("cabal")
    local log = require("log")

    -- Both values are spliced into a shell command, so reject anything that is
    -- not a well-formed package name or version before running cabal.
    cabal.check_package_name(ctx.tool)
    if not cabal.is_version(ctx.version) then
        error("mise-cabal: '" .. tostring(ctx.version) .. "' is not a valid Cabal version")
    end
    local package = ctx.tool .. "-" .. ctx.version

    log.info("Updating the Hackage package index")
    cabal.call(ctx.install_path, "update") -- A fresh per-tool CABAL_DIR has no package index yet.

    log.info("Building " .. package .. " from source, this can take a while")
    cabal.call(ctx.install_path, "install " .. package)

    return {}
end
