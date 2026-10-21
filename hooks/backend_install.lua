--- Installs a Hackage executable package via `cabal install`.
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendinstall
--- @param ctx BackendInstallCtx
--- @return BackendInstallResult
function PLUGIN:BackendInstall(ctx)
    local cabal = require("cabal")
    local index = require("index")
    local log = require("log")
    local shell = require("shell")
    local package = ctx.tool .. "-" .. ctx.version

    -- Read the package index and download sources through the shared cache, so
    -- each install skips re-downloading the index. Builds and binaries still go
    -- in the tool's own CABAL_DIR, and do not need the cache once installed.
    -- Without a shared index, give this CABAL_DIR its own.
    log.info("Updating the Hackage package index")
    local args = "install "
    local env = { MISE_CABAL_PACKAGE = package }
    local shared = index.update()
    if shared ~= nil then
        args = "--remote-repo-cache=" .. shell.var("MISE_CABAL_REPO_CACHE") .. " " .. args
        env.MISE_CABAL_REPO_CACHE = shared.repo_cache
    else
        cabal.call(ctx.install_path, "update")
    end

    log.info("Building " .. package .. " from source, this can take a while")
    -- cabal prints the build log on stdout, but cmd.exec only reports stderr when
    -- a command fails. Redirect stdout to stderr (same syntax in sh and cmd.exe)
    -- so a failed build shows the compiler errors instead of "see the build log".
    cabal.call(ctx.install_path, args .. shell.var("MISE_CABAL_PACKAGE") .. " 1>&2", env)

    return {}
end
