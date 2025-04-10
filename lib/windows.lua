-- CODE
local windows = {}

function windows.createWindow(windowList, title, pos, size)
    table.insert(windowList, {title, pos, size})
    return #windowList
end

function windows.setWindowTitle(windowList, id, title)
    windowList[id][1] = title
end

function windows.setWindowPos(windowList, id, pos)
    windowList[id][2] = pos
end

function windows.setWindowSize(windowList, id, size)
    windowList[id][3] = size
end

function windows.destroyWindow(windowList, id)
    return table.remove(windowList, id)
end

function windows.renderWindow(windowList, term, id)
    local window = windowList[id]
    local title = window[1]
    local xy, wh = window[2], window[3]
    local x, y = xy[1], xy[2]
    local w, h = wh[1], wh[2]
    term.setCursorPos(x, y)
    term.setTextColor(colors.white)
    term.setBackgroundColor(colors.blue)
    term.write(title .. string.rep(" ", w - #title))
    for i = y+1, y+h+1 do
        term.setCursorPos(x, i)
        term.setTextColor(colors.black)
        term.setBackgroundColor(colors.lightGray)
        term.write(string.rep(" ", w))
    end
end

-- END
return windows
