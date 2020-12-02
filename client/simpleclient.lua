local PATH,IP = ...

IP = IP or "127.0.0.1"

package.path = string.format("%s/client/?.lua;%s/skynet/lualib/?.lua;%s/lualib/?.lua", PATH, PATH, PATH)
package.cpath = string.format("%s/skynet/luaclib/?.so;%s/lsocket/?.so", PATH, PATH)

local socket = require "simplesocket"
local message = require "simplemessage"

message.register(string.format("%s/sproto/%s", PATH, "proto"))

message.peer(IP, 5678)
message.connect()

local index = 1
local name = "alice" .. index
local event = {}

message.bind({}, event)

function event:__error(what, err, req, session)
	print("error", what, err)
end

function event:ping()
	print("ping")
end

function event:signin(req, resp)
	print("signin", req.userid, resp.ok)
	if resp.ok then
		message.request "ping"	-- should error before login
		message.request "login"
	else
		-- signin failed, signup
		message.request("signup", { userid = tostring(name) })
	end
end

function event:signup(req, resp)
	print("signup", resp.ok)
	if resp.ok then
		message.request("signin", { userid = req.userid })
	else
		error "Can't signup"
	end
end

function event:login(_, resp)
	print("login", resp.ok)
	if resp.ok then
		message.request "ping"
        message.request ("say", { userid = tostring(name), words = "hello server" } )
	else
		error "Can't login"
	end
end

function event:push(args)
	print("server push", args.text)
end

function event:notify(args)
    print("server notify", args.words)
    message.request("enter", { userid = "alice" })
end

function event:enter(args)
    print("enter room succ roomid", args.roomid)
    message.request("leave", { userid = tostring(name), roomid = args.roomid })
end 

function event:leave(args)
    print("leave room -=------------")
end 

name = "alice"
message.request("signin", { userid = tostring(name) })

while true do
	message.update()
    print("loop")
end
