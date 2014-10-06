Piggy = Piggy or {} --Oink! paulynopoops tipped Nixola 200 PIGGY! "/msg piggytip help" to claim.
Piggy.authed = Piggy.authed
local tipPattern = "^Oink! ([%S]+) tipped ([%S]+) ([%d%.]+) PIGGY! \"/msg piggytip help\" to claim.$"

bot.PRIVMSG:register("piggy.balance", function(source, target, message)

    if not Piggy.authed then return end

    if source:lower() == "piggytip" and target:lower() == bot.nick:lower() then
        --nixola has 200 PIGGY (unconfirmed: 0 PIGGY)
        
        local account, balance = message:match("^(%S+) has ([%d%.]+) PIGGY")
        if account and (account:lower() == bot.nick:lower()) and balance then

            Piggy.balance = tonumber(balance)
            if not Piggy.balance then print(balance) end

        end

    end

end)


bot.NOTICE:register("Piggy.auth", function(source, target, message)

    if source:lower() == "nickserv" then

        local nick, level = message:lower():match("(%S+) acc (%d)")

        if not nick or not nick:lower() == "piggytip" then return end

        Piggy.authed = tonumber(level) == 3

    end

end)


bot["330"]:register("Piggy.auth", function(nick, account)

    if nick:lower() == "piggytip" and account:lower() == "minttip" then

        Piggy.authed = true

    end

end)


Piggy.tip = function(target, amount, channel)

    sendMessage("!tip "..target.." "..amount, channel)
    Piggy.balance = Piggy.balance - amount

end


bot.PRIVMSG:register("Piggy.tipped", function(source, target, message)

    if Piggy.authed then

        local sender, receiver, amount = message:match(tipPattern)

        if not (sender and receiver and amount) then return end

        if receiver:lower() == bot.nick:lower() then

            Piggy.balance = Piggy.balance + amount

            Piggy.tipped:fire(sender, target, amount)

        end

    end

end)


bot.QUIT:register("Piggy.check", function(source, target, message)

    if source:lower() == "piggytip" then

        Piggy.authed = nil

    end

end)


bot.JOIN:register("Piggy.check", function(nick, chan)

    if nick:lower() == "piggytip" then

        irc:send(": WHOIS " .. nick .. "\r\n")

    end

end)


Piggy.tipped = class(bot.callback)

bot.onLoad:register("piggy", function()
    irc:send(": WHOIS piggytip\r\n")
    irc:send ": PRIVMSG piggytip :balance\r\n"
end)

bot.commands:register("piggy", function(message, source, target)

    if masters[source:lower()] then

        sendNotice("I have " .. Piggy.balance .. " PIGGYs right now.", source)

    end

end)
