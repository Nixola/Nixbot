Mint.tipped:register("mint.dice", function(sender, target, amount, comment)

    local number = 6 -- tonumber(comment) or math.random(6)

    local winner = math.random(6)

    if amount*6 > Mint.balance then

        sendMessage("I'm sorry, " .. sender ..", that would be more than what I can afford. Have yout MINTs back.", target)
        Mint.tip(sender, amount, target)
        return

    end

    if number ~= winner then                                                                                

        sendMessage("I'm sorry, " .. sender .. ", you've lost your MINTs. Good luck next time! (Dice: "..number .. ", " .. winner .. ")", target)
        return
    end

    sendMessage("Yay, " .. sender .. ", you won! Here's your MINTs! (Dice: "..number .. ", " .. winner .. ")", target)

    Mint.tip(sender, amount*6, target)

end)
