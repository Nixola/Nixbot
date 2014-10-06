settings = {showSource = false}

--settings.Master = true

masters = {
nixola = false}

ignored = {}

bot = {
	uname = "NixLotto",
	nick = "NixLotto",
	address = "chat.freenode.net",
	port = 6667,
	channel = "#WinDoge",
    startup = function()
        irc:send ": PRIVMSG Nickserv :identify Nixbot HeroAa333\r\n"
    end,
    plugins = {
        "1doge.lua",
--      "1mint.lua",
--      "bark.lua",
--      "beer.lua",
--      "clip.lua",
        "control.lua",
--      "cookie.lua",
--      "dogeDice.lua", 
        "dogeLotto.lua",
--      "fortune.lua",
--      "google.lua",
--      "help.lua",
--      "lua.lua",
--      "math.lua",
--      "mintDice.lua",
--      "op.lua",
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
