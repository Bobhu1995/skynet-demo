local skynet = require "skynet"
local redis = require "skynet.db.redis"
local class = require "class"
local Table = require "table_op"

local Redis = class()
                     
function Redis:_init(conf)
    self._db_conf = conf 
    self._db = redis.connect(conf)
end                               
   

function Redis:get(key)
    return self._db:get(key)
end

function Redis:set(key, value)
    return self._db:set(key, value)
end

function Redis:hset(key, field, value)
    return self._db:hset(key, field, value)
end

function Redis:hget(key, field)
    return self._db:hget(key, field)
end

function Redis:hgetall(key)
    local tmp = self._db:hgetall(key)
    local result = {}
    for i, v in ipairs(tmp) do 
       if i % 2 == 0 then 
            result[tmp[i - 1]] = tmp[i]
       end
    end 
    return result
end 

function Redis:test()
    skynet.error("redis test")
    skynet.error("1", self:set("A", "hello"))
    skynet.error("2", self:set("B", "world"))
    skynet.error("3", self:hset("player", "uin", "111"))
    skynet.error("3", self:hset("player", "uid", "222"))
    
    skynet.error( self:get("A"))
    skynet.error( self:get("B"))    
    skynet.error( self:hget("player", "uin"))    
    skynet.error( self:hget("player", "uid"))

    local x = self:hgetall("player")
    skynet.error("xxxxxxxx=", Table.toString(x))

end                              
       
return Redis
