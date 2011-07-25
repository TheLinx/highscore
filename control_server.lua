require("socket")

pcall(dofile, "config.lua")
if not CONFIGURATED then
	print("Run gen_config.lua before this script.")
end

soc = socket.udp()
soc:setpeername("127.0.0.1", BIND_PORT)
soc:settimeout(2)
print("Welcome to the Highscöre server control!")
print("Available commands: save reload quit new_category clear get new")
while true do
	io.write("> ")
	send = io.read("*l")
	if not send then break end
	soc:send(send)
	print(soc:receive())
end
