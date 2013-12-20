local socket = require("socket")
dofile 'settings.lua'
dofile 'bot.lua'
event = {}
event.next = function(self) table.remove(self, 1) end
event.push =  table.insert
event.clear = function(self) for i in ipairs(self) do self[i] = nil end end


bot.print("LoveBot IRC BOT is running!")

load = function()

	irc = socket.tcp()

	local ok = irc:connect(bot.address,bot.port)

	if ok == 1 then
		bot.print("Connected to the network!")
	else
		bot.print("Couldn't connect!")
	end

	irc:send("NICK "..bot.nick.."\r\n")
	irc:send("USER "..bot.uname.." 8 * :"..bot.uname.."\r\n")
	irc:send("JOIN "..bot.channel.."\r\n")
	irc:settimeout(1)

	update()

end

update = function()
    
    local t, ot
	while true do
        t = os.time()
		if event[1] then 
			success, err = pcall(event[1].func, t, ot, event[1])
            if not success then
                sendNotice("Error in event: "..err, event[1].sender)
            end
			event:next()
		end
		local line, err = irc:receive("*l")
		if line then
			process(line)
		elseif quit then
			irc:close()
			return
		elseif reload then
			irc:close()
			reload = nil
			bot.print "Reloading sequence initialized."
			dofile 'main.lua'
		end
        ot = t
	end

end

load()
