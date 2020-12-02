local skynet = require "skynet"
local redis = require "redis_class"
local service = require "service"
local log = require "log"
local Table = require "table_op"
local redis_conf = require "redis_config"
local redis_mgr = {}


function redis_mgr.init(conf)
    conf = conf or redis_conf
    log("redis mgr init --------------------conf=%s", Table.toString(conf))
    if conf then
        for db_name, db_conf in pairs(conf) do 
            local db = redis(db_conf)
            if db then 
                log("db_name = %s, db_conf=%s", db_name, db_conf)
                redis_mgr[db_name] = db
            else
                log("init db_name=%s fail", db_name)
            end 
        end 
    end
    log("redis_mgr = %s", Table.toString(redis_mgr))
end 

function redis_mgr.get_redis_by_name(db_name)
    log("redis_mgr get_redis_by_name db_name=%s", db_name)
    if redis_mgr[db_name] then 
        return redis_mgr[db_name]
    end 
    return nil
end

function redis_mgr.set(db_name, key, value)
    return redis_mgr[db_name]:set(key, value)
end 

function redis_mgr.get(db_name, key)
    log("redis_mgr get db_name=%s, key=%s", db_name, key)
    return redis_mgr[db_name]:get(key)
end

service.init {
    command = redis_mgr,
    info = {},
}
