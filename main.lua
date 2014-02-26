local socket = require("socket")

local args = {...}

realTime = function(s)

    local secs = math.floor(s%60)

    local mins = math.floor(s%3600/60)

    local hours = math.floor(s%(3600*24)/3600)

    local days = math.floor(s%(3600*24*7)/3600/24)

    local weeks = math.floor(s/3600/24/7)

    local ans = ''

    ans = ans .. (weeks>0 and weeks..' weeks, ' or '')
    ans = ans .. (days >0 and days.. ' days, ' or '')
    ans = ans .. (hours>0 and hours..' hours, ' or '')
    ans = ans .. (mins >0 and mins.. ' minutes, ' or '')
    ans = ans .. (secs >0 and secs.. ' seconds, ' or '')

    ans = ans:sub(1, -3)

    return ans
end

dofile(args[1] or "settings.lua")
dofile 'bot.lua'
event = {}
event.next = function(self) table.remove(self, 1) end
event.push =  table.insert
event.clear = function(self) for i in ipairs(self) do self[i] = nil end end

--[[
remind = {}
remind.add = function(self, osTime, message, target)
    if not self[osTime] then
        self[osTime] = {}
    end
    table.insert(self[osTime], {message, target})
end--]]

cron = {}
cron.add = function(time, func)

    cron[time] = cron[time] or {}

    print(time)
    
    table.insert(cron[time], func)

end

ls = function(path)

    local f = io.popen('ls '..path, 'r')                                                                                            
    local files = {}                                                                                     
    for file in f:lines() do                                                                                                        
        if not (file:match'.+%.lua$' or file:match '.+%.txt' or file == 'bac') then                                                 
            table.insert(files, file)                                                                                               
        end                                                                                                                         
    end                                                                                                                             
    f:close()

    return files
end

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
    if not bot.startup then
        dofile("startup.lua")
    else
        bot.startup()
    end
	irc:settimeout(0.1)

    bot.onLoad:fire()

	update()

end

update = function()
    
    local t, ot = 0, 6/0
	while true do
        t = os.time()
        if love and love.event then
        	love.event.pump()
        	for e in love.event.poll() do
        		if e == "quit" then
        			os.exit()
        		end
        	end
        end
		if event[1] then
			success, err = pcall(event[1].func, t, ot, event[1])
            if not success then
                sendNotice("Error in event: "..err, event[1].sender)
            end
			event:next()
		end


        for rt = ot+1, t do

            if cron[rt] then
                print(rt, "ok")
                for i, v in ipairs(cron[rt]) do
                    v()
                end
            end
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
