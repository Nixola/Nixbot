cookie = {}
cookie.__index = cookie
cookie.buildings = {
	{name = 'cursor'; cps = 0.02, price = 10},
	{name = 'grandma'; cps = 0.1, price = 66},
	{name = 'farm'; cps = 0.4, price = 166},
	{name = 'factory'; cps = 1, price = 2000},
	{name = 'mine'; cps = 4, price = 6666},
	{name = 'shipment'; cps = 10, price = 13333},
	{name = 'alchemyLab'; cps = 40, price = 66665},
	{name = 'portal'; cps = 666.6, price = 1111110},
	{name = 'timeMachine'; cps = 9876.5, price = 82304526},
	{name = 'antimatterCondenser'; cps = 99999.9, price = 2666666666}
}
classOf = setmetatable

for i, v in ipairs(cookie.buildings) do
	cookie.buildings[v.name] = v
end

local int = "(%d+).*"
local float="(%d+%.?%d*).*"


cookie.loadPlayer = function(name)

	local f = io.open("cookie/"..name, 'rw')
	local t = {name = name}
	local l = f:read '*l'
	t.lastTime = tonumber(string.match(l or os.time(), int))
	t.cookies = tonumber(string.match(f:read '*l' or 1, float))

	for i, v in ipairs(cookie.buildings) do
		t[v.name] = tonumber(string.match(f:read '*l' or 0, int))
	end
	f:close()

	return classOf(t, cookie)

end


cookie.save = function(player)

	local f = io.open('cookie/'..player.name, 'w')

	f:write(player.time, ' last time\n')

	f:write(player.cookies, ' cookies\n')

	for i, v in ipairs(cookie.buildings) do

		f:write(player[v.name], ' ', v.name, 's\n')

	end

	f:close()

end


cookie.update = function(player)

	player.time = os.time()
	local dt = player.time - player.lastTime
	local cps = 0

	for i, v in ipairs(cookie.buildings) do
		player.cookies = player.cookies + player[v.name]*dt*cookie.buildings[v.name].cps
		cps = cps + player[v.name]*cookie.buildings[v.name].cps
	end

	player.cookies = player.cookies + 1
	player.cps = cps

end


cookie.list = function(player)

	local str = 'You have %d cookies%s.'

	str = str:format(player.cookies, '%s')

	for i, v in ipairs(cookie.buildings) do

		local name

		if v.name == 'factory' and player.factory > 1 then
			name = 'factor'
		else
			name = v.name
		end

		if cookie.buildings[i+1] and player[cookie.buildings[i+1].name] > 0 then

			str = str:format(', '..player[v.name]..' '..name..(player[v.name] == 1 and '' or 's')..'%s')

		else

			str = str:format(' and '..player[v.name]..' '..name..(player[v.name] == 1 and '' or 's'))

		end

	end

	return str

end


cookie.getPrices = function(player)

	local str = ''

	for i, v in ipairs(cookie.buildings) do

		local Price = cookie.buildings[v.name].price*(1.15^player[v.name])
		
		str = str .. v.name..': '..math.ceil(Price)..'¢; '

	end

	return str

end


cookie.command = function(query, source)

	local player = cookie.loadPlayer(source)

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


		local Price = cookie.buildings[element].price*(1.15^player[element])

		if player.cookies < Price then
			sendNotice("You don't have enough cookies to buy it.", source)
			return true
		end

		player[element] = player[element] + 1
		player.cookies = player.cookies - Price

		if quantity then

			for i = 1, (quantity == 'all' and 6/0 or tonumber(quantity)) do

				Price = cookie.buildings[element].price*(1.15^player[element])
				if player.cookies < Price then
					break
				end

				player[element] = player[element] + 1
				player.cookies = player.cookies - Price

			end

		end

	elseif action == 'cps' then


		sendNotice("You are baking "..player.cps.." cookies per second.", source)
		return true

	elseif action == 'price' or action == 'prices' then

		if element and element ~= '' and not cookie.buildings[element] then
			sendNotice("Invalid building.", source)
			return true

		elseif element == '' then

			sendNotice(player:getPrices(), source)
			return true

		end

		sendNotice(("Your next %s will cost %d cookies."):format(element, cookie.buildings[element].price*(1.15^player[element])), source)
		return true

	elseif action == 'help' then
		com.help('cookie', source)
		return true

	elseif action and not (action == '') then
		sendNotice("Invalid action.", source)
		return true
	end

	sendNotice(player:list(), source)
	
	player:save()
	return true
end


return cookie.command