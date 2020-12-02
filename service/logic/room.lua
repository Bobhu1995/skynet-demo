local skynet = require "skynet"
local service = require "service"
local seat = require "seat"
local Table = require "table_op"
local log = require "log"

local room = {}
local CMD = {}

function CMD.init(room_id)
    log("room init ---------------")
    room.room_conf = {}
    --room.client = {}
    room.seats = {}
    room.room_id = room_id
    room.max_seat_id = 0
    room.used = 1
    room.play_count = 0   

    room.room_mgr = skynet.uniqueservice "room_mgr"
end

function CMD.reuse(room_conf)
    log("room init ---------------")
    room.room_conf = room_conf
    --room.client = {}
    room.seats = {}
    room.room_id = room_id
    room.max_seat_id = 0
    room.used = 1
end

function CMD.enter(agent)
    log("room enter -------------------- ")
    room.max_seat_id = room.max_seat_id + 1
    local s = seat(agent, room.max_seat_id, nil)
    s:sitdown()
    table.insert(room.seats, s)
    room.play_count = room.play_count + 1
    return 0
end

function CMD.leave(agent)
    log("room leave -------------------- userid=%s", agent.userid)
    for i = 1, room.max_seat_id do
        local s = room.seats[i]
        if s.userid == agent.userid then 
            s:standup()
            room.seats[i] = nil
            room.play_count = room.play_count - 1
            if room.play_count == 0 then
                CMD.destory()
            end
            return room.room_id
        end
    end
    return -1
end

function CMD.destory()
    log("destory room-------------")
    room.used = 0
    skynet.call(room.room_mgr, "lua", "free_room", room.room_id)
end

function CMD.say()
    log("room say -------------- room_id=%s", room.room_id)
end

service.init {
    command = CMD,
    info = room,
}
