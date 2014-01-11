bot.commands:register("mode", function(mode, source, target)
    if masters[source:lower()] then
        if not (mode:sub(1,1) == '#') then
            mode = target..' '..mode
        end
        irc:send(": mode "..mode..'\r\n')
    else
        sendNotice("You're not my master! You won't control me!", source)
    end
    return true
end)

bot.commands:register("kick", function(nick, source, target)
	if masters[source:lower()] then
		if not (nick:sub(1,1) == '#') then
			nick = target .. ' ' .. nick
		end
		irc:send(": kick "..nick..'\r\n')
	else
		sendNotice("You're not my master! You won't control me!", source)
	end
	return true
end)