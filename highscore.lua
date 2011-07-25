-- this is a client library
require("socket")

local udp = socket.udp
local error, tonumber = error, tonumber
module("highscore")
local soc = udp()
local ip = ""
local port = "" -- fill these in when you distribute your game
soc:setpeername(ip, port)
soc:settimeout(3)

function new(score, name, category)
	soc:send(("new %d %s %s"):format(score, category, name))
	ret, err = soc:receive()
	if not ret then
		return nil, err
	end
	if ret == "ok" then return true end
	error(ret)
end

function get(category, amount, start)
	start = start or 1
	soc:send(("get %d %d %s"):format(amount, start, category))
	ret, err = soc:receive()
	if not ret then
		return nil, err
	end
	if ret == "no results" then return {} end
	if tonumber(ret:sub(1, 1)) then
		local t = {}
		for score in ret:gmatch("([^\n]+)") do
			t[#t+1] = {score:match("(%d+) (%d+) (.+)")}
		end
		return t
	end
	error(ret)
end
