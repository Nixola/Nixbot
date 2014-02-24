local sentences = {
'pokes %s in the eye with a stick.',
'slaps %s with a loaf of bread.',
'feeds %s with laxative and glass dust',
'kicks %s in the ass',
'smacks a jellyfish in %s\'s face',
'suggests %s to eat a shrimp',
'uninstalled LÖVE from %s\'s PC',
'installed Windows Vista on %s\'s pc'}

bot.commands:register("poke", function(nick, source, target)
    if target == bot.nick then return end
    if not nick or nick:find ' ' then sendNotice('Invalid nickname! Fuck off!', source) return true end
    reply(source, target, '\001ACTION ' .. sentences[math.random(#sentences)]:format(nick) .. '\001')
    return true
end)
