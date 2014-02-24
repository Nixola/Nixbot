bot.commands:register("fortune", function(message, nick, target)

    message = message or ''

    if message:sub(1, 3) == "add" and masters[nick:lower()] then

        local f = io.open("fortune", "a")
        f:write(message:sub(5, -1), '\n')
        f:close()
        sendNotice("Message '"..message:sub(5, -1) .."' added.", nick)
        return

    end

    local t = {}
    local f = io.open("fortune")
    for line in f:lines() do
        t[#t+1] = line
    end
    reply(nick, target, t[math.random(#t)])

    return

end)
