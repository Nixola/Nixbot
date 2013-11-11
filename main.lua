local socket = require("socket")
dofile 'settings.lua'
dofile 'bot.lua'


print("LoveBot IRC BOT is running!")

load = function()

	irc = socket.tcp()

	local ok = irc:connect(bot.address,bot.port)

	if ok == 1 then
		print("Connected to the network!")
	else
		print("Couldn't connect!")
	end

	irc:send("NICK "..bot.nick.."\r\n")
	irc:send("USER "..bot.uname.." 8 * :"..bot.uname.."\r\n")
	irc:send("JOIN "..bot.channel.."\r\n")
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
