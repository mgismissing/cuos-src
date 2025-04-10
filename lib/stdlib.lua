local stdlib = {
    string = {}
}

function stdlib.string.split(string, sep)
    if sep == nil then sep = "%s" end
    local t = {}
    for str in string.gmatch(string, "([^".. sep .. "]+)") do
        table.insert(t, str)
    end
    return t
end

return stdlib
