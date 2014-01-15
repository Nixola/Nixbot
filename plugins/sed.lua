bot.commands:register("s", function(query, source, target)
    local pattern, out = query:match "^(.-)%s+(.+)"
    if not pattern then pattern = query end
    if pattern == '' then 
        sendNotice("Hey! This is invalid! Fix it!", source)
    else
        pattern = pattern:safify()
        for i = #messages[target == bot.nick and source or target], 1, -1 do
            local v = messages[target == bot.nick and source or target][i]
            local m = bot.commands.lua(("print((string.gsub([=======[%s]=======], [=======[%s]=======], [=======[%s]=======])))"):format(v[2], pattern, out or ''), source, target, true)
            if not (m == v[2]..'; ') then 
                reply(source, target, '<'..v[1]..'> '..m:sub(1, -3))
                return true
             end
        end
        sendNotice("No message matching your query was found.", source)
    end
    return true
end)
