Nixbot
======

Nixbot is a single channel IRC bot made with LÖVE (http://love2d.org) based on Kawata's code that uses Nikolai Resokav's (http://nikolairesokav.com) LoveFrames as GUI.
It will answer to the sentences "Nixbot!", "Bots!" and "Circuloid!", as well as some commands that I'm about to list.
Some of those commands can only be used by a Master. Every LÖVE developer is recognized as a Rank 0 master, as well as me.
If a command requires a Master, it will accept any master. If it requires a Rank 0 Master, it has to be a hardcoded one.
There's currently no way to add a Rank 0 master in runtime and I don't want to add one, even though it would be easy.



Commands list:

!poke \<nick\>: sends a mean CTCP ACTION command which has nick as object (e.g: Nixbot installed Windows Vista on Nixola's PC).

!quit: shuts the bot down. A Master is required.

!lock: locks the bot, so that it will ignore every message but Masters' ones. A Master is required.

!free: unlocks the bot, so that it will parse everyone's messages again.

!obey \<nick\>: makes nick a Rank 1 Master. A Master is required.

!disobey \<nick\>: revokes the Master status on nick. A Rank 0 Master is required.

!join \<channel\>: makes the bot part from the current channel to join a new one. A Master is required.

!ignore \<nick\>: makes the bot ignore every nick's message until !listen nick is used. A Master is required.

!listen \<nick\>: makes the bot listen again to an ignored user. A Master is required.

!math \<expression\>[, <expressions>]: makes the bot evaluate expression (or the expressions) and send either a message or a notice with the result[s].

!lua \<code\>: runs sandboxed and ulimit(-t 1)ed Lua code, printing or noticing the result.

!google \<query\>: too lazy to google for something? Let Nixbot google that for you!

!s \<Lua pattern\> \<string\>: iterates backwards through the received messages, until it finds one which matches the pattern, substituting each match with the string.

!cookie \<\[action\]\> \<\[element\]\> \<\[param\]\>: Cookie is a shamelessly limited copy of Orteil's Cookie Clicker. Since I'm too lazy to write how to use it, check it in the code.

!help: sends this message as a notice to who calls it.
