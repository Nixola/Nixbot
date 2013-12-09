local baseUpgrade = {__index = {add1 = 0, multiply = 1, add2 = 0}}
local c = function(t) return setmetatable(t, baseUpgrade) end
return {
    cursors = {
       {name = "Reinforced index finger",
        requirements = "1 cursor",
        effectStr = "Each cursor gains 0.02 cps",
        gettable = function(player) return player.cursor >= 1 end,
        price = 66.6,
        effect = function(player) return c{add1 = 0.02} end},
       {name = "Carpal tunnel prevention cream",
        requirements = "1 cursor",
        effectStr = "Each cursor gets double cps",
        gettable = function(player) return player.cursor >= 1 end,
        price = 400/3*2,
        effect = function(player) return c{multiply = 2} end},
       {name = "Ambidestrous",
        requirements = "10 cursors",
        effectStr = "Each cursor gets double cps",
        price = 10000/3*2,
        effect = function(player) return c{multiply = 2} end},
