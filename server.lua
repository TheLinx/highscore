require("socket")

pcall(dofile, "config.lua")
if not CONFIGURATED then
	print("Run gen_config.lua before this script.")
end


if STORAGE_TYPE == "lstate" then
	local state = require("state")
	local scores
	local asc_sort = function(a, b) return a[1] < b[1] end
	local desc_sort = function(a, b) return a[1] > b[1] end
	function save_scores()
		state.store(STORAGE_NAME, scores)
	end
	function load_scores()
		scores = state.load(STORAGE_NAME) or {}
	end
	function get_scores(category, amount, start)
		if not scores[category] then return "invalid category" end
		local t, tn = {}, 1
		for n = start, start + amount do if scores[category][n] then
			t[tn] = ("%d %d %s"):format(n, unpack(scores[category][n]))
			tn = tn + 1
		end end
		return #t > 0 and table.concat(t, "\n") or "no scores"
	end
	function register(category, name, score)
		if not scores[category] then return "invalid category" end
		table.insert(scores[category], {tonumber(score), name})
		table.sort(scores[category], scores[category].type == "asc" and asc_sort or desc_sort)
		return "ok"
	end
	function new_category(name, ascending)
		scores[name] = {type = (tonumber(ascending) == 1 and "asc" or "desc")}
		return "ok"
	end
	function clear_scores(category)
		if category then
			if not scores[category] then return "invalid category" end
			scores[category] = {type = scores[category].type}
		else
			for key, _ in pairs(scores) do
				scores[key] = {type = scores[key].type}
			end
		end
		return "ok"
	end
end

load_scores()
soc = socket.udp()
soc:setsockname(BIND_IP, BIND_PORT)
while true do
	local data, ip, port = soc:receivefrom()
	data = data:gsub("\n", "")
	print(("[%s:%s] %s"):format(ip, port, data))
	local cmd, arguments = data:match("([^ ]+) (.+)")
	if not cmd then cmd, arguments = data, "" end
	local err = nil
	if cmd == "save" then if ip ~= "127.0.0.1" then err = "unauthorised" else
		save_scores()
		soc:sendto("ok", ip, port)
	end elseif cmd == "reload" then if ip ~= "127.0.0.1" then err = "unauthorised" else
		load_scores()
		soc:sendto("ok", ip, port)
	end elseif cmd == "quit" then if ip ~= "127.0.0.1" then err = "unauthorised" else
		soc:sendto("ok", ip, port)
		break
	end elseif cmd == "new_category" then if ip ~= "127.0.0.1" then err = "unauthorised" else
		local ascending, name = arguments:match("(%d) (.+)")
		if ascending and name then
			soc:sendto(new_category(name, ascending), ip, port)
		else err = "badly formatted command" end
	end elseif cmd == "clear" then if ip ~= "127.0.0.1" then err = "unauthorised" else
		soc:sendto(clear_scores(arguments), ip, port)
	end elseif cmd == "get" then
		local amount, start, category = arguments:match("(%d+) (%d+) (.+)")
		if amount and start and category then
			soc:sendto(get_scores(category, amount, start), ip, port)
		else err = "badly formatted command" end
	elseif cmd == "new" then
		local score, category, name = arguments:match("(%d+) ([^ ]+) (.+)")
		if score and category and name then
			soc:sendto(register(category, name, score), ip, port)
		else err = "badly formatted command" end
	else
		err = "unrecognised command"
	end
	if err then
		soc:sendto(err, ip, port)
	end
end

save_scores()
return 0
