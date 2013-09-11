settings = {showSource = false}
incomingPattern = [[
:(.-)!(.-)%s(%u-)%s(.-)$]]
patterns = {

	JOIN = '%:(.-)$',
	PART = '(%S+)%s*%:*(.*)',
	PRIVMSG = '(%S+)%s%:(.*)',
	QUIT = ':*(.*)',
	NOTICE = '(%S+)%s%:(.*)'
}

commands = {

	received = {
	
		JOIN = function(nick, source, arg)
		
			local s = settings.showSource and ' ('..source..')' or ''
			
			local chan = arg:match(patterns.JOIN)
		
			return nick..s..' has joined '..chan, chan, nick
			
		end,
		
		PART = function(nick, source, args)
		
			local s = settings.showSource and ' ('..source..')' or ''
			local chan, r = args:match(patterns.PART)
			if #r > 0 then r = ' ('..r..')' end
			
			return nick..s..' has left the channel'..r, chan, nick
			
		end,
		
		PRIVMSG = function(n, source, args)
		
			local s = settings.showSource and ' ('..source..')' or ''
			local c, m = args:match(patterns.PRIVMSG)
			local chan = c
			
			return n..': '..m, chan, n, m, c
			
		end,
		
		QUIT = function(nick, source, arg)
		
			local s = settings.showSource and ' ('..source..')' or ''
			local r = arg:match(patterns.QUIT)
			if #r > 0 then r = ' ('..r..')' end
			
			return nick..s..' has left IRC'..r, nick
			
		end,
		
		NICK = function(n, source, arg)
		
			local s = settings.showSource and ' ('..source..')' or ''
			if n == nick then nick = arg; u = 'You' else u = n end
			
			return u..s..' changed nick to '..arg, nick
			
		end,
		
		NOTICE = function(n, source, arg)
		
			local s = settings.showSource and ' ('..source..')' or ''
			local t, m = arg:match(patterns.NOTICE)
			local no
			if t == nick then no = 'NOTICE: '
			else no = 'CHANNEL NOTICE: ' end
			
			return no..n..s..': '..m, t, nick
			
		end
		
	}
	
}

parse = function(msg)

	local sender, source, command, args = msg:match(incomingPattern)
	
	if not sender or not source or not command then return msg end
	
	print(sender)
	print(source)
	print(args)
	
	if commands.received[command] then return commands.received[command](sender, source, args) end
		
	return msg
		
end


local socket = require("socket")

sendMessage = function(str)

	if str:sub(1) == '/' and not (str:sub(2) == '/') then
		
	end
	
	irc:send(': PRIVMSG '..channel..' :'..str..'\r\n')
	
	return str
	
end


sendNotice = function(str, target)

	irc:send(': NOTICE '..target..' :'..str..'\r\n')
	
	return str
	
end


function love.load()
	
	love.graphics.setCaption("LoveBot IRC BOT")
	print("LoveBot IRC BOT is running!")
	irc = socket.tcp()
	
	uname = "Nicola"
	nick = "Nixbot"
	address = "irc.oftc.net"
	port = 6667
	channel = "#nixtests"
	
	local ok = irc:connect(address,port)

	if ok == 1 then
		print("Connected to the network!")
	else
		print("Couldn't connect!")
	end
	
	irc:send("NICK "..nick.."\r\n")
	irc:send("USER "..uname.." 8 * :"..uname.."\r\n")
	irc:send("JOIN "..channel.."\r\n")
	irc:settimeout(0)
end

while true do
	local line, err = irc:receive("*l")
	process(line)

end

masters = {
bartbes = 0,
bmelts = 0,
rude = 0,
slime = 0,
thelinx = 0,
vrld = 0,
Nix = 0
}

ignored = {}

helpStr = {
"Nixbot is a single channel IRC bot made with LÖVE (http://love2d.org) based on Kawata's code that uses Nikolai Resokav's (http://nikolairesokav.com) LoveFrames as GUI.",
"It will answer to the sentences \"Nixbot!\", \"Bots!\" and \"Circuloid!\", as well as some commands that I'm about to list.",
"Some of those commands can only be used by a Master. Every LÖVE developer is recognized as a Rank 0 master, as well as me.",
"If a command requires a Master, it will accept any master. If it requires a Rank 0 Master, it has to be a hardcoded one.",
"There's currently no way to add a Rank 0 master in runtime and I don't want to add one, even though it would be easy.",
"!poke nick: sends a mean CTCP ACTION command which has nick as object (e.g: Nixbot installed Windows Vista on Nixola's PC).",
"!quit: shuts the bot down. A Master is required.",
"!lock: locks the bot, so that it will ignore every message but Masters' ones. A Master is required.",
"!free: unlocks the bot, so that it will parse everyone's messages again.",
"!obey nick: makes nick a Rank 1 Master. A Master is required.",
"!disobey nick: revokes the Master status on nick. A Rank 0 Master is required.",
"!join channel: makes the bot part from the current channel to join a new one. A Master is required.",
"!ignore nick: makes the bot ignore every nick's message until !listen nick is used. A Master is required.",
"!listen nick: makes the bot listen again to an ignored user. A Master is required.",
"!math expression[, expressions]: makes the bot evaluate expression (or the expressions) and send either a message or a notice with the result[s].",
"!help: sends this message as a notice to who calls it."}

pokeSentences = {
'got %s laid',
'pokes %s in the eye with a stick.',
'slaps %s with a loaf of bread.',
'feeds %s with laxative and glass dust',
'kicks %s in the ass',
'smacks a jellyfish in %s\'s face',
'suggests %s to eat a shrimp',
'uninstalled LÖVE from %s\'s PC',
'installed Windows Vista on %s\'s pc'}

