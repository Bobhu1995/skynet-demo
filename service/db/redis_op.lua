local skynet = require "skynet"
local redis = require "redis"
local class = require "class"
local service = require "service"
local Redis = {
    db = "",

}


function Redis.init(conf)
    
    local conf = {
        host = "127.0.0.1" ,
	    port = 6379 ,
	    db = 0
    }
     local db = redis.connect(conf)
     if db then
        Redis.db = db
     end 
end

function Redis:test()
    skynet.error("redis test")
     Redis.db:set("A", "hello")
     Redis.db:set("B", "world")
     Redis.db:sadd("C", "one")

    print( Redis.db:get("A"))
    print( Redis.db:get("B"))
end

service.init {
    command = Redis,
    info = {}
}
