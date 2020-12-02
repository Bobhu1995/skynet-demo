local skynet = require "skynet"
local service = require "service"
local server_common = require "global.server_common"
local Table = require "table_op"
local log = require "log"

local pool = {}
local room_mgr = {}
local rooms = {}
local players = {}
local cur_room_id = 1

function room_mgr.create_room()
    local len = #pool
    log("room_mgr.create_room len = %d", len)
    if len > 0 then
        return table.remove(pool, len)
    end
    log("create_room fail, pool is empty")
    return FAIL
end

function room_mgr.find_free_room()
    log("find_free_room --------")
    local r
    for i = 1, cur_room_id do
        local r = rooms[i]
        if r and r.used == 1 then 
            -- conf
            return r.room, r.room_id
        end
    end
    r = room_mgr.create_room()
    skynet.call(r, "lua", "init", cur_room_id)
    cur_room_id = cur_room_id + 1
    return r, cur_room_id - 1
end



function room_mgr.enter(agent)
    log("room_mgr enter agent.userid=%s", agent.userid)
    local r, room_id = room_mgr.find_free_room()
    rooms[room_id].room = r
    rooms[room_id].room_id = room_id
    if 0 ~= skynet.call(r, "lua", "enter", agent) then
        -- todo fix
    end
    players[agent.userid] = room_id
    table.insert(rooms[room_id].players, agent)
    return r, room_id
end

function room_mgr.leave(agent)
    log("room_mgr leave agent.userid=%s", agent.userid)
    if players[agent.userid] then
        local r = rooms[ players[agent.userid] ]
        if 0 ~= skynet.call(r.room, "lua", "leave", agent) then
            -- todo fix
        end
        players[agent.userid] = nil
        for i, v in pairs(r.players) do
            if v.userid == agent.userid then
                r.players[i] = nil
            end
        end
        return r.room_id
    end    
end

function room_mgr.free_room(room_id)
    rooms[room_id].used = 1
    rooms[room_id].players = {}
end

function room_mgr.init()
    local max_count = server_common.pools_config.room_count or 100
    for i = 1, max_count do
        local info = {
            used = 0,
            players = {},
            status = 0,
            room = 0,
            room_id = 0,
        }
        table.insert(rooms, info)
    end

    skynet.timeout(200, function()
        skynet.fork(function ()
            for i = 1, max_count do
                local room = skynet.newservice "room"
                table.insert(pool, room)
            end
        end)
    end)
end

service.init {
	command = room_mgr,
	info = rooms,
}
