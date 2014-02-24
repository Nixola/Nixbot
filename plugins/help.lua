local helpStr = {
"Some of these commands can only be used by a Master. Every LÖVE developer is recognized as a Rank 0 master, as well as me. If a command requires a Master, it will accept any master. If it requires a Rank 0 Master, it has to be a hardcoded one.",
"Commands: !12poke, !12quit, !12lock, !12free, !12obey, !12disobey, !12join, !12ignore, !12listen, !12math, !12lua, !12google, !12s, !12cookie. Run !help command to get informations about it.",
poke = {"!12poke <3nick>: sends a mean CTCP ACTION command which has nick as object (e.g: Nixbot installed Windows Vista on Nixola's PC)."},
quit = {"!12quit: shuts the bot down. A Master is required."},
lock = {"!12lock: locks the bot, so that it will ignore every message but Masters' ones. A Master is required."},
free = {"!12free: unlocks the bot, so that it will parse everyone's messages again."},
obey = {"!12obey <3nick>: makes nick a Rank 1 Master. A Master is required."},
disobey = {"!12disobey <3nick>: revokes the Master status on nick. A Rank 0 Master is required.",},
join = {"!12join <3channel>: makes the bot part from the current channel to join a new one. A Master is required.",},
ignore = {"!12ignore <3nick>: makes the bot ignore every nick's message until !listen nick is used. A Master is required.",},
listen = {"!12listen <3nick>: makes the bot listen again to an ignored user. A Master is required.",},
math = {"!12math <3expression> <4[, expressions]>: makes the bot evaluate expression (or the expressions) and send either a message or a notice with the result[s].",},
lua = {"!12lua <3code>: runs sandboxed and ulimit(-t 1)ed Lua code, printing or noticing the result.",},
google = {"!12google <3something>: too lazy to google for something? Let Nixbot google that for you!",},
s = {"!12s <3Lua pattern> <4string>: iterates backwards through the received messages, :gsub(pattern,string)ing the first appropriate one.",},
cookie = {"!12cookie <3[action]> <4[element]> <5[param]>: Cookie is a shamelessly limited copy of Orteil's Cookie Clicker. 3Action and 4Element can be null (!12cookie), in which case you gain a cookie and get a list of your buildings.",
          "Actions: 3cps, takes no arguments, shows how many cookies you bake per second; 3buy: takes an element, which is a building, and tries to buy it with the available cookies, buys <5param> buildings if provided (!12cookie 3buy <4building> 5all buys as many as possible);",
          "3price: takes an element, which is a building, and shows you its price, lists the price of the buildings if <4Element> is null or invalid or tells you how much X buildings cost (e.g. !12cookie 3price 4factory5 6); 3sell: behaves like 3buy, except it sells X buildings for half the price you paid them and doesn't list anything. For a list of available buildings, use \"!12cookie 3buy\" or visit http://nixo.ga/?buildings."},
}

bot.commands:register("help", function(topic, source)
    if not topic or #topic == 0 then
        for i, v in ipairs(helpStr) do sendNotice(v, source) end
    elseif not topic:find ' ' and helpStr[topic] then
        for i, v in ipairs(helpStr[topic]) do sendNotice(v, source) end
    else
        sendNotice("Invalid topic. Please use !help to obtain the possible topics.", source)
    end
    return true
end)
