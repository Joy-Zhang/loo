local M = {}
package.loaded[...] = M

local routing_table = {}

M.add = function(http_method, uri_pattern, controller, call) 
    local pattern = ngx.re.gsub(uri_pattern, ':([A-Z0-9a-z-_]*)', '(?<$1>.*?)')
    table.insert(routing_table, {
        pattern = {
            uri = '^'..pattern..'$',
            method = http_method
        },
        execution = {
            controller = controller,
            call = call
        }
    });
end

M.simple = true
M.controller_prefix = 'controller.'

M.route = function(http_method, uri)
    for i, rule in ipairs(routing_table) do
        
        if http_method == rule.pattern.method then
            local m = ngx.re.match(uri, rule.pattern.uri)
            if m then
                local args = {}
                for k in ipairs(m) do
                    table.insert(args, m[k])
                end
                return M.controller_prefix..rule.execution.controller, rule.execution.call, args
            end
        end
    end
    if M.simple then
        local controller = ''
        local call = nil
        for part in string.gmatch(uri, '/(%w+)') do
            call = part
            controller = controller..'.'..call
        end
        if call then
            return M.controller_prefix..string.sub(controller, 2, string.len(controller) - string.len(call) - 1), call, {}
        end
    end
end

return M
