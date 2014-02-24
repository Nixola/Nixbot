local mathEnv = setmetatable({tau = math.pi * 2}, {__index = function(t, k) return rawget(t, k) or math[k] end})
mathEnv.math = mathEnv

bot.commands:register("math", function(code, source, target)
    if not code or #code == 0 then sendNotice("Do you want me to guess the expression you wanna know the result of?", source) return end
    if code:find '"' or code:find "'" or code:find '{' or code:find 'function' or code:match "%[%=*%[" or code:find '%.%.' then sendNotice("You just WON'T hang me. Fuck you.", source) return end
    local expr, err = loadstring("return "..code)
    if not expr then --[[sendNotice(err, source)]] return end
    setfenv(expr, mathEnv)
    local results = {pcall(expr)}
    if not results[1] then --[[sendNotice(results[2], source)]] return end
    local maxN = table.maxn(results)
    for i = maxN, 1, -1 do
        if results[i] == nil then table.remove(results, i) end
    end
    if results[2] == nil then
        sendNotice("Your expression has no result.", source)
        return
    end
    if #results == 2 then
        reply(source, target, "= "..tostring(results[2])..".")
    else 
        table.remove(results, 1)
        for i, v in ipairs(results) do
            results[i] = tostring(v)
        end
        reply(source, target, "= " .. table.concat(results, ', ') .. ".")
    end
    return true
end)
