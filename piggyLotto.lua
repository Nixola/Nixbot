settings = {showSource = false}

--settings.Master = true

masters = {
    paulynopoops = false,
    nix = false,
    piggydev = false,
}

ignored = {}

bot = {
	uname = "PigLotto",
	nick = "PigLotto",
	address = "irc.freenode.net",
	port = 6667,
	channel = "",
    startup = function()
        irc:send ": PRIVMSG Nickserv :identify PigLotto HeroAa333\r\n"
    end,
    plugins = {
--      "1doge.lua",
--      "1mint.lua",
        "1piggy.lua",
--      "bark.lua",
--      "beer.lua",
--      "clip.lua",
        "control.lua",
--      "cookie.lua",
--      "dogeDice.lua", 
--      "dogeLotto.lua",
--      "fortune.lua",
--      "google.lua",
--      "help.lua",
--      "lua.lua",
--      "math.lua",
--      "mintDice.lua",
--      "op.lua",
        "piggyLotto.lua",
--      "poke.lua",
        "print.lua",
        "reminder.lua",
--      "sed.lua",

    }
}

bot.print = function(...)

	--[[
	print(...)--]]

end
