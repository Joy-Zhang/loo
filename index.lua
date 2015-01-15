local router = require('loo.router')

--开启简单路由，当搜索路由表失败时，路由器会尝试根据url结构对应控制器模块
router.simple = true

--添加默认路由
router.add('GET', '/', 'index', 'index')
router.add('GET', '/index', 'index', 'index')

local controller_module, call = router.route(ngx.req.get_method(), ngx.var.uri)
if call then
    local controller = require(controller_module)
    controller[call]()
else
    ngx.exit(ngx.HTTP_NOT_FOUND)
end

