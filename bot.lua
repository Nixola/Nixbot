incomingPattern = [[
:(.-)!(.-)%s(%u-)%s(.-)$]]
patterns = {

    JOIN = '(.+)$',
    PART = '(%S+)%s*%:*(.*)',
    PRIVMSG = '(%S+)%s%:(.*)',
    QUIT = ':*(.*)',
    NOTICE = '(%S+)%s%:(.*)',
}

local iOpen, iPopen = io.open, io.popen

messages = messages or setmetatable({}, {__index = function(self, k) self[k] = {}; return self[k] end})

reply = function(source, target, message)

    if target ~= bot.nick then
        sendMessage(message, target)
    else
        sendNotice(message, source)
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

    local f,e = iOpen('/tmp/pattern', 'w')

    if not f then
        print(e)
        return
    end

    f:write(string)

    f:close()

    f = iPopen([[sed -r "s/(.)\+(\1\+)+/\1\1+/g" /tmp/pattern]], 'r')

    local l = f:read '*l'

    f:close()

    return l

end

class = function(t) return setmetatable({}, {__index = t}) end

bot.callback = {}

bot.callback.register = function(self, name, func)

    if self[name] then
        return nil, "Callback exists"
    end
    local id = #self+1
    local t = {name = name, id = id, func = func}
    self[name] = t
    self[id] = t
    return true
end

bot.callback.unload = function(self, name)

    if not self[name] then
        return nil, "Callback doesn't exist"
    end
    local t = self[name]
    self[name] = nil
    table.remove(self, id)
    for i = id, #self do
        self[i].id = i
    end
    return true
end

bot.callback.fire = function(self, ...)

    for i, v in ipairs(self) do
        local r, e = pcall(v.func, ...)

        if not r then
            print("Error in callback", v.name, e, i)
        end
    end

end


bot.JOIN = class(bot.callback)
bot.JOIN.name = "join"
bot.PART = class(bot.callback)
bot.PART.name = "part"
bot.PRIVMSG = class(bot.callback)
bot.PRIVMSG.name = "privmsg"
bot.QUIT = class(bot.callback)
bot.NICK = class(bot.callback)
bot.NOTICE = class(bot.callback)
bot.CTCP = class(bot.callback)
bot.ERROR = class(bot.callback)

bot.SENTMESSAGE = class(bot.callback)
bot.SENTNOTICE  = class(bot.callback)

commands = {

    received = {

        JOIN = function(nick, source, arg)

            local chan = arg:match(patterns.JOIN)

            bot.JOIN:fire(nick, chan)

        end,

        PART = function(nick, source, args)

            local s = settings.showSource and ' ('..source..')' or ''
            local chan, reason = args:match(patterns.PART)

            bot.PART:fire(nick, chan, reason)

        end,

        PRIVMSG = function(nick, source, args)

            local target, message = args:match(patterns.PRIVMSG)

            if message:match "\001(.+)\001" then

                commands.received.CTCP(nick, source, message:match "\001(.+)\001")

            else

                bot.PRIVMSG:fire(nick, target, message)

            end
            
        end,

        QUIT = function(nick, source, arg)

            local reason = arg:match(patterns.QUIT)
            
            if not nick then
                sendNotice("Alert! Quitting nick couldn't be identified.", "Nixola")
                masters = {}
                return
            end
            masters[nick:lower()] = nil
            
            bot.QUIT:fire(nick, reason)

        end,

        NICK = function(n, source, arg)

            if not n then
                sendNotice("Alert! Changed nick couldn't be identified.", "Nixola")
                masters = {}
                return
            end
            arg = arg:sub(2, -1)
            masters[arg:lower()] = masters[n:lower()]
            masters[n:lower()] = nil

            bot.NICK:fire(n, arg)

        end,

        NOTICE = function(n, source, arg)

            local target, notice = arg:match(patterns.NOTICE)

            bot.NOTICE:fire(n, target, notice)

        end,

        CTCP = function(nick, source, args)

            local params = {}

            for param in args:gmatch "(%S+)" do

                params[#params+1] = param

            end

            local ctcp = params[1]

            bot.CTCP:fire(nick, unpack(params))

        end,

        ERROR = function(nick, source, args)

            bot.ERROR:fire(args)

            reload = true

        end
    }

}

parse = function(msg)

    local sender, source, command, args = msg:match(incomingPattern)

    if not sender or not source or not command then 

        return msg

    end

    if commands.received[command] then

        return commands.received[command](sender, source, args)

    end

    return msg

end

sendMessage = function(str, target)

    target = target or bot.channel

    irc:send(': PRIVMSG '..target..' :'..str..'\r\n')

    bot.SENTMESSAGE:fire(target, str)

    return str

end


sendNotice = function(str, target)

    irc:send(': NOTICE '..target..' :'..(str or 'empty notice, don\'t ask')..'\r\n')

    bot.SENTNOTICE:fire(target, message)

    return str

end

scp = "(.-)%s+(.+)%s*"
--[[
bot.commands = {
    cookie = dofile("plugins/cookie.lua").command,
    clip = Notes.command,
    __index = function(_, _, _, source)
        return function(_, source)

        end
    end}--]]

bot.commands = {}
bot.commands.register = function(self, name, func)
    --[[
    if self[name] then
        return nil, "Command exists"
    end--]]
    self[name] = func
end


function process(lerp)
    if lerp ~= nil then
        local l = lerp:match("^PING")
        if l then
            local x = lerp
            x = string.gsub(x,"PING","PONG",1)
            irc:send(x.."\r\n")
            return
        end
        parse(lerp)
    end
end

dofile "commands.lua"
