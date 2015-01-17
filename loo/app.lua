local M = {}
package.loaded[...] = M

M.router = require('loo.router')
M.model = require('loo.model')

local _run = function() 
    local controller_module, call, args = M.router.route(ngx.req.get_method(), ngx.var.uri)
    if call == nil then
        return false, 'routing uri "'..ngx.var.uri..'" failed'
    end 
    local ok, controller = pcall(require, controller_module)
    if not ok then
        return false, 'error when loading controller "'..controller_module..'"\n'..controller
    end
    if type(controller[call]) ~= 'function' then
        return false, 'controller function "'..call..'" not found'
    end
    M.model._ctor()
    ok, err = pcall(controller[call], unpack(args))
    M.model._finalize()
    if not ok then
        return false, err
    end
    return true
end

M.error = function(status, message)
    ngx.header['Content-Type'] = 'text/plain'
    ngx.status = status
    ngx.print(message)
end

M.run = function()
    local ok, err = _run()
    if not ok then
        M.error(ngx.HTTP_NOT_FOUND, err)
    end
end

return M
