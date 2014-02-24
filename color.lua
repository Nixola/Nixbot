local string = require("string")
local color = {}

function color.strip(text)
    return text:gsub("(%d*),?(%d*)", "")
end

function color.mircToAnsi(text)
    local b = 0
    text = tostring(text)
    local text = text:gsub(string.char(2), function()
        b = b + 1
        local char = b%2 == 1 and 1 or 22
        return string.char(27) .. "["..char.."m"
    end)
    local u = 0
    local text = text:gsub("", function()
        u = u + 1
        local char = u%2 == 1 and 4 or 24
        return string.char(27) .. "["..char.."m"
    end)
    local n = 0
    local text = text:gsub(string.char(0x16), function()
        n = n + 1
        local char = n%2 == 1 and 7 or 27
        return string.char(27).."["..char.."m"
    end)
    return text:gsub("(%d*),?(%d*)", function(fg, bg)
        local fg = color.mircToAnsi256(tonumber(fg or 0))
        local bg = (bg or not fg) and color.mircToAnsi256(tonumber((bg or 0)), true) or ""
        return bg..fg
    end) .. string.char(27) .. "[0m"
end

--[[
function color.mircToAnsi(c, is_bg)
    local char = 3
    if is_bg then char = 4 end
    if c == 0 then      return string.char(27) .. "[1;"..char.."7m"
    elseif c == 1 then  return string.char(27) .. "["..char.."0m"
    elseif c == 2 then  return string.char(27) .. "["..char.."4m"
    elseif c == 3 then  return string.char(27) .. "["..char.."2m"
    elseif c == 4 then  return string.char(27) .. "[1;"..char.."1m"
    elseif c == 5 then  return string.char(27) .. "["..char.."1m"
    elseif c == 6 then  return string.char(27) .. "["..char.."5m"
    elseif c == 7 then  return string.char(27) .. "["..char.."3m"
    elseif c == 8 then  return string.char(27) .. "[1;"..char.."3m"
    elseif c == 9 then  return string.char(27) .. "[1;"..char.."2m"
    elseif c == 10 then return string.char(27) .. "["..char.."6m"
    elseif c == 11 then return string.char(27) .. "[1;"..char.."6m"
    elseif c == 12 then return string.char(27) .. "[1;"..char.."4m"
    elseif c == 13 then return string.char(27) .. "[1;"..char.."5m"
    elseif c == 14 then return string.char(27) .. "[1;"..char.."0m"
    elseif c == 15 then return string.char(27) .. "["..char.."7m"
    else                return string.char(27) .. "[0m" end
end
--]]

color.mircToAnsi256 = function(c, isBG)
    local bg = string.char(0x1b).."[48;5;"
    local fg = string.char(0x1b).."[38;5;"
    local c2 = isBG and bg or fg
    if c == 0 then      return c2 .. "15m"
    elseif c == 1 then  return c2 .. "0m"
    elseif c == 2 then  return c2 .. "4m"
    elseif c == 3 then  return c2 .. "2m"
    elseif c == 4 then  return c2 .. "9m"
    elseif c == 5 then  return c2 .. "1m"
    elseif c == 6 then  return c2 .. "5m"
    elseif c == 7 then  return c2 .. "3m"
    elseif c == 8 then  return c2 .. "11m"
    elseif c == 9 then  return c2 .. "10m"
    elseif c == 10 then return c2 .. "6m"
    elseif c == 11 then return c2 .. "14m"
    elseif c == 12 then return c2 .. "12m"
    elseif c == 13 then return c2 .. "13m"
    elseif c == 14 then return c2 .. "8m"
    elseif c == 15 then return c2 .. "7m"
    else                return string.char(0x1b).."[".. (isBG and 4 or 3) .."9m" end
end

function color.format(text)
    return text:gsub("{(%w-)}", color.color)
end

function color.color(name)
    if name == "darkgreen"
        or name == "dg"
        or name == "green"
        or name == "g" then
            return "3"
    elseif name == "lightgreen"
        or name == "lgreen"
        or name == "lime"
        or name == "lg" then
            return "9"
    elseif name == "yellow"
        or name == "y" then
            return "8"
    elseif name == "blue"
        or name == "navy"
        or name == "b" then
            return "2"
    elseif name == "black"
        or name == "k" then
            return "1"
    elseif name == "white"
        or name == "w" then
            return "0"
    elseif name == "red"
        or name == "r" then
            return "4"
    elseif name == "brown"
        or name == "maroon"
        or name == "m" then
            return "5"
    elseif name == "purple"
        or name == "p" then
            return "6"
    elseif name == "orange"
        or name == "olive"
        or name == "o" then
            return "7"
    elseif name == "teal"
        or name == "t" then
            return "10"
    elseif name == "cyan"
        or name == "aqua"
        or name == "c" then
            return "11"
    elseif name == "lightblue"
        or name == "lblue"
        or name == "lb" then
            return "12"
    elseif name == "pink"
        or name == "fuchsia"
        or name == "f" then
            return "13"
    elseif name == "grey"
        or name == "dgrey"
        or name == "darkgrey"
        or name == "gray"
        or name == "dgray"
        or name == "darkgray" then
            return "14"
    elseif name == "lgrey"
        or name == "lightgrey"
        or name == "lgray"
        or name == "lightgray" then
            return "15"
    elseif name == "underline"
        or name == "u" then
            return string.char(31)
    elseif name == "normal"
        or name == "n" then
            return ""
    else
        return ""
    end
end

return color
