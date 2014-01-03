local Notes = {}
Notes.__index = Notes
Notes.module = Notes


Notes.load = function(nick)
    
    local t = setmetatable({nick = nick:lower()}, Notes)

    local f = io.open("clip/"..nick:lower(), "r")

    if not f then
        --empty, we'll see
    else
        for line in f:lines() do
            table.insert(t, line)
        end
    end

    return t

end


Notes.save = function(user)

    local str = table.concat(user, '\n')
    if #str > 500000 then --what are you even saving >500k
        sendNotice("Your notes are too big. Please delete some of them before adding anything else.", user.nick)
        return true
    end

    local f = io.open("clip/"..user.nick, "w")

    if not f then

        print("DEBUG:", "Can't write to clip/"..user.nick)--can't write? wat

    else
        f:write(str)
        f:close()
    end

end


Notes.command = function(args, source, target)

    args = args or ''

    args = args:match("^%s*(.-)%s*$") --string.strip or something

    local action, arg = args:match("^(.-)%s+(.-)$") --string.split once over space

    local user = Notes.load(source)

    if not (arg or action) then

        reply(source, target, "You have "..#user.." notes.")
        return true

    elseif not arg then

        sendNotice("Missing argument here!", source)
        return true

    else

        if action == "add" then

            user[#user+1] = arg
            user:save()
            sendNotice("Note "..#user.." added.", source)
            return true

        elseif action == "show" then

            local arg = tonumber(arg)

            if not arg then

                sendNotice("This is not a number.", source)
                return true

            end

            if not user[arg] then

                sendNotice("You don't have so many notes, you know.", source)
                return true

            end

            reply(source, target, user[arg])
            return true

        elseif (action == "rem") or (action == "remove") or (action == "rm") or (action == "delete") or (action == "del") then

            local arg = tonumber(arg)

            if not arg then

                sendNotice("This is not a number.", source)
                return true

            end

            if not user[arg] then

                sendNotice("You don't have so many notes, you know.", source)
                return true

            end

            table.remove(user, arg)
            user:save()
            return true

        else

            sendNotice("Invalid action.", source)
            return true

        end

    end

end

return Notes
