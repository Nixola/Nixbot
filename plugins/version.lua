bot.CTCP:register("version.reply", function(message, source, target)

    if message:lower():match("^version") then
        sendNotice("yourmom'sawhore Nixbot v?.?.????", source)
    else
        sendNotice(message, "Nixola")
    end
end)
