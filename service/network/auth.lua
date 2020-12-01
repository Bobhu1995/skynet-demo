local skynet = require "skynet"
local service = require "service"
local client = require "client"
local log = require "log"
local Table = require "table_op"

local auth = {}
local users = {}
local cli = client.handler()
local redis_mgr

local SUCC = { ok = true }
local FAIL = { ok = false }

function cli:signup(args)
	log("signup userid = %s", args.userid)
	if users[args.userid] then
		return FAIL
	else
		users[args.userid] = true
        local result = skynet.call(redis_mgr, "lua", "set", "auth", args.userid, "SUCC")
        if result == "OK" then 
		    return SUCC
        else
            users[args.userid] = nil
            return FAIL
        end 
	end
end

function cli:signin(args)
	log("signin userid = %s", args.userid)
	if users[args.userid] then
		self.userid = args.userid
		self.exit = true
		return SUCC
	else
        local result = skynet.call(redis_mgr, "lua", "get", "auth", args.userid)
	    if result then
            self.userid = args.userid 
            self.exit = true
            return SUCC
        else 
            return FAIL 
        end 
	end
end

function cli:ping()
	log("ping")
end

function auth.shakehand(fd)
	local c = client.dispatch { fd = fd }
	return c.userid
end

function auth.init()
    redis_mgr = skynet.uniqueservice "redis_mgr"
end

service.init {
	command = auth,
	info = users,
	init = client.init "proto",
    initself = auth.init,
}
