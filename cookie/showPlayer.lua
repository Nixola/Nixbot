names = {...}

cookie = {buildings = dofile 'settings.lua'}

b = function(str)

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

for i, name in ipairs(names) do

	local f = io.open(name, 'r')
	if not f then error 'absent player' end
	local t = {name = name}
	local l = f and f:read '*l' or os.time()
	t.lastTime = tonumber(string.match(l, int))
	t.cookies = tonumber(string.match(f and f:read '*l' or 1, float))

	for i, v in ipairs(cookie.buildings) do
		t[v.name] = tonumber(string.match(f and f:read '*l' or 0, int))
	end

	f:close()

	t.time = os.time()
	local dt = t.time - t.lastTime
	local cps = 0

	for i, v in ipairs(cookie.buildings) do
		local cs = v.cps
		local quant = t[v.name]
		t.cookies = t.cookies + quant*dt*cs
		cps = cps + quant*cs
	end

	t.cookies = t.cookies + 1
	t.cps = cps

	print("Name:   ", t.name)
	print("Cps:    ", b(t.cps))
	print("Cookies:", b(t.cookies))
	print''

end