Mint = {}
local tipPattern = "Wow! ([^%s]+) tipped ([^%s]+) ([%d%.]+) MNT! %(?(.*)%)?%s?\"/msg minttip help\" to claim."

bot.PRIVMSG:register("mint.balance", function(source, target, message)

    if not Mint.authed then return end

    if source:lower() == "minttip" then

        if message:match(bot.nick:lower() .. " has ([%d%.]+) MNT %(unconfirmed: [%d%.]+ MNT%)") then

            Mint.balance = message:match(bot.nick:lower() .. " has ([%d%.]+) MNT %(unconfirmed: [%d%.]+ MNT%)")

        end

    end

end)


bot.NOTICE:register("mint.auth", function(source, target, message)

    if source:lower() == "nickserv" then

        local level = message:lower():match("minttip acc (%d)")

        Mint.authed = tonumber(level) == 3

    end

end)


Mint.tip = function(target, amount, channel)

    sendMessage("!tip "..target.." "..amount, channel)
    Mint.balance = Mint.balance - amount

end


bot.PRIVMSG:register("mint.tipped", function(source, target, message)

    if source == "minttip" and Mint.authed then

        local sender, receiver, amount, comment = message:match(tipPattern)

        if not (sender and receiver and amount) then return end

        if receiver:lower() == bot.nick:lower() then

            Mint.balance = Mint.balance + amount

            Mint.tipped:fire(sender, target, amount, comment)

        end

    end

end)


Mint.tipped = class(bot.callback)

irc:send ": PRIVMSG Nickserv :ACC minttip\r\n"
irc:send ": PRIVMSG minttip :balance\r\n"
