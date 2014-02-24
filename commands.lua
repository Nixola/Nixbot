local f = io.popen("ls plugins", "r")

for v in f:lines() do 
    dofile("plugins/"..v)
    print("Plugins."..v:sub(1, -5).." loaded.")
end 

bot.PRIVMSG:register("Command parser", function(nick, target, message) 

    --nick = nick or ''
    message = message or ''
    message = message:match("^%s*(.-)%s*$")

    if target == bot.nick then --private message!
        local success, r = pcall(bot.commands.cookie, message, nick, target, true)
        if not success and r then
            sendNotice(r, nick)
        end
    end

    if ((not settings.Master) or (settings.Master and masters[nick:lower()])) and not ignored[nick:lower()] then

        if message:lower() == bot.nick:lower()..'!' then
            sendMessage(nick..'!', (target == bot.nick) and nick or target)
        end
        if message:match("^".. bot.nick .."%, *") then message = message:gsub("^" .. bot.nick .. "%, *", ",") end
        local i = message:sub(1,1)
        if i == '!' then
            local m = message:sub(2, -1)
            local command, args = m:match(scp)
            command = command or m
            if not bot.commands[command] then return end
            local success, result = pcall(bot.commands[command], args, nick, target)
            if not success then
                sendNotice(result, nick)
            end
        end

        
        table.insert(messages[target == bot.nick and nick or target], {nick, message})
        
    end

end)
