# Highscöre
Highscöre is a library for easy server-side storage of global highscores with an accompanying client-side library for easy server interaction.
It has been designed for usage with [LÖVE](http://love2d.org/) in mind.

## Requirements
The server-side requires [lstate](https://github.com/TheLinx/lstate) and [Luasocket](http://w3.impa.br/~diego/software/luasocket/) installed and available for Lua.
The client-side only requires Luasocket, which is available out-of-box in LÖVE.

## The files
### gen_config.lua
This is an interactive Lua script to generate a config.lua file used by server.lua and control_server.lua.
### server.lua
This is the server executable that binds to a UDP port.
It can only be closed cleanly using control_server.lua.
### control_server.lua
This is an interactive shell that interacts with a Highscöre server on 127.0.0.1 (localhost).
Press Ctrl+D to exit.
For information on the available commands, take a look at the protocol reference down below.
### highscore.lua
This is the client library that you include with your application.
**Note:** You need to input the server IP and port in the actual file.

## Protocol reference
The protocol is a simple text-based setup.
Commands are sent as _command arguments separated by spaces_.
Hence, a command name can not contain any spaces.
Some commands may return "badly formatted command" or "invalid category".
Unless otherwise specified, they return "ok" on success.
Here is a list of the commands:
### save (local only)
Forces a save of the scores to disk. Only matters if you use lstate storage.
### reload (local only)
Forces a load of scores from disk. This overwrites any scores currently in memory. Only matters if you use lstate storage.
### quit (local only)
Saves scores and performs a clean exit.
### new_category asc_or_desc(%d) name(.+) (local only)
asc_or_desc specifies whether the scores should be sorted by lower-is-better or higher-is-better. If 1, lower is better. Otherwise, higher is better.
name specifies the name of the category.
Returns "ok" on success.
### clear [optional: category(.+)] (local only)
If category name is specified, clears scores in specified category. Otherwise, clears all scores. (But keeps categories)
### get amount(%d+) start(%d+) category(.+)
amount specifies the amount of scores to get.
start specifies what score to start from. Useful for pagination.
category specifies what category to get scores from.
Returns a newline separated list formatted as "global-place(%d+) score(%d+) name(.+)" on success.
### new score(%d+) category(^[ ]+) name(.+)
score is the score. Surprise!
category is the name of the category to insert the score in.
name is the name of the player.

## highscore.lua reference
The client-side library has been designed with extreme simplicity in mind.
It exposes two functions. These functions always return gracefully except if something happens that shouldn't happen.
If they encounter an error, they will return nil and a string describing the error.

### highscore.new(score (number), name (string), category (string))
Sends a new score to the server.
Returns true on success.

### highscore.get(category (string), amount (number), start (optional number, defaults to 1))
Gets a sequence (ipairs-iterable table) of scores as sequences defined as {global-scoreboard-place (number), score (number), name (string)}
