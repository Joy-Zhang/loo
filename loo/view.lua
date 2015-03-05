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
        local output = ngx.re.gsub(template, '\\{#(.+?)\\}', function(path)
                local value = args
                ngx.re.gsub(path[1], '([^\\.]+)', function(part)
                        value = value[part[1]]
                        return part[0]
                    end
                )
                if type(value) ~= 'string' then
                    return type(value)..'(string only)'
                else
                    return value
                end
            end
        )
        ngx.print(output)
    end
    return view
end

setmetatable(M, __M)


return M
