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
    -- cabal prints the build log on stdout, but cmd.exec only reports stderr when
    -- a command fails. Redirect stdout to stderr (same syntax in sh and cmd.exe)
    -- so a failed build shows the compiler errors instead of "see the build log".
    cabal.call(
        ctx.install_path,
        "install " .. shell.var("MISE_CABAL_PACKAGE") .. " 1>&2",
        { MISE_CABAL_PACKAGE = package }
    )

    return {}
end
