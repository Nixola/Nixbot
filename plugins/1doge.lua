Doge = Doge or {} --Wow!  Nixola sent Ð10 to Nixbot!  To claim: '/msg fido help'.
Doge.authed = Doge.authed or {}
local tipPattern = "^Wow!%s+([^%s]+)%ssent Ð(%d+) to ([^%s]+)!"

bot.PRIVMSG:register("doge.balance", function(source, target, message)

    if not Doge.authed[source:lower()] then return end

    if source:lower() == "fido" and target:lower() == bot.nick:lower() then

        if message:match("Your confirmed balance: Ð([%d%.]+)%s") then

            Doge.balance = message:match("Your confirmed balance: Ð([%d%.]+)%s")

        end

    end

end)


local isFido = {
    fido = true,
    fidoge = true,
    fido0 = true,
    fido1 = true,
    fido2 = true
}


bot.NOTICE:register("Doge.auth", function(source, target, message)

    if source:lower() == "nickserv" then

        local nick, level = message:lower():match("(%S+) acc (%d)")

        if not nick or not isFido[nick] then return end

        Doge.authed[nick] = tonumber(level) == 3

    end

end)


bot["330"]:register("Doge.auth", function(nick, account)

    if isFido[nick:lower()] and account:lower() == "fido" then

        Doge.authed[nick:lower()] = true

    end

end)


Doge.tip = function(target, amount, channel)

    sendMessage("!tip "..target.." "..amount, channel)
    Doge.balance = Doge.balance - amount

end


bot.PRIVMSG:register("doge.tipped", function(source, target, message)

    if Doge.authed[source:lower()] then

        local sender, amount, receiver = message:match(tipPattern)

        if not (sender and receiver and amount) then return end

        if receiver:lower() == bot.nick:lower() then

            Doge.balance = Doge.balance + amount

            Doge.tipped:fire(sender, target, amount)

        end

    end

end)


bot.QUIT:register("doge.check", function(source, target, message)

    Doge.authed[source:lower()] = nil

end)


bot.JOIN:register("doge.check", function(nick, chan)

    if isFido[nick:lower()] then

        cron.add(os.time()+1, function() 
            irc:send(": WHOIS " .. nick .. "\r\n")
        end)

    end

end)


Doge.tipped = class(bot.callback)

bot.onLoad:register("doge", function()
    for i, v in pairs(isFido) do
        irc:send(": WHOIS " .. i .. "\r\n")
    end
    irc:send ": PRIVMSG fido :balance\r\n"
end)

bot.commands:register("refresh", function()
    for i, v in pairs(isFido) do
        irc:send(": WHOIS " .. i .. "\r\n")
    end
    irc:send ": PRIVMSG fido :balance\r\n"
end)

bot.commands:register("doge", function(message, source, target)

    reply(source, target, "I have " .. Doge.balance .. " DOGE right now.")

end)
