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

local __M = {}

__M.__call = function(M, model_name)
    if M.db == nil then
        return nil, 'db not set'
    end
    local model = {
        table = model_name
    }

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
                values = values..ngx.quote_sql_str(value)
            elseif type(value) == 'number' then
                columns = columns..name
                values = values..string.format('%d', value)
            end
        end
        
        local sql = 'INSERT INTO '..self.table..columns..') VALUES '..values..')'
        return M.query(sql)
    end

    model.delete = function(self, condition)
        local sql = 'DELETE FROM '..self.table..' WHERE '..condition;
        return M.query(sql)
    end

    model.update = function(self, record, condition)
        local i = 0
        local update = ''
        for name, value in pairs(record) do
            if i == 0 then
                update = update..' '
            else
                update = update..','
            end
            i = i + 1
            if type(value) == 'string' then
                update = update..name..'='..ngx.quote_sql_str(value)
            else
                update = update..name..'='..string.format('%d', value)
            end
        end
        local sql = 'UPDATE '..self.table..' SET'..update..' WHERE '..condition
        return M.query(sql)
    end

    return model
end

setmetatable(M, __M)

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

