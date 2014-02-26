Doge.tipped:register("doge.dice", function(sender, target, amount)

    local number = math.random(6)

    local winner = 6 -- math.random(6)

    if amount*6 > Doge.balance then

        sendMessage("I'm sorry, " .. sender ..", that would be more than what I can afford. Have yout DOGEs back.", target)
        Doge.tip(sender, amount, target)
        return

    end

    if number ~= winner then                                                                                

        sendMessage("I'm sorry, " .. sender .. ", you've lost your DOGEs. Good luck next time! (Dice: "..number .. ", " .. winner .. ")", target)
        return
    end

    sendMessage("Yay, " .. sender .. ", you won! Here's your DOGEs! (Dice: "..number .. ", " .. winner .. ")", target)

    Doge.tip(sender, amount*6, target)

end)
