local skynet = require "skynet"
local mysql = require "skynet.db.mysql"
local mysql_config = require "mysql_config"

local CMD = {}
local pool = {}

local maxconn
local index = 2
local function getconn(sync)
	local db
	if sync then
		db = pool[1]
	else
		db = pool[index]
		assert(db)
		index = index + 1
		if index > maxconn then
			index = 2
		end
	end
	return db
end

function CMD.start()
	maxconn = tonumber(skynet.getenv("mysql_maxconn")) or 10
	assert(maxconn >= 2)
	for i = 1, maxconn do
		local db = mysql.connect(mysql_config)
		if db then
			table.insert(pool, db)
			db:query("set charset utf8")
		else
			skynet.error("mysql connect error")
		end
	end
end

-- sync为false或者nil，sql为读操作，如果sync为true用于数据变动时同步数据到mysql，sql为写操作
-- 写操作取连接池中的第一个连接进行操作
function CMD.execute(sql, sync)
	local db = getconn(sync)
	return db:query(sql)
end

function CMD.stop()
	for _, db in pairs(pool) do
		db:disconnect()
	end
	pool = {}
end

skynet.start(function()
	skynet.dispatch("lua", function(session, source, cmd, ...)
		local f = assert(CMD[cmd], cmd .. "not found")
		skynet.retpack(f(...))
	end)
end)