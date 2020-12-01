local skynet = require "skynet"
local service = require "service"
local log = require "log"
local Table = require "table_op"
local server_common = require "global.server_common"

local MAX_AGENT_COUNT = 100

local SUCC = server_common.succ
local FAIL = server_common.fail

local manager = {}
local users = {}
-- 对象池
local pool = {}


local function new_agent()
	local len = #pool
	log("new_agent len=%d", len)
	if len > 0 then
		return table.remove(pool, len)
	end
	log("new_agent fail, pool is empty")
	return FAIL
end

local function free_agent(agent)	
	table.insert(pool, agent)
	log("after free agent len =%d", #pool)
	-- skynet.kill(agent)
end

function manager.assign(fd, userid)
    skynet.error("manager assign fd userid", fd, userid)
	local agent
	repeat
		agent = users[userid]
		if not agent then
			agent = new_agent()
			log("after new_agent len=%d", #pool)
			if not users[userid] then
				-- double check
				users[userid] = agent
			else
				free_agent(agent)
				agent = users[userid]
			end
		end
	until skynet.call(agent, "lua", "assign", fd, userid)
	log("Assign %d to %s [%s]", fd, userid, agent)
end

function manager.exit(userid)
	log("manager userid = %s exit", userid)
	free_agent(users[userid])
    users[userid] = nil
    log("manager exit userid = %s", Table.toString(users))
end

function manager.init()
	MAX_AGENT_COUNT = server_common.pools_config.agent_count or 100
	pool = {}
	skynet.timeout(300, function ()
		skynet.fork(function ()
			for i = 1, MAX_AGENT_COUNT do
				local agent = skynet.newservice "agent"
				table.insert(pool, agent)
			end
		end)
	end)
	log("manager init ------ MAX_AGENT_COUNT=%s, pool=%d", MAX_AGENT_COUNT, #pool)
end

service.init {
	command = manager,
	info = users,
	initself = manager.init,
}


