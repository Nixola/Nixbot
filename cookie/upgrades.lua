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
        gettable = function(player) return player.cursor >= 10 end,
        price = 10000/3*2,
        effect = function(player) return c{multiply = 2} end},

       {name = "Thousand fingers",
        requirements = "20 cursors",
        effectStr = "Each cursor gains 0.02 cps for each non-cursor building",
        gettable = function(player) return player.cursor >= 20 end,
        price = 500000/3*2,
        effect = function(player) local s = 0; for i = 2, #cookie.buildings do s = s + player[cookie.buildings[i].name] end; return c{add2 = 0.02*s} end;},

       {name = "Million fingers", 
        requirements = "40 cursors",
        effectStr = "Each cursor gains 0.1 cps for each non-cursor building",
        gettable = function(player) return player.cursor >= 40 end,
        price = 50000000/3*2,
        effect = function(player) local s = 0; for i = 2, #cookie.buildings do s = s + player[cookie.buildings[i].name] end; return c{add2 = 0.1*s} end;},

       {name = "Billion fingers",
        requirements = "80 cursors",
        effectStr = "Each cursor gains 0.4 cps for each non-cursor building",
        gettable = function(player) return player.cursor >= 80 end,
        price = 500000000/3*2,
        effect = function(player) local s = 0; for i = 2, #cookie.buildings do s = s + player[cookie.buildings[i].name] end; return c{add2 = 0.4*s} end;},

       {name ="Trillion fingers",
        requirements = "120 cursors",
        effectStr = "Each cursor gains 2 cps for each non-cursor building",
        gettable = functon(player) return player.cursor >= 120 end,
        price = 5000000000/3*2
        effect = function(player) local s = 0; for i = 2, #cookie.buildings do s = s + player[cookie.buildings[i].name] end; return c{add2 = 2*s} end;},

       {name = "Quadrillion fingers",
        requirements = "160 cursors",
        effectStr = "Each cursor gains 4 cps for each non-cursor building",
        gettable = function(player) return player.cursor >= 160 end,
        price = 50000000000/3*2
        effect = function(player) local s = 0; for i = 2, #cookie.buildings do s = s + player[cookie.buildings[i].name] end; return c{add2 = 2*s} end;},

       {name =
        requirements = 
        effectStr =
        gettable = 
        price =
        effect = },

       {name =
        requirements = 
        effectStr =
        gettable = 
        price =
        effect = }
    },