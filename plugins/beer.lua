local beers = setmetatable({}, {__index = function() return 0 end})

bot.commands:register("beer", function(message, nick, target)

    local msg

    if target == bot.nick then return end

    if not message or message == '' then

        reply(nick, target, "Who do you want to beer?")
        return
    end

    local t = message:match("([^%s]+)")

    local n = t:lower()

    if nick:lower() == n then

        sendMessage("Hey! Don't get any beer for yourself. Give it to someone else!", target)
        return
    end

    beers[n] = beers[n] + 1

    local s = beers[n] == 1 and '' or 's'

    sendMessage("\001ACTION gives "..t.." some beer. " .. t .. " has " .. beers[n] .." beer".. s .. " now.\001", target)

end)

bot.commands:register("drink", function(message, nick, target)

    if target == bot.nick then

        sendMessage("You wouldn't want to drink that alone, would you?", nick)
        return
    end

    nick = nick:lower()

    if beers[nick] == 0 then

        reply(nick, target, "You're out of beers! Sorry!")

    else
        beers[nick] = beers[nick] - 1
        reply(nick, target, "Here's your beer! You now have " .. beers[nick] .." beers.")
    end

end)

isFido = {}
isFido.fido = true
isFido.fidoge = true
isFido.fido0 = true
isFido.fido1 = true
isFido.fido2 = true
isFido.fido3 = true

bot.PRIVMSG:register("beerz", function(nick, target, message)

    if not isFido[nick:lower()] then return end

    if true then return end

    local sender, amount, dogeTarget = message:match("^Wow!%s+([^%s]+)%ssent Ð(%d%d+) to ([^%s]+)!")

    if nick and amount and dogeTarget and (dogeTarget:lower() == bot.nick:lower()) then

        amount = math.floor(amount/10)

        local s = amount == 1 and '' or 's'

        reply(sender, target, "A hooker brought you " .. amount .. " beer" .. s .. " on a silver plate! You now have " .. beers[sender:lower()]+amount .. " beer" .. s .. ".")

        beers[sender:lower()] = beers[sender:lower()] + amount

    end

end)
