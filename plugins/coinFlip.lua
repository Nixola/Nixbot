bot.commands:register('flip', function(message, source, channel)

    message = message or ''

    local isHeads = message:lower():find "head"

    local isTails = message:lower():find "tail"

    local result = math.random(2) == 2 and "heads" or "tails"

    if (not (isHead or isTails)) or (isHead and isTails) then

        reply(source, channel, result)

    elseif (isHeads and result == "heads") or (isTails and result == "tails") then

        reply(source, channel, source .. ", that's it! You won! (" .. result .. ")")

    else

        reply(source, channel, source .. ", you lost! Sorry! (" .. result .. ")")

    end

end)
