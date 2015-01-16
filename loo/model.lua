local M = {}
package.loaded[...] = M

local mysql = require('resty.mysql')

M.db = 'mysql'
M.host = '127.0.0.1'
M.port = '3306'
M.database = ''
M.user = 'root'
M.password = ''

local db = nil
local information = {}



M.get = function(model_name)
    if M.db == nil then
        return nil, 'db not set'
    end
    local model = {
        table = model_name
    } 

    if information[model_name] == nil then
        local columns, err = M.query('SELECT * FROM INFORMATION_SCHEMA.COLUMNS\
            WHERE TABLE_SCHEMA = \''..M.database..'\' AND TABLE_NAME = \''..model_name..'\'')
        for i, column in ipairs(columns) do
            if column['COLUMN_KEY'] == 'PRI' then
                model.key = column['COLUMN_NAME']
            end
        end
        model.columns = columns
        information[model_name] = model
    end
    
    model.create = function(self, record) 
        local columns = ''
        local values = ''
        local i = 0
        for name, value in pairs(record) do
            if i == 0 then
                columns = columns..'('
                values = values..'('
            else
                columns = columns..','
                values = values..','
            end
            i = i + 1            
            if type(value) == 'string' then
                columns = columns..name
                values = values..string.format('\'%s\'', value)
            elseif type(value) == 'number' then
                columns = columns..name
                values = values..string.format('%d', value)
            end
        end
        
        local sql = 'INERT INTO '..self.table..columns..') VALUES '..values..')'
        return M.query(sql)
    end

    return information[model_name]
end

M.query = function(query)
    if M.db == nil then
        return nil, 'db not set'
    end
    return db:query(query)
end

M._ctor = function()
    if M.db == nil then
        return
    end
    db = mysql:new()
    local ok, err = db:connect({
        host = M.host,
        port = M.port,
        database = M.database,
        user = M.user,
        password = M.password
    })
    if err then
        ngx.header['Content-Type'] = 'text/plain'
        ngx.status = ngx.HTTP_INTERNAL_SERVER_ERROR
        ngx.print(err)
        ngx.exit(ngx.OK)
    end
end

M._finalize = function() 
    if M.db == nil then
        return
    end
    db:close()
end


return M

