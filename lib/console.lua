local console = {}
local stdlib = require("lib.stdlib")

function console.addCommand(commands, name, func)
    table.insert(commands, {name, func})
    return #commands
end

function console.setCommandName(commands, commandID, command)
    commands[commandID][1] = name
end

function console.setCommandHandler(commands, commandID, func)
    commands[commandID][2] = func
end

function console.removeCommand(commands, commandID)
    return table.remove(commands, commandID)
end

function console.runCommand(commands, command)
    local parsed = stdlib.string.split(command, " ")
    local name = parsed[1]
    local args = {}
    for i = 2, #parsed do table.insert(args, parsed[i]) end
    for k, v in pairs(commands) do
        if v[1] == name then
            return v[2](args)
        end
    end
end

return console
