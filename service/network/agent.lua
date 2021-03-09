local skynet = require "skynet"
local service = require "service"
local client = require "client"
local log = require "log"
local Table = require "table_op"
local json = require "json"

local room_mgr
local manager

local agent = {}
local data = {}
local cli = client.handler()

function cli:ping()
	assert(self.login)
	log "ping"
end

function cli:say(args)
    assert(self.login)
    if not data.fd then
        log("say fail %s fd=%s", data.userid, self.fd)
        return { ok = false, words = ""  }
    end
    log("say = %s userid = %s", args.words, args.userid)
    client.notify(self, "notify", { words = "receive" })
    return { ok = true  }
end

function cli:create(args)
	assert(self.login)
	if not data.fd then
		log("create fail %s fd=%s", data.userid, self.fd)
        return { ok = false, val = {}  }
	end
	log("create --------- person = %s", Table.toString(args))
	log("creat - ------ json=%s", json.encode(args))
	return { ok = true, val = { args } }
end

function cli:login()
	log("agent login------")
    assert(not self.login)
	if data.fd then
		log("login fail %s fd=%d", data.userid, self.fd)
		return { ok = false }
	end
    agent.userid = data.userid
	data.fd = self.fd
	self.login = true
	log("login succ %s fd=%d", data.userid, self.fd)
	client.push(self, "push", { text = "welcome" })	-- push message to client
	return { ok = true }
end

function cli:enter(args)
    assert(self.login)
    if not data.fd then
        log("say fail %s fd=%s", data.userid, self.fd)
        return { ok = false, roomid = -1  }
    end
    local room, room_id = skynet.call(room_mgr, "lua", "enter", {userid = data.userid})
    data.room = room
    data.room_id = room_id
    log("agent  ---------- room =%s, room_id=%s", room, room_id)
    --room:say()
    skynet.call(room, "lua", "say")
    return { ok = true, roomid = room_id }
end 

function cli:leave(args)
    assert(self.login)
    if not data.fd then
        log("say fail %s fd=%s", data.userid, self.fd)
        return { ok = false }
    end
    local room_id = skynet.call(room_mgr, "lua", "leave", {userid = data.userid})
    log("agent cli leave roomid = %s", room_id)
    data.room = nil
    data.room_id = nil
    return { ok = true }
end

local function new_user(fd)
	log("agent new user fd=%d", fd)
    local ok, error = pcall(client.dispatch , { fd = fd })
	log("fd=%d is gone. ok=%s error = %s", fd, ok, error)
	client.close(fd)
    if data.fd == fd then
		data.fd = nil
		skynet.sleep(1000)	-- exit after 10s
		if data.fd == nil then
			-- double check
			if not data.exit then
				-- data.exit = true	-- mark exit
				skynet.call(manager, "lua", "exit", data.userid)	-- report exit
				log("user %s afk", data.userid)
				-- skynet.exit()
			end
		end
	end
end

function agent.assign(fd, userid)
	skynet.error("agent assign fd userid", fd, userid)
    if data.exit then
		return false
	end
	if data.userid == nil then
		data.userid = userid
	end
    assert(data.userid == userid)
	skynet.fork(new_user, fd)
	return true
end

function agent.init()
	room_mgr = skynet.uniqueservice "room_mgr"
	manager = skynet.uniqueservice "manager"
end

service.init {
	command = agent,
	info = data,
	init = client.init "proto",
	initself = agent.init,
}

