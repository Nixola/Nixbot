local cookie = {}
cookie.__index = cookie
cookie.buildings = dofile 'cookie/settings.lua'
cookie.buildings.list = "|cursor|grandma|farm|factory|mine|shipment|alchemylab|portal|timemachine|antimattercondenser|"
cookie.actionsList = "|show|buy|cps|prices|sell|ranks|help|"
cookie.autocomplete = function(list, str)

    str = str:gsub("[^a-zA-Z0-9]", function(p) return '%'..p end)

    local building
    local _, n = list:gsub('|('..str..'.-)%|', function(p) building = p return '' end)
    if n == 1 then return building
    else return nil, n end

end

ls = ls or function(path)

    local f = io.popen("ls "..path)
    local t = {}
    for file in f:lines() do
        t[#t+1] = file
    end
    return t
end

local classOf = setmetatable

lastCookie = {}

for i, v in ipairs(cookie.buildings) do
    cookie.buildings[v.name:lower()] = v
end

realTime = function(s)

    local secs = math.floor(s%60)

    local mins = math.floor(s%3600/60)

    local hours = math.floor(s%(3600*24)/3600)

    local days = math.floor(s%(3600*24*7)/3600/24)

    local weeks = math.floor(s/3600/24/7)

    local ans = ''

    ans = ans .. (weeks>0 and weeks..' weeks, ' or '')
    ans = ans .. (days >0 and days.. ' days, ' or '')
    ans = ans .. (hours>0 and hours..' hours, ' or '')
    ans = ans .. (mins >0 and mins.. ' minutes, ' or '')
    ans = ans .. (secs >0 and secs.. ' seconds, ' or '')

    ans = ans:sub(1, -3)

    return ans
end

string.beautify = function(n)
        
    n = tonumber(n)

    str = string.format('%f', n)

    local decimal

    if str:find '%.' then

        str, decimal = str:match '(.+)%.(.+)'

    end

    if n >= 100 or n%1 <= 0.01 then

        decimal = nil

    end

    str = str:reverse()

    while str:find '%d%d%d%d' do

            str = str:gsub('(%d%d%d)(%d)', "%1 %2", 1)

    end

    str = str:reverse()

    return str.. (decimal and ','..decimal or '')

end

cookie.empty = [[
lasttime:0;
cookies:0;
cursor:0;
grandma:0;
farm:0;
factory:0;
mine:0;
shipment:0;
alchemylab:0;
portal:0;
timemachine:0;
antimattercondenser:0;
]]

cookie.price = function(player, building, quantity)

	quantity = quantity or 1

	local quant = player[building:lower()]
    --[[
	local s = 0

	for i = 0, quantity-1 do

		s = s + cookie.buildings[building:lower()].price*(1.15^(quant+i))

	end--]]

    local X = cookie.buildings[building:lower()].price

    local Y = quant

    local n = quantity

    s = (-1/3)*(20^n-23^n)*X*(23^Y)*(20^(-n-Y+1))

	return s == s and s

end

--[[
cookie.loadPlayer = function(name)

    local fname = name:lower()
	local f = io.open("cookie/saves/"..fname, 'rw')
	local t = {name = name}
	local l = f and f:read '*l' or os.time()
	t.lastTime = tonumber(string.match(l, int))
	t.cookies = tonumber(string.match(f and f:read '*l' or 0, float))

	for i, v in ipairs(cookie.buildings) do
		t[v.name:lower()] = tonumber(string.match(f and f:read '*l' or 0, int))
	end
	local _ = f and f:close()

	return classOf(t, cookie), f ~= nil

end--]]

cookie.loadPlayer = function(nick)
    local fname = nick:lower()
    local f = io.open("cookie/saves/"..fname, 'r')
    local t = {name = nick}
    local raw = f and f:read '*a' or cookie.empty
    if f then f:close() end
    raw = raw:gsub('\n', '')
    for statement in raw:gmatch("[^%;]+") do
        local i, v = statement:match "(.+)%:(.+)"
        if i and v then
            t[i:lower()] = tonumber(v)
        end
    end
    return setmetatable(t, cookie), f ~= nil
end


cookie.save = function(player)

	local f = io.open('cookie/saves/'..player.name:lower(), 'w')

	f:write('lasttime:', player.time or os.time(), ';\n')

	f:write('cookies:', player.cookies, ';\n')

	for i, v in ipairs(cookie.buildings) do

		f:write(v.name:lower(), ':', player[v.name:lower()], ';\n')

	end

	f:close()

end


cookie.update = function(player)

	player.time = os.time()
	local dt = player.time - player.lasttime
	local cps = 0

	for i, v in ipairs(cookie.buildings) do
		local cs = cookie.buildings[v.name:lower()].cps
		local quant = player[v.name:lower()]
		player.cookies = player.cookies + quant*dt*cs
		cps = cps + quant*cs
	end

	player.cookies = player.cookies + 1
	player.cps = cps

end


cookie.list = function(player, el)

	local str = 'You have %s cookies%s.'

	str = str:format(string.beautify(math.floor(player.cookies)), '%s')

	local list = {}
    
    if el then

        list[1] = {name = el, i = player[el]}

    else

    	for i, v in ipairs(cookie.buildings) do

	    	if player[v.name:lower()] > 0 then

		    	list[#list+1] = {name = v.name, i = i}

	    	end 

    	end

    end

	--another for

	for i, v in ipairs(list) do

		local name

        local vname = v.name:lower()

		if vname == 'factory' and player.factory > 1 then
			name = 'factorie'
		else
			name = vname
		end

		if list[i+1] then

			str = str:format(', '..player[v.name:lower()]..' '..name..(player[v.name:lower()] == 1 and '' or 's')..'%s')

		else

            print("DEBUG: ", "."..v.name:lower()..".")

			str = str:format(' and '..player[v.name:lower()]..' '..name..(player[v.name:lower()] == 1 and '' or 's'))

		end

	end
	--end another for

	str = str:gsub('%%s', '')

	return str

end


cookie.getPrices = function(player)

	local str = ''

	for i, v in ipairs(cookie.buildings) do

		local Price = player:price(v.name:lower())

        Price = Price and string.beautify(math.ceil(Price)) or "NaN - contact Nix"
		
		str = str .. v.name..': '..Price..'¢; '

	end

	return str

end


cookie.command = function(query, source, target, silent)

    local player = cookie.loadPlayer(source)

    query = query and query:lower() or ''

    query = query:match "^%s*(.-)%s*$"
    
    local action, element = string.match(query or '', "^(%S+)%s*(.*)")

    local Oaction, Oelement = action, element

    action = action or ''
    element = element or ''

    action, element = action:lower(), element:lower()

    local a, n = cookie.autocomplete(cookie.actionsList, action)

    if action == '' then a = action end

    if a then action = a
    else local _ = not silent and reply(source, target, n == 0 and "That action doesn't exist." or "Please be more specific.")
    end

    if action == '' then

        if target == bot.channel then
            return true
        end
        if lastCookie[source] and lastCookie[source] >= os.time() then
            lastCookie[source] = lastCookie[source] + 1
            reply(source, target, ("You can't use ,cookie more than once a second. Wait %d seconds before using it."):format(lastCookie[source]-os.time()))
            return true
        else
            lastCookie[source] = os.time()
        end

    end

    player:update()

    local bought

    element = element:match "^%s*(.-)%s*$"

    if action == 'buy' then

        if target == bot.channel then
            return true
        end

        local quantity, Oel
        if element:match("%S+%s+%S+") then

            element, quantity = element:match "(%S+)%s+(%S+)"
            Oel = Oelement:match "(%S+)%s+%S+"
            quantity = tonumber(quantity) or cookie.autocomplete('|all|', quantity)

        else

            Oel = Oelement

        end

        if not (element == '') then
            local b, n = cookie.autocomplete(cookie.buildings.list, element)

            if not b then
                local _ = not silent and reply(source, target, n == 0 and "There's no such building." or "Please be more accurate.")
                return true
            else
                element = b
            end
        end

        if not cookie.buildings[element] then
            reply(source, target, "Buildings: "..player:getPrices())
            return true
        end


	local Price = player:price(element, quantity ~= 'all' and quantity)

        if not Price then

            reply(source, target, element.."'s price is NaN (Not a Number), maybe you have too many? Contact Nix about this, including "..quantity)
            return true

        end

        if player.cookies < Price then
            local diff = Price-player.cookies
            local cps = player.cps
            local secs = diff/cps
            
            reply(source, target, "You need "..string.beautify(diff).." more cookies to buy "..((quantity == 1 or not quantity) and "it." or "them.") .. " With your current cps rate, "..(secs < math.huge and "it will take you "..realTime(secs).."." or " you will never be able to."))
            return true
        end

        Price = player:price(element)

        player[element] = player[element] + 1
        player.cookies = player.cookies - Price
        bought = element

        if quantity then

            for i = 1, (quantity == 'all' and 6/0 or tonumber(quantity)-1) do

                Price = player:price(element)
                if not Price then 
                    reply(source, target, element.."'s price is NaN (Not a Number), maybe you have too many? Contact Nixola about this, including "..quantity)
                    break
                end
                if player.cookies < Price then
                    break
                end

                player[element] = player[element] + 1
                player.cookies = player.cookies - Price

            end

        end

	elseif action == 'cps' then

        if target == bot.channel then
            return true
        end

		reply(source, target, "You are baking "..string.beautify(player.cps).." cookies per second.")
		return true

	elseif action == 'price' or action == 'prices' then

        if target == bot.channel then
            return true
        end

		local e, q = element:match "(%S+)%s+(%S+)"

		element = e or element

        local b, n = cookie.autocomplete(cookie.buildings.list, element)
        if not (element == '') then
            if not b then
                local _ = not silent and reply(source, target, n == 0 and "There's no such building." or "Please be more accurate.")
                return true
            else
                element = b
            end
        end

		if element and element ~= '' and not cookie.buildings[element] then
			if not silent then sendNotice("Invalid building.", source) end
			return true

		elseif element == '' then

			reply(source, target, player:getPrices())
			return true

		end

		local building
		if not tonumber(q) or tonumber(q) <= 1 then 
			q = nil 
		else
			building = element
			building = building == 'factory' and 'factories' or building..'s'

		end

        local price = player:price(element, q)

        price = price and string.beautify(price) or "NaN"
		reply(source, target, ("Your next%s %s will cost %s¢."):format((q and ' '..q or ''), building or element,price))
		return true

	elseif action == 'help' then
		bot.commands.help('cookie', source)
		return true

	elseif action == 'sell' then

        if target == bot.channel then
            return true
        end

		local quantity
		if element:match("%S+%s+%S+") then

			element, quantity = element:match "(%S+)%s+(%S+)"

			if not (quantity == 'all' or tonumber(quantity)) then quantity = nil end

		end

        local b, n = cookie.autocomplete(cookie.buildings.list, element) 

        if not b then
            local _ = not silent and reply(source, target, n == 0 and "There's no such building." or "Please be more accurate.")
            return true
        else
            element = b
        end

		if not cookie.buildings[element] then
			if not silent then sendNotice("Invalid building.", source) end
			return true
		end

		if player[element] == 0 then
			reply(source, target, "You have 0 "..(element == 'factory' and 'factorie' or element).."s already.")
			return true
		end

		local Price = player:price(element)/2

		player.cookies = player.cookies + Price
		player[element] = player[element] - 1

		if quantity then

			for i = 1, (quantity == 'all' and 6/0 or tonumber(quantity)-1) do

				Price = player:price(element)/2
				if player[element] == 0 then
					break
				end

				player[element] = player[element] - 1
				player.cookies = player.cookies + Price

			end

		end

	elseif action == 'show' then
		local ans, answer = "%s: cookies = %s, cps = %s", ''
		local skip = true
        local p, exists
		for match in Oelement:gmatch "([^%s]+)" do
			p, exists = cookie.loadPlayer(match)
			if not exists then
				if not silent then
					sendNotice(match.." doesn't even exist.", source)
				end
			else
				skip = false
				p:update()
				answer = answer .. ans:format(p.name, string.beautify(math.floor(p.cookies)), string.beautify(p.cps))
                answer = answer .. ", http://nixo.ga/?player=" .. p.name .." ; "
			end
		end
		if skip then return true end
		reply(source, target, answer:sub(1, -4))
		return true

	elseif action == 'rank' or action == 'ranks' then

		local files = ls('cookie/saves')
        local rank = tonumber(Oelement) or Oelement
		local players = {}
		for i, v in ipairs(files) do
			players[i] = cookie.loadPlayer(v)
			players[v] = players[i]
			players[i]:update()
		end
		table.sort(players, function(a, b) return a.cps > b.cps end)

		for i, v in ipairs(players) do

			v.rank = i

		end

		local a = "%d: %s (%s cps); "
		local ans = ''

		if rank == '' then

			for i = 1, #players > 5 and 5 or #players do

				ans = ans .. a:format(i, players[i].name, string.beautify(players[i].cps))

			end

		elseif not players[rank] then

			reply(source, target, "That player ("..rank..") doesn't exist.")
			return true

		else

			local v = players[rank]
			
			ans = a:format(v.rank, v.name, string.beautify(v.cps))

		end

		ans = ans .. "Leaderboard: http://nixo.ga/?ranks"

		reply(source, target, ans)
		return true

	elseif not (action == '') then
		if not silent then sendNotice("Invalid action.", source) end
		return true
	end

	reply(source, target, player:list(bought))
	
	player:save()
	return true
end

if bot then
  bot.commands:register("cookie", cookie.command)
end

return {command = cookie.command, module = cookie}
