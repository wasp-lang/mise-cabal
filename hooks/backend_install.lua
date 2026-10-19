--- Installs a Hackage executable package via `cabal install`.
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendinstall
--- @param ctx BackendInstallCtx
--- @return BackendInstallResult
function PLUGIN:BackendInstall(ctx)
    local cabal = require("cabal")
    local log = require("log")
    local shell = require("shell")
    local package = ctx.tool .. "-" .. ctx.version

    log.info("Updating the Hackage package index")
    cabal.call(ctx.install_path, "update") -- A fresh per-tool CABAL_DIR has no package index yet.

    log.info("Building " .. package .. " from source, this can take a while")
    cabal.call(ctx.install_path, "install " .. shell.var("MISE_CABAL_PACKAGE"), { MISE_CABAL_PACKAGE = package })

    return {}
end
