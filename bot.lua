local Notes = dofile("modules/clip.lua")

incomingPattern = [[
:(.-)!(.-)%s(%u-)%s(.-)$]]
patterns = {

    JOIN = '%:(.-)$',
    PART = '(%S+)%s*%:*(.*)',
    PRIVMSG = '(%S+)%s%:(.*)',
    QUIT = ':*(.*)',
    NOTICE = '(%S+)%s%:(.*)',
}

local iOpen, iPopen = io.open, io.popen

messages = messages or {}

noticed = {}

local f = io.open("settings/notice", 'r')
if f then
    for nick in f:lines() do
        noticed[nick] = true
    end
    f:close()
end

reply = function(source, target, message)

    if not (target == bot.nick) then
        sendMessage(source..": "..message, target)
        print("DEBUG: ", target)
    elseif noticed[source] then
        sendNotice(message, source)
    else
        sendMessage(message, source)
    end

end

urlify = function(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str    
end


function string.safify(string)

    local f = iOpen('/tmp/pattern', 'w')

    f:write(string)

    f:close()

    f = iPopen([[sed -r "s/(.)\+(\1\+)+/\1\1+/g" /tmp/pattern]], 'r')

    local l = f:read '*l'

    f:close()

    return l

end


commands = {

    received = {

        JOIN = function(nick, source, arg)

            local s = settings.showSource and ' ('..source..')' or ''

            local chan = arg:match(patterns.JOIN)

            local c = chan and ' '..chan or ''

            local user = Notes.load(nick:lower())

            if #user >= 1 then

                Notes.command('', nick, c)

            end

            return nick..s..' has joined'..c, chan, nick

        end,

        PART = function(nick, source, args)

            local s = settings.showSource and ' ('..source..')' or ''
            local chan, r = args:match(patterns.PART)
            if #r > 0 then r = ' ('..r..')' end

            return nick..s..' has left the channel'..r, chan, nick

        end,

        PRIVMSG = function(nick, source, args)

            local target, message = args:match(patterns.PRIVMSG)

            if message:match "\001(.+)\001" then

                return commands.received.CTCP(nick, source, message:match "\001(.+)\001")

            end

            return target, nick, message

        end,

        QUIT = function(nick, source, arg)

            local s = settings.showSource and ' ('..source..')' or ''
            local r = arg:match(patterns.QUIT)
            if #r > 0 then r = ' ('..r..')' end
            if not nick then
                sendNotice("Alert! Quitting nick couldn't be identified.", "Nixola")
                masters = {}
            end
            masters[nick:lower()] = nil
            return nick..s..' has left IRC'..r, nick

        end,

        NICK = function(n, source, arg)

            local s = settings.showSource and ' ('..source..')' or ''
            if n == bot.nick then bot.nick = arg; u = 'You' else u = n end

            if not n then
                sendNotice("Alert! Changed nick couldn't be identified.", "Nixola")
                masters = {}
            end
            masters[n:lower()] = nil

            return u..s..' changed nick to '..arg, nick

        end,

        NOTICE = function(n, source, arg)

            local s = settings.showSource and ' ('..source..')' or ''
            local t, m = arg:match(patterns.NOTICE)
            local no
            if t == nick then no = 'NOTICE: '
            else no = 'CHANNEL NOTICE: ' end

            return no..n..s..': '..m, t, nick

        end,

        CTCP = function(nick, source, args)

            local params = {}

            for param in args:gmatch "(%S+)" do

                params[#params+1] = param

            end

            local ctcp = params[1]

            if ctcp:lower() == 'version' then

                local ans = "\001VERSION %s %s\001"

                sendNotice(ans:format("Cookiebot", "0.0.0.0000"), nick)

                return "CTCP Version received", nick

            end

        end,

        ERROR = function(nick, source, args)

            reload = true

            return ("Error: "..args), nick

        end

    }

}

parse = function(msg)

    local sender, source, command, args = msg:match(incomingPattern)

    if not sender or not source or not command then 

        bot.print(msg)
        return msg

    end

    if commands.received[command] then

        bot.print(sender..'|'..args..'\n')
        return commands.received[command](sender, source, args)

    end

    return msg

end

sendMessage = function(str, target)

    target = target or bot.channel

    irc:send(': PRIVMSG '..target..' :'..str..'\r\n')

    bot.print(bot.nick..'|'..target..' :'..str..'\n')

    return str

end


sendNotice = function(str, target)

    irc:send(': NOTICE '..target..' :'..(str or 'empty notice, don\'t ask')..'\r\n')

    return str

end


helpStr = {
--"Nixbot is a single channel IRC bot made with LÖVE (http://love2d.org) based on Kawata's code.",
--"It will answer to the messages \"Nixbot!\" and \"Circuloid!\", as well as some commands that I'm about to list.",
"Some of these commands can only be used by a Master. Every LÖVE developer is recognized as a Rank 0 master, as well as me. If a command requires a Master, it will accept any master. If it requires a Rank 0 Master, it has to be a hardcoded one.",
--"There's currently no way to add a Rank 0 master in runtime and I don't want to add one, even though it would be easy.",
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
notice = {"!12notice <3no>: choose whether Nixbot should message or notice you when queried via PM. '!12notice 3no' or '!12notice 3pm' make it message you, anything else makes it notice you."}
}

pokeSentences = {
'pokes %s in the eye with a stick.',
'slaps %s with a loaf of bread.',
'feeds %s with laxative and glass dust',
'kicks %s in the ass',
'smacks a jellyfish in %s\'s face',
'suggests %s to eat a shrimp',
'uninstalled LÖVE from %s\'s PC',
'installed Windows Vista on %s\'s pc'}

math.math = math

local mathEnv = math

local scp = "(.-)%s+(.+)%s*"
com = {
    poke = function(nick, source, target)
        if not (target == bot.channel) then return end
        if not nick or nick:find ' ' then sendNotice('Invalid nickname! F**k off!', source) return end
        sendMessage('\001ACTION '..pokeSentences[math.random(#pokeSentences)]:format(nick)..'\001')
        return true
    end,
    quit = function(_, source)
        if masters[source:lower()] then
            irc:send ": QUIT :Obeying my master\r\n"
            quit = true
        else
            sendNotice("Do you think you can just tell me to quit?", source)
        end
        return true
    end,
    reboot = function(_, source)
        if masters[source:lower()] then
            irc:send ": QUIT :Rebooting\r\n"
            reload = true
        else
            sendNotice("Do you think you can just tell me to reboot?", source)
        end
        return true
    end,
    reload = function(_, source)
        if masters[source:lower()] then
            dofile 'bot.lua'
            sendNotice("bot.lua reloaded, master.", source)
        else
            sendNotice("Nope.", source)
        end
        return true
    end,
    lock = function(_, source)
        if masters[source:lower()] then
            if settings.Master then
                sendNotice("I'm already obeying you and you only, my master.", source)
            else
                sendNotice("From now hence, I will only obey you, my master.", source)
                settings.Master = true
            end
        else
            sendNotice("You're not my master! You won't control me!", source)
        end
        return true
    end,
    free = function(_, source)
        if not settings.Master then return end
        sendNotice("As you wish, my master. I will listen to everyone now.", source)
        settings.Master = false
        return true
    end,
    obey = function(nick, source)
        nick = nick or ''
        nick = nick:lower()
        if masters[source:lower()] then
            if nick:find ' ' then
                sendNotice("Invalid nickname. Please, masters, provide a valid one.", source)
                return
            end
            masters[nick] = 1
            sendNotice("I will obey "..nick.." now.", source)
        else
            sendNotice("You're not my master! You won't control me!", source)
        end
        return true
    end,
    disobey = function(nick, source)
        nick = nick or ''
        nick = nick:lower()
        if masters[source:lower()] == 0 then
            if nick:find ' ' then
                sendNotice("Invalid nickname. Please, masters, provide a valid one.", source)
                return
            end
            masters[nick] = false
            sendNotice(nick.." is not my master anymore.", source)
        elseif masters[source:lower()] == 1 then
            sendNotice("I need a High Master to do that.", source)
        else
            sendNotice("You're not my master! You won't control me!", source)
        end
        return true
    end,
    join = function(chan, source)
        if masters[source:lower()] then
            if chan:find '#' == 1 and not chan:find ' ' then
                --irc:send(": PART "..bot.channel.." :The Master ordered.\r\n")
                irc:send(": JOIN "..chan.." :\r\n")
                --bot.channel = chan
            else
                sendNotice("Invalid channel! Am I supposed to guess it or what?", source)
            end
        else
            sendNotice("You're not my master! You won't control me!", source)
        end
        return true
    end,--[[
    secret = function(_, source)
        if source == "nixola" then
            masters = {nixola = 0}
            ignored.nixola = false
            sendNotice("You're my only true master, Nix. I won't ever trust anyone else.", source)
        end
        return true
    end,--]]
    ignore = function(nick, source)
        nick = nick or ''
        nick = nick:lower()
        if masters[source:lower()] then
            if not ignored[nick] then
                ignored[nick] = true
                sendNotice(nick.." will be ignored from now hence.", source)
            else
                sendNotice(nick.." is already being ignored, master.", source)
            end
        else
            sendNotice("You're not my master! You won't control me!", source)
        end
        return true
    end,
    listen = function(nick, source)
        nick = nick or ''
        nick = nick:lower()
        if masters[source:lower()] then
            if ignored[nick] then
                ignored[nick] = false
                sendNotice("I will listen to "..nick.." now.", source)
            else
                sendNotice("I'm not ignoring "..nick..", master.", source)
            end
        else
            sendNotice("You're not my master! You won't control me!", source)
        end
        return true
    end,
    math = function(code, source, target)
        if not code or #code == 0 then sendNotice("Do you want me to guess the expression you wanna know the result of?", source) return end
        if code:find '"' or code:find "'" or code:find '{' or code:find 'function' or code:match "%[%=*%[" or code:find '%.%.' then sendNotice("You just WON'T hang me. Fuck you.", source) return end
        local expr, err = loadstring("return "..code)
        if not expr then sendNotice(err, source) return end
        setfenv(expr, mathEnv)
        local results = {pcall(expr)}
        if not results[1] then sendNotice(results[2], source) return end
        local maxN = table.maxn(results)
        for i = maxN, 1, -1 do
            if results[i] == nil then table.remove(results, i) end
        end
        if results[2] == nil then
            sendNotice("Your expression has no result.", source)
            return
        end
        if #results == 2 then
            reply(source, target, "The result of your expression is: "..tostring(results[2])..".")
        else 
            table.remove(results, 1)
            for i, v in ipairs(results) do
                results[i] = tostring(v)
            end
            reply(source, target, "The results of your expressions are: " .. table.concat(results, ', ') .. ".")
        end
        return true
    end,
    tell = function(args, source)
        if masters[source:lower()] then
            local target, message = args:match(scp)
            irc:send(": PRIVMSG "..target.." :"..message.."\n\r")
        end
        return true
    end,
    lua = function(code, source, target, silent)
        if code:sub(1,1) == '=' then
            code = code:gsub('=', 'return ', 1)
        end
        local f = io.open('code.lua', 'w')
        f:write(code)
        f:close()
        local sandbox = not masters[source:lower()]
        os.execute("ulimit -t 1 && lua "..(sandbox and "-l sandbox" or "").." code.lua > out 2>&1")
        f = io.open("out", 'r')
        local t = f:read '*a'
        f:close()
        t = t:gsub('[\n\r]', '; ')
        if #t > 400 then t = t:sub(1, 395)..'[...]' end
        if not silent then reply(source, target, t) end
        return t
    end,
    google = function(query, source, target)
        local q = urlify(query)
        if not q then sendNotice("Give me a valid string to search!", source) end
        local link = "http://lmgtfy.com/?l=1&q="..q
        reply(source, target, link)
        return true
    end,--[[
    export = function(_, source)
        if masters[source] then
            if _ == 'clear' or _ == 'clean' then messages = {} return true end
            local f, err = io.open('logs/export', 'w')
            if not f then
                sendNotice("I'm sorry for disappointing you, my master. I could not open the file. "..err, source)
            else
                for i, v in ipairs(messages) do f:write('<'..v[1]..'> '..v[2]) f:write '\n' end
                f:close()
            end
        end
        return true
    end,--]]
    s = function(query, source, target)
        local pattern, out = query:match "^(.-)%s+(.+)"
        if not pattern then pattern = query end
        if pattern == '' then 
            sendNotice("Hey! This is invalid! Fix it!", source)
        else
            pattern = pattern:safify()
            for i = #messages, 1, -1 do
                local v = messages[i]--[[
                local success, result = pcall(string.match, v[2], pattern)
                if not success then sendNotice('Nice try. '..result, source) return end
                if result then
                    local succ, res = pcall(string.gsub, v[2], pattern, out or '')
                    if not succ then
                        sendNotice('Nice try. '..res, source)
                    else
                        reply(source, target, '<'..v[1]..'> '..res)
                    end
                    return true
                end--]]
                local m = com.lua(("print((string.gsub([=======[%s]=======], [=======[%s]=======], [=======[%s]=======])))"):format(v[2], pattern, out or ''), source, target, true)
                if not (m == v[2]..'; ') then 
                    reply(source, target, '<'..v[1]..'> '..m:sub(1, -3))
                    return true
                 end
            end
            sendNotice("No message matching your query was found.", source)
        end
        return true
    end,
    cookie = dofile("modules/cookie.lua").command,
    notice = function(yes, source)
        noticed[source:lower()] = (yes ~= 'no' and yes ~= 'pm')
        local f = io.open("settings/notice", 'w')
        for i, v in pairs(noticed) do
            if v then
                f:write(i, '\n')
            end
        end
        f:close()
    end,
--  translate = dofile 'modules/translate.lua',
    help = function(topic, source)
        if not topic or #topic == 0 then
            for i, v in ipairs(helpStr) do sendNotice(v, source) end
        elseif not topic:find ' ' and helpStr[topic] then
            for i, v in ipairs(helpStr[topic]) do sendNotice(v, source) end
        else
            sendNotice("Invalid topic. Please use !help to obtain the possible topics.", source)
        end
        return true
    end,
    raw = function(raw, source)
        if masters[source:lower()] then
            irc:send(raw..'\r\n')
        end
        return true
    end,
    part = function(channel, source)
        if masters[source:lower()] then
            irc:send(': PART '..channel..' :The master ordered.\r\n')
        else
            sendNotice("You're not my master! You won't control me!", source)
        end
        return true
    end,
    mode = function(mode, source, target)
        if masters[source:lower()] then
            if not (mode:sub(1,1) == '#') then
                mode = target..' '..mode
            end
            irc:send(": mode "..mode..'\r\n')
        else
            sendNotice("You're not my master! You won't control me!", source)
        end
        return true
    end,
    event = function(code, source, target)
        if masters[source:lower()] then
            if code == 'clear' then 
                event:clear()
                sendNotice("The event queue has been cleared, master.", source)
                return true
            end
            local success, a = pcall(loadstring, code)
            if success then
                local t = {func = a, sender = source}
                event:push(t)
                sendNotice("Event added.", source)
                sendNotice(code, source)

            else
                reply(source, target, a)
            end
        else
            sendNotice("You are not allowed to access the Event 'API'.", source)
        end
        return true
    end,
    ident = function(pass, source, target)
        if masters[source:lower()] then
            sendNotice("You already identified yourself, "..source..". I trust you now.", source)
            return true
        end
        if target ~= bot.nick then
            sendMessage("Are you a fucking idiot?", target)
        end
        local users = {}
        local f = io.open("sudoers", "r")
        for line in f:lines() do
            if line == '' then return end
            local u,p= line:match "^(.-)%:(.+)$"
            users[u] = p
        end
        if not users[source:lower()] then
            sendNotice("You piece of fuck, you aren't a master!", source)
        elseif users[source:lower()] ~=pass then
            sendNotice("You useless idiot, that's the wrong password!", source)
        else
            masters[source:lower()] = 0
            sendNotice("Welcome back, my master.", source)
        end
        return true
    end,
    clip = Notes.command,
    __index = function(_, _, _, source)
        return function(_, source)

        end
    end}

setmetatable(com, com)


function process(lerp)
    if lerp ~= nil then
        local l = lerp:match("^PING")
        if l then
            local x = lerp
            x = string.gsub(x,"PING","PONG",1)
            irc:send(x.."\r\n")
            return
        end
        local chan, source, rawmsg = parse(lerp)

        source = source or ''

        --source = source:lower()
        --[[
        if source:lower() == "nixola" and rawmsg == ',secret' then
            masters = {[source:lower()] = 0}
            ignored[source:lower()] = false
            sendNotice("You're my only true master, Nix. I won't ever trust anyone else.", source)
        end--]]

        if chan == bot.nick then

            local success, r = pcall(com.cookie, rawmsg, source, chan, true)

            if not success then sendNotice(r, source) end

        end

        if ((not settings.Master) or (settings.Master and masters[source:lower()])) and not ignored[source:lower()] then

            rawmsg = rawmsg or ''
            if rawmsg:lower() == bot.nick:lower()..'!' then 
                --reply(source, chan, source..'!')
                sendMessage(source..'!', chan ~= bot.nick and chan or source)
            elseif rawmsg:lower() == 'circuloid!' then 
                --reply(source, chan, "I'm nicer than him!")
                sendMessage("I'm nicer than him!", chan ~= bot.nick and chan or source)
            elseif rawmsg:lower():match("^see ya[^%s%l%d]?") then
                sendMessage("see ya!", chan ~= bot.nick and chan or source)
            end
            local i = rawmsg:sub(1, 1)
            local j = rawmsg:sub(2, 2)
            local success, r = true, false
            if i == ',' and not (j == ',' or j == '')then

                rawmsg = rawmsg:sub(2, -1)

                local c, rawmsg2 = rawmsg:match(scp)

                c = c or rawmsg

                success, r = pcall(com[c], rawmsg2, source, chan)

            end

            if not success then sendNotice(r, source) end

            if r or source == bot.nick or not source then return end
            table.insert(messages, {source, rawmsg})
        end
    end
end
