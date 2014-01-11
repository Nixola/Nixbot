bot.commands:register("lua", function(code, source, target, silent)
    local f = io.open('code.lua', 'w')
    f:write(code)
    f:close()
    local sandbox = not masters[source:lower()]
    os.execute("ulimit -t 1 && lua "..(sandbox and "-l sandbox" or "").." code.lua > out 2>&1")
    f = io.open("out", 'r')
    local t = f:read '*a'
    f:close()
    t = t:gsub('[\n\r]', '; ')
    if #t > 400 then t = t:sub(1, 395)..'[...]' end
    if not silent then reply(source, target, t) end
    return t
end)