bot.commands:register("google", function(query, source, target)
    local q = urlify(query)
    if not q then sendNotice("Give me a valid string to search!", source) end
    local link = "http://lmgtfy.com/?q="..q
    reply(source, target, link)
    return true
end)