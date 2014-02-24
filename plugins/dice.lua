local tipPattern = "Wow! ([^%s]+) tipped ([^%s]) ([%d%.]+) MNT! %((.+)%)\"/msg minttip help\" to claim."

Mint.tipped:register("dice", function(sender, target, amount, comment)

    local number = tonumber(comment) or math.random(6)

    local winner = math.random(6)

    if amount*6 > Mint.balance then

        sendMessage("I'm sorry, " .. sender ..", that would be more than what I can afford. Have yout MINTs back.", target)
        Mint.tip(sender, amount, target)
        return

    end

    if number ~= winner then                                                                                

        sendMessage("I'm sorry, " .. sender .. ", you've lost your MINTs. Good luck next time!", target)
        return
    end

    sendMessage("Yay, " .. sender .. ", you won! Here's your MINTs!", target)

    Mint.tip(sender, amount*6, target)

end)


bot.commands:register("mint", function(source, target, message)

    reply(source, target, "I have " .. Mint.balance .. " MNT right now.")

end)
