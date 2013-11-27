local cookie = {}
cookie.__index = cookie
cookie.buildings = dofile 'cookie/settings.lua'
local classOf = setmetatable

lastCookie = {}

for i, v in ipairs(cookie.buildings) do
	cookie.buildings[v.name:lower()] = v
end

string.beautify = function(n)

        str = tostring(n)

        n = tonumber(n)

        local decimal

        if str:find '%.' then

                str, decimal = str:match '(.+)%.(.+)'

        end

        if n >= 100 then

            decimal = nil

        end

        str = str:reverse()

        while str:find '%d%d%d%d' do

                str = str:gsub('(%d%d%d)(%d)', "%1 %2", 1)

        end

        str = str:reverse()


        return str.. (decimal and ','..decimal or '')

end


ls = function(path)

    local f = io.popen('ls '..path, 'r')                                                                                            
    local files = {}                                                                                     
    for file in f:lines() do                                                                                                        
        if not (file:match'.+%.lua$' or file:match '.+%.txt' or file == 'bac') then                                                 
            table.insert(files, file)                                                                                               
        end                                                                                                                         
    end                                                                                                                             
    f:close()

    return files
end

cookie.price = function(player, building, quantity)

	quantity = quantity or 1

	local quant = player[building:lower()]

	local s = 0

	for i = 0, quantity-1 do

		s = s + cookie.buildings[building:lower()].price*(1.15^(quant+i))

	end

	return s

end


cookie.loadPlayer = function(name)

	local f = io.open("cookie/"..name, 'rw')
	local t = {name = name}
	local l = f and f:read '*l' or os.time()
	t.lastTime = tonumber(string.match(l, int))
	t.cookies = tonumber(string.match(f and f:read '*l' or 1, float))

	for i, v in ipairs(cookie.buildings) do
		t[v.name:lower()] = tonumber(string.match(f and f:read '*l' or 0, int))
	end
	local _ = f and f:close()

	return classOf(t, cookie), f ~= nil

end


cookie.save = function(player)

	local f = io.open('cookie/'..player.name, 'w')

	f:write(player.time, ' last time\n')

	f:write(player.cookies, ' cookies\n')

	for i, v in ipairs(cookie.buildings) do

		f:write(player[v.name:lower()], ' ', v.name, 's\n')

	end

	f:close()

end


cookie.update = function(player)

	player.time = os.time()
	local dt = player.time - player.lastTime
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


cookie.list = function(player)

	local str = 'You have %s cookies%s.'

	str = str:format(string.beautify(math.floor(player.cookies)), '%s')

	local list = {}

	for i, v in ipairs(cookie.buildings) do

		if player[v.name:lower()] > 0 then

			list[#list+1] = {name = v.name, i = i}

		end

	end
	--another for

	for i, v in ipairs(list) do

		local name

		if v.name == 'factory' and player.factory > 1 then
			name = 'factorie'
		else
			name = v.name
		end

		if list[i+1] then

			str = str:format(', '..player[v.name:lower()]..' '..name..(player[v.name:lower()] == 1 and '' or 's')..'%s')

		else

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

		local Price = cookie.buildings[v.name:lower()].price*(1.15^player[v.name:lower()])
		
		str = str .. v.name..': '..string.beautify(math.ceil(Price))..'¢; '

	end

	return str

end


cookie.command = function(query, source, target, silent)

	local player = cookie.loadPlayer(source)

	query = query or nil

	local action, element = string.match(query or '', "^(%S+)%s*(.*)")

	local Oaction, Oelement = action, element

	action = action or ''
	element = element or ''

	action, element = action:lower(), element:lower()

	if action == '' then

		if lastCookie[source] and lastCookie[source] >= os.time() then
			lastCookie[source] = lastCookie[source] + 1
			reply(source, target, ("You can't use ,cookie more than once a second. Wait %d seconds before using it."):format(lastCookie[source]-os.time()))
			return true
		else
			lastCookie[source] = os.time()
		end

	end

	player:update()

	if action == 'buy' or action == 'but' or action == 'butt' then

		local quantity
		if element:match("%S+%s+%S+") then

			element, quantity = element:match "(%S+)%s+(%S+)"

			if not (quantity == 'all' or tonumber(quantity)) then quantity = nil end

		end

		if not cookie.buildings[element] then
			reply(source, target, "Buildings: "..player:getPrices())
			return true
		end


		local Price = player:price(element)

		if player.cookies < Price then
			reply(source, target, "You don't have enough cookies to buy it.")
			return true
		end

		player[element] = player[element] + 1
		player.cookies = player.cookies - Price

		if quantity then

			for i = 1, (quantity == 'all' and 6/0 or tonumber(quantity)-1) do

				Price = player:price(element)
				if player.cookies < Price then
					break
				end

				player[element] = player[element] + 1
				player.cookies = player.cookies - Price

			end

		end

	elseif action == 'cps' then

		reply(source, target, "You are baking "..string.beautify(player.cps).." cookies per second.")
		return true

	elseif action == 'price' or action == 'prices' then

		local e, q = element:match "(%S+)%s+(%S+)"

		element = e or element

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


		reply(source, target, ("Your next%s %s will cost %s¢."):format((q and ' '..q or ''), building or element, string.beautify(math.ceil(player:price(element, q)))))
		return true

	elseif action == 'help' then
		com.help('cookie', source)
		return true

	elseif action == 'sell' then

		local quantity
		if element:match("%S+%s+%S+") then

			element, quantity = element:match "(%S+)%s+(%S+)"

			if not (quantity == 'all' or tonumber(quantity)) then quantity = nil end

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
		for match in Oelement:gmatch "([^%s]+)" do
			local p, exists = cookie.loadPlayer(match)
			if not exists then
				if not silent then
					sendNotice(match.." doesn't even exist.", source)
				end
			else
				skip = false
				p:update()
				answer = answer .. ans:format(p.name, string.beautify(math.floor(p.cookies)), string.beautify(p.cps)) .. '; '
			end
		end
		if skip then return true end
		answer = answer:sub(1, -3)
		reply(source, target, answer)
		return true

	elseif action == 'rank' then

		local files = ls('cookie')
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

		ans = ans:sub(1, -3)

		reply(source, target, ans)
		return true

	elseif not (action == '') then
		if not silent then sendNotice("Invalid action.", source) end
		return true
	end

	reply(source, target, player:list())
	
	player:save()
	return true
end


return {command = cookie.command, module = cookie}
