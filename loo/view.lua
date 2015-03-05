local M = {}
package.loaded[...] = M

M.prefix = 'view.'

local __M = {}

__M.__call = function(M, view_name)
    local ok, template = pcall(require, M.prefix..view_name)
    if not ok then
        return nil, 'view not found'
    end
    local view = {};
    view.template = template;
    view.render = function(self, args)
        local output = ngx.re.gsub(template, '\\{#(.+?)\\}', function(m)
                return args[m[1]]
            end
        )
        ngx.print(output)
    end
    return view
end

setmetatable(M, __M)


return M