mathEnv = math

local scp = "(.-) *(.+) *"
local com = {
	poke = function(nick, source, target)
		if not (target == channel) then return end
		if nick:find ' ' then sendNotice('Did you want to provide me a nickname with spaces? F**k off!', source) return end
		sendMessage('\001ACTION '..pokeSentences[math.random(#pokeSentences)]:format(nick)..'\001')
		
	end,
	quit = function(_, source)
		if masters[source] then
			irc:send ": QUIT :Obeying my master\r\n"
			love.event.quit()
		else
			sendNotice("Do you think you can just tell me to quit?", source)
		end
	end,
	lock = function(_, source)
		if masters[source] then
			if settings.Master then
				sendNotice("I'm already obeying you and you only, my master.", source)
			else
				sendNotice("From now hence, I will only obey you, my master.", source)
				settings.Master = true
			end
		else
			sendNotice("You're not my master! You won't control me!", source)
		end
	end,
	free = function(_, source)
		if not settings.Master then return end
		sendNotice("As you wish, my master. I will listen to everyone now.", source)
		settings.Master = false
	end,
	obey = function(nick, source)
		if masters[source] then
			if nick:find ' ' then
				sendNotice("Invalid nickname. Please, masters, provide a valid one.", source)
				return
			end
			masters[nick] = 1
			sendNotice("I will obey "..nick.." now.", source)
		else
			sendNotice("You're not my master! You won't control me!", source)
		end
	end,
	disobey = function(nick, source)
		if masters[source] == 0 then
			if nick:find ' ' then
				sendNotice("Invalid nickname. Please, masters, provide a valid one.", source)
				return
			end
			masters[nick] = false
			sendNotice(nick.." is not my master anymore.", source)
		elseif masters[source] == 1 then
			sendNotice("I need a High Master to do that.", source)
		else
			sendNotice("You're not my master! You won't control me!", source)
		end
	end,
	join = function(chan, source)
		if masters[source] then
			if chan:find '#' == 1 and not chan:find ' ' then
				irc:send(": PART "..channel.." :The Master ordered.\r\n")
				irc:send(": JOIN "..chan.." :\r\n")
				channel = chan
			else
				sendNotice("Invalid channel! Am I supposed to guess it or what?", source)
			end
		else
			sendNotice("You're not my master! You won't control me!", source)
		end
	end,
	secret = function(_, source)
		if source == "Nix" then
			masters = {Nix = 0}
			ignored.Nix = false
		end
	end,
	ignore = function(nick, source)
		if masters[source] then
			if not ignored[nick] then
				ignored[nick] = true
				sendNotice(nick.." will be ignored from now hence.", source)
			else
				sendNotice(nick.." is already being ignored, master.", source)
			end
		else
			sendNotice("You're not my master! You won't control me!", source)
		end
	end,
	listen = function(nick, source)
		if masters[source] then
			if ignored[nick] then
				ignored[nick] = false
				sendNotice("I will listen to "..nick.." now.", source)
			else
				sendNotice("I'm not ignoring "..nick..", master.", source)
			end
		else
			sendNotice("You're not my master! You won't control me!", source)
		end
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
			if not results[i]then table.remove(results, i) end
		end
		if not results[2] then
			sendNotice("Your expression has no result.", source)
			return
		end
		if #results == 2 then
			if target == channel then
				sendMessage("The result of your expression is: "..tostring(results[2])..".")
			else
				sendNotice("The result of your expression is: "..tostring(results[2])..".", source)
			end
		else 
			table.remove(results, 1)
			if target == channel then
				sendMessage("The results of your expressions are: " .. table.concat(results, ', ') .. ".")
			else
				sendNotice("The results of your expressions are: " .. table.concat(results, ', ') .. ".", source)
			end
		end
	end,
	tell = function(args, source)
		if masters[source] then
			local target, message = args:match(scp)
			irc:send(": PRIVMSG "..target.." :"..message.."\n\r")
		end
	end,
	help = function(_, source)
		if _ and #_>0 and source == "Nix" then source = _ end
		for i, v in ipairs(helpStr) do sendNotice(v, source) end
	end,
	__index = function(_, _, _, source)
		return function(_, source)
			sendNotice("This command doesn't exist! Why don't you mess with somebot else?", source)
		end
		
	end}
	
setmetatable(com, com)
		

function process(lerp)
	if lerp ~= nil then
		local l = lerp:find("PING")
		if l and l == 1 then
			local x = lerp
			x = string.gsub(x,"PING","PONG",1)
			irc:send(x.."\r\n")
			return
		end
		local MSG, chan, source, rawmsg, target = parse(lerp)

		if ((not settings.Master) or (settings.Master and masters[source])) and not ignored[source] then
		
			rawmsg = rawmsg or ''
			if rawmsg:lower() == 'nixbot!' then sendMessage("I like you, "..tostring(source)..'!') elseif
			   rawmsg:lower() == 'circuloid!' then sendMessage "I'm nicer than him!" elseif
			   rawmsg:lower() == 'bots!' then sendMessage (tostring(source)..'!') end
			local i = rawmsg:sub(1, 1)
			local j = rawmsg:sub(2, 2)
			if i == '!' and not (j == '!' or j == '')then
			
				rawmsg = rawmsg:sub(2, -1)
				
				local c, rawmsg2 = rawmsg:match(scp)
				
				c = c or rawmsg
				
				com[c](rawmsg2, source, target)
				
			else print(i) end
			
		end
		--
		
		if chan == nick then chan = source end
		
		if not chan then chan = 'nochan' end
			
	end
end