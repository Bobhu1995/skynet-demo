local skynet = require "skynet"
local class = require "class"
local Table = require "table_op"
local log = require "log"

local seat = class()

function seat:_init(agent, seat_id, seat_conf)
    self.seat_id = seat_id
    self.client = agent
    self.userid = agent.userid
    self.conf = seat_conf
end

function seat:sitdown()
    log("seat sitdown ok")
    return 0
end

function seat:standup()
    log("seat standuo ok")
    self.seat_id = -1
    self.client = nil
    self.conf = nil
    return 0
end 
return seat
