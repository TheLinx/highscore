print("Let's generate a configuration file for Highscöre.")

cfg_file, err = io.open("config.lua", "w")
if not cfg_file then
	print("We can't access config.lua! Error: " .. err)
	print("This is a fatal error.")
	os.exit(1)
end

print("What IP do you want to bind to? Use * to bind to all interfaces.")
repeat
	io.write("> ")
	BIND_IP = io.read("*l")
until BIND_IP and #BIND_IP > 0

print("What port do you want to bind to?")
repeat
	io.write("> ")
	BIND_PORT = io.read("*l")
until tonumber(BIND_PORT)

print("What kind of storage do you want to use? (Choices are lstate)")
repeat
	io.write("> ")
	STORAGE_TYPE = io.read("*l")
	if type(STORAGE_TYPE) == "string" then
		STORAGE_TYPE = STORAGE_TYPE:lower()
	end
until STORAGE_TYPE == "lstate"

if STORAGE_TYPE == "lstate" then
	print("What name do you want to use for the lstate save file?")
	repeat
		io.write("> ")
		STORAGE_NAME = io.read("*l")
	until STORAGE_NAME and #STORAGE_NAME > 0
end

for k, v in pairs(_G) do
	if k:sub(1,1) ~= "_" and k:upper() == k then
		cfg_file:write(("%s = %q\n"):format(k, v))
	end
end
cfg_file:write("CONFIGURATED = true")

cfg_file:close()
