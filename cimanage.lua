local _VERSION = "1.0"

local cuprum_repo = "http://www.github.com/mgismissing/cuprum-src/"
local cuprum_repo_api = "http://api.github.com/repos/mgismissing/cuprum-src/"
print("Welcome to the Cuprum Installations Manager!")
local args = {...}
local ver = args[1]
local versions_path = "/cuprum/versions/"
local apiString = ""

-- Tar Extractor
function extractTar(path, rootDir)
    local file = fs.open(path, "rb")
    local function readBlock()
        local block = file.read(512)
        if not block or #block == 0 then
            return nil
        end
        return block
    end
    
    local function parseHeader(block)
        local name = block:sub(1, 100):gsub("%z.*", "")
        local sizeStr = block:sub(125, 136):gsub("%z.*", "")
        local size = tonumber(sizeStr, 8) or 0
        return name, size
    end
    
    while true do
        local header = readBlock()
        if not header or header == string.rep("\0", 512) then
            break
        end
        
        local name, size = parseHeader(header)
        if name ~= "" then
            if name:sub(-1) == "/" then
                print("Moving to \"" .. name .. "\"")
            else
                print("Extracting \"" .. name .. "\" (" .. size .. " bytes)")
            end
            
            local blocks = math.ceil(size / 512)
            local content = ""
            for i = 1, blocks do
                content = content .. (file.read(512) or "")
            end
            
            content = content:sub(1, size)
            
            if name:sub(-1) ~= "/" then
                local dir = fs.getDir(name)
                if dir and not fs.exists(rootDir .. dir) then
                    fs.makeDir(rootDir .. dir)
                end
                
                local out = fs.open(rootDir .. name, "w")
                out.write(content)
                out.close()
            else
                if not fs.exists(rootDir .. name) then
                    fs.makeDir(rootDir .. name)
                end
            end
        end
    end
        
    file.close()
end

local toInstall = ""
local action = ""

if ver then
    action = "install"
    apiString = "-api"
    toInstall = ver
    print("Installing requested version (" .. toInstall .. apiString .. ")...")
else
    if fs.exists(versions_path) and fs.list(versions_path)[1] then
        print("Available Cuprum versions:")
        local versions = fs.list(versions_path)
        
        for k, v in pairs(versions) do
            if fs.isDir(versions_path .. v) then print(v) end
        end
        print("\nType a version name to get its path, \"install\" to install a new one or anything else to quit.")
        ans = string.lower(read())
        if ans == "install" then
            action = "install"
            print("What do you want to install? [EVERYTHING/api]")
            ans = string.lower(read())
            if ans == "api" then
                apiString = "-api"
            end
        end
        for k, v in pairs(versions) do
            if string.lower(v) == ans then
                print(versions_path .. v .. "/")
                break
            end
        end
    else
        print("No Cuprum installation detected.")
        print("Would you like to install one? [Y/n]")
        ans = string.lower(read())
        if ans ~= "n" then
            action = "install"
            print("What do you want to install? [EVERYTHING/api]")
            ans = string.lower(read())
            if ans == "api" then
                apiString = "-api"
            end
        end
    end
    if ans ~= "n" and action == "install" then
        print("Which version would you like to install?")
        print("(Press Enter to install the latest version)")
        print("To see a list of versions, go to")
        print("github.com/mgismissing/cuprum-src/releases")
        ans = string.lower(read())
        toInstall = ""
        local valid = false
        if ans == "" then
            toInstall = "latest"
        else
            print("Checking for version...")
            toInstall = ans
        end
    end
end

if action == "install" then
    local releases = textutils.unserializeJSON(http.get(cuprum_repo_api .. "releases").readAll())
    local installLink = ""
    for _, v in pairs(releases) do
        if toInstall == "latest" or v["tag_name"] == toInstall then
            toInstall = v["tag_name"]
            installLink = cuprum_repo .. "releases/download/" .. toInstall .. "/cuprum" .. apiString .. ".tar"
            valid = true
            break
        end
    end
    if valid then
        print("Downloading version " .. toInstall .. apiString .. "...")
        if http.get(installLink, {}, true) then
            local file_src = http.get(installLink, {}, true).readAll()
            local file_path = versions_path .. toInstall .. apiString .. ".tar"
            local file = fs.open(file_path, "wb")
            file.write(file_src)
            file.close()
            print("Extracting tar file...")
            extractTar(file_path, versions_path .. toInstall:gsub("%.", "_") .. apiString .. "/")
            print("Cleaning up...")
            fs.delete(file_path)
            print("Cuprum " .. toInstall .. apiString .. " installed successfully.")
        else
            term.setTextColor(colors.red)
            print("Could not fetch version " .. toInstall .. apiString .. " from \"" .. installLink .. "\"")
            term.setTextColor(colors.white)
        end
    else
        term.setTextColor(colors.red)
        print("Version doesn't exist. Please specify a valid Cuprum version.")
        term.setTextColor(colors.white)
    end
end