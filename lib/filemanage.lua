local filemanage = {}

function filemanage.overwrite(filename, content)
    local file = fs.open(filename, "w")
    file.write(content)
    file.close()
end

return filemanage