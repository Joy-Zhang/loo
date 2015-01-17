local app = require('loo.app')

--Enable the simple router. The router will route the url path to controller
--开启简单路由，当搜索路由表失败时，路由器会尝试根据url结构对应控制器模块
app.router.simple = true

--The controller_prefix will be added after routing as controller module name 
--将控制器的前缀设为conrtoller.，即所有控制器都在controller目录下
app.router.controller_prefix = 'controller.'

--Add the routing rule manually
--手动添加路由
--app.router.add('GET', '/', 'index', 'index')

--Configure mysql
--mysql数据库配置

--The mysql is disabled as default. Set this to 'mysql' to enable it
--默认不使用数据库，使用时请将app.model.db设为'mysql'
app.model.db = nil

--Connection configuration for mysql
--mysql数据库的连接信息 
app.model.host = '127.0.0.1'
app.model.user = 'root'
app.model.password = 'root'
app.model.database = 'loo'

--Execute
--执行
app.run()
