local colors = {}
colors.reset = function(self)
    for i = 0, 14 do
        self[i+1] = i
    end
end
colors:reset()
colors.pick = function(self)
    if #self == 0 then
        colors:reset()
    end
    local n = math.random(#self)
    local c = self[n]
    table.remove(self, n)
    return c
end

local channels = {}
channels.__index = function(self, k)
    local c = colors:pick()
    self[k] = c
    return c
end
setmetatable(channels, channels)

local setColor = function(n)
    if n then
        io.write(string.char(0x1b), '[38;5;', n, 'm')
    else
        io.write(string.char(0x1b), '[39m')
    end
end

local setBold = function(bool)
    if bool then
        io.write(string.char(0x1b), '[1m')
    else
        io.write(string.char(0x1b), '[22m')
    end
end

local color = require 'color'    

bot.PRIVMSG:register("log", function(nick, target, message)
    
    setColor(15) --white
    io.write '<'
    setColor(channels[nick])
    io.write(nick)
    setColor(15)
    io.write ':'
    setColor((target ~= bot.nick) and channels[target] or channels[nick])
    io.write(target)
    setColor(15)
    io.write('> ', color.mircToAnsi(message), '\n')
end)

bot.NOTICE:register("log", function(nick, target, message)

    setColor(9)
    setBold(true)
    io.write '!'
    setColor(channels[nick])
    io.write(nick)
    if target ~= bot.nick then
        setColor(15)
        io.write ':'
        setColor(channels[target])
        io.write(target)
    end
    setColor(9)
    io.write('! ')
    setBold(false)
    setColor()
    io.write(color.mircToAnsi(message), '\n')
end)

bot.SENTMESSAGE:register("log", function(target, message)

    setColor(15)
    io.write '<'
    setColor(channels[bot.nick])
    io.write(bot.nick)
    setColor(15)
    io.write ':'
    setColor(channels[target])
    io.write(target)
    setColor(15)
    io.write('> ', color.mircToAnsi(message), '\n')
end)

bot.JOIN:register("log", function(nick, channel)

    setColor(channels[nick])
    io.write(nick)
    setColor(15)
    io.write(" has joined ")
    setColor(channels[channel])
    io.write(channel, '\n')
end)

bot.PART:register("log", function(nick, channel, reason)

    setColor(channels[nick])
    io.write(nick)
    setColor(15)
    io.write(" has left ")
    setColor(channels[channel])
    io.write(channel)
    if reason and reason~='' then
        io.write(' [', reason, ']')
    end
    io.write '\n'
end)

bot.QUIT:register("log", function(nick, reason)

    setColor(channels[nick])
    io.write(nick)
    setColor(15)
    io.write(" has quit")
    if reason and reason ~= '' then
        io.write(" [", reason, "]")
    end
    io.write '\n'
end)

bot.NICK:register("log", function(old, new)

    channels[new] = channels[old]
    channels[old] = nil
    setColor(channels[new])
    io.write(old)
    setColor(15)
    io.write(" has changed nick to ")
    setColor(channels[new])
    io.write(new, '\n')
end)
