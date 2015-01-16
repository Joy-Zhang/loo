local modname = ...
local M = {}
_G[modname] = M

M.router = require('loo.router')

M.run = function()
    local controller_module, call, args = M.router.route(ngx.req.get_method(), ngx.var.uri)
    if call then
        local controller = require(controller_module)
        controller[call](unpack(args))
    else
        ngx.exit(ngx.HTTP_NOT_FOUND)
end


end

return M
