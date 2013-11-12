cookie = {}
cookie.__index = cookie
cookie.buildings = dofile 'cookie/settings.lua'
classOf = setmetatable

for i, v in ipairs(cookie.buildings) do
	cookie.buildings[v.name:lower()] = v
end

string.beautify = function(str)

	str = tostring(str)

	local decimal

	if str:find '%.' then

		str, decimal = str:match '(.+)%.(.+)'

	end

	str = str:reverse()

	while str:find '%d%d%d%d' do

		str = str:gsub('(%d%d%d)(%d)', "%1'%2", 1)

	end

	str = str:reverse()


	return str.. (decimal and '.'..decimal or '')

end


cookie.price = function(player, building)

	local quant = player[building:lower()]

	return cookie.buildings[building:lower()].price*(1.15^quant)

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

	return classOf(t, cookie)

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


cookie.command = function(query, source, silent)

	local player = cookie.loadPlayer(source)

	query = query and query:lower() or nil

	player:update()

	local action, element = string.match(query or '', "^(%S+)%s*(.*)")

	if action == 'buy' then

		local quantity
		if element:match("%S+%s+%S+") then

			element, quantity = element:match "(%S+)%s+(%S+)"

			if not (quantity == 'all' or tonumber(quantity)) then quantity = nil end

		end

		if not cookie.buildings[element] then
			sendNotice("Buildings: "..player:getPrices(), source)
			return true
		end


		local Price = player:price(element)

		if player.cookies < Price then
			sendNotice("You don't have enough cookies to buy it.", source)
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

		sendNotice("You are baking "..string.beautify(player.cps).." cookies per second.", source)
		return true

	elseif action == 'price' or action == 'prices' then

		if element and element ~= '' and not cookie.buildings[element] then
			if not silent then sendNotice("Invalid building.", source) end
			return true

		elseif element == '' then

			sendNotice(player:getPrices(), source)
			return true

		end

		sendNotice(("Your next %s will cost %s cookies."):format(element, string.beautify(player:price(element))), source)
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
			sendNotice("You have 0 "..(element == 'factory' and 'factorie' or element).."s already.", source)
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



	elseif action and not (action == '') then
		if not silent then sendNotice("Invalid action.", source) end
		return true
	end

	sendNotice(player:list(), source)
	
	player:save()
	return true
end


return cookie.command