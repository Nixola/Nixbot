--[[ LuaBot 1.0

	Author: NightKawata
	License: Free to use for anything, credit would be nice (mention my name if you're drugged enough to use this for a commercial project)
	
	THIS IS ONLY THE BARE BONES.
	THIS BOT WILL CONNECT TO ANY NETWORK YOU WANT, AND IT WILL (USUALLY) NOT PING TIMEOUT. (DEPENDS ON YOUR INTERNET)
	
	I did not design the bot to do anything more or less. :P
	
	Note by Nixola: I designed the bot to become a client! Yay!
	Also, the GUI is LoveFrames by Kenny Shields, or Nikolai Resokav. It's way more awesome than anything I could have ever made.


--]]

settings = {showSource = false}

incomingPattern = [[
:(.-)!(.-)%s(%u-)%s(.-)$]]--[[
nick  source command args--]]

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
			--if c == nick then c = ' wrote you'
			--else c = '' end
			
			return n..': '..m, chan, n, m
			
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
	
	if commands.received[command] then return commands.received[command](sender, source, args) end
		
	return msg
		
end


local socket = require("socket")

sendMessage = function(str)

	if str:sub(1) == '/' and not (str:sub(2) == '/') then
	
		--pattern
		
	end
	
	irc:send(': PRIVMSG '..channel..' :'..str..'\r\n')
	
	--print(nick .. ': ' .. str)
	
	return str
	
end


sendNotice = function(str, target)

	irc:send(': NOTICE '..target..' :'..str..'\r\n')
	
	return str
	
end


function love.load()

--	print(string.byte('è', 1, #('è')))

	--require 'repler'.load''
	
	require 'loveframes'
	
	love.frames = loveframes
	
	loveframes.util.SetActiveSkin "Silver"
	
	frame = love.frames.Create 'frame'
	
	frame:SetSize(800, 600)
	
	frame:Center()
	
	tabs = love.frames.Create('tabs', frame)
	
	tabs:SetPos(4, 4)
	
	tabs:SetSize(792, 562)
	
	local loveIRC = love.frames.Create('list', frame)
	
	loveIRC:SetAutoScroll(true)
	
	tabs:AddTab('#love', loveIRC, '#love')
	
	tabsList = {}
	
	tabsList['#love'] = {id = 1, list = loveIRC}
	
	tabsList.len = 1
	
	messageBar = love.frames.Create('textinput', frame)
	
	messageBar:SetPos(4, 600-32)
	
	messageBar:SetWidth(800-8)
	
	messageBar.OnEnter = function(self, text)
	
		sendMessage(text)
		self:Clear()
		
	end
	
	love.graphics.setCaption("LoveBot IRC BOT") -- yeah
	print("LoveBot IRC BOT is running!") -- oh yeah
	irc = socket.tcp() -- now let's actually bother with networking code
	
	
	-- CONFIGURATION
	uname = "Nicola"
	nick = "Nixbot"
	address = "irc.oftc.net"
	port = 6667
	channel = "#nixtests"
	
	-- now connect to the server
	local ok = irc:connect(address,port)
	-- what do you THINK this does
	if ok == 1 then
		print("Connected to the network!")
	else
		print("Couldn't connect!")
	end
	
	irc:send("NICK "..nick.."\r\n") -- set a nickname
	irc:send("USER "..uname.." 8 * :"..uname.."\r\n")
	--socket.sleep(2.0) -- delay a bit
	irc:send("JOIN "..channel.."\r\n") -- now join a channel
	irc:settimeout(0) -- yeah
end

function love.update(dt)
	-- process data
	local line, err = irc:receive("*l")
	process(line)
	-- that was easy
	loveframes.update(dt)
end

function love.draw()
	-- SHAMELESS PLUGGING
	--love.graphics.print("I didn't put anything here.\nDraw stuff here!\nYour choice!\nI'm not you, so do something!",0,0)
	--love.graphics.print("Created by NightKawata!\nSupport his work!",0,195)
	loveframes.draw()
end

function love.keypressed(k, u)
	if k == "escape" then
		love.event.push("quit")
	end
	loveframes.keypressed(k, u)
end

function love.keyreleased(k, u)

	loveframes.keyreleased(k, u)
	
end

function love.mousepressed(x, y, b)

	loveframes.mousepressed(x, y, b)
	
end

function love.mousereleased(x, y, b)

	loveframes.mousereleased(x, y, b)
	
end

love.quit = function()

	--irc:send ": QUIT :Reboot routine initiated\r\n"
	
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
"It will answer to te sentences \"Nixbot!\", \"Bots!\" and \"Circuloid!\", as well as some commands that I'm about to list.",
"Some of those commands can only be used by a Master. Every LÖVE developer is recognized as a Rank 0 master, as well as me.",
"If a command requires a Master, it will accept any master. If it requires a Rank 0 Master, it has to be a hardcoded one.",
"There's currently no way to add a Rank 0 master in runtime and I don't want to add one, even though it would be easy.",
"!poke nick: sends a mean CTCP ACTION command which has nick as object (e.g: Nixbot installed Windows Vista on Nixola's PC).",
"!quit: shuts the bot down. A Master is required.",
"!lock: locks the bot, so that it will ignore every message but Masters' ones. A Master is required.",
"!free: unlocks the bot, so that it will parse everyone's messages again.",
"!obey nick: makes nick a Rank 1 Master. A Master is required.",
"!disobey nick: revokes the Master status on Nix. A Rank 0 Master is required.",
"!join channel: makes the bot part from the current channel to join a new one. A Master is required.",
"!ignore nick: makes the bot ignore every nick's message until !listen nick is used. A Master is required.",
"!listen nick: makes the bot listen again to an ignored user. A Master is required.",
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

local scp = "(.-) (.+)"
local com = {
	poke = function(nick, source)
		if nick:find ' ' then sendNotice('Did you want to provide me a nickname with spaces? F**k off!', source) return end
		sendMessage('\001ACTION '..pokeSentences[math.random(#pokeSentences)]:format(nick)..'\001')
		--irc:send(": ACTION :"..pokeSentences[math.random(#pokeSentences)]:format(nick).."$")
		
	end,
	quit = function(_, source)
		if masters[source] then
			sendMessage "Yes, master. Initiating shutdown routine..."
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
				sendMessage "From now hence, I will only obey you, my masters."
				settings.Master = true
			end
		else
			sendNotice("You're not my master! You won't control me!", source)
		end
	end,
	free = function()
		if not settings.Master then return end
		sendMessage "As you wish, my masters. I will listen to everyone now."
		settings.Master = false
	end,
	obey = function(nick, source)
		if masters[source] then
			if nick:find ' ' then
				sendNotice("Invalid nickname. Please, masters, provide a valid one.", source)
				return
			end
			masters[nick] = 1
			sendMessage("I will obey "..nick.." now.")
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
			sendMessage(nick.." is not my master anymore.")
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
	help = function(_, source)
		for i, v in ipairs(helpStr) do sendNotice(v, source) end
	end,
	__index = function(_, _, _, source)
		return function(_, source)
			sendNotice("This command doesn't exist! Why don't you mess with somebot else?", source)
		end
		
	end}
	
setmetatable(com, com)
		

function process(lerp)
	-- SHAMELESS ALGORITHIM
	if lerp ~= nil then --print(lerp)
		local l = lerp:find("PING")
		if l and l == 1 then -- if the bot gets pinged
			local x = lerp -- get the message so we also know which server
			x = string.gsub(x,"PING","PONG",1) -- now replace ping with pong ONLY ONCE
			irc:send(x.."\r\n") -- send it back
			--print(x) --I used that to make sure it worked
			return
		end
		local MSG, chan, source, rawmsg = parse(lerp)
		
		--if source == 'josePHPagoda' then sendMessage "JesseH" end
		
		--
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
				
				pcall(com[c], rawmsg2, source)
				
			else print(i) end
			
		end
		--
		
		if chan == nick then chan = source end
		
		if not chan then chan = 'nochan' end
		
		if not tabsList[chan] then
		
			local list = love.frames.Create('list', frame)
			list:SetAutoScroll(true)
			tabs:AddTab(chan, list, chan)
		
			tabsList[chan] = {id = tabsList.len+1, list = list}
			
			tabsList.len = tabsList.len + 1
			
		end
		
		local text = love.frames.Create('text', frame)
			
		text:SetText(MSG)
		
		tabsList[chan].list:AddItem(text)
			
	end
end