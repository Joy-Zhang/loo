local app = require('loo.app')

--开启简单路由，当搜索路由表失败时，路由器会尝试根据url结构对应控制器模块
app.router.simple = true

--添加默认路由
app.router.add('GET', '/', 'index', 'index')
app.router.add('GET', '/index', 'index', 'index')
app.router.add('GET', '/index/:type/:id', 'index', 'test')

app.run()
