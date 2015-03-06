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
    
    view.type_error = function(path, type_got)
        return 'ERR('..path..','..type_got..')'
    end
        
    view.render = function(self, args)
        
        local evaluate = function(context, path)        
            local value = context
            ngx.re.gsub(path, '([^\\.]+)', function(part)
                    value = value[part[1]]
                    return part[0]
                end
            )
            return value
        end
        
        local origin_render = render
        
        render = function(template, context)
            local output = ''
            
            local template_pattern = '(\\{!(.+?)#(.+?)#(.+?)\\})|(\\{\\$\\})|(\\{#(.+?)\\})'
            
            local start = 1
            
            while(start < string.len(template)) do
                
                local from, to = ngx.re.find(string.sub(template, start), template_pattern)
                if from == nil then 
                    output = output..string.sub(template, start)
                    start = string.len(template)
                else
                    output = output..string.sub(template, start, start + from - 2)
                    
                    
                    local expression = string.sub(template, start + from - 1, start + to - 1)
                    local match = ngx.re.match(expression, template_pattern)
                    start = start + to
                    
                    if match[6] ~= nil then
                        local value = evaluate(context, match[7])
                        if type(value) ~= 'string' then
                            output = output..self.type_error(match[7], type(value))
                        else
                            output = output..value
                        end
                        
                    elseif match[1] ~= nil then
                        local skip = 0
                        local inner_output = nil
                        
                        local origin_k = context[match[3]]
                        local origin_v = context[match[4]]
                        
                        for k, v in pairs(evaluate(context, match[2])) do
                            context[match[3]] = k
                            context[match[4]] = v
                            inner_output, skip = render(string.sub(template, start), context)
                            output = output..inner_output
                        end
                        
                        context[match[3]] = origin_k
                        context[match[4]] = origin_v
                        
                        start = start + skip
                        
                    elseif match[5] ~= nil then
                        return output, start
                        
                    else
                        output = output..match[0]
                        
                    end
                    
                end
                
            end
            return output, start
        end
        
        local output = render(self.template, args)
        
        ngx.print(output)
        render = origin_render
    end
    return view
end

setmetatable(M, __M)


return M
