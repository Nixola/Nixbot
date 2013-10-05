local socket = require("socket")
require 'settings'
require 'bot'


print("LoveBot IRC BOT is running!")

load = function()

	irc = socket.tcp()

	uname = "Nicola"
	nick = "Nixbot"
	address = "irc.oftc.net"
	port = 6667
	channel = "#nixtests"

	local ok = irc:connect(address,port)

	if ok == 1 then
		print("Connected to the network!")
	else
		print("Couldn't connect!")
	end

	irc:send("NICK "..nick.."\r\n")
	irc:send("USER "..uname.." 8 * :"..uname.."\r\n")
	irc:send("JOIN "..channel.."\r\n")
	irc:settimeout(0)

	update()

end

update = function()

	while true do
		local line, err = irc:receive("*l")
		if line then
			process(line)
		elseif quit then
			irc:close()
			return
		elseif reload then
			irc:close()
			reload = nil
			print "Reloading sequence initialized."
			dofile 'main.lua'
		end

	end

end

load()
