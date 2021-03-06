local M = {}
package.loaded[...] = M

M.router = require('loo.router')
M.model = require('loo.model')

M.execute = function(uri) 
    local controller_module, call, args = M.router.route(ngx.req.get_method(), uri)
    if call == nil then
        return false, 'routing uri "'..uri..'" failed'
    end 
    local ok, controller = pcall(require, controller_module)
    if not ok then
        return false, 'error when loading controller "'..controller_module..'"\n'..controller
    end
    if type(controller[call]) ~= 'function' then
        return false, 'controller function "'..call..'" not found'
    end
    ok, err = pcall(controller[call], unpack(args))
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
    M.model._ctor()
    local ok, err = M.execute(ngx.var.uri)
    M.model._finalize()
    if not ok then
        M.error(ngx.HTTP_NOT_FOUND, err)
    end
end

return M
