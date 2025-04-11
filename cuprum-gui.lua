local c = require("cuprum")

local windows = {}
local events = {}

local isRunning = true

local function quit()
    isRunning = false
end

local mainWindow = c.windows.createWindow(windows, "Cuprum", {1, 1}, {51, 19})
local keyboardEvent = c.events.addEventHandler(events, "key", quit)

while isRunning do
    c.windows.renderWindow(windows, term, mainWindow)
    term.setCursorPos(2, 3)
    term.write("Welcome to Cuprum!")
    term.setCursorPos(2, 5)
    term.write("Since this is a test version it won't have a lot")
    term.setCursorPos(2, 6)
    term.write("of content, so make sure to keep checking for new")
    term.setCursorPos(2, 7)
    term.write("updates!")
    term.setCursorPos(2, 18)
    term.write("Press any key to quit...")
    
    c.events.handlePendingEvents(events)
end

term.setTextColor(colors.white)
term.setBackgroundColor(colors.black)
term.setCursorPos(1, 1)
term.clear()
