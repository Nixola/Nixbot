bot.commands:register("remind", function(message, nick, target)
    local time = message:match("^(.-)%;")
    message = message:match("^.-;%s*(.-)$")
    if not time or not message then
        sendNotice("There's something wrong.", nick)
        return
    end
    local s = time:match("(%d+)s") or 0
    local m = time:match("(%d+)m") or 0
    local h = time:match("(%d+)h") or 0
    local d = time:match("(%d+)d") or 0

    if not (s or m or h or d) then
        sendNotice("There's something wrong.", nick)
        return
    end
    
    target = target == bot.nick and nick or target

    time = os.time() +s +m*60 +h*3600 +d*24*3600

    local f = function()

        sendMessage(nick .. ": " .. message, target)

    end

    cron.add(time, f)

    sendNotice("'"..message.."' will be reminded you at " .. os.date("%X", time) .. " (local hour).", nick)

end)
