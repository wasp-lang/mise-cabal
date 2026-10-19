--- Installs a Hackage executable package via `cabal install`.
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendinstall
--- @param ctx BackendInstallCtx
--- @return BackendInstallResult
function PLUGIN:BackendInstall(ctx)
    local cabal = require("cabal")

    -- Both values are spliced into a shell command, so reject anything that is
    -- not a well-formed package name or version before running cabal.
    cabal.check_package_name(ctx.tool)
    if not cabal.is_version(ctx.version) then
        error("mise-cabal: '" .. tostring(ctx.version) .. "' is not a valid Cabal version")
    end

    cabal.call(ctx.install_path, "update") -- A fresh per-tool CABAL_DIR has no package index yet.
    cabal.call(ctx.install_path, "install " .. ctx.tool .. "-" .. ctx.version)

    return {}
end
