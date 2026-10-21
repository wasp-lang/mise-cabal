--- Searches Hackage for packages, for `mise search` and shell completion.
--- Documentation: https://mise.jdx.dev/backend-plugin-development.html#backendsearchtools
--- @param ctx BackendSearchToolsCtx
--- @return BackendToolsResult
function PLUGIN:BackendSearchTools(ctx)
    local hackage = require("hackage")
    local index = require("index")

    return { tools = index.search(ctx.query) or hackage.search(ctx.query) }
end
