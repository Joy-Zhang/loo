local modname = ...
local M = {}
_G[modname] = M

M.index = function() 
    ngx.header['Content-Type'] = 'text/plain; utf-8'
    ngx.print('Hello, world')
end




return M
