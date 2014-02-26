Mint = Mint or {}
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


bot.QUIT:register("mint.check", function(source, target, message)

    if source:lower() == "minttip" then

        Mint.authed = false

    end

end)


bot.JOIN:register("mint.check", function(nick, chan)

    if nick:lower() == "minttip" then

        sendNotice("ACC minttip", "NickServ")

    end

end)


Mint.tipped = class(bot.callback)

bot.onLoad:register("mint", function()
    irc:send ": PRIVMSG Nickserv :ACC minttip\r\n"
    irc:send ": PRIVMSG minttip :balance\r\n"
end)

--[[
bot.commands:register("mintpal", function(source, target, message)

    message = tonumber(message) or 1

    local json = require 'dkjson'

    local jobj, res = require 'socket.http'.request "http://api.mintpal.com/market/stats/MINT/BTC"

    if not res == 200 then

        reply(source, target, "I'm sorry, something went wrong contacting MintPal. ("..res..")")
        return

    end

    local obj = json.decode(jobj)

    reply(source, target, message.." MINT = " .. obj[1].last_price*(10^8) .." satoshi")

end)--]]


bot.commands:register("mint", function(message, source, target)

   if message == "refresh" then

       sendMessage("balance", "minttip")
       return

   end

    reply(source, target, "I have " .. Mint.balance .. " MNT right now.")

end)
