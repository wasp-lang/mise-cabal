--- Installs a Hackage executable package via `cabal install`.
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendinstall
--- @param ctx BackendInstallCtx
--- @return BackendInstallResult
function PLUGIN:BackendInstall(ctx)
    local cabal = require("cabal")
    local shell = require("shell")

    cabal.call(ctx.install_path, "update") -- A fresh per-tool CABAL_DIR has no package index yet.
    -- cabal prints the build log on stdout, but cmd.exec only reports stderr when
    -- a command fails. Redirect stdout to stderr (same syntax in sh and cmd.exe)
    -- so a failed build shows the compiler errors instead of "see the build log".
    cabal.call(
        ctx.install_path,
        "install " .. shell.var("MISE_CABAL_PACKAGE") .. " 1>&2",
        { MISE_CABAL_PACKAGE = ctx.tool .. "-" .. ctx.version }
    )

    return {}
end
