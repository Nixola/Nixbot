Piggy.tipped:register("mint.dice", function(sender, target, amount)

    local maxBet = 7

    local odds = 1/3

    local number = math.random()

    local factor = 3

    amount = tonumber(amount)

    if amount*factor > Piggy.balance then

        sendMessage("I'm sorry, " .. sender ..", that would be more than what I can afford. Have yout PIGGYs back.", target)
        Piggy.tip(sender, amount, target)
        return

    end

    print(type(amount), type(maxBet))

    if amount > maxBet then

        sendMessage("I'm sorry, " .. sender .. ", the maximum bet is currently "..maxBet.." PIGGYs. Have them back.", target)
        Piggy.tip(sender, amount, target)
        return

    end

    if number > odds then

        sendMessage("I'm sorry, " .. sender .. ", you've lost your PIGGYs. Good luck next time!", target)
        return
    end

    sendMessage("Yay, " .. sender .. ", you won! Here's your PIGGYs!", target)

    Piggy.tip(sender, amount*factor, target)

end)
