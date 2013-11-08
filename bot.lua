incomingPattern = [[
:(.-)!(.-)%s(%u-)%s(.-)$]]
patterns = {

	JOIN = '%:(.-)$',
	PART = '(%S+)%s*%:*(.*)',
	PRIVMSG = '(%S+)%s%:(.*)',
	QUIT = ':*(.*)',
	NOTICE = '(%S+)%s%:(.*)'
}

messages = {}

urlify = function(str)
  if (str) then
    str = string.gsub (str, "\n", "\r\n")
    str = string.gsub (str, "([^%w %-%_%.%~])",
        function (c) return string.format ("%%%02X", string.byte(c)) end)
    str = string.gsub (str, " ", "+")
  end
  return str	
end

commands = {

	received = {

		JOIN = function(nick, source, arg)

			local s = settings.showSource and ' ('..source..')' or ''

			local chan = arg:match(patterns.JOIN)

			local c = chan and ' '..chan or ''

			return nick..s..' has joined'..c, chan, nick

		end,

		PART = function(nick, source, args)

			local s = settings.showSource and ' ('..source..')' or ''
			local chan, r = args:match(patterns.PART)
			if #r > 0 then r = ' ('..r..')' end

			return nick..s..' has left the channel'..r, chan, nick

		end,

		PRIVMSG = function(nick, source, args)

			local s = settings.showSource and ' ('..source..')' or ''
			local target, message = args:match(patterns.PRIVMSG)
			if not (target == bot.channel) then
				local f = io.open('logs/'..nick, 'a')
				f:write(message)
				f:write '\n'
				f:close()
			end

			if target == bot.channel and message and nick then

				--table.insert(messages, '<'..nick..'> '..message)

			end

			return target, nick, message

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

	if not sender or not source or not command then 

		print(msg)
		return msg

	end

	if commands.received[command] then

		print(sender..'|'..args..'\n')
		return commands.received[command](sender, source, args)

	end

	return msg

end

sendMessage = function(str)

	irc:send(': PRIVMSG '..bot.channel..' :'..str..'\r\n')

	print(bot.nick..'|'..bot.channel..' :'..str..'\n')

	return str

end


sendNotice = function(str, target)

	irc:send(': NOTICE '..target..' :'..str..'\r\n')

	return str

end


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
'pokes %s in the eye with a stick.',
'slaps %s with a loaf of bread.',
'feeds %s with laxative and glass dust',
'kicks %s in the ass',
'smacks a jellyfish in %s\'s face',
'suggests %s to eat a shrimp',
'uninstalled LÖVE from %s\'s PC',
'installed Windows Vista on %s\'s pc'}

local mathEnv = math

local scp = "(.-)%s+(.+)%s*"
local com = {
	poke = function(nick, source, target)
		if not (target == bot.channel) then return end
		if nick:find ' ' then sendNotice('Did you want to provide me a nickname with spaces? F**k off!', source) return end
		sendMessage('\001ACTION '..pokeSentences[math.random(#pokeSentences)]:format(nick)..'\001')
		return true
	end,
	quit = function(_, source)
		if masters[source] then
			irc:send ": QUIT :Obeying my master\r\n"
			quit = true
		else
			sendNotice("Do you think you can just tell me to quit?", source)
		end
		return true
	end,
	reboot = function(_, source)
		if masters[source] then
			irc:send ": QUIT :Rebooting\r\n"
			reload = true
		else
			sendNotice("Do you think you can just tell me to reboot?", source)
		end
		return true
	end,
	reload = function(_, source)
		if masters[source] then
			dofile 'bot.lua'
			sendNotice("bot.lua reloaded, master.", source)
		else
			sendNotice("Nope.", source)
		end
		return true
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
		return true
	end,
	free = function(_, source)
		if not settings.Master then return end
		sendNotice("As you wish, my master. I will listen to everyone now.", source)
		settings.Master = false
		return true
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
		return true
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
		return true
	end,
	join = function(chan, source)
		if masters[source] then
			if chan:find '#' == 1 and not chan:find ' ' then
				irc:send(": PART "..bot.channel.." :The Master ordered.\r\n")
				irc:send(": JOIN "..chan.." :\r\n")
				bot.channel = chan
			else
				sendNotice("Invalid channel! Am I supposed to guess it or what?", source)
			end
		else
			sendNotice("You're not my master! You won't control me!", source)
		end
		return true
	end,
	secret = function(_, source)
		if source == "Nix" then
			masters = {Nix = 0}
			ignored.Nix = false
			sendNotice("You're my only true master, Nix. I won't ever trust anyone else.", source)
		end
		return true
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
		return true
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
			if not results[i]then table.remove(results, i) end
		end
		if not results[2] then
			sendNotice("Your expression has no result.", source)
			return
		end
		if #results == 2 then
			if target == bot.channel then
				sendMessage("The result of your expression is: "..tostring(results[2])..".")
			else
				sendNotice("The result of your expression is: "..tostring(results[2])..".", source)
			end
		else 
			table.remove(results, 1)
			if target == bot.channel then
				sendMessage("The results of your expressions are: " .. table.concat(results, ', ') .. ".")
			else
				sendNotice("The results of your expressions are: " .. table.concat(results, ', ') .. ".", source)
			end
		end
		return true
	end,
	tell = function(args, source)
		if masters[source] then
			local target, message = args:match(scp)
			irc:send(": PRIVMSG "..target.." :"..message.."\n\r")
		end
		return true
	end,
	lua = function(code, source, target)
		local f = io.open('code.lua', 'w')
		f:write(code)
		f:close()
		os.execute("ulimit -t 1 && lua -l sandbox code.lua > out 2>&1")
		f = io.open("out", 'r')
		local t = f:read '*a'
		f:close()
		t = t:gsub('\n', '; ')
		if #t > 400 then t = t:sub(1, 395)..'[...]' end
		t = source..': '..t
		if target == bot.channel then sendMessage(t)
		else sendNotice(t, source)
		end
		return true
	end,
	google = function(query, source, target)
		local q = urlify(query)
		if not q then sendNotice("Give me a valid string to search!", source) end
		if target == bot.channel then
			sendMessage(source..": http://lmgtfy.com/?q="..q)
		else
			sendNotice("http://lmgtfy.com/?q="..q, source)
		end
		return true
	end,
	export = function(_, source)
		if masters[source] then
			if _ == 'clear' then messages = {} return end
			local f, err = io.open('logs/export', 'w')
			if not f then
				sendNotice("I'm sorry for disappointing you, my master. I could not open the file. "..err, source)
			else
				for i, v in ipairs(messages) do f:write(v) f:write '\n' end
				f:close()
			end
		end
		return true
	end,
	s = function(query, source, target)
		local pattern, out = query:match "^(.+)%s+(.+)$"
		if not pattern then pattern = query end
		if pattern == '' then 
			sendNotice("Hey! This is invalid! Fix it!", source)
		else
			for i = #messages, 1, -1 do
				local v = messages[i]
				local success, result = pcall(string.match, v, pattern)
				if not success then sendNotice('Nice try. '..result, source) return end
				if result then
					sendMessage(v:gsub(pattern, out or ''))
					return
				end
			end
			sendNotice("No message matching your query was found.", source)
		end
		return true
	end,
	help = function(_, source)
		if _ and #_>0 and source == "Nix" then source = _ end
		for i, v in ipairs(helpStr) do sendNotice(v, source) end
		return true
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
		local chan, source, rawmsg = parse(lerp)

		local r

		if ((not settings.Master) or (settings.Master and masters[source])) and not ignored[source] then

			rawmsg = rawmsg or ''
			if rawmsg:lower() == bot.nick:lower()..'!' then sendMessage(source..'!') elseif
			   rawmsg:lower() == 'circuloid!' then sendMessage "I'm nicer than him!" end
			local i = rawmsg:sub(1, 1)
			local j = rawmsg:sub(2, 2)
			if i == '!' and not (j == '!' or j == '')then

				rawmsg = rawmsg:sub(2, -1)

				local c, rawmsg2 = rawmsg:match(scp)

				c = c or rawmsg

				local r = com[c](rawmsg2, source, chan)
			end

			if r or source == bot.nick then return end
			table.insert(messages, '<'..source..'> '..rawmsg)
		end
	end
end