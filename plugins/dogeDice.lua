local X = 5
local reward = X--/6*5
local maxBeth = 200

Doge.tipped:register("doge.dice", function(sender, target, amount)

    local number = math.ceil(math.random(X*40)/40)

    local winner = X -- math.random(6)

    amount = tonumber(amount)

    if amount > maxBeth then

        sendMessage("I'm sorry, " .. sender ..", the maximum bet is currently set to " .. maxBeth .. " DOGES. Have them back.", target)
        Doge.tip(sender, amount, target)
        return
    end

    if amount*reward > Doge.balance then

        sendMessage("I'm sorry, " .. sender ..", that would be more than what I can afford. Have yout DOGEs back.", target)
        Doge.tip(sender, amount, target)
        return

    end

    if number ~= winner then                                                                                

        sendMessage("I'm sorry, " .. sender .. ", you've lost your DOGEs. Good luck next time! (Dice: "..number .. ", " .. winner .. ")", target)
        return
    end

    sendMessage("Yay, " .. sender .. ", you won! Here's your DOGEs! (Dice: "..number .. ", " .. winner .. ")", target)

    Doge.tip(sender, amount*reward, target)

end)
