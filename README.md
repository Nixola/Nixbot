Nixbot
======

Nixbot is a single channel IRC bot made with LÖVE (http://love2d.org) based on Kawata's code that uses Nikolai Resokav's (http://nikolairesokav.com) LoveFrames as GUI.
It will answer to te sentences "Nixbot!", "Bots!" and "Circuloid!", as well as some commands that I'm about to list.
Some of those commands can only be used by a Master. Every LÖVE developer is recognized as a Rank 0 master, as well as me.
If a command requires a Master, it will accept any master. If it requires a Rank 0 Master, it has to be a hardcoded one.
There's currently no way to add a Rank 0 master in runtime and I don't want to add one, even though it would be easy.

Commands list:
!poke nick: sends a mean CTCP ACTION command which has nick as object (e.g: Nixbot installed Windows Vista on Nixola's PC).\n
!quit: shuts the bot down. A Master is required.\n
!lock: locks the bot, so that it will ignore every message but Masters' ones. A Master is required.\n
!free: unlocks the bot, so that it will parse everyone's messages again.\n
!obey nick: makes nick a Rank 1 Master. A Master is required.\n
!disobey nick: revokes the Master status on Nix. A Rank 0 Master is required.\n
!join channel: makes the bot part from the current channel to join a new one. A Master is required.\n
!secret: it can only be called by Nix. Makes Nix the only Master, a Rank 0 one.\n
!help: sends informations toabout itself to users.\n
