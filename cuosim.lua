local _VERSION = "1.0"

local cuos_repo = "http://www.github.com/mgismissing/cuos-src/"
local cuos_repo_api = "http://api.github.com/repos/mgismissing/cuos-src/"
print("Welcome to the CopperOS Installations Manager!")
local args = {...}
local ver = args[1]
local versions_path = "/cuos/versions/"

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
            print("Extracting \"" .. name .. "\" (" .. size .. " bytes)")
            
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
local toRun = ""
local action = ""

if ver then
    action = "install"
    print("Installing requested version (" .. ver .. ")...")
    toInstall = ver
else
    if fs.exists(versions_path) and fs.list(versions_path)[1] then
        print("Available CopperOS versions:")
        local versions = fs.list(versions_path)
        
        for k, v in pairs(versions) do
            if fs.isDir(versions_path .. v) then print(v) end
        end
        print("\nType a version name to start it, or anything else to install a new one.")
        ans = read()
        for k, v in pairs(versions) do
            if v == ans then
                action = "run"
                toRun = ans
                break
            end
        end
    else
        print("No CopperOS installation detected.")
        print("Would you like to install one? [Y/n]")
        ans = string.lower(read())
    end
    if ans ~= "n" and action == "install" then
        print("Which version would you like to install?")
        print("(Press Enter to install the latest version)")
        print("To see a list of versions, go to")
        print("github.com/mgismissing/cuos-src/releases")
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
    local releases = textutils.unserializeJSON(http.get(cuos_repo_api .. "releases").readAll())
    local installLink = ""
    for _, v in pairs(releases) do
        if toInstall == "latest" or v["tag_name"] == toInstall then
            toInstall = v["tag_name"]
            installLink = cuos_repo .. "releases/download/" .. toInstall .. "/cuos.tar"
            valid = true
            break
        end
    end
    if valid then
        print("Downloading version " .. toInstall .. "...")
        if http.get(installLink, {}, true) then
            local file_src = http.get(installLink, {}, true).readAll()
            local file_path = versions_path .. toInstall .. "/cuos.tar"
            local file = fs.open(file_path, "wb")
            file.write(file_src)
            file.close()
            print("Extracting tar file...")
            extractTar(file_path, versions_path .. toInstall .. "/")
            print("Cleaning up...")
            fs.delete(file_path)
            print("CopperOS " .. toInstall .. " installed successfully.")
        else
            term.setTextColor(colors.red)
            print("Could not fetch version " .. toInstall .. " from \"" .. installLink .. "\"")
            term.setTextColor(colors.white)
        end
    else
        term.setTextColor(colors.red)
        print("Version doesn't exist. Please specify a valid CopperOS version.")
        term.setTextColor(colors.white)
    end
else
    print("In which mode do you want CUOS to run in [GUI/cli]?")
    ans = string.lower(read())
    local mode = "gui"
    if ans == "cli" then
        mode = "cli"
    end
    os.run({}, versions_path .. toRun .. "/cuos-" .. mode .. "lua")
end