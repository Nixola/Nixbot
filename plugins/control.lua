bot.commands:register("reload", function(_, source)
    if masters[source:lower()] then
        dofile 'bot.lua'
        sendNotice("bot.lua reloaded, master.", source)
    else
        sendNotice("Nope.", source)
    end
    return true
end)

bot.commands:register("reboot", function(_, source)
    if masters[source:lower()] then
        irc:send ": QUIT :Rebooting\r\n"
        reload = true
    else
        sendNotice("Do you think you can just tell me to reboot?", source)
    end
    return true
end)

bot.commands:register("quit", function(_, source)
    if masters[source:lower()] then
        irc:send ": QUIT :Obeying my master\r\n"
        quit = true
    else
        sendNotice("Do you think you can just tell me to quit?", source)
    end
    return true
end)

bot.commands:register("lock", function(_, source)
    if masters[source:lower()] then
        if settings.Master then
            sendNotice("I'm already obeying you and you only, my master.", source)
        else
            sendNotice("From now hence, I will only obey you, my master.", source)
            settings.Master = true
        end
    else
        sendNotice("You're not my master! You won't control me!", source)
    end
    return true
end)

bot.commands:register("free", function(_, source)
    if not settings.Master then return end
    sendNotice("As you wish, my master. I will listen to everyone now.", source)
    settings.Master = false
    return true
end)

bot.commands:register("obey", function(nick, source)
    nick = nick or ''
    nick = nick:lower()
    if masters[source:lower()] then
        if nick:find ' ' then
            sendNotice("Invalid nickname. Please, master, provide a valid one.", source)
            return true
        end
        masters[nick] = 1
        sendNotice("I will obey "..nick.." now.", source)
    else
        sendNotice("You're not my master! You won't control me!", source)
    end
    return true
end)

bot.commands:register("disobey", function(nick, source)
    nick = nick or ''
    nick = nick:lower()
    if masters[source:lower()] == 0 then
        if nick:find ' ' then
            sendNotice("Invalid nickname. Please, masters, provide a valid one.", source)
            return
        end
        masters[nick] = false
        sendNotice(nick.." is not my master anymore.", source)
    elseif masters[source:lower()] == 1 then
        sendNotice("I need a High Master to do that.", source)
    else
        sendNotice("You're not my master! You won't control me!", source)
    end
    return true
end)

bot.commands:register("join", function(chan, source)
    if masters[source:lower()] then
        if chan:find '#' == 1 and not chan:find ' ' then
            --irc:send(": PART "..bot.channel.." :The Master ordered.\r\n")
            irc:send(": JOIN "..chan.." :\r\n")
            --bot.channel = chan
        else
            sendNotice("Invalid channel! Am I supposed to guess it or what?", source)
        end
    else
        sendNotice("You're not my master! You won't control me!", source)
    end
    return true
end)

bot.commands:register("part", function(channel, source)
    if masters[source:lower()] then
        irc:send(': PART '..channel..' :The master ordered.\r\n')
    else
        sendNotice("You're not my master! You won't control me!", source)
    end
    return true
end)

bot.commands:register("ignore", function(nick, source)
    nick = nick or ''
    nick = nick:lower()
    if masters[source:lower()] then
        if not ignored[nick] then
            ignored[nick] = true
            sendNotice(nick.." will be ignored from now hence.", source)
        else
            sendNotice(nick.." is already being ignored, master.", source)
        end
    else
        sendNotice("You're not my master! You won't control me!", source)
    end
    return true
end)

bot.commands:register("listen", function(nick, source)
    nick = nick or ''
    nick = nick:lower()
    if masters[source:lower()] then
        if ignored[nick] then
            ignored[nick] = false
            sendNotice("I will listen to "..nick.." now.", source)
        else
            sendNotice("I'm not ignoring "..nick..", master.", source)
        end
    else
        sendNotice("You're not my master! You won't control me!", source)
    end
    return true
end)

bot.commands:register("tell", function(args, source)
    if masters[source:lower()] then
        local target, message = args:match(scp)
        sendMessage(message, target)
    else
        sendNotice("You're not my master! You won't control me!", source)
    end
    return true
end)

bot.commands:register("raw", function(raw, source)
    if masters[source:lower()] then
        irc:send(raw..'\r\n')
    end
    return true
end)

bot.commands:register("event", function(code, source, target)
    if masters[source:lower()] then
        if code == 'clear' then 
            event:clear()
            sendNotice("The event queue has been cleared, master.", source)
            return true
        end
        local success, a = pcall(loadstring, code)
        if success then
            local t = {func = a, sender = source}
            event:push(t)
            sendNotice("Event added.", source)
            sendNotice(code, source)

        else
            reply(source, target, a)
        end
    else
        sendNotice("You are not allowed to access the Event 'API'.", source)
    end
    return true
end)

bot.commands:register("ident", function(pass, source, target)
    if masters[source:lower()] then
        sendNotice("You already identified yourself, "..source..". I trust you now.", source)
        return true
    end
    if target ~= bot.nick then
        sendMessage("Are you a fucking idiot?", target)
    end
    local users = {}
    local f = io.open("sudoers", "r")
    for line in f:lines() do
        if line == '' then return end
        local u,p= line:match "^(.-)%:(.+)$"
        users[u] = p
    end
    if not users[source:lower()] then
        sendNotice("You piece of fuck, you aren't a master!", source)
    elseif users[source:lower()] ~=pass then
        sendNotice("You useless idiot, that's the wrong password!", source)
    else
        masters[source:lower()] = 0
        sendNotice("Welcome back, my master.", source)
    end
    return true
end)
