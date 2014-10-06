local lotto = {}

lotto.tickets = {}
lotto.jackpot = 0
lotto.lastJackpot = 0
lotto.payout = 100 --%
lotto.cost = 5
lotto.time = 600
lotto.announceTime = 120
lotto.factor = 1
lotto.channel = "#piggy"


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
        sendMessage("\00311" .. winner .. "\0032, you won the lottery! Next draw in\00311 " .. realTime(lotto.time), lotto.channel)
        Piggy.tip(winner, lotto.jackpot, lotto.channel)
    end
    lotto.tickets = {}
    lotto.jackpot = 0
    lotto.lastJackpot = 0

    if lotto.last then 
        irc:send(": QUIT :Because I say so.\r\n")
        irc:close()
        os.exit()
    end
    local time = os.time()
    local nextDraw = math.floor(time/lotto.time)*lotto.time + lotto.time
    cron.add(nextDraw, lotto.pick)

end


lotto.announce = function()

    local time = os.time()

    if lotto.jackpot > 0 and lotto.jackpot ~= lotto.lastJackpot then

        local nextDraw = math.floor(time/lotto.time)*lotto.time+lotto.time

        lotto.lastJackpot = lotto.jackpot

        sendMessage("\0034The jackpot is\0035 "..lotto.jackpot.."\0034, next draw in\0035 " .. realTime(nextDraw-time), lotto.channel)

    end

    local nextAnn = math.floor(time/lotto.announceTime)*lotto.announceTime+lotto.announceTime+1

    cron.add(nextAnn, lotto.announce)

end


Piggy.tipped:register("piggyLotto", function(nick, channel, amount)

    channel = channel:lower()
    
    print(channel, lotto.channel)

    if channel ~= lotto.channel then return end

    local tickets = math.floor(amount/lotto.cost)

    lotto.tickets[nick:lower()] = (lotto.tickets[nick:lower()] or 0) + tickets

    local time = os.time()

    local nextDraw = math.floor(time/lotto.time)*lotto.time+lotto.time

    lotto.jackpot = lotto.jackpot + tickets*lotto.payout/100*lotto.cost

    reply(nick, channel, "\0034" .. nick .. "\0035, you bought\0034 " .. tickets .. "\0035 tickets and you now have\0034 " .. lotto.tickets[nick:lower()].."\0035, the jackpot's\0034 "..lotto.jackpot .. "\0035! Next draw in\0034 " .. realTime(nextDraw-time))

end)



bot.onLoad:register("piggyLotto", function()

    irc:send(": JOIN " .. lotto.channel .. "\r\n")

    local time = os.time()
    local nextDraw = math.floor(time/lotto.time)*lotto.time+lotto.time
    local nextAnnounce = math.floor(time/lotto.announceTime)*lotto.announceTime+lotto.announceTime

    cron.add(nextDraw, lotto.pick)
    cron.add(nextAnnounce, lotto.announce)

end)


bot.commands:register("lotto", function(message, nick, channel)

    local time = os.time()

    local nextDraw = math.floor(time/lotto.time)*lotto.time+lotto.time

    reply(nick, channel, "\0035The jackpot is\0034 "..lotto.jackpot.."\0035, the draw is in\0034 "..realTime(nextDraw-time))

    if not message then return end

    if masters[nick:lower()] then

        if message:match("^(%S+)") == "time" and message:match("^%S+%s(%d+)") then

            lotto.time = tonumber(message:match("^%S+%s(%s+)"))

        elseif message:match("^(%S+)") == "draw" then

            lotto.pick()

        elseif message:match("^(%S+)") == "last" then

            lotto.last = true

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
