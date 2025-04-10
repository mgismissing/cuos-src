local events = {}

function events.addEventHandler(eventHandlers, event, func)
    table.insert(eventHandlers, {event, func})
    return #eventHandlers
end

function events.setEventType(eventHandlers, eventID, event)
    eventHandlers[eventID][1] = event
end

function events.setEventHandler(eventHandlers, eventID, func)
    eventHandlers[eventID][2] = func
end

function events.removeEventHandler(eventHandlers, eventID)
    return table.remove(eventHandlers, eventID)
end

function events.handlePendingEvents(eventHandlers)
    local eventData = {os.pullEvent()}
    local event = eventData[1]
    local args = {}
    for i = 2, #eventData do
        table.insert(args, eventData[i])
    end
    for k, v in pairs(eventHandlers) do
        if event == v[1] then
            return v[2](args)
        end
    end
end

return events
