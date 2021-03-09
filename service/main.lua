local skynet = require "skynet"

skynet.start(function()
	skynet.error("Server start")
	if not skynet.getenv "daemon" then
		local console = skynet.newservice("console")
	end
	skynet.newservice("debug_console",8000)
    
     local redis_pool = skynet.uniqueservice "redis_pool"
     skynet.call(redis_pool, "lua", "start")
     -- local a = { name = "alice", id = 100001, email = "aaa@163.com", level = 0 }
     -- skynet.call(redis_pool, "lua", "hmset", 1, "person", a)

     local mysql_pool = skynet.uniqueservice "mysql_pool"
     skynet.call(mysql_pool, "lua", "start")
     -- skynet.call(mysql_pool, "lua", "execute", "insert into user(uid, name) values (2, 'cxq');", "true")

    local proto = skynet.uniqueservice "protoloader"
    skynet.error("call proto lua load")
	skynet.call(proto, "lua", "load", {
		"proto.c2s",
		"proto.s2c",
	})
    -- 初始化全局db管理
    local redis_mgr = skynet.uniqueservice "redis_mgr"
    skynet.call(redis_mgr, "lua", "init")
    -- 初始化全局房间管理
    local room_mgr = skynet.uniqueservice "room_mgr"  
    skynet.call(room_mgr, "lua", "init")

	local hub = skynet.uniqueservice "hub"
    skynet.error("after hub")
	skynet.call(hub, "lua", "open", "0.0.0.0", 5678)
    
    
    --skynet.error("bobhu-------------", hot:set("C", "bobhu"))
    --skynet.error("bobhu-------------", hot:get("C"))
    
    --local redis_mgr2 = skynet.newservice("redis_mgr2")
    --skynet.call(redis_mgr2, "lua", "start")
    --local hot = skynet.call(redis_mgr2, "lua", "set", "hot", "C", "bobhu")
    --local hot2 = skynet.call(redis_mgr2, "lua", "get", "hot", "C")
    --skynet.error("hot --------", hot, hot2)
    --local conf = {
      --host = "127.0.0.1" ,
        --port = 6379 ,
        --db = 0
    --}
    --local redis2 = RedisMq(conf)
    --redis2:test()
	skynet.exit()
end)
