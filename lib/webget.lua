local webget = {}

local filemanage = require("lib.filemanage")

function webget.downloadFromURL(url, filename)
    local response = http.get(url)
    if response then
        local content = response.readAll()
        response.close()
        
        filemanage.overwrite(filename, content)
        return true
    end
    return false
end

return webget