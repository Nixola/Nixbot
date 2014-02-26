local lotto = {}

lotto.tickets = {}
lotto.jackpot = 0
lotto.payout = 100 --%
lotto.cost = 10
lotto.time = 600
lotto.factor = 1
lotto.channel = "#windoge"


lotto.pick = function()

    local sum = 0
    local wins = {}

    for i, v in pairs(lotto.tickets) do
        v = v^lotto.factor
        wins[i] = v
        sum = sum + v
    end

    local winner

    local win = sum*math.random()

    print(win, sum)

    for i, v in pairs(wins) do

        if win <= v then

            winner = i
            break

        else

            win = win - v

        end

    end


    if winner then
        sendMessage(winner .. ", you won the lottery! Next draw in " .. realTime(lotto.time), lotto.channel)
        Doge.tip(winner, lotto.jackpot, lotto.channel)
    end
    lotto.tickets = {n = 0}
    lotto.jackpot = 0
    cron.add(os.time()+lotto.time, lotto.pick)

end

Doge.tipped:register("dogeLotto", function(nick, channel, amount)

    channel = channel:lower()
    
    print(channel, lotto.channel)

    if channel ~= lotto.channel then return end

    local tickets = math.floor(amount/lotto.cost)

    lotto.tickets[nick:lower()] = (lotto.tickets[nick:lower()] or 0) + tickets

    local time = os.time()

    local nextDraw = math.floor(time/lotto.time)*lotto.time+lotto.time

    lotto.jackpot = lotto.jackpot + tickets*lotto.payout/100*lotto.cost

    reply(nick, channel, nick .. ", you bought " .. tickets .. " tickets and you now have " .. lotto.tickets[nick:lower()]..", the jackpot's "..lotto.jackpot .. "! Next draw in " .. realTime(nextDraw-time))

end)



bot.onLoad:register("dogeLotto", function()

    local time = os.time()
    local nextDraw = math.floor(time/lotto.time)*lotto.time+lotto.time

    cron.add(nextDraw, lotto.pick)

end)


bot.commands:register("lotto", function(message, nick, channel)

    local time = os.time()

    local nextDraw = math.floor(time/lotto.time)*lotto.time+lotto.time

    reply(nick, channel, "The jackpot is "..lotto.jackpot..", the draw is in "..realTime(nextDraw-time))

    if not message then return end

    if masters[nick:lower()] then

        if message:match("^(%S+)") == "time" and message:match("^%S+%s(%d+)") then

            lotto.time = tonumber(message:match("^%S+%s(%s+)"))

        elseif message:match("^(%S+)") == "draw" then

            lotto.pick()

        end

    end

end)


bot.JOIN:register("lotto", function(nick, chan)

    if chan:lower() == bot.channel:lower() then

        local time = os.time()

        local nextDraw = math.floor(time/lotto.time)*lotto.time+lotto.time

        sendNotice("Hi! Welcome to the lotto channel. The jackpot is "..lotto.jackpot.." and the next draw will be in " .. realTime(nextDraw-time) .. ". Tip me via Fido to buy tickets! 10Ð/ticket.", nick)

    end

end)
